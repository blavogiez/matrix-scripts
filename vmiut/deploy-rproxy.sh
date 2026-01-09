#!/bin/bash
set -e
# déploiement automatique de rproxy

REPO="https://gitlab.univ-lille.fr/baptiste.lavogiez.etu/matrix-scripts/-/archive/main/matrix-scripts-main.tar.gz"
DIR="/tmp/matrix-scripts-main"

apt-get install -y curl

curl -fL --retry 3 --progress-bar -o /tmp/matrix-scripts.tar.gz "$REPO" && \
tar -xzf /tmp/matrix-scripts.tar.gz -C /tmp
cd "$DIR/configuration" 

source ./config.env


export HOSTNAME=$RPROXY_HOSTNAME
export IP_SUFFIX=$RPROXY_SUFFIX

bash setup-vm.sh

# phase 2 : installation du service spécialisé
# on utilise les scripts du dossier associé au service dans le repo git obtenu
cd ../rproxy 
bash install.sh 
# testing post-installation

bats tests/test.bats && \
rm -rf /tmp/*