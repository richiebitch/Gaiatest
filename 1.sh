#!/bin/bash

# Ensure required packages are installed
echo "📦 Installing dependencies..."
sudo apt update -y && sudo apt install -y pciutils libgomp1 curl wget build-essential libglvnd-dev pkg-config libopenblas-dev libomp-dev

# Detect if running inside WSL
IS_WSL=false
if grep -qi microsoft /proc/version; then
    IS_WSL=true
    echo "🖥️ Running inside WSL."
else
    echo "🖥️ Running on a native Ubuntu system."
fi

# Check if an NVIDIA GPU is present
check_nvidia_gpu() {
    if command -v nvidia-smi &> /dev/null || lspci | grep -i nvidia &> /dev/null; then
        echo "✅ NVIDIA GPU detected."
        return 0
    else
        echo "⚠️ No NVIDIA GPU found."
        return 1
    fi
}

# Check if the system is a VPS, Laptop, or Desktop
check_system_type() {
    vps_type=$(systemd-detect-virt)
    if echo "$vps_type" | grep -qiE "kvm|qemu|vmware|xen|lxc"; then
        echo "✅ This is a VPS."
        return 0  # VPS
    elif ls /sys/class/power_supply/ | grep -q "^BAT[0-9]"; then
        echo "✅ This is a Laptop."
        return 1  # Laptop
    else
        echo "✅ This is a Desktop."
        return 2  # Desktop
    fi
}

# Install CUDA Toolkit 12.8
install_cuda() {
    echo "🖥️ Installing CUDA..."
    if $IS_WSL; then
        CUDA_REPO="https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64"
        CUDA_DEB="cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb"
        wget $CUDA_REPO/cuda-wsl-ubuntu.pin
        sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
    else
        CUDA_REPO="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64"
        CUDA_DEB="cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb"
    fi

    wget $CUDA_REPO/$CUDA_DEB && sudo dpkg -i $CUDA_DEB && sudo cp /var/cuda-repo*/cuda-*-keyring.gpg /usr/share/keyrings/
    sudo apt-get update && sudo apt-get -y install cuda-toolkit-12-8 || { echo "❌ CUDA installation failed."; exit 1; }
    echo "✅ CUDA installed successfully."
    setup_cuda_env
}

# Set up CUDA environment variables
setup_cuda_env() {
    echo "🔧 Setting up CUDA environment variables..."
    echo 'export PATH=/usr/local/cuda-12.8/bin${PATH:+:${PATH}}' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc
    source ~/.bashrc
}

# Install GaiaNet with appropriate CUDA support
install_gaianet() {
    if command -v nvcc &> /dev/null; then
        CUDA_VERSION=$(nvcc --version | grep 'release' | awk '{print $6}' | cut -d',' -f1 | sed 's/V//g' | cut -d'.' -f1)
        echo "✅ CUDA version detected: $CUDA_VERSION"
        if [[ "$CUDA_VERSION" == "11" || "$CUDA_VERSION" == "12" ]]; then
            echo "🔧 Installing GaiaNet with ggmlcuda $CUDA_VERSION..."
            curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/download/0.4.20/install.sh' -o install.sh
            chmod +x install.sh
            ./install.sh --ggmlcuda $CUDA_VERSION || { echo "❌ GaiaNet installation with CUDA failed."; exit 1; }
            return
        fi
    fi
    echo "⚠️ Installing GaiaNet without GPU support..."
    curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/download/0.4.20/install.sh' | bash || { echo "❌ GaiaNet installation without GPU failed."; exit 1; }
}

# Add GaiaNet to PATH
add_gaianet_to_path() {
    echo 'export PATH=$HOME/gaianet/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc
}

# Main logic
if check_nvidia_gpu; then
    install_cuda
    install_gaianet
else
    install_gaianet
fi

# Verify GaiaNet installation
if [ -f ~/gaianet/bin/gaianet ]; then
    echo "✅ GaiaNet installed successfully."
    add_gaianet_to_path
else
    echo "❌ GaiaNet installation failed. Exiting."
    exit 1
fi

# Determine system type and set configuration URL
check_system_type
SYSTEM_TYPE=$?  # Capture the return value of check_system_type

if [[ $SYSTEM_TYPE -eq 0 ]]; then
    # VPS
    CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
elif [[ $SYSTEM_TYPE -eq 1 ]]; then
    # Laptop
    if ! check_nvidia_gpu; then
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
    else
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config1.json"
    fi
elif [[ $SYSTEM_TYPE -eq 2 ]]; then
    # Desktop
    if ! check_nvidia_gpu; then
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
    else
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config3.json"
    fi
fi

# Initialize and start GaiaNet
echo "⚙️ Initializing GaiaNet..."
~/gaianet/bin/gaianet init --config "$CONFIG_URL" || { echo "❌ GaiaNet initialization failed!"; exit 1; }

echo "🚀 Starting GaiaNet node..."
~/gaianet/bin/gaianet config --domain gaia.domains
~/gaianet/bin/gaianet start || { echo "❌ Error: Failed to start GaiaNet node!"; exit 1; }

echo "🔍 Fetching GaiaNet node information..."
~/gaianet/bin/gaianet info || { echo "❌ Error: Failed to fetch GaiaNet node information!"; exit 1; }
# Closing message
echo "🎉 Setup and initialization complete! Your GaiaNet node should now be running."
