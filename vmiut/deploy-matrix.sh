#!/bin/bash
set -e
# déploiement automatique de matrix

# phase 1 : config
wget -O /tmp/matrix-scripts.tar.gz https://gitlab.univ-lille.fr/baptiste.lavogiez.etu/matrix-scripts/-/archive/main/matrix-scripts-main.tar.gz 
tar -xzf /tmp/matrix-scripts.tar.gz -C /tmp 
cd /tmp/matrix-scripts-main/configuration 


export HOSTNAME=$MATRIX_HOSTNAME
export IP_SUFFIX=$MATRIX_SUFFIX

bash setup-vm.sh

# phase 2 : installation du service spécialisé
# on utilise les scripts du dossier associé au service dans le repo git obtenu
cd ../matrix 
bash install.sh 
# testing post-installation

bats tests/test.bats && \
rm -rf /tmp/*