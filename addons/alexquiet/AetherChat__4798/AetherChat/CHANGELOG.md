# Journal des Modifications (Changelog) — AetherChat

Toutes les modifications notables apportées à l'addon **AetherChat** sont consignées dans ce document.

---

## [1.3.0] - 2026-09-09

### 🎮 Prise en Charge Manette Complète & Mode Hybride (Gamepad)
- **Compatibilité Manette & Raccourcis Dédiés :**
  - AetherChat reste pleinement actif et visible lors du jeu à la manette (`IsInGamepadPreferredMode`).
  - Nouveaux raccourcis assignables dans *Commandes > AetherChat* : **Basculer Mode Standard / Compact** (`AETHERCHAT_TOGGLE_MODE`), **Onglet suivant** (`AETHERCHAT_NEXT_TAB`), **Onglet précédent** (`AETHERCHAT_PREV_TAB`), **Guilde suivante** (`AETHERCHAT_NEXT_GUILD`) et **Activer/Quitter la saisie** (`AETHERCHAT_FOCUS_CHAT`).
  - Défilement optimisé en mode Compact : arrêt unique sur l'onglet `[Guildes ▾]` correspondant à la vue écran (1:1), avec rotation directe des guildes via le nouveau raccourci ou menu déroulant à la souris.
- **Libération Intelligente de la Saisie :**
  - **Annulation par déplacement (Joystick)** : Libère instantanément le chat dès que le joueur pousse le stick gauche ou commence à marcher, redonnant immédiatement le contrôle des sorts et des mouvements.
  - **Protection en combat** : Fermeture automatique de la saisie dès l'entrée en combat.
- **Mode Chat Exclusif AetherChat :**
  - Nouvelle option dans les réglages : permet de désactiver intégralement le chat manette officiel d'ESO (`GAMEPAD_SETTING_USE_KEYBOARD_CHAT`) afin d'éviter tout conflit, disparition du chat ou basculement intempestif vers l'interface console.

