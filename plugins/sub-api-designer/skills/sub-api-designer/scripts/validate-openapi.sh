#!/usr/bin/env bash
# API Designer — OpenAPI Spec Validation
#
# Validates basic structure of an OpenAPI spec file.
#
# Usage: validate-openapi.sh <spec-file>
# Output: JSON with valid, errors[], warnings[]
#
# Dependencies: bash + jq only

set -euo pipefail

SPEC_FILE="${1:-}"
if [ -z "${SPEC_FILE}" ] || [ ! -f "${SPEC_FILE}" ]; then
  echo '{"valid":false,"errors":["Spec file not found or not specified"],"warnings":[]}' | jq .
  exit 1
fi

ERRORS=()
WARNINGS=()

# Check file extension
if ! echo "${SPEC_FILE}" | grep -qE '\.(yaml|yml|json)$'; then
  ERRORS+=("File must be .yaml, .yml, or .json")
fi

# Check for required OpenAPI fields
if ! grep -qE '^openapi:' "${SPEC_FILE}" 2>/dev/null && ! grep -qE '"openapi"' "${SPEC_FILE}" 2>/dev/null; then
  ERRORS+=("Missing 'openapi' version field")
fi

if ! grep -qE '^info:' "${SPEC_FILE}" 2>/dev/null && ! grep -qE '"info"' "${SPEC_FILE}" 2>/dev/null; then
  ERRORS+=("Missing 'info' section")
fi

if ! grep -qE '^paths:' "${SPEC_FILE}" 2>/dev/null && ! grep -qE '"paths"' "${SPEC_FILE}" 2>/dev/null; then
  WARNINGS+=("Missing 'paths' section — spec may be incomplete")
fi

# Check for common issues
if grep -qE 'openapi:\s*["\x27]?2\.' "${SPEC_FILE}" 2>/dev/null; then
  WARNINGS+=("Using Swagger 2.x — consider upgrading to OpenAPI 3.1")
fi

if ! grep -qE 'components:' "${SPEC_FILE}" 2>/dev/null; then
  WARNINGS+=("No 'components' section — consider defining reusable schemas")
fi

# Build result
VALID="true"
if [ ${#ERRORS[@]} -gt 0 ]; then
  VALID="false"
fi

ERRORS_JSON=$(printf '%s\n' "${ERRORS[@]}" 2>/dev/null | jq -R . | jq -s . 2>/dev/null || echo '[]')
WARNINGS_JSON=$(printf '%s\n' "${WARNINGS[@]}" 2>/dev/null | jq -R . | jq -s . 2>/dev/null || echo '[]')

jq -n \
  --argjson valid "${VALID}" \
  --argjson errors "${ERRORS_JSON}" \
  --argjson warnings "${WARNINGS_JSON}" \
  '{valid: $valid, errors: $errors, warnings: $warnings}'
