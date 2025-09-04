# Base: Gluetun (qmcgaw/gluetun)
FROM qmcgaw/gluetun:latest

# Install Transmission and utilities
RUN apk add --no-cache transmission-daemon transmission-cli supervisor curl jq

# Create config directories
RUN mkdir -p /config/transmission /downloads /watch /scripts


# Copy sync script
COPY sync-port.sh /scripts/sync-port.sh
RUN chmod +x /scripts/sync-port.sh
COPY settings.json ./config/transmission/settings.json

# Expose Transmission web UI
EXPOSE 9091

# Volumes for persistence
VOLUME /config /downloads /watch

# Supervisor config
RUN printf "[supervisord]\nnodaemon=true\n\n" > /etc/supervisord.conf && \
    printf "[program:gluetun]\ncommand=/gluetun\npriority=1\nautostart=true\nautorestart=true\n\n" >> /etc/supervisord.conf && \
    printf "[program:sync-port]\ncommand=/scripts/sync-port.sh\npriority=2\nautostart=true\nautorestart=true\n\n" >> /etc/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]


