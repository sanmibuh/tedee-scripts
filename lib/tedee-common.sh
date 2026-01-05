#!/bin/sh

# Common functions for Tedee scripts
# This library provides shared functionality for interacting with Tedee Bridge

# ===== CONFIGURATION =====

# Load configuration file
load_config() {
    SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
    CONFIG_FILE="$SCRIPT_DIR/config/tedee.conf"

    if [ -f "$CONFIG_FILE" ]; then
        # shellcheck source=/dev/null
        . "$CONFIG_FILE"
    else
        log "ERROR" "Configuration file not found: $CONFIG_FILE"
        log "ERROR" "Please copy config/tedee.conf.template to config/tedee.conf and configure it."
        exit 1
    fi

    # Validate required variables
    : "${BRIDGE_IP:?BRIDGE_IP not set in config}"
    : "${TEDEE_TOKEN:?TEDEE_TOKEN not set in config}"
    : "${DEVICE_ID:?DEVICE_ID not set in config}"
    : "${MAX_RETRIES:=3}"
    : "${SLEEP_BETWEEN:=5}"

    # Check for empty values
    if [ -z "$BRIDGE_IP" ]; then
        log "ERROR" "BRIDGE_IP is empty in config file"
        log "ERROR" "Please run ./setup.sh to configure your Tedee Bridge"
        exit 1
    fi

    if [ -z "$TEDEE_TOKEN" ]; then
        log "ERROR" "TEDEE_TOKEN is empty in config file"
        log "ERROR" "Please run ./setup.sh to configure your Tedee API Token"
        exit 1
    fi

    if [ -z "$DEVICE_ID" ]; then
        log "ERROR" "DEVICE_ID is empty in config file"
        log "ERROR" "Please run ./setup.sh to configure your Tedee Device ID"
        exit 1
    fi
}

# ===== LOGGING =====

# Log message with timestamp and level (SLF4J style)
# Parameters: $1 = level (INFO, WARN, ERROR, DEBUG), $2 = message
log() {
    LEVEL="$1"
    MESSAGE="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$LEVEL] $MESSAGE"
}

# ===== TELEGRAM NOTIFICATIONS =====

# Send message to Telegram
send_telegram() {
    MESSAGE="$1"

    # Only send if Telegram is configured
    if [ -n "$TELEGRAM_TOKEN" ] && [ -n "$CHAT_ID" ]; then
        curl -s -S -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
             -d chat_id="${CHAT_ID}" \
             -d text="$MESSAGE" >/dev/null 2>&1
    fi
}

# ===== BRIDGE COMMUNICATION =====

# Check if Bridge is online
bridge_online() {
    ping -c 1 -W 2 "$BRIDGE_IP" >/dev/null 2>&1
}

# Generate dynamic encrypted api_token (SHA256(token + timestamp_ms) + timestamp_ms)
generate_api_key() {
    TIMESTAMP_MS=$(($(date +%s) * 1000))
    HASH=$(printf "%s%s" "$TEDEE_TOKEN" "$TIMESTAMP_MS" | sha256sum | awk '{print $1}')
    echo "${HASH}${TIMESTAMP_MS}"
}

# Get the current lock state
# States: 0=uncalibrated, 1=calibration, 2=open, 3=partially_open, 4=opening, 5=closing, 6=closed, 7=pull_spring, 8=pulling, 9=unknown, 255=unpulling
get_lock_state() {
    curl -s -X GET "http://${BRIDGE_IP}/v1.0/lock/${DEVICE_ID}" \
         -H 'accept: */*' \
         -H "api_token: $(generate_api_key)" \
         | grep -o '"state":[0-9]*' | cut -d':' -f2
}

# ===== LOCK OPERATIONS =====

# Check if door is closed
door_closed() {
    STATE=$(get_lock_state)
    [ "$STATE" = "6" ]
}

# Attempt to close the door
attempt_lock() {
    HTTP_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "http://${BRIDGE_IP}/v1.0/lock/${DEVICE_ID}/lock" \
        -H 'accept: */*' \
        -H "api_token: $(generate_api_key)" -d '' 2>&1)
    echo "$HTTP_CODE"
}

# Wait for door to close
# Monitors the lock state until it reaches closed (state 6)
# Sends a notification when closing begins (state 5)
wait_for_closed() {
    MAX_WAIT=$((MAX_RETRIES * SLEEP_BETWEEN))
    ELAPSED=0
    IN_PROGRESS=0

    while [ $ELAPSED -lt $MAX_WAIT ]; do
        STATE=$(get_lock_state)
        if [ "$STATE" = "6" ]; then
            return 0
        elif [ "$STATE" = "5" ] && [ "$IN_PROGRESS" = "0" ]; then
            IN_PROGRESS=1
            send_telegram "🔄 La puerta se está cerrando..."
        fi
        sleep $SLEEP_BETWEEN
        ELAPSED=$((ELAPSED + SLEEP_BETWEEN))
    done

    return 1
}

# ===== VALIDATION =====

# Check if Bridge is online, exit if not
require_bridge_online() {
    if ! bridge_online; then
        send_telegram "🔴 El Bridge Tedee no responde. Comprueba la conexión."
        log "ERROR" "Tedee Bridge is not responding. Check the connection."
        exit 1
    fi
}

