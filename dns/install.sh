#!/bin/bash
set -e

source "$(dirname "$0")/../configuration/utils.sh"

log_info "Installation de dnsmasq" 

apt install -y dnsmasq

log_info "Configuration de dnsmasq"

cat > /etc/dnsmasq.conf << EOF

interface=enp0s3
# Utiliser le fichier hosts local pour les réponses DNS
expand-hosts
# Serveur DNS externe (la passerelle) pour les requêtes internet
server=10.42.0.1
# Ne pas lire /etc/resolv.conf (optionnel, pour éviter les boucles)
no-resolv

EOF

log_info "Redémarrage du service dnamasq"

systemctl restart dnsmasq
