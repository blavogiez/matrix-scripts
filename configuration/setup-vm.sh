#!/bin/bash

# script de configuration complète d'une vm

source "$(dirname "$0")/config.env"

ip="$IP_PREFIX.$IP_OCTET3.$IP_SUFFIX"

echo "========================================="
echo "configuration de la vm: $HOSTNAME"
echo "ip: $ip"
echo "========================================="
echo ""

# 1. installation des paquets
echo "# 1. installation des paquets..."
./config-paquets.sh
echo ""

# 2. configuration réseau
echo "# 2. configuration réseau..."
./config-reseau.sh
echo ""

# 3. configuration hostname
echo "# 3. configuration hostname..."
hostname $HOSTNAME
echo "$HOSTNAME" > /etc/hostname
sed -i "s/127.0.1.1.*/127.0.1.1    $HOSTNAME/" /etc/hosts
echo "hostname configuré: $HOSTNAME"
echo ""

# 4. configuration /etc/hosts pour architecture b
echo "# 4. configuration /etc/hosts (architecture b)..."
./add-host.sh db $IP_PREFIX.$IP_OCTET3.$DB_SUFFIX
./add-host.sh matrix $IP_PREFIX.$IP_OCTET3.$MATRIX_SUFFIX
./add-host.sh element $IP_PREFIX.$IP_OCTET3.$ELEMENT_SUFFIX
./add-host.sh rproxy $IP_PREFIX.$IP_OCTET3.$RPROXY_SUFFIX
echo ""

# 5. configuration sudo
echo "# 5. configuration sudo..."
./config-sudo.sh
echo ""

# 6. changement mot de passe
echo "# 6. changement mot de passe user..."
./change-passwd.sh
echo ""

# 7. vérifications finales
echo "# 7. vérifications finales..."
echo "test connectivité passerelle..."
ping -c 2 $GATEWAY > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "  ok: passerelle accessible"
else
    echo "  erreur: passerelle non accessible"
fi

echo "test résolution dns..."
ping -c 2 google.com > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "  ok: dns fonctionnel"
else
    echo "  erreur: dns non fonctionnel"
fi
echo ""

# récapitulatif
echo "========================================="
echo "configuration terminée"
echo "========================================="
echo "vm: $HOSTNAME"
echo "ip: $ip"
echo "hostname: $(hostname)"
echo ""
echo "reconnectez-vous pour appliquer sudo"
echo "nouvelle ip: ssh $DEFAULT_USER@$ip"
echo "========================================="
