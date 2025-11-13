import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xcards/app/extensions/build_context_extension.dart';
import 'package:xcards/features/generation/presentation/cubit/generation_cubit.dart';
import 'package:xcards/l10n/l10n.dart';
import 'package:xcards/presentation/common_widgets/common_widgets.dart';
import 'package:xcards/presentation/styles/app_dimensions.dart';

class Step1InputView extends StatefulWidget {
  const Step1InputView({super.key});

  @override
  State<Step1InputView> createState() => _Step1InputViewState();
}

class _Step1InputViewState extends State<Step1InputView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currentLength = _controller.text.length;
    final isValid = currentLength >= 1000 && currentLength <= 10000;

    return Padding(
      padding: EdgeInsets.all(AppDimensions.padding16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLength: 10000,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: l10n.generationInputHint,
                border: const OutlineInputBorder(),
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(height: AppDimensions.h16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.generationCharCounter(currentLength),
                style: TextStyle(
                  color: currentLength > 10000
                      ? context.colors.errorRed
                      : currentLength < 1000
                      ? context.theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        )
                      : context.colors.successGreen,
                ),
              ),
              if (currentLength < 1000)
                Text(
                  l10n.generationMinChars,
                  style: TextStyle(
                    color: context.theme.colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          SizedBox(height: AppDimensions.h16),
          AppButton(
            onPressed: isValid
                ? () async {
                    await context.read<GenerationCubit>().generate(
                      text: _controller.text,
                    );
                  }
                : null,
            isFullWidth: true,
            child: Text(l10n.generationGenerateButton),
          ),
        ],
      ),
    );
  }
}
