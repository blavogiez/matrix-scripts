#!/bin/bash
set -e
source "$(dirname "$0")/../configuration/utils.sh"

log_info "Suppression ancienne VM db..."
vmiut supprimer db

log_info "Création VM db..."
vmiut creer db

log_info "Démarrage VM db..."
vmiut demarrer db

echo $PWD

log_info "standby 20S avant démarrage"
sleep 20



log_info "Exécution du script de déploiement..."
export SCRIPT=scripts/vmiut/deploy-db.sh 
vmiut executer db
log_success "Déploiement terminé"
