# --- Stage 1: Build Stage ---
FROM eclipse-temurin:21-jdk AS builder
WORKDIR /app

#Gradle is the build tool used to build the Java project.
COPY gradlew .   
COPY gradle/ gradle/
RUN sed -i 's/\r$//' gradlew && chmod +x gradlew

COPY build.gradle settings.gradle ./

# This command downloads all required libraries
RUN ./gradlew dependencies --no-daemon

#These files define project dependencies and build configuration
COPY . .

#Most developers: develop on Windows run containers on Linux So this issue 
#is very common in CI/CD pipelines.
RUN sed -i 's/\r$//' gradlew && chmod +x gradlew

#This builds the project and creates a runnable distribution.
RUN ./gradlew installDist --no-daemon

# --- Stage 2: Hardened Runtime ---
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

#This copies the built application from the builder stage.
COPY --from=builder /app/build/install/hipstershop /app/

# Security: Create non-root user (Mandatory for Fargate compliance)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# This tells Java: Use only 75% of container memory
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75.0"

#These environment variables disable GCP profiler tools.
ENV DISABLE_PROFILER=1
ENV ENABLE_PROFILER=false

EXPOSE 9555

# Senior Note: Ensure lowercase entrypoint matches the generated script
ENTRYPOINT ["/app/bin/AdService"]   

