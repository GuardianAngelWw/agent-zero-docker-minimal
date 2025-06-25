#!/bin/bash
# Debug script to help diagnose Agent Zero startup issues

# Set up error handling
set -e
trap 'echo "Error on line $LINENO"' ERR

echo "Starting Agent Zero debugging script..."

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed or not in PATH"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo "ERROR: Docker daemon is not running"
    exit 1
fi

# Build the container with debug output
echo "Building Agent Zero container with verbose output..."
docker build -t agent-zero-debug --progress=plain .

# Run the container with interactive shell for debugging
echo "Starting container in interactive mode for debugging..."
docker run -it --name agent-zero-debug \
    -p 50001:8080 \
    --entrypoint /bin/sh \
    agent-zero-debug

# Note: The above command will drop you into a shell inside the container
# From there, you can manually run:
#   1. ls -la /app/
#   2. which agent-zero-entrypoint
#   3. find / -name agent-zero-entrypoint -type f 2>/dev/null
#   4. /app/agent-zero-entrypoint

# Cleanup happens automatically when you exit the shell
echo "Container exited. Cleaning up..."
docker rm -f agent-zero-debug 2>/dev/null || true

echo "Debug session completed."