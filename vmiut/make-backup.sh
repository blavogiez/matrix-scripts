#!/bin/bash
source "$(dirname "$0")/../configuration/utils.sh"

log_info "Suppression ancienne VM backup..."
vmiut supprimer backup

set -e

log_info "Création VM backup..."
vmiut creer backup

log_info "Démarrage VM backup..."
vmiut demarrer backup

echo $PWD

log_info "standby 30S avant démarrage"
sleep 30

log_info "Exécution du script de déploiement..."
export SCRIPT=scripts/vmiut/deploy-backup.sh
vmiut executer backup
log_success "Déploiement terminé"
