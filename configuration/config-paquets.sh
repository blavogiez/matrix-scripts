#!/bin/bash
set -e

source "$(dirname "$0")/utils.sh"

# installe les paquets de base

log_info "Mise à jour des dépôts apt..."
apt-get update

log_info "Installation des paquets: vim curl tree rsync bats..."
apt-get install -y vim curl tree rsync bats

log_success "Paquets installés avec succès"