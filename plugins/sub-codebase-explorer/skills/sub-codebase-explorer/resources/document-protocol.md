# Phase 4: Document Protocol

목표: 전 단계 산출물을 종합하여 `ARCHITECTURE.md` + `ONBOARDING.md` (+ `msa/` 디렉토리) 생성.

## 절차

### 4-1. ARCHITECTURE.md
`templates/architecture-summary.md`을 베이스로 다음 데이터 주입:
- Discover 결과 (스택, 서비스 목록)
- Map 결과 (의존성 그래프 Mermaid)
- Diagnose 결과 (도메인 엔티티)
- 순환 의존성 (있을 경우 경고 섹션)

### 4-2. ONBOARDING.md
`templates/onboarding-guide.md`을 베이스로:
- 1주차 읽을 파일 목록 (hotspot 상위 10개)
- 핵심 모듈 진입점 (의존성 그래프 in-degree 상위)
- 도메인 용어집 (extracted entities)
- 로컬 환경 셋업 가이드 (build_systems 기반)

### 4-3. msa/ 디렉토리 (msa_recommended=true 또는 mode=msa)
```bash
./scripts/generate-msa-docs.sh "$TARGET" "$TARGET/msa"
```

생성물:
- `msa/00-overview.md` — C4 컨테이너 다이어그램
- `msa/api-calls/{caller}__to__{callee}__{METHOD}-{path}.md` — 호출별 1개
- `msa/events/topic__{topic}.md` — 토픽별 1개 (publishers + subscribers 결합)
- `msa/sequence-diagrams/flow__{scenario}.mmd` — 핵심 시나리오 (선택적)
- `msa/service-dependency-matrix.md` — NxN 호출 매트릭스

## 출력 보고

```
📄 ARCHITECTURE.md ({lines}줄)
📄 ONBOARDING.md ({lines}줄)
📁 msa/ ({api-calls 개수} + {events 개수} + overview + matrix)
```

## Skip 조건

- `--no-docs` 플래그
- `mode in [discover, hotspot, deadcode, graph]`
