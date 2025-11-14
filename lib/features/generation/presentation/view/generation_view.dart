import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xcards/app/extensions/build_context_extension.dart';
import 'package:xcards/features/generation/presentation/cubit/generation_cubit.dart';
import 'package:xcards/features/generation/presentation/widgets/step1_input_view.dart';
import 'package:xcards/features/generation/presentation/widgets/step2_proposals_view.dart';
import 'package:xcards/l10n/l10n.dart';
import 'package:xcards/presentation/common_widgets/common_widgets.dart';

class GenerationView extends StatelessWidget {
  const GenerationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.generationTitle)),
      body: BlocConsumer<GenerationCubit, GenerationState>(
        listener: (context, state) {
          if (state.status == GenerationStatus.failure &&
              state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.failure?.message ??
                      context.l10n.generationErrorUnexpected,
                ),
              ),
            );
          }
          if (state.status == GenerationStatus.success) {
            context.router.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.l10n.generationSuccessSaved(state.accepted.length),
                ),
                backgroundColor: context.colors.successGreen,
              ),
            );
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case GenerationStatus.initial:
            case GenerationStatus.validating:
              return const Step1InputView();
            case GenerationStatus.loading:
              return AppLoadingIndicator(
                message: context.l10n.generationLoading,
              );
            case GenerationStatus.ready:
            case GenerationStatus.saving:
              return const Step2ProposalsView();
            case GenerationStatus.success:
            case GenerationStatus.failure:
              return const Step1InputView();
          }
        },
      ),
    );
  }
}
