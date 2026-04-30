#!/usr/bin/env bash
# =====================================================================
# Sen Lab Visa — lance toute la stack en une seule commande.
#
# Ce script est livré avec sen-lab-infra mais il peut être appelé depuis
# le dossier parent (qui contient les 11 repos clonés).
#
# Usage recommandé après clonage :
#
#   cd senlabvisa/                                  # dossier parent contenant les 11 repos
#   cp sen-lab-infra/scripts/up.sh ./up.sh && chmod +x up.sh
#   ./up.sh
#
# Ou directement sans copier :
#
#   ./sen-lab-infra/scripts/up.sh
#
# Sous-commandes :
#   ./up.sh              build + demarre tout (mode detache)
#   ./up.sh logs        affiche les logs en live
#   ./up.sh stop        arrete tout (preserve les volumes)
#   ./up.sh down        arrete + supprime conteneurs (preserve les volumes)
#   ./up.sh nuke        arrete + supprime conteneurs + volumes (perte BDD)
#   ./up.sh status      liste les conteneurs et leur etat
#   ./up.sh rebuild <svc>  rebuild un service precis (ex: ./up.sh rebuild web)
#   ./up.sh seed        relance le seed BDD (utile si la base est vide apres clonage)
#   ./up.sh users       liste les comptes presents dans la BDD
#
# Pre-requis : Docker Desktop lance, ports libres (5432, 3010, 13050, 8080).
# =====================================================================

set -e

# Resolution des chemins, peu importe d'ou on lance le script.
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Si on est dans sen-lab-infra/scripts, le dossier infra est le parent.
# Si on est a la racine senlabvisa (script copie), il faut chercher.
if [ -f "$SCRIPT_PATH/../docker/docker-compose.yml" ]; then
  INFRA_DIR="$(cd "$SCRIPT_PATH/.." && pwd)"
elif [ -f "$SCRIPT_PATH/sen-lab-infra/docker/docker-compose.yml" ]; then
  INFRA_DIR="$SCRIPT_PATH/sen-lab-infra"
else
  echo "Erreur : impossible de localiser sen-lab-infra/docker-compose.yml" >&2
  echo "Place ce script dans le dossier parent de sen-lab-infra ou dans sen-lab-infra/scripts." >&2
  exit 1
fi

ENV_FILE="$INFRA_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
  echo "Erreur : $ENV_FILE introuvable." >&2
  echo "Lance : cp $INFRA_DIR/.env.example $ENV_FILE" >&2
  exit 1
fi

COMPOSE="docker compose -f $INFRA_DIR/docker/docker-compose.yml --env-file $ENV_FILE"

cmd="${1:-up}"

