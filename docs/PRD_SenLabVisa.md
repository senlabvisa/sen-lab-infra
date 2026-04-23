## 1. Vision du Produit

### 1.1 Objectif

Démocratiser l'accès à l'expérimentation scientifique pour tous les élèves du Sénégal (collège et lycée) en remplaçant les laboratoires physiques inexistants ou sous-équipés par une plateforme de simulations virtuelles interactive, accessible hors-ligne et alignée sur le programme national.

### 1.2 Problèmes résolus

- **Fracture matérielle :** Pas besoin d'éprouvettes ou de réactifs coûteux.
- **Fracture numérique :** Fonctionne sur des appareils bas de gamme et sans connexion internet permanente (PWA).
- **Abstraction excessive :** Rend concrets les concepts théoriques de Maths, PC et SVT.

---

## 2. Profils Utilisateurs (Personas)

- **L'Élève (Moussa/Mariama) :** Accède aux TP depuis son smartphone ou le PC de l'école. Doit pouvoir manipuler, échouer, et soumettre un rapport.
- **L'Enseignant (M. Diop) :** Crée une classe, assigne des TP spécifiques, suit les progrès en temps réel et note les comptes-rendus.
- **L'Administrateur :** Gère les accès des établissements et met à jour le contenu pédagogique.

---

## 3. Spécifications Fonctionnelles

### 3.1 Cœur du Produit : Le Laboratoire Virtuel

- **Moteur de Simulation :** Interactions par "Drag & Drop".
- **Bac à sable (Sandbox) :** Mode libre pour explorer sans instructions.
- **Mode TP Guidé :** Instructions étape par étape avec validation intermédiaire.
- **Gestion de l'erreur :** Les erreurs de manipulation (ex: court-circuit) produisent des résultats visuels réalistes.

### 3.2 Espace Enseignant (LMS Lite)

- **Gestion de classe :** Création de groupes par niveau (ex: 2nde S).
- **Banque de TP :** Bibliothèque de simulations classées par chapitre du programme sénégalais.
- **Suivi (Analytics) :** Temps passé, erreurs récurrentes, score final.

### 3.3 Résilience et Accessibilité (Critique)

- **Installation PWA :** Icône sur l'écran d'accueil, sans passer par le Play Store.
- **Service Worker :** Mise en cache des simulations pour usage **100% offline**.
- **Authentification Hybride :** Connexion via numéro de téléphone (OTP) ou identifiant unique d'établissement.

---

## 4. Spécifications Techniques

### 4.1 Frontend & Simulation

- **Framework :** Next.js (App Router) pour la performance.
- **Simulations :** * `P5.js` pour les schémas 2D (optique, électricité, fonctions maths).
    - `Three.js` (format GLB compressé) pour la 3D (géométrie, molécules).
- **UI :** Tailwind CSS avec des composants "Mobile-First".

### 4.2 Backend & Data

- **Base de données :** PostgreSQL (via Supabase).
- **Stockage Local :** `IndexedDB` pour sauvegarder l'avancement hors-ligne.
- **Synchronisation :** Push des données dès le retour de la connexion (Background Sync).

---

## 5. Parcours Utilisateur Type (User Journey)

1. **Connexion :** L'élève accède à l'URL via le Wi-Fi de l'école (installation de la PWA automatique).
2. **Sélection :** Il choisit le TP assigné par son prof (ex: "Mesure de la tension").
3. **Expérimentation :** Il manipule les composants virtuels sur son écran.
4. **Rapport :** Il répond à 3 questions de synthèse en fin de manipulation.
5. **Soumission :** Le rapport est stocké localement et envoyé au prof dès qu'une connexion est détectée.

---

## 6. Critères d'Acceptation (MVP)

- La plateforme doit charger en moins de 3 secondes sur une connexion 3G.
- Une simulation de physique (ex: Circuit série) doit être fonctionnelle sans internet.
- Le prof doit pouvoir voir une liste d'élèves ayant "validé" le TP.

---

## 7. Roadmap de Développement

- **Sprint 1 :** Setup de l'architecture Next.js + PWA + Supabase.
- **Sprint 2 :** Développement de la première simulation de Mathématiques (Fonctions) et Physique (Électricité).
- **Sprint 3 :** Création du tableau de bord enseignant et système de notes.
- **Sprint 4 :** Tests en conditions réelles (Basse bande passante).

---