import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const META_API_VERSION = "v18.0";
const META_API_URL = `https://graph.facebook.com/${META_API_VERSION}/848998828089233/events`;

interface MetaEvent {
  event_name: string;
  event_time: number;
  event_id?: string;
  event_source_url?: string;
