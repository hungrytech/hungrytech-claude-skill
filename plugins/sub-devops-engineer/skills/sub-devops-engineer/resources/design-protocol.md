# 인프라 설계 프로토콜

> Phase 2: 탐색 결과를 기반으로 인프라 설계를 결정한다.

---

## 패턴 선택

### Dockerfile

| 프로젝트 타입 | 베이스 이미지 | 빌드 도구 |
|--------------|-------------|----------|
| Spring Boot (Kotlin/Java) | eclipse-temurin → gcr.io/distroless/java | Gradle |
| Node.js | node:lts-alpine | npm/yarn |
| Go | golang:alpine → scratch | go build |
| Python | python:slim | pip |

### CI/CD 파이프라인

표준 단계:
1. Lint (정적 분석)
2. Test (단위/통합 테스트)
3. Build (아티팩트 생성)
4. Publish (이미지 빌드/푸시)
5. Deploy (환경별 배포)

### 배포 전략

| 전략 | 조건 |
|------|------|
| Rolling | 기본값, 무중단 배포 |
| Blue-Green | 즉각 롤백 필요 시 |
| Canary | 점진적 트래픽 전환 필요 시 |

## 출력

- 생성할 파일 목록
- 각 파일의 설계 결정 근거
