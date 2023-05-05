#!/bin/bash

env_file=""

cd "$HOME" || exit 1
curl https://pyenv.run | bash

if [ -e "$HOME/.bash_profile" ];then
  env_file="$HOME/.bash_profile"
else
  env_file="$HOME/.bashrc"
fi

{
  echo '# PYENV'
  echo 'export PYENV_ROOT="$HOME/.pyenv"'
  echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
  echo 'eval "$(pyenv init -)"'
  echo 'eval "$(pyenv virtualenv-init -)"'
} >> "${env_file}"

echo ". OK"
echo "! source $env_file"
exit 0
