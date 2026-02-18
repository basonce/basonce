import { supabase } from './supabase';
import { TradingService } from './trading-service';
import { EarnQuestPriceManager } from './earnquest-price';

interface Balance {
  symbol: string;
  balance: number;
}

interface PortfolioSnapshot {
  snapshot_date: string;
  total_value_usdt: number;
  balances: Record<string, { balance: number; last_price: number }>;
}

interface RealtimePnL {
  currentTotalValue: number;
  startingValue: number;
  dailyPnL: number;
  dailyPnLPercentage: number;
  balances: Balance[];
}

class RealtimePnLService {
  private static instance: RealtimePnLService;
  private subscribers: Array<(pnl: RealtimePnL) => void> = [];
  private updateInterval: number | null = null;
  private currentPnL: RealtimePnL = {
    currentTotalValue: 0,
    startingValue: 0,
    dailyPnL: 0,
    dailyPnLPercentage: 0,
    balances: []
  };
  private eqPriceManager = EarnQuestPriceManager.getInstance();

  private constructor() {
    this.startRealtimeUpdates();

    this.eqPriceManager.subscribe(() => {
      this.calculatePnL();
    });
  }

  static getInstance(): RealtimePnLService {
    if (!RealtimePnLService.instance) {
      RealtimePnLService.instance = new RealtimePnLService();
    }
    return RealtimePnLService.instance;
  }

  private async getTodaySnapshot(): Promise<PortfolioSnapshot | null> {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return null;

      const { data, error } = await supabase
        .rpc('get_today_portfolio_snapshot', { user_id_param: user.id })
        .maybeSingle();

      if (error) {
        console.error('Error fetching snapshot:', error);
        return null;
      }

      if (!data) {
        console.log('No snapshot found for today, creating one...');
        await supabase.rpc('create_daily_portfolio_snapshot');

        const { data: retryData, error: retryError } = await supabase
          .rpc('get_today_portfolio_snapshot', { user_id_param: user.id })
          .maybeSingle();

        if (retryError) {
          console.error('Error fetching snapshot after creation:', retryError);
          return null;
        }

        return retryData;
      }

      return data;
    } catch (error) {
      console.error('Error in getTodaySnapshot:', error);
      return null;
    }
  }

  private async getCurrentBalances(): Promise<Balance[]> {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return [];

      const { data, error } = await supabase
        .from('user_balances')
        .select('symbol, balance, futures_balance')
        .eq('user_id', user.id);

      if (error) throw error;

      return (data || []).map(b => ({
        symbol: b.symbol,
        balance: parseFloat(b.balance) + parseFloat(b.futures_balance || '0')
      }));
    } catch (error) {
      console.error('Error fetching balances:', error);
      return [];
    }
  }

  private async getCurrentPrice(symbol: string): Promise<number> {
    if (symbol === 'USDT') return 1;
    if (symbol === 'EQ' || symbol === 'EQL') {
      return this.eqPriceManager.getPrice();
    }

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 3000);

      const price = await Promise.race([
        TradingService.getCurrentPrice(symbol),
        new Promise<number>((_, reject) =>
          setTimeout(() => reject(new Error('Timeout')), 3000)
        )
      ]);

      clearTimeout(timeoutId);
      return price;
    } catch (error) {
      console.warn(`Failed to fetch price for ${symbol}, using 0:`, error);
      return 0;
    }
  }

  private async getFuturesUnrealizedPnL(): Promise<number> {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return 0;

      const { data: positions, error } = await supabase
        .from('futures_positions')
        .select('symbol, side, entry_price, position_size, unrealized_pnl, status, created_at')
        .eq('user_id', user.id)
        .eq('status', 'open');

      if (error) throw error;

      if (!positions || positions.length === 0) return 0;

      let totalUnrealizedPnL = 0;

      for (const position of positions) {
        const currentPrice = await this.getCurrentPrice(position.symbol.replace('USDT', ''));
        const entryPrice = parseFloat(position.entry_price);
        const positionSize = parseFloat(position.position_size);
        const quantity = positionSize / entryPrice;

        let unrealizedPnL = 0;
        if (position.side === 'LONG') {
          unrealizedPnL = (currentPrice - entryPrice) * quantity;
        } else {
          unrealizedPnL = (entryPrice - currentPrice) * quantity;
        }

        totalUnrealizedPnL += unrealizedPnL;
      }

      return totalUnrealizedPnL;
    } catch (error) {
      console.error('Error fetching futures unrealized PnL:', error);
      return 0;
    }
  }

  private async calculatePnL() {
    try {
      const [snapshot, balances, futuresUnrealizedPnL] = await Promise.all([
        this.getTodaySnapshot(),
        this.getCurrentBalances(),
        this.getFuturesUnrealizedPnL()
      ]);

      const pricePromises = balances.map(balance =>
        this.getCurrentPrice(balance.symbol).then(price => ({
          balance: balance.balance,
          price
        }))
      );

      const balanceValues = await Promise.all(pricePromises);

      let currentTotalValue = 0;
      for (const { balance, price } of balanceValues) {
        currentTotalValue += balance * price;
      }

      currentTotalValue += futuresUnrealizedPnL;

      if (!snapshot || parseFloat(snapshot.total_value_usdt.toString()) === 0) {
        this.currentPnL = {
          currentTotalValue,
          startingValue: currentTotalValue,
          dailyPnL: 0,
          dailyPnLPercentage: 0,
          balances
        };
        this.notifySubscribers();
        return;
      }

      const startingValue = parseFloat(snapshot.total_value_usdt.toString());
      const dailyPnL = currentTotalValue - startingValue;
      const dailyPnLPercentage = startingValue > 0
        ? (dailyPnL / startingValue) * 100
        : 0;

      this.currentPnL = {
        currentTotalValue,
        startingValue,
        dailyPnL,
        dailyPnLPercentage,
        balances
      };

      this.notifySubscribers();
    } catch (error) {
      console.error('Error calculating PnL:', error);
    }
  }

  private startRealtimeUpdates() {
    this.calculatePnL();

    this.updateInterval = window.setInterval(() => {
      this.calculatePnL();
    }, 30000);
  }

  getPnL(): RealtimePnL {
    return this.currentPnL;
  }

  subscribe(callback: (pnl: RealtimePnL) => void): () => void {
    this.subscribers.push(callback);
    callback(this.currentPnL);

    return () => {
      this.subscribers = this.subscribers.filter(cb => cb !== callback);
    };
  }

  private notifySubscribers() {
    this.subscribers.forEach(callback => callback(this.currentPnL));
  }

  async refresh() {
    await this.calculatePnL();
  }

  destroy() {
    if (this.updateInterval) {
      clearInterval(this.updateInterval);
    }
  }
}

export { RealtimePnLService };
export type { RealtimePnL };
