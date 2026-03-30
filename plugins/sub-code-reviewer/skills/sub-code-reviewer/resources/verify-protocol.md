# 검증 프로토콜

> Phase 4: 리팩토링 적용 후 품질 개선을 검증한다.

---

## 검증 절차

### Step 1: 리팩토링 적용

사용자가 제안된 리팩토링을 적용한 후 실행.

### Step 2: 메트릭 재측정

```bash
scripts/measure-complexity.sh [target-path]
```

### Step 3: 동작 보존 확인

- 테스트 스위트 실행
- 컴파일 성공 확인
- 기존 테스트 모두 통과 확인

### Step 4: 개선 효과 정량화

| 메트릭 | 전 | 후 | 변화 |
|--------|-----|-----|------|
| 순환 복잡도 | {before} | {after} | {delta} |
| 평균 메서드 길이 | {before} | {after} | {delta} |
| 클래스 수 | {before} | {after} | {delta} |
| 중복 라인 | {before} | {after} | {delta} |

## 출력

- 전후 비교 보고서
- 잔여 이슈 목록 (추가 리팩토링 필요 시)
