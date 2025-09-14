#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Variables
MYSTERIUM_ENV_FILE="mysterium.env"
MYSTERIUM_ENV_TEMPLATE="mysterium.env.template"
SYSTEMD_SERVICE_FILE="mysterium-node.service"
REPO_DIR=$(pwd)

# --- Dependency Installation ---
echo "--- Installing dependencies ---"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io ufw curl ipset

# --- Docker Service Setup ---
echo "--- Starting Docker service ---"
systemctl enable docker
systemctl start docker

# --- Configuration ---
echo "--- Configuring Mysterium Node ---"
if [ ! -f "$MYSTERIUM_ENV_FILE" ]; then
  cp "$MYSTERIUM_ENV_TEMPLATE" "$MYSTERIUM_ENV_FILE"
  while true; do
    read -p "Enter your Mysterium wallet address: " wallet_address
    # Basic Ethereum address validation (0x followed by 40 hex characters)
    if [[ $wallet_address =~ ^0x[a-fA-F0-9]{40}$ ]]; then
      break
    else
      echo "Invalid wallet address format. Please enter a valid Ethereum address (0x followed by 40 hex characters)."
    fi
  done
  sed -i "s/MY_WALLET_ADDRESS=.*/MY_WALLET_ADDRESS=$wallet_address/" "$MYSTERIUM_ENV_FILE"
fi

# --- Security Blocklist ---
echo "--- Applying security blocklist ---"
chmod +x update-blocklist.sh
./update-blocklist.sh

# --- Firewall Setup ---
echo "--- Configuring firewall ---"
ufw allow 22/tcp   # SSH
ufw allow 4449/tcp # Mysterium
ufw default deny incoming
ufw default allow outgoing
ufw --force enable

# --- Systemd Service Setup ---
echo "--- Setting up systemd service ---"
cp "$SYSTEMD_SERVICE_FILE" "/etc/systemd/system/"
sed -i "s|REPO_DIR|${REPO_DIR}|g" "/etc/systemd/system/${SYSTEMD_SERVICE_FILE}"
systemctl daemon-reload
systemctl enable "$SYSTEMD_SERVICE_FILE"
systemctl start "$SYSTEMD_SERVICE_FILE"

echo "--- Setup complete! ---"
echo "Your Mysterium node is starting."
echo "You can check its status with: ./status.sh"
