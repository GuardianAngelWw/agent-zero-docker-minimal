#!/bin/bash

# Pull the latest hacking image
docker pull frdel/agent-zero-run:hacking

# Run the container with port mapping and disable Whisper
docker run -p 8080:8080 \
  -e DISABLE_WHISPER=true \
  -e SKIP_WHISPER_DOWNLOAD=true \
  -e A0_DISABLE_SPEECH=true \
  frdel/agent-zero-run:hacking --no-whisper