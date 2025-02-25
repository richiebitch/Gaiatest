#!/bin/bash

# File to store the API key
API_KEY_FILE="api_key.txt"

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
        API_NAME="Hyper"
    elif [ "$system_type" -eq 1 ]; then
        # Laptop
        if [ "$cuda_present" -eq 0 ]; then
            API_URL="https://soneium.gaia.domains/v1/chat/completions"
            API_NAME="Soneium"
        else
            API_URL="https://hyper.gaia.domains/v1/chat/completions"
            API_NAME="Hyper"
        fi
    elif [ "$system_type" -eq 2 ]; then
        # Desktop
        if [ "$cuda_present" -eq 0 ]; then
            API_URL="https://gadao.gaia.domains/v1/chat/completions"
            API_NAME="Gadao"
        else
            API_URL="https://hyper.gaia.domains/v1/chat/completions"
            API_NAME="Hyper"
        fi
    fi

    echo "🔗 Using API: ($API_NAME)"
}

# Function to get the API key
get_api_key() {
    if [ -f "$API_KEY_FILE" ]; then
        # Read the API key from the file
        api_key=$(cat "$API_KEY_FILE")
        echo "🔑 API Key loaded from $API_KEY_FILE."
    else
        # Prompt the user to enter the API key
        while true; do
            echo -n "Enter your API Key: "
            read -r api_key

            if [ -z "$api_key" ]; then
                echo "❌ Error: API Key is required!"
            else
                # Save the API key to the file
                echo "$api_key" > "$API_KEY_FILE"
                echo "🔑 API Key saved to $API_KEY_FILE."
                break
            fi
        done
    fi
}

# Function to generate a random general question
generate_random_general_question() {
    if [[ "$API_URL" == "https://hyper.gaia.domains/v1/chat/completions" ]]; then
        general_questions=(
            "What is the capital of France?"
            "Who wrote 'Romeo and Juliet'?"
            # Add more questions here...
        )
    elif [[ "$API_URL" == "https://gadao.gaia.domains/v1/chat/completions" ]]; then
        general_questions=(
            "Who is the current President of the United States?"
            "What is the capital of Japan?"
            # Add more questions here...
        )
    elif [[ "$API_URL" == "https://soneium.gaia.domains/v1/chat/completions" ]]; then
        general_questions=(
            "Who is the current President of the United States?"
            "What is the capital of Japan?"
            # Add more questions here...
        )
    fi

    echo "${general_questions[$RANDOM % ${#general_questions[@]}]"
}

# Function to handle the API request
send_request() {
    local message="$1"
    local api_key="$2"

    echo "📬 Sending Question to $API_NAME: $message"

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
            ((success_count++))  # Increment success count
            echo "✅ [SUCCESS] Response $success_count Received!"
            echo "📝 Question: $message"
            echo "💬 Response: $response_message"
        fi
    else
        echo "⚠️ [ERROR] API request failed | Status: $http_status | Retrying..."
        sleep 0
    fi

    # Set sleep time based on API URL
    if [[ "$API_URL" == "https://hyper.gaia.domains/v1/chat/completions" ]]; then
        echo "⏳ Sleeping for 2 seconds (hyper API)..."
        sleep 2
    elif [[ "$API_URL" == "https://soneium.gaia.domains/v1/chat/completions" ]]; then
        echo "⏳ Sleeping for 2 seconds (soneium API)..."
        sleep 2
    elif [[ "$API_URL" == "https://gadao.gaia.domains/v1/chat/completions" ]]; then
        echo "⏳ No sleep for gadao API..."
        sleep 0
    fi
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

# Get the API key
get_api_key

# Asking for duration
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

# Display thread information
echo "✅ Using 1 thread..."
echo "⏳ Waiting 30 seconds before sending the first request..."
sleep 5

echo "🚀 Starting requests..."
start_time=$(date +%s)
success_count=0  # Initialize success counter

while true; do
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))

    if [[ "$elapsed" -ge "$max_duration" ]]; then
        echo "🛑 Time limit reached ($bot_hours hours). Exiting..."
        echo "📊 Total successful responses: $success_count"
        exit 0
    fi

    random_message=$(generate_random_general_question)
    send_request "$random_message" "$api_key"
done
