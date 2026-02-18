import React, { useState, useEffect } from 'react';
import { Trophy, Sparkles } from 'lucide-react';
import { supabase } from '../lib/supabase';

interface Winner {
  id: string;
  user_id: string;
  prize_name: string;
  prize_value: number;
  prize_type: string;
  claimed_at: string;
}

export default function WinnersLiveFeed() {
  const [winners, setWinners] = useState<Winner[]>([]);
  const [displayNames, setDisplayNames] = useState<Record<string, string>>({});

  useEffect(() => {
    loadRecentWinners();
    const interval = setInterval(loadRecentWinners, 30000);
    return () => clearInterval(interval);
  }, []);

  const loadRecentWinners = async () => {
    const { data, error } = await supabase
      .from('reward_wheel_history')
      .select('*')
      .eq('is_visible_in_feed', true)
      .order('claimed_at', { ascending: false })
      .limit(20);

    if (!error && data) {
      setWinners(data);
      loadUserNames(data.map(w => w.user_id));
    }
  };

  const loadUserNames = async (userIds: string[]) => {
    const uniqueIds = [...new Set(userIds)];
    const names: Record<string, string> = {};

    for (const userId of uniqueIds) {
      const { data } = await supabase
        .from('user_profiles')
        .select('display_name')
        .eq('user_id', userId)
        .maybeSingle();

      if (data) {
        names[userId] = data.display_name || 'Anonymous';
      } else {
        names[userId] = `User${userId.slice(0, 4)}`;
      }
    }

    setDisplayNames(names);
  };

  const getPrizeEmoji = (prizeType: string) => {
    switch (prizeType) {
      case 'futures_bonus': return '💰';
      case 'mining_boost': return '⚡';
      case 'eq_tokens': return '🪙';
      case 'mining_equipment': return '🖥️';
      case 'mega_jackpot': return '⭐';
      default: return '🎁';
    }
  };

  const duplicatedWinners = [...winners, ...winners];

  return (
    <div className="relative bg-gradient-to-r from-purple-900/20 via-pink-900/20 to-purple-900/20 border-y border-purple-500/30 py-3 overflow-hidden">

      <div className="absolute inset-0 bg-gradient-to-r from-transparent via-purple-500/5 to-transparent animate-shimmer" />

      <div className="flex items-center gap-3 px-4 mb-2">
        <div className="p-2 bg-gradient-to-br from-yellow-500/20 to-pink-500/20 rounded-lg">
          <Trophy className="w-5 h-5 text-yellow-400" />
        </div>
        <div>
          <h3 className="text-sm font-bold text-white flex items-center gap-2">
            <Sparkles className="w-4 h-4 text-yellow-400 animate-pulse" />
            Recent Winners
          </h3>
          <p className="text-xs text-gray-400">Live wheel results</p>
        </div>
      </div>

      <div className="relative overflow-hidden">
        <div className="animate-scroll-left flex gap-4 py-2">
          {duplicatedWinners.map((winner, index) => (
            <div
              key={`${winner.id}-${index}`}
              className="flex-shrink-0 bg-gradient-to-br from-slate-800/80 to-slate-900/80 border border-purple-500/30 rounded-lg px-4 py-2 flex items-center gap-3 min-w-[280px] hover:scale-105 transition-transform"
            >
              <div className="text-2xl">{getPrizeEmoji(winner.prize_type)}</div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-semibold text-white truncate">
                  {displayNames[winner.user_id] || 'Loading...'}
                </p>
                <p className="text-xs text-gray-400">won {winner.prize_name}</p>
              </div>
              <div className="text-xs text-gray-500">
                {new Date(winner.claimed_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
              </div>
            </div>
          ))}
        </div>
      </div>

      <style>{`
        @keyframes scroll-left {
          0% {
            transform: translateX(0);
          }
          100% {
            transform: translateX(-50%);
          }
        }

        .animate-scroll-left {
          animation: scroll-left 30s linear infinite;
        }

        .animate-scroll-left:hover {
          animation-play-state: paused;
        }

        @keyframes shimmer {
          0% {
            transform: translateX(-100%);
          }
          100% {
            transform: translateX(100%);
          }
        }

        .animate-shimmer {
          animation: shimmer 3s ease-in-out infinite;
        }
      `}</style>
    </div>
  );
}