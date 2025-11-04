import 'package:auto_route/auto_route.dart';
import 'package:xcards/app/routing/app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: CounterRoute.page, path: '/counter', initial: true),
  ];
}
