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

# Interactive configuration
if [ "$RECONFIGURING" = true ]; then
    echo "Reconfiguring (press Enter to keep current value):"
else
    echo "Please enter your Tedee configuration:"
    echo "Note: All three fields are mandatory"
fi
echo

# Loop until all mandatory fields are filled
while true; do
    if [ "$RECONFIGURING" = true ]; then
        read -p "Bridge IP address [current: $BRIDGE_IP]: " NEW_BRIDGE_IP
        BRIDGE_IP=${NEW_BRIDGE_IP:-$BRIDGE_IP}
    else
        read -p "Bridge IP address: " BRIDGE_IP
    fi

    if [ -z "$BRIDGE_IP" ]; then
        echo -e "${RED}✗${NC} Bridge IP is required!"
        continue
    fi
    break
done

while true; do
    if [ "$RECONFIGURING" = true ]; then
        read -p "Tedee API Token [current: $TEDEE_TOKEN]: " NEW_TEDEE_TOKEN
        TEDEE_TOKEN=${NEW_TEDEE_TOKEN:-$TEDEE_TOKEN}
    else
        read -p "Tedee API Token: " TEDEE_TOKEN
    fi

    if [ -z "$TEDEE_TOKEN" ]; then
        echo -e "${RED}✗${NC} Tedee API Token is required!"
        continue
    fi
    break
done

while true; do
    if [ "$RECONFIGURING" = true ]; then
        read -p "Device ID [current: $DEVICE_ID]: " NEW_DEVICE_ID
        DEVICE_ID=${NEW_DEVICE_ID:-$DEVICE_ID}
    else
        read -p "Device ID: " DEVICE_ID
    fi

    if [ -z "$DEVICE_ID" ]; then
        echo -e "${RED}✗${NC} Device ID is required!"
        continue
    fi
    break
done

echo
if [ "$RECONFIGURING" = true ]; then
    echo "Telegram notifications (press Enter to keep current, type 'none' to disable):"
    read -p "Telegram Bot Token [current: $([ -n "$TELEGRAM_TOKEN" ] && echo "$TELEGRAM_TOKEN" || echo "not set")]: " NEW_TELEGRAM_TOKEN

    # Check if user wants to unset
    if [ "$NEW_TELEGRAM_TOKEN" = "none" ] || [ "$NEW_TELEGRAM_TOKEN" = "NONE" ]; then
        TELEGRAM_TOKEN=""
        CHAT_ID=""
    elif [ -n "$NEW_TELEGRAM_TOKEN" ]; then
        TELEGRAM_TOKEN="$NEW_TELEGRAM_TOKEN"
    fi
    # else keep current value (empty NEW_TELEGRAM_TOKEN)
else
    echo "Optional - Telegram notifications (press Enter to skip):"
    read -p "Telegram Bot Token (optional): " TELEGRAM_TOKEN
fi

# Only ask for Chat ID if Telegram Token was provided
if [ -n "$TELEGRAM_TOKEN" ]; then
    # If token is provided, Chat ID becomes mandatory
    while true; do
        if [ "$RECONFIGURING" = true ]; then
            read -p "Telegram Chat ID [current: $CHAT_ID]: " NEW_CHAT_ID
            CHAT_ID=${NEW_CHAT_ID:-$CHAT_ID}
        else
            read -p "Telegram Chat ID (required): " CHAT_ID
        fi

        if [ -z "$CHAT_ID" ]; then
            echo -e "${RED}✗${NC} Chat ID is required when Telegram Token is set!"
            continue
        fi
        break
    done
else
    CHAT_ID=""
fi

echo
if [ "$RECONFIGURING" = true ]; then
    echo "Retry Configuration (press Enter to keep current):"
    read -p "Maximum retry attempts [current: $MAX_RETRIES - default: 3]: " NEW_MAX_RETRIES
    MAX_RETRIES=${NEW_MAX_RETRIES:-$MAX_RETRIES}

    read -p "Seconds between retries [current: $SLEEP_BETWEEN - default: 5]: " NEW_SLEEP_BETWEEN
    SLEEP_BETWEEN=${NEW_SLEEP_BETWEEN:-$SLEEP_BETWEEN}
else
    echo "Retry Configuration (press Enter for defaults):"
    read -p "Maximum retry attempts [default: 3]: " MAX_RETRIES
    MAX_RETRIES=${MAX_RETRIES:-3}

    read -p "Seconds between retries [default: 5]: " SLEEP_BETWEEN
    SLEEP_BETWEEN=${SLEEP_BETWEEN:-5}
fi

echo
if [ "$RECONFIGURING" = true ]; then
    echo "Locale Configuration (press Enter to keep current):"
    echo "Available locales: en (English), es (Spanish)"
    while true; do
        read -p "Locale [current: ${LOCALE:-en}]: " NEW_LOCALE
        NEW_LOCALE=${NEW_LOCALE:-$LOCALE}
        NEW_LOCALE=${NEW_LOCALE:-en}

        if [ "$NEW_LOCALE" = "en" ] || [ "$NEW_LOCALE" = "es" ]; then
            LOCALE="$NEW_LOCALE"
            break
        else
            echo -e "${RED}✗${NC} Invalid locale! Available options: en, es"
        fi
    done
else
    echo "Locale Configuration (press Enter for default):"
    echo "Available locales: en (English), es (Spanish)"
    while true; do
        read -p "Locale [default: en]: " LOCALE
        LOCALE=${LOCALE:-en}

        if [ "$LOCALE" = "en" ] || [ "$LOCALE" = "es" ]; then
            break
        else
            echo -e "${RED}✗${NC} Invalid locale! Available options: en, es"
        fi
    done
fi

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

