import { useState, useEffect } from 'react';
import {
  Eye,
  EyeOff,
  ChevronDown,
  ChevronRight,
  Search,
  MoreVertical,
  TrendingUp,
  Wallet as WalletIcon,
  History,
  User,
  Settings,
  Users,
  Gift,
  LayoutDashboard,
  Lock
} from 'lucide-react';
import { supabase } from '../lib/supabase';
import RealDepositModal from './RealDepositModal';
import RealWithdrawModal from './RealWithdrawModal';
import { checkWithdrawalPermission } from '../lib/withdrawal-permission';

interface Balance {
  symbol: string;
  name?: string;
  logo_url?: string;
  balance: number;
  locked_balance: number;
  price?: number;
}

interface Transaction {
  id: string;
  type: string;
  symbol: string;
  amount: number;
  created_at: string;
  notes: string;
}

export default function Wallet() {
  const [hideBalance, setHideBalance] = useState(false);
  const [balances, setBalances] = useState<Balance[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'coin' | 'account'>('coin');
  const [assetsExpanded, setAssetsExpanded] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [hideSmallBalances, setHideSmallBalances] = useState(false);
  const [showDepositModal, setShowDepositModal] = useState(false);
  const [showWithdrawModal, setShowWithdrawModal] = useState(false);
  const [isWithdrawalBlocked, setIsWithdrawalBlocked] = useState(false);
  const [currentTier, setCurrentTier] = useState(0);

  useEffect(() => {
    fetchBalances();
    fetchTransactions();
    checkPermission();

    let balanceChannel: any;
    let transactionChannel: any;

    supabase.auth.getUser().then(({ data: { user } }) => {
      if (!user) return;

      balanceChannel = supabase
        .channel('user_balances_changes')
        .on(
          'postgres_changes',
          {
            event: '*',
            schema: 'public',
            table: 'user_balances',
            filter: `user_id=eq.${user.id}`
          },
          () => {
            fetchBalances();
          }
        )
        .subscribe();

      transactionChannel = supabase
        .channel('transactions_changes')
        .on(
          'postgres_changes',
          {
            event: '*',
            schema: 'public',
            table: 'transactions',
            filter: `user_id=eq.${user.id}`
          },
          () => {
            fetchTransactions();
          }
        )
        .subscribe();
    });

    return () => {
      if (balanceChannel) balanceChannel.unsubscribe();
      if (transactionChannel) transactionChannel.unsubscribe();
    };
  }, []);

  const fetchBalances = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      console.log('🔍 FETCHING BALANCES - User ID:', user?.id);

      if (!user) {
        console.error('❌ NO USER FOUND');
        return;
      }

      const { data, error } = await supabase
        .from('user_balances')
        .select('*')
        .eq('user_id', user.id);

      console.log('📊 DATABASE RESPONSE:', { data, error });

      if (error) {
        console.error('❌ DATABASE ERROR:', error);
        throw error;
      }

      if (!data || data.length === 0) {
        console.warn('⚠️ NO BALANCES FOUND IN DATABASE');
        setBalances([]);
        return;
      }

      console.log('✅ RAW BALANCES FROM DB:', data);

      const { data: coinsData } = await supabase
        .from('supported_coins')
        .select('symbol, name, logo_url');

      const coinsMap = new Map(
        (coinsData || []).map(coin => [coin.symbol, coin])
      );

      const balancesWithPrices = await Promise.all(
        (data || []).map(async (balance) => {
          const coinInfo = coinsMap.get(balance.symbol);
          try {
            const response = await fetch(
              `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/binance-proxy?symbol=${balance.symbol}USDT`,
              {
                headers: {
                  'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
                },
              }
            );
            const priceData = await response.json();
            const parsed = {
              symbol: balance.symbol,
              name: coinInfo?.name || balance.symbol,
              logo_url: coinInfo?.logo_url || null,
              balance: parseFloat(balance.balance) || 0,
              locked_balance: parseFloat(balance.locked_balance) || 0,
              price: balance.symbol === 'USDT' ? 1 : parseFloat(priceData.lastPrice || priceData.price || '0')
            };
            console.log(`💰 PARSED ${balance.symbol}:`, parsed);
            return parsed;
          } catch {
            const parsed = {
              symbol: balance.symbol,
              name: coinInfo?.name || balance.symbol,
              logo_url: coinInfo?.logo_url || null,
              balance: parseFloat(balance.balance) || 0,
              locked_balance: parseFloat(balance.locked_balance) || 0,
              price: balance.symbol === 'USDT' ? 1 : 0
            };
            console.log(`💰 PARSED ${balance.symbol} (NO PRICE):`, parsed);
            return parsed;
          }
        })
      );

      console.log('✅ FINAL BALANCES WITH PRICES:', balancesWithPrices);
      setBalances(balancesWithPrices);
    } catch (error) {
      console.error('❌ CRITICAL ERROR fetching balances:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchTransactions = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data, error } = await supabase
        .from('transactions')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', { ascending: false })
        .limit(10);

      if (error) throw error;

      const parsedTransactions = (data || []).map(tx => ({
        ...tx,
        amount: parseFloat(tx.amount) || 0
      }));

      setTransactions(parsedTransactions);
    } catch (error) {
      console.error('Error fetching transactions:', error);
    }
  };

  const checkPermission = async () => {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    const permission = await checkWithdrawalPermission(user.id);
    if (!permission.allowed) {
      setIsWithdrawalBlocked(true);
      setCurrentTier(permission.currentTier);
    } else {
      setIsWithdrawalBlocked(false);
      setCurrentTier(5);
    }
  };

  const totalBalance = balances.reduce((sum, b) => sum + (b.balance * (b.price || 0)), 0);

  const filteredBalances = balances.filter(b => {
    if (hideSmallBalances && b.balance * (b.price || 0) < 1) return false;
    if (searchQuery && !b.symbol.toLowerCase().includes(searchQuery.toLowerCase())) return false;
    return true;
  });

  const getCoinName = (symbol: string) => {
    const names: { [key: string]: string } = {
      'BNB': 'BNB',
      'BTC': 'Bitcoin',
      'ETH': 'Ethereum',
      'USDT': 'TetherUS',
      'SOL': 'Solana',
      'ADA': 'Cardano',
      'DOT': 'Polkadot',
      'MATIC': 'Polygon'
    };
    return names[symbol] || symbol;
  };

  return (
    <div className="flex min-h-screen bg-[#0b0e11]">
      <aside className="w-64 bg-[#0b0e11] border-[#2b3139] flex flex-col">
        <div className="p-4">
          <div className="flex items-center space-x-2 mb-6">
            <LayoutDashboard className="w-5 h-5 text-[#f0b90b]" />
            <span className="text-[#eaecef] font-medium">Dashboard</span>
          </div>

          <nav className="space-y-1">
            <div className="mb-4">
              <button
                onClick={() => setAssetsExpanded(!assetsExpanded)}
                className="w-full flex items-center justify-between px-3 py-2 text-[#eaecef] hover:bg-[#2b3139] rounded transition-colors"
              >
                <div className="flex items-center space-x-2">
                  <WalletIcon className="w-4 h-4" />
                  <span className="text-sm">Assets</span>
                </div>
                {assetsExpanded ? <ChevronDown className="w-4 h-4" /> : <ChevronRight className="w-4 h-4" />}
              </button>

              {assetsExpanded && (
                <div className="ml-6 mt-1 space-y-1">
                  <button className="w-full px-3 py-2 text-[#eaecef] bg-[#2b3139] rounded">
                    Overview
                  </button>
                  <button className="w-full px-3 py-2 text-[#848e9c] hover:bg-[#2b3139] rounded transition-colors">
                    Spot
                  </button>
                  <button className="w-full px-3 py-2 text-[#848e9c] hover:bg-[#2b3139] rounded transition-colors">
                    Margin
                  </button>
                  <button className="w-full px-3 py-2 text-[#848e9c] hover:bg-[#2b3139] rounded transition-colors">
                    Third-Party Wallet
                  </button>
                </div>
              )}
            </div>

            <button className="w-full flex items-center space-x-2 px-3 py-2 text-[#848e9c] hover:bg-[#2b3139] rounded transition-colors">
              <History className="w-4 h-4" />
              <span className="text-sm">Orders</span>
            </button>

            <button className="w-full flex items-center space-x-2 px-3 py-2 text-[#848e9c] hover:bg-[#2b3139] rounded transition-colors">
              <Gift className="w-4 h-4" />
              <span className="text-sm">Rewards Hub</span>
            </button>

            <button className="w-full flex items-center space-x-2 px-3 py-2 text-[#848e9c] hover:bg-[#2b3139] rounded transition-colors">
              <Users className="w-4 h-4" />
              <span className="text-sm">Referral</span>
            </button>

            <button className="w-full flex items-center space-x-2 px-3 py-2 text-[#848e9c] hover:bg-[#2b3139] rounded transition-colors">
              <User className="w-4 h-4" />
              <span className="text-sm">Account</span>
            </button>

            <button className="w-full flex items-center space-x-2 px-3 py-2 text-[#848e9c] hover:bg-[#2b3139] rounded transition-colors">
              <Users className="w-4 h-4" />
              <span className="text-sm">Sub Accounts</span>
            </button>

            <button className="w-full flex items-center space-x-2 px-3 py-2 text-[#848e9c] hover:bg-[#2b3139] rounded transition-colors">
              <Settings className="w-4 h-4" />
              <span className="text-sm">Settings</span>
            </button>
          </nav>
        </div>
      </aside>

      <main className="flex-1 overflow-y-auto">
        <div className="max-w-[1400px] mx-auto p-6">
          <div className="bg-[#1e2329] rounded-lg p-6 mb-6">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center space-x-3">
                <h2 className="text-sm">Estimated Balance</h2>
                <button
                  onClick={() => setHideBalance(!hideBalance)}
                  className="text-[#848e9c] hover:text-[#eaecef] transition-colors"
                >
                  {hideBalance ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                </button>
              </div>
              <div className="flex space-x-2">
                <button
                  onClick={() => setShowDepositModal(true)}
                  className="px-4 py-2 bg-[#f0b90b] hover:bg-[#f8d12f] font-medium rounded text-sm transition-colors"
                >
                  Deposit
                </button>
                <button
                  onClick={() => setShowWithdrawModal(true)}
                  className="px-4 py-2 bg-[#2b3139] hover:bg-[#3b4149] rounded text-sm transition-colors"
                >
                  Withdraw
                </button>
                <button className="px-4 py-2 bg-[#2b3139] hover:bg-[#3b4149] rounded text-sm transition-colors">
                  Transfer
                </button>
                <button className="px-4 py-2 bg-[#2b3139] hover:bg-[#3b4149] rounded text-sm transition-colors">
                  History
                </button>
              </div>
            </div>

            <div className="flex items-baseline space-x-3 mb-1">
              <h1 className="text-4xl font-mono">
                {hideBalance ? '••••••••' : totalBalance.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
              </h1>
              <div className="flex items-center space-x-2">
                <span className="text-lg">USDT</span>
                <ChevronDown className="w-4 h-4 text-[#848e9c]" />
              </div>
            </div>
            <p className="text-sm">
              ≈ {hideBalance ? '••••' : totalBalance.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} USDT
            </p>

            {isWithdrawalBlocked && (
              <div className="mt-4 p-3 bg-yellow-500/10 border border-yellow-500/20 rounded-lg">
                <div className="flex items-center gap-2">
                  <Lock className="w-4 h-4 text-yellow-400 flex-shrink-0" />
                  <div className="text-sm text-yellow-400">
                    <span className="font-semibold">Withdrawal Locked</span> - Tier {currentTier}/5. Upgrade to unlock.
                  </div>
                </div>
              </div>
            )}
          </div>

          <div className="bg-[#1e2329] rounded-lg">
            <div className="flex items-center justify-between p-6 border-[#2b3139]">
              <div className="flex items-center space-x-6">
                <h3 className="text-lg font-medium">My Assets</h3>
                <button className="text-sm hover:text-[#f0b90b] transition-colors flex items-center space-x-1">
                  <span>View All 350+ Coins</span>
                  <ChevronRight className="w-4 h-4" />
                </button>
              </div>
            </div>

            <div className="p-6 border-[#2b3139]">
              <div className="flex items-center justify-between mb-4">
                <div className="flex space-x-4">
                  <button
                    onClick={() => setActiveTab('coin')}
                    className={`pb-2 border-b-2 transition-colors ${ activeTab === 'coin' ? 'border-[#f0b90b] text-[#eaecef]' : 'border-transparent text-[#848e9c] hover:text-[#eaecef]' }`}
                  >
                    Coin View
                  </button>
                  <button
                    onClick={() => setActiveTab('account')}
                    className={`pb-2 border-b-2 transition-colors ${ activeTab === 'account' ? 'border-[#f0b90b] text-[#eaecef]' : 'border-transparent text-[#848e9c] hover:text-[#eaecef]' }`}
                  >
                    Account View
                  </button>
                </div>

                <div className="flex items-center space-x-4">
                  <div className="relative">
                    <Search className="w-4 h-4 absolute left-3 top-1/2 transform -translate-y-1/2 text-[#848e9c]" />
                    <input
                      type="text"
                      placeholder="Small Amount Exchange"
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="pl-10 pr-4 py-2 bg-[#2b3139] rounded text-sm focus:ring-[#f0b90b] w-64"
                    />
                  </div>
                  <label className="flex items-center space-x-2 text-[#848e9c] cursor-pointer">
                    <input
                      type="checkbox"
                      checked={hideSmallBalances}
                      onChange={(e) => setHideSmallBalances(e.target.checked)}
                      className="rounded"
                    />
                    <span>Hide assets &lt;1 USD</span>
                  </label>
                </div>
              </div>

              {loading ? (
                <div className="py-12 text-[#848e9c]">Loading...</div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead>
                      <tr className="text-sm">
                        <th className="pb-4 font-normal">Coin</th>
                        <th className="pb-4 font-normal text-right">Amount</th>
                        <th className="pb-4 font-normal text-right">Coin Price</th>
                        <th className="pb-4 font-normal text-right">Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {filteredBalances.length === 0 ? (
                        <tr>
                          <td colSpan={4} className="py-12 text-[#848e9c]">
                            No assets found
                          </td>
                        </tr>
                      ) : (
                        filteredBalances.map((balance) => (
                          <tr key={balance.symbol} className="border-[#2b3139] hover:bg-[#2b3139]/30 transition-colors">
                            <td className="py-4">
                              <div className="flex items-center space-x-3">
                                <div className="w-8 h-8 rounded-full bg-[#f0b90b]/10 flex items-center justify-center overflow-hidden p-1">
                                  {balance.logo_url ? (
                                    <img
                                      src={balance.logo_url}
                                      alt={balance.symbol}
                                      className="w-full h-full object-contain"
                                      onError={(e) => {
                                        (e.target as HTMLImageElement).style.display = 'none';
                                        (e.target as HTMLImageElement).parentElement!.innerHTML = `<span class="text-[#f0b90b] font-semibold text-sm">${balance.symbol.charAt(0)}</span>`;
                                      }}
                                    />
                                  ) : (
                                    <span className="font-semibold text-sm">
                                      {balance.symbol.charAt(0)}
                                    </span>
                                  )}
                                </div>
                                <div>
                                  <div className="text-[#eaecef] font-medium">{balance.symbol}</div>
                                  <div className="text-xs">{balance.name || getCoinName(balance.symbol)}</div>
                                </div>
                              </div>
                            </td>
                            <td className="py-4 text-right">
                              <div className="text-[#eaecef] font-mono">
                                {hideBalance ? '••••••' : balance.balance.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                              </div>
                              <div className="text-xs">
                                {hideBalance ? '••••' : `${(balance.balance * (balance.price || 0)).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} USDT`}
                              </div>
                            </td>
                            <td className="py-4 text-right">
                              <div className="text-[#eaecef] font-mono">
                                {balance.price?.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) || '0.00'} USDT
                              </div>
                            </td>
                            <td className="py-4 text-right">
                              <button className="hover:text-[#f8d12f] text-sm transition-colors">
                                Cash In
                              </button>
                            </td>
                          </tr>
                        ))
                      )}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </div>

          <div className="bg-[#1e2329] rounded-lg mt-6 p-6">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-lg font-medium">Recent Transactions</h3>
              <button className="text-sm hover:text-[#f8d12f] transition-colors flex items-center space-x-1">
                <span>More</span>
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>

            {transactions.length === 0 ? (
              <div className="text-center py-16">
                <div className="w-24 h-24 mx-auto mb-4 opacity-20">
                  <svg viewBox="0 0 100 100" className="text-[#848e9c]">
                    <rect x="20" y="30" width="60" height="50" fill="none" stroke="currentColor" strokeWidth="2" rx="4"/>
                    <path d="M30 40 L40 50 L30 60 M70 40 L60 50 L70 60" stroke="currentColor" strokeWidth="2" fill="none"/>
                    <line x1="45" y1="35" x2="45" y2="65" stroke="currentColor" strokeWidth="2"/>
                    <line x1="55" y1="35" x2="55" y2="65" stroke="currentColor" strokeWidth="2"/>
                  </svg>
                </div>
                <p className="text-sm">No records</p>
              </div>
            ) : (
              <div className="space-y-3">
                {transactions.map((tx) => (
                  <div key={tx.id} className="flex items-center justify-between p-4 bg-[#2b3139]/30 rounded hover:bg-[#2b3139]/50 transition-colors">
                    <div className="flex items-center space-x-3">
                      <div className={`w-10 h-10 rounded-full flex items-center justify-center ${ tx.type === 'deposit' || 'admin_add' 'admin_credit' ? 'bg-[#0ecb81]/10' : 'bg-[#f6465d]/10' }`}>
                        {tx.type === 'deposit' || tx.type === 'admin_add' || tx.type === 'admin_credit' ? (
                          <TrendingUp className="w-5 h-5 text-[#0ecb81]" />
                        ) : (
                          <TrendingUp className="w-5 h-5 text-[#f6465d] rotate-180" />
                        )}
                      </div>
                      <div>
                        <div className="text-[#eaecef] font-medium">
                          {tx.type === 'admin_add' || tx.type === 'admin_credit' ? 'Admin Deposit' : tx.type.charAt(0).toUpperCase() + tx.type.slice(1)}
                        </div>
                        <div className="text-xs">
                          {new Date(tx.created_at).toLocaleString()}
                        </div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className={`font-mono ${ tx.type === 'deposit' || 'admin_add' 'admin_credit' ? 'text-[#0ecb81]' : 'text-[#f6465d]' }`}>
                        {tx.type === 'deposit' || tx.type === 'admin_add' || tx.type === 'admin_credit' ? '+' : '-'}
                        {Math.abs(tx.amount).toFixed(2)} {tx.symbol}
                      </div>
                      {tx.notes && (
                        <div className="text-xs">{tx.notes}</div>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </main>

      {showDepositModal && (
        <RealDepositModal onClose={() => setShowDepositModal(false)} />
      )}

      {showWithdrawModal && (
        <RealWithdrawModal onClose={() => setShowWithdrawModal(false)} />
      )}
    </div>
  );
}
