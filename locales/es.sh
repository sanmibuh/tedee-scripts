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
MSG_BATTERY_LEVEL_CHANGED="🔋 Nivel de batería del dispositivo %s cambiado a %s%%"
MSG_BATTERY_LEVEL_CHANGED_UNKNOWN="🔋 Nivel de batería del dispositivo %s cambiado"
MSG_BATTERY_FULLY_CHARGED="🔋✅ Batería del dispositivo %s completamente cargada (100%%)"
MSG_BATTERY_START_CHARGING="🔌 Dispositivo %s comenzó a cargar"
MSG_BATTERY_STOP_CHARGING="🔌❌ Dispositivo %s dejó de cargar"
MSG_UNKNOWN_EVENT="❓ Evento desconocido recibido: %s el %s"

# Lock state messages (complete messages with device ID)
MSG_LOCK_STATE_UNCALIBRATED="🔧❌ La cerradura %s está sin calibrar"
MSG_LOCK_STATE_CALIBRATION="🔧🔄 La cerradura %s se está calibrando..."
MSG_LOCK_STATE_UNLOCKED="🔓 La cerradura %s está desbloqueada"
MSG_LOCK_STATE_PARTIALLY_OPEN="🚪 La cerradura %s está parcialmente abierta"
MSG_LOCK_STATE_UNLOCKING="🔓🔄 La cerradura %s se está desbloqueando..."
MSG_LOCK_STATE_LOCKING="🔐🔄 La cerradura %s se está bloqueando..."
MSG_LOCK_STATE_LOCKED="🔐 La cerradura %s está bloqueada"
MSG_LOCK_STATE_PULL_SPRING="🔑 La cerradura %s tiene el rebalón abierto"
MSG_LOCK_STATE_PULLING="🔄🔑 La cerradura %s está abriendo el rebalón..."
MSG_LOCK_STATE_UNPULLING="🔄🔑 La cerradura %s está cerrando el rebalón..."
MSG_LOCK_STATE_UNKNOWN="❓ La cerradura %s tiene un estado desconocido"

# Jammed alert message
MSG_LOCK_JAMMED_ALERT="🚨 ¡La cerradura %s está atascada!"
