#!/bin/bash

# configure sudo pour user

source "$(dirname "$0")/config.env"

echo "ajout de $DEFAULT_USER au groupe sudo..."
usermod -aG sudo $DEFAULT_USER

echo "$DEFAULT_USER ajouté au groupe sudo"
echo "reconnectez-vous pour appliquer les changements"
