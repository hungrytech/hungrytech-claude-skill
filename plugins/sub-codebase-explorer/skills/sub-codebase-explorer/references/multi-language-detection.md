# 다언어 감지 패턴 카탈로그

`discover-stack.sh` + `_common.sh::detect_languages()`가 사용하는 패턴.

## 빌드 시스템 → 언어 매핑

| 빌드 파일 | 주 언어 | 부가 |
|-----------|--------|------|
| `build.gradle.kts` | Kotlin | Java(혼합 가능) |
| `build.gradle` | Java | Kotlin/Groovy |
| `pom.xml` | Java | Kotlin/Scala |
| `package.json` | TypeScript/JavaScript | — |
| `pnpm-workspace.yaml`, `turbo.json`, `nx.json` | TS 모노레포 | — |
| `pyproject.toml` | Python (Poetry/PEP 621) | — |
| `requirements.txt` | Python (pip) | — |
| `go.mod` | Go | — |
| `Cargo.toml` | Rust | — |
| `Gemfile` | Ruby | — |

## 디렉토리 휴리스틱

| 경로 | 추정 |
|------|------|
| `src/main/kotlin/` | Kotlin (Maven/Gradle 표준) |
| `src/main/java/`   | Java |
| `src/test/{kotlin,java}/` | 테스트 디렉토리 |
| `src/`, `lib/` (TS) | TS/JS 소스 |
| `cmd/`, `pkg/`, `internal/` | Go 표준 |
| `services/*/`, `apps/*/`, `packages/*/` | MSA / 모노레포 |

## 모노레포 신호

- `pnpm-workspace.yaml` + `packages/*/package.json` → pnpm workspace
- `turbo.json` → Turborepo
- `nx.json` → Nx
- Gradle multi-module: `settings.gradle` 의 `include(":foo", ":bar")`
- Go multi-module: 다중 `go.mod`

## 프레임워크 키워드 (의존성 파일 grep 기반)

| 카테고리 | 키워드 |
|---------|-------|
| Web (JVM) | spring-boot, micronaut, quarkus, ktor |
| Web (Python) | django, fastapi, flask, starlette |
| Web (Go) | gin, echo, chi, fiber |
| Web (TS) | nestjs, express, fastify, koa, next |
| ORM (JVM) | jpa, hibernate, exposed, mybatis |
| ORM (Python) | sqlalchemy, peewee, tortoise |
| ORM (TS) | typeorm, prisma, sequelize, drizzle |
| ORM (Go) | gorm, sqlx, ent |
