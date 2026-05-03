#!/usr/bin/env bash
# generate-msa-docs.sh - MSA 문서 일괄 생성
# Usage: generate-msa-docs.sh [TARGET_PATH] [OUTPUT_DIR]
#   기본 OUTPUT_DIR: $TARGET_PATH/msa
# Output: msa/{00-overview.md, api-calls/*.md, events/*.md, sequence-diagrams/*.mmd, service-dependency-matrix.md}
#
# 의존: jq + python3, 호출: extract-msa-api-calls.sh + extract-msa-events.sh

set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_common.sh"

TARGET="${1:-.}"
OUT="${2:-$TARGET/msa}"
[ -d "$TARGET" ] || { log_error "target not a directory: $TARGET"; exit 1; }

mkdir -p "$OUT/api-calls" "$OUT/events" "$OUT/sequence-diagrams"

calls_json=$("$SCRIPT_DIR/extract-msa-api-calls.sh" "$TARGET" 2>/dev/null)
events_json=$("$SCRIPT_DIR/extract-msa-events.sh" "$TARGET" 2>/dev/null)

# 검증
if ! echo "$calls_json" | jq . >/dev/null 2>&1; then
  log_warn "calls JSON invalid, treating as empty"
  calls_json='{"calls":[]}'
fi
if ! echo "$events_json" | jq . >/dev/null 2>&1; then
  log_warn "events JSON invalid, treating as empty"
  events_json='{"events":[]}'
fi

call_count=$(echo "$calls_json" | jq '.calls | length')
event_count=$(echo "$events_json" | jq '.events | length')

log_info "MSA artifacts: $call_count API calls, $event_count event references"

# -----------------------------------------------
# 1. api-calls/*.md - 호출별 1개
# -----------------------------------------------
slugify() {
  echo "$1" | tr '/' '-' | sed -E 's/[^a-zA-Z0-9_-]+/-/g' | sed -E 's/^-+|-+$//g' | sed -E 's/--+/-/g'
}

echo "$calls_json" | jq -c '.calls[]' 2>/dev/null | while IFS= read -r call; do
  caller=$(echo "$call"  | jq -r '.caller')
  callee=$(echo "$call"  | jq -r '.callee')
  method=$(echo "$call"  | jq -r '.method')
  path_=$(echo "$call"   | jq -r '.path')
  file=$(echo "$call"    | jq -r '.file')
  lib=$(echo "$call"     | jq -r '.client_lib')
  lang=$(echo "$call"    | jq -r '.language')
  sa=$(echo "$call"      | jq -r '.sync_async')

  path_slug=$(slugify "$path_")
  fname="${caller}__to__${callee}__${method}-${path_slug}.md"
  fpath="$OUT/api-calls/$fname"

  cat > "$fpath" <<MD
# $caller → $callee: $method $path_

