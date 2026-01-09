#!/bin/bash
set -e
source "$(dirname "$0")/configuration/utils.sh"

# Définition des valeurs par défaut
DEFAULT_SERVER="dattier.iutinfo.fr"
DEFAULT_LOGIN="$(whoami)"
SERVER=""
LOGIN=""
AUTO_RSA=0 # 0 = Demande, 1 = Oui, 2 = Non
AUTO_COPY=0 # 0 = Demande, 1 = Oui, 2 = Non
AUTO_CONFIG=0 # 0 = Demande, 1 = Oui, 2 = Non

# Fonction d'aide
usage() {
    echo "Usage: $0 [-s <adresse_serveur>] [-l <login>] [-r|--no-rsa] [-c|--no-copy] [-a|--no-config]"
    echo ""
    echo "Options :"
    echo "  -s, --server <adresse>  Adresse du serveur (Défaut: $DEFAULT_SERVER)"
    echo "  -l, --login <login>     Votre login (Défaut: $DEFAULT_LOGIN)"
    echo "  -r, --rsa               Créer et copier la clé RSA automatiquement (Sans confirmation)"
    echo "  --no-rsa                Ne pas créer la clé RSA (Sans confirmation)"
    echo "  -c, --copy              Copier la clé distante automatiquement (Implique -r, mais si la clé existe déjà)"
    echo "  --no-copy               Ne pas copier la clé distante (Implique --no-rsa si la clé n'existe pas)"
    echo "  -a, --config            Ajouter à la config SSH (~/.ssh/config) automatiquement"
    echo "  --no-config             Ne pas ajouter à la config SSH (~/.ssh/config) automatiquement"
    echo "  -h, --help              Afficher cette aide"
    exit 1
}

# --- Parsing des arguments ---

# Utilisation de getopts pour les options courtes.
# Les options longues nécessitent une gestion manuelle ou une boucle while séparée (plus simple ici pour éviter 'getopt').
while getopts ":s:l:rcha-:" opt; do
    case ${opt} in
        s )
            SERVER=$OPTARG
            ;;
        l )
            LOGIN=$OPTARG
            ;;
        r )
            AUTO_RSA=1
            AUTO_COPY=1
            ;;
        c )
            AUTO_COPY=1
            ;;
        a )
            AUTO_CONFIG=1
            ;;
        h )
            usage
            ;;
        - ) # Gestion des options longues
            case "${OPTARG}" in
                server)
                    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    SERVER=$val
                    ;;
                login)
                    val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                    LOGIN=$val
                    ;;
                rsa)
                    AUTO_RSA=1
                    AUTO_COPY=1
                    ;;
                no-rsa)
                    AUTO_RSA=2
                    AUTO_COPY=2 # Si on ne crée pas, on ne copie pas non plus
                    ;;
                copy)
                    AUTO_COPY=1
                    ;;
                no-copy)
                    AUTO_COPY=2
                    ;;
                config)
                    AUTO_CONFIG=1
                    ;;
                no-config)
                    AUTO_CONFIG=2
                    ;;
                help)
                    usage
                    ;;
                *)
                    if [ "$OPTERR" = 1 ] && [ "${opt:0:1}" != ":" ]; then
                        echo "Option invalide: --$OPTARG" >&2
                        usage
                    fi
                    ;;
            esac
            ;;
        \? )
            echo "Option invalide: -$OPTARG" >&2
            usage
            ;;
        : )
            echo "Option -$OPTARG requiert un argument." >&2
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Si non spécifié, utilise la valeur par défaut
SERVER=${SERVER:-$DEFAULT_SERVER}
LOGIN=${LOGIN:-$DEFAULT_LOGIN}

log_info "Configuration SSH pour Dattier"
log_info "Serveur: $SERVER"
log_info "Login: $LOGIN"
echo ""

log_info "Ce script va configurer l'accès SSH au serveur $SERVER pour le login $LOGIN."