### 🚀 Mode Ultra-Compact & Ergonomie
- **Disposition Ultra-Compacte Réinventée :**
  - Permutation instantanée entre Mode Standard (Messenger complet avec volet latéral) et Mode Ultra-Compact (bandeau d'onglets horizontaux minimaliste) via bouton dédié ou raccourci.
  - Sauvegarde indépendante des dimensions et positions pour chaque mode.
  - Menu contextuel au clic droit sur l'onglet [Zone] pour le filtrage linguistique instantané (Tous, EN, FR, DE, RU, ES, JP, ZH).
  - Déplacement fluide par glisser-déposer de la fenêtre compacte.

### 📁 Canaux & Onglets Personnalisés (Custom Tabs)
- **Créateur d'Onglets Personnalisés :**
  - Fenêtre de configuration dédiée avec sélection parmi 10 emblèmes officiels haute résolution (Étoile, Or, PvP, Raid, Donjon, Courrier, Lore, Artisanat, Tel Var, Histoires de Gloire).
  - Matrice de filtrage multi-canaux (Zone multi-langues, Dire, Crier, Chuchoter, Groupe, PNJ, Guildes 1 à 5, Officiers 1 à 5).
  - Agrégation rétroactive dynamique des messages existants.
  - Modification et suppression faciles par clic droit sur l'onglet compact.

### 🌐 Bilinguisme Intégral 100% (Français & Anglais)
- **Audit & Parité Complète des Traductions :**
  - Traduction bilingue intégrale et miroir parfait entre le français et l'anglais pour l'ensemble des 283 clés de localisation (`Localization.lua`).
  - Traduction dynamique complète des infobulles de redimensionnement de la fenêtre (bords droit, supérieur et inférieur), des noms et infobulles des onglets compacts, des menus contextuels de filtrage de zone et des alertes de butin/ventes.
  - Traduction intégrée des noms de thèmes et de sonneries dans le panneau de configuration LibAddonMenu (LAM).
  - Élimination de 100% des chaînes en dur restantes dans le code Lua.

---

## [1.2.6] - 2026-09-05

### ✨ Interface & Expérience Utilisateur

- **Double Interface & Mode Ultra-Compact (Au choix dans les paramètres) :**
  - **Mode Standard (Messenger complet)** : L'interface riche originale avec sa barre latérale développable ou réductible en mini-dock de tuiles 38px reste 100% active par défaut et inchangée.
  - **Mode Ultra-Compact (Nouveau)** : Une disposition épurée pensée pour les joueurs souhaitant un encombrement minimal sur l'écran (à l'instar du chat natif d'ESO) :
    - Bandeau d'onglets horizontaux supérieur (`[Zone]`, `[Général]`, `[Groupe]`, `[Système]`, `[Butin]`, `[Guildes ▾]` et onglets de chuchotements dynamiques `[@Ami ✕]`).
    - Menu déroulant contextuel pour basculer facilement entre les 5 guildes avec badges de notifications cumulés.
    - Filtrage linguistique instantané par clic droit sur l'onglet `[Zone]`.
    - Bascule rapide du filtre "Sets Uniquement" par clic droit sur l'onglet `[Butin]`.
    - 100% de la largeur de la fenêtre allouée à la lecture des messages (plus aucune perte d'espace sur une colonne latérale).
    - Boîte de texte native `ZO_ChatWindowTextEntry` intégrée sur toute la largeur inférieure.
    - Redimensionnement libre jusqu'à `320x180 px` pour se loger discrètement dans le coin inférieur gauche de l'écran.
    - **Mémoire de géométrie indépendante** : Sauvegarde et restauration séparée des coordonnées et dimensions pour le mode Standard et le mode Compact.
    - **Bascule instantanée 1-clic** : Bouton direct dans l'en-tête et commande `/aethermode` ou `/acmode`.

- **Refonte et Harmonisation de la Barre Latérale Réduite (Mini-Dock) :**
  - Géométrie carrée symétrique nordique (`38x38 px`) avec espacement vertical aéré (`strideY = 44`).
  - Dégagement parfait de 10px entre les tuiles et la barre de défilement (largeur de rail calibrée à 60px avec ascenseur moderne de 8px).
  - Ancrage des badges de notifications non lues (`TOPRIGHT`) avec dimensionnement adaptatif (18px pour 1 chiffre, 22px pour 2+ chiffres) éliminant tout chevauchement et tout problème de rognage par le rectangle de découpe (scissor rect).
  - Remplacement de l'icône de dossier de guildes par le blason officiel d'héraldique d'ESO (`/esoui/art/guild/tabicon_heraldry_up.dds`) pour une cohérence visuelle parfaite.

### 🛡️ Butin & Social

- **Fiabilisation Totale du Butin & Chuchotement Rapide (« Need » 1-Clic) :**
  - Résolution forcée et prioritaire des identifiants de compte (`@DisplayName`) pour l'ensemble des membres de groupe, amis, guildes et historique LootLog.
  - Affichage systématique du looteur sous la forme de son `@Compte` dans le flux de butin, garantissant le bon fonctionnement à 100% du chuchotement automatique en 1 clic pour demander une pièce de set.

### ⚡ Architecture & Standards ZOS

- **Conformité & Nettoyage Architectural :**
  - Épuration des modules expérimentaux externes.
  - Respect strict de l'ordre de chargement des manifestes XML avant l'exécution du code Lua.
  - Namespace global unifié `AetherChat` et synchronisation sans faille des variables sauvegardées.

---

## [1.2.4] - 2026-09-01

### ✨ Nouvelles Fonctionnalités & Conformité ESO UI (ZOS Standard)

- **Architecture 100% Native ZO_HUDFadeSceneFragment :**
  - Migration complète du cycle de vie de la fenêtre vers le système officiel de fragments ZOS (`ZO_HUDFadeSceneFragment` avec `SetConditional()`).
  - Suppression de tous les workarounds et hooks artificiels pour un masquage/réouverture automatique instantané et fluide lors de l'ouverture des menus du jeu.
- **Conformité des Dépendances du Manifest :**
  - Passage de LootLog en directive `OptionallyDependsOn: LootLog>=409060` pour garantir un chargement propre avec ou sans LootLog.
- **Canal Dédié « Système » (System) :**
  - Ajout d'un nouvel onglet Système indépendant isolant l'ensemble des flux et notifications du moteur de jeu d'ESO (annonces de diffusion serveur, messages d'état, alertes de donjons, alertes de zone et confirmations de files d'attente).
  - Capture automatique et transparente de 100% des messages émis via `CHAT_SYSTEM:AddMessage` et `EVENT_BROADCAST`.
  - Intégration de l'icône officielle de rouage de chat d'ESO (`chat_options_up.dds`) avec support complet du glisser-déposer.

- **Curseur de Typographie Globale en Temps Réel :**
  - Nouveau curseur précis permettant d'ajuster la taille de police de 12px à 24px avec rendu instantané.
  - L'échelle typographique s'applique désormais proportionnellement à **toute l'interface** : messages du chat, liste des canaux, onglets de dossiers, barre de recherche et titres d'en-tête.

- **Support Typographique Universel (Cyrillique & International) :**
  - Migration vers les polices natives officielles `$(CHAT_FONT)` et `$(BOLD_FONT)` du moteur d'ESO.
  - Affichage net et complet des caractères cyrilliques (russe / ukrainien) et des alphabets internationaux sur le mégaserveur européen, éliminant définitivement les boîtes vides (`[][][]`).

- **Scanner de Ventes de Guilde en Direct (Partout en Tamriel) :**
  - Intégration d'un écouteur en temps réel (`EVENT_GUILD_HISTORY_CATEGORY_UPDATED`, `EVENT_GUILD_HISTORY_REFRESHED`) permettant de notifier instantanément les ventes de boutique de guilde même en plein donjon, raid ou combat.
  - Notification centrale à l'écran (CSA) avec bandeau doré, tintement de pièces d'or et archivage automatique dans le canal Général & Ventes.

---

### 🛠️ Améliorations & Optimisations

- **Stabilité Totale du Curseur & Focus Caméra :**
  - Suppression intégrale des forçages manuels de caméra (`SetGameCameraUIMode`) au profit d'une gestion fluide et native de la fenêtre flottante (`TopLevelControl`).
  - Consommation stricte de l'événement clic de souris (`return true`) sur l'icône flottante HUD (MinBar) afin d'éviter tout ciblage ou attaque accidentelle dans le monde 3D.
- **Persistance Renforcée des Données & Géométrie :**
  - Mémorisation et restauration exacte de la position (`windowPos`), des dimensions de la fenêtre (`windowDimensions`), de la taille de police (`chatFontSize`) et du thème choisi à chaque connexion, téléportation ou `/reloadui`.
  - Correction de la table de sélection de la durée de rétention de l'historique (24h, 3 jours, 1 semaine, 1 mois, Illimité) pour une persistance sans faille.
- **Résolution Multi-Source des Pseudos & Whispers :**
  - Résolution dynamique des comptes `@AccountName` à travers le groupe, la liste d'amis et les 5 guildes du joueur pour fiabiliser les messages privés.
  - Mémorisation de l'état de fermeture des onglets de chuchotement pour empêcher leur réouverture involontaire lors des transitions de zone.
- **Bilinguisme Intégral (FR / EN) :**
  - Traduction exhaustive et vérifiée à 100% de toutes les nouvelles options, descriptions, infobulles et noms de canaux en français et en anglais.
- **Épuration de l'Interface :**
  - Suppression des options obsolètes (bouton de réduction docké superflu, paliers de résolution rigides) pour une expérience utilisateur plus propre, légère et moderne.

---

## [1.2.2] - 2026-08-30

- Refonte du système de nettoyage et de formatage des liens d'objets dans le canal Butin & Loots.
- Synchronisation bidirectionnelle avec LootLog (capture des loots personnels et de groupe avec lien direct vers le joueur).
- Ajout des pilules de filtrage linguistique pour le canal Zone (Toutes, FR, EN, DE, ES, Global).
- Système de mots-clés et mentions personnalisées (Pings dorés et alertes sonores).
- Système de réorganisation des onglets par glisser-déposer (Drag & Drop) avec sauvegarde automatique.
