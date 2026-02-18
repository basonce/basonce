import { useState, useEffect } from 'react';
import { Pickaxe, ShoppingBag, Radio, Users, Gamepad2, Headphones } from 'lucide-react';
import { supabase } from '../lib/supabase';
import MineTab from '../components/mining-tabs/MineTab';
import ShopTab from '../components/mining-tabs/ShopTab';
import GamesTab from '../components/mining-tabs/GamesTab';
import SupportTab from '../components/mining-tabs/SupportTab';
import MiningLiveChatModal from '../components/MiningLiveChatModal';
import { globalMiningStats } from '../lib/global-mining-stats';

export default function MiningPage() {
  const [activeTab, setActiveTab] = useState<'mine' | 'shop' | 'games' | 'support'>('mine');
  const [chatModal, setChatModal] = useState(false);
  const [mineRefreshKey, setMineRefreshKey] = useState(0);
  const [onlineUsers, setOnlineUsers] = useState(3745);

  useEffect(() => {
    initializeUser();

    // Subscribe to global mining stats
    const unsubscribe = globalMiningStats.subscribe((stats) => {
      setOnlineUsers(stats.onlineCount);
    });

    return () => unsubscribe();
  }, []);

  useEffect(() => {
    if (activeTab === 'mine') {
      setMineRefreshKey(prev => prev + 1);
    }
  }, [activeTab]);

  const handlePurchaseComplete = () => {
    console.log('🔄 MiningPage: handlePurchaseComplete called!');
    setMineRefreshKey(prev => {
      console.log('📈 MiningPage: Updating mineRefreshKey from', prev, 'to', prev + 1);
      return prev + 1;
    });
  };

  const initializeUser = async () => {
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;

    const { data: existingPurchases } = await supabase
      .from('user_mining_purchases')
      .select('id')
      .eq('user_id', user.id)
      .limit(1);

    if (!existingPurchases || existingPurchases.length === 0) {
      const { data: freeItem } = await supabase
        .from('mining_shop_items')
        .select('id')
        .eq('tier', 'free')
        .maybeSingle();

      if (freeItem) {
        await supabase
          .from('user_mining_purchases')
          .insert({
            user_id: user.id,
            shop_item_id: freeItem.id,
            purchase_price_usdt: 0,
            status: 'active',
            total_earned_usdt: 0,
            session_earned_usdt: 0
          });
      }
    }
  };

  return (
    <div className="relative">
      <div className="fixed top-0 left-0 right-0 z-40 bg-[#1A1B23] border-b border-[#2B3139]">
        <div className="max-w-2xl mx-auto px-4">
          <div className="grid grid-cols-4 gap-2 py-3">
            <button
              onClick={() => setActiveTab('mine')}
              className={`py-3 rounded-xl font-bold transition-all flex flex-col items-center justify-center gap-1 ${
                activeTab === 'mine'
                  ? 'bg-gradient-to-r from-[#F0B90B] to-[#FCD535] text-black'
                  : 'bg-[#0D0E12] text-gray-400 hover:text-white'
              }`}
            >
              <Pickaxe className="w-5 h-5" />
              <span className="text-xs">Mine</span>
            </button>

            <button
              onClick={() => setActiveTab('shop')}
              className={`py-3 rounded-xl font-bold transition-all flex flex-col items-center justify-center gap-1 relative overflow-hidden ${
                activeTab === 'shop'
                  ? 'bg-gradient-to-r from-[#F0B90B] to-[#FCD535] text-black'
                  : 'bg-gradient-to-br from-[#0D0E12] via-[#1A1B23] to-[#0D0E12] border-2 border-[#F0B90B] text-[#F0B90B] animate-shop-attention'
              }`}
            >
              {activeTab !== 'shop' && (
                <>
                  <div className="absolute inset-0 bg-[#F0B90B]/10 rounded-xl animate-pulse"></div>
                  <div className="absolute top-1 right-1 w-1.5 h-1.5 bg-gradient-to-r from-red-500 to-orange-500 rounded-full animate-pulse shadow-lg shadow-red-500/80"></div>
                  <div className="absolute top-0.5 right-0.5 w-3 h-3">
                    <div className="absolute inset-0 bg-gradient-to-r from-red-500/30 to-orange-500/30 rounded-full animate-ping"></div>
                  </div>
                </>
              )}
              <ShoppingBag className={`w-5 h-5 ${activeTab !== 'shop' ? 'animate-shop-icon' : ''}`} />
              <span className={`text-xs font-bold ${activeTab !== 'shop' ? 'animate-shop-text' : ''}`}>Shop</span>
            </button>

            <button
              onClick={() => setActiveTab('games')}
              className={`py-3 rounded-xl font-bold transition-all flex flex-col items-center justify-center gap-1 relative overflow-hidden ${
                activeTab === 'games'
                  ? 'bg-gradient-to-r from-[#F0B90B] to-[#FCD535] text-black'
                  : 'bg-[#0D0E12] text-gray-400 hover:text-white'
              }`}
            >
              <Gamepad2 className="w-5 h-5" />
              <span className="text-xs">Games</span>
            </button>

            <button
              onClick={() => setActiveTab('support')}
              className={`py-3 rounded-xl font-bold transition-all flex flex-col items-center justify-center gap-1 relative overflow-hidden ${
                activeTab === 'support'
                  ? 'bg-gradient-to-r from-[#F0B90B] to-[#FCD535] text-black'
                  : 'bg-gradient-to-br from-green-500/10 to-emerald-500/10 border border-green-500/30 text-green-400 hover:border-green-500/50'
              }`}
            >
              <div className="relative">
                <Headphones className="w-5 h-5" />
                {activeTab !== 'support' && (
                  <div className="absolute -top-1 -right-1 w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                )}
              </div>
              <span className="text-xs">Support</span>
            </button>
          </div>

          <button
            onClick={() => setChatModal(true)}
            className="w-full mb-3 py-2.5 rounded-xl font-bold transition-all flex items-center justify-center gap-2 bg-gradient-to-br from-pink-500 via-purple-600 to-purple-700 text-white hover:shadow-xl hover:shadow-purple-500/40 relative overflow-hidden group active:scale-95"
          >
            <div className="absolute inset-0 bg-gradient-to-br from-white/20 via-transparent to-black/20 opacity-0 group-hover:opacity-100 transition-opacity"></div>
            <div className="flex items-center gap-1 bg-gradient-to-r from-red-500 to-rose-600 px-2 py-0.5 rounded-full shadow-lg shadow-red-500/50 animate-pulse">
              <Radio className="w-2.5 h-2.5 text-white animate-pulse" />
              <span className="text-[9px] font-black tracking-widest text-white">LIVE</span>
            </div>
            <div className="relative z-10 flex items-center gap-2">
              <Radio className="w-5 h-5 text-white" />
              <span className="text-sm font-black">Miners Live Chat</span>
              <div className="flex items-center gap-1 text-xs font-bold text-white/95">
                <Users className="w-3.5 h-3.5" />
                <span>{onlineUsers.toLocaleString()}</span>
              </div>
            </div>
          </button>
        </div>
      </div>

      <div className="pt-32">
        {activeTab === 'mine' && (
          <MineTab key={mineRefreshKey} onSwitchToShop={() => setActiveTab('shop')} />
        )}
        {activeTab === 'shop' && (
          <ShopTab onPurchaseComplete={handlePurchaseComplete} />
        )}
        {activeTab === 'games' && (
          <GamesTab />
        )}
        {activeTab === 'support' && (
          <SupportTab />
        )}
      </div>

      <MiningLiveChatModal
        isOpen={chatModal}
        onClose={() => setChatModal(false)}
      />
    </div>
  );
}
