# Bootstrap for Windows PowerShell
# Gets you: shared aliases via $PROFILE symlink
#
# Run from PowerShell (not CMD):
#   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#   git clone https://github.com/dylangovender/dotfiles.git $HOME\dotfiles
#   . $HOME\dotfiles\scripts\bootstrap_windows.ps1

$repoUrl = "https://github.com/dylangovender/dotfiles.git"
$repoDir = "$HOME\dotfiles"

if (-not (Test-Path "$repoDir\.git")) {
    git clone $repoUrl $repoDir
} else {
    git -C $repoDir pull --ff-only
}

# Ensure the PowerShell profile directory exists
$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# Back up existing profile if it's a real file (not already a symlink)
if ((Test-Path $PROFILE) -and (Get-Item $PROFILE).LinkType -ne "SymbolicLink") {
    $backup = "$PROFILE.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Move-Item $PROFILE $backup
    Write-Host "Backed up existing profile to $backup"
}

# Create symlink — requires Developer Mode or admin privileges
try {
    New-Item -ItemType SymbolicLink -Path $PROFILE -Target "$repoDir\shell\profile.ps1" -Force | Out-Null
    Write-Host "Symlinked $PROFILE -> $repoDir\shell\profile.ps1"
} catch {
    Write-Host "Symlink failed (needs Developer Mode or admin). Falling back to dot-source."
    Write-Host ". $repoDir\shell\profile.ps1" | Out-File -FilePath $PROFILE -Append
    Write-Host "Added dot-source line to $PROFILE instead."
}

Write-Host "Done. Restart PowerShell or run: . `$PROFILE"
