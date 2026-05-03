#!/usr/bin/env bash
# _common.sh - sub-codebase-explorer shared utilities
# Source: source "$(dirname "$0")/_common.sh"
#
# 다언어 코드베이스 분석을 위한 공통 헬퍼.
# bash 3.2+ 호환, 외부 의존: bash + jq + git + (optional) ast-grep

set -o pipefail

CACHE_PREFIX="sub-codebase-explorer"
CACHE_DIR="${CLAUDE_CACHE_DIR:-$HOME/.claude/cache}"

# -----------------------------------------------
# 해시 + 캐시
# -----------------------------------------------

# md5 sum (linux md5sum / macOS md5 -q 모두 지원)
md5_of_string() {
  if command -v md5sum >/dev/null 2>&1; then
    printf %s "$1" | md5sum | awk '{print $1}'
  else
    printf %s "$1" | md5 -q
  fi
}

md5_of_file() {
  local f="$1"
  [ -f "$f" ] || return 1
  if command -v md5sum >/dev/null 2>&1; then
    md5sum "$f" | awk '{print $1}'
  else
    md5 -q "$f"
  fi
}

# 프로젝트 경로 → 해시
project_path_hash() {
  local p="${1:-.}"
  local abs
  abs=$(cd "$p" 2>/dev/null && pwd)
  md5_of_string "${abs:-$p}"
}

# 빌드 파일들을 합친 해시 (캐시 무효화용)
compute_build_hash() {
  local p="${1:-.}"
  local acc=""
  for f in build.gradle build.gradle.kts settings.gradle settings.gradle.kts pom.xml \
           package.json pnpm-workspace.yaml turbo.json nx.json \
           pyproject.toml setup.py poetry.lock requirements.txt \
           go.mod go.sum Cargo.toml Cargo.lock Gemfile Gemfile.lock; do
    if [ -f "$p/$f" ]; then
      acc+="$(md5_of_file "$p/$f")"
    fi
  done
  md5_of_string "$acc"
}

cache_path() {
  # cache_path <artifact> <project_dir>
  local artifact="$1"
  local p="${2:-.}"
  local h
  h=$(project_path_hash "$p")
  mkdir -p "$CACHE_DIR" 2>/dev/null
  echo "${CACHE_DIR}/${CACHE_PREFIX}-${h}-${artifact}"
}

cleanup_stale_cache() {
  local days="${1:-30}"
  [ -d "$CACHE_DIR" ] || return 0
  find "$CACHE_DIR" -name "${CACHE_PREFIX}-*" -type f -mtime +"$days" -delete 2>/dev/null || true
}

# -----------------------------------------------
# 로깅
# -----------------------------------------------

log_info()  { echo "[INFO]  $*" >&2; }
log_warn()  { echo "[WARN]  $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

# -----------------------------------------------
# ast-grep 통합
# -----------------------------------------------

AST_GREP_RULES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../ast-grep-rules" 2>/dev/null && pwd)"

has_ast_grep() {
  command -v ast-grep >/dev/null 2>&1 || command -v sg >/dev/null 2>&1
}

run_ast_grep() {
  if command -v ast-grep >/dev/null 2>&1; then
    ast-grep "$@"
  elif command -v sg >/dev/null 2>&1; then
    sg "$@"
  else
    return 127
  fi
}

# rule_path <subdir/rule_name> → 절대경로 (없으면 비어있음)
ast_grep_rule_path() {
  local rule_rel="$1"
  local p="${AST_GREP_RULES_DIR}/${rule_rel}.yml"
  [ -f "$p" ] && echo "$p"
}

# -----------------------------------------------
# 언어 감지
# -----------------------------------------------

# 현재 디렉토리 또는 인자 경로의 주요 언어 목록 (한 줄에 하나씩)
detect_languages() {
  local p="${1:-.}"
  local langs=""
  [ -d "$p/src/main/kotlin" ] && langs+="kotlin "
  [ -d "$p/src/main/java" ]   && langs+="java "
  if find "$p" -maxdepth 4 -type f \( -name "*.kt" -o -name "*.kts" \) -not -path "*/node_modules/*" -not -path "*/build/*" 2>/dev/null | head -1 | grep -q .; then
    [[ "$langs" == *kotlin* ]] || langs+="kotlin "
  fi
  if find "$p" -maxdepth 4 -type f -name "*.java" -not -path "*/node_modules/*" -not -path "*/build/*" 2>/dev/null | head -1 | grep -q .; then
    [[ "$langs" == *java* ]] || langs+="java "
  fi
  if find "$p" -maxdepth 4 -type f -name "*.py" -not -path "*/.venv/*" -not -path "*/venv/*" 2>/dev/null | head -1 | grep -q .; then
    langs+="python "
  fi
  if find "$p" -maxdepth 4 -type f -name "*.go" -not -path "*/vendor/*" 2>/dev/null | head -1 | grep -q .; then
    langs+="go "
  fi
  if find "$p" -maxdepth 4 -type f \( -name "*.ts" -o -name "*.tsx" \) -not -path "*/node_modules/*" 2>/dev/null | head -1 | grep -q .; then
    langs+="typescript "
  fi
  if find "$p" -maxdepth 4 -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.mjs" \) -not -path "*/node_modules/*" 2>/dev/null | head -1 | grep -q .; then
    langs+="javascript "
  fi
  if find "$p" -maxdepth 4 -type f -name "*.rb" -not -path "*/vendor/*" 2>/dev/null | head -1 | grep -q .; then
    langs+="ruby "
  fi
  echo "$langs" | tr ' ' '\n' | grep -v '^$' | sort -u
}

# -----------------------------------------------
# JSON 안전 출력
# -----------------------------------------------

json_string() {
  if command -v jq >/dev/null 2>&1; then
    printf %s "$1" | jq -Rs .
  else
    # 매우 단순한 escape
    printf '"%s"' "$(printf %s "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  fi
}
