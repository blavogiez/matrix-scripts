#!/bin/bash

SESSION="deploy_vms"
tmux kill-session -a
tmux new-session -d -s $SESSION 'echo "rm -rvf scripts && git clone https://gitlab.univ-lille.fr/baptiste.lavogiez.etu/matrix-scripts.git scripts && scripts/vmiut/make-dns.sh" | ssh dattier'
tmux a 
tmux split-window -h -t $SESSION "bash"


