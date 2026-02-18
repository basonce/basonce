import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.57.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers":
    "Content-Type, Authorization, X-Client-Info, Apikey",
};

const BINANCE_API = "https://api.binance.com/api/v3";
const BINANCE_FALLBACKS = [
  "https://api1.binance.com/api/v3",
  "https://api2.binance.com/api/v3",
  "https://api3.binance.com/api/v3",
  "https://api4.binance.com/api/v3",
];
const CACHE_TTL = 10000;
const GROWTH_MULTIPLIER = 1.0001348;

const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";
const supabase = createClient(supabaseUrl, supabaseServiceKey);

let tickerCache = new Map<string, any>();
let allTickersCache: any[] = [];
let lastCacheRefresh = 0;
let refreshing = false;

async function binanceFetch(path: string, timeout = 10000): Promise<Response | null> {
  const urls = [`${BINANCE_API}${path}`, ...BINANCE_FALLBACKS.map(b => `${b}${path}`)];

  for (const url of urls) {
    try {
      const resp = await fetch(url, {
        headers: { "Accept": "application/json" },
        signal: AbortSignal.timeout(timeout),
      });
      if (resp.ok) return resp;
    } catch {
      continue;
    }
  }
  return null;
}

async function updateEarnQuestPrice() {
  try {
    const { data: priceData, error: fetchError } = await supabase
      .from("earnquest_price")
      .select("*")
      .eq("id", 1)
      .single();

    if (fetchError || !priceData) {
      return null;
    }

    let newPrice = parseFloat(priceData.current_price) * GROWTH_MULTIPLIER;
    const smallVariation = (Math.random() - 0.5) * 0.000001;
    newPrice += smallVariation;

    const initialPrice = parseFloat(priceData.initial_price_of_cycle);
    const changePercentage =
      ((newPrice - initialPrice) / initialPrice) * 100;
    const targetMultiplier = parseFloat(priceData.target_multiplier);

    let shouldReset = false;
    if (changePercentage >= (targetMultiplier - 1) * 100) {
      newPrice = parseFloat(priceData.start_price);
      shouldReset = true;
    }

    const now = new Date();
    const last24hReset = new Date(priceData.last_24h_reset_at);
    const hoursSinceLast24hReset =
      (now.getTime() - last24hReset.getTime()) / (1000 * 60 * 60);
    const should24hReset = hoursSinceLast24hReset >= 24;

    const high24h = should24hReset
      ? newPrice
      : Math.max(parseFloat(priceData.high_24h), newPrice);
    const low24h = should24hReset
      ? newPrice
      : Math.min(parseFloat(priceData.low_24h), newPrice);
    const marketCap = newPrice * parseInt(priceData.total_supply);

    const updateData = shouldReset
      ? {
          current_price: newPrice,
          initial_price_of_cycle: newPrice,
          change_percentage: 0,
          high_24h: newPrice,
          low_24h: newPrice,
          market_cap: marketCap,
          last_reset_at: now.toISOString(),
          last_24h_reset_at: should24hReset
            ? now.toISOString()
            : priceData.last_24h_reset_at,
          updated_at: now.toISOString(),
        }
      : {
          current_price: newPrice,
          change_percentage: changePercentage,
          high_24h: high24h,
          low_24h: low24h,
          market_cap: marketCap,
          last_24h_reset_at: should24hReset
            ? now.toISOString()
            : priceData.last_24h_reset_at,
          updated_at: now.toISOString(),
        };

    await supabase
      .from("earnquest_price")
      .update(updateData)
      .eq("id", 1);

    return { ...priceData, ...updateData };
  } catch (error) {
    return null;
  }
}

async function refreshAllTickers(): Promise<void> {
  const now = Date.now();
  if (refreshing || (now - lastCacheRefresh < CACHE_TTL && allTickersCache.length > 0)) return;

  refreshing = true;
  try {
    const resp = await binanceFetch("/ticker/24hr", 15000);
    if (!resp) return;

    const data = await resp.json();
    if (!Array.isArray(data)) return;

    const newCache = new Map<string, any>();
    const newAll: any[] = [];

    for (const ticker of data) {
      if (!ticker.symbol || !ticker.lastPrice) continue;
      if (!ticker.symbol.endsWith("USDT")) continue;

      newCache.set(ticker.symbol, ticker);
      const base = ticker.symbol.replace("USDT", "");
      newCache.set(base, ticker);
      newAll.push(ticker);
    }

    tickerCache = newCache;
    allTickersCache = newAll;
    lastCacheRefresh = now;
  } catch (error) {
    console.error("Binance cache refresh error:", error);
  } finally {
    refreshing = false;
  }
}

async function fetchSingleTicker(symbol: string): Promise<any | null> {
  try {
    const resp = await binanceFetch(`/ticker/24hr?symbol=${encodeURIComponent(symbol)}`);
    if (!resp) return null;

    const data = await resp.json();
    if (data && data.symbol) {
      tickerCache.set(data.symbol, data);
      return data;
    }
    return null;
  } catch {
    return null;
  }
}

