#!/bin/bash
set -e
source "$(dirname "$0")/../configuration/utils.sh"

log_info "Suppression ancienne VM db..."
vmiut supprimer db

log_info "Création VM db..."
vmiut creer db

log_info "Démarrage VM db..."
vmiut demarrer db

log_info "Exécution du script de déploiement..."
export SCRIPT=deploy-db.sh # chemin depuis la racine dattier (identique à celui des vboxes)
vmiut executer db
log_success "Déploiement terminé"
