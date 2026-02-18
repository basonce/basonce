import { useState, useEffect } from 'react';
import {
  Users,
  DollarSign,
  TrendingUp,
  Activity,
  Search,
  Plus,
  Send,
  Edit,
  Eye,
  AlertCircle,
  CheckCircle,
  XCircle,
  ArrowUpRight,
  ArrowDownRight,
  Filter,
  Download,
  RefreshCw,
  LogOut,
  Home,
  BarChart3,
  Settings,
  Shield,
  MessageSquare,
  Target,
  Zap,
  AlertTriangle,
  TrendingDown,
  Wallet,
  X
} from 'lucide-react';
import { supabase } from '../lib/supabase';
import SupportTicketsPanel from './SupportTicketsPanel';
import WalletPoolManagement from './WalletPoolManagement';
import ManualDepositUpdate from './ManualDepositUpdate';
import WalletLookupModal from './WalletLookupModal';
import WalletSafetyPanel from './WalletSafetyPanel';
import AdminActivityLog from './AdminActivityLog';
import AdminCommandCenter from './AdminCommandCenter';
import AdminAnalyticsDashboard from './AdminAnalyticsDashboard';

interface UserProfile {
  id: string;
  email: string;
  full_name: string;
  is_admin: boolean;
  is_active: boolean;
  created_at: string;
}

interface UserBalance {
  id: string;
  user_id: string;
  symbol: string;
  balance: number;
  locked_balance: number;
}

interface Transaction {
  id: string;
  user_id: string;
  type: string;
  symbol: string;
  amount: number;
  balance_before: number;
  balance_after: number;
  notes: string;
  created_at: string;
  user_profiles?: {
    email: string;
  };
}

interface AdminDashboardProps {
  onBack: () => void;
}

interface Agent {
  id: string;
  name: string;
  country_code: string;
  country_name: string;
  avatar_url: string;
  status: string;
  languages: string[];
  specialty: string;
  active_tickets: number;
  flag_emoji: string;
  region: string;
}

