#!/bin/bash
source "$(dirname "$0")/../configuration/utils.sh"

log_info "Suppression ancienne VM matrix..."
vmiut supprimer matrix

set -e

log_info "Création VM matrix..."
vmiut creer matrix

log_info "Démarrage VM matrix..."
vmiut demarrer matrix

echo $PWD

log_info "standby 30S avant démarrage"
sleep 30



log_info "Exécution du script de déploiement..."
export SCRIPT=scripts/vmiut/deploy-matrix.sh 
vmiut executer matrix
log_success "Déploiement terminé"
