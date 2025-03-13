#!/bin/bash

# Function to check if NVIDIA CUDA or GPU is present
check_cuda() {
    if command -v nvcc &> /dev/null || command -v nvidia-smi &> /dev/null; then
        echo "✅ NVIDIA GPU with CUDA detected."
        return 0  # CUDA is present
    else
        echo "❌ NVIDIA GPU Not Found."
        return 1  # CUDA is not present
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

# Function to set the API URL based on system type and CUDA presence
set_api_url() {
    check_system_type
    system_type=$?

    check_cuda
    cuda_present=$?

    if [ "$system_type" -eq 0 ]; then
        # VPS
        API_URL="https://hyper.gaia.domains/v1/chat/completions"
        API_NAME="hyper"
    elif [ "$system_type" -eq 1 ]; then
        # Laptop
        if [ "$cuda_present" -eq 0 ]; then
            API_URL="https://gacrypto.gaia.domains/v1/chat/completions"
            API_NAME="gacrypto"
        else
            API_URL="https://hyper.gaia.domains/v1/chat/completions"
            API_NAME="hyper"
        fi
    elif [ "$system_type" -eq 2 ]; then
        # Desktop
        if [ "$cuda_present" -eq 0 ]; then
            API_URL="https://gacrypto.gaia.domains/v1/chat/completions"
            API_NAME="gacrypto"
        else
            API_URL="https://hyper.gaia.domains/v1/chat/completions"
            API_NAME="hyper"
        fi
    fi

    echo "🔗 Using API: ($API_NAME)"
}

# Set the API URL based on system type and CUDA presence
set_api_url

# Check if jq is installed, and if not, install it
if ! command -v jq &> /dev/null; then
    echo "❌ jq not found. Installing jq..."
    sudo apt update && sudo apt install jq -y
    if [ $? -eq 0 ]; then
        echo "✅ jq installed successfully!"
    else
        echo "❌ Failed to install jq. Please install jq manually and re-run the script."
        exit 1
    fi
else
    echo "✅ jq is already installed."
fi

generate_random_general_question() {
    local general_questions=(
        "Why is the Renaissance considered a turning point in history?"
        "How did the Industrial Revolution change the world?"
        "Why is the Great Wall of China historically significant?"
        "What were the main causes of World War I?"
        "How did the printing press impact society?"
        "Why is the moon landing in 1969 considered a major achievement?"
        "What led to the fall of the Roman Empire?"
        "How did the Cold War shape global politics?"
        "Why is the Amazon rainforest important for the planet?"
        "What sound does a cat make?"
        "Which number comes after 4?"
        "What is the opposite of 'hot'?"
        "What do you use to brush your teeth?"
        "What is the first letter of the alphabet?"
        "What shape is a football?"
        "How many fingers do humans have?"
        "How do vaccines work to protect against diseases?"
        "What are black holes, and why are they important in astronomy?"
        "How does climate change affect ecosystems?"
        "Why is the discovery of DNA considered revolutionary?"
        "How did the internet change modern communication?"
        "What role does the United Nations play in global peacekeeping?"
        "Why is the Suez Canal important for global trade?"
        "How did the Magna Carta influence modern democracy?"
        "Why is the water cycle crucial for life on Earth?"
        "What are the main challenges of space exploration?"
        "How did the discovery of electricity transform society?"
        "Why is the number zero important in mathematics?"
        "How is the Fibonacci sequence observed in nature?"
        "Why is the Pythagorean theorem significant in geometry?"
        "How does probability influence real-life decision-making?"
        "What are prime numbers, and why are they important in cryptography?"
        "Why is calculus essential in modern science and engineering?"
        "How does the concept of infinity affect mathematical theories?"
        "What is the significance of Euler’s formula in mathematics?"
        "Why is Pi considered an irrational number, and why is it useful?"
        "How does statistics help in making informed decisions?"
    )

    # Check if API_URL is set and matches any of the specified URLs
    if [[ -n "$API_URL" ]]; then
        case "$API_URL" in
            "https://hyper.gaia.domains/v1/chat/completions" | "https://gacrypto.gaia.domains/v1/chat/completions")
                # Use the general_questions array as is
                ;;
            *)
                # Handle unexpected API_URL values
                echo "Unsupported API_URL: $API_URL" >&2
                return 1
                ;;
        esac
    else
        echo "API_URL is not set." >&2
        return 1
    fi

    # Return a random question
    echo "${general_questions[$RANDOM % ${#general_questions[@]}]}"
}

