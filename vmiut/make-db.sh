#!/bin/bash
source "$(dirname "$0")/../configuration/utils.sh"
source "$(dirname "$0")/../configuration/config.env"

log_info "Suppression ancienne VM db..."
vmiut supprimer db

set -e

log_info "Création VM db..."
vmiut creer db

log_info "Démarrage VM db..."
vmiut demarrer db

echo $PWD

TARGET_IP="${IP_PREFIX}.${IP_OCTET3}.${DB_SUFFIX}"
log_info "Attente de la réponse de la VM ($TARGET_IP)..."
while ! ping -c 1 $TARGET_IP &> /dev/null; do
    sleep 1
done
log_success "VM accessible !"



log_info "Exécution du script de déploiement..."
export SCRIPT=scripts/vmiut/deploy-db.sh 
vmiut executer db
log_success "Déploiement terminé"
