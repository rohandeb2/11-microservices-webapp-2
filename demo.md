FROM eclipse-temurin:21-jdk AS builder
WORKDIR /app

# Copy wrapper and set permissions
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

# Copy the contents of the hipstershop install folder to /app
COPY --from=builder /app/build/install/hipstershop /app/

# Senior Tip: Let's verify the script name. 
# In this specific repo, the script is usually 'adservice' (lowercase)
# but the folder was 'hipstershop'. 

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Environment variables for Java

EXPOSE 9555

# This must match the filename inside /app/bin/
ENTRYPOINT ["/app/bin/AdService"]



# Stage 1: Build & Publish
# Use the stable 8.0 SDK instead of RC (Release Candidate) for production reliability
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine@sha256:0990497554906f3629471f49646b9ec7858f918454173d324867958564a93883 AS builder

WORKDIR /app

# Optimization: Copy and restore dependencies as a separate layer
# This ensures 'dotnet restore' is only re-run if the .csproj changes
COPY cartservice.csproj .
RUN dotnet restore cartservice.csproj -r linux-musl-x64

# Copy remaining source code
COPY . .

# Publish the application
# -p:PublishTrimmed=True and TrimMode=Full significantly reduce image size
RUN dotnet publish cartservice.csproj \
    -c Release \
    -o /cartservice \
    -r linux-musl-x64 \
    --self-contained true \
    -p:PublishSingleFile=true \
    -p:PublishTrimmed=True \
    -p:TrimMode=Full \
    --no-restore

# Stage 2: Final Hardened Runtime
# Using runtime-deps:8.0-alpine for the smallest possible attack surface
FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-alpine@sha256:d898511456254425b03770415392d47565e381648a3182813df973a0e633d719

WORKDIR /app

# Industrial Standard: Copy from builder stage
COPY --from=builder /cartservice .

# Security: Set up a non-root user specifically for this application
# Do not rely on ID 1000 being pre-existent or safe in all environments
RUN addgroup -S cartgroup && adduser -S cartuser -G cartgroup
USER cartuser

# Standardized Ports and Environment Variables
ENV ASPNETCORE_HTTP_PORTS=7070 \
    DOTNET_EnableDiagnostics=0 \
    # Ensure the app knows it is in a production container
    DOTNET_RUNNING_IN_CONTAINER=true

EXPOSE 7070

# Use the full path for the Entrypoint
ENTRYPOINT ["./cartservice"]