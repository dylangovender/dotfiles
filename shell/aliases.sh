#!/usr/bin/env sh
# Shared aliases and functions — sourced by both .bashrc and .zshrc

# Navigation
alias b="cd .."

# Listing
alias l='ls -lrthF'
alias la='ls -A'
alias ll='ls -lrthF'

# Editors
alias v='vi'

# Python
alias p='python3'
alias venv="python3 -m venv .venv && source .venv/bin/activate"

# History search
alias hg="history | grep"

# npm
alias npm="npm --loglevel verbose"

# zoxide — only wire up if installed
if command -v zoxide >/dev/null 2>&1; then
    alias c="z"
    alias cd="z"
fi

# AWS profiles
alias awsdefault="export AWS_PROFILE=default"
alias awsprod="export AWS_PROFILE=prod"
alias awsuat="export AWS_PROFILE=uat"

# Kubernetes
alias k="kubectl"
alias kpersonal="export KUBECONFIG=~/.kube/config_personal"
alias kproddev="export KUBECONFIG=~/.kube/config_prod_dev"
alias kproddpl="export KUBECONFIG=~/.kube/config_prod_dpl"
alias kprodonyxia="export KUBECONFIG=~/.kube/config_prod_onyxia"
alias kprodrancher="export KUBECONFIG=~/.kube/config_prod_rancher"
alias kuatdev="export KUBECONFIG=~/.kube/config_uat_dev"
alias kuatonyxia="export KUBECONFIG=~/.kube/config_uat_onyxia"
alias kuatrancher="export KUBECONFIG=~/.kube/config_uat_rancher"

# AWS SSM session helper
assh() {
    if [ -z "$1" ]; then
        echo "Usage: assh <instance-id>"
        return 1
    fi
    aws ssm start-session --target "$1"
}
