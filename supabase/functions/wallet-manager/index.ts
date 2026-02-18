import { createClient } from 'npm:@supabase/supabase-js@2';
import { ethers } from 'npm:ethers@6';

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const supabase = createClient(supabaseUrl, supabaseKey);

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Client-Info, Apikey',
};

function encryptPrivateKey(privateKey: string): string {
  return btoa(privateKey);
}

function decryptPrivateKey(encrypted: string): string {
  return atob(encrypted);
}

async function generateWalletAddress(userId: string, network: string, currency: string) {
  try {
    const { data: existing } = await supabase
      .from('wallet_addresses')
      .select('*')
      .eq('user_id', userId)
      .eq('network', network)
      .eq('currency', currency)
      .eq('is_active', true)
      .single();

    if (existing) {
      return {
        address: existing.address,
        network,
        currency,
        existing: true
      };
    }

    const wallet = ethers.Wallet.createRandom();
    const address = wallet.address;
    const privateKeyEncrypted = encryptPrivateKey(wallet.privateKey);

    const { data, error } = await supabase
      .from('wallet_addresses')
      .insert({
        user_id: userId,
        network,
        address,
        currency,
        private_key_encrypted: privateKeyEncrypted,
        is_active: true
      })
      .select()
      .single();

    if (error) throw error;

    return {
      address,
      network,
      currency,
      existing: false
    };
  } catch (error) {
    console.error('Error generating wallet:', error);
    return { error: error.message };
  }
}

async function getWalletAddresses(userId: string) {
  try {
    const { data, error } = await supabase
      .from('wallet_addresses')
      .select('id, network, address, currency, is_active, created_at')
      .eq('user_id', userId)
      .eq('is_active', true);

    if (error) throw error;

    return { wallets: data };
  } catch (error) {
    console.error('Error fetching wallets:', error);
    return { error: error.message };
  }
}

async function recordDeposit(
  userId: string,
  txHash: string,
  network: string,
  currency: string,
  amount: number,
  fromAddress: string,
  toAddress: string
) {
  try {
    const { data: existing } = await supabase
      .from('blockchain_deposits')
      .select('id')
      .eq('tx_hash', txHash)
      .single();

    if (existing) {
      return { error: 'Deposit already recorded' };
    }

    const { data: walletAddress } = await supabase
      .from('wallet_addresses')
      .select('id')
      .eq('user_id', userId)
      .eq('address', toAddress)
      .eq('network', network)
      .single();

    const requiredConfirmations = network === 'bsc_testnet' ? 15 : 128;

    const { data, error } = await supabase
      .from('blockchain_deposits')
      .insert({
        user_id: userId,
        wallet_address_id: walletAddress?.id,
        tx_hash: txHash,
        network,
        currency,
        amount,
        from_address: fromAddress,
        to_address: toAddress,
        required_confirmations: requiredConfirmations,
        status: 'pending'
      })
      .select()
      .single();

    if (error) throw error;

    return { success: true, deposit: data };
  } catch (error) {
    console.error('Error recording deposit:', error);
    return { error: error.message };
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const token = authHeader.replace('Bearer ', '');
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const body = await req.json();
    const { action } = body;

    if (action === 'generate') {
      const { network, currency } = body;
      const result = await generateWalletAddress(user.id, network, currency);

      return new Response(
        JSON.stringify(result),
        {
          status: result.error ? 400 : 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    if (action === 'list') {
      const result = await getWalletAddresses(user.id);

      return new Response(
        JSON.stringify(result),
        {
          status: result.error ? 400 : 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    if (action === 'record_deposit') {
      const { txHash, network, currency, amount, fromAddress, toAddress } = body;
      const result = await recordDeposit(
        user.id,
        txHash,
        network,
        currency,
        amount,
        fromAddress,
        toAddress
      );

      return new Response(
        JSON.stringify(result),
        {
          status: result.error ? 400 : 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
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
