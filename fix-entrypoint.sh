#!/bin/bash
#
# Script to find and fix the agent-zero entrypoint in the Docker container
# This helps resolve the "exec: /agent-zero-entrypoint: not found" error
# Works with both standard and hacking editions
#

set -e

echo "🔍 Searching for Agent Zero entrypoint..."

# Define possible entrypoint locations
POSSIBLE_LOCATIONS=(
  "/usr/local/bin/agent-zero-entrypoint"
  "/usr/bin/agent-zero-entrypoint"
  "/bin/agent-zero-entrypoint"
  "/a0/run_ui.py"
  "/opt/agent-zero/agent-zero-entrypoint"
)

# Function to check if entrypoint exists and is executable
check_entrypoint() {
  if [ -f "$1" ]; then
    echo "✅ Found valid entrypoint at: $1"
    return 0
  fi
  return 1
}

# Try the 'which' command first
if ENTRYPOINT_PATH=$(which agent-zero-entrypoint 2>/dev/null); then
  echo "✅ Found entrypoint using 'which' at: $ENTRYPOINT_PATH"
  cp "$ENTRYPOINT_PATH" /app/agent-zero-entrypoint
  chmod +x /app/agent-zero-entrypoint
  exit 0
fi

# Check all possible locations
for LOCATION in "${POSSIBLE_LOCATIONS[@]}"; do
  if check_entrypoint "$LOCATION"; then
    echo "📋 Copying entrypoint to /app/agent-zero-entrypoint"
    cp "$LOCATION" /app/agent-zero-entrypoint
    chmod +x /app/agent-zero-entrypoint
    exit 0
  fi
done

# If we get here, search the entire filesystem
echo "🔍 Searching entire filesystem for agent-zero-entrypoint..."
FOUND_PATH=$(find / -name agent-zero-entrypoint -type f 2>/dev/null | head -1)

if [ -n "$FOUND_PATH" ]; then
  echo "✅ Found entrypoint using 'find' at: $FOUND_PATH"
  cp "$FOUND_PATH" /app/agent-zero-entrypoint
  chmod +x /app/agent-zero-entrypoint
  exit 0
fi

# Check for the hacking edition's run_ui.py
if [ -f "/a0/run_ui.py" ]; then
  echo "✅ Found hacking edition's run_ui.py"
  echo '#!/bin/bash' > /app/agent-zero-entrypoint
  echo 'echo "Starting Agent Zero Hacking Edition..."' >> /app/agent-zero-entrypoint
  echo 'export DISABLE_WHISPER=true' >> /app/agent-zero-entrypoint
  echo 'export SKIP_WHISPER_DOWNLOAD=true' >> /app/agent-zero-entrypoint
  echo 'export A0_DISABLE_SPEECH=true' >> /app/agent-zero-entrypoint
  echo 'cd /a0 && python3 run_ui.py --no-whisper "$@"' >> /app/agent-zero-entrypoint
  chmod +x /app/agent-zero-entrypoint
  exit 0
fi

# Last resort: create a fallback entrypoint
echo "⚠️ No entrypoint found. Creating fallback script..."
cat > /app/agent-zero-entrypoint << 'EOF'
#!/bin/bash
echo "Agent Zero Hacking Edition fallback entrypoint"

# Disable Whisper model
export DISABLE_WHISPER=true
export SKIP_WHISPER_DOWNLOAD=true
export A0_DISABLE_SPEECH=true

# Try various methods to start Agent Zero
if [ -f "/a0/run_ui.py" ]; then
  echo "Starting with run_ui.py..."
  cd /a0 && python3 run_ui.py --no-whisper "$@"
elif command -v node > /dev/null && [ -f "/usr/local/bin/agent-zero-run" ]; then
  echo "Starting with Node.js..."
  node /usr/local/bin/agent-zero-run
elif command -v npm > /dev/null; then
  echo "Starting with npm..."
  npm start
else
  echo "ERROR: Could not find any way to start Agent Zero!"
  echo "Please check if the Docker image is correctly installed."
  exit 1
fi
EOF

chmod +x /app/agent-zero-entrypoint
echo "✅ Created fallback entrypoint at /app/agent-zero-entrypoint"