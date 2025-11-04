import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xcards/app/di/injection.dart';
import 'package:xcards/features/counter/presentation/cubit/counter_cubit.dart';
import 'package:xcards/features/counter/presentation/view/counter_view.dart';

@RoutePage()
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>(
      create: (_) => getIt<CounterCubit>(),
      child: const CounterView(),
    );
  }
}
