import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xcards/l10n/l10n.dart';
import 'package:xcards/presentation/styles/app_dimensions.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(Widget widget) async {
    await binding.setSurfaceSize(AppDimensions.mobileMockSize);

    return pumpWidget(
      ScreenUtilInit(
        designSize: AppDimensions.mobileMockSize,

        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: widget,
        ),
      ),
    );
  }
}
