import { useState, useEffect } from 'react';
import { X, Search, TrendingUp, Clock } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { getProxiedLogoUrl } from '../lib/logo-utils';

interface Coin {
  id: string;
  symbol: string;
  name: string;
  logo_url: string | null;
  is_trending: boolean;
}

interface CoinSelectorProps {
  onClose: () => void;
  onSelectCoin: (coin: Coin) => void;
}

export default function CoinSelector({ onClose, onSelectCoin }: CoinSelectorProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [allCoins, setAllCoins] = useState<Coin[]>([]);
  const [historyCoins, setHistoryCoins] = useState<Coin[]>([]);
  const [trendingCoins, setTrendingCoins] = useState<Coin[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadCoins();
  }, []);

  const loadCoins = async () => {
    try {
      console.log('🔍 CoinSelector: Loading coins...');
      const { data: { user } } = await supabase.auth.getUser();
      console.log('👤 CoinSelector: User ID:', user?.id);

      const { data: coins, error: coinsError } = await supabase
        .from('supported_coins')
        .select('*')
        .eq('is_active', true)
        .order('sort_order', { ascending: true });

      console.log('🪙 CoinSelector: Coins loaded:', coins?.length, 'coins');
      console.log('📊 CoinSelector: Sample coins:', coins?.slice(0, 3));

      if (coinsError) {
        console.error('❌ CoinSelector: Error loading coins:', coinsError);
        throw coinsError;
      }
      setAllCoins(coins || []);
      console.log('✅ CoinSelector: All coins set:', coins?.length);

      const trending = coins?.filter(coin => coin.is_trending) || [];
      setTrendingCoins(trending);

      if (user) {
        const { data: history } = await supabase
          .from('user_coin_history')
          .select(`
            coin_id,
            last_used_at,
            supported_coins (
              id,
              symbol,
              name,
              icon_url,
              is_trending
            )
          `)
          .eq('user_id', user.id)
          .order('last_used_at', { ascending: false })
          .limit(5);

        if (history) {
          const historyCoinsList = history
            .map(h => h.supported_coins)
            .filter(Boolean) as Coin[];
          setHistoryCoins(historyCoinsList);
        }
      }
    } catch (error) {
      console.error('Error loading coins:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredCoins = allCoins.filter(coin =>
    coin.symbol.toLowerCase().includes(searchQuery.toLowerCase()) ||
    coin.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const CoinLogo = ({ coin }: { coin: Coin }) => {
    if (coin.logo_url) {
      return (
        <img
          src={getProxiedLogoUrl(coin.logo_url)}
          alt={coin.symbol}
          className="w-full h-full object-contain"
          onError={(e) => {
            (e.target as HTMLImageElement).style.display = 'none';
            (e.target as HTMLImageElement).parentElement!.innerHTML = '🪙';
          }}
        />
      );
    }
    return <span className="text-2xl">🪙</span>;
  };

  const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.split('');

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
          <h2 className="font-semibold text-white">Select Coin</h2>
          <div className="w-9" />
        </div>

        <div className="p-4 border-white/10">
          <div className="relative">
            <div className="absolute left-3 top-1/2 -translate-y-1/2 w-6 h-6 rounded-full border-2 border-[#F0B90B] flex items-center justify-center">
              <Search className="w-4 h-4 text-[#F0B90B]" />
            </div>
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search Coins"
              className="w-full pl-11 pr-4 py-3 bg-[#0f1419] rounded-xl text-white placeholder-gray-500 focus:ring-[#F0B90B]/20"
            />
          </div>
        </div>

        <div className="flex-1 overflow-y-auto">
          {loading ? (
            <div className="flex items-center justify-center py-12">
              <div className="animate-spin rounded-full h-8 w-8 border-yellow-500"></div>
            </div>
          ) : (
            <>
              {historyCoins.length > 0 && !searchQuery && (
                <div className="p-4 border-white/10">
                  <div className="flex items-center gap-2 mb-3 text-gray-400">
                    <Clock className="w-4 h-4" />
                    <span className="text-sm font-medium">History</span>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {historyCoins.map(coin => (
                      <button
                        key={coin.id}
                        onClick={() => onSelectCoin(coin)}
                        className="px-3 py-1.5 bg-white/5 hover:bg-white/10 rounded-lg text-sm font-medium transition-colors"
                      >
                        {coin.symbol}
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {trendingCoins.length > 0 && !searchQuery && (
                <div className="p-4 border-white/10">
                  <div className="flex items-center gap-2 mb-3 text-gray-400">
                    <TrendingUp className="w-4 h-4" />
                    <span className="text-sm font-medium">Trending</span>
                  </div>
                  <div className="space-y-2">
                    {trendingCoins.map(coin => (
                      <button
                        key={coin.id}
                        onClick={() => onSelectCoin(coin)}
                        className="w-full flex items-center gap-3 p-3 hover:bg-white/5 rounded-xl transition-colors group"
                      >
                        <div className="w-10 h-10 bg-gradient-to-br from-yellow-500/20 to-orange-500/20 rounded-full flex items-center justify-center overflow-hidden p-1.5">
                          <CoinLogo coin={coin} />
                        </div>
                        <div className="flex-1 text-left">
                          <div className="text-white font-medium">{coin.symbol}</div>
                          <div className="text-gray-400">{coin.name}</div>
                        </div>
                      </button>
                    ))}
                  </div>
                </div>
              )}

              {searchQuery && (
                <div className="p-4">
                  <div className="space-y-2">
                    {filteredCoins.length > 0 ? (
                      filteredCoins.map(coin => (
                        <button
                          key={coin.id}
                          onClick={() => onSelectCoin(coin)}
                          className="w-full flex items-center gap-3 p-3 hover:bg-white/5 rounded-xl transition-colors"
                        >
                          <div className="w-10 h-10 bg-gradient-to-br from-yellow-500/20 to-orange-500/20 rounded-full flex items-center justify-center overflow-hidden p-1.5">
                            <CoinLogo coin={coin} />
                          </div>
                          <div className="flex-1 text-left">
                            <div className="text-white font-medium">{coin.symbol}</div>
                            <div className="text-gray-400">{coin.name}</div>
                          </div>
                        </button>
                      ))
                    ) : (
                      <div className="py-8 text-gray-400">
                        No coins found
                      </div>
                    )}
                  </div>
                </div>
              )}

              {!searchQuery && (
                <div className="p-4">
                  <div className="grid grid-cols-[auto_1fr] gap-4">
                    <div className="flex flex-col gap-1">
                      {alphabet.map(letter => (
                        <button
                          key={letter}
                          className="text-gray-500 hover:text-yellow-500 transition-colors py-0.5"
                          onClick={() => {
                            const element = document.getElementById(`letter-${letter}`);
                            element?.scrollIntoView({ behavior: 'smooth' });
                          }}
                        >
                          {letter}
                        </button>
                      ))}
                    </div>
                    <div className="space-y-4">
                      {alphabet.map(letter => {
                        const coinsStartingWith = allCoins.filter(coin =>
                          coin.symbol.startsWith(letter) || coin.name.startsWith(letter)
                        );
                        if (coinsStartingWith.length === 0) return null;

                        return (
                          <div key={letter} id={`letter-${letter}`}>
                            <div className="font-medium text-gray-400 mb-2">{letter}</div>
                            <div className="space-y-2">
                              {coinsStartingWith.map(coin => (
                                <button
                                  key={coin.id}
                                  onClick={() => onSelectCoin(coin)}
                                  className="w-full flex items-center gap-3 p-3 hover:bg-white/5 rounded-xl transition-colors"
                                >
                                  <div className="w-10 h-10 bg-gradient-to-br from-yellow-500/20 to-orange-500/20 rounded-full flex items-center justify-center overflow-hidden p-1.5">
                                    <CoinLogo coin={coin} />
                                  </div>
                                  <div className="flex-1 text-left">
                                    <div className="text-white font-medium">{coin.symbol}</div>
                                    <div className="text-gray-400">{coin.name}</div>
                                  </div>
                                </button>
                              ))}
                            </div>
                          </div>
                        );
                      })}
                    </div>
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
}