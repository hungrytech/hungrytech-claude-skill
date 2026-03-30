# Claude Code Skills Repository

Claude Code 스킬(플러그인) 모음 레포지토리. 11개 플러그인으로 구성되며, 런타임 빌드 시스템 없이 셸 스크립트와 SKILL.md 기반으로 동작한다.

## 전문가 팀 구조

### 기존 전문가 (6명)
- **sub-kopring-engineer** — Kotlin/Java Spring Boot 개발 (Hexagonal Architecture)
- **sub-test-engineer** — 타입 기반 테스트 생성 (Java/Kotlin/TypeScript/Go)
- **engineering-workflow** — DB/BE/IF/SE 4개 도메인, 60+ 마이크로 에이전트 아키텍처 의사결정
- **numerical** — Python/Dart 수치 연산 검증/최적화
- **plugin-introspector** — 플러그인 모니터링 및 자기 개선 메타 플러그인
- **claude-autopilot** — 시간 제한 자율 실행 오케스트레이터

### 신규 전문가 (5명)
- **sub-team-lead** — 팀 오케스트레이터 (요청 분류, 전문가 라우팅, 멀티 전문가 조율)
- **sub-api-designer** — Contract-first API 설계 (OpenAPI 3.1, Breaking Change 감지)
- **sub-code-reviewer** — 코드 리뷰/리팩토링 (SOLID, 코드 스멜, 기술 부채 정량화)
- **sub-devops-engineer** — DevOps/CI-CD (Dockerfile, GitHub Actions, K8s, Terraform)
- **sub-performance-engineer** — 성능 분석/최적화 (JVM, DB, 부하 테스트, 캐싱)

### 팀 협업 모델

```
사용자 요청
    │
    ▼
sub-team-lead (분류)
    ├── 단일 도메인 → 해당 전문가 직접 위임
    ├── 멀티 도메인 → 순차/병렬 멀티 전문가 디스패치
    ├── 기존 스킬 매치 → 기존 스킬로 패스스루
    └── 모호한 요청 → 사용자에게 명확화 요청
```

## Validation commands

컨벤션 검증 — 빌드 없이 실행 가능한 셸 스크립트:

```bash
# sub-kopring-engineer: Kotlin/Java 코드 컨벤션 검증
plugins/sub-kopring-engineer/skills/sub-kopring-engineer/scripts/verify-conventions.sh [대상경로]

# numerical: 수치 연산 코드 검증
plugins/numerical/skills/numerical/scripts/verify-numeric.sh [대상경로]

# sub-test-engineer: 문서 일관성 검증
plugins/sub-test-engineer/skills/sub-test-engineer/scripts/verify-doc-consistency.sh [대상경로]

# engineering-workflow: 쿼리 도메인 분류 (DB/BE/IF/SE)
plugins/engineering-workflow/skills/engineering-workflow/scripts/classify-query.sh "쿼리 텍스트"

# sub-team-lead: 요청 분류 (전문가 라우팅)
plugins/sub-team-lead/skills/sub-team-lead/scripts/classify-request.sh "요청 텍스트"

# sub-api-designer: API 프레임워크 감지
plugins/sub-api-designer/skills/sub-api-designer/scripts/detect-api-framework.sh [프로젝트경로]

# sub-code-reviewer: 복잡도 측정
plugins/sub-code-reviewer/skills/sub-code-reviewer/scripts/measure-complexity.sh [대상경로]

# sub-devops-engineer: 인프라 파일 감지
plugins/sub-devops-engineer/skills/sub-devops-engineer/scripts/detect-infra.sh [프로젝트경로]

# sub-performance-engineer: 슬로우 쿼리 패턴 감지
plugins/sub-performance-engineer/skills/sub-performance-engineer/scripts/analyze-slow-query.sh [대상경로]

# 프로젝트 자동 감지 (언어, 프레임워크, 쿼리 라이브러리 등)
plugins/sub-kopring-engineer/skills/sub-kopring-engineer/scripts/discover-project.sh
plugins/numerical/skills/numerical/scripts/discover-project.sh
```

## Architecture

### 2-Layer 스킬 구조

모든 플러그인이 공유하는 핵심 패턴:
- **SKILL.md** — Claude Code가 읽는 진입점. 코어 프롬프트와 워크플로우 정의
- **resources/** — 단계별 on-demand 로딩. 토큰 효율을 위해 필요한 단계에서만 주입

### Phase-based 워크플로우

각 플러그인은 단계별 워크플로우를 따른다:
- sub-kopring-engineer: Brainstorm → Plan → Implement → Verify
- sub-test-engineer: Analyze → Strategize → Generate → Validate
- numerical: Analyze → Verify → Optimize
- plugin-introspector: 명령어 기반 (status, dashboard, analyze 등)
- engineering-workflow: Classify → Route → Execute → Resolve → Synthesize
- sub-team-lead: Classify → Route → Coordinate → Synthesize
- sub-api-designer: Analyze → Design → Validate → Document
- sub-code-reviewer: Scan → Analyze → Propose → Verify
- sub-devops-engineer: Discover → Design → Generate → Validate
- sub-performance-engineer: Baseline → Analyze → Optimize → Validate

### Hook 시스템

`plugin.json`의 hooks로 자동화 트리거 설정:
- **PreToolUse** — Edit/Write 전 보안 검사 (프로덕션 시크릿 파일 차단 등)
- **PostToolUse** — Edit/Write 후 자동 lint (ktlint, checkstyle 등)
- **Stop** — 세션 종료 시 테스트 Quality Gate

Hook 명령은 `$CLAUDE_TOOL_INPUT`을 jq로 파싱하여 대상 파일 경로를 추출한다.

### 셸 스크립트 원칙

- 외부 의존성 없음: bash + jq + git만 사용
- LLM 호출 없이 결정론적 검증 수행
- 패턴 캐시 저장 위치: `~/.claude/cache/`

## Plugin layout

표준 플러그인 디렉터리 구조 (sub-kopring-engineer 기준):

```
plugins/sub-kopring-engineer/
├── .claude-plugin/
│   └── plugin.json          # hooks 정의 (PreToolUse/PostToolUse/Stop)
└── skills/
    └── sub-kopring-engineer/
        ├── SKILL.md          # 진입점 — Claude Code가 읽는 코어 프롬프트
        ├── resources/        # 단계별 on-demand 프로토콜 문서
        ├── references/       # 정적 참조 자료
        ├── scripts/          # 검증/감지 셸 스크립트
        ├── templates/        # 코드 생성 템플릿
        └── ast-grep-rules/   # AST 기반 정적 분석 규칙 (선택적)
```

plugin-introspector는 추가로 `skills/` 하위에 meta-rules, analysis-patterns, cost-tracking 지식 스킬을 포함한다.

## Key conventions

- **문서 언어**: 한국어 (SKILL.md, resources, 커밋 메시지 제외)
- **SKILL.md가 진입점**: Claude Code는 SKILL.md를 먼저 읽고, resources/는 해당 단계 진입 시 로딩
- **Tiered Verification**: 변경 규모에 따라 LIGHT / STANDARD / THOROUGH 자동 선택
- **plugin-introspector hooks**: `INTROSPECTOR_SCRIPTS` 환경변수로 훅 스크립트 디렉터리 경로 오버라이드 가능
- **패턴 학습**: 프로젝트 코드 패턴을 자동 학습 → `~/.claude/cache/`에 저장 → 코드 생성에 반영

## Cross-skill protocols

Sister-skill 간 연동은 `docs/shared/03-invoke-protocol.md`에 정의된 프로토콜을 따른다.
