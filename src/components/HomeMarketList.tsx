import { useState, useEffect, useRef, useCallback } from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';
import { EarnQuestPriceManager } from '../lib/earnquest-price';
import { getCoinLogoUrl, FUTURES_COINS } from '../lib/coin-logos';
import { supabase } from '../lib/supabase';

interface MarketCoin {
  symbol: string;
  price: number;
  change24h: number;
  volume24h: number;
  logo: string;
}

const GRADIENT_COLORS = ['#F0B90B', '#0ECB81', '#3861FB', '#E8831D', '#627EEA', '#00D1FF', '#FF6B35'];
const COLLAPSED_COUNT = 5;
const EXPANDED_COUNT = 20;
const MIN_VOLUME = 50000;

function formatPrice(price: number): string {
  if (price >= 10000) return price.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  if (price >= 1) return price.toFixed(2);
  if (price >= 0.01) return price.toFixed(4);
  if (price >= 0.0001) return price.toFixed(6);
  return price.toFixed(8);
}

function formatVolume(vol: number): string {
  if (vol >= 1e9) return `$${(vol / 1e9).toFixed(2)}B`;
  if (vol >= 1e6) return `$${(vol / 1e6).toFixed(1)}M`;
  if (vol >= 1e3) return `$${(vol / 1e3).toFixed(0)}K`;
  return `$${vol.toFixed(0)}`;
}

function CoinLogo({ logo, symbol }: { logo: string; symbol: string }) {
  const [failed, setFailed] = useState(false);

  if (!logo || failed) {
    const idx = symbol.charCodeAt(0) % GRADIENT_COLORS.length;
    const c1 = GRADIENT_COLORS[idx];
    const c2 = GRADIENT_COLORS[(idx + 2) % GRADIENT_COLORS.length];
    return (
      <div
        className="w-full h-full rounded-full flex items-center justify-center"
        style={{ background: `linear-gradient(135deg, ${c1}, ${c2})` }}
      >
        <span className="font-extrabold text-white text-xs">{symbol.slice(0, 2)}</span>
      </div>
    );
  }

  return (
    <img
      src={logo}
      alt={symbol}
      className="w-full h-full rounded-full object-cover"
      onError={() => setFailed(true)}
      loading="lazy"
    />
  );
}

interface Props {
  activeFilter: 'gainers' | 'losers' | '24h-vol';
  marketType?: 'crypto' | 'spot' | 'futures';
}

