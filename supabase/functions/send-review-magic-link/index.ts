import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const SITE_URL = Deno.env.get('SITE_URL')!;
const RESEND_FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL')!;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { email, username, name, surname } = await req.json();
    if (!email || !username || !name || !surname) {
      return new Response(
        JSON.stringify({ error: 'Tutti i campi sono obbligatori' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Upsert user (email is PK)
    const { error: upsertError } = await supabase
      .from('reviewer_users')
      .upsert({ email, username, name, surname }, { onConflict: 'email' });
    if (upsertError) throw upsertError;

    // Delete any existing token for this email
    await supabase.from('email_approval').delete().eq('email', email);

    // Generate token and store
    const token = crypto.randomUUID() + '-' + crypto.randomUUID();
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 hour
    const { error: insertError } = await supabase.from('email_approval').insert({
      email,
      token,
      expires_at: expiresAt.toISOString(),
    });
    if (insertError) throw insertError;

    // Send magic link email
    const magicLink = `${SITE_URL}/#/recensioni?token=${token}`;
    const emailRes = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: RESEND_FROM_EMAIL,
        to: email,
        subject: 'Conferma la tua email per inviare la recensione',
        html: `
          <p>Ciao ${name},</p>
          <p>Clicca il link seguente per confermare la tua email e inviare la tua recensione. Il link è valido per 1 ora.</p>
          <p><a href="${magicLink}">${magicLink}</a></p>
          <p>Se non hai richiesto questo link, ignoralo.</p>
        `,
      }),
    });
    if (!emailRes.ok) {
      const body = await emailRes.text();
      throw new Error(`Errore Resend: ${body}`);
    }

    // Always return ok to avoid email enumeration
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
