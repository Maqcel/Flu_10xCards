/// Constants for Supabase table names, column names, and error codes
class SupabaseConstants {
  // Prevent instantiation
  const SupabaseConstants._();

  // ============= TABLES =============
  static const String flashcardsTable = 'flashcards';
  static const String generationsTable = 'generations';
  static const String errorLogsTable = 'generation_error_logs';

  // ============= COMMON COLUMNS =============
  static const String idColumn = 'id';
  static const String userIdColumn = 'user_id';
  static const String createdAtColumn = 'created_at';
  static const String updatedAtColumn = 'updated_at';

  // ============= FLASHCARD COLUMNS =============
  static const String flashcardFrontColumn = 'front';
  static const String flashcardBackColumn = 'back';
  static const String flashcardSourceColumn = 'source';
  static const String flashcardGenerationIdColumn = 'generation_id';

  // ============= GENERATION COLUMNS =============
  static const String generationModelColumn = 'model';
  static const String generationSourceTextHashColumn = 'source_text_hash';
  static const String generationSourceTextLengthColumn = 'source_text_length';
  static const String generationGeneratedCountColumn = 'generated_count';
  static const String generationAcceptedUneditedCountColumn =
      'accepted_unedited_count';
  static const String generationAcceptedEditedCountColumn =
      'accepted_edited_count';
  static const String generationDurationColumn = 'generation_duration';

  // ============= ERROR LOG COLUMNS =============
  static const String errorLogErrorCodeColumn = 'error_code';
  static const String errorLogErrorMessageColumn = 'error_message';
  static const String errorLogModelColumn = 'model';
  static const String errorLogSourceTextHashColumn = 'source_text_hash';
  static const String errorLogSourceTextLengthColumn = 'source_text_length';

  // ============= QUERY PARAMETERS =============
  static const String orderAscending = 'ascending';
  static const String orderDescending = 'descending';

  // ============= POSTGREST ERROR CODES =============
  /// Resource not found
  static const String errorCodeNotFound = 'PGRST116';

  /// Unique constraint violation
  static const String errorCodeUniqueViolation = '23505';

  /// Foreign key violation
  static const String errorCodeForeignKeyViolation = '23503';

  /// Check constraint violation
  static const String errorCodeCheckViolation = '23514';

  /// Not null violation
  static const String errorCodeNotNullViolation = '23502';

  // ============= RLS ERROR CODES =============
  /// Insufficient privilege (RLS policy denial)
  static const String errorCodeInsufficientPrivilege = '42501';
}
