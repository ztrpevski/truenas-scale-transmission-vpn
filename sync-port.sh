#!/bin/sh
set -e

CONF_DIR="/config"
SETTINGS_JSON="$CONF_DIR/settings.json"

echo "[sync] Waiting for Gluetun forwarded port..."

while true; do
  PORT=$(curl -s http://localhost:8000/v1/openvpn/portforwarded | jq -r '.port' || true)
  if [ -n "$PORT" ] && [ "$PORT" != "null" ]; then
    echo "[sync] Got port: $PORT"
    break
  fi
  sleep 5
done

# Patch Transmission config
if [ -f "$SETTINGS_JSON" ]; then
  TMP=$(mktemp)
  jq --argjson p "$PORT" '.["peer-port"]=$p' "$SETTINGS_JSON" > "$TMP" && mv "$TMP" "$SETTINGS_JSON"
else
  echo "{ \"peer-port\": $PORT }" > "$SETTINGS_JSON"
fi
