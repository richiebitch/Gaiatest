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

# Function to install packages if not already installed
install_pkg() {
    local pkg=$1
    if ! command -v $pkg &> /dev/null; then
        echo "❌ $pkg is not installed. Installing $pkg..."
        sudo apt update
        sudo apt install -y $pkg
    else
        echo "✅ $pkg is already installed."
    fi
}

# Install sudo if not present
if ! command -v sudo &> /dev/null; then
    echo "❌ sudo is not installed. Installing sudo..."
    apt update
    apt install -y sudo
else
    echo "✅ sudo is already installed."
fi

# List of essential packages to install
pkgs=(
    "screen" "lsof" "wget" "htop" "nvtop" "curl" "git" "sudo"
)

# Install each package
for pkg in "${pkgs[@]}"; do
    install_pkg $pkg
done

# Update locate database
if command -v updatedb &> /dev/null; then
    echo "🔄 Updating locate database..."
    sudo updatedb
fi

# Check for upgradable packages
echo "🔍 Checking for upgradable packages..."
upgradable=$(apt list --upgradable 2>/dev/null | grep -v "Listing...")

if [[ -n "$upgradable" ]]; then
    echo "📦 The following packages can be upgraded:"
    echo "$upgradable"
    echo "🚀 Upgrading packages..."
    sudo apt upgrade -y
else
    echo "✅ No packages to upgrade."
fi

echo "🎉 System setup and updates are complete!"

# Detect if running inside WSL
IS_WSL=false
if grep -qi microsoft /proc/version; then
    IS_WSL=true
    echo "🖥️ Running inside WSL."
else
    echo "🖥️ Running on a native Ubuntu system."
fi

# Function to automatically detect and set the local timezone
setup_timezone() {
    log_message "Detecting and setting local timezone..."

    # Install tzdata if not already installed
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update > /dev/null 2>&1
    sudo apt-get install -y tzdata > /dev/null 2>&1

    # Detect the local timezone using timedatectl
    if command -v timedatectl &> /dev/null; then
        LOCAL_TIMEZONE=$(timedatectl show --property=Timezone --value)
        if [ -z "$LOCAL_TIMEZONE" ]; then
            log_message "Warning: Unable to detect local timezone. Falling back to UTC."
            LOCAL_TIMEZONE="UTC"
        fi
    else
        log_message "Warning: 'timedatectl' not found. Falling back to IP-based timezone detection."
        # Fallback to IP-based timezone detection
        LOCAL_TIMEZONE=$(curl -s https://ipapi.co/timezone)
        if [ -z "$LOCAL_TIMEZONE" ]; then
            log_message "Warning: IP-based timezone detection failed. Falling back to UTC."
            LOCAL_TIMEZONE="UTC"
        fi
    fi

    # Set the detected timezone
    log_message "Setting timezone to $LOCAL_TIMEZONE..."
    echo "$LOCAL_TIMEZONE" | sudo tee /etc/timezone > /dev/null
    sudo ln -fs "/usr/share/zoneinfo/$LOCAL_TIMEZONE" /etc/localtime
    sudo dpkg-reconfigure -f noninteractive tzdata > /dev/null 2>&1

    log_message "Timezone successfully set to $(date)."
}

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
    echo "🔧 Detected System Type: $SYSTEM_TYPE"

    if [[ $SYSTEM_TYPE -eq 0 ]]; then
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
    elif [[ $SYSTEM_TYPE -eq 1 ]]; then
        if ! check_nvidia_gpu; then
            CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
        else
            CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config3.json"
        fi
    elif [[ $SYSTEM_TYPE -eq 2 ]]; then
        if ! check_nvidia_gpu; then
            CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config2.json"
        else
            CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config3.json"
        fi
    else
        echo "⚠️ Unable to determine system type. Using default configuration."
        CONFIG_URL="https://raw.githubusercontent.com/abhiag/Gaia_Node/main/config1.json"
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
    local CONFIG_URL=$2

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
            curl -sSfL 'https://raw.githubusercontent.com/abhiag/Gaiatest/main/install21.sh' | bash -s -- --base "$BASE_DIR" --ggmlcuda "$CUDA_VERSION" || { echo "❌ GaiaNet installation failed."; exit 1; }
            return
        fi
    fi

    echo "⚠️ Installing GaiaNet without GPU support..."
    curl -sSfL 'https://raw.githubusercontent.com/abhiag/Gaiatest/main/install21.sh' | bash -s -- --base "$BASE_DIR" || { echo "❌ GaiaNet installation failed."; exit 1; }

    # Download and apply the configuration file
    echo "📥 Downloading configuration from $CONFIG_URL..."
    wget -O "$BASE_DIR/config.json" "$CONFIG_URL" || { echo "❌ Failed to download configuration file."; exit 1; }
}

