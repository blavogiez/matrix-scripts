#!/bin/bash

# script de configuration complète d'une vm

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "usage: $0 nom_vm xx suffixe"
    echo "exemple: $0 matrix 110 1"
    exit 1
fi

nom_vm=$1
xx=$2
suffixe=$3
ip="10.42.$xx.$suffixe"

echo "========================================="
echo "configuration de la vm: $nom_vm"
echo "ip: $ip"
echo "========================================="
echo ""

# 1. installation des paquets
echo "# 1. installation des paquets..."
./config-paquets.sh
echo ""

# 2. configuration réseau
echo "# 2. configuration réseau..."
./config-reseau.sh $xx $suffixe
echo ""

# 3. configuration hostname
echo "# 3. configuration hostname..."
hostname $nom_vm
echo "$nom_vm" > /etc/hostname
sed -i "s/127.0.1.1.*/127.0.1.1    $nom_vm/" /etc/hosts
echo "hostname configuré: $nom_vm"
echo ""

# 4. configuration /etc/hosts pour architecture b
echo "# 4. configuration /etc/hosts (architecture b)..."
./add-host.sh db 10.42.$xx.3
./add-host.sh matrix 10.42.$xx.1
./add-host.sh element 10.42.$xx.4
./add-host.sh rproxy 10.42.$xx.2
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
ping -c 2 10.42.0.1 > /dev/null 2>&1
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
echo "vm: $nom_vm"
echo "ip: $ip"
echo "hostname: $(hostname)"
echo ""
echo "reconnectez-vous pour appliquer sudo"
echo "nouvelle ip: ssh user@$ip"
echo "========================================="
