#!/bin/bash
source "$(dirname "$0")/../configuration/utils.sh"

log_info "Suppression ancienne VM dns..."
vmiut supprimer dns

set -e

log_info "Création VM dns..."
vmiut creer dns

log_info "Démarrage VM dns..."
vmiut demarrer dns

echo $PWD

log_info "standby 20S avant démarrage"
sleep 20



log_info "Exécution du script de déploiement..."
export SCRIPT=scripts/vmiut/deploy-dns.sh 
vmiut executer dns
log_success "Déploiement terminé"
