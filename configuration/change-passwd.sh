#!/bin/bash

# change le mot de passe d'un utilisateur

source "$(dirname "$0")/config.env"

echo "changement du mot de passe pour $DEFAULT_USER..."
echo "$DEFAULT_USER:$USER_PASS" | chpasswd
echo "mot de passe changé"
