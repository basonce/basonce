
interface CoinPnL {
  symbol: string;
  name: string;
  logo: string;
  balance: number;
  valueUSDT: number;
  dailyPnL: number;
  dailyChange: number;
}

interface PnLDropdownProps {
  totalPnL: number;
  totalPnLPercentage: number;
  coins: CoinPnL[];
  hideBalance: boolean;
}

export default function PnLDropdown({ totalPnL, totalPnLPercentage, coins, hideBalance }: PnLDropdownProps) {
  return (
    <div className="mb-6">
      <div className="flex items-center gap-4 px-1">
        <span className="text-sm border-b border-dotted border-gray-600 pb-0.5">Today's PNL</span>
        <div className="flex items-center gap-1.5">
          <span className={`text-base font-bold ${totalPnL >= 0 ? 'text-[#0ECB81]' : 'text-[#F6465D]'}`}>
            {totalPnL >= 0 ? '+' : ''}{hideBalance ? '****' : totalPnL.toFixed(2)} USDT
          </span>
          <span className={`text-sm font-semibold ${totalPnL >= 0 ? 'text-[#0ECB81]' : 'text-[#F6465D]'}`}>
            ({totalPnLPercentage >= 0 ? '+' : ''}{hideBalance ? '**' : totalPnLPercentage.toFixed(2)}%)
          </span>
        </div>
      </div>
    </div>
  );
}
