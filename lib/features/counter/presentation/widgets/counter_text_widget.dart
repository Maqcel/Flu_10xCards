import 'package:flutter/material.dart';

class CounterTextWidget extends StatelessWidget {
  const CounterTextWidget({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text('$count', style: theme.textTheme.displayLarge);
  }
}
