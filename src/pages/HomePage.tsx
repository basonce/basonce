import { useState } from 'react';
import { UserPlus, Coins, DollarSign, MoreHorizontal, Menu, Headphones, Shield, Users, CreditCard, Gift, BarChart3 } from 'lucide-react';
import SocialFeed from '../components/SocialFeed';
import HomeMarketList from '../components/HomeMarketList';
import BasonceAlpha from '../components/BasonceAlpha';
import SupportModal from '../components/SupportModal';
import AlphaEventsModal from '../components/AlphaEventsModal';
import ReferralModal from '../components/ReferralModal';
import EarnModal from '../components/EarnModal';
import DepositUSDModal from '../components/DepositUSDModal';
import MoreModal from '../components/MoreModal';
import P2PModal from '../components/P2PModal';
import PayModal from '../components/PayModal';
import RewardsModal from '../components/RewardsModal';
import AnalyticsModal from '../components/AnalyticsModal';

export default function HomePage() {
  const [activeMode, setActiveMode] = useState<'exchange' | 'wallet'>('exchange');
  const [activeTab, setActiveTab] = useState<'crypto' | 'spot' | 'futures'>('crypto');
  const [activeFilter, setActiveFilter] = useState<'gainers' | 'losers' | '24h-vol' | 'alpha'>('gainers');
  const [discoverTab, setDiscoverTab] = useState<'discover' | 'following' | 'campaign' | 'announcement'>('discover');
  const [showSupportModal, setShowSupportModal] = useState(false);
  const [showAlphaEvents, setShowAlphaEvents] = useState(false);
  const [showReferral, setShowReferral] = useState(false);
  const [showEarn, setShowEarn] = useState(false);
  const [showDepositUSD, setShowDepositUSD] = useState(false);
  const [showMore, setShowMore] = useState(false);
  const [showP2P, setShowP2P] = useState(false);
  const [showPay, setShowPay] = useState(false);
  const [showRewards, setShowRewards] = useState(false);
  const [showAnalytics, setShowAnalytics] = useState(false);

  return (
    <div className="min-h-screen bg-[#0B0E11] pb-20">
      <div className="bg-[#181A20] px-4 pt-8 pb-4 sticky top-0 z-20">
        <div className="flex items-center justify-between mb-4">
          <button className="p-2 hover:bg-[#2B3139] rounded-lg transition-colors">
            <Menu className="w-5 h-5 text-gray-300" />
          </button>
          <div className="flex items-center gap-2">
            <button
              onClick={() => setShowSupportModal(true)}
              className="p-2 hover:bg-[#2B3139] rounded-lg transition-colors"
            >
              <Headphones className="w-5 h-5 text-[#F0B90B]" />
            </button>
            <button className="p-2 rounded-lg transition-colors text-green-500 hover:text-green-400">
              <Shield className="w-5 h-5" />
            </button>
          </div>
        </div>

        <div className="flex items-center gap-1 bg-[#0B0E11] rounded-lg p-1 mb-4">
          <button
            onClick={() => setActiveMode('exchange')}
            className={`flex-1 py-2 px-4 rounded-md text-sm font-medium transition-all ${ activeMode === 'exchange' ? 'bg-[#F0B90B] text-[#0B0E11]' : 'text-gray-400' }`}
          >
            Exchange
          </button>
          <button
            onClick={() => setActiveMode('wallet')}
            className={`flex-1 py-2 px-4 rounded-md text-sm font-medium transition-all ${ activeMode === 'wallet' ? 'bg-[#F0B90B] text-[#0B0E11]' : 'text-gray-400' }`}
          >
            Wallet
          </button>
        </div>

        <div className="overflow-x-auto scrollbar-hide mb-4 -mx-4">
          <div className="flex gap-3 min-w-max px-4">
            <button onClick={() => setShowDepositUSD(true)} className="flex flex-col items-center gap-1.5 group flex-shrink-0">
              <div className="w-12 h-12 bg-[#0B0E11] rounded-xl flex items-center justify-center transition-all duration-300 active:scale-95 hover:bg-[#2B3139]">
                <DollarSign className="w-6 h-6 text-[#F0B90B] group-hover:drop-shadow-[0_0_8px_rgba(240,185,11,0.8)]" />
              </div>
              <span className="text-white text-xs font-bold">Deposit</span>
            </button>
            <button onClick={() => setShowEarn(true)} className="flex flex-col items-center gap-1.5 group flex-shrink-0">
              <div className="w-12 h-12 bg-[#0B0E11] rounded-xl flex items-center justify-center transition-all duration-300 active:scale-95 hover:bg-[#2B3139]">
                <Coins className="w-6 h-6 text-[#F0B90B] group-hover:drop-shadow-[0_0_8px_rgba(240,185,11,0.8)]" />
              </div>
              <span className="text-white text-xs font-bold">Earn</span>
            </button>
            <button onClick={() => setShowReferral(true)} className="flex flex-col items-center gap-1.5 group flex-shrink-0">
              <div className="w-12 h-12 bg-[#0B0E11] rounded-xl flex items-center justify-center transition-all duration-300 active:scale-95 hover:bg-[#2B3139]">
                <UserPlus className="w-6 h-6 text-[#F0B90B] group-hover:drop-shadow-[0_0_8px_rgba(240,185,11,0.8)]" />
              </div>
              <span className="text-white text-xs font-bold">Referral</span>
            </button>
            <button onClick={() => setShowP2P(true)} className="flex flex-col items-center gap-1.5 group flex-shrink-0">
              <div className="w-12 h-12 bg-[#0B0E11] rounded-xl flex items-center justify-center transition-all duration-300 active:scale-95 hover:bg-[#2B3139]">
                <Users className="w-6 h-6 text-[#F0B90B] group-hover:drop-shadow-[0_0_8px_rgba(240,185,11,0.8)]" />
              </div>
              <span className="text-white text-xs font-bold">P2P</span>
            </button>
            <button onClick={() => setShowPay(true)} className="flex flex-col items-center gap-1.5 group flex-shrink-0">
              <div className="w-12 h-12 bg-[#0B0E11] rounded-xl flex items-center justify-center transition-all duration-300 active:scale-95 hover:bg-[#2B3139]">
                <CreditCard className="w-6 h-6 text-[#F0B90B] group-hover:drop-shadow-[0_0_8px_rgba(240,185,11,0.8)]" />
              </div>
              <span className="text-white text-xs font-bold">Pay</span>
            </button>
            <button onClick={() => setShowRewards(true)} className="flex flex-col items-center gap-1.5 group flex-shrink-0">
              <div className="w-12 h-12 bg-[#0B0E11] rounded-xl flex items-center justify-center transition-all duration-300 active:scale-95 hover:bg-[#2B3139]">
                <Gift className="w-6 h-6 text-[#F0B90B] group-hover:drop-shadow-[0_0_8px_rgba(240,185,11,0.8)]" />
              </div>
              <span className="text-white text-xs font-bold">Rewards</span>
            </button>
            <button onClick={() => setShowAnalytics(true)} className="flex flex-col items-center gap-1.5 group flex-shrink-0">
              <div className="w-12 h-12 bg-[#0B0E11] rounded-xl flex items-center justify-center transition-all duration-300 active:scale-95 hover:bg-[#2B3139]">
                <BarChart3 className="w-6 h-6 text-[#F0B90B] group-hover:drop-shadow-[0_0_8px_rgba(240,185,11,0.8)]" />
              </div>
              <span className="text-white text-xs font-bold">Analytics</span>
            </button>
            <button onClick={() => setShowMore(true)} className="flex flex-col items-center gap-1.5 group flex-shrink-0">
              <div className="w-12 h-12 bg-[#0B0E11] rounded-xl flex items-center justify-center transition-all duration-300 active:scale-95 hover:bg-[#2B3139]">
                <MoreHorizontal className="w-6 h-6 text-[#F0B90B] group-hover:drop-shadow-[0_0_8px_rgba(240,185,11,0.8)]" />
              </div>
              <span className="text-white text-xs font-bold">More</span>
            </button>
          </div>
        </div>
      </div>

      <div className="bg-gradient-to-br from-[#F0B90B]/10 to-transparent border border-[#F0B90B]/20 rounded-lg mx-4 mb-4 p-4">
        <div className="flex items-start justify-between mb-2">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 bg-white rounded-full flex items-center justify-center">
              <span className="text-lg">🎁</span>
            </div>
            <div>
              <h3 className="font-bold text-sm text-white">38,000,000 FOGO Reward Pool!</h3>
              <p className="text-xs text-gray-300">Limited time offer</p>
            </div>
          </div>
          <button className="text-xl">×</button>
        </div>
        <button
          onClick={() => setShowAlphaEvents(true)}
          className="w-full bg-[#F0B90B] hover:bg-[#F0B90B]/90 font-bold py-2 rounded-lg text-sm transition-all"
        >
          JOIN
        </button>
      </div>

      <div className="px-4 mb-2">
        <div className="flex items-center gap-4 mb-3 overflow-x-auto scrollbar-hide">
          {[
            { id: 'crypto', label: 'Crypto' },
            { id: 'spot', label: 'Spot' },
            { id: 'futures', label: 'Futures' }
          ].map(({ id, label }) => (
            <button
              key={id}
              onClick={() => {
                setActiveTab(id as typeof activeTab);
                if (activeFilter === 'alpha') setActiveFilter('gainers');
              }}
              className={`text-sm font-bold whitespace-nowrap pb-2 transition-all ${ activeTab === id ? 'text-white border-b-2 border-[#F0B90B]' : 'text-gray-500' }`}
            >
              {label}
            </button>
          ))}
        </div>

        <div className="flex items-center gap-2 mb-2 overflow-x-auto scrollbar-hide -mx-4 px-4">
          {[
            { id: 'gainers', label: 'Gainers' },
            { id: 'losers', label: 'Losers' },
            { id: '24h-vol', label: '24h Vol' },
            { id: 'alpha', label: 'Basonce Alpha', special: true }
          ].map(({ id, label, special }) => (
            <button
              key={id}
              onClick={() => setActiveFilter(id as typeof activeFilter)}
              className={`px-3.5 py-1.5 rounded-md text-xs font-bold transition-all whitespace-nowrap flex-shrink-0 ${
                activeFilter === id
                  ? special ? 'bg-gradient-to-r from-[#F0B90B] to-[#F8D12F] text-[#0B0E11]' : 'bg-[#F0B90B] text-[#0B0E11]'
                  : special ? 'bg-[#181A20] text-[#F0B90B] border border-[#F0B90B]/30' : 'bg-[#181A20] text-gray-400 hover:text-gray-300'
              }`}
            >
              {label}
            </button>
          ))}
        </div>
      </div>

      {activeFilter === 'alpha' ? (
        <BasonceAlpha />
      ) : (
        <HomeMarketList activeFilter={activeFilter} marketType={activeTab} />
      )}

      <div className="bg-[#181A20] mt-4">
        <div className="flex items-center gap-4 px-4 py-3 border-b border-[#2B3139] overflow-x-auto scrollbar-hide bg-[#181A20]">
          {[
            { id: 'discover', label: 'Discover' },
            { id: 'following', label: 'Following', badge: true },
            { id: 'campaign', label: 'Campaign' },
            { id: 'announcement', label: 'Announcement' }
          ].map(({ id, label, badge }) => (
            <button
              key={id}
              onClick={() => setDiscoverTab(id as any)}
              className={`text-sm font-medium whitespace-nowrap pb-2 transition-all relative ${ discoverTab === id ? 'text-[#F0B90B] border-b-2 border-[#F0B90B]' : 'text-gray-400 hover:text-gray-300' }`}
            >
              {label}
              {badge && <span className="absolute -top-1 -right-2 w-2 h-2 bg-[#F0B90B] rounded-full animate-pulse" />}
            </button>
          ))}
        </div>

        {discoverTab === 'discover' && (
          <SocialFeed />
        )}
        {discoverTab === 'following' && (
          <div className="flex flex-col items-center justify-center py-16 px-4">
            <UserPlus className="w-12 h-12 text-gray-500 mb-4" />
            <p className="text-center text-gray-200">No following posts yet</p>
            <p className="text-center text-gray-400 mt-2">Follow traders to see their updates here</p>
          </div>
        )}
        {discoverTab === 'campaign' && (
          <div className="flex flex-col items-center justify-center py-16 px-4">
            <Coins className="w-12 h-12 text-gray-500 mb-4" />
            <p className="text-center text-gray-200">No campaigns available</p>
            <p className="text-center text-gray-400 mt-2">Check back later for exciting rewards</p>
          </div>
        )}
        {discoverTab === 'announcement' && (
          <div className="flex flex-col items-center justify-center py-16 px-4">
            <svg className="w-12 h-12 text-gray-500 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
            </svg>
            <p className="text-center text-gray-200">No announcements</p>
            <p className="text-center text-gray-400 mt-2">Stay tuned for important updates</p>
          </div>
        )}
      </div>

      <SupportModal
        isOpen={showSupportModal}
        onClose={() => setShowSupportModal(false)}
      />

      <AlphaEventsModal
        isOpen={showAlphaEvents}
        onClose={() => setShowAlphaEvents(false)}
      />

      <ReferralModal
        isOpen={showReferral}
        onClose={() => setShowReferral(false)}
      />

      <EarnModal
        isOpen={showEarn}
        onClose={() => setShowEarn(false)}
      />

      <DepositUSDModal
        isOpen={showDepositUSD}
        onClose={() => setShowDepositUSD(false)}
      />

      <MoreModal
        isOpen={showMore}
        onClose={() => setShowMore(false)}
      />

      <P2PModal
        isOpen={showP2P}
        onClose={() => setShowP2P(false)}
      />

      <PayModal
        isOpen={showPay}
        onClose={() => setShowPay(false)}
      />

      <RewardsModal
        isOpen={showRewards}
        onClose={() => setShowRewards(false)}
      />

      <AnalyticsModal
        isOpen={showAnalytics}
        onClose={() => setShowAnalytics(false)}
      />
    </div>
  );
}
