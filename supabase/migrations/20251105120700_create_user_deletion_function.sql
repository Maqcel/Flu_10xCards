-- migration: create user data deletion function for gdpr compliance
-- purpose: provide controlled mechanism for complete user data removal
-- phase: 4 - automation
-- affected tables: auth.users (cascades to flashcards, generations, generation_error_logs)
-- special considerations: security definer function, hard delete with cascade

-- ============================================================================
-- function: delete user data
-- description: deletes all user data for gdpr compliance
-- rationale: cascade delete ensures all related data is removed
-- ============================================================================
create or replace function delete_user_data(target_user_id uuid)
returns void
language plpgsql
security definer -- execute with elevated privileges
set search_path = public
as $$
begin
  -- hard delete: immediately removes user and all related data
  -- cascade constraints automatically delete:
  -- - all flashcards (flashcards.user_id -> auth.users.id)
  -- - all generation logs (generations.user_id -> auth.users.id)
  -- - all error logs (generation_error_logs.user_id -> auth.users.id)
  
  delete from auth.users where id = target_user_id;
  
  -- future enhancement: implement soft delete with retention period
  -- update auth.users
  -- set deleted_at = now(),
  --     email = 'deleted_' || id || '@deleted.local'
  -- where id = target_user_id;
  --
  -- then schedule a job to hard-delete after 30 days retention
end;
$$;

-- add comment explaining function usage and security implications
comment on function delete_user_data(uuid) is 'GDPR compliance function: permanently deletes user and all associated data via cascade. Execute with caution.';

-- note: this function should only be called by:
-- 1. user-initiated account deletion requests
-- 2. gdpr data removal procedures
-- 3. administrative cleanup with proper authorization
-- 
-- warning: this is irreversible. consider implementing soft delete
-- with retention period for production environments

