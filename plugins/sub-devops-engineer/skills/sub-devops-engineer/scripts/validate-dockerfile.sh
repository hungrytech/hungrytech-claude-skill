#!/usr/bin/env bash
# DevOps Engineer — Dockerfile Validation
#
# Validates Dockerfile best practices.
#
# Usage: validate-dockerfile.sh <dockerfile-path>
# Output: JSON with valid, warnings[], suggestions[]
#
# Dependencies: bash + jq only

set -euo pipefail

DOCKERFILE="${1:-Dockerfile}"
if [ ! -f "${DOCKERFILE}" ]; then
  echo '{"valid":false,"warnings":["Dockerfile not found"],"suggestions":[]}' | jq .
  exit 1
fi

WARNINGS=()
SUGGESTIONS=()

# Check for FROM
if ! grep -qE '^FROM\s' "${DOCKERFILE}"; then
  WARNINGS+=("Missing FROM instruction")
fi

# Check for multi-stage build
STAGE_COUNT=$(grep -cE '^FROM\s' "${DOCKERFILE}" || echo 0)
if [ "${STAGE_COUNT}" -lt 2 ]; then
  SUGGESTIONS+=("Consider multi-stage build to reduce image size")
fi

# Check for non-root user
if ! grep -qE '^\s*USER\s' "${DOCKERFILE}"; then
  WARNINGS+=("No USER instruction — container runs as root")
fi

# Check for HEALTHCHECK
if ! grep -qE '^\s*HEALTHCHECK\s' "${DOCKERFILE}"; then
  SUGGESTIONS+=("Add HEALTHCHECK for container health monitoring")
fi

# Check for pinned versions
if grep -qE '^FROM\s+\w+:latest' "${DOCKERFILE}"; then
  WARNINGS+=("Using :latest tag — pin to specific version for reproducibility")
fi

# Check for COPY vs ADD
if grep -qE '^\s*ADD\s' "${DOCKERFILE}"; then
  SUGGESTIONS+=("Prefer COPY over ADD unless extracting archives")
fi

# Check for layer caching
if grep -qE 'COPY\s+\.\s' "${DOCKERFILE}" && ! grep -qE 'COPY.*requirements\|COPY.*package.*json\|COPY.*build\.gradle\|COPY.*pom\.xml' "${DOCKERFILE}"; then
  SUGGESTIONS+=("Copy dependency files first, then source code for better layer caching")
fi

VALID="true"
if [ ${#WARNINGS[@]} -gt 0 ]; then
  VALID="false"
fi

WARNINGS_JSON=$(printf '%s\n' "${WARNINGS[@]}" 2>/dev/null | jq -R . | jq -s . 2>/dev/null || echo '[]')
SUGGESTIONS_JSON=$(printf '%s\n' "${SUGGESTIONS[@]}" 2>/dev/null | jq -R . | jq -s . 2>/dev/null || echo '[]')

jq -n \
  --argjson valid "${VALID}" \
  --argjson warnings "${WARNINGS_JSON}" \
  --argjson suggestions "${SUGGESTIONS_JSON}" \
  '{valid: $valid, warnings: $warnings, suggestions: $suggestions}'
