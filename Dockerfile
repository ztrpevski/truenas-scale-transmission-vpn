FROM qmcgaw/gluetun:latest

# Install dependencies
RUN apk add --no-cache transmission-daemon curl jq bash

# Create necessary directories
RUN mkdir -p /config/transmission /watch /scripts

# Copy sync script
COPY sync-port.sh /scripts/sync-port.sh
RUN chmod +x /scripts/sync-port.sh

# Expose web UI (optional, mapped via Gluetun port forwarding)
EXPOSE 9091


# Entrypoint: sync port then start Transmission
ENTRYPOINT ["/scripts/sync-port.sh"]
