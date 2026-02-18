import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.57.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

const CMC_API_KEY = "801a4a23617745e197e9335202b14feb";
const CMC_API_BASE = "https://pro-api.coinmarketcap.com";
const CACHE_TTL = 60000;

const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
const supabase = createClient(supabaseUrl, supabaseServiceKey);

let priceCache = new Map<string, any>();
let lastRefresh = 0;
let isRefreshing = false;

async function refreshPrices(): Promise<void> {
  const now = Date.now();
  if (isRefreshing || (now - lastRefresh < CACHE_TTL && priceCache.size > 0)) return;

  isRefreshing = true;
  try {
    const response = await fetch(
      `${CMC_API_BASE}/v1/cryptocurrency/listings/latest?limit=500&convert=USD`,
      {
        headers: {
          "X-CMC_PRO_API_KEY": CMC_API_KEY,
          "Accept": "application/json",
        },
        signal: AbortSignal.timeout(15000),
      }
    );

    if (!response.ok) return;

    const result = await response.json();
    if (!result.data) return;

    const newCache = new Map<string, any>();
    for (const coin of result.data) {
      const quote = coin.quote?.USD;
      if (!quote || !quote.price) continue;

      const price = quote.price;
      const pctChange = quote.percent_change_24h || 0;
      const absChange = Math.abs(pctChange);
      const volatility = Math.max(absChange, 1) / 100;
      const openPrice = price / (1 + pctChange / 100);
      const highPrice = Math.max(price, openPrice) * (1 + volatility * 0.3);
      const lowPrice = Math.min(price, openPrice) * (1 - volatility * 0.3);

      newCache.set(coin.symbol, {
        symbol: coin.symbol,
        price,
        change24h: pctChange,
        high24h: highPrice,
        low24h: lowPrice,
        volume: quote.volume_24h || 0,
        source: "coinmarketcap",
      });
    }

    priceCache = newCache;
    lastRefresh = now;
  } catch (error) {
    console.error("CMC refresh error:", error);
  } finally {
    isRefreshing = false;
  }
}

async function fetchSpecific(symbols: string[]): Promise<void> {
  try {
    const response = await fetch(
      `${CMC_API_BASE}/v2/cryptocurrency/quotes/latest?symbol=${symbols.join(",")}&convert=USD`,
      {
        headers: {
          "X-CMC_PRO_API_KEY": CMC_API_KEY,
          "Accept": "application/json",
        },
        signal: AbortSignal.timeout(10000),
      }
    );

    if (!response.ok) return;

    const result = await response.json();
    if (!result.data) return;

    for (const [sym, coins] of Object.entries(result.data)) {
      const coinArr = coins as any[];
      if (!coinArr || coinArr.length === 0) continue;
      const coin = coinArr[0];
      const quote = coin.quote?.USD;
      if (!quote || !quote.price) continue;

      const price = quote.price;
      const pctChange = quote.percent_change_24h || 0;
      const absChange = Math.abs(pctChange);
      const volatility = Math.max(absChange, 1) / 100;
      const openPrice = price / (1 + pctChange / 100);

      priceCache.set(sym, {
        symbol: sym,
        price,
        change24h: pctChange,
        high24h: Math.max(price, openPrice) * (1 + volatility * 0.3),
        low24h: Math.min(price, openPrice) * (1 - volatility * 0.3),
        volume: quote.volume_24h || 0,
        source: "coinmarketcap",
      });
    }
  } catch (error) {
    console.error("CMC specific fetch error:", error);
  }
}

async function checkPriceOverride(symbol: string) {
  try {
    const { data, error } = await supabase
      .from("admin_price_overrides")
      .select("override_price, expires_at")
      .eq("coin_symbol", symbol)
      .eq("is_active", true)
      .order("created_at", { ascending: false })
      .limit(1)
      .single();

    if (error || !data) return null;

    if (data.expires_at && new Date(data.expires_at) < new Date()) {
      await supabase
        .from("admin_price_overrides")
        .update({ is_active: false })
        .eq("coin_symbol", symbol)
        .eq("is_active", true);
      return null;
    }

    return parseFloat(data.override_price);
  } catch {
    return null;
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const symbols = url.searchParams.get("symbols")?.split(",") || [];

    if (symbols.length === 0) {
      return new Response(
        JSON.stringify({ error: "symbols parameter required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    await refreshPrices();

    const missing = symbols.filter((s) => !priceCache.has(s));
    if (missing.length > 0) {
      await fetchSpecific(missing);
    }

    const overrideChecks = await Promise.all(
      symbols.map((s) => checkPriceOverride(s))
    );

    const prices = symbols.map((sym, i) => {
      const overridePrice = overrideChecks[i];

      if (overridePrice !== null) {
        return {
          symbol: sym,
          price: overridePrice,
          change24h: 0,
          high24h: overridePrice,
          low24h: overridePrice,
          volume: 0,
          source: "admin_override",
        };
      }

      const cached = priceCache.get(sym);
      if (cached) return cached;

      return {
        symbol: sym,
        price: 0,
        change24h: 0,
        high24h: 0,
        low24h: 0,
        volume: 0,
        source: "none",
        error: "No price data available",
      };
    });

    return new Response(JSON.stringify({ success: true, prices }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Internal server error",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
