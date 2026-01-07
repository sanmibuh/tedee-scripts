#!/bin/bash

# Setup script for tedee-scripts
# Helps with initial configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"
mkdir -p "$CONFIG_DIR"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "========================================"
echo "  Tedee Scripts - Setup"
echo "========================================"
echo

# Check if config exists and load current values
RECONFIGURING=false
if [ -f "$CONFIG_DIR/tedee.conf" ]; then
    echo -e "${GREEN}✓${NC} Configuration found: config/tedee.conf"
    echo
    read -p "Do you want to reconfigure? (y/N): " RECONFIGURE
    echo
    if [ "$RECONFIGURE" != "y" ] && [ "$RECONFIGURE" != "Y" ]; then
        echo -e "${GREEN}Setup complete!${NC}"
        echo
        echo "You can now use:"
        echo "  ./bin/close  - Lock the door"
        echo "  ./bin/update - Update repository"
        exit 0
    fi

    # Load existing values for reconfiguration
    RECONFIGURING=true
    # shellcheck source=/dev/null
    . "$CONFIG_DIR/tedee.conf"
else
    echo -e "${YELLOW}!${NC} No configuration found"
    echo
fi

# Helper function to read and validate a configuration value
# Args: $1=var_name, $2=prompt_text, $3=current_value, $4=default_value, $5=is_required
read_config_value() {
    local var_name="$1"
    local prompt_text="$2"
    local current_value="$3"
    local default_value="$4"
    local is_required="$5"

    local full_prompt
    if [ "$RECONFIGURING" = true ]; then
        if [ -n "$current_value" ]; then
            full_prompt="$prompt_text [current: $current_value]: "
        else
            full_prompt="$prompt_text [current: not set]: "
        fi
    else
        if [ -n "$default_value" ]; then
            full_prompt="$prompt_text [default: $default_value]: "
        else
            full_prompt="$prompt_text: "
        fi
    fi

    while true; do
        read -p "$full_prompt" input_value

        # Handle reconfiguration: keep current value if no input
        if [ "$RECONFIGURING" = true ] && [ -z "$input_value" ]; then
            input_value="$current_value"
        fi

        # Apply default if no input and not reconfiguring
        if [ -z "$input_value" ] && [ -n "$default_value" ]; then
            input_value="$default_value"
        fi

        # Validate if required
        if [ "$is_required" = true ] && [ -z "$input_value" ]; then
            echo -e "${RED}✗${NC} $prompt_text is required!"
            continue
        fi

        # Set the value using indirect variable assignment
        eval "$var_name=\"\$input_value\""
        break
    done
}

# Helper function to read and validate a value with custom validation
# Args: $1=var_name, $2=prompt_text, $3=current_value, $4=default_value, $5=validation_function
read_config_with_validation() {
    local var_name="$1"
    local prompt_text="$2"
    local current_value="$3"
    local default_value="$4"
    local validation_func="$5"

    local full_prompt
    if [ "$RECONFIGURING" = true ]; then
        if [ -n "$current_value" ]; then
            full_prompt="$prompt_text [current: $current_value]: "
        else
            full_prompt="$prompt_text [current: ${default_value:-not set}]: "
        fi
    else
        if [ -n "$default_value" ]; then
            full_prompt="$prompt_text [default: $default_value]: "
        else
            full_prompt="$prompt_text: "
        fi
    fi

    while true; do
        read -p "$full_prompt" input_value

        # Handle reconfiguration: keep current value if no input
        if [ "$RECONFIGURING" = true ] && [ -z "$input_value" ]; then
            input_value="$current_value"
        fi

        # Apply default if no input
        if [ -z "$input_value" ] && [ -n "$default_value" ]; then
            input_value="$default_value"
        fi

        # Run custom validation
        if $validation_func "$input_value"; then
            eval "$var_name=\"\$input_value\""
            break
        fi
    done
}

# Validation function for locale
validate_locale() {
    local value="$1"
    if [ "$value" = "en" ] || [ "$value" = "es" ]; then
        return 0
    else
        echo -e "${RED}✗${NC} Invalid locale! Available options: en, es"
        return 1
    fi
}

# Validation function for auth_type
validate_auth_type() {
    local value="$1"
    if [ "$value" = "encrypted" ] || [ "$value" = "non-encrypted" ]; then
        return 0
    else
        echo -e "${RED}✗${NC} Invalid authentication type! Available options: encrypted, non-encrypted"
        return 1
    fi
}

# Interactive configuration
if [ "$RECONFIGURING" = true ]; then
    echo "Reconfiguring (press Enter to keep current value):"
else
    echo "Please enter your Tedee configuration:"
    echo "Note: All three fields are mandatory"
