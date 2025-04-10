#!/bin/sh

CONFIG_DIR="/etc/transmission-daemon"
CONFIG_FILE="$CONFIG_DIR/settings.json"

echo "Starting Transmission..."

# Optional: Create config if missing
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating default config..."
    transmission-daemon --config-dir "$CONFIG_DIR" --foreground &
    sleep 5
    killall transmission-daemon
    sleep 1
fi

# Start in foreground, let it block
exec transmission-daemon \
    --config-dir "$CONFIG_DIR" \
    --foreground
