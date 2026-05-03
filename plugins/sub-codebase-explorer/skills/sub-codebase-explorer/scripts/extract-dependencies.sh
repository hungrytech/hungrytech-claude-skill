#!/usr/bin/env bash
# extract-dependencies.sh - 모듈 import 그래프 추출 (다언어)
# Usage: extract-dependencies.sh [TARGET_PATH]
# Output: JSON {nodes:[...], edges:[{from, to, count}]} to stdout
#
# 휴리스틱:
#  - 모듈 = 첫 단계 디렉토리 (services/*, apps/*, packages/*, src/main/<lang>/<top-pkg>)
#         또는 settings.gradle include() 항목
#  - 엣지 = import/require/from 문에 다른 모듈명/패키지명 포함

set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_common.sh"

TARGET="${1:-.}"
[ -d "$TARGET" ] || { echo '{"error":"target not a directory"}'; exit 1; }
cd "$TARGET" || exit 1

# 모듈 후보 수집
modules=()
for parent in services apps packages modules cmd; do
  if [ -d "$parent" ]; then
    while IFS= read -r d; do
      modules+=("$(basename "$d")")
    done < <(find "$parent" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  fi
done
# Gradle 멀티모듈
for f in settings.gradle settings.gradle.kts; do
  if [ -f "$f" ]; then
    while IFS= read -r m; do
      modules+=("$m")
    done < <(grep -oE "include\s*[(\"']:?[a-zA-Z0-9_-]+" "$f" 2>/dev/null \
              | sed -E "s/include\s*[(\"']:?//")
  fi
done
# 단일 모듈 폴백
if [ "${#modules[@]}" -eq 0 ]; then
  modules=("$(basename "$(pwd)")")
fi

# 중복 제거 (bash 3.2 호환 — mapfile 미지원)
if [ "${#modules[@]}" -gt 0 ]; then
  unique_modules=()
  while IFS= read -r m; do
    [ -n "$m" ] && unique_modules+=("$m")
  done < <(printf '%s\n' "${modules[@]}" | sort -u | grep -v '^$')
  modules=("${unique_modules[@]}")
fi

# 각 모듈의 소스 디렉토리 결정
module_dir() {
  local m="$1"
  for parent in services apps packages modules cmd; do
    [ -d "$parent/$m" ] && { echo "$parent/$m"; return; }
  done
  [ -d "$m" ] && { echo "$m"; return; }
  echo "."
}

# 모듈별 import 라인 수집
declare -a edge_lines=()

for m in "${modules[@]}"; do
  src=$(module_dir "$m")
  [ -d "$src" ] || continue
  # 모든 다른 모듈명에 대해 import 매칭 카운트
  for target_m in "${modules[@]}"; do
    [ "$m" = "$target_m" ] && continue
    # import/from/require 라인 중 target 모듈명 포함
    count=$(grep -rEn --include='*.kt' --include='*.java' --include='*.py' \
                     --include='*.ts' --include='*.tsx' --include='*.js' \
                     --include='*.go' --include='*.rb' \
                     -E "^(import|from|require|use)\b.*$target_m" "$src" 2>/dev/null | wc -l | tr -d ' ')
    if [ "${count:-0}" -gt 0 ]; then
      edge_lines+=("{\"from\":\"$m\",\"to\":\"$target_m\",\"count\":$count}")
    fi
  done
done

# JSON 출력 (빈 배열 안전)
if [ "${#modules[@]}" -eq 0 ]; then
  nodes_json="[]"
else
  nodes_json=$(printf '%s\n' "${modules[@]}" | jq -R . 2>/dev/null | jq -s . 2>/dev/null || echo "[]")
fi
edges_json="["
first=1
if [ "${#edge_lines[@]}" -gt 0 ]; then
  for e in "${edge_lines[@]}"; do
    [ $first -eq 0 ] && edges_json+=","
    edges_json+="$e"
    first=0
  done
fi
edges_json+="]"

cat <<EOF
{
  "target": "$(pwd)",
  "modules": $nodes_json,
  "edges": $edges_json
}
EOF
