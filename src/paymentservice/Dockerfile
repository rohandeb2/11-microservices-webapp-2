FROM node:20.11.0-alpine AS builder

# Install build dependencies for native modules
RUN apk add --update --no-cache \
    python3 \
    make \
    g++

WORKDIR /usr/src/app

COPY package*.json ./


RUN npm ci --only=production

# Stage 2: Final Hardened Runtime
FROM node:20.11.0-alpine


ENV NODE_ENV=production

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/node_modules ./node_modules

# Copy application source code
COPY . .


USER node

EXPOSE 50051


ENTRYPOINT [ "node", "index.js" ]
