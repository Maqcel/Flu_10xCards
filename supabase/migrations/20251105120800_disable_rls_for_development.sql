-- migration: disable row level security for development
-- purpose: ease development by disabling rls on application tables
-- phase: development only
-- affected tables: flashcards, generations, generation_error_logs
-- special considerations: this should be reverted before production deployment

-- ============================================================================
-- disable row level security on application tables
-- rationale: simplifies development and testing without authentication overhead
-- warning: re-enable rls before production deployment for data security
-- ============================================================================

-- disable rls on flashcards table
-- allows unrestricted access during development
alter table flashcards disable row level security;

-- disable rls on generations table
-- allows unrestricted access during development
alter table generations disable row level security;

-- disable rls on generation_error_logs table
-- allows unrestricted access during development
alter table generation_error_logs disable row level security;

-- note: all previously created policies remain in the database
-- they will be automatically re-activated when rls is re-enabled
-- to re-enable rls in production, run:
-- alter table flashcards enable row level security;
-- alter table generations enable row level security;
-- alter table generation_error_logs enable row level security;

