import 'package:flutter/material.dart';

// String-based enum for REST/JSON only
enum Stage {
  unspecified,  // 미지정
  questioning,   // 연구 주제 및 주요 질문 선정
  planning,     // 세부 계획 수립
  research,     // 연구 단계
  analysis,     // 분석 단계
  conclusion,   // 결론 단계
  review,       // 검토 단계
  finalization; // 최종화 단계
}

class AppConstants {
  static const String apiBaseUrl = 'http://127.0.0.1:8000';
  static const String localOrigin = 'http://localhost:3000';
  static const Duration cacheDuration = Duration(minutes: 5);
  
  static const Map<String, String> stageNames = {
    'questioning': '연구 주제 및 주요 질문 선정',
    'planning': '세부 계획 수립',
    'research': '연구',
    'analysis': '분석',
    'conclusion': '결론',
    'review': '검토',
    'finalization': '최종화',
  };

  static const Map<String, List<String>> stageQuestionTemplates = {
    'questioning': [
      '이 연구의 주제는 무엇인가요?',
      '이 연구에서 가장 중요한 질문은 무엇인가요?',
      '이 연구가 해결하고자 하는 핵심 문제는 무엇인가요?',
      '이 연구의 필요성은 무엇인가요?',
    ],
    'planning': [
      '이 연구를 위한 가설이나 목표는 무엇인가요?',
      '연구를 수행하기 위한 구체적인 계획은 어떻게 세울 수 있나요?',
      '필요한 데이터나 환경 요구사항은 무엇인가요?',
      '성공을 측정하기 위한 지표는 무엇으로 설정해야 할까요?',
      '실험의 독립변수와 종속변수는 무엇인가요?',
      '통제해야 할 외부 변수는 무엇이 있나요?',
      '실험의 재현성을 어떻게 보장할 수 있을까요?',
      '윤리적 고려사항이나 제약조건은 무엇인가요?',
    ],
    'research': [
      '이 연구와 관련된 기존 연구는 무엇이 있나요?',
      '참고할 만한 관련 연구나 이론은 무엇이 있을까요?',
      '이 연구의 독특한 기여점은 무엇인가요?',
      '연구 방법론은 어떻게 선택했나요?',
      '데이터 수집 방법은 어떻게 결정했나요?',
      '연구의 한계점은 무엇인가요?',
      '이 연구가 기존 지식에 어떻게 기여하나요?',
      '향후 연구 방향은 어떻게 제시할 수 있을까요?',
    ],
    'analysis': [
      '수집된 데이터를 어떻게 분석했나요?',
      '주요 발견점은 무엇인가요?',
      '분석 결과의 의미는 무엇인가요?',
    ],
    'conclusion': [
      '연구의 주요 결론은 무엇인가요?',
      '연구의 한계점은 무엇인가요?',
      '향후 연구 방향은 무엇인가요?',
    ],
    'review': [
      '연구 결과의 일관성과 논리성을 검토해주세요.',
      '결론이 연구 질문에 적절히 답변하고 있나요?',
    ],
    'finalization': [
      '최종 논문의 구조와 형식이 적절한가요?',
      '참고문헌과 인용이 올바르게 정리되어 있나요?',
    ],
  };

  static const Map<String, String> initialStageContext = {
    'stage': 'planning',
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
    Stage.questioning,
    Stage.planning,
    Stage.research,
    Stage.analysis,
    Stage.conclusion,
    Stage.review,
    Stage.finalization,
  ];

  // Stage status options
  static const Map<String, String> stageStatus = {
    'not_started': '시작 전',
    'in_progress': '진행 중',
    'completed': '완료',
    'review_needed': '검토 필요',
  };
} 