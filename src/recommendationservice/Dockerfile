# Stage 1: Build Stage
FROM python:3.10.8-slim as builder

# Install build-essential tools only in the builder stage
RUN apt-get -qq update \
    && apt-get install -y --no-install-recommends \
        wget g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Optimization: Copy requirements first to leverage Docker layer caching
COPY requirements.txt .

# Install dependencies to a specific prefix to keep the final image clean
RUN pip install --no-cache-dir --prefix="/install" -r requirements.txt

# Stage 2: Final Hardened Runtime
FROM python:3.10.8-slim

# Industry Standard: Unbuffered logging and clean bytecode
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8080

WORKDIR /app

# Copy only the installed packages from the builder stage
# Using --from=builder /install is cleaner than copying specific site-package paths
COPY --from=builder /install /usr/local

# Add application code
COPY . .

# Security: Create a dedicated non-root user
# Production EKS clusters should never run containers as root
# Create a system group and user
RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 --gid 1001 appuser

# Switch to the new user
USER 1001

EXPOSE 8080

# Use the full path for the Entrypoint
ENTRYPOINT ["python", "recommendation_server.py"]
