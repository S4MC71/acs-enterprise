#!/bin/bash
# One-Click Deployment Script for Vultr / Ubuntu instances
# This script installs Docker, Git, clones the repo, and runs the lab launcher.

echo "============================================================"
echo "    NEXUS ENTERPRISE LAB - ONE-CLICK DEPLOYMENT SCRIPT      "
echo "============================================================"
echo ""

# Exit immediately if a command exits with a non-zero status
set -e

# Update packages and install git
echo "[*] Updating system packages & installing git..."
sudo apt-get update -y && sudo apt-get install git -y

# Install Docker if not present
if ! command -v docker &> /dev/null
then
    echo "[*] Installing Docker Engine..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
else
    echo "[*] Docker is already installed. Skipping..."
fi

REPO_DIR="acs-enterprise"

# Clone or update the repository
if [ ! -d "$REPO_DIR" ]; then
    echo "[*] Cloning the lab repository..."
    git clone https://github.com/S4MC71/acs-enterprise.git
else
    echo "[*] Repository already exists. Pulling latest updates..."
    cd "$REPO_DIR"
    git pull
    cd ..
fi

# Set permissions and start the lab
echo "[*] Setting executable permissions for lab scripts..."
cd "$REPO_DIR/lab"
chmod +x scripts/*.sh

echo "[*] Launching the Lab Profile Menu..."
# Need to use 'newgrp' to apply the docker group immediately if docker was just installed,
# otherwise 'docker compose' might fail with permission denied.
# However, if docker was already there, standard exec is fine.
if groups $USER | grep -q '\bdocker\b'; then
    ./scripts/start-lab.sh
else
    # Launch sub-shell with newgrp
    sg docker -c "./scripts/start-lab.sh"
fi
