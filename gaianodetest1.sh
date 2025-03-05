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

# Check if sudo is installed
if ! command -v sudo &> /dev/null; then
    echo "❌ sudo is not installed. Installing sudo..."
    apt update
    apt install -y sudo
else
    echo "✅ sudo is already installed."
fi

# Check if screen is installed
if ! command -v screen &> /dev/null; then
    echo "❌ screen is not installed. Installing screen..."
    sudo apt update
    sudo apt install -y screen
else
    echo "✅ screen is already installed."
fi

# Check if net-tools is installed
if ! command -v ifconfig &> /dev/null; then
    echo "❌ net-tools is not installed. Installing net-tools..."
    sudo apt install -y net-tools
else
    echo "✅ net-tools is already installed."
fi

# Check if lsof is installed
if ! command -v lsof &> /dev/null; then
    echo "❌ lsof is not installed. Installing lsof..."
    sudo apt update
    sudo apt install -y lsof
    sudo apt upgrade -y
else
    echo "✅ lsof is already installed."
fi

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
        CUDA_VERSION=$(nvcc --version | grep -oP 'release \K\d+\.\d+' | cut -d. -f1)
        echo "✅ CUDA version $CUDA_VERSION is already installed."
        return 0
    else
        echo "⚠️ CUDA is not installed."
        return 1
    fi
}

