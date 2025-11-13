import 'package:flutter/material.dart';
import 'package:xcards/app/extensions/build_context_extension.dart';
import 'package:xcards/presentation/styles/app_dimensions.dart';

/// Reusable loading indicator widget with consistent styling across the app.
///
/// Displays a centered CircularProgressIndicator with optional message.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({this.message, this.size, super.key});

  /// Optional message to display below the loading indicator.
  final String? message;

  /// Size of the loading indicator.
  /// Defaults to null (standard size).
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (size != null)
            SizedBox(
              width: size,
              height: size,
              child: const CircularProgressIndicator(),
            )
          else
            const CircularProgressIndicator(),
          if (message != null) ...[
            SizedBox(height: AppDimensions.h16),
            Text(
              message!,
              style: context.typography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
