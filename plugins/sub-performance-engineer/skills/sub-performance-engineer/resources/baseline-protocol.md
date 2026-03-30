# 베이스라인 프로토콜

> Phase 1: 현재 성능 베이스라인을 수집한다.

---

## 실행 절차

### Step 1: 성능 스택 감지

```bash
scripts/detect-performance-stack.sh [project-root]
```

### Step 2: 현재 메트릭 수집

| 도메인 | 수집 항목 | 도구 |
|--------|----------|------|
| JVM | 힙 사용량, GC 빈도, 스레드 수 | JFR, jstat |
| DB | 평균 쿼리 시간, 커넥션 풀 사용률 | pg_stat, HikariCP 메트릭 |
| HTTP | 평균 응답 시간, P99, 에러율 | k6 smoke test |
| System | CPU 사용률, 메모리 사용률 | top, vmstat |

### Step 3: 병목 후보 식별

코드 스캔으로 잠재적 병목 식별:
```bash
scripts/analyze-slow-query.sh [target-path]
```

## 출력

- 현재 성능 메트릭 스냅샷
- 잠재적 병목 후보 목록
- 성능 스택 프로파일
