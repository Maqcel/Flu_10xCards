-- migration: create rls policies for flashcards table
-- purpose: define granular access control for flashcard operations
-- phase: 3 - security (policies)
-- affected tables: flashcards
-- special considerations: separate policies for select, insert, update, delete operations

-- ============================================================================
-- rls policies for flashcards table
-- rationale: users should have full crud access to their own flashcards only
-- ============================================================================

-- policy: select own flashcards
-- role: authenticated users
-- behavior: users can view only their own flashcards
create policy "authenticated_users_select_own_flashcards"
  on flashcards
  for select
  to authenticated
  using (user_id = auth.uid());

-- policy: insert own flashcards
-- role: authenticated users
-- behavior: users can create flashcards only with their own user_id
create policy "authenticated_users_insert_own_flashcards"
  on flashcards
  for insert
  to authenticated
  with check (user_id = auth.uid());

-- policy: update own flashcards
-- role: authenticated users
-- behavior: users can update only their own flashcards and cannot change user_id
create policy "authenticated_users_update_own_flashcards"
  on flashcards
  for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- policy: delete own flashcards
-- role: authenticated users
-- behavior: users can delete only their own flashcards
create policy "authenticated_users_delete_own_flashcards"
  on flashcards
  for delete
  to authenticated
  using (user_id = auth.uid());

-- note: anonymous users have no access to flashcards
-- all policies require authenticated role

