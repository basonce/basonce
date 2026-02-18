import { useState, useEffect, useRef, useCallback } from 'react';
import { X, Users, Send, Link as LinkIcon, DollarSign, MoreHorizontal } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { EarnQuestPriceManager } from '../lib/earnquest-price';
import {
  generateInitialMessages,
  generateNewMessage,
  generateParticipantSlots,
  type ChatMessage,
  type ParticipantSlot,
} from '../lib/live-chat-generator';

interface LiveRoomModalProps {
  isOpen: boolean;
  onClose: () => void;
  roomId: string;
}

interface Room {
  id: string;
  title: string;
  description: string;
  topic: string;
  listener_count: number;
  host_id: string;
  is_vip: boolean;
  required_level: number;
  access_type: string;
  room_category: string;
  background_gradient: string;
  coin_symbol?: string;
  coin_logo?: string;
}

interface CoinData {
  symbol: string;
  logo: string;
  price: number;
  change: number;
  chartData: number[];
}

const COIN_TOPICS: Record<string, string> = {
  BTC: 'Bitcoin Price Action & Market Analysis',
  ETH: 'Ethereum DeFi & Smart Contracts',
  SOL: 'Solana Ecosystem & Speed',
  BNB: 'BNB Chain & Exchange Updates',
  XRP: 'XRP Payments & Regulation News',
  ADA: 'Cardano Development & Staking',
  DOGE: 'Dogecoin Community & Memes',
  DOT: 'Polkadot Parachains & Web3',
  MATIC: 'Polygon Scaling & L2 Solutions',
  EQ: 'EarnQuest Mining & Token Economy',
};

function formatPrice(price: number): string {
  if (price >= 1000) return price.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  if (price >= 1) return price.toFixed(2);
  if (price >= 0.01) return price.toFixed(4);
  return price.toFixed(6);
}

