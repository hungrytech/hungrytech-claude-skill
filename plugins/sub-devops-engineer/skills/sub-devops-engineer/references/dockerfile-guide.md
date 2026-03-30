# Dockerfile 가이드

> 멀티 스테이지 빌드, 보안 강화, 캐싱 최적화.

---

## 멀티 스테이지 빌드

```dockerfile
# Stage 1: Build
FROM eclipse-temurin:21-jdk AS builder
WORKDIR /app
COPY build.gradle.kts settings.gradle.kts ./
COPY gradle/ gradle/
RUN ./gradlew dependencies --no-daemon  # 의존성 캐시
COPY src/ src/
RUN ./gradlew bootJar --no-daemon

# Stage 2: Runtime
FROM gcr.io/distroless/java21-debian12
COPY --from=builder /app/build/libs/*.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

## 보안 강화

- `USER nonroot`: non-root 사용자로 실행
- distroless/alpine: 최소 이미지 (공격 표면 축소)
- `.dockerignore`: 불필요한 파일 제외
- COPY 대신 ADD 사용 금지 (아카이브 제외)
- 시크릿은 빌드 인자가 아닌 런타임 환경 변수로

## 레이어 캐싱

의존성 파일을 먼저 복사하여 캐시 활용:
```dockerfile
COPY build.gradle.kts settings.gradle.kts ./
RUN ./gradlew dependencies
COPY src/ src/
RUN ./gradlew build
```

## 헬스체크

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1
```
