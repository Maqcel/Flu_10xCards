import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:xcards/l10n/l10n.dart';

@RoutePage()
class LearningSessionPage extends StatelessWidget {
  const LearningSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.learnTitle)),
      body: Center(child: Text(context.l10n.learnTitle)),
    );
  }
}
