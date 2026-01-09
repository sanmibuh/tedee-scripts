#!/bin/sh

# English locale for Tedee Scripts

# Telegram messages
MSG_BRIDGE_OFFLINE="🔴 The Tedee Bridge is not responding. Check the connection."
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
MSG_BATTERY_LEVEL_CHANGED="🔋 Device %s battery level changed to %s%%"
MSG_BATTERY_LEVEL_CHANGED_UNKNOWN="🔋 Device %s battery level changed"
MSG_BATTERY_FULLY_CHARGED="🔋✅ Device %s battery is fully charged (100%%)"
MSG_BATTERY_START_CHARGING="🔌 Device %s started charging"
MSG_BATTERY_STOP_CHARGING="🔌❌ Device %s stopped charging"
MSG_UNKNOWN_EVENT="❓ Unknown event received: %s at %s"

# Lock state messages (complete messages with device ID)
MSG_LOCK_STATE_UNCALIBRATED="🔧❌ Lock %s is uncalibrated"
MSG_LOCK_STATE_CALIBRATION="🔧🔄 Lock %s is calibrating..."
MSG_LOCK_STATE_UNLOCKED="🔓 Lock %s is unlocked"
MSG_LOCK_STATE_PARTIALLY_OPEN="🚪 Lock %s is partially open"
MSG_LOCK_STATE_UNLOCKING="🔓🔄 Lock %s is unlocking..."
MSG_LOCK_STATE_LOCKING="🔐🔄 Lock %s is locking..."
MSG_LOCK_STATE_LOCKED="🔐 Lock %s is locked"
MSG_LOCK_STATE_PULL_SPRING="🔑 Lock %s has pull spring open"
MSG_LOCK_STATE_PULLING="🔄🔑 Lock %s is pulling spring..."
MSG_LOCK_STATE_UNPULLING="🔄🔑 Lock %s is unpulling spring..."
MSG_LOCK_STATE_UNKNOWN="❓ Lock %s has unknown state"

# Jammed alert message
MSG_LOCK_JAMMED_ALERT="🚨 The lock %s is jammed!"
