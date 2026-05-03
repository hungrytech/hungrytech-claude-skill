# Event: `{{TOPIC}}`

- **Brokers**: {{BROKERS}}
- **Schema**: {{SCHEMA}}
- **Publishers**: {{PUBLISHER_COUNT}}
- **Subscribers**: {{SUBSCRIBER_COUNT}}

## Publishers

| Service | File:Line | Trigger |
|---------|-----------|---------|
{{PUBLISHER_ROWS}}

## Subscribers

| Service | File:Line | Handler | Side Effect |
|---------|-----------|---------|-------------|
{{SUBSCRIBER_ROWS}}

## Mermaid Flow

```mermaid
flowchart LR
{{FLOW_DIAGRAM}}
```

## 위험 요소

- [ ] DLQ(Dead Letter Queue) 설정 여부
- [ ] 중복 처리 멱등성 보장
- [ ] 스키마 호환성 정책 (forward/backward)
- [ ] 컨슈머 lag 모니터링
- [ ] 재시도 정책
- [ ] Tracing/Correlation ID 전파
