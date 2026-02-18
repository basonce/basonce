import { TrendingUp, LineChart, BarChart3, Pickaxe, Wallet, User } from 'lucide-react';

interface BottomNavProps {
  activeTab: string;
  onTabChange: (tab: string) => void;
}

export default function BottomNav({ activeTab, onTabChange }: BottomNavProps) {
  const tabs = [
    { id: 'home', label: 'Home', icon: null },
    { id: 'markets', label: 'Markets', icon: TrendingUp },
    { id: 'trade', label: 'Trade', icon: LineChart },
    { id: 'futures', label: 'Futures', icon: BarChart3 },
    { id: 'mining', label: 'Mining', icon: Pickaxe, special: true },
    { id: 'assets', label: 'Assets', icon: Wallet },
    { id: 'profile', label: 'Profile', icon: User },
  ];

  return (
    <div className="fixed bottom-0 left-1/2 transform -translate-x-1/2 w-full max-w-[428px] bg-[#181A20] border-t border-[#2B3139] z-50">
      <div className="grid grid-cols-7 px-2 py-2">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.id;
          const isMining = tab.id === 'mining';

          return (
            <button
              key={tab.id}
              onClick={() => onTabChange(tab.id)}
              className={`flex flex-col items-center gap-1 p-2 relative ${isMining && isActive ? 'animate-pulse' : ''}`}
            >
              {isMining && isActive && (
                <div className="absolute inset-0 bg-gradient-to-t from-[#F0B90B]/20 to-transparent rounded-lg" />
              )}

              {tab.id === 'home' ? (
                <div className="w-6 h-6 flex items-center justify-center relative z-10">
                  <img
                    src="/image.png"
                    alt="BASONCE"
                    className={`max-w-full object-contain transition-all ${isActive ? 'brightness-100 saturate-150' : 'brightness-75 saturate-50 opacity-60'}`}
                    style={{
                      filter: isActive
                        ? 'drop-shadow(0 0 2px rgba(240, 185, 11, 0.5))'
                        : 'grayscale(20%)'
                    }}
                  />
                </div>
              ) : (
                Icon && (
                  <div className="relative z-10">
                    <Icon
                      className={`w-6 h-6 ${isMining ? (isActive ? 'text-[#F0B90B]' : 'text-[#F0B90B]') : 'text-gray-400'} ${isMining ? 'drop-shadow-[0_0_8px_rgba(240,185,11,0.6)]' : ''}`}
                    />
                    {isMining && !isActive && (
                      <div className="absolute inset-0 bg-[#F0B90B] opacity-20 blur-sm rounded-full" />
                    )}
                  </div>
                )
              )}
              <span
                className={`text-xs font-medium relative z-10 ${isMining ? (isActive ? 'text-[#F0B90B] font-bold' : 'text-[#F0B90B] font-semibold') : (isActive ? 'text-[#F0B90B]' : 'text-gray-400')} ${isMining ? 'drop-shadow-[0_0_4px_rgba(240,185,11,0.8)]' : ''}`}
              >
                {tab.label}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
}
