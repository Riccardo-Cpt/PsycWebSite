CREATE TABLE IF NOT EXISTS psyc_app.contact_requests (
  id          bigint generated always as identity primary key,
  name        text not null,
  surname     text not null,
  email       text not null,
  title       text not null,
  message     text not null,
  created_at  timestamptz default now()
);


DROP TABLE IF EXISTS psyc_app.articoli;
CREATE TABLE IF NOT EXISTS psyc_app.articoli(
  id bigint generated always as identity primary key,
  titolo text not null,
  corpo text not null,
  pubblicato_at timestamp not null,
  immagine_url text
);

DROP TABLE IF EXISTS  psyc_app.reviewer_users;
CREATE TABLE IF NOT EXISTS psyc_app.reviewer_users (
  id bigint generated always as identity,
  username text unique not null,
  name text not null,
  surname text not null,
  email text not null,
  created_at timestamptz default now(),
  primary key (email)
);

DROP TABLE IF EXISTS psyc_app.reviews;
CREATE TABLE IF NOT EXISTS psyc_app.reviews (
  id bigint generated always as identity,
  email text unique not null references reviewer_users (email),
  username text not null,
  title text not null,
  description text not null,
  created_at timestamptz default now(),
  stars int not null check (stars >= 1 and stars <= 5),
  approved boolean default false
);

DROP TABLE IF EXISTS psyc_app.email_approval
CREATE TABLE IF NOT EXISTS psyc_app.email_approval(
  id bigint generated always as identity,
  email text not null,
  token text,
  expires_at timestamptz
);

CREATE POLICY "public read approved reviews"
ON psyc_app.reviews
FOR SELECT
USING (approved = true);

