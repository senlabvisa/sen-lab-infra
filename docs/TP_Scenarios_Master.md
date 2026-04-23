# Manuel de Scénarisation des TP : LaboSénégal STEM

**Objectif :** Standardiser la structure pédagogique de chaque simulation pour garantir une expérience utilisateur (UX) fluide et une efficacité d'apprentissage maximale.

---

## 1. Structure Standard d'une Session de TP (Le "Workflow")

Chaque TP doit obligatoirement suivre ces 5 étapes :

### Étape 1 : Phase d'Engagement (L'Amorce)

- **Titre du TP :** En lien avec le programme officiel.
- **Objectif Pédagogique :** "À la fin de ce TP, tu seras capable de..."
- **Contexte Local :** Une courte phrase liant le concept à une réalité sénégalaise (ex: "Comme dans les installations solaires de Diamniadio...").

### Étape 2 : Hypothèse & Prédiction (Le "Bridge")

- **Questionnement :** Avant de manipuler, l'élève doit répondre à une question prédictive (ex: "À ton avis, si on augmente la résistance, que va-t-il se passer pour l'intensité ?").
- **Objectif :** Activer les connaissances théoriques du cours.

### Étape 3 : Manipulation (Le Cœur du Labo)

- **Mode Guidé :** Instructions étape par étape (ex: "1. Glisse la pile sur le circuit").
- **Interactivité :** L'élève doit pouvoir modifier des variables (curseurs, boutons, drag & drop).
- **Gestion de l'erreur :** Si l'élève fait une mauvaise manipulation, afficher un indice visuel au lieu d'un message bloquant (ex: une fumée virtuelle en cas de court-circuit).

### Étape 4 : Observation & Collecte de Données

- **Tableau de mesures :** Un petit tableau intégré où l'élève note ses résultats ou clique sur un bouton "Enregistrer la mesure".
- **Graphique Dynamique :** Visualisation en temps réel (ex: tracé de la caractéristique d'un dipôle).

### Étape 5 : Conclusion & Validation

- **Vérification de l'hypothèse :** "Ton hypothèse de départ était-elle correcte ?"
- **Quiz de sortie :** 2 ou 3 questions rapides pour valider la compréhension.
- **Génération du Rapport :** Un résumé automatique des actions effectuées par l'élève.

---

## 2. Règles de Design Pédagogique (Instructions pour Claude)

1. **Simplicité de la langue :** Utiliser des verbes d'action (Prends, Verse, Mesure, Observe).
2. **Feedback Immédiat :** Chaque action de l'élève doit avoir une réaction visuelle instantanée.
3. **Progression de la difficulté :** Commencer par un TP très simple (tutoriel) avant de passer aux concepts complexes.
4. **Autonomie :** Toujours proposer un bouton "Aide" ou "Indice" qui n'enlève pas de points, mais guide l'élève.

---

## 3. Exemples de scénarios types par matière

### Physique-Chimie : Le Dosage Acide-Base

- **Manipulation :** Remplir la burette, ouvrir le robinet goutte à goutte.
- **Point de contrôle :** L'élève doit arrêter le versage dès que la couleur change (indicateur coloré).
- **Calcul :** L'élève doit entrer la formule $CaVa = CbVb$ pour trouver la concentration inconnue.

### Mathématiques : Le Théorème de Pythagore

- **Manipulation :** Déplacer les sommets d'un triangle rectangle.
- **Observation :** Voir les carrés sur les côtés se remplir d'eau (analogie visuelle classique).
- **Validation :** Vérifier que la somme des aires des deux petits carrés est toujours égale à l'aire du grand carré, peu importe la forme du triangle rectangle.

---

## 4. Métriques de Réussite (Données à envoyer au prof)

Pour chaque TP, le fichier `tp_attempts` (voir Database_Schema) doit enregistrer :

- **Temps total :** Durée de la session.
- **Nombre d'erreurs :** Tentatives infructueuses avant la réussite.
- **Score final :** Basé sur la précision des mesures et le quiz de sortie.

---