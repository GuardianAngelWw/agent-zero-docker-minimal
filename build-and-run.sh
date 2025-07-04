#!/bin/bash

# Build the image locally (pulls frdel/agent-zero-run during build)
docker build -t agent-zero-local .

# Run the container with port mapping
docker run -d -p 50001:8080 --name agentzero agent-zero-local

echo "Agent Zero is running at http://localhost:50001"