import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xcards/l10n/l10n.dart';

part 'app_failure.freezed.dart';

/// Base failure class for all application errors.
/// Use this instead of throwing exceptions directly.
@freezed
abstract class AppFailure with _$AppFailure {
  /// Network-related failures (connection timeout, no internet, etc.)
  const factory AppFailure.network({String? message}) = _Network;

  /// Server-related failures (5xx errors, invalid response, etc.)
  const factory AppFailure.server({String? message}) = _Server;

  /// Validation failures (invalid input, form errors, etc.)
  const factory AppFailure.validation({String? message}) = _Validation;

  /// Unauthorized access (401, expired token, etc.)
  const factory AppFailure.unauthorized({String? message}) = _Unauthorized;

  /// Resource not found (404)
  const factory AppFailure.notFound({String? message}) = _NotFound;

  /// Cache-related failures
  const factory AppFailure.cache({String? message}) = _Cache;

  /// Unexpected errors that don't fit other categories
  const factory AppFailure.unexpected({String? message}) = _Unexpected;

  /// AI rate limit exceeded (429 error)
  const factory AppFailure.aiRateLimitExceeded({String? message}) =
      _AiRateLimitExceeded;

  /// Insufficient AI credits (402 error)
  const factory AppFailure.aiInsufficientCredits({String? message}) =
      _AiInsufficientCredits;

  /// AI model unavailable (503 error)
  const factory AppFailure.aiModelUnavailable({
    required String model,
    String? message,
  }) = _AiModelUnavailable;

  /// Invalid response from AI (malformed JSON, etc.)
  const factory AppFailure.aiInvalidResponse({String? message}) =
      _AiInvalidResponse;

  /// AI request timeout
  const factory AppFailure.aiTimeout({String? message}) = _AiTimeout;
}

/// Extension to get user-friendly error messages from l10n
extension AppFailureX on AppFailure {
  /// Get localized user-friendly error message
  ///
  /// Usage:
  /// ```dart
  /// Text(failure.userMessage(context))
  /// ```
  String userMessage(BuildContext context) {
    final l10n = context.l10n;
    return when(
      network: (message) => message ?? l10n.appFailureNetwork,
      server: (message) => message ?? l10n.appFailureServer,
      validation: (message) => message ?? l10n.appFailureValidation,
      unauthorized: (message) => message ?? l10n.appFailureUnauthorized,
      notFound: (message) => message ?? l10n.appFailureNotFound,
      cache: (message) => message ?? l10n.appFailureCache,
      unexpected: (message) => message ?? l10n.appFailureUnexpected,
      aiRateLimitExceeded: (message) =>
          message ?? l10n.appFailureAiRateLimitExceeded,
      aiInsufficientCredits: (message) =>
          message ?? l10n.appFailureAiInsufficientCredits,
      aiModelUnavailable: (model, message) =>
          message ?? l10n.appFailureAiModelUnavailable(model),
      aiInvalidResponse: (message) =>
          message ?? l10n.appFailureAiInvalidResponse,
      aiTimeout: (message) => message ?? l10n.appFailureAiTimeout,
    );
  }
}
