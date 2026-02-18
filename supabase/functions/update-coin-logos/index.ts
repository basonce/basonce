import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.57.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

const CMC_API_KEY = "801a4a23617745e197e9335202b14feb";
const CMC_API_BASE = "https://pro-api.coinmarketcap.com";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 200, headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { data: supportedCoins, error: fetchError } = await supabase
      .from("supported_coins")
      .select("symbol, name");

    if (fetchError) {
      throw new Error(`Failed to fetch supported coins: ${fetchError.message}`);
    }

    const listingsResponse = await fetch(
      `${CMC_API_BASE}/v1/cryptocurrency/listings/latest?limit=5000&convert=USD`,
      {
        headers: {
          "X-CMC_PRO_API_KEY": CMC_API_KEY,
          "Accept": "application/json",
        },
        signal: AbortSignal.timeout(30000),
      }
    );

    if (!listingsResponse.ok) {
      throw new Error(`CMC listings API error: ${listingsResponse.status}`);
    }

    const listingsResult = await listingsResponse.json();
    if (!listingsResult.data) {
      throw new Error("No data from CMC listings endpoint");
    }

    const symbolToId = new Map<string, number>();
    for (const coin of listingsResult.data) {
      const sym = coin.symbol.toUpperCase();
      if (!symbolToId.has(sym)) {
        symbolToId.set(sym, coin.id);
      }
    }

    let updatedCount = 0;
    let skippedCount = 0;

    for (const supportedCoin of supportedCoins) {
      const symbol = supportedCoin.symbol.toUpperCase();

      if (symbol === "EQ") {
        await supabase
          .from("supported_coins")
          .update({ logo_url: "/earnquest-logo-icon-2.png" })
          .eq("symbol", "EQ");
        updatedCount++;
        continue;
      }

      const cmcId = symbolToId.get(symbol);
      if (cmcId) {
        const logoUrl = `https://s2.coinmarketcap.com/static/img/coins/64x64/${cmcId}.png`;
        const { error: updateError } = await supabase
          .from("supported_coins")
          .update({ logo_url: logoUrl })
          .eq("symbol", symbol);

        if (!updateError) {
          updatedCount++;
        }
      } else {
        skippedCount++;
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: `Updated ${updatedCount} coin logos from CoinMarketCap`,
        total_coins: supportedCoins.length,
        updated: updatedCount,
        skipped: skippedCount,
        cmc_coins_fetched: listingsResult.data.length,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Error updating coin logos:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
