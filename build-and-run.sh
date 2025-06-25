#!/bin/bash
#
# Build and run script for Agent Zero Hacker Docker container
# This script builds the Docker image and runs it with appropriate settings
#

set -e  # Exit immediately if a command exits with a non-zero status

# Define variables for better maintainability
IMAGE_NAME="agent-zero-hacker-local"
CONTAINER_NAME="agentzero-hacker"
PORT="50001"

# Print status messages
echo "Building Docker image: ${IMAGE_NAME}..."

# Build the image locally (pulls frdel/agent-zero-run:hacking during build)
docker build -t ${IMAGE_NAME} .

# Stop and remove any existing container with the same name
if docker ps -a | grep -q ${CONTAINER_NAME}; then
  echo "Stopping and removing existing container: ${CONTAINER_NAME}..."
  docker stop ${CONTAINER_NAME} >/dev/null 2>&1 || true
  docker rm ${CONTAINER_NAME} >/dev/null 2>&1 || true
fi

# Run the container with port mapping and resource limits
echo "Starting container: ${CONTAINER_NAME}..."
docker run -d \
  -p ${PORT}:8080 \
  --name ${CONTAINER_NAME} \
  --restart unless-stopped \
  --memory="512m" \
  --cpus="1.0" \
  -e DISABLE_WHISPER=true \
  -e SKIP_WHISPER_DOWNLOAD=true \
  -e A0_DISABLE_SPEECH=true \
  ${IMAGE_NAME} --no-whisper

# Verify container is running
if docker ps | grep -q ${CONTAINER_NAME}; then
  echo "✅ Agent Zero Hacking Edition is running at http://localhost:${PORT}"
else
  echo "❌ Failed to start Agent Zero container"
  exit 1
fi

# Output container logs for debugging
echo "Container logs:"
docker logs ${CONTAINER_NAME}