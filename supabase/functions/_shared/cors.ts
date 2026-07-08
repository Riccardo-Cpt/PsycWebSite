// supabase/functions/_shared/cors.ts
const ALLOWED_ORIGIN = Deno.env.get('ALLOWED_ORIGIN') ?? '';

export function corsHeaders(origin: string | null): Record<string, string> {
  const allowOrigin = origin === ALLOWED_ORIGIN ? ALLOWED_ORIGIN : (ALLOWED_ORIGIN || '*');
  return {
    'Access-Control-Allow-Origin': allowOrigin,
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  };
}

export function checkOrigin(req: Request): Response | null {
  const origin = req.headers.get('origin');
  if (origin !== ALLOWED_ORIGIN) {
    return new Response(null, { status: 403 });
  }
  return null;
}

export function optionsResponse(req: Request): Response {
  const origin = req.headers.get('origin');
  return new Response('ok', { headers: corsHeaders(origin) });
}
