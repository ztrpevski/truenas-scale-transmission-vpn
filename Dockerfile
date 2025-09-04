FROM qmcgaw/gluetun:latest

# Install Transmission and tools
USER root
RUN apk add --no-cache transmission-daemon transmission-cli curl jq bash sh supervisor

# Create directories
RUN mkdir -p /config /watch

# Copy settings.json
COPY settings.json /config/settings.json

# Copy sync script
COPY sync-port.sh /usr/local/bin/sync-port.sh
RUN chmod +x /usr/local/bin/sync-port.sh

# Copy supervisord config to run both processes
COPY supervisord.conf /etc/supervisord.conf

# Expose Transmission Web UI
EXPOSE 9091

CMD /usr/bin/supervisord -c /etc/supervisord.conf
