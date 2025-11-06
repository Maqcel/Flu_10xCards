/// Barrel file for all Supabase database entities and API DTOs
library;

// Core database entities
export 'database/flashcard_entity.dart';
export 'database/generation_entity.dart';
export 'database/generation_error_log_entity.dart';
// Request DTOs
export 'requests/create_flashcard_request_entity.dart';
export 'requests/generate_flashcards_request_entity.dart';
export 'requests/update_flashcard_request_entity.dart';
export 'requests/update_generation_stats_request_entity.dart';
// Response DTOs
export 'responses/flashcard_proposal_entity.dart';
export 'responses/generate_flashcards_response_entity.dart';
// Statistics DTOs
export 'statistics/flashcard_statistics_entity.dart';
export 'statistics/generation_statistics_entity.dart';
export 'statistics/model_statistics_entity.dart';
export 'statistics/source_statistics_entity.dart';
// Enums and utilities
export 'utils/flashcard_source.dart';
