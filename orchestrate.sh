#!/bin/bash

# Run tmux depuis dattier, lancé automatiquement par dist-launch.sh

# configuration (par souci de dynamicité)
SESSION="matrix_deploy"
REPO_URL="https://gitlab.univ-lille.fr/baptiste.lavogiez.etu/matrix-scripts"
SCRIPT_PATH="scripts/vmiut"

orchestrate_infra() {

    # on attend que la VM DNS soit configurée avant de passer à la suite
    tmux wait-for dns_ready

    # disivion de l'espace de travail
    tmux split-window -v -t "$SESSION:0.0"
    tmux split-window -v -b -l 6 -t "$SESSION:0.1"
    tmux resize-pane -t "$SESSION:0.0" -U 6
    tmux split-window -h -t "$SESSION:0.0"
    tmux split-window -h -t "$SESSION:0.3"

    # résultat de la disivion :
    #
    # P0 | P1
    # -------
    #   P2
    # -------
    # P3 | P4
    #

    # exécution des commandes (ordre séquentiel)

    # P0: Base de données (après backup)
    tmux send-keys -t "$SESSION:0.0" "tmux wait-for backup_ready && clear && $SCRIPT_PATH/make-db.sh; echo 'DB Running'; tmux wait-for -S db-ready ; bash" C-m

    # P1: Matrix (après db)
    #tmux send-keys -t "$SESSION:0.1" "tmux wait-for db-ready && $SCRIPT_PATH/make-matrix.sh; echo 'Matrix Running'; tmux wait-for -S matrix-ready ; bash" C-m
    tmux send-keys -t "$SESSION:0.1" "tmux wait-for backup_ready && sleep 60 && $SCRIPT_PATH/make-matrix.sh; echo 'Matrix Running'; tmux wait-for -S matrix-ready ; bash" C-m

    # P3: Element (dns déjà ready car orchestrate_infra attend dns_ready)
    tmux send-keys -t "$SESSION:0.3" "$SCRIPT_PATH/make-element.sh; echo 'Element Running'; tmux wait-for -S element-ready ; bash" C-m

    # P4: Rproxy (après matrix, car matrix a attendu db donc c assez long)
    tmux send-keys -t "$SESSION:0.4" "tmux wait-for backup_ready && sleep 150 && $SCRIPT_PATH/make-rproxy.sh; echo 'Rproxy Running'; tmux wait-for -S rproxy-ready ; bash" C-m

    # P2: Monitoring (Au centre)
    tmux send-keys -t "$SESSION:0.2" "watch -n 1 --color 'scripts/dashboard.sh'" C-m
}


if tmux has-session -t "$SESSION" 2>/dev/null; then
    echo "Reset de la session précédente..."
    tmux kill-session -t "$SESSION"
    sleep 1
fi

echo "Démarrage de l'orchestrateur..."
tmux new-session -d -s "$SESSION"

# lancement de la procédure complète (en attente que DNS soit up)
orchestrate_infra &

CMD_DNS="rm -rvf scripts; \
         git clone $REPO_URL scripts && \
         clear && \
         tmux split-window -h -t '$SESSION:0.0' && \
         tmux send-keys -t '$SESSION:0.1' '$SCRIPT_PATH/make-backup.sh; echo Backup Ready; tmux wait-for -S backup_ready; sleep 2; exit' C-m && \
         $SCRIPT_PATH/make-dns.sh && \
         echo 'DNS Ready! Splitting...' && \
         tmux wait-for -S dns_ready && \
         bash"

tmux send-keys -t "$SESSION:0" "$CMD_DNS" C-m

# connexion à la session pour visualiser ce qu'il se passe
exec tmux attach-session -t "$SESSION"
