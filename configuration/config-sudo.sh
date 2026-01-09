#!/bin/bash
set -e

# configure sudo pour user

source "$(dirname "$0")/config.env"
source "$(dirname "$0")/utils.sh"

log_info "Ajout de $DEFAULT_USER au groupe sudo..."
usermod -aG sudo $DEFAULT_USER

log_success "$DEFAULT_USER ajouté au groupe sudo"
log_info "Reconnectez-vous pour appliquer les changements"