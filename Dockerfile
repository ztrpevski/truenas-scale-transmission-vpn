FROM qmcgaw/gluetun:latest

USER root

# Install Transmission and required tools
RUN apk add --no-cache \
    transmission-daemon transmission-cli \
    curl jq bash

# Create directories
RUN mkdir -p /config /watch

# Copy configuration and scripts
COPY settings.json /config/settings.json
COPY sync-port.sh /usr/local/bin/sync-port.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/sync-port.sh /usr/local/bin/entrypoint.sh

EXPOSE 9091

ENTRYPOINT  ["/usr/local/bin/entrypoint.sh && sh /gluetun-entrypoint"]
