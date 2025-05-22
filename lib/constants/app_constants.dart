// String-based enum for REST/JSON only
enum Stage {
  topicSelection,
  questionGeneration,
  questionRefinement,
  answerGeneration,
  answerRefinement,
  conclusion,
}

class AppConstants {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String localOrigin = String.fromEnvironment(
    'LOCAL_ORIGIN',
    defaultValue: 'http://localhost:3000',
  );
  
  static const Map<String, String> stageDescriptions = {
    'topicSelection': '연구 주제를 선택하고 정의하는 단계입니다.',
    'questionGeneration': '연구 주제에 대한 핵심 질문들을 생성하는 단계입니다.',
    'questionRefinement': '생성된 질문들을 검토하고 개선하는 단계입니다.',
    'answerGeneration': '선택된 질문들에 대한 답변을 생성하는 단계입니다.',
    'answerRefinement': '생성된 답변들을 검토하고 개선하는 단계입니다.',
    'conclusion': '연구 결과를 종합하고 결론을 도출하는 단계입니다.',
  };

  static const Map<String, List<String>> stageGuidelines = {
    'topicSelection': [
      '연구 주제는 명확하고 구체적이어야 합니다.',
      '연구의 범위와 한계를 고려하세요.',
      '연구의 중요성과 기여도를 설명할 수 있어야 합니다.',
    ],
    'questionGeneration': [
      '핵심적인 연구 질문을 생성하세요.',
      '질문들은 서로 연관되어 있어야 합니다.',
      '질문들은 연구 목표를 달성하는데 도움이 되어야 합니다.',
    ],
    'questionRefinement': [
      '생성된 질문들을 검토하고 개선하세요.',
      '질문들이 명확하고 구체적인지 확인하세요.',
      '필요한 경우 새로운 질문을 추가하세요.',
    ],
    'answerGeneration': [
      '각 질문에 대한 상세한 답변을 생성하세요.',
      '답변은 논리적이고 체계적이어야 합니다.',
      '필요한 경우 참고문헌을 포함하세요.',
    ],
    'answerRefinement': [
      '생성된 답변들을 검토하고 개선하세요.',
      '답변들이 일관성 있게 연결되어 있는지 확인하세요.',
      '필요한 경우 추가 정보를 보완하세요.',
    ],
    'conclusion': [
      '연구 결과를 종합적으로 정리하세요.',
      '연구의 한계점과 향후 연구 방향을 제시하세요.',
      '연구의 기여도와 의미를 설명하세요.',
    ],
  };

  static const Map<String, String> stageIcons = {
    'topicSelection': '🎯',
    'questionGeneration': '❓',
    'questionRefinement': '🔍',
    'answerGeneration': '💡',
    'answerRefinement': '✏️',
    'conclusion': '📝',
  };

  static const Map<String, String> stageNames = {
    'topicSelection': '연구 주제를 선택하고 정의하는 단계입니다.',
    'questionGeneration': '연구 주제에 대한 핵심 질문들을 생성하는 단계입니다.',
    'questionRefinement': '생성된 질문들을 검토하고 개선하는 단계입니다.',
    'answerGeneration': '선택된 질문들에 대한 답변을 생성하는 단계입니다.',
    'answerRefinement': '생성된 답변들을 검토하고 개선하는 단계입니다.',
    'conclusion': '연구 결과를 종합하고 결론을 도출하는 단계입니다.',
  };

  static const Map<String, List<String>> stageQuestionTemplates = {
    'topicSelection': [
      '이 연구의 주제는 무엇인가요?',
      '이 연구에서 가장 중요한 질문은 무엇인가요?',
      '이 연구가 해결하고자 하는 핵심 문제는 무엇인가요?',
      '이 연구의 필요성은 무엇인가요?',
    ],
    'questionGeneration': [
      '이 연구를 위한 가설이나 목표는 무엇인가요?',
      '연구를 수행하기 위한 구체적인 계획은 어떻게 세울 수 있나요?',
      '필요한 데이터나 환경 요구사항은 무엇인가요?',
      '성공을 측정하기 위한 지표는 무엇으로 설정해야 할까요?',
      '실험의 독립변수와 종속변수는 무엇인가요?',
      '통제해야 할 외부 변수는 무엇이 있나요?',
      '실험의 재현성을 어떻게 보장할 수 있을까요?',
      '윤리적 고려사항이나 제약조건은 무엇인가요?',
    ],
    'questionRefinement': [
      '이 연구와 관련된 기존 연구는 무엇이 있나요?',
      '참고할 만한 관련 연구나 이론은 무엇이 있을까요?',
      '이 연구의 독특한 기여점은 무엇인가요?',
      '연구 방법론은 어떻게 선택했나요?',
      '데이터 수집 방법은 어떻게 결정했나요?',
      '연구의 한계점은 무엇인가요?',
      '이 연구가 기존 지식에 어떻게 기여하나요?',
      '향후 연구 방향은 어떻게 제시할 수 있을까요?',
    ],
    'answerGeneration': [
      '수집된 데이터를 어떻게 분석했나요?',
      '주요 발견점은 무엇인가요?',
      '분석 결과의 의미는 무엇인가요?',
    ],
    'answerRefinement': [
      '연구의 주요 결론은 무엇인가요?',
      '연구의 한계점은 무엇인가요?',
      '향후 연구 방향은 무엇인가요?',
    ],
    'conclusion': [
      '연구 결과의 일관성과 논리성을 검토해주세요.',
      '결론이 연구 질문에 적절히 답변하고 있나요?',
    ],
  };

  static const Map<String, String> initialStageContext = {
    'stage': 'topicSelection',
    'status': 'not_started',
    'progress': '0',
    'last_updated': '',
    'current_question_index': '0',
    'total_questions': '0',
    'research_topic': '',
    'keywords': '',
  };

  // Stage progression order
  static const List<Stage> stageProgression = [
    Stage.topicSelection,
    Stage.questionGeneration,
    Stage.questionRefinement,
    Stage.answerGeneration,
    Stage.answerRefinement,
    Stage.conclusion,
  ];

  // Stage status options
  static const Map<String, String> stageStatus = {
    'not_started': '시작 전',
    'in_progress': '진행 중',
    'completed': '완료',
    'review_needed': '검토 필요',
  };
} 