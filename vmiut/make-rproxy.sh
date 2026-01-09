#!/bin/bash
source "$(dirname "$0")/../configuration/utils.sh"
source "$(dirname "$0")/../configuration/config.env"

log_info "Suppression ancienne VM rproxy..."
vmiut supprimer rproxy

set -e

log_info "Création VM rproxy..."
vmiut creer rproxy

log_info "Démarrage VM rproxy..."
vmiut demarrer rproxy

echo $PWD

TARGET_IP="${IP_PREFIX}.${IP_OCTET3}.${RPROXY_SUFFIX}"
log_info "Attente de la réponse de la VM ($TARGET_IP)..."
while ! ping -c 1 $TARGET_IP &> /dev/null; do
    sleep 1
done
log_success "VM accessible !"



log_info "Exécution du script de déploiement..."
export SCRIPT=scripts/vmiut/deploy-rproxy.sh 
vmiut executer rproxy
log_success "Déploiement terminé"
