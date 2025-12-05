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
});
