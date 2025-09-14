#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Variables
BLOCKLIST_URL="https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset"
BLOCKLIST_FILE="firehol_level1.netset"
IPSET_NAME="firehol_level1"

# --- Download Blocklist ---
echo "--- Downloading blocklist ---"
curl -o "$BLOCKLIST_FILE" "$BLOCKLIST_URL"

# --- IPSet Setup ---
echo "--- Creating ipset ---"
ipset create "$IPSET_NAME" hash:net -exist
ipset flush "$IPSET_NAME"

while read -r line; do
  # Ignore comments and empty lines
  if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]]; then
    continue
  fi
  ipset add "$IPSET_NAME" "$line"
done < "$BLOCKLIST_FILE"

# --- IPTables Rules ---
echo "--- Applying iptables rules ---"

# Add new rules if they don't exist
if ! iptables -C FORWARD -m set --match-set "$IPSET_NAME" dst -j DROP 2>/dev/null; then
    iptables -I FORWARD -m set --match-set "$IPSET_NAME" dst -j DROP
fi

if ! iptables -C INPUT -m set --match-set "$IPSET_NAME" dst -j DROP 2>/dev/null; then
    iptables -I INPUT -m set --match-set "$IPSET_NAME" dst -j DROP
fi

# --- Persist Rules ---
echo "--- Making rules persistent ---"
apt-get install -y iptables-persistent
debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v4 boolean true"
debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v6 boolean true"
/usr/sbin/netfilter-persistent save

echo "--- Blocklist update complete ---"