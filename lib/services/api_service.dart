import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/conversation.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final String baseUrl;
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? 'http://127.0.0.1:8000';

  Future<List<QuestionResponse>> getStageQuestions({
    required String conversationId,
    required String currentStage,
    required Map<String, dynamic> stageContext,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_stage_questions'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'conversation_id': conversationId,
        'current_stage': currentStage,
        'stage_context': stageContext,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == 'success') {
      return (data['data']['questions'] as List)
          .map((q) => QuestionResponse.fromJson(q))
          .toList();
    } else {
      throw Exception(data['error']?['message'] ?? 'Failed to get questions');
    }
  }

  Future<Map<String, dynamic>> proceedToNextStage({
    required String conversationId,
    required String currentStage,
    required Map<String, dynamic> stageContext,
    required List<dynamic> stageHistory,
    String? researchTopic,
    String? keywords,
  }) async {
    final url = '$baseUrl/proceed_to_next_stage';
    final body = jsonEncode({
      'conversation_id': conversationId,
      'current_stage': currentStage,
      'stage_context': stageContext,
      'stage_history': stageHistory,
      if (researchTopic != null) 'research_topic': researchTopic,
      if (keywords != null) 'keywords': keywords,
    });
    debugPrint('API REQUEST: $url\nBODY: $body');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    debugPrint('API RESPONSE: $url\nSTATUS: \\${response.statusCode}\\nBODY: \\${response.body}');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == 'success') {
      if (data['data'] == null || data['data']['next_stage'] == null) {
        throw Exception('Invalid response: missing next_stage');
      }
      return data['data'];
    } else {
      throw Exception(data['error']?['message'] ?? 'Failed to proceed to next stage');
    }
  }

  Future<Map<String, dynamic>> askLLM({
    required String conversationId,
    required String question,
    required String stage,
    required Map<String, dynamic> context,
    required int questionIndex,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ask_llm'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'conversation_id': conversationId,
        'question': question,
        'stage': stage,
        'context': context,
        'question_index': questionIndex,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == 'success') {
      return data['data'];
    } else {
      throw Exception(data['error']?['message'] ?? 'Failed to get LLM response');
    }
  }

  Future<Map<String, dynamic>> reviewResponse({
    required String conversationId,
    required String stage,
    required String question,
    required String responseText,
    required Map<String, dynamic> context,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/review_response'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'conversation_id': conversationId,
        'stage': stage,
        'question': question,
        'response': responseText,
        'context': context,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == 'success') {
      return data['data'];
    } else {
      throw Exception(data['error']?['message'] ?? 'Failed to review response');
    }
  }

  Future<Map<String, dynamic>> checkStageCompletion({
    required String conversationId,
    required String stage,
    required List<dynamic> questionHistory,
    required Map<String, dynamic> context,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/check_stage_completion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'conversation_id': conversationId,
        'stage': stage,
        'question_history': questionHistory,
        'context': context,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == 'success') {
      return data['data'];
    } else {
      throw Exception(data['error']?['message'] ?? 'Failed to check stage completion');
    }
  }

  Future<Map<String, dynamic>> runPipeline({
    required String researchTopic,
    required String keywords,
    String questionType = 'default',
  }) async {
    final url = '$baseUrl/run_pipeline';
    final body = jsonEncode({
      'research_context': researchTopic,
      'keywords': keywords,
      'question_type': questionType,
    });
    debugPrint('API REQUEST: $url\nBODY: $body');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    debugPrint('API RESPONSE: $url\nSTATUS: \\${response.statusCode}\\nBODY: \\${response.body}');
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] == 'success') {
      if (data['conversation_id'] == null || data['data'] == null) {
        throw Exception('Invalid response: missing conversation_id or data');
      }
      if (data['data']['llm_response'] == null) {
        throw Exception('Invalid response: missing llm_response');
      }
      return data;
    } else {
      throw Exception(data['error']?['message'] ?? 'Failed to run pipeline');
    }
  }
} 