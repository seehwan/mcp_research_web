import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_styles.dart';
import '../models/research_state.dart';

class StageControls extends StatelessWidget {
  final ResearchState state;
  final VoidCallback onNextStage;
  final VoidCallback onPreviousStage;
  final VoidCallback onReset;

  const StageControls({
    super.key,
    required this.state,
    required this.onNextStage,
    required this.onPreviousStage,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final currentIndex = AppConstants.stageProgression.indexOf(state.currentStage);
    final isFirstStage = currentIndex == 0;
    final isLastStage = currentIndex == AppConstants.stageProgression.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (!isFirstStage)
              ElevatedButton.icon(
                onPressed: onPreviousStage,
                icon: const Icon(Icons.arrow_back),
                label: const Text('이전 단계'),
                style: AppStyles.getButtonStyle(
                  context: context,
                  isPrimary: false,
                ),
              ),
            if (!isFirstStage) SizedBox(width: AppStyles.spacingMedium),
            ElevatedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh),
              label: const Text('초기화'),
              style: AppStyles.getButtonStyle(
                context: context,
                isPrimary: false,
                isOutlined: true,
              ),
            ),
          ],
        ),
        if (!isLastStage)
          ElevatedButton.icon(
            onPressed: onNextStage,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('다음 단계'),
            style: AppStyles.getButtonStyle(context: context),
          ),
      ],
    );
  }
} 