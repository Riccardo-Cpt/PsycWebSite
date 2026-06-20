import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const RESEND_FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL')!;
const ADMIN_EMAIL = Deno.env.get('ADMIN_EMAIL')!;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { name, surname, email, title, message, tesseraBase64, tesseraFileName } = await req.json();
    if (!name || !surname || !email || !title || !message || !tesseraBase64 || !tesseraFileName) {
      return new Response(
        JSON.stringify({ error: 'Tutti i campi sono obbligatori' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Upload tessera sanitaria to storage
    const fileBytes = Uint8Array.from(atob(tesseraBase64), c => c.charCodeAt(0));
    const ext = tesseraFileName.split('.').pop() ?? 'bin';
    const storagePath = `tessere/${Date.now()}_${tesseraFileName}`;
    const mimeTypes: Record<string, string> = {
      pdf: 'application/pdf',
      jpg: 'image/jpeg',
      jpeg: 'image/jpeg',
      png: 'image/png',
    };
    const contentType = mimeTypes[ext.toLowerCase()] ?? 'application/octet-stream';

    const { error: uploadError } = await supabase.storage
      .from('contact-attachments')
      .upload(storagePath, fileBytes, { contentType });
    if (uploadError) throw uploadError;

    const { data: urlData } = supabase.storage
      .from('contact-attachments')
      .getPublicUrl(storagePath);
    const tesseraSanitaria = urlData.publicUrl;

    const { error: insertError } = await supabase
      .from('contact_requests')
      .insert({ name, surname, email, title, message, tessera_sanitaria: tesseraSanitaria });
    if (insertError) throw insertError;

    // Send admin notification (non-blocking)
    fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: RESEND_FROM_EMAIL,
        to: ADMIN_EMAIL,
        subject: 'Nuova richiesta di primo colloquio',
        html: `
          <p>È stata ricevuta una nuova richiesta di primo colloquio.</p>
          <ul>
            <li><strong>Nome:</strong> ${name} ${surname}</li>
            <li><strong>Email:</strong> ${email}</li>
            <li><strong>Oggetto:</strong> ${title}</li>
            <li><strong>Tessera sanitaria:</strong> <a href="${tesseraSanitaria}">${tesseraFileName}</a></li>
          </ul>
          <blockquote>${message}</blockquote>
        `,
      }),
    }).catch(() => {});

    return new Response(JSON.stringify({ ok: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
