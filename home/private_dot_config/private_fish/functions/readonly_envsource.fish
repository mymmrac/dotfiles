function envsource --description 'source for env files'
  for line in (cat $argv | grep -v '^#')
    set item (string split -m 1 '=' $line)
    set -gx $item[1] $item[2]
  end
end

function fenv --wraps 'envsource ~/.config/fish/.env' --description 'source fish ,env file'
  envsource ~/.config/fish/.env
end
