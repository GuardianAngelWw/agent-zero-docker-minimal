# Makefile for agent-zero-docker-minimal
# Google-style makefile for building and deploying Agent Zero

.PHONY: build run stop clean help deploy

# Variables
IMAGE_NAME := agent-zero-local
CONTAINER_NAME := agentzero
PORT := 50001

# Default target
help:
	@echo "Available targets:"
	@echo "  build       Build the Docker image"
	@echo "  run         Run the container"
	@echo "  stop        Stop the running container"
	@echo "  clean       Remove the container and image"
	@echo "  deploy      Deploy to Kubernetes cluster"
	@echo "  all         Build and run the container"

# Build the Docker image
build:
	@echo "Building Docker image: $(IMAGE_NAME)"
	docker build -t $(IMAGE_NAME) .

# Run the container
run:
	@echo "Starting container: $(CONTAINER_NAME)"
	@if docker ps -a | grep -q $(CONTAINER_NAME); then \
		echo "Stopping and removing existing container: $(CONTAINER_NAME)"; \
		docker stop $(CONTAINER_NAME) >/dev/null 2>&1 || true; \
		docker rm $(CONTAINER_NAME) >/dev/null 2>&1 || true; \
	fi
	docker run -d -p $(PORT):80 --name $(CONTAINER_NAME) --restart unless-stopped --memory="512m" --cpus="1.0" $(IMAGE_NAME)
	@echo "✅ Agent Zero is running at http://localhost:$(PORT)"

# Stop the container
stop:
	@echo "Stopping container: $(CONTAINER_NAME)"
	@if docker ps -a | grep -q $(CONTAINER_NAME); then \
		docker stop $(CONTAINER_NAME); \
	else \
		echo "Container $(CONTAINER_NAME) is not running"; \
	fi

# Remove the container and image
clean: stop
	@echo "Removing container and image"
	@if docker ps -a | grep -q $(CONTAINER_NAME); then \
		docker rm $(CONTAINER_NAME); \
	fi
	@if docker images | grep -q $(IMAGE_NAME); then \
		docker rmi $(IMAGE_NAME); \
	fi

# Deploy to Kubernetes
deploy:
	@echo "Deploying to Kubernetes"
	kubectl apply -f kubernetes/deployment.yaml
	kubectl apply -f kubernetes/service.yaml

# Build and run
all: build run