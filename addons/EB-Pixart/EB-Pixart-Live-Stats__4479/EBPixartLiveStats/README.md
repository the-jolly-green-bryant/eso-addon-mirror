# EBPixartLiveStats

Addon Elder Scrolls Online en Lua pour afficher des statistiques de session en direct.

## Fonctionnalites incluses

- Initialisation propre via `EVENT_ADD_ON_LOADED`
- Variables sauvegardees account-wide avec `ZO_SavedVars:NewAccountWide`
- Dependance declaree vers `LibAddonMenu2.0>=31`
- Commande slash `/ebstats`
- Fenetre UI simple et extensible
- Base modulaire pour stats, combat, UI et parametres

## Fichiers

- `EBPixartLiveStats.txt` : manifest ESO
- `Core.lua` : point d'entree et initialisation
- `Stats.lua` : stockage et acces aux statistiques de session
- `Combat.lua` : gestion des evenements de combat
- `UI.lua` : fenetre de statistiques
- `Settings.lua` : integration LibAddonMenu2.0
- `Strings_FR.lua` : chaines FR
- `bindings.xml` : declaration des raccourcis

## Installation

1. Placez le dossier `EBPixartLiveStats` dans `Documents/Elder Scrolls Online/live/AddOns/`.
2. Verifiez que `LibAddonMenu-2.0` est installe.
3. Remplacez `REPLACE_WITH_CURRENT_ESO_API_VERSION` dans `EBPixartLiveStats.txt` par l'API ESO courante.

## Notes

Le fichier `bindings.xml` prepare une action de raccourci nommee `EBPIXARTLIVESTATS_TOGGLE_WINDOW`.
