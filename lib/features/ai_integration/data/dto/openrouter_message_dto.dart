import 'package:json_annotation/json_annotation.dart';

part 'openrouter_message_dto.g.dart';

/// Data Transfer Object for OpenRouter chat message
@JsonSerializable()
class OpenRouterMessageDto {
  OpenRouterMessageDto({required this.role, required this.content});

  factory OpenRouterMessageDto.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterMessageDtoFromJson(json);

  final String role;
  final String content;

  Map<String, dynamic> toJson() => _$OpenRouterMessageDtoToJson(this);
}
