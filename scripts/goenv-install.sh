#!/bin/bash

cd "$HOME" || exit 1
git clone https://github.com/syndbg/goenv.git "$HOME/.goenv"

{
  echo 'export GOENV_ROOT="$HOME/.goenv"'
  echo 'export PATH="$GOENV_ROOT/bin:$PATH"'
  echo 'eval "$(goenv init -)"'
  echo 'export PATH="$GOROOT/bin:$PATH"'
  echo 'export PATH="$PATH:$GOPATH/bin"'
} >> "$HOME/.bash_profile"

exit 0
