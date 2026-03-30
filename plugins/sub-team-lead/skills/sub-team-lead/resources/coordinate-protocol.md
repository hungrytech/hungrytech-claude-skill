# 조율 프로토콜

> Phase 3: 전문가 실행을 관리하고 핸드오프를 조율한다.

---

## 개요

라우팅 전략에 따라 전문가를 실행하고, 전문가 간 핸드오프를 관리한다.

## Sister-Skill Invoke 발행

각 전문가에게 표준 invoke 메시지 발행:

```xml
<sister-skill-invoke skill="{target-expert}">
  <caller>sub-team-lead</caller>
  <phase>coordinate</phase>
  <trigger>{routing-reason}</trigger>
  <targets>{user-request-summary}</targets>
  <constraints>
    <timeout>300s</timeout>
    <max-loop>3</max-loop>
  </constraints>
</sister-skill-invoke>
```

## 순차 파이프라인 조율

```
전문가 A 실행 → 결과 수집 → 전문가 B 입력 구성 → 전문가 B 실행 → ...
```

각 단계에서:
1. 이전 전문가의 결과를 파싱
2. 다음 전문가의 입력 형식에 맞게 변환
3. 다음 전문가에게 invoke 발행
4. 실패 시 파이프라인 중단 + 사용자 알림

### 대표 파이프라인 예시

**API → 구현 → 테스트 → 배포**:
```
sub-api-designer (OpenAPI 스펙)
  → sub-kopring-engineer (컨트롤러 구현, 스펙 참조)
    → sub-test-engineer (Contract Test 생성)
      → sub-devops-engineer (CI 파이프라인 추가)
```

## 병렬 팬아웃 조율

독립 전문가를 Task 에이전트로 동시 실행:
- 각 전문가에게 별도 Task 할당
- 모든 Task 완료 대기
- 결과 수집 후 Phase 4로 이동

## 피드백 루프

설계 ↔ 리뷰 반복 패턴:
1. 전문가 A 실행 (설계/구현)
2. 전문가 B 실행 (리뷰)
3. 리뷰 결과에 이슈 있으면 → 전문가 A 재실행 (수정)
4. 최대 2회 반복 후 중단

## 타임아웃 및 실패 처리

| 상황 | 처리 |
|------|------|
| 전문가 타임아웃 (300s) | 부분 결과 수집 + 사용자 알림 |
| 전문가 실행 실패 | 에러 로그 + 대체 방안 제시 |
| 전문가 결과 불충분 | 추가 컨텍스트와 함께 재시도 1회 |
