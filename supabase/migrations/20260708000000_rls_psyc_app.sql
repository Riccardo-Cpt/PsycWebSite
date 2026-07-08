-- Enable RLS on all psyc_app tables
ALTER TABLE psyc_app.articoli ENABLE ROW LEVEL SECURITY;
ALTER TABLE psyc_app.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE psyc_app.reviewer_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE psyc_app.email_approval ENABLE ROW LEVEL SECURITY;
ALTER TABLE psyc_app.contact_requests ENABLE ROW LEVEL SECURITY;

-- Default deny: no existing policies = no access for anon/authenticated roles
-- Explicit policies for service_role are not needed (service_role bypasses RLS)

-- articoli: public can read, nothing else
CREATE POLICY "articoli_public_select"
  ON psyc_app.articoli FOR SELECT
  TO anon
  USING (true);

-- reviews: public can read approved only, nothing else
CREATE POLICY "reviews_public_select"
  ON psyc_app.reviews FOR SELECT
  TO anon
  USING (approved = true);

-- All other tables: no anon access at all (no policy = deny)
-- reviewer_users, email_approval, contact_requests: service_role only (via Edge Functions)
