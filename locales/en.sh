#!/bin/sh

# English locale for Tedee Scripts

# Telegram messages
MSG_BRIDGE_OFFLINE="🔴 The Tedee Bridge is not responding. Check the connection."
MSG_DOOR_CLOSING="🔄 The door is closing..."
MSG_DOOR_CLOSED="🔐 The door has been closed successfully."
MSG_DOOR_FAILED="❌ The door has NOT been closed. Current state: %s"
MSG_DOOR_ALREADY_CLOSED="🚪 The door was already closed."
MSG_AUTH_FAILED="🔑❌ Authentication failed. Check your TEDEE_TOKEN and AUTH_TYPE in config/tedee.conf"
MSG_SCRIPTS_UPDATED="📥 Tedee Scripts Updated\n\nScripts have been successfully updated to the latest version from branch: %s"

# Callback event messages
MSG_BACKEND_CONNECTED="🌐 Bridge connected to backend"
MSG_BACKEND_DISCONNECTED="🌐❌ Bridge disconnected from backend"
MSG_DEVICE_CONNECTED="🟢 Device %s connected to the bridge"
MSG_DEVICE_DISCONNECTED="🔴 Device %s disconnected from the bridge"
MSG_DEVICE_SETTINGS_CHANGED="⚙️ Device %s settings have been changed"
MSG_LOCK_STATUS_CHANGED="🔄 Device %s lock state: %s"
MSG_BATTERY_LEVEL_CHANGED="🔋 Device %s battery level changed to %s%%"
MSG_BATTERY_LEVEL_CHANGED_UNKNOWN="🔋 Device %s battery level changed"
MSG_BATTERY_FULLY_CHARGED="🔋✅ Device %s battery is fully charged (100%%)"
MSG_BATTERY_START_CHARGING="🔌 Device %s started charging"
MSG_BATTERY_STOP_CHARGING="🔌❌ Device %s stopped charging"
MSG_UNKNOWN_EVENT="❓ Unknown event received: %s at %s"

# Lock state messages
MSG_LOCK_STATE_UNCALIBRATED="🔧 Uncalibrated"
MSG_LOCK_STATE_CALIBRATION="🔧 Calibrating"
MSG_LOCK_STATE_UNLOCKED="🔓 Unlocked"
MSG_LOCK_STATE_PARTIALLY_OPEN="🚪 Partially Open"
MSG_LOCK_STATE_UNLOCKING="🔓 Unlocking..."
MSG_LOCK_STATE_LOCKING="🔐 Locking..."
MSG_LOCK_STATE_LOCKED="🔐 Locked"
MSG_LOCK_STATE_PULL_SPRING="🔄 Pull Spring"
MSG_LOCK_STATE_PULLING="🔄 Pulling..."
MSG_LOCK_STATE_UNPULLING="🔄 Unpulling..."
MSG_LOCK_STATE_UNKNOWN="❓ Unknown"

# Jammed alert message
MSG_LOCK_JAMMED_ALERT="🚨 The lock %s is jammed!"
