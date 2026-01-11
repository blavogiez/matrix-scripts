#!/bin/bash

# Orchestration 2 phases depuis dattier
# phase 1: Setup parallèle de toutes les VMs (création + config réseau + firewall + hostname + packages + sudo)
# phase 2: Installation et configuration des services spécialisés avec dépendances
# Enfin, tout est testé

SESSION="matrix_deploy"
REPO_URL="https://gitlab.univ-lille.fr/baptiste.lavogiez.etu/matrix-scripts"
SCRIPT_PATH="scripts/vmiut"

# phase 2 : Installation avec dépendances
# dans cette phase certaines installations doivent attendre la fin des autres. Par exemple, Synapse a besoin que DB soit fini pour tester que la création d'un utilisateur marche
phase2_install() {
    tmux wait-for phase1_complete

    # Layout: P0: dns | P1: backup | P2: db | P3: matrix | P4: element | P5: rproxy | P6: dashboard
    # DNS d'abord (les autres en ont besoin)
    tmux send-keys -t "$SESSION:0.0" "$SCRIPT_PATH/make-vm.sh dns install && tmux wait-for -S dns_ready" C-m
    tmux wait-for dns_ready

    # Backup + Element en parallèle (indépendants)
    tmux send-keys -t "$SESSION:0.1" "$SCRIPT_PATH/make-vm.sh backup install && tmux wait-for -S backup_ready" C-m
    tmux send-keys -t "$SESSION:0.4" "$SCRIPT_PATH/make-vm.sh element install && tmux wait-for -S element_ready" C-m

    # DB doit attendre backup car il en a besoin pour ses tests
    tmux send-keys -t "$SESSION:0.2" "tmux wait-for backup_ready && $SCRIPT_PATH/make-vm.sh db install && tmux wait-for -S db_ready" C-m

    # Matrix attend DB
    tmux send-keys -t "$SESSION:0.3" "tmux wait-for db_ready && $SCRIPT_PATH/make-vm.sh matrix install && tmux wait-for -S matrix_ready" C-m

    # Rproxy en dernier (après matrix et element)
    tmux send-keys -t "$SESSION:0.5" "tmux wait-for matrix_ready && tmux wait-for element_ready && $SCRIPT_PATH/make-vm.sh rproxy install && tmux wait-for -S rproxy_ready" C-m
}

# reset session
if tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "Reset de la session précédente..."
    tmux kill-session -t "$SESSION"
    sleep 1
fi

echo "Démarrage de l'orchestration 2 phases..."
tmux new-session -d -s "$SESSION"

# Clone le repo d'abord
tmux send-keys -t "$SESSION:0" "rm -rf scripts && git clone $REPO_URL scripts && clear" C-m

sleep 3

# phase 1 : Setup parallèle (6 VMs)
# Création de la grille 3x2 + dashboard
#
# ┌─────────┬─────────┐
# │   dns   │  backup │  (P0 | P1)
# ├─────────┼─────────┤
# │   db    │  matrix │  (P2 | P3)
# ├─────────┼─────────┤
# │ element │  rproxy │  (P4 | P5)
# ├─────────┴─────────┤
# │     dashboard     │  (P6)
# └───────────────────┘

# Grille 3x2 + dashboard
tmux split-window -h -t "$SESSION:0"
tmux split-window -v -p 67 -t "$SESSION:0.0"
tmux split-window -v -p 50 -t "$SESSION:0.2"
tmux split-window -v -p 67 -t "$SESSION:0.1"
tmux split-window -v -p 50 -t "$SESSION:0.4"
tmux select-layout -t "$SESSION:0" tiled
tmux split-window -v -f -l 1 -t "$SESSION:0"

# Lancement du setup parallèle (P0: dns | P1: backup | P2: db | P3: matrix | P4: element | P5: rproxy | P6: dashboard)
tmux send-keys -t "$SESSION:0.0" "$SCRIPT_PATH/make-vm.sh dns setup && tmux wait-for -S dns_setup" C-m
tmux send-keys -t "$SESSION:0.1" "$SCRIPT_PATH/make-vm.sh backup setup && tmux wait-for -S backup_setup" C-m
tmux send-keys -t "$SESSION:0.2" "$SCRIPT_PATH/make-vm.sh db setup && tmux wait-for -S db_setup" C-m
tmux send-keys -t "$SESSION:0.3" "$SCRIPT_PATH/make-vm.sh matrix setup && tmux wait-for -S matrix_setup" C-m
tmux send-keys -t "$SESSION:0.4" "$SCRIPT_PATH/make-vm.sh element setup && tmux wait-for -S element_setup" C-m
tmux send-keys -t "$SESSION:0.5" "$SCRIPT_PATH/make-vm.sh rproxy setup && tmux wait-for -S rproxy_setup" C-m
tmux send-keys -t "$SESSION:0.6" "watch -n 1 --color 'scripts/dashboard.sh'" C-m

# attendre tous les setup en background puis lancer phase 2
(
    for vm in dns db matrix element rproxy backup; do
        tmux wait-for ${vm}_setup
    done
    echo "Phase 1 complete! Lancement phase 2..."
    tmux wait-for -S phase1_complete
) &

# lancer phase 2 en background (attend phase1_complete)
phase2_install &

# Connexion à la session
exec tmux attach-session -t "$SESSION"
