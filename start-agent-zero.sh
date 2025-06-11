#!/bin/bash

# Pull the latest image
docker pull frdel/agent-zero-run

# Run the container with port mapping
docker run -p 50001:80 frdel/agent-zero-run