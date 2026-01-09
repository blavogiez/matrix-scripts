#!/bin/bash
set -e

source "$(dirname "$0")/utils.sh"

# affichage des informations
log_info "====================="
log_info "CONFIGURATION RÉSEAU" 
log_info "---------------------------------------------------------------"
log_info "IP: $IP"
log_info "INTERFACE: $INTERFACE"
log_info "GATEWAY: $GATEWAY"
log_info "NETMASK: $NETMASK"
log_info "DNS: $DNS"
log_info "DEBIAN-FRONTEND: $DEBIAN_FRONTEND"
log_info "====================="

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
EOF



log_success "IP statique configurée: $IP"

# configuration du serveur DNS
log_info "Installation de resolvconf..."
log_info "DEBIAN_FRONTEND=$DEBIAN_FRONTEND"
apt install -y resolvconf

# configuration temporaire
log_info "Configuration DNS..."


# configuration dynamique (en fonction de hostname /= dns)
if [ "$HOSTNAME" == "dns" ]; then 
    echo "dns-nameservers $GATEWAY"
    echo nameserver $GATEWAY > /etc/resolv.conf
else
    echo "dns-nameservers $DNS"
    echo nameserver $DNS > /etc/resolv.conf
fi

# redémarre interface
log_info "Redémarrage interface réseau..."
ifdown $INTERFACE 2>/dev/null
ifup $INTERFACE

log_success "Configuration réseau terminée"
log_info "Utilisez: ping -c 2 $GATEWAY"