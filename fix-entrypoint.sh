#!/bin/bash
# This script is used by the Dockerfile to find and copy the agent-zero-entrypoint

# Print the current working directory for debugging
echo "Current working directory: $(pwd)"

# Find the agent-zero-entrypoint in the system
ENTRYPOINT_PATH=$(which agent-zero-entrypoint 2>/dev/null || find / -name agent-zero-entrypoint -type f 2>/dev/null | head -1)

# Check if the entrypoint was found
if [ -z "$ENTRYPOINT_PATH" ]; then
  echo "ERROR: agent-zero-entrypoint not found in the system"
  exit 1
else
  echo "Found agent-zero-entrypoint at: $ENTRYPOINT_PATH"
  # Copy the entrypoint to a known location
  cp "$ENTRYPOINT_PATH" /app/agent-zero-entrypoint
  chmod +x /app/agent-zero-entrypoint
  echo "Successfully copied and made executable: /app/agent-zero-entrypoint"
fi