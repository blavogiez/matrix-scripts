#!/bin/bash

# attente ip et connexion ssh automatique

if [ -z "$1" ]; then
    echo "usage: $0 nom_vm"
    exit 1
fi

nom_vm=$1
delai=10
max_essais=12
essai=0

echo "attente de l'ip pour $nom_vm..."

while [ $essai -lt $max_essais ]; do
    essai=$((essai + 1))
    temps_ecoule=$((essai * delai))

    # récupère l'ip depuis vmiut info
    ip_line=$(vmiut info $nom_vm | grep "ip-potentielle")
    ip=$(echo $ip_line | cut -d'=' -f2)

    if [ -n "$ip" ] && [ "$ip" != "" ]; then
        echo "ip trouvée: $ip"
        echo "connexion ssh..."
        ssh user@$ip
        exit 0
    fi

    echo "pas d'ip après ${temps_ecoule}s, on réessaie..."
    sleep $delai
done

echo "erreur: pas d'ip après $((max_essais * delai))s"
exit 1
