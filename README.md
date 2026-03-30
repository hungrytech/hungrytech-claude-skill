# hungrytech-claude-skills

A curated collection of **12 Claude Code plugins** that form a complete software engineering team. Each plugin is a specialized expert agent — no runtime build system, just shell scripts and SKILL.md prompts.

> **[한국어 버전은 아래에 있습니다 →](#한국어)**

---

## Team Overview

```
User Request
    │
    ▼
sub-team-lead (classify & route)
    ├── Single domain  → Direct delegation to one expert
    ├── Multi domain   → Sequential/parallel multi-expert dispatch
    ├── Existing skill → Pass-through to matching skill
    └── Ambiguous      → Ask user for clarification
```

### Expert Roster

| # | Expert | Command | Role |
|---|--------|---------|------|
| 1 | [sub-team-lead](#sub-team-lead) | `/sub-team-lead` | Team orchestrator — classifies requests, routes to experts |
| 2 | [sub-kopring-engineer](#sub-kopring-engineer) | `/sub-kopring-engineer` | Kotlin/Java Spring Boot development (Hexagonal Architecture) |
| 3 | [sub-test-engineer](#sub-test-engineer) | `/sub-test-engineer` | Type-driven test generation (Java/Kotlin/TypeScript/Go) |
| 4 | [sub-api-designer](#sub-api-designer) | `/sub-api-designer` | Contract-first API design (OpenAPI 3.1) |
| 5 | [sub-code-reviewer](#sub-code-reviewer) | `/sub-code-reviewer` | Code review & refactoring (SOLID, code smells, tech debt) |
| 6 | [sub-devops-engineer](#sub-devops-engineer) | `/sub-devops-engineer` | DevOps/CI-CD (Docker, GitHub Actions, K8s, Terraform) |
| 7 | [sub-performance-engineer](#sub-performance-engineer) | `/sub-performance-engineer` | Performance analysis & optimization (JVM, DB, load testing) |
| 8 | [engineering-workflow](#engineering-workflow) | `/engineering-workflow` | Architecture decisions across DB/BE/IF/SE domains |
| 9 | [numerical](#numerical) | `/numerical` | Numerical computing verification (Python/Dart) |
| 10 | [plugin-introspector](#plugin-introspector) | `/plugin-introspector` | Plugin monitoring & self-improvement |
| 11 | [claude-autopilot](#claude-autopilot) | `/claude-autopilot` | Time-bounded autonomous task orchestration |
| 12 | [sub-frontend-engineer](#sub-frontend-engineer) | `/sub-frontend-engineer` | React/Vite frontend development (components, state, build) |

---

## Pick Your Team

You don't need all 12 experts. Install only the ones that match your workflow.

### Presets by Role

| If you are... | Recommended experts | Install |
|---------------|--------------------:|---------|
| **Backend developer (Kotlin/Java)** | kopring + test + code-reviewer | 3 plugins |
| **Backend + API design** | kopring + test + api-designer + code-reviewer | 4 plugins |
| **Full-stack team** | team-lead + kopring + test + api-designer + code-reviewer + devops + frontend | 7 plugins |
| **Performance-focused** | kopring + test + performance | 3 plugins |
| **Architecture/decision-making** | engineering-workflow + code-reviewer | 2 plugins |
| **Everything** | All 12 | 12 plugins |

### Standalone Experts (no dependencies)

Every expert works independently. There are no required dependencies between plugins.

```bash
# Example: Install only code-reviewer and test-engineer
/plugin install sub-code-reviewer@hungrytech-plugins
/plugin install sub-test-engineer@hungrytech-plugins
```

`sub-team-lead` is useful when you have 3+ experts installed — it auto-routes your requests. With 1-2 experts, just call them directly.

### Sister-skill Integration (optional, not required)

When multiple experts are installed, they can hand off work to each other. This is automatic — no configuration needed. If a sister skill isn't installed, the expert simply skips the handoff and continues on its own.

```
sub-api-designer ──design──→ sub-kopring-engineer ──implement──→ sub-test-engineer
       │                                                              │
       └── works fine alone                              works fine alone

sub-api-designer ──spec──→ sub-frontend-engineer ──UI──→ sub-devops-engineer
       │                          │                           │
       └── works fine alone       └── works fine alone        └── works fine alone
```

---

## Install

**Marketplace:**

```bash
/plugin marketplace add hungrytech/hungrytech-claude-skills
/plugin install <skill-name>@hungrytech-plugins
```

**Manual (single plugin):**

```bash
git clone https://github.com/hungrytech/hungrytech-claude-skills.git
cp -r plugins/<skill-name>/skills/<skill-name> /path/to/project/.claude/skills/
```

**Manual (multiple plugins):**

```bash
git clone https://github.com/hungrytech/hungrytech-claude-skills.git
for skill in sub-kopring-engineer sub-test-engineer sub-code-reviewer; do
  cp -r plugins/$skill/skills/$skill /path/to/project/.claude/skills/
done
```

---

## Architecture

### 2-Layer Skill Structure

Every plugin shares the same core pattern:

- **SKILL.md** — Entry point that Claude Code reads. Core prompt + workflow definition.
- **resources/** — On-demand loading per phase. Only injected when that phase starts (token efficiency).

### Plugin Directory Layout

```
plugins/{expert-name}/
├── .claude-plugin/
│   └── plugin.json              # Hook definitions (PreToolUse/PostToolUse/Stop)
└── skills/{expert-name}/
    ├── SKILL.md                 # Entry point — core prompt & workflow
    ├── resources/               # Phase-specific protocol docs
    ├── references/              # Static reference material
    ├── scripts/                 # Deterministic shell scripts (bash + jq)
    └── templates/               # Code/config generation templates
```

### Hook System

Hooks in `plugin.json` automate quality gates:

| Hook | When | Examples |
|------|------|----------|
| **PreToolUse** | Before Edit/Write | Block secret file access, block production files |
| **PostToolUse** | After Edit/Write | Auto-lint (ktlint, ruff), log changes |
| **Stop** | Session end | Run tests as quality gate |

### Shell Script Principles

- **Zero external dependencies**: bash + jq + git only
- **Deterministic**: No LLM calls — pattern matching and validation only
- **macOS compatible**: bash 3.2+ (no `declare -A`, no bash 4+ features)
- **Cache location**: `~/.claude/cache/`

---

## Experts

### sub-team-lead

Team orchestrator that classifies user requests and routes them to the appropriate expert(s).

**Workflow**: Classify → Route → Coordinate → Synthesize

```bash
/sub-team-lead
"Kotlin API 설계하고 테스트 생성해줘"
```

The classifier script (`classify-request.sh`) uses keyword matching to identify which expert(s) should handle a request. For multi-domain requests, it dispatches to multiple experts in sequence or parallel.

**Routing patterns:**

| Pattern | Example |
|---------|---------|
| Sequential pipeline | API design → Controller implementation → Test generation → Deploy |
| Parallel fan-out | Code review + Performance analysis simultaneously |
| Feedback loop | API design ↔ Code review (design → review → fix → re-review) |
| Escalation | Low confidence → re-route through team lead |

**Keywords**: "team lead", "팀 리드", "프로젝트 설정", "기술 스택", "어떤 전문가", "who should", "coordinate"

---

### sub-kopring-engineer

Kotlin/Java Spring Boot implementation agent with convention verification.

**Workflow**: Brainstorm → Plan → Implement → Verify

```bash
/sub-kopring-engineer
Order 취소 기능 구현해줘. loop 3
```

| Mode | Example | Behavior |
|------|---------|----------|
| All-in-one | `Order 취소 기능` | Full pipeline, single pass |
| Loop | `Order 취소. loop 3` | Repeats Verify up to 3 times |
| Per-phase | `plan: 결제 취소` | Runs only the specified phase |
| Verify-only | `verify loop 2` | Verifies current code twice |
| Dry run | `Order 취소. dry-run` | Stops after Plan, no file changes |

**Convention checks** (25 items, 7 categories): Architecture layer deps, style (constructor injection, no `@Autowired`), naming (`*JpaEntity`, `*RestController`), JOOQ, test patterns, JPA, git conventions. All checks run as shell commands — zero LLM tokens.

**Pattern learning**: `learn-patterns.sh` extracts base classes, annotations, naming patterns from source code and caches them. `capture-task-patterns.sh` detects new patterns after each verify loop.

---

### sub-test-engineer

Type-driven test generation for Java/Kotlin/TypeScript/Go backends.

**Workflow**: Analyze → Strategize → Generate → Validate

```bash
/sub-test-engineer
OrderService 테스트 생성. loop 3
```

| Mode | Example | Behavior |
|------|---------|----------|
| All-in-one | `OrderService 테스트 생성` | Full pipeline |
| Loop | `loop 3` | Repeats Validate 3 times |
| Coverage target | `coverage-target 80%` | Loops until target met |
| Technique | `property-test: OrderValidator` | Runs only the specified technique |

**Type extraction**: 3-stage pipeline — ast-grep (structural) → LLM (semantic) → ClassGraph (bytecode). Derives test cases from sealed classes, enums, validation annotations.

**Validation**: compile → execute → coverage → mutation test → quality evaluation. With 5+ targets, Agent Teams run tests in parallel (~60% time reduction).

---

### sub-api-designer

Contract-first API design agent with OpenAPI 3.1 spec generation.

**Workflow**: Analyze → Design → Validate → Document

```bash
/sub-api-designer
주문 API 설계해줘. REST, 페이지네이션 포함
```

| Mode | Example | Behavior |
|------|---------|----------|
| Full pipeline | `주문 API 설계` | Analyze → Design → Validate → Document |
| Breaking change | `breaking-change: v1 vs v2` | Detect breaking changes between versions |
| Mock | `mock: order-api.yaml` | Generate mock server from spec |
| Validate only | `validate: api-spec.yaml` | Validate existing OpenAPI spec |

**Capabilities**: OpenAPI 3.1 spec generation, breaking change detection, REST patterns (pagination, filtering, RFC 7807 error responses), mock server setup, contract test stub generation.

**Sister-skill integration**: → `sub-kopring-engineer` (controller implementation) → `sub-test-engineer` (contract tests) → `engineering-workflow` SE (API security review)

---

### sub-code-reviewer

Language-agnostic code review and refactoring agent.

**Workflow**: Scan → Analyze → Propose → Verify

```bash
/sub-code-reviewer
OrderService 코드 리뷰해줘
```

| Mode | Example | Behavior |
|------|---------|----------|
| Full review | `review: src/order/` | Complete code review pipeline |
| Refactor | `refactor: OrderService` | Focused refactoring suggestions |
| Debt report | `debt-report` | Tech debt quantification |
| Complexity | `complexity: src/` | Complexity metrics analysis |

**Analysis**: SOLID violations, code smells (God class, Feature Envy, Long Method, etc.), cyclomatic/cognitive complexity, Martin Fowler refactoring catalog-based diff suggestions.

**Tech debt formula**: `Debt Score = Σ(severity × frequency × fix_cost)` — prioritized improvement plan.

**Scripts**: `detect-language.sh` (language detection), `measure-complexity.sh` (basic complexity metrics)

---

### sub-devops-engineer

DevOps/CI-CD agent for infrastructure and deployment.

**Workflow**: Discover → Design → Generate → Validate

```bash
/sub-devops-engineer
GitHub Actions CI/CD 파이프라인 만들어줘
```

| Mode | Example | Behavior |
|------|---------|----------|
| Full pipeline | `CI/CD 파이프라인 설계` | Discover → Design → Generate → Validate |
| Dockerfile | `dockerfile: Spring Boot` | Generate optimized Dockerfile |
| Pipeline | `pipeline: GitHub Actions` | CI/CD pipeline generation |
| K8s | `k8s: deployment` | Kubernetes manifest generation |
| Terraform | `terraform: AWS ECS` | Terraform module generation |

**Templates**: Multi-stage Dockerfile, GitHub Actions CI/CD, K8s Deployment/Service, Terraform modules.

**Capabilities**: Dockerfile best practices (multi-stage, non-root, layer caching), CI/CD pipelines (GitHub Actions, GitLab CI), Kubernetes patterns, Terraform IaC, deployment strategies (Blue-Green, Canary, Rolling), secret management.

---

### sub-performance-engineer

Performance analysis and optimization agent.

**Workflow**: Baseline → Analyze → Optimize → Validate

```bash
/sub-performance-engineer
주문 API 성능 분석해줘. slow query 포함
```

| Mode | Example | Behavior |
|------|---------|----------|
| Full pipeline | `성능 분석` | Baseline → Analyze → Optimize → Validate |
| JVM profile | `jvm-profile` | JVM heap/GC/thread analysis |
| DB analyze | `db-analyze: OrderRepository` | Query plan analysis, N+1 detection |
| Load test | `load-test: order-api` | k6/Gatling scenario generation |
| Cache strategy | `cache-strategy` | Caching layer design |

**Capabilities**: JVM profiling (JFR, async-profiler, heap/GC/thread), DB query optimization (EXPLAIN, slow query, N+1 detection), load testing (k6, Gatling), connection pool sizing, caching strategies, response time budget allocation.

**Scripts**: `detect-performance-stack.sh` (JVM/DB/cache detection), `analyze-slow-query.sh` (N+1 and query pattern detection)

---

### engineering-workflow

Routes architecture queries across **DB**, **BE**, **IF**, **SE** domains using 60+ micro-agents.

**Workflow**: Classify → Route → Execute → Resolve → Synthesize

```bash
/engineering-workflow
"Design a multi-tenant architecture with tenant isolation"
```

| Mode | Example | Behavior |
|------|---------|----------|
| Query | `"index design for large tables"` | Full pipeline |
| Analyze | `analyze: current sharding strategy` | Deep analysis |
| Compare | `compare: PostgreSQL vs CockroachDB` | Trade-off matrix |
| Recommend | `recommend: caching strategy` | Recommendation-first |

**Scripts**: `classify-query.sh` (domain classification), `resolve-constraints.sh` (conflict detection), `audit-analysis.sh` (quality checks), `format-output.sh` (output formatting)

---

### numerical

Numerical computing verification and optimization for Python/Dart.

**Workflow**: Analyze → Verify → Optimize

```bash
/numerical
numpy broadcasting 검증. loop 2
```

**Capabilities**: IEEE 754 floating-point analysis, broadcasting validation, dtype tracking, SIMD/GPU optimization, numerically stable algorithm suggestions (log-sum-exp, Kahan summation, Welford's algorithm).

---

### plugin-introspector

Meta-plugin that monitors other plugins and suggests improvements.

```bash
/plugin-introspector dashboard
/plugin-introspector quick-scan --target my-plugin
```

| Command | What it does |
|---------|-------------|
| `status` | Session overview |
| `dashboard` | htop-style live monitoring |
| `analyze` | Workflow deep-dive |
| `tokens` | Token usage analysis |
| `quick-scan` | Plugin structure & security check |
| `optimize` | APE loop-based prompt optimization |

---

### claude-autopilot

Time-bounded autonomous execution orchestrator.

```bash
/claude-autopilot
API 엔드포인트 리팩토링하고 테스트 추가해줘. --until 15:30
```

Accepts a directive and deadline, then autonomously decomposes tasks, executes them, and manages time budget. Includes safety guardrails (no destructive ops, secret file protection, scope enforcement).

**Time levels**: NORMAL (>50%) → AWARE (30-50%) → CAUTION (15-30%) → WIND_DOWN (5-15%) → CRITICAL (<5%)

---

### sub-frontend-engineer

React/Vite/TypeScript frontend development agent.

**Workflow**: Discover → Design → Implement → Verify

```bash
/sub-frontend-engineer
로그인 페이지 만들어줘
```

| Mode | Example | Behavior |
|------|---------|----------|
| Full cycle | `로그인 페이지 만들어줘` | Discover → Design → Implement → Verify |
| Component | `component: UserCard` | Single component generation |
| Page | `page: /dashboard` | Page-level generation with routing |
| Hook | `hook: useAuth` | Custom hook generation |
| Style | `style: 다크 모드 추가` | Tailwind theme/style config |

**Tech stack**: React 18+, Vite, TypeScript, Tailwind CSS, React Router, Zustand, TanStack Query.

**Testing**: Vitest + React Testing Library (unit/integration), Playwright (E2E).

**Scripts**: `detect-frontend-stack.sh` (stack detection), `measure-bundle-size.sh` (bundle analysis)

**Sister-skill integration**: → `sub-api-designer` (API client hooks) → `sub-test-engineer` (test strategy) → `sub-code-reviewer` (code review) → `sub-devops-engineer` (build + deploy)

**Keywords**: "react", "vite", "frontend", "프론트엔드", "component", "컴포넌트", "tailwind", "zustand", "tanstack", "vitest", "프론트", "UI", "페이지", "화면"

---

## Validation Commands

All scripts run without a build system — bash + jq only:

```bash
# Team Lead: Request classification
plugins/sub-team-lead/skills/sub-team-lead/scripts/classify-request.sh "요청 텍스트"

# Kopring: Convention verification
plugins/sub-kopring-engineer/skills/sub-kopring-engineer/scripts/verify-conventions.sh [path]

# Test Engineer: Doc consistency
plugins/sub-test-engineer/skills/sub-test-engineer/scripts/verify-doc-consistency.sh [path]

# API Designer: Framework detection
plugins/sub-api-designer/skills/sub-api-designer/scripts/detect-api-framework.sh [path]

# Code Reviewer: Complexity measurement
plugins/sub-code-reviewer/skills/sub-code-reviewer/scripts/measure-complexity.sh [path]

# DevOps: Infrastructure detection
plugins/sub-devops-engineer/skills/sub-devops-engineer/scripts/detect-infra.sh [path]

# Performance: Slow query analysis
plugins/sub-performance-engineer/skills/sub-performance-engineer/scripts/analyze-slow-query.sh [path]

# Frontend: Stack detection
plugins/sub-frontend-engineer/skills/sub-frontend-engineer/scripts/detect-frontend-stack.sh [path]

# Engineering Workflow: Query classification
plugins/engineering-workflow/skills/engineering-workflow/scripts/classify-query.sh "query"

# Numerical: Numeric code verification
plugins/numerical/skills/numerical/scripts/verify-numeric.sh [path]
```

---

## Project Stats

| Plugin | Files | Role |
|--------|------:|------|
| sub-team-lead | 10 | Team orchestration |
| sub-kopring-engineer | 68 | Backend development |
| sub-test-engineer | 92 | Test generation |
| sub-api-designer | 13 | API design |
| sub-code-reviewer | 13 | Code review |
| sub-devops-engineer | 16 | DevOps/CI-CD |
| sub-performance-engineer | 14 | Performance |
| engineering-workflow | 144 | Architecture decisions |
| numerical | 21 | Numerical computing |
| plugin-introspector | 48 | Meta-monitoring |
| claude-autopilot | 20 | Autonomous execution |
| sub-frontend-engineer | 16 | Frontend development |
| **Total** | **475** | **12 experts** |

## License

MIT

---

---

<a id="한국어"></a>

# hungrytech-claude-skills (한국어)

**12개의 Claude Code 플러그인**으로 구성된 완전한 소프트웨어 엔지니어링 팀. 각 플러그인은 전문 영역의 에이전트로, 런타임 빌드 시스템 없이 셸 스크립트와 SKILL.md 프롬프트만으로 동작합니다.

---

## 팀 구조

```
사용자 요청
    │
    ▼
sub-team-lead (분류 & 라우팅)
    ├── 단일 도메인  → 해당 전문가 직접 위임
    ├── 멀티 도메인  → 순차/병렬 멀티 전문가 디스패치
    ├── 기존 스킬    → 기존 스킬로 패스스루
    └── 모호한 요청  → 사용자에게 명확화 요청
```

### 전문가 목록

| # | 전문가 | 명령어 | 역할 |
|---|--------|--------|------|
| 1 | [sub-team-lead](#sub-team-lead-1) | `/sub-team-lead` | 팀 오케스트레이터 — 요청 분류, 전문가 라우팅 |
| 2 | [sub-kopring-engineer](#sub-kopring-engineer-1) | `/sub-kopring-engineer` | Kotlin/Java Spring Boot 개발 (Hexagonal Architecture) |
| 3 | [sub-test-engineer](#sub-test-engineer-1) | `/sub-test-engineer` | 타입 기반 테스트 생성 (Java/Kotlin/TypeScript/Go) |
| 4 | [sub-api-designer](#sub-api-designer-1) | `/sub-api-designer` | Contract-first API 설계 (OpenAPI 3.1) |
| 5 | [sub-code-reviewer](#sub-code-reviewer-1) | `/sub-code-reviewer` | 코드 리뷰/리팩토링 (SOLID, 코드 스멜, 기술 부채) |
| 6 | [sub-devops-engineer](#sub-devops-engineer-1) | `/sub-devops-engineer` | DevOps/CI-CD (Docker, GitHub Actions, K8s, Terraform) |
| 7 | [sub-performance-engineer](#sub-performance-engineer-1) | `/sub-performance-engineer` | 성능 분석/최적화 (JVM, DB, 부하 테스트) |
| 8 | [engineering-workflow](#engineering-workflow-1) | `/engineering-workflow` | DB/BE/IF/SE 도메인 아키텍처 의사결정 |
| 9 | [numerical](#numerical-1) | `/numerical` | 수치 연산 검증/최적화 (Python/Dart) |
| 10 | [plugin-introspector](#plugin-introspector-1) | `/plugin-introspector` | 플러그인 모니터링/자기 개선 |
| 11 | [claude-autopilot](#claude-autopilot-1) | `/claude-autopilot` | 시간 제한 자율 실행 오케스트레이터 |
| 12 | [sub-frontend-engineer](#sub-frontend-engineer-1) | `/sub-frontend-engineer` | React/Vite 프론트엔드 (컴포넌트, 상태 관리, 빌드 최적화) |

---

## 필요한 전문가만 골라 쓰기

12명 전부 설치할 필요 없습니다. 자신의 워크플로우에 맞는 전문가만 골라 설치하세요.

### 역할별 추천 조합

| 당신이... | 추천 전문가 | 설치 수 |
|-----------|-----------:|--------:|
| **백엔드 개발자 (Kotlin/Java)** | kopring + test + code-reviewer | 3개 |
| **백엔드 + API 설계** | kopring + test + api-designer + code-reviewer | 4개 |
| **풀스택 팀** | team-lead + kopring + test + api-designer + code-reviewer + devops + frontend | 7개 |
| **성능 중심** | kopring + test + performance | 3개 |
| **아키텍처/의사결정** | engineering-workflow + code-reviewer | 2개 |
| **전부 다** | 전체 12개 | 12개 |

### 단독 사용 가능

모든 전문가는 독립적으로 동작합니다. 플러그인 간 필수 의존성은 없습니다.

```bash
# 예시: code-reviewer와 test-engineer만 설치
/plugin install sub-code-reviewer@hungrytech-plugins
/plugin install sub-test-engineer@hungrytech-plugins
```

`sub-team-lead`는 전문가 3명 이상 설치 시 유용합니다 — 요청을 자동 라우팅합니다. 1-2명이면 직접 호출하는 게 빠릅니다.

### 자매 스킬 연동 (선택 사항, 필수 아님)

여러 전문가가 설치되면 자동으로 작업을 넘겨줍니다. 별도 설정 불필요. 자매 스킬이 없으면 핸드오프를 건너뛰고 혼자 계속합니다.

```
sub-api-designer ──설계──→ sub-kopring-engineer ──구현──→ sub-test-engineer
       │                                                        │
       └── 단독으로도 OK                              단독으로도 OK

sub-api-designer ──스펙──→ sub-frontend-engineer ──UI──→ sub-devops-engineer
       │                          │                           │
       └── 단독으로도 OK           └── 단독으로도 OK            └── 단독으로도 OK
```

---

## 설치

**마켓플레이스:**

```bash
/plugin marketplace add hungrytech/hungrytech-claude-skills
/plugin install <skill-name>@hungrytech-plugins
```

**수동 설치 (단일 플러그인):**

```bash
git clone https://github.com/hungrytech/hungrytech-claude-skills.git
cp -r plugins/<skill-name>/skills/<skill-name> /path/to/project/.claude/skills/
```

**수동 설치 (여러 플러그인):**

```bash
git clone https://github.com/hungrytech/hungrytech-claude-skills.git
for skill in sub-kopring-engineer sub-test-engineer sub-code-reviewer; do
  cp -r plugins/$skill/skills/$skill /path/to/project/.claude/skills/
done
```

---

## 아키텍처

### 2-Layer 스킬 구조

모든 플러그인이 공유하는 핵심 패턴:

- **SKILL.md** — Claude Code가 읽는 진입점. 코어 프롬프트와 워크플로우 정의.
- **resources/** — 단계별 on-demand 로딩. 토큰 효율을 위해 필요한 단계에서만 주입.

### 플러그인 디렉터리 구조

```
plugins/{expert-name}/
├── .claude-plugin/
│   └── plugin.json              # 훅 정의 (PreToolUse/PostToolUse/Stop)
└── skills/{expert-name}/
    ├── SKILL.md                 # 진입점 — 코어 프롬프트 & 워크플로우
    ├── resources/               # 페이즈별 프로토콜 문서
    ├── references/              # 정적 레퍼런스 자료
    ├── scripts/                 # 결정론적 셸 스크립트 (bash + jq)
    └── templates/               # 코드/설정 생성 템플릿
```

### 훅 시스템

`plugin.json`의 훅으로 품질 게이트를 자동화:

| 훅 | 시점 | 예시 |
|----|------|------|
| **PreToolUse** | Edit/Write 전 | 시크릿 파일 차단, 프로덕션 파일 차단 |
| **PostToolUse** | Edit/Write 후 | 자동 린트 (ktlint, ruff), 변경 로그 |
| **Stop** | 세션 종료 | 테스트 실행 (품질 게이트) |

### 셸 스크립트 원칙

- **외부 의존성 제로**: bash + jq + git만 사용
- **결정론적**: LLM 호출 없음 — 패턴 매칭과 검증만 수행
- **macOS 호환**: bash 3.2+ (associative array 미사용)
- **캐시 경로**: `~/.claude/cache/`

---

## 전문가 상세

<a id="sub-team-lead-1"></a>
### sub-team-lead — 팀 오케스트레이터

사용자 요청을 분류하여 적절한 전문가에게 라우팅하고, 멀티 전문가 협업을 조율합니다.

**워크플로우**: Classify → Route → Coordinate → Synthesize

```bash
/sub-team-lead
"Kotlin API 설계하고 테스트 생성해줘"
```

분류 스크립트(`classify-request.sh`)가 키워드 매칭으로 어떤 전문가가 처리할지 판단합니다. 멀티 도메인 요청은 여러 전문가를 순차 또는 병렬로 디스패치합니다.

**라우팅 패턴:**

| 패턴 | 예시 |
|------|------|
| 순차 파이프라인 | API 설계 → 컨트롤러 구현 → 테스트 생성 → 배포 |
| 병렬 팬아웃 | 코드 리뷰 + 성능 분석 동시 실행 |
| 피드백 루프 | API 설계 ↔ 코드 리뷰 (설계→리뷰→수정→재리뷰) |
| 에스컬레이션 | 신뢰도 낮음 → 팀 리드 재라우팅 |

**활성화 키워드**: "team lead", "팀 리드", "프로젝트 설정", "기술 스택", "어떤 전문가", "who should", "coordinate"

---

<a id="sub-kopring-engineer-1"></a>
### sub-kopring-engineer — Kotlin/Java Spring Boot 전문가

Kotlin/Java Spring Boot 코드베이스에서 Brainstorm, Plan, Implement, Verify 파이프라인을 실행합니다.

**워크플로우**: Brainstorm → Plan → Implement → Verify

```bash
/sub-kopring-engineer
Order 취소 기능 구현해줘. loop 3
```

| 모드 | 예시 | 동작 |
|------|------|------|
| 올인원 | `Order 취소 기능` | 전체 파이프라인, 단일 패스 |
| 루프 | `Order 취소. loop 3` | Verify 최대 3회 반복 |
| 단계별 | `plan: 결제 취소` | 지정 단계만 실행 |
| 검증만 | `verify loop 2` | 현재 코드 2회 검증 |
| 드라이런 | `Order 취소. dry-run` | Plan 이후 중단, 파일 변경 없음 |

**컨벤션 검사** (25개 항목, 7개 카테고리): 아키텍처 레이어 의존성, 스타일 (생성자 주입, `@Autowired` 금지), 네이밍 (`*JpaEntity`, `*RestController`), JOOQ, 테스트 패턴, JPA, git 컨벤션. 모든 검사는 셸 명령으로 실행 — LLM 토큰 소모 제로.

**패턴 학습**: `learn-patterns.sh`가 소스 코드에서 베이스 클래스, 어노테이션, 네이밍 패턴을 추출하여 캐시합니다. `capture-task-patterns.sh`가 검증 루프마다 새 패턴을 감지합니다.

---

<a id="sub-test-engineer-1"></a>
### sub-test-engineer — 테스트 생성 전문가

Java/Kotlin/TypeScript/Go 백엔드의 타입 정보를 읽어 테스트를 생성합니다.

**워크플로우**: Analyze → Strategize → Generate → Validate

```bash
/sub-test-engineer
OrderService 테스트 생성. loop 3
```

| 모드 | 예시 | 동작 |
|------|------|------|
| 올인원 | `OrderService 테스트 생성` | 전체 파이프라인 |
| 루프 | `loop 3` | Validate 3회 반복 |
| 커버리지 목표 | `coverage-target 80%` | 목표 달성까지 루프 |
| 기법 지정 | `property-test: OrderValidator` | 특정 기법만 실행 |

**타입 추출**: 3단계 파이프라인 — ast-grep (구조) → LLM (시맨틱) → ClassGraph (바이트코드). sealed class, enum, 검증 어노테이션에서 테스트 케이스를 도출합니다.

**검증**: 컴파일 → 실행 → 커버리지 → 뮤테이션 테스트 → 품질 평가. 5개 이상 대상 시 Agent Teams 병렬 실행 (~60% 시간 절감).

---

<a id="sub-api-designer-1"></a>
### sub-api-designer — API 설계 전문가

OpenAPI 3.1 표준에 따른 Contract-first API 설계 에이전트.

**워크플로우**: Analyze → Design → Validate → Document

```bash
/sub-api-designer
주문 API 설계해줘. REST, 페이지네이션 포함
```

| 모드 | 예시 | 동작 |
|------|------|------|
| 전체 파이프라인 | `주문 API 설계` | Analyze → Design → Validate → Document |
| Breaking change | `breaking-change: v1 vs v2` | 버전 간 호환성 검증 |
| Mock | `mock: order-api.yaml` | Mock 서버 생성 |
| 검증만 | `validate: api-spec.yaml` | 기존 OpenAPI 스펙 검증 |

**기능**: OpenAPI 3.1 스펙 생성, Breaking Change 감지, REST 패턴 (페이지네이션, 필터링, RFC 7807 에러 응답), Mock 서버, Contract Test 스텁 생성.

**자매 스킬 연동**: → `sub-kopring-engineer` (컨트롤러 구현) → `sub-test-engineer` (Contract 테스트) → `engineering-workflow` SE (API 보안 검토)

---

<a id="sub-code-reviewer-1"></a>
### sub-code-reviewer — 코드 리뷰/리팩토링 전문가

언어에 구애받지 않는 코드 품질 리뷰 및 리팩토링 에이전트.

**워크플로우**: Scan → Analyze → Propose → Verify

```bash
/sub-code-reviewer
OrderService 코드 리뷰해줘
```

| 모드 | 예시 | 동작 |
|------|------|------|
| 전체 리뷰 | `review: src/order/` | 전체 코드 리뷰 파이프라인 |
| 리팩토링 | `refactor: OrderService` | 집중 리팩토링 제안 |
| 부채 보고서 | `debt-report` | 기술 부채 정량화 |
| 복잡도 | `complexity: src/` | 복잡도 메트릭 분석 |

**분석**: SOLID 위반, 코드 스멜 (God class, Feature Envy, Long Method 등), 순환/인지 복잡도, Martin Fowler 리팩토링 카탈로그 기반 diff 제안.

**기술 부채 공식**: `Debt Score = Σ(severity × frequency × fix_cost)` — 우선순위 기반 개선 계획.

**스크립트**: `detect-language.sh` (언어 감지), `measure-complexity.sh` (복잡도 메트릭)

---

<a id="sub-devops-engineer-1"></a>
### sub-devops-engineer — DevOps/CI-CD 전문가

IaC, CI/CD 파이프라인, 컨테이너화, 배포 전략을 설계하고 생성합니다.

**워크플로우**: Discover → Design → Generate → Validate

```bash
/sub-devops-engineer
GitHub Actions CI/CD 파이프라인 만들어줘
```

| 모드 | 예시 | 동작 |
|------|------|------|
| 전체 파이프라인 | `CI/CD 파이프라인 설계` | Discover → Design → Generate → Validate |
| Dockerfile | `dockerfile: Spring Boot` | 최적화된 Dockerfile 생성 |
| 파이프라인 | `pipeline: GitHub Actions` | CI/CD 파이프라인 생성 |
| K8s | `k8s: deployment` | Kubernetes 매니페스트 생성 |
| Terraform | `terraform: AWS ECS` | Terraform 모듈 생성 |

**템플릿**: 멀티 스테이지 Dockerfile, GitHub Actions CI/CD, K8s Deployment/Service, Terraform 모듈.

**기능**: Dockerfile 모범 사례 (멀티 스테이지, non-root, 레이어 캐싱), CI/CD 파이프라인 (GitHub Actions, GitLab CI), Kubernetes 패턴, Terraform IaC, 배포 전략 (Blue-Green, Canary, Rolling), 시크릿 관리.

---

<a id="sub-performance-engineer-1"></a>
### sub-performance-engineer — 성능 분석/최적화 전문가

JVM, DB, 시스템 수준의 성능 병목을 분석하고 최적화합니다.

**워크플로우**: Baseline → Analyze → Optimize → Validate

```bash
/sub-performance-engineer
주문 API 성능 분석해줘. slow query 포함
```

| 모드 | 예시 | 동작 |
|------|------|------|
| 전체 파이프라인 | `성능 분석` | Baseline → Analyze → Optimize → Validate |
| JVM 프로파일링 | `jvm-profile` | 힙/GC/스레드 분석 |
| DB 분석 | `db-analyze: OrderRepository` | 쿼리 플랜, N+1 감지 |
| 부하 테스트 | `load-test: order-api` | k6/Gatling 시나리오 생성 |
| 캐싱 전략 | `cache-strategy` | 캐싱 레이어 설계 |

**기능**: JVM 프로파일링 (JFR, async-profiler, 힙/GC/스레드), DB 쿼리 최적화 (EXPLAIN, 슬로우 쿼리, N+1 감지), 부하 테스트 (k6, Gatling), Connection Pool 사이징, 캐싱 전략, 응답 시간 버짓 할당.

**스크립트**: `detect-performance-stack.sh` (JVM/DB/캐시 감지), `analyze-slow-query.sh` (N+1/쿼리 패턴 감지)

---

<a id="engineering-workflow-1"></a>
### engineering-workflow — 아키텍처 의사결정

**DB**, **BE**, **IF**, **SE** 4개 도메인에 걸쳐 60+ 마이크로 에이전트로 아키텍처 질의를 라우팅합니다.

**워크플로우**: Classify → Route → Execute → Resolve → Synthesize

```bash
/engineering-workflow
"멀티 테넌트 아키텍처 설계, 테넌트 격리 포함"
```

| 모드 | 예시 | 동작 |
|------|------|------|
| 질의 | `"대용량 테이블 인덱스 설계"` | 전체 파이프라인 |
| 분석 | `analyze: 현재 샤딩 전략` | 심층 분석 |
| 비교 | `compare: PostgreSQL vs CockroachDB` | 트레이드오프 매트릭스 |
| 추천 | `recommend: 캐싱 전략` | 추천 우선 출력 |

---

<a id="numerical-1"></a>
### numerical — 수치 연산 검증/최적화

Python/Dart 수치 연산 코드의 정확성 검증 및 성능 최적화.

**워크플로우**: Analyze → Verify → Optimize

```bash
/numerical
numpy broadcasting 검증. loop 2
```

**기능**: IEEE 754 부동소수점 분석, 브로드캐스팅 검증, dtype 추적, SIMD/GPU 최적화, 수치적으로 안정한 알고리즘 제안 (log-sum-exp, Kahan summation, Welford's algorithm).

---

<a id="plugin-introspector-1"></a>
### plugin-introspector — 플러그인 모니터링/자기 개선

다른 플러그인의 도구 호출, API 요청, 토큰 사용량, 실행 패턴을 수집하여 개선합니다.

```bash
/plugin-introspector dashboard
/plugin-introspector quick-scan --target my-plugin
```

| 명령어 | 기능 |
|--------|------|
| `status` | 세션 개요 |
| `dashboard` | htop 스타일 실시간 모니터링 |
| `analyze` | 워크플로우 심층 분석 |
| `tokens` | 토큰 사용량 분석 |
| `quick-scan` | 플러그인 구조/보안 점검 |
| `optimize` | APE 루프 기반 프롬프트 최적화 |

---

<a id="claude-autopilot-1"></a>
### claude-autopilot — 시간 제한 자율 실행

사용자 지시와 마감 시간을 받아 자율적으로 작업을 분해, 실행, 시간 관리합니다.

```bash
/claude-autopilot
API 엔드포인트 리팩토링하고 테스트 추가해줘. --until 15:30
```

**시간 레벨**: NORMAL (>50%) → AWARE (30-50%) → CAUTION (15-30%) → WIND_DOWN (5-15%) → CRITICAL (<5%)

**안전장치**: 파괴적 명령 차단, 시크릿 파일 보호, 스코프 강제, force push 금지, 3회 연속 동일 에러 시 자동 중단.

---

<a id="sub-frontend-engineer-1"></a>
### sub-frontend-engineer — React/Vite 프론트엔드 전문가

React + Vite + TypeScript 기반 프론트엔드 프로젝트의 컴포넌트 설계, 상태 관리, 스타일링, 빌드 최적화를 수행합니다.

**워크플로우**: Discover → Design → Implement → Verify

```bash
/sub-frontend-engineer
로그인 페이지 만들어줘
```

| 모드 | 예시 | 동작 |
|------|------|------|
| 전체 사이클 | `로그인 페이지 만들어줘` | Discover → Design → Implement → Verify |
| 컴포넌트 | `component: UserCard` | 단일 컴포넌트 생성 |
| 페이지 | `page: /dashboard` | 페이지 단위 생성 (라우팅 포함) |
| 훅 | `hook: useAuth` | 커스텀 훅 생성 |
| 스타일 | `style: 다크 모드 추가` | Tailwind 테마/스타일 설정 |

**기술 스택**: React 18+, Vite, TypeScript, Tailwind CSS, React Router, Zustand, TanStack Query.

**테스트**: Vitest + React Testing Library (단위/통합), Playwright (E2E).

**스크립트**: `detect-frontend-stack.sh` (스택 감지), `measure-bundle-size.sh` (번들 분석)

**자매 스킬 연동**: → `sub-api-designer` (API 클라이언트/훅 생성) → `sub-test-engineer` (테스트 전략 위임) → `sub-code-reviewer` (코드 리뷰) → `sub-devops-engineer` (Vite 빌드 + Docker + CI/CD)

**활성화 키워드**: "react", "vite", "frontend", "프론트엔드", "component", "컴포넌트", "tailwind", "zustand", "tanstack", "vitest", "프론트", "UI", "페이지", "화면"

---

## 검증 명령어

모든 스크립트는 빌드 시스템 없이 실행 — bash + jq만 필요:

```bash
# 팀 리드: 요청 분류
plugins/sub-team-lead/skills/sub-team-lead/scripts/classify-request.sh "요청 텍스트"

# Kopring: 컨벤션 검증
plugins/sub-kopring-engineer/skills/sub-kopring-engineer/scripts/verify-conventions.sh [경로]

# 테스트 엔지니어: 문서 일관성 검증
plugins/sub-test-engineer/skills/sub-test-engineer/scripts/verify-doc-consistency.sh [경로]

# API 디자이너: 프레임워크 감지
plugins/sub-api-designer/skills/sub-api-designer/scripts/detect-api-framework.sh [경로]

# 코드 리뷰어: 복잡도 측정
plugins/sub-code-reviewer/skills/sub-code-reviewer/scripts/measure-complexity.sh [경로]

# DevOps: 인프라 파일 감지
plugins/sub-devops-engineer/skills/sub-devops-engineer/scripts/detect-infra.sh [경로]

# 성능 엔지니어: 슬로우 쿼리 분석
plugins/sub-performance-engineer/skills/sub-performance-engineer/scripts/analyze-slow-query.sh [경로]

# 프론트엔드: 스택 감지
plugins/sub-frontend-engineer/skills/sub-frontend-engineer/scripts/detect-frontend-stack.sh [경로]

# 엔지니어링 워크플로우: 쿼리 분류
plugins/engineering-workflow/skills/engineering-workflow/scripts/classify-query.sh "쿼리"

# 수치 연산: 수치 코드 검증
plugins/numerical/skills/numerical/scripts/verify-numeric.sh [경로]
```

---

## 프로젝트 통계

| 플러그인 | 파일 수 | 역할 |
|----------|--------:|------|
| sub-team-lead | 10 | 팀 오케스트레이션 |
| sub-kopring-engineer | 68 | 백엔드 개발 |
| sub-test-engineer | 92 | 테스트 생성 |
| sub-api-designer | 13 | API 설계 |
| sub-code-reviewer | 13 | 코드 리뷰 |
| sub-devops-engineer | 16 | DevOps/CI-CD |
| sub-performance-engineer | 14 | 성능 분석 |
| engineering-workflow | 144 | 아키텍처 의사결정 |
| numerical | 21 | 수치 연산 |
| plugin-introspector | 48 | 메타 모니터링 |
| claude-autopilot | 20 | 자율 실행 |
| sub-frontend-engineer | 16 | 프론트엔드 개발 |
| **합계** | **475** | **12명의 전문가** |

## 라이선스

MIT
