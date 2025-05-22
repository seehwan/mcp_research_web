import '../models/conversation.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import 'http_client.dart';
import 'base_service.dart';

class ApiService extends BaseService {
  ApiService() : super(
    client: HttpClient(
      baseUrl: AppConstants.apiBaseUrl,
      maxRetries: 3,
      retryDelay: const Duration(seconds: 1),
    ),
  );

  Future<Map<String, dynamic>> generateQuestions({
    required String topic,
    required String stage,
    required List<Map<String, dynamic>> conversationHistory,
  }) async {
    return handleApiCall(
      apiCall: () => post(
        endpoint: 'generate-questions',
        body: {
          'topic': topic,
          'stage': stage,
          'conversation_history': conversationHistory,
        },
        debug: kDebugMode,
      ),
      operationName: 'generate questions',
      defaultErrorCode: ErrorCode.llmError,
      defaultErrorMessage: 'Failed to generate questions',
    );
  }

  Future<Map<String, dynamic>> generateAnswer({
    required String question,
    required String topic,
    required String stage,
    required List<Map<String, dynamic>> conversationHistory,
  }) async {
    return handleApiCall(
      apiCall: () => post(
        endpoint: 'generate-answer',
        body: {
          'question': question,
          'topic': topic,
          'stage': stage,
          'conversation_history': conversationHistory,
        },
        debug: kDebugMode,
      ),
      operationName: 'generate answer',
      defaultErrorCode: ErrorCode.llmError,
      defaultErrorMessage: 'Failed to generate answer',
    );
  }

  Future<List<QuestionResponse>> getStageQuestions({
    required String conversationId,
    required String currentStage,
    required Map<String, dynamic> stageContext,
  }) async {
    final data = await handleApiCall(
      apiCall: () => post(
        endpoint: 'get_stage_questions',
        body: {
          'conversation_id': conversationId,
          'current_stage': currentStage,
          'stage_context': stageContext,
        },
        debug: kDebugMode,
      ),
      operationName: 'get stage questions',
      defaultErrorCode: ErrorCode.validationError,
      defaultErrorMessage: 'Failed to get stage questions',
    );

    return (data['questions'] as List)
        .map((q) => QuestionResponse.fromJson(q))
        .toList();
  }

  Future<Map<String, dynamic>> proceedToNextStage({
    required String conversationId,
    required String currentStage,
    required Map<String, dynamic> stageContext,
    required List<dynamic> stageHistory,
    String? researchTopic,
    List<String>? keywords,
  }) async {
    final data = await handleApiCall(
      apiCall: () => post(
        endpoint: 'proceed_to_next_stage',
        body: {
          'conversation_id': conversationId,
          'current_stage': currentStage,
          'stage_context': stageContext,
          'stage_history': stageHistory,
          if (researchTopic != null) 'research_topic': researchTopic,
          if (keywords != null) 'keywords': keywords,
        },
        debug: kDebugMode,
      ),
      operationName: 'proceed to next stage',
      defaultErrorCode: ErrorCode.stageTransitionError,
      defaultErrorMessage: 'Failed to proceed to next stage',
    );

    if (data['next_stage'] == null) {
      throw ApiException(
        message: 'Invalid response: missing next_stage',
        error: ErrorDetails(
          code: ErrorCode.validationError,
          message: 'Server response missing required field: next_stage',
        ),
      );
    }
    return data;
  }

  Future<Map<String, dynamic>> askLLM({
    required String conversationId,
    required String question,
    required String stage,
    required Map<String, dynamic> context,
    required int questionIndex,
  }) async {
    return handleApiCall(
      apiCall: () => post(
        endpoint: 'ask_llm',
        body: {
          'conversation_id': conversationId,
          'question': question,
          'stage': stage,
          'context': context,
          'question_index': questionIndex,
        },
        debug: kDebugMode,
      ),
      operationName: 'ask LLM',
      defaultErrorCode: ErrorCode.llmError,
      defaultErrorMessage: 'Failed to communicate with LLM',
    );
  }

  Future<Map<String, dynamic>> reviewResponse({
    required String conversationId,
    required String stage,
    required String question,
    required String responseText,
    required Map<String, dynamic> context,
  }) async {
    return handleApiCall(
      apiCall: () => post(
        endpoint: 'review_response',
        body: {
          'conversation_id': conversationId,
          'stage': stage,
          'question': question,
          'response': responseText,
          'context': context,
        },
        debug: kDebugMode,
      ),
      operationName: 'review response',
      defaultErrorCode: ErrorCode.validationError,
      defaultErrorMessage: 'Failed to review response',
    );
  }

  Future<Map<String, dynamic>> checkStageCompletion({
    required String conversationId,
    required String stage,
    required List<dynamic> questionHistory,
    required Map<String, dynamic> context,
  }) async {
    return handleApiCall(
      apiCall: () => post(
        endpoint: 'check_stage_completion',
        body: {
          'conversation_id': conversationId,
          'stage': stage,
          'question_history': questionHistory,
          'context': context,
        },
        debug: kDebugMode,
      ),
      operationName: 'check stage completion',
      defaultErrorCode: ErrorCode.validationError,
      defaultErrorMessage: 'Failed to check stage completion',
    );
  }

  Future<Map<String, dynamic>> runPipeline({
    required String researchTopic,
    required List<String> keywords,
    required String researchGoal,
    required String researchProblem,
    required String approach,
    required String motivation,
    required String challenges,
    required String contribution,
  }) async {
    final data = await handleApiCall(
      apiCall: () => post(
        endpoint: 'run_pipeline',
        body: {
          'research_topic': researchTopic,
          'keywords': keywords,
          'research_goal': researchGoal,
          'research_problem': researchProblem,
          'approach': approach,
          'motivation': motivation,
          'challenges': challenges,
          'contribution': contribution,
        },
        debug: kDebugMode,
      ),
      operationName: 'run pipeline',
      defaultErrorCode: ErrorCode.internalError,
      defaultErrorMessage: 'Failed to run pipeline',
    );

    if (data['conversation_id'] == null) {
      throw ApiException(
        message: 'Invalid response: missing required field: conversation_id',
        error: ErrorDetails(
          code: ErrorCode.validationError,
          message: 'Server response missing required field: conversation_id',
        ),
      );
    }
    return data;
  }
} 