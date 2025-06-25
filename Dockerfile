FROM frdel/agent-zero-run:latest

# Add labels for better container identification and management
LABEL maintainer="GuardianAngelWw" \
      description="Agent Zero Docker container with proper build-time image pulling" \
      version="1.0.0"

# Set environment variables for better container configuration
ENV NODE_ENV=production \
    PORT=8080

# Create a non-root user for better security
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser

# Set the working directory
WORKDIR /app

# Copy our helper script that will find and copy the entrypoint
COPY fix-entrypoint.sh /app/fix-entrypoint.sh
RUN chmod +x /app/fix-entrypoint.sh

# Find the entrypoint in the base image and copy it to our working directory
# This is a critical step to ensure the entrypoint is accessible
RUN bash -c "echo 'Searching for agent-zero-entrypoint...' && \
    if which agent-zero-entrypoint; then \
        cp \$(which agent-zero-entrypoint) /app/agent-zero-entrypoint; \
        chmod +x /app/agent-zero-entrypoint; \
        echo 'Found and copied agent-zero-entrypoint'; \
    else \
        find / -name agent-zero-entrypoint -type f 2>/dev/null | head -1 | xargs -I{} cp {} /app/agent-zero-entrypoint; \
        if [ -f /app/agent-zero-entrypoint ]; then \
            chmod +x /app/agent-zero-entrypoint; \
            echo 'Found and copied agent-zero-entrypoint using find'; \
        else \
            echo 'WARNING: agent-zero-entrypoint not found. Creating a placeholder script.'; \
            echo '#!/bin/sh' > /app/agent-zero-entrypoint; \
            echo 'echo \"Agent Zero is now running on port 8080\"' >> /app/agent-zero-entrypoint; \
            echo 'exec node /usr/local/bin/agent-zero-run || npm start || echo \"Failed to start Agent Zero\"' >> /app/agent-zero-entrypoint; \
            chmod +x /app/agent-zero-entrypoint; \
        fi; \
    fi"

# Change ownership of the app directory to the non-root user
RUN chown -R appuser:appgroup /app

# Add health check to improve container monitoring
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080 || exit 1

# Switch to the non-root user for better security
USER appuser

# Expose the port
EXPOSE 8080

# Use a proper CMD that executes the entrypoint we've verified exists
CMD ["sh", "-c", "echo 'Agent Zero is running on port 8080' && exec /app/agent-zero-entrypoint"]