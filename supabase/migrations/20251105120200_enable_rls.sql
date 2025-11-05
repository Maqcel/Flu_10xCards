-- migration: enable row level security on all tables
-- purpose: enforce data isolation and user-specific access control
-- phase: 3 - security
-- affected tables: flashcards, generations, generation_error_logs
-- special considerations: users can only access their own data

-- ============================================================================
-- enable row level security on all application tables
-- ============================================================================

-- enable rls on flashcards table
-- rationale: users should only see and modify their own flashcards
alter table flashcards enable row level security;

-- enable rls on generations table
-- rationale: generation logs contain user-specific metrics
alter table generations enable row level security;

-- enable rls on generation_error_logs table
-- rationale: error logs may contain sensitive debugging information
alter table generation_error_logs enable row level security;

-- note: policies for each table will be created in separate migration files
-- for better granularity and maintainability

