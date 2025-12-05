import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const META_API_VERSION = "v18.0";
const META_API_URL = `https://graph.facebook.com/${META_API_VERSION}/848998828089233/events`;

interface MetaEvent {
  event_name: string;
  event_time: number;
  event_id?: string;
  event_source_url?: string;
  action_source: "website" | "email" | "phone_call" | "chat" | "physical_store" | "system_generated" | "other";
  user_data: {
    em?: string[]; // Email (hashed)
    ph?: string[]; // Phone (hashed)
    fn?: string[]; // First name (hashed)
    ln?: string[]; // Last name (hashed)
    ct?: string[]; // City (hashed)
    st?: string[]; // State (hashed)
    zp?: string[]; // Zip code (hashed)
    country?: string[]; // Country (hashed)
    external_id?: string[]; // External ID
    client_ip_address?: string;
    client_user_agent?: string;
    fbc?: string; // Facebook click ID
    fbp?: string; // Facebook browser ID
  };
  custom_data?: {
    value?: number;
    currency?: string;
    content_name?: string;
    content_category?: string;
    content_ids?: string[];
    contents?: Array<{
      id: string;
      quantity: number;
    }>;
    content_type?: string;
    order_id?: string;
    predicted_ltv?: number;
    num_items?: number;
    search_string?: string;
    status?: string;
  };
}

interface RequestBody {
  events: MetaEvent[];
  test_event_code?: string;
}

serve(async (req) => {
  // Handle CORS
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
    const { events, test_event_code }: RequestBody = await req.json();
    
    if (!events || !Array.isArray(events) || events.length === 0) {
      return new Response(
        JSON.stringify({ error: "No events provided" }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // Get the Meta Access Token from environment variable
    const accessToken = Deno.env.get("META_ACCESS_TOKEN");
    if (!accessToken) {
      console.error("META_ACCESS_TOKEN environment variable is not set");
      return new Response(
        JSON.stringify({ error: "Server configuration error" }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // Prepare the payload for Meta API
    const payload = {
      data: events,
      test_event_code,
      access_token: accessToken,
    };

    // Send to Meta Conversions API
    const response = await fetch(META_API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });

    const responseData = await response.json();

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
