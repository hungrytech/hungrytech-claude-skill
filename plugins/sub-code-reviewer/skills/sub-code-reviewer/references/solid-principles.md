# SOLID 원칙

> 각 원칙의 설명, 위반 예시, 수정 예시.

---

## S — Single Responsibility Principle (단일 책임)

**원칙**: 클래스는 하나의 변경 이유만 가져야 한다.

**위반 예시** (Kotlin):
```kotlin
class OrderService(
    private val repository: OrderRepository,
    private val emailSender: EmailSender
) {
    fun createOrder(request: CreateOrderRequest): Order { ... }
    fun sendConfirmationEmail(order: Order) { ... }  // 별도 책임
    fun generateReport(orders: List<Order>): Report { ... }  // 또 다른 책임
}
```

**수정**: EmailService, ReportService로 분리.

## O — Open/Closed Principle (개방-폐쇄)

**원칙**: 확장에는 열려있고, 수정에는 닫혀있어야 한다.

**위반 예시**:
```kotlin
fun calculateDiscount(type: String, amount: BigDecimal): BigDecimal {
    return when (type) {
        "VIP" -> amount * 0.2.toBigDecimal()
        "GOLD" -> amount * 0.1.toBigDecimal()
        else -> BigDecimal.ZERO
    }
}
```

**수정**: `DiscountStrategy` 인터페이스 + 구현체.

## L — Liskov Substitution Principle (리스코프 치환)

**원칙**: 하위 타입은 상위 타입을 대체할 수 있어야 한다.

**위반**: 사전 조건 강화, 사후 조건 약화, 예외 추가.

## I — Interface Segregation Principle (인터페이스 분리)

**원칙**: 사용하지 않는 메서드에 의존하지 않아야 한다.

**위반**: 10개 메서드를 가진 인터페이스, 구현체가 절반만 사용.

## D — Dependency Inversion Principle (의존 역전)

**원칙**: 고수준 모듈이 저수준 모듈에 의존하지 않고, 추상화에 의존해야 한다.

**위반**: `class OrderService(private val mysqlRepository: MySQLOrderRepository)`
**수정**: `class OrderService(private val repository: OrderRepository)`
