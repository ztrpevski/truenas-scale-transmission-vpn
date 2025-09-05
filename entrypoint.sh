#!/bin/bash
set -e

CONFIG_DIR="/config"
SETTINGS_JSON="$CONFIG_DIR/settings.json"

echo "[entrypoint] Starting Gluetun..."
/gluetun &   # run Gluetun binary in background
GLUETUN_PID=$!

echo "[entrypoint] Starting Transmission..."
transmission-daemon --config-dir "$CONFIG_DIR" &
TRANSMISSION_PID=$!

# Background job to sync forwarded port once Gluetun is ready
(
  echo "[entrypoint] Waiting for Gluetun forwarded port..."
  while true; do
    PORT=$(curl -s http://localhost:8000/v1/openvpn/portforwarded | jq -r '.port' || true)
    if [ -n "$PORT" ] && [ "$PORT" != "null" ]; then
      echo "[entrypoint] Got forwarded port: $PORT"

      if [ -f "$SETTINGS_JSON" ]; then
        TMP=$(mktemp)
        jq --argjson p "$PORT" '.["peer-port"]=$p' "$SETTINGS_JSON" > "$TMP" && mv "$TMP" "$SETTINGS_JSON"
      else
        echo "{ \"peer-port\": $PORT }" > "$SETTINGS_JSON"
      fi

      # Reload Transmission with new port
      echo "[entrypoint] Updating Transmission to new port..."
      transmission-remote -p "$PORT" || echo "[entrypoint] Failed to update Transmission via RPC"
      break
    fi
    sleep 5
  done
) &

# Wait for either process to exit
wait -n $GLUETUN_PID $TRANSMISSION_PID
