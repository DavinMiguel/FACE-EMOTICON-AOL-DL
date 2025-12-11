# Use a small official Python image
FROM python:3.11-slim

# Set working dir
WORKDIR /app

# Install system deps needed by opencv-headless and general builds
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libgl1 \
  && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python deps
COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copy application code
COPY . /app

# Expose port (Railway will map $PORT)
ENV PORT=5000

# Start with gunicorn (app:app -> backend/app.py must define app)
CMD ["gunicorn", "-w", "1", "-b", "0.0.0.0:5000", "app:app"]
