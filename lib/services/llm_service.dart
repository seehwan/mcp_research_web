import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/conversation.dart';
import 'http_client.dart';
import 'base_service.dart';

class LLMService extends BaseService {
  LLMService() : super(
    client: HttpClient(
      baseUrl: AppConstants.apiBaseUrl,
      maxRetries: 3,
      retryDelay: const Duration(seconds: 1),
    ),
  );

  Future<Map<String, dynamic>> generateResponse({
    required String prompt,
    required String context,
    required List<Map<String, dynamic>> conversationHistory,
  }) async {
    return handleApiCall(
      apiCall: () => post(
        endpoint: 'generate-response',
        body: {
          'prompt': prompt,
          'context': context,
          'conversation_history': conversationHistory,
        },
        debug: kDebugMode,
      ),
      operationName: 'generate response',
      defaultErrorCode: ErrorCode.llmError,
      defaultErrorMessage: 'An unexpected error occurred while communicating with LLM',
    );
  }

  Future<Map<String, dynamic>> analyzeResponse({
    required String response,
    required String context,
  }) async {
    return handleApiCall(
      apiCall: () => post(
        endpoint: 'analyze-response',
        body: {
          'response': response,
          'context': context,
        },
        debug: kDebugMode,
      ),
      operationName: 'analyze response',
      defaultErrorCode: ErrorCode.llmError,
      defaultErrorMessage: 'An unexpected error occurred while analyzing response',
    );
  }
} 