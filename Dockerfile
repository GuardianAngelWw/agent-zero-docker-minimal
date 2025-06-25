FROM frdel/agent-zero-run:hacking

# Add labels for better container identification and management
LABEL maintainer="GuardianAngelWw" \
      description="Agent Zero Hacking Edition with Whisper disabled" \
      version="1.0.1"

# Set environment variables for better container configuration
ENV NODE_ENV=production \
    PORT=8080 \
    # Disable Whisper model loading
    DISABLE_WHISPER=true \
    SKIP_WHISPER_DOWNLOAD=true \
    A0_DISABLE_SPEECH=true

# Create a non-root user for better security
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser

# Set the working directory
WORKDIR /app

# Copy our helper script that will find and copy the entrypoint
COPY fix-entrypoint.sh /app/fix-entrypoint.sh
RUN chmod +x /app/fix-entrypoint.sh

# Run the entrypoint fixer script
RUN /app/fix-entrypoint.sh

# Attempt to disable Whisper by renaming any existing model files
RUN find / -path "*/whisper*" -type d -o -name "*whisper*" 2>/dev/null | \
    xargs -I{} bash -c 'if [ -e "{}" ]; then mv "{}" "{}.disabled" 2>/dev/null || true; echo "Disabled: {}"; fi'

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
CMD ["sh", "-c", "echo 'Agent Zero Hacking Edition is running on port 8080 (Whisper disabled)' && exec /app/agent-zero-entrypoint --no-whisper"]