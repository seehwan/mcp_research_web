import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/conversation.dart';

class LLMService {
  final _logger = Logger('LLMService');
  final String _apiKey = const String.fromEnvironment('OPENAI_API_KEY');
  final String _apiUrl = 'https://api.openai.com/v1/chat/completions';

  String formatPrompt({
    required String stage,
    required Map<String, dynamic> context,
    required String question,
    required String userResponse,
    required List<QuestionResponse> questionHistory,
  }) {
    final prompt = '''
현재 연구 단계: ${stage}

연구 컨텍스트:
${_formatContext(context)}

이전 질문과 응답:
${_formatQuestionHistory(questionHistory)}

현재 질문: $question
사용자 응답: $userResponse

위 정보를 바탕으로 다음을 포함하는 상세한 응답을 제공해주세요:
1. 사용자 응답에 대한 분석
2. 다음 단계를 위한 제안
3. 잠재적인 우려사항이나 고려해야 할 점
4. 연구 목표 달성에 기여하는 부분

응답은 마크다운 형식으로 작성해주세요.
''';

    return prompt;
  }

  String _formatContext(Map<String, dynamic> context) {
    final buffer = StringBuffer();
    context.forEach((key, value) {
      buffer.writeln('- $key: $value');
    });
    return buffer.toString();
  }

  String _formatQuestionHistory(List<QuestionResponse> history) {
    if (history.isEmpty) return '이전 질문 없음';

    final buffer = StringBuffer();
    for (final qr in history) {
      buffer.writeln('Q: ${qr.question}');
      buffer.writeln('A: ${qr.userResponse}');
      buffer.writeln('LLM: ${qr.llmResponse}');
      buffer.writeln('---');
    }
    return buffer.toString();
  }

  List<String> extractSuggestedQuestions(String llmResponse) {
    try {
      final questions = <String>[];
      final lines = llmResponse.split('\n');
      var inQuestionSection = false;

      for (final line in lines) {
        if (line.trim().toLowerCase().contains('추가 질문') ||
            line.trim().toLowerCase().contains('suggested questions')) {
          inQuestionSection = true;
          continue;
        }

        if (inQuestionSection) {
          if (line.trim().isEmpty) {
            inQuestionSection = false;
            continue;
          }

          if (line.trim().startsWith('-') || line.trim().startsWith('*')) {
            questions.add(line.trim().substring(1).trim());
          }
        }
      }

      return questions;
    } catch (e) {
      _logger.warning('Error extracting suggested questions: $e');
      return [];
    }
  }

  Map<String, dynamic> parseLLMResponse(String response) {
    try {
      final sections = <String, String>{};
      var currentSection = '';
      var currentContent = StringBuffer();

      final lines = response.split('\n');
      for (final line in lines) {
        if (line.trim().startsWith('#')) {
          if (currentSection.isNotEmpty) {
            sections[currentSection] = currentContent.toString().trim();
            currentContent.clear();
          }
          currentSection = line.trim().substring(1).trim();
        } else {
          currentContent.writeln(line);
        }
      }

      if (currentSection.isNotEmpty) {
        sections[currentSection] = currentContent.toString().trim();
      }

      return sections;
    } catch (e) {
      _logger.warning('Error parsing LLM response: $e');
      return {'error': 'Failed to parse LLM response'};
    }
  }

  Future<String> generateResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a research assistant helping with academic research. Provide detailed, well-structured responses in markdown format.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        _logger.severe('Error calling LLM API: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to generate LLM response');
      }
    } catch (e) {
      _logger.severe('Error in generateResponse: $e');
      throw Exception('Failed to generate LLM response: $e');
    }
  }

  Future<Map<String, dynamic>> reviewResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a research assistant evaluating research responses. Provide feedback and suggestions in a structured format.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.3,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // 응답을 구조화된 형식으로 파싱
        final sections = parseLLMResponse(content);
        return {
          'is_valid': sections['validation']?.toLowerCase().contains('valid') ?? false,
          'feedback': sections['feedback'] ?? 'No feedback provided',
          'suggestions': sections['suggestions']?.split('\n').where((s) => s.trim().isNotEmpty).toList() ?? [],
          'confidence': 0.9,
        };
      } else {
        _logger.severe('Error calling LLM API: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to review response');
      }
    } catch (e) {
      _logger.severe('Error in reviewResponse: $e');
      throw Exception('Failed to review response: $e');
    }
  }
} 