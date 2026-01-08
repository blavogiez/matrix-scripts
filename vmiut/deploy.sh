#!/bin/bash
# déploiement automatique de db
# phase 1 : config
set -euo pipefail

# arguments du script
SERVICE_NAME="${1:-db}"        # 1er argument, défaut "db"
IP_SUFFIX="${2:-3}"            # 2e argument, défaut "3"
HOSTNAME_PREFIX="${3:-}"       # 3e argument, optionnel

echo $SERVICE_NAME

REPO="https://gitlab.univ-lille.fr/baptiste.lavogiez.etu/matrix-scripts/-/archive/main/matrix-scripts-main.tar.gz"
DIR="/tmp/matrix-scripts-main"

apt-get install -y curl
curl -fL --retry 3 --progress-bar -o /tmp/matrix-scripts.tar.gz "$REPO" && \
tar -xzf /tmp/matrix-scripts.tar.gz -C /tmp && \
cd "$DIR/configuration" && \
sed -i.bak \
  -e "s/^HOSTNAME=.*/HOSTNAME=\"${HOSTNAME_PREFIX}${SERVICE_NAME}\"/" \
  -e "s/^IP_SUFFIX=.*/IP_SUFFIX=\"${IP_SUFFIX}\"/" \
  config.env && \
bash setup-vm.sh && \
cd ../"$SERVICE_NAME" && \
bash install.sh && \
# testing post-installation
bats tests/test.bats && \
# suppression des traces
rm -rf /tmp/*