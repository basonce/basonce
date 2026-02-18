import { useEffect, useState, useRef } from 'react';
import { TrendingUp, TrendingDown, Search } from 'lucide-react';
import { fetchHybridPrices } from '../lib/hybrid-price';
import { EarnQuestPriceManager } from '../lib/earnquest-price';
import { supabase } from '../lib/supabase';
import { getProxiedLogoUrl } from '../lib/logo-utils';

interface MarketData {
  symbol: string;
  name: string;
  price: number;
  change24h: number;
  volume: number;
  logoUrl: string;
  isEarnQuest?: boolean;
}

interface MarketListProps {
  onSelectCrypto: (crypto: any) => void;
}

export default function MarketList({ onSelectCrypto }: MarketListProps) {
  const [markets, setMarkets] = useState<MarketData[]>([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);
  const priceManager = useRef(EarnQuestPriceManager.getInstance());

  useEffect(() => {
    fetchMarkets();

    const unsubscribe = priceManager.current.subscribe(() => {
      updatePrices();
    });

    return () => {
      unsubscribe();
    };
  }, []);

  const updatePrices = () => {
    setMarkets(prevMarkets =>
      prevMarkets.map(market => {
        if (market.isEarnQuest) {
          return {
            ...market,
            price: priceManager.current.getPrice(),
            change24h: priceManager.current.getChange()
          };
        }
        return market;
      })
    );
  };

  const fetchMarkets = async () => {
    try {
      const { data: coins } = await supabase
        .from('supported_coins')
        .select('symbol, name, logo_url, is_spot_enabled')
        .eq('is_active', true)
        .eq('is_spot_enabled', true)
        .order('sort_order');

      if (!coins || coins.length === 0) {
        setLoading(false);
        return;
      }

      const symbols = coins.map(c => c.symbol).filter(s => s !== 'EQ');
      const priceResult = await fetchHybridPrices(symbols);

      const priceMap = new Map();
      if (priceResult.success) {
        priceResult.prices.forEach(p => {
          if (p.price > 0) {
            priceMap.set(p.symbol, p);
          }
        });
      }

      const marketData: MarketData[] = [];

      coins.forEach(coin => {
        if (coin.symbol === 'EQ') {
          marketData.push({
            symbol: 'EQ',
            name: 'EarnQuest',
            price: priceManager.current.getPrice(),
            change24h: priceManager.current.getChange(),
            volume: 255000000,
            logoUrl: getProxiedLogoUrl(coin.logo_url) || '/earnquest-logo-icon-2.png',
            isEarnQuest: true,
          });
          return;
        }

        const priceData = priceMap.get(coin.symbol);
        if (priceData) {
          marketData.push({
            symbol: coin.symbol,
            name: coin.name,
            price: priceData.price,
            change24h: priceData.change24h,
            volume: priceData.volume,
            logoUrl: getProxiedLogoUrl(coin.logo_url) || `https://ui-avatars.com/api/?name=${coin.symbol}&background=f0b90b&color=000&size=128&bold=true`,
          });
        }
      });

      setMarkets(marketData);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching markets:', error);
      setLoading(false);
    }
  };

  const getFullName = (symbol: string): string => {
    const names: { [key: string]: string } = {
      EQ: 'EarnQuest',
      BTC: 'Bitcoin',
      ETH: 'Ethereum',
      BNB: 'BNB',
      SOL: 'Solana',
      XRP: 'Ripple',
      ADA: 'Cardano',
      DOGE: 'Dogecoin',
      AVAX: 'Avalanche',
      DOT: 'Polkadot',
      MATIC: 'Polygon',
      LINK: 'Chainlink',
      UNI: 'Uniswap',
      LTC: 'Litecoin',
      ATOM: 'Cosmos',
      ETC: 'Ethereum Classic',
      XLM: 'Stellar',
      NEAR: 'NEAR Protocol',
      ALGO: 'Algorand',
      VET: 'VeChain',
      ICP: 'Internet Computer',
      FIL: 'Filecoin',
      APT: 'Aptos',
      ARB: 'Arbitrum',
      OP: 'Optimism',
      INJ: 'Injective',
      SUI: 'Sui',
      SEI: 'Sei',
      TIA: 'Celestia',
      RENDER: 'Render',
      FTM: 'Fantom',
      PEPE: 'Pepe',
      SHIB: 'Shiba Inu',
      WIF: 'dogwifhat',
      BONK: 'Bonk',
      FLOKI: 'Floki',
    };
    return names[symbol] || symbol;
  };

  const filteredMarkets = markets.filter(market =>
    market.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    market.symbol.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const formatPrice = (price: number) => {
    if (price < 0.01) return `$${price.toFixed(8)}`;
    if (price < 1) return `$${price.toFixed(6)}`;
    if (price < 100) return `$${price.toFixed(4)}`;
    return `$${price.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  };

  const formatVolume = (num: number) => {
    if (num >= 1e9) return `$${(num / 1e9).toFixed(2)}B`;
    if (num >= 1e6) return `$${(num / 1e6).toFixed(2)}M`;
    if (num >= 1e3) return `$${(num / 1e3).toFixed(2)}K`;
    return `$${num.toFixed(2)}`;
  };

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center h-screen bg-[#181A20]">
        <div className="animate-spin rounded-full h-16 w-16 border-[#F0B90B] mb-4"></div>
        <p className="text-lg">Loading real-time market data from Basonce...</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#181A20] text-white">
      <div className="max-w-7xl mx-auto px-8 py-8">
        <div className="mb-8">
          <h1 className="font-bold mb-2 text-3xl">Market Overview</h1>
          <p className="text-base">Real-time prices from Basonce - Updates every 5 seconds</p>
        </div>

        <div className="mb-6 relative">
          <div className="absolute left-4 top-1/2 transform -translate-y-1/2 w-6 h-6 rounded-full border-2 border-[#F0B90B] flex items-center justify-center">
            <Search className="w-4 h-4 text-[#F0B90B]" />
          </div>
          <input
            type="text"
            placeholder="Search cryptocurrencies..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full bg-[#181A20] border border-[#2B3139] rounded-lg pl-12 pr-4 py-3 text-white placeholder-gray-500 focus:border-[#F0B90B] transition-colors"
          />
        </div>

        <div className="hidden bg-[#181A20] rounded-lg overflow-hidden border border-[#2B3139] block">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-[#2B3139] bg-[#2B3139]/50">
                  <th className="px-6 py-4 text-gray-400 font-medium">#</th>
                  <th className="px-6 py-4 text-gray-400 font-medium">Asset</th>
                  <th className="px-6 py-4 text-gray-400 font-medium">Price</th>
                  <th className="px-6 py-4 text-gray-400 font-medium">24h Change</th>
                  <th className="px-6 py-4 text-gray-400 font-medium hidden table-cell">24h Volume</th>
                  <th className="px-6 py-4 text-gray-400 font-medium">Trade</th>
                </tr>
              </thead>
              <tbody>
                {filteredMarkets.map((market, index) => (
                  <tr
                    key={market.symbol}
                    className={`border-b hover:bg-[#2B3139]/50 transition-colors cursor-pointer ${ market.isEarnQuest ? 'bg-gradient-to-r from-[#7B3FE4]/10 via-[#A726C1]/5 to-[#00C9FF]/10' : '' }`}
                    onClick={() => onSelectCrypto(market)}
                  >
                    <td className="px-6 py-4 text-gray-400">{index + 1}</td>
                    <td className="px-6 py-4">
                      <div className="flex items-center space-x-3">
                        <div className={`w-12 h-12 rounded-full flex items-center justify-center ${ market.isEarnQuest ? 'bg-gradient-to-br from-[#7B3FE4] to-[#00C9FF] p-[2px]' : 'bg-[#2B3139] p-1.5' }`}>
                          <img
                            src={getProxiedLogoUrl(market.logoUrl)}
                            alt={market.symbol}
                            className="w-full h-full rounded-full object-contain"
                          />
                        </div>
                        <div>
                          <div className="font-semibold text-base flex items-center gap-2">
                            {market.symbol}
                            {market.isEarnQuest && (
                              <span className="bg-[#F0B90B] text-[9px] font-bold px-2 py-0.5 rounded">HOT</span>
                            )}
                          </div>
                          <div className="text-gray-500">{market.name}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-white font-medium">
                      {formatPrice(market.price)}
                    </td>
                    <td className="px-6 py-4 text-right">
                      <div className={`flex items-center justify-end space-x-1 font-semibold ${ market.change24h >= 0 ? 'text-green-500' : 'text-red-500' }`}>
                        {market.change24h >= 0 ? (
                          <TrendingUp className="w-4 h-4" />
                        ) : (
                          <TrendingDown className="w-4 h-4" />
                        )}
                        <span>
                          {market.change24h >= 0 ? '+' : ''}{market.change24h.toFixed(2)}%
                        </span>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-gray-300 font-mono hidden table-cell">
                      {formatVolume(market.volume)}
                    </td>
                    <td className="px-6 py-4 text-center">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          onSelectCrypto(market);
                        }}
                        className="px-5 py-2 bg-[#F0B90B] font-semibold rounded-lg transition-all transform hover:scale-105 text-sm"
                      >
                        Trade
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        <div className="space-y-3 hidden">
          {filteredMarkets.map((market, index) => (
            <div
              key={market.symbol}
              onClick={() => onSelectCrypto(market)}
              className={`rounded-lg border p-4 hover:bg-[#2B3139]/50 transition-colors active:scale-98 ${ market.isEarnQuest ? 'bg-gradient-to-br from-[#7B3FE4]/20 via-[#A726C1]/10 to-[#00C9FF]/20 border-[#7B3FE4]/30' : 'bg-[#181A20] border-[#2B3139]' }`}
            >
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center space-x-3">
                  <span className="text-sm font-medium">{index + 1}</span>
                  <div className={`w-10 h-10 rounded-full flex items-center justify-center ${ market.isEarnQuest ? 'bg-gradient-to-br from-[#7B3FE4] to-[#00C9FF] p-[2px]' : 'bg-[#2B3139] p-1.5' }`}>
                    <img
                      src={market.logoUrl}
                      alt={market.symbol}
                      className="w-full h-full rounded-full object-contain"
                    />
                  </div>
                  <div>
                    <div className="font-semibold text-white flex items-center gap-2">
                      {market.symbol}
                      {market.isEarnQuest && (
                        <span className="bg-[#F0B90B] text-[8px] font-bold px-1.5 py-0.5 rounded">HOT</span>
                      )}
                    </div>
                    <div className="text-gray-500">{market.name}</div>
                  </div>
                </div>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    onSelectCrypto(market);
                  }}
                  className="px-4 py-2 bg-[#F0B90B] hover:bg-[#F0B90B] font-semibold rounded-lg text-sm"
                >
                  Trade
                </button>
              </div>
              <div className="flex items-center justify-between">
                <div>
                  <div className="text-gray-500 mb-1">Price</div>
                  <div className="text-white font-medium">{formatPrice(market.price)}</div>
                </div>
                <div className="text-right">
                  <div className="text-gray-500 mb-1">24h Change</div>
                  <div className={`flex items-center justify-end space-x-1 font-semibold ${ market.change24h >= 0 ? 'text-green-500' : 'text-red-500' }`}>
                    {market.change24h >= 0 ? (
                      <TrendingUp className="w-4 h-4" />
                    ) : (
                      <TrendingDown className="w-4 h-4" />
                    )}
                    <span>
                      {market.change24h >= 0 ? '+' : ''}{market.change24h.toFixed(2)}%
                    </span>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {filteredMarkets.length === 0 && !loading && (
          <div className="py-12 text-gray-400">
            No cryptocurrencies found matching "{searchTerm}"
          </div>
        )}
      </div>
    </div>
  );
}
