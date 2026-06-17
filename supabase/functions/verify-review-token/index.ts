import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

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
    const { token } = await req.json();
    if (!token) {
      return new Response(JSON.stringify({ error: 'Token mancante' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    // Look up token
    const { data: rows, error } = await supabase
      .from('email_approval')
      .select('email, expires_at')
      .eq('token', token)
      .limit(1);
    if (error) throw error;

    if (!rows || rows.length === 0) {
      return new Response(JSON.stringify({ error: 'Token non valido' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const row = rows[0];
    if (new Date(row.expires_at) < new Date()) {
      await supabase.from('email_approval').delete().eq('token', token);
      return new Response(JSON.stringify({ error: 'Token scaduto' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // Delete token (one-time use)
    await supabase.from('email_approval').delete().eq('token', token);

    // Fetch user details
    const { data: users, error: userError } = await supabase
      .from('reviewer_users')
      .select('username, name')
      .eq('email', row.email)
      .limit(1);
    if (userError) throw userError;

    const user = users?.[0];
    return new Response(
      JSON.stringify({
        email: row.email,
        username: user?.username ?? '',
        name: user?.name ?? '',
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
