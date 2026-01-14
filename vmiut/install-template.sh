#!/bin/bash
set -e
# Template Phase 2 - %%SERVICE%% sera remplacé par sed (car on peut pas transmettre d'argument à la vm)

SERVICE=%%SERVICE%%
DIR="/tmp/matrix-scripts-main"

cd "$DIR"
source config.env

# Test DNS (déplacé ici car DNS doit être installé en Phase 2 avant les autres)
ping -c 1 google.com || echo "Warning: DNS not resolving"

# Dépendances spécifiques pour les tests
case $SERVICE in
    matrix) apt install -y postgresql-client ;;
esac

cd "$SERVICE/"
bash install.sh

# Tests post-installation
bats tests/test.bats

# On change les mot de passe à la fin pour que VBoxManage puisse encore s'authentifier par le biais de vmiut executer (on a du le faire 2 fois), sinon il aurait pas pu car il utilise les mots de passe par défaut
cd "$DIR/configuration"
./change-passwd.sh
./firewall.sh

rm -rf /tmp/*
