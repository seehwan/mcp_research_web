import 'package:flutter/material.dart';
import '../constants/app_styles.dart';

class QuestionSelection extends StatelessWidget {
  final List<String> questions;
  final List<String> selectedQuestions;
  final Function(String) onQuestionSelected;
  final VoidCallback onGenerateMore;
  final bool isLoading;

  const QuestionSelection({
    super.key,
    required this.questions,
    required this.selectedQuestions,
    required this.onQuestionSelected,
    required this.onGenerateMore,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '질문 선택',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: isLoading ? null : onGenerateMore,
              icon: const Icon(Icons.refresh),
              label: const Text('더 생성하기'),
              style: AppStyles.getButtonStyle(
                context: context,
                isPrimary: false,
              ),
            ),
          ],
        ),
        SizedBox(height: AppStyles.spacingMedium),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Wrap(
            spacing: AppStyles.spacingSmall,
            runSpacing: AppStyles.spacingSmall,
            children: questions.map((question) {
              final isSelected = selectedQuestions.contains(question);
              return FilterChip(
                label: Text(question),
                selected: isSelected,
                onSelected: (selected) => onQuestionSelected(question),
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primary.withAlpha(51),
                checkmarkColor: theme.colorScheme.primary,
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyMedium?.color,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
} 