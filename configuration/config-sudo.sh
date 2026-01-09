#!/bin/bash

# configure sudo pour user

source "$(dirname "$0")/config.env"

echo "ajout de $USER au groupe sudo..."
usermod -aG sudo $USER

echo "$USER ajouté au groupe sudo"
echo "reconnectez-vous pour appliquer les changements"
