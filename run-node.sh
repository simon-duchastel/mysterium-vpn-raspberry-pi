#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Change to the script's directory
cd "$(dirname "$0")"

# Check Docker permissions
if ! docker ps > /dev/null 2>&1; then
    echo "Error: Cannot access Docker daemon. This usually means:"
    echo "1. You need to run this script with sudo, OR"
    echo "2. Your user needs to be added to the 'docker' group"
    echo ""
    echo "To add your user to the docker group, run:"
    echo "  sudo usermod -aG docker \$USER"
    echo "  newgrp docker"
    echo ""
    echo "Or run this script with sudo."
    exit 1
fi

# Load environment variables
if [ -f "mysterium.env" ]; then
  set -a
  source "mysterium.env"
  set +a
fi

# Docker variables
CONTAINER_NAME="mysterium-node"
IMAGE_NAME="mysteriumnetwork/myst"

# Stop and remove existing container
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "--- Stopping existing container ---"
    docker stop $CONTAINER_NAME
fi

if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "--- Removing existing container ---"
    docker rm $CONTAINER_NAME
fi

# Check Docker image architecture compatibility
echo "--- Checking Docker image architecture compatibility ---"
if ! docker manifest inspect $IMAGE_NAME > /dev/null 2>&1; then
    echo "Warning: Unable to verify Docker image architecture compatibility"
    echo "The image may not support this platform architecture"
    read -p "Continue anyway? (y/N): " continue_choice
    if [[ ! $continue_choice =~ ^[Yy]$ ]]; then
        echo "Exiting due to architecture compatibility concerns"
        exit 1
    fi
fi

# Pull the latest image
echo "--- Pulling latest Mysterium image ---"
docker pull $IMAGE_NAME

# Start the container
echo "--- Starting Mysterium node ---"
docker run -d --name $CONTAINER_NAME \
  --cap-add NET_ADMIN \
  -p 4449:4449 \
  -v mysterium-node-data:/var/lib/mysterium-node \
  --restart unless-stopped \
  $IMAGE_NAME service --agreed-terms-and-conditions

# Wait for the service to start
sleep 15

# Configure the identity
docker exec $CONTAINER_NAME myst identity register --beneficiary "$MY_WALLET_ADDRESS"

