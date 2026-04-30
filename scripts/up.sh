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

  *)
    # passe les arguments tels quels a compose
    $COMPOSE "$@"
    ;;
esac
