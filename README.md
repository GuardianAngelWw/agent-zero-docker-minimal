# agent-zero-docker-minimal

A repository that builds and runs the Agent Zero Hacking Edition Docker container with proper build-time image pulling and optimized resource usage.

This setup uses the official `frdel/agent-zero-run:hacking` image as the base, which includes Kali Linux and cybersecurity-focused prompts.

## Resource Optimization Features

This repository provides Docker configurations specifically designed to run Agent Zero efficiently under resource constraints:

- **Whisper Model Disabled**: The resource-intensive Whisper speech-to-text model is completely disabled to prevent container crashes
- **Optimized Resource Usage**: Configurations to run with minimal memory and CPU requirements
- **Production-Ready Settings**: Proper health checks and stability improvements

## Setup Options

### Option 1: Direct Build and Run (Recommended)

Use the provided script to both build a local image (which pulls the base image during build) and run it:

```bash
# Make the script executable
chmod +x build-and-run.sh

# Run the build and start script
./build-and-run.sh
```

This will:
1. Build a local image (which pulls the base image during build)
2. Run the container with the name "agentzero" on port 8080

### Option 2: Manual Steps

#### Build the image:

```bash
# This pulls the base image during build
docker build -t agent-zero-local .
```

#### Run the container:

```bash
# Run the container
docker run -p 8080:8080 agent-zero-local
```

## Zeabur Deployment

For deployment on Zeabur, use the `zeabur-dockerfile` which includes optimizations to ensure the container runs properly in that environment:

1. Set up a new service in Zeabur using the `zeabur-dockerfile`
2. Set resource limits appropriately (at least 2GB RAM and 1 vCPU recommended)
3. The container will automatically disable Whisper model loading

## Environment Variables

The following environment variables are preconfigured to disable resource-intensive features:

| Variable | Description |
|----------|-------------|
| A0_DISABLE_WHISPER | Disables the Whisper speech-to-text model |
| A0_DISABLE_SEARXNG | Disables the SearXNG search component |
| A0_SKIP_WHISPER_PRELOAD | Prevents preloading of Whisper models |
| A0_PRELOAD_DISABLED | Disables general preloading operations |

## Accessing the Service

The service will be available at http://localhost:8080

## Stopping and Removing

To stop and remove the container:

```bash
docker stop agentzero
docker rm agentzero
```

## Troubleshooting

If you encounter resource-related errors:

1. Ensure you're using the latest version of this repository with Whisper disabled
2. Check container logs for specific error messages
3. Increase container resource limits if needed
4. Verify all environment variables are correctly set