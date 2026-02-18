import { useState, useEffect, useRef, useCallback } from 'react';
import { supabase } from '../lib/supabase';
import { ChevronDown, Menu, Gift, BarChart3, Calculator, MoreVertical, Plus, Minus, ChevronUp, Settings, Zap } from 'lucide-react';
import FuturesPositionCard from '../components/FuturesPositionCard';
import LeverageModal from '../components/LeverageModal';
import FuturesMarketSelector from '../components/FuturesMarketSelector';
import FuturesRecentTrades from '../components/FuturesRecentTrades';
import FuturesAdvancedOrders from '../components/FuturesAdvancedOrders';
import FuturesMarketStats from '../components/FuturesMarketStats';
import ClosePositionResultModal from '../components/ClosePositionResultModal';
import BottomNav from '../components/BottomNav';
import { EarnQuestPriceManager } from '../lib/earnquest-price';
import { fetchBinanceTicker } from '../lib/binance';
import { PriceCache } from '../lib/price-cache';
import { formatPrice as sharedFormatPrice, formatAmount as sharedFormatAmount, getPriceDecimals } from '../lib/format-utils';
import {
  calculateLiquidationPrice,
  calculateMargin,
  calculateTradingFee,
  getMaintenanceMarginRate,
  getFundingRate,
  isPositionLiquidated,
} from '../lib/futures-calculator';

async function fetchFreshPrice(symbol: string): Promise<number> {
  if (symbol === 'EQUSDT') {
    const pm = EarnQuestPriceManager.getInstance();
    const p = pm.getPrice();
    if (p > 0) return p;
    return 0;
  }

  const pc = PriceCache.getInstance();
  const cached = pc.get(symbol);
  if (cached && cached.price > 0 && Date.now() - cached.updatedAt < 15000) {
    return cached.price;
  }

  const ticker = await fetchBinanceTicker(symbol);
  if (ticker) {
    const lp = parseFloat(ticker.lastPrice);
    if (lp > 0) return lp;
  }

  if (cached && cached.price > 0) return cached.price;
  return 0;
}

interface Position {
  id: string;
  symbol: string;
  side: string;
  position_size: number;
  entry_price: number;
  leverage: number;
  margin_mode?: string;
  margin: number;
  liquidation_price: number;
  unrealized_pnl: number;
  mark_price?: number;
  status: string;
}

interface OrderBookEntry {
  price: number;
  amount: number;
}

interface Order {
  id: string;
  symbol: string;
  side: 'buy' | 'sell';
  type: string;
  price: number;
  amount: number;
  filled: number;
  status: string;
  created_at: string;
}

