import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { checkOrigin, optionsResponse, corsHeaders } from '../_shared/cors.ts';
import { makeServiceClient } from '../_shared/client.ts';
import { escHtml } from '../_shared/utils.ts';

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const RESEND_FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL')!;
const ADMIN_EMAIL = Deno.env.get('ADMIN_EMAIL')!;
const SITE_URL = Deno.env.get('SITE_URL')!;

serve(async (req) => {
  if (req.method === 'OPTIONS') return optionsResponse(req);
  const originError = checkOrigin(req);
  if (originError) return originError;

  const origin = req.headers.get('origin');
  const headers = { ...corsHeaders(origin), 'Content-Type': 'application/json' };

  try {
    const { email, title, description, stars } = await req.json();
    if (!email || !title || !description || !stars ||
        email.length > 254 || title.length > 200 ||
        description.length > 2000 || typeof stars !== 'number' ||
        stars < 1 || stars > 5) {
      return new Response(JSON.stringify({ error: 'Dati non validi' }), { status: 400, headers });
    }

    const supabase = makeServiceClient();

    const { data: users, error: userError } = await supabase
      .from('reviewer_users')
      .select('username, name, surname')
      .eq('email', email)
      .limit(1);
    if (userError) throw userError;
    if (!users || users.length === 0) {
      return new Response(JSON.stringify({ error: 'Utente non trovato' }), { status: 404, headers });
    }
    const user = users[0];

    const { error: insertError } = await supabase.from('reviews').insert({
      email,
      username: user.username,
      title,
      description,
      stars,
      approved: false,
    });
    if (insertError) {
      if (insertError.code === '23505') {
        return new Response(JSON.stringify({ error: 'duplicate' }), { status: 409, headers });
      }
      throw insertError;
    }

    fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        from: RESEND_FROM_EMAIL,
        to: ADMIN_EMAIL,
        subject: 'Nuova recensione in attesa di approvazione',
        html: `<p>Nuova recensione da approvare.</p><ul><li><strong>Username:</strong> ${escHtml(user.username)}</li><li><strong>Stelle:</strong> ${escHtml(String(stars))}/5</li><li><strong>Titolo:</strong> ${escHtml(title)}</li><strong>Recensione rilasciata:</strong>${escHtml(description)}<br><br>Per approvare accedere alla console di Admin:  ${SITE_URL}/admin`,
      }),
    }).catch(() => {});

    return new Response(JSON.stringify({ ok: true }), { headers });
  } catch (_) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }
});
