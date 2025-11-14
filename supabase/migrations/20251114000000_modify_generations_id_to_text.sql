-- migration: modify generations table id column to support openrouter generation ids
-- purpose: change id from uuid to text to store openrouter's generation ids (format: 'gen-xxxx')
-- phase: schema modification
-- affected tables: generations, flashcards
-- special considerations: requires dropping and recreating foreign key constraint

-- ============================================================================
-- step 1: drop foreign key constraint from flashcards
-- rationale: cannot modify referenced column while foreign key exists
-- ============================================================================
alter table flashcards
  drop constraint if exists fk_flashcards_generation;

-- ============================================================================
-- step 2: modify generations.id column type from uuid to text
-- rationale: openrouter generates unique string ids (e.g., 'gen-673de8b25fca5a4d9e9b1234')
--            using text allows us to use their id as primary key directly
-- ============================================================================
alter table generations
  alter column id type text;

-- remove default uuid generation since we now provide id explicitly
alter table generations
  alter column id drop default;

-- ============================================================================
-- step 3: modify flashcards.generation_id column type to match
-- rationale: foreign key column must have same type as referenced column
-- ============================================================================
alter table flashcards
  alter column generation_id type text;

-- ============================================================================
-- step 4: recreate foreign key constraint with new types
-- on delete set null: flashcards are preserved even if generation log is deleted
-- ============================================================================
alter table flashcards
  add constraint fk_flashcards_generation
    foreign key (generation_id)
    references generations(id)
    on delete set null;

-- ============================================================================
-- add documentation comments
-- ============================================================================
comment on column generations.id is 'Unique generation ID from OpenRouter (format: gen-xxxx)';
comment on column flashcards.generation_id is 'Optional link to generation session via OpenRouter generation ID';
