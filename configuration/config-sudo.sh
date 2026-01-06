#!/bin/bash

# configure sudo pour user

username=${1:-user}

echo "ajout de $username au groupe sudo..."
usermod -aG sudo $username

echo "$username ajouté au groupe sudo"
echo "reconnectez-vous pour appliquer les changements"
