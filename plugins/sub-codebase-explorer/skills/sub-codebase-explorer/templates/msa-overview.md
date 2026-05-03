# MSA Overview — {{PROJECT_NAME}}

> Auto-generated. {{SERVICE_COUNT}} services, {{CALL_COUNT}} HTTP/gRPC calls, {{TOPIC_COUNT}} event topics.

## Service Topology

```mermaid
flowchart LR
    classDef service fill:#e3f2fd,stroke:#1565c0;
    classDef topic   fill:#fff3e0,stroke:#e65100;

{{SERVICE_NODES}}

{{TOPIC_NODES}}

{{HTTP_EDGES}}

{{EVENT_EDGES}}
```

## 인덱스

- [api-calls/](./api-calls/) — {{CALL_COUNT}} 호출 상세
- [events/](./events/) — {{TOPIC_COUNT}} 이벤트 토픽
- [sequence-diagrams/](./sequence-diagrams/) — 핵심 시나리오 시퀀스
- [service-dependency-matrix.md](./service-dependency-matrix.md) — NxN 의존성 매트릭스

## 통계

| 카테고리 | 건수 |
|---------|------|
| 총 서비스 | {{SERVICE_COUNT}} |
| 총 HTTP/gRPC 호출 | {{CALL_COUNT}} |
| 고유 caller→callee 쌍 | {{UNIQUE_PAIR_COUNT}} |
| 이벤트 토픽 | {{TOPIC_COUNT}} |
| Publishers (총합) | {{PUBLISHER_COUNT}} |
| Subscribers (총합) | {{SUBSCRIBER_COUNT}} |
