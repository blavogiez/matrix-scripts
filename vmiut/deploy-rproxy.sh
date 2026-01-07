#!/bin/bash
# déploiement automatique de rproxy

wget -O /tmp/matrix-scripts.tar.gz https://gitlab.univ-lille.fr/baptiste.lavogiez.etu/matrix-scripts/-/archive/main/matrix-scripts-main.tar.gz && \
tar -xzf /tmp/matrix-scripts.tar.gz -C /tmp && \
cd /tmp/matrix-scripts-main/configuration && \
sed -i 's/^HOSTNAME=.*/HOSTNAME="rproxy"/' config.env && \
sed -i 's/^IP_SUFFIX=.*/IP_SUFFIX="2"/' config.env && \
bash setup-vm.sh
