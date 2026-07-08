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
    const { token } = await req.json();
    if (!token || typeof token !== 'string' || token.length > 200) {
      return new Response(JSON.stringify({ error: 'Token non valido' }), { status: 400, headers });
    }

    const supabase = makeServiceClient();

    const { data: rows, error } = await supabase
      .from('email_approval')
      .select('email, expires_at')
      .eq('token', token)
      .limit(1);
    if (error) throw error;

    if (!rows || rows.length === 0) {
      return new Response(JSON.stringify({ error: 'Token non valido' }), { status: 400, headers });
    }

    const row = rows[0];
    if (new Date(row.expires_at) < new Date()) {
      await supabase.from('email_approval').delete().eq('token', token);
      return new Response(JSON.stringify({ error: 'Token scaduto' }), { status: 400, headers });
    }

    await supabase.from('email_approval').delete().eq('token', token);

    const { data: users, error: userError } = await supabase
      .from('reviewer_users')
      .select('username, name')
      .eq('email', row.email)
      .limit(1);
    if (userError) throw userError;

    const user = users?.[0];
    return new Response(
      JSON.stringify({ email: row.email, username: user?.username ?? '', name: user?.name ?? '' }),
      { headers },
    );
  } catch (_) {
    return new Response(JSON.stringify({ error: 'Errore interno' }), { status: 500, headers });
  }
});
