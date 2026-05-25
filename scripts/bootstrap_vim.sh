#!/usr/bin/env bash
set -euo pipefail
if [ "$(uname -s)" = "Darwin" ]; then
  brew install vim neovim
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo apt-get install -y vim neovim
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y vim neovim
elif command -v yum >/dev/null 2>&1; then
  sudo yum install -y vim neovim
fi
ln -sf "$HOME/dotfiles/.vimrc" "$HOME/.vimrc"
mkdir -p "$HOME/.config/nvim"
ln -sf "$HOME/.vimrc" "$HOME/.config/nvim/init.vim"
