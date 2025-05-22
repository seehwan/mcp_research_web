import 'package:flutter/foundation.dart';

// String-based enums for REST/JSON only
enum MessageType { user, system, error, llm }
enum ApiStatus { success, error }
enum ErrorCode {
  invalidRequest,
  conversationNotFound,
  stageTransitionError,
  llmError,
  validationError,
  internalError
}

@immutable
class ErrorDetails {
  final ErrorCode code;
  final String message;
  final Map<String, dynamic>? details;

  const ErrorDetails({
    required this.code,
    required this.message,
    this.details,
  });

  factory ErrorDetails.fromJson(Map<String, dynamic> json) {
    return ErrorDetails(
      code: ErrorCode.values.firstWhere(
        (e) => e.name == json['code'],
        orElse: () => ErrorCode.internalError,
      ),
      message: json['message'] as String,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code.name,
      'message': message,
      if (details != null) 'details': details,
    };
  }
}

class MessageMetadata {
  final double confidence;
  final List<String> sources;
  final String stage;
  final int? questionIndex;
  final Map<String, dynamic>? additionalInfo;

  MessageMetadata({
    required this.confidence,
    required this.sources,
    required this.stage,
    this.questionIndex,
    this.additionalInfo,
  });

  factory MessageMetadata.fromJson(Map<String, dynamic> json) {
    return MessageMetadata(
      confidence: (json['confidence'] as num).toDouble(),
      sources: List<String>.from(json['sources'] ?? []),
      stage: json['stage'] as String,
      questionIndex: json['question_index'] as int?,
      additionalInfo: json['additional_info'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confidence': confidence,
      'sources': sources,
      'stage': stage,
      if (questionIndex != null) 'question_index': questionIndex,
      if (additionalInfo != null) 'additional_info': additionalInfo,
    };
  }
}

class ConversationMessage {
  final String role;
  final String content;
  final DateTime timestamp;
  final MessageMetadata? metadata;

  ConversationMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        if (metadata != null) 'metadata': metadata!.toJson(),
      };

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] != null
          ? MessageMetadata.fromJson(json['metadata'])
          : null,
    );
  }
}

class QuestionMetadata {
  final double confidence;
  final List<String> sources;
  final String stage;
  final int questionIndex;
  final String validationStatus;
  final String? feedback;
  final List<String>? suggestions;

  QuestionMetadata({
    required this.confidence,
    required this.sources,
    required this.stage,
    required this.questionIndex,
    required this.validationStatus,
    this.feedback,
    this.suggestions,
  });

  factory QuestionMetadata.fromJson(Map<String, dynamic> json) {
    return QuestionMetadata(
      confidence: (json['confidence'] as num).toDouble(),
      sources: List<String>.from(json['sources'] ?? []),
      stage: json['stage'] as String,
      questionIndex: json['question_index'] as int,
      validationStatus: json['validation_status'] as String,
      feedback: json['feedback'] as String?,
      suggestions: (json['suggestions'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confidence': confidence,
      'sources': sources,
      'stage': stage,
      'question_index': questionIndex,
      'validation_status': validationStatus,
      if (feedback != null) 'feedback': feedback,
      if (suggestions != null) 'suggestions': suggestions,
    };
  }
}

class QuestionResponse {
  final String question;
  final String userResponse;
  final String llmResponse;
  final String timestamp;
  final QuestionMetadata metadata;

  QuestionResponse({
    required this.question,
    required this.userResponse,
    required this.llmResponse,
    required this.timestamp,
    required this.metadata,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      question: json['question'] as String,
      userResponse: json['userResponse'] as String,
      llmResponse: json['llmResponse'] as String,
      timestamp: json['timestamp'] as String,
      metadata: QuestionMetadata.fromJson(json['metadata']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'userResponse': userResponse,
      'llmResponse': llmResponse,
      'timestamp': timestamp,
      'metadata': metadata.toJson(),
    };
  }
}

class ApiResponse<T> {
  final ApiStatus status;
  final T? data;
  final String? message;
  final ErrorDetails? error;

  const ApiResponse({
    required this.status,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJson) {
    return ApiResponse(
      status: ApiStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['status'] as String).toLowerCase(),
        orElse: () => ApiStatus.error,
      ),
      data: json['data'] != null ? fromJson(json['data']) : null,
      message: json['message'] as String?,
      error: json['error'] != null ? ErrorDetails.fromJson(json['error']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name.toLowerCase(),
      if (data != null) 'data': data,
      if (message != null) 'message': message,
      if (error != null) 'error': error!.toJson(),
    };
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ErrorDetails? error;

  const ApiException({
    required this.message,
    this.statusCode,
    this.error,
  });

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}${error != null ? ' - ${error!.message}' : ''}';
} 