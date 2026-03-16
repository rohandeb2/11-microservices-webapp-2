#This stage is only used to install dependencies and build native modules.
FROM node:20.11.0-alpine AS builder

# Install build dependencies for native modules 
RUN apk add --update --no-cache python3 make g++

WORKDIR /usr/src/app

# These files define Node dependencies.
COPY package*.json ./

# installs exact versions from package-lock.json and 
# --only=production  This avoids installing dev dependencies like:
RUN npm ci --only=production
#run npm install --> installs dependencies normally

# Stage 2: Final Hardened Runtime
FROM node:20.11.0-alpine

#This tells Node libraries: run in production mode
ENV NODE_ENV=production

WORKDIR /usr/src/app

# Copy only necessary production modules from the builder stage
COPY --from=builder /usr/src/app/node_modules ./node_modules

# Copy application source code
COPY . .

#Node official images already include a user named: node with UID 1000
USER node

EXPOSE 7000

ENTRYPOINT [ "node", "server.js" ]
