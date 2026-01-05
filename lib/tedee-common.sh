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
        echo "ERROR: Configuration file not found: $CONFIG_FILE"
        echo "Please copy config/tedee.conf.template to config/tedee.conf and configure it."
        exit 1
    fi

    # Validate required variables
    : "${BRIDGE_IP:?BRIDGE_IP not set in config}"
    : "${TEDEE_TOKEN:?TEDEE_TOKEN not set in config}"
    : "${DEVICE_ID:?DEVICE_ID not set in config}"
    : "${MAX_RETRIES:=3}"
    : "${SLEEP_BETWEEN:=5}"
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

# ===== LOCK STATE CHECKS =====

# Check if door is closed
door_closed() {
    STATE=$(get_lock_state)
    [ "$STATE" = "6" ]
}

# Check if door is open
door_open() {
    STATE=$(get_lock_state)
    [ "$STATE" = "2" ]
}

# Check if door is in transition (opening/closing)
door_in_transition() {
    STATE=$(get_lock_state)
    [ "$STATE" = "4" ] || [ "$STATE" = "5" ]
}

# ===== LOCK OPERATIONS =====

# Attempt to close the door
attempt_lock() {
    HTTP_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "http://${BRIDGE_IP}/v1.0/lock/${DEVICE_ID}/lock" \
        -H 'accept: */*' \
        -H "api_token: $(generate_api_key)" -d '' 2>&1)
    echo "$HTTP_CODE"
}

# Attempt to open the door
attempt_unlock() {
    HTTP_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "http://${BRIDGE_IP}/v1.0/lock/${DEVICE_ID}/unlock" \
        -H 'accept: */*' \
        -H "api_token: $(generate_api_key)" -d '' 2>&1)
    echo "$HTTP_CODE"
}

# Wait for door to reach a specific state
# Parameters: $1 = target_state, $2 = in_progress_state, $3 = notification_message
wait_for_state() {
    TARGET_STATE="$1"
    IN_PROGRESS_STATE="$2"
    NOTIFICATION_MSG="$3"

    MAX_WAIT=$((MAX_RETRIES * SLEEP_BETWEEN))
    ELAPSED=0
    IN_PROGRESS=0

    while [ $ELAPSED -lt $MAX_WAIT ]; do
        STATE=$(get_lock_state)
        if [ "$STATE" = "$TARGET_STATE" ]; then
            return 0
        elif [ "$STATE" = "$IN_PROGRESS_STATE" ] && [ "$IN_PROGRESS" = "0" ]; then
            IN_PROGRESS=1
            if [ -n "$NOTIFICATION_MSG" ]; then
                send_telegram "$NOTIFICATION_MSG"
            fi
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
        send_telegram "ERROR: El Bridge Tedee no responde. Comprueba la conexión."
        echo "ERROR: Tedee Bridge is not responding. Check the connection."
        exit 1
    fi
}

