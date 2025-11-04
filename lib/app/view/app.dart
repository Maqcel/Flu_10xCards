import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:xcards/l10n/l10n.dart';
import 'package:xcards/presentation/styles/app_dimensions.dart';

class App extends StatelessWidget {
  const App({required RootStackRouter appRouter, super.key})
    : _appRouter = appRouter;

  final RootStackRouter _appRouter;

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    designSize: AppDimensions.mobileMockSize,
    builder: (context, _) => MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _appRouter.config(),
    ),
  );
}
