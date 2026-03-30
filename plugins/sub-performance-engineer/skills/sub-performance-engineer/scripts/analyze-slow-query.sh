#!/usr/bin/env bash
# Performance Engineer — Slow Query Pattern Detection
#
# Detects potential slow query patterns in source code.
#
# Usage: analyze-slow-query.sh [target-path]
# Output: JSON with detected patterns
#
# Dependencies: bash + jq only

set -euo pipefail

TARGET="${1:-.}"
PATTERNS="[]"

# N+1 pattern: findAll/getAll followed by forEach/map with nested query
while IFS= read -r file; do
  [ -z "$file" ] && continue
  # Detect findAll + loop patterns
  LINES=$(grep -nE '(findAll|getAll|fetchAll|select\s*\()' "$file" 2>/dev/null || true)
  if [ -n "$LINES" ]; then
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      LINE_NUM=$(echo "$line" | cut -d: -f1)
      PATTERNS=$(echo "${PATTERNS}" | jq --arg type "potential-n+1" --arg file "$file" --argjson line "$LINE_NUM" --arg desc "findAll/getAll pattern — check for N+1 in subsequent loop" \
        '. + [{type: $type, file: $file, line: $line, description: $desc}]')
    done <<< "$LINES"
  fi
done < <(find "${TARGET}" -name "*.kt" -o -name "*.java" 2>/dev/null | grep -v test | grep -v build | head -30)

# Missing index hints: queries without @Indexed or index annotation
while IFS= read -r file; do
  [ -z "$file" ] && continue
  if grep -qE '@(Query|NamedQuery|NativeQuery)' "$file" 2>/dev/null; then
    LINE_NUM=$(grep -nE '@(Query|NamedQuery|NativeQuery)' "$file" 2>/dev/null | head -1 | cut -d: -f1)
    PATTERNS=$(echo "${PATTERNS}" | jq --arg type "custom-query" --arg file "$file" --argjson line "${LINE_NUM:-0}" --arg desc "Custom query found — verify index coverage" \
      '. + [{type: $type, file: $file, line: $line, description: $desc}]')
  fi
done < <(find "${TARGET}" -name "*Repository*.kt" -o -name "*Repository*.java" -o -name "*Dao*.kt" -o -name "*Dao*.java" 2>/dev/null | grep -v test | head -20)

echo "${PATTERNS}" | jq '{patterns: ., summary: {total: (. | length), n_plus_1: ([.[] | select(.type == "potential-n+1")] | length), custom_queries: ([.[] | select(.type == "custom-query")] | length)}}'
