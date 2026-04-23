#!/usr/bin/env bash
# Clone ou met à jour tous les repos de Sen Lab Visa dans le dossier parent.
# À lancer depuis le dossier parent qui contient (ou contiendra) sen-lab-infra.

set -euo pipefail

GH_ORG="${GH_ORG:-senlabvisa}"
GH_BASE="${GH_BASE:-https://github.com/${GH_ORG}}"

REPOS=(
  sen-lab-shared-types
  sen-lab-gateway
  sen-lab-auth-service
  sen-lab-users-service
  sen-lab-schools-service
  sen-lab-classes-service
  sen-lab-simulations-service
  sen-lab-attempts-service
  sen-lab-analytics-service
  sen-lab-web
)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$( cd "${SCRIPT_DIR}/../.." && pwd )"

cd "${PARENT_DIR}"

cloned=0
pulled=0
failed=0

for repo in "${REPOS[@]}"; do
  if [ -d "${repo}/.git" ]; then
    printf "[pull ] %s ... " "${repo}"
    if git -C "${repo}" pull --ff-only >/dev/null 2>&1; then
      echo "ok"
      pulled=$((pulled+1))
    else
      echo "FAILED"
      failed=$((failed+1))
    fi
  elif [ -d "${repo}" ]; then
    echo "[skip ] ${repo} existe mais n'est pas un repo git"
  else
    printf "[clone] %s ... " "${repo}"
    if git clone --quiet "${GH_BASE}/${repo}.git" "${repo}" 2>/dev/null; then
      echo "ok"
      cloned=$((cloned+1))
    else
      echo "NOT FOUND (repo pas encore créé)"
      failed=$((failed+1))
    fi
  fi
done

echo ""
echo "Résumé : ${cloned} cloné(s), ${pulled} mis à jour, ${failed} échec(s)"
[ "${failed}" -eq 0 ]
