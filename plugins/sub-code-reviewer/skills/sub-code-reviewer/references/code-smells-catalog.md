# 코드 스멜 카탈로그

> Martin Fowler 분류 기준 코드 스멜 목록.

---

## Bloaters (비대해진 코드)

### Long Method
- **설명**: 30줄 이상의 메서드
- **감지**: 라인 수 측정
- **리팩토링**: Extract Method

### Large Class
- **설명**: 300줄 이상, 또는 10+ 필드를 가진 클래스
- **감지**: 라인/필드 수 측정
- **리팩토링**: Extract Class, Extract Interface

### Primitive Obsession
- **설명**: 도메인 개념을 원시 타입으로 표현
- **감지**: String/Int 파라미터가 반복적으로 함께 전달
- **리팩토링**: Replace Primitive with Value Object

### Long Parameter List
- **설명**: 4개 이상의 파라미터
- **감지**: 파라미터 수 카운트
- **리팩토링**: Introduce Parameter Object

## OO Abusers (객체지향 남용)

### Switch Statements
- **설명**: 타입별 switch/when 분기
- **리팩토링**: Replace Conditional with Polymorphism

### Temporary Field
- **설명**: 특정 상황에서만 사용되는 필드
- **리팩토링**: Extract Class

## Change Preventers (변경 방해)

### Divergent Change
- **설명**: 하나의 클래스가 여러 이유로 변경
- **리팩토링**: Extract Class (책임별 분리)

### Shotgun Surgery
- **설명**: 하나의 변경이 여러 클래스에 영향
- **리팩토링**: Move Method, Inline Class

## Dispensables (불필요한 요소)

### Dead Code
- **설명**: 호출되지 않는 코드
- **리팩토링**: 삭제

### Duplicate Code
- **설명**: 동일/유사한 코드 반복
- **리팩토링**: Extract Method, Pull Up Method

## Couplers (과도한 결합)

### Feature Envy
- **설명**: 다른 클래스의 데이터를 과도하게 사용
- **리팩토링**: Move Method

### Inappropriate Intimacy
- **설명**: 클래스 간 내부 상세 접근
- **리팩토링**: Move Method, Extract Class
