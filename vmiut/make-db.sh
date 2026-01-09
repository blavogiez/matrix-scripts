#!/bin/bash
set -e
vmiut supprimer db
vmiut creer db
vmiut demarrer db
export SCRIPT=deploy-db.sh # chemin depuis la racine dattier (identique à celui des vboxes)
vmiut executer db