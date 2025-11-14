import 'package:json_annotation/json_annotation.dart';
import 'package:xcards/features/ai_integration/data/dto/openrouter_message_dto.dart';

part 'openrouter_request_dto.g.dart';

/// Data Transfer Object for OpenRouter API request
@JsonSerializable(explicitToJson: true)
class OpenRouterRequestDto {
  OpenRouterRequestDto({
    required this.model,
    required this.messages,
    this.temperature,
    this.maxTokens,
    this.responseFormat,
    this.topP,
  });

  factory OpenRouterRequestDto.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterRequestDtoFromJson(json);

  final String model;
  final List<OpenRouterMessageDto> messages;

  @JsonKey(name: 'temperature')
  final double? temperature;

  @JsonKey(name: 'max_tokens')
  final int? maxTokens;

  @JsonKey(name: 'response_format')
  final Map<String, dynamic>? responseFormat;

  @JsonKey(name: 'top_p')
  final double? topP;

  Map<String, dynamic> toJson() => _$OpenRouterRequestDtoToJson(this);
}
