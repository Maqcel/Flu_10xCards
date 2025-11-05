-- migration: create rls policies for generations table
-- purpose: define granular access control for generation log operations
-- phase: 3 - security (policies)
-- affected tables: generations
-- special considerations: read-only access for users, write access during generation

-- ============================================================================
-- rls policies for generations table
-- rationale: users can view and create their own generation logs
-- update/delete operations typically not needed for metrics/logs
-- ============================================================================

-- policy: select own generation logs
-- role: authenticated users
-- behavior: users can view only their own generation logs for metrics analysis
create policy "authenticated_users_select_own_generations"
  on generations
  for select
  to authenticated
  using (user_id = auth.uid());

-- policy: insert own generation logs
-- role: authenticated users
-- behavior: users can create generation log entries during ai generation process
create policy "authenticated_users_insert_own_generations"
  on generations
  for insert
  to authenticated
  with check (user_id = auth.uid());

-- note: update and delete policies are intentionally omitted
-- generation logs are immutable metrics records
-- if cleanup is needed, use scheduled functions with elevated privileges

