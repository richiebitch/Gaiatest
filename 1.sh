#!/bin/bash

# Ensure required packages are installed
echo "📦 Installing dependencies..."
sudo apt update -y && sudo apt install -y pciutils libgomp1 curl wget
sudo apt update && sudo apt install -y build-essential libglvnd-dev pkg-config

# Detect if running inside WSL
IS_WSL=false
if grep -qi microsoft /proc/version; then
    IS_WSL=true
    echo "🖥️ Running inside WSL."
else
    echo "🖥️ Running on a native Ubuntu system."
fi

# Function to check if an NVIDIA GPU is present
check_nvidia_gpu() {
    if command -v nvidia-smi &> /dev/null; then
        echo "✅ NVIDIA GPU detected."
        return 0
    elif lspci | grep -i nvidia &> /dev/null; then
        echo "✅ NVIDIA GPU detected (via lspci)."
        return 0
    else
        echo "⚠️ No NVIDIA GPU found."
        return 1
    fi
}

# Function to check if the system is a VPS, Laptop, or Desktop
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

# Function to install CUDA Toolkit 12.8 in WSL or Ubuntu 24.04
install_cuda() {
    if $IS_WSL; then
        echo "🖥️ Installing CUDA for WSL 2..."
        wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
        sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
        wget https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb
        sudo dpkg -i cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb
        sudo cp /var/cuda-repo-wsl-ubuntu-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
    else
        echo "🖥️ Installing CUDA for Ubuntu 24.04..."
        wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
        sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600
        wget https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb
        sudo dpkg -i cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb
        sudo cp /var/cuda-repo-ubuntu2404-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
    fi

    sudo apt-get update
    sudo apt-get -y install cuda-toolkit-12-8
    if [ $? -eq 0 ]; then
        echo "✅ CUDA installed successfully."
        setup_cuda_env
    else
        echo "❌ CUDA installation failed."
        return 1
    fi
}

# Function to set up CUDA environment variables
setup_cuda_env() {
    echo "🔧 Setting up CUDA environment variables..."
    echo 'export PATH=/usr/local/cuda-12.8/bin${PATH:+:${PATH}}' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc
    source ~/.bashrc
}

# Function to check CUDA version and install GaiaNet accordingly
get_cuda_version() {
    if command -v nvcc &> /dev/null; then
        CUDA_VERSION=$(nvcc --version | grep 'release' | awk '{print $6}' | cut -d',' -f1 | sed 's/V//g' | cut -d'.' -f1)
        echo "✅ CUDA version detected: $CUDA_VERSION"

        if [[ "$CUDA_VERSION" == "11" ]]; then
            echo "🔧 Installing GaiaNet with ggmlcuda 11..."
            curl -sSf https://github.com/GaiaNet-AI/gaianet-node/releases/download/0.4.20/install.sh | bash -s -- --ggmlcuda 12
        elif [[ "$CUDA_VERSION" == "12" ]]; then
            echo "🔧 Installing GaiaNet with ggmlcuda 12..."
            curl -sSf https://github.com/GaiaNet-AI/gaianet-node/releases/download/0.4.20/install.sh | bash -s -- --ggmlcuda 12
        else
            echo "⚠️ Unsupported CUDA version detected. Installing GaiaNet without GPU support..."
            curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/download/0.4.20/install.sh' | bash
        fi
    else
        echo "⚠️ CUDA not found. Installing GaiaNet without GPU support..."
        curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/download/0.4.20/install.sh' | bash
    fi
}

# Function to install GaiaNet without GPU support
install_gaianet_no_gpu() {
    echo "📥 Installing GaiaNet without GPU support..."
    curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/download/0.4.20/install.sh' | bash
}

# Function to add GaiaNet to PATH
add_gaianet_to_path() {
    echo 'export PATH=$HOME/gaianet/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc
}

# Main logic
if check_nvidia_gpu; then
    echo "🖥️ NVIDIA GPU detected. Checking CUDA version..."
    if install_cuda; then
        get_cuda_version
    else
        echo "❌ CUDA installation failed. Installing GaiaNet without GPU support..."
        install_gaianet_no_gpu
    fi
else
    echo "🖥️ No NVIDIA GPU detected. Installing GaiaNet without GPU support..."
    install_gaianet_no_gpu
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

# Initialize GaiaNet with the appropriate configuration
echo "⚙️ Initializing GaiaNet..."
~/gaianet/bin/gaianet init --config "$CONFIG_URL" || { echo "❌ GaiaNet initialization failed!"; exit 1; }

# Start GaiaNet node
echo "🚀 Starting GaiaNet node..."
~/gaianet/bin/gaianet config --domain gaia.domains
~/gaianet/bin/gaianet start || { echo "❌ Error: Failed to start GaiaNet node!"; exit 1; }

# Fetch GaiaNet node information
echo "🔍 Fetching GaiaNet node information..."
~/gaianet/bin/gaianet info || { echo "❌ Error: Failed to fetch GaiaNet node information!"; exit 1; }

# Closing message
echo "🎉 Setup and initialization complete! Your GaiaNet node should now be running."
