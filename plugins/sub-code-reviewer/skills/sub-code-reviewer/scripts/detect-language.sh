#!/usr/bin/env bash
# Code Reviewer — Language Detection
#
# Detects the primary language of the target path.
# Compatible with bash 3.2+ (macOS default).
#
# Usage: detect-language.sh [target-path]
# Output: JSON with language, file_count, framework_hints[]
#
# Dependencies: bash + jq only

set -euo pipefail

TARGET="${1:-.}"
MAX_COUNT=0
LANGUAGE="unknown"
HINTS=""

# Count files by extension and find the primary language
for ext in kt java ts tsx py go rs rb; do
  count=$(find "${TARGET}" -name "*.${ext}" -not -path "*/node_modules/*" -not -path "*/.gradle/*" -not -path "*/build/*" -not -path "*/target/*" 2>/dev/null | wc -l | tr -d ' ')
  if [ "${count}" -gt "${MAX_COUNT}" ]; then
    MAX_COUNT=${count}
    case $ext in
      kt) LANGUAGE="kotlin" ;;
      java) LANGUAGE="java" ;;
      ts|tsx) LANGUAGE="typescript" ;;
      py) LANGUAGE="python" ;;
      go) LANGUAGE="go" ;;
      rs) LANGUAGE="rust" ;;
      rb) LANGUAGE="ruby" ;;
    esac
  fi
done

# Detect framework hints
add_hint() {
  if [ -z "${HINTS}" ]; then
    HINTS="$1"
  else
    HINTS="${HINTS} $1"
  fi
}

if [ -f "${TARGET}/build.gradle.kts" ] || [ -f "${TARGET}/build.gradle" ]; then
  add_hint "gradle"
  grep -qiE 'spring' "${TARGET}/build.gradle"* 2>/dev/null && add_hint "spring-boot"
fi
[ -f "${TARGET}/pom.xml" ] && add_hint "maven"
[ -f "${TARGET}/package.json" ] && add_hint "node"
[ -f "${TARGET}/go.mod" ] && add_hint "go-modules"
[ -f "${TARGET}/Cargo.toml" ] && add_hint "cargo"

if [ -z "${HINTS}" ]; then
  HINTS_JSON='[]'
else
  HINTS_JSON=$(echo "${HINTS}" | tr ' ' '\n' | jq -R . | jq -s . 2>/dev/null || echo '[]')
fi

jq -n \
  --arg language "${LANGUAGE}" \
  --argjson file_count "${MAX_COUNT}" \
  --argjson framework_hints "${HINTS_JSON}" \
  '{language: $language, file_count: $file_count, framework_hints: $framework_hints}'
