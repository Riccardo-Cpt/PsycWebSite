import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { verifyAdmin } from '../_shared/auth.ts';
import { makeServiceClient } from '../_shared/client.ts';

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  const originError = checkOrigin(req);
  if (originError) return originError;
  const authError = await verifyAdmin(req);
  if (authError) return authError;

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  try {
    const { action, id } = await req.json();
    const supabase = makeServiceClient();

    if (action === 'list') {
      const { data, error } = await supabase
        .from('reviews')
        .select('id, username, email, title, description, stars, approved, created_at')
        .order('created_at', { ascending: false });
      if (error) throw error;
      return new Response(JSON.stringify(data ?? []), { headers });
    }

    if (action === 'approve') {
      if (!id) return new Response(JSON.stringify({ error: 'id mancante' }), { status: 400, headers });
      const { error } = await supabase.from('reviews').update({ approved: true }).eq('id', Number(id));
      if (error) throw error;
      return new Response(JSON.stringify({ ok: true }), { headers });
    }

    if (action === 'delete') {
      if (!id) return new Response(JSON.stringify({ error: 'id mancante' }), { status: 400, headers });
      const { error } = await supabase.from('reviews').delete().eq('id', Number(id));
      if (error) throw error;
      return new Response(JSON.stringify({ ok: true }), { headers });
    }

    return new Response(JSON.stringify({ error: 'Azione non valida' }), { status: 400, headers });
  } catch (_) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }
});
