#!/bin/bash
set -e

CONFIG_DIR="/config"
SETTINGS_JSON="$CONFIG_DIR/settings.json"

echo "[entrypoint] Starting Gluetun..."
#/gluetun &   # run Gluetun in background
# GLUETUN_PID=$!

echo "[entrypoint] Starting Transmission..."
transmission-daemon --config-dir "$CONFIG_DIR" &
TRANSMISSION_PID=$!

# Background job: continuously check for forwarded port changes
# (
#   CURRENT_PORT=""

#   echo "[entrypoint] Watching for Gluetun forwarded port..."
#   while true; do
#     PORT=$(curl -s http://localhost:8000/v1/openvpn/portforwarded | jq -r '.port' || true)

#     if [ -n "$PORT" ] && [ "$PORT" != "null" ] && [ "$PORT" != "$CURRENT_PORT" ]; then
#       echo "[entrypoint] Forwarded port changed: $PORT"
#       CURRENT_PORT="$PORT"

#       # Update Transmission config file
#       if [ -f "$SETTINGS_JSON" ]; then
#         TMP=$(mktemp)
#         jq --argjson p "$PORT" '.["peer-port"]=$p' "$SETTINGS_JSON" > "$TMP" && mv "$TMP" "$SETTINGS_JSON"
#       else
#         echo "{ \"peer-port\": $PORT }" > "$SETTINGS_JSON"
#       fi

#       # Apply new port live to Transmission
#       echo "[entrypoint] Applying new port to Transmission..."
#       transmission-remote -p "$PORT" || echo "[entrypoint] Failed to update Transmission via RPC"
#     fi

#     sleep 30  # check every 30 seconds
#   done
# ) &

# Wait for either Gluetun or Transmission to exit
# wait -n $GLUETUN_PID $TRANSMISSION_PID
wait -n $TRANSMISSION_PID
