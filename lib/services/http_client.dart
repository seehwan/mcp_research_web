import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/conversation.dart';

class HttpClient {
  final String baseUrl;
  final _logger = Logger();
  final int maxRetries;
  final Duration retryDelay;
  final _client = http.Client();

  HttpClient({
    required this.baseUrl,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    bool debug = false,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Connection': 'close',
    };
    final finalHeaders = {...defaultHeaders, ...?headers};

    if (debug) {
      _logger.i('POST $url', error: {
        'headers': finalHeaders,
        'body': body,
      });
    }

    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final response = await _client.post(
          url,
          headers: finalHeaders,
          body: jsonEncode(body),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );

        if (debug) {
          _logger.i('Response from $url', error: {
            'status': response.statusCode,
            'body': response.body,
          });
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }

        throw ApiException(
          message: 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
          error: response.body.isNotEmpty
              ? ErrorDetails.fromJson(jsonDecode(response.body))
              : null,
        );
      } catch (e) {
        attempts++;
        if (attempts == maxRetries) rethrow;
        await Future.delayed(retryDelay);
      }
    }

    throw ApiException(
      message: 'Failed after $maxRetries attempts',
      error: ErrorDetails(
        code: ErrorCode.internalError,
        message: 'Request failed after $maxRetries attempts',
      ),
    );
  }

  Future<Map<String, dynamic>> get({
    required String endpoint,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    bool debug = false,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint').replace(
      queryParameters: queryParameters,
    );
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Connection': 'close',
    };
    final finalHeaders = {...defaultHeaders, ...?headers};

    if (debug) {
      _logger.i('GET $url', error: {
        'headers': finalHeaders,
        'query': queryParameters,
      });
    }

    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        final response = await _client.get(
          url,
          headers: finalHeaders,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );

        if (debug) {
          _logger.i('Response from $url', error: {
            'status': response.statusCode,
            'body': response.body,
          });
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }

        throw ApiException(
          message: 'HTTP ${response.statusCode}',
          statusCode: response.statusCode,
          error: response.body.isNotEmpty
              ? ErrorDetails.fromJson(jsonDecode(response.body))
              : null,
        );
      } catch (e) {
        attempts++;
        if (attempts == maxRetries) rethrow;
        await Future.delayed(retryDelay);
      }
    }

    throw ApiException(
      message: 'Failed after $maxRetries attempts',
      error: ErrorDetails(
        code: ErrorCode.internalError,
        message: 'Request failed after $maxRetries attempts',
      ),
    );
  }

  void dispose() {
    _client.close();
  }
} 