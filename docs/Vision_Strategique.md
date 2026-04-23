## 1. Analyse du Contexte et Besoins (Le "Product-Market Fit")

- **Problème :** Absence de laboratoires physiques (coût des équipements, maintenance, produits chimiques périmés).
- **Opportunité :** Le programme national sénégalais est très théorique ; l'introduction de l'expérimentation virtuelle peut augmenter radicalement le taux de réussite au BFEM et au Bac (S1, S2, S2A).
- **Cible Prioritaire :** Établissements publics (Lycées d'Excellence, Lycées techniques et collèges de proximité).

---

## 2. Architecture Technique (La "Stack" Résiliente)

Pour répondre à la fracture numérique, nous adoptons une architecture **"Edge-Learning"**.

- **Frontend :** **React / Next.js** (Rapidité et structure modulaire).
- **Moteur de Simulation :**
    - **2D :** `p5.js` ou `Canvas API` (Léger, idéal pour les circuits électriques ou l'optique).
    - **3D :** `Three.js` avec compression `Draco` (Pour la géométrie dans l'espace ou l'anatomie en SVT).
- **Résilience (Offline-First) :** * **Service Workers :** Mise en cache automatique des simulations.
    - **PWA :** Installation sur mobile/PC sans passer par les Stores (économie de data).
    - **IndexedDB :** Sauvegarde locale des résultats de l'élève.
- **Backend & Data :** **Supabase** ou **Firebase**. Permet une gestion temps réel de l'espace enseignant et une authentification via numéro de téléphone (très utilisé au Sénégal).

---

## 3. Conception Pédagogique (Le "Contenu")

Le laboratoire ne doit pas être un jeu vidéo, mais un outil académique.

| **Matière** | **Exemple de Simulation Prioritaire** | **Concept Pédagogique** |
| --- | --- | --- |
| **Physique** | Banc d'optique virtuel | Manipulation de lentilles, calcul de vergence. |
| **Chimie** | Dosage acide-base | Virage colorimétrique, gestion des volumes. |
| **SVT** | Division cellulaire (Mitose) | Observation microscopique interactive. |
| **Maths** | Visualisateur de fonctions 3D | Compréhension des limites et des volumes. |

---

## 4. Expérience Utilisateur (UX) : L'Espace Enseignant

Le professeur est le pivot de l'adoption.

- **Dashboard "Classe" :** Visualisation de l'avancement (Ex: "80% de la classe a terminé le TP sur l'électrolyse").
- **Correcteur Automatique :** Le système vérifie si l'élève a atteint le bon résultat et génère une note préliminaire que le prof peut valider.
- **Générateur de Rapport :** L'élève peut exporter sa simulation en un compte-rendu structuré (Hypothèse -> Expérience -> Conclusion).

---

## 5. Modèle de Déploiement au Sénégal

Pour contourner le manque d'internet dans certaines zones :

1. **Le Hub Local :** Installation d'un mini-serveur local (type Raspberry Pi) dans la salle informatique de l'école. Les élèves s'y connectent en Wi-Fi local sans consommer de data internet.
2. **Partenariat Télécom :** Négocier avec Orange ou Free pour le "Zero-rating" (accès gratuit au domaine de la plateforme sans forfait data).

---

## 6. Feuille de Route (Roadmap)

- **Phase 1 (MVP) :** Développement de 3 simulations clés (1 Maths, 1 PC, 1 SVT) + Système PWA de base.
- **Phase 2 (Beta) :** Test dans 5 lycées pilotes (ex: Limamou Laye, Mariama Bâ) pour récolter les retours profs/élèves.
- **Phase 3 (Scale) :** Intégration du système de gestion des notes et déploiement national.

---

## 7. Analyse des Risques

- **Technique :** Appareils avec très peu de RAM. *Solution :* Limiter le nombre de polygones en 3D.
- **Adoption :** Résistance des enseignants au numérique. *Solution :* Formation certifiante et simplification extrême de l'interface.