#!/bin/bash

# script pour créer et démarrer une vm

if [ -z "$1" ]; then
    echo "usage: $0 nom_vm"
    exit 1
fi

nom_vm=$1

echo "création de la vm $nom_vm..."
vmiut creer $nom_vm

echo "démarrage de la vm $nom_vm..."
vmiut demarrer $nom_vm

echo "vm $nom_vm créée et démarrée"
echo "utilisez auto-log.sh $nom_vm pour vous connecter"
