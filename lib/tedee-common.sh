#!/bin/sh

# Common functions for Tedee scripts
# This library provides shared functionality for interacting with Tedee Bridge

# ===== LOGGING =====

# Log message with timestamp and level (SLF4J style)
# Parameters: $1 = level (INFO, WARN, ERROR, DEBUG), $2 = message
log() {
    LEVEL="$1"
    MESSAGE="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$LEVEL] $MESSAGE" >&2
}

# ===== LOCALIZATION =====

# Load locale messages
load_locale() {
    # Default to English if not specified
    LOCALE="${LOCALE:-en}"

    # Validate locale
    if [ "$LOCALE" != "en" ] && [ "$LOCALE" != "es" ]; then
        log "WARN" "Invalid locale '$LOCALE', falling back to 'en'"
        LOCALE="en"
    fi

    LOCALE_FILE="$SCRIPT_DIR/locales/${LOCALE}.sh"

    if [ -f "$LOCALE_FILE" ]; then
        # shellcheck source=/dev/null
        . "$LOCALE_FILE"
        log "DEBUG" "Loaded locale: $LOCALE"
    else
        log "WARN" "Locale file not found: $LOCALE_FILE, falling back to English"
        # shellcheck source=/dev/null
        . "$SCRIPT_DIR/locales/en.sh"
    fi
}

# ===== CONFIGURATION =====

# Load configuration file
load_config() {
    SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
    CONFIG_DIR="$SCRIPT_DIR/config"
    CONFIG_FILE="$CONFIG_DIR/tedee.conf"

    if [ -f "$CONFIG_FILE" ]; then
        # shellcheck source=/dev/null
        . "$CONFIG_FILE"
    else
        log "ERROR" "Configuration file not found: $CONFIG_FILE"
        log "ERROR" "Please run ./setup.sh to create and configure it."
        exit 1
    fi

    # Validate required configuration values
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

    # Validate AUTH_TYPE (related to TEDEE_TOKEN)
    if [ -z "$AUTH_TYPE" ]; then
        log "ERROR" "AUTH_TYPE is not set in config file"
        log "ERROR" "Please run ./setup.sh to configure authentication type"
        exit 1
    fi

    if [ "$AUTH_TYPE" != "encrypted" ] && [ "$AUTH_TYPE" != "non-encrypted" ]; then
        log "ERROR" "Invalid AUTH_TYPE: $AUTH_TYPE (must be 'encrypted' or 'non-encrypted')"
        log "ERROR" "Please run ./setup.sh to configure authentication type"
        exit 1
    fi

    if [ -z "$DEVICE_ID" ]; then
        log "ERROR" "DEVICE_ID is empty in config file"
        log "ERROR" "Please run ./setup.sh to configure your Tedee Device ID"
        exit 1
    fi

    if [ -z "$MAX_RETRIES" ]; then
        log "ERROR" "MAX_RETRIES is empty in config file"
        log "ERROR" "Please run ./setup.sh to configure retry settings"
        exit 1
    fi

    if [ -z "$SLEEP_BETWEEN" ]; then
        log "ERROR" "SLEEP_BETWEEN is empty in config file"
        log "ERROR" "Please run ./setup.sh to configure retry settings"
        exit 1
    fi

    # Load locale after config is loaded
    load_locale
}

# ===== TELEGRAM NOTIFICATIONS =====

# Send message to Telegram
# Parameters: $1 = message template, $2... = optional parameters for printf
send_telegram() {
    MESSAGE_TEMPLATE="$1"
    shift  # Remove first argument, remaining are printf parameters

    # Format message with printf if there are parameters
    if [ $# -gt 0 ]; then
        MESSAGE=$(printf "$MESSAGE_TEMPLATE" "$@")
    else
        MESSAGE="$MESSAGE_TEMPLATE"
    fi

    # Only send if Telegram is configured
    if [ -n "$TELEGRAM_TOKEN" ] && [ -n "$CHAT_ID" ]; then
        if ! curl -s -S -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
             -d chat_id="${CHAT_ID}" \
             -d text="$MESSAGE" >/dev/null 2>&1; then
            log "WARN" "Failed to send Telegram notification: $MESSAGE"
        fi
    fi
}

# ===== BRIDGE COMMUNICATION =====

# Check if Bridge is online
bridge_online() {
    ping -c 1 -W 2 "$BRIDGE_IP" >/dev/null 2>&1
}

# Generate api_key based on authentication type
# - encrypted: SHA256(token + timestamp_ms) + timestamp_ms
# - non-encrypted: returns the token as-is
generate_api_key() {
    if [ "$AUTH_TYPE" = "encrypted" ]; then
        # Encrypted authentication: generate dynamic key with real millisecond precision
        # Get current time in milliseconds using Node.js
        # (BusyBox date does not support millisecond precision)
        TIMESTAMP_MS=$(node -e 'console.log(Date.now())' | tr -d '\n')
        log "DEBUG" "Timestamp: $TIMESTAMP_MS"
        HASH=$(printf "%s%s" "$TEDEE_TOKEN" "$TIMESTAMP_MS" | sha256sum | awk '{print $1}')
        echo "${HASH}${TIMESTAMP_MS}"
    else
        # Non-encrypted authentication: return token directly
        echo "$TEDEE_TOKEN"
    fi
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
# Returns: HTTP status code (204=success, 401/403=auth error, other=error)
attempt_lock() {
    HTTP_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "http://${BRIDGE_IP}/v1.0/lock/${DEVICE_ID}/lock" \
        -H 'accept: */*' \
        -H "api_token: $(generate_api_key)" -d '' 2>&1)

    # Log auth failures
    if [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "403" ]; then
        log "ERROR" "Authentication failed (HTTP $HTTP_CODE). Check TEDEE_TOKEN and AUTH_TYPE in config."
        send_telegram "$MSG_AUTH_FAILED"
    fi

    echo "$HTTP_CODE"
}

# Wait for door to close
# Monitors the lock state until it reaches closed (state 6)
wait_for_closed() {
    MAX_WAIT=$((MAX_RETRIES * SLEEP_BETWEEN))
    ELAPSED=0

    while [ $ELAPSED -lt $MAX_WAIT ]; do
        STATE=$(get_lock_state)
        if [ "$STATE" = "6" ]; then
            return 0
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
        send_telegram "$MSG_BRIDGE_OFFLINE"
        log "ERROR" "Tedee Bridge is not responding. Check the connection."
        exit 1
    fi
}

