#!/bin/sh

# ===== FUNCTIONS =====

# Send message to Telegram
send_telegram() {
    MESSAGE="$1"
    curl -s -S -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
         -d chat_id="${CHAT_ID}" \
         -d text="$MESSAGE"
}

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
get_lock_state() {
    curl -s -X GET "http://${BRIDGE_IP}/v1.0/lock/${DEVICE_ID}" \
         -H 'accept: */*' \
         -H "api_token: $(generate_api_key)" \
         | grep -o '"state":[0-9]*' | cut -d':' -f2
}

# Check if door is already locked
door_already_locked() {
    STATE=$(get_lock_state)
    [ "$STATE" = "6" ]
}

# Attempt to lock the door
attempt_lock() {
    HTTP_CODE=$(curl -sS -o /dev/null -w "%{http_code}" -X POST "http://${BRIDGE_IP}/v1.0/lock/${DEVICE_ID}/lock" \
        -H 'accept: */*' \
        -H "api_token: $(generate_api_key)" -d '' 2>&1)
    echo "$HTTP_CODE"
}

# Lock door with retries
lock_door_with_retries() {
    RETRIES=0
    while [ $RETRIES -lt $MAX_RETRIES ]; do
        HTTP_CODE=$(attempt_lock)
        if [ "$HTTP_CODE" = "204" ]; then
            break
        fi
        RETRIES=$((RETRIES+1))
        sleep $SLEEP_BETWEEN
    done
}

# Wait for door to finish closing
wait_for_lock() {
    MAX_WAIT=$((MAX_RETRIES * SLEEP_BETWEEN))
    ELAPSED=0
    CLOSING=0

    while [ $ELAPSED -lt $MAX_WAIT ]; do
        STATE=$(get_lock_state)
        if [ "$STATE" = "6" ]; then
            return 0
        elif [ "$STATE" = "5" ] && [ "$CLOSING" = "0" ]; then
            CLOSING=1
            send_telegram "INFO: La puerta se está cerrando..."
        fi
        sleep $SLEEP_BETWEEN
        ELAPSED=$((ELAPSED + SLEEP_BETWEEN))
    done

    return 1
}

# Notify final state
notify_final_state() {
    if wait_for_lock; then
        send_telegram "ÉXITO: La puerta se ha cerrado correctamente."
    else
        send_telegram "ERROR: La puerta NO se ha cerrado. Último código HTTP: $HTTP_CODE, estado actual: $(get_lock_state)"
    fi
}

# Load configuration
load_config() {
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    CONFIG_FILE="$SCRIPT_DIR/tedee.conf"

    if [ -f "$CONFIG_FILE" ]; then
        . "$CONFIG_FILE"
    else
        echo "ERROR: Fichero de configuración no encontrado: $CONFIG_FILE"
        exit 1
    fi

    # Validate required variables
    : "${BRIDGE_IP:?BRIDGE_IP not set in config}"
    : "${TEDEE_TOKEN:?TEDEE_TOKEN not set in config}"
    : "${DEVICE_ID:?DEVICE_ID not set in config}"
    : "${TELEGRAM_TOKEN:?TELEGRAM_TOKEN not set in config}"
    : "${CHAT_ID:?CHAT_ID not set in config}"
    : "${MAX_RETRIES:?MAX_RETRIES not set in config}"
    : "${SLEEP_BETWEEN:?SLEEP_BETWEEN not set in config}"
}

# Check if Bridge is online
check_bridge() {
    if ! bridge_online; then
        send_telegram "ERROR: El Bridge Tedee no responde. Comprueba la conexión."
        exit 1
    fi
}

# Check if door is already locked
check_door_locked() {
    if door_already_locked; then
        send_telegram "INFO: La puerta ya estaba cerrada. No se necesita acción."
        exit 0
    fi
}

# ===== MAIN =====
main() {
    load_config
    check_bridge
    check_door_locked

    lock_door_with_retries
    notify_final_state
}

main
