#!/bin/sh

CONFIG_DIR="/etc/transmission-daemon"
CONFIG_FILE="$CONFIG_DIR/settings.json"

echo "Starting Transmission..."

# Start transmission daemon in the background
nohup transmission-daemon \
    --config-dir "$CONFIG_DIR" \
    --foreground &

# Continue with other tasks, or exit the script
echo "Transmission started in the background."
