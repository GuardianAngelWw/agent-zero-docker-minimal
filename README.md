# agent-zero-docker-minimal

A repository that builds and runs the Agent Zero Docker container with proper build-time image pulling and Kubernetes deployment support.

## Features

- Secure container configuration with non-root user
- Health checks for better monitoring
- Resource limits for stability
- Kubernetes configurations with proper node affinity and tolerations
- Google-style code for better maintainability

## Recent Fixes in the `fixed-dockerfile` Branch

The following issues have been fixed in this branch:

1. **Fixed Entrypoint Not Found Error**: Resolved the `exec: /agent-zero-entrypoint: not found` error by implementing a robust entrypoint detection and copying mechanism.
   
2. **Improved CMD Syntax**: Fixed the syntax error in the CMD directive that was causing the container to fail.

3. **Added Fallback Mechanism**: If the entrypoint cannot be found in the standard locations, a fallback script is created that attempts to start Agent Zero using alternative methods.

4. **Enhanced Error Logging**: Added better error logging to troubleshoot startup issues.

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
2. Stop and remove any existing container with the same name
3. Run the container with the name "agentzero" on port 50001
4. Apply resource limits for better stability

### Option 2: Manual Steps

#### Build the image:

```bash
# This pulls the base image during build
docker build -t agent-zero-local .
```

#### Run the container:

```bash
# Run the container
docker run -d -p 50001:80 --name agentzero --restart unless-stopped agent-zero-local
```

## Kubernetes Deployment

To deploy in a Kubernetes cluster:

```bash
# Apply the Kubernetes manifests
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/service.yaml
```

## Accessing the Service

The service will be available at http://localhost:50001

## Stopping and Removing

To stop and remove the container:

```bash
docker stop agentzero
docker rm agentzero
```

## Security Features

- Non-root user execution
- Resource limits
- Container isolation
- Health checks for better reliability

## Troubleshooting

If you encounter issues with the container not starting properly:

1. Check container logs: `docker logs agentzero`
2. Verify the entrypoint is accessible: `docker exec -it agentzero ls -la /app/agent-zero-entrypoint`
3. Check if the base image has changed: `docker pull frdel/agent-zero-run:latest` and rebuild