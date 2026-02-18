import { useState, useEffect } from 'react';
import { Wallet, Database, Users, TrendingUp, RefreshCw, Plus, Upload, Trash2, X, CheckCircle, AlertCircle } from 'lucide-react';
import { supabase } from '../lib/supabase';

interface WalletStats {
  totalWallets: number;
  assignedWallets: number;
  availableWallets: number;
  bep20Count: number;
  trc20Count: number;
}

interface MasterWallet {
  id: string;
  network: string;
  address: string;
  balance_usdt: number;
  total_collected: number;
}

interface WalletPoolItem {
  id: string;
  network: string;
  address: string;
  is_assigned: boolean;
  assigned_at: string | null;
  assigned_user_id: string | null;
  user_profiles?: {
    email: string;
    full_name: string;
  };
}

export default function WalletPoolManagement() {
  const [stats, setStats] = useState<WalletStats>({
    totalWallets: 0,
    assignedWallets: 0,
    availableWallets: 0,
    bep20Count: 0,
    trc20Count: 0
  });
  const [masterWallets, setMasterWallets] = useState<MasterWallet[]>([]);
  const [recentWallets, setRecentWallets] = useState<WalletPoolItem[]>([]);
  const [allWallets, setAllWallets] = useState<WalletPoolItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [showAddModal, setShowAddModal] = useState(false);
  const [showBulkImportModal, setShowBulkImportModal] = useState(false);
  const [notification, setNotification] = useState<{type: 'success' | 'error', message: string} | null>(null);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    setLoading(true);
    try {
      await Promise.all([
        fetchStats(),
        fetchMasterWallets(),
        fetchRecentWallets(),
        fetchAllWallets()
      ]);
    } catch (error) {
      console.error('Error fetching wallet data:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchStats = async () => {
    const { data, error } = await supabase
      .from('wallet_pool')
      .select('network, is_assigned');

    if (error) throw error;

    const stats: WalletStats = {
      totalWallets: data.length,
      assignedWallets: data.filter(w => w.is_assigned).length,
      availableWallets: data.filter(w => !w.is_assigned).length,
      bep20Count: data.filter(w => w.network === 'BEP20').length,
      trc20Count: data.filter(w => w.network === 'TRC20').length
    };

    setStats(stats);
  };

  const fetchMasterWallets = async () => {
    const { data, error } = await supabase
      .from('master_wallets')
      .select('*')
      .order('network');

    if (error) throw error;
    setMasterWallets(data || []);
  };

  const fetchRecentWallets = async () => {
    const { data, error } = await supabase
      .from('wallet_pool')
      .select(`
        id,
        network,
        address,
        is_assigned,
        assigned_at,
        assigned_user_id,
        user_profiles:assigned_user_id (
          email,
          full_name
        )
      `)
      .order('created_at', { ascending: false })
      .limit(10);

    if (error) throw error;
    setRecentWallets(data || []);
  };

  const fetchAllWallets = async () => {
    const { data, error } = await supabase
      .from('wallet_pool')
      .select(`
        id,
        network,
        address,
        is_assigned,
        assigned_at,
        assigned_user_id,
        user_profiles:assigned_user_id (
          email,
          full_name
        )
      `)
      .order('created_at', { ascending: false });

    if (error) throw error;
    setAllWallets(data || []);
  };

  const showNotification = (type: 'success' | 'error', message: string) => {
    setNotification({ type, message });
    setTimeout(() => setNotification(null), 5000);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-96">
        <RefreshCw className="w-8 h-8 animate-spin text-blue-500" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Notification */}
      {notification && (
        <div className={`fixed top-4 right-4 z-50 flex items-center space-x-3 px-6 py-4 rounded-lg shadow-lg ${
          notification.type === 'success' ? 'bg-green-500' : 'bg-red-500'
        } text-white animate-slide-in`}>
          {notification.type === 'success' ? (
            <CheckCircle className="w-5 h-5" />
          ) : (
            <AlertCircle className="w-5 h-5" />
          )}
          <span className="font-medium">{notification.message}</span>
        </div>
      )}

      {/* Action Buttons */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Cüzdan Havuzu Yönetimi</h2>
          <p className="text-sm text-gray-500 mt-1">Sadece adres girin - Yeni kullanıcılara otomatik atanır</p>
        </div>
        <div className="flex flex-col sm:flex-row gap-2 sm:gap-3">
          <button
            onClick={() => setShowBulkImportModal(true)}
            className="flex items-center justify-center space-x-2 px-3 sm:px-4 py-2 bg-blue-500 hover:bg-blue-600 text-white rounded-lg transition-colors text-sm sm:text-base"
          >
            <Upload className="w-4 h-4" />
            <span>Toplu Ekle</span>
          </button>
          <button
            onClick={() => setShowAddModal(true)}
            className="flex items-center justify-center space-x-2 px-3 sm:px-4 py-2 bg-green-500 hover:bg-green-600 text-white rounded-lg transition-colors text-sm sm:text-base"
          >
            <Plus className="w-4 h-4" />
            <span>Cüzdan Ekle</span>
          </button>
        </div>
      </div>

      {/* Stats Overview */}
      <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
        <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl p-6 text-white">
          <div className="flex items-center justify-between mb-4">
            <Database className="w-8 h-8 opacity-80" />
          </div>
          <div className="text-3xl font-bold mb-1">
            {stats.totalWallets.toLocaleString()}
          </div>
          <div className="text-blue-100 text-sm">Toplam Cüzdan</div>
        </div>

        <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-xl p-6 text-white">
          <div className="flex items-center justify-between mb-4">
            <Users className="w-8 h-8 opacity-80" />
          </div>
          <div className="text-3xl font-bold mb-1">
            {stats.assignedWallets.toLocaleString()}
          </div>
          <div className="text-green-100 text-sm">Atanmış</div>
        </div>

        <div className="bg-gradient-to-br from-yellow-500 to-yellow-600 rounded-xl p-6 text-white">
          <div className="flex items-center justify-between mb-4">
            <Wallet className="w-8 h-8 opacity-80" />
          </div>
          <div className="text-3xl font-bold mb-1">
            {stats.availableWallets.toLocaleString()}
          </div>
          <div className="text-yellow-100 text-sm">Boşta</div>
        </div>

        <div className="bg-gradient-to-br from-orange-500 to-orange-600 rounded-xl p-6 text-white">
          <div className="flex items-center justify-between mb-4">
            <div className="text-sm font-bold">BEP-20</div>
          </div>
          <div className="text-3xl font-bold mb-1">
            {stats.bep20Count.toLocaleString()}
          </div>
          <div className="text-orange-100 text-sm">BSC Network</div>
        </div>

        <div className="bg-gradient-to-br from-red-500 to-red-600 rounded-xl p-6 text-white">
          <div className="flex items-center justify-between mb-4">
            <div className="text-sm font-bold">TRC-20</div>
          </div>
          <div className="text-3xl font-bold mb-1">
            {stats.trc20Count.toLocaleString()}
          </div>
          <div className="text-red-100 text-sm">TRON Network</div>
        </div>
      </div>

      {/* Master Wallets */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-200 bg-gradient-to-r from-purple-50 to-pink-50">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <Wallet className="w-5 h-5 text-purple-600" />
              <h3 className="text-lg font-semibold text-gray-900">Master Wallets</h3>
            </div>
            <button
              onClick={fetchMasterWallets}
              className="p-2 hover:bg-white/50 rounded-lg transition-colors"
            >
              <RefreshCw className="w-4 h-4 text-purple-600" />
            </button>
          </div>
        </div>

        <div className="divide-y divide-gray-200">
          {masterWallets.map((wallet) => (
            <div key={wallet.id} className="p-6 hover:bg-gray-50">
              <div className="flex items-start justify-between">
                <div className="flex-1">
                  <div className="flex items-center space-x-3 mb-3">
                    <span className={`px-3 py-1 rounded-full text-xs font-bold ${
                      wallet.network === 'BEP20'
                        ? 'bg-orange-100 text-orange-700'
                        : 'bg-red-100 text-red-700'
                    }`}>
                      {wallet.network}
                    </span>
                    <span className="text-gray-500 text-sm">Master Collection Wallet</span>
                  </div>

                  <div className="mb-4">
                    <div className="text-xs text-gray-500 mb-1">Address</div>
                    <div className="font-mono text-xs sm:text-sm text-gray-900 bg-gray-50 px-3 py-2 rounded-lg break-all">
                      {wallet.address}
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <div className="text-xs text-gray-500 mb-1">Current Balance</div>
                      <div className="text-xl font-bold text-green-600">
                        ${wallet.balance_usdt.toLocaleString()} USDT
                      </div>
                    </div>
                    <div>
                      <div className="text-xs text-gray-500 mb-1">Total Collected</div>
                      <div className="text-xl font-bold text-blue-600">
                        ${wallet.total_collected.toLocaleString()} USDT
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* All Wallets List */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-200 bg-gradient-to-r from-blue-50 to-cyan-50">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <TrendingUp className="w-5 h-5 text-blue-600" />
              <h3 className="text-lg font-semibold text-gray-900">Tüm Cüzdanlar ({allWallets.length})</h3>
            </div>
            <button
              onClick={fetchAllWallets}
              className="p-2 hover:bg-white/50 rounded-lg transition-colors"
            >
              <RefreshCw className="w-4 h-4 text-blue-600" />
            </button>
          </div>
        </div>

        <div className="overflow-x-auto max-h-96 overflow-y-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-200 sticky top-0">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Network</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Address</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Assigned To</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {allWallets.map((wallet) => (
                <WalletRow
                  key={wallet.id}
                  wallet={wallet}
                  onDelete={() => {
                    fetchData();
                    showNotification('success', 'Cüzdan silindi');
                  }}
                />
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Add Wallet Modal */}
      {showAddModal && (
        <AddWalletModal
          onClose={() => setShowAddModal(false)}
          onSuccess={() => {
            setShowAddModal(false);
            fetchData();
            showNotification('success', 'Cüzdan başarıyla eklendi!');
          }}
        />
      )}

      {/* Bulk Import Modal */}
      {showBulkImportModal && (
        <BulkImportModal
          onClose={() => setShowBulkImportModal(false)}
          onSuccess={(count) => {
            setShowBulkImportModal(false);
            fetchData();
            showNotification('success', `${count} cüzdan başarıyla eklendi!`);
          }}
        />
      )}
    </div>
  );
}

function WalletRow({ wallet, onDelete }: { wallet: WalletPoolItem; onDelete: () => void }) {
  const [isDeleting, setIsDeleting] = useState(false);

  const handleDelete = async () => {
    if (!confirm('Bu cüzdanı silmek istediğinizden emin misiniz?')) return;

    setIsDeleting(true);
    const { error } = await supabase
      .from('wallet_pool')
      .delete()
      .eq('id', wallet.id);

    if (error) {
      alert('Hata: ' + error.message);
    } else {
      onDelete();
    }
    setIsDeleting(false);
  };

  return (
    <tr className="hover:bg-gray-50">
      <td className="px-6 py-4">
        <span className={`px-2 py-1 rounded-full text-xs font-bold ${
          wallet.network === 'BEP20'
            ? 'bg-orange-100 text-orange-700'
            : 'bg-red-100 text-red-700'
        }`}>
          {wallet.network}
        </span>
      </td>
      <td className="px-6 py-4">
        <div className="font-mono text-sm text-gray-900">
          {wallet.address.slice(0, 10)}...{wallet.address.slice(-8)}
        </div>
      </td>
      <td className="px-6 py-4">
        <span className={`px-2 py-1 rounded-full text-xs font-bold ${
          wallet.is_assigned
            ? 'bg-green-100 text-green-700'
            : 'bg-gray-100 text-gray-700'
        }`}>
          {wallet.is_assigned ? 'Atanmış' : 'Boşta'}
        </span>
      </td>
      <td className="px-6 py-4">
        {wallet.user_profiles ? (
          <div>
            <div className="text-sm font-medium text-gray-900">
              {wallet.user_profiles.full_name || 'N/A'}
            </div>
            <div className="text-xs text-gray-500">
              {wallet.user_profiles.email}
            </div>
          </div>
        ) : (
          <span className="text-sm text-gray-400">-</span>
        )}
      </td>
      <td className="px-6 py-4">
        {!wallet.is_assigned && (
          <button
            onClick={handleDelete}
            disabled={isDeleting}
            className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors disabled:opacity-50"
          >
            <Trash2 className="w-4 h-4" />
          </button>
        )}
      </td>
    </tr>
  );
}

function AddWalletModal({ onClose, onSuccess }: { onClose: () => void; onSuccess: () => void }) {
  const [address, setAddress] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [detectedNetwork, setDetectedNetwork] = useState<string>('');

  const detectAndValidateAddress = (address: string): { valid: boolean; network?: string; error?: string } => {
    const trimmedAddress = address.trim();

    if (!trimmedAddress) {
      return { valid: false };
    }

    if (trimmedAddress.startsWith('0x')) {
      if (trimmedAddress.length !== 42) {
        return { valid: false, error: 'BEP20 adresi 42 karakter olmalıdır' };
      }
      if (!/^0x[0-9a-fA-F]{40}$/.test(trimmedAddress)) {
        return { valid: false, error: 'Geçersiz BEP20 adresi' };
      }
      return { valid: true, network: 'BEP20' };
    } else if (trimmedAddress.startsWith('T')) {
      if (trimmedAddress.length !== 34) {
        return { valid: false, error: 'TRC20 adresi 34 karakter olmalıdır' };
      }
      if (!/^T[1-9A-HJ-NP-Za-km-z]{33}$/.test(trimmedAddress)) {
        return { valid: false, error: 'Geçersiz TRC20 adresi' };
      }
      return { valid: true, network: 'TRC20' };
    }

    return { valid: false, error: 'Adres 0x (BEP20) veya T (TRC20) ile başlamalıdır' };
  };

  const handleAddressChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newAddress = e.target.value;
    setAddress(newAddress);
    const result = detectAndValidateAddress(newAddress);
    setDetectedNetwork(result.network || '');
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!address.trim()) {
      setError('Cüzdan adresi zorunludur');
      return;
    }

    const validation = detectAndValidateAddress(address);
    if (!validation.valid) {
      setError(validation.error || 'Geçersiz adres formatı');
      return;
    }

    setLoading(true);

    try {
      const { data, error: rpcError } = await supabase.rpc('safe_add_wallet', {
        p_address: address.trim(),
        p_network: validation.network
      });

      if (rpcError) throw rpcError;

      const result = data as any;
      if (!result.success) {
        throw new Error(result.message || 'Cüzdan eklenemedi');
      }

      onSuccess();
    } catch (err: any) {
      setError(err.message || 'Cüzdan eklenirken hata oluştu');
    } finally {
      setLoading(false);
    }
  };

  const validation = detectAndValidateAddress(address);

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl max-w-md w-full shadow-2xl">
        <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
          <h3 className="text-lg font-bold text-gray-900">Cüzdan Ekle</h3>
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {error && (
            <div className="p-3 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700">
              {error}
            </div>
          )}

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Cüzdan Adresi
            </label>
            <input
              type="text"
              value={address}
              onChange={handleAddressChange}
              placeholder="0x... veya T... ile başlayan adres"
              className={`w-full px-3 sm:px-4 py-3 border-2 rounded-lg focus:ring-2 focus:border-transparent font-mono text-xs sm:text-sm break-all ${
                address.trim() && !validation.valid
                  ? 'border-red-300 focus:ring-red-500 bg-red-50'
                  : address.trim() && validation.valid
                  ? 'border-green-300 focus:ring-green-500 bg-green-50'
                  : 'border-gray-300 focus:ring-blue-500'
              }`}
              required
            />

            {detectedNetwork && validation.valid && (
              <div className="mt-2 flex items-center space-x-2">
                <span className={`px-3 py-1 rounded-full text-xs font-bold ${
                  detectedNetwork === 'BEP20'
                    ? 'bg-orange-100 text-orange-700'
                    : 'bg-red-100 text-red-700'
                }`}>
                  {detectedNetwork}
                </span>
                <CheckCircle className="w-4 h-4 text-green-600" />
                <span className="text-xs text-green-600 font-medium">Otomatik tespit edildi</span>
              </div>
            )}

            {address.trim() && !validation.valid && (
              <div className="mt-2 flex items-start space-x-2 text-xs text-red-600">
                <AlertCircle className="w-4 h-4 flex-shrink-0 mt-0.5" />
                <span>{validation.error}</span>
              </div>
            )}

            <p className="text-xs text-gray-500 mt-2">
              Adresi yapıştır, sistem otomatik olarak BEP20 veya TRC20 olduğunu anlayacak
            </p>
          </div>

          <div className="flex gap-2 sm:gap-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 px-3 sm:px-4 py-2.5 sm:py-3 border border-gray-300 rounded-lg font-medium hover:bg-gray-50 transition-colors text-sm sm:text-base"
            >
              İptal
            </button>
            <button
              type="submit"
              disabled={loading || !validation.valid}
              className="flex-1 px-3 sm:px-4 py-2.5 sm:py-3 bg-green-500 hover:bg-green-600 text-white rounded-lg font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed text-sm sm:text-base"
            >
              {loading ? 'Ekleniyor...' : 'Ekle'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function BulkImportModal({ onClose, onSuccess }: { onClose: () => void; onSuccess: (count: number) => void }) {
  const [importText, setImportText] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const detectAndValidateAddress = (address: string): { valid: boolean; network?: string; error?: string } => {
    const trimmedAddress = address.trim();

    if (!trimmedAddress) {
      return { valid: false, error: 'Adres boş olamaz' };
    }

    if (trimmedAddress.startsWith('0x')) {
      if (trimmedAddress.length !== 42) {
        return { valid: false, error: 'BEP20 adresi 42 karakter olmalıdır' };
      }
      if (!/^0x[0-9a-fA-F]{40}$/.test(trimmedAddress)) {
        return { valid: false, error: 'Geçersiz BEP20 adresi' };
      }
      return { valid: true, network: 'BEP20' };
    } else if (trimmedAddress.startsWith('T')) {
      if (trimmedAddress.length !== 34) {
        return { valid: false, error: 'TRC20 adresi 34 karakter olmalıdır' };
      }
      if (!/^T[1-9A-HJ-NP-Za-km-z]{33}$/.test(trimmedAddress)) {
        return { valid: false, error: 'Geçersiz TRC20 adresi' };
      }
      return { valid: true, network: 'TRC20' };
    }

    return { valid: false, error: 'Adres 0x (BEP20) veya T (TRC20) ile başlamalıdır' };
  };

  const handleImport = async () => {
    setError('');

    if (!importText.trim()) {
      setError('Lütfen cüzdan adreslerini girin');
      return;
    }

    setLoading(true);

    try {
      const lines = importText.trim().split('\n').filter(line => line.trim());
      const wallets: any[] = [];
      const errors: string[] = [];

      for (let i = 0; i < lines.length; i++) {
        const address = lines[i].trim();

        if (!address) {
          continue;
        }

        const validation = detectAndValidateAddress(address);
        if (!validation.valid) {
          errors.push(`Satır ${i + 1}: ${validation.error} (${address.slice(0, 20)}...)`);
          continue;
        }

        wallets.push({
          network: validation.network,
          address: address,
          encrypted_private_key: 'admin-added-no-key',
          is_assigned: false
        });
      }

      if (errors.length > 0) {
        setError(`Şu hatalı adresler atlandı:\n${errors.slice(0, 5).join('\n')}${errors.length > 5 ? `\n... ve ${errors.length - 5} hata daha` : ''}`);
      }

      if (wallets.length === 0) {
        setError('Geçerli cüzdan bulunamadı. Tüm adresler hatalı.');
        setLoading(false);
        return;
      }

      let successCount = 0;
      const insertErrors: string[] = [];

      for (const wallet of wallets) {
        const { data, error } = await supabase.rpc('safe_add_wallet', {
          p_address: wallet.address,
          p_network: wallet.network
        });

        if (error || (data && !(data as any).success)) {
          const errorMsg = error?.message || (data as any)?.message || 'Unknown error';
          insertErrors.push(`${wallet.address.slice(0, 20)}...: ${errorMsg}`);
        } else {
          successCount++;
        }
      }

      if (insertErrors.length > 0) {
        const errorMsg = `${successCount} cüzdan eklendi, ${insertErrors.length} hata:\n${insertErrors.slice(0, 3).join('\n')}${insertErrors.length > 3 ? `\n... ve ${insertErrors.length - 3} hata daha` : ''}`;
        if (successCount === 0) {
          setError(errorMsg);
          setLoading(false);
          return;
        } else {
          setError(errorMsg);
        }
      }

      onSuccess(successCount);
    } catch (err: any) {
      setError(err.message || 'Toplu ekleme sırasında hata oluştu');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl max-w-2xl w-full shadow-2xl">
        <div className="px-6 py-4 border-b border-gray-200 flex items-center justify-between">
          <h3 className="text-lg font-bold text-gray-900">Toplu Cüzdan Ekle</h3>
          <button
            onClick={onClose}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-6 space-y-4">
          {error && (
            <div className="p-4 bg-red-50 border border-red-200 rounded-lg text-sm text-red-700 max-h-48 overflow-y-auto">
              <div className="flex items-start space-x-2">
                <AlertCircle className="w-5 h-5 flex-shrink-0 mt-0.5" />
                <pre className="whitespace-pre-wrap font-sans">{error}</pre>
              </div>
            </div>
          )}

          <div className="bg-gradient-to-br from-green-50 to-emerald-50 border-2 border-green-300 rounded-xl p-5">
            <h4 className="font-bold text-green-900 mb-3 text-lg flex items-center space-x-2">
              <CheckCircle className="w-6 h-6" />
              <span>Süper Basit!</span>
            </h4>
            <div className="bg-white rounded-lg p-4 mb-4">
              <div className="text-sm text-gray-800 space-y-2">
                <p className="font-semibold text-green-700">Sadece adresleri yapıştır!</p>
                <ul className="list-disc list-inside space-y-1 text-gray-700">
                  <li>Her satıra bir adres</li>
                  <li>Network otomatik tespit edilir</li>
                  <li>0x ile başlarsa BEP20</li>
                  <li>T ile başlarsa TRC20</li>
                </ul>
              </div>
            </div>
            <div className="text-sm text-gray-700">
              <div className="font-semibold mb-2">Örnek:</div>
              <div className="font-mono bg-white p-3 sm:p-4 rounded-lg border-2 border-green-200 text-xs space-y-1 break-all">
                <div className="break-all">0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb</div>
                <div className="break-all">TYASr5UV6HEcXatwdFQfmLVUqQQQMUxHLS</div>
                <div className="break-all">0x1234567890123456789012345678901234567890</div>
                <div className="break-all">TMuA6YqfCeX8EhbfYEg5y7S4DqzSJireY9</div>
              </div>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Cüzdan Adreslerini Yapıştır
            </label>
            <textarea
              value={importText}
              onChange={(e) => setImportText(e.target.value)}
              placeholder="0x742d35Cc...&#10;TYASr5UV6HE...&#10;0x12345678...&#10;TMuA6YqfCeX..."
              className="w-full h-64 px-3 sm:px-4 py-3 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-green-500 font-mono text-xs sm:text-sm resize-none break-all overflow-auto"
            />
            <p className="text-xs text-gray-500 mt-2 flex items-center space-x-1">
              <CheckCircle className="w-3.5 h-3.5 text-green-600" />
              <span>Her satıra bir adres - Network otomatik tespit edilir</span>
            </p>
          </div>

          <div className="flex gap-2 sm:gap-3 pt-4">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 px-3 sm:px-4 py-2.5 sm:py-3 border border-gray-300 rounded-lg font-medium hover:bg-gray-50 transition-colors text-sm sm:text-base"
            >
              İptal
            </button>
            <button
              type="button"
              onClick={handleImport}
              disabled={loading}
              className="flex-1 px-3 sm:px-4 py-2.5 sm:py-3 bg-green-500 hover:bg-green-600 text-white rounded-lg font-medium transition-colors disabled:opacity-50 text-sm sm:text-base"
            >
              {loading ? 'Ekleniyor...' : 'Ekle'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
