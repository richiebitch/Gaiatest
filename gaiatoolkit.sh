#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Try: sudo $0"
    exit 1
fi

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -qw "$1"
}

# Fix Google Chrome GPG key issue
wget -qO - https://dl.google.com/linux/linux_signing_key.pub | sudo tee /etc/apt/trusted.gpg.d/google-chrome.asc

# Update package lists
apt update

# Show upgradable packages
apt list --upgradable

# Install required packages only if not already installed
for pkg in sudo curl htop systemd fonts-noto-color-emoji; do
    if ! is_installed "$pkg"; then
        echo "Installing $pkg..."
        apt install -y "$pkg"
    else
        echo "$pkg is already installed, skipping."
    fi
done

# Upgrade packages if any are upgradable
apt list --upgradable | grep -q upgradable && apt upgrade -y

# Download and execute the Gaia installer script
INSTALLER="gaiainstaller.sh"
rm -f "$INSTALLER"
curl -O https://raw.githubusercontent.com/abhiag/Gaiatest/main/gaiainstaller.sh
chmod +x "$INSTALLER"
./"$INSTALLER"