# Function to handle the API request
send_request() {
    local message="$1"
    local api_key="$2"
    local key_name="$3"

    echo "📬 Sending Question to $API_NAME using key: $key_name"
    echo "📝 Question: $message"

    json_data=$(cat <<EOF
{
    "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "$message"}
    ]
}
EOF
    )

    response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
        -H "Authorization: Bearer $api_key" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "$json_data")

    http_status=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | head -n -1)

    # Extract the 'content' from the JSON response using jq (Suppress errors)
    response_message=$(echo "$body" | jq -r '.choices[0].message.content' 2>/dev/null)

    if [[ "$http_status" -eq 200 ]]; then
        if [[ -z "$response_message" ]]; then
            echo "⚠️ Response content is empty!"
        else
            echo "✅ [SUCCESS] Response Received!"
            echo "💬 Response: $response_message"
        fi
    else
        echo "⚠️ [ERROR] API request failed | Status: $http_status | Retrying."
        sleep 5
    fi
}

# Directory for API keys
API_KEY_DIR="$HOME/gaianet"
mkdir -p "$API_KEY_DIR"

# Function to load existing API keys
load_existing_keys() {
    API_KEY_LIST=($(ls "$API_KEY_DIR" 2>/dev/null | grep '^apikey_'))
    if [ ${#API_KEY_LIST[@]} -eq 0 ]; then
        echo "❌ No existing API keys found."
        return 1
    else
        echo "🔍 Detected existing API keys:"
        for i in "${!API_KEY_LIST[@]}"; do
            echo "$((i+1))) ${API_KEY_LIST[$i]}"
        done
        return 0
    fi
}

# Function to add a new API key
add_new_key() {
    echo -n "Enter your API Key: "
    read -r api_key

    if [ -z "$api_key" ]; then
        echo "❌ Error: API Key is required!"
        return 1
    fi

    while true; do
        echo -n "Enter a name to save this key (no spaces): "
        read -r key_name
        key_name=$(echo "$key_name" | tr -d ' ')  # Remove spaces

        if [ -z "$key_name" ]; then
            echo "❌ Error: Name cannot be empty!"
        elif [ -f "$API_KEY_DIR/apikey_$key_name" ]; then
            echo "⚠️  A key with this name already exists! Choose a different name."
        else
            echo "$api_key" > "$API_KEY_DIR/apikey_$key_name"
            chmod 600 "$API_KEY_DIR/apikey_$key_name"  # Secure the key file
            echo "✅ API Key saved as 'apikey_$key_name'"
            break
        fi
    done
}

# Main Menu
while true; do
    echo "📂 API Key Management"
    echo "1) Load existing API keys"
    echo "2) Add a new API key"
    echo "3) Start sending requests"
    echo "4) Exit"
    echo -n "👉 Choose an option (1-4): "
    read -r choice

    case "$choice" in
        1)
            load_existing_keys
            ;;
        2)
            add_new_key
            ;;
        3)
            if [ ${#API_KEY_LIST[@]} -eq 0 ]; then
                echo "❌ No API keys loaded. Please add or load keys first."
            else
                break  # Exit the menu and start sending requests
            fi
            ;;
        4)
            echo "🛑 Exiting..."
            exit 0
            ;;
        *)
            echo "❌ Invalid choice. Please try again."
            ;;
    esac
done

# Ask for duration
echo -n "⏳ How many hours do you want the bot to run? "
read -r bot_hours

# Convert hours to seconds
if [[ "$bot_hours" =~ ^[0-9]+$ ]]; then
    max_duration=$((bot_hours * 3600))
    echo "🕒 The bot will run for $bot_hours hour(s) ($max_duration seconds)."
else
    echo "⚠️ Invalid input! Please enter a number."
    exit 1
fi

# Main Loop
start_time=$(date +%s)
while true; do
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))

    if [[ "$elapsed" -ge "$max_duration" ]]; then
        echo "🛑 Time limit reached ($bot_hours hours). Exiting..."
        exit 0
    fi

    random_message=$(generate_random_general_question)

    # Send requests using all API keys in parallel
    for key_file in "${API_KEY_LIST[@]}"; do
        api_key=$(cat "$API_KEY_DIR/$key_file")
        send_request "$random_message" "$api_key" "$key_file" &
    done

    # Wait for all background processes to finish
    wait

    # Sleep before the next batch of requests
    sleep 1
done
