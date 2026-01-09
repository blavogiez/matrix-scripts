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

log_info "StandBY 5S avant démarrage"
sleep 5



log_info "Exécution du script de déploiement..."
SCRIPT=deploy-db.sh vmiut executer db
log_success "Déploiement terminé"
