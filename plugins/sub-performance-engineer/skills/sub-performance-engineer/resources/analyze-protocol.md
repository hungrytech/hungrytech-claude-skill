# 분석 프로토콜

> Phase 2: 식별된 병목을 심층 분석한다.

---

## JVM 분석

### 힙 분석
- 힙 사용 패턴 (시간별 추이)
- 대형 객체 식별 (histo)
- 메모리 누수 후보 (GC 후에도 감소 안 하는 객체)

### GC 분석
- GC 빈도 및 일시 정지 시간
- Full GC 발생 빈도
- GC 알고리즘 적합성 평가

### 스레드 분석
- 스레드 수 추이
- 데드락 감지
- 블로킹 스레드 식별

## DB 분석

### 실행 계획 분석
```sql
EXPLAIN ANALYZE SELECT ...
```

주요 확인 사항:
- Seq Scan (Full Table Scan) → 인덱스 필요
- Nested Loop + 큰 테이블 → JOIN 전략 변경
- Sort 비용 → 인덱스 커버링

### N+1 쿼리 감지

코드에서 N+1 패턴 탐지:
- `findAll()` + `forEach { entity.getRelation() }`
- Lazy loading 트리거
- 해결: `@EntityGraph`, `JOIN FETCH`, `@BatchSize`

### Connection Pool 분석

HikariCP 메트릭:
- Active connections / Max pool size
- Pending threads (대기 스레드)
- Connection wait time

## 출력

- 병목 원인 + 근거
- 우선순위별 최적화 대상 목록
