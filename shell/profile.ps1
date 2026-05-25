# Shared aliases for PowerShell — mirrors shell/aliases.sh
# Sourced via symlink at $PROFILE

# Navigation
function b { Set-Location .. }

# Listing
function l  { Get-ChildItem -Force $args }
function la { Get-ChildItem -Force $args }
function ll { Get-ChildItem -Force $args | Format-Table Mode, LastWriteTime, Length, Name }

# Editors
Set-Alias v vim

# Python
Set-Alias p python3

function venv {
    python3 -m venv .venv
    .\.venv\Scripts\Activate.ps1
}

# History search
function hg {
    param([string]$Pattern)
    Get-History | Where-Object { $_.CommandLine -match $Pattern }
}

# npm with verbose logging
function npm { npm.cmd --loglevel verbose @args }

# zoxide — wire up if installed
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell | Out-String) })
    function c { z @args }
}

# AWS profiles
function awsdefault { $env:AWS_PROFILE = "default" }
function awsprod    { $env:AWS_PROFILE = "prod" }
function awsuat     { $env:AWS_PROFILE = "uat" }

# Kubernetes
Set-Alias k kubectl
function kpersonal   { $env:KUBECONFIG = "$HOME\.kube\config_personal" }
function kproddev    { $env:KUBECONFIG = "$HOME\.kube\config_prod_dev" }
function kproddpl    { $env:KUBECONFIG = "$HOME\.kube\config_prod_dpl" }
function kprodonyxia { $env:KUBECONFIG = "$HOME\.kube\config_prod_onyxia" }
function kprodrancher{ $env:KUBECONFIG = "$HOME\.kube\config_prod_rancher" }
function kuatdev     { $env:KUBECONFIG = "$HOME\.kube\config_uat_dev" }
function kuatonyxia  { $env:KUBECONFIG = "$HOME\.kube\config_uat_onyxia" }
function kuatrancher { $env:KUBECONFIG = "$HOME\.kube\config_uat_rancher" }

# AWS SSM session helper
function assh {
    param([string]$InstanceId)
    if (-not $InstanceId) {
        Write-Host "Usage: assh <instance-id>"
        return
    }
    aws ssm start-session --target $InstanceId
}
