#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Change to the script's directory
cd "$(dirname "$0")"

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
