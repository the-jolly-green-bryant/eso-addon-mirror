# AetherChat — Changelog

## [1.2.0] — 2026-08-30

### 🇫🇷 Français

#### 🌟 Mots-Clés & Mentions Personnalisées (Pings)
- **Surveillance en direct :** Détection instantanée de vos mots-clés configurés (`@Pseudo`, `WTS`, `WTT`, `Tank`, `Heal`, `Motif`, `vSS`...).
- **Marqueur d'alerte `★` :** Une étoile colorée apparaît à gauche de l'horodatage (`★ [14:16]`) pour repérer immédiatement les lignes importantes.
- **Badge stylisé `[MOT]` :** Encadrement net des mots-clés sous forme de tag pour une visibilité maximale sans encombrer la lecture.
- **Palette de 7 Couleurs au Choix :** Or de Bordeciel, Rose Néon (style Mention Discord), Cyan Céleste, Vert Émeraude, Ambre Brûlé, Violet Arcaniste, Jaune Éclair.
- **Sonnerie d'alerte paramétrable :** Choix parmi un catalogue de sons immersifs à haute audibilité lors de la réception d'un mot-clé d'un autre joueur.
- **Rendu Rétroactif et Dynamique :** Tout l'historique existant s'illumine instantanément lors de l'ajout d'un mot-clé.

#### 🔍 Recherche en Direct dans le Chat (SearchBox)
- **Barre de recherche intégrée :** Champ de recherche discret dans l'en-tête avec icône loupe et bouton d'effacement rapide.
- **Filtrage instantané :** Filtre en direct les messages du canal actif par nom d'auteur ou contenu du message.

#### 📋 Copie Rapide de Message & Détection de Liens
- **Détection des URLs & Discord :** Mise en évidence céleste des adresses Web et invitations Discord (`discord.gg/...`).
- **Fenêtre de copie dédiée :** Modale au style nordique permettant de copier facilement n'importe quel texte ou lien avec Ctrl+C.

#### 🛍️ Ventes de Boutique de Guilde Améliorées
- **Extraction du véritable nom de l'objet :** Récupération automatique du nom ou du lien d'objet réel (`|H1:item:...|h[Nom]|h`) depuis le corps de la facture.
- **Formatage ergonomique :** `[Boutique de Guilde] Vente : [Nom / Lien] pour 4 464 Or`.
- **Annonce CSA harmonisée :** `[Vente] [Nom de l'objet] (+4 464 Or)`.

#### 👥 Statuts de Guilde Épurés
- **Suppression du double préfixe :** Disparition des répétitions de nom de guilde dans le canal.
- **Couleurs contrastées :** Vert pour les connexions, gris sobre pour les déconnexions.

#### 🖥️ Résolution & Échelle Visuelle
- **Détection automatique :** Adaptation aux écrans 720p, 1080p, 1440p (2K) et 2160p (4K).
- **Curseur d'échelle manuelle :** Redimensionnement de la fenêtre de 60% à 150%.

#### 🛡️ Correctifs & Stabilité
- Correction du bug de conversion de chaîne dans la purge d'historique (`History.PruneExpiredMessages`).
- Correction des ancres XML de la SearchBox pour un focus fluide.

---

### 🇬🇧 English

#### 🌟 Custom Keywords & Mention Alerts (Pings)
- **Real-Time Monitoring:** Instant detection of your custom keywords and mentions (`@MyName`, `WTS`, `WTT`, `Tank`, `Heal`, `Motif`, `vSS`...).
- **Alert Star `★`:** A color-coded star marker appears next to the timestamp (`★ [14:16]`) to easily scan important lines.
- **Sleek `[KEYWORD]` Badge:** Clean bracketed tag formatting for crystal-clear readability without visual clutter.
- **7 Accent Colors:** Skyrim Gold, Neon Pink (Discord Mention Style), Celestial Cyan, Emerald Green, Burnt Amber, Arcanist Purple, Lightning Yellow.
- **Customizable Audio Chimes:** Select from a catalogue of high-audibility immersive notification sounds.
- **Instant Retroactive Highlighting:** Full chat history highlights instantly when adding or editing keywords.

#### 🔍 Live Chat Search
- **Integrated Search Bar:** Sleek header search box with magnifier icon and quick clear button.
- **Real-Time Filtering:** Instantly filters active channel history by sender name or message content.

#### 📋 Quick Copy Modal & Link Detection
- **URL & Discord Detection:** Automatic detection and sky-blue highlighting for Web links and Discord invites (`discord.gg/...`).
- **Dedicated Copy Window:** Authentic Skyrim-styled modal with direct Ctrl+C clipboard copy support.

#### 🛍️ Enhanced Guild Store Sales
- **Real Item Name Extraction:** Automatically extracts the true sold item name or link (`|H1:item:...|h[Item]|h`) from the mail body.
- **Clean Formatting:** `[Guild Store] Sold: [Item Name] for 4,464 Gold`.
- **Streamlined CSA Announcement:** `[Item Sold] [Item Name] (+4,464 Gold)`.

#### 👥 Refined Guild Member Status
- **Clean Channel Output:** Removed repetitive guild name tags in guild tabs.
- **Color-Coded Status:** Bright green for login, subtle grey for logout.

#### 🖥️ Screen Resolution & UI Scaling
- **Automatic Detection:** Optimized default scaling for 720p, 1080p, 1440p (2K), and 2160p (4K).
- **Manual Scale Slider:** Custom window sizing from 60% to 150%.

#### 🛡️ Bug Fixes & Stability
- Fixed type conversion error in history retention pruner (`History.PruneExpiredMessages`).
- Fixed XML layout anchors on the SearchBox for instant focus on click.
