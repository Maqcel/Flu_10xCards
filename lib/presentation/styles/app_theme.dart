import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xcards/presentation/styles/app_text_styles.dart';
import 'package:xcards/presentation/styles/color_scheme_extension.dart';

/// Application-wide [ThemeData] definitions.
/// Access via `lightTheme` / `darkTheme`.
class AppTheme {
  const AppTheme._();

  static ThemeData lightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        ColorSchemeExtension.light,
        AppTextStyles.light(),
      ],
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      colorScheme: base.colorScheme.copyWith(
        primary: ColorSchemeExtension.light.accentBlue,
        secondary: ColorSchemeExtension.light.accentBlue,
      ),
    );
  }

  static ThemeData darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        ColorSchemeExtension.dark,
        AppTextStyles.dark(),
      ],
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      colorScheme: base.colorScheme.copyWith(
        primary: ColorSchemeExtension.dark.accentBlue,
        secondary: ColorSchemeExtension.dark.accentBlue,
      ),
    );
  }
}
