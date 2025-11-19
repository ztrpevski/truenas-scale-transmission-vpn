#!/bin/bash
set -e

# echo "[entrypoint] Waiting for Gluetun forwarded port..."

# # Wait for the forwarded port from Gluetun API
# while true; do
#   PORT=$(curl -s http://localhost:8000/v1/openvpn/portforwarded | jq -r '.port' || true)
#   if [ -n "$PORT" ] && [ "$PORT" != "null" ]; then
#     echo "[entrypoint] Got forwarded port: $PORT"
#     break
#   fi
#   sleep 5
# done

# # Patch Transmission configuration
# CONFIG_DIR="/config"
# SETTINGS_JSON="$CONFIG_DIR/settings.json"

# if [ -f "$SETTINGS_JSON" ]; then
#   TMP=$(mktemp)
#   jq --argjson p "$PORT" '.["peer-port"]=$p' "$SETTINGS_JSON" > "$TMP" && mv "$TMP" "$SETTINGS_JSON"
# else
#   echo "{ \"peer-port\": $PORT }" > "$SETTINGS_JSON"
# fi
echo "[entrypoint] Starting gluetin..."
exec cd /
exec ./gluetun-entrypoint  &
echo "[entrypoint] Starting Transmission..."
exec transmission-daemon --foreground --config-dir /config 