# Function to install GaiaNet node
install_gaianet_node() {
    local NODE_NUMBER=$1
    local CONFIG_URL=$2
    local BASE_DIR="$HOME/gaianet$NODE_NUMBER"
    local PORT=$((8090 + NODE_NUMBER))

    echo "🔧 Setting up GaiaNet Node $NODE_NUMBER in $BASE_DIR on port $PORT..."

    # Check if GaiaNet is already installed
    if [ -f "$BASE_DIR/bin/gaianet" ]; then
        echo "ℹ️ GaiaNet is already installed in $BASE_DIR. Skipping installation."
    else
        # Install GaiaNet with the provided CONFIG_URL
        install_gaianet "$BASE_DIR" "$CONFIG_URL"

        # Verify installation
        if [ -f "$BASE_DIR/bin/gaianet" ]; then
            echo "✅ GaiaNet Node $NODE_NUMBER installed successfully in $BASE_DIR."
        else
            echo "❌ GaiaNet Node $NODE_NUMBER installation failed."
            return 1
        fi
    fi

    # Download and apply the configuration file
    echo "📥 Downloading configuration from $CONFIG_URL..."
    wget -O "$BASE_DIR/config.json" "$CONFIG_URL" || { echo "❌ Failed to download configuration file."; return 1; }

    # Configure port
    "$BASE_DIR/bin/gaianet" config --base "$BASE_DIR" --port "$PORT" || { echo "❌ Port configuration failed."; return 1; }

    # Initialize the node
    echo "⚙️ Initializing GaiaNet..."
    "$BASE_DIR/bin/gaianet" init --base "$BASE_DIR" || { echo "❌ GaiaNet initialization failed!"; return 1; }

    # Start the node
    echo "🚀 Starting GaiaNet Node $NODE_NUMBER..."
    "$BASE_DIR/bin/gaianet" start --base "$BASE_DIR" || { echo "❌ Error: Failed to start GaiaNet node!"; return 1; }

    echo "🎉 GaiaNet Node $NODE_NUMBER successfully installed and started in $BASE_DIR on port $PORT!"
}

# Function to start a specific node
start_gaianet_node() {
    local NODE_NUMBER=$1
    local BASE_DIR="$HOME/gaianet$NODE_NUMBER"
    local LOG_FILE="$BASE_DIR/gaianet.log"

    if [ -f "$BASE_DIR/bin/gaianet" ]; then
        echo "🚀 Starting GaiaNet Node $NODE_NUMBER with nohup..."
        nohup "$BASE_DIR/bin/gaianet" start --base "$BASE_DIR" > "$LOG_FILE" 2>&1 < /dev/null & 
        echo "✅ GaiaNet Node $NODE_NUMBER started. Logs: $LOG_FILE"
    else
        echo "❌ GaiaNet Node $NODE_NUMBER is not installed."
    fi
}

