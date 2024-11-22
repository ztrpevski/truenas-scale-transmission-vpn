# Use the Gluetun image as the base image
FROM qmcgaw/gluetun:latest

# Set environment variables for Surfshark VPN with WireGuard
ENV VPNSP="surfshark"
ENV WIREGUARD_PRIVATE_KEY="your_wireguard_private_key"
ENV WIREGUARD_ADDRESSES="your_wireguard_addresses"
ENV WIREGUARD_ENDPOINT="your_wireguard_endpoint"
ENV WIREGUARD_PUBLIC_KEY="your_wireguard_public_key"
ENV WIREGUARD_PRESHARED_KEY="your_wireguard_preshared_key"

# Install Transmission
RUN apk update && apk add --no-cache transmission-daemon

# Copy Transmission configuration file (optional, replace with your specific configuration file)
COPY settings.json /etc/transmission-daemon/settings.json

# Create a script to start Transmission
RUN echo '#!/bin/sh\n\
transmission-daemon --foreground --config-dir /etc/transmission-daemon' > /start-transmission.sh \
    && chmod +x /start-transmission.sh

# Expose Transmission ports
EXPOSE 9091 51413

# Start Gluetun and Transmission
CMD ["/start-transmission.sh"]
