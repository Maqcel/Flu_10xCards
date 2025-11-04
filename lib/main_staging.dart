import 'package:xcards/app/app.dart';
import 'package:xcards/bootstrap.dart';

Future<void> main() async {
  await bootstrap((router) => App(appRouter: router));
}
