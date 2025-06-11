# agent-zero-docker-minimal

Minimal repository for building and running frdel/agent-zero-run container.

## Usage

### Option 1: Run the commands directly

```bash
# Pull the latest image
docker pull frdel/agent-zero-run

# Run the container with port mapping
docker run -p 80:80 frdel/agent-zero-run
```

### Option 2: Use the provided script

```bash
# Make the script executable
chmod +x start-agent-zero.sh

# Run the script
./start-agent-zero.sh
```

The service will be available at http://localhost:50001
