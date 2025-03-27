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
if ! test -f /etc/apt/trusted.gpg.d/google-chrome.asc; then
    echo "Adding Google Chrome GPG key..."
    wget -qO - https://dl.google.com/linux/linux_signing_key.pub | sudo tee /etc/apt/trusted.gpg.d/google-chrome.asc
else
    echo "Google Chrome GPG key already exists, skipping."
fi

# Update package lists
echo "Updating package list..."
apt update -q

# Show upgradable packages
echo "Checking for upgradable packages..."
UPGRADABLE=$(apt list --upgradable 2>/dev/null | grep -v "Listing..." || true)

if [ -z "$UPGRADABLE" ]; then
    echo "All packages are up to date. Skipping upgrade."
else
    echo "Upgradable packages found:"
    echo "$UPGRADABLE"
    echo "Upgrading packages..."
    apt upgrade -y
fi

# Install required packages only if not already installed
REQUIRED_PACKAGES=(nvtop sudo curl htop systemd fonts-noto-color-emoji)
ALL_INSTALLED=true

for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! is_installed "$pkg"; then
        echo "Installing $pkg..."
        apt install -y "$pkg"
        ALL_INSTALLED=false
    else
        echo "$pkg is already installed, skipping."
    fi
done

if $ALL_INSTALLED; then
    echo "All required packages are already installed. Skipping installation."
fi

# Download and execute the Gaia installer script
INSTALLER="gaiainstaller.sh"

if [ -f "$INSTALLER" ]; then
    echo "Gaia installer script already exists, removing old version..."
    rm -f "$INSTALLER"
fi

echo "Downloading latest Gaia installer script..."
curl -O https://raw.githubusercontent.com/richiebitch/Gaiatest/main/gaiainstaller.sh
chmod +x "$INSTALLER"
./"$INSTALLER"
