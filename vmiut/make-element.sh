#!/bin/bash
source "$(dirname "$0")/../configuration/utils.sh"
source "$(dirname "$0")/../configuration/config.env"

log_info "Suppression ancienne VM element..."
vmiut supprimer element

set -e

log_info "Création VM element..."
vmiut creer element

log_info "Démarrage VM element..."
vmiut demarrer element

echo $PWD

TARGET_IP="${IP_PREFIX}.${IP_OCTET3}.${ELEMENT_SUFFIX}"
log_info "Attente de la réponse de la VM ($TARGET_IP)..."
while ! ping -c 1 $TARGET_IP &> /dev/null; do
    sleep 1
done
log_success "VM accessible !"



log_info "Exécution du script de déploiement..."
export SCRIPT=scripts/vmiut/deploy-element.sh 
vmiut executer element
log_success "Déploiement terminé"
