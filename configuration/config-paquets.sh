#!/bin/bash

# installe les paquets de base


echo "mise à jour des dépôts apt..."
apt-get update

echo "installation des paquets: vim curl tree rsync..."
apt-get install -y vim curl tree rsync

echo "paquets installés avec succès"
