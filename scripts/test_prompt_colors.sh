#!/usr/bin/env zsh
# Renders sample AWS profile / kubecontext prompt segments using the actual
# color and classification rules from .p10k.zsh, without needing a real AWS
# session or kubeconfig. Run after editing .p10k.zsh to sanity-check that
# prod/uat/dev values map to the colors you expect.
#
# Usage: scripts/test_prompt_colors.sh

setopt extended_glob

DOTFILES_DIR=${0:A:h:h}
source "$DOTFILES_DIR/.p10k.zsh" >/dev/null 2>&1

swatch() {
  local fg=$1 bg=$2 text=$3
  print -P "\e[38;5;${fg}m\e[48;5;${bg}m $text \e[0m"
}

# Picks the first matching class from a POWERLEVEL9K_*_CLASSES array, the
# same way Powerlevel10k does: first pattern that matches $value wins.
classify() {
  local classes_var=$1 value=$2
  local -a classes
  classes=("${(@P)classes_var}")
  local class=DEFAULT i pattern name
  for ((i = 1; i <= ${#classes}; i += 2)); do
    pattern=${classes[i]}
    name=${classes[i + 1]}
    if [[ $value == ${~pattern} ]]; then
      class=$name
      break
    fi
  done
  echo "$class"
}

render_aws() {
  local profile=$1
  local class=$(classify POWERLEVEL9K_AWS_CLASSES "$profile")
  local fg=${(P)$(echo POWERLEVEL9K_AWS_${class}_FOREGROUND)}
  local bg=${(P)$(echo POWERLEVEL9K_AWS_${class}_BACKGROUND)}
  printf "  %-30s class=%-8s -> " "$profile" "$class"
  swatch "$fg" "$bg" " $profile "
}

render_kube() {
  local raw=$1 ns=${2:-default}
  local P9K_KUBECONTEXT_NAME=$raw
  local P9K_KUBECONTEXT_NAMESPACE=$ns
  local P9K_KUBECONTEXT_CLOUD_CLUSTER=
  [[ $raw == arn:aws:eks:*:*:cluster/* ]] && P9K_KUBECONTEXT_CLOUD_CLUSTER=${raw##*cluster/}

  local class=$(classify POWERLEVEL9K_KUBECONTEXT_CLASSES "$raw")
  local fg=${(P)$(echo POWERLEVEL9K_KUBECONTEXT_${class}_FOREGROUND)}
  local bg=${(P)$(echo POWERLEVEL9K_KUBECONTEXT_${class}_BACKGROUND)}
  local exp_var=POWERLEVEL9K_KUBECONTEXT_${class}_CONTENT_EXPANSION
  local expansion=${(P)exp_var}
  local content
  content=$(eval "print -n -- \"$expansion\"")

  printf "  %-65s class=%-8s -> " "$raw" "$class"
  swatch "$fg" "$bg" " $content "
}

print "AWS profile samples (POWERLEVEL9K_AWS_CLASSES):"
for p in prod production company-prod uat uat-readonly default sandbox; do
  render_aws "$p"
done

print
print "Kube context samples (POWERLEVEL9K_KUBECONTEXT_CLASSES):"
render_kube "eks-onyxia-prod-cluster"
render_kube "eks-onyxia-uat-cluster"
render_kube "eks-onyxia-dev-cluster"
render_kube "arn:aws:eks:af-south-1:186111169403:cluster/eks-onyxia-prod-cluster"
render_kube "arn:aws:eks:af-south-1:186111169403:cluster/eks-onyxia-uat-cluster" "team-namespace"
render_kube "minikube"
render_kube "docker-desktop"

# These segments have no _CLASSES pattern array — just one static color each.
# They only render when Powerlevel10k's live detection finds something:
# virtualenv/anaconda/pyenv check shell env vars or the pyenv binary, and
# java_version checks for `java` on PATH. So "testing" them means reporting
# what's actually detected on this machine, not a color/class mapping.
report_static() {
  local label=$1 fg_var=$2 bg_var=$3 sample=$4 state=$5
  local fg=${(P)fg_var} bg=${(P)bg_var}
  printf "  %-14s " "$label"
  swatch "$fg" "$bg" " $sample "
  print "    -> $state"
}

print
print "Environment-detected segments (single static color, no classes):"

if [[ -n $VIRTUAL_ENV ]]; then
  report_static virtualenv POWERLEVEL9K_VIRTUALENV_FOREGROUND POWERLEVEL9K_VIRTUALENV_BACKGROUND \
    "${VIRTUAL_ENV:t}" "ACTIVE: \$VIRTUAL_ENV=$VIRTUAL_ENV"
else
  report_static virtualenv POWERLEVEL9K_VIRTUALENV_FOREGROUND POWERLEVEL9K_VIRTUALENV_BACKGROUND \
    "venv-name" "inactive: \$VIRTUAL_ENV is unset (hidden until 'source <venv>/bin/activate')"
fi

if [[ -n $CONDA_DEFAULT_ENV ]]; then
  report_static anaconda POWERLEVEL9K_ANACONDA_FOREGROUND POWERLEVEL9K_ANACONDA_BACKGROUND \
    "$CONDA_DEFAULT_ENV" "ACTIVE: \$CONDA_DEFAULT_ENV=$CONDA_DEFAULT_ENV"
else
  report_static anaconda POWERLEVEL9K_ANACONDA_FOREGROUND POWERLEVEL9K_ANACONDA_BACKGROUND \
    "env-name" "inactive: \$CONDA_DEFAULT_ENV is unset (hidden until 'conda activate <env>')"
fi

if command -v pyenv >/dev/null 2>&1; then
  report_static pyenv POWERLEVEL9K_PYENV_FOREGROUND POWERLEVEL9K_PYENV_BACKGROUND \
    "$(pyenv version-name 2>/dev/null)" "found on PATH: $(command -v pyenv)"
else
  report_static pyenv POWERLEVEL9K_PYENV_FOREGROUND POWERLEVEL9K_PYENV_BACKGROUND \
    "3.x.x" "not found on PATH (segment hidden)"
fi

if command -v java >/dev/null 2>&1; then
  report_static java_version POWERLEVEL9K_JAVA_VERSION_FOREGROUND POWERLEVEL9K_JAVA_VERSION_BACKGROUND \
    "$(java -version 2>&1 | head -1)" "found on PATH: $(command -v java)"
else
  report_static java_version POWERLEVEL9K_JAVA_VERSION_FOREGROUND POWERLEVEL9K_JAVA_VERSION_BACKGROUND \
    "17.0.2" "not found on PATH (segment hidden) — install a JDK or fix PATH in this shell"
fi
