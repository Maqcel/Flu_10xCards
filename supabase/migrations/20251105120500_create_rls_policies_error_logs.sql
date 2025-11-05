-- migration: create rls policies for generation_error_logs table
-- purpose: define granular access control for error log operations
-- phase: 3 - security (policies)
-- affected tables: generation_error_logs
-- special considerations: read-only access for users, write access during error handling

-- ============================================================================
-- rls policies for generation_error_logs table
-- rationale: users can view and create their own error logs
-- useful for debugging and support purposes
-- ============================================================================

-- policy: select own error logs
-- role: authenticated users
-- behavior: users can view only their own error logs for debugging
create policy "authenticated_users_select_own_error_logs"
  on generation_error_logs
  for select
  to authenticated
  using (user_id = auth.uid());

-- policy: insert own error logs
-- role: authenticated users
-- behavior: users can create error log entries when generation fails
create policy "authenticated_users_insert_own_error_logs"
  on generation_error_logs
  for insert
  to authenticated
  with check (user_id = auth.uid());

-- note: update and delete policies are intentionally omitted
-- error logs are immutable records for debugging and analytics
-- consider implementing automated cleanup for logs older than 90 days

