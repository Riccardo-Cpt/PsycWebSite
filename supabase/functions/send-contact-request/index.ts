import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { makeServiceClient } from '../_shared/client.ts';

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const RESEND_FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL')!;
const ADMIN_EMAIL = Deno.env.get('ADMIN_EMAIL')!;
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

// Storage client without schema override — storage API operates outside psyc_app schema
const storageClient = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  const originError = checkOrigin(req);
  if (originError) return originError;

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  const { name, surname, email, title, message, tesseraBase64, tesseraFileName } =
    await req.json().catch(() => ({}));

  if (
    !name || !surname || !email || !title || !message || !tesseraBase64 || !tesseraFileName ||
    name.length > 100 || surname.length > 100 || email.length > 254 ||
    title.length > 200 || message.length > 5000 || tesseraFileName.length > 255
  ) {
    return new Response(JSON.stringify({ error: 'Dati non validi' }), { status: 400, headers });
  }

  // Decode attachment and prepare storage path before the try/finally block
  const fileBytes = Uint8Array.from(atob(tesseraBase64), (c) => c.charCodeAt(0));
  const ext = tesseraFileName.split('.').pop() ?? 'bin';
  const storagePath = `tessere/${crypto.randomUUID()}.${ext}`;
  const mimeTypes: Record<string, string> = {
    pdf: 'application/pdf',
    jpg: 'image/jpeg',
    jpeg: 'image/jpeg',
    png: 'image/png',
  };
  const contentType = mimeTypes[ext.toLowerCase()] ?? 'application/octet-stream';

  // Upload tessera to transient staging bucket
  const { error: uploadError } = await storageClient.storage
    .from('contact-attachments')
    .upload(storagePath, fileBytes, { contentType, upsert: false });

  if (uploadError) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }

  // Article 9 guarantee: delete from storage in a finally block so it executes
  // regardless of whether the email send or DB insert succeed or fail.
  let emailOk = false;
  let insertError: unknown = null;

  try {
    // Email attachment to admin — capture outcome, never throw
    try {
      const emailRes = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${RESEND_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: RESEND_FROM_EMAIL,
          to: ADMIN_EMAIL,
          subject: 'Nuova richiesta di primo colloquio',
          html: `<p>Nuova richiesta di colloquio.</p><ul><li><strong>Nome:</strong> ${name} ${surname}</li><li><strong>Email:</strong> ${email}</li><li><strong>Oggetto:</strong> ${title}</li></ul><blockquote>${message}</blockquote>`,
          attachments: [{ filename: tesseraFileName, content: tesseraBase64 }],
        }),
      });
      emailOk = emailRes.ok;
    } catch (_) {
      emailOk = false;
    }

    // Insert contact record — NO attachment reference stored (Article 9 compliance)
    const supabase = makeServiceClient();
    const { error: dbError } = await supabase
      .from('contact_requests')
      .insert({ name, surname, email, title, message });
    insertError = dbError ?? null;
  } finally {
    // Article 9: unconditionally delete the tessera from storage
    const { error: deleteError } = await storageClient.storage
      .from('contact-attachments')
      .remove([storagePath]);
    if (deleteError) {
      // Log orphan path for manual remediation — do not expose to client
      console.error('ORPHAN_FILE:', storagePath, deleteError.message);
    }
  }

  if (insertError) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }

  // If email failed, fire-and-forget a fallback alert to admin (no attachment)
  if (!emailOk) {
    fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: RESEND_FROM_EMAIL,
        to: ADMIN_EMAIL,
        subject: '[ATTENZIONE] Richiesta colloquio ricevuta — allegato non consegnato',
        html: `<p><strong>Attenzione:</strong> una richiesta di colloquio è stata ricevuta ma l'allegato (tessera sanitaria) non è stato consegnato per un errore tecnico.</p><ul><li><strong>Nome:</strong> ${name} ${surname}</li><li><strong>Email:</strong> ${email}</li></ul><p>Contattare il paziente per richiedere nuovamente il documento.</p>`,
      }),
    }).catch(() => {});
  }

  return new Response(JSON.stringify({ ok: true }), { headers });
});
