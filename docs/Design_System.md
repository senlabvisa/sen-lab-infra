**Philosophie :** "Clarté, Résilience et Tactile". L'interface doit être intuitive pour un élève n'ayant jamais utilisé de simulateur et lisible sous le soleil intense (contraste élevé).

---

## 1. Palette de Couleurs (Brand Colors)

Nous utilisons des couleurs qui évoquent la science et le sérieux, avec des accents vibrants pour la motivation.

- **Primaire (Science Blue) :** `#1E40AF` (Bleu profond, confiance et académie).
- **Secondaire (Action Green) :** `#059669` (Vert émeraude, utilisé pour les succès et la validation).
- **Accent (Alert Orange) :** `#F59E0B` (Orange vif pour les avertissements ou les éléments interactifs).
- **Fond (Background) :** `#F9FAFB` (Gris très clair pour réduire la fatigue oculaire).
- **Texte :** `#111827` (Presque noir pour un contraste maximal).

---

## 2. Typographie

- **Titres :** `Inter` ou `Outfit` (Sans-serif moderne, très lisible même en petite taille).
- **Corps de texte :** `Inter` (Standard pour le web, optimisé pour les écrans mobiles).
- **Monospace (Données/Maths) :** `JetBrains Mono` (Pour les valeurs numériques et les formules).

---

## 3. Principes d'UX (Expérience Utilisateur)

### 3.1 Approche Mobile-First & Tactile

- **Zone de clic :** Tous les boutons et éléments manipulables doivent avoir une taille minimale de **44x44 pixels** pour être facilement cliquables au doigt.
- **Drag & Drop :** Les éléments du labo (fils électriques, éprouvettes) doivent avoir un feedback visuel immédiat (changement de couleur ou légère vibration) quand ils sont sélectionnés.

### 3.2 Micro-interactions

- **Feedback d'erreur :** Si un élève fait une erreur (ex: court-circuit), ne pas afficher un message d'erreur textuel rouge uniquement. Utiliser un effet visuel (l'ampoule qui grille, une petite animation de fumée).
- **Chargement (Skeleton Screens) :** Comme la connexion peut être lente, afficher des formes grises pendant que le contenu charge pour montrer que l'app n'est pas "plantée".

---

## 4. Composants UI Clés

### 4.1 La "Carte TP" (TP Card)

- Doit afficher : Titre, Matière, Temps estimé, et le statut (À faire / Complété / Badge obtenu).
- Visuel : Une icône symbolisant la matière (Un atome pour la PC, une règle pour les Maths).

### 4.2 L'Interface du Laboratoire (The Canvas)

- **Zone Centrale :** Espace blanc propre pour la manipulation.
- **Barre d'outils (Sidebar ou Bottom Sheet) :** Liste des objets disponibles (résistances, béchers, etc.).
- **Bouton "Action" :** Toujours en bas à droite, bien visible (ex: "Lancer l'expérience" ou "Valider le résultat").

---

## 5. Accessibilité & Résilience (Low-End Devices)

- **Images :** Utiliser des icônes SVG (légères) au lieu d'images PNG/JPG.
- **Animations :** Limiter les animations CSS lourdes pour économiser la batterie des téléphones.
- **Contraste :** Respecter le ratio WCAG 2.1 (AA) pour s'assurer que les élèves malvoyants puissent utiliser la plateforme.

---

## 6. Instructions pour Claude (Copilote)

1. **Framework UI :** Utilise exclusivement **Tailwind CSS** pour l'intégration.
2. **Icônes :** Utilise la bibliothèque **Lucide-React** (légère et moderne).
3. **Simulations :** Pour les canvas `p5.js`, utilise un fond blanc (`background(255)`) et des traits épais pour une visibilité optimale sur petit écran.