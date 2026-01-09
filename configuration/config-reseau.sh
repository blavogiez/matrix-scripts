#!/bin/bash
set -e

source "$(dirname "$0")/utils.sh"

# configure ip statique et dns

log_info "Configuration IP statique: $IP..."

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

log_success "IP statique configurée: $IP"

# configuration du serveur DNS
log_info "Installation de resolvconf..."
log_info "DEBIAN_FRONTEND=$DEBIAN_FRONTEND"
apt install -y resolvconf

# configuration temporaire
log_info "Configuration DNS..."
echo nameserver $DNS > /etc/resolv.conf

# redémarre interface
log_info "Redémarrage interface réseau..."
ifdown $INTERFACE 2>/dev/null
ifup $INTERFACE

log_success "Configuration réseau terminée"
log_info "Utilisez: ping -c 2 $GATEWAY"