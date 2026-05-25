# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=
HISTFILESIZE=
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
#PS1='${debian_chroot:+($debian_chroot)}\[\e[01;37m\]\u@\h\[\e[00m\]:$(aws_profile):$(kube_context)\[\e[01;34m\]\w\[\e[00m\]\$ '
PS1='${debian_chroot:+($debian_chroot)}\[\e[01;90m\]\u@\h\[\e[00m\]:$(aws_profile):$(kube_context):$(parse_git_branch):\[\e[01;34m\]\w\[\e[00m\]\n\[\e[01;33m\]\$\[\e[00m\] '
#PS1='${debian_chroot:+($debian_chroot)}\[\e[01;32m\]\u@\h\[\e[00m\]:\[\e[01;34m\]\w\[\e[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Function to get the current Git branch and status
function parse_git_branch() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null)
        if [[ -n $(git status --porcelain) ]]; then
            echo -e "\e[01;31m[$branch*]\e[00m"  # Uncommitted changes
        else
            echo -e "\e[01;32m[$branch]\e[00m"
        fi
    fi
}


# Function to get the current AWS profile and color it based on the environment
function aws_profile() {
    if [ -n "$AWS_PROFILE" ]; then
        if [ "$AWS_PROFILE" == "uat" ]; then
            echo -e "\e[01;32m[$AWS_PROFILE]\e[00m"  # Green for uat
        elif [ "$AWS_PROFILE" == "prod" ]; then
            echo -e "\e[01;31m[$AWS_PROFILE]\e[00m"  # Red for prod
        else
            echo -e "\e[01;33m[$AWS_PROFILE]\e[00m"  # Yellow for others
        fi
    else
        echo -e "[No env]"  # Yellow for default
    fi
}

# Function to get the current Kubernetes context
function kube_context() {
    local context
    context=$(kubectl config current-context | rev | cut -d'/' -f1 | rev 2>/dev/null)
    
    if [ -n "$context" ]; then
        if [[ "$context" == *"dev"* ]]; then
            echo -e "\e[01;32m[$context]\e[00m"  # Green for uat
        elif [[ "$context" == *"prod"* ]]; then
            echo -e "\e[01;31m[$context]\e[00m"  # Red for prod
        else
            echo -e "\e[01;33m[$context]\e[00m"  # Yellow for others
        fi
    else
        echo "[no cluster]"
    fi
}


# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Shared aliases (same file sourced by .zshrc on macOS)
[ -f "$HOME/dotfiles/shell/aliases.sh" ] && source "$HOME/dotfiles/shell/aliases.sh"

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


