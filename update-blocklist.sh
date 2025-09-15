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
UFW_BEFORE_RULES="/etc/ufw/before.rules"

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

# --- UFW Rules ---
echo "--- Applying UFW rules ---"

# Rules to be added
RULE_INPUT="-A ufw-before-input -m set --match-set ${IPSET_NAME} src -j DROP"
RULE_FORWARD="-A ufw-before-forward -m set --match-set ${IPSET_NAME} src -j DROP"

# Check if rules already exist
if ! grep -Fq "${RULE_INPUT}" "${UFW_BEFORE_RULES}"; then
  sed -i "/^COMMIT/i ${RULE_INPUT}" "${UFW_BEFORE_RULES}"
fi

if ! grep -Fq "${RULE_FORWARD}" "${UFW_BEFORE_RULES}"; then
  sed -i "/^COMMIT/i ${RULE_FORWARD}" "${UFW_BEFORE_RULES}"
fi



echo "--- Blocklist update complete ---"
