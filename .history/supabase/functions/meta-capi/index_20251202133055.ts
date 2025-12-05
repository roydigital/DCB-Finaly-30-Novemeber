// Supabase Edge Function for Meta Conversions API (CAPI)
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const META_PIXEL_ID = "848998828089233";
const META_API_VERSION = "v18.0";
const META_API_URL = `https://graph.facebook.com/${META_API_VERSION}/${META_PIXEL_ID}/events`;

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 204,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    // Parse request body
    const requestData = await req.json();
    const { events, test_event_code } = requestData;
    
    // Validate events
    if (!events || !Array.isArray(events) || events.length === 0) {
      return new Response(
        JSON.stringify({ error: "No events provided" }),
        {
          status: 400,
          headers: { 
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }

    // Get Meta Access Token from environment variable
    const accessToken = Deno.env.get("META_ACCESS_TOKEN");
    if (!accessToken) {
      console.error("META_ACCESS_TOKEN environment variable is not set");
      return new Response(
        JSON.stringify({ error: "Server configuration error" }),
        {
          status: 500,
          headers: { 
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
          },
        }
      );
    }

    // Prepare payload for Meta Conversions API
    const payload = {
      data: events,
      test_event_code: test_event_code || null,
      access_token: accessToken,
    };

    // Send events to Meta Conversions API
    const metaResponse = await fetch(META_API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const metaResponseData = await metaResponse.json();

    // Return response
    return new Response(
      JSON.stringify({
        success: metaResponse.ok,
        status: metaResponse.status,
        meta_response: metaResponseData,
        events_count: events.length,
      }),
      {
        status: metaResponse.ok ? 200 : metaResponse.status,
        headers: { 
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );

  } catch (error) {
    console.error("Error in Meta CAPI Edge Function:", error);
    
    return new Response(
      JSON.stringify({ 
        error: "Internal server error",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { 
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );
  }
    if (!response.ok) {
      console.error("Meta API error:", responseData);
      return new Response(
        JSON.stringify({ 
          error: "Failed to send events to Meta", 
          details: responseData 
        }),
        {
          status: response.status,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // Return success response
    return new Response(
      JSON.stringify({ 
        success: true, 
        message: "Events sent successfully",
        response: responseData 
      }),
      {
        status: 200,
        headers: { 
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
      }
    );

  } catch (error) {
    console.error("Error processing request:", error);
    return new Response(
      JSON.stringify({ 
        error: "Internal server error", 
        message: error.message 
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      }
    );
  }
});
