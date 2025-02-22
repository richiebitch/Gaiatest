#!/bin/bash

printf "\n"
cat <<EOF


░██████╗░░█████╗░  ░█████╗░██████╗░██╗░░░██╗██████╗░████████╗░█████╗░
██╔════╝░██╔══██╗  ██╔══██╗██╔══██╗╚██╗░██╔╝██╔══██╗╚══██╔══╝██╔══██╗
██║░░██╗░███████║  ██║░░╚═╝██████╔╝░╚████╔╝░██████╔╝░░░██║░░░██║░░██║
██║░░╚██╗██╔══██║  ██║░░██╗██╔══██╗░░╚██╔╝░░██╔═══╝░░░░██║░░░██║░░██║
╚██████╔╝██║░░██║  ╚█████╔╝██║░░██║░░░██║░░░██║░░░░░░░░██║░░░╚█████╔╝
░╚═════╝░╚═╝░░╚═╝  ░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░░░░╚═╝░░░░╚════╝░
EOF

printf "\n\n"

##########################################################################################
#                                                                                        
#                🚀 THIS SCRIPT IS PROUDLY CREATED BY **GA CRYPTO**! 🚀                 
#                                                                                        
#   🌐 Join our revolution in decentralized networks and crypto innovation!               
#                                                                                        
# 📢 Stay updated:                                                                      
#     • Follow us on Telegram: https://t.me/GaCryptOfficial                             
#     • Follow us on X: https://x.com/GACryptoO                                         
##########################################################################################

# Green color for advertisement
GREEN="\033[0;32m"
RESET="\033[0m"

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
    else
        echo "⚠️ No NVIDIA GPU found."
        return 1
    fi
}

# Function to install CUDA Toolkit 12.8 with progress display
install_cuda() {
    echo "🔄 Installing CUDA Toolkit 12.8..."

    if $IS_WSL; then
        echo "🖥️ Installing CUDA for WSL 2..."
        wget --progress=bar:force -O cuda-wsl-ubuntu.pin https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
        sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600

        wget --progress=bar:force -O cuda-wsl.deb https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb
        sudo dpkg -i cuda-wsl.deb

        sudo cp /var/cuda-repo-wsl-ubuntu-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
    else
        echo "🖥️ Installing CUDA for Ubuntu 24.04..."
        wget --progress=bar:force -O cuda-ubuntu2404.pin https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
        sudo mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600

        wget --progress=bar:force -O cuda-ubuntu.deb https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb
        sudo dpkg -i cuda-ubuntu.deb

        sudo cp /var/cuda-repo-ubuntu2404-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/
    fi

    sudo apt-get update
    sudo apt-get -y install cuda-toolkit-12-8
    setup_cuda_env
}

# Function to set up CUDA environment variables
setup_cuda_env() {
    echo "🔧 Setting up CUDA environment variables..."
    echo 'export PATH=/usr/local/cuda-12.8/bin${PATH:+:${PATH}}' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc
    source ~/.bashrc  # ✅ Ensure the new paths are applied immediately
}

# Function to check CUDA version and install GaiaNet accordingly
install_gaianet_with_cuda() {
    source ~/.bashrc  # ✅ Load CUDA paths before checking `nvcc`
    
    if command -v nvcc &> /dev/null; then
        CUDA_VERSION=$(nvcc --version | grep 'release' | awk '{print $6}' | cut -d',' -f1 | sed 's/V//g' | cut -d'.' -f1)  
        echo "✅ CUDA version detected: $CUDA_VERSION"

        if [[ "$CUDA_VERSION" == "11" ]]; then
            echo "🔧 Installing GaiaNet with ggmlcuda 11..."
            curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash -s -- --ggmlcuda 11
        elif [[ "$CUDA_VERSION" == "12" ]]; then
            echo "🔧 Installing GaiaNet with ggmlcuda 12..."
            curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash -s -- --ggmlcuda 12
        else
            echo "⚠️ Unsupported CUDA version detected. Exiting..."
            exit 1
        fi
    else
        echo "⚠️ CUDA not found. Installing CUDA Toolkit 12.8..."
        install_cuda
        source ~/.bashrc  # ✅ Reload after installation
        install_gaianet_with_cuda  # ✅ Retry after CUDA install
    fi
}

# Function to check if the system is a VPS or Laptop
check_if_vps_or_laptop() {
    vps_type=$(systemd-detect-virt)
    if echo "$vps_type" | grep -qiE "kvm|qemu|vmware|xen|lxc"; then
        echo "✅ This is a VPS."
        return 0  # VPS detected
    elif ls /sys/class/power_supply/ | grep -q "^BAT[0-9]"; then
        echo "✅ This is a Laptop."
        return 0  # Laptop detected
    else
        echo "✅ This is a Desktop."
        return 1  # Desktop detected
    fi
}

# Function to install GaiaNet
install_gaianet() {
    echo "📥 Installing GaiaNet..."
    curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/install.sh' | bash
}

# Function to add GaiaNet to PATH
add_gaianet_to_path() {
    echo 'export PATH=$HOME/gaianet/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc
}

# Determine correct config file based on system type and GPU presence
if check_if_vps_or_laptop; then
    config_url="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
elif check_nvidia_gpu; then
    config_url="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config1.json"
else
    config_url="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
fi

# Install GaiaNet once, only after determining correct configuration
if check_nvidia_gpu; then
    setup_cuda_env
    install_gaianet_with_cuda
else
    install_gaianet
fi

add_gaianet_to_path

echo "⚙️ Initializing GaiaNet node..."
~/gaianet/bin/gaianet init --config "$config_url" || { echo "❌ GaiaNet initialization failed!"; exit 1; }

# Start GaiaNet node
echo "🚀 Starting GaiaNet node..."
~/gaianet/bin/gaianet config --domain gaia.domains
~/gaianet/bin/gaianet start || { echo "❌ Error: Failed to start GaiaNet node!"; exit 1; }

echo "🔍 Fetching GaiaNet node information..."
~/gaianet/bin/gaianet info || { echo "❌ Error: Failed to fetch GaiaNet node information!"; exit 1; }

# Closing message
echo "==========================================================="
echo "🎉 Congratulations! Your GaiaNet node is successfully set up!"
echo "🌟 Stay connected: Telegram: https://t.me/GaCryptOfficial | Twitter: https://x.com/GACryptoO"
echo "💪 Together, let's build the future of decentralized networks!"
echo "===========================================================" 
