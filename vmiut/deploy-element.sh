#!/bin/bash
# déploiement automatique de element

# phase 1 : config
wget -O /tmp/matrix-scripts.tar.gz https://gitlab.univ-lille.fr/baptiste.lavogiez.etu/matrix-scripts/-/archive/main/matrix-scripts-main.tar.gz && \
tar -xzf /tmp/matrix-scripts.tar.gz -C /tmp && \
cd /tmp/matrix-scripts-main/configuration && \
sed -i 's/^HOSTNAME=.*/HOSTNAME="element"/' config.env && \
sed -i 's/^IP_SUFFIX=.*/IP_SUFFIX="4"/' config.env && \
bash setup-vm.sh

# phase 2 : installation du service spécialisé
# on utilise les scripts du dossier associé au service dans le repo git obtenu
