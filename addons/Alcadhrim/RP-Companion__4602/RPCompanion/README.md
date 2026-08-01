# RP Companion

**Version:** 1.0.0  
**Author:** Didier Verstringe  
**Game:** The Elder Scrolls Online  

RP Companion is an immersive roleplay addon for The Elder Scrolls Online.

It allows roleplayers to create, edit and share character profiles directly in-game, with biography, appearance, current status, alignment, journal entries, encounters and RP profile sharing.

## Main Features

- Complete RP character profile
- Long editable biography
- “Currently” field
- Appearance field
- RP journal
- Encounter log
- Multiple profiles
- Alignment system: Lawful ↔ Chaotic
- Alignment system: Good ↔ Evil
- Morality scale
- Network tab
- Voluntary detection of other RP Companion users
- RP profile sharing and received profiles
- RP inspection through whisper-based profile exchange
- LibAddonMenu-2.0 settings panel

## Installation

1. Copy the `RPCompanion` folder into:

```text
Documents\Elder Scrolls Online\live\AddOns\
```

2. Install the required library:

```text
LibAddonMenu-2.0
```

3. Launch the game.
4. Enable RP Companion in the Add-ons menu.
5. If necessary, check `Allow out of date addons`.

## Commands

```text
/rp help
/rp ui
/rp show
/rp inspect
/rp inspect @UserID
/rp set name <text>
/rp set title <text>
/rp set race <text>
/rp set alliance <text>
/rp set status <text>
/rp set bio <text>
/rp set current <text>
/rp set appearance <text>
/rp journal add <text>
/rp encounter add <name> <note>
/rp profile create <name>
/rp profile use <name>
/rp ping <@UserID>
/rp share <@UserID>
/rp compatibles
/rp inbox
```

## Shared Profile Fields

When a profile is shared, RP Companion sends:

- Character name
- Title
- Race
- Alliance
- RP status
- Biography
- Currently
- Appearance
- Lawful ↔ Chaotic alignment
- Good ↔ Evil alignment
- Morality

## Important

If you update from an older development version and encounter issues, close the game and delete:

```text
Documents\Elder Scrolls Online\live\SavedVariables\RPCompanionSavedVars.lua
```

This will reset RP Companion saved data.

---

# Français

**Version :** 1.0.0  
**Auteur :** Didier Verstringe  
**Jeu :** The Elder Scrolls Online  

RP Companion est un addon RP immersif pour The Elder Scrolls Online.

Il permet aux rôlistes de créer, modifier et partager des fiches de personnage directement en jeu, avec biographie, apparence, statut actuel, alignement, journal, rencontres et partage de fiches RP.

## Fonctions principales

- Fiche personnage RP complète
- Biographie éditable longue
- Champ “Actuellement”
- Champ “Aspect”
- Journal RP
- Carnet de rencontres
- Profils multiples
- Alignement : Loyal ↔ Chaotique
- Alignement : Bon ↔ Mauvais
- Échelle de moralité
- Onglet Réseau
- Détection volontaire d’autres utilisateurs de RP Companion
- Partage et réception de fiches RP
- Inspection RP par échange de fiche via whisper
- Panneau d’options LibAddonMenu-2.0

## Installation

1. Copier le dossier `RPCompanion` dans :

```text
Documents\Elder Scrolls Online\live\AddOns\
```

2. Installer la bibliothèque obligatoire :

```text
LibAddonMenu-2.0
```

3. Lancer le jeu.
4. Activer RP Companion dans le menu Add-ons.
5. Si nécessaire, cocher `Allow out of date addons`.

## Commandes

```text
/rp help
/rp ui
/rp show
/rp inspect
/rp inspect @UserID
/rp set name <texte>
/rp set title <texte>
/rp set race <texte>
/rp set alliance <texte>
/rp set status <texte>
/rp set bio <texte>
/rp set current <texte>
/rp set appearance <texte>
/rp journal add <texte>
/rp encounter add <nom> <note>
/rp profile create <nom>
/rp profile use <nom>
/rp ping <@UserID>
/rp share <@UserID>
/rp compatibles
/rp inbox
```

## Champs partagés

Lorsqu’une fiche est envoyée, RP Companion partage :

- Nom du personnage
- Titre
- Race
- Alliance
- Statut RP
- Biographie
- Actuellement
- Aspect
- Alignement Loyal ↔ Chaotique
- Alignement Bon ↔ Mauvais
- Moralité

## Important

Si vous venez d’une ancienne version de développement et qu’un bug apparaît, fermez le jeu puis supprimez :

```text
Documents\Elder Scrolls Online\live\SavedVariables\RPCompanionSavedVars.lua
```

Cela réinitialisera les données sauvegardées de RP Companion.
