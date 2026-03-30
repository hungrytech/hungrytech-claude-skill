# 캐싱 전략

---

## 로컬 캐시 (Caffeine)

```kotlin
@Configuration
class CacheConfig {
    @Bean
    fun cacheManager(): CacheManager = CaffeineCacheManager().apply {
        setCaffeine(Caffeine.newBuilder()
            .maximumSize(10_000)
            .expireAfterWrite(Duration.ofMinutes(10))
            .recordStats())
    }
}
```

## 분산 캐시 (Redis)

```yaml
spring:
  cache:
    type: redis
    redis:
      time-to-live: 600000  # 10분
```

## 캐싱 패턴

### Cache-Aside (Lazy Loading)
```kotlin
fun getOrder(id: String): Order {
    return cache.get(id) ?: run {
        val order = repository.findById(id)
        cache.put(id, order)
        order
    }
}
```

### Write-Through
```kotlin
fun createOrder(order: Order): Order {
    val saved = repository.save(order)
    cache.put(saved.id, saved)
    return saved
}
```

## 캐시 무효화

| 전략 | 적합 조건 |
|------|----------|
| TTL 기반 | 일정 시간 후 자동 만료 |
| 이벤트 기반 | 데이터 변경 시 즉시 무효화 |
| 버전 기반 | 캐시 키에 버전 포함 |
