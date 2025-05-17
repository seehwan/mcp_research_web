import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/conversation.dart';
import '../constants/app_constants.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    if (currentStage == 'questioning') {
      return const SizedBox.shrink();
    }

    final questions = AppConstants.stageQuestionTemplates[currentStage] ?? [];
    if (questions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '질문 응답',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              currentQuestion,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (llmResponse.isNotEmpty) ...[
              Text(
                'LLM 응답',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: MarkdownBody(
                  data: llmResponse,
                  selectable: true,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (questionHistory.isNotEmpty) ...[
              Text(
                '이전 질문과 응답',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _buildQuestionHistory(context),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: TextEditingController(text: userResponse)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: userResponse.length),
                ),
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: '응답',
                hintText: '답변을 입력하세요',
                border: OutlineInputBorder(),
              ),
              enabled: !isLoading,
              onChanged: onUserResponseChanged,
            ),
            const SizedBox(height: 16),
            if (suggestedQuestions.isNotEmpty) ...[
              Text(
                '추천 질문',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestedQuestions.map((question) {
                  return ActionChip(
                    label: Text(question),
                    onPressed: () => onUserResponseChanged(question),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: isLoading ? null : onPreviousQuestion,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: isLoading ? null : onNextQuestion,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('제출'),
                  onPressed: isLoading ? null : onSubmit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: questionHistory.map((qr) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q: ${qr.question}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text('A: ${qr.userResponse}'),
                const SizedBox(height: 4),
                MarkdownBody(
                  data: qr.llmResponse,
                  selectable: true,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
} 