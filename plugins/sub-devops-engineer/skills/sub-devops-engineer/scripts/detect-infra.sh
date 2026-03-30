#!/usr/bin/env bash
# DevOps Engineer — Infrastructure Detection
#
# Detects existing infrastructure files in the project.
#
# Usage: detect-infra.sh [project-root]
# Output: JSON with detected infrastructure
#
# Dependencies: bash + jq only

set -euo pipefail

PROJECT_DIR="${1:-.}"

HAS_DOCKER="false"
CI_TOOL="none"
ORCHESTRATOR="none"
IAC_TOOL="none"
EXISTING_FILES=()

# Docker
if [ -f "${PROJECT_DIR}/Dockerfile" ] || find "${PROJECT_DIR}" -maxdepth 2 -name "Dockerfile*" 2>/dev/null | grep -q .; then
  HAS_DOCKER="true"
  while IFS= read -r f; do EXISTING_FILES+=("$f"); done < <(find "${PROJECT_DIR}" -maxdepth 2 -name "Dockerfile*" 2>/dev/null)
fi
if [ -f "${PROJECT_DIR}/docker-compose.yml" ] || [ -f "${PROJECT_DIR}/docker-compose.yaml" ]; then
  while IFS= read -r f; do EXISTING_FILES+=("$f"); done < <(find "${PROJECT_DIR}" -maxdepth 2 -name "docker-compose*" 2>/dev/null)
fi

# CI/CD
if [ -d "${PROJECT_DIR}/.github/workflows" ]; then
  CI_TOOL="github-actions"
  while IFS= read -r f; do EXISTING_FILES+=("$f"); done < <(find "${PROJECT_DIR}/.github/workflows" -name "*.yml" -o -name "*.yaml" 2>/dev/null)
elif [ -f "${PROJECT_DIR}/.gitlab-ci.yml" ]; then
  CI_TOOL="gitlab-ci"
  EXISTING_FILES+=("${PROJECT_DIR}/.gitlab-ci.yml")
elif [ -f "${PROJECT_DIR}/Jenkinsfile" ]; then
  CI_TOOL="jenkins"
  EXISTING_FILES+=("${PROJECT_DIR}/Jenkinsfile")
fi

# Orchestrator
if [ -d "${PROJECT_DIR}/k8s" ] || [ -d "${PROJECT_DIR}/kubernetes" ] || find "${PROJECT_DIR}" -maxdepth 2 -name "*.k8s.yaml" 2>/dev/null | grep -q .; then
  ORCHESTRATOR="kubernetes"
  while IFS= read -r f; do EXISTING_FILES+=("$f"); done < <(find "${PROJECT_DIR}/k8s" "${PROJECT_DIR}/kubernetes" -type f 2>/dev/null | head -20)
fi
if find "${PROJECT_DIR}" -maxdepth 2 -name "Chart.yaml" 2>/dev/null | grep -q .; then
  ORCHESTRATOR="helm"
fi

# IaC
if find "${PROJECT_DIR}" -maxdepth 3 -name "*.tf" 2>/dev/null | grep -q .; then
  IAC_TOOL="terraform"
  while IFS= read -r f; do EXISTING_FILES+=("$f"); done < <(find "${PROJECT_DIR}" -maxdepth 3 -name "*.tf" 2>/dev/null | head -10)
fi

FILES_JSON=$(printf '%s\n' "${EXISTING_FILES[@]}" 2>/dev/null | jq -R . | jq -s . 2>/dev/null || echo '[]')

jq -n \
  --argjson docker "${HAS_DOCKER}" \
  --arg ci_tool "${CI_TOOL}" \
  --arg orchestrator "${ORCHESTRATOR}" \
  --arg iac_tool "${IAC_TOOL}" \
  --argjson existing_files "${FILES_JSON}" \
  '{docker: $docker, ci_tool: $ci_tool, orchestrator: $orchestrator, iac_tool: $iac_tool, existing_files: $existing_files}'
