#!/bin/bash
# disable-whisper.sh
#
# This script helps configure an existing Agent Zero container to disable Whisper model loading.
# It can be run on an existing container or as part of a new container startup.
#
# Usage:
#   ./disable-whisper.sh [container_name]
#
# If container_name is provided, it will update that running container.
# If no container is specified, it will only print the commands to add to your own scripts.

set -e

CONTAINER_NAME=$1

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Agent Zero Whisper Disabler ===${NC}"
echo -e "${YELLOW}This script helps disable the Whisper model to prevent resource-related crashes${NC}"
echo

# Function to create the config directory and files
create_config_files() {
    local target=$1
    
    if [ "$target" == "local" ]; then
        # Creating local config directory
        echo -e "${YELLOW}Creating local configuration...${NC}"
        mkdir -p /etc/agent-zero/config
        echo '{"whisper": {"enabled": false, "preload": false, "model": null}}' > /etc/agent-zero/config/audio.json
        echo -e "${GREEN}✓ Configuration created locally${NC}"
    else
        # Creating config in container
        echo -e "${YELLOW}Creating configuration in container $target...${NC}"
        docker exec $target mkdir -p /etc/agent-zero/config
        docker exec $target bash -c "echo '{\"whisper\": {\"enabled\": false, \"preload\": false, \"model\": null}}' > /etc/agent-zero/config/audio.json"
        echo -e "${GREEN}✓ Configuration created in container${NC}"
    fi
}

# If a container name is provided
if [ ! -z "$CONTAINER_NAME" ]; then
    echo -e "${YELLOW}Checking if container $CONTAINER_NAME exists...${NC}"
    
    if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
        echo -e "${GREEN}✓ Container found${NC}"
        
        # Check if container is running
        if docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
            echo -e "${YELLOW}Container is running. Setting environment variables...${NC}"
            
            # Set environment variables in the running container
            docker exec $CONTAINER_NAME bash -c "export A0_DISABLE_WHISPER=true"
            docker exec $CONTAINER_NAME bash -c "export A0_SKIP_WHISPER_PRELOAD=true"
            docker exec $CONTAINER_NAME bash -c "export A0_PRELOAD_DISABLED=true"
            docker exec $CONTAINER_NAME bash -c "export A0_WHISPER_MODEL=''"
            
            # Create config files in the container
            create_config_files $CONTAINER_NAME
            
            echo -e "${GREEN}✓ Environment variables set in container${NC}"
            echo -e "${YELLOW}Note: These changes will be lost when the container restarts.${NC}"
            echo -e "${YELLOW}To make them permanent, update your Docker run command or Dockerfile.${NC}"
        else
            echo -e "${YELLOW}Container exists but is not running.${NC}"
            echo -e "${YELLOW}Would you like to start it with Whisper disabled? (y/n)${NC}"
            read -p "Start container? " choice
            
            if [[ $choice == "y" || $choice == "Y" ]]; then
                echo -e "${YELLOW}Starting container with Whisper disabled...${NC}"
                docker start $CONTAINER_NAME
                
                # Set environment variables in the running container
                docker exec $CONTAINER_NAME bash -c "export A0_DISABLE_WHISPER=true"
                docker exec $CONTAINER_NAME bash -c "export A0_SKIP_WHISPER_PRELOAD=true"
                docker exec $CONTAINER_NAME bash -c "export A0_PRELOAD_DISABLED=true"
                docker exec $CONTAINER_NAME bash -c "export A0_WHISPER_MODEL=''"
                
                # Create config files in the container
                create_config_files $CONTAINER_NAME
                
                echo -e "${GREEN}✓ Container started with Whisper disabled${NC}"
            else
                echo -e "${YELLOW}Container not started.${NC}"
            fi
        fi
    else
        echo -e "${RED}✗ Container $CONTAINER_NAME not found${NC}"
        echo -e "${YELLOW}Would you like to create a new Docker run command? (y/n)${NC}"
        read -p "Create command? " choice
        
        if [[ $choice == "y" || $choice == "Y" ]]; then
            echo -e "${YELLOW}Creating docker run command with Whisper disabled...${NC}"
            echo
            echo -e "${GREEN}docker run -d --name $CONTAINER_NAME -p 50001:80 \\"
            echo -e "  -e A0_DISABLE_WHISPER=true \\"
            echo -e "  -e A0_SKIP_WHISPER_PRELOAD=true \\"
            echo -e "  -e A0_PRELOAD_DISABLED=true \\"
            echo -e "  -e A0_WHISPER_MODEL=\"\" \\"
            echo -e "  frdel/agent-zero-run:latest${NC}"
            echo
            echo -e "${YELLOW}Run this command to create and start a container with Whisper disabled.${NC}"
        fi
    fi
else
    # No container provided, just print instructions
    echo -e "${YELLOW}No container name provided. Here's how to disable Whisper:${NC}"
    echo
    echo -e "${BLUE}== Docker Run Command ==${NC}"
    echo -e "${GREEN}docker run -d --name agentzero -p 50001:80 \\"
    echo -e "  -e A0_DISABLE_WHISPER=true \\"
    echo -e "  -e A0_SKIP_WHISPER_PRELOAD=true \\"
    echo -e "  -e A0_PRELOAD_DISABLED=true \\"
    echo -e "  -e A0_WHISPER_MODEL=\"\" \\"
    echo -e "  frdel/agent-zero-run:latest${NC}"
    echo
    echo -e "${BLUE}== Dockerfile Environment Variables ==${NC}"
    echo -e "${GREEN}ENV A0_DISABLE_WHISPER=true"
    echo -e "ENV A0_SKIP_WHISPER_PRELOAD=true"
    echo -e "ENV A0_PRELOAD_DISABLED=true"
    echo -e "ENV A0_WHISPER_MODEL=\"\"${NC}"
    echo
    echo -e "${BLUE}== Configuration File ==${NC}"
    echo -e "${GREEN}# Create this file at /etc/agent-zero/config/audio.json"
    echo -e '{\"whisper\": {\"enabled\": false, \"preload\": false, \"model\": null}}'
    echo
    echo -e "${YELLOW}To update a running container, rerun this script with the container name:${NC}"
    echo -e "${GREEN}./disable-whisper.sh my-container-name${NC}"
fi

echo
echo -e "${BLUE}=== Complete ===${NC}"