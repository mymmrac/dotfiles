#!/usr/bin/bash

set -eu

echo -e "==== Start: Gis SSH ====\n"

pushd ~/.local/share/chezmoi/
git remote set-url origin git@github.com:mymmrac/dotfiles.git
popd

echo -e "\n==== End: SSH ===="
