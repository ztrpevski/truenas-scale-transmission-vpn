FROM qmcgaw/gluetun:latest

RUN  apk add --no-cache transmission-daemon curl jq bash


# Copy settings.json and sync-port.sh
COPY settings.json /config/settings.json
COPY sync-port.sh /usr/local/bin/sync-port.sh
RUN chmod +x /usr/local/bin/sync-port.sh

# Use entrypoint to run your sync-port script (which waits for port and starts transmission)
ENTRYPOINT ["/usr/local/bin/sync-port.sh"]
