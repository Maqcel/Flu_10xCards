import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xcards/app/di/injection.dart';
import 'package:xcards/features/generation/presentation/cubit/generation_cubit.dart';
import 'package:xcards/features/generation/presentation/view/generation_view.dart';

@RoutePage()
class GenerationPage extends StatelessWidget implements AutoRouteWrapper {
  const GenerationPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider<GenerationCubit>(
    create: (_) => getIt<GenerationCubit>(),
    child: this,
  );

  @override
  Widget build(BuildContext context) => const GenerationView();
}
