#!/usr/bin/env bash
# Frontend Engineer — Bundle Size Measurement
#
# Analyzes dist/ folder to report JS/CSS bundle sizes.
# Compatible with bash 3.2+ (macOS default).
#
# Usage: measure-bundle-size.sh [project-root]
# Output: JSON with js_total, css_total, asset_total, largest_chunk, file_count
#
# Dependencies: bash + jq only

set -euo pipefail

TARGET="${1:-.}"
DIST_DIR="${TARGET}/dist"

# ── Check dist directory ────────────────────────────────
if [ ! -d "${DIST_DIR}" ]; then
  jq -n '{
    error: "No dist/ directory found. Run build first.",
    js_total_bytes: 0,
    css_total_bytes: 0,
    asset_total_bytes: 0,
    largest_chunk: "none",
    largest_chunk_bytes: 0,
    file_count: 0,
    status: "not_built"
  }'
  exit 0
fi

# ── Measure JS files ───────────────────────────────────
JS_TOTAL=0
JS_COUNT=0
LARGEST_CHUNK=""
LARGEST_CHUNK_SIZE=0
JS_FILES=""

while IFS= read -r file; do
  [ -z "${file}" ] && continue
  size=$(wc -c < "${file}" | tr -d ' ')
  JS_TOTAL=$((JS_TOTAL + size))
  JS_COUNT=$((JS_COUNT + 1))
  basename_file=$(basename "${file}")
  if [ "${size}" -gt "${LARGEST_CHUNK_SIZE}" ]; then
    LARGEST_CHUNK="${basename_file}"
    LARGEST_CHUNK_SIZE=${size}
  fi
  if [ -z "${JS_FILES}" ]; then
    JS_FILES="${basename_file}:${size}"
  else
    JS_FILES="${JS_FILES} ${basename_file}:${size}"
  fi
done < <(find "${DIST_DIR}" -name "*.js" -type f 2>/dev/null)

# ── Measure CSS files ──────────────────────────────────
CSS_TOTAL=0
CSS_COUNT=0

while IFS= read -r file; do
  [ -z "${file}" ] && continue
  size=$(wc -c < "${file}" | tr -d ' ')
  CSS_TOTAL=$((CSS_TOTAL + size))
  CSS_COUNT=$((CSS_COUNT + 1))
done < <(find "${DIST_DIR}" -name "*.css" -type f 2>/dev/null)

# ── Measure all assets ─────────────────────────────────
ASSET_TOTAL=0
ASSET_COUNT=0

while IFS= read -r file; do
  [ -z "${file}" ] && continue
  size=$(wc -c < "${file}" | tr -d ' ')
  ASSET_TOTAL=$((ASSET_TOTAL + size))
  ASSET_COUNT=$((ASSET_COUNT + 1))
done < <(find "${DIST_DIR}" -type f 2>/dev/null)

# ── Status determination ───────────────────────────────
# Based on uncompressed sizes (gzip typically ~30% of original)
JS_GZIP_EST=$((JS_TOTAL * 30 / 100))
if [ "${JS_GZIP_EST}" -lt 204800 ]; then
  STATUS="good"
elif [ "${JS_GZIP_EST}" -lt 512000 ]; then
  STATUS="warning"
else
  STATUS="danger"
fi

# ── Helper: format bytes ───────────────────────────────
format_bytes() {
  local bytes=$1
  if [ "${bytes}" -ge 1048576 ]; then
    echo "$((bytes / 1048576)).$((bytes % 1048576 * 10 / 1048576))MB"
  elif [ "${bytes}" -ge 1024 ]; then
    echo "$((bytes / 1024)).$((bytes % 1024 * 10 / 1024))KB"
  else
    echo "${bytes}B"
  fi
}

JS_DISPLAY=$(format_bytes ${JS_TOTAL})
CSS_DISPLAY=$(format_bytes ${CSS_TOTAL})
ASSET_DISPLAY=$(format_bytes ${ASSET_TOTAL})
LARGEST_DISPLAY=$(format_bytes ${LARGEST_CHUNK_SIZE})

# ── Build JSON output ──────────────────────────────────
jq -n \
  --argjson js_total_bytes "${JS_TOTAL}" \
  --arg js_total "${JS_DISPLAY}" \
  --argjson css_total_bytes "${CSS_TOTAL}" \
  --arg css_total "${CSS_DISPLAY}" \
  --argjson asset_total_bytes "${ASSET_TOTAL}" \
  --arg asset_total "${ASSET_DISPLAY}" \
  --arg largest_chunk "${LARGEST_CHUNK:-none}" \
  --argjson largest_chunk_bytes "${LARGEST_CHUNK_SIZE}" \
  --arg largest_chunk_size "${LARGEST_DISPLAY}" \
  --argjson js_count "${JS_COUNT}" \
  --argjson css_count "${CSS_COUNT}" \
  --argjson file_count "${ASSET_COUNT}" \
  --arg status "${STATUS}" \
  '{
    js_total_bytes: $js_total_bytes,
    js_total: $js_total,
    css_total_bytes: $css_total_bytes,
    css_total: $css_total,
    asset_total_bytes: $asset_total_bytes,
    asset_total: $asset_total,
    largest_chunk: $largest_chunk,
    largest_chunk_bytes: $largest_chunk_bytes,
    largest_chunk_size: $largest_chunk_size,
    js_file_count: $js_count,
    css_file_count: $css_count,
    total_file_count: $file_count,
    status: $status
  }'
