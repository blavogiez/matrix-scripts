#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

get_status() {
    local etat=$(vmiut info "$1" 2>/dev/null | grep "^etat=" | cut -d'=' -f2)
    [ "$etat" = "running" ] && echo -e "${GREEN}[UP]${NC}" || echo -e "${RED}[DOWN]${NC}"
}

echo "--- Infrastructure matrix ---"
echo "DNS (dns) : $(get_status dns)"
echo "Base de données (db) : $(get_status db)"
echo "Synapse Matrix (matrix) : $(get_status matrix)"
echo "Element Web (element) : $(get_status element)"
echo "Reverse Proxy (rproxy) : $(get_status rproxy)"
echo "Backup Server (backup) : $(get_status backup)"
