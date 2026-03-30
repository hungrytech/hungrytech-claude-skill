# 리팩토링 카탈로그

> 주요 리팩토링 기법과 적용 절차.

---

## Extract Method

**동기**: 긴 메서드에서 의미 있는 코드 블록을 분리
**절차**: 코드 블록 선택 → 새 메서드 생성 → 변수 파라미터화 → 호출로 교체

```kotlin
// Before
fun processOrder(order: Order) {
    // validate
    if (order.items.isEmpty()) throw IllegalArgumentException("No items")
    if (order.total < BigDecimal.ZERO) throw IllegalArgumentException("Negative total")
    // process
    ...
}

// After
fun processOrder(order: Order) {
    validateOrder(order)
    // process
    ...
}

private fun validateOrder(order: Order) {
    if (order.items.isEmpty()) throw IllegalArgumentException("No items")
    if (order.total < BigDecimal.ZERO) throw IllegalArgumentException("Negative total")
}
```

## Replace Conditional with Polymorphism

**동기**: 타입별 분기를 다형성으로 교체
**절차**: 인터페이스 추출 → 타입별 구현체 → switch 제거

## Introduce Parameter Object

**동기**: 자주 함께 전달되는 파라미터 그룹화
**절차**: 데이터 클래스 생성 → 파라미터 교체 → 호출부 수정

## Move Method

**동기**: Feature Envy 해결
**절차**: 대상 클래스에 메서드 복사 → 원본을 위임으로 변경 → 원본 제거
