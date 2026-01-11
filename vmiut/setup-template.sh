#!/bin/bash
set -e
# Template Phase 1 - %%SERVICE%% sera remplacé par sed (car on peut pas transmettre d'argument à la vm)

SERVICE=%%SERVICE%%
DIR="/tmp/matrix-scripts-main"
REPO="https://gitlab.univ-lille.fr/baptiste.lavogiez.etu/matrix-scripts/-/archive/main/matrix-scripts-main.tar.gz"

wget --tries=10 -O /tmp/matrix-scripts.tar.gz "$REPO" && \
tar -xzf /tmp/matrix-scripts.tar.gz -C /tmp
cd "$DIR/configuration"
source ../config.env

# map des variables setup selon le service
case $SERVICE in
    dns)     export HOSTNAME=$DNS_HOSTNAME;     export IP_SUFFIX=$DNS_SUFFIX ;;
    db)      export HOSTNAME=$DB_HOSTNAME;      export IP_SUFFIX=$DB_SUFFIX ;;
    matrix)  export HOSTNAME=$MATRIX_HOSTNAME;  export IP_SUFFIX=$MATRIX_SUFFIX ;;
    element) export HOSTNAME=$ELEMENT_HOSTNAME; export IP_SUFFIX=$ELEMENT_SUFFIX ;;
    rproxy)  export HOSTNAME=$RPROXY_HOSTNAME;  export IP_SUFFIX=$RPROXY_SUFFIX ;;
    backup)  export HOSTNAME=$BACKUP_HOSTNAME;  export IP_SUFFIX=$BACKUP_SUFFIX ;;
esac

bash setup-vm.sh
