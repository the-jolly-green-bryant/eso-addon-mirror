# TraitTimer - Research Tracker for ESO

**Version 1.4.1** | by HMariou

---

## English

### What does it do?

TraitTimer is a HUD widget that displays your active trait research timers and missing traits directly on screen, so you never forget a research slot sitting idle.

### Features

- **Live countdown timers** for all active trait research (Blacksmithing, Clothier, Woodworking, Jewelry)
- **Missing traits view** showing which traits you still need to research for each item
- **Owned trait detection** - traits you own an item for are highlighted in blue so you know which ones you can research right now
- **Chat alerts** when a research completes and when you have free research slots at login
- **Resizable & movable** widget - drag to reposition, drag edges to resize
- **Minimizable** to a compact header bar
- **Settings panel** via LibAddonMenu (optional)

### Timer colors

| Color | Meaning |
|-------|---------|
| Red | More than 3 days remaining |
| Orange | 1 to 3 days remaining |
| Yellow | 6 hours to 1 day remaining |
| Yellow-green | 1 to 6 hours remaining |
| Green | Less than 1 hour remaining |

### Missing traits colors

| Color | Meaning |
|-------|---------|
| Light blue | You own an item with this trait - you can research it now! |
| Grey | You don't have an item for this trait yet |

### Slot status colors

| Color | Meaning |
|-------|---------|
| Green | You have free research slots available |
| Grey | All research slots are in use |

### Commands

| Command | Action |
|---------|--------|
| `/tt` | Show or hide the widget |
| `/tt lock` | Lock/unlock widget position |
| `/tt scan` | Print research summary in chat |
| `/tt missing` | Switch between Timers and Missing Traits view |
| `/tt width 500` | Set widget width (270-800) |
| `/tt help` | Show available commands |

### Buttons

- **`><`** Switch between Timers view and Missing Traits view
- **`-`** Minimize the widget / **`+`** Expand it back

### Installation

1. Extract the `TraitTimer` folder into:
   `Documents/Elder Scrolls Online/live/AddOns/`
2. Launch the game - the addon appears automatically
3. (Optional) Install **LibAddonMenu-2.0** for a settings panel in Settings > Addons > TraitTimer

### Settings (requires LibAddonMenu-2.0)

- Hide in combat
- Lock position
- Default view (Timers or Missing Traits)
- Background opacity (0-100%)
- Reset position & size

---

## Francais

### A quoi ca sert ?

TraitTimer est un widget HUD qui affiche vos recherches de traits en cours et les traits manquants directement a l'ecran, pour ne plus jamais oublier un emplacement de recherche libre.

### Fonctionnalites

- **Compte a rebours en temps reel** pour toutes les recherches de traits actives (Forge, Couture, Travail du bois, Joaillerie)
- **Vue des traits manquants** montrant quels traits vous devez encore rechercher pour chaque objet
- **Detection des traits possedes** - les traits pour lesquels vous avez un objet sont affiches en bleu pour savoir lesquels vous pouvez rechercher immediatement
- **Alertes dans le chat** quand une recherche se termine et quand vous avez des emplacements libres a la connexion
- **Widget redimensionnable et deplacable** - glissez pour repositionner, tirez les bords pour redimensionner
- **Minimisable** en barre compacte
- **Panneau d'options** via LibAddonMenu (optionnel)

### Couleurs des timers

| Couleur | Signification |
|---------|---------------|
| Rouge | Plus de 3 jours restants |
| Orange | 1 a 3 jours restants |
| Jaune | 6 heures a 1 jour restant |
| Jaune-vert | 1 a 6 heures restantes |
| Vert | Moins d'1 heure restante |

### Couleurs des traits manquants

| Couleur | Signification |
|---------|---------------|
| Bleu clair | Vous possedez un objet avec ce trait - vous pouvez le rechercher maintenant ! |
| Gris | Vous n'avez pas encore d'objet pour ce trait |

### Couleurs des emplacements

| Couleur | Signification |
|---------|---------------|
| Vert | Vous avez des emplacements de recherche disponibles |
| Gris | Tous les emplacements sont utilises |

### Commandes

| Commande | Action |
|----------|--------|
| `/tt` | Afficher ou masquer le widget |
| `/tt lock` | Verrouiller/deverrouiller la position |
| `/tt scan` | Afficher le resume des recherches dans le chat |
| `/tt missing` | Basculer entre la vue Recherches et Traits manquants |
| `/tt width 500` | Definir la largeur du widget (270-800) |
| `/tt help` | Afficher les commandes disponibles |

### Boutons

- **`><`** Basculer entre la vue Recherches et la vue Traits manquants
- **`-`** Minimiser le widget / **`+`** Le re-agrandir

### Installation

1. Extraire le dossier `TraitTimer` dans :
   `Documents/Elder Scrolls Online/live/AddOns/`
2. Lancer le jeu - l'addon apparait automatiquement
3. (Optionnel) Installer **LibAddonMenu-2.0** pour avoir un panneau d'options dans Parametres > Extensions > TraitTimer

### Options (necessite LibAddonMenu-2.0)

- Masquer en combat
- Verrouiller la position
- Vue par defaut (Recherches ou Traits manquants)
- Opacite du fond (0-100%)
- Reinitialiser position et taille
