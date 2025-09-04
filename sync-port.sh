#!/bin/sh
set -e

RPC_HOST=localhost
RPC_PORT=9091
RPC_USER=${TRANSMISSION_USER:-""}
RPC_PASS=${TRANSMISSION_PASS:-""}

CONF_DIR=/config/transmission
SETTINGS_JSON="$CONF_DIR/settings.json"

wait_for_port() {
    while true; do
        PORT=$(curl -s http://localhost:8000/v1/openvpn/portforwarded | jq -r '.port')
        if [ -n "$PORT" ] && [ "$PORT" != "null" ]; then
            echo "Got forwarded port: $PORT"
            echo $PORT
            return
        else
            echo "Waiting for forwarded port from Gluetun..."
            sleep 10
        fi
    done
}

# Wait until Gluetun provides a port
FORWARDED_PORT=$(wait_for_port)

# Update settings.json peer-port before starting Transmission
if [ -f "$SETTINGS_JSON" ]; then
    echo "Patching $SETTINGS_JSON with peer-port $FORWARDED_PORT"
    # Use jq to safely update JSON
    tmpfile=$(mktemp)
    jq --argjson port "$FORWARDED_PORT" '.["peer-port"]=$port' "$SETTINGS_JSON" > "$tmpfile" && mv "$tmpfile" "$SETTINGS_JSON"
else
    echo "No settings.json found at $SETTINGS_JSON, creating a minimal one"
    echo "{ \"peer-port\": $FORWARDED_PORT }" > "$SETTINGS_JSON"
fi

# Start Transmission with the updated config
echo "Starting Transmission on port $FORWARDED_PORT"
transmission-daemon \
    --foreground \
    --config-dir "$CONF_DIR" \
    --download-dir /downloads \
    --watch-dir /watch &

TRANS_PID=$!

# Keep syncing port every 5 minutes in case ProtonVPN changes it
while kill -0 $TRANS_PID 2>/dev/null; do
    NEW_PORT=$(curl -s http://localhost:8000/v1/openvpn/portforwarded | jq -r '.port')

    if [ -n "$NEW_PORT" ] && [ "$NEW_PORT" != "null" ] && [ "$NEW_PORT" != "$FORWARDED_PORT" ]; then
        echo "Port changed: updating Transmission to $NEW_PORT"
        # Update settings.json
        tmpfile=$(mktemp)
        jq --argjson port "$NEW_PORT" '.["peer-port"]=$port' "$SETTINGS_JSON" > "$tmpfile" && mv "$tmpfile" "$SETTINGS_JSON"
        # Update live session via RPC
        SESSION_ID=$(curl -si --anyauth --user "$RPC_USER:$RPC_PASS" "$RPC_HOST:$RPC_PORT/transmission/rpc" | sed -n 's/X-Transmission-Session-Id: //p' | tr -d '\r')
        curl -s --anyauth --user "$RPC_USER:$RPC_PASS" \
          --header "X-Transmission-Session-Id: $SESSION_ID" \
          -d "{\"method\":\"session-set\",\"arguments\":{\"peer-port\":$NEW_PORT}}" \
          "$RPC_HOST:$RPC_PORT/transmission/rpc" > /dev/null
        FORWARDED_PORT=$NEW_PORT
    fi

    sleep 300
done
