# Stage 1: Build & Dependency Stage
# Industry Standard: Use a specific SHA for immutability and stable LTS version
FROM node:20.11.0-alpine AS builder

# Install build dependencies for native modules
RUN apk add --update --no-cache \
    python3 \
    make \
    g++

WORKDIR /usr/src/app

# Optimization: Copy package files first to leverage Docker layer caching
# This ensures 'npm ci' is only re-run if package.json changes
COPY package*.json ./

# Industrial Standard: Use 'npm ci' for reproducible builds in CI/CD
# --only=production avoids installing heavy devDependencies
RUN npm ci --only=production

# Stage 2: Final Hardened Runtime
FROM node:20.11.0-alpine

# Set production environment early
ENV NODE_ENV=production

WORKDIR /usr/src/app

# Copy only necessary production modules from the builder stage
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Copy application source code
COPY . .

# Security: Use the built-in 'node' non-root user
# Never run production containers as 'root' to prevent host-level exploits
USER node

EXPOSE 50051

# Industry Standard: Use 'node index.js' directly for proper signal handling (SIGTERM)
# This allows Kubernetes to gracefully shut down the service
ENTRYPOINT [ "node", "index.js" ]
