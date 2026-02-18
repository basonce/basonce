import { supabase } from './supabase';
import type { AlphaToken, AlphaTransaction, AlphaComment, AlphaCompetition, AlphaHolder, AlphaPricePoint } from '../types/alpha';

export async function fetchAlphaTokens(filter: string, network: string): Promise<AlphaToken[]> {
  let query = supabase
    .from('alpha_tokens')
    .select('*')
    .eq('status', 'active');

  if (network !== 'All') {
    query = query.eq('network', network);
  }

  switch (filter) {
    case 'trending':
      query = query.order('volume_24h', { ascending: false });
      break;
    case 'new':
      query = query.order('created_at', { ascending: false });
      break;
    case 'voted':
      query = query.order('community_score', { ascending: false });
      break;
    case 'graduated':
      query = query.eq('is_graduated', true).order('market_cap', { ascending: false });
      break;
    default:
      query = query.order('volume_24h', { ascending: false });
  }

  const { data, error } = await query.limit(50);
  if (error) throw error;
  return data || [];
}

export async function fetchRecentTransactions(limit = 30): Promise<AlphaTransaction[]> {
  const { data, error } = await supabase
    .from('alpha_transactions')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(limit);

  if (error) throw error;
  return data || [];
}

export async function fetchTokenTransactions(tokenId: string): Promise<AlphaTransaction[]> {
  const { data, error } = await supabase
    .from('alpha_transactions')
    .select('*')
    .eq('token_id', tokenId)
    .order('created_at', { ascending: false })
    .limit(50);

  if (error) throw error;
  return data || [];
}

export async function fetchTokenComments(tokenId: string): Promise<AlphaComment[]> {
  const { data, error } = await supabase
    .from('alpha_comments')
    .select('*')
    .eq('token_id', tokenId)
    .order('created_at', { ascending: false })
    .limit(50);

  if (error) throw error;
  return data || [];
}

export async function fetchTokenHolders(tokenId: string): Promise<AlphaHolder[]> {
  const { data, error } = await supabase
    .from('alpha_token_holders')
    .select('*')
    .eq('token_id', tokenId)
    .order('percentage', { ascending: false })
    .limit(20);

  if (error) throw error;
  return data || [];
}

export async function fetchPriceHistory(tokenId: string): Promise<AlphaPricePoint[]> {
  const { data, error } = await supabase
    .from('alpha_price_history')
    .select('*')
    .eq('token_id', tokenId)
    .order('timestamp', { ascending: true })
    .limit(200);

  if (error) throw error;
  return data || [];
}

export async function fetchActiveCompetition(): Promise<AlphaCompetition | null> {
  const { data, error } = await supabase
    .from('alpha_competitions')
    .select('*')
    .eq('status', 'active')
    .order('created_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  if (error) throw error;
  return data;
}

export function calculateBondingCurvePrice(raisedAmount: number, targetAmount: number, initialPrice: number): number {
  const progress = Math.min(raisedAmount / targetAmount, 1);
  const multiplier = 1 + progress * progress * 100;
  return initialPrice * multiplier;
}

export function calculatePriceImpact(amount: number, raisedAmount: number, targetAmount: number): number {
  const currentProgress = raisedAmount / targetAmount;
  const newProgress = Math.min((raisedAmount + amount) / targetAmount, 1);
  return ((newProgress - currentProgress) / currentProgress) * 100;
}

const FAKE_USERNAMES = [
  'CryptoKing42','MoonHunter','DegenTrader','DiamondHands88','ApeStrong',
  'WhaleAlert','GemFinder','BullRunner','TokenMaster','AlphaSeeker',
  'ChartWizard','PumpDetector','EarlyBird99','SolanaFan','DeFiPro',
  'MemeKing','CryptoNinja','BlockchainBro','YieldFarmer','GasOptimizer'
];

export function generateFakeTransaction(tokens: AlphaToken[]): AlphaTransaction {
  const token = tokens[Math.floor(Math.random() * tokens.length)];
  const isBuy = Math.random() > 0.35;
  const ui = Math.floor(Math.random() * FAKE_USERNAMES.length);
  const totalValue = token.raised_token === 'SOL'
    ? +(Math.random() * 15 + 0.5).toFixed(2)
    : token.raised_token === 'ETH'
      ? +(Math.random() * 0.8 + 0.01).toFixed(4)
      : +(Math.random() * 2.5 + 0.05).toFixed(3);

  return {
    id: crypto.randomUUID(),
    token_id: token.id,
    user_id: null,
    tx_type: isBuy ? 'buy' : 'sell',
    amount: Math.round(totalValue * 1000000 / Math.max(token.market_cap, 1)),
    price: token.current_price,
    total_value: totalValue,
    wallet_address: '0x' + Math.random().toString(16).slice(2, 6) + '...' + Math.random().toString(16).slice(2, 6),
    username: FAKE_USERNAMES[ui],
    avatar_url: `https://i.pravatar.cc/150?img=${10 + ui}`,
    token_symbol: token.symbol,
    token_name: token.name,
    raised_token: token.raised_token,
    created_at: new Date().toISOString(),
  };
}

export function generateBotTrade(token: AlphaToken): AlphaTransaction {
  const isBuy = Math.random() > 0.3;
  const ui = Math.floor(Math.random() * FAKE_USERNAMES.length);

  let totalValue: number;
  if (token.raised_token === 'SOL') {
    totalValue = +(Math.random() * 8 + 0.2).toFixed(2);
  } else if (token.raised_token === 'ETH') {
    totalValue = +(Math.random() * 0.5 + 0.005).toFixed(4);
  } else {
    totalValue = +(Math.random() * 1.5 + 0.02).toFixed(3);
  }

  const priceVariation = token.current_price * (1 + (Math.random() * 0.02 - 0.01));

  return {
    id: crypto.randomUUID(),
    token_id: token.id,
    user_id: null,
    tx_type: isBuy ? 'buy' : 'sell',
    amount: Math.round(totalValue / Math.max(priceVariation, 0.000001)),
    price: priceVariation,
    total_value: totalValue,
    wallet_address: '0x' + Math.random().toString(16).slice(2, 6) + '...' + Math.random().toString(16).slice(2, 6),
    username: FAKE_USERNAMES[ui],
    avatar_url: `https://i.pravatar.cc/150?img=${10 + ui}`,
    token_symbol: token.symbol,
    token_name: token.name,
    raised_token: token.raised_token,
    created_at: new Date().toISOString(),
  };
}