fi
echo

# Mandatory configuration
read_config_value "BRIDGE_IP" "Bridge IP address" "$BRIDGE_IP" "" true
read_config_value "TEDEE_TOKEN" "Tedee API Token" "$TEDEE_TOKEN" "" true

# Authentication Type configuration (related to TEDEE_TOKEN)
echo
if [ "$RECONFIGURING" = true ]; then
    echo "Authentication Type (press Enter to keep current):"
else
    echo "Authentication Type (press Enter for default):"
fi
echo "Available types: encrypted, non-encrypted"
read_config_with_validation "AUTH_TYPE" "Authentication Type" "${AUTH_TYPE:-encrypted}" "encrypted" validate_auth_type

read_config_value "DEVICE_ID" "Device ID" "$DEVICE_ID" "" true

# Optional Telegram configuration
echo
if [ "$RECONFIGURING" = true ]; then
    echo "Telegram notifications (press Enter to keep current, type 'none' to disable):"
    display_token="not set"
    [ -n "$TELEGRAM_TOKEN" ] && display_token="$TELEGRAM_TOKEN"
    read -p "Telegram Bot Token [current: $display_token]: " input_token

    # Check if user wants to unset
    if [ "$input_token" = "none" ] || [ "$input_token" = "NONE" ]; then
        TELEGRAM_TOKEN=""
        CHAT_ID=""
    elif [ -n "$input_token" ]; then
        TELEGRAM_TOKEN="$input_token"
    fi
    # else keep current value (empty input_token)
else
    echo "Optional - Telegram notifications (press Enter to skip):"
    read -p "Telegram Bot Token (optional): " TELEGRAM_TOKEN
fi

# Only ask for Chat ID if Telegram Token was provided
if [ -n "$TELEGRAM_TOKEN" ]; then
    read_config_value "CHAT_ID" "Telegram Chat ID (required)" "$CHAT_ID" "" true
else
    CHAT_ID=""
fi

# Retry configuration
echo
if [ "$RECONFIGURING" = true ]; then
    echo "Retry Configuration (press Enter to keep current):"
else
    echo "Retry Configuration (press Enter for defaults):"
fi
read_config_value "MAX_RETRIES" "Maximum retry attempts" "$MAX_RETRIES" "3" false
read_config_value "SLEEP_BETWEEN" "Seconds between retries" "$SLEEP_BETWEEN" "5" false

# Locale configuration
echo
if [ "$RECONFIGURING" = true ]; then
    echo "Locale Configuration (press Enter to keep current):"
else
    echo "Locale Configuration (press Enter for default):"
fi
echo "Available locales: en (English), es (Spanish)"
read_config_with_validation "LOCALE" "Locale" "${LOCALE:-en}" "en" validate_locale

# Create config file directly
echo "Creating configuration file..."

cat > "$CONFIG_DIR/tedee.conf" << EOF
#!/bin/sh

# Tedee Bridge Configuration
# Generated by setup.sh on $(date '+%Y-%m-%d %H:%M:%S')

# ===== MANDATORY SETTINGS =====

# IP address of your Tedee Bridge
BRIDGE_IP="$BRIDGE_IP"

# API Token for Tedee Bridge authentication
TEDEE_TOKEN="$TEDEE_TOKEN"

# Authentication Type (how the token is used)
# Options: encrypted, non-encrypted
# Default: encrypted
AUTH_TYPE="$AUTH_TYPE"

# Device ID of your Tedee lock
DEVICE_ID="$DEVICE_ID"

# ===== OPTIONAL SETTINGS =====

# Telegram Bot Configuration (for notifications)
TELEGRAM_TOKEN="$TELEGRAM_TOKEN"
CHAT_ID="$CHAT_ID"

# Retry Configuration
MAX_RETRIES="$MAX_RETRIES"
SLEEP_BETWEEN="$SLEEP_BETWEEN"

# Locale Configuration
# Available: en (English), es (Spanish)
LOCALE="$LOCALE"
EOF

echo
echo -e "${GREEN}✓${NC} Configuration saved successfully!"

# Make scripts executable
chmod +x "$SCRIPT_DIR/bin/"*
echo -e "${GREEN}✓${NC} Scripts are now executable"

echo
echo "========================================"
echo -e "${GREEN}  Setup Complete!${NC}"
echo "========================================"
echo
echo "Available commands:"
echo "  ./bin/close  - Lock the door"
echo "  ./bin/update - Update repository"
echo
echo "To use scripts from anywhere, add to your PATH:"
echo "  export PATH=\"$SCRIPT_DIR/bin:\$PATH\""
echo

