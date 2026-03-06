# Stage 1: Build Stage (Immutable & Optimized)
FROM golang:1.21.3-alpine AS builder


# Install minimal build tools
RUN apk add --no-cache ca-certificates git build-base

WORKDIR /src

# Optimization: Dependency Caching
# Layers are only re-built if go.mod/go.sum changes
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Production Build Flags:
# -ldflags="-s -w": Strips debug info/symbol tables to reduce binary size
# CGO_ENABLED=0: Mandatory for Distroless (creates a static binary)
ARG SKAFFOLD_GO_GCFLAGS
RUN CGO_ENABLED=0 go build \
    -gcflags="${SKAFFOLD_GO_GCFLAGS}" \
    -ldflags="-s -w" \
    -o /shippingservice .

# Stage 2: Hardened Runtime (Distroless)
# Industry Standard: Smallest attack surface (no shell, no apk, no root)
FROM gcr.io/distroless/static-debian12:latest

WORKDIR /app

# Copy binary from builder
COPY --from=builder /shippingservice .

# Environment configuration
ENV GOTRACEBACK=single \
    APP_PORT=50051

# Security: Distroless static images run as non-root (uid 65532) by default
USER 65532:65532

EXPOSE 50051

# Execute the binary directly
ENTRYPOINT ["/app/shippingservice"]
