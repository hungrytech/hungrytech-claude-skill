#!/usr/bin/env bash
# extract-msa-events.sh - 이벤트 발행/구독 추출 (Kafka/RabbitMQ/SNS/Spring Events)
# Usage: extract-msa-events.sh [TARGET_PATH]
# Output: JSON {events: [{topic, type: publish|subscribe, service, file, line, broker, language}]}

set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_common.sh"

TARGET="${1:-.}"
[ -d "$TARGET" ] || { echo '{"error":"target not a directory"}'; exit 1; }
cd "$TARGET" || exit 1

EXCLUDES="--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=build --exclude-dir=dist --exclude-dir=.venv --exclude-dir=venv --exclude-dir=target --exclude-dir=vendor"

service_of() {
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

emit() {
  local topic="$1" type="$2" service="$3" loc="$4" broker="$5" lang="$6"
  local esc
  esc=$(printf %s "$loc" | sed 's/"/\\"/g')
  echo "{\"topic\":\"$topic\",\"type\":\"$type\",\"service\":\"$service\",\"file\":\"$esc\",\"broker\":\"$broker\",\"language\":\"$lang\"}"
}

# -----------------------------------------------
# JVM
# -----------------------------------------------
jvm_events() {
  # Kafka publish: kafkaTemplate.send("topic", ...)
  grep -rEn $EXCLUDES --include='*.kt' --include='*.java' \
    'kafkaTemplate\.send\s*\(' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      svc=$(service_of "$f")
      topic=$(echo "$rest" | grep -oE '"[^"]+"' | head -1 | tr -d '"')
      emit "${topic:-unknown}" "publish" "$svc" "$f:$ln" "kafka" "jvm"
    done

  # Kafka subscribe: @KafkaListener(topics = "...")
  grep -rEn $EXCLUDES --include='*.kt' --include='*.java' \
    '@KafkaListener\s*\(' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      svc=$(service_of "$f")
      topic=$(echo "$rest" | grep -oE 'topics\s*=\s*[\["]?[^"\]]+' | head -1 | sed -E 's/topics\s*=\s*[\["]?([^"\]]+).*/\1/')
      [ -z "$topic" ] && topic=$(echo "$rest" | grep -oE '"[^"]+"' | head -1 | tr -d '"')
      emit "${topic:-unknown}" "subscribe" "$svc" "$f:$ln" "kafka" "jvm"
    done

  # RabbitMQ publish
  grep -rEn $EXCLUDES --include='*.kt' --include='*.java' \
    'rabbitTemplate\.(convertAndSend|send)\s*\(' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      svc=$(service_of "$f")
      topic=$(echo "$rest" | grep -oE '"[^"]+"' | head -1 | tr -d '"')
      emit "${topic:-unknown}" "publish" "$svc" "$f:$ln" "rabbitmq" "jvm"
    done

  # RabbitMQ subscribe
  grep -rEn $EXCLUDES --include='*.kt' --include='*.java' \
    '@RabbitListener\s*\(' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      svc=$(service_of "$f")
      topic=$(echo "$rest" | grep -oE '"[^"]+"' | head -1 | tr -d '"')
      emit "${topic:-unknown}" "subscribe" "$svc" "$f:$ln" "rabbitmq" "jvm"
    done

  # Spring ApplicationEvent
  grep -rEn $EXCLUDES --include='*.kt' --include='*.java' \
    'applicationEventPublisher\.publishEvent\s*\(' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      svc=$(service_of "$f")
      type=$(echo "$rest" | grep -oE 'publishEvent\s*\(\s*[A-Za-z_][A-Za-z0-9_]*' | head -1 | sed -E 's/publishEvent\s*\(\s*//')
      emit "${type:-ApplicationEvent}" "publish" "$svc" "$f:$ln" "spring-events" "jvm"
    done

  grep -rEn $EXCLUDES --include='*.kt' --include='*.java' \
    '@EventListener\b' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      svc=$(service_of "$f")
      emit "ApplicationEvent" "subscribe" "$svc" "$f:$ln" "spring-events" "jvm"
    done
}

# -----------------------------------------------
# TS/JS: kafkajs
# -----------------------------------------------
ts_events() {
  grep -rEn $EXCLUDES --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
    'producer\.send\s*\(' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      svc=$(service_of "$f")
      emit "kafka-topic" "publish" "$svc" "$f:$ln" "kafkajs" "typescript"
    done

  grep -rEn $EXCLUDES --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' \
    'consumer\.subscribe\s*\(' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      svc=$(service_of "$f")
      topic=$(echo "$rest" | grep -oE 'topic[s]?\s*:\s*[\["]?[^"\]]+' | head -1 | sed -E 's/.*:\s*[\["]?([^"\]]+).*/\1/')
      emit "${topic:-unknown}" "subscribe" "$svc" "$f:$ln" "kafkajs" "typescript"
    done
}

# -----------------------------------------------
# Python
# -----------------------------------------------
py_events() {
  grep -rEn $EXCLUDES --include='*.py' \
    'producer\.send\s*\(' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      svc=$(service_of "$f")
      topic=$(echo "$rest" | grep -oE "['\"][^'\"]+['\"]" | head -1 | tr -d "'\"")
      emit "${topic:-unknown}" "publish" "$svc" "$f:$ln" "kafka-python" "python"
    done

  grep -rEn $EXCLUDES --include='*.py' \
    'KafkaConsumer\s*\(' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      svc=$(service_of "$f")
      topic=$(echo "$rest" | grep -oE "['\"][^'\"]+['\"]" | head -1 | tr -d "'\"")
      emit "${topic:-unknown}" "subscribe" "$svc" "$f:$ln" "kafka-python" "python"
    done
}

# -----------------------------------------------
# Go: kafka-go
# -----------------------------------------------
go_events() {
  grep -rEn $EXCLUDES --include='*.go' \
    'kafka\.Writer|kafka\.NewWriter|WriteMessages' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      svc=$(service_of "$f")
      emit "kafka-topic" "publish" "$svc" "$f:$ln" "kafka-go" "go"
    done

  grep -rEn $EXCLUDES --include='*.go' \
    'kafka\.Reader|kafka\.NewReader|ReadMessage' . 2>/dev/null \
  | while IFS=: read -r f ln rest; do
      svc=$(service_of "$f")
      emit "kafka-topic" "subscribe" "$svc" "$f:$ln" "kafka-go" "go"
    done
}

{
  jvm_events
  ts_events
  py_events
  go_events
} > /tmp/__sce_events.jsonl

echo -n '{"events":['
first=1
while IFS= read -r line; do
  [ -z "$line" ] && continue
  [ $first -eq 0 ] && echo -n ","
  echo -n "$line"
  first=0
done < /tmp/__sce_events.jsonl
echo "]}"

rm -f /tmp/__sce_events.jsonl