async function fetchBatchTickers(symbols: string[]): Promise<any[]> {
  try {
    const jsonSymbols = JSON.stringify(symbols);
    const resp = await binanceFetch(`/ticker/24hr?symbols=${encodeURIComponent(jsonSymbols)}`);
    if (!resp) return [];

    const data = await resp.json();
    if (!Array.isArray(data)) return [];

    for (const ticker of data) {
      if (ticker?.symbol) {
        tickerCache.set(ticker.symbol, ticker);
      }
    }
    return data;
  } catch {
    return [];
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  try {
    const url = new URL(req.url);
    const endpoint = url.searchParams.get("endpoint") || "ticker24hr";
    const symbol = url.searchParams.get("symbol");
    const symbolsParam = url.searchParams.get("symbols");
    const interval = url.searchParams.get("interval");
    const limit = url.searchParams.get("limit");

    if (endpoint === "ticker24hr") {
      if (symbolsParam) {
        const symbolList = symbolsParam
          .split(",")
          .map((s) => s.trim())
          .filter(Boolean);

        if (symbolList.length === 0) {
          return new Response(JSON.stringify([]), {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          });
        }

        const results: any[] = [];
        const missing: string[] = [];

        for (const sym of symbolList) {
          const cached = tickerCache.get(sym);
          if (cached && (Date.now() - lastCacheRefresh < CACHE_TTL)) {
            results.push(cached);
          } else {
            missing.push(sym);
          }
        }

        if (missing.length > 0) {
          const validSymbols = missing.filter(s => s.endsWith("USDT"));
          if (validSymbols.length > 0) {
            const fetched = await fetchBatchTickers(validSymbols);
            results.push(...fetched);
          }
        }

        return new Response(JSON.stringify(results), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      if (symbol) {
        if (
          symbol === "EQLUSDT" ||
          symbol === "EQL" ||
          symbol === "EQUSDT" ||
          symbol === "EQ"
        ) {
          const priceData = await updateEarnQuestPrice();

          if (!priceData) {
            return new Response(
              JSON.stringify({ error: "Failed to fetch EarnQuest price" }),
              {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
              }
            );
          }

          return new Response(
            JSON.stringify({
              symbol:
                symbol === "EQ" || symbol === "EQUSDT" ? "EQUSDT" : "EQLUSDT",
              lastPrice: priceData.current_price.toString(),
              priceChange: (
                parseFloat(priceData.current_price) -
                parseFloat(priceData.initial_price_of_cycle)
              ).toString(),
              priceChangePercent: priceData.change_percentage.toString(),
              highPrice: priceData.high_24h.toString(),
              lowPrice: priceData.low_24h.toString(),
              volume: "1000000",
              quoteVolume: (
                1000000 * parseFloat(priceData.current_price)
              ).toString(),
              openPrice: priceData.initial_price_of_cycle.toString(),
            }),
            {
              headers: { ...corsHeaders, "Content-Type": "application/json" },
            }
          );
        }

        let cached = tickerCache.get(symbol);
        if (cached && (Date.now() - lastCacheRefresh < CACHE_TTL)) {
          return new Response(JSON.stringify(cached), {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          });
        }

        const ticker = await fetchSingleTicker(symbol);
        if (ticker) {
          return new Response(JSON.stringify(ticker), {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          });
        }

        return new Response(
          JSON.stringify({ error: "Symbol not found" }),
          {
            status: 404,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }

      await refreshAllTickers();

      return new Response(JSON.stringify(allTickersCache), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (endpoint === "depth") {
      if (!symbol) {
        return new Response(
          JSON.stringify({ error: "Symbol parameter is required" }),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }

      const depthLimit = limit || "20";
      const resp = await binanceFetch(`/depth?symbol=${encodeURIComponent(symbol)}&limit=${depthLimit}`);
      if (resp) {
        const data = await resp.json();
        return new Response(JSON.stringify(data), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      return new Response(
        JSON.stringify({ lastUpdateId: 0, bids: [], asks: [] }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    if (endpoint === "klines") {
      if (!symbol) {
        return new Response(
          JSON.stringify({ error: "Symbol parameter is required" }),
          {
            status: 400,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
          }
        );
      }

      const klineInterval = interval || "1m";
      const klineLimit = limit || "100";
      const resp = await binanceFetch(
        `/klines?symbol=${encodeURIComponent(symbol)}&interval=${klineInterval}&limit=${klineLimit}`
      );
      if (resp) {
        const data = await resp.json();
        return new Response(JSON.stringify(data), {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      return new Response(JSON.stringify([]), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ error: "Invalid endpoint" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({
        error:
          error instanceof Error ? error.message : "Internal server error",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
