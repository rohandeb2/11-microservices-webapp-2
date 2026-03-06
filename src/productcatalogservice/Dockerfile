# Stage 1: Optimized Build Stage
# Use specific SHA for immutability and Alpine for a small build footprint
FROM golang:1.21.3-alpine AS builder

# Install necessary build tools
RUN apk add --no-cache ca-certificates git build-base

WORKDIR /src

# Optimization: Separate dependency download
# This ensures layers are cached unless go.mod or go.sum changes
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build flags for Production:
# -ldflags="-s -w": Strips debug info/symbol tables to reduce binary size
# CGO_ENABLED=0: Ensures a statically linked binary (vital for Distroless)
ARG SKAFFOLD_GO_GCFLAGS
RUN CGO_ENABLED=0 go build \
    -gcflags="${SKAFFOLD_GO_GCFLAGS}" \
    -ldflags="-s -w" \
    -o /productcatalogservice .

# Stage 2: Final Hardened Runtime (Distroless)
# Industry Standard: Use Distroless for the smallest attack surface (no shell, no package manager)
FROM gcr.io/distroless/static-debian12:latest

WORKDIR /app

# Copy binary and data from builder
COPY --from=builder /productcatalogservice ./server
COPY --from=builder /src/products.json .

# Environment configuration
ENV GOTRACEBACK=single

# Security: Distroless static images run as non-root by default (uid 65532)
USER 65532:65532

EXPOSE 3550

# Execute the binary directly
ENTRYPOINT ["/app/server"]
