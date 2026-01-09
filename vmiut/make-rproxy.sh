#!/bin/bash
source "$(dirname "$0")/../configuration/utils.sh"

log_info "Suppression ancienne VM rproxy..."
vmiut supprimer rproxy

set -e

log_info "Création VM rproxy..."
vmiut creer rproxy

log_info "Démarrage VM rproxy..."
vmiut demarrer rproxy

echo $PWD

log_info "standby 20S avant démarrage"
sleep 20



log_info "Exécution du script de déploiement..."
export SCRIPT=scripts/vmiut/deploy-rproxy.sh 
vmiut executer rproxy
log_success "Déploiement terminé"
