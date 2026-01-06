#!/bin/bash

# installe les paquets de base

source "$(dirname "$0")/config.env"

echo "mise à jour des dépôts apt..."
apt-get update

echo "installation des paquets: $PACKAGES..."
apt-get install -y $PACKAGES

echo "paquets installés avec succès"
