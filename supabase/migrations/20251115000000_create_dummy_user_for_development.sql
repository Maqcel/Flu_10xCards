-- migration: create dummy user for development without authentication
-- purpose: allow saving flashcards without user authentication during development
-- phase: development only
-- affected tables: auth.users, flashcards
-- special considerations: this should be removed before production deployment

-- ============================================================================
-- create dummy user in auth.users for development
-- rationale: allows testing flashcard functionality without authentication
-- warning: remove before production deployment
-- ============================================================================

-- insert dummy user into auth.users table
-- id: 00000000-0000-0000-0000-000000000000 (easy to identify)
-- email: dev@localhost (clearly a development user)
-- this user will be used for all flashcards created during development
insert into auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  is_super_admin,
  confirmation_token,
  email_change_token_new,
  recovery_token
)
values (
  '00000000-0000-0000-0000-000000000000'::uuid,
  '00000000-0000-0000-0000-000000000000'::uuid,
  'authenticated',
  'authenticated',
  'dev@localhost',
  crypt('development-password-not-for-production', gen_salt('bf')),
  now(),
  now(),
  now(),
  '{"provider":"email","providers":["email"]}'::jsonb,
  '{}'::jsonb,
  false,
  '',
  '',
  ''
)
on conflict (id) do nothing;

-- note: this user is only for development purposes
-- to remove this user before production, run:
-- delete from auth.users where id = '00000000-0000-0000-0000-000000000000';


