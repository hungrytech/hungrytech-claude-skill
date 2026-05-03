# Git Hotspot Report — {{PROJECT_NAME}}

- **Period**: {{SINCE}} ~ now
- **Scoring**: `commits × lines` (Adam Tornhill, "Your Code as a Crime Scene")
- **Top 50** files by score:

| Rank | Path | Commits | Lines | Score | 권장 조치 |
|------|------|---------|-------|-------|----------|
{{HOTSPOT_ROWS}}

## 해석

- 🔴 **Top 5**: 즉시 코드 리뷰 + 테스트 커버리지 확인 권장 → `/sub-code-reviewer`
- 🟡 **Top 6-15**: 안정적이지 않은 영역, 리팩토링 후보
- 🟢 **나머지**: 정상 변경 빈도

## 후속 명령

```bash
/sub-code-reviewer  # 상위 5개 파일 심층 리뷰
/sub-test-engineer  # 커버리지 부족 파일 테스트 보강
```
