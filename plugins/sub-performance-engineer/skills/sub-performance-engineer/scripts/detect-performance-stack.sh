#!/usr/bin/env bash
# Performance Engineer — Performance Stack Detection
#
# Detects performance-related configuration in the project.
#
# Usage: detect-performance-stack.sh [project-root]
# Output: JSON with jvm, db, cache, monitoring info
#
# Dependencies: bash + jq only

set -euo pipefail

PROJECT_DIR="${1:-.}"

# JVM detection
JVM_VERSION="unknown"
GC_ALGO="unknown"
HEAP_SIZE="unknown"

if [ -f "${PROJECT_DIR}/build.gradle.kts" ] || [ -f "${PROJECT_DIR}/build.gradle" ]; then
  JVM_VERSION=$(grep -oE 'jvmTarget\s*=\s*"[^"]*"' "${PROJECT_DIR}/build.gradle"* 2>/dev/null | head -1 | grep -oE '"[^"]*"' | tr -d '"' || echo "unknown")
  GC_ALGO=$(grep -oE '(-XX:\+Use\w+GC)' "${PROJECT_DIR}/build.gradle"* 2>/dev/null | head -1 || echo "unknown")
fi

# Application properties
if find "${PROJECT_DIR}" -name "application*.yml" -o -name "application*.yaml" -o -name "application*.properties" 2>/dev/null | grep -q .; then
  APP_CONFIG=$(find "${PROJECT_DIR}" -name "application*.yml" -o -name "application*.yaml" -o -name "application*.properties" 2>/dev/null | head -1)

  # DB detection
  DB_TYPE="unknown"
  CONNECTION_POOL="unknown"
  if grep -qiE 'postgresql|postgres' "${APP_CONFIG}" 2>/dev/null; then DB_TYPE="postgresql"; fi
  if grep -qiE 'mysql' "${APP_CONFIG}" 2>/dev/null; then DB_TYPE="mysql"; fi
  if grep -qiE 'h2' "${APP_CONFIG}" 2>/dev/null; then DB_TYPE="h2"; fi
  if grep -qiE 'hikari' "${APP_CONFIG}" 2>/dev/null; then CONNECTION_POOL="hikari"; fi

  # Cache detection
  CACHE_TYPE="none"
  if grep -qiE 'redis' "${APP_CONFIG}" 2>/dev/null; then CACHE_TYPE="redis"; fi
  if grep -qiE 'caffeine' "${APP_CONFIG}" 2>/dev/null; then CACHE_TYPE="caffeine"; fi
  if grep -qiE 'ehcache' "${APP_CONFIG}" 2>/dev/null; then CACHE_TYPE="ehcache"; fi
else
  DB_TYPE="unknown"
  CONNECTION_POOL="unknown"
  CACHE_TYPE="none"
fi

# Monitoring detection
MONITORING=()
if grep -rqiE 'micrometer|actuator' "${PROJECT_DIR}/build.gradle"* "${PROJECT_DIR}/pom.xml" 2>/dev/null; then
  MONITORING+=("micrometer")
fi
if grep -rqiE 'prometheus' "${PROJECT_DIR}" --include="*.yml" --include="*.yaml" --include="*.xml" --include="*.gradle*" 2>/dev/null; then
  MONITORING+=("prometheus")
fi
if grep -rqiE 'datadog' "${PROJECT_DIR}" --include="*.yml" --include="*.yaml" --include="*.properties" 2>/dev/null; then
  MONITORING+=("datadog")
fi

MONITORING_JSON=$(printf '%s\n' "${MONITORING[@]}" 2>/dev/null | jq -R . | jq -s . 2>/dev/null || echo '[]')

jq -n \
  --arg jvm_version "${JVM_VERSION}" \
  --arg gc_algo "${GC_ALGO}" \
  --arg heap_size "${HEAP_SIZE}" \
  --arg db_type "${DB_TYPE}" \
  --arg connection_pool "${CONNECTION_POOL}" \
  --arg cache_type "${CACHE_TYPE}" \
  --argjson monitoring "${MONITORING_JSON}" \
  '{jvm: {version: $jvm_version, gc_algo: $gc_algo, heap_size: $heap_size}, db: {type: $db_type, connection_pool: $connection_pool}, cache: {type: $cache_type}, monitoring: $monitoring}'
