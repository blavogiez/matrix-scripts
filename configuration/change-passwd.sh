#!/bin/bash
set -e

# change le mot de passe d'un utilisateur

echo "changement du mot de passe pour $USER..."
echo "$USER:$USER_PWD" | chpasswd
echo "root:$ROOT_PWD" | chpasswd
echo "Mot de passe changé"