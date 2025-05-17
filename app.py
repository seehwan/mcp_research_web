from flask import Flask, request, jsonify
from flask_cors import CORS
import logging
from datetime import datetime
import json
from typing import Dict, List, Optional, Any, TypedDict, Union
import uuid
from dataclasses import dataclass, asdict
from enum import Enum
from lib.services.llm_service import LLMService

app = Flask(__name__)
CORS(app, supports_credentials=True)

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# LLM 서비스 초기화
llm_service = LLMService()

class Stage(str, Enum):
    UNSPECIFIED = "STAGE_UNSPECIFIED"
    PLANNING = "STAGE_PLANNING"    # 계획 단계
    RESEARCH = "STAGE_RESEARCH"    # 연구 단계
    ANALYSIS = "STAGE_ANALYSIS"    # 분석 단계
    CONCLUSION = "STAGE_CONCLUSION"  # 결론 단계
    REVIEW = "STAGE_REVIEW"      # 검토 단계
    FINALIZATION = "STAGE_FINALIZATION" # 최종화 단계

class MessageType(str, Enum):
    USER = "user"
    SYSTEM = "system"
    ERROR = "error"
    LLM = "llm"

class ApiStatus(str, Enum):
    SUCCESS = "success"
    ERROR = "error"

class ErrorCode(str, Enum):
    INVALID_REQUEST = "invalid_request"
    CONVERSATION_NOT_FOUND = "conversation_not_found"
    STAGE_TRANSITION_ERROR = "stage_transition_error"
    LLM_ERROR = "llm_error"
    VALIDATION_ERROR = "validation_error"
    INTERNAL_ERROR = "internal_error"

@dataclass
class ErrorDetails:
    code: ErrorCode
    message: str
    details: Optional[Dict[str, Any]] = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "code": self.code.value,
            "message": self.message,
            "details": self.details
        }

@dataclass
class MessageMetadata:
    confidence: float
    sources: List[str]
    stage: Stage
    question_index: Optional[int] = None
    additional_info: Optional[Dict[str, Any]] = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "confidence": self.confidence,
            "sources": self.sources,
            "stage": self.stage.value,
            "question_index": self.question_index,
            "additional_info": self.additional_info
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'MessageMetadata':
        return cls(
            confidence=data["confidence"],
            sources=data["sources"],
            stage=Stage(data["stage"]),
            question_index=data.get("question_index"),
            additional_info=data.get("additional_info")
        )

@dataclass
class ConversationMessage:
    type: MessageType
    content: str
    timestamp: datetime
    metadata: Optional[MessageMetadata] = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "type": self.type.value,
            "content": self.content,
            "timestamp": self.timestamp.isoformat(),
            "metadata": self.metadata.to_dict() if self.metadata else None
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'ConversationMessage':
        return cls(
            type=MessageType(data["type"]),
            content=data["content"],
            timestamp=datetime.fromisoformat(data["timestamp"]),
            metadata=MessageMetadata.from_dict(data["metadata"]) if data.get("metadata") else None
        )

@dataclass
class QuestionMetadata:
    confidence: float
    sources: List[str]
    stage: Stage
    question_index: int
    validation_status: str
    feedback: Optional[str] = None
    suggestions: Optional[List[str]] = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "confidence": self.confidence,
            "sources": self.sources,
            "stage": self.stage.value,
            "question_index": self.question_index,
            "validation_status": self.validation_status,
            "feedback": self.feedback,
            "suggestions": self.suggestions
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'QuestionMetadata':
        return cls(
            confidence=data["confidence"],
            sources=data["sources"],
            stage=Stage(data["stage"]),
            question_index=data["question_index"],
            validation_status=data["validation_status"],
            feedback=data.get("feedback"),
            suggestions=data.get("suggestions")
        )

