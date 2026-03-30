# 제안 프로토콜

> Phase 3: 분석된 이슈에 대한 리팩토링을 제안한다.

---

## 리팩토링 기법 매칭

각 이슈에 대해 Martin Fowler 카탈로그에서 적합한 기법 선택:

| 이슈 | 리팩토링 기법 |
|------|-------------|
| Long Method | Extract Method |
| Large Class | Extract Class, Extract Interface |
| Feature Envy | Move Method |
| Switch on type | Replace Conditional with Polymorphism |
| Duplicate Code | Extract Method, Pull Up Method |
| Long Parameter List | Introduce Parameter Object |
| Primitive Obsession | Replace Primitive with Object |

## diff 생성

각 제안에 대해 before/after 코드 차이 생성:
- 변경 위치 (파일:라인)
- 변경 전 코드
- 변경 후 코드
- 변경 근거

## 우선순위 결정

```
Priority = Severity × Impact × (1 / Effort)
```

높은 심각도 + 높은 영향도 + 낮은 노력 = 최우선

## 출력

- 리팩토링 제안 목록 (우선순위 정렬)
- 각 제안의 구체적 diff
- 예상 효과 (복잡도 감소량, 중복 제거량)
