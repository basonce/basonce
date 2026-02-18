import { createClient } from 'npm:@supabase/supabase-js@2';
import { ethers } from 'npm:ethers@6';

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const supabase = createClient(supabaseUrl, supabaseKey);

const NETWORKS = {
  bsc_testnet: {
    rpcUrl: 'https://data-seed-prebsc-1-s1.binance.org:8545',
    explorerUrl: 'https://testnet.bscscan.com',
    requiredConfirmations: 15
  },
  polygon_mumbai: {
    rpcUrl: 'https://rpc-mumbai.maticvigil.com',
    explorerUrl: 'https://mumbai.polygonscan.com',
    requiredConfirmations: 128
  },
  bsc: {
    rpcUrl: 'https://bsc-dataseed1.binance.org',
    explorerUrl: 'https://bscscan.com',
    requiredConfirmations: 15
  },
  polygon: {
    rpcUrl: 'https://polygon-rpc.com',
    explorerUrl: 'https://polygonscan.com',
    requiredConfirmations: 128
  }
};

const ERC20_ABI = [
  'function balanceOf(address owner) view returns (uint256)',
  'function decimals() view returns (uint8)',
  'event Transfer(address indexed from, address indexed to, uint amount)'
];

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Client-Info, Apikey',
};

async function checkDeposit(txHash: string, network: string, expectedAddress: string) {
  try {
    const networkConfig = NETWORKS[network as keyof typeof NETWORKS];
    if (!networkConfig) {
      throw new Error(`Unsupported network: ${network}`);
    }

    const provider = new ethers.JsonRpcProvider(networkConfig.rpcUrl);

    const tx = await provider.getTransaction(txHash);
    if (!tx) {
      return { error: 'Transaction not found' };
    }

    const receipt = await provider.getTransactionReceipt(txHash);
    if (!receipt) {
      return { error: 'Transaction receipt not found' };
    }

    const currentBlock = await provider.getBlockNumber();
    const confirmations = currentBlock - (receipt.blockNumber || 0);

    if (tx.to?.toLowerCase() !== expectedAddress.toLowerCase()) {
      return { error: 'Transaction is not sent to the expected address' };
    }

    const amount = ethers.formatEther(tx.value);

    return {
      txHash: tx.hash,
      from: tx.from,
      to: tx.to,
      amount,
      confirmations,
      requiredConfirmations: networkConfig.requiredConfirmations,
      status: confirmations >= networkConfig.requiredConfirmations ? 'completed' : 'confirming',
      blockNumber: receipt.blockNumber,
      gasUsed: receipt.gasUsed.toString()
    };
  } catch (error) {
    console.error('Error checking deposit:', error);
    return { error: error.message };
  }
}

async function monitorDeposits() {
  try {
    const { data: pendingDeposits, error } = await supabase
      .from('blockchain_deposits')
      .select('*')
      .in('status', ['pending', 'confirming']);

    if (error) throw error;

    for (const deposit of pendingDeposits || []) {
      const result = await checkDeposit(
        deposit.tx_hash,
        deposit.network,
        deposit.to_address
      );

      if (result.error) {
        await supabase
          .from('blockchain_deposits')
          .update({
            status: 'failed',
            updated_at: new Date().toISOString()
          })
          .eq('id', deposit.id);
        continue;
      }

      const updates: any = {
        confirmations: result.confirmations,
        status: result.status,
        block_number: result.blockNumber
      };

      if (result.status === 'completed' && deposit.status !== 'completed') {
        updates.credited_at = new Date().toISOString();
      }

      await supabase
        .from('blockchain_deposits')
        .update(updates)
        .eq('id', deposit.id);

      await supabase
        .from('blockchain_transactions')
        .upsert({
          user_id: deposit.user_id,
          type: 'deposit',
          tx_hash: deposit.tx_hash,
          network: deposit.network,
          currency: deposit.currency,
          amount: deposit.amount,
          from_address: deposit.from_address,
          to_address: deposit.to_address,
          status: result.status === 'completed' ? 'confirmed' : 'pending',
          block_number: result.blockNumber,
          confirmations: result.confirmations,
          gas_used: result.gasUsed
        }, { onConflict: 'tx_hash,type' });
    }

    return { success: true, processed: pendingDeposits?.length || 0 };
  } catch (error) {
    console.error('Error monitoring deposits:', error);
    throw error;
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const action = url.searchParams.get('action');

    if (action === 'check') {
      const txHash = url.searchParams.get('txHash');
      const network = url.searchParams.get('network');
      const address = url.searchParams.get('address');

      if (!txHash || !network || !address) {
        return new Response(
          JSON.stringify({ error: 'Missing required parameters' }),
          { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
        );
      }

      const result = await checkDeposit(txHash, network, address);

      return new Response(
        JSON.stringify(result),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    if (action === 'monitor') {
      const result = await monitorDeposits();

      return new Response(
        JSON.stringify(result),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    return new Response(
      JSON.stringify({ error: 'Invalid action' }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  }
});
