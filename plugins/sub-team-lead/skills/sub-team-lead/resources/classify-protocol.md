# 요청 분류 프로토콜

> Phase 1: 사용자 요청을 분석하여 적절한 전문가를 식별한다.

---

## 개요

사용자 요청을 키워드 매칭과 LLM 보조 분류를 통해 하나 이상의 전문가에게 매핑한다.
빠른 경로(키워드)로 먼저 시도하고, 신뢰도가 낮으면 LLM 분류로 보강한다.

## 실행 절차

### Step 1: 키워드 기반 분류 (Fast Path)

```bash
scripts/classify-request.sh "사용자 요청 텍스트"
```

출력 JSON 구조:
```json
{
  "query": "원본 요청",
  "experts": ["sub-api-designer"],
  "pattern": "single",
  "confidence": 0.9,
  "needs_llm_verification": false
}
```

### Step 2: 신뢰도 평가

| 신뢰도 | 행동 |
|---------|------|
| ≥ 0.9 | 즉시 라우팅 (Phase 2로 이동) |
| 0.7 - 0.89 | LLM 보조 분류로 확인 |
| < 0.7 | LLM 전체 분류 수행 |
| 0.0 | 사용자에게 명확화 요청 |

### Step 3: LLM 보조 분류 (신뢰도 < 0.9)

키워드 분류 결과를 컨텍스트로 제공하여 LLM에게 확인/수정을 요청:

```
분류 대상: "{query}"
키워드 분류 결과: {experts} (신뢰도: {confidence})
전문가 목록: [sub-kopring-engineer, sub-test-engineer, sub-api-designer, ...]
이 분류가 정확한지 확인하고, 더 적합한 전문가가 있으면 수정하세요.
```

### Step 4: 모호성 해결

요청이 모호한 경우 (confidence = 0 또는 experts 비어있음):

1. **Git diff 기반 추론**: 최근 변경 파일로부터 컨텍스트 파악
   ```bash
   git diff --name-only HEAD~3
   ```
2. **사용자 질의**: 구체적인 의도 확인
   - "어떤 종류의 작업을 원하시나요?"
   - 선택지: API 설계, 코드 구현, 테스트, 리뷰, 배포, 성능 분석

## 분류 결과 캐싱

동일 세션 내 반복 분류를 방지하기 위해 분류 결과를 메모리에 캐시한다.
세션 종료 시 캐시는 자동 폐기된다.

## 출력

Phase 1 완료 시 산출물:
- **전문가 목록**: 1개 이상의 전문가 식별자
- **신뢰도**: 0.0 ~ 1.0
- **패턴**: single | multi | none
- **분류 근거**: 키워드 매치 또는 LLM 판단 이유
