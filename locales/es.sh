#!/bin/sh

# Spanish locale for Tedee Scripts

# Telegram messages
MSG_BRIDGE_OFFLINE="🔴 El Bridge Tedee no responde. Comprueba la conexión."
MSG_DOOR_CLOSING="🔄 La puerta se está cerrando..."
MSG_DOOR_CLOSED="🔐 La puerta se ha cerrado correctamente."
MSG_DOOR_FAILED="❌ La puerta NO se ha cerrado. Estado actual: %s"
MSG_DOOR_ALREADY_CLOSED="🚪 La puerta ya estaba cerrada."
MSG_AUTH_FAILED="🔑❌ Autenticación fallida. Verifica tu TEDEE_TOKEN y AUTH_TYPE en config/tedee.conf"
MSG_SCRIPTS_UPDATED="📥 Scripts Tedee Actualizados\n\nLos scripts se han actualizado correctamente a la última versión desde la rama: %s"

# Callback event messages
MSG_BACKEND_CONNECTED="🌐 Bridge conectado al backend"
MSG_BACKEND_DISCONNECTED="🌐❌ Bridge desconectado del backend"
MSG_DEVICE_CONNECTED="🟢 Dispositivo %s conectado al bridge"
MSG_DEVICE_DISCONNECTED="🔴 Dispositivo %s desconectado del bridge"
MSG_DEVICE_SETTINGS_CHANGED="⚙️ La configuración del dispositivo %s ha sido modificada"
MSG_LOCK_STATUS_CHANGED="🔄 Estado de la cerradura del dispositivo %s: %s"
MSG_BATTERY_LEVEL_CHANGED="🔋 Nivel de batería del dispositivo %s cambiado a %s%%"
MSG_BATTERY_LEVEL_CHANGED_UNKNOWN="🔋 Nivel de batería del dispositivo %s cambiado"
MSG_BATTERY_FULLY_CHARGED="🔋✅ Batería del dispositivo %s completamente cargada (100%%)"
MSG_BATTERY_START_CHARGING="🔌 Dispositivo %s comenzó a cargar"
MSG_BATTERY_STOP_CHARGING="🔌❌ Dispositivo %s dejó de cargar"
MSG_UNKNOWN_EVENT="❓ Evento desconocido recibido: %s el %s"

# Lock state messages
MSG_LOCK_STATE_UNCALIBRATED="🔧 Sin calibrar"
MSG_LOCK_STATE_CALIBRATION="🔧 Calibrando"
MSG_LOCK_STATE_UNLOCKED="🔓 Desbloqueado"
MSG_LOCK_STATE_PARTIALLY_OPEN="🚪 Parcialmente abierto"
MSG_LOCK_STATE_UNLOCKING="🔓 Desbloqueando..."
MSG_LOCK_STATE_LOCKING="🔐 Bloqueando..."
MSG_LOCK_STATE_LOCKED="🔐 Bloqueado"
MSG_LOCK_STATE_PULL_SPRING="🔄 Retracción de resorte"
MSG_LOCK_STATE_PULLING="🔄 Retrayendo..."
MSG_LOCK_STATE_UNPULLING="🔄 Liberando..."
MSG_LOCK_STATE_UNKNOWN="❓ Desconocido"

# Jammed alert message
MSG_LOCK_JAMMED_ALERT="🚨 ¡La cerradura %s está atascada!"
