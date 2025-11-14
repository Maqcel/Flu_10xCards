import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_message.freezed.dart';

/// Domain model for AI chat message
@freezed
abstract class AiMessage with _$AiMessage {
  const factory AiMessage({
    required AiMessageRole role,
    required String content,
  }) = _AiMessage;
}

/// Role of the message in AI conversation
enum AiMessageRole {
  /// System message that sets the context/instructions for the AI
  system,

  /// Message from the user
  user,

  /// Response from the AI assistant
  assistant,
}

/// Extension to convert AiMessageRole to string for API
extension AiMessageRoleX on AiMessageRole {
  String toApiString() {
    switch (this) {
      case AiMessageRole.system:
        return 'system';
      case AiMessageRole.user:
        return 'user';
      case AiMessageRole.assistant:
        return 'assistant';
    }
  }

  static AiMessageRole fromApiString(String value) {
    switch (value) {
      case 'system':
        return AiMessageRole.system;
      case 'user':
        return AiMessageRole.user;
      case 'assistant':
        return AiMessageRole.assistant;
      default:
        throw ArgumentError('Invalid role: $value');
    }
  }
}
