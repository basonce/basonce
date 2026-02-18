import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.57.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface EarnQuestPrice {
  id: number;
  current_price: string;
  start_price: string;
  initial_price_of_cycle: string;
  target_multiplier: string;
  change_percentage: string;
  high_24h: string;
  low_24h: string;
  market_cap: string;
  total_supply: string;
  last_reset_at: string;
  last_24h_reset_at: string;
  updated_at: string;
}

const CYCLE_DURATION_HOURS = 5;

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

    const { data: priceData, error: fetchError } = await supabase
      .from("earnquest_price")
      .select("*")
      .eq("id", 1)
      .single();

    if (fetchError) {
      throw new Error(`Failed to fetch price: ${fetchError.message}`);
    }

    const price = priceData as unknown as EarnQuestPrice;

    const lastResetTime = new Date(price.last_reset_at);
    const now = new Date();
    const elapsedMs = now.getTime() - lastResetTime.getTime();
    const elapsedHours = elapsedMs / (1000 * 60 * 60);

    const startPrice = parseFloat(price.start_price);
    const initialPrice = parseFloat(price.initial_price_of_cycle);
    const targetMultiplier = parseFloat(price.target_multiplier);
    const totalSupply = parseInt(price.total_supply);

    let newPrice: number;
    let newChangePercentage: number;

    if (elapsedHours >= CYCLE_DURATION_HOURS) {
      const { error: resetError } = await supabase.rpc("reset_earnquest_price");

      if (resetError) {
        throw new Error(`Failed to reset price: ${resetError.message}`);
      }

      newPrice = startPrice;
      newChangePercentage = 0;
    } else {
      const progressRatio = elapsedHours / CYCLE_DURATION_HOURS;
      const currentMultiplier = 1 + (targetMultiplier - 1) * progressRatio;

      newPrice = initialPrice * currentMultiplier;
      newChangePercentage = (currentMultiplier - 1) * 100;

      const currentPrice = parseFloat(price.current_price);
      const highPrice = parseFloat(price.high_24h);
      const lowPrice = parseFloat(price.low_24h);

      const newHigh = Math.max(newPrice, highPrice);
      const newLow = Math.min(newPrice, lowPrice);
      const newMarketCap = newPrice * totalSupply;

      const last24hResetTime = new Date(price.last_24h_reset_at);
      const hoursSince24hReset = (now.getTime() - last24hResetTime.getTime()) / (1000 * 60 * 60);

      if (hoursSince24hReset >= 24) {
        const { error: reset24hError } = await supabase.rpc("reset_earnquest_24h_stats");

        if (reset24hError) {
          console.error("Failed to reset 24h stats:", reset24hError);
        }
      }

      const { error: updateError } = await supabase
        .from("earnquest_price")
        .update({
          current_price: newPrice.toFixed(8),
          change_percentage: newChangePercentage.toFixed(2),
          high_24h: newHigh.toFixed(8),
          low_24h: newLow.toFixed(8),
          market_cap: newMarketCap.toFixed(2),
          updated_at: now.toISOString(),
        })
        .eq("id", 1);

      if (updateError) {
        throw new Error(`Failed to update price: ${updateError.message}`);
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        price: newPrice,
        change_percentage: newChangePercentage,
        elapsed_hours: elapsedHours,
        message: elapsedHours >= CYCLE_DURATION_HOURS
          ? "Price cycle completed and reset"
          : "Price updated successfully",
      }),
      {
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  } catch (error) {
    console.error("Error updating EarnQuest price:", error);

    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
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
