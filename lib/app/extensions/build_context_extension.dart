import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:xcards/presentation/styles/app_text_styles.dart';
import 'package:xcards/presentation/styles/color_scheme_extension.dart';

extension BuildContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorSchemeExtension get colors =>
      Theme.of(this).extension<ColorSchemeExtension>() ??
      ColorSchemeExtension.light;

  AppTextStyles get typography =>
      Theme.of(this).extension<AppTextStyles>() ?? AppTextStyles.light();

  StackRouter get appRouter => AutoRouter.of(this);
}
