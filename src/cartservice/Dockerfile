# --- Stage 1: Build & Restore ---
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS builder
WORKDIR /app

# Install compatibility libraries for gRPC/protoc on Alpine
RUN apk add --no-cache libc6-compat gcompat

# Optimization: Cache dependencies separately
COPY cartservice.sln .
COPY src/cartservice.csproj src/
COPY tests/cartservice.tests.csproj tests/
RUN dotnet restore cartservice.sln -r linux-musl-x64

COPY . .

# --- Stage 2: Self-Contained Publish ---
# SENIOR FIX: Build for 'linux-musl-x64' so it carries its own engine
RUN dotnet publish src/cartservice.csproj -c Release \
    -o /out \
    --no-restore \
    --runtime linux-musl-x64 \
    --self-contained true \
    -p:PublishSingleFile=true \
    -p:PublishTrimmed=true \
    -p:TrimMode=full

# --- Stage 3: Hardened Runtime ---
# We use 'runtime-deps' because the binary is now self-contained
FROM mcr.microsoft.com/dotnet/runtime-deps:8.0-alpine
WORKDIR /app

# Copy only the standalone binary and app settings
COPY --from=builder /out/cartservice .
COPY --from=builder /out/appsettings.json .

# Security: Set execution permissions and run as non-root UID
RUN chmod +x ./cartservice
USER 1000

# Industry Standard: Environment-based port flexibility
ENV ASPNETCORE_URLS=http://*:7070 \
    LISTEN_ADDR=0.0.0.0 \
    PORT=7070

EXPOSE 7070

ENTRYPOINT ["./cartservice"]
