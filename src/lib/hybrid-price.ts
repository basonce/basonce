const HYBRID_PRICE_URL = `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/hybrid-price`;

export interface HybridPrice {
  symbol: string;
  price: number;
  change24h: number;
  high24h: number;
  low24h: number;
  volume: number;
  source: 'binance' | 'coingecko' | 'coinmarketcap' | 'admin_override' | 'none';
  error?: string;
}

export interface HybridPriceResponse {
  success: boolean;
  prices: HybridPrice[];
  error?: string;
}

export async function fetchHybridPrices(symbols: string[]): Promise<HybridPriceResponse> {
  try {
    const symbolsParam = symbols.join(',');
    const response = await fetch(`${HYBRID_PRICE_URL}?symbols=${symbolsParam}`);

    if (!response.ok) {
      throw new Error(`Failed to fetch prices: ${response.status}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Hybrid price fetch error:', error);
    return {
      success: false,
      prices: [],
      error: error instanceof Error ? error.message : 'Unknown error'
    };
  }
}

export async function fetchSingleHybridPrice(symbol: string): Promise<HybridPrice | null> {
  try {
    const result = await fetchHybridPrices([symbol]);
    if (result.success && result.prices.length > 0) {
      return result.prices[0];
    }
    return null;
  } catch (error) {
    console.error(`Hybrid price fetch error for ${symbol}:`, error);
    return null;
  }
}
