import { useState, useEffect, useCallback, useRef } from 'react';
import { X, ThumbsUp, ThumbsDown, Users, Activity, TrendingUp, BarChart3, Clock, ExternalLink, Award, MessageCircle, ArrowUpRight, ArrowDownRight, Globe, Send, Droplets, Crown, Share2, Star, Copy, CheckCircle, Zap, AlertTriangle } from 'lucide-react';
import type { AlphaToken, AlphaTransaction, AlphaComment, AlphaHolder, AlphaPricePoint } from '../../types/alpha';
import { fetchTokenTransactions, fetchTokenComments, fetchTokenHolders, fetchPriceHistory, generateBotTrade } from '../../lib/alpha-service';
import AlphaTokenChart from './AlphaTokenChart';
import AlphaTradingPanel from './AlphaTradingPanel';

const GRADIENT_COLORS = ['#F0B90B', '#0ECB81', '#3861FB', '#E8831D', '#627EEA', '#00D1FF', '#FF6B35'];

const NETWORK_COLORS: Record<string, string> = {
  BSC: '#F0B90B', Ethereum: '#627EEA', Solana: '#00D1FF', Base: '#0052FF',
};

const HOLDER_COLORS = ['#F0B90B', '#0ECB81', '#3861FB', '#E8831D', '#627EEA', '#00D1FF', '#F6465D', '#FF6B35', '#9B59B6', '#1ABC9C'];

function timeAgo(dateStr: string): string {
  const diff = Date.now() - new Date(dateStr).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1) return 'just now';
  if (mins < 60) return `${mins}m`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24) return `${hrs}h`;
  return `${Math.floor(hrs / 24)}d`;
}

function formatVal(val: number): string {
  if (val >= 1e6) return `$${(val / 1e6).toFixed(2)}M`;
  if (val >= 1e3) return `$${(val / 1e3).toFixed(1)}K`;
  return `$${val.toFixed(0)}`;
}

function formatNumber(val: number): string {
  if (val >= 1e9) return `${(val / 1e9).toFixed(2)}B`;
  if (val >= 1e6) return `${(val / 1e6).toFixed(2)}M`;
  if (val >= 1e3) return `${(val / 1e3).toFixed(1)}K`;
  return val.toFixed(0);
}

interface WhaleAlert {
  id: string;
  username: string;
  type: 'buy' | 'sell';
  amount: number;
  token: string;
  raisedToken: string;
}

interface Props {
  token: AlphaToken;
  isOpen: boolean;
  onClose: () => void;
}

