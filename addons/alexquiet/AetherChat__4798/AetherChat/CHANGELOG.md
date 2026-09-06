# Journal des Modifications (Changelog) — AetherChat

Toutes les modifications notables apportées à l'addon **AetherChat** sont consignées dans ce document.

---

## [1.2.6] - 2026-09-05

### ✨ Interface & Expérience Utilisateur

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
