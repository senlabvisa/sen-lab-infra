#!/usr/bin/env bash
# Génère un .env local à partir de .env.example avec des secrets aléatoires.

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT="$( cd "${SCRIPT_DIR}/.." && pwd )"

if [ -f "${ROOT}/.env" ]; then
  echo ".env existe déjà. Supprime-le d'abord si tu veux regénérer."
  exit 1
fi

gen_secret() {
  openssl rand -hex 32
}

cp "${ROOT}/.env.example" "${ROOT}/.env"

if command -v gsed >/dev/null; then SED="gsed"; else SED="sed"; fi

"${SED}" -i "s|^JWT_SECRET=.*|JWT_SECRET=$(gen_secret)|" "${ROOT}/.env"
"${SED}" -i "s|^JWT_REFRESH_SECRET=.*|JWT_REFRESH_SECRET=$(gen_secret)|" "${ROOT}/.env"
"${SED}" -i "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$(gen_secret)|" "${ROOT}/.env"

echo ".env généré dans ${ROOT}/.env"
echo "Modifie les valeurs marquées 'change-me' avant déploiement prod."