# Function to stop a specific node or all nodes
stop_gaianet_node() {
    local NODE_NUMBER=$1

    if [[ "$NODE_NUMBER" == "all" ]]; then
        # Stop all nodes and shared services
        echo "🛑 Stopping all GaiaNet nodes and shared services..."

        # Check if ~/gaianet/bin/gaianet exists
        if [ -f "$HOME/gaianet/bin/gaianet" ]; then
            "$HOME/gaianet/bin/gaianet" stop || { echo "❌ Error: Failed to stop all nodes!"; return 1; }
        # Check if ~/gaianet0/bin/gaianet exists
        elif [ -f "$HOME/gaianet1/bin/gaianet" ]; then
            "$HOME/gaianet1/bin/gaianet" stop || { echo "❌ Error: Failed to stop all nodes!"; return 1; }
        else
            echo "❌ Gaianet node not found. Unable to stop all nodes."
            return 1
        fi

        echo "✅ All GaiaNet nodes and shared services stopped."
    else
        # Stop a specific node by killing the process(es) listening on its port
        local BASE_DIR="$HOME/gaianet$NODE_NUMBER"
        local PORT=$((8090 + NODE_NUMBER))

        if [ -f "$BASE_DIR/bin/gaianet" ]; then
            echo "🛑 Stopping GaiaNet Node $NODE_NUMBER..."

            # Find and kill the process(es) listening on the node's port
            PIDS=$(lsof -t -i :$PORT)
            if [ -n "$PIDS" ]; then
                echo "🛑 Killing process(es) listening on port $PORT..."
                for PID in $PIDS; do
                    echo "🛑 Killing process $PID..."
                    kill -9 "$PID" || { echo "❌ Error: Failed to stop process $PID!"; return 1; }
                done
                echo "✅ GaiaNet Node $NODE_NUMBER stopped."
            else
                echo "ℹ️ No process found listening on port $PORT. Node may already be stopped."
            fi
        else
            echo "❌ GaiaNet Node $NODE_NUMBER is not installed."
        fi
    fi
}

restart_gaianet_node() {
    local NODE_NUMBER=$1

    # If "all" is passed, restart all nodes (0-10)
    if [[ "$NODE_NUMBER" == "all" ]]; then
        echo "🔄 Restarting all GaiaNet nodes (0-10)..."
        for i in {0..10}; do
            restart_gaianet_node "$i"
        done
        echo "✅ All GaiaNet nodes restarted."
        return
    fi

    # Set the base directory and port based on the node number
    if [[ "$NODE_NUMBER" -eq 0 ]]; then
        BASE_DIR="$HOME/gaianet"  # Default directory for node 0
        PORT=8090
    else
        BASE_DIR="$HOME/gaianet$NODE_NUMBER"  # Directory for nodes 1-10
        PORT=$((8090 + NODE_NUMBER))
    fi

    if [ -f "$BASE_DIR/bin/gaianet" ]; then
        echo "🔄 Restarting GaiaNet Node $NODE_NUMBER..."

        # Stop the node first
        stop_gaianet_node "$NODE_NUMBER" || { echo "❌ Error: Failed to stop node $NODE_NUMBER!"; return 1; }

        # Start the node without logging
        echo "🚀 Starting GaiaNet Node $NODE_NUMBER..."
        nohup "$BASE_DIR/bin/gaianet" start --base "$BASE_DIR" > /dev/null 2>&1 &
        
        echo "✅ GaiaNet Node $NODE_NUMBER restarted."
    else
        echo "❌ GaiaNet Node $NODE_NUMBER is not installed."
    fi
}

# Function to check if a node is running by checking its port
check_node_status() {
    local NODE_NUMBER=$1
    local PORT=$((8090 + NODE_NUMBER))  # Calculate the port based on the node number

    # Check if the port is open and listening
    if lsof -i :$PORT > /dev/null 2>&1; then
        echo "Node Status: Running 🟢 (Port $PORT)"
    else
        echo "Node Status: Stopped 🔴 (Port $PORT)"
    fi
}

