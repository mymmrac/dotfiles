function lh --wraps=ls --wraps='exa --icons --all --long --header --git --group-directories-first' --description 'alias lh=exa --icons --all --long --header --git --group-directories-first'
  exa --icons --all --long --header --git --group-directories-first $argv; 
end
