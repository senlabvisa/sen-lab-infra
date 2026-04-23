# Architecture — Sen Lab Visa

Plateforme web (PWA desktop/mobile/tablette) de laboratoires virtuels pour élèves sénégalais (collège + lycée). Offline-first, low-end devices friendly.

## Vue d'ensemble

```
                    ┌────────────────────────────────┐
                    │  sen-lab-web (Next.js + PWA)   │
                    │  shadcn/ui + Tailwind          │
                    │  IndexedDB (Dexie) offline     │
                    └───────────────┬────────────────┘
                                    │ HTTPS
                                    ▼
                    ┌────────────────────────────────┐
                    │  Traefik (reverse proxy + TLS) │
                    └───────────────┬────────────────┘
                                    │
                                    ▼
                    ┌────────────────────────────────┐
                    │  sen-lab-gateway (NestJS)      │
                    │  JWT guards, rate limit        │
                    └───┬──────┬──────┬──────┬───────┘
                        │      │      │      │
            ┌───────────┘      │      │      └───────────┐
            ▼                  ▼      ▼                  ▼
      ┌──────────┐      ┌─────────┐ ┌────────┐     ┌──────────┐
      │ auth-svc │      │ users   │ │ schools│ ... │ analytics│
      │ NestJS   │      │ svc     │ │ svc    │     │ svc      │
      │ argon2   │      │         │ │        │     │ XP/badge │
      └─────┬────┘      └────┬────┘ └───┬────┘     └─────┬────┘
            │                │          │                │
            └────────────────┼──────────┼────────────────┘
                             ▼          ▼
                    ┌────────────────────────────┐
                    │  PostgreSQL 16 (Docker)    │
                    └────────────────────────────┘
```

## 11 repos

| Repo | Rôle | Stack |
|---|---|---|
| sen-lab-infra | Orchestration, docker-compose, Traefik, docs, CI reusable | Bash, YAML, Docker |
| sen-lab-shared-types | DTOs/enums partagés | TypeScript (package npm GHCR) |
| sen-lab-gateway | API gateway | NestJS |
| sen-lab-auth-service | Login, JWT, refresh | NestJS + Prisma + argon2 |
| sen-lab-users-service | Profiles student/teacher/admin | NestJS + Prisma |
| sen-lab-schools-service | Écoles, régions | NestJS + Prisma |
| sen-lab-classes-service | Classes, inscriptions | NestJS + Prisma |
| sen-lab-simulations-service | Catalogue de TPs | NestJS + Prisma |
| sen-lab-attempts-service | Sessions élève, scores (jsonb) | NestJS + Prisma |
| sen-lab-analytics-service | XP, badges, stats | NestJS + Prisma |
| sen-lab-web | Frontend PWA | Next.js App Router + shadcn/ui |

## Communication inter-services

- **MVP** : REST synchrone via le gateway.
- **Phase 4+** : events asynchrones via Redis Pub/Sub (ex. `attempt.completed` consommé par analytics pour MAJ XP/badges).

## Authentification

- Identifiant école (format `<slug-ecole>/<login>`) + mot de passe.
- Hashing argon2.
- JWT access (15 min) + refresh (7 jours).
- Pas d'OTP SMS ni de magic link.

## Base de données

- PostgreSQL 16 unique pour tous les services (schémas séparés par service).
- Prisma comme ORM dans chaque service.
- Migrations versionnées dans chaque repo de service.

## CI/CD

- GitHub Actions, reusable workflows dans `sen-lab-infra/.github/workflows/`.
- Images Docker publiées sur GHCR (`ghcr.io/senlabvisa/<service>`).
- Déploiement SSH vers VPS (provider choisi ultérieurement).

## Design System

Palette (voir `Design_System.md`) :
- Primary (Science Blue) `#1E40AF`
- Secondary (Action Green) `#059669`
- Accent (Alert Orange) `#F59E0B`
- Background `#F9FAFB`, Text `#111827`

Typographie : Inter (UI) + JetBrains Mono (données/maths). Icônes : Lucide-React.

## Dev local

```bash
# depuis ~/Documents/senlabvisa/
./sen-lab-infra/scripts/bootstrap.sh       # clone tous les repos
cd sen-lab-infra
./scripts/env-init.sh                      # génère .env avec secrets aléatoires
cd docker
docker compose up
```

## Hors scope

- Hub Local Raspberry Pi (plateforme web responsive uniquement).
- App native (iOS/Android) — la PWA couvre desktop + mobile + tablette.
