import { useState, useEffect, useRef } from 'react';
import { TrendingUp } from 'lucide-react';

interface TopTrader {
  id: string;
  name: string;
  avatar: string;
  badge: string;
  pnl7d: number;
  roi: number;
  winRate: number;
  aum: number;
  followers: number;
}

const topTraders: TopTrader[] = [
  {
    id: '1',
    name: '明明10倍多军',
    avatar: 'https://i.pravatar.cc/150?img=12',
    badge: 'Whale Manager',
    pnl7d: 25860.97,
    roi: 115.94,
    winRate: 26.31,
    aum: 71498.09,
    followers: 61
  },
  {
    id: '2',
    name: 'CryptoKing2024',
    avatar: 'https://i.pravatar.cc/150?img=33',
    badge: 'Master Trader',
    pnl7d: 48920.15,
    roi: 234.67,
    winRate: 42.18,
    aum: 125340.50,
    followers: 142
  },
  {
    id: '3',
    name: 'FuturesGuru',
    avatar: 'https://i.pravatar.cc/150?img=68',
    badge: 'Pro Trader',
    pnl7d: 15670.88,
    roi: 89.23,
    winRate: 35.92,
    aum: 42890.33,
    followers: 89
  },
  {
    id: '4',
    name: 'DiamondHands',
    avatar: 'https://i.pravatar.cc/150?img=52',
    badge: 'Whale Manager',
    pnl7d: 67340.22,
    roi: 312.45,
    winRate: 51.67,
    aum: 198765.40,
    followers: 278
  },
  {
    id: '5',
    name: 'MoonShot_Pro',
    avatar: 'https://i.pravatar.cc/150?img=29',
    badge: 'Elite Trader',
    pnl7d: 32450.67,
    roi: 156.89,
    winRate: 38.44,
    aum: 87654.21,
    followers: 156
  },
  {
    id: '6',
    name: 'BullMarket888',
    avatar: 'https://i.pravatar.cc/150?img=15',
    badge: 'Master Trader',
    pnl7d: 41230.55,
    roi: 198.76,
    winRate: 44.23,
    aum: 134567.80,
    followers: 201
  }
];

export default function CopyTradingCarousel() {
  const scrollRef = useRef<HTMLDivElement>(null);
  const [isPaused, setIsPaused] = useState(false);

  useEffect(() => {
    const scrollContainer = scrollRef.current;
    if (!scrollContainer || isPaused) return;

    const scroll = () => {
      if (scrollContainer.scrollLeft >= scrollContainer.scrollWidth / 2) {
        scrollContainer.scrollLeft = 0;
      } else {
        scrollContainer.scrollLeft += 0.5;
      }
    };

    const interval = setInterval(scroll, 20);
    return () => clearInterval(interval);
  }, [isPaused]);

  const handleCopy = (trader: TopTrader) => {
    console.log('Copy trader:', trader.name);
  };

  const duplicatedTraders = [...topTraders, ...topTraders];

  return (
    <div className="py-4 bg-gradient-to-r from-[#1a1a1a] to-[#252525] border-y border-gray-800">
      <div className="flex items-center justify-between px-4 mb-3">
        <h3 className="text-white font-semibold text-base flex items-center gap-2">
          <TrendingUp className="w-5 h-5 text-[#F0B90B]" />
          Copy Trading For You
        </h3>
        <button className="text-[#F0B90B] text-xs font-medium">
          View All
        </button>
      </div>

      <div
        ref={scrollRef}
        className="flex gap-3 overflow-x-auto scrollbar-hide px-4"
        style={{ scrollBehavior: 'auto' }}
        onMouseEnter={() => setIsPaused(true)}
        onMouseLeave={() => setIsPaused(false)}
        onTouchStart={() => setIsPaused(true)}
        onTouchEnd={() => setIsPaused(false)}
      >
        {duplicatedTraders.map((trader, index) => (
          <div
            key={`${trader.id}-${index}`}
            className="flex-shrink-0 w-[280px] bg-[#1E1E1E] rounded-lg p-4 border border-gray-800"
          >
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <img
                  src={trader.avatar}
                  alt={trader.name}
                  className="w-10 h-10 rounded-full"
                />
                <div>
                  <div className="text-white font-medium text-sm">
                    {trader.name}
                  </div>
                  <div className="flex items-center gap-1 text-xs">
                    <span className="text-gray-400">{trader.followers}</span>
                    <span className="text-gray-500">/</span>
                    <span className="text-gray-400">400</span>
                    <span className="px-1.5 py-0.5 bg-[#F0B90B] text-black text-[10px] font-semibold rounded ml-1">
                      {trader.badge}
                    </span>
                  </div>
                </div>
              </div>
              <button
                onClick={() => handleCopy(trader)}
                className="px-4 py-1.5 bg-[#F0B90B] hover:bg-[#F8D12F] text-black font-semibold text-sm rounded-md transition-colors"
              >
                Copy
              </button>
            </div>

            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-gray-400 text-xs">7D PNL (USDT)</span>
                <span className="text-[#0ECB81] text-sm font-semibold">
                  +{trader.pnl7d.toLocaleString()} <span className="text-gray-400">USDT</span>
                </span>
              </div>

              <div className="flex items-center justify-between text-xs">
                <div className="flex flex-col">
                  <span className="text-gray-400">ROI</span>
                  <span className="text-[#0ECB81] font-medium">+{trader.roi}%</span>
                </div>
                <div className="flex flex-col items-center">
                  <span className="text-gray-400">AUM</span>
                  <span className="text-white font-medium">${trader.aum.toLocaleString()}</span>
                </div>
                <div className="flex flex-col items-end">
                  <span className="text-gray-400">Win Rate</span>
                  <span className="text-white font-medium">{trader.winRate}%</span>
                </div>
              </div>

              <div className="pt-2">
                <div className="h-12 flex items-end gap-0.5">
                  {[...Array(20)].map((_, i) => {
                    const height = Math.random() * 80 + 20;
                    const isGreen = Math.random() > 0.3;
                    return (
                      <div
                        key={i}
                        className={`flex-1 rounded-sm ${
                          isGreen ? 'bg-[#0ECB81]' : 'bg-[#F6465D]'
                        }`}
                        style={{ height: `${height}%` }}
                      />
                    );
                  })}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
