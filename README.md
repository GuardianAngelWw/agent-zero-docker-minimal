# agent-zero-docker-minimal

A repository that builds and runs the Agent Zero Docker container with proper build-time image pulling.

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
2. Run the container with the name "agentzero" on port 50001

### Option 2: Manual Steps

#### Build the image:

```bash
# This pulls the base image during build
docker build -t agent-zero-local .
```

#### Run the container:

```bash
# Run the container
docker run -p 50001:80 agent-zero-local
```

## Accessing the Service

The service will be available at http://localhost:50001

## Stopping and Removing

To stop and remove the container:

```bash
docker stop agentzero
docker rm agentzero
```