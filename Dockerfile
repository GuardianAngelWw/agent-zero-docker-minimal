FROM frdel/agent-zero-run:latest

# Metadata labels following Google container standards
LABEL maintainer="GuardianAngelWw"
LABEL version="1.0.0"
LABEL description="Agent Zero Docker container with optimized resource usage"

# Set environment variables to disable resource-intensive features
# A0_DISABLE_WHISPER ensures the Whisper model is not loaded at startup
# Using ARG and ENV pattern for flexibility
ARG DISABLE_WHISPER=true
ARG DISABLE_SEARXNG=true
ENV A0_DISABLE_WHISPER=${DISABLE_WHISPER}
ENV A0_DISABLE_SEARXNG=${DISABLE_SEARXNG}

# Additional environment variables for stability
ENV A0_WHISPER_MODEL=""
ENV A0_SKIP_WHISPER_PRELOAD=true
ENV A0_PRELOAD_DISABLED=true

# Create a configuration to ensure Whisper isn't loaded
RUN mkdir -p /etc/agent-zero/config
RUN echo '{"whisper": {"enabled": false, "preload": false, "model": null}}' > /etc/agent-zero/config/audio.json

# Expose the web interface port
EXPOSE 8080

# Add a healthcheck to monitor container stability
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# Set the entrypoint with environment variables to ensure Whisper is not loaded
ENTRYPOINT ["/bin/bash", "-c", "export A0_DISABLE_WHISPER=true A0_SKIP_WHISPER_PRELOAD=true A0_PRELOAD_DISABLED=true && /entrypoint.sh"]