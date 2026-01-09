#!/bin/bash
set -e
source "$(dirname "$0")/../configuration/utils.sh"

# script pour créer et démarrer une vm

if [ -z "$1" ]; then
    log_error "Usage: $0 nom_vm"
    exit 1
fi

nom_vm=$1

log_info "Création de la vm $nom_vm..."
vmiut creer $nom_vm

log_info "Démarrage de la vm $nom_vm..."
vmiut demarrer $nom_vm

log_success "VM $nom_vm créée et démarrée"
log_info "Utilisez auto-log.sh $nom_vm pour vous connecter"