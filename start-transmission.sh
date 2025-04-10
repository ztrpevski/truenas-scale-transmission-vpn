#!/bin/sh

echo "Starting Transmission..."
exec transmission-daemon \
    --config-dir /etc/transmission-daemon \
    --foreground