export default function LiveRoomModal({ isOpen, onClose, roomId }: LiveRoomModalProps) {
  const [room, setRoom] = useState<Room | null>(null);
  const [chatMessages, setChatMessages] = useState<ChatMessage[]>([]);
  const [participantSlots, setParticipantSlots] = useState<ParticipantSlot[]>([]);
  const [hostAvatar, setHostAvatar] = useState('/ber1.jpg');
  const [newMessage, setNewMessage] = useState('');
  const [isFollowing, setIsFollowing] = useState(false);
  const [showPriceCard, setShowPriceCard] = useState(true);
  const [showNote, setShowNote] = useState(true);
  const [coinData, setCoinData] = useState<CoinData>({
    symbol: 'BTC', logo: '', price: 0, change: 0, chartData: [],
  });
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const intervalsRef = useRef<number[]>([]);
  const coinSymbolRef = useRef('BTC');

  const clearIntervals = useCallback(() => {
    intervalsRef.current.forEach(id => clearInterval(id));
    intervalsRef.current = [];
    if ((window as any).__eqUnsub) {
      (window as any).__eqUnsub();
      delete (window as any).__eqUnsub;
    }
  }, []);

  useEffect(() => {
    if (!isOpen) return;

    const hostId = Math.floor(Math.random() * 70) + 1;
    setHostAvatar(`https://i.pravatar.cc/80?img=${hostId}`);

    setParticipantSlots(generateParticipantSlots(5));

    loadRoomData();

    const listenerInt = window.setInterval(() => {
      setRoom(prev => {
        if (!prev) return prev;
        const delta = Math.floor(Math.random() * 30) - 10;
        return { ...prev, listener_count: Math.max(500, prev.listener_count + delta) };
      });
    }, 3000);
    intervalsRef.current.push(listenerInt);

    const slotInt = window.setInterval(() => {
      setParticipantSlots(generateParticipantSlots(5));
    }, 240000);
    intervalsRef.current.push(slotInt);

    return () => {
      clearIntervals();
      setChatMessages([]);
      setRoom(null);
      setCoinData({ symbol: 'BTC', logo: '', price: 0, change: 0, chartData: [] });
      setShowPriceCard(true);
      setShowNote(true);
    };
  }, [isOpen, roomId]);

  const startChatEngine = useCallback((symbol: string) => {
    const initial = generateInitialMessages(symbol, 15);
    setChatMessages(initial);

    const baseDelay = 2500;
    const addMessage = () => {
      const msg = generateNewMessage(symbol);
      setChatMessages(prev => [...prev.slice(-40), msg]);
      const next = baseDelay + Math.random() * 3000;
      const tid = window.setTimeout(addMessage, next);
      intervalsRef.current.push(tid as unknown as number);
    };

    const firstId = window.setTimeout(addMessage, baseDelay + Math.random() * 2000);
    intervalsRef.current.push(firstId as unknown as number);
  }, []);

  const fetchRealCoinData = async (symbol: string, logo: string) => {
    coinSymbolRef.current = symbol;

    if (symbol === 'EQ') {
      const pm = EarnQuestPriceManager.getInstance();
      const price = pm.getPrice();
      const ch = pm.getChange();

      const pts: number[] = [];
      let p = price * 0.98;
      for (let i = 0; i < 50; i++) {
        p += (Math.random() - 0.48) * price * 0.008;
        pts.push(Math.max(p, price * 0.92));
      }
      pts[pts.length - 1] = price;

      setCoinData({ symbol: 'EQ', logo: logo || '/earnquest-logo-icon-2.png', price, change: ch, chartData: pts });
      startChatEngine('EQ');

      const unsub = pm.subscribe(() => {
        const np = pm.getPrice();
        const nch = pm.getChange();
        setCoinData(prev => ({
          ...prev,
          price: np,
          change: nch,
          chartData: [...prev.chartData.slice(1), np],
        }));
      });

      const unsubId = window.setTimeout(() => {}, 0);
      intervalsRef.current.push(unsubId);
      const origCleanup = () => unsub();
      (window as any).__eqUnsub = origCleanup;
      return;
    }

    try {
      const [tickerRes, klineRes] = await Promise.all([
        fetch(`https://api.binance.com/api/v3/ticker/24hr?symbol=${symbol}USDT`),
        fetch(`https://api.binance.com/api/v3/klines?symbol=${symbol}USDT&interval=1h&limit=50`),
      ]);

      const ticker = await tickerRes.json();
      const klines = await klineRes.json();
      const realPrice = parseFloat(ticker.lastPrice);
      const realChange = parseFloat(ticker.priceChangePercent);
      const chartPts = Array.isArray(klines) ? klines.map((k: string[]) => parseFloat(k[4])) : [];

      setCoinData({ symbol, logo, price: realPrice, change: realChange, chartData: chartPts.length > 0 ? chartPts : [realPrice] });
      startChatEngine(symbol);

      const tid = window.setInterval(async () => {
        try {
          const res = await fetch(`https://api.binance.com/api/v3/ticker/price?symbol=${symbol}USDT`);
          const d = await res.json();
          const np = parseFloat(d.price);
          setCoinData(prev => ({
            ...prev,
            price: np,
            change: ((np - realPrice) / realPrice) * 100 + realChange,
            chartData: [...prev.chartData.slice(1), np],
          }));
        } catch { /* ignore */ }
      }, 5000);
      intervalsRef.current.push(tid);
    } catch {
      setCoinData(prev => ({ ...prev, symbol, logo, price: 0, change: 0, chartData: [] }));
      startChatEngine(symbol);
    }
  };

  const loadRoomData = async () => {
    const { data: roomData } = await supabase
      .from('live_rooms')
      .select('*')
      .eq('id', roomId)
      .maybeSingle();

    if (roomData) {
      setRoom(roomData);
      fetchRealCoinData(roomData.coin_symbol || 'BTC', roomData.coin_logo || '');
    }
  };

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [chatMessages]);

  const sendMessage = () => {
    if (!newMessage.trim()) return;

    setChatMessages(prev => [...prev.slice(-40), {
      id: `user-${Date.now()}`,
      username: 'You',
      avatar: '',
      message: newMessage.trim(),
      timestamp: Date.now(),
    }]);
    setNewMessage('');
  };

  const handleKeyPress = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); sendMessage(); }
  };

  if (!isOpen || !room) return null;

  const topic = COIN_TOPICS[coinData.symbol] || room.topic || 'Crypto Discussion';

  const miniChartPoints = coinData.chartData.length > 1
    ? (() => {
        const min = Math.min(...coinData.chartData);
        const max = Math.max(...coinData.chartData);
        const range = max - min || 1;
        return coinData.chartData.map((p, i) =>
          `${(i / (coinData.chartData.length - 1)) * 100},${28 - ((p - min) / range) * 22}`
        ).join(' ');
      })()
    : '';

  return (
    <div className="fixed inset-0 bg-[#0B0E11] z-[60] flex flex-col">
      {/* Basonce Logo Background with Subtle Yellow Glow */}
      <div className="absolute inset-0 flex items-center justify-center pointer-events-none z-0">
        <div className="relative">
          <div
            className="absolute inset-0 rounded-full"
            style={{
              background: 'radial-gradient(circle, rgba(240, 185, 11, 0.12) 0%, rgba(240, 185, 11, 0.05) 35%, rgba(240, 185, 11, 0.02) 55%, transparent 75%)',
              transform: 'scale(2.2)',
            }}
          />
          <img
            src="/BASONCE_LOGO_SON_BITEN.png"
            alt=""
            className="w-[420px] h-[420px] object-contain opacity-[0.08]"
            style={{
              filter: 'drop-shadow(0 0 30px rgba(240, 185, 11, 0.15)) drop-shadow(0 0 60px rgba(240, 185, 11, 0.08)) drop-shadow(0 0 100px rgba(240, 185, 11, 0.04))',
            }}
          />
        </div>
      </div>

      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 border-b border-gray-800/50 z-10 bg-[#0B0E11]/80 backdrop-blur-sm">
        <div className="flex items-center gap-3">
          <div className="relative">
            <div className="w-12 h-12 rounded-full overflow-hidden border-2 border-gray-700">
              <img src={hostAvatar} alt="Host" className="w-full h-full object-cover" />
            </div>
            <div className="absolute -bottom-1 -right-1 bg-red-500 text-white text-[8px] font-bold px-1.5 py-0.5 rounded">LIVE</div>
          </div>
          <div>
            <h2 className="text-white font-semibold text-sm">{room.title}</h2>
            <div className="flex items-center gap-1 text-xs text-gray-400">
              <Users className="w-3 h-3" />
              <span>{room.listener_count.toLocaleString()} listeners</span>
            </div>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <button
            onClick={() => setIsFollowing(!isFollowing)}
            className={`px-4 py-1.5 rounded-full text-xs font-bold transition-all ${isFollowing ? 'bg-gray-700 text-gray-300' : 'bg-[#F0B90B] text-black'}`}
          >
            {isFollowing ? 'Following' : 'Follow'}
          </button>
          <button onClick={onClose} className="text-gray-400 hover:text-white">
            <X className="w-5 h-5" />
          </button>
        </div>
      </div>

      {/* Participants - 5 Pravatar Users */}
      <div className="px-4 py-3 border-b border-gray-800/30 z-10">
        <div className="flex items-center gap-2 overflow-x-auto">
          {participantSlots.map((slot) => (
            <div key={slot.id} className="flex-shrink-0 relative">
              <div className="w-14 h-14 rounded-full overflow-hidden border-2 border-gray-600 hover:border-[#F0B90B] transition-colors">
                <img src={slot.avatar} alt={slot.username} className="w-full h-full object-cover" />
              </div>
              {Math.random() > 0.6 && (
                <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-green-500 rounded-full border-2 border-[#0B0E11]"></div>
              )}
            </div>
          ))}
        </div>
      </div>

      {/* Chat Messages */}
      <div className="flex-1 overflow-y-auto px-4 py-3 space-y-3 z-10 relative">
        {chatMessages.map((msg) => (
          <div key={msg.id} className="flex items-start gap-2.5 animate-[fadeSlideIn_0.3s_ease-out]">
            <div className="w-8 h-8 rounded-full overflow-hidden bg-gray-800 flex-shrink-0">
              {msg.avatar ? (
                <img src={msg.avatar} alt={msg.username} className="w-full h-full object-cover" />
              ) : (
                <div className="w-full h-full bg-[#F0B90B]/20 flex items-center justify-center text-[#F0B90B] text-xs font-bold">
                  {msg.username[0]}
                </div>
              )}
            </div>
            <div className="flex-1 min-w-0">
              <span className={`text-sm font-semibold ${msg.username === 'You' ? 'text-[#F0B90B]' : 'text-white'}`}>
                {msg.username}
              </span>
              <p className="text-gray-300 text-sm leading-relaxed break-words">{msg.message}</p>
            </div>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      {/* Note */}
      {showNote && (
        <div className="mx-4 mb-2 bg-[#1A1D26] rounded-lg p-3 border border-gray-800/50 relative z-10">
          <button onClick={() => setShowNote(false)} className="absolute top-2 right-2 text-gray-500 hover:text-gray-300">
            <X className="w-4 h-4" />
          </button>
          <p className="text-xs text-gray-400 pr-6">
            <span className="text-[#F0B90B] font-semibold">Note:</span> Please respect Basonce's community standards.
            Opinions expressed in the live room are personal and do not constitute financial advice.
          </p>
          <p className="text-xs mt-1.5">
            <span className="text-gray-400">Topic:</span>{' '}
            <span className="text-[#F0B90B] font-semibold">{topic}</span>
          </p>
        </div>
      )}

      {/* Floating Coin Price Card - Compact */}
      {showPriceCard && coinData.price > 0 && (
        <div className="absolute bottom-24 right-3 w-36 bg-white rounded-xl shadow-2xl overflow-hidden z-20">
          <button onClick={() => setShowPriceCard(false)} className="absolute top-1.5 right-1.5 text-gray-400 hover:text-gray-600 z-10">
            <X className="w-3 h-3" />
          </button>
          <div className="absolute top-1.5 left-2 bg-[#F0B90B] text-[9px] font-bold px-1.5 py-0.5 rounded text-black">Pinned</div>
          <div className="pt-6 px-2.5 pb-2">
            <div className="flex items-center gap-1.5 mb-0.5">
              {coinData.logo ? (
                <img src={coinData.logo} alt={coinData.symbol} className="w-4 h-4 rounded-full" />
              ) : (
                <div className="w-4 h-4 rounded-full bg-[#F0B90B] flex items-center justify-center text-black text-[8px] font-bold">
                  {coinData.symbol[0]}
                </div>
              )}
              <span className="text-black font-bold text-xs">{coinData.symbol}</span>
            </div>
            <div className={`text-xs font-semibold mb-0.5 ${coinData.change >= 0 ? 'text-green-600' : 'text-red-600'}`}>
              {coinData.change >= 0 ? '+' : ''}{coinData.change.toFixed(2)}%
            </div>
            {miniChartPoints && (
              <div className="h-8 mb-1">
                <svg className="w-full h-full" preserveAspectRatio="none" viewBox="0 0 100 28">
                  <polyline fill="none" stroke={coinData.change >= 0 ? '#10b981' : '#ef4444'} strokeWidth="1.5" points={miniChartPoints} />
                </svg>
              </div>
            )}
            <div className="text-black text-base font-bold mb-1.5">${formatPrice(coinData.price)}</div>
            <button
              onClick={() => {
                onClose();
                localStorage.setItem('currentTab', 'trade');
                localStorage.setItem('selectedCoinSymbol', coinData.symbol);
                window.dispatchEvent(new CustomEvent('navigate-to-trade', { detail: { symbol: coinData.symbol } }));
              }}
              className="w-full bg-[#F0B90B] hover:bg-[#F0B90B]/90 text-black font-bold py-1.5 rounded-lg text-[11px] transition-colors"
            >
              Trade
            </button>
          </div>
        </div>
      )}

      {/* Bottom Action Bar */}
      <div className="bg-[#0B0E11] border-t border-gray-800/50 px-4 py-3 z-10">
        <div className="flex items-center gap-2">
          <div className="flex-1">
            <input
              type="text"
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              onKeyPress={handleKeyPress}
              placeholder="Chat with everyone"
              className="w-full bg-[#1E2028] border border-gray-700 rounded-full px-4 py-2.5 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-gray-600"
            />
          </div>
          <button
            onClick={sendMessage}
            className={`w-10 h-10 rounded-full flex items-center justify-center transition-colors ${newMessage.trim() ? 'bg-[#F0B90B] hover:bg-[#F0B90B]/80' : 'bg-[#1E2028] hover:bg-[#2A2D38]'}`}
          >
            <Send className={`w-5 h-5 ${newMessage.trim() ? 'text-black' : 'text-gray-400'}`} />
          </button>
          <button className="w-10 h-10 bg-[#1E2028] hover:bg-[#2A2D38] rounded-full flex items-center justify-center transition-colors">
            <LinkIcon className="w-5 h-5 text-gray-400" />
          </button>
          <button className="w-10 h-10 bg-[#1E2028] hover:bg-[#2A2D38] rounded-full flex items-center justify-center transition-colors">
            <DollarSign className="w-5 h-5 text-[#F0B90B]" />
          </button>
          <button className="w-10 h-10 bg-[#1E2028] hover:bg-[#2A2D38] rounded-full flex items-center justify-center transition-colors">
            <MoreHorizontal className="w-5 h-5 text-gray-400" />
          </button>
        </div>
      </div>

      <style>{`
        @keyframes fadeSlideIn {
          from { opacity: 0; transform: translateY(6px); }
          to { opacity: 1; transform: translateY(0); }
        }
      `}</style>
    </div>
  );
}
