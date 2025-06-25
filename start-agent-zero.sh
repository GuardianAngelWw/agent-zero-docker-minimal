#!/bin/bash

# Pull the latest image
docker pull frdel/agent-zero-run

# Run the container with port mapping
docker run -p 8080:8080 frdel/agent-zero-run