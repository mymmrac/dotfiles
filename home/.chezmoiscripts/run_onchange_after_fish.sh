#!/usr/bin/fish

echo -e "==== Start: Fish ====\n"

curl -sL "https://raw.githubusercontent.com/jorgebucaran/fisher/HEAD/functions/fisher.fish" | source && fisher install jorgebucaran/fisher

fisher install catppuccin/fish
fish_config theme save "Catppuccin Mocha"

chezmoi completion fish --output=~/.config/fish/completions/chezmoi.fish
fish_update_completions

mkdir -p ~/.go
set -Ux GOPATH ~/.go
set -Ux EDITOR nvim

fish_add_path -U ~/.local/bin
fish_add_path -U ~/.go/bin
fish_add_path -U ~/.cargo/bin

echo -e "\n==== End: Fish ==="