# Function to display node information (merged with check_all_installed_nodes)
display_node_info() {
    local NODE_NUMBER=$1

    if [[ -z "$NODE_NUMBER" ]]; then
        # If no node number is provided, check all installed nodes
        echo "🔍 Checking all installed GaiaNet nodes..."

        # Check the default node in ~/gaianet
        if [ -d "$HOME/gaianet" ]; then
            echo "---------------------------------------------------------------"
            echo "📂 Checking default node in directory: $HOME/gaianet"
            display_node_info "0"  # Default node is treated as node 0
        fi

        # Check additional nodes in ~/gaianet1, ~/gaianet2, etc.
        for NODE_DIR in "$HOME/gaianet"{1..10}; do
            if [ -d "$NODE_DIR" ]; then
                echo "---------------------------------------------------------------"
                echo "📂 Checking node in directory: $NODE_DIR"
                NODE_NUMBER=$(basename "$NODE_DIR" | grep -o '[0-9]*')
                display_node_info "$NODE_NUMBER"
            fi
        done

        echo "✅ Done checking all installed nodes."
    else
        # If a node number is provided, check the specific node
        if [[ "$NODE_NUMBER" == "0" ]]; then
            local BASE_DIR="$HOME/gaianet"  # Default node directory
        else
            local BASE_DIR="$HOME/gaianet$NODE_NUMBER"
        fi

        if [ -f "$BASE_DIR/bin/gaianet" ]; then
            echo "🔍 Information for GaiaNet Node $NODE_NUMBER:"
            "$BASE_DIR/bin/gaianet" info --base "$BASE_DIR" || { echo "❌ Error: Failed to fetch node information!"; return 1; }
            check_node_status "$NODE_NUMBER"  # Check and display the node status
        else
            echo "❌ GaiaNet Node $NODE_NUMBER is not installed."
        fi
    fi
}

# Function to check installed nodes and their port status
check_installed_nodes() {
    echo "🔍 Checking installed GaiaNet nodes and port status..."

    # Loop through all gaianet directories
    for dir in "$HOME"/gaianet*; do
        if [ -d "$dir" ]; then
            # Extract node number from directory name
            if [[ "$dir" == "$HOME/gaianet" ]]; then
                NODE_NUMBER=0
            else
                NODE_NUMBER=$(echo "$dir" | grep -oP '(?<=gaianet)\d+')
            fi

            # Calculate port number
            PORT=$((8090 + NODE_NUMBER))

            # Check if the gaianet binary exists
            if [ -f "$dir/bin/gaianet" ]; then
                STATUS="✅ Installed"
            else
                STATUS="❌ Not Installed"
            fi

            # Check if the port is active
            if lsof -i :$PORT > /dev/null 2>&1; then
                PORT_STATUS="🟢 Active (Port $PORT)"
            else
                PORT_STATUS="🔴 Inactive (Port $PORT)"
            fi

            # Display node information
            echo "Node $NODE_NUMBER:"
            echo "  Directory: $dir"
            echo "  Status: $STATUS"
            echo "  Node Status: $PORT_STATUS"
            echo "----------------------------------------"
        fi
    done
}

# Function to list active screen sessions and allow user to select one
select_screen_session() {
    while true; do
        echo "🔍 Checking for active screen sessions..."

        # Get the list of active screen sessions
        sessions=$(screen -list | grep -oP '\d+\.\S+' | awk '{print $1}')

        # Check if there are any active sessions
        if [ -z "$sessions" ]; then
            echo "❌ No active screen sessions found."
            return  # Return to the main menu
        fi

        # Display the list of sessions with numbers
        echo "✅ Active screen sessions:"
        i=1
        declare -A session_map
        for session in $sessions; do
            session_name=$(echo "$session" | cut -d'.' -f2)
            echo "$i) $session_name"
            session_map[$i]=$session
            i=$((i+1))
        done

        # Prompt the user to select a session
        echo -n "👉 Select a session by number (1, 2, 3, ...) or press Enter to return to the main menu: "
        read -r choice

        # If the user presses Enter, return to the main menu
        if [ -z "$choice" ]; then
            echo "Returning to the main menu..."
            return
        fi

        # Validate the user's choice
        if [[ -z "${session_map[$choice]}" ]]; then
            echo "❌ Invalid selection. Please try again."
            continue
        fi

        # Attach to the selected session
        selected_session=${session_map[$choice]}
        echo "🚀 Attaching to session: $selected_session"
        screen -d -r "$selected_session"
        break
    done
}

