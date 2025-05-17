import 'package:flutter/material.dart';
import 'package:mcp_research_web/constants/app_constants.dart';

class QuestionSelection extends StatelessWidget {
  final String currentStage;
  final List<String> generatedQuestions;
  final int currentQuestionIndex;
  final Function(int) onQuestionSelected;
  final Function(String) onQuestionModified;
  final Function() onAddQuestion;
  final Function() onRemoveQuestion;
  final Function() onRegenerateQuestions;

  const QuestionSelection({
    super.key,
    required this.currentStage,
    required this.generatedQuestions,
    required this.currentQuestionIndex,
    required this.onQuestionSelected,
    required this.onQuestionModified,
    required this.onAddQuestion,
    required this.onRemoveQuestion,
    required this.onRegenerateQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${AppConstants.stageNames[currentStage] ?? currentStage} 단계 질문',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: onRegenerateQuestions,
                      tooltip: '질문 재생성',
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: onAddQuestion,
                      tooltip: '질문 추가',
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: onRemoveQuestion,
                      tooltip: '질문 제거',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (generatedQuestions.isEmpty)
              const Center(
                child: Text('생성된 질문이 없습니다.'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: generatedQuestions.length,
                itemBuilder: (context, index) {
                  final isSelected = index == currentQuestionIndex;
                  return Card(
                    color: isSelected ? Colors.blue.shade50 : null,
                    child: ListTile(
                      title: Text(
                        generatedQuestions[index],
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onTap: () => onQuestionSelected(index),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              final controller = TextEditingController(
                                text: generatedQuestions[index],
                              );
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('질문 수정'),
                                  content: TextField(
                                    controller: controller,
                                    decoration: const InputDecoration(
                                      labelText: '질문',
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLines: 3,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        onQuestionModified(controller.text);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('저장'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
} 