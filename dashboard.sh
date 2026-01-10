#!/bin/bash
# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# on test 2 chemins
source configuration/config.env
source scripts/configuration/config.env


echo "--- INFRASTRUCTURE STATUS ---"
echo "Date: $(date)"
echo "------------------------------"

check_port() {
    local name=$1
    local ip=$2
    local port=$3
    # On teste le port avec timeout de 1s
    nc -z -w 1 "$ip" "$port" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "$name ($ip:$port) : ${GREEN}[UP]${NC}"
    else
        echo -e "$name ($ip:$port) : ${RED}[DOWN]${NC}"
    fi
}

# Liste des services
check_port "DNS" "$IP_PREFIX.$IP_OCTET3.$DNS_SUFFIX" 53
check_port "Base de données" "$IP_PREFIX.$IP_OCTET3.$DB_SUFFIX" 5432
check_port "Synapse Matrix"  "$IP_PREFIX.$IP_OCTET3.$MATRIX_SUFFIX" 8008
check_port "Element Web"     "$IP_PREFIX.$IP_OCTET3.$ELEMENT_SUFFIX" 80
check_port "Reverse Proxy" "$IP_PREFIX.$IP_OCTET3.$RPROXY_SUFFIX" 80
