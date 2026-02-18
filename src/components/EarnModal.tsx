import { X, TrendingUp, Lock, Unlock, Zap, Info } from 'lucide-react';

interface EarnModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function EarnModal({ isOpen, onClose }: EarnModalProps) {
  if (!isOpen) return null;

  const earnPrograms = [
    {
      id: 1,
      type: 'Flexible Staking',
      asset: 'USDT',
      apy: '8.5',
      minAmount: '10',
      description: 'Withdraw anytime, no lock period',
      icon: Unlock,
      logo: 'https://cryptologos.cc/logos/tether-usdt-logo.png',
      color: 'text-blue-400',
      bgColor: 'bg-blue-500/10',
      totalStaked: '$125M'
    },
    {
      id: 2,
      type: 'EQ Staking',
      asset: 'EQ',
      apy: '15.0',
      minAmount: '100',
      description: 'Exclusive high APY for EarnQuest token',
      icon: Zap,
      logo: '/earnquest-logo-icon-2.png',
      color: 'text-yellow-400',
      bgColor: 'bg-yellow-500/10',
      totalStaked: '50M EQ',
      featured: true
    },
    {
      id: 3,
      type: 'Locked Staking',
      asset: 'BTC',
      apy: '12.0',
      minAmount: '0.001',
      lockPeriod: '30 Days',
      description: 'Higher APY with lock period',
      icon: Lock,
      logo: 'https://cryptologos.cc/logos/bitcoin-btc-logo.png',
      color: 'text-orange-400',
      bgColor: 'bg-orange-500/10',
      totalStaked: '1,250 BTC'
    },
    {
      id: 4,
      type: 'Flexible Staking',
      asset: 'ETH',
      apy: '6.5',
      minAmount: '0.01',
      description: 'Flexible staking with daily rewards',
      icon: Unlock,
      logo: 'https://cryptologos.cc/logos/ethereum-eth-logo.png',
      color: 'text-purple-400',
      bgColor: 'bg-purple-500/10',
      totalStaked: '8,500 ETH'
    },
    {
      id: 5,
      type: 'Launchpool',
      asset: 'FOGO',
      apy: '25.0',
      minAmount: '1000',
      description: 'Farm new tokens with your FOGO',
      icon: TrendingUp,
      logo: 'https://cryptologos.cc/logos/tether-usdt-logo.png',
      color: 'text-green-400',
      bgColor: 'bg-green-500/10',
      totalStaked: '38M FOGO',
      featured: true
    },
    {
      id: 6,
      type: 'Locked Staking',
      asset: 'BNB',
      apy: '9.5',
      minAmount: '0.1',
      lockPeriod: '60 Days',
      description: 'Long-term staking with premium APY',
      icon: Lock,
      logo: 'https://cryptologos.cc/logos/bnb-bnb-logo.png',
      color: 'text-yellow-400',
      bgColor: 'bg-yellow-500/10',
      totalStaked: '450K BNB'
    }
  ];

  return (
    <div className="fixed inset-0 bg-black/80 z-50 flex items-end justify-center">
      <div className="bg-[#181A20] w-full rounded-t-2xl max-h-[90vh] overflow-hidden flex flex-col">
        <div className="sticky top-0 bg-[#181A20] border-[#2B3139] px-4 py-4 flex items-center justify-between z-10">
          <h2 className="text-lg font-bold">Earn Programs</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-white">
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto pb-24">
          <div className="bg-gradient-to-br from-[#F0B90B]/20 to-transparent p-6 mb-4">
            <h3 className="text-xl font-bold mb-2">Start Earning Today</h3>
            <p className="text-sm">Stake your crypto and earn passive income with competitive APYs</p>
          </div>

          <div className="px-4 space-y-3">
            {earnPrograms.map((program) => {
              return (
                <div
                  key={program.id}
                  className="bg-[#181A20] rounded-xl p-4 border border-[#2B3139] hover:border-[#F0B90B]/50 transition-all"
                >
                  {program.featured && (
                    <div className="mb-3 flex items-center gap-2">
                      <span className="font-bold bg-gradient-to-r from-yellow-400 to-orange-500 text-black px-2 py-1 rounded">
                        FEATURED
                      </span>
                      <span className="font-bold bg-red-500 text-white px-2 py-1 rounded">
                        HOT
                      </span>
                    </div>
                  )}

                  <div className="flex items-start gap-3 mb-3">
                    <div className="w-12 h-12 rounded-full bg-white flex items-center justify-center flex-shrink-0 p-1.5">
                      <img src={program.logo} alt={program.asset} className="w-full h-full object-contain" />
                    </div>

                    <div className="flex-1">
                      <div className="flex items-center justify-between mb-1">
                        <h3 className="text-white font-bold">{program.asset}</h3>
                        <div className="text-right">
                          <div className="font-bold text-lg">{program.apy}%</div>
                          <div className="text-[10px]">APY</div>
                        </div>
                      </div>
                      <div className="text-xs mb-1">{program.type}</div>
                      <p className="text-xs">{program.description}</p>
                    </div>
                  </div>

                  <div className="grid grid-cols-3 gap-2 mb-3">
                    <div className="bg-[#2B3139] rounded-lg p-2">
                      <div className="text-[10px] mb-1">Min Amount</div>
                      <div className="font-bold text-xs">{program.minAmount}</div>
                    </div>
                    {program.lockPeriod && (
                      <div className="bg-[#2B3139] rounded-lg p-2">
                        <div className="text-[10px] mb-1">Lock Period</div>
                        <div className="font-bold text-xs">{program.lockPeriod}</div>
                      </div>
                    )}
                    <div className={`bg-[#2B3139] rounded-lg p-2 ${program.lockPeriod ? '' : 'col-span-2'}`}>
                      <div className="text-[10px] mb-1">Total Staked</div>
                      <div className="font-bold text-xs">{program.totalStaked}</div>
                    </div>
                  </div>

                  <button className="w-full bg-[#F0B90B] hover:bg-[#F0B90B]/90 font-bold py-2 rounded-lg text-sm transition-all">
                    Stake Now
                  </button>
                </div>
              );
            })}
          </div>

          <div className="px-4 mt-6">
            <div className="bg-[#181A20] rounded-xl p-4 border border-[#2B3139]">
              <div className="flex items-center gap-2 mb-3">
                <Info className="w-5 h-5 text-[#F0B90B]" />
                <h3 className="text-white font-bold">Important Information</h3>
              </div>
              <div className="space-y-2 text-gray-400">
                <p>• Rewards are distributed daily to your account</p>
                <p>• Flexible staking allows withdrawal anytime</p>
                <p>• Locked staking requires completion of lock period</p>
                <p>• APY rates may vary based on market conditions</p>
                <p>• Your funds are secured with institutional-grade custody</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
