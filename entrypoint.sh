#!/bin/bash
set -e

echo "[entrypoint] Starting Gluetun..."
/gluetun &   # Run Gluetun in the background
GLUETUN_PID=$!

# Wait for VPN port to be forwarded
echo "[entrypoint] Waiting for Gluetun forwarded port..."
/usr/local/bin/sync-port.sh

# Start Transmission in foreground
echo "[entrypoint] Starting Transmission..."
transmission-daemon --foreground --config-dir /config

# Wait for Gluetun (keeps container running if Gluetun exits)
wait $GLUETUN_PID