export default function AdminDashboard({ onBack }: AdminDashboardProps) {
  const [activeTab, setActiveTab] = useState<'overview' | 'command' | 'support' | 'agents' | 'positions' | 'wallets' | 'deposits' | 'safety' | 'activity' | 'analytics'>('command');
  const [showAnalyticsDashboard, setShowAnalyticsDashboard] = useState(false);
  const [agents, setAgents] = useState<Agent[]>([]);
  const [agentsLoading, setAgentsLoading] = useState(false);
  const [users, setUsers] = useState<UserProfile[]>([]);
  const [selectedUser, setSelectedUser] = useState<UserProfile | null>(null);
  const [userBalances, setUserBalances] = useState<UserBalance[]>([]);
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);
  const [showAddBalanceModal, setShowAddBalanceModal] = useState(false);
  const [showSendCoinModal, setShowSendCoinModal] = useState(false);
  const [showWalletLookup, setShowWalletLookup] = useState(false);
  const [stats, setStats] = useState({
    totalUsers: 0,
    activeUsers: 0,
    totalTransactions: 0,
    totalVolume: 0
  });
  const [unreadSupportCount, setUnreadSupportCount] = useState(0);

  const [addBalanceForm, setAddBalanceForm] = useState({
    symbol: 'USDT',
    amount: '',
    notes: ''
  });

  const [sendCoinForm, setSendCoinForm] = useState({
    toUserId: '',
    toEmail: '',
    symbol: 'USDT',
    amount: '',
    notes: ''
  });

  const [emailSearchResults, setEmailSearchResults] = useState<UserProfile[]>([]);

  const cryptoSymbols = [
    'USDT', 'BTC', 'ETH', 'BNB', 'SOL', 'XRP', 'ADA', 'DOGE',
    'AVAX', 'DOT', 'MATIC', 'LINK', 'UNI', 'LTC', 'ATOM', 'PEPE', 'SHIB', 'WIF', 'BONK'
  ];

  useEffect(() => {
    loadData();
    loadUnreadSupportCount();

    const channel = supabase
      .channel('admin_unread_support')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'support_messages',
        },
        () => {
          loadUnreadSupportCount();
        }
      )
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'support_tickets',
        },
        () => {
          loadUnreadSupportCount();
        }
      )
      .subscribe();

    const interval = setInterval(() => {
      loadUnreadSupportCount();
    }, 5000);

    return () => {
      supabase.removeChannel(channel);
      clearInterval(interval);
    };
  }, []);

  const loadData = async () => {
    setLoading(true);
    await Promise.all([
      loadUsers(),
      loadTransactions(),
      loadStats()
    ]);
    setLoading(false);
  };

  const loadAgents = async () => {
    setAgentsLoading(true);
    try {
      const { data, error } = await supabase
        .from('support_agents')
        .select('*')
        .order('name', { ascending: true });

      if (error) throw error;
      setAgents(data || []);
    } catch (error) {
      console.error('Error loading agents:', error);
    } finally {
      setAgentsLoading(false);
    }
  };

  useEffect(() => {
    if (activeTab === 'agents') {
      loadAgents();
    }
  }, [activeTab]);

  const loadUsers = async () => {
    const { data, error } = await supabase
      .from('user_profiles')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error loading users:', error);
      return;
    }

    setUsers(data || []);
  };

  const loadUnreadSupportCount = async () => {
    const { count, error } = await supabase
      .from('support_messages')
      .select('*', { count: 'exact', head: true })
      .eq('sender_type', 'customer')
      .eq('read', false);

    if (!error) {
      console.log('Unread support messages:', count);
      setUnreadSupportCount(count || 0);
    } else {
      console.error('Error loading unread count:', error);
    }
  };

  const loadUserBalances = async (userId: string) => {
    const { data, error } = await supabase
      .from('user_balances')
      .select('*')
      .eq('user_id', userId)
      .order('symbol');

    if (error) {
      console.error('Error loading balances:', error);
      return;
    }

    setUserBalances(data || []);
  };

  const loadTransactions = async () => {
    const { data, error } = await supabase
      .from('transactions')
      .select(`
        *,
        user_profiles!transactions_user_id_fkey(email)
      `)
      .order('created_at', { ascending: false })
      .limit(50);

    if (error) {
      console.error('Error loading transactions:', error);
      return;
    }

    setTransactions(data || []);
  };

  const loadStats = async () => {
    const { data: usersData } = await supabase
      .from('user_profiles')
      .select('id, is_active');

    const { data: transactionsData } = await supabase
      .from('transactions')
      .select('amount');

    setStats({
      totalUsers: usersData?.length || 0,
      activeUsers: usersData?.filter(u => u.is_active).length || 0,
      totalTransactions: transactionsData?.length || 0,
      totalVolume: transactionsData?.reduce((sum, t) => sum + parseFloat(t.amount.toString()), 0) || 0
    });
  };

  const handleUserSelect = async (user: UserProfile) => {
    setSelectedUser(user);
    await loadUserBalances(user.id);
  };

  const handleAddBalance = async () => {
    if (!selectedUser || !addBalanceForm.amount || parseFloat(addBalanceForm.amount) <= 0) {
      alert('Please enter a valid amount');
      return;
    }

    try {
      const amount = parseFloat(addBalanceForm.amount);
      const { data: adminData } = await supabase.auth.getUser();

      const { data: existingBalance } = await supabase
        .from('user_balances')
        .select('*')
        .eq('user_id', selectedUser.id)
        .eq('symbol', addBalanceForm.symbol)
        .maybeSingle();

      const balanceBefore = existingBalance ? parseFloat(existingBalance.balance) : 0;
      const balanceAfter = balanceBefore + amount;

      if (existingBalance) {
        await supabase
          .from('user_balances')
          .update({
            balance: balanceAfter,
            updated_at: new Date().toISOString()
          })
          .eq('id', existingBalance.id);
      } else {
        await supabase
          .from('user_balances')
          .insert({
            user_id: selectedUser.id,
            symbol: addBalanceForm.symbol,
            balance: amount,
            locked_balance: 0
          });
      }

      await supabase
        .from('transactions')
        .insert({
          user_id: selectedUser.id,
          type: 'admin_credit',
          symbol: addBalanceForm.symbol,
          amount: amount,
          balance_before: balanceBefore,
          balance_after: balanceAfter,
          admin_id: adminData.user?.id,
          notes: addBalanceForm.notes || `Admin credit: ${amount} ${addBalanceForm.symbol}`
        });

      await supabase
        .from('admin_actions')
        .insert({
          admin_id: adminData.user?.id,
          action_type: 'credit_balance',
          target_user_id: selectedUser.id,
          details: {
            symbol: addBalanceForm.symbol,
            amount: amount,
            notes: addBalanceForm.notes
          }
        });

      setAddBalanceForm({ symbol: 'USDT', amount: '', notes: '' });
      setShowAddBalanceModal(false);
      await loadUserBalances(selectedUser.id);
      await loadTransactions();
      alert('Balance added successfully!');
    } catch (error) {
      console.error('Error adding balance:', error);
      alert('Error adding balance');
    }
  };

  const searchUsersByEmail = async (email: string) => {
    if (email.length < 3) {
      setEmailSearchResults([]);
      return;
    }

    const filtered = users.filter(u =>
      u.email.toLowerCase().includes(email.toLowerCase()) && !u.is_admin
    );
    setEmailSearchResults(filtered);
  };

  const handleSendCoin = async () => {
    if (!sendCoinForm.toUserId || !sendCoinForm.amount || parseFloat(sendCoinForm.amount) <= 0) {
      alert('Please select a user and enter a valid amount');
      return;
    }

    try {
      const amount = parseFloat(sendCoinForm.amount);
      const { data: adminData } = await supabase.auth.getUser();

      const { data: existingBalance } = await supabase
        .from('user_balances')
        .select('*')
        .eq('user_id', sendCoinForm.toUserId)
        .eq('symbol', sendCoinForm.symbol)
        .maybeSingle();

      const balanceBefore = existingBalance ? parseFloat(existingBalance.balance) : 0;
      const balanceAfter = balanceBefore + amount;

      if (existingBalance) {
        await supabase
          .from('user_balances')
          .update({
            balance: balanceAfter,
            updated_at: new Date().toISOString()
          })
          .eq('id', existingBalance.id);
      } else {
        await supabase
          .from('user_balances')
          .insert({
            user_id: sendCoinForm.toUserId,
            symbol: sendCoinForm.symbol,
            balance: amount,
            locked_balance: 0
          });
      }

      await supabase
        .from('transactions')
        .insert({
          user_id: sendCoinForm.toUserId,
          type: 'admin_credit',
          symbol: sendCoinForm.symbol,
          amount: amount,
          balance_before: balanceBefore,
          balance_after: balanceAfter,
          admin_id: adminData.user?.id,
          notes: sendCoinForm.notes || `Admin transfer: ${amount} ${sendCoinForm.symbol}`
        });

      await supabase
        .from('admin_actions')
        .insert({
          admin_id: adminData.user?.id,
          action_type: 'send_coin',
          target_user_id: sendCoinForm.toUserId,
          details: {
            symbol: sendCoinForm.symbol,
            amount: amount,
            notes: sendCoinForm.notes
          }
        });

      setSendCoinForm({ toUserId: '', toEmail: '', symbol: 'USDT', amount: '', notes: '' });
      setEmailSearchResults([]);
      setShowSendCoinModal(false);
      await loadTransactions();
      await loadStats();
      alert('Coin sent successfully!');
    } catch (error) {
      console.error('Error sending coin:', error);
      alert('Error sending coin');
    }
  };

  const toggleUserStatus = async (user: UserProfile) => {
    const { error } = await supabase
      .from('user_profiles')
      .update({ is_active: !user.is_active })
      .eq('id', user.id);

    if (error) {
      alert('Error updating user status');
      return;
    }

    await loadUsers();
    if (selectedUser?.id === user.id) {
      setSelectedUser({ ...user, is_active: !user.is_active });
    }
  };

  const filteredUsers = users.filter(user =>
    user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.full_name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (loading) {
    return (
      <div className="min-h-screen bg-[#0b0e11] flex items-center justify-center">
        <div className="text-center">
          <RefreshCw className="w-12 h-12 text-[#f0b90b] animate-spin mx-auto mb-4" />
          <p className="text-white">Loading dashboard...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#0b0e11] text-white">
      <header className="bg-[#181A20] border-b border-[#2b3139] sticky top-0 z-50">
        <div className="max-w-[1920px] mx-auto px-4 sm:px-6 py-3 sm:py-4">
          <div className="flex items-center justify-between gap-3">
            <div className="flex items-center gap-2 sm:gap-3 min-w-0">
              <div className="w-8 h-8 sm:w-10 sm:h-10 bg-gradient-to-br from-[#f0b90b] to-[#f8d12f] rounded-lg flex items-center justify-center flex-shrink-0">
                <Shield className="w-4 h-4 sm:w-6 sm:h-6 text-black" />
              </div>
              <div className="min-w-0">
                <h1 className="text-sm sm:text-base font-bold text-white truncate">Admin Dashboard</h1>
                <p className="text-xs text-gray-400 hidden sm:block">Basonce Management System</p>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <button
                onClick={onBack}
                className="flex items-center gap-1.5 px-2 sm:px-4 py-2 bg-[#2b3139] hover:bg-[#3b4149] text-white rounded-lg transition-colors text-xs sm:text-sm"
              >
                <Home className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
                <span className="hidden sm:inline">Back</span>
              </button>
              <button
                onClick={async () => {
                  await supabase.auth.signOut();
                  onBack();
                }}
                className="flex items-center gap-1.5 px-2 sm:px-4 py-2 bg-[#f6465d] hover:bg-[#ff6b7a] text-white rounded-lg transition-colors text-xs sm:text-sm"
              >
                <LogOut className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
                <span className="hidden sm:inline">Logout</span>
              </button>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-[1920px] mx-auto p-3 sm:p-4 md:p-6">
        <div className="flex items-center gap-1 sm:gap-2 mb-4 sm:mb-6 bg-[#181A20] p-1 rounded-lg overflow-x-auto">
          <button
            onClick={() => setActiveTab('overview')}
            className={`flex items-center gap-1.5 sm:gap-2 px-3 sm:px-6 py-2 sm:py-3 rounded-lg text-xs sm:text-sm font-medium transition-all whitespace-nowrap ${ activeTab === 'overview' ? 'bg-[#F0B90B] text-[#181A20]' : 'text-gray-400 hover:text-white' }`}
          >
            <BarChart3 className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
            <span>Overview</span>
          </button>
          <button
            onClick={() => setActiveTab('command')}
            className={`flex items-center gap-1.5 sm:gap-2 px-3 sm:px-6 py-2 sm:py-3 rounded-lg text-xs sm:text-sm font-bold transition-all whitespace-nowrap shadow-lg ${ activeTab === 'command' ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white scale-105' : 'bg-gradient-to-r from-purple-600 to-pink-600 text-white hover:scale-105 hover:shadow-xl' }`}
          >
            <Activity className="w-4 h-4 sm:w-5 sm:h-5" />
            <span>Command Center</span>
          </button>
          <button
            onClick={() => setActiveTab('agents')}
            className={`flex items-center gap-1.5 sm:gap-2 px-3 sm:px-6 py-2 sm:py-3 rounded-lg text-xs sm:text-sm font-medium transition-all whitespace-nowrap ${ activeTab === 'agents' ? 'bg-[#F0B90B] text-[#181A20]' : 'bg-[#2B3139] text-gray-400 hover:text-white' }`}
          >
            <Users className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
            <span className="hidden sm:inline">Agents ({agents.length})</span>
            <span className="sm:hidden">Agents</span>
          </button>
          <button
            onClick={() => setActiveTab('support')}
            className={`flex items-center gap-1.5 sm:gap-2 px-3 sm:px-6 py-2 sm:py-3 rounded-lg text-xs sm:text-sm font-medium transition-all relative whitespace-nowrap ${ activeTab === 'support' ? 'bg-[#F0B90B] text-[#181A20]' : 'text-gray-400 hover:text-white' }`}
          >
            <MessageSquare className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
            <span className="hidden sm:inline">Support Tickets</span>
            <span className="sm:hidden">Support</span>
            {unreadSupportCount > 0 && (
              <span className="absolute -top-1 -right-1 px-1.5 sm:px-2 py-0.5 bg-[#f6465d] text-[10px] sm:text-xs font-bold rounded-full min-w-[18px] sm:min-w-[20px] text-center">
                {unreadSupportCount}
              </span>
            )}
          </button>
          <button
            onClick={() => setActiveTab('positions')}
            className={`flex items-center gap-1.5 sm:gap-2 px-3 sm:px-6 py-2 sm:py-3 rounded-lg text-xs sm:text-sm font-medium transition-all whitespace-nowrap ${ activeTab === 'positions' ? 'bg-[#f6465d] text-white' : 'text-gray-400 hover:text-white' }`}
          >
            <Target className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
            <span className="hidden sm:inline">Position Control</span>
            <span className="sm:hidden">Positions</span>
          </button>
          <button
            onClick={() => setActiveTab('wallets')}
            className={`flex items-center gap-1.5 sm:gap-2 px-3 sm:px-6 py-2 sm:py-3 rounded-lg text-xs sm:text-sm font-bold transition-all whitespace-nowrap shadow-lg ${ activeTab === 'wallets' ? 'bg-gradient-to-r from-blue-500 to-cyan-500 text-white scale-105' : 'bg-gradient-to-r from-blue-600 to-cyan-600 text-white hover:scale-105 hover:shadow-xl' }`}
          >
            <Wallet className="w-4 h-4 sm:w-5 sm:h-5" />
            <span>Cüzdan Pool</span>
          </button>
          <button
            onClick={() => setActiveTab('deposits')}
            className={`flex items-center gap-1.5 sm:gap-2 px-3 sm:px-6 py-2 sm:py-3 rounded-lg text-xs sm:text-sm font-medium transition-all whitespace-nowrap ${ activeTab === 'deposits' ? 'bg-green-600 text-white' : 'text-gray-400 hover:text-white' }`}
          >
            <DollarSign className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
            <span>Deposits</span>
          </button>
          <button
            onClick={() => setActiveTab('safety')}
            className={`flex items-center gap-1.5 sm:gap-2 px-3 sm:px-6 py-2 sm:py-3 rounded-lg text-xs sm:text-sm font-bold transition-all whitespace-nowrap shadow-lg ${ activeTab === 'safety' ? 'bg-gradient-to-r from-red-500 to-orange-500 text-white scale-105' : 'bg-gradient-to-r from-red-600 to-orange-600 text-white hover:scale-105 hover:shadow-xl' }`}
          >
            <Shield className="w-4 h-4 sm:w-5 sm:h-5" />
            <span>Güvenlik</span>
          </button>
          <button
            onClick={() => setActiveTab('activity')}
            className={`flex items-center gap-1.5 sm:gap-2 px-3 sm:px-6 py-2 sm:py-3 rounded-lg text-xs sm:text-sm font-bold transition-all whitespace-nowrap shadow-lg ${ activeTab === 'activity' ? 'bg-gradient-to-r from-indigo-500 to-purple-500 text-white scale-105' : 'bg-gradient-to-r from-indigo-600 to-purple-600 text-white hover:scale-105 hover:shadow-xl' }`}
          >
            <Activity className="w-4 h-4 sm:w-5 sm:h-5" />
            <span>Activity Log</span>
          </button>
          <button
            onClick={() => setShowAnalyticsDashboard(true)}
            className="flex items-center gap-1.5 sm:gap-2 px-3 sm:px-6 py-2 sm:py-3 rounded-lg text-xs sm:text-sm font-bold transition-all whitespace-nowrap shadow-lg bg-gradient-to-r from-blue-500 via-cyan-500 to-teal-500 text-white hover:scale-105 hover:shadow-xl"
          >
            <Eye className="w-4 h-4 sm:w-5 sm:h-5" />
            <span>User Analytics</span>
          </button>
        </div>

        {activeTab === 'command' && (
          <>
            <div className="mb-6">
              <h2 className="text-2xl font-bold text-white mb-2">Command Center</h2>
              <p className="text-sm text-gray-400">Mobil yönetim merkezi - Platformu tek bir yerden kontrol et</p>
            </div>
            <AdminCommandCenter />
          </>
        )}

        {activeTab === 'overview' && (
          <>
            <div className="mb-4 sm:mb-6 md:mb-8">
              <h2 className="text-lg sm:text-xl font-bold text-white mb-1 sm:mb-2">Overview</h2>
              <p className="text-xs sm:text-sm text-gray-400">Manage users, balances, and transactions</p>
            </div>

            <div className="grid gap-3 sm:gap-4 mb-6 sm:mb-8 grid-cols-2 lg:grid-cols-4">
          <div className="bg-[#181A20] rounded-lg p-4 sm:p-6 border border-[#2b3139]">
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs sm:text-sm text-gray-400">Total Users</span>
              <Users className="w-4 h-4 sm:w-5 sm:h-5 text-[#f0b90b]" />
            </div>
            <div className="text-xl sm:text-2xl font-bold text-white">{stats.totalUsers}</div>
          </div>

          <div className="bg-[#181A20] rounded-lg p-4 sm:p-6 border border-[#2b3139]">
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs sm:text-sm text-gray-400">Active Users</span>
              <Activity className="w-4 h-4 sm:w-5 sm:h-5 text-[#0ecb81]" />
            </div>
            <div className="text-xl sm:text-2xl font-bold text-white">{stats.activeUsers}</div>
          </div>

          <div className="bg-[#181A20] rounded-lg p-4 sm:p-6 border border-[#2b3139]">
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs sm:text-sm text-gray-400">Total Transactions</span>
              <TrendingUp className="w-4 h-4 sm:w-5 sm:h-5 text-[#3b82f6]" />
            </div>
            <div className="text-xl sm:text-2xl font-bold text-white">{stats.totalTransactions}</div>
          </div>

          <div className="bg-[#181A20] rounded-lg p-4 sm:p-6 border border-[#2b3139]">
            <div className="flex items-center justify-between mb-2">
              <span className="text-xs sm:text-sm text-gray-400">Total Volume</span>
              <DollarSign className="w-4 h-4 sm:w-5 sm:h-5 text-[#f0b90b]" />
            </div>
            <div className="text-xl sm:text-2xl font-bold text-white">${stats.totalVolume.toFixed(2)}</div>
          </div>
        </div>

        <div className="grid gap-4 sm:gap-6 grid-cols-1 lg:grid-cols-3">
          <div className="lg:col-span-1">
            <div className="bg-[#181A20] rounded-lg border border-[#2b3139] p-4 sm:p-6">
              <div className="flex items-center justify-between mb-4 gap-2">
                <h2 className="text-base sm:text-lg font-bold text-white">Users</h2>
                <button
                  onClick={() => setShowSendCoinModal(true)}
                  className="flex items-center gap-1.5 sm:gap-2 px-3 sm:px-4 py-2 bg-[#f0b90b] hover:bg-[#f8d12f] font-medium rounded transition-colors text-xs sm:text-sm whitespace-nowrap"
                >
                  <Send className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
                  <span>Send</span>
                </button>
              </div>

              <div className="mb-4">
                <div className="relative">
                  <div className="absolute left-3 top-1/2 transform -translate-y-1/2 w-6 h-6 rounded-full border-2 border-[#F0B90B] flex items-center justify-center">
                    <Search className="w-4 h-4 text-[#F0B90B]" />
                  </div>
                  <input
                    type="text"
                    placeholder="Search users..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    className="w-full bg-[#0b0e11] border border-[#2b3139] rounded-lg py-2 pl-11 pr-4 text-white placeholder-[#848e9c] focus:border-[#f0b90b]"
                  />
                </div>
              </div>

              <div className="space-y-2 max-h-[600px] overflow-y-auto">
                {filteredUsers.map((user) => (
                  <div
                    key={user.id}
                    onClick={() => handleUserSelect(user)}
                    className={`p-4 rounded-lg cursor-pointer transition-colors border ${ selectedUser?.id === user.id ? 'bg-[#f0b90b]/10 border-[#f0b90b]' : 'bg-[#0b0e11] border-[#2b3139] hover:border-[#f0b90b]/50' }`}
                  >
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center space-x-2">
                        <div className={`w-2 h-2 rounded-full ${user.is_active ? 'bg-[#0ecb81]' : 'bg-[#f6465d]'}`} />
                        <span className="text-white font-medium">{user.email}</span>
                      </div>
                      {user.is_admin && (
                        <span className="px-2 py-1 bg-[#f0b90b] text-xs font-bold rounded">ADMIN</span>
                      )}
                    </div>
                    <div className="text-gray-400">
                      Joined {new Date(user.created_at).toLocaleDateString()}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="space-y-4 sm:space-y-6 lg:col-span-2">
            {selectedUser ? (
              <>
                <div className="bg-[#181A20] rounded-lg border border-[#2b3139] p-6">
                  <div className="flex items-center justify-between mb-6">
                    <div>
                      <h2 className="font-bold text-white mb-1">{selectedUser.email}</h2>
                      <p className="text-gray-400">User ID: {selectedUser.id.slice(0, 8)}...</p>
                    </div>
                    <div className="flex items-center space-x-3">
                      <button
                        onClick={() => toggleUserStatus(selectedUser)}
                        className={`px-4 py-2 rounded font-medium text-sm transition-colors ${selectedUser.is_active ? 'bg-[#f6465d] hover:bg-[#ff6b7a] text-white' : 'bg-[#0ecb81] hover:bg-[#1cd490] text-white'}`}
                      >
                        {selectedUser.is_active ? 'Deactivate' : 'Activate'}
                      </button>
                      <button
                        onClick={() => setShowAddBalanceModal(true)}
                        className="flex items-center space-x-2 px-4 py-2 bg-[#f0b90b] hover:bg-[#f8d12f] text-black font-medium rounded transition-colors"
                      >
                        <Plus className="w-4 h-4" />
                        <span>Add Balance</span>
                      </button>
                    </div>
                  </div>

                  <div className="bg-[#0b0e11] rounded-lg p-4 mb-4">
                    <h3 className="font-semibold text-gray-400 mb-3">Account Status</h3>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <span className="text-gray-400">Status</span>
                        <div className="flex items-center space-x-2 mt-1">
                          {selectedUser.is_active ? (
                            <>
                              <CheckCircle className="w-4 h-4 text-[#0ecb81]" />
                              <span className="text-[#0ecb81] font-medium">Active</span>
                            </>
                          ) : (
                            <>
                              <XCircle className="w-4 h-4 text-[#f6465d]" />
                              <span className="text-[#f6465d] font-medium">Inactive</span>
                            </>
                          )}
                        </div>
                      </div>
                      <div>
                        <span className="text-gray-400">Role</span>
                        <div className="mt-1">
                          <span className="text-white font-medium">{selectedUser.is_admin ? 'Admin' : 'User'}</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <h3 className="font-semibold text-white mb-3">Balances</h3>
                  {userBalances.length > 0 ? (
                    <div className="space-y-2">
                      {userBalances.map((balance) => (
                        <div
                          key={balance.id}
                          className="flex items-center justify-between p-3 bg-[#0b0e11] rounded-lg"
                        >
                          <div className="flex items-center space-x-3">
                            <div className="w-8 h-8 bg-[#f0b90b] rounded-full flex items-center justify-center font-bold text-sm">
                              {balance.symbol.slice(0, 1)}
                            </div>
                            <div>
                              <div className="text-white font-medium">{balance.symbol}</div>
                              <div className="text-gray-400">Available</div>
                            </div>
                          </div>
                          <div className="text-right">
                            <div className="text-white font-semibold">{parseFloat(balance.balance.toString()).toFixed(8)}</div>
                            {parseFloat(balance.locked_balance.toString()) > 0 && (
                              <div className="text-gray-400">Locked: {parseFloat(balance.locked_balance.toString()).toFixed(8)}</div>
                            )}
                          </div>
                        </div>
                      ))}
                    </div>
                  ) : (
                    <div className="py-8 text-gray-400">
                      <AlertCircle className="w-12 h-12 mx-auto mb-2 opacity-50" />
                      <p>No balances found</p>
                    </div>
                  )}
                </div>
              </>
            ) : (
              <div className="bg-[#181A20] rounded-lg border border-[#2b3139] p-12 text-center">
                <Users className="w-16 h-16 text-gray-400 mx-auto mb-4 opacity-50" />
                <p className="text-lg">Select a user to view details</p>
              </div>
            )}

            <div className="bg-[#181A20] rounded-lg border border-[#2b3139] p-6">
              <div className="flex items-center justify-between mb-4">
                <h2 className="font-bold text-white">Recent Transactions</h2>
                <button
                  onClick={loadTransactions}
                  className="p-2 hover:bg-[#2b3139] rounded transition-colors"
                >
                  <RefreshCw className="w-4 h-4 text-gray-400" />
                </button>
              </div>

              <div className="space-y-2 max-h-[400px] overflow-y-auto">
                {transactions.map((tx) => (
                  <div
                    key={tx.id}
                    className="flex items-center justify-between p-3 bg-[#0b0e11] rounded-lg"
                  >
                    <div className="flex items-center space-x-3">
                      <div className={`p-2 rounded-lg ${ tx.type.includes('credit') || tx.type === 'deposit' ? 'bg-[#0ecb81]/10' : 'bg-[#f6465d]/10' }`}>
                        {tx.type.includes('credit') || tx.type === 'deposit' ? (
                          <ArrowDownRight className="w-4 h-4 text-[#0ecb81]" />
                        ) : (
                          <ArrowUpRight className="w-4 h-4 text-[#f6465d]" />
                        )}
                      </div>
                      <div>
                        <div className="text-white font-medium">{tx.user_profiles?.email}</div>
                        <div className="text-gray-400">
                          {tx.type.replace('_', ' ').toUpperCase()} - {tx.notes}
                        </div>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className={`font-semibold ${ tx.type.includes('credit') || tx.type === 'deposit' ? 'text-[#0ecb81]' : 'text-[#f6465d]' }`}>
                        {tx.type.includes('credit') || tx.type === 'deposit' ? '+' : '-'}
                        {parseFloat(tx.amount.toString()).toFixed(8)} {tx.symbol}
                      </div>
                      <div className="text-gray-400">
                        {new Date(tx.created_at).toLocaleString()}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        {showAddBalanceModal && selectedUser && (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4" onClick={() => { setShowAddBalanceModal(false); setAddBalanceForm({ symbol: 'USDT', amount: '', notes: '' }); }}>
          <div className="bg-[#181A20] rounded-lg p-6 max-w-md w-full border border-[#2b3139]" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-bold text-white">Add Balance to {selectedUser.email}</h3>
              <button onClick={() => { setShowAddBalanceModal(false); setAddBalanceForm({ symbol: 'USDT', amount: '', notes: '' }); }} className="p-1 hover:bg-[#2b3139] rounded-lg transition-colors">
                <X className="w-5 h-5 text-gray-400 hover:text-white" />
              </button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block font-medium text-gray-400 mb-2">Cryptocurrency</label>
                <select
                  value={addBalanceForm.symbol}
                  onChange={(e) => setAddBalanceForm({ ...addBalanceForm, symbol: e.target.value })}
                  className="w-full bg-[#0b0e11] border border-[#2b3139] rounded-lg py-2 px-4 text-white focus:border-[#f0b90b]"
                >
                  {cryptoSymbols.map(symbol => (
                    <option key={symbol} value={symbol}>{symbol}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block font-medium text-gray-400 mb-2">Amount</label>
                <input
                  type="number"
                  step="0.00000001"
                  value={addBalanceForm.amount}
                  onChange={(e) => setAddBalanceForm({ ...addBalanceForm, amount: e.target.value })}
                  placeholder="0.00"
                  className="w-full bg-[#0b0e11] border border-[#2b3139] rounded-lg py-2 px-4 text-white placeholder-[#848e9c] focus:border-[#f0b90b]"
                />
              </div>

              <div>
                <label className="block font-medium text-gray-400 mb-2">Notes (Optional)</label>
                <textarea
                  value={addBalanceForm.notes}
                  onChange={(e) => setAddBalanceForm({ ...addBalanceForm, notes: e.target.value })}
                  placeholder="Add a note..."
                  rows={3}
                  className="w-full bg-[#0b0e11] border border-[#2b3139] rounded-lg py-2 px-4 text-white placeholder-[#848e9c] focus:border-[#f0b90b]"
                />
              </div>

              <div className="flex space-x-3 pt-4">
                <button
                  onClick={() => {
                    setShowAddBalanceModal(false);
                    setAddBalanceForm({ symbol: 'USDT', amount: '', notes: '' });
                  }}
                  className="flex-1 px-4 py-2 bg-[#2b3139] hover:bg-[#3b4149] text-white rounded-lg transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleAddBalance}
                  className="flex-1 px-4 py-2 bg-[#f0b90b] hover:bg-[#f8d12f] text-black font-semibold rounded-lg transition-colors"
                >
                  Add Balance
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {showSendCoinModal && (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4" onClick={() => setShowSendCoinModal(false)}>
          <div className="bg-[#181A20] rounded-lg p-6 max-w-md w-full border border-[#2b3139]" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-bold text-white">Send Coin to User</h3>
              <button onClick={() => setShowSendCoinModal(false)} className="p-1 hover:bg-[#2b3139] rounded-lg transition-colors">
                <X className="w-5 h-5 text-gray-400 hover:text-white" />
              </button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block font-medium text-gray-400 mb-2">Search User by Email</label>
                <div className="relative">
                  <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
                  <input
                    type="email"
                    value={sendCoinForm.toEmail}
                    onChange={(e) => {
                      setSendCoinForm({ ...sendCoinForm, toEmail: e.target.value, toUserId: '' });
                      searchUsersByEmail(e.target.value);
                    }}
                    placeholder="Enter user email..."
                    className="w-full bg-[#0b0e11] border border-[#2b3139] rounded-lg py-2 pl-10 pr-4 text-white placeholder-[#848e9c] focus:border-[#f0b90b]"
                  />
                </div>
                {sendCoinForm.toEmail.length >= 3 && emailSearchResults.length === 0 && (
                  <div className="mt-2 p-3 bg-[#f6465d]/10 border border-[#f6465d]/30 rounded-lg">
                    <div className="flex items-start space-x-2">
                      <AlertCircle className="w-4 h-4 text-[#f6465d] mt-0.5 flex-shrink-0" />
                      <div className="text-[#f6465d]">
                        <p className="font-medium mb-1">User not found</p>
                        <p className="text-xs">The user needs to register first with this email before you can send them funds.</p>
                      </div>
                    </div>
                  </div>
                )}
                {emailSearchResults.length > 0 && (
                  <div className="mt-2 space-y-1 max-h-40 overflow-y-auto">
                    {emailSearchResults.map(user => (
                      <button
                        key={user.id}
                        onClick={() => {
                          setSendCoinForm({ ...sendCoinForm, toUserId: user.id, toEmail: user.email });
                          setEmailSearchResults([]);
                        }}
                        className="w-full p-3 bg-[#0b0e11] hover:bg-[#2b3139] border border-[#2b3139] rounded-lg text-left transition-colors"
                      >
                        <div className="flex items-center justify-between">
                          <span className="text-white font-medium">{user.email}</span>
                          {user.is_active ? (
                            <CheckCircle className="w-4 h-4 text-[#0ecb81]" />
                          ) : (
                            <XCircle className="w-4 h-4 text-[#f6465d]" />
                          )}
                        </div>
                        <div className="text-gray-400 mt-1">
                          {user.full_name || 'No name set'}
                        </div>
                      </button>
                    ))}
                  </div>
                )}
                {sendCoinForm.toUserId && (
                  <div className="mt-2 p-3 bg-[#0ecb81]/10 border border-[#0ecb81]/30 rounded-lg">
                    <div className="flex items-center space-x-2">
                      <CheckCircle className="w-4 h-4 text-[#0ecb81]" />
                      <span className="text-[#0ecb81] font-medium">User selected: {sendCoinForm.toEmail}</span>
                    </div>
                  </div>
                )}
              </div>

              <div>
                <label className="block font-medium text-gray-400 mb-2">Cryptocurrency</label>
                <select
                  value={sendCoinForm.symbol}
                  onChange={(e) => setSendCoinForm({ ...sendCoinForm, symbol: e.target.value })}
                  className="w-full bg-[#0b0e11] border border-[#2b3139] rounded-lg py-2 px-4 text-white focus:border-[#f0b90b]"
                >
                  {cryptoSymbols.map(symbol => (
                    <option key={symbol} value={symbol}>{symbol}</option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block font-medium text-gray-400 mb-2">Amount</label>
                <input
                  type="number"
                  step="0.00000001"
                  value={sendCoinForm.amount}
                  onChange={(e) => setSendCoinForm({ ...sendCoinForm, amount: e.target.value })}
                  placeholder="0.00"
                  className="w-full bg-[#0b0e11] border border-[#2b3139] rounded-lg py-2 px-4 text-white placeholder-[#848e9c] focus:border-[#f0b90b]"
                />
                <div className="mt-2 flex flex-wrap gap-2">
                  <button
                    type="button"
                    onClick={() => setSendCoinForm({ ...sendCoinForm, amount: '1000' })}
                    className="px-3 py-1 bg-[#2b3139] hover:bg-[#3b4149] text-sm rounded transition-colors"
                  >
                    $1,000
                  </button>
                  <button
                    type="button"
                    onClick={() => setSendCoinForm({ ...sendCoinForm, amount: '5000' })}
                    className="px-3 py-1 bg-[#2b3139] hover:bg-[#3b4149] text-sm rounded transition-colors"
                  >
                    $5,000
                  </button>
                  <button
                    type="button"
                    onClick={() => setSendCoinForm({ ...sendCoinForm, amount: '10000' })}
                    className="px-3 py-1 bg-[#2b3139] hover:bg-[#3b4149] text-sm rounded transition-colors"
                  >
                    $10,000
                  </button>
                  <button
                    type="button"
                    onClick={() => setSendCoinForm({ ...sendCoinForm, amount: '50000' })}
                    className="px-3 py-1 bg-[#f0b90b] hover:bg-[#f8d12f] text-sm font-semibold rounded transition-colors"
                  >
                    $50,000
                  </button>
                  <button
                    type="button"
                    onClick={() => setSendCoinForm({ ...sendCoinForm, amount: '100000' })}
                    className="px-3 py-1 bg-[#2b3139] hover:bg-[#3b4149] text-sm rounded transition-colors"
                  >
                    $100,000
                  </button>
                </div>
              </div>

              <div>
                <label className="block font-medium text-gray-400 mb-2">Notes (Optional)</label>
                <textarea
                  value={sendCoinForm.notes}
                  onChange={(e) => setSendCoinForm({ ...sendCoinForm, notes: e.target.value })}
                  placeholder="Add a note..."
                  rows={3}
                  className="w-full bg-[#0b0e11] border border-[#2b3139] rounded-lg py-2 px-4 text-white placeholder-[#848e9c] focus:border-[#f0b90b]"
                />
              </div>

              <div className="flex space-x-3 pt-4">
                <button
                  onClick={() => {
                    setShowSendCoinModal(false);
                    setSendCoinForm({ toUserId: '', toEmail: '', symbol: 'USDT', amount: '', notes: '' });
                    setEmailSearchResults([]);
                  }}
                  className="flex-1 px-4 py-2 bg-[#2b3139] hover:bg-[#3b4149] text-white rounded-lg transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleSendCoin}
                  disabled={!sendCoinForm.toUserId || !sendCoinForm.amount || parseFloat(sendCoinForm.amount) <= 0}
                  className="flex-1 px-4 py-2 bg-[#f0b90b] hover:bg-[#f8d12f] text-black font-semibold rounded-lg transition-colors disabled:cursor-not-allowed"
                >
                  Send Coin
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
          </>
        )}

        {activeTab === 'agents' && (
          <div className="mb-6 sm:mb-8">
            <div className="mb-4 sm:mb-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 sm:gap-4">
              <div>
                <h2 className="text-lg sm:text-xl font-bold text-white mb-1 sm:mb-2">Support Agents</h2>
                <p className="text-xs sm:text-sm text-gray-400">View all customer service representatives</p>
              </div>
              <button
                onClick={loadAgents}
                className="flex items-center gap-2 px-3 sm:px-4 py-2 bg-[#2B3139] hover:bg-[#3B3F46] text-white rounded-lg transition-colors text-xs sm:text-sm"
              >
                <RefreshCw className={`w-3.5 h-3.5 sm:w-4 sm:h-4 ${agentsLoading ? 'animate-spin' : ''}`} />
                <span>Refresh</span>
              </button>
            </div>

            {agentsLoading ? (
              <div className="flex items-center justify-center h-64">
                <RefreshCw className="w-8 h-8 text-[#F0B90B] animate-spin" />
              </div>
            ) : (
              <div className="grid gap-3 sm:gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
                {agents.map((agent) => (
                  <div
                    key={agent.id}
                    className="bg-[#181A20] border border-[#2B3139] rounded-lg p-4 hover:border-[#F0B90B] transition-all"
                  >
                    <div className="flex items-center gap-3 mb-3">
                      <img
                        src={agent.avatar_url}
                        alt={agent.name}
                        className="w-16 h-16 rounded-full object-cover border-[#F0B90B]"
                        onError={(e) => {
                          const target = e.target as HTMLImageElement;
                          target.src = 'https://via.placeholder.com/100/F0B90B/181A20?text=' + agent.name.charAt(0);
                        }}
                      />
                      <div className="flex-1 min-w-0">
                        <h3 className="font-semibold text-sm truncate">{agent.name}</h3>
                        <div className="flex items-center gap-1.5 mt-1">
                          <div className={`w-2 h-2 rounded-full ${agent.status === 'online' ? 'bg-green-500' : 'bg-gray-500'}`}></div>
                          <span className={`text-xs ${agent.status === 'online' ? 'text-green-400' : 'text-gray-400'}`}>
                            {agent.status}
                          </span>
                        </div>
                      </div>
                    </div>
                    <div className="space-y-2">
                      <div className="flex items-center gap-2">
                        <span className="text-2xl">{agent.flag_emoji}</span>
                        <span className="px-2 py-0.5 bg-opacity-20 font-bold text-xs rounded">
                          {agent.country_code}
                        </span>
                        <span className="text-gray-400">{agent.country_name}</span>
                      </div>
                      <div className="text-gray-400">
                        Region: <span className="text-white">{agent.region}</span>
                      </div>
                      <div className="text-gray-400">
                        Specialty: <span className="text-white capitalize">{agent.specialty}</span>
                      </div>
                      <div className="text-gray-400">
                        Languages: <span className="text-white">{agent.languages.join(', ')}</span>
                      </div>
                      <div className="text-gray-400">
                        Active Tickets: <span className="text-[#F0B90B] font-bold">{agent.active_tickets}</span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}

            <div className="mt-4 sm:mt-6 bg-[#181A20] border border-[#2B3139] rounded-lg p-4 sm:p-6">
              <h3 className="text-base sm:text-lg text-white font-semibold mb-3 sm:mb-4">Summary</h3>
              <div className="grid gap-3 sm:gap-4 grid-cols-2 lg:grid-cols-4">
                <div>
                  <p className="text-xs mb-1">Total Agents</p>
                  <p className="text-2xl font-bold">{agents.length}</p>
                </div>
                <div>
                  <p className="text-xs mb-1">Online</p>
                  <p className="text-2xl font-bold">
                    {agents.filter(a => a.status === 'online').length}
                  </p>
                </div>
                <div>
                  <p className="text-xs mb-1">Countries</p>
                  <p className="text-2xl font-bold">
                    {new Set(agents.map(a => a.country_code)).size}
                  </p>
                </div>
                <div>
                  <p className="text-xs mb-1">Languages</p>
                  <p className="text-2xl font-bold">
                    {new Set(agents.flatMap(a => a.languages)).size}
                  </p>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'support' && (
          <div className="mb-6 sm:mb-8">
            <div className="mb-4 sm:mb-6">
              <h2 className="text-lg sm:text-xl font-bold text-white mb-1 sm:mb-2">Support Tickets</h2>
              <p className="text-xs sm:text-sm text-gray-400">Manage customer support requests and conversations</p>
            </div>
            <SupportTicketsPanel />
          </div>
        )}

        {activeTab === 'positions' && <PositionControlPanel />}

        {activeTab === 'wallets' && (
          <>
            <div className="mb-6 flex items-center justify-between">
              <div>
                <h2 className="text-xl font-bold text-white mb-2">Wallet Pool Management</h2>
                <p className="text-sm text-gray-400">Sadece adres girin - Yeni kullanıcılara otomatik atanır</p>
              </div>
              <button
                onClick={() => setShowWalletLookup(true)}
                className="flex items-center space-x-2 px-6 py-3 bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-yellow-600 hover:to-orange-600 text-white rounded-lg font-bold transition-all shadow-lg hover:shadow-xl hover:scale-105"
              >
                <Search className="w-5 h-5" />
                <span>Cüzdan Sorgula</span>
              </button>
            </div>
            <WalletPoolManagement />
          </>
        )}

        {showWalletLookup && (
          <WalletLookupModal onClose={() => setShowWalletLookup(false)} />
        )}

        {activeTab === 'deposits' && (
          <>
            <div className="mb-6">
              <h2 className="text-xl font-bold text-white mb-2">Manuel Deposit Güncelleme</h2>
              <p className="text-sm text-gray-400">Blockchain deposit'lerini manuel olarak onaylayın</p>
            </div>
            <ManualDepositUpdate />
          </>
        )}

        {activeTab === 'safety' && (
          <>
            <div className="mb-6">
              <h2 className="text-xl font-bold text-white mb-2">Wallet Güvenlik Merkezi</h2>
              <p className="text-sm text-gray-400">Duplicate kontrol, integrity check ve audit log</p>
            </div>
            <WalletSafetyPanel />
          </>
        )}

        {activeTab === 'activity' && (
          <>
            <div className="mb-6">
              <h2 className="text-xl font-bold text-white mb-2">Admin Activity Log</h2>
              <p className="text-sm text-gray-400">Tüm admin işlemleri eksiksiz kaydediliyor</p>
            </div>
            <AdminActivityLog />
          </>
        )}
      </div>

      {showAnalyticsDashboard && (
        <AdminAnalyticsDashboard onClose={() => setShowAnalyticsDashboard(false)} />
      )}
    </div>
  );
}

function PositionControlPanel() {
  const [positions, setPositions] = useState<any[]>([]);
  const [priceOverrides, setPriceOverrides] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterCoin, setFilterCoin] = useState('all');
  const [filterType, setFilterType] = useState('all');
  const [showOverrideModal, setShowOverrideModal] = useState(false);
  const [showLiquidateConfirm, setShowLiquidateConfirm] = useState(false);
  const [selectedPosition, setSelectedPosition] = useState<any>(null);
  const [overrideForm, setOverrideForm] = useState({
    coin_symbol: '',
    override_price: '',
    duration_minutes: '',
    reason: ''
  });

  useEffect(() => {
    loadPositions();
    loadPriceOverrides();
    const interval = setInterval(() => {
      loadPositions();
      loadPriceOverrides();
    }, 5000);
    return () => clearInterval(interval);
  }, []);

  const loadPositions = async () => {
    try {
      const { data, error } = await supabase.rpc('get_all_active_positions');
      if (error) throw error;
      setPositions(data || []);
    } catch (error) {
      console.error('Error loading positions:', error);
    } finally {
      setLoading(false);
    }
  };

  const loadPriceOverrides = async () => {
    try {
      const { data, error } = await supabase
        .from('admin_price_overrides')
        .select('*')
        .eq('is_active', true)
        .order('created_at', { ascending: false });
      if (error) throw error;
      setPriceOverrides(data || []);
    } catch (error) {
      console.error('Error loading overrides:', error);
    }
  };

  const handleRunAutoLiquidation = async () => {
    if (!confirm('Run automatic liquidation check? This will liquidate all positions that have reached their liquidation price.')) {
      return;
    }

    try {
      const { data, error } = await supabase.rpc('check_and_liquidate');

      if (error) throw error;

      const result = data as any;

      if (result.liquidated_count > 0) {
        alert(`Auto Liquidation Complete!\n\nLiquidated: ${result.liquidated_count} positions\nTotal Margin Lost: $${parseFloat(result.total_margin_lost).toFixed(2)}`);
      } else {
        alert('No positions need liquidation at current prices.');
      }

      loadPositions();
      loadPriceOverrides();
    } catch (error) {
      console.error('Error running auto liquidation:', error);
      alert('Failed to run auto liquidation');
    }
  };

  const handleForceLiquidate = async () => {
    if (!selectedPosition) return;

    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data: profile } = await supabase
        .from('user_profiles')
        .select('email')
        .eq('id', user.id)
        .single();

      const { data, error } = await supabase.rpc('force_liquidate_position', {
        p_position_id: selectedPosition.position_id,
        p_admin_email: profile?.email || 'admin'
      });

      if (error) throw error;

      alert(`Position liquidated! User lost ${data.liquidated_amount} USDT`);
      setShowLiquidateConfirm(false);
      setSelectedPosition(null);
      loadPositions();
    } catch (error) {
      console.error('Error liquidating:', error);
      alert('Failed to liquidate position');
    }
  };

  const handleApplyOverride = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data: profile } = await supabase
        .from('user_profiles')
        .select('email')
        .eq('id', user.id)
        .single();

      const { error } = await supabase.rpc('apply_price_override', {
        p_coin_symbol: overrideForm.coin_symbol,
        p_override_price: parseFloat(overrideForm.override_price),
        p_admin_email: profile?.email || 'admin',
        p_duration_minutes: overrideForm.duration_minutes ? parseInt(overrideForm.duration_minutes) : null,
        p_reason: overrideForm.reason || null
      });

      if (error) throw error;

      alert(`Price override applied for ${overrideForm.coin_symbol}`);
      setShowOverrideModal(false);
      setOverrideForm({ coin_symbol: '', override_price: '', duration_minutes: '', reason: '' });
      loadPriceOverrides();
      setTimeout(loadPositions, 1000);
    } catch (error) {
      console.error('Error applying override:', error);
      alert('Failed to apply price override');
    }
  };

  const handleRemoveOverride = async (coinSymbol: string) => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data: profile } = await supabase
        .from('user_profiles')
        .select('email')
        .eq('id', user.id)
        .single();

      const { error } = await supabase.rpc('remove_price_override', {
        p_coin_symbol: coinSymbol,
        p_admin_email: profile?.email || 'admin'
      });

      if (error) throw error;

      alert(`Price override removed for ${coinSymbol}`);
      loadPriceOverrides();
      setTimeout(loadPositions, 1000);
    } catch (error) {
      console.error('Error removing override:', error);
      alert('Failed to remove override');
    }
  };

  const filteredPositions = positions.filter(pos => {
    const matchesSearch = searchTerm === '' ||
      pos.user_email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      pos.coin_symbol?.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCoin = filterCoin === 'all' || pos.coin_symbol?.includes(filterCoin);
    const matchesType = filterType === 'all' || pos.position_type === filterType;
    return matchesSearch && matchesCoin && matchesType;
  });

  const uniqueCoins = Array.from(new Set(positions.map(p => p.coin_symbol)));

  return (
    <div className="mb-6 sm:mb-8">
      <div className="mb-6">
        <h2 className="text-xl font-bold text-white mb-2">Position Control Panel</h2>
        <p className="text-sm text-gray-400">Manipulate user positions and market prices</p>
      </div>

      <div className="grid gap-4 mb-6 grid-cols-2 lg:grid-cols-4">
        <div className="bg-[#181A20] rounded-lg p-4 border border-[#2b3139]">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-gray-400">Active Positions</span>
            <Target className="w-5 h-5 text-[#f0b90b]" />
          </div>
          <div className="text-2xl font-bold text-white">{positions.length}</div>
        </div>

        <div className="bg-[#181A20] rounded-lg p-4 border border-[#2b3139]">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-gray-400">Price Overrides</span>
            <Zap className="w-5 h-5 text-[#f6465d]" />
          </div>
          <div className="text-2xl font-bold text-white">{priceOverrides.length}</div>
        </div>

        <div className="bg-[#181A20] rounded-lg p-4 border border-[#2b3139]">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-gray-400">At Risk</span>
            <AlertTriangle className="w-5 h-5 text-[#ff9800]" />
          </div>
          <div className="text-2xl font-bold text-white">
            {positions.filter(p => parseFloat(p.distance_to_liquidation_percent) < 10).length}
          </div>
        </div>

        <div className="bg-[#181A20] rounded-lg p-4 border border-[#2b3139]">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-gray-400">Total Margin</span>
            <DollarSign className="w-5 h-5 text-[#0ecb81]" />
          </div>
          <div className="text-2xl font-bold text-white">
            ${positions.reduce((sum, p) => sum + parseFloat(p.margin || 0), 0).toFixed(2)}
          </div>
        </div>
      </div>

      <div className="bg-[#181A20] rounded-lg p-4 border border-[#2b3139] mb-6">
        <h3 className="text-lg font-bold text-white mb-4 flex items-center gap-2">
          <Zap className="w-5 h-5 text-[#f6465d]" />
          Active Price Overrides
        </h3>

        {priceOverrides.length > 0 ? (
          <div className="grid gap-3 grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
            {priceOverrides.map((override) => (
              <div key={override.id} className="bg-[#0f1114] rounded-lg p-3 border border-[#f6465d]">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-lg font-bold text-white">{override.coin_symbol}</span>
                  <span className="text-[#f6465d] text-xl font-bold">${parseFloat(override.override_price).toFixed(2)}</span>
                </div>
                {override.reason && (
                  <p className="text-xs text-gray-400 mb-2">{override.reason}</p>
                )}
                <div className="flex items-center justify-between">
                  <span className="text-xs text-gray-500">
                    {override.expires_at ? `Expires ${new Date(override.expires_at).toLocaleTimeString()}` : 'No expiration'}
                  </span>
                  <button
                    onClick={() => handleRemoveOverride(override.coin_symbol)}
                    className="px-2 py-1 bg-[#f6465d] hover:bg-[#ff6b7a] text-white rounded text-xs"
                  >
                    Remove
                  </button>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <p className="text-gray-400 text-sm">No active price overrides</p>
        )}

        <div className="flex gap-3 mt-4">
          <button
            onClick={() => setShowOverrideModal(true)}
            className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-[#f6465d] hover:bg-[#ff6b7a] text-white rounded-lg"
          >
            <Zap className="w-4 h-4" />
            Set Price Override
          </button>
          <button
            onClick={handleRunAutoLiquidation}
            className="flex-1 flex items-center justify-center gap-2 px-4 py-2 bg-[#ff9800] hover:bg-[#ffa726] text-white rounded-lg"
          >
            <AlertTriangle className="w-4 h-4" />
            Run Auto Liquidation
          </button>
        </div>
      </div>

      <div className="bg-[#181A20] rounded-lg p-4 border border-[#2b3139]">
        <div className="flex flex-col sm:flex-row gap-3 mb-4">
          <div className="flex-1">
            <input
              type="text"
              placeholder="Search by email or coin..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full px-4 py-2 bg-[#0f1114] border border-[#2b3139] rounded-lg text-white placeholder-gray-500 focus:outline-none focus:border-[#f0b90b]"
            />
          </div>
          <select
            value={filterCoin}
            onChange={(e) => setFilterCoin(e.target.value)}
            className="px-4 py-2 bg-[#0f1114] border border-[#2b3139] rounded-lg text-white focus:outline-none focus:border-[#f0b90b]"
          >
            <option value="all">All Coins</option>
            {uniqueCoins.map(coin => (
              <option key={coin} value={coin}>{coin}</option>
            ))}
          </select>
          <select
            value={filterType}
            onChange={(e) => setFilterType(e.target.value)}
            className="px-4 py-2 bg-[#0f1114] border border-[#2b3139] rounded-lg text-white focus:outline-none focus:border-[#f0b90b]"
          >
            <option value="all">All Types</option>
            <option value="LONG">Long</option>
            <option value="SHORT">Short</option>
          </select>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="border-b border-[#2b3139]">
                <th className="text-left py-3 px-2 text-xs text-gray-400">User</th>
                <th className="text-left py-3 px-2 text-xs text-gray-400">Coin</th>
                <th className="text-left py-3 px-2 text-xs text-gray-400">Type</th>
                <th className="text-right py-3 px-2 text-xs text-gray-400">Entry</th>
                <th className="text-right py-3 px-2 text-xs text-gray-400">Current</th>
                <th className="text-right py-3 px-2 text-xs text-gray-400">Liq. Price</th>
                <th className="text-right py-3 px-2 text-xs text-gray-400">Distance</th>
                <th className="text-right py-3 px-2 text-xs text-gray-400">Leverage</th>
                <th className="text-right py-3 px-2 text-xs text-gray-400">Margin</th>
                <th className="text-right py-3 px-2 text-xs text-gray-400">PnL</th>
                <th className="text-right py-3 px-2 text-xs text-gray-400">Actions</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan={11} className="text-center py-8 text-gray-400">Loading...</td>
                </tr>
              ) : filteredPositions.length === 0 ? (
                <tr>
                  <td colSpan={11} className="text-center py-8 text-gray-400">No positions found</td>
                </tr>
              ) : (
                filteredPositions.map((pos) => (
                  <tr key={pos.position_id} className="border-b border-[#2b3139] hover:bg-[#0f1114]">
                    <td className="py-3 px-2 text-xs text-white truncate max-w-[120px]">{pos.user_email}</td>
                    <td className="py-3 px-2 text-xs text-white">{pos.coin_symbol}</td>
                    <td className="py-3 px-2">
                      <span className={`text-xs px-2 py-1 rounded ${pos.position_type === 'LONG' ? 'bg-[#0ecb81]/20 text-[#0ecb81]' : 'bg-[#f6465d]/20 text-[#f6465d]'}`}>
                        {pos.position_type}
                      </span>
                    </td>
                    <td className="py-3 px-2 text-xs text-right text-white">${parseFloat(pos.entry_price).toFixed(2)}</td>
                    <td className="py-3 px-2 text-xs text-right text-white">${parseFloat(pos.current_price).toFixed(2)}</td>
                    <td className="py-3 px-2 text-xs text-right text-white">${parseFloat(pos.liquidation_price).toFixed(2)}</td>
                    <td className="py-3 px-2 text-xs text-right">
                      <span className={parseFloat(pos.distance_to_liquidation_percent) < 10 ? 'text-[#f6465d]' : parseFloat(pos.distance_to_liquidation_percent) < 30 ? 'text-[#ff9800]' : 'text-[#0ecb81]'}>
                        {parseFloat(pos.distance_to_liquidation_percent).toFixed(1)}%
                      </span>
                    </td>
                    <td className="py-3 px-2 text-xs text-right text-white">{pos.leverage}x</td>
                    <td className="py-3 px-2 text-xs text-right text-white">${parseFloat(pos.margin).toFixed(2)}</td>
                    <td className="py-3 px-2 text-xs text-right">
                      <span className={parseFloat(pos.unrealized_pnl) >= 0 ? 'text-[#0ecb81]' : 'text-[#f6465d]'}>
                        ${parseFloat(pos.unrealized_pnl).toFixed(2)}
                      </span>
                    </td>
                    <td className="py-3 px-2 text-right">
                      <button
                        onClick={() => {
                          setSelectedPosition(pos);
                          setShowLiquidateConfirm(true);
                        }}
                        className="px-3 py-1 bg-[#f6465d] hover:bg-[#ff6b7a] text-white rounded text-xs"
                      >
                        Liquidate
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>

      {showOverrideModal && (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4" onClick={() => { setShowOverrideModal(false); setOverrideForm({ coin_symbol: '', override_price: '', duration_minutes: '', reason: '' }); }}>
          <div className="bg-[#181A20] rounded-lg p-6 max-w-md w-full border border-[#2b3139]" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-xl font-bold text-white">Set Price Override</h3>
              <button onClick={() => { setShowOverrideModal(false); setOverrideForm({ coin_symbol: '', override_price: '', duration_minutes: '', reason: '' }); }} className="p-1 hover:bg-[#2b3139] rounded-lg transition-colors">
                <X className="w-5 h-5 text-gray-400 hover:text-white" />
              </button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-sm text-gray-400 mb-2">Coin Symbol</label>
                <input
                  type="text"
                  placeholder="e.g., BTC, ETH"
                  value={overrideForm.coin_symbol}
                  onChange={(e) => setOverrideForm({ ...overrideForm, coin_symbol: e.target.value.toUpperCase() })}
                  className="w-full px-4 py-2 bg-[#0f1114] border border-[#2b3139] rounded-lg text-white focus:outline-none focus:border-[#f0b90b]"
                />
              </div>

              <div>
                <label className="block text-sm text-gray-400 mb-2">Override Price (USD)</label>
                <input
                  type="number"
                  step="0.01"
                  placeholder="e.g., 45000"
                  value={overrideForm.override_price}
                  onChange={(e) => setOverrideForm({ ...overrideForm, override_price: e.target.value })}
                  className="w-full px-4 py-2 bg-[#0f1114] border border-[#2b3139] rounded-lg text-white focus:outline-none focus:border-[#f0b90b]"
                />
              </div>

              <div>
                <label className="block text-sm text-gray-400 mb-2">Duration (minutes, optional)</label>
                <input
                  type="number"
                  placeholder="Leave empty for permanent"
                  value={overrideForm.duration_minutes}
                  onChange={(e) => setOverrideForm({ ...overrideForm, duration_minutes: e.target.value })}
                  className="w-full px-4 py-2 bg-[#0f1114] border border-[#2b3139] rounded-lg text-white focus:outline-none focus:border-[#f0b90b]"
                />
              </div>

              <div>
                <label className="block text-sm text-gray-400 mb-2">Reason (internal note)</label>
                <textarea
                  placeholder="Why are you setting this override?"
                  value={overrideForm.reason}
                  onChange={(e) => setOverrideForm({ ...overrideForm, reason: e.target.value })}
                  className="w-full px-4 py-2 bg-[#0f1114] border border-[#2b3139] rounded-lg text-white focus:outline-none focus:border-[#f0b90b] h-20 resize-none"
                />
              </div>

              <div className="flex gap-3">
                <button
                  onClick={handleApplyOverride}
                  className="flex-1 py-3 bg-[#f6465d] hover:bg-[#ff6b7a] text-white rounded-lg font-medium"
                >
                  Apply Override
                </button>
                <button
                  onClick={() => {
                    setShowOverrideModal(false);
                    setOverrideForm({ coin_symbol: '', override_price: '', duration_minutes: '', reason: '' });
                  }}
                  className="flex-1 py-3 bg-[#2b3139] hover:bg-[#3b4249] text-white rounded-lg"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {showLiquidateConfirm && selectedPosition && (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4" onClick={() => { setShowLiquidateConfirm(false); setSelectedPosition(null); }}>
          <div className="bg-[#181A20] rounded-lg p-6 max-w-md w-full border border-[#f6465d]" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-start justify-between mb-4">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-full bg-[#f6465d]/20 flex items-center justify-center">
                  <AlertTriangle className="w-6 h-6 text-[#f6465d]" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-white">Force Liquidation</h3>
                  <p className="text-sm text-gray-400">This action cannot be undone</p>
                </div>
              </div>
              <button onClick={() => { setShowLiquidateConfirm(false); setSelectedPosition(null); }} className="p-1 hover:bg-[#2b3139] rounded-lg transition-colors">
                <X className="w-5 h-5 text-gray-400 hover:text-white" />
              </button>
            </div>

            <div className="bg-[#0f1114] rounded-lg p-4 mb-4 space-y-2">
              <div className="flex justify-between">
                <span className="text-gray-400">User:</span>
                <span className="text-white">{selectedPosition.user_email}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Position:</span>
                <span className="text-white">{selectedPosition.coin_symbol} {selectedPosition.position_type}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Leverage:</span>
                <span className="text-white">{selectedPosition.leverage}x</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-400">Margin Loss:</span>
                <span className="text-[#f6465d] font-bold">${parseFloat(selectedPosition.margin).toFixed(2)}</span>
              </div>
            </div>

            <p className="text-sm text-gray-400 mb-4">
              The user will lose all margin ({selectedPosition.margin} USDT) from their futures balance. Position will be closed and recorded as liquidated.
            </p>

            <div className="flex gap-3">
              <button
                onClick={handleForceLiquidate}
                className="flex-1 py-3 bg-[#f6465d] hover:bg-[#ff6b7a] text-white rounded-lg font-medium"
              >
                Confirm Liquidation
              </button>
              <button
                onClick={() => {
                  setShowLiquidateConfirm(false);
                  setSelectedPosition(null);
                }}
                className="flex-1 py-3 bg-[#2b3139] hover:bg-[#3b4249] text-white rounded-lg"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
