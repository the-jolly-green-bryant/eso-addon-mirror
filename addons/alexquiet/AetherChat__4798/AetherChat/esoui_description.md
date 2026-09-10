# Description Officielle ESOUI (Prête à copier-coller)

---

```bbcode
[CENTER]
[SIZE="6"][COLOR="Gold"][B]✦ AETHERCHAT ✦[/B][/COLOR][/SIZE]
[SIZE="3"][COLOR="LightSteelBlue"][I]The Modern, Immersive Messenger & Complete Chat Suite for The Elder Scrolls Online[/I][/COLOR][/SIZE]
[SIZE="2"][COLOR="PaleGreen"][B]Version 1.3.0 — Full Gamepad Support, Ultra-Compact Mode & Custom Tabs[/B][/COLOR][/SIZE]
[/CENTER]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[SIZE="4"][COLOR="SkyBlue"][B]📦 DEPENDENCIES / DÉPENDANCES[/B][/COLOR][/SIZE]
[LIST]
[*][B]Mandatory / Requis :[/B] [B][URL="https://www.esoui.com/downloads/info7-LibAddonMenu.html"]LibAddonMenu-2.0[/URL][/B] (Version >= 43) [I]— Required for settings, themes, and configuration menus.[/I]
[*][B]Optional / Optionnel :[/B] [B][URL="https://www.esoui.com/downloads/info1455-LootLog.html"]LootLog[/URL][/B] (Version >= 409060) [I]— For advanced group drop tracking and collection detection.[/I]
[/LIST]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[CENTER]
[SIZE="5"][COLOR="Gold"][B]🇬🇧 ENGLISH PRESENTATION & OVERVIEW[/B][/COLOR][/SIZE]
[/CENTER]

[B]AetherChat[/B] completely revolutionizes the Elder Scrolls Online chat interface into a modern, sleek, and intuitive messenger inspired by contemporary communication apps and Nordic fantasy aesthetics. It enhances immersion, social connectivity, and convenience across every activity in Tamriel—from Trials and Dungeons to Guild Trading, Gamepad play, and Roleplay.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[SIZE="4"][COLOR="Orange"][B]✨ NEW IN VERSION 1.3.0[/B][/COLOR][/SIZE]

[B]🎮 Full Gamepad & Controller Support[/B]
[LIST]
[*][B]Full Gamepad Compatibility:[/B] AetherChat remains active and fully accessible whether you play with mouse/keyboard or an Xbox/PlayStation controller.
[*][B]Dedicated Controller Keybindings:[/B] Bind [B]Toggle Mode[/B], [B]Next Tab[/B], [B]Previous Tab[/B], [B]Next Guild[/B], and [B]Focus / Unfocus Chat[/B] directly to your controller buttons (Bumper, Trigger, D-Pad, etc.) in [I]Settings -> Controls -> AetherChat[/I].
[*][B]Optimized 1:1 Compact Tab Cycling:[/B] Tab navigation stops exactly once on the active guild tab, matching the visual layout. Use the dedicated [B]Next Guild[/B] keybind to rotate through guilds instantly without cluttering the main cycle.
[*][B]Smart Joystick Movement Auto-Release:[/B] Moving the left thumbstick or beginning to walk instantly dismisses chat input focus, immediately restoring full control of character movement and abilities.
[*][B]Combat Safety:[/B] Automatically releases chat input when entering combat so you never get locked into typing during fights.
[*][B]Exclusive Chat Mode:[/B] Option in [I]Settings -> AetherChat -> Gamepad[/I] that automatically activates ESO's native [B]GAMEPAD_SETTING_USE_KEYBOARD_CHAT[/B], completely disabling the native gamepad HUD bubble and routing all chat cleanly through AetherChat.
[/LIST]

[B]🚀 Reimagined Ultra-Compact Layout[/B]
[LIST]
[*][B]Minimalist Horizontal Tab Bar:[/B] Switch between Full Messenger mode (with expandable sidebar) and Ultra-Compact mode ([B]Zone[/B], [B]General[/B], [B]Group[/B], [B]System[/B], [B]Loot[/B], [B]Guilds ▾[/B], [B]Custom Tabs[/B]).
[*][B]100% Reading Area:[/B] No lost horizontal space; fits cleanly in the bottom corner of your screen (down to 320x180 px).
[*][B]Independent Geometry Memory:[/B] Position and dimensions are saved independently for standard and compact modes.
[*][B]Instant 1-Click Toggle:[/B] Seamlessly switch anytime with the header toggle button or via [B]/aethermode[/B] / [B]/acmode[/B].
[*][B]Context Menus:[/B] Right-click [B]Zone[/B] to switch language filter; right-click [B]Loot[/B] to toggle Set Pieces Only filter.
[/LIST]

[B]📁 Custom Tabs System[/B]
[LIST]
[*][B]Custom Multi-Channel Tabs:[/B] Create personalized tabs with custom labels, colors, and 10 official high-res emblems (Star, Gold, PvP, Raid, Dungeon, Mail, Lore, Crafting, Tel Var, Tales of Tribute).
[*][B]Multi-Channel Filtering Matrix:[/B] Combine any channels into a single tab: Zone (multi-language), Say, Yell, Whisper, Group, NPC, Guilds 1-5, and Officer channels 1-5.
[*][B]Retroactive History Aggregation:[/B] Automatically pulls existing chat history into your new tab upon creation.
[/LIST]

[B]🌐 100% Bilingual Parity (English & French)[/B]
[LIST]
[*][B]Comprehensive Bilingual Audit:[/B] Complete parity across all settings, menus, themes, sounds, tooltips, edge resizing handles, context menus, and chat system announcements.
[*][B]Zero Untranslated Strings:[/B] Every single UI element dynamically adapts to the selected client or addon language with no hardcoded leftovers.
[/LIST]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[SIZE="4"][COLOR="Orange"][B]✨ CORE FEATURES[/B][/COLOR][/SIZE]

[B]🌟 Modern Messenger Architecture & Native Scene Orchestration[/B]
[LIST]
[*][B]Nordic Sleek Interface:[/B] High-fidelity dark slate panels with refined metallic accents, smooth animations, and clean typography.
[*][B]Collapsible Sidebar Rail:[/B] Switch seamlessly between an expanded sidebar with full channel labels and a minimalist compact icon dock to maximize screen real estate.
[*][B]Native Chat Replacement & Smart Input Docking:[/B] Full two-way synchronization with default ESO chat. When AetherChat closes, text focus instantly restores to standard chat without friction.
[*][B]Native Scene Fragment Integration:[/B] Fully compliant with ZOS Scene Manager architecture ([B]ZO_HUDFadeSceneFragment[/B] with [B]SetConditional[/B]). Automatically hides when opening game menus (Escape, Inventory, Skills, Map) and restores seamlessly upon returning to the world.
[*][B]Combat Auto-Close:[/B] Optional automatic window hiding during combat to keep your battlefield view entirely clear.
[/LIST]

[B]⚙️ Dedicated System Channel & Broadcast Scanner[/B]
[LIST]
[*][B]Dedicated System Tab:[/B] Separate channel capturing 100% of game status messages, server broadcasts, queue alerts, and dungeon announcements.
[*][B]Official ESO Gear Icon:[/B] Crisp native system texture with full drag-and-drop channel reordering support.
[/LIST]

[B]🔔 Moveable Floating HUD Dock & Status Badges[/B]
[LIST]
[*][B]Freely Moveable HUD Widget:[/B] A subtle, draggable floating icon that can be placed anywhere on your screen.
[*][B]Rich Hover Tooltip:[/B] Instant summary showing total unread messages, online friends count, and unread mail.
[*][B]Dynamic Tri-Color Notification Badges:[/B]
  [LIST]
  [*]🔴 [COLOR="Red"][B]Red Badge:[/B][/COLOR] Unread messages counter (Whispers, Guilds, Party, Mentions).
  [*]🟢 [COLOR="Lime"][B]Green Badge:[/B][/COLOR] Real-time online friends count.
  [*]🔵 [COLOR="DeepSkyBlue"][B]Blue Badge:[/B][/COLOR] Unread mail indicator.
  [/LIST]
[/LIST]

[B]💬 Dedicated Channels, Guilds & Private Whispers (DMs)[/B]
[LIST]
[*][B]Organized Channels:[/B] Dedicated tabs for Zone, General/Say, Group/Party, System, and Loot.
[*][B]Collapsible Guild Sections:[/B] Expand or collapse your 5 guilds with clean status indicators.
[*][B]Private Messaging Suite (DMs):[/B] Individual whisper conversations featuring multi-source account resolution, online presence indicators, unread counters, and 1-click conversation closing.
[/LIST]

[B]🌍 Instant Multi-Zone Language Filters & Cyrillic Support[/B]
[LIST]
[*][B]Interactive Language Pills:[/B] Filter Zone chat instantly right from the header or right-click: [B]ALL[/B], [B]FR[/B], [B]EN[/B], [B]DE[/B], [B]RU[/B], [B]ES[/B], [B]JP[/B], [B]ZH[/B].
[*][B]Full Unicode & Cyrillic Support:[/B] Crystal-clear rendering of Russian, Cyrillic, and extended European alphabets without empty boxes ([][][]).
[/LIST]

[B]🔤 Real-Time Typography Scaling[/B]
[LIST]
[*][B]Dynamic Font Size Slider:[/B] Adjust message font size smoothly from 12px to 24px with proportional scaling across the entire interface (messages, sidebar, header, search).
[/LIST]

[B]🔍 Live In-Chat Search[/B]
[LIST]
[*][B]Instant Live Filtering:[/B] Real-time search bar embedded directly in the header with magnifier icon and 1-click clear button.
[*][B]Fast Search:[/B] Search messages across the active channel by sender name or message content in milliseconds.
[/LIST]

[B]🎯 Custom Keywords & Mention Alerts (Pings)[/B]
[LIST]
[*][B]Personalized Watchlist:[/B] Track any custom word or tag ([I]@MyName, WTS, WTT, Tank, Heal, Motif, vCR, vSS, LF[/I]).
[*][B]Visual Highlight & Star Marker:[/B] Triggered lines display a colored [B]★ star marker[/B] beside the timestamp, with the keyword framed in a stylish [B]{KEYWORD}[/B] badge.
[*][B]Audible Chime Alert:[/B] Crisp audio notification plays when a monitored keyword is detected.
[*][B]7 Selectable Accent Colors:[/B] Customize your ping badge with Skyrim Gold, Neon Pink, Celestial Cyan, Emerald Green, Burnt Amber, Arcanist Purple, or Lightning Yellow.
[/LIST]

[B]💎 Smart Loot & Gear Feed with 1-Click "Need"[/B]
[LIST]
[*][B]Filtered Loot Feed:[/B] Dedicated loot log with customizable quality filters (White, Green, Blue, Purple, Gold) and an "Equipment Only" / "Sets Only" toggle.
[*][B]Enhanced Item Display:[/B] Shows equipment traits (e.g. [I]Divines, Infused, Arcane[/I]), item icons, and an alert tag [B]|cFFCC00!!!|r[/B] on gear set pieces.
[*][B]1-Click Need Whisper:[/B] Right-click any looted item to whisper a customizable template message directly to the looter or ask in party chat.
[/LIST]

[B]💰 Live Guild Store Sales Alerts (Combat & Dungeons)[/B]
[LIST]
[*][B]Real-Time History Scanner:[/B] Instantly detects sales anywhere in Tamriel (even inside trials, dungeons, and combat).
[*][B]Center Screen Announcement (CSA):[/B] Gold banner notification, audio coin chime, and clean log in the General channel.
[/LIST]

[B]🎨 Visual Themes & Window Geometry[/B]
[LIST]
[*][B]5 Crafted Visual Themes:[/B] Skyrim Dragonborn, Dwemer Gold, Nordic Emerald, Crimson Brotherhood, and Dark Glass.
[*][B]Multi-Edge Resizing:[/B] Resize the window freely using responsive edge handles with full persistence across sessions.
[/LIST]

[B]📜 Persistent Chat History[/B]
[LIST]
[*][B]Configurable Retention:[/B] Retain your conversations across reloadui, zone transitions, and logout (1 day, 3 days, 1 week, 1 month, or Unlimited).
[/LIST]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[SIZE="4"][COLOR="SkyBlue"][B]⌨️ SLASH COMMANDS & KEYBINDINGS[/B][/COLOR][/SIZE]
[LIST]
[*][B]Esc -> Controls -> AetherChat:[/B]
  [LIST]
  [*]Toggle AetherChat Window
  [*]Toggle Standard / Ultra-Compact Mode
  [*]Next Tab (Cycle through channels / custom tabs)
  [*]Previous Tab
  [*]Next Guild (Compact Mode)
  [*]Focus / Unfocus Chat Input
  [/LIST]
[*][B]/aetherchat[/B] or [B]/ac[/B] or [B]/aether[/B] — Toggle AetherChat window.
[*][B]/aethermode[/B] or [B]/acmode[/B] — Toggle between Standard Messenger and Ultra-Compact layout.
[*][B]/aethericon[/B] — Show / hide the floating HUD dock widget.
[*][B]/chathead[/B] — Test message and notification sounds.
[/LIST]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[SIZE="4"][COLOR="Gold"][B]👏 CREDITS & ACKNOWLEDGMENTS[/B][/COLOR][/SIZE]
[LIST]
[*][B]LibAddonMenu-2.0:[/B] Created by [I]sirinsidiator & Seerah[/I].
[*][B]LootLog Integration:[/B] Inspired by and integrated with [I]LootLog by code65536[/I].
[*][B]Community Inspiration:[/B] Special thanks to the ESO UI developer community, notably the creators of [I]pChat[/I] (Ayantir / Baertram) and [I]ArkadiusTradeTools[/I] (Arkadius) whose foundational work on chat ergonomics and guild history parsing paved the way for modern ESO UI development.
[/LIST]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[CENTER]
[SIZE="5"][COLOR="Gold"][B]🇫🇷 PRÉSENTATION & FONCTIONNALITÉS EN FRANÇAIS[/B][/COLOR][/SIZE]
[/CENTER]

[B]AetherChat[/B] transforme intégralement l'interface de discussion classique de The Elder Scrolls Online en une messagerie moderne, fluide et immersive, inspirée des meilleures applications contemporaines et de l'ambiance nordique des parchemins anciens.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[SIZE="4"][COLOR="Orange"][B]✨ NOUVEAUTÉS VERSION 1.3.0[/B][/COLOR][/SIZE]

[B]🎮 Prise en Charge Manette Complète & Mode Exclusif (Gamepad)[/B]
[LIST]
[*][B]Compatibilité Manette Totale :[/B] AetherChat reste actif et utilisable que vous jouiez au clavier/souris ou à la manette (Xbox / PlayStation).
[*][B]Raccourcis Manette Dédiés :[/B] Attribuez dans [I]Échap -> Commandes -> AetherChat[/I] les actions [B]Basculer Mode Standard / Compact[/B], [B]Onglet suivant[/B], [B]Onglet précédent[/B], [B]Guilde suivante[/B] et [B]Activer/Quitter la saisie[/B] sur vos gâchettes ou boutons favoris.
[*][B]Défilement 1:1 en Mode Compact :[/B] La navigation par onglets s'arrête une seule fois sur l'onglet de guilde active (conforme à l'affichage visuel). La touche dédiée [B]Guilde suivante[/B] permet de faire tourner les 5 guildes directement sans quitter l'onglet.
[*][B]Libération Intelligente de la Saisie (Stick Gauche) :[/B] Dès que vous poussez le joystick de déplacement ou commencez à marcher, la saisie se ferme automatiquement pour redonner immédiatement le contrôle des sorts et des mouvements.
[*][B]Sécurité en Combat :[/B] Fermeture automatique de la saisie dès l'entrée en combat pour éviter tout blocage.
[*][B]Mode Chat Exclusif AetherChat :[/B] Option dédiée dans [I]Réglages -> Extensions -> AetherChat[/I] qui active le paramètre natif d'ESO [B]GAMEPAD_SETTING_USE_KEYBOARD_CHAT[/B], désactivant proprement la bulle de chat d'ATH et le chat console officiel.
[/LIST]

[B]🚀 Disposition Ultra-Compacte Réinventée[/B]
[LIST]
[*][B]Bandeau d'Onglets Horizontaux Minimaliste :[/B] Basculez d'un clic entre le mode Messenger complet (volet latéral) et le mode Ultra-Compact ([B]Zone[/B], [B]Général[/B], [B]Groupe[/B], [B]Système[/B], [B]Butin[/B], [B]Guildes ▾[/B], [B]Onglets Perso[/B]).
[*][B]100% d'Espace de Lecture :[/B] Aucune perte d'espace latéral ; se loge discrètement dans le coin inférieur gauche (jusqu'à 320x180 px).
[*][B]Mémoire de Géométrie Indépendante :[/B] Dimensions et positions distinctes mémorisées pour chaque mode.
[*][B]Bascule Instantanée 1-Clic :[/B] Bouton dédié dans l'en-tête ou commandes [B]/aethermode[/B] / [B]/acmode[/B].
[*][B]Menus Contextuels Rapides :[/B] Clic droit sur [B]Zone[/B] pour filtrer la langue instantanément ; clic droit sur [B]Butin[/B] pour basculer le filtre "Sets uniquement".
[/LIST]

[B]📁 Canaux & Onglets Personnalisés (Custom Tabs)[/B]
[LIST]
[*][B]Création d'Onglets sur Mesure :[/B] Créez vos propres onglets avec nom personnalisé, couleur et sélection parmi 10 emblèmes officiels haute résolution (Étoile, Or, PvP, Raid, Donjon, Courrier, Lore, Artisanat, Tel Var, Histoires de Gloire).
[*][B]Matrice de Filtrage Multi-Canaux :[/B] Associez n'importe quels canaux (Zone multi-langues, Dire, Crier, Chuchoter, Groupe, PNJ, Guildes 1-5, Officiers 1-5).
[*][B]Agrégation Rétroactive :[/B] Récupère et affiche dynamiquement l'historique des messages correspondants dès la création.
[/LIST]

[B]🌐 Bilinguisme Intégral 100% (Français & Anglais)[/B]
[LIST]
[*][B]Audit Bilingue Complet :[/B] Traduction intégrale et miroir parfait entre le français et l'anglais pour l'ensemble des paramètres LAM, infobulles, menus contextuels, poignées d'étirement de fenêtre, alertes CSA et annonces système.
[*][B]Zéro Texte Résiduel :[/B] Remplacement de toutes les chaînes fixes par le moteur de localisation dynamique [B]L(...)[/B].
[/LIST]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[SIZE="4"][COLOR="Orange"][B]✨ FONCTIONNALITÉS MAJEURES[/B][/COLOR][/SIZE]

[B]🌟 Interface Moderne & Intégration Native au Scene Manager[/B]
[LIST]
[*][B]Design Nordique Épuré :[/B] Panneaux ardoise sombres, bordures ouvragées et lisibilité optimale.
[*][B]Volet Latéral Rétractable :[/B] Basculez en un clic du mode étendu (avec noms des canaux) au mode compact (avec icônes seules).
[*][B]Remplacement Transparent du Chat Natif :[/B] Synchronisation totale avec le chat du jeu. Dès la fermeture d'AetherChat, la saisie clavier retourne immédiatement au chat par défaut.
[*][B]Intégration Standard par Fragments :[/B] Conforme aux normes ZOS ([B]ZO_HUDFadeSceneFragment[/B] avec [B]SetConditional[/B]). Se masque automatiquement lors de l'ouverture des menus du jeu (Échap, Réglages, Inventaire, Carte) et réapparaît à la fermeture.
[*][B]Masquage en Combat :[/B] Option de fermeture automatique lors de l'entrée en combat pour une visibilité totale.
[/LIST]

[B]⚙️ Canal « Système » Dédié & Capture des Annonces[/B]
[LIST]
[*][B]Onglet Système Dédié :[/B] Isole 100% des messages du moteur de jeu, alertes de zone, files d'attente et diffusions de serveur.
[*][B]Icône Officielle d'Engrenage :[/B] Texture native d'ESO avec réorganisation par glisser-déposer.
[/LIST]

[B]🔔 Widget HUD Flottant & Badges Tri-Couleurs[/B]
[LIST]
[*][B]Icône HUD Déplaçable :[/B] Bouton discret positionnable librement sur votre écran avec mémorisation de l'emplacement.
[*][B]Infobulle Complète au Survol :[/B] Récapitulatif instantané des messages non lus, amis en ligne et courriers en attente.
[*][B]Badges Dynamiques :[/B]
  [LIST]
  [*]🔴 [COLOR="Red"][B]Pastille Rouge :[/B][/COLOR] Total des messages non lus (Chuchotements, Guildes, Groupe, Mentions).
  [*]🟢 [COLOR="Lime"][B]Pastille Verte :[/B][/COLOR] Amis connectés en ligne.
  [*]🔵 [COLOR="DeepSkyBlue"][B]Pastille Bleue :[/B][/COLOR] Courriers reçus non lus.
  [/LIST]
[/LIST]

[B]💬 Canaux Organisés, Guildes & Chuchotements Privés (DMs)[/B]
[LIST]
[*][B]Onglets Dédiés :[/B] Canaux séparés pour Zone, Général (/say), Groupe (/party), Système et Butin.
[*][B]Sections de Guilde Repliables :[/B] Dépliez ou repliez vos 5 guildes avec indicateurs de présence.
[*][B]Messagerie Privée Complète :[/B] Conversations individuelles avec résolution automatique des comptes (@AccountName), statut de présence, compteur non-lus et fermeture rapide.
[/LIST]

[B]🌍 Filtres de Zone Multilingues & Support Cyrillique[/B]
[LIST]
[*][B]Pastilles de Langue Interactives :[/B] Filtrez le canal Zone d'un simple clic : [B]ALL[/B], [B]FR[/B], [B]EN[/B], [B]DE[/B], [B]RU[/B], [B]ES[/B], [B]JP[/B], [B]ZH[/B].
[*][B]Support Intégral du Cyrillique :[/B] Rendu net des caractères russes, cyrilliques et internationaux sans boîte vide ([][][]).
[/LIST]

[B]🔤 Curseur de Taille de Police en Temps Réel[/B]
[LIST]
[*][B]Typographie Dynamique :[/B] Ajustez précisément la taille de texte de 12px à 24px répercutée sur toute l'interface.
[/LIST]

[B]🔍 Recherche Textuelle en Direct (Live Search)[/B]
[LIST]
[*][B]Filtrage Instantané :[/B] Barre de recherche intégrée dans l'en-tête avec loupe et bouton d'effacement rapide.
[/LIST]

[B]🎯 Mots-Clés & Mentions Personnalisées (Pings)[/B]
[LIST]
[*][B]Surveillance Personnalisée :[/B] Suivez vos termes favoris ([I]@MonPseudo, WTS, WTT, Tank, Heal, Motif, vCR, vSS, Cherche[/I]).
[*][B]Alerte Visuelle & Étoile ★ :[/B] Étoile dorée ★ et mot-clé encadré d'un badge coloré avec sonnerie claire.
[*][B]7 Couleurs d'Accentuation au Choix :[/B] Or nordique, Rose Néon, Cyan Céleste, Vert Émeraude, Ambre, Violet Arcaniste ou Jaune Flash.
[/LIST]

[B]💎 Suivi du Butin & Demande de Set Rapide (Need 1-Clic)[/B]
[LIST]
[*][B]Journal de Butin Filtrable :[/B] Filtrez par qualité avec option "Équipement uniquement" ou "Sets uniquement".
[*][B]Détails Avancés des Objets :[/B] Traits d'armure, icônes d'objets et marqueur d'alerte [B]|cFFCC00!!!|r[/B] sur les sets.
[*][B]Demande de Set d'un Clic :[/B] Clic droit sur un objet pour chuchoter directement au looteur.
[/LIST]

[B]💰 Alertes de Ventes en Boutique de Guilde (En Combat & Donjons)[/B]
[LIST]
[*][B]Scanner en Temps Réel :[/B] Détecte instantanément les ventes partout en jeu via l'historique de guilde.
[*][B]Annonce CSA :[/B] Notification centrale dorée, tintement de pièces et archivage dans le canal Général.
[/LIST]

[B]🎨 Thèmes Visuels & Persistance Totale[/B]
[LIST]
[*][B]5 Thèmes Graphiques :[/B] Skyrim Dragonborn, Dwemer Gold, Nordic Emerald, Crimson Brotherhood et Dark Glass.
[*][B]Sauvegarde Intégrale :[/B] Position, dimensions et taille de police conservées à chaque connexion.
[/LIST]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[SIZE="4"][COLOR="SkyBlue"][B]⌨️ COMMANDES SLASH & RACCOURCIS[/B][/COLOR][/SIZE]
[LIST]
[*][B]Échap -> Commandes -> AetherChat :[/B]
  [LIST]
  [*]Afficher / Masquer AetherChat
  [*]Basculer Mode Standard / Ultra-Compact
  [*]Onglet suivant (Parcourir canaux / onglets perso)
  [*]Onglet précédent
  [*]Guilde suivante (Mode Compact)
  [*]Activer / Quitter la saisie chat
  [/LIST]
[*][B]/aetherchat[/B] ou [B]/ac[/B] ou [B]/aether[/B] — Ouvrir / Fermer AetherChat.
[*][B]/aethermode[/B] ou [B]/acmode[/B] — Basculer entre Mode Standard et Mode Ultra-Compact.
[*][B]/aethericon[/B] — Afficher / Masquer l'icône HUD flottante.
[*][B]/chathead[/B] — Tester les sons et l'interface.
[/LIST]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[SIZE="4"][COLOR="Gold"][B]👏 REMERCIEMENTS & CRÉDITS[/B][/COLOR][/SIZE]
[LIST]
[*][B]LibAddonMenu-2.0 :[/B] Développé par [I]sirinsidiator & Seerah[/I].
[*][B]Intégration LootLog :[/B] Inspiré et intégré avec [I]LootLog par code65536[/I].
[*][B]Inspiration Communautaire :[/B] Un grand merci à la communauté de développeurs d'ESO UI, notamment aux créateurs de [I]pChat[/I] (Ayantir / Baertram) et [I]ArkadiusTradeTools[/I] (Arkadius) pour leurs travaux pionniers sur l'ergonomie du chat et le suivi des ventes en jeu.
[/LIST]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[CENTER]
[SIZE="2"][COLOR="Gray"]AetherChat — Conçu avec passion pour la communauté de The Elder Scrolls Online.[/COLOR][/SIZE]
[/CENTER]
```
