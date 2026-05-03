# Git Hotspot 분석 가이드

## 공식

```
hotspot_score = commit_count × file_lines
```

근거: Adam Tornhill의 "Your Code as a Crime Scene"
- **commit_count** (지난 6개월): 변경 빈도 = 미래 변경 확률
- **file_lines**: 복잡도 프록시 (실제 cyclomatic complexity가 더 정확하나 비용 큼)
- 곱셈으로 결합 → 둘 다 높을 때만 hotspot

## 해석 가이드

| score 범위 | 해석 |
|------------|------|
| 매우 높음 (top 5%) | 핵심 모듈 OR 기술 부채 hotspot — 즉시 검토 |
| 중간-높음 | 안정적이지 않은 영역 — 테스트 보강 권장 |
| 낮음 + 큰 파일 | 안정적 코드 — 그대로 둬도 됨 |
| 낮음 + 작은 파일 | 무시 가능 |

## 후속 조치

1. **상위 10개 파일 → `sub-code-reviewer` 위임**
   - 코드 스멜, SOLID 위반, 복잡도 측정
2. **상위 10개 파일 → 테스트 커버리지 확인**
   - 커버리지 낮은 hotspot은 회귀 위험 ↑
3. **상위 5개 → 도메인 전문가 인터뷰**
   - "왜 이 파일이 자주 바뀌는가?" → 누락된 추상화 발견 가능

## SINCE 파라미터

기본 `6 months ago`. 옵션:
- `1 month ago` — 단기 변동성
- `1 year ago` — 장기 trend
- `2024-01-01` — 특정 시점부터

## 노이즈 필터링

생성 파일/대용량 자동 생성물 제외 권장:
- `*.lock`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- `*.generated.ts`, `*_pb2.py` (proto)
- `dist/`, `build/`, `node_modules/` (이미 git 추적 안 됨)
