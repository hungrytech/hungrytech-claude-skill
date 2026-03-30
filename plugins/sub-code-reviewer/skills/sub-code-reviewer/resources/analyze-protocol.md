# 분석 프로토콜

> Phase 2: 코드 품질 이슈를 분석한다.

---

## SOLID 원칙 위반 감지

### SRP (단일 책임 원칙)
- 클래스 내 메서드 그룹 간 결합도 분석
- 2개 이상의 독립적 책임 식별 시 위반

### OCP (개방-폐쇄 원칙)
- if-else/switch 체인이 타입별 분기인 경우
- 새 타입 추가 시 기존 코드 수정 필요 여부

### LSP (리스코프 치환 원칙)
- 오버라이드 메서드의 사전/사후 조건 변경
- 예외 추가, 파라미터 제약 강화 감지

### ISP (인터페이스 분리 원칙)
- 인터페이스의 메서드 수 (>5 = 경고)
- 구현 클래스의 빈 메서드/UnsupportedOperationException

### DIP (의존 역전 원칙)
- 구체 클래스 직접 의존 (new 키워드)
- 고수준 모듈이 저수준 모듈에 의존

## 코드 스멜 탐지

5개 카테고리별 체계적 탐색:

| 카테고리 | 주요 탐지 대상 |
|----------|--------------|
| Bloaters | Long Method (>30줄), Large Class (>300줄), Long Parameter List (>4) |
| OO Abusers | Switch on type, Temporary Field |
| Change Preventers | Divergent Change, Shotgun Surgery |
| Dispensables | Dead Code, Duplicate Code, Speculative Generality |
| Couplers | Feature Envy, Inappropriate Intimacy |

## 복잡도 측정

순환 복잡도 (McCabe):
- 1-10: 단순 (녹색)
- 11-20: 보통 (황색)
- 21-50: 복잡 (적색)
- 50+: 매우 복잡 (위험)

## 심각도 분류

| 심각도 | 기준 | 예시 |
|--------|------|------|
| CRITICAL | 버그 또는 보안 취약점 | NPE 가능성, SQL Injection |
| HIGH | 유지보수 심각 저해 | God Class, 순환 의존성 |
| MEDIUM | 코드 품질 저하 | Long Method, Magic Number |
| LOW | 개선 권장 | 명명 규칙, 주석 부재 |
