# Supabase Database Entities

This directory contains Freezed entities that map directly to your Supabase database tables.

## Generated from Supabase Schema

These entities were generated based on the TypeScript types from:
```bash
supabase gen types typescript --local
```

## Available Entities

### FlashcardEntity
Represents a flashcard stored in the `flashcards` table.

**Source Types:**
- `'ai-full'` - Accepted without edit
- `'ai-edited'` - Accepted after edit  
- `'manual'` - Created manually

**Usage:**
```dart
// From JSON (Supabase response)
final flashcard = FlashcardEntity.fromJson(json);

// To JSON (for Supabase insert/update)
final json = flashcard.toJson();
```

### GenerationEntity
Represents an AI generation log stored in the `generations` table.

Tracks metrics and analytics for AI flashcard generation sessions.

### GenerationErrorLogEntity
Represents an error log stored in the `generation_error_logs` table.

Stores errors that occur during AI generation attempts for debugging.

## JSON Serialization

All entities use:
- **Freezed** for immutable data classes
- **json_serializable** for JSON conversion
- **@JsonKey** for snake_case ↔ camelCase field mapping
- **@DateTimeConverter** for DateTime ISO 8601 serialization

## Example Service Usage

```dart
import 'package:xcards/app/networking/entities/entities.dart';
import 'package:xcards/app/constants/supabase_constants.dart';

class FlashcardService {
  final SupabaseClient _supabase;

  FlashcardService(this._supabase);

  Future<List<FlashcardEntity>> getAllFlashcards() async {
    final response = await _supabase
        .from(SupabaseConstants.flashcardsTable)
        .select()
        .order(SupabaseConstants.createdAtColumn, ascending: false);

    return (response as List<dynamic>)
        .map((json) => FlashcardEntity.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> createFlashcard(FlashcardEntity flashcard) async {
    await _supabase
        .from(SupabaseConstants.flashcardsTable)
        .insert(flashcard.toJson());
  }
}
```

## Regenerating Entities

If the database schema changes:

1. Update migrations in `supabase/migrations/`
2. Apply migrations: `supabase db reset --local`
3. Check TypeScript types: `supabase gen types typescript --local`
4. Update entity classes to match new schema
5. Run codegen: `dart run build_runner build --delete-conflicting-outputs`

## Note on Analyzer Warnings

You may see warnings like:
```
The annotation 'JsonKey.new' can only be used on fields or getters.
```

These are **false positives** - this is the correct way to use `@JsonKey` with Freezed. The generated code works perfectly as shown in the `.g.dart` files.