export default function HomeMarketList({ activeFilter, marketType = 'crypto' }: Props) {
  const [allCoins, setAllCoins] = useState<MarketCoin[]>([]);
  const [expanded, setExpanded] = useState(false);
  const [flashMap, setFlashMap] = useState<Record<string, 'up' | 'down'>>({});
  const prevPricesRef = useRef<Record<string, number>>({});
  const priceManager = useRef(EarnQuestPriceManager.getInstance());
  const flashTimerRef = useRef<ReturnType<typeof setTimeout>>();
  const dbLogosRef = useRef<Record<string, string>>({});
  const logosLoadedRef = useRef(false);

  useEffect(() => {
    const fetchLogos = async () => {
      try {
        const { data } = await supabase
          .from('supported_coins')
          .select('symbol, logo_url');
        if (data) {
          const map: Record<string, string> = {};
          for (const c of data) {
            if (c.symbol && c.logo_url) map[c.symbol] = c.logo_url;
          }
          map['EQ'] = '/earnquest-logo-icon-2.png';
          dbLogosRef.current = map;
          logosLoadedRef.current = true;
        }
      } catch { /* keep empty */ }
    };
    fetchLogos();
  }, []);

  const fetchAllTickers = useCallback(async () => {
    try {
      const response = await fetch(
        `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/binance-proxy?endpoint=ticker24hr`,
        {
          headers: { 'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}` },
          signal: AbortSignal.timeout(10000),
        }
      );

      if (!response.ok) return;
      const data = await response.json();
      if (!Array.isArray(data)) return;

      const dbLogos = dbLogosRef.current;
      const newFlashes: Record<string, 'up' | 'down'> = {};
      const coins: MarketCoin[] = [];

      for (const t of data) {
        if (!t.symbol?.endsWith('USDT')) continue;
        const price = parseFloat(t.lastPrice);
        if (price <= 0) continue;

        const symbol = t.symbol.replace('USDT', '');
        const volume = parseFloat(t.quoteVolume || '0');

        if (volume < MIN_VOLUME) continue;

        const logo = getCoinLogoUrl(symbol, dbLogos);
        if (!logo) continue;

        const prevPrice = prevPricesRef.current[symbol];
        if (prevPrice !== undefined && prevPrice !== price) {
          newFlashes[symbol] = price > prevPrice ? 'up' : 'down';
        }
        prevPricesRef.current[symbol] = price;

        coins.push({
          symbol,
          price,
          change24h: parseFloat(t.priceChangePercent || '0'),
          volume24h: volume,
          logo,
        });
      }

      const eqPrice = priceManager.current.getPrice();
      if (eqPrice > 0) {
        const eqPrev = prevPricesRef.current['EQ'];
        if (eqPrev !== undefined && eqPrev !== eqPrice) {
          newFlashes['EQ'] = eqPrice > eqPrev ? 'up' : 'down';
        }
        prevPricesRef.current['EQ'] = eqPrice;
        coins.push({
          symbol: 'EQ',
          price: eqPrice,
          change24h: priceManager.current.getChange(),
          volume24h: priceManager.current.getMarketCap() * 0.15,
          logo: '/earnquest-logo-icon-2.png',
        });
      }

      setAllCoins(coins);

      if (Object.keys(newFlashes).length > 0) {
        setFlashMap(newFlashes);
        if (flashTimerRef.current) clearTimeout(flashTimerRef.current);
        flashTimerRef.current = setTimeout(() => setFlashMap({}), 750);
      }
    } catch { /* keep existing data */ }
  }, []);

  useEffect(() => {
    fetchAllTickers();
    const interval = setInterval(fetchAllTickers, 10000);
    return () => {
      clearInterval(interval);
      if (flashTimerRef.current) clearTimeout(flashTimerRef.current);
    };
  }, [fetchAllTickers]);

  useEffect(() => {
    setExpanded(false);
  }, [activeFilter, marketType]);

  const displayCoins = (() => {
    if (allCoins.length === 0) return [];
    let filtered = [...allCoins];

    if (marketType === 'futures') {
      filtered = filtered.filter(c => FUTURES_COINS.has(c.symbol));
    }

    switch (activeFilter) {
      case 'gainers':
        filtered.sort((a, b) => b.change24h - a.change24h);
        break;
      case 'losers':
        filtered.sort((a, b) => a.change24h - b.change24h);
        break;
      case '24h-vol':
        filtered.sort((a, b) => b.volume24h - a.volume24h);
        break;
    }

    const limit = expanded ? EXPANDED_COUNT : COLLAPSED_COUNT;
    return filtered.slice(0, limit);
  })();

  const totalAvailable = (() => {
    if (allCoins.length === 0) return 0;
    let filtered = allCoins;
    if (marketType === 'futures') {
      filtered = allCoins.filter(c => FUTURES_COINS.has(c.symbol));
    }
    return Math.min(filtered.length, EXPANDED_COUNT);
  })();

  if (displayCoins.length === 0) {
    return (
      <div>
        {[...Array(5)].map((_, i) => (
          <div key={i} className="px-4 py-4 border-b border-[#2B3139] animate-pulse">
            <div className="flex items-center">
              <div className="w-10 h-10 rounded-full bg-[#2B3139] mr-3 flex-shrink-0" />
              <div className="flex-1">
                <div className="h-4 w-14 bg-[#2B3139] rounded mb-1.5" />
                <div className="h-3 w-20 bg-[#2B3139]/50 rounded" />
              </div>
              <div className="h-5 w-24 bg-[#2B3139] rounded mr-3" />
              <div className="h-9 w-[82px] bg-[#2B3139] rounded" />
            </div>
          </div>
        ))}
      </div>
    );
  }

  return (
    <div>
      <div className="flex items-center text-gray-500 text-[11px] font-bold mb-1 px-5 uppercase tracking-wider">
        <div className="flex-1">Name</div>
        <div className="w-28 text-right mr-3">Last Price</div>
        <div className="w-[82px] text-center">24h chg%</div>
      </div>

      {displayCoins.map((coin) => {
        const flash = flashMap[coin.symbol];
        return (
          <div
            key={coin.symbol}
            className={`px-4 py-3 border-b border-[#2B3139]/50 cursor-pointer active:bg-[#2B3139]/50 transition-colors ${
              flash === 'up' ? 'animate-flash-green' : flash === 'down' ? 'animate-flash-red' : ''
            }`}
            style={flash ? { animationIterationCount: 1, animationFillMode: 'forwards' } : undefined}
            onClick={() => {
              localStorage.setItem('currentTab', 'trade');
              localStorage.setItem('selectedCoinSymbol', coin.symbol);
              localStorage.setItem('selectedCoinSide', 'buy');
              window.dispatchEvent(new CustomEvent('navigate-to-trade', {
                detail: { symbol: coin.symbol, side: 'buy' }
              }));
            }}
          >
            <div className="flex items-center">
              <div className="flex items-center gap-3 flex-1 min-w-0">
                <div className="w-8 h-8 flex-shrink-0">
                  <CoinLogo logo={coin.logo} symbol={coin.symbol} />
                </div>
                <div className="min-w-0">
                  <div className="font-bold text-[15px] text-white leading-tight">
                    {coin.symbol}
                    <span className="text-gray-500 font-medium text-[11px] ml-1">/USDT</span>
                  </div>
                  <div className="text-[11px] text-gray-500 mt-0.5">
                    Vol {formatVolume(coin.volume24h)}
                  </div>
                </div>
              </div>

              <div className="text-right mr-3 flex-shrink-0">
                <div className={`font-semibold text-[14px] tabular-nums leading-tight transition-colors duration-300 ${
                  flash === 'up' ? 'text-[#0ECB81]' : flash === 'down' ? 'text-[#F6465D]' : 'text-white'
                }`}>
                  ${formatPrice(coin.price)}
                </div>
              </div>

              <div className={`min-w-[82px] py-1.5 px-2.5 rounded text-center font-bold text-[13px] flex-shrink-0 ${
                coin.change24h >= 0
                  ? 'bg-[#0ECB81] text-white'
                  : 'bg-[#F6465D] text-white'
              }`}>
                {coin.change24h >= 0 ? '+' : ''}{coin.change24h.toFixed(2)}%
              </div>
            </div>
          </div>
        );
      })}

      {totalAvailable > COLLAPSED_COUNT && (
        <button
          onClick={() => setExpanded(!expanded)}
          className="w-full py-3 flex items-center justify-center gap-1.5 text-sm font-medium text-gray-400 hover:text-white transition-colors border-b border-[#2B3139]/50"
        >
          {expanded ? (
            <>
              View Less
              <ChevronUp className="w-4 h-4" />
            </>
          ) : (
            <>
              View More
              <ChevronDown className="w-4 h-4" />
            </>
          )}
        </button>
      )}
    </div>
  );
}