# Function to check if an NVIDIA GPU is present
check_nvidia_gpu() {
    if command -v nvidia-smi &> /dev/null || lspci | grep -i nvidia &> /dev/null; then
        echo "✅ NVIDIA GPU detected."
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

# Function to install GaiaNet with or without CUDA support
install_gaianet() {
    local BASE_DIR=$1

    # Create the base directory if it doesn't exist
    if [ ! -d "$BASE_DIR" ]; then
        echo "📂 Creating directory $BASE_DIR..."
        mkdir -p "$BASE_DIR" || { echo "❌ Failed to create directory $BASE_DIR"; exit 1; }
    fi

    # Check for CUDA support
    if command -v nvcc &> /dev/null; then
        CUDA_VERSION=$(nvcc --version | grep -oP 'release \K\d+\.\d+' | cut -d. -f1)
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

# Function to install GaiaNet node
install_gaianet_node() {
    local NODE_NUMBER=$1
    local BASE_DIR

    # Determine the base directory
    if [[ $NODE_NUMBER -eq 0 ]]; then
        BASE_DIR="$HOME/gaianet"  # Default directory for the first node
    else
        BASE_DIR="$HOME/gaianet$NODE_NUMBER"  # Incremental directories for subsequent nodes
    fi

    local PORT=$((8080 + NODE_NUMBER))

    echo "🔧 Setting up GaiaNet Node $NODE_NUMBER in $BASE_DIR on port $PORT..."

    # Check if GaiaNet is already installed
    if [ -f "$BASE_DIR/bin/gaianet" ]; then
        echo "ℹ️ GaiaNet is already installed in $BASE_DIR. Skipping installation."
    else
        # Install GaiaNet
        install_gaianet "$BASE_DIR"

        # Verify installation
        if [ -f "$BASE_DIR/bin/gaianet" ]; then
            echo "✅ GaiaNet Node $NODE_NUMBER installed successfully in $BASE_DIR."
        else
            echo "❌ GaiaNet Node $NODE_NUMBER installation failed."
            return 1
        fi
    fi

    # Configure port
    "$BASE_DIR/bin/gaianet" config --base "$BASE_DIR" --port "$PORT" || { echo "❌ Port configuration failed."; return 1; }

    # Initialize and start the node
    "$BASE_DIR/bin/gaianet" init --base "$BASE_DIR" || { echo "❌ GaiaNet initialization failed!"; return 1; }
    "$BASE_DIR/bin/gaianet" start --base "$BASE_DIR" || { echo "❌ Error: Failed to start GaiaNet node!"; return 1; }

    echo "🎉 GaiaNet Node $NODE_NUMBER successfully installed and started in $BASE_DIR on port $PORT!"
}

# Function to start a specific node
start_gaianet_node() {
    local NODE_NUMBER=$1
    local BASE_DIR="$HOME/gaianet$NODE_NUMBER"

    if [ -f "$BASE_DIR/bin/gaianet" ]; then
        echo "🚀 Starting GaiaNet Node $NODE_NUMBER..."
        "$BASE_DIR/bin/gaianet" start --base "$BASE_DIR" || { echo "❌ Error: Failed to start GaiaNet node!"; return 1; }
    else
        echo "❌ GaiaNet Node $NODE_NUMBER is not installed."
    fi
}

# Function to stop a specific node
stop_gaianet_node() {
    local NODE_NUMBER=$1
    local BASE_DIR="$HOME/gaianet$NODE_NUMBER"

    if [ -f "$BASE_DIR/bin/gaianet" ]; then
        echo "🛑 Stopping GaiaNet Node $NODE_NUMBER..."
        "$BASE_DIR/bin/gaianet" stop --base "$BASE_DIR" || { echo "❌ Error: Failed to stop GaiaNet node!"; return 1; }
    else
        echo "❌ GaiaNet Node $NODE_NUMBER is not installed."
    fi
}

# Function to restart a specific node
restart_gaianet_node() {
    local NODE_NUMBER=$1
    local BASE_DIR="$HOME/gaianet$NODE_NUMBER"

    if [ -f "$BASE_DIR/bin/gaianet" ]; then
        echo "🔄 Restarting GaiaNet Node $NODE_NUMBER..."
        "$BASE_DIR/bin/gaianet" stop --base "$BASE_DIR" || { echo "❌ Error: Failed to stop GaiaNet node!"; return 1; }
        "$BASE_DIR/bin/gaianet" start --base "$BASE_DIR" || { echo "❌ Error: Failed to start GaiaNet node!"; return 1; }
    else
        echo "❌ GaiaNet Node $NODE_NUMBER is not installed."
    fi
}

# Function to display node information
display_node_info() {
    local NODE_NUMBER=$1
    local BASE_DIR="$HOME/gaianet$NODE_NUMBER"

    if [ -f "$BASE_DIR/bin/gaianet" ]; then
        echo "🔍 Information for GaiaNet Node $NODE_NUMBER:"
        "$BASE_DIR/bin/gaianet" info --base "$BASE_DIR" || { echo "❌ Error: Failed to fetch node information!"; return 1; }
    else
        echo "❌ GaiaNet Node $NODE_NUMBER is not installed."
    fi
}

# Main menu
while true; do
    clear
    echo "==============================================================="
    echo -e "\e[1;36m🚀🚀 GAIANET NODE INSTALLER Tool-Kit BY GA CRYPTO 🚀🚀\e[0m"

    echo -e "\e[1;85m📢 Stay updated:\e[0m"
    echo -e "\e[1;85m🔹 Telegram: https://t.me/GaCryptOfficial\e[0m"
    echo -e "\e[1;85m🔹 X (Twitter): https://x.com/GACryptoO\e[0m"

    echo "==============================================================="
    echo -e "\e[1;97m✨ Your GPU, CPU & RAM Specs Matter a Lot for Optimal Performance! ✨\e[0m"
    echo "==============================================================="
    
    # Performance & Requirement Section
    echo -e "\e[1;96m⏱  Keep Your Node Active Minimum 15 - 20 Hours Each Day! ⏳\e[0m"
    echo -e "\e[1;91m⚠️  Don’t Run Multiple Nodes if You Only Have 6-8GB RAM! ❌\e[0m"
    echo -e "\e[1;94m☁️  VPS Requirements: 8 Core+ CPU & 6-8GB RAM (Higher is Better) ⚡\e[0m"
    echo -e "\e[1;92m💻  Supported GPUs: RTX 20/30/40/50 Series Or Higher 🟢\e[0m"
    echo "==============================================================="
    echo -e "\e[1;32m✅ Earn Gaia Points Continuously – Keep Your System Active for Maximum Rewards! 💰💰\e[0m"
    echo "==============================================================="
    
    # Menu Options
    echo -e "\n\e[1mSelect an action:\e[0m\n"
    echo -e "1) \e[1;46m\e[97m☁️  Install Gaia-Node (VPS/Non-GPU)\e[0m"
    echo -e "2) \e[1;45m\e[97m💻  Install Gaia-Node (Laptop Nvidia GPU)\e[0m"
    echo -e "3) \e[1;44m\e[97m🎮  Install Gaia-Node (Desktop NVIDIA GPU)\e[0m"
    echo -e "4) \e[1;42m\e[97m🤖  Start Auto Chat With Ai-Agent\e[0m"
    echo -e "5) \e[1;100m\e[97m🔍  Switch to Active Screens\e[0m"
    echo -e "6) \e[1;41m\e[97m✋  Stop Auto Chatting With Ai-Agent\e[0m"
    echo -e "7) \e[1;43m\e[97m🔄  Restart GaiaNet Node\e[0m"
    echo -e "8) \e[1;43m\e[97m⏹️  Stop GaiaNet Node\e[0m"
    echo -e "9) \e[1;46m\e[97m🔍  Check Your Gaia Node ID & Device ID\e[0m"
    echo -e "10) \e[1;31m🗑️  Uninstall GaiaNet Node (Risky Operation)\e[0m"
    echo -e "0) \e[1;31m❌  Exit Installer\e[0m"
    echo "==============================================================="
    
    read -rp "Enter your choice: " choice

case $choice in
        1|2|3)
            echo "How many nodes do you want to install? (1-4)"
            read -rp "Enter the number of nodes: " NODE_COUNT
            if [[ ! "$NODE_COUNT" =~ ^[0-3]$ ]]; then
                echo "❌ Invalid input. Please enter a number between 0 and 3."
            else
                # Check for NVIDIA GPU and install CUDA if available
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

                # Install GaiaNet nodes
                for ((i=0; i<NODE_COUNT; i++)); do
                    install_gaianet_node "$i"
                done
            fi
            ;;

        4)
            # Start Auto Chat With Ai-Agent
            echo "Starting Auto Chat With Ai-Agent..."
            # Add your logic here
            ;;

        5)
            # Switch to Active Screens
            echo "Switching to Active Screens..."
            # Add your logic here
            ;;

        6)
            # Stop Auto Chatting With Ai-Agent
            echo "Stopping Auto Chatting With Ai-Agent..."
            # Add your logic here
            ;;

        7)
            echo "Which node do you want to restart? (0-3)"
            read -rp "Enter the node number: " NODE_NUMBER
            if [[ ! "$NODE_NUMBER" =~ ^[0-3]$ ]]; then
                echo "❌ Invalid input. Please enter a number between 0 and 3."
            else
                restart_gaianet_node "$NODE_NUMBER"
            fi
            ;;

        8)
            echo "Which node do you want to stop? (0-3)"
            read -rp "Enter the node number: " NODE_NUMBER
            if [[ ! "$NODE_NUMBER" =~ ^[0-3]$ ]]; then
                echo "❌ Invalid input. Please enter a number between 0 and 3."
            else
                stop_gaianet_node "$NODE_NUMBER"
            fi
            ;;

        9)
            echo "Which node do you want to check? (0-3)"
            read -rp "Enter the node number: " NODE_NUMBER
            if [[ ! "$NODE_NUMBER" =~ ^[0-3]$ ]]; then
                echo "❌ Invalid input. Please enter a number between 0 and 3."
            else
                display_node_info "$NODE_NUMBER"
            fi
            ;;

        10)
            echo "Which node do you want to uninstall? (0-3)"
            read -rp "Enter the node number: " NODE_NUMBER
            if [[ ! "$NODE_NUMBER" =~ ^[0-3]$ ]]; then
                echo "❌ Invalid input. Please enter a number between 0 and 3."
            else
                echo "⚠️ WARNING: This will completely remove GaiaNet Node $NODE_NUMBER from your system!"
                read -rp "Are you sure you want to proceed? (y/n) " confirm
                if [[ "$confirm" == "y" ]]; then
                    BASE_DIR="$HOME/gaianet$NODE_NUMBER"
                    if [[ $NODE_NUMBER -eq 0 ]]; then
                        BASE_DIR="$HOME/gaianet"  # Default directory for the first node
                    fi

                    if [ -d "$BASE_DIR" ]; then
                        echo "🗑️ Uninstalling GaiaNet Node $NODE_NUMBER..."
                        rm -rf "$BASE_DIR"
                        echo "✅ GaiaNet Node $NODE_NUMBER has been uninstalled."
                    else
                        echo "❌ GaiaNet Node $NODE_NUMBER is not installed."
                    fi
                else
                    echo "Uninstallation aborted."
                fi
            fi
            ;;

        0)
            echo "Exiting..."
            exit 0
            ;;

        *)
            echo "Invalid choice. Please try again."
            ;;
    esac

    read -rp "Press Enter to return to the main menu..."
done
