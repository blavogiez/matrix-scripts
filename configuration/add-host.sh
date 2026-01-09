#!/bin/bash
set -e

# ajoute une entrée dans /etc/hosts

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "usage: $0 nom_host ip_host"
    echo "exemple: $0 matrix 10.42.110.1"
    exit 1
fi

nom=$1
ip=$2

echo "ajout de l'entrée: $ip    $nom"
echo "$ip    $nom" >> /etc/hosts

echo "entrée ajoutée dans /etc/hosts"
echo "vérifiez avec: ping -c 2 $nom"
