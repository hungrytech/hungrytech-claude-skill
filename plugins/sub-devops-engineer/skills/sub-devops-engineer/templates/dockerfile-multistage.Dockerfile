# ============================================================
# Multi-stage Dockerfile for {APP_NAME}
# Language: {LANGUAGE} | Build: {BUILD_TOOL} | Runtime: {RUNTIME}
# ============================================================

# Stage 1: Build
FROM eclipse-temurin:{JVM_VERSION}-jdk AS builder

WORKDIR /app

# Copy dependency files first for layer caching
COPY build.gradle.kts settings.gradle.kts ./
COPY gradle/ gradle/
COPY gradlew ./
RUN chmod +x gradlew && ./gradlew dependencies --no-daemon

# Copy source and build
COPY src/ src/
RUN ./gradlew bootJar --no-daemon -x test

# Stage 2: Runtime (distroless for security)
FROM gcr.io/distroless/java{JVM_MAJOR_VERSION}-debian12

WORKDIR /app
COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080

# JVM options for container environment
ENV JAVA_OPTS="-XX:+UseG1GC -XX:MaxRAMPercentage=75.0 -XX:+UseContainerSupport"

ENTRYPOINT ["java", "-jar", "app.jar"]
