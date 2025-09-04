#!/bin/bash
set -e

CONFIG_DIR="/config"
SETTINGS_JSON="$CONFIG_DIR/settings.json"

while true; do
  PORT=$(curl -s http://localhost:8000/v1/openvpn/portforwarded | jq -r '.port' || true)
  if [ -n "$PORT" ] && [ "$PORT" != "null" ]; then
    echo "[sync-port] Got forwarded port: $PORT"
    break
  fi
  sleep 5
done

# Patch Transmission configuration
if [ -f "$SETTINGS_JSON" ]; then
  TMP=$(mktemp)
  jq --argjson p "$PORT" '.["peer-port"]=$p' "$SETTINGS_JSON" > "$TMP" && mv "$TMP" "$SETTINGS_JSON"
else
  echo "{ \"peer-port\": $PORT }" > "$SETTINGS_JSON"
fi
