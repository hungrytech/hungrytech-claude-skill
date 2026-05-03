#!/usr/bin/env bash
# analyze-git-hotspot.sh - Git 변경 빈도 × 파일 크기로 hotspot 산출
# Usage: analyze-git-hotspot.sh [TARGET_PATH] [SINCE]
#   SINCE 기본값: "6 months ago"
# Output: JSON {hotspots: [{path, commits, lines, score}]} (score = commits * lines)

set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_common.sh"

TARGET="${1:-.}"
SINCE="${2:-6 months ago}"

cd "$TARGET" || { echo '{"error":"target not a directory"}'; exit 1; }
git rev-parse --git-dir >/dev/null 2>&1 || { echo '{"error":"not a git repo"}'; exit 1; }

# 1) 파일별 커밋 수
tmp_commits=$(mktemp)
git log --since="$SINCE" --pretty=format: --name-only 2>/dev/null \
  | grep -v '^$' \
  | sort | uniq -c | sort -rn > "$tmp_commits"

# 2) 결과 빌드: 상위 50개
out="["
first=1
while read -r line; do
  count=$(echo "$line" | awk '{print $1}')
  path=$(echo "$line" | awk '{for (i=2; i<=NF; i++) printf "%s%s", $i, (i==NF?"":" ")}')
  [ -z "$path" ] && continue
  # 현재 시점에 파일 존재 여부 + 라인 수
  if [ -f "$path" ]; then
    lines=$(wc -l < "$path" 2>/dev/null | tr -d ' ')
  else
    lines=0
  fi
  score=$((count * (lines == 0 ? 1 : lines)))
  [ $first -eq 0 ] && out+=","
  out+="{\"path\":\"$(printf %s "$path" | sed 's/"/\\"/g')\",\"commits\":$count,\"lines\":$lines,\"score\":$score}"
  first=0
done < <(head -50 "$tmp_commits")
out+="]"

rm -f "$tmp_commits"

# score 내림차순 정렬 (jq 사용)
echo "{\"since\":\"$SINCE\",\"hotspots\":$out}" \
  | jq '. + {hotspots: (.hotspots | sort_by(-.score))}' 2>/dev/null \
  || echo "{\"since\":\"$SINCE\",\"hotspots\":$out}"
