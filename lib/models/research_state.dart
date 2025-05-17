import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'conversation.dart' as models;
import 'package:flutter/foundation.dart';

class ResearchState extends ChangeNotifier {
  String? _conversationId;
  Stage _currentStage = Stage.planning;
  Map<String, String> _stageContext = {};
  List<models.QuestionResponse> _questionHistory = [];
  List<models.ConversationMessage> _conversationHistory = [];
  List<String> _generatedQuestions = [];
  bool _isLoading = false;
  String? _error;
  String _currentQuestion = '';
  String _userResponse = '';
  String _llmResponse = '';
  List<String> _suggestedQuestions = [];
  List<String> _generatedQuestionsList = [];
  int _currentQuestionIndex = 0;
  Map<String, List<models.QuestionResponse>> _stageHistory = {};
  Map<String, Map<String, dynamic>> _questionCache = {};
  DateTime? _lastCacheUpdate;
  String _researchTopic = '';
  String _keywords = '';

  // Getters
  String? get conversationId => _conversationId;
  Stage get currentStage => _currentStage;
  Map<String, String> get stageContext => _stageContext;
  List<models.QuestionResponse> get questionHistory => _questionHistory;
  List<models.ConversationMessage> get conversationHistory => _conversationHistory;
  List<String> get generatedQuestions => _generatedQuestions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentQuestion {
    if (_generatedQuestions.isEmpty) return '';
    return _generatedQuestions[_currentQuestionIndex];
  }
  String get userResponse => _userResponse;
  String get llmResponse => _llmResponse;
  List<String> get suggestedQuestions => _suggestedQuestions;
  List<String> get generatedQuestionsList => _generatedQuestionsList;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, List<models.QuestionResponse>> get stageHistory => _stageHistory;
  String get researchTopic => _researchTopic;
  String get keywords => _keywords;

  // Setters
  set conversationId(String? value) {
    _conversationId = value;
    notifyListeners();
  }

  set currentStage(Stage value) {
    _currentStage = value;
    notifyListeners();
  }

  set stageContext(Map<String, String> value) {
    _stageContext = value;
    notifyListeners();
  }

  set questionHistory(List<models.QuestionResponse> value) {
    _questionHistory = value;
    notifyListeners();
  }

  set conversationHistory(List<models.ConversationMessage> value) {
    _conversationHistory = value;
    notifyListeners();
  }

  set generatedQuestions(List<String> value) {
    _generatedQuestions = value;
    notifyListeners();
  }

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set error(String? value) {
    _error = value;
    notifyListeners();
  }

  set currentQuestion(String question) {
    _currentQuestion = question;
    notifyListeners();
  }

  set userResponse(String response) {
    _userResponse = response;
    notifyListeners();
  }

  set llmResponse(String response) {
    _llmResponse = response;
    notifyListeners();
  }

  set suggestedQuestions(List<String> questions) {
    _suggestedQuestions = questions;
    notifyListeners();
  }

  set generatedQuestionsList(List<String> questions) {
    _generatedQuestionsList = questions;
    notifyListeners();
  }

  set currentQuestionIndex(int index) {
    _currentQuestionIndex = index;
    notifyListeners();
  }

  set researchTopic(String topic) {
    _researchTopic = topic;
    notifyListeners();
  }

  set keywords(String keywords) {
    _keywords = keywords;
    notifyListeners();
  }

  // Methods
  void addToConversationHistory(models.ConversationMessage message) {
    _conversationHistory.add(message);
    notifyListeners();
  }

  void addToQuestionHistory(models.QuestionResponse response) {
    _questionHistory.add(response);
    notifyListeners();
  }

  void addToStageHistory(String stage, models.QuestionResponse response) {
    if (!_stageHistory.containsKey(stage)) {
      _stageHistory[stage] = [];
    }
    _stageHistory[stage]!.add(response);
    notifyListeners();
  }

  List<models.QuestionResponse> getStageHistory(String stage) {
    return _stageHistory[stage] ?? [];
  }

  void updateStageContext(Map<String, dynamic> context) {
    _stageContext = context as Map<String, String>;
    notifyListeners();
  }

  void updateSuggestedQuestions(List<String> questions) {
    _suggestedQuestions = questions;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _conversationId = null;
    _currentStage = Stage.planning;
    _stageContext = AppConstants.initialStageContext;
    _questionHistory = [];
    _conversationHistory = [];
    _generatedQuestions = [];
    _isLoading = false;
    _error = null;
    _currentQuestion = '';
    _userResponse = '';
    _llmResponse = '';
    _suggestedQuestions = [];
    _generatedQuestionsList = [];
    _currentQuestionIndex = 0;
    _stageHistory = {};
    _questionCache = {};
    _lastCacheUpdate = null;
    _researchTopic = '';
    _keywords = '';
    notifyListeners();
  }

  // Cache management
  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheJson = prefs.getString('question_cache');
    if (cacheJson != null) {
      final cacheData = json.decode(cacheJson);
      _questionCache = Map<String, Map<String, dynamic>>.from(cacheData['cache']);
      _lastCacheUpdate = DateTime.parse(cacheData['timestamp']);
    }
  }

  Future<void> saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'cache': _questionCache,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString('question_cache', json.encode(cacheData));
  }

  bool isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < AppConstants.cacheDuration;
  }

  Map<String, dynamic>? getCachedQuestion(String stage, String question) {
    if (!isCacheValid()) return null;
    return _questionCache['$stage:$question'];
  }

  void cacheQuestion(String stage, String question, Map<String, dynamic> data) {
    _questionCache['$stage:$question'] = data;
    _lastCacheUpdate = DateTime.now();
    saveCache();
  }

  void updateCache() {
    _lastCacheUpdate = DateTime.now();
  }

  void clearConversationHistory() {
    _conversationHistory.clear();
    notifyListeners();
  }
} 