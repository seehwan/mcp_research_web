import 'package:flutter/material.dart';
import '../constants/app_styles.dart';

class ResearchTopicInput extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController keywordsController;
  final TextEditingController researchGoalController;
  final TextEditingController researchProblemController;
  final TextEditingController approachController;
  final TextEditingController motivationController;
  final TextEditingController challengesController;
  final TextEditingController contributionController;
  final bool isLoading;
  final VoidCallback onSubmit;

  const ResearchTopicInput({
    super.key,
    required this.controller,
    required this.keywordsController,
    required this.researchGoalController,
    required this.researchProblemController,
    required this.approachController,
    required this.motivationController,
    required this.challengesController,
    required this.contributionController,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '연구 주제 입력',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: AppStyles.getInputDecoration(
                  context: context,
                  labelText: '연구 주제',
                  hintText: '연구 주제를 입력하세요',
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: keywordsController,
                decoration: AppStyles.getInputDecoration(
                  context: context,
                  labelText: '키워드',
                  hintText: '쉼표로 구분된 키워드를 입력하세요',
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 24),
              Text(
                '연구 질문',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '0) 이 연구의 목적이 무엇인가요?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: researchGoalController,
                      decoration: AppStyles.getInputDecoration(
                        context: context,
                        labelText: '연구 목적',
                      ),
                      maxLines: 3,
                      enabled: !isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1) 이 연구가 풀고자하는 문제가 무엇인가요?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: researchProblemController,
                      decoration: AppStyles.getInputDecoration(
                        context: context,
                        labelText: '연구 문제',
                      ),
                      maxLines: 3,
                      enabled: !isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2) 이 문제를 어떻게 풀고자하나요?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: approachController,
                      decoration: AppStyles.getInputDecoration(
                        context: context,
                        labelText: '접근 방법',
                      ),
                      maxLines: 3,
                      enabled: !isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3) 이 연구를 통해 도움을 받을 수 있는 응용분야가 무엇인가요?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: motivationController,
                      decoration: AppStyles.getInputDecoration(
                        context: context,
                        labelText: '연구 동기',
                      ),
                      maxLines: 3,
                      enabled: !isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '4) 이 문제를 푸는 것이 왜 어려운가요?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: challengesController,
                      decoration: AppStyles.getInputDecoration(
                        context: context,
                        labelText: '도전 과제',
                      ),
                      maxLines: 3,
                      enabled: !isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '5) 주요 기여점은 무엇인가요?',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: contributionController,
                      decoration: AppStyles.getInputDecoration(
                        context: context,
                        labelText: '주요 기여점',
                      ),
                      maxLines: 3,
                      enabled: !isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: isLoading ? null : onSubmit,
                  style: AppStyles.getButtonStyle(context: context),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('시작하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 