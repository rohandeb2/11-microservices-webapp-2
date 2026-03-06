# Stage 1: Build Stage
# Use a specific SHA for immutability and a slightly heavier image for compilation
FROM python:3.10.8-slim as builder

RUN apt-get -qq update \
    && apt-get install -y --no-install-recommends \
        wget g++ \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Optimization: Copy only requirements first to leverage Docker layer caching
# This ensures 'pip install' is only re-run if requirements.txt changes
COPY requirements.txt .
# Install to a local folder to make copying to the final stage cleaner
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Final Hardened Runtime
FROM python:3.10.8-slim

# Industry Standard: Enable unbuffered logging for better log aggregation (Promtail/Fluentd)
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    ENABLE_PROFILER=1

WORKDIR /app

# Copy only the installed packages from the builder stage
COPY --from=builder /install /usr/local

# Copy application source code
COPY . .

# Security: Create a dedicated non-root user
# Running as 'root' in EKS is a major security finding in MNC audits
# Create a system group and user
RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 --gid 1001 appuser

# Switch to the new user
USER 1001

EXPOSE 8080

# Use the full path for the Entrypoint and ensure signals are handled correctly
ENTRYPOINT [ "python", "email_server.py" ]
