import 'package:flutter/material.dart';
import 'package:xcards/presentation/styles/app_dimensions.dart';

/// Reusable card widget with consistent styling across the app.
///
/// Provides a Material Design card with customizable elevation,
/// padding, and content. Follows AppDimensions for consistent spacing.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.onTap,
    super.key,
  });

  /// The widget to display inside the card.
  final Widget child;

  /// Internal padding of the card.
  /// Defaults to AppDimensions.padding16 if not specified.
  final EdgeInsetsGeometry? padding;

  /// External margin of the card.
  /// Defaults to EdgeInsets.zero if not specified.
  final EdgeInsetsGeometry? margin;

  /// The elevation of the card.
  /// Defaults to 2 if not specified.
  final double? elevation;

  /// Callback when the card is tapped.
  /// If null, the card is not tappable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation ?? 2,
      margin: margin ?? EdgeInsets.zero,
      child: Padding(
        padding: padding ?? EdgeInsets.all(AppDimensions.padding16),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radius12),
        child: card,
      );
    }

    return card;
  }
}
