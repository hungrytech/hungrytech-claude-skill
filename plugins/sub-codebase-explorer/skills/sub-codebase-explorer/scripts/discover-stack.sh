#!/usr/bin/env bash
# discover-stack.sh - 다언어 스택 인벤토리 + MSA 시그널 감지
# Usage: discover-stack.sh [TARGET_PATH]
# Output: JSON to stdout

set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_common.sh"

TARGET="${1:-.}"
[ -d "$TARGET" ] || { echo '{"error":"target not a directory"}'; exit 1; }

cd "$TARGET" || exit 1

# -----------------------------------------------
# 빌드 시스템 감지
# -----------------------------------------------
build_systems=()
[ -f build.gradle.kts ]    && build_systems+=("gradle-kotlin-dsl")
[ -f build.gradle ]        && build_systems+=("gradle-groovy")
[ -f pom.xml ]             && build_systems+=("maven")
[ -f package.json ]        && build_systems+=("npm")
[ -f pnpm-workspace.yaml ] && build_systems+=("pnpm-workspace")
[ -f turbo.json ]          && build_systems+=("turborepo")
[ -f nx.json ]             && build_systems+=("nx")
[ -f pyproject.toml ]      && build_systems+=("poetry-or-pep621")
[ -f requirements.txt ]    && build_systems+=("pip-requirements")
[ -f go.mod ]              && build_systems+=("go-modules")
[ -f Cargo.toml ]          && build_systems+=("cargo")
[ -f Gemfile ]             && build_systems+=("bundler")

# -----------------------------------------------
# 언어 감지
# -----------------------------------------------
languages=$(detect_languages ".")

# -----------------------------------------------
# 모듈/서비스 디렉토리 (MSA 후보)
# -----------------------------------------------
service_dirs=()
for parent in services apps packages modules cmd; do
  if [ -d "$parent" ]; then
    while IFS= read -r d; do
      service_dirs+=("$d")
    done < <(find "$parent" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
  fi
done
# Gradle 멀티모듈
if [ -f settings.gradle ] || [ -f settings.gradle.kts ]; then
  for f in settings.gradle settings.gradle.kts; do
    [ -f "$f" ] && grep -oE "include\s*[(\"']:?[a-zA-Z0-9_-]+" "$f" 2>/dev/null \
      | sed -E "s/include\s*[(\"']:?//" | while read -r m; do
        echo "$m"
      done
  done > /tmp/__sce_gmod 2>/dev/null
  while IFS= read -r m; do
    [ -n "$m" ] && service_dirs+=("$m")
  done < /tmp/__sce_gmod
  rm -f /tmp/__sce_gmod
fi

# -----------------------------------------------
# MSA 시그널: 메시지 브로커 / HTTP 클라이언트 / gRPC / API Gateway
# -----------------------------------------------
msa_signals=()
broker_libs="kafka|rabbitmq|amqp|sns|sqs|eventbridge|nats|pulsar|redis-pubsub|kafkajs|aiokafka|kafka-go"
http_libs="resttemplate|webclient|openfeign|axios|httpx|requests|aiohttp|resty|got |ky |cross-fetch"
grpc_libs="grpc|protobuf|grpcio|grpc-go|grpc-java|grpc-kotlin"
gateway="kong|traefik|envoy|ambassador|krakend"

scan_dep_files=(build.gradle build.gradle.kts pom.xml package.json pyproject.toml requirements.txt go.mod Cargo.toml Gemfile)
deps_blob=""
for f in "${scan_dep_files[@]}"; do
  [ -f "$f" ] && deps_blob+="$(cat "$f" 2>/dev/null)"$'\n'
done

if echo "$deps_blob" | grep -qiE "$broker_libs"; then msa_signals+=("message-broker"); fi
if echo "$deps_blob" | grep -qiE "$http_libs"; then  msa_signals+=("http-client"); fi
if echo "$deps_blob" | grep -qiE "$grpc_libs"; then  msa_signals+=("grpc"); fi
if find . -maxdepth 6 -name "*.proto" -not -path "*/node_modules/*" 2>/dev/null | head -1 | grep -q .; then
  msa_signals+=("proto-files")
fi
if echo "$deps_blob" | grep -qiE "$gateway"; then msa_signals+=("api-gateway"); fi
if [ "${#service_dirs[@]}" -ge 2 ]; then msa_signals+=("multi-service-dir"); fi

# 2개 이상 시그널 → MSA 모드 자동 활성화 권장
msa_recommended="false"
[ "${#msa_signals[@]}" -ge 2 ] && msa_recommended="true"

# -----------------------------------------------
# 테스트 프레임워크
# -----------------------------------------------
test_fw=""
echo "$deps_blob" | grep -qiE "junit|jupiter"        && test_fw+="junit "
echo "$deps_blob" | grep -qiE "kotest|strikt"        && test_fw+="kotest-strikt "
echo "$deps_blob" | grep -qiE "assertj"              && test_fw+="assertj "
echo "$deps_blob" | grep -qiE "mockk|mockito"        && test_fw+="mock "
echo "$deps_blob" | grep -qiE "pytest"               && test_fw+="pytest "
echo "$deps_blob" | grep -qiE "vitest|jest|mocha"    && test_fw+="js-test "
echo "$deps_blob" | grep -qiE "playwright|cypress"   && test_fw+="e2e "
echo "$deps_blob" | grep -qiE "go test|testify"      && test_fw+="go-test "

# -----------------------------------------------
# JSON 출력
# -----------------------------------------------
to_json_array() {
  if [ "$#" -eq 0 ]; then echo "[]"; return; fi
  printf '['
  local first=1
  for x in "$@"; do
    [ $first -eq 0 ] && printf ','
    printf '"%s"' "$(printf %s "$x" | sed 's/"/\\"/g')"
    first=0
  done
  printf ']'
}

# 빈 배열 안전 처리 (bash 3.2)
build_arr=$(to_json_array ${build_systems[@]+"${build_systems[@]}"})
service_arr=$(to_json_array ${service_dirs[@]+"${service_dirs[@]}"})
signals_arr=$(to_json_array ${msa_signals[@]+"${msa_signals[@]}"})
if [ -z "$languages" ]; then
  languages_arr="[]"
else
  languages_arr=$(printf '%s\n' $languages | grep -v '^$' | jq -R . | jq -s . 2>/dev/null || echo "[]")
fi
test_arr=$(to_json_array $test_fw)

cat <<EOF
{
  "target": "$(pwd)",
  "build_systems": $build_arr,
  "languages": $languages_arr,
  "service_dirs": $service_arr,
  "msa_signals": $signals_arr,
  "msa_recommended": $msa_recommended,
  "test_frameworks": $test_arr,
  "build_hash": "$(compute_build_hash .)"
}
EOF
