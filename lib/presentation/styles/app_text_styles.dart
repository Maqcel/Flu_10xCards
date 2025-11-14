import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xcards/presentation/styles/app_dimensions.dart';

/// Custom text styles extension for theming.
///
/// Provides consistent typography across the app with predefined text styles
/// that can be easily accessed via context.typography.
///
/// Usage:
/// ```dart
/// Text('Hello', style: context.typography.bodyMedium)
/// ```
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  /// Light theme text styles using Inter font
  factory AppTextStyles.light() {
    final baseTextTheme = GoogleFonts.interTextTheme();

    return AppTextStyles(
      displayLarge: baseTextTheme.displayLarge!.copyWith(
        fontSize: AppDimensions.fontSize32,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: baseTextTheme.displayMedium!.copyWith(
        fontSize: AppDimensions.fontSize28,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: baseTextTheme.displaySmall!.copyWith(
        fontSize: AppDimensions.fontSize24,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: baseTextTheme.headlineLarge!.copyWith(
        fontSize: AppDimensions.fontSize24,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: baseTextTheme.headlineMedium!.copyWith(
        fontSize: AppDimensions.fontSize20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: baseTextTheme.headlineSmall!.copyWith(
        fontSize: AppDimensions.fontSize18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        fontSize: AppDimensions.fontSize20,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        fontSize: AppDimensions.fontSize16,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: baseTextTheme.titleSmall!.copyWith(
        fontSize: AppDimensions.fontSize14,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        fontSize: AppDimensions.fontSize16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        fontSize: AppDimensions.fontSize14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: baseTextTheme.bodySmall!.copyWith(
        fontSize: AppDimensions.fontSize12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: baseTextTheme.labelLarge!.copyWith(
        fontSize: AppDimensions.fontSize14,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: baseTextTheme.labelMedium!.copyWith(
        fontSize: AppDimensions.fontSize12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: baseTextTheme.labelSmall!.copyWith(
        fontSize: AppDimensions.fontSize10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Dark theme text styles - same as light for now
  factory AppTextStyles.dark() => AppTextStyles.light();

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle displaySmall;
  final TextStyle headlineLarge;
  final TextStyle headlineMedium;
  final TextStyle headlineSmall;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;

  @override
  ThemeExtension<AppTextStyles> copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
  }) {
    return AppTextStyles(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
    );
  }

  @override
  ThemeExtension<AppTextStyles> lerp(
    covariant ThemeExtension<AppTextStyles>? other,
    double t,
  ) {
    if (other is! AppTextStyles) return this;

    return AppTextStyles(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t)!,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t)!,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t)!,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t)!,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t)!,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t)!,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t)!,
    );
  }
}
