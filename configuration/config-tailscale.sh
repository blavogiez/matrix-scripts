#!/bin/bash
set -e

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/../config.env"

log_info "Installation et configuration de Tailscale pour $(hostname)..."

# Vérifier si TAILSCALE_AUTH_KEY est défini
if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    log_error "La variable d'environnement TAILSCALE_AUTH_KEY n'est pas définie."
    log_error "Veuillez la définir dans votre environnement ou dans le fichier config.env."
    exit 1
fi

log_task "Ajout du dépôt Tailscale..."
curl -fsSL https://pkgs.tailscale.com/stable/debian/$(. /etc/os-release && echo $VERSION_CODENAME).noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
curl -fsSL https://pkgs.tailscale.com/stable/debian/$(. /etc/os-release && echo $VERSION_CODENAME).tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

log_task "Installation de Tailscale..."
apt-get update
apt-get install -y tailscale

log_task "Connexion au réseau Tailscale..."
# --ssh active le serveur SSH de Tailscale pour un accès facile
# On utilise la clé d'authentification pour ne pas avoir à se connecter manuellement
tailscale up --authkey="$TAILSCALE_AUTH_KEY" --ssh

# Activer le routage IP si nécessaire (par exemple, pour une exit node ou un subnet router)
# Pour ce cas d'usage, ce n'est probablement pas nécessaire, donc on le laisse commenté.
# echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
# echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.conf
# sudo sysctl -p /etc/sysctl.conf

log_success "Tailscale est configuré et connecté."

log_info "Adresse IP Tailscale de cette machine :"
tailscale ip -4
