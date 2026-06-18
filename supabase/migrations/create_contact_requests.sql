create table if not exists contact_requests (
  id          bigint generated always as identity primary key,
  name        text not null,
  surname     text not null,
  email       text not null,
  title       text not null,
  message     text not null,
  created_at  timestamptz default now()
);
