# AetherChat — Changelog

## [1.2.2] — 2026-08-30

### 🇫🇷 Français
- **Fix — Restitution Intégrale du Chat Officiel ESO (`UndockNativeChatEntry`) :**
  - Correction d'un problème majeur où la boîte de texte officielle (`ZO_ChatWindowTextEntry`) restait emprisonnée dans la fenêtre AetherChat une fois celle-ci fermée.
  - La boîte de saisie est désormais immédiatement détachée et restituée à sa place d'origine dans le chat de base d'ESO dès qu'AetherChat est masqué. Le chat classique fonctionne ainsi à 100% sans aucun conflit.
- **Fix — Clic Gauche sur l'Icône HUD Flottante (`AetherChat_MinBar`) :**
  - Réactivation du clic gauche direct sur l'icône flottante pour ouvrir et fermer AetherChat de manière fluide pour les joueurs n'utilisant pas de raccourci clavier.
- **Nouveau — Bouton de Fermeture Officiel (`ZO_CloseButton`) :**
  - Ajout d'une croix de fermeture dédiée en haut à droite de l'en-tête de la fenêtre AetherChat pour une fermeture rapide en 1 clic.

---

### 🇬🇧 English
- **Fix — Native ESO Chat Input Restoration (`UndockNativeChatEntry`):**
  - Fixed a critical issue where the native ESO text entry box (`ZO_ChatWindowTextEntry`) remained attached inside the hidden AetherChat window when closed, preventing typing in the default chat.
  - Text input is now instantly undocked and returned to its default location in the native chat window as soon as AetherChat is closed. Default chat now works seamlessly at 100%.
- **Fix — Left-Click Toggle on Floating HUD Icon (`AetherChat_MinBar`):**
  - Re-enabled direct left-click interaction on the moveable HUD icon to open and close AetherChat for players who prefer clicking over keybindings.
- **New — Official Header Close Button (`ZO_CloseButton`):**
  - Added an authentic Skyrim close button in the top-right header for quick 1-click window closing.

---

## [1.2.0] — 2026-08-30

### 🇫🇷 Français
- **Mots-Clés & Mentions Personnalisées (Pings) :**
  - Surveillance en direct de vos mots-clés (`@Pseudo`, `WTS`, `WTT`, `Tank`, `Heal`, `Motif`, `vSS`...).
  - Marqueur d'alerte `★` coloré devant l'horodatage (`★ [14:16]`) pour repérer instantanément les messages importants.
  - Badge stylisé `[MOT]` encadrant les mots-clés pour une netteté visuelle parfaite.
  - Palette de 7 couleurs d'accentuation au choix dans les paramètres LAM.
  - Sons d'alerte haute audibilité personnalisables.
- **Recherche en Direct dans le Chat (SearchBox) :**
  - Filtrage instantané de l'historique du canal actif par auteur ou mot-clé.
- **Copie Rapide & Détection d'URLs :**
  - Détection automatique et coloration des liens Discord et Web avec modale de copie dédiée.
- **Ventes de Boutique de Guilde Améliorées :**
  - Extraction du nom ou lien réel de l'objet vendu (`|H1:item:...|h[Nom]|h`) depuis le corps de la facture.
- **Statuts de Guilde Épurés :**
  - Suppression des répétitions de noms de guilde et contraste vert/gris pour connexions/déconnexions.
- **Support Multi-Résolutions :**
  - Détection automatique pour écrans 720p, 1080p, 1440p (2K) et 2160p (4K) avec curseur d'échelle.

---

### 🇬🇧 English
- **Custom Keywords & Mention Alerts (Pings):**
  - Real-time monitoring with `★` timestamp prefix and clean `[KEYWORD]` bracketed badges.
  - 7 selectable accent colors and customizable audio chimes.
- **Live Chat Search (SearchBox):**
  - Real-time instant filtering of active channel history by author or keyword.
- **Quick Copy Modal & Link Detection:**
  - Automatic detection and highlighting for Web and Discord links with dedicated copy window.
- **Enhanced Guild Store Sales:**
  - True sold item name/link extraction from mail invoices with refined CSA alerts.
- **Multi-Resolution UI Scaling:**
  - Auto-detection for 720p to 4K displays and manual scale slider.
