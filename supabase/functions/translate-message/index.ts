import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

interface TranslateRequest {
  text: string;
  targetLang: string;
  sourceLang?: string;
}

interface TranslateResponse {
  translatedText: string;
  detectedLanguage: string;
  sourceLanguage: string;
}

const MYMEMORY_API = "https://api.mymemory.translated.net/get";

async function translateText(
  text: string,
  targetLang: string,
  sourceLang?: string
): Promise<{ translatedText: string; detectedLanguage: string }> {
  try {
    const source = sourceLang && sourceLang !== "auto" ? sourceLang : "auto";
    const langPair = `${source}|${targetLang}`;

    const url = new URL(MYMEMORY_API);
    url.searchParams.append("q", text);
    url.searchParams.append("langpair", langPair);

    console.log(`Translating from ${source} to ${targetLang}:`, text);

    const response = await fetch(url.toString());

    if (!response.ok) {
      console.error("Translation failed:", await response.text());
      return {
        translatedText: text,
        detectedLanguage: sourceLang || "en",
      };
    }

    const data = await response.json();

    if (data && data.responseData && data.responseData.translatedText) {
      console.log("Translation result:", data.responseData.translatedText);
      const detected = data.matches && data.matches.length > 0
        ? data.matches[0].segment.split('|')[0]
        : sourceLang || "en";

      return {
        translatedText: data.responseData.translatedText,
        detectedLanguage: detected,
      };
    }

    console.error("Invalid translation response:", data);
    return {
      translatedText: text,
      detectedLanguage: sourceLang || "en",
    };
  } catch (error) {
    console.error("Translation error:", error);
    return {
      translatedText: text,
      detectedLanguage: sourceLang || "en",
    };
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const { text, targetLang, sourceLang }: TranslateRequest = await req.json();

    if (!text || !targetLang) {
      return new Response(
        JSON.stringify({
          translatedText: text || "",
          detectedLanguage: sourceLang || "en",
          sourceLanguage: sourceLang || "en",
        }),
        {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        }
      );
    }

    if (sourceLang === targetLang) {
      return new Response(
        JSON.stringify({
          translatedText: text,
          detectedLanguage: sourceLang,
          sourceLanguage: sourceLang,
        }),
        {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        }
      );
    }

    const { translatedText, detectedLanguage } = await translateText(
      text,
      targetLang,
      sourceLang
    );

    const response: TranslateResponse = {
      translatedText,
      detectedLanguage,
      sourceLanguage: sourceLang || detectedLanguage,
    };

    return new Response(JSON.stringify(response), {
      status: 200,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json",
      },
    });
  } catch (error) {
    console.error("Server error:", error);
    return new Response(
      JSON.stringify({
        translatedText: "",
        detectedLanguage: "en",
        sourceLanguage: "en",
      }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      }
    );
  }
});
