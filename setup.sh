#!/bin/bash

# Setup script for tedee-scripts
# Helps with initial configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "========================================"
echo "  Tedee Scripts - Setup"
echo "========================================"
echo

# Check if config exists
if [ -f "$SCRIPT_DIR/config/tedee.conf" ]; then
    echo "${GREEN}✓${NC} Configuration found: config/tedee.conf"
    echo
    read -p "Do you want to reconfigure? (y/N): " RECONFIGURE
    echo
    if [ "$RECONFIGURE" != "y" ] && [ "$RECONFIGURE" != "Y" ]; then
        echo "${GREEN}Setup complete!${NC}"
        echo
        echo "You can now use:"
        echo "  ./bin/close  - Lock the door"
        echo "  ./bin/update - Update repository"
        exit 0
    fi
else
    echo "${YELLOW}!${NC} No configuration found"
    echo
fi

# Create config from template
if [ ! -f "$SCRIPT_DIR/config/tedee.conf.template" ]; then
    echo "${RED}✗${NC} Error: config/tedee.conf.template not found"
    exit 1
fi

echo "Creating configuration file..."
cp "$SCRIPT_DIR/config/tedee.conf.template" "$SCRIPT_DIR/config/tedee.conf"
echo "${GREEN}✓${NC} Created config/tedee.conf"
echo

# Interactive configuration
echo "Please enter your Tedee configuration:"
echo

read -p "Bridge IP address: " BRIDGE_IP
read -p "Tedee API Token: " TEDEE_TOKEN
read -p "Device ID: " DEVICE_ID

echo
echo "Optional - Telegram notifications (press Enter to skip):"
read -p "Telegram Bot Token (optional): " TELEGRAM_TOKEN
read -p "Telegram Chat ID (optional): " CHAT_ID

# Update config file
if command -v sed >/dev/null 2>&1; then
    # macOS compatible sed
    sed -i '' "s|BRIDGE_IP=\"TEDEE-BRIDGE-IP\"|BRIDGE_IP=\"$BRIDGE_IP\"|g" "$SCRIPT_DIR/config/tedee.conf"
    sed -i '' "s|TEDEE_TOKEN=\"TEDEE-API-TOKEN\"|TEDEE_TOKEN=\"$TEDEE_TOKEN\"|g" "$SCRIPT_DIR/config/tedee.conf"
    sed -i '' "s|DEVICE_ID=\"TEDEE-DEVICE-ID\"|DEVICE_ID=\"$DEVICE_ID\"|g" "$SCRIPT_DIR/config/tedee.conf"

    if [ -n "$TELEGRAM_TOKEN" ]; then
        sed -i '' "s|TELEGRAM_TOKEN=\"TELEGRAM-BOT-TOKEN\"|TELEGRAM_TOKEN=\"$TELEGRAM_TOKEN\"|g" "$SCRIPT_DIR/config/tedee.conf"
    fi

    if [ -n "$CHAT_ID" ]; then
        sed -i '' "s|CHAT_ID=\"TELEGRAM-CHAT-ID\"|CHAT_ID=\"$CHAT_ID\"|g" "$SCRIPT_DIR/config/tedee.conf"
    fi

    echo
    echo "${GREEN}✓${NC} Configuration saved successfully!"
else
    echo
    echo "${YELLOW}!${NC} Please manually edit config/tedee.conf with your values"
fi

# Make scripts executable
chmod +x "$SCRIPT_DIR/bin/"*
echo "${GREEN}✓${NC} Scripts are now executable"

echo
echo "========================================"
echo "${GREEN}  Setup Complete!${NC}"
echo "========================================"
echo
echo "Available commands:"
echo "  ./bin/close  - Lock the door"
echo "  ./bin/update - Update repository"
echo
echo "To use scripts from anywhere, add to your PATH:"
echo "  export PATH=\"$SCRIPT_DIR/bin:\$PATH\""
echo

