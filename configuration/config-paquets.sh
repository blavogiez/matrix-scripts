#!/bin/bash

# installe les paquets de base

echo "mise à jour des dépôts apt..."
apt-get update

echo "installation des paquets: vim less tree rsync sudo..."
apt-get install -y vim less tree rsync sudo

echo "paquets installés avec succès"
