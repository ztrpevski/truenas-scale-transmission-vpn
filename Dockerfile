# Use the Gluetun image as the base image
FROM qmcgaw/gluetun:latest

# Set environment variables for Surfshark VPN with WireGuard
ENV VPN_SERVICE_PROVIDER="surfshark"
ENV VPN_TYPE="wireguard"
ENV SERVER_COUNTRIES="Netherlands"
ENV WIREGUARD_PRIVATE_KEY="your_wireguard_private_key"

RUN apk add --no-cache --upgrade bash
# Install Transmission
RUN apk update && apk add --no-cache transmission-daemon

# Copy Transmission configuration file (optional, replace with your specific configuration file)
COPY settings.json /etc/transmission-daemon/settings.json
COPY start-transmission.sh start-transmission.sh
RUN chmod +x start-transmission.sh

# Expose Transmission ports
EXPOSE 9091 51413

# Start Gluetun and Transmission
CMD ["sh", "start-transmission.sh"]
