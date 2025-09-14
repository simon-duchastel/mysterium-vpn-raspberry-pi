# Mysterium VPN Node on Raspberry Pi Plan

This plan outlines the steps to create a secure, profitable, and easy-to-use Mysterium VPN node setup on a Raspberry Pi.

## 1. Project Structure

Create a clear and organized directory structure for the scripts and configurations.

```
/
├───LICENSE
├───README.md
├───plan.md
├───setup.sh
├───run-node.sh
├───status.sh
├───update-blocklist.sh
├───mysterium.env.template
├───mysterium-node.service
└───.gitignore
```

## 2. Create `setup.sh`

This script will be the main entry point for the user. It will perform the following actions:

1.  **Check for root privileges:** Ensure the script is run as root.
2.  **Install dependencies:** Install `docker`, `ufw`, and other necessary tools.
3.  **Create `mysterium.env`:** Copy `mysterium.env.template` to `mysterium.env` and prompt the user for their Mysterium wallet address.
4.  **Set up firewall:** Configure `ufw` to allow SSH, Mysterium traffic, and block other incoming connections.
5.  **Set up blocklist:** Execute `update-blocklist.sh` to apply the initial security blocklist.
6.  **Set up `systemd` service:** Copy `mysterium-node.service` to `/etc/systemd/system/`, enable it, and start it.
7.  **Provide feedback:** Inform the user that the setup is complete and the node is starting.

## 3. Create `run-node.sh`

This script will be responsible for running the Mysterium node Docker container.

1.  **Load environment variables:** Source the `mysterium.env` file.
2.  **Pull the latest image:** Ensure the latest Mysterium node image is being used.
3.  **Start the container:** Run the `mysteriumnetwork/myst` Docker container with the correct parameters, including the wallet address and any other configurations for profitability and security. The container will be named to prevent duplicates.

## 4. Create `status.sh`

This script will provide a simple way for the user to check the status of their node.

1.  **Execute `myst` commands:** Use `docker exec` to run `myst` commands inside the container to get information like:
    *   Node identity
    *   Connection status
    *   Earnings
    *   Session history

## 5. Create `update-blocklist.sh`

This script will download a blocklist and apply it using `iptables`.

1.  **Download blocklist:** Fetch a reputable IP blocklist (e.g., from FireHOL).
2.  **Apply rules:** Use `iptables` to create a new chain and add rules to drop traffic to and from the IPs in the blocklist.
3.  **Make rules persistent:** Ensure the `iptables` rules are reloaded on boot.

## 6. Create Configuration Files

*   **`mysterium.env.template`:** A template file for the user's configuration. It will include a placeholder for the Mysterium wallet address.
*   **`mysterium-node.service`:** A `systemd` service file to manage the `run-node.sh` script, ensuring the node starts on boot and restarts on failure.
*   **`.gitignore`:** Add `mysterium.env` to the `.gitignore` file to prevent the user from accidentally committing their private wallet address.

## 7. Update `README.md`

The `README.md` will be updated to provide clear, step-by-step instructions for the user:

1.  **Prerequisites:** What the user needs before starting (Raspberry Pi, OS, etc.).
2.  **Installation:** How to clone the repo and run the `setup.sh` script.
3.  **Configuration:** How to set their wallet address.
4.  **Usage:** How to check the status of their node using `status.sh`.
5.  **Security:** An explanation of the security measures in place.

## 8. Git Workflow

1.  Create a new branch (e.g., `feature/setup-scripts`).
2.  Add and commit the new files.
3.  Push the branch to the remote repository.
4.  Open a pull request to merge the changes into the main branch.
