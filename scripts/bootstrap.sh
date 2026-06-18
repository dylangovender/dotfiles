#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/dylangovender/dotfiles.git"
REPO_DIR="$HOME/dotfiles"

if [ ! -d "$REPO_DIR/.git" ]; then
  git clone "$REPO_URL" "$REPO_DIR"
else
  git -C "$REPO_DIR" pull --ff-only
fi

backup_if_needed() {
  local src="$1"
  if [ -e "$src" ] && [ ! -L "$src" ]; then
    mv "$src" "${src}.bak.$(date +%Y%m%d%H%M%S)"
  fi
}

backup_if_needed "$HOME/.zshrc"
backup_if_needed "$HOME/.p10k.zsh"
backup_if_needed "$HOME/.vimrc"
backup_if_needed "$HOME/.bashrc"

ln -sf "$REPO_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$REPO_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
ln -sf "$REPO_DIR/.vimrc" "$HOME/.vimrc"
ln -sf "$REPO_DIR/.bashrc" "$HOME/.bashrc"

OS="$(uname -s)"

if [ "$OS" = "Darwin" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)" || true
  fi
  brew update
  brew install git zsh zoxide fzf powerlevel10k kubectl awscli coreutils findutils gnu-sed gawk vim zip
  if [ -x "/opt/homebrew/opt/fzf/install" ]; then
    yes | /opt/homebrew/opt/fzf/install
  fi
elif [ "$OS" = "Linux" ]; then
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq
    sudo apt-get install -y git zsh zoxide fzf curl ca-certificates vim zip
  elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y git zsh zoxide fzf curl ca-certificates vim zip
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y git zsh zoxide fzf curl ca-certificates vim zip
  fi
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ ! -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
  curl -s "https://get.sdkman.io" | bash
fi

if [ "$SHELL" != "$(command -v zsh)" ]; then
  if command -v chsh >/dev/null 2>&1; then
    chsh -s "$(command -v zsh)" "$USER" || true
  fi
fi

echo "Bootstrap complete. Open a new terminal or run: exec zsh"
