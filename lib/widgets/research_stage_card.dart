import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../constants/app_constants.dart';
import '../constants/app_styles.dart';

class ResearchStageCard extends StatelessWidget {
  final Stage stage;
  final String content;
  final bool isActive;
  final VoidCallback? onTap;
  final bool isSelectable;

  const ResearchStageCard({
    super.key,
    required this.stage,
    required this.content,
    this.isActive = false,
    this.onTap,
    this.isSelectable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: isActive ? 4 : 1,
      color: isActive
          ? (isDark ? Colors.blueGrey[800] : Colors.blue[50])
          : (isDark ? Colors.blueGrey[900] : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.cardBorderRadius),
        side: BorderSide(
          color: isActive
              ? theme.colorScheme.primary
              : (isDark ? Colors.blueGrey[700]! : Colors.grey[300]!),
          width: isActive ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isSelectable ? onTap : null,
        borderRadius: BorderRadius.circular(AppStyles.cardBorderRadius),
        child: Padding(
          padding: EdgeInsets.all(AppStyles.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    AppConstants.stageIcons[stage.name] ?? '📝',
                    style: const TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: AppStyles.spacingSmall),
                  Expanded(
                    child: Text(
                      AppConstants.stageNames[stage.name] ?? stage.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.textTheme.titleMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppStyles.spacingSmall),
              Text(
                AppConstants.stageDescriptions[stage.name] ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.blueGrey[300] : Colors.grey[700],
                ),
              ),
              if (content.isNotEmpty) ...[
                SizedBox(height: AppStyles.spacingMedium),
                Container(
                  padding: EdgeInsets.all(AppStyles.spacingSmall),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blueGrey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(AppStyles.inputBorderRadius),
                  ),
                  child: MarkdownBody(
                    data: content,
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
              ],
              if (isActive) ...[
                SizedBox(height: AppStyles.spacingMedium),
                Text(
                  '가이드라인:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppStyles.spacingSmall),
                ...AppConstants.stageGuidelines[stage.name]?.map(
                  (guideline) => Padding(
                    padding: EdgeInsets.only(bottom: AppStyles.spacingSmall),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: theme.textTheme.bodyMedium),
                        Expanded(
                          child: Text(
                            guideline,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ) ?? [],
              ],
            ],
          ),
        ),
      ),
    );
  }
} 