# Function to stop a node by its port
stop_node_by_port() {
    local PORT=$1
    echo "🛑 Stopping GaiaNet Node on Port $PORT..."
    if lsof -i :$PORT > /dev/null 2>&1; then
        kill $(lsof -t -i :$PORT)  # Kill the process using the port
        sleep 2  # Wait for the process to stop
        if lsof -i :$PORT > /dev/null 2>&1; then
            echo "❌ Failed to stop GaiaNet Node on Port $PORT."
            return 1
        else
            echo "✅ GaiaNet Node on Port $PORT has been stopped."
            return 0
        fi
    else
        echo "✅ GaiaNet Node on Port $PORT is already stopped."
        return 0
    fi
}

# Function to uninstall a node by port
uninstall_node_by_port() {
    local NODE_NUMBER=$1
    local PORT=$((8090 + NODE_NUMBER))
    local BASE_DIR

    if [[ "$NODE_NUMBER" == "0" ]]; then
        BASE_DIR="$HOME/gaianet"  # Default node directory
    else
        BASE_DIR="$HOME/gaianet$NODE_NUMBER"
    fi

    echo "⚠️ WARNING: This will completely remove GaiaNet Node $NODE_NUMBER (Port: $PORT) from your system!"
    read -rp "Are you sure you want to proceed? (y/n) " confirm
    if [[ "$confirm" != "y" ]]; then
        echo "Uninstallation aborted."
        return
    fi

    echo "🔍 Checking if GaiaNet Node $NODE_NUMBER (Port: $PORT) is running..."
    if check_node_status "$NODE_NUMBER"; then
        echo "🛑 GaiaNet Node $NODE_NUMBER (Port: $PORT) is currently running. Stopping it now..."
        if stop_node_by_port "$PORT"; then
            echo "🗑️ Uninstalling GaiaNet Node $NODE_NUMBER (Port: $PORT)..."
            if [ -d "$BASE_DIR" ]; then
                rm -rf "$BASE_DIR"
                echo "✅ GaiaNet Node $NODE_NUMBER (Port: $PORT) has been uninstalled."
            else
                echo "❌ GaiaNet Node $NODE_NUMBER (Port: $PORT) is not installed."
            fi
        else
            echo "❌ Failed to stop GaiaNet Node $NODE_NUMBER (Port: $PORT). Uninstallation aborted."
        fi
    else
        echo "🗑️ Uninstalling GaiaNet Node $NODE_NUMBER (Port: $PORT)..."
        if [ -d "$BASE_DIR" ]; then
            rm -rf "$BASE_DIR"
            echo "✅ GaiaNet Node $NODE_NUMBER (Port: $PORT) has been uninstalled."
        else
            echo "❌ GaiaNet Node $NODE_NUMBER (Port: $PORT) is not installed."
        fi
    fi
}

