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
    );
  }
}
