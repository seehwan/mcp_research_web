// Flutter Web UI (main.dart version, 질문: 한국어, 단계별 대화 기록 및 진행 표시 포함)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mcp_research_web/constants/app_constants.dart';
import 'package:mcp_research_web/models/research_state.dart';
import 'package:mcp_research_web/models/conversation.dart';
import 'package:mcp_research_web/services/api_service.dart';
import 'package:mcp_research_web/widgets/conversation_history.dart';
import 'package:mcp_research_web/widgets/question_input.dart';
import 'package:mcp_research_web/widgets/question_selection.dart';
import 'package:mcp_research_web/widgets/stage_controls.dart';
import 'package:mcp_research_web/widgets/research_topic_input.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // Add timestamp and format the log message
    final timestamp = DateTime.now().toIso8601String();
    final message = '${record.level.name}: $timestamp: ${record.message}';
    
    // Print to console with different colors based on log level
    switch (record.level) {
      case Level.SEVERE:
        debugPrint('\x1B[31m$message\x1B[0m'); // Red for errors
        break;
      case Level.WARNING:
        debugPrint('\x1B[33m$message\x1B[0m'); // Yellow for warnings
        break;
      case Level.INFO:
        debugPrint('\x1B[32m$message\x1B[0m'); // Green for info
        break;
      default:
        debugPrint('\x1B[37m$message\x1B[0m'); // White for others
    }
  });
  runApp(const MCPResearchApp());
}

class MCPResearchApp extends StatelessWidget {
  const MCPResearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MCP Research',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MCPResearchHomePage(),
    );
  }
}

class MCPResearchHomePage extends StatefulWidget {
  const MCPResearchHomePage({super.key});

  @override
  State<MCPResearchHomePage> createState() => _MCPResearchHomePageState();
}

