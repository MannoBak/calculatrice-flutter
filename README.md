# Calculatrice Flutter

Cette application mobile de calculatrice a été développée par **BAKOUAN Hermann** et **KABORE Zakaria** dans le cadre du cours de développement mobile. Elle permet d’effectuer des opérations arithmétiques de base dans une interface moderne et intuitive.

## Fonctionnalités

- Interface utilisateur moderne basée sur **Material 3**
- Thème sombre pour une meilleure lisibilité
- Calculs de base :
    - Addition
    - Soustraction
    - Multiplication
    - Division
- Architecture modulaire avec séparation entre logique métier et interface

## Technologies utilisées

- **Flutter** (SDK mobile multiplateforme)
- **Dart** (langage de programmation)
- **Android Studio** (environnement de développement intégré utilisé pour ce projet)

## Structure du projet

lib/
├── main.dart                # Point d’entrée de l’application
├── pages/
│   └── calc_page.dart      # Interface utilisateur de la calculatrice
└── services/
└── logique.dart         # Logique métier (calculs)


## Installation

Pour exécuter l’application localement :

```bash
git clone https://github.com/MannoBak/calculatrice-flutter.git
cd calculatrice-flutter
flutter pub get
flutter run
