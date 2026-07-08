import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { makeServiceClient } from '../_shared/client.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  const originError = checkOrigin(req);
  if (originError) return originError;

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  try {
    const url = new URL(req.url);
    const id = url.searchParams.get('id');
    const supabase = makeServiceClient();

    if (id) {
      const { data, error } = await supabase
        .from('articoli')
        .select('id, titolo, corpo, pubblicato_at, immagine_url')
        .eq('id', Number(id))
        .limit(1);
      if (error) throw error;
      if (!data || data.length === 0) {
        return new Response(JSON.stringify({ error: 'Non trovato' }), { status: 404, headers });
      }
      return new Response(JSON.stringify(data[0]), { headers });
    }

    const { data, error } = await supabase
      .from('articoli')
      .select('id, titolo, corpo, pubblicato_at, immagine_url')
      .order('pubblicato_at', { ascending: false });
    if (error) throw error;
    return new Response(JSON.stringify(data ?? []), { headers });
  } catch (_) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }
});
