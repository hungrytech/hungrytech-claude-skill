# 최적화 프로토콜

> Phase 3: 분석 결과를 기반으로 최적화를 적용한다.

---

## JVM 최적화

### GC 튜닝
- G1GC: `-XX:MaxGCPauseMillis`, `-XX:G1HeapRegionSize`
- ZGC: `-XX:+UseZGC` (JDK 15+, 낮은 레이턴시 요구 시)
- 힙 크기: `-Xmx` (컨테이너 메모리의 75%)

### 코드 최적화
- 불필요한 객체 생성 제거
- 컬렉션 사이즈 사전 지정
- 문자열 연결 최적화

## DB 최적화

### 인덱스 추가
```sql
CREATE INDEX idx_orders_status_created ON orders(status, created_at);
```

### N+1 해결
```kotlin
// Before: N+1
val orders = orderRepository.findAll()
orders.forEach { it.items }  // N queries

// After: JOIN FETCH
@Query("SELECT o FROM Order o JOIN FETCH o.items")
fun findAllWithItems(): List<Order>
```

### Connection Pool 사이징
```
pool_size = (core_count * 2) + effective_spindle_count
```

## 캐싱 적용

적절한 캐싱 전략 선택 및 구현:
- 읽기 비율 높은 데이터 → Cache-Aside
- 일관성 중요 데이터 → Write-Through
- TTL 기반 자동 만료

## 출력

- 최적화 코드/설정 변경사항
- 예상 개선 효과
