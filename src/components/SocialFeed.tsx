import { useState, useEffect, useRef } from 'react';
import { Heart, MessageCircle, Share2, Radio, Crown, Lock, Sparkles, Users, BookOpen, BarChart2, MessageSquare, Newspaper } from 'lucide-react';
import { supabase } from '../lib/supabase';
import { PriceCache } from '../lib/price-cache';
import LiveRoomModal from './LiveRoomModal';
import CopyTradingCarousel from './CopyTradingCarousel';
import FeedPositionCard from './feed/FeedPositionCard';
import FeedNewsCard from './feed/FeedNewsCard';
import FeedLiveEmbed from './feed/FeedLiveEmbed';
import FeedMultiPosition from './feed/FeedMultiPosition';
import FeedCoinTags from './feed/FeedCoinTags';
import FeedEventCard from './feed/FeedEventCard';

interface CoinTag {
  symbol: string;
  change: number;
}

interface SocialPost {
  id: string;
  username: string;
  avatar_url: string;
  content: string;
  coin_symbol: string;
  trade_type: 'long' | 'short';
  entry_price: number;
  exit_price: number;
  profit_loss: number;
  profit_loss_percent: number;
  leverage: number;
  image_url: string | null;
  image_url_2?: string | null;
  post_type?: string;
  likes_count: number;
  comments_count: number;
  shares_count: number;
  is_bullish: boolean;
  created_at: string;
  coin_tags?: CoinTag[];
  asset_change_30d?: number | null;
  chart_coin?: string | null;
  sub_positions?: any[];
  live_room_data?: any;
  sentiment?: string;
}

interface LiveRoom {
  id: string;
  title: string;
  description: string;
  topic: string;
  listener_count: number;
  is_active: boolean;
  is_vip: boolean;
  required_level: number;
  access_type: string;
  room_category: string;
  background_gradient: string;
}

