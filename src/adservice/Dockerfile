# --- Stage 1: Build Stage ---
FROM eclipse-temurin:21-jdk AS builder
WORKDIR /app

# Copy Gradle wrapper and set permissions (Fixes Windows line-ending issues)
COPY gradlew . 
COPY gradle/ gradle/
RUN sed -i 's/\r$//' gradlew && chmod +x gradlew

COPY build.gradle settings.gradle ./
RUN ./gradlew dependencies --no-daemon

COPY . .
RUN sed -i 's/\r$//' gradlew && chmod +x gradlew
RUN ./gradlew installDist --no-daemon

# --- Stage 2: Hardened Runtime ---
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copy built application from the 'hipstershop' directory
COPY --from=builder /app/build/install/hipstershop /app/

# Security: Create non-root user (Mandatory for Fargate compliance)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# --- THE PRODUCTION TRUTH: Environment Variables ---
# JVM tuning: Ensures Java respects Kubernetes memory limits
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75.0"
# Disable profiler: Prevents crash in EKS/Fargate due to missing GCP agents
ENV DISABLE_PROFILER=1

EXPOSE 9555

# Senior Note: Ensure lowercase entrypoint matches the generated script
ENTRYPOINT ["/app/bin/adservice"]