- **Caller**: \`$caller\` (\`$file\`)
- **Callee**: \`$callee\`
- **Protocol**: HTTP/REST
- **Method**: $method
- **Path**: \`$path_\`
- **Client**: $lib ($lang)
- **Sync/Async**: $sa

## Mermaid Sequence

\`\`\`mermaid
sequenceDiagram
    autonumber
    participant C as $caller
    participant S as $callee
    C->>+S: $method $path_
    S-->>-C: response
\`\`\`

## 점검 항목

- [ ] Timeout 설정 명시 여부
- [ ] Retry 정책 (Resilience4j / Spring Retry / 없음)
- [ ] Error handling (try-catch / onErrorResume / .catch)
- [ ] Circuit breaker 적용 여부
- [ ] Tracing/Correlation ID 전파 여부
MD
done

# -----------------------------------------------
# 2. events/*.md - 토픽별 1개 (publishers + subscribers 결합)
# -----------------------------------------------
python3 - "$events_json" "$OUT/events" <<'PYEOF'
import json, sys, os, re

events = json.loads(sys.argv[1]).get("events", [])
out_dir = sys.argv[2]

by_topic = {}
for e in events:
    by_topic.setdefault(e["topic"], []).append(e)

def slug(s):
    s = re.sub(r'[^a-zA-Z0-9_-]+', '-', s).strip('-')
    return s or "unknown"

for topic, items in by_topic.items():
    publishers = [x for x in items if x["type"] == "publish"]
    subscribers = [x for x in items if x["type"] == "subscribe"]
    brokers = sorted({x["broker"] for x in items})

    fname = f"topic__{slug(topic)}.md"
    fpath = os.path.join(out_dir, fname)

    pub_rows = "\n".join(
        f"| {p['service']} | `{p['file']}` | {p['language']} |" for p in publishers
    ) or "| _(없음)_ | | |"
    sub_rows = "\n".join(
        f"| {s['service']} | `{s['file']}` | {s['language']} |" for s in subscribers
    ) or "| _(없음)_ | | |"

    pub_nodes = "\n".join(f"    {p['service']} -- publish --> T(({topic}))" for p in publishers) or f"    %% no publishers for {topic}"
    sub_nodes = "\n".join(f"    T(({topic})) --> {s['service']}" for s in subscribers) or f"    %% no subscribers for {topic}"

    md = f"""# Event: `{topic}`

- **Brokers**: {", ".join(brokers) or "unknown"}
- **Publishers**: {len(publishers)}
- **Subscribers**: {len(subscribers)}

## Publishers

| Service | File:Line | Language |
|---------|-----------|----------|
{pub_rows}

## Subscribers

| Service | File:Line | Language |
|---------|-----------|----------|
{sub_rows}

## Mermaid Flow

```mermaid
flowchart LR
{pub_nodes}
{sub_nodes}
```

## 위험 요소

- [ ] DLQ(Dead Letter Queue) 설정 여부
- [ ] 중복 처리 멱등성 보장
- [ ] 스키마 호환성 (forward/backward)
- [ ] 컨슈머 lag 모니터링
- [ ] 재시도 정책
"""
    with open(fpath, "w") as f:
        f.write(md)
PYEOF

# -----------------------------------------------
# 3. 00-overview.md - C4 컨테이너 다이어그램
# -----------------------------------------------
python3 - "$calls_json" "$events_json" "$OUT/00-overview.md" <<'PYEOF'
import json, sys

calls = json.loads(sys.argv[1]).get("calls", [])
events = json.loads(sys.argv[2]).get("events", [])
out_path = sys.argv[3]

services = set()
for c in calls:
    services.add(c["caller"])
    services.add(c["callee"])
for e in events:
    services.add(e["service"])

call_edges = sorted({(c["caller"], c["callee"]) for c in calls})
event_edges = []
# publish→topic, topic→subscribe
topics = {}
for e in events:
    topics.setdefault(e["topic"], {"pub": [], "sub": []})[("pub" if e["type"]=="publish" else "sub")].append(e["service"])

lines = [
    "# MSA Overview",
    "",
    f"- **Services**: {len(services)}",
    f"- **HTTP/gRPC calls (unique caller→callee pairs)**: {len(call_edges)}",
    f"- **Event topics**: {len(topics)}",
    "",
    "## Service Topology (Mermaid)",
    "",
    "```mermaid",
    "flowchart LR",
]

for s in sorted(services):
    lines.append(f"    {s}([{s}])")

for caller, callee in call_edges:
    lines.append(f"    {caller} -- HTTP --> {callee}")

for topic, info in sorted(topics.items()):
    tnode = f"T_{topic.replace('-', '_').replace('.', '_')}"
    lines.append(f"    {tnode}([(\"{topic}\")]):::topic")
    for p in sorted(set(info["pub"])):
        lines.append(f"    {p} == publish ==> {tnode}")
    for s in sorted(set(info["sub"])):
        lines.append(f"    {tnode} ==> {s}")

lines.append("    classDef topic fill:#fff3e0,stroke:#e65100;")
lines.append("```")
lines.append("")
lines.append("## 인덱스")
lines.append("")
lines.append("- [api-calls/](./api-calls/) — 호출별 상세 ({} 파일)".format(len(calls)))
lines.append("- [events/](./events/) — 이벤트 토픽별 ({} 파일)".format(len(topics)))
lines.append("- [sequence-diagrams/](./sequence-diagrams/) — 시나리오별 시퀀스 다이어그램")
lines.append("- [service-dependency-matrix.md](./service-dependency-matrix.md) — NxN 의존성 매트릭스")

with open(out_path, "w") as f:
    f.write("\n".join(lines))
PYEOF

# -----------------------------------------------
# 4. service-dependency-matrix.md
# -----------------------------------------------
python3 - "$calls_json" "$OUT/service-dependency-matrix.md" <<'PYEOF'
import json, sys

calls = json.loads(sys.argv[1]).get("calls", [])
out_path = sys.argv[2]

services = sorted({c["caller"] for c in calls} | {c["callee"] for c in calls})
matrix = {(s,t): 0 for s in services for t in services}
for c in calls:
    matrix[(c["caller"], c["callee"])] += 1

lines = ["# Service Dependency Matrix", "", "행=Caller, 열=Callee, 값=호출 라인 수", ""]
header = "| caller \\ callee |" + "|".join(f" {s} " for s in services) + "|"
sep = "|" + "|".join("---" for _ in range(len(services)+1)) + "|"
lines.append(header)
lines.append(sep)
for s in services:
    row = f"| **{s}** |"
    for t in services:
        v = matrix[(s,t)]
        row += f" {v if v else '-'} |"
    lines.append(row)

with open(out_path, "w") as f:
    f.write("\n".join(lines))
PYEOF

log_info "MSA docs generated at: $OUT"
log_info "  - 00-overview.md"
log_info "  - api-calls/ (${call_count} files)"
log_info "  - events/ (per topic)"
log_info "  - service-dependency-matrix.md"

echo "{\"output_dir\":\"$OUT\",\"call_count\":$call_count,\"event_count\":$event_count}"
