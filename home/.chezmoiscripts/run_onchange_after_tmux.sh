#!/usr/bin/bash

set -eu

echo -e "==== Start: Tmux ====\n"

tmux source ~/.config/tmux/tmux.conf
echo "Source updated"

echo -e "\n==== End: Tmux ===="

