import { createClient } from 'npm:@supabase/supabase-js@2';
import { ethers } from 'npm:ethers@6';

const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const supabase = createClient(supabaseUrl, supabaseKey);

const NETWORKS = {
  bsc_testnet: {
    rpcUrl: 'https://data-seed-prebsc-1-s1.binance.org:8545',
    chainId: 97
  },
  polygon_mumbai: {
    rpcUrl: 'https://rpc-mumbai.maticvigil.com',
    chainId: 80001
  },
  bsc: {
    rpcUrl: 'https://bsc-dataseed1.binance.org',
    chainId: 56
  },
  polygon: {
    rpcUrl: 'https://polygon-rpc.com',
    chainId: 137
  }
};

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Client-Info, Apikey',
};

async function createWithdrawal(
  userId: string,
  currency: string,
  network: string,
  amount: number,
  toAddress: string,
  fee: number
) {
  try {
    if (!ethers.isAddress(toAddress)) {
      return { error: 'Invalid withdrawal address' };
    }

    const { data: balance } = await supabase
      .from('balances')
      .select('available')
      .eq('user_id', userId)
      .eq('currency', currency)
      .single();

    if (!balance || balance.available < (amount + fee)) {
      return { error: 'Insufficient balance' };
    }

    const { data: limits } = await supabase
      .from('withdrawal_limits')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (limits) {
      const today = new Date();
      const lastReset = new Date(limits.last_reset);

      if (today.toDateString() !== lastReset.toDateString()) {
        await supabase
          .from('withdrawal_limits')
          .update({
            daily_used: 0,
            last_reset: today.toISOString()
          })
          .eq('user_id', userId);
      } else if (limits.daily_used + amount > limits.daily_limit) {
        return { error: 'Daily withdrawal limit exceeded' };
      }
    }

    const totalAmount = amount + fee;

    const { data: withdrawal, error } = await supabase
      .from('blockchain_withdrawals')
      .insert({
        user_id: userId,
        currency,
        network,
        amount,
        fee,
        total_amount: totalAmount,
        to_address: toAddress,
        status: 'pending'
      })
      .select()
      .single();

    if (error) throw error;

    await supabase
      .from('balances')
      .update({
        available: balance.available - totalAmount
      })
      .eq('user_id', userId)
      .eq('currency', currency);

    if (limits) {
      await supabase
        .from('withdrawal_limits')
        .update({
          daily_used: limits.daily_used + amount
        })
        .eq('user_id', userId);
    }

    return { success: true, withdrawal };
  } catch (error) {
    console.error('Error creating withdrawal:', error);
    return { error: error.message };
  }
}

async function processWithdrawal(withdrawalId: string) {
  try {
    const { data: withdrawal } = await supabase
      .from('blockchain_withdrawals')
      .select('*')
      .eq('id', withdrawalId)
      .single();

    if (!withdrawal) {
      return { error: 'Withdrawal not found' };
    }

    if (withdrawal.status !== 'pending') {
      return { error: 'Withdrawal already processed' };
    }

    const { data: hotWallet } = await supabase
      .from('hot_wallet_config')
      .select('*')
      .eq('network', withdrawal.network)
      .eq('currency', withdrawal.currency)
      .single();

    if (!hotWallet || !hotWallet.is_active) {
      await supabase
        .from('blockchain_withdrawals')
        .update({
          status: 'failed',
          error_message: 'Hot wallet not configured'
        })
        .eq('id', withdrawalId);

      return { error: 'Hot wallet not configured for this network' };
    }

    await supabase
      .from('blockchain_withdrawals')
      .update({
        status: 'processing',
        from_address: hotWallet.address
      })
      .eq('id', withdrawalId);

    return {
      success: true,
      message: 'Withdrawal is being processed. This would send crypto on mainnet.',
      testMode: true,
      withdrawal: {
        ...withdrawal,
        status: 'processing',
        note: 'In production, this would execute real blockchain transaction'
      }
    };

  } catch (error) {
    console.error('Error processing withdrawal:', error);

    await supabase
      .from('blockchain_withdrawals')
      .update({
        status: 'failed',
        error_message: error.message
      })
      .eq('id', withdrawalId);

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

    const { action, currency, network, amount, toAddress, fee, withdrawalId } = await req.json();

    if (action === 'create') {
      const result = await createWithdrawal(
        user.id,
        currency,
        network,
        amount,
        toAddress,
        fee || 0
      );

      return new Response(
        JSON.stringify(result),
        {
          status: result.error ? 400 : 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      );
    }

    if (action === 'process') {
      const result = await processWithdrawal(withdrawalId);

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