export default function AlphaTokenDetail({ token, isOpen, onClose }: Props) {
  const [transactions, setTransactions] = useState<AlphaTransaction[]>([]);
  const [comments, setComments] = useState<AlphaComment[]>([]);
  const [holders, setHolders] = useState<AlphaHolder[]>([]);
  const [priceHistory, setPriceHistory] = useState<AlphaPricePoint[]>([]);
  const [activeTab, setActiveTab] = useState<'trades' | 'holders' | 'comments'>('trades');
  const [commentText, setCommentText] = useState('');
  const [copied, setCopied] = useState(false);
  const [showTradeSuccess, setShowTradeSuccess] = useState<{ type: string; amount: number } | null>(null);
  const [liveOnline] = useState(Math.floor(Math.random() * 200) + 50);
  const [whaleAlert, setWhaleAlert] = useState<WhaleAlert | null>(null);
  const [flashTxId, setFlashTxId] = useState<string | null>(null);
  const [entering, setEntering] = useState(true);
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isOpen) {
      setEntering(true);
      requestAnimationFrame(() => {
        requestAnimationFrame(() => setEntering(false));
      });
    }
  }, [isOpen]);

  const generateLocalPriceHistory = useCallback((basePrice: number): AlphaPricePoint[] => {
    const points: AlphaPricePoint[] = [];
    let price = basePrice * (0.5 + Math.random() * 0.5);
    const now = Date.now();
    for (let i = 72; i >= 0; i--) {
      const open = price;
      price = price * (0.92 + Math.random() * 0.18);
      if (price < basePrice * 0.1) price = basePrice * (0.1 + Math.random() * 0.3);
      const close = price;
      const high = Math.max(open, close) * (1 + Math.random() * 0.08);
      const low = Math.min(open, close) * (1 - Math.random() * 0.08);
      points.push({
        timestamp: new Date(now - i * 3600000).toISOString(),
        open_price: open, high_price: high, low_price: low, close_price: close,
        volume: 100 + Math.random() * 5000,
        price: close, market_cap: close * 1000000000,
      });
    }
    return points;
  }, []);

  const loadData = useCallback(async () => {
    if (!isOpen) return;
    const [txs, cmts, hlds, prices] = await Promise.all([
      fetchTokenTransactions(token.id).catch(() => []),
      fetchTokenComments(token.id).catch(() => []),
      fetchTokenHolders(token.id).catch(() => []),
      fetchPriceHistory(token.id).catch(() => []),
    ]);
    setTransactions(txs);
    setComments(cmts);
    setHolders(hlds);
    setPriceHistory(prices.length > 0 ? prices : generateLocalPriceHistory(token.current_price || 0.000001));
  }, [isOpen, token.id, token.current_price, generateLocalPriceHistory]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  useEffect(() => {
    if (!isOpen) return;
    const interval = setInterval(() => {
      const botTrade = generateBotTrade(token);
      setTransactions(prev => [botTrade, ...prev].slice(0, 60));
      setFlashTxId(botTrade.id);
      setTimeout(() => setFlashTxId(null), 1500);

      const isWhale = botTrade.total_value > (token.raised_token === 'SOL' ? 5 : token.raised_token === 'ETH' ? 0.3 : 1);
      if (isWhale && Math.random() > 0.6) {
        setWhaleAlert({
          id: botTrade.id,
          username: botTrade.username || 'Whale',
          type: botTrade.tx_type as 'buy' | 'sell',
          amount: botTrade.total_value,
          token: token.symbol,
          raisedToken: token.raised_token,
        });
        setTimeout(() => setWhaleAlert(null), 4000);
      }
    }, 4000 + Math.random() * 6000);
    return () => clearInterval(interval);
  }, [isOpen, token]);

  if (!isOpen) return null;

  const progress = Math.min((token.raised_amount / token.target_amount) * 100, 100);
  const idx = token.symbol.charCodeAt(0) % GRADIENT_COLORS.length;
  const netColor = NETWORK_COLORS[token.network] || '#666';
  const graduationMcap = token.target_amount * (token.raised_token === 'BNB' ? 600 : token.raised_token === 'ETH' ? 3500 : 150);
  const contractAddr = '0x' + token.id.replace(/-/g, '').slice(0, 40);

  const handleCopy = () => {
    navigator.clipboard.writeText(contractAddr);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleTrade = (type: 'buy' | 'sell', amount: number) => {
    setShowTradeSuccess({ type, amount });
    setTimeout(() => setShowTradeSuccess(null), 3000);

    const newTx: AlphaTransaction = {
      id: crypto.randomUUID(),
      token_id: token.id,
      user_id: null,
      tx_type: type,
      amount: Math.round(amount / Math.max(token.current_price, 0.000001)),
      price: token.current_price,
      total_value: amount,
      wallet_address: '0xYou...r',
      username: 'You',
      avatar_url: null,
      token_symbol: token.symbol,
      token_name: token.name,
      raised_token: token.raised_token,
      created_at: new Date().toISOString(),
    };
    setTransactions(prev => [newTx, ...prev]);
    setFlashTxId(newTx.id);
    setTimeout(() => setFlashTxId(null), 1500);
  };

  const totalHolderPct = holders.reduce((s, h) => s + h.percentage, 0);

  return (
    <div className={`fixed inset-0 z-50 bg-[#0B0E11] overflow-y-auto transition-all duration-300 ${entering ? 'opacity-0 translate-y-4' : 'opacity-100 translate-y-0'}`}>
      {whaleAlert && (
        <div className="fixed top-20 left-1/2 -translate-x-1/2 z-[70] whale-alert-enter">
          <div className={`px-5 py-3 rounded-2xl font-bold text-sm flex items-center gap-3 shadow-2xl border backdrop-blur-md ${
            whaleAlert.type === 'buy'
              ? 'bg-[#0ECB81]/20 border-[#0ECB81]/40 shadow-[#0ECB81]/20'
              : 'bg-[#F6465D]/20 border-[#F6465D]/40 shadow-[#F6465D]/20'
          }`}>
            <div className={`w-8 h-8 rounded-full flex items-center justify-center ${whaleAlert.type === 'buy' ? 'bg-[#0ECB81]/30' : 'bg-[#F6465D]/30'}`}>
              <AlertTriangle className={`w-4 h-4 ${whaleAlert.type === 'buy' ? 'text-[#0ECB81]' : 'text-[#F6465D]'}`} />
            </div>
            <div>
              <div className="text-white text-xs font-bold">Whale Alert!</div>
              <div className={`text-[11px] ${whaleAlert.type === 'buy' ? 'text-[#0ECB81]' : 'text-[#F6465D]'}`}>
                {whaleAlert.username} {whaleAlert.type === 'buy' ? 'bought' : 'sold'} {whaleAlert.amount} {whaleAlert.raisedToken} of ${whaleAlert.token}
              </div>
            </div>
            <Zap className="w-4 h-4 text-[#F0B90B] animate-pulse" />
          </div>
        </div>
      )}

      {showTradeSuccess && (
        <div className="fixed top-16 left-1/2 -translate-x-1/2 z-[60] trade-success-enter">
          <div className={`px-5 py-3 rounded-xl font-bold text-sm flex items-center gap-2 shadow-2xl ${
            showTradeSuccess.type === 'buy' ? 'bg-[#0ECB81] text-white' : 'bg-[#F6465D] text-white'
          }`}>
            {showTradeSuccess.type === 'buy' ? <ArrowUpRight className="w-4 h-4" /> : <ArrowDownRight className="w-4 h-4" />}
            {showTradeSuccess.type === 'buy' ? 'Bought' : 'Sold'} {showTradeSuccess.amount} {token.raised_token} of {token.symbol}
          </div>
        </div>
      )}

      <div className="sticky top-0 bg-[#0B0E11]/95 backdrop-blur-sm z-10 border-b border-[#2B3139]/50">
        <div className="px-4 py-2.5 flex items-center justify-between">
          <button onClick={onClose} className="p-1.5 hover:bg-[#2B3139] rounded-lg transition-colors">
            <X className="w-5 h-5 text-gray-400" />
          </button>
          <div className="flex items-center gap-2">
            {token.logo_url ? (
              <img src={token.logo_url} alt="" className="w-7 h-7 rounded-lg object-cover" />
            ) : (
              <div
                className="w-7 h-7 rounded-lg flex items-center justify-center"
                style={{ background: `linear-gradient(135deg, ${GRADIENT_COLORS[idx]}dd, ${GRADIENT_COLORS[(idx + 3) % GRADIENT_COLORS.length]}aa)` }}
              >
                <span className="text-white text-[9px] font-black">{token.symbol.slice(0, 2)}</span>
              </div>
            )}
            <div className="text-center">
              <span className="font-bold text-white text-sm block leading-tight">{token.name}</span>
              <span className="text-gray-500 text-[10px]">${token.symbol}</span>
            </div>
            {token.is_graduated && <Award className="w-4 h-4 text-[#0ECB81]" />}
          </div>
          <div className="flex items-center gap-1.5">
            <div className="flex items-center gap-1 px-2 py-1 rounded-full" style={{ backgroundColor: `${netColor}15` }}>
              <div className="w-1.5 h-1.5 rounded-full" style={{ backgroundColor: netColor }} />
              <span className="text-[10px] font-bold" style={{ color: netColor }}>{token.network}</span>
            </div>
            <button className="p-1.5 hover:bg-[#2B3139] rounded-lg transition-colors">
              <Share2 className="w-4 h-4 text-gray-500" />
            </button>
          </div>
        </div>

        <div className="px-4 pb-2 flex items-center gap-2">
          <div className="flex items-center gap-1 text-[10px] text-gray-500">
            <div className="w-1.5 h-1.5 rounded-full bg-[#0ECB81] animate-pulse" />
            {liveOnline} online
          </div>
          <div className="flex items-center gap-1 text-[10px]" onClick={handleCopy} role="button">
            <span className="text-gray-600 font-mono">{contractAddr.slice(0, 8)}...{contractAddr.slice(-6)}</span>
            {copied ? <CheckCircle className="w-3 h-3 text-[#0ECB81]" /> : <Copy className="w-3 h-3 text-gray-600" />}
          </div>
        </div>
      </div>

      <div ref={scrollRef} className="px-4 pt-3 pb-24">
        <div className="fade-in-up" style={{ animationDelay: '0.05s' }}>
          <AlphaTokenChart
            priceHistory={priceHistory}
            currentPrice={token.current_price}
            priceChange={token.price_change_24h || 0}
          />
        </div>

        <div className="grid grid-cols-4 gap-1.5 mt-3 fade-in-up" style={{ animationDelay: '0.1s' }}>
          {[
            { label: 'MCap', value: formatVal(token.market_cap), icon: TrendingUp, color: '#F0B90B' },
            { label: 'Volume', value: formatVal(token.volume_24h), icon: BarChart3, color: '#E8831D' },
            { label: 'Holders', value: formatNumber(token.holder_count), icon: Users, color: '#0ECB81' },
            { label: 'Liquidity', value: formatVal(token.liquidity || 0), icon: Droplets, color: '#3861FB' },
          ].map(s => (
            <div key={s.label} className="bg-[#181A20] rounded-xl p-2.5 border border-[#2B3139]/30 hover:border-[#2B3139] transition-colors">
              <div className="flex items-center gap-1 mb-1">
                <s.icon className="w-3 h-3" style={{ color: s.color }} />
                <span className="text-[9px] text-gray-500">{s.label}</span>
              </div>
              <span className="text-white font-bold text-xs block">{s.value}</span>
            </div>
          ))}
        </div>

        <div className="bg-[#181A20] rounded-xl p-3 border border-[#2B3139]/50 mt-3 fade-in-up" style={{ animationDelay: '0.15s' }}>
          <div className="flex items-center justify-between mb-2">
            <span className="text-xs text-gray-400 font-medium">Bonding Curve</span>
            <span className={`text-sm font-black ${token.is_graduated ? 'text-[#0ECB81]' : 'text-[#F0B90B]'}`}>
              {progress.toFixed(1)}%
            </span>
          </div>
          <div className="h-3 bg-[#2B3139] rounded-full overflow-hidden mb-2 relative">
            <div
              className={`h-full rounded-full transition-all duration-700 ${
                token.is_graduated
                  ? 'bg-gradient-to-r from-[#0ECB81] to-[#0ECB81]/80'
                  : progress > 80
                    ? 'bg-gradient-to-r from-[#F0B90B] to-[#F8D12F]'
                    : 'bg-gradient-to-r from-[#F0B90B]/60 to-[#F0B90B]'
              }`}
              style={{ width: `${progress}%` }}
            />
            {progress > 80 && !token.is_graduated && (
              <div className="absolute inset-0 overflow-hidden rounded-full">
                <div className="shimmer-bar" />
              </div>
            )}
          </div>
          <div className="flex justify-between text-[10px]">
            <span className="text-gray-500">{token.raised_amount.toFixed(2)} / {token.target_amount} {token.raised_token}</span>
            <span className="text-gray-500">Grad at {formatVal(graduationMcap)}</span>
          </div>
          {token.is_graduated && (
            <div className="mt-2 py-1.5 bg-[#0ECB81]/10 rounded-lg text-center">
              <span className="text-[#0ECB81] text-[11px] font-bold flex items-center justify-center gap-1">
                <Crown className="w-3.5 h-3.5" /> Graduated - Trading on Basonce Exchange
              </span>
            </div>
          )}
        </div>

        <div className="mt-3 fade-in-up" style={{ animationDelay: '0.2s' }}>
          <AlphaTradingPanel token={token} onTrade={handleTrade} />
        </div>

        <div className="bg-[#181A20] rounded-xl p-3.5 border border-[#2B3139]/50 mt-3 fade-in-up" style={{ animationDelay: '0.25s' }}>
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm font-bold text-white">Community</span>
            <span className={`text-lg font-black ${token.community_score >= 0 ? 'text-[#0ECB81]' : 'text-[#F6465D]'}`}>
              {token.community_score > 0 ? '+' : ''}{token.community_score}
            </span>
          </div>
          <div className="flex items-center gap-2">
            <button className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl bg-[#0ECB81]/10 border border-[#0ECB81]/20 active:scale-95 transition-transform hover:bg-[#0ECB81]/15">
              <ThumbsUp className="w-4 h-4 text-[#0ECB81]" />
              <span className="text-[#0ECB81] font-bold text-sm">{Math.max(0, token.community_score)}</span>
            </button>
            <button className="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl bg-[#F6465D]/10 border border-[#F6465D]/20 active:scale-95 transition-transform hover:bg-[#F6465D]/15">
              <ThumbsDown className="w-4 h-4 text-[#F6465D]" />
              <span className="text-[#F6465D] font-bold text-sm">{Math.max(0, -token.community_score + Math.floor(Math.random() * 20))}</span>
            </button>
            <button className="px-3 py-2.5 rounded-xl bg-[#F0B90B]/10 border border-[#F0B90B]/20 active:scale-95 transition-transform hover:bg-[#F0B90B]/15">
              <Star className="w-4 h-4 text-[#F0B90B]" />
            </button>
          </div>
        </div>

        <div className="bg-[#181A20] rounded-xl p-3.5 border border-[#2B3139]/50 mt-3 fade-in-up" style={{ animationDelay: '0.3s' }}>
          <span className="text-sm font-bold text-white block mb-2">About</span>
          <p className="text-gray-400 text-xs leading-relaxed mb-3">{token.description}</p>
          <div className="flex flex-wrap gap-1.5">
            {token.website_url && (
              <a href={token.website_url} className="flex items-center gap-1 px-2 py-1 rounded-lg bg-[#2B3139] text-gray-400 text-[11px] hover:text-white transition-colors">
                <Globe className="w-3 h-3" /> Website <ExternalLink className="w-2.5 h-2.5" />
              </a>
            )}
            {token.twitter_url && (
              <a href={token.twitter_url} className="flex items-center gap-1 px-2 py-1 rounded-lg bg-[#2B3139] text-gray-400 text-[11px] hover:text-white transition-colors">
                Twitter <ExternalLink className="w-2.5 h-2.5" />
              </a>
            )}
            {token.telegram_url && (
              <a href={token.telegram_url} className="flex items-center gap-1 px-2 py-1 rounded-lg bg-[#2B3139] text-gray-400 text-[11px] hover:text-white transition-colors">
                Telegram <ExternalLink className="w-2.5 h-2.5" />
              </a>
            )}
          </div>
        </div>

        <div className="bg-[#181A20] rounded-xl border border-[#2B3139]/50 mt-3 overflow-hidden fade-in-up" style={{ animationDelay: '0.35s' }}>
          <div className="flex border-b border-[#2B3139]/50">
            {[
              { id: 'trades' as const, label: 'Trades', icon: Activity, count: transactions.length },
              { id: 'holders' as const, label: 'Holders', icon: Users, count: holders.length },
              { id: 'comments' as const, label: 'Chat', icon: MessageCircle, count: comments.length },
            ].map(tab => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex-1 py-2.5 text-center text-[11px] font-bold transition-colors flex items-center justify-center gap-1 relative ${
                  activeTab === tab.id ? 'text-[#F0B90B]' : 'text-gray-500'
                }`}
              >
                <tab.icon className="w-3.5 h-3.5" />
                {tab.label}
                <span className={`text-[9px] px-1 py-0.5 rounded ${activeTab === tab.id ? 'bg-[#F0B90B]/15' : 'bg-[#2B3139]'}`}>
                  {tab.count}
                </span>
                {activeTab === tab.id && (
                  <div className="absolute bottom-0 left-2 right-2 h-0.5 bg-[#F0B90B] rounded-full" />
                )}
              </button>
            ))}
          </div>

          {activeTab === 'trades' && (
            <div className="max-h-80 overflow-y-auto">
              <div className="grid grid-cols-[auto_1fr_auto_auto] gap-x-2 px-3 py-2 border-b border-[#2B3139]/50 text-[9px] text-gray-600 font-bold uppercase">
                <span>Type</span>
                <span>Account</span>
                <span className="text-right">Amount</span>
                <span className="text-right">Time</span>
              </div>
              {transactions.length === 0 && (
                <div className="py-10 text-center text-gray-600 text-xs">No trades yet</div>
              )}
              {transactions.map(tx => (
                <div
                  key={tx.id}
                  className={`grid grid-cols-[auto_1fr_auto_auto] gap-x-2 px-3 py-2 border-b border-[#2B3139]/20 last:border-0 items-center transition-all duration-500
                    ${flashTxId === tx.id ? (tx.tx_type === 'buy' ? 'bg-[#0ECB81]/10' : 'bg-[#F6465D]/10') : 'bg-transparent'}`}
                >
                  <div className={`w-5 h-5 rounded-full flex items-center justify-center flex-shrink-0 ${tx.tx_type === 'buy' ? 'bg-[#0ECB81]/15' : 'bg-[#F6465D]/15'}`}>
                    {tx.tx_type === 'buy'
                      ? <ArrowUpRight className="w-3 h-3 text-[#0ECB81]" />
                      : <ArrowDownRight className="w-3 h-3 text-[#F6465D]" />
                    }
                  </div>
                  <div className="min-w-0">
                    <span className="text-white text-[11px] font-medium truncate block">{tx.username || 'Anonymous'}</span>
                    <span className="text-gray-600 text-[9px] font-mono block truncate">{tx.wallet_address}</span>
                  </div>
                  <div className="text-right">
                    <span className={`text-[11px] font-bold block ${tx.tx_type === 'buy' ? 'text-[#0ECB81]' : 'text-[#F6465D]'}`}>
                      {tx.tx_type === 'buy' ? '+' : '-'}{tx.total_value} {tx.raised_token}
                    </span>
                  </div>
                  <span className="text-gray-600 text-[9px] text-right whitespace-nowrap">{timeAgo(tx.created_at)}</span>
                </div>
              ))}
            </div>
          )}

          {activeTab === 'holders' && (
            <div>
              <div className="p-3 border-b border-[#2B3139]/50">
                <div className="h-4 rounded-full overflow-hidden flex">
                  {holders.map((h, i) => (
                    <div
                      key={h.id}
                      className="h-full transition-all duration-500"
                      style={{
                        width: `${h.percentage}%`,
                        backgroundColor: HOLDER_COLORS[i % HOLDER_COLORS.length],
                        minWidth: h.percentage > 0.5 ? '4px' : '2px',
                      }}
                    />
                  ))}
                  {totalHolderPct < 100 && (
                    <div className="h-full bg-[#2B3139]" style={{ width: `${100 - totalHolderPct}%` }} />
                  )}
                </div>
                <div className="flex items-center gap-2 mt-2 flex-wrap">
                  {holders.slice(0, 5).map((h, i) => (
                    <div key={h.id} className="flex items-center gap-1">
                      <div className="w-2 h-2 rounded-full" style={{ backgroundColor: HOLDER_COLORS[i] }} />
                      <span className="text-[9px] text-gray-500">{h.username} ({h.percentage.toFixed(1)}%)</span>
                    </div>
                  ))}
                </div>
              </div>
              <div className="max-h-64 overflow-y-auto">
                {holders.map((h, i) => (
                  <div key={h.id} className="flex items-center gap-2 px-3 py-2.5 border-b border-[#2B3139]/20 last:border-0">
                    <span className="text-[10px] text-gray-600 font-bold w-4">#{i + 1}</span>
                    <div className="w-2 h-2 rounded-full flex-shrink-0" style={{ backgroundColor: HOLDER_COLORS[i % HOLDER_COLORS.length] }} />
                    {h.avatar_url ? (
                      <img src={h.avatar_url} alt="" className="w-5 h-5 rounded-full object-cover" />
                    ) : (
                      <div className="w-5 h-5 rounded-full bg-[#2B3139] flex items-center justify-center">
                        <span className="text-[7px] text-gray-400 font-bold">{h.username.slice(0, 2)}</span>
                      </div>
                    )}
                    <div className="flex-1 min-w-0">
                      <span className="text-white text-[11px] font-medium truncate block">{h.username}</span>
                    </div>
                    <div className="text-right">
                      <span className="text-white text-[11px] font-bold block">{formatNumber(h.amount)}</span>
                      <span className="text-gray-500 text-[9px]">{h.percentage.toFixed(1)}%</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {activeTab === 'comments' && (
            <div>
              <div className="flex items-center gap-2 px-3 py-2.5 border-b border-[#2B3139]/50">
                <input
                  type="text"
                  value={commentText}
                  onChange={e => setCommentText(e.target.value)}
                  placeholder="Write a comment..."
                  className="flex-1 bg-[#0B0E11] rounded-lg px-3 py-2 text-xs text-white placeholder-gray-600 outline-none focus:ring-1 focus:ring-[#F0B90B]/50 border border-[#2B3139]"
                />
                <button className="p-2 bg-[#F0B90B] rounded-lg active:scale-95 transition-transform">
                  <Send className="w-3.5 h-3.5 text-[#0B0E11]" />
                </button>
              </div>
              <div className="max-h-80 overflow-y-auto">
                {comments.length === 0 && (
                  <div className="py-10 text-center text-gray-600 text-xs">Be the first to comment!</div>
                )}
                {comments.map(cmt => (
                  <div key={cmt.id} className="px-3 py-2.5 border-b border-[#2B3139]/20 last:border-0">
                    <div className="flex items-center gap-2 mb-1">
                      {cmt.avatar_url ? (
                        <img src={cmt.avatar_url} alt="" className="w-5 h-5 rounded-full object-cover" />
                      ) : (
                        <div className="w-5 h-5 rounded-full bg-[#2B3139] flex items-center justify-center">
                          <span className="text-[8px] text-gray-400 font-bold">{cmt.username.slice(0, 1)}</span>
                        </div>
                      )}
                      <span className="text-white text-[11px] font-medium">{cmt.username}</span>
                      <span className="text-gray-600 text-[9px] flex items-center gap-0.5">
                        <Clock className="w-2.5 h-2.5" /> {timeAgo(cmt.created_at)}
                      </span>
                    </div>
                    <p className="text-gray-300 text-xs leading-relaxed pl-7">{cmt.content}</p>
                    <div className="flex items-center gap-1 pl-7 mt-1">
                      <ThumbsUp className="w-3 h-3 text-gray-600 cursor-pointer hover:text-[#0ECB81] transition-colors" />
                      <span className="text-gray-600 text-[10px]">{cmt.likes}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        <div className="bg-[#181A20] rounded-xl p-3 border border-[#2B3139]/50 mt-3 fade-in-up" style={{ animationDelay: '0.4s' }}>
          <span className="text-xs font-bold text-white block mb-2">Token Info</span>
          <div className="space-y-1.5">
            {[
              { l: 'Total Supply', v: formatNumber(token.total_supply || 1000000000) },
              { l: 'Circulating', v: formatNumber(token.circulating_supply || 0) },
              { l: 'Initial Price', v: `$${(token.initial_price || 0).toFixed(8)}` },
              { l: 'ATH Price', v: `$${(token.ath_price || 0) < 0.01 ? (token.ath_price || 0).toFixed(8) : (token.ath_price || 0).toFixed(4)}` },
              { l: 'Transactions', v: token.transaction_count.toLocaleString() },
              { l: 'Created', v: new Date(token.created_at).toLocaleDateString() },
            ].map(info => (
              <div key={info.l} className="flex items-center justify-between py-1">
                <span className="text-gray-500 text-[11px]">{info.l}</span>
                <span className="text-white text-[11px] font-bold">{info.v}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      <style>{`
        .fade-in-up {
          animation: fadeInUp 0.4s ease-out both;
        }
        @keyframes fadeInUp {
          from { opacity: 0; transform: translateY(12px); }
          to { opacity: 1; transform: translateY(0); }
        }
        .whale-alert-enter {
          animation: whaleAlertIn 0.4s cubic-bezier(0.34, 1.56, 0.64, 1) both;
        }
        @keyframes whaleAlertIn {
          from { opacity: 0; transform: translate(-50%, -20px) scale(0.9); }
          to { opacity: 1; transform: translate(-50%, 0) scale(1); }
        }
        .trade-success-enter {
          animation: tradeSuccessIn 0.3s cubic-bezier(0.34, 1.56, 0.64, 1) both;
        }
        @keyframes tradeSuccessIn {
          from { opacity: 0; transform: translate(-50%, -10px) scale(0.95); }
          to { opacity: 1; transform: translate(-50%, 0) scale(1); }
        }
        .shimmer-bar {
          position: absolute;
          top: 0;
          left: -100%;
          width: 100%;
          height: 100%;
          background: linear-gradient(90deg, transparent, rgba(255,255,255,0.15), transparent);
          animation: shimmer 2s infinite;
        }
        @keyframes shimmer {
          100% { left: 100%; }
        }
      `}</style>
    </div>
  );
}
