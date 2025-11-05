-- migration: create indexes for performance optimization
-- purpose: add b-tree indexes on foreign keys and frequently queried columns
-- phase: 2 - indexes and optimization
-- affected tables: flashcards, generations, generation_error_logs
-- special considerations: improves query performance for user-specific data access

-- ============================================================================
-- indexes for flashcards table
-- ============================================================================

-- index on user_id for filtering flashcards by user
-- used in: select * from flashcards where user_id = ?
create index idx_flashcards_user_id
  on flashcards(user_id);

-- index on generation_id for linking flashcards to generation sessions
-- used in: select * from flashcards where generation_id = ?
create index idx_flashcards_generation_id
  on flashcards(generation_id);

-- ============================================================================
-- indexes for generations table
-- ============================================================================

-- index on user_id for user-specific metrics
-- used in: select * from generations where user_id = ?
create index idx_generations_user_id
  on generations(user_id);

-- ============================================================================
-- indexes for generation_error_logs table
-- ============================================================================

-- index on user_id for filtering error logs by user
-- used in: select * from generation_error_logs where user_id = ?
create index idx_generation_error_logs_user_id
  on generation_error_logs(user_id);

-- add comments for index purpose documentation
comment on index idx_flashcards_user_id is 'Optimizes queries filtering flashcards by user';
comment on index idx_flashcards_generation_id is 'Optimizes queries linking flashcards to generation sessions';
comment on index idx_generations_user_id is 'Optimizes queries for user-specific generation metrics';
comment on index idx_generation_error_logs_user_id is 'Optimizes queries filtering error logs by user';

