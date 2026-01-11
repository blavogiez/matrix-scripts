#!/bin/bash
set -e

# change le mot de passe d'un utilisateur

source "$(dirname "$0")/../config.env"
source "$(dirname "$0")/utils.sh"

log_info "Changement du mot de passe pour $DEFAULT_USER..."
echo "$DEFAULT_USER:$USER_PASS" | chpasswd
echo "root:$ROOT_PASS" | chpasswd
log_success "Mots de passe changés"
