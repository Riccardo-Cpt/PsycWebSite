GRANT USAGE ON SCHEMA psyc_app TO service_role, anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA psyc_app TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA psyc_app TO service_role;
GRANT SELECT ON ALL TABLES IN SCHEMA psyc_app TO anon;
GRANT SELECT ON ALL TABLES IN SCHEMA psyc_app TO authenticated;