class _MCPResearchHomePageState extends State<MCPResearchHomePage> {
  final _apiService = ApiService(baseUrl: 'http://127.0.0.1:8000');
  final _researchState = ResearchState();
  bool _isLoading = false;
  String _llmResponse = '';
  TextEditingController _questionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _initializeResearch() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.proceedToNextStage(
        conversationId: _researchState.conversationId ?? '',
        currentStage: _researchState.currentStage.name.toUpperCase(),
        stageContext: _researchState.stageContext,
        stageHistory: [],
        researchTopic: _researchState.researchTopic,
        keywords: _researchState.keywords,
      );
      _handleStageTransition(response);
    } catch (e) {
      _addErrorToHistory('초기화 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleStageTransition(Map<String, dynamic> response) {
    setState(() {
      _researchState.currentStage = Stage.values.firstWhere(
        (s) => s.name.toUpperCase() == response['next_stage'],
        orElse: () => Stage.planning,
      );
      _researchState.stageContext = Map<String, String>.from(response['initial_context'] ?? {});
      _researchState.generatedQuestions = (response['stage_questions'] as List)
          .map((q) => q['question'] as String)
          .toList();
      _researchState.currentQuestionIndex = 0;
      _researchState.userResponse = '';
      _researchState.conversationId = response['conversation_id'] ?? _researchState.conversationId;
    });
    _addSystemMessageToHistory(
      '단계 전환',
      {
        'from_stage': _researchState.currentStage.name,
        'to_stage': response['next_stage'],
        'context': response['initial_context'],
      },
    );
    _getSuggestedQuestions();
  }

  Future<void> _getSuggestedQuestions() async {
    if (_researchState.generatedQuestions.isEmpty) {
      setState(() => _isLoading = true);
      try {
        final questions = await _apiService.getStageQuestions(
          conversationId: _researchState.conversationId ?? '',
          currentStage: _researchState.currentStage.name.toUpperCase(),
          stageContext: _researchState.stageContext,
        );
        setState(() {
          _researchState.generatedQuestions = questions.map((q) => q.question).toList();
          _researchState.currentQuestionIndex = 0;
        });
      } catch (e) {
        _addErrorToHistory('질문을 가져오는 중 오류가 발생했습니다: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _proceedToNextStage() async {
    setState(() => _isLoading = true);
    try {
      // 1. 선택된 질문을 컨텍스트에 추가
      final selectedQuestion = _researchState.generatedQuestions[_researchState.currentQuestionIndex];
      final newContext = Map<String, String>.from(_researchState.stageContext);
      newContext['selected_question'] = selectedQuestion;

      // 2. 컨텍스트를 오른쪽 카드에 기록
      _addSystemMessageToHistory('컨텍스트 확장', newContext);

      // 3. 다음 단계로 진행
      final response = await _apiService.proceedToNextStage(
        conversationId: _researchState.conversationId ?? '',
        currentStage: _researchState.currentStage.name.toUpperCase(),
        stageContext: newContext,
        stageHistory: [],
        researchTopic: _researchState.researchTopic,
        keywords: _researchState.keywords,
      );
      _handleStageTransition(response);
    } catch (e) {
      _addErrorToHistory('다음 단계로 진행하는 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addErrorToHistory(String message) {
    setState(() {
      _researchState.addToConversationHistory(
        ConversationMessage(
          type: MessageType.ERROR,
          content: message,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _addSystemMessageToHistory(String step, Map<String, dynamic> content) {
    setState(() {
      final msg = ConversationMessage(
        type: MessageType.SYSTEM,
        content: jsonEncode({
          'step': step,
          'content': content,
        }),
        timestamp: DateTime.now(),
      );
      _researchState.addToConversationHistory(msg);
      _logMessageToServer(_researchState.conversationId ?? '', msg.content);
    });
  }

  void _addUserMessageToHistory() {
    if (_researchState.userResponse.isEmpty) return;
    setState(() {
      final msg = ConversationMessage(
        type: MessageType.USER,
        content: jsonEncode({
          'current_question': _researchState.currentQuestion,
          'user_response': _researchState.userResponse,
        }),
        timestamp: DateTime.now(),
      );
      _researchState.addToConversationHistory(msg);
      _logMessageToServer(_researchState.conversationId ?? '', msg.content);
      _researchState.userResponse = '';
    });
  }

  void _addLLMMessageToHistory(String response) {
    setState(() {
      final msg = ConversationMessage(
        type: MessageType.LLM,
        content: response,
        timestamp: DateTime.now(),
      );
      _researchState.addToConversationHistory(msg);
      _logMessageToServer(_researchState.conversationId ?? '', msg.content);
    });
  }

  void _handleQuestionSelected(int index) {
    setState(() {
      _researchState.currentQuestionIndex = index;
      _researchState.userResponse = '';
    });
  }

  void _handleQuestionModified(String newQuestion) {
    setState(() {
      _researchState.generatedQuestions[_researchState.currentQuestionIndex] = newQuestion;
    });
  }

  void _handleAddQuestion() {
    setState(() {
      _researchState.generatedQuestions.add('새로운 질문');
      _researchState.currentQuestionIndex = _researchState.generatedQuestions.length - 1;
    });
  }

  void _handleRemoveQuestion() {
    if (_researchState.generatedQuestions.length > 1) {
      setState(() {
        _researchState.generatedQuestions.removeAt(_researchState.currentQuestionIndex);
        if (_researchState.currentQuestionIndex >= _researchState.generatedQuestions.length) {
          _researchState.currentQuestionIndex = _researchState.generatedQuestions.length - 1;
        }
      });
    }
  }

  Future<void> _handleRegenerateQuestions() async {
    setState(() => _isLoading = true);
    try {
      final questions = await _apiService.getStageQuestions(
        conversationId: _researchState.conversationId ?? '',
        currentStage: _researchState.currentStage.name.toUpperCase(),
        stageContext: _researchState.stageContext,
      );
      setState(() {
        _researchState.generatedQuestions = questions.map((q) => q.question).toList();
        _researchState.currentQuestionIndex = 0;
      });
    } catch (e) {
      _addErrorToHistory('질문을 재생성하는 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleUserResponseChanged(String response) {
    setState(() {
      _researchState.userResponse = response;
    });
  }

  void _handleSubmit() {
    if (_researchState.userResponse.isEmpty) return;
    _addUserMessageToHistory();
  }

  Future<void> _logMessageToServer(String conversationId, String message) async {
    if (conversationId.isEmpty) return;
    final url = 'http://127.0.0.1:8000/log_message';
    try {
      await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'conversation_id': conversationId, 'message': message}),
      );
    } catch (e) {
      debugPrint('로그 서버 전송 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              width: 280,
              child: DropdownButtonFormField<String>(
                value: _researchState.currentStage.name,
                decoration: const InputDecoration(
                  labelText: '현재 단계',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.stageNames.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: _isLoading ? null : (value) {
                  if (value != null) {
                    setState(() {
                      _researchState.currentStage = Stage.values.firstWhere((s) => s.name == value);
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'MCP Research',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _researchState.researchTopic.isEmpty
              ? ResearchTopicInput(
                  isLoading: _isLoading,
                  onSubmit: (topic, keywords) async {
                    setState(() => _isLoading = true);
                    try {
                      _researchState.clearConversationHistory();
                      _researchState.researchTopic = topic;
                      _researchState.keywords = keywords;
                      final pipelineResponse = await _apiService.runPipeline(
                        researchTopic: topic,
                        keywords: keywords,
                        questionType: 'default',
                      );
                      _researchState.conversationId = pipelineResponse['conversation_id'];
                      final data = pipelineResponse['data'];
                      
                      // Handle llm_response
                      if (data['llm_response'] != null) {
                        final questions = data['llm_response'] as List<dynamic>;
                        if (questions.isNotEmpty) {
                          _researchState.generatedQuestions = questions
                              .map((q) => q['question'].toString())
                              .toList();
                          _researchState.currentQuestionIndex = 0;
                        }
                      }
                      
                      // Handle llm_response_markdown
                      if (data['llm_response_markdown'] != null) {
                        setState(() {
                          _llmResponse = data['llm_response_markdown'];
                        });
                        _addLLMMessageToHistory(data['llm_response_markdown']);
                      }
                      
                      await _initializeResearch();
                    } catch (e) {
                      _addErrorToHistory('연구 파이프라인 시작 중 오류가 발생했습니다: $e');
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // 서버 통신 정보 표시
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '서버 통신 정보',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Scrollbar(
                                        thumbVisibility: true,
                                        child: SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  '요청 내용:',
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
                                                Text('연구 주제: ${_researchState.researchTopic}'),
                                                Text('키워드: ${_researchState.keywords}'),
                                                const SizedBox(height: 16),
                                                const Text(
                                                  '서버 응답:',
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
                                                Text('대화 ID: ${_researchState.conversationId}'),
                                                const SizedBox(height: 8),
                                                const Text(
                                                  '생성된 질문:',
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                const SizedBox(height: 4),
                                                ..._researchState.generatedQuestions.map((q) => Padding(
                                                  padding: const EdgeInsets.only(bottom: 8),
                                                  child: Text('• $q'),
                                                )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 질문 선택 및 수정 UI
                              if (_researchState.generatedQuestions.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('질문', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _questionController..text = _researchState.generatedQuestions[_researchState.currentQuestionIndex],
                                        onChanged: (val) {
                                          _researchState.generatedQuestions[_researchState.currentQuestionIndex] = val;
                                        },
                                        maxLines: 2,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: '질문을 수정하세요',
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          if (_researchState.currentQuestionIndex > 0)
                                            IconButton(
                                              icon: const Icon(Icons.arrow_back),
                                              onPressed: _isLoading
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        _researchState.currentQuestionIndex--;
                                                      });
                                                    },
                                            ),
                                          if (_researchState.currentQuestionIndex < _researchState.generatedQuestions.length - 1)
                                            IconButton(
                                              icon: const Icon(Icons.arrow_forward),
                                              onPressed: _isLoading
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        _researchState.currentQuestionIndex++;
                                                      });
                                                    },
                                            ),
                                          const Spacer(),
                                          ElevatedButton(
                                            onPressed: _isLoading ? null : _proceedToNextStage,
                                            child: const Text('다음 단계로'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              QuestionInput(
                                currentStage: _researchState.currentStage.name,
                                currentQuestion: _researchState.currentQuestion,
                                userResponse: _researchState.userResponse,
                                llmResponse: _researchState.llmResponse,
                                suggestedQuestions: _researchState.suggestedQuestions,
                                questionHistory: [], // TODO: Implement question history
                                isLoading: _isLoading,
                                onUserResponseChanged: _handleUserResponseChanged,
                                onPreviousQuestion: () {
                                  if (_researchState.currentQuestionIndex > 0) {
                                    _handleQuestionSelected(_researchState.currentQuestionIndex - 1);
                                  }
                                },
                                onNextQuestion: () {
                                  if (_researchState.currentQuestionIndex < _researchState.generatedQuestions.length - 1) {
                                    _handleQuestionSelected(_researchState.currentQuestionIndex + 1);
                                  }
                                },
                                onCheckAdditionalQuestions: () async {
                                  // TODO: Implement additional questions check
                                },
                                onSubmit: _handleSubmit,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(),
                    Expanded(
                      flex: 3,
                      child: ConversationHistory(
                        messages: _researchState.conversationHistory ?? [],
                        onEditMessage: (index) {
                          // TODO: Implement message editing
                        },
                        toEncodable: (object) {
                          if (object is DateTime) {
                            return object.toIso8601String();
                          }
                          return object.toString();
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
