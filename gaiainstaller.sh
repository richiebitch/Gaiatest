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

    echo -e "\e[1;96m⏱  Keep Your Node Active Minimum 15 - 20 Hours Each Day! ⏳\e[0m"
    echo -e "\e[1;91m⚠️  Don’t Run Multiple Nodes if You Only Have 6-8GB RAM! ❌\e[0m"
    echo -e "\e[1;94m☁️  VPS Requirements: 8 Core+ CPU & 6-8GB RAM (Higher is Better) ⚡\e[0m"
    echo -e "\e[1;92m💻  Supported GPUs: RTX 20/30/40/50 Series Or Higher 🟢\e[0m"
    echo "==============================================================="

    echo -e "\e[1;33m🎮  Desktop GPU Users: Higher Points – 10x More Powerful than Laptop GPUs! ⚡🔥\e[0m"
    echo -e "\e[1;33m💻  Laptop GPU Users: Earn More Points Than Non-GPU Users 🚀💸\e[0m"
    echo -e "\e[1;33m🌐  VPS/Non-GPU Users: Earn Based on VPS Specifications ⚙️📊\e[0m"
    echo "==============================================================="
    echo -e "\e[1;32m✅ Earn Gaia Points Continuously – Keep Your System Active for Maximum Rewards! 💰💰\e[0m"
    echo "==============================================================="

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
            echo "Installing Gaia-Node..."
            rm -rf 1.sh
            curl -O https://raw.githubusercontent.com/richiebitch/Gaiatest/main/1.sh
            chmod +x 1.sh
            ./1.sh
            ;;

        4)
            echo "Starting Auto Chat with AI-Agent..."

            check_if_vps_or_laptop() {
                vps_type=$(systemd-detect-virt)
                if echo "$vps_type" | grep -qiE "kvm|qemu|vmware|xen|lxc"; then
                    return 0  # VPS
                elif ls /sys/class/power_supply/ | grep -q "^BAT[0-9]"; then
                    return 0  # Laptop
                else
                    return 1  # Desktop
                fi
            }

            if check_if_vps_or_laptop || command -v nvcc &>/dev/null || command -v nvidia-smi &>/dev/null; then
                script_name="gaiachat1.sh"
            else
                script_name="gaiachat1.sh"
            fi

            screen -dmS gaiabot bash -c '
                curl -O https://raw.githubusercontent.com/richiebitch/Gaiatest/main/'"$script_name"' && chmod +x '"$script_name"';
                if [ -f "'"$script_name"'" ]; then
                    ./'"$script_name"'
                else
                    echo "❌ Error: Failed to download '"$script_name"'"
                    sleep 10
                    exit 1
                fi'
            sleep 5
            screen -r gaiabot
            ;;

        5)
            select_screen_session() {
                while true; do
                    echo "Checking for active screen sessions..."
                    sessions=$(screen -list | grep -oP '\d+\.\S+' | awk '{print $1}')
                    if [ -z "$sessions" ]; then
                        echo "No active screen sessions found."
                        return
                    fi

                    echo "Active screen sessions:"
                    i=1
                    declare -A session_map
                    for session in $sessions; do
                        session_name=$(echo "$session" | cut -d'.' -f2)
                        echo "$i) $session_name"
                        session_map[$i]=$session
                        ((i++))
                    done

                    read -rp "Select a session by number or press Enter to go back: " choice
                    if [ -z "$choice" ]; then return; fi

                    if [[ -n "${session_map[$choice]}" ]]; then
                        screen -d -r "${session_map[$choice]}"
                        break
                    else
                        echo "Invalid selection. Try again."
                    fi
                done
            }
            select_screen_session
            ;;

        6)
            echo "🔴 Terminating all 'gaiabot' screen sessions..."
            screen -ls | awk '/[0-9]+\.gaiabot/ {print $1}' | xargs -r -I{} screen -X -S {} quit
            echo -e "\e[32m✅ All 'gaiabot' screen sessions terminated.\e[0m"
            ;;

        7)
            echo "Restarting GaiaNet Node..."
            sudo netstat -tulnp | grep :8080
            ~/gaianet/bin/gaianet stop
            ~/gaianet/bin/gaianet init
            ~/gaianet/bin/gaianet start
            ~/gaianet/bin/gaianet info
            ;;

        8)
            echo "Stopping GaiaNet Node..."
            sudo netstat -tulnp | grep :8080
            ~/gaianet/bin/gaianet stop
            ;;

        9)
            echo "Checking Gaia Node ID & Device ID..."
            info=$(~/gaianet/bin/gaianet info 2>/dev/null)
            if [[ -n "$info" ]]; then
                echo "$info"
            else
                echo "❌ GaiaNet not found or not configured correctly."
            fi
            ;;

        10)
            echo "⚠️ WARNING: This will uninstall GaiaNet Node."
            read -rp "Are you sure? (y/n): " confirm
            if [[ "$confirm" == "y" ]]; then
                curl -sSfL 'https://github.com/GaiaNet-AI/gaianet-node/releases/latest/download/uninstall.sh' | bash
                source ~/.bashrc
            else
                echo "Aborted."
            fi
            ;;

        0)
            echo "Exiting..."
            exit 0
            ;;

        *)
            echo "Invalid option. Try again."
            ;;
    esac

    read -rp "Press Enter to return to the menu..."
done
