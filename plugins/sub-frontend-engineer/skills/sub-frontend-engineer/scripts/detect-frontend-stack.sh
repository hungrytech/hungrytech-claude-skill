#!/usr/bin/env bash
# Frontend Engineer — Frontend Stack Detection
#
# Detects React/Vite/TypeScript/Tailwind/state management stack.
# Compatible with bash 3.2+ (macOS default).
#
# Usage: detect-frontend-stack.sh [project-root]
# Output: JSON with framework, build_tool, css, state_management, testing, routing
#
# Dependencies: bash + jq only

set -euo pipefail

TARGET="${1:-.}"
PKG_FILE="${TARGET}/package.json"

# ── Default values ──────────────────────────────────────
REACT="unknown"
VITE="false"
TYPESCRIPT="false"
CSS_FRAMEWORK="none"
STATE_MGMT=""
TESTING=""
ROUTING=""
NODE_PKG_MANAGER="unknown"

# ── Check package.json ──────────────────────────────────
if [ ! -f "${PKG_FILE}" ]; then
  jq -n '{
    error: "No package.json found",
    react: "unknown",
    vite: false,
    typescript: false,
    css_framework: "none",
    state_management: [],
    testing: [],
    routing: "none",
    package_manager: "unknown"
  }'
  exit 0
fi

# Helper to check if a dep exists in package.json
has_dep() {
  local dep="$1"
  jq -e --arg d "${dep}" '
    (.dependencies[$d] // .devDependencies[$d] // .peerDependencies[$d]) != null
  ' "${PKG_FILE}" > /dev/null 2>&1
}

get_dep_version() {
  local dep="$1"
  jq -r --arg d "${dep}" '
    .dependencies[$d] // .devDependencies[$d] // .peerDependencies[$d] // "unknown"
  ' "${PKG_FILE}" 2>/dev/null
}

# ── React ───────────────────────────────────────────────
if has_dep "react"; then
  REACT=$(get_dep_version "react")
fi

# ── Vite ────────────────────────────────────────────────
if has_dep "vite"; then
  VITE="true"
fi
if [ -f "${TARGET}/vite.config.ts" ] || [ -f "${TARGET}/vite.config.js" ] || [ -f "${TARGET}/vite.config.mts" ]; then
  VITE="true"
fi

# ── TypeScript ──────────────────────────────────────────
if has_dep "typescript"; then
  TYPESCRIPT="true"
fi
if [ -f "${TARGET}/tsconfig.json" ]; then
  TYPESCRIPT="true"
fi

# ── CSS Framework ───────────────────────────────────────
if has_dep "tailwindcss"; then
  CSS_FRAMEWORK="tailwind"
elif has_dep "@chakra-ui/react"; then
  CSS_FRAMEWORK="chakra-ui"
elif has_dep "@mui/material"; then
  CSS_FRAMEWORK="material-ui"
elif has_dep "styled-components"; then
  CSS_FRAMEWORK="styled-components"
elif has_dep "@emotion/react"; then
  CSS_FRAMEWORK="emotion"
fi

# ── State Management ───────────────────────────────────
add_state() {
  if [ -z "${STATE_MGMT}" ]; then
    STATE_MGMT="$1"
  else
    STATE_MGMT="${STATE_MGMT} $1"
  fi
}

has_dep "zustand" && add_state "zustand"
has_dep "@tanstack/react-query" && add_state "tanstack-query"
has_dep "@reduxjs/toolkit" && add_state "redux-toolkit"
has_dep "redux" && add_state "redux"
has_dep "jotai" && add_state "jotai"
has_dep "recoil" && add_state "recoil"
has_dep "mobx" && add_state "mobx"

# ── Testing ─────────────────────────────────────────────
add_test() {
  if [ -z "${TESTING}" ]; then
    TESTING="$1"
  else
    TESTING="${TESTING} $1"
  fi
}

has_dep "vitest" && add_test "vitest"
has_dep "jest" && add_test "jest"
has_dep "@testing-library/react" && add_test "react-testing-library"
has_dep "@playwright/test" && add_test "playwright"
has_dep "cypress" && add_test "cypress"

# ── Routing ─────────────────────────────────────────────
if has_dep "react-router-dom"; then
  ROUTING="react-router"
elif has_dep "@tanstack/react-router"; then
  ROUTING="tanstack-router"
else
  ROUTING="none"
fi

# ── Package Manager ─────────────────────────────────────
if [ -f "${TARGET}/pnpm-lock.yaml" ]; then
  NODE_PKG_MANAGER="pnpm"
elif [ -f "${TARGET}/yarn.lock" ]; then
  NODE_PKG_MANAGER="yarn"
elif [ -f "${TARGET}/bun.lockb" ] || [ -f "${TARGET}/bun.lock" ]; then
  NODE_PKG_MANAGER="bun"
elif [ -f "${TARGET}/package-lock.json" ]; then
  NODE_PKG_MANAGER="npm"
fi

# ── Build JSON output ──────────────────────────────────
to_json_array() {
  local input="$1"
  if [ -z "${input}" ]; then
    echo '[]'
  else
    echo "${input}" | tr ' ' '\n' | jq -R . | jq -s . 2>/dev/null || echo '[]'
  fi
}

STATE_JSON=$(to_json_array "${STATE_MGMT}")
TEST_JSON=$(to_json_array "${TESTING}")

jq -n \
  --arg react "${REACT}" \
  --argjson vite "${VITE}" \
  --argjson typescript "${TYPESCRIPT}" \
  --arg css_framework "${CSS_FRAMEWORK}" \
  --argjson state_management "${STATE_JSON}" \
  --argjson testing "${TEST_JSON}" \
  --arg routing "${ROUTING}" \
  --arg package_manager "${NODE_PKG_MANAGER}" \
  '{
    react: $react,
    vite: $vite,
    typescript: $typescript,
    css_framework: $css_framework,
    state_management: $state_management,
    testing: $testing,
    routing: $routing,
    package_manager: $package_manager
  }'
