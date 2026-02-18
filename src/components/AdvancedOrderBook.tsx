import { useState } from 'react';
import { TrendingUp, TrendingDown } from 'lucide-react';

interface OrderBookEntry {
  price: number;
  amount: number;
  total: number;
}

interface AdvancedOrderBookProps {
  symbol: string;
  asks: OrderBookEntry[];
  bids: OrderBookEntry[];
  currentPrice: number;
  onPriceClick?: (price: number) => void;
}

export default function AdvancedOrderBook({
  symbol,
  asks,
  bids,
  currentPrice,
  onPriceClick
}: AdvancedOrderBookProps) {
  const isEQUSDT = symbol === 'EQUSDT';
  const [precision, setPrecision] = useState(isEQUSDT ? 0.00001 : 0.01);
  const [showDepth, setShowDepth] = useState(true);

  const precisionOptions = isEQUSDT
    ? [
        { label: '0.00001', value: 0.00001 },
        { label: '0.0001', value: 0.0001 },
        { label: '0.001', value: 0.001 },
        { label: '0.01', value: 0.01 },
      ]
    : [
        { label: '0.01', value: 0.01 },
        { label: '0.1', value: 0.1 },
        { label: '1', value: 1 },
        { label: '10', value: 10 },
      ];

  const groupOrders = (orders: OrderBookEntry[], prec: number): OrderBookEntry[] => {
    const grouped: { [key: string]: OrderBookEntry } = {};
    const decimals = isEQUSDT ? 5 : 2;

    orders.forEach(order => {
      const groupedPrice = Math.floor(order.price / prec) * prec;
      const key = groupedPrice.toFixed(decimals);

      if (!grouped[key]) {
        grouped[key] = { price: groupedPrice, amount: 0, total: 0 };
      }
      grouped[key].amount += order.amount;
      grouped[key].total += order.total;
    });

    return Object.values(grouped).sort((a, b) => b.price - a.price);
  };

  const groupedAsks = groupOrders(asks.slice(0, 15), precision);
  const groupedBids = groupOrders(bids.slice(0, 15), precision);

  const maxAskAmount = Math.max(...groupedAsks.map(a => a.amount));
  const maxBidAmount = Math.max(...groupedBids.map(b => b.amount));
  const maxAmount = Math.max(maxAskAmount, maxBidAmount);

  const priceChange = ((currentPrice - asks[0]?.price) / asks[0]?.price * 100) || 0;
  const isPriceUp = priceChange >= 0;

  const formatAmount = (amount: number): string => {
    if (amount >= 1000) return amount.toLocaleString('en-US', { minimumFractionDigits: 1, maximumFractionDigits: 1 });
    if (amount >= 100) return amount.toFixed(2);
    if (amount >= 10) return amount.toFixed(3);
    if (amount >= 1) return amount.toFixed(3);
    if (amount >= 0.01) return amount.toFixed(4);
    if (amount >= 0.0001) return amount.toFixed(5);
    return amount.toFixed(6);
  };

  return (
    <div className="bg-[#181A20] rounded-lg h-full flex flex-col">
      <div className="px-3 py-2 border-[#2B3139]">
        <div className="flex items-center justify-between mb-2">
          <span className="text-xs font-medium">Order Book</span>
          <div className="flex items-center gap-1">
            {precisionOptions.map(opt => (
              <button
                key={opt.value}
                onClick={() => setPrecision(opt.value)}
                className={`px-2 py-0.5 text-[9px] rounded ${ precision === opt.value ? 'bg-[#2B3139] text-[#F0B90B]' : 'text-gray-400 hover:text-white' }`}
              >
                {opt.label}
              </button>
            ))}
          </div>
        </div>
        <div className="flex items-center gap-3 text-gray-400">
          <span>Price(USDT)</span>
          <span className="ml-auto">Amount({symbol.replace('USDT', '')})</span>
          <span>Total</span>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto">
        <div className="px-3 py-1">
          {groupedAsks.reverse().map((ask, idx) => (
            <button
              key={`ask-${idx}`}
              onClick={() => onPriceClick?.(ask.price)}
              className="w-full flex items-center justify-between text-[10px] py-0.5 hover:bg-[#2B3139]/50 relative group"
            >
              {showDepth && (
                <div
                  className="absolute right-0 top-0 bottom-0 bg-[#F6465D]/10"
                  style={{ width: `${(ask.amount / maxAmount) * 100}%` }}
                />
              )}
              <span className="text-[#F6465D] relative z-10">{ask.price.toFixed(isEQUSDT ? 5 : 2)}</span>
              <span className="text-white relative z-10">{formatAmount(ask.amount)}</span>
              <span className="text-gray-400 relative z-10">{ask.total.toFixed(2)}</span>
            </button>
          ))}
        </div>

        <div className="px-3 py-2 bg-[#181A20]">
          <div className="flex items-center gap-2">
            <span className={`text-base font-bold ${isPriceUp ? 'text-[#0ECB81]' : 'text-[#F6465D]'}`}>
              {currentPrice.toFixed(isEQUSDT ? 5 : 2)}
            </span>
            {isPriceUp ? (
              <TrendingUp className="w-3 h-3 text-[#0ECB81]" />
            ) : (
              <TrendingDown className="w-3 h-3 text-[#F6465D]" />
            )}
            <span className={`text-[10px] ${isPriceUp ? 'text-[#0ECB81]' : 'text-[#F6465D]'}`}>
              {isPriceUp ? '+' : ''}{priceChange.toFixed(2)}%
            </span>
          </div>
          <div className="text-gray-400 mt-0.5">
            ≈ ${currentPrice.toFixed(isEQUSDT ? 5 : 2)}
          </div>
        </div>

        <div className="px-3 py-1">
          {groupedBids.map((bid, idx) => (
            <button
              key={`bid-${idx}`}
              onClick={() => onPriceClick?.(bid.price)}
              className="w-full flex items-center justify-between text-[10px] py-0.5 hover:bg-[#2B3139]/50 relative group"
            >
              {showDepth && (
                <div
                  className="absolute right-0 top-0 bottom-0 bg-[#0ECB81]/10"
                  style={{ width: `${(bid.amount / maxAmount) * 100}%` }}
                />
              )}
              <span className="text-[#0ECB81] relative z-10">{bid.price.toFixed(isEQUSDT ? 5 : 2)}</span>
              <span className="text-white relative z-10">{formatAmount(bid.amount)}</span>
              <span className="text-gray-400 relative z-10">{bid.total.toFixed(2)}</span>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
