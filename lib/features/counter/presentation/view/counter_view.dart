import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xcards/features/counter/presentation/cubit/counter_cubit.dart';
import 'package:xcards/features/counter/presentation/widgets/counter_text_widget.dart';
import 'package:xcards/l10n/l10n.dart';
import 'package:xcards/presentation/styles/app_dimensions.dart';

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.counterAppBarTitle), centerTitle: true),
      body: Center(
        child: BlocBuilder<CounterCubit, CounterState>(
          builder: (context, state) {
            return state.when(
              initial: () => const CounterTextWidget(count: 0),
              data: (model) => CounterTextWidget(count: model.count),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: context.read<CounterCubit>().increment,
            child: const Icon(Icons.add),
          ),
          SizedBox(height: AppDimensions.h8),
          FloatingActionButton(
            onPressed: context.read<CounterCubit>().decrement,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
