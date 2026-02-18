import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.57.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const { data: coins, error: fetchError } = await supabase
      .from("supported_coins")
      .select("symbol, name, coingecko_id");

    if (fetchError) {
      throw new Error(`Failed to fetch coins: ${fetchError.message}`);
    }

    const coinListResponse = await fetch(
      "https://api.coingecko.com/api/v3/coins/list?include_platform=false"
    );

    if (!coinListResponse.ok) {
      throw new Error(`CoinGecko API error: ${coinListResponse.status}`);
    }

    const coinGeckoList = await coinListResponse.json() as Array<{
      id: string;
      symbol: string;
      name: string;
    }>;

    const symbolMap = new Map<string, string[]>();
    for (const coin of coinGeckoList) {
      const symbol = coin.symbol.toUpperCase();
      if (!symbolMap.has(symbol)) {
        symbolMap.set(symbol, []);
      }
      symbolMap.get(symbol)!.push(coin.id);
    }

    let updatedCount = 0;
    let skippedCount = 0;

    for (const coin of coins) {
      if (coin.coingecko_id) {
        skippedCount++;
        continue;
      }

      const symbol = coin.symbol.toUpperCase();
      const possibleIds = symbolMap.get(symbol);

      if (!possibleIds || possibleIds.length === 0) {
        console.log(`No CoinGecko ID found for ${symbol}`);
        continue;
      }

      let bestId = possibleIds[0];

      if (possibleIds.length > 1) {
        const nameLower = coin.name.toLowerCase();
        for (const id of possibleIds) {
          if (id.includes(nameLower.replace(/\s+/g, '-')) ||
              id === nameLower.replace(/\s+/g, '-')) {
            bestId = id;
            break;
          }
        }
      }

      const { error: updateError } = await supabase
        .from("supported_coins")
        .update({ coingecko_id: bestId })
        .eq("symbol", coin.symbol);

      if (updateError) {
        console.error(`Failed to update ${coin.symbol}:`, updateError);
      } else {
        updatedCount++;
        console.log(`Updated ${coin.symbol} with CoinGecko ID: ${bestId}`);
      }

      await new Promise(resolve => setTimeout(resolve, 50));
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: `Updated ${updatedCount} coins with CoinGecko IDs`,
        updated: updatedCount,
        skipped: skippedCount,
        total: coins.length
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Unknown error"
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  }
});