export default function SocialFeed() {
  const [posts, setPosts] = useState<SocialPost[]>([]);
  const [liveRooms, setLiveRooms] = useState<LiveRoom[]>([]);
  const [selectedRoom, setSelectedRoom] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const priceCacheRef = useRef(PriceCache.getInstance());
  const [, setPriceVersion] = useState(0);

  useEffect(() => {
    const pc = priceCacheRef.current;
    pc.init();
    const unsub = pc.subscribe(() => setPriceVersion(v => v + 1));
    return unsub;
  }, []);

  useEffect(() => {
    fetchPosts();
    fetchLiveRooms();

    const postsInterval = setInterval(fetchPosts, 30000);
    const roomsInterval = setInterval(fetchLiveRooms, 30000);
    const listenerInterval = setInterval(() => {
      setLiveRooms(prev => prev.map(room => ({
        ...room,
        listener_count: Math.max(100, room.listener_count + Math.floor(Math.random() * 40) - 20)
      })));
    }, 3000);

    return () => {
      clearInterval(postsInterval);
      clearInterval(roomsInterval);
      clearInterval(listenerInterval);
    };
  }, []);

  const fetchPosts = async () => {
    try {
      const { data, error } = await supabase.rpc('get_random_social_posts', { post_limit: 50 });
      if (error) throw error;

      const adjusted = (data || []).map((post: SocialPost) => {
        if (!post.profit_loss_percent || !post.leverage || post.leverage <= 1) return post;
        if (post.post_type !== 'text' && post.post_type !== 'winner') return post;
        const currentSize = (Math.abs(post.profit_loss) / Math.abs(post.profit_loss_percent)) * 100 * post.leverage;
        if (currentSize < 3793 || currentSize > 200000) {
          const targetSize = 3793 + Math.random() * (200000 - 3793);
          const newPnl = (post.profit_loss_percent / 100) * (targetSize / post.leverage);
          return { ...post, profit_loss: newPnl };
        }
        return post;
      });

      setPosts(adjusted);
    } catch (error) {
      console.error('Error fetching posts:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchLiveRooms = async () => {
    try {
      const { data, error } = await supabase
        .from('live_rooms')
        .select('*')
        .eq('is_active', true)
        .order('listener_count', { ascending: false })
        .limit(72);
      if (error) throw error;
      setLiveRooms(data || []);
    } catch (error) {
      console.error('Error fetching live rooms:', error);
    }
  };

  const formatTimeAgo = (timestamp: string) => {
    const now = new Date();
    const postDate = new Date(timestamp);
    const diffMs = now.getTime() - postDate.getTime();
    const diffH = Math.floor(diffMs / (1000 * 60 * 60));
    const diffD = Math.floor(diffH / 24);
    const diffM = Math.floor(diffMs / (1000 * 60));

    if (diffM < 1) return 'Just now';
    if (diffM < 60) return `${diffM}m`;
    if (diffH < 24) return `${diffH}h`;
    if (diffD < 7) return `${diffD}d`;
    return postDate.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  };

  const getPostTypeIcon = (postType?: string) => {
    switch (postType) {
      case 'analysis': return <BarChart2 className="w-3 h-3" />;
      case 'educational': return <BookOpen className="w-3 h-3" />;
      case 'live_embed': return <Radio className="w-3 h-3" />;
      case 'multi_position': return <BarChart2 className="w-3 h-3" />;
      case 'news': return <Newspaper className="w-3 h-3" />;
      default: return null;
    }
  };

  const getSentimentBadge = (post: SocialPost) => {
    if (post.post_type === 'educational' || post.post_type === 'event' || post.post_type === 'personal') return null;
    const s = post.sentiment || (post.is_bullish ? 'bullish' : 'bearish');
    if (s === 'bullish') return <span className="text-[#0ECB81] text-xs font-semibold">Bullish</span>;
    if (s === 'bearish') return <span className="text-[#F6465D] text-xs font-semibold">Bearish</span>;
    return null;
  };

  if (loading) {
    return (
      <div className="flex justify-center py-16">
        <div className="w-10 h-10 border-2 border-[#F0B90B] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="space-y-0">
      {liveRooms.length > 0 && <LiveRoomsScroller rooms={liveRooms} onRoomClick={setSelectedRoom} />}

      {posts.map((post, index) => (
        <div key={post.id}>
          <div className="bg-[#181A20] border-b border-[#2B3139] px-4 py-4 hover:bg-[#1E2026] transition-colors">
            <div className="flex items-start gap-3">
              <div className="relative flex-shrink-0">
                <img
                  src={post.avatar_url}
                  alt={post.username}
                  className="w-10 h-10 rounded-full object-cover"
                />
                {post.post_type === 'live_embed' && (
                  <div className="absolute -bottom-0.5 -left-0.5 bg-[#F6465D] text-white text-[7px] font-bold px-1 rounded">
                    LIVE
                  </div>
                )}
              </div>

              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-2 flex-wrap">
                  <span className="font-semibold text-sm">{post.username}</span>
                  {getPostTypeIcon(post.post_type) && (
                    <span className="text-[#F0B90B]">{getPostTypeIcon(post.post_type)}</span>
                  )}
                  <span className="text-xs text-gray-500">{formatTimeAgo(post.created_at)}</span>
                  {getSentimentBadge(post)}
                </div>

                <p className="text-sm leading-relaxed mb-3 whitespace-pre-line">{post.content}</p>

                {renderPostContent(post, priceCacheRef.current)}

                {post.coin_tags && Array.isArray(post.coin_tags) && post.coin_tags.length > 0 && (
                  <FeedCoinTags tags={adjustCoinTags(post.coin_tags, priceCacheRef.current)} />
                )}

                <div className="flex items-center gap-6 text-sm text-gray-400 mt-3">
                  <button className="flex items-center gap-1.5 hover:text-white transition-colors">
                    <MessageCircle className="w-4 h-4" />
                    <span>{post.comments_count}</span>
                  </button>
                  <button className="flex items-center gap-1.5 hover:text-white transition-colors">
                    <Share2 className="w-4 h-4" />
                    <span>{post.shares_count}</span>
                  </button>
                  <button className="flex items-center gap-1.5 hover:text-[#F6465D] transition-colors">
                    <Heart className="w-4 h-4" />
                    <span>{post.likes_count}</span>
                  </button>
                  <button className="flex items-center gap-1.5 hover:text-white transition-colors">
                    <MessageSquare className="w-4 h-4" />
                    <span>{Math.floor(post.shares_count / 3)}</span>
                  </button>
                </div>
              </div>
            </div>
          </div>

          {(index + 1) % 5 === 0 && <CopyTradingCarousel />}
        </div>
      ))}

      {selectedRoom && (
        <LiveRoomModal
          isOpen={!!selectedRoom}
          onClose={() => setSelectedRoom(null)}
          roomId={selectedRoom}
        />
      )}
    </div>
  );
}

function adjustCoinTags(tags: CoinTag[], priceCache: PriceCache): CoinTag[] {
  return tags.map(tag => {
    const cached = priceCache.getBySymbol(tag.symbol);
    if (cached && cached.change24h !== undefined) {
      return { ...tag, change: Number(cached.change24h.toFixed(2)) };
    }
    return tag;
  });
}

function adjustPriceForPosition(
  coinSymbol: string,
  tradeType: string,
  leverage: number,
  roiPercent: number,
  priceCache: PriceCache
) {
  const cached = priceCache.getBySymbol(coinSymbol);
  if (!cached || cached.price <= 0 || leverage <= 1 || roiPercent === 0) return null;
  const realPrice = cached.price;
  const roi = Math.abs(roiPercent);
  const isLong = tradeType === 'long';
  const mark = realPrice;
  const entry = isLong
    ? mark / (1 + roi / 100 / leverage)
    : mark / (1 - roi / 100 / leverage);
  return { entry, mark };
}

function renderPostContent(post: SocialPost, priceCache: PriceCache) {
  switch (post.post_type) {
    case 'analysis':
      return null;

    case 'educational':
      return null;

    case 'personal':
      return null;

    case 'event':
      return <FeedEventCard content={post.content} />;

    case 'news':
      return <FeedNewsCard content={post.content} coinSymbol={post.coin_symbol} />;

    case 'multi_position':
      if (!post.sub_positions || post.sub_positions.length === 0) return null;
      const adjustedPositions = post.sub_positions.map((pos: any) => {
        const adj = adjustPriceForPosition(pos.coin, pos.type, pos.leverage || 10, pos.roi || 0, priceCache);
        if (!adj) return pos;
        return { ...pos, entry: adj.entry, mark: adj.mark, liq: pos.type === 'long' ? adj.entry * (1 - 0.9 / (pos.leverage || 10)) : adj.entry * (1 + 0.9 / (pos.leverage || 10)) };
      });
      return (
        <FeedMultiPosition
          positions={adjustedPositions}
          assetChange30d={post.asset_change_30d}
        />
      );

    case 'live_embed':
      return post.live_room_data ? (
        <FeedLiveEmbed data={post.live_room_data} />
      ) : null;

    default: {
      const adj = adjustPriceForPosition(post.coin_symbol, post.trade_type, post.leverage, post.profit_loss_percent, priceCache);
      const adjEntry = adj ? adj.entry : post.entry_price;
      const adjExit = adj ? adj.mark : post.exit_price;
      return (
        <>
          {post.profit_loss_percent !== 0 && post.leverage > 1 && (
            <FeedPositionCard
              coinSymbol={post.coin_symbol}
              tradeType={post.trade_type}
              leverage={post.leverage}
              profitLoss={post.profit_loss}
              profitLossPercent={post.profit_loss_percent}
              isBullish={post.is_bullish}
              entryPrice={adjEntry}
              exitPrice={adjExit}
            />
          )}
          {post.image_url && (
            <img
              src={post.image_url}
              alt=""
              className="w-full rounded-xl mb-3 max-h-[300px] object-cover"
            />
          )}
        </>
      );
    }
  }
}

function LiveRoomsScroller({ rooms, onRoomClick }: { rooms: LiveRoom[]; onRoomClick: (id: string) => void }) {
  return (
    <div className="bg-[#181A20] border-[#2B3139] py-3 overflow-hidden relative">
      <style>{`
        @keyframes scroll-left {
          0% { transform: translate3d(0, 0, 0); }
          100% { transform: translate3d(-50%, 0, 0); }
        }
        .animate-scroll {
          animation: scroll-left 120s linear infinite;
          backface-visibility: hidden;
          perspective: 1000px;
        }
      `}</style>

      <div className="flex gap-3 animate-scroll min-w-max" style={{ pointerEvents: 'none', willChange: 'transform' }}>
        {[...rooms, ...rooms].map((room, index) => (
          <button
            key={`${room.id}-${index}`}
            onClick={() => onRoomClick(room.id)}
            style={{ pointerEvents: 'auto' }}
            className={`
              flex-shrink-0 rounded-2xl px-4 py-3 flex items-center gap-3
              hover:scale-105 transition-all active:scale-95 shadow-lg relative
              ${room.is_vip
                ? `bg-gradient-to-br ${room.background_gradient} border-2 border-yellow-400/50 shadow-yellow-500/30`
                : `bg-gradient-to-br ${room.background_gradient} border border-purple-400/30 shadow-purple-500/20`
              }
            `}
          >
            {room.is_vip && (
              <div className="absolute -top-1.5 -right-1.5 bg-gradient-to-r from-yellow-400 to-amber-500 rounded-full p-1 shadow-lg border-[#1E2329]">
                <Crown className="w-3 h-3 text-black" />
              </div>
            )}

            <div className={`w-12 h-12 rounded-full flex items-center justify-center shadow-lg relative flex-shrink-0 ${
              room.is_vip ? 'bg-gradient-to-br from-yellow-400 via-amber-500 to-yellow-600' : 'bg-gradient-to-br from-[#F0B90B] to-[#F0B90B]'
            }`}>
              {room.is_vip ? (
                <>
                  <Sparkles className="w-6 h-6 text-black animate-pulse" />
                  <div className="absolute inset-0 rounded-full bg-yellow-300/30 animate-ping" />
                </>
              ) : (
                <Radio className="w-5 h-5 text-black" />
              )}
              <div className={`absolute -top-0.5 -right-0.5 w-3 h-3 rounded-full animate-pulse ${
                room.is_vip ? 'bg-gradient-to-r from-red-500 to-red-600 border-2 border-yellow-400' : 'bg-red-500 border-purple-800'
              }`} />
            </div>

            <div className="text-left">
              <div className="flex items-center gap-1.5 mb-1">
                <div className="font-bold text-sm line-clamp-1 max-w-[160px]">{room.title}</div>
                {room.is_vip && <Lock className="w-3 h-3 text-yellow-300" />}
              </div>
              <div className="flex items-center gap-2 text-[11px] mb-1">
                <span className={`px-2 py-0.5 rounded font-bold ${
                  room.is_vip ? 'bg-gradient-to-r from-red-500 to-red-600 text-white' : 'bg-red-500 text-white'
                }`}>LIVE</span>
                {room.is_vip && (
                  <span className="bg-gradient-to-r from-yellow-400 to-amber-500 text-black px-2 py-0.5 rounded font-bold">VIP</span>
                )}
                <div className={`flex items-center gap-1 ${room.is_vip ? 'text-yellow-200' : 'text-purple-200'}`}>
                  <Users className="w-3 h-3" />
                  <span className="font-semibold">{room.listener_count.toLocaleString()}</span>
                </div>
              </div>
              <div className={`text-[10px] font-medium line-clamp-1 max-w-[180px] ${
                room.is_vip ? 'text-yellow-300' : 'text-purple-300'
              }`}>
                {room.topic}
              </div>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}
