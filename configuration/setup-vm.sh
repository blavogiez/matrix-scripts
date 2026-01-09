#!/bin/bash
set -e

# script de configuration complète d'une vm
# On configure pleinement la vm avant d'installer ses services spécifiques. C'est la préparation/setup
# donc on réutilise les scripts du dossier afin d'être modulaire

source "$(dirname "$0")/config.env"
source "$(dirname "$0")/utils.sh"

# reconstruction ip selon parametres
export IP=$IP_PREFIX.$IP_OCTET3.$IP_SUFFIX

log_info "======================================="
log_info "Configuration de la vm: $HOSTNAME"
log_info "IP cible: $IP"
log_info "======================================="
echo 

# 1. installation des paquets
log_task "1. Installation des paquets..."
./config-paquets.sh
echo

# 2. configuration réseau
log_task "2. Configuration réseau..."
./config-reseau.sh
echo

# 3. configuration hostname
log_task "3. Configuration hostname..."
hostname $HOSTNAME
echo "$HOSTNAME" > /etc/hostname
sed -i "s/127.0.1.1.*/127.0.1.1    $HOSTNAME/" /etc/hosts
log_success "Hostname configuré: $HOSTNAME"
echo


# 5. configuration sudo
log_task "5. Configuration sudo..."
./config-sudo.sh
echo

# 6. changement mot de passe
log_task "6. Changement mot de passe user..."
./change-passwd.sh
echo

# 7. vérifications finales
log_task "7. Vérifications finales..."
log_info "Test connectivité passerelle..."
ping -c 2 $GATEWAY > /dev/null 2>&1
if [ $? -eq 0 ]; then
    log_success "Passerelle accessible"
else
    log_error "Passerelle non accessible"
fi

log_info "Test résolution DNS..."
ping -c 2 google.com > /dev/null 2>&1
if [ $? -eq 0 ]; then
    log_success "DNS fonctionnel"
else
    log_error "DNS non fonctionnel"
fi
echo

# récapitulatif
log_info "========================================="
log_success "Configuration terminée"
log_info "========================================="
log_info "VM: $HOSTNAME"
log_info "IP: $IP"
log_info "Hostname: $(hostname)"
echo
log_info "Reconnectez-vous pour appliquer sudo"
log_info "Nouvelle IP: ssh $DEFAULT_USER@$IP"
log_info "========================================="