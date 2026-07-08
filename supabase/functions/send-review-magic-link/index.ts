import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { makeServiceClient } from '../_shared/client.ts';

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const SITE_URL = Deno.env.get('SITE_URL')!;
const RESEND_FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL')!;

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  const originError = checkOrigin(req);
  if (originError) return originError;

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  try {
    const { email, username, name, surname } = await req.json();
    if (!email || !username || !name || !surname ||
        email.length > 254 || username.length > 50 ||
        name.length > 100 || surname.length > 100) {
      return new Response(JSON.stringify({ error: 'Dati non validi' }), { status: 400, headers });
    }

    const supabase = makeServiceClient();

    const { data: existing } = await supabase
      .from('reviews')
      .select('id')
      .eq('email', email)
      .limit(1);
    if (existing && existing.length > 0) {
      return new Response(JSON.stringify({ error: 'already_reviewed' }), { status: 409, headers });
    }

    const { error: upsertError } = await supabase
      .from('reviewer_users')
      .upsert({ email, username, name, surname }, { onConflict: 'email' });
    if (upsertError) throw upsertError;

    await supabase.from('email_approval').delete().eq('email', email);

    const token = crypto.randomUUID() + '-' + crypto.randomUUID();
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000);
    const { error: insertError } = await supabase.from('email_approval').insert({
      email,
      token,
      expires_at: expiresAt.toISOString(),
    });
    if (insertError) throw insertError;

    const magicLink = `${SITE_URL}/recensioni?token=${token}`;
    await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        from: RESEND_FROM_EMAIL,
        to: email,
        subject: 'Conferma la tua email per inviare la recensione',
        html: `<p>Ciao ${name},</p><p>Clicca il link per confermare la tua email e inviare la recensione. Valido 1 ora.</p><p><a href="${magicLink}">${magicLink}</a></p><p>Se non hai richiesto questo link, ignoralo.</p>`,
      }),
    }).catch(() => {});

    return new Response(JSON.stringify({ ok: true }), { headers });
  } catch (_) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }
});
