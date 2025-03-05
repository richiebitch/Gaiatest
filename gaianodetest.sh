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
sudo apt update -y && sudo apt install -y pciutils libgomp1 curl wget build-essential libglvnd-dev pkg-config libopenblas-dev libomp-dev
sudo apt upgrade -y && sudo apt update

# Detect if running inside WSL
IS_WSL=false
if grep -qi microsoft /proc/version; then
    IS_WSL=true
    echo "🖥️ Running inside WSL."
else
    echo "🖥️ Running on a native Ubuntu system."
fi

# Check if CUDA is already installed
check_cuda_installed() {
    if command -v nvcc &> /dev/null; then
        CUDA_VERSION=$(nvcc --version | awk '/release/ {print $NF}' | cut -d. -f1)
        echo "✅ CUDA version $CUDA_VERSION is already installed."
        return 0
    else
        echo "⚠️ CUDA is not installed."
        return 1
    fi
}

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

# Function to determine system type and set config URL
set_config_url() {
    check_system_type
    SYSTEM_TYPE=$?  # Capture the return value of check_system_type

    if [[ $SYSTEM_TYPE -eq 0 ]]; then
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
    elif [[ $SYSTEM_TYPE -eq 1 ]]; then
        if ! check_nvidia_gpu; then
            CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
        else
            CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config1.json"
        fi
    elif [[ $SYSTEM_TYPE -eq 2 ]]; then
        if ! check_nvidia_gpu; then
            CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
        else
            CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config3.json"
        fi
    fi
    echo "🔗 Using configuration: $CONFIG_URL"
}

# Function to install CUDA Toolkit 12.8 in WSL or Ubuntu 24.04
install_cuda() {
    if $IS_WSL; then
        echo "🖥️ Installing CUDA for WSL 2..."
        # Define file names and URLs for WSL
        PIN_FILE="cuda-wsl-ubuntu.pin"
        PIN_URL="https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin"
        DEB_FILE="cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb"
        DEB_URL="https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-wsl-ubuntu-12-8-local_12.8.0-1_amd64.deb"
    else
        echo "🖥️ Installing CUDA for Ubuntu 24.04..."
        # Define file names and URLs for Ubuntu 24.04
        PIN_FILE="cuda-ubuntu2404.pin"
        PIN_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin"
        DEB_FILE="cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb"
        DEB_URL="https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-repo-ubuntu2404-12-8-local_12.8.0-570.86.10-1_amd64.deb"
    fi

    # Download the .pin file
    echo "📥 Downloading $PIN_FILE from $PIN_URL..."
    wget "$PIN_URL" || { echo "❌ Failed to download $PIN_FILE from $PIN_URL"; exit 1; }

    # Move the .pin file to the correct location
    sudo mv "$PIN_FILE" /etc/apt/preferences.d/cuda-repository-pin-600 || { echo "❌ Failed to move $PIN_FILE to /etc/apt/preferences.d/"; exit 1; }

    # Remove the .deb file if it exists, then download a fresh copy
    if [ -f "$DEB_FILE" ]; then
        echo "🗑️ Deleting existing $DEB_FILE..."
        rm -f "$DEB_FILE"
    fi
    echo "📥 Downloading $DEB_FILE from $DEB_URL..."
    wget "$DEB_URL" || { echo "❌ Failed to download $DEB_FILE from $DEB_URL"; exit 1; }

    # Install the .deb file
    sudo dpkg -i "$DEB_FILE" || { echo "❌ Failed to install $DEB_FILE"; exit 1; }

    # Copy the keyring
    sudo cp /var/cuda-repo-*/cuda-*-keyring.gpg /usr/share/keyrings/ || { echo "❌ Failed to copy CUDA keyring to /usr/share/keyrings/"; exit 1; }

    # Update the package list and install CUDA Toolkit 12.8
    echo "🔄 Updating package list..."
    sudo apt-get update || { echo "❌ Failed to update package list"; exit 1; }
    echo "🔧 Installing CUDA Toolkit 12.8..."
    sudo apt-get install -y cuda-toolkit-12-8 || { echo "❌ Failed to install CUDA Toolkit 12.8"; exit 1; }

    echo "✅ CUDA Toolkit 12.8 installed successfully."
    setup_cuda_env
}

# Set up CUDA environment variables
setup_cuda_env() {
    echo "🔧 Setting up CUDA environment variables..."
    echo 'export PATH=/usr/local/cuda-12.8/bin${PATH:+:${PATH}}' | sudo tee /etc/profile.d/cuda.sh
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' | sudo tee -a /etc/profile.d/cuda.sh
    source /etc/profile.d/cuda.sh
}

