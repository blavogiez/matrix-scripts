#!/bin/bash
set -e

# configure ip statique et dns

# Paramètres
# IP: Adresse IP
# NETMASK : Masque de sous-réseau
# GATEWAY : Passerelle (routeur) par défaut
# DNS : Serveur DNS

echo "configuration ip statique: $IP..."

# configure /etc/network/interfaces
cat > /etc/network/interfaces << EOF
# Configuration de l'interface réseau

auto lo
iface lo inet loopback

allow-hotplug $INTERFACE
iface $INTERFACE inet static
    address $IP
    netmask $NETMASK
    gateway $GATEWAY
    pre-up /usr/bin/sleep 5
    dns-nameservers $DNS
EOF

echo "ip statique configurée: $ip"

# configuration du serveur DNS
apt install -y resolvconf

# configuration temporaire
echo nameserver $DNS > /etc/resolv.conf

# redémarre interface
echo "redémarrage interface réseau..."
ifdown $INTERFACE 2>/dev/null
ifup $INTERFACE

echo "configuration réseau terminée"
echo "utilisez: ping -c 2 $GATEWAY"
