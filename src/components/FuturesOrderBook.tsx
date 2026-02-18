import { useEffect, useState } from 'react';
import { fetchBinanceDepth } from '../lib/binance';

interface OrderBookEntry {
  price: number;
  amount: number;
  total: number;
}

interface FuturesOrderBookProps {
  symbol: string;
  currentPrice: number;
}

export default function FuturesOrderBook({ symbol, currentPrice }: FuturesOrderBookProps) {
  const [asks, setAsks] = useState<OrderBookEntry[]>([]);
  const [bids, setBids] = useState<OrderBookEntry[]>([]);

  const getPriceDecimals = (price: number): number => {
    if (price >= 100) return 2;
    if (price >= 10) return 3;
    if (price >= 1) return 4;
    if (price >= 0.1) return 5;
    return 6;
  };

  const formatAmount = (amount: number): string => {
    if (amount >= 1000) return `${(amount / 1000).toFixed(2)}K`;
    if (amount >= 100) return amount.toFixed(1);
    if (amount >= 10) return amount.toFixed(2);
    if (amount >= 1) return amount.toFixed(3);
    if (amount >= 0.01) return amount.toFixed(3);
    if (amount >= 0.001) return amount.toFixed(4);
    return amount.toFixed(5);
  };

  useEffect(() => {
    const updateOrderBook = async () => {
      if (symbol === 'EQUSDT') {
        const newAsks: OrderBookEntry[] = [];
        const newBids: OrderBookEntry[] = [];

        const increment = 0.001;

        for (let i = 0; i < 9; i++) {
          const askPrice = currentPrice + (i + 1) * (currentPrice * increment);
          const bidPrice = currentPrice - (i + 1) * (currentPrice * increment);
          const askAmount = Math.random() * 100 + 10;
          const bidAmount = Math.random() * 100 + 10;

          newAsks.unshift({
            price: askPrice,
            amount: askAmount,
            total: askAmount * askPrice
          });

          newBids.push({
            price: bidPrice,
            amount: bidAmount,
            total: bidAmount * bidPrice
          });
        }

        setAsks(newAsks);
        setBids(newBids);
      } else {
        try {
          const depth = await fetchBinanceDepth(symbol, 100);
          if (depth) {
            const minTotalValue = currentPrice > 10000 ? 50 : 5;

            let filteredBids = depth.bids
              .map(([price, amount]) => ({
                price: parseFloat(price),
                amount: parseFloat(amount),
                total: parseFloat(price) * parseFloat(amount)
              }))
              .filter(order => order.total >= minTotalValue);

            let filteredAsks = depth.asks
              .map(([price, amount]) => ({
                price: parseFloat(price),
                amount: parseFloat(amount),
                total: parseFloat(price) * parseFloat(amount)
              }))
              .filter(order => order.total >= minTotalValue);

            if (filteredBids.length < 9) {
              filteredBids = depth.bids.slice(0, 15).map(([price, amount]) => ({
                price: parseFloat(price),
                amount: parseFloat(amount),
                total: parseFloat(price) * parseFloat(amount)
              }));
            }

            if (filteredAsks.length < 9) {
              filteredAsks = depth.asks.slice(0, 15).map(([price, amount]) => ({
                price: parseFloat(price),
                amount: parseFloat(amount),
                total: parseFloat(price) * parseFloat(amount)
              }));
            }

            setBids(filteredBids.slice(0, 9));
            setAsks(filteredAsks.slice(0, 9));
          }
        } catch (error) {
          console.error('Error fetching order book:', error);
        }
      }
    };

    updateOrderBook();
    const interval = setInterval(updateOrderBook, 1500);

    return () => clearInterval(interval);
  }, [currentPrice, symbol]);

  const maxTotal = Math.max(
    ...asks.map(a => a.total),
    ...bids.map(b => b.total)
  );

  const totalBidsValue = bids.reduce((sum, bid) => sum + bid.total, 0);
  const totalAsksValue = asks.reduce((sum, ask) => sum + ask.total, 0);
  const totalValue = totalBidsValue + totalAsksValue;
  const bidPercentage = totalValue > 0 ? (totalBidsValue / totalValue) * 100 : 50;
  const askPercentage = 100 - bidPercentage;

  return (
    <div className="flex-1 overflow-hidden">
      <div className="space-y-[1px]">
        {asks.map((ask, index) => (
          <div key={`ask-${index}`} className="relative h-[16px] flex items-center justify-between text-[10px] px-1">
            <div
              className="absolute right-0 top-0 bottom-0 bg-[#F6465D]/10"
              style={{ width: `${(ask.total / maxTotal) * 100}%` }}
            />
            <span className="relative text-[#F6465D] font-medium">
              {ask.price.toFixed(getPriceDecimals(currentPrice))}
            </span>
            <span className="relative text-gray-400">
              {formatAmount(ask.amount)}
            </span>
          </div>
        ))}
      </div>

      <div className="my-2 py-2 bg-[#2B3139]/30 rounded">
        <div className="text-center">
          <div className="font-bold text-[#0ECB81]">
            {currentPrice.toFixed(getPriceDecimals(currentPrice))}
          </div>
          <div className="text-gray-400">
            {currentPrice.toFixed(getPriceDecimals(currentPrice) + 1)}
          </div>
        </div>

        <div className="flex items-center justify-center gap-4 mt-1.5">
          <div className="flex items-center gap-1">
            <div className="w-8 h-1 bg-[#0ECB81] rounded" />
            <span className="text-gray-400">{bidPercentage.toFixed(1)}%</span>
          </div>
          <div className="flex items-center gap-1">
            <div className="w-8 h-1 bg-[#F6465D] rounded" />
            <span className="text-gray-400">{askPercentage.toFixed(1)}%</span>
          </div>
        </div>
      </div>

      <div className="space-y-[1px]">
        {bids.map((bid, index) => (
          <div key={`bid-${index}`} className="relative h-[16px] flex items-center justify-between text-[10px] px-1">
            <div
              className="absolute right-0 top-0 bottom-0 bg-[#0ECB81]/10"
              style={{ width: `${(bid.total / maxTotal) * 100}%` }}
            />
            <span className="relative text-[#0ECB81] font-medium">
              {bid.price.toFixed(getPriceDecimals(currentPrice))}
            </span>
            <span className="relative text-gray-400">
              {formatAmount(bid.amount)}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
