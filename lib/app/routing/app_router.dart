import 'package:auto_route/auto_route.dart';
import 'package:xcards/app/routing/app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: MainShellRoute.page,
      path: '/',
      initial: true,
      children: [
        AutoRoute(page: DashboardRoute.page, path: 'dashboard'),
        AutoRoute(page: LearningSessionRoute.page, path: 'learn'),
        AutoRoute(page: StatisticsRoute.page, path: 'stats'),
        AutoRoute(page: SettingsRoute.page, path: 'settings'),
      ],
    ),
    AutoRoute(
      page: GenerationRoute.page,
      path: '/generate',
      fullscreenDialog: true,
    ),
  ];
}
