import { useState, useEffect } from 'react';
import { supabase } from './lib/supabase';
import { analyticsTracker } from './lib/analytics-tracker';
import AdminDashboard from './components/AdminDashboard';
import BottomNav from './components/BottomNav';
import HomePage from './pages/HomePage';
import MarketsPage from './pages/MarketsPage';
import TradePage from './pages/TradePage';
import FuturesPage from './pages/FuturesPage';
import MiningPage from './pages/MiningPage';
import AssetsPage from './pages/AssetsPage';
import ProfilePage from './pages/ProfilePage';

type Page = 'markets' | 'trade' | 'wallet' | 'admin';

function App() {
  const [currentPage, setCurrentPage] = useState<Page>('markets');
  const [mobileTab, setMobileTab] = useState(() => {
    const savedTab = localStorage.getItem('currentTab');
    return savedTab || 'home';
  });
  const [selectedCrypto, setSelectedCrypto] = useState<any>(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [user, setUser] = useState<any>(null);

  useEffect(() => {
    analyticsTracker.initialize();

    return () => {
      analyticsTracker.cleanup();
    };
  }, []);

  useEffect(() => {
    const checkAdminStatus = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (!session?.user) {
          setIsAdmin(false);
          setUser(null);
          return;
        }

        setUser(session.user);

        const { data, error } = await supabase
          .from('user_profiles')
          .select('is_admin')
          .eq('id', session.user.id)
          .maybeSingle();

        if (error) {
          setIsAdmin(false);
          return;
        }

        if (data) {
          setIsAdmin(data.is_admin || false);
        }
      } catch (error) {
        setIsAdmin(false);
      }
    };

    checkAdminStatus();

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setUser(session?.user ?? null);
      if (session?.user) {
        checkAdminStatus();
        analyticsTracker.updateUserRegistration(session.user.id);
      } else {
        setIsAdmin(false);
      }
    });

    return () => subscription.unsubscribe();
  }, []);

  useEffect(() => {
    localStorage.setItem('currentTab', mobileTab);
    analyticsTracker.trackPageView(`/${mobileTab}`);
  }, [mobileTab]);

  useEffect(() => {
    const handleNavigateToTrade = async (e: any) => {
      const coinSymbol = e.detail?.symbol || localStorage.getItem('selectedCoinSymbol');

      if (coinSymbol) {
        const { data: coin } = await supabase
          .from('supported_coins')
          .select('*')
          .eq('symbol', coinSymbol)
          .maybeSingle();

        if (coin) {
          setSelectedCrypto(coin);
        }
      }
      setMobileTab('trade');
    };

    window.addEventListener('navigate-to-trade', handleNavigateToTrade);
    return () => window.removeEventListener('navigate-to-trade', handleNavigateToTrade);
  }, []);

  const handleNavigate = (page: Page) => {
    if (page === 'admin' && !isAdmin) {
      alert('Access denied. Admin privileges required.');
      return;
    }

    setCurrentPage(page);
    if (page !== 'trade') {
      setSelectedCrypto(null);
    }
  };

  const handleSelectCrypto = (crypto: any) => {
    setSelectedCrypto(crypto);
    setCurrentPage('trade');
  };

  const handleBackToMarkets = () => {
    setSelectedCrypto(null);
    setCurrentPage('markets');
  };

  useEffect(() => {
    const pageTitles: Record<string, string> = {
      home: 'BASONCE Exchange - Kripto Para Borsasi | Bitcoin, Ethereum Al Sat',
      markets: 'Piyasalar | BASONCE Exchange - Kripto Para Borsasi',
      trade: 'Spot Trading | BASONCE Exchange - Kripto Para Borsasi',
      futures: 'Vadeli Islem | BASONCE Exchange - Kripto Para Borsasi',
      mining: 'Mining | BASONCE Exchange - Kripto Para Borsasi',
      assets: 'Varliklar | BASONCE Exchange - Kripto Para Borsasi',
      profile: 'Profil | BASONCE Exchange - Kripto Para Borsasi',
    };
    document.title = pageTitles[mobileTab] || pageTitles.home;
  }, [mobileTab]);

  if (currentPage === 'admin' && isAdmin) {
    return (
      <div className="min-h-screen bg-[#181A20] flex justify-center">
        <div className="w-full max-w-[428px]">
          <AdminDashboard onBack={() => setCurrentPage('markets')} />
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#181A20] flex justify-center">
      <div className="w-full max-w-[428px] relative">
        <main role="main">
          {mobileTab === 'home' && <HomePage />}
          {mobileTab === 'markets' && <MarketsPage />}
          {mobileTab === 'trade' && <TradePage />}
          {mobileTab === 'futures' && <FuturesPage />}
          {mobileTab === 'mining' && <MiningPage />}
          {mobileTab === 'assets' && <AssetsPage />}
          {mobileTab === 'profile' && (
            <ProfilePage
              onNavigateToAdmin={() => handleNavigate('admin')}
            />
          )}
        </main>

        <BottomNav activeTab={mobileTab} onTabChange={setMobileTab} />
      </div>
    </div>
  );
}

export default App;
