# Phase 2: Map Protocol

목표: 의존성 그래프 + 순환 탐지, MSA 시그널 시 API 호출 + 이벤트 토폴로지 추출.

## 절차

### 2-1. 모듈 의존성 그래프
```bash
./scripts/extract-dependencies.sh "$TARGET" > /tmp/deps.json
./scripts/detect-circular-deps.sh "$TARGET" > /tmp/cycles.json
```

산출:
- `templates/dependency-graph.dot`을 채워 Graphviz DOT 파일 생성
- `templates/dependency-graph.mmd`을 채워 Mermaid flowchart 생성
- 순환 발견 시 사용자에게 강조 보고 (red border)

### 2-2. MSA 매핑 (msa_recommended=true 또는 mode=msa)
```bash
./scripts/extract-msa-api-calls.sh "$TARGET" > /tmp/calls.json
./scripts/extract-msa-events.sh    "$TARGET" > /tmp/events.json
```

이 단계에서 파일 생성하지 않음 — Phase 4에서 `generate-msa-docs.sh`가 일괄 생성.

## 출력 보고

```
🕸  모듈 그래프: {nodes}개 노드, {edges}개 엣지
🔁 순환: {cycles.length}개 (있다면 SCC 멤버 나열)
📡 MSA: API 호출 {calls.length}건, 이벤트 {events.length}건 (publish/subscribe 분리 카운트)
```

## 캐시
- 결과는 `~/.claude/cache/sub-codebase-explorer-{hash}-map-{deps,cycles,calls,events}.json`
