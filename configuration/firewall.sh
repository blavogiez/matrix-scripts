#!/bin/bash
set -e

source "$(dirname "$0")/utils.sh"
source "$(dirname "$0")/../config.env"

log_info "Configuration firewall pour $(hostname) !"

apt-get install -f -y ufw

ufw --force reset

ufw default deny incoming
ufw default allow outgoing

NETWORK="10.42.0.0/16"
VM_SUBNET="$IP_PREFIX.$IP_OCTET3"

MATRIX_IP="$VM_SUBNET.$MATRIX_SUFFIX"
RPROXY_IP="$VM_SUBNET.$RPROXY_SUFFIX"
DB_IP="$VM_SUBNET.$DB_SUFFIX"
ELEMENT_IP="$VM_SUBNET.$ELEMENT_SUFFIX"
DNS_IP="$VM_SUBNET.$DNS_SUFFIX"
BACKUP_IP="$VM_SUBNET.$BACKUP_SUFFIX"

ufw allow from $NETWORK to any port 22 proto tcp

case "$(hostname)" in
    dns)
        log_task "regles DNS: 53/tcp+udp depuis les VMs"
        ufw allow from $VM_SUBNET.0/24 to any port 53 proto tcp
        ufw allow from $VM_SUBNET.0/24 to any port 53 proto udp
        ;;
    db)
        log_task "regles DB: 5432 depuis matrix uniquement"
        ufw allow from $MATRIX_IP to any port 5432 proto tcp
        ;;
    matrix)
        log_task "regles Matrix: 8008 depuis rproxy uniquement"
        ufw allow from $RPROXY_IP to any port 8008 proto tcp
        ;;
    element)
        log_task "regles Element: 80 depuis rproxy uniquement"
        ufw allow from $RPROXY_IP to any port 80 proto tcp
        ;;
    rproxy)
        log_task "regles Rproxy: 80/tcp depuis anywhere"
        ufw allow 80/tcp
        ;;
    backup)
        log_task "regles Backup: SSH uniquement"
        ;;
    *)
        log_warning "Hostname inconnu: $(hostname), regles par défaut"
        ;;
esac

ufw --force enable

log_success "Firewall activé"
log_info "regles actuelles:"
ufw status numbered
