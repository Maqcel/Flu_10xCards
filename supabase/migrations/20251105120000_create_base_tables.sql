-- migration: create base tables for flashcards application
-- purpose: create flashcards, generations, and generation_error_logs tables with constraints
-- phase: 1 - basic structures
-- affected tables: flashcards, generations, generation_error_logs
-- special considerations: enables uuid generation, sets up foreign keys to auth.users

-- enable uuid generation extension
create extension if not exists "uuid-ossp";

-- ============================================================================
-- table: flashcards
-- description: stores accepted flashcards (ai-generated and manual)
-- ============================================================================
create table flashcards (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  front varchar(200) not null,
  back varchar(500) not null,
  source varchar not null check (source in ('ai-full', 'ai-edited', 'manual')),
  generation_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  
  -- foreign key to auth.users
  -- on delete cascade: all user flashcards are deleted when user account is deleted
  constraint fk_flashcards_user
    foreign key (user_id)
    references auth.users(id)
    on delete cascade
);

-- add comment explaining source values
comment on column flashcards.source is 'Source of flashcard: ai-full (accepted without edit), ai-edited (accepted after edit), manual (created manually)';

-- ============================================================================
-- table: generations
-- description: stores ai generation logs for metrics and analytics
-- ============================================================================
create table generations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  model varchar not null,
  source_text_length integer not null check (source_text_length between 1000 and 10000),
  source_text_hash varchar not null,
  generated_count integer not null,
  accepted_unedited_count integer,
  accepted_edited_count integer,
  generation_duration integer not null,
  created_at timestamptz not null default now(),
  
  -- foreign key to auth.users
  -- on delete cascade: all generation logs are deleted when user account is deleted
  constraint fk_generations_user
    foreign key (user_id)
    references auth.users(id)
    on delete cascade
);

-- add comments for clarity
comment on column generations.model is 'LLM model used for generation (e.g., gpt-4, claude-3)';
comment on column generations.source_text_length is 'Length of source text in characters (1000-10000)';
comment on column generations.source_text_hash is 'SHA-256 hash of source text for deduplication';
comment on column generations.generation_duration is 'Generation time in milliseconds';

-- ============================================================================
-- table: generation_error_logs
-- description: stores error logs from ai generation attempts
-- ============================================================================
create table generation_error_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  model varchar not null,
  source_text_hash varchar not null,
  source_text_length integer not null check (source_text_length between 1000 and 10000),
  error_code varchar(100) not null,
  error_message text not null,
  created_at timestamptz not null default now(),
  
  -- foreign key to auth.users
  -- on delete cascade: all error logs are deleted when user account is deleted
  constraint fk_generation_error_logs_user
    foreign key (user_id)
    references auth.users(id)
    on delete cascade
);

-- add comments for debugging context
comment on column generation_error_logs.error_code is 'Error code for categorization (e.g., TIMEOUT, INVALID_RESPONSE)';
comment on column generation_error_logs.error_message is 'Detailed error message for debugging';

-- ============================================================================
-- add foreign key from flashcards to generations
-- on delete set null: flashcards are preserved even if generation log is deleted
-- ============================================================================
alter table flashcards
  add constraint fk_flashcards_generation
    foreign key (generation_id)
    references generations(id)
    on delete set null;

comment on column flashcards.generation_id is 'Optional link to generation session (null for manual flashcards)';

