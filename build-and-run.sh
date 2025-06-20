#!/bin/bash
#
# Build and run script for Agent Zero Docker container
# This script builds the Docker image and runs it with appropriate settings
#

set -e  # Exit immediately if a command exits with a non-zero status

# Define variables for better maintainability
IMAGE_NAME="agent-zero-local"
CONTAINER_NAME="agentzero"
PORT="50001"

# Print status messages
echo "Building Docker image: ${IMAGE_NAME}..."

# Build the image locally (pulls frdel/agent-zero-run during build)
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
  -p ${PORT}:80 \
  --name ${CONTAINER_NAME} \
  --restart unless-stopped \
  --memory="512m" \
  --cpus="1.0" \
  ${IMAGE_NAME}

# Verify container is running
if docker ps | grep -q ${CONTAINER_NAME}; then
  echo "✅ Agent Zero is running at http://localhost:${PORT}"
else
  echo "❌ Failed to start Agent Zero container"
  exit 1
fi

# Output container logs for debugging
echo "Container logs:"
docker logs ${CONTAINER_NAME}