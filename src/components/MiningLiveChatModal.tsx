import { useState, useEffect, useRef } from 'react';
import { X, Send, Radio, Users, TrendingUp, Zap, MessageCircle, DollarSign, ArrowUpCircle, Award, Sparkles, Flame, Crown, Star, Activity } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { globalMiningStats } from '../lib/global-mining-stats';
import VoiceRoomPlayer from './VoiceRoomPlayer';

interface Message {
  id: string;
  username: string;
  avatar_url: string;
  message: string;
  created_at: string;
  level: number;
  country: string;
  message_type: 'withdrawal' | 'profit' | 'upgrade' | 'milestone' | 'tip' | 'celebration' | 'general';
  amount: number;
  is_featured: boolean;
}

export default function MiningLiveChatModal({ isOpen, onClose }: { isOpen: boolean; onClose: () => void }) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [newMessage, setNewMessage] = useState('');
  const [onlineCount, setOnlineCount] = useState(3745);
  const [isLoading, setIsLoading] = useState(true);
  const [totalWithdrawnToday, setTotalWithdrawnToday] = useState(520000);
  const [bigWins, setBigWins] = useState(342);
  const [isTyping, setIsTyping] = useState(false);
  const [activeMiners, setActiveMiners] = useState(12847);
  const [totalEarnings, setTotalEarnings] = useState(645000);
  const [displayedMessageCount, setDisplayedMessageCount] = useState(847);
  const [recentUpgrades, setRecentUpgrades] = useState(5842);
  const [recentUpgradesMinutes, setRecentUpgradesMinutes] = useState(18);
  const [isSending, setIsSending] = useState(false);
  const [lastMessageTime, setLastMessageTime] = useState(0);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const messagesContainerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isOpen) {
      loadMessages();

      // Subscribe to real-time new messages
      const channel = supabase
        .channel('mining-chat-messages')
        .on(
          'postgres_changes',
          {
            event: 'INSERT',
            schema: 'public',
            table: 'mining_chat_messages'
          },
          (payload) => {
            const newMsg = payload.new as Message;
            setMessages(prev => [...prev, newMsg]);
          }
        )
        .subscribe();

      // Subscribe to global mining stats
      const unsubscribe = globalMiningStats.subscribe((stats) => {
        setActiveMiners(stats.activeMiners);
        setTotalEarnings(stats.hourlyEarnings);
        setRecentUpgrades(stats.recentUpgrades);
        setRecentUpgradesMinutes(stats.upgradesLast10Min);
        setOnlineCount(stats.onlineCount);
      });

      const typingInterval = setInterval(() => {
        setIsTyping(Math.random() > 0.6);
      }, 3000);

      const withdrawnInterval = setInterval(() => {
        setTotalWithdrawnToday(prev => Math.min(678000, prev + Math.floor(Math.random() * 800 + 200)));
      }, 3000);

      const bigWinsInterval = setInterval(() => {
        setBigWins(prev => Math.max(200, Math.min(500, prev + Math.floor(Math.random() * 6 - 2))));
      }, 6000);

      let messageTimeout: NodeJS.Timeout;
      const scheduleNextMessageUpdate = () => {
        const randomDelay = Math.random() * 2000 + 1500;
        messageTimeout = setTimeout(() => {
          setDisplayedMessageCount(prev => {
            const increment = Math.floor(Math.random() * 5) + 2;
            const newCount = prev + increment;
            if (newCount >= 2000) {
              return 847;
            }
            return newCount;
          });
          scheduleNextMessageUpdate();
        }, randomDelay);
      };
      scheduleNextMessageUpdate();

      return () => {
        channel.unsubscribe();
        unsubscribe();
        clearInterval(typingInterval);
        clearInterval(withdrawnInterval);
        clearInterval(bigWinsInterval);
        clearTimeout(messageTimeout);
      };
    }
  }, [isOpen]);

  useEffect(() => {
    if (messagesEndRef.current && messages.length > 0) {
      messagesEndRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [messages]);

  const loadMessages = async () => {
    setIsLoading(true);

    const { count } = await supabase
      .from('mining_chat_messages')
      .select('*', { count: 'exact', head: true });

    const totalMessages = count || 10000;
    const randomOffset = Math.floor(Math.random() * Math.max(0, totalMessages - 100));

    const { data } = await supabase
      .from('mining_chat_messages')
      .select('*')
      .order('created_at', { ascending: true })
      .range(randomOffset, randomOffset + 99);

    if (data) {
      setMessages(data as Message[]);

      const withdrawalMessages = data.filter((msg: any) => msg.message_type === 'withdrawal');
      const totalWithdrawn = withdrawalMessages.reduce((sum: number, msg: any) => sum + Number(msg.amount || 0), 0);
      const boostedWithdrawn = 520000 + totalWithdrawn;
      setTotalWithdrawnToday(boostedWithdrawn);

      const profitMessages = data.filter((msg: any) => msg.message_type === 'profit' || msg.message_type === 'milestone');
      const totalProfit = profitMessages.reduce((sum: number, msg: any) => sum + Number(msg.amount || 0), 0);
      const boostedEarnings = 645000 + totalProfit;
      setTotalEarnings(boostedEarnings);

      const featuredCount = data.filter((msg: any) => msg.is_featured).length;
      const boostedBigWins = 342 + featuredCount;
      setBigWins(boostedBigWins);
    }

    setIsLoading(false);
  };

  const handleSendMessage = async () => {
    if (!newMessage.trim()) return;
    if (isSending) return;

    // Rate limiting: 5 seconds between messages
    const now = Date.now();
    if (now - lastMessageTime < 5000) {
      alert('Please wait 5 seconds between messages');
      return;
    }

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      alert('Please sign in to send messages');
      return;
    }

    setIsSending(true);

    try {
      // Get user profile
      const { data: profile } = await supabase
        .from('user_profiles')
        .select('username, avatar_url, country')
        .eq('user_id', user.id)
        .maybeSingle();

      // Get user level from mining purchases
      const { data: purchases } = await supabase
        .from('user_mining_purchases')
        .select('shop_item_id')
        .eq('user_id', user.id);

      const userLevel = purchases ? Math.min(5, Math.floor(purchases.length / 2) + 1) : 1;

      // Insert message
      const { error } = await supabase
        .from('mining_chat_messages')
        .insert({
          user_id: user.id,
          username: profile?.username || user.email?.split('@')[0] || 'User',
          avatar_url: profile?.avatar_url || `https://api.dicebear.com/7.x/avataaars/svg?seed=${user.id}`,
          message: newMessage.trim(),
          message_type: 'general',
          amount: 0,
          level: userLevel,
          country: profile?.country || 'US',
          is_featured: false
        });

      if (error) throw error;

      setNewMessage('');
      setLastMessageTime(now);
    } catch (error) {
      console.error('Error sending message:', error);
      alert('Failed to send message. Please try again.');
    } finally {
      setIsSending(false);
    }
  };

  const getTimeAgo = (timestamp: string) => {
    const now = new Date();
    const messageTime = new Date(timestamp);
    const diffInSeconds = Math.floor((now.getTime() - messageTime.getTime()) / 1000);

    if (diffInSeconds < 60) return 'just now';
    if (diffInSeconds < 3600) return `${Math.floor(diffInSeconds / 60)}m ago`;
    if (diffInSeconds < 86400) return `${Math.floor(diffInSeconds / 3600)}h ago`;
    return `${Math.floor(diffInSeconds / 86400)}d ago`;
  };

  const getLevelColor = (level: number) => {
    if (level >= 5) return 'text-purple-400 bg-gradient-to-r from-purple-500/30 to-pink-500/30 border border-purple-400/30';
    if (level >= 4) return 'text-blue-400 bg-gradient-to-r from-blue-500/30 to-cyan-500/30 border border-blue-400/30';
    if (level >= 3) return 'text-emerald-400 bg-gradient-to-r from-emerald-500/30 to-green-500/30 border border-emerald-400/30';
    if (level >= 2) return 'text-yellow-400 bg-gradient-to-r from-yellow-500/30 to-orange-500/30 border border-yellow-400/30';
    return 'text-gray-400 bg-gray-500/20 border border-gray-400/20';
  };

  const getMessageTypeIcon = (type: string, isFeatured: boolean) => {
    if (isFeatured) {
      return <Crown className="w-4 h-4 text-yellow-400 drop-shadow-[0_0_8px_rgba(250,204,21,0.8)]" />;
    }
    switch (type) {
      case 'withdrawal':
        return <DollarSign className="w-4 h-4 text-emerald-400" />;
      case 'profit':
        return <TrendingUp className="w-4 h-4 text-purple-400" />;
      case 'upgrade':
        return <ArrowUpCircle className="w-4 h-4 text-pink-400" />;
      case 'milestone':
        return <Award className="w-4 h-4 text-orange-400" />;
      case 'celebration':
        return <Sparkles className="w-4 h-4 text-fuchsia-400" />;
      default:
        return null;
    }
  };

  const getMessageTypeColor = (type: string, isFeatured: boolean) => {
    if (isFeatured) {
      return 'bg-gradient-to-r from-yellow-500/10 via-orange-500/10 to-pink-500/10 border-l-4 border-yellow-500 shadow-lg shadow-yellow-500/20';
    }
    switch (type) {
      case 'withdrawal':
        return 'hover:bg-gradient-to-r hover:from-emerald-500/5 hover:to-transparent';
      case 'profit':
        return 'hover:bg-gradient-to-r hover:from-purple-500/5 hover:to-transparent';
      case 'upgrade':
        return 'hover:bg-gradient-to-r hover:from-pink-500/5 hover:to-transparent';
      case 'milestone':
        return 'hover:bg-gradient-to-r hover:from-orange-500/5 hover:to-transparent';
      case 'celebration':
        return 'hover:bg-gradient-to-r hover:from-fuchsia-500/5 hover:to-transparent';
      default:
        return 'hover:bg-[#1A1B23]/50';
    }
  };

  const getCountryFlag = (country: string) => {
    const flags: { [key: string]: string } = {
      'USA': '🇺🇸', 'US': '🇺🇸',
      'UK': '🇬🇧', 'United Kingdom': '🇬🇧',
      'Canada': '🇨🇦', 'CA': '🇨🇦',
      'Australia': '🇦🇺', 'AU': '🇦🇺',
      'Germany': '🇩🇪', 'DE': '🇩🇪',
      'France': '🇫🇷', 'FR': '🇫🇷',
      'Spain': '🇪🇸', 'ES': '🇪🇸',
      'Italy': '🇮🇹', 'IT': '🇮🇹',
      'Japan': '🇯🇵', 'JP': '🇯🇵',
      'South Korea': '🇰🇷', 'Korea': '🇰🇷', 'KR': '🇰🇷',
      'China': '🇨🇳', 'CN': '🇨🇳',
      'India': '🇮🇳', 'IN': '🇮🇳',
      'Brazil': '🇧🇷', 'BR': '🇧🇷',
      'Mexico': '🇲🇽', 'MX': '🇲🇽',
      'Argentina': '🇦🇷', 'AR': '🇦🇷',
      'Netherlands': '🇳🇱', 'NL': '🇳🇱',
      'Sweden': '🇸🇪', 'SE': '🇸🇪',
      'Singapore': '🇸🇬', 'SG': '🇸🇬',
      'UAE': '🇦🇪', 'United Arab Emirates': '🇦🇪', 'AE': '🇦🇪',
      'South Africa': '🇿🇦', 'ZA': '🇿🇦',
      'Russia': '🇷🇺', 'RU': '🇷🇺',
      'Norway': '🇳🇴', 'NO': '🇳🇴',
      'Denmark': '🇩🇰', 'DK': '🇩🇰',
      'Finland': '🇫🇮', 'FI': '🇫🇮',
      'Poland': '🇵🇱', 'PL': '🇵🇱',
      'Turkey': '🇹🇷', 'Türkiye': '🇹🇷', 'TR': '🇹🇷',
      'Switzerland': '🇨🇭', 'CH': '🇨🇭',
      'Belgium': '🇧🇪', 'BE': '🇧🇪',
      'Portugal': '🇵🇹', 'PT': '🇵🇹',
      'Greece': '🇬🇷', 'GR': '🇬🇷',
      'Austria': '🇦🇹', 'AT': '🇦🇹',
      'Ireland': '🇮🇪', 'IE': '🇮🇪',
      'New Zealand': '🇳🇿', 'NZ': '🇳🇿',
      'Thailand': '🇹🇭', 'TH': '🇹🇭',
      'Vietnam': '🇻🇳', 'VN': '🇻🇳',
      'Philippines': '🇵🇭', 'PH': '🇵🇭',
      'Indonesia': '🇮🇩', 'ID': '🇮🇩',
      'Malaysia': '🇲🇾', 'MY': '🇲🇾',
      'Pakistan': '🇵🇰', 'PK': '🇵🇰',
      'Bangladesh': '🇧🇩', 'BD': '🇧🇩',
      'Egypt': '🇪🇬', 'EG': '🇪🇬',
      'Saudi Arabia': '🇸🇦', 'SA': '🇸🇦',
      'Nigeria': '🇳🇬', 'NG': '🇳🇬',
      'Kenya': '🇰🇪', 'KE': '🇰🇪',
      'Morocco': '🇲🇦', 'MA': '🇲🇦',
      'Chile': '🇨🇱', 'CL': '🇨🇱',
      'Colombia': '🇨🇴', 'CO': '🇨🇴',
      'Peru': '🇵🇪', 'PE': '🇵🇪',
      'Venezuela': '🇻🇪', 'VE': '🇻🇪',
      'Israel': '🇮🇱', 'IL': '🇮🇱',
      'Czech Republic': '🇨🇿', 'Czechia': '🇨🇿', 'CZ': '🇨🇿',
      'Romania': '🇷🇴', 'RO': '🇷🇴',
      'Hungary': '🇭🇺', 'HU': '🇭🇺',
      'Ukraine': '🇺🇦', 'UA': '🇺🇦'
    };
    return flags[country] || '🌍';
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/90 backdrop-blur-md z-[100] flex items-end sm:items-center justify-center sm:p-4 animate-fadeIn">
      <div className="bg-gradient-to-b from-[#1A1B23] to-[#0D0E12] rounded-t-3xl sm:rounded-3xl w-full max-w-2xl h-screen sm:max-h-[90vh] flex flex-col border border-pink-500/20 shadow-2xl shadow-pink-500/10 animate-slide-up">

        <div className="relative bg-gradient-to-br from-pink-500 via-purple-600 to-orange-500 p-5 rounded-t-3xl flex items-center justify-between overflow-hidden">
          <div className="absolute inset-0 bg-gradient-to-br from-white/10 via-transparent to-black/20"></div>
          <div className="absolute top-0 left-0 w-full h-full">
            <div className="absolute top-2 right-10 w-32 h-32 bg-yellow-400/20 rounded-full blur-3xl animate-pulse"></div>
            <div className="absolute bottom-2 left-10 w-40 h-40 bg-purple-400/20 rounded-full blur-3xl animate-pulse" style={{ animationDelay: '1s' }}></div>
          </div>

          <div className="flex items-center gap-3 relative z-10">
            <div className="relative">
              <div className="w-14 h-14 bg-gradient-to-br from-yellow-400 via-orange-400 to-orange-500 rounded-2xl flex items-center justify-center shadow-xl shadow-orange-500/50 border-2 border-white/30 animate-pulse">
                <Radio className="w-7 h-7 text-white" />
              </div>
              <div className="absolute -top-1 -right-1 w-4 h-4 bg-red-500 rounded-full animate-ping"></div>
              <div className="absolute -top-1 -right-1 w-4 h-4 bg-red-500 rounded-full"></div>
            </div>
            <div>
              <div className="flex items-center gap-2 mb-1">
                <h2 className="text-2xl font-black text-white drop-shadow-lg">Miners Chat</h2>
                <div className="flex items-center gap-1 bg-gradient-to-r from-red-500 to-rose-600 px-3 py-1 rounded-full shadow-lg shadow-red-500/50 animate-pulse">
                  <Radio className="w-3 h-3 text-white animate-pulse" />
                  <span className="text-white text-xs font-black tracking-widest">LIVE</span>
                </div>
              </div>
              <div className="flex items-center gap-3 text-white/90 text-xs sm:text-sm">
                <div className="flex items-center gap-1 sm:gap-1.5">
                  <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse shadow-lg shadow-green-400/50"></div>
                  <span className="font-bold text-sm sm:text-base">{onlineCount.toLocaleString()}</span>
                  <span className="text-white/70 text-xs sm:text-sm">online</span>
                </div>
                <div className="flex items-center gap-1 sm:gap-1.5">
                  <Flame className="w-3.5 h-3.5 sm:w-4 sm:h-4 text-orange-300" />
                  <span className="font-bold text-sm sm:text-base">{activeMiners.toLocaleString()}</span>
                  <span className="text-white/70 text-xs sm:text-sm">mining</span>
                </div>
              </div>
            </div>
          </div>
          <button
            onClick={onClose}
            className="relative z-10 w-12 h-12 rounded-xl bg-white/10 hover:bg-white/20 active:bg-white/30 backdrop-blur-sm transition-all flex items-center justify-center flex-shrink-0 border border-white/20 shadow-lg hover:scale-110 active:scale-95"
          >
            <X className="w-6 h-6 text-white drop-shadow-lg" />
          </button>
        </div>

        <div className="bg-gradient-to-b from-[#1A1B23] to-[#0D0E12] border-y border-[#2B3139]/50 px-3 py-1.5 sm:py-4 backdrop-blur-sm">
          <div className="flex items-center justify-between mb-1">
            <div className="flex items-center gap-1">
              <div className="w-1 h-1 bg-red-500 rounded-full animate-pulse"></div>
              <h3 className="text-[10px] sm:text-xs font-bold text-white/90 tracking-wide">LIVE</h3>
            </div>
          </div>

          <div className="grid grid-cols-3 gap-1 sm:gap-3">
            <div className="bg-[#0D0E12] rounded p-1 sm:p-3 border border-[#2B3139]/50">
              <div className="text-[8px] sm:text-xs text-gray-400 font-medium mb-0 sm:mb-1 truncate">Miners</div>
              <div className="text-xs sm:text-xl font-bold text-white tracking-tight">
                {(activeMiners / 1000).toFixed(1)}k
              </div>
            </div>

            <div className="bg-[#0D0E12] rounded p-1 sm:p-3 border border-[#2B3139]/50">
              <div className="text-[8px] sm:text-xs text-gray-400 font-medium mb-0 sm:mb-1 truncate">Earned</div>
              <div className="text-xs sm:text-xl font-bold text-emerald-400 tracking-tight">
                ${(totalEarnings / 1000).toFixed(1)}k
              </div>
            </div>

            <div className="bg-[#0D0E12] rounded p-1 sm:p-3 border border-[#2B3139]/50">
              <div className="text-[8px] sm:text-xs text-gray-400 font-medium mb-0 sm:mb-1 truncate">Upgrades</div>
              <div className="text-xs sm:text-xl font-bold text-white tracking-tight">
                {(recentUpgrades / 1000).toFixed(1)}k
              </div>
            </div>
          </div>
        </div>

        <div className="px-3 pt-3">
          <VoiceRoomPlayer />
        </div>

        <div
          ref={messagesContainerRef}
          className="flex-1 overflow-y-auto p-3 space-y-2.5 scrollbar-thin scrollbar-thumb-purple-500/20 scrollbar-track-transparent"
        >
          {isLoading ? (
            <div className="flex flex-col items-center justify-center h-full">
              <div className="relative">
                <div className="w-16 h-16 border-4 border-purple-500/20 border-t-purple-500 rounded-full animate-spin"></div>
                <div className="absolute inset-0 flex items-center justify-center">
                  <Radio className="w-6 h-6 text-purple-500 animate-pulse" />
                </div>
              </div>
              <div className="text-gray-400 text-sm mt-4 font-medium">Loading messages...</div>
            </div>
          ) : messages.length === 0 ? (
            <div className="flex flex-col items-center justify-center h-full text-gray-400">
              <div className="w-20 h-20 bg-gradient-to-br from-purple-500/10 to-pink-500/10 rounded-2xl flex items-center justify-center mb-4 border border-purple-500/20">
                <MessageCircle className="w-10 h-10 text-purple-400/50" />
              </div>
              <p className="text-base font-medium">No messages yet</p>
              <p className="text-sm text-gray-500 mt-1">Be the first to chat!</p>
            </div>
          ) : (
            <>
              {messages.map((msg) => (
                <div
                  key={msg.id}
                  className={`flex gap-2.5 group p-3 rounded-xl transition-all duration-300 ${getMessageTypeColor(msg.message_type, msg.is_featured)} backdrop-blur-sm bg-[#1A1B23]/80 border border-purple-500/10`}
                >
                  <div className="relative flex-shrink-0">
                    <div className="relative">
                      <img
                        src={msg.avatar_url}
                        alt={msg.username}
                        className="w-11 h-11 rounded-full border-2 border-purple-500/40 shadow-lg"
                      />
                      {msg.is_featured && (
                        <div className="absolute inset-0 rounded-full bg-gradient-to-br from-yellow-400/30 to-orange-400/30 animate-pulse"></div>
                      )}
                    </div>
                    {msg.is_featured && (
                      <div className="absolute -top-1 -right-1 w-6 h-6 bg-gradient-to-br from-yellow-400 to-orange-500 rounded-full flex items-center justify-center shadow-lg shadow-yellow-500/50 border-2 border-white">
                        <Crown className="w-3 h-3 text-white" />
                      </div>
                    )}
                    {msg.level >= 5 && !msg.is_featured && (
                      <div className="absolute -bottom-1 -right-1 w-5 h-5 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center shadow-lg">
                        <Star className="w-2.5 h-2.5 text-white" />
                      </div>
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-1.5 sm:gap-2 mb-1 sm:mb-1.5 flex-wrap">
                      <span className="font-bold text-white text-sm sm:text-base drop-shadow-lg">{msg.username}</span>
                      {msg.level > 0 && (
                        <span className={`text-[9px] sm:text-[10px] px-1.5 sm:px-2 py-0.5 sm:py-1 rounded-lg font-black ${getLevelColor(msg.level)} drop-shadow-lg`}>
                          Lv.{msg.level}
                        </span>
                      )}
                      <span className="text-sm sm:text-base drop-shadow-lg">{getCountryFlag(msg.country)}</span>
                      {getMessageTypeIcon(msg.message_type, msg.is_featured)}
                      <span className="text-[10px] sm:text-xs text-gray-500 font-medium">{getTimeAgo(msg.created_at)}</span>
                    </div>
                    <p className="text-gray-300 text-sm sm:text-base break-words leading-relaxed">{msg.message}</p>
                    {msg.amount > 0 && (msg.message_type === 'withdrawal' || msg.message_type === 'profit' || msg.message_type === 'milestone') && (
                      <div className="mt-1.5 sm:mt-2 inline-flex items-center gap-1 sm:gap-1.5 bg-gradient-to-r from-emerald-500/30 to-green-500/20 px-2 sm:px-3 py-1 sm:py-1.5 rounded-lg border border-emerald-400/30 shadow-lg">
                        <DollarSign className="w-3.5 h-3.5 sm:w-4 sm:h-4 text-emerald-400" />
                        <span className="text-xs sm:text-sm font-black text-emerald-400 drop-shadow-lg">
                          ${msg.amount.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                        </span>
                      </div>
                    )}
                  </div>
                </div>
              ))}
              {isTyping && (
                <div className="flex gap-2.5 p-3 rounded-xl bg-[#1A1B23]/80 border border-purple-500/10 animate-fadeIn">
                  <div className="w-11 h-11 rounded-full bg-gradient-to-br from-purple-500/20 to-pink-500/20 flex items-center justify-center border border-purple-500/40">
                    <Users className="w-5 h-5 text-purple-400" />
                  </div>
                  <div className="flex-1">
                    <span className="text-sm text-gray-300 font-medium">Someone is typing</span>
                    <div className="flex gap-1.5 mt-2">
                      <div className="w-2.5 h-2.5 bg-purple-500 rounded-full animate-bounce" style={{ animationDelay: '0ms' }}></div>
                      <div className="w-2.5 h-2.5 bg-pink-500 rounded-full animate-bounce" style={{ animationDelay: '150ms' }}></div>
                      <div className="w-2.5 h-2.5 bg-orange-500 rounded-full animate-bounce" style={{ animationDelay: '300ms' }}></div>
                    </div>
                  </div>
                </div>
              )}
              <div ref={messagesEndRef} />
            </>
          )}
        </div>

        <div className="p-4 bg-gradient-to-t from-[#0D0E12] via-[#1A1B23] to-transparent border-t border-purple-500/20 backdrop-blur-sm">
          <div className="flex gap-2">
            <input
              type="text"
              value={newMessage}
              onChange={(e) => setNewMessage(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
              placeholder="Type your message..."
              className="flex-1 bg-[#0D0E12] border-2 border-purple-500/30 focus:border-purple-500 rounded-xl px-4 py-3.5 text-base text-white placeholder-gray-500 focus:outline-none transition-all shadow-lg focus:shadow-purple-500/20"
            />
            <button
              onClick={handleSendMessage}
              disabled={!newMessage.trim() || isSending}
              className="bg-gradient-to-br from-pink-500 via-purple-600 to-orange-500 hover:shadow-xl hover:shadow-purple-500/30 active:scale-95 disabled:from-gray-600 disabled:to-gray-700 disabled:shadow-none text-white px-6 rounded-xl font-bold transition-all disabled:cursor-not-allowed flex items-center justify-center gap-2 border border-white/10 shadow-lg"
            >
              {isSending ? (
                <>
                  <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                  <span className="hidden sm:inline font-black">Sending...</span>
                </>
              ) : (
                <>
                  <Send className="w-5 h-5" />
                  <span className="hidden sm:inline font-black">Send</span>
                </>
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
