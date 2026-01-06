#!/bin/bash

# configure ip statique et dns

source "$(dirname "$0")/config.env"

ip="$IP_PREFIX.$IP_OCTET3.$IP_SUFFIX"

echo "configuration ip statique: $ip..."

# configure /etc/network/interfaces
cat > /etc/network/interfaces << EOF
# Configuration de l'interface réseau

allow-hotplug $INTERFACE
iface $INTERFACE inet static
    address $ip
    netmask $NETMASK
    gateway $GATEWAY
    pre-up /usr/bin/sleep 5
EOF

echo "ip statique configurée: $ip"

# configure dns
echo "nameserver $DNS" > /etc/resolv.conf
echo "dns configuré: $DNS"

# redémarre interface
echo "redémarrage interface réseau..."
ifdown $INTERFACE 2>/dev/null
ifup $INTERFACE

echo "configuration réseau terminée"
echo "utilisez: ping -c 2 $GATEWAY"
