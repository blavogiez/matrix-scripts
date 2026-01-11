#!/bin/bash

# Script à lancer depuis la machine physique : récolte le nom, puis le modifie dans la configuration sur le dépôt, et lance l'autoinstall sur dattier.

set -e

DIST="${1:-dattier}"
RUN_ID=$(date +%Y%m%d-%H%M%S-%N)

# Recup de l'octet 3 selon l'utilisateur etudiant (On check la plage moodle)
USER_NAME=$(whoami)
IP_OCTET3=$(grep "^${USER_NAME}=" "$(dirname "$0")/attribution-ip.env" | cut -d'=' -f2)

if [ -z "$IP_OCTET3" ]; then
    echo "Erreur: Aucune plage IP trouvée pour l'utilisateur $USER_NAME"
    exit 1
fi

echo "Utilisateur: $USER_NAME -> IP_OCTET3: $IP_OCTET3"

echo "Machine distante utilisée: $DIST"

# suppression du dossier temporaire (s'il existe)
rm -rvf /tmp/scripts 

# changement de la configuration pour la machine physique
git clone git@gitlab-ssh.univ-lille.fr:baptiste.lavogiez.etu/matrix-scripts.git /tmp/scripts
cd /tmp/scripts
sed -i -e 's/PHYS_HOSTNAME=".*"/PHYS_HOSTNAME='"$HOSTNAME"'/g' config.env
sed -i -e 's/IP_OCTET3=".*"/IP_OCTET3="'"$IP_OCTET3"'"/g' config.env

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# commit des changements
# suppression de set -e (au cas où le commit ne change rien)
set +e
git commit -a -m "Run #$RUN_ID: Config file change"
git push origin $GIT_BRANCH

cd
rm -rvf /tmp/scripts

# set -e
set -e

# exécution sur le serveur distant
ssh -t dattier "bash <(curl https://gitlab.univ-lille.fr/baptiste.lavogiez.etu/matrix-scripts/-/raw/main/orchestrate.sh?ref_type=heads)"


