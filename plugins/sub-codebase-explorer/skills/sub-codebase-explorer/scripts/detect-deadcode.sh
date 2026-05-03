#!/usr/bin/env bash
# detect-deadcode.sh - 미사용 export/공개 함수/클래스 후보 탐지
# Usage: detect-deadcode.sh [TARGET_PATH]
# Output: JSON {candidates: [{name, file, kind, language}]}
#
# 휴리스틱 (정밀도 < 컴파일러):
#  - TS/JS: `export (function|const|class|interface) NAME` 정의 ↔ 다른 파일에서 `import { NAME }`
#  - Python: `def NAME(...)` / `class NAME` (top-level, no underscore prefix) ↔ `from .* import NAME`
#  - Kotlin/Java: `(public )?(class|fun|object) NAME` ↔ 다른 파일에서 NAME 참조

set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_common.sh"

TARGET="${1:-.}"
[ -d "$TARGET" ] || { echo '{"error":"target not a directory"}'; exit 1; }
cd "$TARGET" || exit 1

declare -a candidates=()

# 공통 검색 제외 경로
EXCLUDES="--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=build --exclude-dir=dist --exclude-dir=.venv --exclude-dir=venv --exclude-dir=target --exclude-dir=vendor"

emit() {
  local name="$1" file="$2" kind="$3" lang="$4"
  local esc_file
  esc_file=$(printf %s "$file" | sed 's/"/\\"/g')
  candidates+=("{\"name\":\"$name\",\"file\":\"$esc_file\",\"kind\":\"$kind\",\"language\":\"$lang\"}")
}

# count_refs <name> <def_file> -> 다른 파일에서 참조되는 횟수
count_refs() {
  local name="$1" def_file="$2"
  # 단어 경계로 매칭, 정의 파일은 제외
  grep -rEn $EXCLUDES \
    --include='*.kt' --include='*.java' --include='*.py' \
    --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
    --include='*.go' --include='*.rb' \
    "\\b${name}\\b" . 2>/dev/null \
    | grep -v "^${def_file}:" | wc -l | tr -d ' '
}

scan_file() {
  local file="$1"
  case "$file" in
    *.ts|*.tsx|*.js|*.jsx)
      grep -nE '^\s*export\s+(default\s+)?(function|const|let|var|class|interface|type|enum)\s+[A-Za-z_][A-Za-z0-9_]*' "$file" 2>/dev/null \
      | while IFS=: read -r ln rest; do
          name=$(echo "$rest" | sed -E 's/^\s*export\s+(default\s+)?(function|const|let|var|class|interface|type|enum)\s+([A-Za-z_][A-Za-z0-9_]*).*/\3/')
          [ -z "$name" ] && continue
          refs=$(count_refs "$name" "$file")
          [ "${refs:-0}" -le 0 ] && echo "ts|$name|$file:$ln|export"
        done
      ;;
    *.py)
      grep -nE '^(def|class)\s+[A-Za-z_][A-Za-z0-9_]*' "$file" 2>/dev/null \
      | while IFS=: read -r ln rest; do
          name=$(echo "$rest" | sed -E 's/^(def|class)\s+([A-Za-z_][A-Za-z0-9_]*).*/\2/')
          [ -z "$name" ] && continue
          [[ "$name" == _* ]] && continue
          refs=$(count_refs "$name" "$file")
          [ "${refs:-0}" -le 0 ] && echo "python|$name|$file:$ln|public"
        done
      ;;
    *.kt|*.java)
      grep -nE '^(public\s+)?(class|object|fun|interface)\s+[A-Za-z_][A-Za-z0-9_]*' "$file" 2>/dev/null \
      | while IFS=: read -r ln rest; do
          name=$(echo "$rest" | sed -E 's/^(public\s+)?(class|object|fun|interface)\s+([A-Za-z_][A-Za-z0-9_]*).*/\3/')
          [ -z "$name" ] && continue
          refs=$(count_refs "$name" "$file")
          [ "${refs:-0}" -le 0 ] && echo "jvm|$name|$file:$ln|public"
        done
      ;;
    *.go)
      grep -nE '^func\s+[A-Z][A-Za-z0-9_]*\s*\(' "$file" 2>/dev/null \
      | while IFS=: read -r ln rest; do
          name=$(echo "$rest" | sed -E 's/^func\s+([A-Z][A-Za-z0-9_]*)\s*\(.*/\1/')
          [ -z "$name" ] && continue
          refs=$(count_refs "$name" "$file")
          [ "${refs:-0}" -le 0 ] && echo "go|$name|$file:$ln|exported"
        done
      ;;
  esac
}

# 처리 대상 파일 (bash 3.2 호환, 상위 1000개)
files=()
while IFS= read -r f; do
  files+=("$f")
done < <(find . -type f \( \
    -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \
    -o -name "*.py" -o -name "*.kt" -o -name "*.java" -o -name "*.go" \
  \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" \
  -not -path "*/build/*" -not -path "*/dist/*" \
  -not -path "*/.venv/*" -not -path "*/venv/*" \
  -not -path "*/target/*" -not -path "*/vendor/*" 2>/dev/null | head -1000)

if [ "${#files[@]}" -eq 0 ]; then
  echo '{"candidates":[]}'
  exit 0
fi

for f in "${files[@]}"; do
  scan_file "$f"
done | while IFS='|' read -r lang name loc kind; do
  echo "{\"name\":\"$name\",\"file\":\"$loc\",\"kind\":\"$kind\",\"language\":\"$lang\"}"
done > /tmp/__sce_dead.jsonl

# 결합
echo -n '{"candidates":['
first=1
while IFS= read -r line; do
  [ -z "$line" ] && continue
  [ $first -eq 0 ] && echo -n ","
  echo -n "$line"
  first=0
done < /tmp/__sce_dead.jsonl
echo "]}"

rm -f /tmp/__sce_dead.jsonl
