#!/bin/bash
# Usage: make-vm.sh <service> [setup|install]
# Génère dynamiquement le script avec sed et l'exécute via vmiut (car on peut pas transmettre d'argument à la vm)

# setup = on configure le réseau, le hostname, de façon générale (Donc parallélisation possible)
# install = on installe le service spécialisé et on le configure (Parallélisation impossible puisque par exemple Matrix a besoin de DB por être testée)

source "$(dirname "$0")/../configuration/utils.sh"
source "$(dirname "$0")/../config.env"

SERVICE=$1
ACTION=${2:-setup}
TEMPLATE_DIR="$(dirname "$0")"

if [ -z "$SERVICE" ]; then
    log_error "Usage: $0 <service> [setup|install]"
    log_error "Services: dns, db, matrix, element, rproxy, backup"
    exit 1
fi

# Générer le script avec sed (remplace %%SERVICE%% par le nom du service)
GENERATED_SCRIPT="/tmp/${ACTION}-${SERVICE}.sh"
sed "s/%%SERVICE%%/$SERVICE/g" "$TEMPLATE_DIR/${ACTION}-template.sh" > "$GENERATED_SCRIPT"
chmod +x "$GENERATED_SCRIPT"

case $ACTION in
    setup) 
        log_info "Suppression ancienne VM $SERVICE..."
        vmiut supprimer $SERVICE 2>/dev/null || true

        set -e

        log_info "Création VM $SERVICE..."
        vmiut creer $SERVICE

        log_info "Démarrage VM $SERVICE..."
        vmiut demarrer $SERVICE

        log_info "Standy 30s apres demarrage pour éviter bug VirtualBox"
        sleep 30

        log_info "Exécution du script de setup..."
        export SCRIPT="$GENERATED_SCRIPT"
        vmiut executer $SERVICE
        log_success "Phase 1 : Setup $SERVICE terminé"
        ;;
    install)
        set -e
        log_info "Installation service $SERVICE..."
        export SCRIPT="$GENERATED_SCRIPT"
        vmiut executer $SERVICE
        log_success "Service $SERVICE installé"
        ;;
    *)
        log_error "Action inconnue: $ACTION (setup ou install)"
        exit 1
        ;;
esac
