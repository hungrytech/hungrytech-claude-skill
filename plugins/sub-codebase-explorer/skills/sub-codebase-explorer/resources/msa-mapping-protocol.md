# MSA Mapping Protocol — 전용 모드 (`mode=msa`)

`/sub-codebase-explorer msa [TARGET]` 호출 시 활성화. Phase 1+2(MSA만)+4(msa/만) 실행.

## 절차

1. **Discover (간소)**
   - `discover-stack.sh` 실행, `msa_signals` 확인만 — 시그널 0개여도 사용자가 `msa` 모드 명시했으므로 진행

2. **Extract**
   ```bash
   ./scripts/extract-msa-api-calls.sh "$TARGET" > /tmp/calls.json
   ./scripts/extract-msa-events.sh    "$TARGET" > /tmp/events.json
   ```

3. **Generate**
   ```bash
   ./scripts/generate-msa-docs.sh "$TARGET" "$TARGET/msa"
   ```

4. **검증 보고**
   - `msa/00-overview.md` 줄 수
   - `msa/api-calls/` 파일 수
   - `msa/events/` 파일 수
   - `msa/service-dependency-matrix.md` 매트릭스 차원 (NxN)

## 파일명 규칙 (변경 금지 — 다른 도구가 의존)

| 산출물 | 규칙 | 예시 |
|--------|------|------|
| API 호출 | `api-calls/{caller}__to__{callee}__{METHOD}-{path-slug}.md` | `order-service__to__user-service__GET-users-id.md` |
| 이벤트 토픽 | `events/topic__{topic-slug}.md` | `events/topic__order-created.md` |
| 시퀀스 | `sequence-diagrams/flow__{scenario-slug}.mmd` | `sequence-diagrams/flow__order-placement.mmd` |

slug 변환:
- 영숫자/`_-` 외 문자 → `-`
- 연속 `-` → 단일 `-`
- 좌우 `-` 제거

## 정밀도 한계

- caller/callee 추정은 디렉토리 컨벤션(`services/`, `apps/`)에 의존. 컨벤션 위반 시 caller만 정확.
- callee는 URL 호스트에서 추출 (서비스 디스커버리 사용 시 부정확 가능).
- 동적 토픽명 (변수에서 빌드) → 추출 실패 가능, "unknown" 토픽으로 분류.
