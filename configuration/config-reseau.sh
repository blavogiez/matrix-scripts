#!/bin/bash

# configure ip statique et dns

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "usage: $0 xx suffixe"
    echo "exemple: $0 110 1"
    exit 1
fi

xx=$1
suffixe=$2
ip="10.42.$xx.$suffixe"

echo "configuration ip statique: $ip..."

# configure /etc/network/interfaces
cat > /etc/network/interfaces << EOF
# Configuration de l'interface réseau

allow-hotplug enp0s3
iface enp0s3 inet static
    address $ip
    netmask 255.255.0.0
    gateway 10.42.0.1
    pre-up /usr/bin/sleep 5
EOF

echo "ip statique configurée: $ip"

# configure dns
echo "nameserver 10.42.0.1" > /etc/resolv.conf
echo "dns configuré: 10.42.0.1"

# redémarre interface
echo "redémarrage interface réseau..."
ifdown enp0s3 2>/dev/null
ifup enp0s3

echo "configuration réseau terminée"
echo "utilisez: ping -c 2 10.42.0.1"
