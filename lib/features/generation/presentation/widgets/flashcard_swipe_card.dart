import 'package:flutter/material.dart';
import 'package:xcards/app/extensions/build_context_extension.dart';
import 'package:xcards/app/networking/entities/responses/flashcard_proposal_entity.dart';
import 'package:xcards/l10n/l10n.dart';
import 'package:xcards/presentation/common_widgets/common_widgets.dart';
import 'package:xcards/presentation/styles/app_dimensions.dart';

class FlashcardSwipeCard extends StatefulWidget {
  const FlashcardSwipeCard({
    required this.proposal,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onEdit,
    super.key,
  });

  final FlashcardProposalEntity proposal;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onEdit;

  @override
  State<FlashcardSwipeCard> createState() => _FlashcardSwipeCardState();
}

class _FlashcardSwipeCardState extends State<FlashcardSwipeCard> {
  bool _showBack = false;

  void _flipCard() => setState(() => _showBack = !_showBack);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(widget.proposal.hashCode),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          widget.onSwipeRight();
        } else {
          widget.onSwipeLeft();
        }
      },
      background: _buildSwipeBackground(
        context,
        Alignment.centerLeft,
        context.colors.successGreen,
        Icons.check,
      ),
      secondaryBackground: _buildSwipeBackground(
        context,
        Alignment.centerRight,
        context.colors.errorRed,
        Icons.close,
      ),
      child: GestureDetector(
        onTap: _flipCard,
        child: AppCard(
          elevation: 8,
          margin: EdgeInsets.all(AppDimensions.padding16),
          padding: EdgeInsets.all(AppDimensions.padding24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      _showBack ? widget.proposal.back : widget.proposal.front,
                      style: context.typography.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppDimensions.h24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton.filled(
                    onPressed: widget.onSwipeLeft,
                    icon: const Icon(Icons.close),
                    color: context.colors.mainWhite,
                    style: IconButton.styleFrom(
                      backgroundColor: context.colors.errorRed,
                      padding: EdgeInsets.all(AppDimensions.padding16),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit),
                    color: context.colors.mainWhite,
                    style: IconButton.styleFrom(
                      backgroundColor: context.colors.warningOrange,
                      padding: EdgeInsets.all(AppDimensions.padding16),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: widget.onSwipeRight,
                    icon: const Icon(Icons.check),
                    color: context.colors.mainWhite,
                    style: IconButton.styleFrom(
                      backgroundColor: context.colors.successGreen,
                      padding: EdgeInsets.all(AppDimensions.padding16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppDimensions.h16),
              Text(
                _showBack
                    ? context.l10n.generationCardBackLabel
                    : context.l10n.generationCardFrontLabel,
                style: context.typography.bodySmall.copyWith(
                  color: context.theme.colorScheme.onSurface.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context,
    Alignment alignment,
    Color color,
    IconData icon,
  ) {
    return Container(
      alignment: alignment,
      color: color.withValues(alpha: 0.2),
      padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding32),
      child: Icon(icon, size: AppDimensions.iconSize48, color: color),
    );
  }
}
