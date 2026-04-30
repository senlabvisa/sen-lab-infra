# sen-lab-infra

> 🏗️ **Orchestration & infrastructure** de la plateforme **Sen Lab Visa** — laboratoires virtuels STEM pour les élèves du Sénégal.

[![Stack](https://img.shields.io/badge/stack-NestJS_+_Next.js_+_Postgres-8B5CF6)](https://github.com/senlabvisa)
[![License](https://img.shields.io/badge/license-MIT-green)](#)
[![Status](https://img.shields.io/badge/phase-0_(MVP)-blue)](#)

---

## 🎯 Le problème

Au Sénégal, **la majorité des collèges et lycées n'ont pas de laboratoire de sciences fonctionnel**. Les élèves apprennent les concepts STEM (Maths, Physique-Chimie, SVT) de manière purement théorique, sans manipuler. Cela crée :

- Un **désintérêt** pour les filières scientifiques
- Une **mauvaise compréhension** des concepts abstraits
- Une **fracture matérielle** avec les écoles bien équipées

## 💡 La solution

**Sen Lab Visa** est une **plateforme web (PWA) de laboratoires virtuels** qui permet à tout élève sénégalais de :

- 🧪 **Manipuler virtuellement** des expériences (circuits, photosynthèse, géométrie…)
- 📱 **Travailler hors-ligne** — fonctionne sur smartphone bas de gamme avec connectivité intermittente
- 🇸🇳 **Apprendre en contexte** — chaque TP est ancré dans une réalité sénégalaise (compteur Woyofal, corde du maçon de Thiès, élodée du Saloum…)
- 👩‍🏫 **Être accompagné** par son enseignant·e via le suivi de tentatives + tutorat optionnel

---

## 🏛️ Architecture

Sen Lab Visa est un **écosystème de 11 repos** organisés en microservices :

```
┌──────────────────────────────────────────────────────────────┐
│                  Browser (élève / prof / admin)              │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼  http://localhost:13050
                ┌─────────────────────────────┐
                │  sen-lab-web (Next.js PWA)  │
                └─────────────────────────────┘
                              │
                              ▼  http://localhost:3010
                ┌─────────────────────────────┐
                │  sen-lab-gateway (NestJS)   │
                └─────────────────────────────┘
                              │
        ┌─────────┬───────────┼───────────┬─────────┬──────────┐
        ▼         ▼           ▼           ▼         ▼          ▼
     ┌─────┐  ┌─────┐    ┌────────┐   ┌────────┐ ┌────────┐ ┌─────────┐
     │auth │  │users│    │schools │   │classes │ │simulat.│ │attempts │
     │3001 │  │3002 │    │ 3003   │   │ 3004   │ │ 3006   │ │ 3007    │
     └─────┘  └─────┘    └────────┘   └────────┘ └────────┘ └─────────┘
        └─────────┴──────────┴───────────┴─────────┴──────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  PostgreSQL 16   │
                    │  (5 schémas)     │
                    └──────────────────┘

      ┌────────────────────┐
      │ analytics (3008)   │  ← stateless, agrège les autres via HTTP
      └────────────────────┘
```

### Les 11 repos

| Repo | Rôle | Port | Stack |
|---|---|---|---|
| [`sen-lab-shared-types`](https://github.com/senlabvisa/sen-lab-shared-types) | DTOs et enums TypeScript partagés | — | TS |
| [`sen-lab-auth-service`](https://github.com/senlabvisa/sen-lab-auth-service) | Authentification JWT | 3001 | NestJS + Prisma |
| [`sen-lab-users-service`](https://github.com/senlabvisa/sen-lab-users-service) | Gestion utilisateurs (CRUD + import CSV) | 3002 | NestJS + Prisma |
| [`sen-lab-schools-service`](https://github.com/senlabvisa/sen-lab-schools-service) | Établissements scolaires | 3003 | NestJS + Prisma |
| [`sen-lab-classes-service`](https://github.com/senlabvisa/sen-lab-classes-service) | Classes + assignations TPs | 3004 | NestJS + Prisma |
| [`sen-lab-simulations-service`](https://github.com/senlabvisa/sen-lab-simulations-service) | Catalogue des TPs | 3006 | NestJS + Prisma |
| [`sen-lab-attempts-service`](https://github.com/senlabvisa/sen-lab-attempts-service) | Tentatives élèves + scores | 3007 | NestJS + Prisma |
| [`sen-lab-analytics-service`](https://github.com/senlabvisa/sen-lab-analytics-service) | XP, badges, dashboards | 3008 | NestJS (stateless) |
| [`sen-lab-gateway`](https://github.com/senlabvisa/sen-lab-gateway) | API Gateway (HTTP proxy) | 3010 | NestJS |
| [`sen-lab-web`](https://github.com/senlabvisa/sen-lab-web) | Frontend PWA | 13050 | Next.js 14 + Tailwind + Framer Motion |
| [`sen-lab-infra`](https://github.com/senlabvisa/sen-lab-infra) | **Orchestration Docker, scripts, docs** | — | Docker Compose + Bash |

---

## 🚀 Démarrage rapide (1 commande)

### Pré-requis

- macOS / Linux
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) lancé
- ~4 Go de RAM libre + ~2 Go de disque

### Lancement

```bash
# 1. Cloner les 11 repos dans un dossier parent senlabvisa/
mkdir -p ~/Documents/senlabvisa && cd ~/Documents/senlabvisa
for r in shared-types auth-service users-service schools-service \
         classes-service simulations-service attempts-service \
         analytics-service gateway web infra; do
  git clone https://github.com/senlabvisa/sen-lab-$r.git
done

# 2. Lancer toute la stack
cp sen-lab-infra/.env.example sen-lab-infra/.env
chmod +x ./up.sh                          # le script up.sh vit dans le parent
./up.sh                                    # build + démarre tout
```

Au premier lancement, Docker build les **9 images** et démarre **11 conteneurs** (~5-10 min). Aux relances suivantes : ~30 secondes grâce au cache.

### Accès

| URL | Cible |
|---|---|
| **http://localhost:13050** | 🎨 Frontend (Sen Lab Visa) |
| http://localhost:3010 | 🚪 API Gateway |
| http://localhost:8080 | 📊 Dashboard Traefik (optionnel) |
| postgres://senlab@localhost:5432/senlab | 💾 BDD |

### Comptes seedés (mode dev)

| Rôle | Identifiant | Mot de passe |
|---|---|---|
| 👨‍🎓 Élève | `lycee-limamou/moussa` | `moussa123` |
| 👩‍🎓 Élève | `lycee-limamou/fatou` | `fatou123` |
| 👨‍🏫 Enseignant | `lycee-limamou/diallo` | `diallo123` |
| 🏫 Admin école | `lycee-limamou/proviseur` | `proviseur123` |
| ⚙️ Sysadmin | `sysadmin/root` | `sysadmin123` |

---

## 📋 Commandes du `up.sh`

```bash
./up.sh                    # build + démarre tout (mode détaché)
./up.sh logs               # logs en live
./up.sh logs auth-service  # logs d'un seul service
./up.sh status             # liste des conteneurs
./up.sh stop               # arrête (BDD préservée)
./up.sh down               # arrête + supprime conteneurs (BDD préservée)
./up.sh nuke               # ⚠️ tout effacer (BDD comprise)
./up.sh rebuild web        # rebuild un seul service
```

---

## 📂 Structure du repo `sen-lab-infra`

```
sen-lab-infra/
├── docker/
│   ├── docker-compose.yml         # 10 services orchestrés
│   ├── docker-compose.prod.yml    # override prod (TLS, restart always)
│   └── traefik/                   # config additionnelle traefik
├── docs/
│   ├── ARCHITECTURE.md            # vue d'ensemble stack + 11 repos
│   ├── PRD_SenLabVisa.md          # produit
│   ├── Vision_Strategique.md      # vision + PMF
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

## 🌍 Ancrage Sénégal

Chaque TP est conçu autour d'un **contexte local concret** :

| TP | Contexte sénégalais |
|---|---|
| Loi d'Ohm (3ème) | Compteur Woyofal de la maison + LED |
| Photosynthèse (4ème) | Élodée des mares du Saloum |
| Théorème de Pythagore (4ème) | La corde 3-4-5 du maçon de Thiès |

Plus de 60 TPs alignés sur le programme officiel sont planifiés pour les phases suivantes (voir `docs/Curriculum_Referentiel.md`).

---

## 🛣️ Roadmap

- ✅ **Phase 0 (MVP)** — Architecture microservices + 3 TPs pilotes + UI skillzone-style + Docker
- 🟡 **Phase 1** — Déploiement pilote (3 lycées dakarois) + 10 TPs supplémentaires
- ⬜ **Phase 2** — Création de TPs par les enseignants (builder)
- ⬜ **Phase 3** — Tests pilotes en zone rurale (mode 100% offline)
- ⬜ **Phase 4** — Scaling national (200+ écoles)

---

## 🤝 Contribution

Sen Lab Visa est **open source** (MIT). Pour contribuer :

1. Identifie le repo concerné dans la liste ci-dessus
2. Fork → branche `feat/...` ou `fix/...`
3. PR vers `main` avec description claire

Pour les enseignants STEM sénégalais : contactez-nous pour proposer des **scénarios de TP** ancrés dans votre quotidien.

---

## 📜 Licence

MIT — voir le fichier `LICENSE` dans chaque repo.

## 📧 Contact

**Sérigne Saliou Faye** — sesaf1998@gmail.com — UADB (Université Alioune Diop de Bambey)
