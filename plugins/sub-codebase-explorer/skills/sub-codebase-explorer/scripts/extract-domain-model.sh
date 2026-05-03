#!/usr/bin/env bash
# extract-domain-model.sh - 도메인 엔티티/관계 추출 (다언어)
# Usage: extract-domain-model.sh [TARGET_PATH]
# Output: JSON {entities: [{name, file, fields: [{name, type, relation}]}]}
#
# 휴리스틱:
#  - JVM: @Entity / @Table 클래스 + 필드/관계 어노테이션 (@OneToMany, @ManyToOne, @JoinColumn)
#  - Python: SQLAlchemy declarative_base 자식 / Pydantic BaseModel
#  - TS: TypeORM @Entity / Prisma model

set -o pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_common.sh"

TARGET="${1:-.}"
[ -d "$TARGET" ] || { echo '{"error":"target not a directory"}'; exit 1; }
cd "$TARGET" || exit 1

EXCLUDES="--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=build --exclude-dir=dist --exclude-dir=.venv --exclude-dir=venv --exclude-dir=target --exclude-dir=vendor"

# JVM: @Entity 라인 → 클래스 이름 추출
jvm_entities() {
  grep -rln $EXCLUDES --include='*.kt' --include='*.java' -E '^[[:space:]]*@Entity\b' . 2>/dev/null \
  | while read -r f; do
      cls=$(grep -E "^[[:space:]]*(data\s+)?(class|object)\s+[A-Z][A-Za-z0-9_]+" "$f" 2>/dev/null \
        | head -1 | sed -E 's/.*(class|object)\s+([A-Z][A-Za-z0-9_]+).*/\2/')
      [ -z "$cls" ] && continue
      # 관계 어노테이션 카운트
      one_many=$(grep -cE '@OneToMany' "$f" 2>/dev/null)
      many_one=$(grep -cE '@ManyToOne' "$f" 2>/dev/null)
      one_one=$(grep -cE '@OneToOne' "$f" 2>/dev/null)
      many_many=$(grep -cE '@ManyToMany' "$f" 2>/dev/null)
      echo "{\"name\":\"$cls\",\"file\":\"$f\",\"language\":\"jvm\",\"relations\":{\"oneToMany\":$one_many,\"manyToOne\":$many_one,\"oneToOne\":$one_one,\"manyToMany\":$many_many}}"
    done
}

# Python: SQLAlchemy / Pydantic
py_entities() {
  grep -rln $EXCLUDES --include='*.py' -E '(declarative_base\(\)|class\s+\w+\(.*BaseModel.*\))' . 2>/dev/null \
  | while read -r f; do
      grep -nE 'class\s+\w+\(' "$f" 2>/dev/null \
      | while IFS=: read -r ln rest; do
          cls=$(echo "$rest" | sed -E 's/.*class\s+(\w+)\(.*/\1/')
          [ -z "$cls" ] && continue
          base=$(echo "$rest" | sed -E 's/.*class\s+\w+\((.+)\).*/\1/')
          if echo "$base" | grep -qiE 'base|model'; then
            echo "{\"name\":\"$cls\",\"file\":\"$f:$ln\",\"language\":\"python\",\"base\":\"$base\"}"
          fi
        done
    done
}

# TS: TypeORM @Entity / Prisma model
ts_entities() {
  grep -rln $EXCLUDES --include='*.ts' --include='*.tsx' -E '@Entity\(' . 2>/dev/null \
  | while read -r f; do
      grep -nE 'export\s+class\s+\w+' "$f" 2>/dev/null \
      | while IFS=: read -r ln rest; do
          cls=$(echo "$rest" | sed -E 's/.*class\s+(\w+).*/\1/')
          [ -z "$cls" ] && continue
          echo "{\"name\":\"$cls\",\"file\":\"$f:$ln\",\"language\":\"typescript\",\"orm\":\"typeorm\"}"
        done
    done
  # Prisma
  find . -name "schema.prisma" -not -path "*/node_modules/*" 2>/dev/null \
  | while read -r f; do
      grep -E '^model\s+\w+' "$f" 2>/dev/null \
      | sed -E 's/^model\s+(\w+).*/\1/' \
      | while read -r cls; do
          echo "{\"name\":\"$cls\",\"file\":\"$f\",\"language\":\"prisma\",\"orm\":\"prisma\"}"
        done
    done
}

{
  jvm_entities
  py_entities
  ts_entities
} > /tmp/__sce_entities.jsonl

echo -n '{"entities":['
first=1
while IFS= read -r line; do
  [ -z "$line" ] && continue
  [ $first -eq 0 ] && echo -n ","
  echo -n "$line"
  first=0
done < /tmp/__sce_entities.jsonl
echo "]}"

rm -f /tmp/__sce_entities.jsonl
