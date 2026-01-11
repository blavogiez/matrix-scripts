#!/bin/bash
set -e

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/../config.env"

# installe les paquets de base

log_info "Mise à jour des dépôts apt..."
apt-get update

log_info "Installation des paquets: $PACKAGES..."
apt-get install -y $PACKAGES

log_success "Paquets installés avec succès"