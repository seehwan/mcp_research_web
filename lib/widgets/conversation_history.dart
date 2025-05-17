import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mcp_research_web/models/conversation.dart';

class ConversationHistory extends StatelessWidget {
  final List<ConversationMessage> messages;
  final Function(int)? onEditMessage;
  final Object? Function(Object?)? toEncodable;

  const ConversationHistory({
    super.key,
    required this.messages,
    this.onEditMessage,
    this.toEncodable,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        Widget messageWidget;

        switch (message.type) {
          case MessageType.USER:
            messageWidget = _buildUserMessage(message.content);
            break;
          case MessageType.ERROR:
            messageWidget = _buildErrorMessage(message.content);
            break;
          case MessageType.SYSTEM:
            final content = jsonDecode(message.content) as Map<String, dynamic>;
            messageWidget = _buildSystemMessage(content);
            break;
          case MessageType.LLM:
            messageWidget = _buildLLMMessage(message.content);
            break;
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getMessageTypeLabel(message.type),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      message.timestamp.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                messageWidget,
                if (message.metadata != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: _buildMetadata(message.metadata!, context),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserMessage(String content) {
    return Text(content);
  }

  Widget _buildErrorMessage(String content) {
    return Text(
      content,
      style: const TextStyle(color: Colors.red),
    );
  }

  Widget _buildSystemMessage(Map<String, dynamic> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          content['step'] as String,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(content['content'].toString()),
      ],
    );
  }

  Widget _buildLLMMessage(String content) {
    return MarkdownBody(
      data: content,
      selectable: true,
    );
  }

  Widget _buildMetadata(MessageMetadata metadata, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (metadata.confidence != null)
          Text('Confidence: ${metadata.confidence}'),
        if (metadata.sources != null && metadata.sources!.isNotEmpty)
          Text('Sources: ${metadata.sources!.join(", ")}'),
        if (metadata.stage != null)
          Text('Stage: ${metadata.stage!}'),
        if (metadata.questionIndex != null)
          Text('Question Index: ${metadata.questionIndex}'),
        if (metadata.additionalInfo != null)
          Text('Additional Info: ${metadata.additionalInfo}'),
      ],
    );
  }

  String _getMessageTypeLabel(MessageType type) {
    switch (type) {
      case MessageType.USER:
        return 'User';
      case MessageType.ERROR:
        return 'Error';
      case MessageType.SYSTEM:
        return 'System';
      case MessageType.LLM:
        return 'LLM';
    }
  }
} 