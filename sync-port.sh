#!/bin/bash
set -e

CONF_DIR=/config/transmission
SETTINGS_JSON="$CONF_DIR/settings.json"
RPC_USER=${TRANSMISSION_USER:-transmission}
RPC_PASS=${TRANSMISSION_PASS:-pwd}

# Wait until Gluetun container has assigned a forwarded port
wait_for_port() {
    while true; do
        # Gluetun exposes forwarded port via its API
        PORT=$(curl -s http://gluetun:8000/v1/openvpn/portforwarded | jq -r '.port')
        if [ -n "$PORT" ] && [ "$PORT" != "null" ]; then
            echo "Forwarded port from VPN: $PORT"
            echo $PORT
            return
        else
            echo "Waiting for forwarded port from Gluetun..."
            sleep 10
        fi
    done
}

FORWARDED_PORT=$(wait_for_port)

# Patch settings.json with the forwarded port
if [ -f "$SETTINGS_JSON" ]; then
    echo "Updating peer-port in settings.json to $FORWARDED_PORT"
    tmpfile=$(mktemp)
    jq --argjson port "$FORWARDED_PORT" '.["peer-port"]=$port' "$SETTINGS_JSON" > "$tmpfile" && mv "$tmpfile" "$SETTINGS_JSON"
else
    echo "No settings.json found, creating minimal one"
    echo "{ \"peer-port\": $FORWARDED_PORT }" > "$SETTINGS_JSON"
fi

# Start Transmission
echo "Starting Transmission with peer-port $FORWARDED_PORT"
transmission-daemon --foreground --config-dir "$CONF_DIR" --download-dir /mnt/downloads --watch-dir /watch &

TRANS_PID=$!

# Monitor Gluetun port changes every 5 min
while kill -0 $TRANS_PID 2>/dev/null; do
    NEW_PORT=$(curl -s http://gluetun:8000/v1/openvpn/portforwarded | jq -r '.port')
    if [ "$NEW_PORT" != "$FORWARDED_PORT" ] && [ "$NEW_PORT" != "null" ]; then
        echo "Port changed: updating Transmission to $NEW_PORT"
        tmpfile=$(mktemp)
        jq --argjson port "$NEW_PORT" '.["peer-port"]=$port' "$SETTINGS_JSON" > "$tmpfile" && mv "$tmpfile" "$SETTINGS_JSON"

        SESSION_ID=$(curl -si --anyauth --user "$RPC_USER:$RPC_PASS" "http://127.0.0.1:9091/transmission/rpc" \
          | sed -n 's/X-Transmission-Session-Id: //p' | tr -d '\r')

        curl -s --anyauth --user "$RPC_USER:$RPC_PASS" \
          --header "X-Transmission-Session-Id: $SESSION_ID" \
          -d "{\"method\":\"session-set\",\"arguments\":{\"peer-port\":$NEW_PORT}}" \
          "http://127.0.0.1:9091/transmission/rpc" > /dev/null

        FORWARDED_PORT=$NEW_PORT
    fi
    sleep 300
done
