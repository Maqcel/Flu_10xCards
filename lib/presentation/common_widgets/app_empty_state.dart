import 'package:flutter/material.dart';
import 'package:xcards/app/extensions/build_context_extension.dart';
import 'package:xcards/presentation/styles/app_dimensions.dart';

/// Reusable empty state widget with consistent styling across the app.
///
/// Displays an icon, title, optional description, and optional action button.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// The icon to display.
  final IconData icon;

  /// The title text.
  final String title;

  /// Optional description text.
  final String? description;

  /// Optional action button label.
  final String? actionLabel;

  /// Optional action button callback.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.padding24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppDimensions.iconSize64,
              color: context.colors.accentBlue,
            ),
            SizedBox(height: AppDimensions.h24),
            Text(
              title,
              style: context.typography.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: AppDimensions.h12),
              Text(
                description!,
                style: context.typography.bodyMedium.copyWith(
                  color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppDimensions.h24),
              ElevatedButton(
                onPressed: onAction,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.padding24,
                    vertical: AppDimensions.padding12,
                  ),
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
