/// Enum representing the source of a flashcard
///
/// - [aiFull]: Accepted without edit from AI generation
/// - [aiEdited]: Accepted after editing from AI generation
/// - [manual]: Created manually by the user
enum FlashcardSource {
  /// Accepted without edit from AI generation
  aiFull('ai-full'),

  /// Accepted after editing from AI generation
  aiEdited('ai-edited'),

  /// Created manually by the user
  manual('manual');

  const FlashcardSource(this.value);

  /// The string value stored in the database
  final String value;

  /// Parse a string value to FlashcardSource
  static FlashcardSource fromString(String value) {
    switch (value) {
      case 'ai-full':
        return FlashcardSource.aiFull;
      case 'ai-edited':
        return FlashcardSource.aiEdited;
      case 'manual':
        return FlashcardSource.manual;
      default:
        throw ArgumentError('Invalid FlashcardSource value: $value');
    }
  }

  /// Check if this source is AI-generated (full or edited)
  bool get isAiGenerated => this == aiFull || this == aiEdited;

  /// Check if this source is manually created
  bool get isManual => this == manual;
}
