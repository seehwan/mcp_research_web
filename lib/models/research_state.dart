import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'conversation.dart' as models;

class ResearchState extends ChangeNotifier {
  String? _conversationId;
  Stage _currentStage = Stage.topicSelection;
  Map<String, dynamic> _stageContext = Map.from(AppConstants.initialStageContext);
  List<models.QuestionResponse> _questionHistory = [];
  List<models.ConversationMessage> _conversationHistory = [];
  List<String> _generatedQuestions = [];
  bool _isLoading = false;
  String? _error;
  String _userResponse = '';
  String _llmResponse = '';
  List<String> _suggestedQuestions = [];
  int _currentQuestionIndex = 0;
  Map<String, List<models.QuestionResponse>> _stageHistory = {};
  String _researchTopic = '';
  List<String> _keywords = [];
  String _researchGoal = '';
  String _researchProblem = '';
  String _approach = '';
  String _motivation = '';
  String _challenges = '';
  String _contribution = '';
  List<String> _questions = [];
  List<String> _answers = [];

  // Getters
  String? get conversationId => _conversationId;
  Stage get currentStage => _currentStage;
  Map<String, dynamic> get stageContext => Map.unmodifiable(_stageContext);
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
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, List<models.QuestionResponse>> get stageHistory => _stageHistory;
  String get researchTopic => _researchTopic;
  List<String> get keywords => List.unmodifiable(_keywords);
  String get researchGoal => _researchGoal;
  String get researchProblem => _researchProblem;
  String get approach => _approach;
  String get motivation => _motivation;
  String get challenges => _challenges;
  String get contribution => _contribution;
  List<String> get questions => List.unmodifiable(_questions);
  List<String> get answers => List.unmodifiable(_answers);

  // Setters
  set conversationId(String? value) {
    _conversationId = value;
    notifyListeners();
  }

  set currentStage(Stage value) {
    _currentStage = value;
    notifyListeners();
  }

  set stageContext(Map<String, dynamic> value) {
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

  set currentQuestionIndex(int index) {
    _currentQuestionIndex = index;
    notifyListeners();
  }

  set researchTopic(String topic) {
    _researchTopic = topic;
    notifyListeners();
  }

  set keywords(List<String> keywords) {
    _keywords = keywords;
    notifyListeners();
  }

  set researchGoal(String value) {
    _researchGoal = value;
    notifyListeners();
  }

  set researchProblem(String value) {
    _researchProblem = value;
    notifyListeners();
  }

  set approach(String value) {
    _approach = value;
    notifyListeners();
  }

  set motivation(String value) {
    _motivation = value;
    notifyListeners();
  }

  set challenges(String value) {
    _challenges = value;
    notifyListeners();
  }

  set contribution(String value) {
    _contribution = value;
    notifyListeners();
  }

  set questions(List<String> value) {
    _questions = value;
    notifyListeners();
  }

  set answers(List<String> value) {
    _answers = value;
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
    _stageContext = context;
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
    _currentStage = Stage.topicSelection;
    _stageContext = Map.from(AppConstants.initialStageContext);
    _questionHistory = [];
    _conversationHistory = [];
    _generatedQuestions = [];
    _isLoading = false;
    _error = null;
    _userResponse = '';
    _llmResponse = '';
    _suggestedQuestions = [];
    _currentQuestionIndex = 0;
    _stageHistory = {};
    _researchTopic = '';
    _keywords = [];
    _researchGoal = '';
    _researchProblem = '';
    _approach = '';
    _motivation = '';
    _challenges = '';
    _contribution = '';
    _questions = [];
    _answers = [];
    notifyListeners();
  }

  void moveToNextStage() {
    final currentIndex = AppConstants.stageProgression.indexOf(_currentStage);
    if (currentIndex < AppConstants.stageProgression.length - 1) {
      _currentStage = AppConstants.stageProgression[currentIndex + 1];
      _stageContext = Map.from(AppConstants.initialStageContext);
      _stageContext['stage'] = _currentStage.name;
      notifyListeners();
    }
  }

  void moveToPreviousStage() {
    final currentIndex = AppConstants.stageProgression.indexOf(_currentStage);
    if (currentIndex > 0) {
      _currentStage = AppConstants.stageProgression[currentIndex - 1];
      _stageContext = Map.from(AppConstants.initialStageContext);
      _stageContext['stage'] = _currentStage.name;
      notifyListeners();
    }
  }
} 