# truenas-scale-transmission-vpn

# Set environment variables for Surfshark VPN with WireGuard
ENV VPN_SERVICE_PROVIDER="surfshark"

ENV VPN_TYPE="wireguard"

ENV SERVER_COUNTRIES=Netherlands

ENV WIREGUARD_PRIVATE_KEY="your_wireguard_private_key"


docker run -d --cap-add=NET_ADMIN --device /dev/net/tun --name surfshark-gluetun-transmission -p 9091:9091 -p 51413:51413 surfshark-gluetun-transmission
