import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../constants/app_constants.dart';
import '../constants/app_styles.dart';

class QuestionInput extends StatelessWidget {
  final String currentStage;
  final String currentQuestion;
  final String userResponse;
  final String llmResponse;
  final List<String> suggestedQuestions;
  final List<QuestionResponse> questionHistory;
  final bool isLoading;
  final Function(String) onUserResponseChanged;
  final VoidCallback onPreviousQuestion;
  final VoidCallback onNextQuestion;
  final VoidCallback onCheckAdditionalQuestions;
  final VoidCallback onSubmit;
  final TextEditingController controller;

  const QuestionInput({
    super.key,
    required this.currentStage,
    required this.currentQuestion,
    required this.userResponse,
    required this.llmResponse,
    required this.suggestedQuestions,
    required this.questionHistory,
    required this.isLoading,
    required this.onUserResponseChanged,
    required this.onPreviousQuestion,
    required this.onNextQuestion,
    required this.onCheckAdditionalQuestions,
    required this.onSubmit,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (currentStage == 'questioning') {
      return const SizedBox.shrink();
    }

    final questions = AppConstants.stageQuestionTemplates[currentStage] ?? [];
    if (questions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '질문하기',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppStyles.spacingSmall),
        TextField(
          controller: controller,
          decoration: AppStyles.getInputDecoration(
            context: context,
            hintText: '질문을 입력하세요',
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: isLoading ? null : onSubmit,
            ),
          ),
          enabled: !isLoading,
          onSubmitted: (_) => onSubmit(),
        ),
        if (isLoading) ...[
          SizedBox(height: AppStyles.spacingMedium),
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ],
    );
  }
} 