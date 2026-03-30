# 성능 분석 보고서

**대상**: {target}
**날짜**: {date}
**분석 도메인**: {domains}

## 요약

| 메트릭 | 현재 | 목표 | 상태 |
|--------|------|------|------|
| P99 응답 시간 | {p99_current}ms | {p99_target}ms | {status} |
| 평균 응답 시간 | {avg_current}ms | {avg_target}ms | {status} |
| 처리량 | {rps_current} RPS | {rps_target} RPS | {status} |
| 에러율 | {error_rate}% | <1% | {status} |

## 병목 분석

### 병목 1: {bottleneck_name}
- **위치**: {location}
- **원인**: {root_cause}
- **영향**: {impact}
- **최적화 제안**: {optimization}

## 최적화 적용 결과

| 최적화 | 전 | 후 | 개선 |
|--------|-----|-----|------|
| {optimization_1} | {before} | {after} | {improvement} |

## 권장 사항

- {recommendation_1}
- {recommendation_2}
