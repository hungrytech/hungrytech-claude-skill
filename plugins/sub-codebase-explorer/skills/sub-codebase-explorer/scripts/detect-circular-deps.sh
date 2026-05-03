#!/usr/bin/env bash
# detect-circular-deps.sh - Tarjan SCC 알고리즘으로 순환 의존성 탐지
# Usage: detect-circular-deps.sh [TARGET_PATH]
# Input  : extract-dependencies.sh의 출력 (자동 호출)
# Output : JSON {cycles: [[a,b,c], [d,e]]} (각 cycle은 SCC, 크기 ≥ 2만 보고)

set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_common.sh"

TARGET="${1:-.}"

deps_json=$("$SCRIPT_DIR/extract-dependencies.sh" "$TARGET" 2>/dev/null)
if [ -z "$deps_json" ] || ! echo "$deps_json" | jq . >/dev/null 2>&1; then
  echo '{"error":"failed to extract dependencies"}'; exit 1
fi

# Python으로 Tarjan SCC 실행 (bash로 그래프 알고리즘 작성하면 너무 복잡)
if ! command -v python3 >/dev/null 2>&1; then
  log_warn "python3 missing — fallback to simple back-edge detection"
  echo "$deps_json" | jq '{cycles: []}'
  exit 0
fi

python3 - <<PYEOF
import json, sys

data = json.loads('''$deps_json''')
nodes = data.get("modules", [])
edges = data.get("edges", [])

# 인접 리스트
graph = {n: [] for n in nodes}
for e in edges:
    if e["from"] in graph and e["to"] in graph:
        graph[e["from"]].append(e["to"])

# Tarjan SCC
index_counter = [0]
stack = []
lowlinks = {}
index = {}
on_stack = {}
sccs = []

def strongconnect(node):
    index[node] = index_counter[0]
    lowlinks[node] = index_counter[0]
    index_counter[0] += 1
    stack.append(node)
    on_stack[node] = True

    for successor in graph[node]:
        if successor not in index:
            strongconnect(successor)
            lowlinks[node] = min(lowlinks[node], lowlinks[successor])
        elif on_stack.get(successor):
            lowlinks[node] = min(lowlinks[node], index[successor])

    if lowlinks[node] == index[node]:
        scc = []
        while True:
            w = stack.pop()
            on_stack[w] = False
            scc.append(w)
            if w == node:
                break
        if len(scc) >= 2:
            sccs.append(scc)
        # 자기 루프도 순환
        elif len(scc) == 1 and scc[0] in graph[scc[0]]:
            sccs.append(scc)

sys.setrecursionlimit(10000)
for n in nodes:
    if n not in index:
        strongconnect(n)

print(json.dumps({"cycles": sccs, "module_count": len(nodes)}, indent=2))
PYEOF
