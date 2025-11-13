import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:xcards/l10n/l10n.dart';

@RoutePage()
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.statsTitle)),
      body: Center(child: Text(context.l10n.statsTitle)),
    );
  }
}
