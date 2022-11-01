if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
end

function fish_greeting
	LC_TIME="en_US.UTF-8" date | lolcat
end

mkdir -p ~/.go
set -Ux GOPATH ~/.go
set -Ux EDITOR nvim

fish_add_path -U ~/.local/bin
fish_add_path -U ~/.go/bin
fish_add_path -U ~/.cargo/bin

