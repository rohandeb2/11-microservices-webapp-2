#This stage is used to install dependencies.
FROM python:3.10.8-slim as builder

#Some Python packages need to compile native code during installation.
# removes package lists to reduce image size.
RUN apt-get -qq update && apt-get install -y --no-install-recommends wget g++ && rm -rf /var/lib/apt/lists/*

WORKDIR /app

#This file lists Python dependencies.
COPY requirements.txt .

# Install to a local folder to make copying to the final stage cleaner
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# We start a fresh Python runtime image.It does not contain build tools.
FROM python:3.10.8-slim

# PYTHONUNBUFFERED : logs are written immediately,
# PYTHONDONTWRITEBYTECODE Prevents creation of .pyc files. Benefits: cleaner container filesystem less disk usage
# ENABLE_PROFILER : This is used for performance profiling tools.
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    ENABLE_PROFILER=1

WORKDIR /app

# This copies Python packages from the builder stage into the final container.
COPY --from=builder /install /usr/local

# Copy application source code
COPY . .

RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 --gid 1001 appuser

# Switch to the new user
USER 1001

EXPOSE 8080

ENTRYPOINT [ "python", "email_server.py" ]
