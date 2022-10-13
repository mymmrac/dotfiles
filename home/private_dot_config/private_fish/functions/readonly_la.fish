function la --wraps=ls --wraps='exa --icons --all --group-directories-first' --description 'alias la=exa --icons --all --group-directories-first'
  exa --icons --all --group-directories-first $argv; 
end
