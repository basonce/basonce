import { useState, useEffect } from 'react';
import { X, Send, ArrowUpCircle, DollarSign, Users, Lock } from 'lucide-react';
import { RealWithdrawModal } from './RealWithdrawModal';
import { supabase } from '../lib/supabase';
import { checkWithdrawalPermission } from '../lib/withdrawal-permission';

interface SendMethodModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function SendMethodModal({ isOpen, onClose }: SendMethodModalProps) {
  const [realWithdrawModal, setRealWithdrawModal] = useState<{
    open: boolean;
    currency: string;
    network: string;
    balance: number;
  }>({
    open: false,
    currency: 'USDT',
    network: 'bsc',
    balance: 0
  });
  const [isBlocked, setIsBlocked] = useState(false);
  const [currentTier, setCurrentTier] = useState(0);

  useEffect(() => {
    if (isOpen) {
      checkPermission();
    }
  }, [isOpen]);

  const checkPermission = async () => {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    const permission = await checkWithdrawalPermission(user.id);
    if (!permission.allowed) {
      setIsBlocked(true);
      setCurrentTier(permission.currentTier);
    }
  };

  if (!isOpen) return null;

  const openRealWithdraw = async (currency: string) => {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) {
      alert('Please login first');
      return;
    }

    const { data: balance } = await supabase
      .from('balances')
      .select('available')
      .eq('user_id', session.user.id)
      .eq('currency', currency)
      .single();

    setRealWithdrawModal({
      open: true,
      currency,
      network: 'bsc',
      balance: balance?.available || 0
    });
    onClose();
  };

  const methods = [
    {
      icon: Send,
      title: 'Send to users',
      description: 'Internal transfer, send via Email/Phone/ID'
    },
    {
      icon: ArrowUpCircle,
      title: 'On-Chain Withdraw',
      description: 'Withdraw Crypto to other exchanges/wallets',
      action: () => openRealWithdraw('USDT')
    },
    {
      icon: DollarSign,
      title: 'Sell to USD',
      description: 'Sell crypto easily to your account'
    },
    {
      icon: Users,
      title: 'P2P Trading',
      description: 'Sell directly to users. Competitive pricing'
    }
  ];

  return (
    <div className="fixed inset-0 bg-black/80 z-50 flex items-center justify-center p-4">
      <div className="bg-[#181A20] w-full max-w-[480px] rounded-2xl animate-slide-up overflow-hidden">
        <div className="p-5">
          <div className="flex items-center justify-between mb-5">
            <h2 className="font-semibold text-white">Select Withdraw Method</h2>
            <button onClick={onClose} className="text-gray-400 hover:text-white">
              <X className="w-6 h-6" />
            </button>
          </div>

          <div className="space-y-2.5 max-h-[500px] overflow-y-auto scrollbar-hide">
            {methods.map((method, index) => {
              const isOnChain = method.title === 'On-Chain Withdraw';
              const isLocked = isOnChain && isBlocked;

              return (
                <button
                  key={index}
                  onClick={method.action}
                  className={`w-full bg-[#2B3139] hover:bg-[#353D47] rounded-xl p-4 flex items-center gap-4 transition-colors text-left disabled:cursor-not-allowed ${
                    isLocked ? 'opacity-50' : ''
                  }`}
                  disabled={!method.action || isLocked}
                >
                  <div className="w-11 h-11 bg-[#F0B90B]/20 rounded-full flex items-center justify-center flex-shrink-0">
                    {isLocked ? (
                      <Lock className="w-5 h-5 text-red-400" />
                    ) : (
                      <method.icon className="w-5 h-5 text-[#F0B90B]" />
                    )}
                  </div>
                  <div className="flex-1">
                    <div className="font-semibold mb-1 text-[15px] flex items-center gap-2">
                      {method.title}
                      {isLocked && (
                        <span className="text-xs text-red-400">
                          (Tier {currentTier}/5)
                        </span>
                      )}
                    </div>
                    <div className="text-[13px] leading-[1.4]">
                      {isLocked
                        ? 'Upgrade to Tier 5 to unlock withdrawals'
                        : method.description}
                    </div>
                  </div>
                </button>
              );
            })}
          </div>
        </div>
      </div>

      {realWithdrawModal.open && (
        <RealWithdrawModal
          onClose={() => setRealWithdrawModal({ ...realWithdrawModal, open: false })}
          currency={realWithdrawModal.currency}
          network={realWithdrawModal.network}
          availableBalance={realWithdrawModal.balance}
        />
      )}
    </div>
  );
}
