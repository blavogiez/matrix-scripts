#!/bin/bash
source "$(dirname "$0")/../configuration/utils.sh"
source "$(dirname "$0")/../config.env"

log_info "Suppression ancienne VM element..."
vmiut supprimer element

set -e

log_info "Création VM element..."
vmiut creer element

log_info "Démarrage VM element..."
vmiut demarrer element

echo $PWD

log_info "standby 30S avant démarrage"
sleep 30



log_info "Exécution du script de déploiement..."
export SCRIPT=scripts/vmiut/deploy-element.sh 
vmiut executer element
log_success "Déploiement terminé"
