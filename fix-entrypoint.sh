#!/bin/bash
#
# Script to find and fix the agent-zero entrypoint in the Docker container
# This helps resolve the "exec: /agent-zero-entrypoint: not found" error
# Works with both standard and hacking editions
# Also disables Whisper speech-to-text model for better performance
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

# Function to disable Whisper model
disable_whisper() {
  echo "🔇 Disabling Whisper model..."
  
  # Find and rename any Whisper model directories
  find / -path "*/whisper*" -type d -o -name "*whisper*" 2>/dev/null | 
    xargs -I{} bash -c 'if [ -e "{}" ]; then mv "{}" "{}.disabled" 2>/dev/null || true; echo "  Disabled: {}"; fi' || true
  
  # Create environment variable file to ensure Whisper is disabled
  mkdir -p /etc/agent-zero
  echo "DISABLE_WHISPER=true" > /etc/agent-zero/env.conf
  echo "SKIP_WHISPER_DOWNLOAD=true" >> /etc/agent-zero/env.conf
  echo "A0_DISABLE_SPEECH=true" >> /etc/agent-zero/env.conf
  
  echo "✅ Whisper model disabled successfully"
}

# Try the 'which' command first
if ENTRYPOINT_PATH=$(which agent-zero-entrypoint 2>/dev/null); then
  echo "✅ Found entrypoint using 'which' at: $ENTRYPOINT_PATH"
  cp "$ENTRYPOINT_PATH" /app/agent-zero-entrypoint
  chmod +x /app/agent-zero-entrypoint
  disable_whisper
  exit 0
fi

# Check all possible locations
for LOCATION in "${POSSIBLE_LOCATIONS[@]}"; do
  if check_entrypoint "$LOCATION"; then
    echo "🔄 Copying entrypoint to /app/agent-zero-entrypoint"
    cp "$LOCATION" /app/agent-zero-entrypoint
    chmod +x /app/agent-zero-entrypoint
    disable_whisper
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
  disable_whisper
  exit 0
fi

# Check for the hacking edition's run_ui.py
if [ -f "/a0/run_ui.py" ]; then
  echo "✅ Found hacking edition's run_ui.py"
  cat > /app/agent-zero-entrypoint << 'EOF'
#!/bin/bash
echo "Starting Agent Zero Hacking Edition..."

# Set Whisper model disable flags
export DISABLE_WHISPER=true
export SKIP_WHISPER_DOWNLOAD=true
export A0_DISABLE_SPEECH=true

# Add --no-whisper flag to arguments if not already present
args="$@"
if [[ ! $args == *"--no-whisper"* ]]; then
  args="$args --no-whisper"
fi

# Change to directory and run with proper arguments
cd /a0 && python3 run_ui.py $args
EOF
  chmod +x /app/agent-zero-entrypoint
  disable_whisper
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

# Add --no-whisper flag to arguments if not already present
args="$@"
if [[ ! $args == *"--no-whisper"* ]]; then
  args="$args --no-whisper"
fi

# Try various methods to start Agent Zero
if [ -f "/a0/run_ui.py" ]; then
  echo "Starting with run_ui.py..."
  cd /a0 && python3 run_ui.py $args
elif command -v node > /dev/null && [ -f "/usr/local/bin/agent-zero-run" ]; then
  echo "Starting with Node.js..."
  node /usr/local/bin/agent-zero-run $args
elif command -v npm > /dev/null; then
  echo "Starting with npm..."
  npm start -- $args
else
  echo "ERROR: Could not find any way to start Agent Zero!"
  echo "Please check if the Docker image is correctly installed."
  exit 1
fi
EOF

chmod +x /app/agent-zero-entrypoint
disable_whisper
echo "✅ Created fallback entrypoint at /app/agent-zero-entrypoint"