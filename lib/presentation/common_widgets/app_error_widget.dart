import 'package:flutter/material.dart';
import 'package:xcards/app/extensions/build_context_extension.dart';
import 'package:xcards/app/failures/app_failure.dart';
import 'package:xcards/l10n/l10n.dart';
import 'package:xcards/presentation/common_widgets/app_button.dart';
import 'package:xcards/presentation/styles/app_dimensions.dart';

/// Reusable error widget with consistent styling across the app.
///
/// Displays an error icon, message, and optional retry button.
/// Supports AppFailure for standardized error messaging.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({this.failure, this.message, this.onRetry, super.key})
    : assert(
        failure != null || message != null,
        'Either failure or message must be provided',
      );

  /// The AppFailure to display.
  /// If provided, the error message will be derived from the failure.
  final AppFailure? failure;

  /// Custom error message to display.
  /// If both failure and message are provided, message takes precedence.
  final String? message;

  /// Optional retry callback.
  /// If provided, a retry button will be displayed.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final errorMessage = _getErrorMessage(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.padding24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: AppDimensions.iconSize64,
              color: context.colors.errorRed,
            ),
            SizedBox(height: AppDimensions.h24),
            Text(
              errorMessage,
              style: context.typography.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppDimensions.h24),
              AppButton(
                onPressed: onRetry,
                variant: AppButtonVariant.outlined,
                child: Text(context.l10n.generationButtonCancel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getErrorMessage(BuildContext context) {
    if (message != null) return message!;

    if (failure != null) {
      return failure!.userMessage(context);
    }

    return context.l10n.appFailureUnexpected;
  }
}
