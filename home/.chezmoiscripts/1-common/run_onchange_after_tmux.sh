#!/usr/bin/bash

set -eu

echo -e "==== Start: Tmux ====\n"

tmux new-session -d
tmux source ~/.config/tmux/tmux.conf

echo -e "\n==== End: Tmux ===="
