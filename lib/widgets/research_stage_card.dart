import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResearchStageCard extends StatelessWidget {
  final String llmResponse;

  const ResearchStageCard({Key? key, required this.llmResponse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LLM 응답',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: '복사하기',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: llmResponse));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('텍스트가 클립보드에 복사되었습니다'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  llmResponse,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                  toolbarOptions: const ToolbarOptions(
                    copy: true,
                    selectAll: true,
                    cut: false,
                    paste: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 