#!/bin/bash
# Dashboard d'état des VMs avec rafraîchissement automatique (pour suivre l'installation)

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # 


check_vm_state() {
    local name=$1
    local vm_name=$2
    local etat=$(vmiut info "$vm_name" 2>/dev/null | grep "^etat=" | cut -d'=' -f2)
    if [ "$etat" = "running" ]; then
        echo -e "$name ($vm_name) : ${GREEN}[UP]${NC}"
    else
        echo -e "$name ($vm_name) : ${RED}[DOWN]${NC}"
    fi
}

# boucle
while true; do
    clear

    # chrono depuis debut
    minutes=$((SECONDS / 60))
    seconds=$((SECONDS % 60))

    echo "--- Infrastructure matrix ---"
    echo "Date: $(date)"
    printf "Temps d'analyse: %02d:%02d\n" $minutes $seconds
    echo "------------------------------"

    # Vérification des VMs
    check_vm_state "DNS"             "dns"
    check_vm_state "Base de données" "db"
    check_vm_state "Synapse Matrix"  "matrix"
    check_vm_state "Element Web"     "element"
    check_vm_state "Reverse Proxy"   "rproxy"
    check_vm_state "Backup Server"   "backup"

    echo "------------------------------"
    echo "Appuyez sur Ctrl+C pour quitter"

    sleep 1
done
