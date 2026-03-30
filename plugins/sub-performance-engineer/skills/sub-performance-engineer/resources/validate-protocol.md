# 검증 프로토콜

> Phase 4: 최적화 효과를 검증한다.

---

## 검증 절차

### Step 1: 동일 조건 재측정

최적화 전과 동일한 조건에서 메트릭 재수집:
- 동일 부하 시나리오
- 동일 데이터셋
- 동일 환경

### Step 2: 전후 비교

| 메트릭 | 전 | 후 | 변화 | 목표 달성 |
|--------|-----|-----|------|----------|
| P99 응답 시간 | {before}ms | {after}ms | {delta}% | {yes/no} |
| 평균 응답 시간 | {before}ms | {after}ms | {delta}% | {yes/no} |
| 처리량 (RPS) | {before} | {after} | {delta}% | {yes/no} |
| GC 일시정지 | {before}ms | {after}ms | {delta}% | {yes/no} |
| DB 쿼리 시간 | {before}ms | {after}ms | {delta}% | {yes/no} |

### Step 3: 회귀 확인

- 기존 테스트 모두 통과
- 다른 엔드포인트 성능 저하 없음
- 메모리 사용량 급증 없음

## 출력

- 전후 비교 보고서
- 목표 달성 여부
- 추가 최적화 필요 시 권장 사항
