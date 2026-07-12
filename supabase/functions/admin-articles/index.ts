import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { verifyAdmin } from '../_shared/auth.ts';
import { makeServiceClient } from '../_shared/client.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  if (req.method !== 'POST') {
    return new Response(null, { status: 405 });
  }
  const originError = checkOrigin(req);
  if (originError) return originError;
  const authError = await verifyAdmin(req);
  if (authError) return authError;

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  try {
    const body = await req.json();
    const { action } = body;
    const supabase = makeServiceClient();
    const storageClient = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    if (action === 'list') {
      const { data, error } = await supabase
        .from('articoli')
        .select('id, titolo, corpo, pubblicato_at, immagine_url')
        .order('pubblicato_at', { ascending: false });
      if (error) throw error;
      return new Response(JSON.stringify(data ?? []), { headers });
    }

    if (action === 'create') {
      const { titolo, corpo, immagine_url } = body;
      if (!titolo || !corpo || titolo.length > 500 || corpo.length > 100000) {
        return new Response(JSON.stringify({ error: 'Dati non validi' }), { status: 400, headers });
      }
      const { data, error } = await supabase
        .from('articoli')
        .insert({ titolo, corpo, pubblicato_at: new Date().toISOString(), immagine_url: immagine_url ?? null })
        .select('id, titolo, corpo, pubblicato_at, immagine_url');
      if (error) throw error;
      if (!data || data.length === 0) {
        throw new Error('Insert returned no data');
      }
      return new Response(JSON.stringify(data[0]), { headers });
    }

    if (action === 'update') {
      const { id, titolo, corpo, immagine_url } = body;
      if (id == null || !titolo || !corpo || titolo.length > 500 || corpo.length > 100000) {
        return new Response(JSON.stringify({ error: 'Dati non validi' }), { status: 400, headers });
      }
      const { error } = await supabase
        .from('articoli')
        .update({ titolo, corpo, immagine_url: immagine_url ?? null })
        .eq('id', Number(id));
      if (error) throw error;
      return new Response(JSON.stringify({ ok: true }), { headers });
    }

    if (action === 'delete') {
      const { id } = body;
      if (id == null) return new Response(JSON.stringify({ error: 'id mancante' }), { status: 400, headers });
      const { error } = await supabase.from('articoli').delete().eq('id', Number(id));
      if (error) throw error;
      return new Response(JSON.stringify({ ok: true }), { headers });
    }

    if (action === 'upload-image') {
      const { imageBase64, mimeType } = body;
      if (!imageBase64 || !mimeType) {
        return new Response(JSON.stringify({ error: 'Dati non validi' }), { status: 400, headers });
      }
      const allowedMimes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
      if (!allowedMimes.includes(mimeType)) {
        return new Response(JSON.stringify({ error: 'Tipo file non supportato' }), { status: 400, headers });
      }
      const ext = mimeType.split('/')[1] ?? 'jpg';
      const filename = `${crypto.randomUUID()}.${ext}`;
      let bytes: Uint8Array;
      try {
        bytes = Uint8Array.from(atob(imageBase64), c => c.charCodeAt(0));
      } catch (_) {
        return new Response(JSON.stringify({ error: 'Dati non validi' }), { status: 400, headers });
      }
      const { error } = await storageClient.storage
        .from('articoli-images')
        .upload(filename, bytes, { contentType: mimeType });
      if (error) throw error;
      const { data: urlData } = storageClient.storage
        .from('articoli-images')
        .getPublicUrl(filename);
      return new Response(JSON.stringify({ url: urlData.publicUrl }), { headers });
    }

    if (action === 'delete-image') {
      const { url } = body;
      if (!url) return new Response(JSON.stringify({ error: 'url mancante' }), { status: 400, headers });
      const prefix = `${SUPABASE_URL}/storage/v1/object/public/articoli-images/`;
      if (!url.startsWith(prefix)) {
        return new Response(JSON.stringify({ error: 'url non valido' }), { status: 400, headers });
      }
      const filename = url.substring(prefix.length);
      if (!filename || filename.includes('..') || filename.includes('/')) {
        return new Response(JSON.stringify({ error: 'url non valido' }), { status: 400, headers });
      }
      const { error } = await storageClient.storage.from('articoli-images').remove([filename]);
      if (error) throw error;
      return new Response(JSON.stringify({ ok: true }), { headers });
    }

    return new Response(JSON.stringify({ error: 'Azione non valida' }), { status: 400, headers });
  } catch (e) {
    console.error('admin-articles error:', e);
    return new Response(JSON.stringify({ error: 'Errore interno', detail: String(e) }), { status: 500, headers });
  }
});

