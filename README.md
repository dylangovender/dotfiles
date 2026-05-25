# dotfiles

Personal shell configuration for macOS (zsh) and Linux servers (bash).

## Structure

```
dotfiles/
├── shell/
│   └── aliases.sh          # shared aliases — sourced by both .zshrc and .bashrc
├── .zshrc                  # macOS / zsh (oh-my-zsh + powerlevel10k)
├── .bashrc                 # Linux servers / bash
├── .vimrc
├── .p10k.zsh
└── scripts/
    ├── bootstrap.sh        # full setup: macOS or personal Linux (installs zsh, omz, etc.)
    ├── bootstrap_server.sh # minimal setup: bash servers (aliases + vimrc only)
    └── bootstrap_vim.sh    # vim/neovim only
```

## New machine (macOS or personal Linux)

```sh
bash -lc 'git clone https://github.com/dylangovender/dotfiles.git ~/dotfiles && ~/dotfiles/scripts/bootstrap.sh'
```

## Server / EC2 (bash, no zsh)

```sh
git clone https://github.com/dylangovender/dotfiles.git ~/dotfiles && ~/dotfiles/scripts/bootstrap_server.sh
```

## Adding aliases

Edit `shell/aliases.sh`, commit, push. On any other machine: `git -C ~/dotfiles pull && source ~/.bashrc` (or `source ~/.zshrc`).
