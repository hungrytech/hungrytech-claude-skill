#!/usr/bin/env bash
# extract-msa-api-calls.sh - HTTP/gRPC 서비스 간 호출 추출 (다언어)
# Usage: extract-msa-api-calls.sh [TARGET_PATH]
# Output: JSON {calls: [{caller, callee, method, path, file, line, client_lib, language, sync_async}]}
#
# 휴리스틱:
#  - caller = 호출 코드가 위치한 서비스 디렉토리 (services/<NAME>, apps/<NAME>)
#  - callee = URL/host에서 추정 (예: http://order-service/... → order-service)
#  - method/path = 호출 함수의 첫 인자 정규식 매칭

set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_common.sh"

TARGET="${1:-.}"
[ -d "$TARGET" ] || { echo '{"error":"target not a directory"}'; exit 1; }
cd "$TARGET" || exit 1

EXCLUDES="--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=build --exclude-dir=dist --exclude-dir=.venv --exclude-dir=venv --exclude-dir=target --exclude-dir=vendor"

# caller_of <file> → service name
caller_of() {
  local f="$1"
  case "$f" in
    ./services/*) echo "$f" | sed -E 's|\./services/([^/]+)/.*|\1|' ;;
    ./apps/*)     echo "$f" | sed -E 's|\./apps/([^/]+)/.*|\1|' ;;
    ./packages/*) echo "$f" | sed -E 's|\./packages/([^/]+)/.*|\1|' ;;
    ./modules/*)  echo "$f" | sed -E 's|\./modules/([^/]+)/.*|\1|' ;;
    ./cmd/*)      echo "$f" | sed -E 's|\./cmd/([^/]+)/.*|\1|' ;;
    *) basename "$(pwd)" ;;
  esac
}

# callee_from_url <url-string> → callee service name
callee_from_url() {
  local url="$1"
  # http(s)://HOST[:port]/path  → HOST
  echo "$url" | sed -E 's|https?://([^/:]+).*|\1|' | sed -E 's/\.svc\.cluster\.local//' | sed -E 's/\.internal//'
}

# emit_call <caller> <callee> <method> <path> <file:line> <lib> <lang> <sync_async>
emit_call() {
  local caller="$1" callee="$2" method="$3" path="$4" loc="$5" lib="$6" lang="$7" sa="$8"
  local esc_path
  esc_path=$(printf %s "$path" | sed 's/"/\\"/g')
  local esc_loc
  esc_loc=$(printf %s "$loc" | sed 's/"/\\"/g')
  echo "{\"caller\":\"$caller\",\"callee\":\"$callee\",\"method\":\"$method\",\"path\":\"$esc_path\",\"file\":\"$esc_loc\",\"client_lib\":\"$lib\",\"language\":\"$lang\",\"sync_async\":\"$sa\"}"
}

# -----------------------------------------------
# JVM (Kotlin/Java): RestTemplate, WebClient, OpenFeign
# -----------------------------------------------
jvm_calls() {
  # RestTemplate
  grep -rEn $EXCLUDES --include='*.kt' --include='*.java' \
    'restTemplate\.(getForObject|getForEntity|postForObject|postForEntity|exchange|put|delete)\s*\(' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      caller=$(caller_of "$f")
      method=$(echo "$rest" | grep -oE '(getForObject|getForEntity|postForObject|postForEntity|exchange|put|delete)' | head -1)
      url=$(echo "$rest" | grep -oE '"http[^"]*"' | head -1 | tr -d '"')
      [ -z "$url" ] && url=$(echo "$rest" | grep -oE "'/[^']*'" | head -1 | tr -d "'")
      callee=$(callee_from_url "$url")
      path=$(echo "$url" | sed -E 's|https?://[^/]+||')
      [ -z "$path" ] && path="$url"
      emit_call "$caller" "${callee:-unknown}" "$(echo "$method" | tr '[:lower:]' '[:upper:]')" "${path:-/}" "$f:$ln" "RestTemplate" "jvm" "sync"
    done

  # WebClient (Reactive)
  grep -rEn $EXCLUDES --include='*.kt' --include='*.java' \
    'webClient\.(get|post|put|delete|patch)\s*\(\s*\)' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      caller=$(caller_of "$f")
      method=$(echo "$rest" | grep -oE '(get|post|put|delete|patch)' | head -1)
      url=$(echo "$rest" | grep -oE '"http[^"]*"' | head -1 | tr -d '"')
      callee=$(callee_from_url "${url:-unknown}")
      path=$(echo "${url:-/}" | sed -E 's|https?://[^/]+||')
      emit_call "$caller" "${callee:-unknown}" "$(echo "$method" | tr '[:lower:]' '[:upper:]')" "${path:-/}" "$f:$ln" "WebClient" "jvm" "async"
    done

  # OpenFeign @FeignClient
  grep -rEn $EXCLUDES --include='*.kt' --include='*.java' \
    '@FeignClient\s*\(' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      caller=$(caller_of "$f")
      callee=$(echo "$rest" | grep -oE 'name\s*=\s*"[^"]+"' | head -1 | sed -E 's/name\s*=\s*"([^"]+)"/\1/')
      [ -z "$callee" ] && callee=$(echo "$rest" | grep -oE 'value\s*=\s*"[^"]+"' | head -1 | sed -E 's/value\s*=\s*"([^"]+)"/\1/')
      url=$(echo "$rest" | grep -oE 'url\s*=\s*"[^"]+"' | head -1 | sed -E 's/url\s*=\s*"([^"]+)"/\1/')
      [ -z "$callee" ] && callee=$(callee_from_url "${url:-unknown}")
      emit_call "$caller" "${callee:-unknown}" "FEIGN" "(declared interface)" "$f:$ln" "OpenFeign" "jvm" "sync"
    done
}

# -----------------------------------------------
# TypeScript/JavaScript: axios / fetch
# -----------------------------------------------
ts_calls() {
  grep -rEn $EXCLUDES --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
    'axios\.(get|post|put|delete|patch)\s*\(' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      caller=$(caller_of "$f")
      method=$(echo "$rest" | grep -oE 'axios\.(get|post|put|delete|patch)' | head -1 | sed -E 's/axios\.//')
      url=$(echo "$rest" | grep -oE "['\"][^'\"]*['\"]" | head -1 | tr -d "'\"")
      callee=$(callee_from_url "${url:-unknown}")
      path=$(echo "${url:-/}" | sed -E 's|https?://[^/]+||')
      emit_call "$caller" "${callee:-unknown}" "$(echo "$method" | tr '[:lower:]' '[:upper:]')" "${path:-/}" "$f:$ln" "axios" "typescript" "async"
    done

  grep -rEn $EXCLUDES --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
    '\bfetch\s*\(' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      caller=$(caller_of "$f")
      url=$(echo "$rest" | grep -oE "['\"\\\`][^'\"\\\`]*['\"\\\`]" | head -1 | tr -d "'\"\`")
      callee=$(callee_from_url "${url:-unknown}")
      path=$(echo "${url:-/}" | sed -E 's|https?://[^/]+||')
      method="GET"
      echo "$rest" | grep -qiE 'method.*(post|put|delete|patch)' && method=$(echo "$rest" | grep -oiE '(POST|PUT|DELETE|PATCH)' | head -1)
      emit_call "$caller" "${callee:-unknown}" "$method" "${path:-/}" "$f:$ln" "fetch" "typescript" "async"
    done
}

# -----------------------------------------------
# Python: requests / httpx
# -----------------------------------------------
py_calls() {
  grep -rEn $EXCLUDES --include='*.py' \
    '(requests|httpx)\.(get|post|put|delete|patch)\s*\(' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      caller=$(caller_of "$f")
      lib=$(echo "$rest" | grep -oE '(requests|httpx)' | head -1)
      method=$(echo "$rest" | grep -oE "$lib\.(get|post|put|delete|patch)" | head -1 | sed -E "s/$lib\.//")
      url=$(echo "$rest" | grep -oE "['\"][^'\"]*['\"]" | head -1 | tr -d "'\"")
      callee=$(callee_from_url "${url:-unknown}")
      path=$(echo "${url:-/}" | sed -E 's|https?://[^/]+||')
      sa="sync"
      [ "$lib" = "httpx" ] && echo "$rest" | grep -q "AsyncClient" && sa="async"
      emit_call "$caller" "${callee:-unknown}" "$(echo "$method" | tr '[:lower:]' '[:upper:]')" "${path:-/}" "$f:$ln" "$lib" "python" "$sa"
    done
}

# -----------------------------------------------
# Go: net/http
# -----------------------------------------------
go_calls() {
  grep -rEn $EXCLUDES --include='*.go' \
    'http\.(NewRequest|Get|Post|PostForm)\s*\(' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      caller=$(caller_of "$f")
      method=$(echo "$rest" | grep -oE 'http\.(NewRequest|Get|Post|PostForm)' | head -1 | sed -E 's/http\.//')
      url=$(echo "$rest" | grep -oE '"[^"]*"' | head -1 | tr -d '"')
      [ "$method" = "NewRequest" ] && {
        m=$(echo "$rest" | grep -oE '"(GET|POST|PUT|DELETE|PATCH)"' | head -1 | tr -d '"')
        [ -n "$m" ] && method="$m"
      }
      callee=$(callee_from_url "${url:-unknown}")
      path=$(echo "${url:-/}" | sed -E 's|https?://[^/]+||')
      emit_call "$caller" "${callee:-unknown}" "$(echo "$method" | tr '[:lower:]' '[:upper:]')" "${path:-/}" "$f:$ln" "net/http" "go" "sync"
    done
}

{
  jvm_calls
  ts_calls
  py_calls
  go_calls
} > /tmp/__sce_calls.jsonl

echo -n '{"calls":['
first=1
while IFS= read -r line; do
  [ -z "$line" ] && continue
  [ $first -eq 0 ] && echo -n ","
  echo -n "$line"
  first=0
done < /tmp/__sce_calls.jsonl
echo "]}"

rm -f /tmp/__sce_calls.jsonl
