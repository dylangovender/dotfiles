#!/usr/bin/env bash
# Minimal bootstrap for bash servers (EC2, VPS, etc.)
# Gets you: shared aliases + .vimrc. No zsh, no oh-my-zsh.
#
# One-liner:
#   git clone https://github.com/dylangovender/dotfiles.git ~/dotfiles && ~/dotfiles/scripts/bootstrap_server.sh
set -euo pipefail

REPO_URL="https://github.com/dylangovender/dotfiles.git"
REPO_DIR="$HOME/dotfiles"

if [ ! -d "$REPO_DIR/.git" ]; then
  git clone "$REPO_URL" "$REPO_DIR"
else
  git -C "$REPO_DIR" pull --ff-only
fi

if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo apt-get install -y vim git
elif command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y vim git
elif command -v yum >/dev/null 2>&1; then
  sudo yum install -y vim git
fi

backup_if_needed() {
  local src="$1"
  if [ -e "$src" ] && [ ! -L "$src" ]; then
    mv "$src" "${src}.bak.$(date +%Y%m%d%H%M%S)"
  fi
}

backup_if_needed "$HOME/.bashrc"
backup_if_needed "$HOME/.vimrc"

ln -sf "$REPO_DIR/.bashrc" "$HOME/.bashrc"
ln -sf "$REPO_DIR/.vimrc" "$HOME/.vimrc"

echo "Done. Run: source ~/.bashrc"