# Function to install GaiaNet
install_gaianet() {
    local BASE_DIR=$1

    # Create the base directory if it doesn't exist
    if [ ! -d "$BASE_DIR" ]; then
        echo "📂 Creating directory $BASE_DIR..."
        mkdir -p "$BASE_DIR" || { echo "❌ Failed to create directory $BASE_DIR"; exit 1; }
    fi

    # Check for CUDA support
    if command -v nvcc &> /dev/null; then
        CUDA_VERSION=$(nvcc --version | awk '/release/ {print $NF}' | cut -d. -f1)
        echo "✅ CUDA version detected: $CUDA_VERSION"
        
        if [[ "$CUDA_VERSION" == "11"* || "$CUDA_VERSION" == "12"* ]]; then
            echo "🔧 Installing GaiaNet with CUDA support..."
            curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/download/0.4.20/install.sh' | bash -s -- --base "$BASE_DIR" --ggmlcuda "$CUDA_VERSION" || { echo "❌ GaiaNet installation failed."; exit 1; }
            return
        fi
    fi

    echo "⚠️ Installing GaiaNet without GPU support..."
    curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/download/0.4.20/install.sh' | bash -s -- --base "$BASE_DIR" || { echo "❌ GaiaNet installation failed."; exit 1; }
}

# Function to verify installation
verify_gaianet_installation() {
    local BASE_DIR=$1
    if [ -f "$BASE_DIR/bin/gaianet" ]; then
        echo "✅ GaiaNet installed successfully in $BASE_DIR."
        add_gaianet_to_path "$BASE_DIR"
    else
        echo "❌ GaiaNet installation failed. Exiting."
        exit 1
    fi
}

# Function to add GaiaNet to PATH
add_gaianet_to_path() {
    local BASE_DIR=$1
    GAIA_PATH="export PATH=$BASE_DIR/bin:\$PATH"
    if ! grep -Fxq "$GAIA_PATH" ~/.bashrc; then
        echo "$GAIA_PATH" >> ~/.bashrc
        echo "✅ Added GaiaNet to PATH. Restart your terminal or run 'source ~/.bashrc'."
    else
        echo "ℹ️ GaiaNet is already in PATH."
    fi
    source ~/.bashrc
}

# Function to configure GaiaNet port
configure_gaianet_port() {
    local BASE_DIR=$1
    local PORT=$2
    echo "🔧 Configuring GaiaNet on port $PORT..."
    "$BASE_DIR/bin/gaianet" config --base "$BASE_DIR" --port "$PORT" || { echo "❌ Port configuration failed."; exit 1; }
}

# Function to initialize and start GaiaNet
initialize_gaianet() {
    local BASE_DIR=$1
    echo "⚙️ Initializing GaiaNet..."
    "$BASE_DIR/bin/gaianet" init --base "$BASE_DIR" || { echo "❌ GaiaNet initialization failed!"; exit 1; }

    echo "🚀 Starting GaiaNet node..."
    "$BASE_DIR/bin/gaianet" start --base "$BASE_DIR" || { echo "❌ Error: Failed to start GaiaNet node!"; exit 1; }

    echo "🔍 Fetching GaiaNet node information..."
    "$BASE_DIR/bin/gaianet" info --base "$BASE_DIR" || { echo "❌ Error: Failed to fetch GaiaNet node information!"; exit 1; }
}

# Main function to orchestrate the script
main() {
    # Prompt user for the number of nodes to install
    read -p "Enter the number of GaiaNet nodes to install (1-4): " NODE_COUNT
    if [[ ! "$NODE_COUNT" =~ ^[1-4]$ ]]; then
        echo "❌ Invalid input. Please enter a number between 1 and 4."
        exit 1
    fi

    # Step 1: Install dependencies
    echo "📦 Installing dependencies..."
    sudo apt update -y && sudo apt install -y pciutils libgomp1 curl wget build-essential libglvnd-dev pkg-config libopenblas-dev libomp-dev
    sudo apt upgrade -y && sudo apt update

    # Step 2: Check for NVIDIA GPU and install CUDA if available and not already installed
    if check_nvidia_gpu; then
        if ! check_cuda_installed; then
            setup_cuda_env
            install_cuda
        else
            echo "⚠️ CUDA is already installed. Skipping CUDA installation."
        fi
    else
        echo "⚠️ Skipping CUDA installation (no NVIDIA GPU detected)."
    fi

    # Step 3: Set configuration URL based on system type
    set_config_url

    # Step 4: Install and configure each node
    for ((i=1; i<=NODE_COUNT; i++)); do
        echo "🔧 Setting up GaiaNet Node $i..."

        # Assign unique directory and port
        BASE_DIR="$HOME/gaianet$i"
        PORT=$((8081 + i - 1))

        # Step 5: Install GaiaNet
        install_gaianet "$BASE_DIR"
        verify_gaianet_installation "$BASE_DIR"

        # Step 6: Configure GaiaNet port
        configure_gaianet_port "$BASE_DIR" "$PORT"

        # Step 7: Initialize and start GaiaNet
        initialize_gaianet "$BASE_DIR"

        echo "🎉 GaiaNet Node $i successfully installed in $BASE_DIR on port $PORT!"
    done
}

# Call the main function to start the script
main
