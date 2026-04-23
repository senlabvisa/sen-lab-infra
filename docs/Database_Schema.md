**Architecture :** Relationnelle (PostgreSQL)

**Objectif :** Gérer les utilisateurs, les sessions de TP, la progression pédagogique et la gamification.

---

## 1. Gestion des Utilisateurs et Accès

### Table `profiles`

Stocke les informations de base des utilisateurs (élèves et profs).

- `id` : uuid (clé primaire, liée à l'auth Supabase)
- `full_name` : text (Nom complet)
- `role` : enum ('student', 'teacher', 'admin')
- `phone_number` : text (Identifiant principal au Sénégal)
- `school_id` : uuid (clé étrangère vers la table `schools`)
- `grade_level` : text (ex: '3eme', 'Terminal S2')
- `xp_points` : integer (Défaut : 0)

### Table `schools`

- `id` : uuid
- `name` : text (ex: 'Lycée Limamou Laye')
- `region` : text (ex: 'Dakar', 'Saint-Louis')

---

## 2. Structure Pédagogique

### Table `classes`

- `id` : uuid
- `teacher_id` : uuid (FK vers `profiles`)
- `name` : text (ex: '3ème A', 'Terminale S2-1')
- `academic_year` : text (ex: '2023-2024')

### Table `class_students`

Lien entre les élèves et leurs classes respectives.

- `class_id` : uuid
- `student_id` : uuid

---

## 3. Laboratoire et Résultats

### Table `simulations`

Référentiel des expériences disponibles.

- `id` : uuid
- `title` : text (ex: 'Dosage Acide-Base')
- `subject` : enum ('Maths', 'Physique-Chimie', 'SVT')
- `target_grade` : text
- `slug` : text (ex: 'dosage-chimie-3eme' - utilisé pour l'URL)

### Table `tp_attempts` (La plus importante)

Enregistre chaque session de TP d'un élève.

- `id` : uuid
- `student_id` : uuid
- `simulation_id` : uuid
- `status` : enum ('started', 'completed', 'failed')
- `score` : float (Note sur 20)
- `data_json` : jsonb (Stocke les variables de l'expérience : volumes utilisés, erreurs commises, etc.)
- `created_at` : timestamp (Date de réalisation)
- `synced_at` : timestamp (Pour vérifier si la donnée locale a été envoyée au serveur)

---

## 4. Gamification

### Table `badges`

- `id` : uuid
- `name` : text
- `description` : text
- `icon_url` : text

### Table `student_badges`

- `student_id` : uuid
- `badge_id` : uuid
- `awarded_at` : timestamp

---

## 5. Instructions pour Claude (Copilote)

1. **Synchronisation Offline :** Lors de la génération du code de soumission, utilise `localStorage` ou `IndexedDB` pour stocker temporairement les lignes de la table `tp_attempts` si `navigator.onLine` est faux.
2. **Sécurité :** Les profs ne peuvent lire que les données des élèves liés à leurs propres `classes`.
3. **Performances :** Utilise des requêtes `JSONB` pour analyser les erreurs fréquentes des élèves dans la table `tp_attempts` sans alourdir la base.

---