#!/usr/bin/env bash
# Code Reviewer — Basic Complexity Measurement
#
# Measures basic complexity metrics for source files.
#
# Usage: measure-complexity.sh <target-path> [--extension kt|java|ts|py|go]
# Output: JSON with file metrics
#
# Dependencies: bash + jq only

set -euo pipefail

TARGET="${1:-.}"
EXT="${2:-}"

# Auto-detect extension if not provided
if [ -z "${EXT}" ]; then
  for e in kt java ts py go; do
    count=$(find "${TARGET}" -name "*.${e}" -not -path "*/test/*" -not -path "*/node_modules/*" 2>/dev/null | wc -l | tr -d ' ')
    if [ "${count}" -gt 0 ]; then
      EXT="${e}"
      break
    fi
  done
fi

if [ -z "${EXT}" ]; then
  echo '{"error":"No source files found","files":[]}' | jq .
  exit 1
fi

# Find source files (exclude test/build dirs)
FILES=$(find "${TARGET}" -name "*.${EXT}" \
  -not -path "*/test/*" -not -path "*/Test*" \
  -not -path "*/build/*" -not -path "*/target/*" \
  -not -path "*/node_modules/*" -not -path "*/.gradle/*" \
  2>/dev/null | head -50)

RESULTS="[]"
while IFS= read -r file; do
  [ -z "$file" ] && continue
  LINES=$(wc -l < "$file" | tr -d ' ')

  # Count methods/functions
  case $EXT in
    kt|java) METHODS=$(grep -cE '^\s*(public|private|protected|internal|override)?\s*(fun|static|void|suspend)\s' "$file" 2>/dev/null || echo 0) ;;
    ts) METHODS=$(grep -cE '^\s*(public|private|protected|async)?\s*(function|\w+\s*\()' "$file" 2>/dev/null || echo 0) ;;
    py) METHODS=$(grep -cE '^\s*def\s' "$file" 2>/dev/null || echo 0) ;;
    go) METHODS=$(grep -cE '^func\s' "$file" 2>/dev/null || echo 0) ;;
    *) METHODS=0 ;;
  esac

  # Count classes/structs
  case $EXT in
    kt|java) CLASSES=$(grep -cE '^\s*(class|interface|enum|object|data class|sealed class|abstract class)\s' "$file" 2>/dev/null || echo 0) ;;
    ts) CLASSES=$(grep -cE '^\s*(export\s+)?(class|interface|enum)\s' "$file" 2>/dev/null || echo 0) ;;
    py) CLASSES=$(grep -cE '^\s*class\s' "$file" 2>/dev/null || echo 0) ;;
    go) CLASSES=$(grep -cE '^\s*type\s+\w+\s+struct' "$file" 2>/dev/null || echo 0) ;;
    *) CLASSES=0 ;;
  esac

  RESULTS=$(echo "${RESULTS}" | jq --arg path "$file" --argjson lines "$LINES" --argjson methods "$METHODS" --argjson classes "$CLASSES" \
    '. + [{path: $path, lines: $lines, methods: $methods, classes: $classes}]')
done <<< "$FILES"

echo "${RESULTS}" | jq '{files: ., summary: {total_files: (. | length), total_lines: ([.[].lines] | add // 0), avg_lines_per_file: (([.[].lines] | add // 0) / ([.[].lines] | length) | floor)}}'
