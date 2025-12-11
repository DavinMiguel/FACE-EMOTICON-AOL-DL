# backend/Dockerfile
FROM python:3.11-slim

# Metadata
LABEL maintainer="you@example.com"

# Set working directory
WORKDIR /app

# Ensure utf-8, unbuffered stdout/stderr
ENV PYTHONUNBUFFERED=1
ENV PORT=5000

# Install system packages required by opencv-headless and build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    wget \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libgl1 \
  && rm -rf /var/lib/apt/lists/*

# Copy only requirements first to leverage Docker cache
COPY requirements.txt /app/requirements.txt

# Install Python dependencies
RUN pip install --upgrade pip \
 && pip install --no-cache-dir -r /app/requirements.txt

# Copy application code
COPY . /app

# Expose port (conventional; Railway will provide $PORT at runtime)
EXPOSE 5000

# Use shell form so $PORT expands at runtime (Railway sets PORT env var)
CMD ["sh", "-c", "gunicorn -w 1 -b 0.0.0.0:${PORT:-5000} app:app"]
