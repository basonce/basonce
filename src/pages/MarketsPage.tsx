import { useState, useEffect, useRef } from 'react';
import { Search, ChevronDown } from 'lucide-react';
import { EarnQuestPriceManager } from '../lib/earnquest-price';
import { PriceCache } from '../lib/price-cache';
import { supabase } from '../lib/supabase';
import { getProxiedLogoUrl } from '../lib/logo-utils';
import { formatPriceWithSymbol, formatVolumeWithSymbol } from '../lib/format-utils';

interface Market {
  symbol: string;
  name: string;
  fullName: string;
  price: number;
  change24h: number;
  volume: number;
  logo: string;
  binanceSymbol: string | null;
  direction: 'up' | 'down' | 'neutral';
  isEarnQuest?: boolean;
  flashClass: string;
}

export default function MarketsPage() {
  const [markets, setMarkets] = useState<Market[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [showAllCoins, setShowAllCoins] = useState(false);
  const [sortBy, setSortBy] = useState<'volume' | 'price' | 'change'>('volume');
  const [loading, setLoading] = useState(true);
  const priceManager = useRef(EarnQuestPriceManager.getInstance());
  const priceCache = useRef(PriceCache.getInstance());
  const flashTimers = useRef<Map<string, number>>(new Map());

  useEffect(() => {
    loadCoins();
    return () => {
      flashTimers.current.forEach(t => clearTimeout(t));
    };
  }, []);

  useEffect(() => {
    if (markets.length === 0) return;

    const unsubCache = priceCache.current.subscribe(() => {
      updateFromCache();
    });

    const unsubEQ = priceManager.current.subscribe(() => {
      setMarkets(prev => prev.map(m => {
        if (!m.isEarnQuest) return m;
        return {
          ...m,
          price: priceManager.current.getPrice(),
          change24h: priceManager.current.getChange(),
          volume: priceManager.current.getMarketCap(),
          direction: 'up',
          flashClass: 'animate-flash-green'
        };
      }));
    });

    return () => {
      unsubCache();
      unsubEQ();
    };
  }, [markets.length]);

  const loadCoins = async () => {
    try {
      const { data: coins } = await supabase
        .from('supported_coins')
        .select('symbol, name, logo_url, binance_symbol, is_spot_enabled')
        .eq('is_active', true)
        .eq('is_spot_enabled', true)
        .order('sort_order');

      if (!coins) { setLoading(false); return; }

      if (!priceCache.current.isReady()) {
        await priceCache.current.init();
      }

      const initialMarkets: Market[] = coins.map(coin => {
        if (coin.symbol === 'EQ') {
          return {
            symbol: coin.symbol,
            name: coin.symbol,
            fullName: coin.name,
            price: priceManager.current.getPrice(),
            change24h: priceManager.current.getChange(),
            volume: priceManager.current.getMarketCap(),
            logo: getProxiedLogoUrl(coin.logo_url) || '/earnquest-logo-icon-2.png',
            binanceSymbol: null,
            direction: 'neutral' as const,
            isEarnQuest: true,
            flashClass: ''
          };
        }

        if (coin.symbol === 'USDT') {
          return {
            symbol: coin.symbol,
            name: coin.symbol,
            fullName: coin.name,
            price: 1.0,
            change24h: 0,
            volume: 145000000000,
            logo: getProxiedLogoUrl(coin.logo_url),
            binanceSymbol: null,
            direction: 'neutral' as const,
            flashClass: ''
          };
        }

        const binSym = coin.binance_symbol || `${coin.symbol}USDT`;
        const cached = priceCache.current.get(binSym);

        return {
          symbol: coin.symbol,
          name: coin.symbol,
          fullName: coin.name,
          price: cached?.price || 0,
          change24h: cached?.change24h || 0,
          volume: cached?.volume || 0,
          logo: getProxiedLogoUrl(coin.logo_url),
          binanceSymbol: binSym,
          direction: cached?.direction || 'neutral',
          flashClass: ''
        };
      });

      setMarkets(initialMarkets);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching markets:', error);
      setLoading(false);
    }
  };

  const updateFromCache = () => {
    setMarkets(prev => prev.map(m => {
      if (m.isEarnQuest || m.symbol === 'USDT' || !m.binanceSymbol) return m;

      const cached = priceCache.current.get(m.binanceSymbol);
      if (!cached) return m;

      const priceChanged = cached.price !== m.price;
      const dir = cached.direction;

      if (priceChanged) {
        const existing = flashTimers.current.get(m.symbol);
        if (existing) clearTimeout(existing);
        const timer = window.setTimeout(() => {
          setMarkets(c => c.map(x =>
            x.symbol === m.symbol ? { ...x, flashClass: '' } : x
          ));
        }, 600);
        flashTimers.current.set(m.symbol, timer);
      }

      return {
        ...m,
        price: cached.price,
        change24h: cached.change24h,
        volume: cached.volume,
        direction: dir,
        flashClass: priceChanged
          ? (dir === 'up' ? 'animate-flash-green' : dir === 'down' ? 'animate-flash-red' : '')
          : m.flashClass
      };
    }));
  };

  const formatPrice = formatPriceWithSymbol;
  const formatVolume = formatVolumeWithSymbol;

  const getRandomBidAsk = (price: number) => {
    if (price === 0) return { high: 0, low: 0, bid: 0, ask: 0 };
    const high = price * (1 + Math.random() * 0.02);
    const low = price * (1 - Math.random() * 0.02);
    const bid = price * (1 - Math.random() * 0.001);
    const ask = price * (1 + Math.random() * 0.001);
    return { high, low, bid, ask };
  };

  const filtered = markets
    .filter(m =>
      m.symbol.toLowerCase().includes(searchQuery.toLowerCase()) ||
      m.fullName.toLowerCase().includes(searchQuery.toLowerCase())
    )
    .sort((a, b) => {
      if (a.isEarnQuest) return -1;
      if (b.isEarnQuest) return 1;
      if (sortBy === 'volume') return b.volume - a.volume;
      if (sortBy === 'price') return b.price - a.price;
      if (sortBy === 'change') return b.change24h - a.change24h;
      return 0;
    });

  const visibleMarkets = showAllCoins ? filtered : filtered.slice(0, 15);

  return (
    <>
      <style>{`
        @keyframes flashGreen {
          0% { background-color: rgba(14, 203, 129, 0.25); }
          100% { background-color: transparent; }
        }
        @keyframes flashRed {
          0% { background-color: rgba(246, 70, 93, 0.25); }
          100% { background-color: transparent; }
        }
        .animate-flash-green { animation: flashGreen 0.6s ease-out; }
        .animate-flash-red { animation: flashRed 0.6s ease-out; }
      `}</style>
      <div className="min-h-screen bg-[#0B0E11] text-white pb-20 max-w-[480px] mx-auto">
        <div className="bg-[#0B0E11] pt-4 px-4">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <h1 className="font-bold text-white text-lg">Markets</h1>
              <span className="bg-[#F0B90B] text-[10px] font-bold px-2 py-0.5 rounded text-black">LIVE</span>
            </div>
            <span className="text-[13px] text-gray-400">{filtered.length} pairs</span>
          </div>

          <div className="mb-4 bg-[#1A1D24] border border-[#2B3139] rounded-lg px-3 py-2.5 flex items-center gap-2">
            <Search className="w-4 h-4 text-gray-400" />
            <input
              type="text"
              placeholder="Search coin name or symbol"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="bg-transparent border-none outline-none flex-1 placeholder-[#5E6673] text-[13px]"
            />
          </div>

          <div className="flex items-center gap-2 mb-4">
            {(['volume', 'change', 'price'] as const).map(s => (
              <button
                key={s}
                onClick={() => setSortBy(s)}
                className={`px-3 py-1.5 rounded text-[12px] font-medium transition-colors ${
                  sortBy === s ? 'bg-[#F0B90B] text-black' : 'bg-[#2B3139] text-gray-400'
                }`}
              >
                {s === 'volume' ? 'Volume' : s === 'change' ? 'Change' : 'Price'}
              </button>
            ))}
          </div>
        </div>

        {loading ? (
          <div className="flex justify-center py-16">
            <div className="w-8 h-8 border-2 border-[#F0B90B] border-t-transparent rounded-full animate-spin" />
          </div>
        ) : filtered.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-16 px-4">
            <Search className="w-12 h-12 text-[#474D57] mb-3" />
            <p className="text-sm text-gray-400">No results found</p>
          </div>
        ) : (
          <div className="space-y-3 px-4">
            {visibleMarkets.map((market) => {
              const { high, low, bid, ask } = getRandomBidAsk(market.price);

              return (
                <div
                  key={market.symbol}
                  className={`bg-[#1A1D24] rounded-lg p-4 border border-[#2B3139] ${market.flashClass}`}
                >
                  <div
                    className="flex items-start justify-between mb-4 cursor-pointer active:opacity-70"
                    onClick={() => {
                      localStorage.setItem('currentTab', 'trade');
                      localStorage.setItem('selectedCoinSymbol', market.symbol);
                      localStorage.setItem('selectedCoinSide', 'buy');
                      window.dispatchEvent(new CustomEvent('navigate-to-trade', {
                        detail: { symbol: market.symbol, side: 'buy' }
                      }));
                    }}
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-12 h-12 rounded-full bg-gradient-to-br from-purple-500/20 to-pink-500/20 border border-purple-500/30 flex items-center justify-center overflow-hidden flex-shrink-0">
                        {market.logo ? (
                          <img
                            src={market.logo}
                            alt=""
                            className="w-full h-full object-cover"
                            loading="lazy"
                            onError={(e) => {
                              (e.target as HTMLImageElement).style.display = 'none';
                              const p = (e.target as HTMLImageElement).parentElement;
                              if (p) p.innerHTML = `<span class="text-white font-bold">${market.symbol.slice(0, 2)}</span>`;
                            }}
                          />
                        ) : (
                          <span className="text-white font-bold">{market.symbol.slice(0, 2)}</span>
                        )}
                      </div>
                      <div>
                        <div className="font-bold text-white text-lg">{market.symbol}</div>
                        <div className="text-[#848E9C] text-xs">/USDT</div>
                      </div>
                    </div>

                    <div className="text-right">
                      <div className="font-bold text-white text-xl mb-0.5">{formatPrice(market.price)}</div>
                      <div className="text-[#848E9C] text-xs">{formatVolume(market.volume)}</div>
                    </div>
                  </div>

                  <div className="flex items-center justify-between mb-4">
                    <div className={`text-lg font-bold ${
                      market.change24h >= 0 ? 'text-[#0ECB81]' : 'text-[#F6465D]'
                    }`}>
                      {market.price === 0 ? '0.00%' : `${market.change24h >= 0 ? '+' : ''}${market.change24h.toFixed(2)}%`}
                    </div>

                    <svg width="120" height="40" viewBox="0 0 120 40" className="opacity-70">
                      <path
                        d={`M 0 ${40 - Math.abs(market.change24h)} L 30 ${40 - Math.abs(market.change24h) * 0.8} L 60 ${40 - Math.abs(market.change24h) * 1.2} L 90 ${40 - Math.abs(market.change24h) * 0.9} L 120 ${40 - Math.abs(market.change24h)}`}
                        stroke={market.change24h >= 0 ? '#0ECB81' : '#F6465D'}
                        strokeWidth="2"
                        fill="none"
                      />
                    </svg>
                  </div>

                  <div className="grid grid-cols-4 gap-2 mb-4 text-xs">
                    <div>
                      <div className="text-[#848E9C] mb-1">24h High</div>
                      <div className="text-white font-medium">{formatPrice(high)}</div>
                    </div>
                    <div>
                      <div className="text-[#848E9C] mb-1">24h Low</div>
                      <div className="text-white font-medium">{formatPrice(low)}</div>
                    </div>
                    <div>
                      <div className="text-[#848E9C] mb-1">Bid</div>
                      <div className="text-[#0ECB81] font-semibold">{formatPrice(bid)}</div>
                    </div>
                    <div>
                      <div className="text-[#848E9C] mb-1">Ask</div>
                      <div className="text-[#F6465D] font-semibold">{formatPrice(ask)}</div>
                    </div>
                  </div>

                  <div className="flex gap-3">
                    <button
                      onClick={() => {
                        localStorage.setItem('currentTab', 'trade');
                        localStorage.setItem('selectedCoinSymbol', market.symbol);
                        localStorage.setItem('selectedCoinSide', 'buy');
                        window.dispatchEvent(new CustomEvent('navigate-to-trade', {
                          detail: { symbol: market.symbol, side: 'buy' }
                        }));
                      }}
                      className="flex-1 bg-[#0ECB81] hover:bg-[#0ECB81]/90 text-white font-bold py-3 rounded-lg transition-colors"
                    >
                      Buy {market.symbol}
                    </button>
                    <button
                      onClick={() => {
                        localStorage.setItem('currentTab', 'trade');
                        localStorage.setItem('selectedCoinSymbol', market.symbol);
                        localStorage.setItem('selectedCoinSide', 'sell');
                        window.dispatchEvent(new CustomEvent('navigate-to-trade', {
                          detail: { symbol: market.symbol, side: 'sell' }
                        }));
                      }}
                      className="flex-1 bg-[#F6465D] hover:bg-[#F6465D]/90 text-white font-bold py-3 rounded-lg transition-colors"
                    >
                      Sell {market.symbol}
                    </button>
                  </div>
                </div>
              );
            })}

            {filtered.length > 15 && (
              <div className="flex justify-center py-5">
                <button
                  onClick={() => setShowAllCoins(!showAllCoins)}
                  className="px-6 py-2.5 bg-[#2B3139] hover:bg-[#343C45] rounded-lg font-medium text-[13px] transition-all flex items-center gap-2"
                >
                  {showAllCoins ? 'Show Less' : `View All ${filtered.length} Pairs`}
                  <ChevronDown className={`w-4 h-4 transition-transform ${showAllCoins ? 'rotate-180' : ''}`} />
                </button>
              </div>
            )}
          </div>
        )}
      </div>
    </>
  );
}
