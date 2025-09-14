#!/bin/bash

# Docker container name
CONTAINER_NAME="mysterium-node"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Check if container is running
if [ ! "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Mysterium node container is not running."
    exit 1
fi

echo "--- Node ConnectionStatus ---"
docker exec $CONTAINER_NAME myst connection info

echo "
--- Node Identity ---"
docker exec $CONTAINER_NAME myst identities get
