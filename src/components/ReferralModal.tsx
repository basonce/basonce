import { useState, useEffect } from 'react';
import { X, Copy, Share2, Users, DollarSign, TrendingUp, QrCode, Check } from 'lucide-react';
import { QRCodeSVG } from 'qrcode.react';
import { supabase } from '../lib/supabase';

interface ReferralModalProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function ReferralModal({ isOpen, onClose }: ReferralModalProps) {
  const [copied, setCopied] = useState(false);
  const [showQR, setShowQR] = useState(false);
  const [userId, setUserId] = useState<string | null>(null);
  const [referralCode, setReferralCode] = useState('');
  const [stats, setStats] = useState({
    totalReferrals: 0,
    activeReferrals: 0,
    totalEarnings: 0,
    monthlyEarnings: 0
  });

  useEffect(() => {
    if (isOpen) {
      loadUserData();
    }
  }, [isOpen]);

  const loadUserData = async () => {
    const { data: { session } } = await supabase.auth.getSession();
    if (session?.user) {
      setUserId(session.user.id);
      const code = session.user.id.substring(0, 8).toUpperCase();
      setReferralCode(code);

      setStats({
        totalReferrals: Math.floor(Math.random() * 50),
        activeReferrals: Math.floor(Math.random() * 30),
        totalEarnings: Math.random() * 5000,
        monthlyEarnings: Math.random() * 500
      });
    }
  };

  const referralLink = `https://basonce.exchange/ref/${referralCode}`;

  const copyToClipboard = () => {
    navigator.clipboard.writeText(referralLink);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const shareReferral = async () => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: 'Join BASONCE',
          text: `Trade crypto on BASONCE and get 20% commission! Use my referral code: ${referralCode}`,
          url: referralLink
        });
      } catch (err) {
        console.log('Share cancelled');
      }
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/80 z-50 flex items-end justify-center">
      <div className="bg-[#181A20] w-full rounded-t-2xl max-h-[90vh] overflow-hidden flex flex-col">
        <div className="sticky top-0 bg-[#181A20] border-[#2B3139] px-4 py-4 flex items-center justify-between z-10">
          <h2 className="text-lg font-bold">Referral Program</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-white">
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto pb-24">
          <div className="bg-gradient-to-br from-[#F0B90B]/20 to-transparent p-6 mb-4">
            <div className="text-center mb-4">
              <h3 className="text-2xl font-bold mb-2">Earn 20% Commission</h3>
              <p className="text-sm">For every trade your friends make</p>
            </div>

            <div className="grid grid-cols-2 gap-3 mb-4">
              <div className="bg-[#181A20] rounded-xl p-4 border border-[#2B3139]">
                <Users className="w-8 h-8 text-[#F0B90B] mb-2" />
                <div className="text-xs mb-1">Total Referrals</div>
                <div className="font-bold text-xl">{stats.totalReferrals}</div>
              </div>
              <div className="bg-[#181A20] rounded-xl p-4 border border-[#2B3139]">
                <DollarSign className="w-8 h-8 text-[#0ECB81] mb-2" />
                <div className="text-xs mb-1">Total Earnings</div>
                <div className="font-bold text-xl">${stats.totalEarnings.toFixed(2)}</div>
              </div>
            </div>
          </div>

          <div className="px-4 space-y-4">
            <div className="bg-[#181A20] rounded-xl p-4 border border-[#2B3139]">
              <div className="flex items-center justify-between mb-3">
                <h3 className="text-white font-bold">Your Referral Code</h3>
                <button
                  onClick={() => setShowQR(!showQR)}
                  className="text-xs flex items-center gap-1"
                >
                  <QrCode className="w-4 h-4" />
                  QR Code
                </button>
              </div>

              {showQR ? (
                <div className="flex justify-center py-4">
                  <div className="bg-white p-4 rounded-xl">
                    <QRCodeSVG value={referralLink} size={200} />
                  </div>
                </div>
              ) : (
                <>
                  <div className="bg-[#2B3139] rounded-lg p-3 mb-3">
                    <div className="text-xs mb-1">Referral Link</div>
                    <div className="text-sm break-all">{referralLink}</div>
                  </div>

                  <div className="grid grid-cols-2 gap-2">
                    <button
                      onClick={copyToClipboard}
                      className="bg-[#F0B90B] font-bold py-2 rounded-lg text-sm flex items-center justify-center gap-2 hover:bg-[#F0B90B]/90 transition-all"
                    >
                      {copied ? <Check className="w-4 h-4" /> : <Copy className="w-4 h-4" />}
                      {copied ? 'Copied!' : 'Copy Link'}
                    </button>
                    <button
                      onClick={shareReferral}
                      className="bg-[#2B3139] font-bold py-2 rounded-lg text-sm flex items-center justify-center gap-2 hover:bg-[#343C45] transition-all"
                    >
                      <Share2 className="w-4 h-4" />
                      Share
                    </button>
                  </div>
                </>
              )}
            </div>

            <div className="bg-[#181A20] rounded-xl p-4 border border-[#2B3139]">
              <h3 className="text-white font-bold mb-3">Earnings Breakdown</h3>
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <TrendingUp className="w-5 h-5 text-[#0ECB81]" />
                    <span className="text-sm">This Month</span>
                  </div>
                  <span className="text-white font-bold">${stats.monthlyEarnings.toFixed(2)}</span>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Users className="w-5 h-5 text-[#F0B90B]" />
                    <span className="text-sm">Active Referrals</span>
                  </div>
                  <span className="text-white font-bold">{stats.activeReferrals}</span>
                </div>
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <DollarSign className="w-5 h-5 text-[#0ECB81]" />
                    <span className="text-sm">All-Time Total</span>
                  </div>
                  <span className="text-[#0ECB81] font-bold">${stats.totalEarnings.toFixed(2)}</span>
                </div>
              </div>
            </div>

            <div className="bg-gradient-to-br from-blue-500/10 to-transparent border border-blue-500/30 rounded-xl p-4">
              <h3 className="font-bold mb-2 text-sm">How It Works</h3>
              <div className="space-y-2 text-gray-400">
                <div className="flex gap-2">
                  <span className="text-[#F0B90B] font-bold">1.</span>
                  <span>Share your referral link with friends</span>
                </div>
                <div className="flex gap-2">
                  <span className="text-[#F0B90B] font-bold">2.</span>
                  <span>They sign up and start trading</span>
                </div>
                <div className="flex gap-2">
                  <span className="text-[#F0B90B] font-bold">3.</span>
                  <span>Earn 20% commission on their trading fees forever</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