export default function FuturesPage() {
  const [selectedSymbol, setSelectedSymbol] = useState('BTCUSDT');
  const [selectedCoinLogo, setSelectedCoinLogo] = useState('https://cryptologos.cc/logos/bitcoin-btc-logo.png');
  const [currentPrice, setCurrentPrice] = useState(78023.0);
  const [priceChange, setPriceChange] = useState(-7.17);
  const [leverage, setLeverage] = useState(10);
  const [marginMode, setMarginMode] = useState<'cross' | 'isolated'>('cross');
  const [positionMode, setPositionMode] = useState<'one-way' | 'hedge'>('one-way');
  const [side, setSide] = useState<'buy' | 'sell'>('buy');
  const [orderType, setOrderType] = useState<'limit' | 'market' | 'stop-limit' | 'stop-market'>('limit');
  const [price, setPrice] = useState('78035.7');
  const [amount, setAmount] = useState('');
  const [stopPrice, setStopPrice] = useState('');
  const [takeProfitPrice, setTakeProfitPrice] = useState('');
  const [stopLossPrice, setStopLossPrice] = useState('');
  const [showMarketSelector, setShowMarketSelector] = useState(false);
  const [showLeverageModal, setShowLeverageModal] = useState(false);
  const [activeTab, setActiveTab] = useState<'usdm' | 'coinm' | 'options' | 'smartm'>('usdm');
  const [activeBottomTab, setActiveBottomTab] = useState<'positions' | 'orders' | 'bots'>('positions');
  const [tpslEnabled, setTpslEnabled] = useState(false);
  const [reduceOnly, setReduceOnly] = useState(false);
  const [postOnly, setPostOnly] = useState(false);
  const [timeInForce, setTimeInForce] = useState<'GTC' | 'IOC' | 'FOK'>('GTC');
  const [hideOtherPairs, setHideOtherPairs] = useState(false);
  const [showChart, setShowChart] = useState(false);
  const [markPrice, setMarkPrice] = useState(78023.0);
  const [lastPrice, setLastPrice] = useState(78023.0);
  const [showOrderTypeDropdown, setShowOrderTypeDropdown] = useState(false);
  const [showTimeInForceDropdown, setShowTimeInForceDropdown] = useState(false);
  const [showAdvancedOrders, setShowAdvancedOrders] = useState(false);
  const [showMarketStats, setShowMarketStats] = useState(false);

  const [userId, setUserId] = useState<string | null>(null);
  const [usdtBalance, setUsdtBalance] = useState(0);
  const [positions, setPositions] = useState<Position[]>([]);
  const [openOrders, setOpenOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(false);
  const positionsRef = useRef<Position[]>([]);

  const [asks, setAsks] = useState<OrderBookEntry[]>([]);
  const [bids, setBids] = useState<OrderBookEntry[]>([]);
  const [fundingRate, setFundingRate] = useState(0);
  const [fundingCountdown, setFundingCountdown] = useState('01:08:01');
  const [orderBookSize, setOrderBookSize] = useState(0.1);
  const [closeResult, setCloseResult] = useState<{
    success: boolean;
    symbol: string;
    side: string;
    entryPrice: number;
    closePrice: number;
    positionSize: number;
    sizePnl: number;
    fees: number;
    netPnl: number;
    pnlPercentage: number;
  } | null>(null);
  const [showCloseResult, setShowCloseResult] = useState(false);

  useEffect(() => {
    const initUser = async () => {
      const { data: { session } } = await supabase.auth.getSession();
      if (session?.user) {
        setUserId(session.user.id);
        loadUserBalance(session.user.id);
        loadPositions(session.user.id);
        loadOpenOrders(session.user.id);
      }
    };
    initUser();
  }, []);

  useEffect(() => {
    if (!userId) return;

    const positionsChannel = supabase
      .channel('futures_positions_changes')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'futures_positions',
          filter: `user_id=eq.${userId}`,
        },
        (payload) => {
          console.log('Position changed:', payload);
          if (payload.eventType === 'UPDATE' || payload.eventType === 'DELETE') {
            loadPositions(userId);
          } else if (payload.eventType === 'INSERT') {
            loadPositions(userId);
          }
        }
      )
      .subscribe();

    const balancesChannel = supabase
      .channel('user_balances_changes')
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'user_balances',
          filter: `user_id=eq.${userId}`,
        },
        () => {
          loadUserBalance(userId);
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(positionsChannel);
      supabase.removeChannel(balancesChannel);
    };
  }, [userId]);

  useEffect(() => {
    const priceCache = PriceCache.getInstance();
    if (!priceCache.isReady()) {
      priceCache.init();
    }
  }, []);

  useEffect(() => {
    setCurrentPrice(0);
    setMarkPrice(0);
    setLastPrice(0);
    setPrice('');

    const fetchCoinLogo = async () => {
      const coinSymbol = selectedSymbol.replace('USDT', '');
      const { data } = await supabase
        .from('supported_coins')
        .select('logo_url')
        .eq('symbol', coinSymbol)
        .maybeSingle();

      if (data?.logo_url) {
        const { getProxiedLogoUrl } = await import('../lib/logo-utils');
        setSelectedCoinLogo(getProxiedLogoUrl(data.logo_url));
      }
    };

    fetchCoinLogo();
    loadPriceData();

    if (selectedSymbol === 'EQUSDT') {
      const priceManager = EarnQuestPriceManager.getInstance();
      const unsubscribe = priceManager.subscribe(() => {
        loadPriceData();
      });
      return () => unsubscribe();
    } else {
      const priceInterval = setInterval(loadPriceData, 1200);
      return () => clearInterval(priceInterval);
    }
  }, [selectedSymbol]);

  useEffect(() => {
    const timer = setInterval(() => {
      const now = new Date();
      const seconds = now.getSeconds();
      const minutes = now.getMinutes();
      const hours = now.getHours();

      const nextFundingHour = Math.ceil(hours / 8) * 8;
      const hoursLeft = nextFundingHour - hours;
      const minutesLeft = 8 - (minutes % 8);
      const secondsLeft = 60 - seconds;

      setFundingCountdown(`${String(hoursLeft).padStart(2, '0')}:${String(minutesLeft).padStart(2, '0')}:${String(secondsLeft).padStart(2, '0')}`);
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  useEffect(() => {
    positionsRef.current = positions;
  }, [positions]);

  useEffect(() => {
    if (!userId) return;

    const updatePositionPrices = async () => {
      const currentPositions = positionsRef.current;
      if (currentPositions.length === 0) return;

      const eqPriceManager = EarnQuestPriceManager.getInstance();
      const pc = PriceCache.getInstance();

      const updatedPositions = currentPositions.map((position) => {
        if (position.status !== 'open') return position;

        let markPrice = 0;

        if (position.symbol === 'EQUSDT') {
          markPrice = eqPriceManager.getPrice();
        } else if (position.symbol === selectedSymbol) {
          markPrice = currentPrice;
        } else {
          const cached = pc.get(position.symbol);
          if (cached && cached.price > 0) {
            markPrice = cached.price;
          }
        }

        if (markPrice <= 0) {
          markPrice = position.mark_price || position.entry_price;
        }

        return { ...position, mark_price: markPrice };
      });

      setPositions(updatedPositions);
    };

    const checkLiquidations = async () => {
      const currentPositions = positionsRef.current;
      const eqPM = EarnQuestPriceManager.getInstance();
      const pc = PriceCache.getInstance();

      for (const position of currentPositions) {
        if (position.status !== 'open') continue;

        let mp = 0;
        if (position.symbol === 'EQUSDT') {
          mp = eqPM.getPrice();
        } else if (position.symbol === selectedSymbol) {
          mp = currentPrice;
        } else {
          const cached = pc.get(position.symbol);
          if (cached && cached.price > 0) mp = cached.price;
        }

        if (mp <= 0) mp = position.mark_price || 0;
        if (mp <= 0) continue;

        const positionSide = position.side === 'LONG' ? 'LONG' : 'SHORT';

        const correctLiqPrice = calculateLiquidationPrice(
          position.entry_price,
          position.leverage,
          positionSide,
          position.maintenance_margin_rate || 0.004,
          position.margin_mode || 'isolated',
          position.margin,
          0
        );

        if (Math.abs(correctLiqPrice - position.liquidation_price) > 1) {
          await supabase
            .from('futures_positions')
            .update({ liquidation_price: correctLiqPrice })
            .eq('id', position.id);

          position.liquidation_price = correctLiqPrice;
        }

        if (isPositionLiquidated(positionSide, mp, position.liquidation_price)) {
          await liquidatePosition(position, mp);
        }
      }
    };

    const priceInterval = setInterval(updatePositionPrices, 5000);
    const liqInterval = setInterval(checkLiquidations, 10000);

    return () => {
      clearInterval(priceInterval);
      clearInterval(liqInterval);
    };
  }, [userId, currentPrice, selectedSymbol]);

  const loadPriceData = async () => {
    try {
      let newPrice = currentPrice;

      if (selectedSymbol === 'EQUSDT') {
        const priceManager = EarnQuestPriceManager.getInstance();
        newPrice = priceManager.getPrice();

        if (newPrice > 0) {
          setCurrentPrice(newPrice);
          setPriceChange(priceManager.getChange());
          setMarkPrice(newPrice);
          setLastPrice(newPrice);
          setPrice(newPrice.toFixed(8));
        }
      } else {
        const pc = PriceCache.getInstance();
        const cached = pc.get(selectedSymbol);
        if (cached && cached.price > 0) {
          newPrice = cached.price;
          setCurrentPrice(cached.price);
          setPriceChange(cached.change24h);
          setPrice(cached.price.toFixed(getPriceDecimals(cached.price)));
          setMarkPrice(cached.price);
          setLastPrice(cached.price);
        } else {
          const ticker = await fetchBinanceTicker(selectedSymbol);
          if (!ticker) {
            return;
          }
          const lp = parseFloat(ticker.lastPrice);
          newPrice = lp;
          setCurrentPrice(lp);
          setPriceChange(parseFloat(ticker.priceChangePercent));
          setPrice(lp.toFixed(getPriceDecimals(lp)));
          setMarkPrice(lp);
          setLastPrice(lp);
        }
      }

      const newFundingRate = getFundingRate(selectedSymbol);
      setFundingRate(newFundingRate);

      generateOrderBook(newPrice);
    } catch (error) {
      console.error('Failed to load price:', error);
    }
  };

  const generateOrderBook = (price: number = currentPrice) => {
    const newAsks: OrderBookEntry[] = [];
    const newBids: OrderBookEntry[] = [];

    const increment = selectedSymbol === 'EQUSDT'
      ? price * 0.001
      : price * 0.00001;

    for (let i = 8; i >= 0; i--) {
      newAsks.push({
        price: price + (increment * (i + 1)),
        amount: Math.random() * 5 + 1
      });
    }

    for (let i = 0; i < 9; i++) {
      newBids.push({
        price: price - (increment * (i + 1)),
        amount: Math.random() * 5 + 1
      });
    }

    setAsks(newAsks);
    setBids(newBids);
  };

  const loadUserBalance = async (uid: string) => {
    try {
      const { data, error } = await supabase
        .from('user_balances')
        .select('futures_balance')
        .eq('user_id', uid)
        .eq('symbol', 'USDT')
        .maybeSingle();

      if (error) throw error;
      if (data) {
        setUsdtBalance(data.futures_balance || 0);
      }
    } catch (error) {
      console.error('Failed to load balance:', error);
    }
  };

  const loadPositions = async (uid: string) => {
    try {
      const { data, error } = await supabase
        .from('futures_positions')
        .select('*')
        .eq('user_id', uid)
        .eq('status', 'open')
        .order('created_at', { ascending: false });

      if (error) throw error;

      const positionsWithMode = (data || []).map(pos => ({
        ...pos,
        margin_mode: marginMode
      }));

      setPositions(positionsWithMode);
    } catch (error) {
      console.error('Failed to load positions:', error);
    }
  };

  const loadOpenOrders = async (uid: string) => {
    try {
      const { data, error } = await supabase
        .from('futures_orders')
        .select('*')
        .eq('user_id', uid)
        .in('status', ['pending', 'partial'])
        .order('created_at', { ascending: false });

      if (error) throw error;
      setOpenOrders(data || []);
    } catch (error) {
      console.error('Failed to load orders:', error);
    }
  };

  const liquidatePosition = async (position: Position, liquidationPrice: number) => {
    try {
      const verifiedPrice = await fetchFreshPrice(position.symbol);
      if (verifiedPrice > 0) {
        const positionSide = position.side === 'LONG' ? 'LONG' : 'SHORT';
        if (!isPositionLiquidated(positionSide, verifiedPrice, position.liquidation_price)) {
          return;
        }
      }

      const quantity = position.position_size / position.entry_price;
      const priceDiff = position.side === 'LONG'
        ? (liquidationPrice - position.entry_price)
        : (position.entry_price - liquidationPrice);

      const grossPnl = priceDiff * quantity;
      const closeFee = calculateTradingFee(position.position_size, false);
      const netPnl = grossPnl - closeFee;

      const maintenanceMarginRate = getMaintenanceMarginRate(position.position_size, position.symbol, position.leverage);

      const { error: historyError } = await supabase
        .from('futures_history')
        .insert({
          user_id: userId,
          symbol: position.symbol,
          side: position.side,
          leverage: position.leverage,
          entry_price: position.entry_price,
          close_price: liquidationPrice,
          position_size: position.position_size,
          margin: position.margin,
          liquidation_price: position.liquidation_price,
          maintenance_margin_rate: maintenanceMarginRate,
          realized_pnl: netPnl,
          trading_fee: closeFee,
          close_reason: 'liquidation',
          created_at: new Date().toISOString()
        });

      if (historyError) throw historyError;

      const { error: deleteError } = await supabase
        .from('futures_positions')
        .delete()
        .eq('id', position.id);

      if (deleteError) throw deleteError;

      const { data: freshBalance } = await supabase
        .from('user_balances')
        .select('futures_balance')
        .eq('user_id', userId)
        .eq('symbol', 'USDT')
        .maybeSingle();

      const currentFuturesBalance = freshBalance?.futures_balance || 0;
      const newBalance = Math.max(0, currentFuturesBalance);

      const { error: balanceError } = await supabase
        .from('user_balances')
        .update({ futures_balance: newBalance })
        .eq('user_id', userId)
        .eq('symbol', 'USDT');

      if (balanceError) throw balanceError;

      if (userId) {
        await loadUserBalance(userId);
        await loadPositions(userId);
      }

      const entryDisplay = position.entry_price < 1 ? position.entry_price.toFixed(8) : position.entry_price.toFixed(2);
      const liqDisplay = liquidationPrice < 1 ? liquidationPrice.toFixed(8) : liquidationPrice.toFixed(2);

      alert(`LIQUIDATION\n\nYour ${position.side} position on ${position.symbol} was liquidated!\n\nEntry: ${entryDisplay}\nLiq Price: ${liqDisplay}\nMargin Lost: ${position.margin.toFixed(2)} USDT`);
    } catch (error) {
      console.error('Failed to liquidate position:', error);
    }
  };

  const handlePlaceOrder = async () => {
    if (!userId || !amount) {
      alert('Please enter amount');
      return;
    }

    try {
      setLoading(true);
      const marginAmount = parseFloat(amount);

      if (marginAmount <= 0) {
        alert('Amount must be greater than 0');
        return;
      }

      if (marginAmount < 5) {
        alert('Minimum margin is 5 USDT');
        return;
      }

      const freshPrice = await fetchFreshPrice(selectedSymbol);
      if (!freshPrice || freshPrice <= 0) {
        alert('Cannot fetch current price. Please try again.');
        return;
      }

      let orderPrice: number;
      if (orderType === 'market') {
        orderPrice = freshPrice;
      } else {
        orderPrice = parseFloat(price);
        if (!orderPrice || orderPrice <= 0) {
          alert('Invalid price. Please enter a valid price.');
          return;
        }
        const ratio = orderPrice / freshPrice;
        if (ratio > 10 || ratio < 0.1) {
          alert(`Price ${orderPrice} seems incorrect for ${selectedSymbol}. Current market price is ${freshPrice}. Please check your price.`);
          return;
        }
      }

      if (usdtBalance <= 0) {
        alert('Insufficient balance. Please deposit funds first.');
        return;
      }

      const positionSize = marginAmount * leverage;
      const tradingFee = calculateTradingFee(positionSize, orderType === 'limit');
      const totalCost = marginAmount + tradingFee;

      if (totalCost > usdtBalance) {
        alert(`Insufficient balance. Required: ${totalCost.toFixed(2)} USDT, Available: ${usdtBalance.toFixed(2)} USDT`);
        return;
      }

      const positionSide = side === 'buy' ? 'LONG' : 'SHORT';
      const maintenanceMarginRate = getMaintenanceMarginRate(positionSize, selectedSymbol, leverage);
      const liquidationPrice = calculateLiquidationPrice(
        orderPrice,
        leverage,
        positionSide,
        maintenanceMarginRate,
        marginMode,
        marginAmount,
        usdtBalance
      );

      const { error: positionError } = await supabase
        .from('futures_positions')
        .insert({
          user_id: userId,
          symbol: selectedSymbol,
          side: positionSide,
          position_size: positionSize,
          entry_price: orderPrice,
          leverage: leverage,
          margin: marginAmount,
          liquidation_price: liquidationPrice,
          unrealized_pnl: 0,
          realized_pnl: 0,
          trading_fee: tradingFee,
          status: 'open',
          margin_mode: marginMode,
          maintenance_margin_rate: maintenanceMarginRate
        });

      if (positionError) throw positionError;

      const newBalance = Math.max(0, usdtBalance - totalCost);
      const { error: balanceError } = await supabase
        .from('user_balances')
        .update({ futures_balance: newBalance })
        .eq('user_id', userId)
        .eq('symbol', 'USDT');

      if (balanceError) throw balanceError;

      await loadUserBalance(userId);
      await loadPositions(userId);

      setAmount('');

      const liqPriceDisplay = liquidationPrice < 1 ? liquidationPrice.toFixed(8) : liquidationPrice.toFixed(2);
      const entryPriceDisplay = orderPrice < 1 ? orderPrice.toFixed(8) : orderPrice.toFixed(2);

      alert(`${positionSide} position opened!\nEntry Price: ${entryPriceDisplay} USDT\nMargin: ${marginAmount} USDT\nPosition Size: ${positionSize.toFixed(2)} USDT\nLeverage: ${leverage}x\nLiquidation Price: ${liqPriceDisplay} USDT`);
    } catch (error) {
      console.error('Failed to place order:', error);
      alert('Failed to place order: ' + (error as Error).message);
    } finally {
      setLoading(false);
    }
  };

  const handleClosePositionWithModal = async (
    positionId: string,
    closeType: 'market' | 'limit',
    limitPrice?: number,
    percentage: number = 100
  ) => {
    if (!userId) {
      alert('User not authenticated');
      return;
    }

    try {
      const position = positions.find(p => p.id === positionId);
      if (!position) {
        alert('Position not found');
        return;
      }

      let closePrice: number;
      if (closeType === 'market') {
        const freshPrice = await fetchFreshPrice(position.symbol);
        if (!freshPrice || freshPrice <= 0) {
          alert('Cannot fetch current price for ' + position.symbol + '. Please try again.');
          return;
        }
        closePrice = freshPrice;
      } else {
        closePrice = limitPrice || 0;
        if (closePrice <= 0) {
          alert('Invalid limit price');
          return;
        }
        const freshPrice = await fetchFreshPrice(position.symbol);
        if (freshPrice > 0) {
          const ratio = closePrice / freshPrice;
          if (ratio > 10 || ratio < 0.1) {
            alert(`Limit price ${closePrice} seems incorrect for ${position.symbol}. Current market price is ${freshPrice}.`);
            return;
          }
        }
      }

      const quantity = position.position_size / position.entry_price;
      const priceDiff = position.side === 'LONG'
        ? (closePrice - position.entry_price)
        : (position.entry_price - closePrice);

      const grossPnl = priceDiff * quantity * (percentage / 100);
      const closeFee = calculateTradingFee(position.position_size * (percentage / 100), false);
      const netPnl = grossPnl - closeFee;

      const maintenanceMarginRate = getMaintenanceMarginRate(position.position_size, position.symbol, position.leverage);

      const { error: historyError } = await supabase
        .from('futures_history')
        .insert({
          user_id: userId,
          symbol: position.symbol,
          side: position.side,
          leverage: position.leverage,
          entry_price: position.entry_price,
          close_price: closePrice,
          position_size: position.position_size * (percentage / 100),
          margin: position.margin * (percentage / 100),
          liquidation_price: position.liquidation_price,
          maintenance_margin_rate: maintenanceMarginRate,
          realized_pnl: netPnl,
          trading_fee: closeFee,
          close_reason: 'manual'
        });

      if (historyError) throw historyError;

      const { error: deleteError } = await supabase
        .from('futures_positions')
        .delete()
        .eq('id', positionId)
        .eq('user_id', userId);

      if (deleteError) throw deleteError;

      const returnAmount = position.margin * (percentage / 100) + netPnl;
      const newBalance = Math.max(0, usdtBalance + returnAmount);

      const { error: balanceError } = await supabase
        .from('user_balances')
        .update({ futures_balance: newBalance })
        .eq('user_id', userId)
        .eq('symbol', 'USDT');

      if (balanceError) throw balanceError;

      await loadUserBalance(userId);
      await loadPositions(userId);

      const pnlPercentage = (netPnl / (position.margin * (percentage / 100))) * 100;

      setCloseResult({
        success: true,
        symbol: position.symbol,
        side: position.side,
        entryPrice: position.entry_price,
        closePrice: closePrice,
        positionSize: position.position_size * (percentage / 100),
        sizePnl: grossPnl,
        fees: closeFee,
        netPnl: netPnl,
        pnlPercentage: pnlPercentage
      });
      setShowCloseResult(true);
    } catch (error: any) {
      console.error('Close position failed:', error);
      alert(`Failed to close position: ${error?.message || 'Unknown error'}`);

      setCloseResult({
        success: false,
        symbol: '',
        side: '',
        entryPrice: 0,
        closePrice: 0,
        positionSize: 0,
        sizePnl: 0,
        fees: 0,
        netPnl: 0,
        pnlPercentage: 0
      });
      setShowCloseResult(true);
    }
  };

  const handleClosePosition = async (positionId: string) => {
    handleClosePositionWithModal(positionId, 'market', undefined, 100);
  };

  const handleAdvancedOrder = async (orderData: any) => {
    if (!userId) return;
    try {
      setLoading(true);
      alert(`${orderData.type} order placed successfully! This will be triggered when conditions are met.`);
    } catch (error) {
      console.error('Failed to place advanced order:', error);
      alert('Failed to place advanced order');
    } finally {
      setLoading(false);
    }
  };

  const totalBidAmount = bids.reduce((sum, bid) => sum + bid.amount, 0);
  const totalAskAmount = asks.reduce((sum, ask) => sum + ask.amount, 0);
  const bidPercentage = totalBidAmount / (totalBidAmount + totalAskAmount) * 100;
  const askPercentage = 100 - bidPercentage;

  const formatPrice = sharedFormatPrice;
  const formatAmount = sharedFormatAmount;

  return (
    <div className="min-h-screen bg-[#181A20] text-white flex flex-col overflow-x-hidden">
      <div className="flex items-center justify-between px-3 py-2 bg-[#181A20] border-[#2B3139]">
        <div className="flex items-center gap-3 text-xs">
          <button
            onClick={() => setActiveTab('usdm')}
            className={`font-medium ${activeTab === 'usdm' ? 'text-white' : 'text-gray-500'}`}
          >
            USD⊙-M
          </button>
          <button
            onClick={() => setActiveTab('coinm')}
            className={`font-medium ${activeTab === 'coinm' ? 'text-white' : 'text-gray-500'}`}
          >
            COIN-M
          </button>
          <button
            onClick={() => setActiveTab('options')}
            className={`font-medium ${activeTab === 'options' ? 'text-white' : 'text-gray-500'}`}
          >
            Options
          </button>
          <button
            onClick={() => setActiveTab('smartm')}
            className={`font-medium ${activeTab === 'smartm' ? 'text-white' : 'text-gray-500'}`}
          >
            Smart M
          </button>
        </div>
        <button className="text-gray-400">
          <Menu className="w-5 h-5" />
        </button>
      </div>

      <div className="flex items-center justify-between px-3 py-2 bg-[#181A20]">
        <div>
          <button
            onClick={() => setShowMarketSelector(true)}
            className="flex items-center gap-1.5"
          >
            {selectedCoinLogo && (
              <img
                src={selectedCoinLogo}
                alt={selectedSymbol}
                className="w-5 h-5 rounded-full"
                onError={(e) => {
                  const target = e.target as HTMLImageElement;
                  target.style.display = 'none';
                }}
              />
            )}
            <span className="text-base font-bold">{selectedSymbol}</span>
            <span className="text-gray-500">Perp</span>
            <ChevronDown className="w-3.5 h-3.5 text-gray-400" />
          </button>
          <div className="flex items-center gap-3 mt-0.5">
            <div className={`text-sm font-bold ${priceChange >= 0 ? 'text-[#0ECB81]' : 'text-[#F6465D]'}`}>
              {priceChange >= 0 ? '+' : ''}{priceChange.toFixed(2)}%
            </div>
            <div className="text-gray-500 text-xs">
              Mark: <span className="text-white">{formatPrice(currentPrice)}</span>
            </div>
          </div>
        </div>
        <div className="flex items-center gap-3">
          <div className="relative">
            <Gift className="w-5 h-5 text-gray-400" />
            <div className="absolute -top-0.5 -right-0.5 w-2 h-2 bg-[#F0B90B] rounded-full"></div>
          </div>
          <BarChart3 className="w-5 h-5 text-gray-400" />
          <Calculator className="w-5 h-5 text-gray-400" />
          <div className="relative">
            <MoreVertical className="w-5 h-5 text-gray-400" />
            <div className="absolute -top-0.5 -right-0.5 w-2 h-2 bg-[#F0B90B] rounded-full"></div>
          </div>
        </div>
      </div>

      <div className="flex items-center justify-between px-3 py-1.5 bg-[#181A20]">
        <div className="flex items-center gap-1.5">
          <button
            onClick={() => setShowLeverageModal(true)}
            className="bg-[#2B3139] hover:bg-[#363D47] px-2 py-1 rounded-sm text-white text-[11px]"
          >
            {marginMode === 'cross' ? 'Cross' : 'Isolated'}
          </button>
          <button
            onClick={() => setShowLeverageModal(true)}
            className="bg-[#2B3139] hover:bg-[#363D47] px-2 py-1 rounded-sm text-white text-[11px]"
          >
            {leverage}x
          </button>
          <button className="bg-[#2B3139] hover:bg-[#363D47] px-2 py-1 rounded-sm text-white text-[11px]">
            S
          </button>
        </div>
        <div className="text-right">
          <div className="text-gray-500 text-[10px]">Funding (8h) / Countdown</div>
          <div className="text-white text-[11px]">
            {fundingRate >= 0 ? '+' : ''}{(fundingRate * 100).toFixed(4)}%/{fundingCountdown}
          </div>
        </div>
      </div>

      <div className="flex flex-1 overflow-hidden max-w-full">
        <div className="flex flex-col px-2 py-2 overflow-x-hidden w-[52%]">
          <div className="flex rounded-md overflow-hidden mb-2">
            <button
              onClick={() => setSide('buy')}
              className={`flex-1 py-2 text-xs font-medium transition-colors ${ side === 'buy' ? 'bg-[#0ECB81] text-white' : 'bg-[#2B3139] text-gray-400' }`}
            >
              Buy
            </button>
            <button
              onClick={() => setSide('sell')}
              className={`flex-1 py-2 text-xs font-medium transition-colors ${ side === 'sell' ? 'bg-[#F6465D] text-white' : 'bg-[#2B3139] text-gray-400' }`}
            >
              Sell
            </button>
          </div>

          <div className="mb-2 relative">
            <button
              onClick={() => setShowOrderTypeDropdown(!showOrderTypeDropdown)}
              className="w-full flex items-center justify-between bg-[#2B3139] rounded px-2 py-1.5 text-xs"
            >
              <div className="flex items-center gap-2">
                <span className="text-white capitalize">
                  {orderType === 'stop-limit' ? 'Stop-Limit' : orderType === 'stop-market' ? 'Stop-Market' : orderType.charAt(0).toUpperCase() + orderType.slice(1)}
                </span>
              </div>
              <ChevronDown className="w-3.5 h-3.5 text-gray-400" />
            </button>
            {showOrderTypeDropdown && (
              <div className="absolute top-full left-0 right-0 mt-1 bg-[#2B3139] rounded shadow-lg z-50 border border-[#2B3139]">
                {(['limit', 'market', 'stop-limit', 'stop-market'] as const).map((type) => (
                  <button
                    key={type}
                    onClick={() => {
                      setOrderType(type);
                      setShowOrderTypeDropdown(false);
                    }}
                    className="w-full px-3 py-2.5 text-left hover:bg-[#363D47] transition-colors flex items-center gap-2"
                  >
                    <div className="w-4 h-4 rounded-full border border-[#474D57] flex items-center justify-center">
                      {orderType === type && <div className="w-2 h-2 bg-[#F0B90B] rounded-full"></div>}
                    </div>
                    <span className="text-white capitalize">
                      {type === 'stop-limit' ? 'Stop-Limit' : type === 'stop-market' ? 'Stop-Market' : type.charAt(0).toUpperCase() + type.slice(1)}
                    </span>
                  </button>
                ))}
              </div>
            )}
          </div>

          {(orderType === 'stop-limit' || orderType === 'stop-market') && (
            <div className="mb-2">
              <div className="text-gray-500 mb-1 text-[10px]">Stop Price (USDT)</div>
              <div className="flex items-center bg-[#2B3139] rounded overflow-hidden">
                <button
                  onClick={() => {
                    const val = parseFloat(stopPrice || currentPrice.toString());
                    setStopPrice((val - 0.1).toFixed(1));
                  }}
                  className="flex-shrink-0 p-1.5 text-gray-400 hover:text-white"
                >
                  <Minus className="w-3 h-3" />
                </button>
                <input
                  type="text"
                  value={stopPrice}
                  onChange={(e) => setStopPrice(e.target.value)}
                  placeholder={formatPrice(currentPrice)}
                  className="flex-1 min-w-0 bg-transparent text-xs focus:outline-none placeholder:text-gray-600 truncate px-1"
                />
                <button
                  onClick={() => {
                    const val = parseFloat(stopPrice || currentPrice.toString());
                    const increment = selectedSymbol === 'EQUSDT' ? 0.001 : 0.1;
                    setStopPrice((val + increment).toFixed(getPriceDecimals(currentPrice)));
                  }}
                  className="flex-shrink-0 p-1.5 text-gray-400 hover:text-white"
                >
                  <Plus className="w-3 h-3" />
                </button>
                <button
                  onClick={() => setStopPrice(formatPrice(currentPrice))}
                  className="flex-shrink-0 px-2 py-1.5 text-[#F0B90B] border-[#2B3139] text-[11px]"
                >
                  Mark
                </button>
              </div>
            </div>
          )}

          {(orderType === 'limit' || orderType === 'stop-limit') && (
            <div className="mb-2">
              <div className="text-gray-500 mb-1 text-[10px]">Price (USDT)</div>
              <div className="flex items-center bg-[#2B3139] rounded overflow-hidden">
                <button
                  onClick={() => {
                    const increment = selectedSymbol === 'EQUSDT' ? 0.001 : 0.1;
                    setPrice((parseFloat(price) - increment).toFixed(getPriceDecimals(currentPrice)));
                  }}
                  className="flex-shrink-0 p-1.5 text-gray-400 hover:text-white"
                >
                  <Minus className="w-3 h-3" />
                </button>
                <input
                  type="text"
                  value={price}
                  onChange={(e) => setPrice(e.target.value)}
                  className="flex-1 min-w-0 bg-transparent text-xs focus:outline-none truncate px-1"
                />
                <button
                  onClick={() => {
                    const increment = selectedSymbol === 'EQUSDT' ? 0.001 : 0.1;
                    setPrice((parseFloat(price) + increment).toFixed(getPriceDecimals(currentPrice)));
                  }}
                  className="flex-shrink-0 p-1.5 text-gray-400 hover:text-white"
                >
                  <Plus className="w-3 h-3" />
                </button>
                <button className="flex-shrink-0 px-2 py-1.5 text-[#F0B90B] border-[#2B3139] text-[11px]">
                  BBO
                </button>
              </div>
            </div>
          )}

          <div className="mb-2">
            <div className="text-gray-500 mb-1 text-[10px]">Margin (USDT)</div>
            <div className="flex items-center bg-[#2B3139] rounded overflow-hidden">
              <button
                onClick={() => {
                  const val = parseFloat(amount || '0');
                  if (val > 0) setAmount((val - 10).toFixed(2));
                }}
                className="flex-shrink-0 p-1.5 text-gray-400 hover:text-white"
              >
                <Minus className="w-3 h-3" />
              </button>
              <input
                type="text"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                placeholder="Margin"
                className="flex-1 min-w-0 bg-transparent text-xs focus:outline-none placeholder:text-gray-600 truncate px-1"
              />
              <button
                onClick={() => {
                  const val = parseFloat(amount || '0');
                  setAmount((val + 10).toFixed(2));
                }}
                className="flex-shrink-0 p-1.5 text-gray-400 hover:text-white"
              >
                <Plus className="w-3 h-3" />
              </button>
              <button className="flex-shrink-0 px-2 py-1.5 text-white border-[#2B3139] flex items-center gap-1 text-[11px]">
                USDT
                <ChevronDown className="w-2.5 h-2.5" />
              </button>
            </div>
          </div>

          <div className="mb-2">
            <div className="flex gap-1.5">
              {[25, 50, 75, 100].map((percentage) => (
                <button
                  key={percentage}
                  onClick={() => {
                    const availBal = Math.max(0, usdtBalance);
                    const marginAmount = (availBal * percentage) / 100;
                    setAmount(marginAmount.toFixed(2));
                  }}
                  className="flex-1 py-1 bg-[#2B3139] text-gray-400 hover:text-white rounded transition-colors text-[10px]"
                >
                  {percentage}%
                </button>
              ))}
            </div>
          </div>

          <div className="mb-2">
            <label className="flex items-center gap-2 text-[10px] cursor-pointer mb-1">
              <input
                type="checkbox"
                checked={tpslEnabled}
                onChange={(e) => setTpslEnabled(e.target.checked)}
                className="w-3 h-3 rounded border-[#474D57] bg-[#2B3139]"
              />
              <span className="text-white">TP/SL</span>
            </label>
            {tpslEnabled && (
              <div className="space-y-1.5 pl-4">
                <div>
                  <div className="text-gray-500 mb-0.5 text-[10px]">Take Profit</div>
                  <input
                    type="text"
                    value={takeProfitPrice}
                    onChange={(e) => setTakeProfitPrice(e.target.value)}
                    placeholder="Price"
                    className="w-full bg-[#2B3139] rounded px-2 py-1 text-xs text-white focus:ring-[#F0B90B] placeholder:text-gray-600"
                  />
                </div>
                <div>
                  <div className="text-gray-500 mb-0.5 text-[10px]">Stop Loss</div>
                  <input
                    type="text"
                    value={stopLossPrice}
                    onChange={(e) => setStopLossPrice(e.target.value)}
                    placeholder="Price"
                    className="w-full bg-[#2B3139] rounded px-2 py-1 text-xs text-white focus:ring-[#F0B90B] placeholder:text-gray-600"
                  />
                </div>
              </div>
            )}
          </div>

          <div className="space-y-1.5 mb-2">
            <div className="flex items-center justify-between">
              <label className="flex items-center gap-2 text-[10px] cursor-pointer">
                <input
                  type="checkbox"
                  checked={reduceOnly}
                  onChange={(e) => setReduceOnly(e.target.checked)}
                  className="w-3 h-3 rounded border-[#474D57] bg-[#2B3139]"
                />
                <span className="text-white">Reduce Only</span>
              </label>
              <div className="relative">
                <button
                  onClick={() => setShowTimeInForceDropdown(!showTimeInForceDropdown)}
                  className="flex items-center gap-1 text-white bg-[#2B3139] px-3 py-1.5 rounded"
                >
                  {timeInForce}
                  <ChevronDown className="w-3 h-3 text-gray-400" />
                </button>
                {showTimeInForceDropdown && (
                  <div className="absolute top-full right-0 mt-1 bg-[#2B3139] rounded shadow-lg z-50 border border-[#2B3139] w-24">
                    {(['GTC', 'IOC', 'FOK'] as const).map((tif) => (
                      <button
                        key={tif}
                        onClick={() => {
                          setTimeInForce(tif);
                          setShowTimeInForceDropdown(false);
                        }}
                        className="w-full px-3 py-2 text-left hover:bg-[#363D47] transition-colors"
                      >
                        <span className={`${timeInForce === tif ? 'text-[#F0B90B]' : 'text-white'}`}>
                          {tif}
                        </span>
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>
            {orderType === 'limit' && (
              <label className="flex items-center gap-2 text-[10px] cursor-pointer">
                <input
                  type="checkbox"
                  checked={postOnly}
                  onChange={(e) => setPostOnly(e.target.checked)}
                  className="w-3 h-3 rounded border-[#474D57] bg-[#2B3139]"
                />
                <span className="text-white">Post Only</span>
              </label>
            )}
          </div>

          <div className="flex items-center justify-between text-[10px] mb-1">
            <span className="text-gray-500">Available</span>
            <span className="text-white">{Math.max(0, usdtBalance).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} USDT</span>
          </div>

          <div className="flex items-center justify-between text-[10px] mb-1">
            <span className="text-gray-500">Max Margin</span>
            <span className="text-white">{Math.max(0, usdtBalance).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} USDT</span>
          </div>

          {amount && parseFloat(amount) > 0 && (
            <>
              <div className="flex items-center justify-between text-[10px] mb-1">
                <span className="text-gray-500">Position Size</span>
                <span className="text-[#F0B90B]">{(parseFloat(amount) * leverage).toFixed(2)} USDT</span>
              </div>

              <div className="flex items-center justify-between text-[10px] mb-1">
                <span className="text-gray-500">Trading Fee</span>
                <span className="text-white">
                  {calculateTradingFee(parseFloat(amount) * leverage, orderType === 'limit').toFixed(2)} USDT
                </span>
              </div>

              <div className="flex items-center justify-between text-[10px] mb-2">
                <span className="text-gray-500">Total Cost</span>
                <span className="text-[#F6465D] font-semibold">
                  {(parseFloat(amount) + calculateTradingFee(parseFloat(amount) * leverage, orderType === 'limit')).toFixed(2)} USDT
                </span>
              </div>
            </>
          )}

          {(!amount || parseFloat(amount) <= 0) && (
            <div className="h-[40px] mb-2"></div>
          )}

          <button
            onClick={handlePlaceOrder}
            disabled={loading || !amount}
            className={`w-full py-2 rounded text-xs font-medium transition-colors ${ side === 'buy' ? 'bg-[#0ECB81] hover:bg-[#0ECB81]/90 text-white' : 'bg-[#F6465D] hover:bg-[#F6465D]/90 text-white' } disabled:opacity-50`}
          >
            {loading ? 'Processing...' : `${side === 'buy' ? 'Buy' : 'Sell'} / ${side === 'buy' ? 'Long' : 'Short'}`}
          </button>

          <button
            onClick={() => setShowAdvancedOrders(true)}
            className="w-full py-1.5 mt-1.5 rounded text-[10px] font-medium bg-[#2B3139] hover:bg-[#363D47] text-[#F0B90B] transition-colors flex items-center justify-center gap-1"
          >
            <Zap className="w-3 h-3" />
            Advanced Orders
          </button>
        </div>

        <div className="w-[48%] bg-[#181A20] flex flex-col overflow-hidden">
          <div className="text-gray-500 px-2 py-1.5 flex items-center justify-between border-[#2B3139] text-[10px]">
            <div className="flex items-center gap-3">
              <span>Price (USDT)</span>
              <span>Amount (USDT)</span>
            </div>
          </div>

          <div className="flex-1 overflow-x-hidden">
            <div className="space-y-0">
              {asks.map((ask, i) => {
                const maxAmt = Math.max(...asks.map(a => a.amount));
                const fillPct = maxAmt > 0 ? (ask.amount / maxAmt) * 100 : 0;
                return (
                  <div key={`ask-${i}`} className="ob-row-ask flex items-center justify-between px-2 py-[3px] text-[11px]" style={{ '--fill': `${fillPct}%` } as React.CSSProperties}>
                    <span className="text-[#F6465D] relative z-10 font-semibold">{formatPrice(ask.price)}</span>
                    <span className="text-gray-400 relative z-10">{formatAmount(ask.amount)}</span>
                  </div>
                );
              })}
            </div>

            <div className="py-2 px-2 bg-[#0B0E11] rounded">
              <div className="text-[#0ECB81] font-bold text-sm">
                {formatPrice(currentPrice)}
              </div>
              <div className="text-gray-500 text-[10px]">{formatPrice(currentPrice)}</div>
            </div>

            <div className="space-y-0">
              {bids.map((bid, i) => {
                const maxAmt = Math.max(...bids.map(b => b.amount));
                const fillPct = maxAmt > 0 ? (bid.amount / maxAmt) * 100 : 0;
                return (
                  <div key={`bid-${i}`} className="ob-row-bid flex items-center justify-between px-2 py-[3px] text-[11px]" style={{ '--fill': `${fillPct}%` } as React.CSSProperties}>
                    <span className="text-[#0ECB81] relative z-10 font-semibold">{formatPrice(bid.price)}</span>
                    <span className="text-gray-400 relative z-10">{formatAmount(bid.amount)}</span>
                  </div>
                );
              })}
            </div>
          </div>

          <div className="px-2 py-2 border-[#2B3139]">
            <div className="flex items-center gap-2 mb-2">
              <span className="text-[#0ECB81] font-medium text-[11px]">{bidPercentage.toFixed(2)}%</span>
              <div className="flex-1 flex h-1 rounded overflow-hidden">
                <div className="bg-[#0ECB81]" style={{ width: `${bidPercentage}%` }} />
                <div className="bg-[#F6465D]" style={{ width: `${askPercentage}%` }} />
              </div>
              <span className="text-[#F6465D] font-medium text-[11px]">{askPercentage.toFixed(2)}%</span>
            </div>
            <div className="flex items-center justify-between">
              <button className="flex items-center gap-1 text-gray-400">
                {orderBookSize}
                <ChevronDown className="w-3 h-3" />
              </button>
              <div className="flex items-center gap-2">
                <Settings className="w-3.5 h-3.5 text-gray-400" />
                <div className="flex flex-col gap-0.5">
                  <div className="flex gap-0.5">
                    <div className="w-1.5 h-1.5 bg-[#0ECB81]"></div>
                    <div className="w-1.5 h-1.5 bg-[#F6465D]"></div>
                  </div>
                  <div className="flex gap-0.5">
                    <div className="w-1.5 h-1.5 bg-[#0ECB81]"></div>
                    <div className="w-1.5 h-1.5 bg-[#F6465D]"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="bg-[#181A20] border-[#2B3139] overflow-hidden">
        <div className="flex items-center px-3 py-2 border-[#2B3139] overflow-x-auto">
          <div className="flex items-center gap-6 flex-1 min-w-max">
            <button
              onClick={() => setActiveBottomTab('positions')}
              className={`text-xs font-medium pb-1 border-b-2 transition-colors ${ activeBottomTab === 'positions' ? 'text-[#F0B90B] border-[#F0B90B]' : 'text-gray-400 border-transparent' }`}
            >
              Positions ({positions.length})
            </button>
            <button
              onClick={() => setActiveBottomTab('orders')}
              className={`text-xs font-medium pb-1 border-b-2 transition-colors ${ activeBottomTab === 'orders' ? 'text-[#F0B90B] border-[#F0B90B]' : 'text-gray-400 border-transparent' }`}
            >
              Open Orders ({openOrders.length})
            </button>
            <button
              onClick={() => setActiveBottomTab('bots')}
              className={`text-xs font-medium pb-1 border-b-2 transition-colors ${ activeBottomTab === 'bots' ? 'text-[#F0B90B] border-[#F0B90B]' : 'text-gray-400 border-transparent' }`}
            >
              Bots
            </button>
          </div>
          <button className="p-1">
            <svg width="16" height="16" viewBox="0 0 16 16" fill="none">
              <circle cx="8" cy="8" r="7" stroke="currentColor" strokeWidth="1.5"/>
              <path d="M8 5v6M5 8h6" stroke="currentColor" strokeWidth="1.5"/>
            </svg>
          </button>
        </div>

        <div className="px-3 py-2 flex items-center justify-between border-[#2B3139] overflow-hidden">
          <label className="flex items-center gap-2 text-xs cursor-pointer flex-shrink-0">
            <input
              type="checkbox"
              checked={hideOtherPairs}
              onChange={(e) => setHideOtherPairs(e.target.checked)}
              className="w-3.5 h-3.5 rounded border-[#474D57] bg-[#2B3139]"
            />
            <span className="text-gray-400 whitespace-nowrap">Hide Other Pairs</span>
          </label>
          <button className="text-gray-400 bg-[#2B3139] px-3 py-1.5 rounded-sm whitespace-nowrap flex-shrink-0">
            Close All Positions
          </button>
        </div>

        {activeBottomTab === 'positions' && (
          <div className="min-h-[200px] overflow-hidden">
            {positions.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-12">
                <div className="w-16 h-16 rounded-full border-[#2B3139] flex items-center justify-center mb-3">
                  <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <circle cx="12" cy="12" r="10"/>
                    <path d="M12 6v6l4 2"/>
                  </svg>
                </div>
              </div>
            ) : (
              <div className="p-3 pb-24 space-y-2 overflow-x-auto">
                {positions.map((position) => (
                  <FuturesPositionCard
                    key={position.id}
                    position={position}
                    currentPrice={currentPrice}
                    currentSymbol={selectedSymbol}
                    onClose={() => handleClosePosition(position.id)}
                    onClosePosition={handleClosePositionWithModal}
                    onUpdateLeverage={() => {}}
                    availableBalance={usdtBalance}
                    onMarginAdjusted={() => loadUserBalance(userId!)}
                  />
                ))}
              </div>
            )}
          </div>
        )}

        {activeBottomTab === 'orders' && (
          <div className="flex flex-col items-center justify-center py-12 pb-24 min-h-[200px]">
            <div className="text-xs">No open orders</div>
          </div>
        )}

        {activeBottomTab === 'bots' && (
          <div className="flex flex-col items-center justify-center py-12 pb-24 min-h-[200px]">
            <div className="text-xs">No bots</div>
          </div>
        )}

        <button
          onClick={() => setShowChart(!showChart)}
          className="w-full px-3 py-2.5 flex items-center justify-between border-[#2B3139] hover:bg-[#2B3139] transition-colors"
        >
          <span className="text-white">{selectedSymbol} Perp Chart</span>
          <ChevronUp className={`w-4 h-4 text-gray-400 transition-transform ${showChart ? '' : 'rotate-180'}`} />
        </button>
      </div>

      <BottomNav />

      {showMarketSelector && (
        <FuturesMarketSelector
          isOpen={showMarketSelector}
          onClose={() => setShowMarketSelector(false)}
          currentSymbol={selectedSymbol}
          onSelectSymbol={setSelectedSymbol}
        />
      )}

      {showLeverageModal && (
        <LeverageModal
          symbol={selectedSymbol}
          currentLeverage={leverage}
          currentMode={marginMode}
          positionMode={positionMode}
          onClose={() => setShowLeverageModal(false)}
          onUpdate={(lev, mode) => {
            setLeverage(lev);
            setMarginMode(mode);
          }}
          onPositionModeChange={setPositionMode}
        />
      )}

      {showAdvancedOrders && (
        <FuturesAdvancedOrders
          isOpen={showAdvancedOrders}
          onClose={() => setShowAdvancedOrders(false)}
          symbol={selectedSymbol}
          currentPrice={currentPrice}
          side={side}
          leverage={leverage}
          onPlaceOrder={handleAdvancedOrder}
        />
      )}

      <ClosePositionResultModal
        isOpen={showCloseResult}
        onClose={() => setShowCloseResult(false)}
        result={closeResult}
      />
    </div>
  );
}
