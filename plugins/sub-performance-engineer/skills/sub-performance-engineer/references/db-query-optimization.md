# DB 쿼리 최적화

---

## EXPLAIN ANALYZE

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT ...
```

주요 확인:
- **Seq Scan**: Full Table Scan → 인덱스 추가 고려
- **Index Scan**: 인덱스 사용 → 양호
- **Nested Loop**: 소량 조인에 적합, 대량이면 Hash Join 고려
- **Sort**: 정렬 비용 → 인덱스 커버링

## 인덱스 전략

| 타입 | 용도 |
|------|------|
| B-tree | 범위 검색, 정렬 (기본) |
| Hash | 정확한 일치 검색 |
| GiST | 공간/전문 검색 |
| Composite | 다중 컬럼 조건 |

## N+1 해결

```kotlin
// EntityGraph
@EntityGraph(attributePaths = ["items", "customer"])
fun findAllOrders(): List<Order>

// JOIN FETCH (JPQL)
@Query("SELECT o FROM Order o JOIN FETCH o.items WHERE o.status = :status")
fun findByStatus(status: Status): List<Order>

// @BatchSize
@BatchSize(size = 100)
@OneToMany(mappedBy = "order")
val items: List<OrderItem>
```

## HikariCP 사이징

```
최적 풀 크기 = (코어 수 × 2) + 유효 디스크 수
```

일반적 권장: 10-20 (대부분의 서비스에 적합)

```yaml
spring:
  datasource:
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
      connection-timeout: 30000
      idle-timeout: 600000
```
