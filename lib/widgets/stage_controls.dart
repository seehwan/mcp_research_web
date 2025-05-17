import 'package:flutter/material.dart';
import 'package:mcp_research_web/constants/app_constants.dart';

class StageControls extends StatelessWidget {
  final String currentStage;
  final bool isLoading;
  final Function(String) onStageSelected;
  final Function() onProceedToNextStage;

  const StageControls({
    super.key,
    required this.currentStage,
    required this.isLoading,
    required this.onStageSelected,
    required this.onProceedToNextStage,
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
            const Text(
              '단계 제어',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: currentStage,
                    decoration: const InputDecoration(
                      labelText: '현재 단계',
                      border: OutlineInputBorder(),
                    ),
                    items: AppConstants.stageNames.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: isLoading ? null : (value) {
                      if (value != null) {
                        onStageSelected(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('다음 단계로'),
                    onPressed: isLoading ? null : onProceedToNextStage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 