#!/bin/bash

DIST={$1:"dattier"} 
RUN_ID=$(date +%Y%m%d-%H%M%S-%N)

echo "Machine distante utilisée: $DIST"

# changement de la configuration pour la machine physique
git clone git@gitlab-ssh.univ-lille.fr:baptiste.lavogiez.etu/matrix-scripts.git /tmp/scripts
cd /tmp/scripts
sed -e 's/PHYS_HOSTNAME=".*"/PHYS_HOSTNAME='"$HOSTNAME"'/g' configuration/config.env

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# commit des changements
git commit -a -m "Run #$RUN_ID: Config file change"
git push origin $GIT_BRANCH

# exécution sur le serveur distant

ssh $DIST << EOF
curl https://gitlab.univ-lille.fr/baptiste.lavogiez.etu/matrix-scripts/-/raw/main/orchestrate.sh?ref_type=heads | bash
EOF


