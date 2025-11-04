import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  StackRouter get appRouter => AutoRouter.of(this);
}