# Function to list all installed nodes
list_installed_nodes() {
    local nodes=()
    for dir in "$HOME"/gaianet*; do
        if [ -d "$dir" ]; then
            nodes+=("$(basename "$dir")")
        fi
    done
    if [ ${#nodes[@]} -eq 0 ]; then
        echo "No installed nodes found."
        return 1
    else
        echo "Installed nodes:"
        for node in "${nodes[@]}"; do
            echo "- $node"
        done
    fi
}

# Function to uninstall all nodes
uninstall_all_nodes() {
    echo "🔧 Uninstalling all nodes..."
    for dir in "$HOME"/gaianet*; do
        if [ -d "$dir" ]; then
            local NODE_NUMBER
            NODE_NUMBER=$(basename "$dir" | sed 's/gaianet//')
            uninstall_node_by_port "$NODE_NUMBER"
        fi
    done
    echo "✅ All nodes have been uninstalled."
}

# Main uninstall function
uninstall_gaianet_nodes() {
    echo "Uninstall GaiaNet Nodes"
    echo "======================"

    # List all installed nodes
    if ! list_installed_nodes; then
        return 1
    fi

    # Ask the user which node to uninstall
    echo "Which node do you want to uninstall? (Enter node number or 'all' to uninstall all nodes)"
    read -rp "Your choice: " UNINSTALL_CHOICE

    if [[ "$UNINSTALL_CHOICE" == "all" ]]; then
        # Uninstall all nodes
        uninstall_all_nodes
    elif [[ "$UNINSTALL_CHOICE" =~ ^[0-9]+$ ]]; then
        # Uninstall a specific node
        uninstall_node_by_port "$UNINSTALL_CHOICE"
    else
        echo "❌ Invalid choice. Please enter a valid node number or 'all'."
        return 1
    fi
}

# Main menu
while true; do
    clear
    echo "==============================================================="
    echo -e "\e[1;36m🚀🚀 GAIANET MULTI-NODE INSTALLER Tool-Kit BY GA CRYPTO 🚀🚀\e[0m"

    echo -e "\e[1;85m📢 Stay updated:\e[0m"
    echo -e "\e[1;85m🔹 Telegram: https://t.me/GaCryptOfficial\e[0m"
    echo -e "\e[1;85m🔹 X (Twitter): https://x.com/GACryptoO\e[0m"

    echo "==============================================================="
    echo -e "\e[1;97m✨ Your GPU, CPU & RAM Specs Matter a Lot for Optimal Performance! ✨\e[0m"
    echo "==============================================================="
    
    # Performance & Requirement Section
    echo -e "\e[1;96m⏱  Keep Your Node Active Minimum 15 - 20 Hours Each Day! ⏳\e[0m"
    echo -e "\e[1;91m⚠️  Don’t Run Multiple Nodes if You Only Have 6-8GB RAM! ❌\e[0m"
    echo -e "\e[1;94m☁️  1 NODE Required 4 GB RAM, U Must Have 20 GB Free RAM For 4 Nodes ⚡\e[0m"
    echo -e "\e[1;92m💻  Must Create 1 New Gaia Account & Claim 500 Credits for 1 Node (4 Nodes = 4 Gaia-Accounts) 🟢\e[0m"
    echo "==============================================================="
    echo -e "\e[1;32m✅ Earn Gaia Points Continuously – Keep Your System Active for Maximum Rewards! 💰💰\e[0m"
    echo "==============================================================="
    
# Menu Options
echo -e "\n\e[1mSelect an action:\e[0m\n"
echo -e "1) \e[1m☁️  Install Gaia-Node (VPS/Non-GPU)\e[0m"
echo -e "3) \e[1m🎮  Install Gaia-Node (NVIDIA GPU Desktop/Laptop/VSP)\e[0m"
echo -e "4) \e[1m🤖  Start Auto Chat With AI-Agent\e[0m"
echo -e "5) \e[1m🔍 Check Chatting With AI-Agent Active or Not\e[0m"
echo -e "6) \e[1m✋  Stop Auto Chatting With AI-Agent\e[0m"
echo -e "7) \e[1m🔄  Restart GaiaNet Node\e[0m"
echo -e "8) \e[1m⏹️  Stop All GaiaNet Nodes\e[0m"
echo -e "9) \e[1m🔍  Check Your Gaia Node ID & Device ID\e[0m"
echo -e "10) \e[1m📋  Check Installed & Active Nodes\e[0m"
echo -e "0) \e[1m❌  Exit Installer\e[0m"
echo "==============================================================="
echo -e "11) \e[1;31m🗑️  Uninstall GaiaNet Node (Risky Operation)\e[0m"
echo "==============================================================="

echo "==============================================================="
echo -e "12) \e[1;34m🌐 Update port for all installed nodes)\e[0m"
echo "==============================================================="

    
    read -rp "Enter your choice: " choice

case $choice in
    1|2|3)
        echo "How many nodes do you want to install? (1-10)"
        read -rp "Enter the number of nodes: " NODE_COUNT
        if [[ ! "$NODE_COUNT" =~ ^[1-9]$|^10$ ]]; then
            echo "❌ Invalid input. Please enter a number between 1 and 10."
        else
            # Check for NVIDIA GPU and install CUDA if available
            if check_nvidia_gpu; then
                if ! setup_cuda_env; then
                    if ! install_cuda; then
                        echo "❌ Failed to install CUDA. Exiting."
                        exit 1
                    fi
                else
                    echo "⚠️ CUDA is already installed. Skipping CUDA installation."
                fi
            else
                echo "⚠️ Skipping CUDA installation (no NVIDIA GPU detected)."
            fi

            # Determine the configuration URL based on system type and GPU availability
            if ! set_config_url; then
                echo "❌ Failed to set configuration URL. Exiting."
                exit 1
            fi

            # Install the specified number of nodes
            for ((i=1; i<=NODE_COUNT; i++)); do
                if ! install_gaianet_node "$i" "$CONFIG_URL"; then
                    echo "❌ Failed to install Node $i. Exiting."
                    exit 1
                fi
            done

            echo "🎉 Successfully installed $NODE_COUNT nodes!"
        fi
        ;;

        4)
            # Terminate any existing 'gaiabot' screen sessions before starting a new one
            echo "🔴 Terminating any existing 'gaiabot' screen sessions..."
            screen -ls | awk '/[0-9]+\.gaiabot/ {print $1}' | xargs -r -I{} screen -X -S {} quit

            # Function to check if a port is active
            check_port() {
                local port=$1
                if sudo lsof -i :$port > /dev/null 2>&1; then
                    echo -e "\e[1;32m✅ Port $port is active. GaiaNet node is running.\e[0m"
                    return 0
                else
                    return 1
                fi
            }

            # Function to check if the system is a VPS, laptop, or desktop
            check_if_vps_or_laptop() {
                echo "🔍 Detecting system type..."
                
                # Check for virtualization (VPS)
                if grep -qiE "kvm|qemu|vmware|xen|lxc" /proc/cpuinfo || grep -qiE "kvm|qemu|vmware|xen|lxc" /proc/meminfo; then
                    echo "✅ This is a VPS."
                    return 0
                # Check for battery (Laptop)
                elif ls /sys/class/power_supply/ | grep -q "^BAT[0-9]"; then
                    echo "✅ This is a Laptop."
                    return 1
                else
                    echo "✅ This is a Desktop."
                    return 2
                fi
            }

            # Main script logic
            echo "Detecting system configuration..."

            # Check if at least one GaiaNet node is installed
            at_least_one_node_installed=0

            for ((i=0; i<=4; i++)); do
                BASE_DIR="$HOME/gaianet$i"

                # Check if the gaianet binary exists in the BASE_DIR
                if command -v "$BASE_DIR/bin/gaianet" &> /dev/null; then
                    echo -e "\e[1;32m✅ GaiaNet binary found in $BASE_DIR/bin.\e[0m"
                    at_least_one_node_installed=$((at_least_one_node_installed + 1))
                else
                    echo -e "\e[1;31m❌ GaiaNet binary not found in $BASE_DIR/bin.\e[0m"
                fi
            done

            # If no nodes are installed, exit
            if [ $at_least_one_node_installed -eq 0 ]; then
                echo -e "\e[1;31m❌ No GaiaNet nodes are installed.\e[0m"
                echo -e "\e[1;33m🔍 Please install at least one node.\e[0m"
                read -r -p "Press Enter to return to the main menu..."
                continue
            fi

            # Proceed if at least one node is installed
            echo -e "\e[1;32m✅ At least one GaiaNet node is installed. Proceeding with chatbot setup.\e[0m"

            # Check if at least one of the ports is active
            at_least_one_port_active=0

            echo -e "\e[1;34m🔍 Checking ports...\e[0m"
            for ((i=1; i<=4; i++)); do
                BASE_DIR="$HOME/gaianet$i"
                PORT=$((8090 + i))

                # Check if the gaianet binary exists in the BASE_DIR
                if command -v "$BASE_DIR/bin/gaianet" &> /dev/null; then
                    echo -e "\e[1;34m🔍 Checking Node $i in $BASE_DIR on port $PORT...\e[0m"
                    if check_port $PORT; then
                        at_least_one_port_active=$((at_least_one_port_active + 1))
                        echo -e "\e[1;32m✅ Node $i is running on port $PORT.\e[0m"
                    else
                        echo -e "\e[1;31m❌ Node $i is not running on port $PORT.\e[0m"
                    fi
                else
                    echo -e "\e[1;33m⚠️ GaiaNet binary not found in $BASE_DIR/bin.\e[0m"
                fi
            done

            # If none of the ports are active, provide additional instructions
            if [ $at_least_one_port_active -eq 0 ]; then
                echo -e "\e[1;31m❌ No active ports found.\e[0m"
                echo -e "\e[1;33m🔗 Check Node Status Green Or Red: \e[1;34mhttps://www.gaianet.ai/setting/nodes\e[0m"
                echo -e "\e[1;33m🔍 If Red, Please Back to Main Menu & Restart your GaiaNet node first.\e[0m"
                read -r -p "Press Enter to return to the main menu..."
                continue
            fi

            echo -e "\e[1;32m🎉 At least one port is active. GaiaNet node is running.\e[0m"

            # Determine the appropriate script based on system type
            echo "🔍 Determining system type..."
            check_if_vps_or_laptop
            SYSTEM_TYPE=$?

            if [[ $SYSTEM_TYPE -eq 0 ]]; then
                script_name="gac.sh"
            elif [[ $SYSTEM_TYPE -eq 1 ]]; then
                script_name="gac.sh"
            else
                if command -v nvcc &> /dev/null || command -v nvidia-smi &> /dev/null; then
                    echo "✅ NVIDIA GPU detected on Desktop. Running GPU-optimized Domain Chat..."
                    script_name="gac.sh"
                else
                    echo "⚠️ No GPU detected on Desktop. Running Non-GPU version..."
                    script_name="gac.sh"
                fi
            fi

            # Start the chatbot in a detached screen session
            echo "🚀 Starting chatbot in a detached screen session..."
            screen -dmS gaiabot bash -c '
            echo "🔍 Starting chatbot script..."
            curl -O https://raw.githubusercontent.com/abhiag/Gaiatest/main/'"$script_name"' && chmod +x '"$script_name"';
            if [ -f "'"$script_name"'" ]; then
                echo "🔍 Executing chatbot script..."
                ./'"$script_name"'
                echo "🔍 Chatbot script execution complete."
            else
                echo "❌ Error: Failed to download '"$script_name"'"
                sleep 10
                exit 1
            fi'
            sleep 5
            screen -r gaiabot
            ;;

        5)
        echo "🔍 Check Chat-Bot Active or Not..."
        select_screen_session
        ;;

        6)
            # Stop Auto Chatting With Ai-Agent
            echo "Stopping Auto Chatting With Ai-Agent..."
            echo "🔴 Terminating and wiping all 'gaiabot' screen sessions..."
            # Terminate all 'gaiabot' screen sessions
            screen -ls | awk '/[0-9]+\.gaiabot/ {print $1}' | xargs -r -I{} screen -X -S {} quit
            # Remove any remaining screen sockets for 'gaiabot'
            find /var/run/screen -type s -name "*gaiabot*" -exec sudo rm -rf {} + 2>/dev/null
            echo -e "\e[32m✅ All 'gaiabot' screen sessions have been killed and wiped.\e[0m"
            ;;

7)
    echo "Do you want to restart a specific node or all nodes?"
    echo "1) Restart a specific node (0-10)"
    echo "2) Restart all nodes (0-10)"
    read -rp "Enter your choice (1 or 2): " CHOICE

    if [[ "$CHOICE" == "1" ]]; then
        echo "Which node do you want to restart? (0-10)"
        read -rp "Enter the node number: " NODE_NUMBER
        if [[ ! "$NODE_NUMBER" =~ ^[0-10]$ ]]; then
            echo "❌ Invalid input. Please enter a number between 0 and 4."
        else
            restart_gaianet_node "$NODE_NUMBER"
        fi
    elif [[ "$CHOICE" == "2" ]]; then
        restart_gaianet_node "all"
    else
        echo "❌ Invalid choice. Please enter 1 or 2."
    fi
    ;;

8)
    echo "🛑 Stopping all GaiaNet nodes (0-10)..."
    stop_gaianet_node "all"
    ;;

        9)
            display_node_info
            ;;

    11)
            uninstall_gaianet_nodes
            ;;

        10)
            # Check installed nodes
            check_installed_nodes
            ;;

12)
    echo "🔄 Updating port configuration for all installed GaiaNet nodes..."
    update_all_gaianet_ports
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
