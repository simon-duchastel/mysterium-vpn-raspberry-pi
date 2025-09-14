# Mysterium VPN Node on Raspberry Pi

This repository provides a set of scripts to easily and securely run a Mysterium VPN node on a Raspberry Pi.

## Features

- **Easy Setup:** A single script to install, configure, and start the node.
- **Automated:** Runs as a `systemd` service, so it starts on boot.
- **Secure:** Includes a firewall and a network blocklist to prevent abuse.
- **Profitable:** Configured to maximize your earnings.

## Prerequisites

- A Raspberry Pi with a fresh installation of Raspberry Pi OS (or any other Debian-based Linux distribution).
- A Mysterium wallet address.

## Installation

1.  Clone this repository:

    ```bash
    git clone https://github.com/your-username/mysterium-vpn-raspberry-pi.git
    cd mysterium-vpn-raspberry-pi
    ```

2.  Run the setup script:

    ```bash
    sudo ./setup.sh
    ```

    The script will prompt you for your Mysterium wallet address.

## Usage

- **Check Node Status:**

  ```bash
  ./status.sh
  ```

- **Update Blocklist:**

  The blocklist is updated automatically during setup. To update it manually:

  ```bash
  sudo ./update-blocklist.sh
  ```

## Security

This setup includes the following security measures:

- **Firewall:** `ufw` is configured to only allow necessary ports (SSH and Mysterium).
- **Blocklist:** A blocklist from FireHOL is used to block traffic to and from known malicious IPs.

## Disclaimer

Running a VPN exit node carries risks. By using these scripts, you are responsible for the traffic that passes through your node. These scripts are provided as-is, without any warranty.