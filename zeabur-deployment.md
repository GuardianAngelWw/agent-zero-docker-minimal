# Zeabur Deployment Troubleshooting

## Analysis of the Error

Based on the logs provided, the container is starting up properly but then crashing with a "Back-off restarting failed container" error. Here's what's happening:

1. The container successfully pulls the image
2. Supervisord starts and launches several processes:
   - `the_listener`
   - `run_cron`
   - `run_searxng`
   - `run_sshd`
   - `run_tunnel_api`
   - `run_ui`
3. The processes enter the RUNNING state
4. The container tries to load a Whisper model
5. Shortly after, the container crashes and Kubernetes attempts to restart it

## Possible Causes and Solutions

### 1. Resource Limitations

The most likely issue is that the container is running out of resources (memory or CPU) when loading the Whisper model. Agent Zero needs significant resources to run properly.

**Solution:**
- Increase memory allocation in Zeabur (recommended at least 4GB RAM)
- Increase CPU allocation (recommended at least 2 vCPUs)

### 2. Missing Environment Variables

The container might need specific environment variables to function properly.

**Solution:**
Add these environment variables in Zeabur:
```
A0_DISABLE_WHISPER=true  # Try this first to skip Whisper model loading
```

### 3. Port Configuration

Ensure that the correct port is exposed in Zeabur.

**Solution:**
- Make sure port 80 is properly mapped in Zeabur

### 4. Container Termination

The logs show the container is being terminated unexpectedly after loading the Whisper model.

**Solution:**
Try creating a custom Dockerfile for Zeabur that disables unnecessary services:

```dockerfile
FROM frdel/agent-zero-run:latest

# Set environment variables to reduce resource usage
ENV A0_DISABLE_WHISPER=true
ENV A0_DISABLE_SEARXNG=true

# Expose the port
EXPOSE 80
```

## Deployment Instructions for Zeabur

1. In Zeabur, create a new service using the custom Dockerfile above
2. Set resource limits appropriately (4GB RAM, 2 vCPUs recommended)
3. Map port 80 to the external port you want to use
4. Deploy and monitor logs for any specific errors

If the container continues to crash, check the last few lines of logs before the crash to identify the specific failing component.