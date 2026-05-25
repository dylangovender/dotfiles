# dotfiles

Personal shell configuration for macOS (zsh), Linux/bash servers, and Windows (PowerShell).

## Structure

```
dotfiles/
├── shell/
│   ├── aliases.sh           # shared aliases — sourced by .zshrc and .bashrc
│   └── profile.ps1          # shared aliases for PowerShell (mirrors aliases.sh)
├── .zshrc                   # macOS / zsh (oh-my-zsh + powerlevel10k)
├── .bashrc                  # Linux servers / bash
├── .vimrc
├── .p10k.zsh
└── scripts/
    ├── bootstrap.sh          # full setup: macOS or personal Linux (installs zsh, omz, etc.)
    ├── bootstrap_server.sh   # minimal setup: bash servers (aliases + vimrc only)
    ├── bootstrap_windows.ps1 # Windows PowerShell setup
    └── bootstrap_vim.sh      # vim/neovim only
```

## New machine (macOS or personal Linux)

```sh
bash -lc 'git clone https://github.com/dylangovender/dotfiles.git ~/dotfiles && ~/dotfiles/scripts/bootstrap.sh'
```

## Server / EC2 (bash, no zsh)

```sh
git clone https://github.com/dylangovender/dotfiles.git ~/dotfiles && ~/dotfiles/scripts/bootstrap_server.sh
```

## Windows (PowerShell)

```powershell
# One-time: allow local scripts to run
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Clone and bootstrap
git clone https://github.com/dylangovender/dotfiles.git $HOME\dotfiles
. $HOME\dotfiles\scripts\bootstrap_windows.ps1
```

> **Note:** creating a symlink for `$PROFILE` requires Windows Developer Mode (`Settings → For developers → Developer Mode`) or running PowerShell as Administrator. The bootstrap script falls back to a dot-source line automatically if symlinks aren't available.

## Adding aliases

Edit `shell/aliases.sh` (bash/zsh) and mirror the change in `shell/profile.ps1` (PowerShell), then commit and push.

On any machine to pull updates:
- **macOS/Linux:** `git -C ~/dotfiles pull && source ~/.zshrc` (or `~/.bashrc`)
- **Windows:** `git -C $HOME\dotfiles pull` then restart PowerShell (or `. $PROFILE`)