# Test Connexion
while true; do
    echo ""
    log_task "Test de la connexion SSH au serveur Dattier"
    log_info "Commande: ssh $LOGIN@$SERVER echo 'Connexion réussie!'"

    # Using short timeout in order not to block everything
    ssh -o ConnectTimeout=5 $LOGIN@$SERVER echo 'Connexion réussie!'

    if [[ "$?" == 0 ]]; then
        log_success "Connexion SSH OK."
        break
    else
        log_error "La connexion a échoué."

        # If in interactive mode, asking then retrying if incorrect
        if [[ "$1" == "" && "$2" == "" ]]; then
            read -r -p "Essayer avec une nouvelle configuration? [y/N] " test
            if [[ "$test" =~ ^[Yy]$ ]]; then
                read -r -p "Entrez l'adresse du serveur [${SERVER}]: " new_serv
                SERVER=${new_serv:-$SERVER}
                read -r -p "Entrez votre login [${LOGIN}]: " new_login
                LOGIN=${new_login:-$LOGIN}
            else
                exit 1
            fi
        else
            # In non-interactive mode, exit if it fails
            log_error "Arrêt du script car la connexion a échoué avec les arguments fournis."
            exit 1
        fi
    fi
done

# RSA Key
if [[ $AUTO_RSA == 0 ]]; then
    read -r -p "Créer une clé privée RSA? [Y/n] " rsa
    if [[ "$rsa" =~ ^[Nn]$ ]]; then
        AUTO_RSA=2
    else
        AUTO_RSA=1
    fi
fi

if [[ $AUTO_RSA == 1 ]]; then
    echo ""
    log_task "Génération de la clé RSA (ssh-keygen)"

    ssh-keygen -t rsa

    if [[ "$?" != "0" ]]; then
        log_error "La clé n'a pas pu être générée. On continue quand même."
    else
        log_success "Clé RSA générée."

        # --- Copie de la Clé ---
        if [[ $AUTO_COPY == 0 ]]; then
            read -r -p "Copier la clé publique sur le serveur distant ($LOGIN@$SERVER)? [Y/n] " copy
            if [[ "$copy" =~ ^[Nn]$ ]]; then
                AUTO_COPY=2
            else
                AUTO_COPY=1
            fi
        fi

        if [[ $AUTO_COPY == 1 ]]; then
            echo ""
            log_task "Copie de la clé distante (ssh-copy-id)"
            ssh-copy-id "$LOGIN@$SERVER"

            if [[ "$?" != "0" ]]; then
                log_error "La clé n'a pas pu être copiée. Vérifiez le mot de passe."
            else
                log_success "Clé publique copiée. Vous devriez pouvoir vous connecter sans mot de passe maintenant."
            fi
        fi
    fi
fi

# SSH Config
if [[ $AUTO_CONFIG == 0 ]]; then
    read -r -p "Ajouter 'dattier' à la configuration SSH (~/.ssh/config)? [Y/n] " config
    if [[ "$config" =~ ^[Nn]$ ]]; then
        AUTO_CONFIG=2
    else
        AUTO_CONFIG=1
    fi
fi

if [[ $AUTO_CONFIG == 1 ]]; then
    # Simple verification in order to avoid adding the same host multiple times
    if grep -q "Host dattier" ~/.ssh/config 2>/dev/null; then
        log_warning "L'hôte 'dattier' est déjà dans ta config SSH. Je ne fais rien."
    else
        echo ""
        log_task "Ajout de la configuration à ~/.ssh/config"

        # Utilisation de HERE document pour écrire plusieurs lignes proprement
        cat << EOF >> ~/.ssh/config

Host dattier
    HostName $SERVER
    User $LOGIN
EOF
        log_success "Configuration ajoutée. Tu peux te connecter avec : ssh dattier"
    fi
fi

echo ""
log_success "Le script a bien été exécuté."
