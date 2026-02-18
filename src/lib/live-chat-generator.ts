import {
  COIN_MESSAGES,
  MARKET_BULLISH,
  MARKET_BEARISH,
  MARKET_GENERAL,
  TECHNICAL_ANALYSIS,
  EXCITED_REACTIONS,
  TRADING_WISDOM,
  NEWS_COMMENTS,
  USERNAMES,
} from './live-chat-messages';

export interface ChatMessage {
  id: string;
  username: string;
  avatar: string;
  message: string;
  timestamp: number;
}

export interface ParticipantSlot {
  id: string;
  username: string;
  avatar: string;
}

const recentMessages = new Set<string>();
const MAX_RECENT = 400;

let avatarCounter = 1;

function getNextAvatar(): string {
  const id = avatarCounter;
  avatarCounter = (avatarCounter % 70) + 1;
  return `https://i.pravatar.cc/80?img=${id}`;
}

function getRandomUsername(): string {
  return USERNAMES[Math.floor(Math.random() * USERNAMES.length)];
}

function pickUniqueRandom(arr: string[]): string {
  const available = arr.filter(m => !recentMessages.has(m));
  const pool = available.length > 0 ? available : arr;
  const msg = pool[Math.floor(Math.random() * pool.length)];

  recentMessages.add(msg);
  if (recentMessages.size > MAX_RECENT) {
    const first = recentMessages.values().next().value;
    if (first) recentMessages.delete(first);
  }

  return msg;
}

function getCoinMessages(symbol: string): string[] {
  return COIN_MESSAGES[symbol] || COIN_MESSAGES.BTC;
}

function pickMessage(coinSymbol: string): string {
  const coinMsgs = getCoinMessages(coinSymbol);
  const roll = Math.random();

  if (roll < 0.25) {
    return pickUniqueRandom(coinMsgs);
  } else if (roll < 0.38) {
    return pickUniqueRandom(MARKET_BULLISH);
  } else if (roll < 0.48) {
    return pickUniqueRandom(MARKET_BEARISH);
  } else if (roll < 0.63) {
    return pickUniqueRandom(MARKET_GENERAL);
  } else if (roll < 0.76) {
    return pickUniqueRandom(TECHNICAL_ANALYSIS);
  } else if (roll < 0.85) {
    return pickUniqueRandom(TRADING_WISDOM);
  } else if (roll < 0.93) {
    return pickUniqueRandom(NEWS_COMMENTS);
  } else {
    return pickUniqueRandom(EXCITED_REACTIONS);
  }
}

export function generateInitialMessages(coinSymbol: string, count: number = 15): ChatMessage[] {
  const msgs: ChatMessage[] = [];
  const now = Date.now();

  for (let i = 0; i < count; i++) {
    msgs.push({
      id: `init-${i}-${Math.random()}`,
      username: getRandomUsername(),
      avatar: getNextAvatar(),
      message: pickMessage(coinSymbol),
      timestamp: now - (count - i) * 8000,
    });
  }

  return msgs;
}

export function generateNewMessage(coinSymbol: string): ChatMessage {
  return {
    id: `msg-${Date.now()}-${Math.random()}`,
    username: getRandomUsername(),
    avatar: getNextAvatar(),
    message: pickMessage(coinSymbol),
    timestamp: Date.now(),
  };
}

export function generateParticipantSlots(count: number = 5): ParticipantSlot[] {
  const slots: ParticipantSlot[] = [];
  for (let i = 0; i < count; i++) {
    const avatarId = Math.floor(Math.random() * 70) + 1;
    slots.push({
      id: `slot-${i}-${Math.random()}`,
      username: getRandomUsername(),
      avatar: `https://i.pravatar.cc/80?img=${avatarId}`,
    });
  }
  return slots;
}
