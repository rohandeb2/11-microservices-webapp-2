# Stage 1: Build Stage
# Industry Standard: Use a specific SHA for immutability
FROM python:3.11.1-slim as builder

WORKDIR /app

# Optimization: Copy requirements first to leverage Docker layer caching
# This ensures 'pip install' is only re-run if requirements.txt changes
COPY requirements.txt .

# --prefix --> Install Python packages into a specific directory instead of the default system location.
RUN pip install --no-cache-dir --prefix="/install" -r requirements.txt

# Stage 2: Final Hardened Runtime
FROM python:3.11.1-slim

# PYTHONUNBUFFERED	prints logs immediately
# PYTHONDONTWRITEBYTECODE	prevents .pyc files
# GEVENT_SUPPORT	enables async gevent support in the app
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    GEVENT_SUPPORT=True

WORKDIR /app

# Copy only the installed packages from the builder stage
COPY --from=builder /install /usr/local

# Add application code
COPY locustfile.py .

# groupadd	command to create a group
# -g 10001	sets the group ID
# appgroup	name of the group

# useradd	create a new user
# -u 10001	user ID
# -g appgroup	primary group
# appuser	username
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup appuser

USER 10001

ENTRYPOINT ["locust", "--headless"]
