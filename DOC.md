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

Sur le plan logique, le symbole `%` est traité comme un opérateur mathématique, permettant d’effectuer une opération de modulo(reste de la division écludienne) dans l’expression saisie.

Il est intégré au moteur de calcul au même titre que les autres opérateurs `(+, −, ×, ÷)`, et respecte les règles de priorité définies dans l’évaluation des expressions.

   # 7.2. Choix ergonomique et visuel

Sur le plan visuel, le bouton `%` n’est pas mis en évidence comme les opérateurs principaux (+, −, ×, ÷).

Il est volontairement affiché avec le même style que les boutons utilitaires (comme le bouton C : Réinitialisation) et les chiffres :
 - couleur de fond neutre,
 - texte blanc,

Ce choix est motivé par les raisons suivantes :

  - le `%` est une fonction secondaire dans l’usage courant d’une calculatrice, le distinguer visuellement des opérateurs principaux améliore la lisibilité globale, ce comportement est conforme aux calculatrices numériques modernes (ex. Google Calculator).

Ainsi, le bouton `%` est :

 - opérateur sur le plan logique,
 - bouton utilitaire sur le plan ergonomique.

## 8. Gestion des priorités opératoires

L’application intègre un moteur de calcul interne capable d’évaluer correctement les expressions mathématiques saisies par l’utilisateur en respectant les règles de priorité des opérateurs (également appelées priorités opératoires).

## 8.1. Règles de priorité appliquées

Les opérateurs sont évalués selon l’ordre de priorité suivant :

Multiplication (×), Division (÷) et Modulo (%)

Addition (+) et Soustraction (−)

Ainsi, une expression comme : 2 + 3 × 4 est correctement évaluée comme : 2 + (3 × 4) = 14
et non comme : (2 + 3) × 4 = 20


Ce comportement est conforme aux règles mathématiques standards et à celui des calculatrices réelles.

## 8.2. Principe de fonctionnement du moteur de calcul

L’évaluation des expressions repose sur une analyse structurée de la chaîne saisie (_expr) :

- l’expression est découpée en nombres et opérateurs,

  - les opérateurs sont traités en fonction de leur niveau de priorité,

  - les opérations de priorité élevée sont calculées en premier,

le résultat final est ensuite déterminé de manière séquentielle.

Cette approche permet :

- d’éviter toute ambiguïté dans le calcul,
- de garantir un résultat correct quelle que soit la complexité de l’expression,

## 8.3. Intégration du modulo (%) dans les priorités

L’opérateur `%` est intégré au même niveau de priorité que la multiplication et la division.
Exemple : 10 % 3 + 4 = 5

Ce choix assure une cohérence mathématique et un comportement prévisible pour l’utilisateur.

## 8.4. Avantages de cette approche

La gestion explicite des priorités permet :
- une fidélité au raisonnement mathématique standard,
  - un comportement identique à celui des calculatrices physiques,
  - une meilleure compréhension des résultats affichés,
  - une base évolutive pour l’ajout futur de fonctionnalités (parenthèses, mode scientifique, etc.).


## 9. Choix ergonomiques
Les choix suivants ont été faits pour améliorer l’expérience utilisateur :
  - Couleurs contrastées pour une bonne lisibilité.
  - Taille de police adaptable à la largeur de l’écran.
  - Interaction fluide avec effet tactile.
  - Comportement cohérent avec les calculatrices physiques et numériques existantes.

---

## 10. Gestion de l’orientation de l’écran

Afin de garantir une interface stable, lisible et conforme à la maquette fournie, l’application est volontairement verrouillée en mode portrait.

Ce choix est motivé par les points suivants :

  - la maquette de la calculatrice est conçue pour un usage vertical,

  - les écrans en mode paysage (faible hauteur) peuvent provoquer des débordements visuels (RenderFlex overflow),

  - les calculatrices réelles et numériques sont principalement utilisées en orientation portrait sur smartphone.
