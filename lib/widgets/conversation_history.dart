import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../constants/app_styles.dart';
import '../models/conversation.dart';

class ConversationHistory extends StatelessWidget {
  final List<ConversationMessage> messages;
  final ScrollController scrollController;

  const ConversationHistory({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '대화 기록',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppStyles.spacingMedium),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isUser = message.role == 'user';

              return Padding(
                padding: EdgeInsets.only(bottom: AppStyles.spacingMedium),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: isUser
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary,
                      child: Icon(
                        isUser ? Icons.person : Icons.assistant,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(width: AppStyles.spacingSmall),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(AppStyles.spacingSmall),
                        decoration: BoxDecoration(
                          color: isUser
                              ? (isDark ? Colors.blueGrey[800] : Colors.blue[50])
                              : (isDark ? Colors.blueGrey[900] : Colors.grey[100]),
                          borderRadius: BorderRadius.circular(AppStyles.cardBorderRadius),
                        ),
                        child: MarkdownBody(
                          data: message.content,
                          styleSheet: MarkdownStyleSheet(
                            p: theme.textTheme.bodyMedium,
                            h1: theme.textTheme.titleLarge,
                            h2: theme.textTheme.titleMedium,
                            h3: theme.textTheme.titleSmall,
                            blockquote: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.blueGrey[300] : Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                            code: theme.textTheme.bodyMedium?.copyWith(
                              backgroundColor: isDark ? Colors.blueGrey[900] : Colors.grey[200],
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 