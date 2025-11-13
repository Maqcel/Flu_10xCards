import 'package:flutter/material.dart';
import 'package:xcards/presentation/styles/app_dimensions.dart';

/// Reusable button widget with consistent styling across the app.
///
/// Provides three variants: elevated, outlined, and text buttons.
/// All variants follow AppDimensions for consistent padding and sizing.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.onPressed,
    required this.child,
    this.variant = AppButtonVariant.elevated,
    this.isLoading = false,
    this.isFullWidth = false,
    super.key,
  });

  /// The callback function when the button is pressed.
  /// If null, the button will be disabled.
  final VoidCallback? onPressed;

  /// The widget to display inside the button (usually Text).
  final Widget child;

  /// The visual variant of the button.
  final AppButtonVariant variant;

  /// Whether to show a loading indicator instead of the child.
  final bool isLoading;

  /// Whether the button should take full width of its parent.
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final button = switch (variant) {
      AppButtonVariant.elevated => _buildElevatedButton(context),
      AppButtonVariant.outlined => _buildOutlinedButton(context),
      AppButtonVariant.text => _buildTextButton(context),
    };

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildElevatedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildButtonContent(),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.padding16,
        horizontal: AppDimensions.padding8,
      ),
      child: isLoading
          ? SizedBox(
              height: AppDimensions.h20,
              width: AppDimensions.w20,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : child,
    );
  }
}

/// Visual variants for AppButton.
enum AppButtonVariant {
  /// Elevated button with filled background (primary action).
  elevated,

  /// Outlined button with border (secondary action).
  outlined,

  /// Text button with no background (tertiary action).
  text,
}
