import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { makeServiceClient } from '../_shared/client.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  const originError = checkOrigin(req);
  if (originError) return originError;

  if (req.method !== 'GET') {
    return new Response(null, { status: 405 });
  }

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  try {
    const supabase = makeServiceClient();
    const { data, error } = await supabase
      .from('reviews')
      .select('id, username, title, description, stars, created_at')
      .eq('approved', true)
      .order('created_at', { ascending: false });
    if (error) throw error;
    return new Response(JSON.stringify(data ?? []), { headers });
  } catch (e) {
    console.error('get-approved-reviews error:', e);
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }
});
