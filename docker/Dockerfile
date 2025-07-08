# # Stage 1: Build
# FROM python:3.11-slim as builder

# WORKDIR /app
# COPY requirements.txt .
# RUN pip install --user --no-cache-dir -r requirements.txt

# # Stage 2: Minimal, non-root image
# FROM python:3.11-slim

# RUN useradd -m -u 1000 appuser

# USER appuser

# WORKDIR /home/appuser/app

# COPY --chown=appuser:appuser --from=builder /root/.local /home/appuser/.local
# COPY --chown=appuser:appuser app/ .

# ENV PATH=/home/appuser/.local/bin:$PATH

# EXPOSE 8080

# CMD ["python3", "main.py"]


# Metrics Docker

# Base image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy application code
COPY app/main.py /app/

# Install dependencies
RUN pip install --no-cache-dir flask prometheus_client

# Expose the port your app runs on
EXPOSE 8000

# Command to run your app
CMD ["python", "main.py"]
