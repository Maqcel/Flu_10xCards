-- migration: create triggers for automatic timestamp updates
-- purpose: automatically update updated_at column on flashcards modifications
-- phase: 4 - automation
-- affected tables: flashcards
-- special considerations: trigger fires before update operations

-- ============================================================================
-- function: update updated_at column
-- description: sets updated_at to current timestamp on row update
-- ============================================================================
create or replace function update_updated_at_column()
returns trigger as $$
begin
  -- set updated_at to current timestamp
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- add comment explaining function purpose
comment on function update_updated_at_column() is 'Automatically updates updated_at column to current timestamp on row modification';

-- ============================================================================
-- trigger: update flashcards updated_at
-- description: automatically updates updated_at when flashcard is modified
-- ============================================================================
create trigger update_flashcards_updated_at
  before update on flashcards
  for each row
  execute function update_updated_at_column();

-- add comment explaining trigger behavior
comment on trigger update_flashcards_updated_at on flashcards is 'Automatically sets updated_at to current timestamp before each update operation';

