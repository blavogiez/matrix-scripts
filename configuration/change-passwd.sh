#!/bin/bash

# change le mot de passe d'un utilisateur

username=${1:-user}

echo "changement du mot de passe pour $username..."
passwd $username
