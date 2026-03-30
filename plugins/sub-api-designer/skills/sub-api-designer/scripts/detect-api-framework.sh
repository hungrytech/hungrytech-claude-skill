#!/usr/bin/env bash
# API Designer — API Framework Detection
#
# Detects the API framework used in the project.
#
# Usage: detect-api-framework.sh [project-root]
# Output: JSON with framework, language, router_type, has_openapi_config
#
# Dependencies: bash + jq only

set -euo pipefail

PROJECT_DIR="${1:-.}"
FRAMEWORK="unknown"
LANGUAGE="unknown"
ROUTER_TYPE="unknown"
HAS_OPENAPI="false"

# Detect by build/config files
if [ -f "${PROJECT_DIR}/build.gradle.kts" ] || [ -f "${PROJECT_DIR}/build.gradle" ]; then
  LANGUAGE="kotlin/java"
  if grep -qiE 'spring-boot-starter-web' "${PROJECT_DIR}/build.gradle"* 2>/dev/null; then
    FRAMEWORK="spring-webmvc"
    ROUTER_TYPE="annotation"
  elif grep -qiE 'spring-boot-starter-webflux' "${PROJECT_DIR}/build.gradle"* 2>/dev/null; then
    FRAMEWORK="spring-webflux"
    ROUTER_TYPE="functional"
  fi
elif [ -f "${PROJECT_DIR}/pom.xml" ]; then
  LANGUAGE="java"
  if grep -qiE 'spring-boot-starter-web' "${PROJECT_DIR}/pom.xml" 2>/dev/null; then
    FRAMEWORK="spring-webmvc"
    ROUTER_TYPE="annotation"
  fi
elif [ -f "${PROJECT_DIR}/package.json" ]; then
  LANGUAGE="typescript/javascript"
  if grep -qiE '"express"' "${PROJECT_DIR}/package.json" 2>/dev/null; then
    FRAMEWORK="express"
    ROUTER_TYPE="middleware"
  elif grep -qiE '"fastify"' "${PROJECT_DIR}/package.json" 2>/dev/null; then
    FRAMEWORK="fastify"
    ROUTER_TYPE="plugin"
  elif grep -qiE '"@nestjs/core"' "${PROJECT_DIR}/package.json" 2>/dev/null; then
    FRAMEWORK="nestjs"
    ROUTER_TYPE="decorator"
  fi
elif [ -f "${PROJECT_DIR}/go.mod" ]; then
  LANGUAGE="go"
  if grep -qiE 'gin-gonic' "${PROJECT_DIR}/go.mod" 2>/dev/null; then
    FRAMEWORK="gin"
    ROUTER_TYPE="handler"
  elif grep -qiE 'go-chi' "${PROJECT_DIR}/go.mod" 2>/dev/null; then
    FRAMEWORK="chi"
    ROUTER_TYPE="middleware"
  fi
elif [ -f "${PROJECT_DIR}/requirements.txt" ] || [ -f "${PROJECT_DIR}/pyproject.toml" ]; then
  LANGUAGE="python"
  if grep -qiE 'fastapi' "${PROJECT_DIR}/requirements.txt" "${PROJECT_DIR}/pyproject.toml" 2>/dev/null; then
    FRAMEWORK="fastapi"
    ROUTER_TYPE="decorator"
  elif grep -qiE 'django' "${PROJECT_DIR}/requirements.txt" "${PROJECT_DIR}/pyproject.toml" 2>/dev/null; then
    FRAMEWORK="django"
    ROUTER_TYPE="urlconf"
  fi
fi

# Check for OpenAPI config
if find "${PROJECT_DIR}" -maxdepth 3 -name "openapi*.yaml" -o -name "openapi*.yml" -o -name "openapi*.json" -o -name "swagger*.yaml" -o -name "swagger*.json" 2>/dev/null | grep -q .; then
  HAS_OPENAPI="true"
fi

jq -n \
  --arg framework "${FRAMEWORK}" \
  --arg language "${LANGUAGE}" \
  --arg router_type "${ROUTER_TYPE}" \
  --argjson has_openapi "${HAS_OPENAPI}" \
  '{framework: $framework, language: $language, router_type: $router_type, has_openapi_config: $has_openapi}'
