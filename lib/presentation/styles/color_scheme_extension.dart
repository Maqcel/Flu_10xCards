import 'package:flutter/material.dart';

/// Custom color scheme used across the application.
/// Provides light and dark presets and can be accessed via
/// `Theme.of(context).extension<ColorSchemeExtension>()`.
@immutable
class ColorSchemeExtension extends ThemeExtension<ColorSchemeExtension> {
  const ColorSchemeExtension({
    required this.mainWhite,
    required this.mainBlack,
    required this.accentBlue,
    required this.successGreen,
    required this.errorRed,
    required this.warningOrange,
    required this.infoBlue,
    required this.surfaceVariant,
  });

  final Color mainWhite;
  final Color mainBlack;
  final Color accentBlue;
  final Color successGreen;
  final Color errorRed;
  final Color warningOrange;
  final Color infoBlue;
  final Color surfaceVariant;

  // Light preset
  static const light = ColorSchemeExtension(
    mainWhite: Color(0xFFFFFFFF),
    mainBlack: Color(0xFF000000),
    accentBlue: Color(0xFF0066FF),
    successGreen: Color(0xFF4CAF50),
    errorRed: Color(0xFFF44336),
    warningOrange: Color(0xFFFF9800),
    infoBlue: Color(0xFF2196F3),
    surfaceVariant: Color(0xFFF5F5F5),
  );

  // Dark preset
  static const dark = ColorSchemeExtension(
    mainWhite: Color(0xFF1B1B1B),
    mainBlack: Color(0xFFFFFFFF),
    accentBlue: Color(0xFF4C8DFF),
    successGreen: Color(0xFF66BB6A),
    errorRed: Color(0xFFEF5350),
    warningOrange: Color(0xFFFFA726),
    infoBlue: Color(0xFF42A5F5),
    surfaceVariant: Color(0xFF2C2C2C),
  );

  @override
  ColorSchemeExtension copyWith({
    Color? mainWhite,
    Color? mainBlack,
    Color? accentBlue,
    Color? successGreen,
    Color? errorRed,
    Color? warningOrange,
    Color? infoBlue,
    Color? surfaceVariant,
  }) {
    return ColorSchemeExtension(
      mainWhite: mainWhite ?? this.mainWhite,
      mainBlack: mainBlack ?? this.mainBlack,
      accentBlue: accentBlue ?? this.accentBlue,
      successGreen: successGreen ?? this.successGreen,
      errorRed: errorRed ?? this.errorRed,
      warningOrange: warningOrange ?? this.warningOrange,
      infoBlue: infoBlue ?? this.infoBlue,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
    );
  }

  @override
  ColorSchemeExtension lerp(
    ThemeExtension<ColorSchemeExtension>? other,
    double t,
  ) {
    if (other is! ColorSchemeExtension) return this;
    return ColorSchemeExtension(
      mainWhite: Color.lerp(mainWhite, other.mainWhite, t) ?? mainWhite,
      mainBlack: Color.lerp(mainBlack, other.mainBlack, t) ?? mainBlack,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t) ?? accentBlue,
      successGreen:
          Color.lerp(successGreen, other.successGreen, t) ?? successGreen,
      errorRed: Color.lerp(errorRed, other.errorRed, t) ?? errorRed,
      warningOrange:
          Color.lerp(warningOrange, other.warningOrange, t) ?? warningOrange,
      infoBlue: Color.lerp(infoBlue, other.infoBlue, t) ?? infoBlue,
      surfaceVariant:
          Color.lerp(surfaceVariant, other.surfaceVariant, t) ?? surfaceVariant,
    );
  }
}
