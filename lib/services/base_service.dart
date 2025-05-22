import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import '../models/conversation.dart';
import 'http_client.dart';

abstract class BaseService {
  final _logger = Logger();
  final HttpClient client;

  BaseService({
    required this.client,
  });

  void logError(String message, dynamic error, [StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace ?? StackTrace.current);
  }

  void logInfo(String message, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      _logger.i(message, error: data);
    }
  }

  void logWarning(String message, [Map<String, dynamic>? data]) {
    _logger.w(message, error: data);
  }

  Future<T> handleApiCall<T>({
    required Future<T> Function() apiCall,
    required String operationName,
    ErrorCode defaultErrorCode = ErrorCode.internalError,
    String? defaultErrorMessage,
  }) async {
    try {
      return await apiCall();
    } on ApiException catch (e) {
      logError('Error in $operationName', e);
      rethrow;
    } catch (e) {
      logError('Unexpected error in $operationName', e);
      throw ApiException(
        message: 'Failed to $operationName: ${e.toString()}',
        error: ErrorDetails(
          code: defaultErrorCode,
          message: defaultErrorMessage ?? 'An unexpected error occurred',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    bool debug = false,
  }) async {
    return handleApiCall(
      apiCall: () => client.post(
        endpoint: endpoint,
        body: body,
        headers: headers,
        debug: debug,
      ),
      operationName: 'POST $endpoint',
    );
  }

  Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    bool debug = false,
  }) async {
    return handleApiCall(
      apiCall: () => client.get(
        endpoint: endpoint,
        headers: headers,
        queryParameters: queryParameters,
        debug: debug,
      ),
      operationName: 'GET $endpoint',
    );
  }
} 