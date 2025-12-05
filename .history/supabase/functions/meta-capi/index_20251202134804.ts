// Supabase Edge Function for Meta Conversions API (CAPI)
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const META_PIXEL_ID = "848998828089233";
const META_API_VERSION = "v18.0";
const META_API_URL = `https://graph.facebook.com/${META_API_VERSION}/${META_PIXEL_ID}/events`;

// Helper function to hash data for Meta CAPI
async function hashData(data: string): Promise<string> {
  const encoder = new TextEncoder();
  const dataBuffer = encoder.encode(data);
  const hashBuffer = await crypto.subtle.digest("SHA-256", dataBuffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

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

    // Get client IP from request headers
    const clientIp = req.headers.get("x-forwarded-for") || req.headers.get("x-real-ip") || "127.0.0.1";
    
    // Process events: hash user data fields as required by Meta CAPI
    const processedEvents = await Promise.all(events.map(async (event: any) => {
      const processedEvent = { ...event };
      
      // Process user_data if present
      if (processedEvent.user_data) {
        const userData = { ...processedEvent.user_data };
        
        // Replace {{client_ip}} placeholder with actual client IP
        if (userData.client_ip_address === '{{client_ip}}') {
          userData.client_ip_address = clientIp;
        }
        
        // Hash sensitive user data fields as required by Meta
        const fieldsToHash = [
          'client_ip_address',
          'client_user_agent',
          'em',
          'ph',
          'fn',
          'ln',
          'ge',
          'db',
          'ct',
          'st',
          'zp',
          'country'
        ];
        
        for (const field of fieldsToHash) {
          if (userData[field] && typeof userData[field] === 'string' && userData[field] !== '') {
            // Skip if already looks like a hash (64 hex chars)
            if (!/^[a-f0-9]{64}$/i.test(userData[field])) {
              userData[field] = await hashData(userData[field].toLowerCase());
            }
          }
        }
        
        processedEvent.user_data = userData;
      }
      
      return processedEvent;
    }));

    // Prepare payload for Meta Conversions API
    const payload = {
      data: processedEvents,
      test_event_code: test_event_code || null,
      access_token: accessToken,
    };

    console.log("Sending to Meta CAPI:", JSON.stringify(payload, null, 2));

    // Send events to Meta Conversions API
    const metaResponse = await fetch(META_API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const metaResponseData = await metaResponse.json();
    
    console.log("Meta API response:", {
      status: metaResponse.status,
      data: metaResponseData
    });

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
