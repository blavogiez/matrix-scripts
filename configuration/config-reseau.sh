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

# configuration du serveur DNS
log_info "Installation de resolvconf..."
log_info "DEBIAN_FRONTEND=$DEBIAN_FRONTEND"
apt install -y resolvconf

# resolvconf va automatiquement générer /etc/resolv.conf
# basé sur la directive dns-nameservers dans /etc/network/interfaces


log_info "Configuration IP statique: $IP..."

log_info "On éteint enp0s3"
ifdown $INTERFACE


# configure /etc/network/interfaces
if [ "$HOSTNAME" == "dns" ]; then
    cat > /etc/network/interfaces << EOF
# Configuration de l'interface réseau

auto lo
iface lo inet loopback

allow-hotplug $INTERFACE
iface $INTERFACE inet static
    address $IP
    netmask $NETMASK
    gateway $GATEWAY
    dns-nameservers $GATEWAY
    pre-up /usr/bin/sleep 5
EOF
else
    cat > /etc/network/interfaces << EOF
# Configuration de l'interface réseau

auto lo
iface lo inet loopback

allow-hotplug $INTERFACE
iface $INTERFACE inet static
    address $IP
    netmask $NETMASK
    gateway $GATEWAY
    dns-nameservers $DNS
    pre-up /usr/bin/sleep 5
EOF
fi



log_success "IP statique configurée: $IP"

# redémarre interface
log_info "Redémarrage interface réseau..."
ifup $INTERFACE

log_success "Configuration réseau terminée"
log_info "Utilisez: ping -c 2 $GATEWAY"