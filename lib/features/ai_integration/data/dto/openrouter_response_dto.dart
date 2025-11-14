import 'package:json_annotation/json_annotation.dart';

part 'openrouter_response_dto.g.dart';

/// Data Transfer Object for OpenRouter API response
@JsonSerializable(explicitToJson: true)
class OpenRouterResponseDto {
  OpenRouterResponseDto({
    required this.id,
    required this.model,
    required this.choices,
    required this.usage,
    required this.created,
  });

  factory OpenRouterResponseDto.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterResponseDtoFromJson(json);

  final String id;
  final String model;
  final List<ChoiceDto> choices;
  final UsageDto usage;
  final int created;

  Map<String, dynamic> toJson() => _$OpenRouterResponseDtoToJson(this);
}

/// Choice in OpenRouter response
@JsonSerializable(explicitToJson: true)
class ChoiceDto {
  ChoiceDto({
    required this.index,
    required this.message,
    required this.finishReason,
  });

  factory ChoiceDto.fromJson(Map<String, dynamic> json) =>
      _$ChoiceDtoFromJson(json);

  final int index;
  final MessageDto message;

  @JsonKey(name: 'finish_reason')
  final String finishReason;

  Map<String, dynamic> toJson() => _$ChoiceDtoToJson(this);
}

/// Message in choice
@JsonSerializable()
class MessageDto {
  MessageDto({required this.role, required this.content});

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);

  final String role;
  final String content;

  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}

/// Token usage information
@JsonSerializable()
class UsageDto {
  UsageDto({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory UsageDto.fromJson(Map<String, dynamic> json) =>
      _$UsageDtoFromJson(json);

  @JsonKey(name: 'prompt_tokens')
  final int promptTokens;

  @JsonKey(name: 'completion_tokens')
  final int completionTokens;

  @JsonKey(name: 'total_tokens')
  final int totalTokens;

  Map<String, dynamic> toJson() => _$UsageDtoToJson(this);
}
