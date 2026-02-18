import { supabase } from './supabase';

export interface CachedPrice {
  symbol: string;
  price: number;
  change24h: number;
  high24h: number;
  low24h: number;
  volume: number;
  prevPrice: number;
  direction: 'up' | 'down' | 'neutral';
  updatedAt: number;
}

const EDGE_URL = `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/binance-proxy`;
const ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY;
const POLL_INTERVAL = 3000;
const BATCH_SIZE = 25;
const BATCH_TIMEOUT = 12000;
const FALLBACK_TIMEOUT = 20000;

class PriceCache {
  private static instance: PriceCache;
  private cache = new Map<string, CachedPrice>();
  private subscribers = new Set<() => void>();
  private pollTimer: number | null = null;
  private allBinanceSymbols: string[] = [];
  private symbolToBinance = new Map<string, string>();
  private ready = false;
  private initializing = false;
  private consecutiveFailures = 0;

  static getInstance(): PriceCache {
    if (!PriceCache.instance) {
      PriceCache.instance = new PriceCache();
    }
    return PriceCache.instance;
  }

  isReady(): boolean {
    return this.ready;
  }

  async init(): Promise<void> {
    if (this.ready || this.initializing) return;
    this.initializing = true;

    try {
      const { data: coins } = await supabase
        .from('supported_coins')
        .select('symbol, binance_symbol')
        .eq('is_active', true);

      if (!coins) return;

      this.allBinanceSymbols = [];
      this.symbolToBinance.clear();

      for (const coin of coins) {
        if (coin.binance_symbol) {
          this.allBinanceSymbols.push(coin.binance_symbol);
          this.symbolToBinance.set(coin.symbol, coin.binance_symbol);
        }
      }

      await this.fetchAllPrices();
      this.ready = true;
      this.startPolling();
    } catch (error) {
      console.error('PriceCache init failed:', error);
    } finally {
      this.initializing = false;
    }
  }

  private async fetchAllPrices(): Promise<void> {
    if (this.allBinanceSymbols.length === 0) return;

    const batches: string[][] = [];
    for (let i = 0; i < this.allBinanceSymbols.length; i += BATCH_SIZE) {
      batches.push(this.allBinanceSymbols.slice(i, i + BATCH_SIZE));
    }

    let anySuccess = false;

    const results = await Promise.allSettled(
      batches.map(batch => this.fetchBatch(batch))
    );

    for (const result of results) {
      if (result.status === 'fulfilled' && Array.isArray(result.value) && result.value.length > 0) {
        for (const ticker of result.value) {
          if (ticker?.symbol) {
            this.processTicker(ticker);
            anySuccess = true;
          }
        }
      }
    }

    if (anySuccess) {
      this.consecutiveFailures = 0;
      this.notify();
    } else {
      this.consecutiveFailures++;
      if (this.consecutiveFailures <= 3) {
        await this.fetchAllTickersFallback();
      }
    }
  }

  private async fetchBatch(symbols: string[]): Promise<any[]> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), BATCH_TIMEOUT);

    try {
      const resp = await fetch(
        `${EDGE_URL}?endpoint=ticker24hr&symbols=${symbols.join(',')}`,
        {
          headers: { 'Authorization': `Bearer ${ANON_KEY}` },
          signal: controller.signal,
        }
      );
      if (!resp.ok) return [];
      const data = await resp.json();
      return Array.isArray(data) ? data : [data];
    } catch {
      return [];
    } finally {
      clearTimeout(timeoutId);
    }
  }

  private async fetchAllTickersFallback(): Promise<void> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), FALLBACK_TIMEOUT);

    try {
      const resp = await fetch(
        `${EDGE_URL}?endpoint=ticker24hr`,
        {
          headers: { 'Authorization': `Bearer ${ANON_KEY}` },
          signal: controller.signal,
        }
      );

      if (!resp.ok) return;

      const data = await resp.json();
      if (!Array.isArray(data)) return;

      const symbolSet = new Set(this.allBinanceSymbols);
      let changed = false;

      for (const ticker of data) {
        if (ticker?.symbol && symbolSet.has(ticker.symbol)) {
          this.processTicker(ticker);
          changed = true;
        }
      }

      if (changed) {
        this.consecutiveFailures = 0;
        this.notify();
      }
    } catch {
      // silently fail, will retry next poll
    } finally {
      clearTimeout(timeoutId);
    }
  }

  private processTicker(ticker: any): void {
    const symbol = ticker.symbol;
    const newPrice = parseFloat(ticker.lastPrice || '0');
    if (newPrice <= 0) return;

    const existing = this.cache.get(symbol);
    const prevPrice = existing?.price ?? newPrice;

    this.cache.set(symbol, {
      symbol,
      price: newPrice,
      change24h: parseFloat(ticker.priceChangePercent || '0'),
      high24h: parseFloat(ticker.highPrice || '0'),
      low24h: parseFloat(ticker.lowPrice || '0'),
      volume: parseFloat(ticker.quoteVolume || '0'),
      prevPrice,
      direction: newPrice > prevPrice ? 'up' : newPrice < prevPrice ? 'down' : 'neutral',
      updatedAt: Date.now(),
    });
  }

  private startPolling(): void {
    if (this.pollTimer) return;
    this.pollTimer = window.setInterval(() => {
      this.fetchAllPrices();
    }, POLL_INTERVAL);
  }

  get(binanceSymbol: string): CachedPrice | null {
    return this.cache.get(binanceSymbol) || null;
  }

  getBySymbol(coinSymbol: string): CachedPrice | null {
    const binanceSymbol = this.symbolToBinance.get(coinSymbol);
    if (!binanceSymbol) return null;
    return this.cache.get(binanceSymbol) || null;
  }

  getBinanceSymbol(coinSymbol: string): string | undefined {
    return this.symbolToBinance.get(coinSymbol);
  }

  subscribe(cb: () => void): () => void {
    this.subscribers.add(cb);
    return () => this.subscribers.delete(cb);
  }

  private notify(): void {
    this.subscribers.forEach(cb => {
      try { cb(); } catch {}
    });
  }

  destroy(): void {
    if (this.pollTimer) {
      clearInterval(this.pollTimer);
      this.pollTimer = null;
    }
    this.subscribers.clear();
    this.cache.clear();
    this.ready = false;
  }
}

export { PriceCache };
