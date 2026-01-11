#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

update_status() {
    local line=$1
    local col=$2
    local vm_name=$3
    local etat=$(vmiut info "$vm_name" 2>/dev/null | grep "^etat=" | cut -d'=' -f2)
    echo -ne "\033[${line};${col}H\033[K"
    if [ "$etat" = "running" ]; then
        echo -e "${GREEN}[UP]${NC}"
    else
        echo -e "${RED}[DOWN]${NC}"
    fi
}

clear
echo "--- Infrastructure matrix ---"
echo "Date: $(date)"
echo "Temps d'analyse: 00:00"
echo "------------------------------"
echo "DNS (dns) :"
echo "Base de données (db) :"
echo "Synapse Matrix (matrix) :"
echo "Element Web (element) :"
echo "Reverse Proxy (rproxy) :"
echo "Backup Server (backup) :"
echo "------------------------------"
echo "Appuyez sur Ctrl+C pour quitter"

while true; do
    minutes=$((SECONDS / 60))
    seconds=$((SECONDS % 60))
    echo -ne "\033[2;7H$(date)\033[K"
    printf "\033[3;18H%02d:%02d" $minutes $seconds
    update_status 5 14 "dns"
    update_status 6 23 "db"
    update_status 7 24 "matrix"
    update_status 8 20 "element"
    update_status 9 22 "rproxy"
    update_status 10 22 "backup"
    sleep 1
done
