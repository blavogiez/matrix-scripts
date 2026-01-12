#!/bin/bash
# tableau d'état des vm (suivre rapidement l'état de l'installation)

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[0;33m' # Added for clarity in warnings

# --- Configuration ---
# Infrastructure network settings
IP_PREFIX="10.42"
IP_OCTET3="123"

# Static VM configured with Tailscale, to be used as a relay
STATIC_VM_IP="$IP_PREFIX.$IP_OCTET3.254"
REMOTE_USER="user" # User for SSH connection to the static VM

# VM suffixes and hostnames for display and checking
DNS_SUFFIX="5"
DB_SUFFIX="3"
MATRIX_SUFFIX="1"
ELEMENT_SUFFIX="4"
RPROXY_SUFFIX="2"
BACKUP_SUFFIX="6"

DNS_HOSTNAME="dns"
DB_HOSTNAME="db"
MATRIX_HOSTNAME="matrix"
ELEMENT_HOSTNAME="element"
RPROXY_HOSTNAME="rproxy"
BACKUP_HOSTNAME="backup"


echo "--- INFRASTRUCTURE STATUS (via SSH to static VM at $STATIC_VM_IP) ---"
echo "Date: $(date)"
echo "---------------------------------------------------"

# Vérifier si ssh et jq sont installés sur la machine locale
if ! command -v ssh &> /dev/null; then
    echo -e "${RED}Erreur: 'ssh' n'est pas installé ou non trouvé dans le PATH.${NC}"
    exit 1
fi


# Commande SSH pour se connecter à la VM statique
SSH_CMD="ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 ${REMOTE_USER}@${STATIC_VM_IP}"

# Récupérer le status de tailscale en JSON, via SSH sur la VM statique
TS_STATUS=$($SSH_CMD "tailscale status --json")

if [ -z "$TS_STATUS" ]; then
    echo -e "${RED}Erreur: Impossible de récupérer le status de Tailscale depuis la VM statique ($STATIC_VM_IP).${NC}"
    echo "Assurez-vous que la VM est accessible via SSH pour l'utilisateur '$REMOTE_USER' et que Tailscale y est fonctionnel."
    exit 1
fi

# Fonction pour récupérer l'IP Tailscale d'un peer par son nom d'hôte
get_ts_ip() {
    local hostname_param=$1
    echo "$TS_STATUS" | $SSH_CMD "jq -r --arg name '$hostname_param' '.Peer[] | select(.HostName == \$name) | .TailscaleIPs[0]'"
}

# Fonction pour vérifier la disponibilité d'un port sur une VM du tailnet
check_port() {
    local service_name=$1
    local local_ip_for_display=$2
    local port=$3
    local vm_hostname=$4

    local ts_ip
    ts_ip=$(get_ts_ip "$vm_hostname")

    if [ -z "$ts_ip" ];
    then
        echo -e "$service_name ($local_ip_for_display:$port) : ${YELLOW}[ABSENT]${NC} (VM '$vm_hostname' non trouvée sur le réseau Tailscale)"
        return
    fi

    # On exécute le test de port via le SSH de Tailscale, lui-même appelé via SSH sur la VM statique
    # La commande 'tailscale ssh' se connecte en tant que root sur la VM de destination par défaut.
    if $SSH_CMD "tailscale ssh '$vm_hostname' -- -o 'StrictHostKeyChecking=no' 'nc -z -w 1 localhost $port'" > /dev/null 2>&1; then
        echo -e "$service_name ($local_ip_for_display:$port) : ${GREEN}[UP]${NC}"
    else
        echo -e "$service_name ($local_ip_for_display:$port) : ${RED}[DOWN]${NC}"
    fi
}

# --- Vérification des services ---
check_port "DNS"             "$IP_PREFIX.$IP_OCTET3.$DNS_SUFFIX"     53   "$DNS_HOSTNAME"
check_port "Base de données" "$IP_PREFIX.$IP_OCTET3.$DB_SUFFIX"      5432 "$DB_HOSTNAME"
check_port "Synapse Matrix"  "$IP_PREFIX.$IP_OCTET3.$MATRIX_SUFFIX"  8008 "$MATRIX_HOSTNAME"
check_port "Element Web"     "$IP_PREFIX.$IP_OCTET3.$ELEMENT_SUFFIX" 80   "$ELEMENT_HOSTNAME"
check_port "Reverse Proxy"   "$IP_PREFIX.$IP_OCTET3.$RPROXY_SUFFIX"  80   "$RPROXY_HOSTNAME"
# Le serveur de backup est aussi une VM, on peut vérifier son port SSH
check_port "Backup Server"   "$IP_PREFIX.$IP_OCTET3.$BACKUP_SUFFIX"  22   "$BACKUP_HOSTNAME"

echo "---------------------------------------------------"