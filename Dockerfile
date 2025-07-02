FROM frdel/agent-zero-run:hacking

# Metadata labels following Google container standards
LABEL maintainer="GuardianAngelWw"
LABEL version="1.0.0"
LABEL description="Agent Zero Hacking Edition with optimized resource usage"

# Set environment variables to disable resource-intensive features
# These must be set early and comprehensively to prevent model loading
ENV A0_DISABLE_WHISPER=true
ENV A0_DISABLE_SEARXNG=true
ENV A0_WHISPER_MODEL=""
ENV A0_SKIP_WHISPER_PRELOAD=true
ENV A0_PRELOAD_DISABLED=true
ENV A0_MEMORY_LIMIT=2048
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Create configuration directory and disable resource-intensive features
RUN mkdir -p /etc/agent-zero/config && \
    echo '{"whisper": {"enabled": false, "preload": false, "model": null}, "searxng": {"enabled": false}}' > /etc/agent-zero/config/audio.json && \
    echo '{"memory_limit": "2GB", "cpu_limit": "1"}' > /etc/agent-zero/config/resources.json

# Expose the correct port (Agent Zero runs on port 80 internally)
EXPOSE 80

# Add a more lenient healthcheck for Zeabur environment
HEALTHCHECK --interval=60s --timeout=30s --start-period=120s --retries=3 \
  CMD curl -f http://localhost/ || wget -q --spider http://localhost/ || exit 1