case "$cmd" in
  up|"")
    echo "Lancement de Sen Lab Visa..."
    $COMPOSE up -d --build

    # ---- Auto-soin de la BDD ----------------------------------------
    # Le seed initial peut echouer silencieusement (race condition entre
    # users-service et schools-service au boot). Ce bloc verifie l'etat
    # final et relance le seed automatiquement si necessaire.

    echo ""
    echo "[auto-check] Attente du demarrage complet des services..."

    # 1. Attente postgres healthy
    waited=0
    until docker exec senlab-postgres pg_isready -U "${POSTGRES_USER:-senlab}" -d "${POSTGRES_DB:-senlab}" >/dev/null 2>&1; do
      [ $waited -ge 60 ] && { echo "[auto-check] postgres pas pret apres 60s, abandon."; break; }
      sleep 2; waited=$((waited+2))
    done

    # 2. Attente que les tables critiques soient creees par les services Prisma
    #    On surveille public.users (users-service) et schools_svc.schools (schools-service)
    #    car le seed users-service a besoin des deux.
    waited=0
    max_wait=180
    while [ $waited -lt $max_wait ]; do
      users_ok=$(docker exec senlab-postgres psql -U "${POSTGRES_USER:-senlab}" -d "${POSTGRES_DB:-senlab}" \
        -tAc "SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='users' LIMIT 1;" 2>/dev/null | tr -d ' \r')
      schools_ok=$(docker exec senlab-postgres psql -U "${POSTGRES_USER:-senlab}" -d "${POSTGRES_DB:-senlab}" \
        -tAc "SELECT 1 FROM information_schema.tables WHERE table_schema='schools_svc' AND table_name='schools' LIMIT 1;" 2>/dev/null | tr -d ' \r')

      if [ "$users_ok" = "1" ] && [ "$schools_ok" = "1" ]; then
        echo "[auto-check] Tables prisma creees ($((waited))s)."
        break
      fi
      [ $((waited % 15)) -eq 0 ] && echo "[auto-check] Attente prisma db push... users=$users_ok schools=$schools_ok ($((waited))s)"
      sleep 3; waited=$((waited+3))
    done

    if [ "$users_ok" != "1" ] || [ "$schools_ok" != "1" ]; then
      echo "[auto-check] Tables non creees apres ${max_wait}s. Verifie : ./up.sh logs"
    else
      # 3. Laisse le seed initial finir, puis verifie le nombre de comptes
      sleep 4
      user_count=$(docker exec senlab-postgres psql -U "${POSTGRES_USER:-senlab}" -d "${POSTGRES_DB:-senlab}" \
        -tAc "SELECT COUNT(*) FROM public.users;" 2>/dev/null | tr -d ' \r')

      if [ "${user_count:-0}" -eq 0 ] 2>/dev/null; then
        echo "[auto-check] BDD vide detectee, relance automatique du seed..."

        TSNODE_OPTS='TS_NODE_TRANSPILE_ONLY=true TS_NODE_COMPILER_OPTIONS={\"module\":\"commonjs\",\"moduleResolution\":\"node\",\"target\":\"ES2022\",\"esModuleInterop\":true,\"resolveJsonModule\":true}'

        docker exec senlab-users sh -c \
          "$TSNODE_OPTS npx --no-install ts-node prisma/seed.ts" 2>&1 \
          | sed 's/^/  [users] /' || true

        docker exec senlab-simulations sh -c \
          "$TSNODE_OPTS npx --no-install ts-node prisma/seed.ts" 2>&1 \
          | sed 's/^/  [sims]  /' || true

        user_count=$(docker exec senlab-postgres psql -U "${POSTGRES_USER:-senlab}" -d "${POSTGRES_DB:-senlab}" \
          -tAc "SELECT COUNT(*) FROM public.users;" 2>/dev/null | tr -d ' \r')
      fi

      if [ "${user_count:-0}" -gt 0 ] 2>/dev/null; then
        echo "[auto-check] BDD prete : $user_count comptes en place."
      else
        echo "[auto-check] Probleme avec le seed. Verifie : ./up.sh logs users-service"
      fi
    fi

    echo ""
    echo "Tout est lance."
    echo "  Web      -> http://localhost:13050"
    echo "  API      -> http://localhost:3010"
    echo "  Postgres -> postgres://senlab@localhost:5432/senlab"
    echo "  Traefik  -> http://localhost:8080"
    echo ""
    echo "Comptes seedes (mode dev) :"
    echo "  Eleve         lycee-limamou/moussa      / moussa123"
    echo "  Enseignant    lycee-limamou/diallo      / diallo123"
    echo "  Admin ecole   lycee-limamou/proviseur   / proviseur123"
    echo "  Sysadmin      sysadmin/root             / sysadmin123"
    ;;

  logs)
    $COMPOSE logs -f --tail=100 "${@:2}"
    ;;

  stop)
    echo "Arret des conteneurs..."
    $COMPOSE stop
    ;;

  down)
    echo "Arret + suppression des conteneurs (volumes preserves)..."
    $COMPOSE down
    ;;

  nuke)
    read -p "Supprimer aussi les volumes (BDD effacee) ? [y/N] " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
      $COMPOSE down -v
      echo "Tout supprime."
    else
      echo "Annule."
    fi
    ;;

  status|ps)
    $COMPOSE ps
    ;;

  rebuild)
    svc="${2:?Indique le service a rebuilder (ex: ./up.sh rebuild web)}"
    echo "Rebuild $svc..."
    $COMPOSE up -d --build --no-deps "$svc"
    ;;

  seed)
    echo "Re-execution du seed users-service + simulations-service..."
    if ! docker ps --format '{{.Names}}' | grep -q '^senlab-users$'; then
      echo "Erreur : senlab-users n'est pas demarre. Lance d'abord : ./up.sh"
      exit 1
    fi
    TSNODE_OPTS='TS_NODE_TRANSPILE_ONLY=true TS_NODE_COMPILER_OPTIONS={\"module\":\"commonjs\",\"moduleResolution\":\"node\",\"target\":\"ES2022\",\"esModuleInterop\":true,\"resolveJsonModule\":true}'
    docker exec senlab-users sh -c \
      "$TSNODE_OPTS npx --no-install ts-node prisma/seed.ts" \
      || echo "(seed users-service termine avec warnings)"
    docker exec senlab-simulations sh -c \
      "$TSNODE_OPTS npx --no-install ts-node prisma/seed.ts" \
      || echo "(seed simulations-service termine avec warnings)"
    echo ""
    echo "Verification : comptes presents en BDD"
    docker exec senlab-postgres psql -U "${POSTGRES_USER:-senlab}" -d "${POSTGRES_DB:-senlab}" \
      -c "SELECT identifier, role FROM public.users ORDER BY role, identifier;" 2>&1 \
      | head -20
    ;;

  users)
    echo "Comptes presents dans la BDD :"
    docker exec senlab-postgres psql -U "${POSTGRES_USER:-senlab}" -d "${POSTGRES_DB:-senlab}" \
      -c "SELECT identifier, role, \"fullName\" FROM public.users ORDER BY role, identifier;" 2>&1
    ;;

  *)
    # passe les arguments tels quels a compose
    $COMPOSE "$@"
    ;;
esac
