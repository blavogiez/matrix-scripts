#!/bin/bash

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

    # exécution des commandes
    
    # P0: Base de données
    tmux send-keys -t "$SESSION:0.0" "clear && $SCRIPT_PATH/make-db.sh; echo 'DB Running'; tmux wait-for -S db-ready ; bash" C-m

    # P1: Matrix
    tmux send-keys -t "$SESSION:0.1" "$SCRIPT_PATH/make-matrix.sh; echo 'Matrix Running'; tmux wait-for -S matrix-ready ; bash" C-m

    # P3: Element
    tmux send-keys -t "$SESSION:0.3" "$SCRIPT_PATH/make-element.sh; echo 'Element Running'; tmux wait-for -S element-ready ; bash" C-m

    # P4: Rproxy
    tmux send-keys -t "$SESSION:0.4" "$SCRIPT_PATH/make-rproxy.sh; echo 'Rproxy Running'; tmux wait-for -S rproxy-ready ; bash" C-m

    # P2: Monitoring (Au centre)
    tmux send-keys -t "$SESSION:0.2" "watch -n 1 --color 'scripts/dashboard.sh'" C-m

    # Dernière pane (à la fin)
    # Crée une window 3
    tmux split-window -h -t "$SESSION:0.2"
    tmux send-keys -t "$SESSION:0.3" "clear && echo 'Waiting for other to finish...' ; tmux wait-for db-ready ; \
				tmux wait-for matrix-ready ; \
				tmux wait-for element-ready ; \
				tmux wait-for rproxy-ready ; \
				$SCRIPT_PATH/make-backup.sh ; echo 'Backup running' ; bash"
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
         $SCRIPT_PATH/make-dns.sh && \
         echo 'DNS Ready! Splitting...' && \
         tmux wait-for -S dns_ready && \
         bash"

tmux send-keys -t "$SESSION:0" "$CMD_DNS" C-m

# connexion à la session pour visualiser ce qu'il se passe
exec tmux attach-session -t "$SESSION"
