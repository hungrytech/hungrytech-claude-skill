#!/usr/bin/env bash
# Team Lead — Request Classification (Fast Path)
#
# Classifies a user query into expert skill(s) using keyword matching.
# Compatible with bash 3.2+ (macOS default).
#
# Usage: classify-request.sh "query text"
# Output: JSON with experts[], confidence, pattern
#
# Dependencies: bash + jq only

set -euo pipefail

# ── Input ─────────────────────────────────────────────────
QUERY="${1:-}"
if [ -z "${QUERY}" ]; then
  echo '{"error":"No query provided","experts":[],"confidence":0,"pattern":"none"}' | jq .
  exit 1
fi

QUERY_LOWER=$(printf '%s' "${QUERY}" | tr '[:upper:]' '[:lower:]')

# ── Expert Keyword Matching (bash 3.2 compatible) ────────
EXPERTS=""
EXPERT_COUNT=0

match_expert() {
  local name="$1"
  local pattern="$2"
  local count
  count=$(echo "${QUERY_LOWER}" | { grep -oiE "${pattern}" 2>/dev/null || true; } | wc -l | tr -d ' ')
  if [ "${count}" -gt 0 ]; then
    if [ -z "${EXPERTS}" ]; then
      EXPERTS="${name}"
    else
      EXPERTS="${EXPERTS} ${name}"
    fi
    EXPERT_COUNT=$((EXPERT_COUNT + 1))
  fi
}

match_expert "sub-frontend-engineer"     "react|vite|frontend|프론트엔드|component|컴포넌트|tailwind|zustand|tanstack|vitest|프론트|ui |페이지|화면"
match_expert "sub-kopring-engineer"      "kotlin|java|spring|hexagonal|jpa|jooq|gradle|controller|repository|entity|kopring"
match_expert "sub-test-engineer"         "test|coverage|mutation|property-test|junit|kotest|jest|테스트|커버리지"
match_expert "sub-api-designer"          "api design|openapi|rest api|swagger|endpoint|api 설계|api 문서|breaking change|contract"
match_expert "sub-code-reviewer"         "code review|refactor|코드 리뷰|리팩토링|code smell|기술 부채|tech debt|solid|complexity|clean code"
match_expert "sub-devops-engineer"       "devops|ci/cd|docker|kubernetes|terraform|github actions|배포|deploy|pipeline|k8s|helm|gitlab ci|dockerfile"
match_expert "sub-performance-engineer"  "performance|성능|latency|load test|부하 테스트|gc tuning|slow query|n\\+1|profiling|cache|connection pool|throughput"
match_expert "engineering-workflow"       "architecture|아키텍처|decision|의사결정|db design|인프라|security|보안|설계 결정"
match_expert "numerical"                 "numerical|tensor|ndarray|scientific|수치|행렬|벡터"
match_expert "claude-autopilot"          "autopilot|autonomous|자율|time-limit|시간 제한"
match_expert "plugin-introspector"       "introspect|plugin status|self-improve|플러그인 상태|자기 개선"
match_expert "sub-team-lead"             "team lead|팀 리드|프로젝트 설정|기술 스택|어떤 전문가|expert list|who should|coordinate"
match_expert "sub-codebase-explorer"     "explore|codebase|legacy|architecture analysis|dependency graph|hotspot|deadcode|dead code|onboarding|msa|microservice|event flow|api call map|sequence diagram|코드베이스|레거시|온보딩|의존성 그래프|아키텍처 분석|마이크로서비스|이벤트 발행|이벤트 흐름|시퀀스 다이어그램|구조 분석|도식화"

# ── Pattern Determination ────────────────────────────────
if [ "${EXPERT_COUNT}" -eq 0 ]; then
  PATTERN="none"
  CONFIDENCE="0.0"
elif [ "${EXPERT_COUNT}" -eq 1 ]; then
  PATTERN="single"
  CONFIDENCE="0.9"
else
  PATTERN="multi"
  CONFIDENCE="0.7"
fi

# ── Build JSON ───────────────────────────────────────────
if [ -z "${EXPERTS}" ]; then
  EXPERTS_JSON='[]'
else
  EXPERTS_JSON=$(echo "${EXPERTS}" | tr ' ' '\n' | jq -R . | jq -s . 2>/dev/null || echo '[]')
fi

jq -n \
  --argjson experts "${EXPERTS_JSON}" \
  --arg confidence "${CONFIDENCE}" \
  --arg query "${QUERY}" \
  --arg pattern "${PATTERN}" \
  '{
    query: $query,
    experts: $experts,
    pattern: $pattern,
    confidence: ($confidence | tonumber),
    needs_llm_verification: (($confidence | tonumber) < 0.85)
  }'
