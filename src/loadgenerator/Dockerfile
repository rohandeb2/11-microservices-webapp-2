# Stage 1: Build Stage
# Industry Standard: Use a specific SHA for immutability
FROM python:3.11.1-slim as builder

WORKDIR /app

# Optimization: Copy requirements first to leverage Docker layer caching
# This ensures 'pip install' is only re-run if requirements.txt changes
COPY requirements.txt .

# Install dependencies to a prefix to keep the final image clean
RUN pip install --no-cache-dir --prefix="/install" -r requirements.txt

# Stage 2: Final Hardened Runtime
FROM python:3.11.1-slim

# Industry Standard: Enable unbuffered logging for better observability in EKS/CloudWatch
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    GEVENT_SUPPORT=True

WORKDIR /app

# Copy only the installed packages from the builder stage
COPY --from=builder /install /usr/local

# Add application code
COPY locustfile.py .

# Security: Create and use a dedicated non-root user
# This is a critical requirement for production-grade security audits
# Create a system group and user
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup appuser

USER 10001

# Industry Standard: Use exec-form ENTRYPOINT for proper signal handling (SIGTERM)
# This allows the container to shut down gracefully in Kubernetes
ENTRYPOINT ["locust", "--headless"]
