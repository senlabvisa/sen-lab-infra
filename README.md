# sen-lab-infra

Orchestration, docker-compose, reverse proxy Traefik, reusable GitHub Actions workflows et docs produit pour Sen Lab Visa.

## Démarrage rapide (dev local)

```bash
# Depuis ~/Documents/senlabvisa/
./sen-lab-infra/scripts/bootstrap.sh        # clone les 10 repos frères
cd sen-lab-infra
./scripts/env-init.sh                        # génère .env avec secrets aléatoires
cd docker
docker compose up -d
```

Services exposés en local :
- `http://localhost:8080` — dashboard Traefik
- `postgres://senlab@localhost:5432/senlab` — PostgreSQL

Les services applicatifs (gateway, auth, users, web) sont commentés dans `docker/docker-compose.yml` ; décommente-les au fur et à mesure que chaque repo frère est construit.

## Layout

```
sen-lab-infra/
├── .github/workflows/
│   ├── reusable-node-ci.yml           # réutilisé par chaque service via `uses:`
│   └── reusable-docker-deploy.yml
├── docker/
│   ├── docker-compose.yml             # dev local
│   ├── docker-compose.prod.yml        # override prod (TLS, restart always)
│   └── traefik/                       # config additionnelle traefik
├── docs/
│   ├── ARCHITECTURE.md                # vue d'ensemble stack + 11 repos
│   └── (specs produit copiées du repo docs)
├── scripts/
│   ├── bootstrap.sh                   # clone/pull tous les repos frères
│   └── env-init.sh                    # génère .env avec secrets aléatoires
├── .env.example
└── .gitignore
```

## Variables d'environnement

Voir `.env.example`. Essentielles :

| Variable | Rôle |
|---|---|
| `POSTGRES_*` | Credentials Postgres partagés par tous les services |
| `JWT_SECRET` / `JWT_REFRESH_SECRET` | Signature JWT, partagés entre auth-service et gateway |
| `SEED_ADMIN_*` | Compte admin créé au premier boot de users-service |
| `TRAEFIK_DOMAIN` | Nom de domaine pour la prod |

## Utiliser les reusable workflows dans un repo de service

Dans `<service>/.github/workflows/ci.yml` :

```yaml
jobs:
  ci:
    uses: senlabvisa/sen-lab-infra/.github/workflows/reusable-node-ci.yml@main
```

## Déploiement

Configurer les secrets GitHub suivants dans chaque repo de service :
- `GHCR_TOKEN` — PAT avec scope `write:packages`
- `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`, `VPS_DEPLOY_PATH`

Puis déclencher `reusable-docker-deploy.yml` sur push `main` avec `service-name: <nom>`.

## Documentation produit

- [ARCHITECTURE.md](docs/ARCHITECTURE.md) — vue d'ensemble stack
- [PRD_SenLabVisa.md](docs/PRD_SenLabVisa.md) — produit
- [Vision_Strategique.md](docs/Vision_Strategique.md) — vision + PMF
- [Curriculum_Referentiel.md](docs/Curriculum_Referentiel.md) — matrice curriculum Sénégal
- [Database_Schema.md](docs/Database_Schema.md) — schéma DB
- [Design_System.md](docs/Design_System.md) — couleurs, typo, UX
- [Glossaire_Local.md](docs/Glossaire_Local.md) — contextualisation culturelle
- [TP_Scenarios_Master.md](docs/TP_Scenarios_Master.md) — structure pédagogique
- [System_Role.txt](docs/System_Role.txt) — rôle CTO + consignes
