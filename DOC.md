# Documentation – Conception de l’interface et gestion des calculs

## 1. Présentation générale
Cette application est une **calculatrice mobile développée avec Flutter**, visant à reproduire le comportement et l’ergonomie d’une calculatrice réelle, tout en garantissant une adaptation correcte à toutes les tailles d’écran (**responsivité**).

L’interface respecte une maquette imposée, avec :
  - des **boutons circulaires**,
  - un **bouton égal (=)** vertical occupant deux lignes,
  - une **séparation claire** entre l’expression saisie et le résultat.

---

## 2. Gestion de l’affichage (Expression / Résultat)
L’affichage est divisé en deux zones :
  - **Zone supérieure (petite taille)** : affiche l’expression mathématique saisie par l’utilisateur.
  - **Zone inférieure (grande taille)** : affiche le résultat du calcul.

**Comportement après validation (=)** :
  - L’expression complète est affichée en haut avec le symbole `=` (exemple : `1×2=`).
  - Le résultat est affiché en grand en bas (exemple : `2`).

 Ce choix améliore la lisibilité et permet à l’utilisateur de comprendre clairement quelle opération a produit le résultat affiché.

---

## 3. Gestion interne des données
Trois variables principales sont utilisées :
  - `_expr` : contient l’expression courante utilisée pour le calcul.
  - `_lastExpr` : mémorise l’expression validée (affichée en haut après `=`).
  - `_display` : contient la valeur affichée en grand (résultat ou saisie en cours).

Cette séparation permet :
- d’afficher l’expression sans perturber les calculs internes,
  - de continuer un calcul à partir du résultat,
  - d’éviter la duplication du résultat dans les deux zones.

---

## 4. Gestion des erreurs
Lorsqu’une expression invalide est évaluée (exemple : division par zéro), le moteur de calcul retourne **Error**.

Comportement adopté :
  - `Error` est affiché uniquement dans la zone du résultat.
  - Si l’utilisateur appuie ensuite sur un chiffre ou sur le point (`.`), la calculatrice se réinitialise automatiquement et démarre une nouvelle saisie.

 Ce comportement correspond à celui des calculatrices réelles et évite toute confusion.

---

## 5. Gestion de la responsivité
Pour garantir une compatibilité avec les petits écrans (ex. Nexus S) et les écrans modernes (Pixel, etc.), la taille des boutons est calculée dynamiquement.

**Approche utilisée** :
  - Utilisation de `LayoutBuilder` pour récupérer la hauteur et la largeur disponibles.
      - Calcul de la taille des boutons en fonction :
      - du nombre de lignes du clavier,
      - de l’espace vertical disponible,
      - de l’espace horizontal disponible.
  - La taille finale des boutons est la plus petite valeur possible entre la contrainte verticale et horizontale.

 Cette méthode garantit :
  - l’absence totale de débordement (**RenderFlex overflow**),
  - un rendu cohérent sur tous les appareils,
  - le respect strict de la maquette.

---

## 6. Alignement du bouton égal (=)
Le bouton égal est conçu comme une **pilule verticale** occupant exactement la hauteur de deux lignes de boutons standards.

Formule utilisée : hauteur = 2 × taille_bouton + espacement


 Cette approche garantit un alignement parfait avec les deux lignes adjacentes, sans décalage visuel, même sur des écrans de tailles différentes.

---

## 7. Choix d’implémentation du bouton pourcentage (%)

Le bouton pourcentage (%) a fait l’objet d’un choix spécifique, à la fois fonctionnel et ergonomique.

   # 7.1. Rôle fonctionnel

Sur le plan logique, le symbole `%` est traité comme un opérateur mathématique, permettant d’effectuer une opération de modulo dans l’expression saisie.

Il est intégré au moteur de calcul au même titre que les autres opérateurs `(+, −, ×, ÷)`, et respecte les règles de priorité définies dans l’évaluation des expressions.

   # 7.2. Choix ergonomique et visuel

Sur le plan visuel, le bouton `%` n’est pas mis en évidence comme les opérateurs principaux (+, −, ×, ÷).

Il est volontairement affiché avec le même style que les boutons utilitaires (comme le bouton C) et les chiffres :
 - couleur de fond neutre,
 - texte blanc,
 - bouton circulaire standard.

Ce choix est motivé par les raisons suivantes :

  - le `%` est une fonction secondaire dans l’usage courant d’une calculatrice, le distinguer visuellement des opérateurs principaux améliore la lisibilité globale, ce comportement est conforme aux calculatrices numériques modernes (ex. Google Calculator).

Ainsi, le bouton `%` est :

 - opérateur sur le plan logique,
 - bouton utilitaire sur le plan ergonomique.

Ce compromis permet de conserver une hiérarchie visuelle claire tout en garantissant un comportement mathématique correct.

## 8. Choix ergonomiques
Les choix suivants ont été faits pour améliorer l’expérience utilisateur :
  - Couleurs contrastées pour une bonne lisibilité.
  - Taille de police adaptable à la largeur de l’écran.
  - Interaction fluide avec effet tactile.
  - Comportement cohérent avec les calculatrices physiques et numériques existantes.

---

## 9. Conclusion
Cette implémentation permet de concilier :
  - fidélité à la maquette,
  - robustesse fonctionnelle,
  - responsivité complète,
  - expérience utilisateur intuitive.

L’architecture choisie facilite également l’évolution future de l’application (historique des calculs, thèmes, mode scientifique, etc.).

---