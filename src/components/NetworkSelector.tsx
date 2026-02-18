import { X, AlertCircle } from 'lucide-react';
import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';

interface Network {
  id: string;
  network_name: string;
  network_code: string;
  chain_id: string | null;
  contract_address: string | null;
  min_deposit: number;
  confirmations_required: number;
  estimated_arrival_minutes: number;
  withdrawal_fee: number;
  is_mainnet: boolean;
}

interface NetworkSelectorProps {
  coinId: string;
  coinSymbol: string;
  coinName: string;
  coinIconUrl: string | null;
  onClose: () => void;
  onSelectNetwork: (network: Network) => void;
}

export default function NetworkSelector({
  coinId,
  coinSymbol,
  coinName,
  coinIconUrl,
  onClose,
  onSelectNetwork
}: NetworkSelectorProps) {
  const [networks, setNetworks] = useState<Network[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadNetworks();
  }, [coinId]);

  const loadNetworks = async () => {
    try {
      const { data, error } = await supabase
        .from('supported_networks')
        .select('*')
        .eq('coin_id', coinId)
        .eq('is_active', true)
        .order('sort_order', { ascending: true });

      if (error) throw error;
      setNetworks(data || []);
    } catch (error) {
      console.error('Error loading networks:', error);
    } finally {
      setLoading(false);
    }
  };

  const getNetworkIcon = (code: string) => {
    const icons: Record<string, string> = {
      'BEP20': '🔶',
      'TRC20': '⚡',
      'ERC20': 'Ξ',
      'Polygon': '🔷',
      'BTC': '₿'
    };
    return icons[code] || '🌐';
  };

  return (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-[#1a1f2e] rounded-2xl w-full max-h-[80vh] overflow-hidden flex flex-col">
        <div className="flex items-center justify-between p-4 border-white/10">
          <button
            onClick={onClose}
            className="p-2 hover:bg-white/5 rounded-lg transition-colors"
          >
            <X className="w-5 h-5 text-gray-400" />
          </button>
          <div className="flex items-center gap-2">
            {coinIconUrl && (
              <div className="w-8 h-8 rounded-full overflow-hidden bg-white/10 p-1">
                <img src={coinIconUrl} alt={coinSymbol} className="w-full h-full object-contain" />
              </div>
            )}
            <h2 className="font-semibold text-white">Deposit {coinSymbol}</h2>
          </div>
          <div className="w-9" />
        </div>

        <div className="flex-1 overflow-y-auto">
          {loading ? (
            <div className="flex items-center justify-center py-12">
              <div className="animate-spin rounded-full h-8 w-8 border-yellow-500"></div>
            </div>
          ) : (
            <>
              <div className="p-4">
                <h3 className="font-semibold text-white mb-4">Choose Network</h3>
                <div className="space-y-3">
                  {networks.map(network => (
                    <button
                      key={network.id}
                      onClick={() => onSelectNetwork(network)}
                      className="w-full p-4 bg-[#0f1419] hover:bg-white/5 rounded-xl transition-colors border border-white/5 text-left"
                    >
                      <div className="flex items-start gap-3">
                        <div className="text-3xl mt-1">
                          {getNetworkIcon(network.network_code)}
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-2">
                            <span className="font-semibold text-lg">
                              {network.network_code}
                            </span>
                            <span className="text-gray-400">
                              {network.network_name}
                            </span>
                            {!network.is_mainnet && (
                              <span className="px-2 py-0.5 bg-yellow-500/20 text-xs rounded">
                                Testnet
                              </span>
                            )}
                          </div>
                          <div className="space-y-1 text-gray-400">
                            <div>
                              {network.confirmations_required} block confirmation/s
                            </div>
                            <div>
                              Min. deposit {'>'}{network.min_deposit} {coinSymbol}
                            </div>
                            <div>
                              Est. arrival {network.estimated_arrival_minutes} mins
                            </div>
                          </div>
                        </div>
                      </div>
                    </button>
                  ))}
                </div>
              </div>

              <div className="p-4 bg-blue-500/10 border-blue-500/20">
                <div className="flex gap-3">
                  <AlertCircle className="w-5 h-5 text-blue-400 flex-shrink-0 mt-0.5" />
                  <p className="text-blue-300">
                    Please note that only supported networks on our platform are shown.
                    If you deposit via another network your assets may be lost.
                  </p>
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}