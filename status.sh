#!/bin/bash

# Docker container name
CONTAINER_NAME="mysterium-node"

# Check if container is running
if [ ! "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Mysterium node container is not running."
    exit 1
fi

echo "--- Node Status ---"
docker exec $CONTAINER_NAME myst status

echo "
--- Node Identity ---"
docker exec $CONTAINER_NAME myst identity show

echo "
--- Earnings ---"
docker exec $CONTAINER_NAME myst earnings