@dataclass
class QuestionResponse:
    question: str
    userResponse: str
    llmResponse: str
    timestamp: datetime
    metadata: QuestionMetadata

    def to_dict(self) -> Dict[str, Any]:
        return {
            "question": self.question,
            "userResponse": self.userResponse,
            "llmResponse": self.llmResponse,
            "timestamp": self.timestamp.isoformat(),
            "metadata": self.metadata.to_dict()
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'QuestionResponse':
        return cls(
            question=data["question"],
            userResponse=data["userResponse"],
            llmResponse=data["llmResponse"],
            timestamp=datetime.fromisoformat(data["timestamp"]),
            metadata=QuestionMetadata.from_dict(data["metadata"])
        )

@dataclass
class ApiResponse:
    status: ApiStatus
    data: Optional[Any] = None
    message: Optional[str] = None
    error: Optional[ErrorDetails] = None

    def to_dict(self) -> Dict[str, Any]:
        return {
            "status": self.status.value,
            "data": self.data,
            "message": self.message,
            "error": self.error.to_dict() if self.error else None
        }

@dataclass
class StageContext:
    stage: Stage
    context: Dict[str, Any]
    question_history: List[QuestionResponse]
    conversation_history: List[ConversationMessage]

    def to_dict(self) -> Dict[str, Any]:
        return {
            "stage": self.stage.value,
            "context": self.context,
            "question_history": [q.to_dict() for q in self.question_history],
            "conversation_history": [m.to_dict() for m in self.conversation_history]
        }

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'StageContext':
        return cls(
            stage=Stage(data["stage"]),
            context=data["context"],
            question_history=[QuestionResponse.from_dict(q) for q in data["question_history"]],
            conversation_history=[ConversationMessage.from_dict(m) for m in data["conversation_history"]]
        )

class Conversation:
    def __init__(self, conversation_id: str):
        self.id = conversation_id
        self.current_stage = Stage.PLANNING
        self.stage_history: List[StageContext] = []
        self.question_history: List[QuestionResponse] = []
        self.context: Dict[str, Any] = {}
        self.created_at = datetime.now()
        self.last_updated = datetime.now()

    def to_dict(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "current_stage": self.current_stage.value,
            "stage_history": [
                {
                    "stage": ctx.stage.value,
                    "context": ctx.context,
                    "last_updated": ctx.last_updated.isoformat()
                }
                for ctx in self.stage_history
            ],
            "question_history": [
                {
                    "question": qr.question,
                    "user_response": qr.userResponse,
                    "llm_response": qr.llmResponse,
                    "timestamp": qr.timestamp.isoformat(),
                    "metadata": qr.metadata.to_dict()
                }
                for qr in self.question_history
            ],
            "context": self.context,
            "created_at": self.created_at.isoformat(),
            "last_updated": self.last_updated.isoformat()
        }

# 전역 상태 관리
conversations: Dict[str, Conversation] = {}

def create_api_response(data: Optional[Any] = None, message: Optional[str] = None) -> Dict[str, Any]:
    return ApiResponse(
        status=ApiStatus.SUCCESS,
        data=data,
        message=message
    ).to_dict()

def create_error_response(
    code: ErrorCode,
    message: str,
    details: Optional[Dict[str, Any]] = None,
    status_code: int = 400
) -> Dict[str, Any]:
    return ApiResponse(
        status=ApiStatus.ERROR,
        error=ErrorDetails(
            code=code,
            message=message,
            details=details
        )
    ).to_dict()

def get_or_create_conversation(conversation_id: Optional[str] = None) -> Conversation:
    if not conversation_id:
        conversation_id = str(uuid.uuid4())
        logger.info(f"Created new conversation with ID: {conversation_id}")
    
    if conversation_id not in conversations:
        conversations[conversation_id] = Conversation(conversation_id)
        logger.info(f"Initialized conversation state for ID: {conversation_id}")
    
    return conversations[conversation_id]

def generate_stage_questions(stage: Stage, context: Dict[str, Any]) -> List[Dict[str, Any]]:
    stage_questions = {
        Stage.PLANNING: [
            {
                "id": "planning_1",
                "question": "연구 주제는 무엇인가요?",
                "description": "연구하고자 하는 주제를 명확하게 정의해주세요.",
                "required": True
            },
            {
                "id": "planning_2",
                "question": "연구의 목적은 무엇인가요?",
                "description": "이 연구를 통해 달성하고자 하는 목표를 설명해주세요.",
                "required": True
            },
            {
                "id": "planning_3",
                "question": "예상되는 결과는 무엇인가요?",
                "description": "연구를 통해 얻을 수 있을 것으로 예상되는 결과를 설명해주세요.",
                "required": True
            }
        ],
        Stage.RESEARCH: [
            {
                "id": "research_1",
                "question": "관련된 주요 문헌은 무엇인가요?",
                "description": "연구 주제와 관련된 주요 문헌들을 나열해주세요.",
                "required": True
            },
            {
                "id": "research_2",
                "question": "연구 방법론은 어떻게 되나요?",
                "description": "연구를 수행하기 위한 구체적인 방법론을 설명해주세요.",
                "required": True
            },
            {
                "id": "research_3",
                "question": "데이터 수집 방법은 무엇인가요?",
                "description": "연구에 필요한 데이터를 수집하는 방법을 설명해주세요.",
                "required": True
            }
        ],
        Stage.ANALYSIS: [
            {
                "id": "analysis_1",
                "question": "수집된 데이터를 어떻게 분석했나요?",
                "description": "데이터 분석 방법과 과정을 설명해주세요.",
                "required": True
            },
            {
                "id": "analysis_2",
                "question": "주요 발견점은 무엇인가요?",
                "description": "데이터 분석을 통해 발견한 주요 내용을 설명해주세요.",
                "required": True
            },
            {
                "id": "analysis_3",
                "question": "분석 결과의 의미는 무엇인가요?",
                "description": "분석 결과가 가지는 의미와 시사점을 설명해주세요.",
                "required": True
            }
        ],
        Stage.CONCLUSION: [
            {
                "id": "conclusion_1",
                "question": "연구의 주요 결론은 무엇인가요?",
                "description": "연구를 통해 도출된 주요 결론을 설명해주세요.",
                "required": True
            },
            {
                "id": "conclusion_2",
                "question": "연구의 한계점은 무엇인가요?",
                "description": "연구 과정에서 발견된 한계점을 설명해주세요.",
                "required": True
            },
            {
                "id": "conclusion_3",
                "question": "향후 연구 방향은 무엇인가요?",
                "description": "이 연구를 바탕으로 제안하는 향후 연구 방향을 설명해주세요.",
                "required": True
            }
        ]
    }
    return stage_questions.get(stage, [])

def determine_next_stage(current_stage: Stage, context: Dict[str, Any], history: List[StageContext]) -> Stage:
    try:
        # 단계 전환 로직 구현
        stage_order = [
            Stage.PLANNING,
            Stage.RESEARCH,
            Stage.ANALYSIS,
            Stage.CONCLUSION,
            Stage.REVIEW,
            Stage.FINALIZATION
        ]
        
        current_index = stage_order.index(current_stage)
        if current_index < len(stage_order) - 1:
            return stage_order[current_index + 1]
        return current_stage  # 마지막 단계인 경우 현재 단계 유지
    except Exception as e:
        logger.error(f"Error determining next stage: {str(e)}")
        raise

def prepare_initial_context(next_stage: Stage, current_context: Dict[str, Any]) -> Dict[str, Any]:
    return {
        **current_context,
        "stage": next_stage.value,
        "last_updated": datetime.now().isoformat()
    }

def process_llm_question(question: str, context: Dict[str, Any], stage: Stage, question_index: int) -> Dict[str, Any]:
    try:
        # LLM 서비스를 사용하여 응답 생성
        prompt = llm_service.formatPrompt(
            stage=stage.value,
            context=context,
            question=question,
            userResponse="",
            questionHistory=[]
        )
        
        # 실제 LLM API 호출
        llm_response = llm_service.generateResponse(prompt)
        
        metadata = {
            'confidence': 0.95,
            'sources': ['source1', 'source2'],
            'stage': stage.value,
            'question_index': question_index
        }

        return {
            'response': llm_response,
            'metadata': metadata,
            'conversation_id': str(uuid.uuid4())
        }
    except Exception as e:
        logger.error(f"Error processing LLM question: {str(e)}")
        return {
            'error': {
                'code': 'LLM_ERROR',
                'message': str(e)
            }
        }

def review_user_response(stage: Stage, question: str, response: str, context: Dict[str, Any]) -> Dict[str, Any]:
    try:
        # LLM 서비스를 사용하여 응답 검토
        prompt = llm_service.formatPrompt(
            stage=stage.value,
            context=context,
            question=question,
            userResponse=response,
            questionHistory=[]
        )
        
        # 실제 LLM API 호출
        review_result = llm_service.reviewResponse(prompt)

        return {
            'is_valid': review_result['is_valid'],
            'feedback': review_result['feedback'],
            'suggestions': review_result['suggestions'],
            'confidence': 0.9 if review_result['is_valid'] else 0.5
        }
    except Exception as e:
        logger.error(f"Error reviewing user response: {str(e)}")
        raise

def check_completion_status(stage: Stage, question_history: List[QuestionResponse], context: Dict[str, Any]) -> Dict[str, Any]:
    try:
        # 단계 완료 상태 확인 로직 구현
        total_questions = len(question_history)
        answered_questions = sum(1 for q in question_history if q.userResponse.strip())
        completion_percentage = (answered_questions / total_questions * 100) if total_questions > 0 else 0
        
        return {
            "is_complete": completion_percentage >= 80,  # 80% 이상 완료 시 단계 완료로 간주
            "remaining_questions": total_questions - answered_questions,
            "completion_percentage": completion_percentage
        }
    except Exception as e:
        logger.error(f"Error checking completion status: {str(e)}")
        raise

@app.route('/get_stage_questions', methods=['POST'])
def get_stage_questions():
    try:
        data = request.get_json() or {}
        conversation_id = data.get('conversation_id')
        current_stage = Stage(data.get('current_stage', Stage.PLANNING.value))
        stage_context = data.get('stage_context', {})

        conversation = get_or_create_conversation(conversation_id)
        questions = generate_stage_questions(current_stage, stage_context)
        
        return jsonify(create_api_response(
            data={
                "questions": questions,
                "conversation_id": conversation.id
            },
            message="단계별 질문이 생성되었습니다."
        ))
    except Exception as e:
        logger.error(f"Error in get_stage_questions: {str(e)}")
        return jsonify(create_error_response(ErrorCode.INTERNAL_ERROR, str(e))), 500

@app.route('/proceed_to_next_stage', methods=['POST'])
def proceed_to_next_stage():
    try:
        data = request.get_json() or {}
        conversation_id = data.get('conversation_id')
        current_stage = Stage(data.get('current_stage', Stage.PLANNING.value))
        stage_context = data.get('stage_context', {})
        stage_history = data.get('stage_history', [])

        conversation = get_or_create_conversation(conversation_id)
        next_stage = determine_next_stage(current_stage, stage_context, conversation.stage_history)
        initial_context = prepare_initial_context(next_stage, stage_context)
        stage_questions = generate_stage_questions(next_stage, initial_context)

        # 대화 상태 업데이트
        conversation.current_stage = next_stage
        conversation.context = initial_context
        conversation.stage_history.append(StageContext(
            stage=next_stage,
            context=initial_context,
            question_history=conversation.question_history,
            conversation_history=conversation.stage_history[-1].conversation_history
        ))
        conversation.last_updated = datetime.now()

        return jsonify(create_api_response(
            data={
                "next_stage": next_stage.value,
                "initial_context": initial_context,
                "stage_questions": stage_questions,
                "conversation_id": conversation.id
            },
            message="다음 단계로 진행되었습니다."
        ))
    except Exception as e:
        logger.error(f"Error in proceed_to_next_stage: {str(e)}")
        return jsonify(create_error_response(ErrorCode.INTERNAL_ERROR, str(e))), 500

@app.route('/ask_llm', methods=['POST'])
def ask_llm():
    try:
        data = request.get_json() or {}
        conversation_id = data.get('conversation_id')
        question = data.get('question')
        context = data.get('context', {})
        stage = Stage(data.get('stage', Stage.PLANNING.value))
        question_index = data.get('question_index', 0)

        response = process_llm_question(question, context, stage, question_index)

        return jsonify(create_api_response(
            data={
                **response,
                "conversation_id": conversation_id
            },
            message="LLM 응답이 생성되었습니다."
        ))
    except Exception as e:
        logger.error(f"Error in ask_llm: {str(e)}")
        return jsonify(create_error_response(ErrorCode.INTERNAL_ERROR, str(e))), 500

@app.route('/review_response', methods=['POST'])
def review_response():
    try:
        data = request.get_json() or {}
        conversation_id = data.get('conversation_id')
        stage = Stage(data.get('stage', Stage.PLANNING.value))
        question = data.get('question')
        response = data.get('response')
        context = data.get('context', {})

        review_result = review_user_response(stage, question, response, context)

        # 응답 저장
        conversation = get_or_create_conversation(conversation_id)
        conversation.question_history.append(QuestionResponse(
            question=question,
            userResponse=response,
            llmResponse=review_result.get('feedback', ''),
            timestamp=datetime.now(),
            metadata=QuestionMetadata(
                confidence=0.95,
                sources=["source1", "source2"],
                stage=stage,
                question_index=0,
                validation_status="valid",
                feedback=review_result.get('feedback', ''),
                suggestions=review_result.get('suggestions', [])
            )
        ))
        conversation.last_updated = datetime.now()

        return jsonify(create_api_response(
            data={
                **review_result,
                "conversation_id": conversation.id
            },
            message="응답이 검토되었습니다."
        ))
    except Exception as e:
        logger.error(f"Error in review_response: {str(e)}")
        return jsonify(create_error_response(ErrorCode.INTERNAL_ERROR, str(e))), 500

@app.route('/check_stage_completion', methods=['POST'])
def check_stage_completion():
    try:
        data = request.get_json() or {}
        conversation_id = data.get('conversation_id')
        stage = Stage(data.get('stage', Stage.PLANNING.value))
        question_history = data.get('question_history', [])
        context = data.get('context', {})

        conversation = get_or_create_conversation(conversation_id)
        completion_status = check_completion_status(stage, conversation.question_history, context)

        return jsonify(create_api_response(
            data={
                **completion_status,
                "conversation_id": conversation.id
            },
            message="단계 완료 여부가 확인되었습니다."
        ))
    except Exception as e:
        logger.error(f"Error in check_stage_completion: {str(e)}")
        return jsonify(create_error_response(ErrorCode.INTERNAL_ERROR, str(e))), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000) 