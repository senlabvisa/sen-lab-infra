# sen-lab-infra

Orchestration et infrastructure de la plateforme **Sen Lab Visa** — laboratoires virtuels STEM pour les élèves du Sénégal.

Ce repo contient le `docker-compose.yml`, les scripts de démarrage et la documentation produit. C'est le **point d'entrée recommandé** pour découvrir et lancer l'écosystème complet.

---

## Sommaire

1. [Le problème](#le-probleme)
2. [La solution](#la-solution)
3. [Architecture](#architecture)
4. [Pré-requis](#pre-requis)
5. [Démarrage en 1 commande](#demarrage-en-1-commande)
6. [Comprendre ce qui tourne](#comprendre-ce-qui-tourne)
7. [Comptes de test](#comptes-de-test)
8. [Commandes du `up.sh`](#commandes-du-upsh)
9. [Variables d'environnement](#variables-denvironnement)
10. [Développement (sans Docker)](#developpement-sans-docker)
11. [Dépannage](#depannage)
12. [Roadmap](#roadmap)

---

## Le problème

Au Sénégal, la majorité des collèges et lycées n'ont pas de laboratoire de sciences fonctionnel. Les élèves apprennent les concepts STEM (Mathématiques, Physique-Chimie, SVT) de manière purement théorique, sans manipuler. Cela crée :

- Un désintérêt pour les filières scientifiques
- Une mauvaise compréhension des concepts abstraits
- Une fracture matérielle entre les écoles bien équipées et les autres

## La solution

Sen Lab Visa est une plateforme web (PWA) de laboratoires virtuels qui permet à tout élève sénégalais de :

- Manipuler virtuellement des expériences (circuits électriques, photosynthèse, géométrie)
- Travailler hors-ligne sur smartphone bas de gamme avec connectivité intermittente
- Apprendre dans un contexte sénégalais (compteur Woyofal, corde du maçon de Thiès, élodée du Saloum)
- Être suivi par son enseignant via un tableau de bord et un système de tutorat

---

## Architecture

L'écosystème est composé de **11 repos** organisés en microservices :

```
                  Browser (élève / professeur / admin)
                              |
                              v   http://localhost:13050
                +-----------------------------+
                |  sen-lab-web (Next.js PWA)  |
                +-----------------------------+
                              |
                              v   http://localhost:3010
                +-----------------------------+
                |  sen-lab-gateway (NestJS)   |
                +-----------------------------+
                              |
        +---------+-----------+-----------+---------+----------+
        v         v           v           v         v          v
     [auth]   [users]    [schools]   [classes] [simulations] [attempts]
      3001     3002        3003        3004        3006         3007
        |         |           |           |          |           |
        +---------+-----------+-----------+----------+-----------+
                              |
                              v
                    +------------------+
                    |  PostgreSQL 16   |
                    |  (5 schemas)     |
                    +------------------+

      [analytics] (3008)  <--- stateless, agrege via HTTP
```

### Les 11 repos

| Repo | Rôle | Port | Stack |
|---|---|---|---|
| [`sen-lab-shared-types`](https://github.com/senlabvisa/sen-lab-shared-types) | DTOs et enums TypeScript partagés | — | TypeScript |
| [`sen-lab-auth-service`](https://github.com/senlabvisa/sen-lab-auth-service) | Authentification JWT (argon2id) | 3001 | NestJS + Prisma |
| [`sen-lab-users-service`](https://github.com/senlabvisa/sen-lab-users-service) | Utilisateurs (CRUD + import CSV) | 3002 | NestJS + Prisma |
| [`sen-lab-schools-service`](https://github.com/senlabvisa/sen-lab-schools-service) | Établissements scolaires | 3003 | NestJS + Prisma |
| [`sen-lab-classes-service`](https://github.com/senlabvisa/sen-lab-classes-service) | Classes et assignations TP | 3004 | NestJS + Prisma |
| [`sen-lab-simulations-service`](https://github.com/senlabvisa/sen-lab-simulations-service) | Catalogue des TP | 3006 | NestJS + Prisma |
| [`sen-lab-attempts-service`](https://github.com/senlabvisa/sen-lab-attempts-service) | Tentatives élèves et scores | 3007 | NestJS + Prisma |
| [`sen-lab-analytics-service`](https://github.com/senlabvisa/sen-lab-analytics-service) | XP, badges, dashboards | 3008 | NestJS (stateless) |
| [`sen-lab-gateway`](https://github.com/senlabvisa/sen-lab-gateway) | API Gateway (HTTP proxy) | 3010 | NestJS |
| [`sen-lab-web`](https://github.com/senlabvisa/sen-lab-web) | Frontend PWA | 13050 | Next.js 14 + Tailwind + Framer Motion |
| [`sen-lab-infra`](https://github.com/senlabvisa/sen-lab-infra) | **Orchestration Docker, scripts, docs** | — | Docker Compose + Bash |

---

## Pré-requis

- **macOS** ou **Linux** (Windows via WSL2 fonctionne aussi)
- **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** installé et lancé
- **[Git](https://git-scm.com/)**
- Environ **4 Go de RAM libre** et **3 Go d'espace disque**

Pour vérifier que Docker tourne :

```bash
docker info | grep "Server Version"
```

Si la commande répond avec un numéro de version, c'est bon.

---

## Démarrage en 1 commande

### Étape 1 — Cloner les 11 repos

L'écosystème étant en multi-repos, il faut cloner les 11 dépôts dans un même dossier parent. Le script ci-dessous le fait pour toi :

```bash
# Crée un dossier parent et y entrer
mkdir -p ~/Documents/senlabvisa
cd ~/Documents/senlabvisa

# Cloner les 11 repos
for r in shared-types auth-service users-service schools-service \
         classes-service simulations-service attempts-service \
         analytics-service gateway web infra; do
  git clone https://github.com/senlabvisa/sen-lab-$r.git
done
```

À la fin, ton arborescence ressemble à :

```
senlabvisa/
├── sen-lab-shared-types/
├── sen-lab-auth-service/
├── sen-lab-users-service/
├── sen-lab-schools-service/
├── sen-lab-classes-service/
├── sen-lab-simulations-service/
├── sen-lab-attempts-service/
├── sen-lab-analytics-service/
├── sen-lab-gateway/
├── sen-lab-web/
└── sen-lab-infra/
```

### Étape 2 — Configurer les variables d'environnement

Le fichier `.env` est partagé entre tous les services via Docker Compose. Copie le template fourni :

```bash
cp sen-lab-infra/.env.example sen-lab-infra/.env
```

Pour le développement local, le fichier par défaut fonctionne tel quel. Pour la production, change au minimum :

- `POSTGRES_PASSWORD` (mot de passe BDD)
- `JWT_SECRET` et `JWT_REFRESH_SECRET` (au moins 32 caractères chacun)
- `SEED_ADMIN_PASSWORD` (mot de passe du compte admin par défaut)

### Étape 3 — Récupérer le script de lancement

Le script `up.sh` vit dans le dossier parent (et non dans `sen-lab-infra`) car il pilote l'ensemble. Tu peux le créer manuellement avec le contenu fourni dans `sen-lab-infra/scripts/up.sh.template` ou le télécharger directement :

```bash
curl -O https://raw.githubusercontent.com/senlabvisa/sen-lab-infra/main/scripts/up.sh
chmod +x up.sh
```

### Étape 4 — Lancer la stack

```bash
./up.sh
```

**Ce qui se passe au premier lancement :**

1. Docker pull les images de base (`node:20-alpine`, `postgres:16-alpine`, `traefik:v3.1`)
2. Build des **9 images** Docker (les 7 microservices NestJS + le gateway + le web)
3. Démarrage de **11 conteneurs** dans l'ordre des dépendances
4. PostgreSQL se met en healthy
5. Chaque service Prisma exécute au boot :
   - `prisma generate` (régénère le client pour l'arch alpine)
   - `prisma db push` (synchronise le schéma)
   - Pour `users-service` et `simulations-service` : exécution du seed (idempotent)
6. Le gateway et le web démarrent quand les services sont up

**Durée :** environ 5 à 10 minutes au premier lancement (téléchargements + build). Aux relances suivantes, environ 30 secondes grâce au cache Docker.

À la fin, le script affiche les URL d'accès et les comptes seedés.

---

## Comprendre ce qui tourne

Une fois `./up.sh` exécuté, tu peux vérifier l'état des conteneurs :

```bash
./up.sh status
# ou directement :
docker compose -f sen-lab-infra/docker/docker-compose.yml ps
```

Tu devrais voir 11 conteneurs `Up` :

| Conteneur | Service | Port hôte | Port interne |
|---|---|---|---|
| `senlab-postgres` | PostgreSQL 16 | 5432 | 5432 |
| `senlab-auth` | auth-service | — | 3001 |
| `senlab-users` | users-service | — | 3002 |
| `senlab-schools` | schools-service | — | 3003 |
| `senlab-classes` | classes-service | — | 3004 |
| `senlab-simulations` | simulations-service | — | 3006 |
| `senlab-attempts` | attempts-service | — | 3007 |
| `senlab-analytics` | analytics-service | — | 3008 |
| `senlab-gateway` | API Gateway | **3010** | 3010 |
| `senlab-web` | Frontend Next.js | **13050** | 3005 |
| `senlab-traefik` | Reverse proxy (optionnel) | 8080 | 80/443 |

Seuls **3 ports sont exposés sur l'hôte** :

- `5432` (PostgreSQL — pour pouvoir y accéder avec un client comme DBeaver ou TablePlus)
- `3010` (API Gateway — appelé par le navigateur)
- `13050` (Frontend — l'URL que tu visites)

Les autres services communiquent entre eux par le réseau Docker `senlab-net` (résolution DNS par nom de service).

### URL d'accès

| URL | Cible |
|---|---|
| http://localhost:13050 | Frontend Sen Lab Visa (interface utilisateur) |
| http://localhost:3010 | API Gateway (endpoints REST) |
| http://localhost:3010/health | Statut du gateway et des services downstream |
| http://localhost:8080 | Dashboard Traefik (optionnel) |
| postgres://senlab@localhost:5432/senlab | Base de données |

---

## Comptes de test

Le service `users-service` exécute automatiquement un script de seed au premier démarrage. Les comptes ci-dessous sont créés dans le **Lycée Limamou Laye** (école de démo, région Dakar) :

| Rôle | Identifiant | Mot de passe |
|---|---|---|
| Élève | `lycee-limamou/moussa` | `moussa123` |
| Élève | `lycee-limamou/fatou` | `fatou123` |
| Enseignant Physique-Chimie | `lycee-limamou/diallo` | `diallo123` |
| Admin école (proviseur) | `lycee-limamou/proviseur` | `proviseur123` |
| Sysadmin global | `sysadmin/root` | `sysadmin123` |
| Admin legacy | `admin/root` | `admin123` |

Connecte-toi sur **http://localhost:13050/login** avec un de ces couples identifiant / mot de passe.

> Le seed est **idempotent** : il vérifie l'existence du compte avant de créer. Tu peux donc relancer le service sans craindre les doublons.

---

## Commandes du `up.sh`

```bash
./up.sh                   # Build + démarre tout (mode détaché)
./up.sh logs              # Logs en live de tous les conteneurs
./up.sh logs auth-service # Logs d'un seul service
./up.sh status            # Liste des conteneurs et leur état
./up.sh stop              # Arrête (préserve la BDD)
./up.sh down              # Arrête + supprime les conteneurs (préserve la BDD)
./up.sh nuke              # Tout effacer y compris la BDD (demande confirmation)
./up.sh rebuild web       # Rebuild un service après modification du code
```

### Cas d'usage courants

**Tu modifies du code dans `sen-lab-web` et veux voir le résultat :**

```bash
./up.sh rebuild web
```

**Tu veux voir les logs en live d'un service qui crash :**

```bash
./up.sh logs gateway
```

**Tu veux remettre la BDD à zéro pour repartir propre :**

```bash
./up.sh nuke
./up.sh
```

---

## Variables d'environnement

Toutes les variables sont définies dans `sen-lab-infra/.env` :

```env
# Base de données partagée
POSTGRES_USER=senlab
POSTGRES_PASSWORD=change-me-in-prod
POSTGRES_DB=senlab
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# JWT — au moins 32 caractères pour la prod
JWT_SECRET=change-me-at-least-32-characters-long
JWT_REFRESH_SECRET=change-me-too-at-least-32-characters-long
JWT_ACCESS_TTL=900           # access token : 15 minutes
JWT_REFRESH_TTL=604800       # refresh token : 7 jours

# URL gateway côté navigateur (bakée au build du frontend)
NEXT_PUBLIC_GATEWAY_URL=http://localhost:3010

# Compte admin créé au premier seed
SEED_ADMIN_IDENTIFIER=admin/root
SEED_ADMIN_PASSWORD=admin123
SEED_ADMIN_FULLNAME=Super Admin

# Traefik (uniquement utile en prod avec un nom de domaine)
TRAEFIK_DOMAIN=senlab.local
TRAEFIK_ACME_EMAIL=admin@example.com
```

> **Important** : `NEXT_PUBLIC_GATEWAY_URL` est lu **au moment du build** du conteneur `web` (Next.js intègre les variables `NEXT_PUBLIC_*` dans le bundle JavaScript final). Si tu changes cette URL, lance `./up.sh rebuild web` pour reconstruire le frontend.

---

## Développement (sans Docker)

Si tu préfères lancer chaque service en mode hot-reload Node, tu peux te passer de Docker pour les services applicatifs (mais garde Postgres en Docker pour simplifier) :

```bash
# 1. Lance uniquement Postgres
docker compose -f sen-lab-infra/docker/docker-compose.yml --env-file sen-lab-infra/.env up -d postgres

# 2. Configure le .env de chaque service pour pointer vers localhost:5432
#    (chaque service a son propre .env basé sur .env.example)

# 3. Lance chaque service en mode dev
cd sen-lab-shared-types && pnpm install && pnpm build && cd ..
cd sen-lab-auth-service && pnpm install && pnpm prisma:generate && pnpm start:dev &
cd sen-lab-users-service && pnpm install && pnpm prisma:generate && pnpm start:dev &
# ... etc pour les 7 microservices

# 4. Lance le gateway
cd sen-lab-gateway && pnpm install && pnpm start:dev &

# 5. Lance le frontend
cd sen-lab-web && pnpm install && pnpm dev
```

Le mode hot-reload est plus rapide pour itérer sur le code, mais demande de gérer manuellement les ports et les `.env`. Pour une démo ou un déploiement, utilise `./up.sh`.

---

## Dépannage

### "no space left on device" pendant le build

Docker accumule du cache de build. Nettoie-le sans toucher aux volumes (la BDD reste préservée) :

```bash
docker builder prune -af
docker image prune -af
```

### Un conteneur reste en `Restarting`

Vérifie les logs :

```bash
docker logs senlab-<service>
```

Le plus souvent, c'est un problème de connexion à Postgres ou de variable d'env manquante.

### "port already in use"

Un autre process occupe les ports 5432, 3010 ou 13050. Soit tu l'arrêtes, soit tu changes le mapping dans `sen-lab-infra/docker/docker-compose.yml`.

### Mot de passe oublié

Lance `./up.sh nuke` puis `./up.sh` — le seed recrée les comptes par défaut.

---

## Structure du repo `sen-lab-infra`

```
sen-lab-infra/
├── docker/
│   ├── docker-compose.yml         # 11 services orchestrés
│   ├── docker-compose.prod.yml    # override prod (TLS, restart always)
│   └── traefik/                   # config additionnelle traefik
├── docs/
│   ├── ARCHITECTURE.md            # vue d'ensemble stack + 11 repos
│   ├── PRD_SenLabVisa.md          # produit
│   ├── Vision_Strategique.md      # vision et PMF
│   ├── Curriculum_Referentiel.md  # matrice curriculum Sénégal
│   ├── Database_Schema.md         # schéma DB
│   ├── Design_System.md           # couleurs, typo, UX
│   ├── Glossaire_Local.md         # contextualisation culturelle
│   └── TP_Scenarios_Master.md     # manuel de scénarisation TP
├── scripts/
│   ├── bootstrap.sh               # clone/pull tous les repos frères
│   └── env-init.sh                # génère .env avec secrets aléatoires
├── .env.example
└── README.md                      # ce fichier
```

---

## Roadmap

- **Phase 0 (terminée)** — Architecture microservices, 3 TP pilotes, UI skillzone-style, Docker Compose
- **Phase 1** — Déploiement pilote dans 3 lycées dakarois, ajout de 10 TP supplémentaires
- **Phase 2** — Builder permettant aux enseignants de créer leurs propres TP
- **Phase 3** — Tests pilotes en zone rurale (mode 100 % offline)
- **Phase 4** — Scaling national (200+ écoles)

---

## Ancrage Sénégal

Chaque TP est conçu autour d'un contexte local concret pour rendre la science palpable :

| TP | Niveau | Contexte sénégalais |
|---|---|---|
| Loi d'Ohm | 3ème | Compteur Woyofal de la maison et résistance d'une LED |
| Photosynthèse | 4ème | Élodée des mares du Saloum |
| Théorème de Pythagore | 4ème | La corde 3-4-5 du maçon de Thiès |

Plus de 60 TP alignés sur le programme officiel sont planifiés pour les phases suivantes (voir `docs/Curriculum_Referentiel.md`).

---

## Contribution

Sen Lab Visa est open source (MIT). Pour contribuer :

1. Identifie le repo concerné dans la liste ci-dessus
2. Fork puis crée une branche `feat/...` ou `fix/...`
3. Ouvre une Pull Request vers `main` avec une description claire

Pour les enseignants STEM sénégalais : contactez-nous pour proposer des scénarios de TP ancrés dans votre quotidien de classe.

---

## Licence

MIT — voir le fichier `LICENSE` dans chaque repo.

## Contact

**Sérigne Saliou Faye** — sesaf1998@gmail.com — UADB (Université Alioune Diop de Bambey)
