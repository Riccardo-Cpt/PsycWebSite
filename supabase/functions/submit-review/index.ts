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
    const { email, title, description, stars } = await req.json();
    if (!email || !title || !description || !stars) {
      return new Response(
        JSON.stringify({ error: 'Tutti i campi sono obbligatori' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Fetch user details for the review row and admin email
    const { data: users, error: userError } = await supabase
      .from('reviewer_users')
      .select('username, name, surname')
      .eq('email', email)
      .limit(1);
    if (userError) throw userError;
    if (!users || users.length === 0) {
      return new Response(JSON.stringify({ error: 'Utente non trovato' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }
    const user = users[0];

    // Insert review
    const { error: insertError } = await supabase.from('reviews').insert({
      email,
      username: user.username,
      title,
      description,
      stars,
      approved: false,
    });
    if (insertError) {
      // Unique constraint on email = duplicate review
      if (insertError.code === '23505') {
        return new Response(JSON.stringify({ error: 'duplicate' }), {
          status: 409,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        });
      }
      throw insertError;
    }

    // Send admin notification (non-blocking — review already saved)
    fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: RESEND_FROM_EMAIL,
        to: ADMIN_EMAIL,
        subject: 'Nuova recensione in attesa di approvazione',
        html: `
          <p>È stata ricevuta una nuova recensione che richiede la tua approvazione.</p>
          <ul>
            <li><strong>Username:</strong> ${user.username}</li>
            <li><strong>Nome:</strong> ${user.name} ${user.surname}</li>
            <li><strong>Email:</strong> ${email}</li>
            <li><strong>Stelle:</strong> ${stars}/5</li>
            <li><strong>Titolo:</strong> ${title}</li>
          </ul>
          <blockquote>${description}</blockquote>
          <p>Accedi al pannello admin per approvarla o rifiutarla.</p>
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
