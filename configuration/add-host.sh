#!/bin/bash
set -e

source "$(dirname "$0")/utils.sh"

# ajoute une entrée dans /etc/hosts

if [ -z "$1" ] || [ -z "$2" ]; then
    log_error "Usage: $0 nom_host ip_host"
    log_info "Exemple: $0 matrix 10.42.110.1"
    exit 1
fi

nom=$1
ip=$2

log_info "Ajout de l'entrée: $ip    $nom"
echo "$ip    $nom" >> /etc/hosts

log_success "Entrée ajoutée dans /etc/hosts"
log_info "Vérifiez avec: ping -c 2 $nom"