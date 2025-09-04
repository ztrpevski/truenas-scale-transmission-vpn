#!/bin/sh
set -e

# Wait for Gluetun to assign port
while [ -z "$(curl -s http://gluetun:8000/v1/openvpn/portforwarded | grep port)" ]; do
  echo "Waiting for VPN port..."
  sleep 5
done

PORT=$(curl -s http://gluetun:8000/v1/openvpn/portforwarded | jq -r '.port')
echo "Forwarded port: $PORT"

# Update Transmission settings.json
jq --arg port "$PORT" '.["peer-port"] = ($port | tonumber)' /config/settings.json > /config/settings.json.tmp
mv /config/settings.json.tmp /config/settings.json

# Start Transmission
exec /init
