# 도메인 모델 추출 휴리스틱

## ORM 시그너처

| 언어 | 마커 | 추가 어노테이션 |
|------|------|-----------------|
| Java/Kotlin (JPA) | `@Entity` | `@Table`, `@Id`, `@OneToMany`, `@ManyToOne` |
| Python (SQLAlchemy) | `class X(Base)` (declarative) | `__tablename__`, `relationship()`, `ForeignKey` |
| Python (Pydantic) | `class X(BaseModel)` | (도메인 모델 + 검증) |
| TypeScript (TypeORM) | `@Entity()` | `@Column`, `@OneToMany`, `@JoinColumn` |
| TypeScript (Prisma) | `model X { ... }` (schema.prisma) | `@relation` |
| Go (GORM) | `gorm.Model` 임베딩 | 태그 `gorm:"foreignKey:..."` |

## 관계 추출

### JVM (JPA)
```kotlin
@Entity
class Order {
    @ManyToOne
    @JoinColumn(name = "customer_id")
    lateinit var customer: Customer

    @OneToMany(mappedBy = "order")
    var items: MutableList<OrderItem> = mutableListOf()
}
```
→ Order ↔ Customer (N:1), Order ↔ OrderItem (1:N)

### Prisma
```prisma
model Order {
  id         Int       @id
  customer   Customer  @relation(fields: [customerId], references: [id])
  customerId Int
  items      OrderItem[]
}
```
→ 동일 추출.

## ARCHITECTURE.md 도메인 섹션 양식

```markdown
## Domain Model

### Aggregates
- **Order** (`src/.../Order.kt`)
  - belongs_to: Customer
  - has_many: OrderItem

### Entities
- Customer
- OrderItem

### Value Objects (식별 휴리스틱: data class without @Entity)
- Money
- Address
```

## 한계

- 다대다 (`@JoinTable`)는 양방향 추적 필요
- 도메인 이벤트는 별도 패턴 (`*Event` 클래스명)
- DDD Bounded Context는 자동 추출 어려움 — 디렉토리/모듈명에서 유추
