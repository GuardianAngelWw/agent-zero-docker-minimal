FROM frdel/agent-zero-run:latest

# Add labels for better container identification and management
LABEL maintainer="GuardianAngelWw" \
      description="Agent Zero Docker container with proper build-time image pulling" \
      version="1.0.0"

# Add health check to improve container monitoring
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80 || exit 1

# Set environment variables for better container configuration
ENV NODE_ENV=production \
    PORT=80

# Create a non-root user for better security
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser

# Set the working directory
WORKDIR /app

# Copy the entrypoint script from the base image to ensure it's accessible
# This ensures we can find the entrypoint script in the right location
RUN cp $(which agent-zero-entrypoint) /app/agent-zero-entrypoint || echo "Entrypoint not found at expected location"

# Make the entrypoint script executable
RUN chmod +x /app/agent-zero-entrypoint || echo "Could not make entrypoint executable"

# Change ownership of the app directory to the non-root user
RUN chown -R appuser:appgroup /app

# Switch to the non-root user for better security
USER appuser

# Expose the port
EXPOSE 80

# Use a more specific CMD with proper shell form that executes the entrypoint in the correct location
CMD ["sh", "-c", "echo 'Agent Zero is running on port 80' && exec /app/agent-zero-entrypoint"]