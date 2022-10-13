if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
end

function fish_greeting
	LC_TIME="en_US.UTF-8" date | lolcat
end

