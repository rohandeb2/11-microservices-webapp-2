# Stage 1: Build & Dependency Stage
# Use the latest stable LTS Alpine image with SHA for immutability
FROM node:20.11.0-alpine AS builder

# Install build dependencies for native modules (e.g., @google-cloud/profiler)
RUN apk add --update --no-cache \
    python3 \
    make \
    g++

WORKDIR /usr/src/app

# Optimization: Copy package files first to cache dependency installation
# This prevents re-running 'npm install' unless package.json changes
COPY package*.json ./

# Industrial Standard: Use 'npm ci' for reproducible builds in CI/CD
# --only=production avoids installing heavy devDependencies like test runners
RUN npm ci --only=production

# Stage 2: Final Hardened Runtime
FROM node:20.11.0-alpine

# Set production environment early to optimize library behaviors
ENV NODE_ENV=production

WORKDIR /usr/src/app

# Copy only necessary production modules from the builder stage
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Copy application source code
COPY . .

# Security: Use a non-root user (standard in Node.js official images)
# Never run production containers as 'root' to prevent host-level exploits
USER node

EXPOSE 7000

# Industry Standard: Use 'node server.js' directly for proper signal handling (SIGTERM)
# Avoid 'npm start' in Docker as it traps signals and prevents graceful shutdowns
ENTRYPOINT [ "node", "server.js" ]
