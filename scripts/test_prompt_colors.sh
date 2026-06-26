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
