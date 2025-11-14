import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xcards/app/extensions/build_context_extension.dart';
import 'package:xcards/app/networking/entities/responses/flashcard_proposal_entity.dart';
import 'package:xcards/features/generation/presentation/cubit/generation_cubit.dart';
import 'package:xcards/features/generation/presentation/widgets/flashcard_swipe_card.dart';
import 'package:xcards/l10n/l10n.dart';
import 'package:xcards/presentation/common_widgets/common_widgets.dart';
import 'package:xcards/presentation/styles/app_dimensions.dart';

class Step2ProposalsView extends StatelessWidget {
  const Step2ProposalsView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GenerationCubit>();
    final state = context.watch<GenerationCubit>().state;

    return Column(
      children: [
        Expanded(
          child: state.proposals.isEmpty
              ? _buildEmptyState(context)
              : _buildSwipeStack(context, state.proposals, cubit),
        ),
        _buildCountersPanel(context, state),
        _buildActionButtons(context, state, cubit),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return AppEmptyState(
      icon: Icons.check_circle_outline,
      title: context.l10n.generationAllReviewed,
    );
  }

  Widget _buildSwipeStack(
    BuildContext context,
    List<FlashcardProposalEntity> proposals,
    GenerationCubit cubit,
  ) {
    return Stack(
      children: [
        for (int i = proposals.length - 1; i >= 0; i--)
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: (proposals.length - 1 - i) * AppDimensions.h8,
              ),
              child: i == 0
                  ? FlashcardSwipeCard(
                      proposal: proposals[i],
                      onSwipeLeft: () => cubit.swipeReject(0),
                      onSwipeRight: () => cubit.swipeAccept(0),
                      onEdit: () =>
                          _showEditDialog(context, proposals[i], cubit),
                    )
                  : _buildStackedCard(context, proposals[i]),
            ),
          ),
      ],
    );
  }

  Widget _buildStackedCard(
    BuildContext context,
    FlashcardProposalEntity proposal,
  ) {
    return AppCard(
      elevation: 2,
      margin: EdgeInsets.all(AppDimensions.padding16),
      padding: EdgeInsets.all(AppDimensions.padding24),
      child: Center(
        child: Text(
          proposal.front,
          style: context.typography.headlineSmall,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildCountersPanel(BuildContext context, GenerationState state) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.padding16),
      color: context.colors.surfaceVariant,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCounter(
            context,
            context.l10n.generationCounterAccepted,
            state.accepted.length,
            context.colors.successGreen,
          ),
          _buildCounter(
            context,
            context.l10n.generationCounterEdited,
            state.editedIds.length,
            context.colors.warningOrange,
          ),
          _buildCounter(
            context,
            context.l10n.generationCounterRemaining,
            state.proposals.length,
            context.colors.infoBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(
    BuildContext context,
    String label,
    int count,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: context.typography.headlineMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: context.typography.bodySmall),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    GenerationState state,
    GenerationCubit cubit,
  ) {
    final hasAccepted = state.accepted.isNotEmpty;

    return Padding(
      padding: EdgeInsets.all(AppDimensions.padding16),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              onPressed: () => Navigator.of(context).pop(),
              variant: AppButtonVariant.outlined,
              child: Text(context.l10n.generationButtonCancel),
            ),
          ),
          SizedBox(width: AppDimensions.w16),
          Expanded(
            flex: 2,
            child: AppButton(
              onPressed: hasAccepted ? () => cubit.saveAccepted() : null,
              child: Text(
                context.l10n.generationButtonSave(state.accepted.length),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    FlashcardProposalEntity proposal,
    GenerationCubit cubit,
  ) async {
    final frontController = TextEditingController(text: proposal.front);
    final backController = TextEditingController(text: proposal.back);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.generationEditDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: frontController,
              labelText: context.l10n.generationEditDialogFrontLabel,
              maxLength: 200,
            ),
            SizedBox(height: AppDimensions.h16),
            AppTextField(
              controller: backController,
              labelText: context.l10n.generationEditDialogBackLabel,
              maxLength: 500,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          AppButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            variant: AppButtonVariant.text,
            child: Text(context.l10n.generationEditDialogCancel),
          ),
          AppButton(
            onPressed: () {
              cubit.editProposal(
                0,
                FlashcardProposalEntity(
                  front: frontController.text,
                  back: backController.text,
                ),
              );
              Navigator.of(dialogContext).pop();
            },
            child: Text(context.l10n.generationEditDialogSave),
          ),
        ],
      ),
    );

    frontController.dispose();
    backController.dispose();
  }
}
