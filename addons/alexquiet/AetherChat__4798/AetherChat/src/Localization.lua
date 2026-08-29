-- ============================================================================
-- AetherChat : Complete Bilingual Localization Engine (French & English)
-- ============================================================================
AetherChat = AetherChat or {}
local AetherChat = AetherChat

AetherChat.L10n = {}
local L10n = AetherChat.L10n

local STRINGS = {
    fr = {
        -- Header & Branding
        HEADER_TITLE_SKYRIM   = "|c38BDF8AETHER|r|cFFFFFFCHAT|r",
        HEADER_TITLE_DWEMER   = "|cD4AF37AETHER|r|cFFFFFFCHAT|r",
        HEADER_TITLE_EMERALD  = "|c57F287AETHER|r|cFFFFFFCHAT|r",
        HEADER_TITLE_CRIMSON  = "|cF23F43AETHER|r|cFFFFFFCHAT|r",
        HEADER_TITLE_DARK     = "|c5865F2AETHER|r|cFFFFFFCHAT|r",
        HEADER_TITLE_DEFAULT  = "|cE5B558AETHER|r|cFFFFFFCHAT|r",

        -- Channel Names
        CH_LOOT               = "Butin & Loots",
        CH_ZONE               = "Canal Zone",
        CH_GENERAL            = "Général & Ventes",
        CH_PARTY              = "Groupe",
        CH_GUILDS_FOLDER      = "Guildes",
        CH_GUILD_PREFIX       = "Guilde",

        -- Zone Language Pills
        ZONE_LANG_ALL         = "Toutes",
        ZONE_LANG_FR          = "FR",
        ZONE_LANG_EN          = "EN",
        ZONE_LANG_DE          = "DE",
        ZONE_LANG_ES          = "ES",
        ZONE_LANG_GLOBAL      = "Global",
        TT_ZONE_LANG          = "Canal Zone : %s",
        TT_ZONE_LANG_DESC     = "Cliquez pour filtrer les messages de cette langue et envoyer vos messages dans ce canal (/frzone, /enzone, /eszone...).",

        -- Tooltips & Buttons
        CHANNEL_GUILD         = "Discussion de Guilde",
        TT_UNREAD_COUNT       = "%d non lu(s)",
        TT_CLOSE_CONV         = "Fermer la discussion",
        SALES_ALERT_TITLE     = "|c57F287[Vente Réussie]|r",
        SALES_STORE_AUTHOR    = "|cFFD700Boutique de Guilde|r",
        SALES_MSG_FORMAT      = "Vous avez vendu un objet : %s pour |cFFD700%s|r !",
        BINDING_NAME          = "Ouvrir / Masquer AetherChat",
        CHAT_LOADED_MSG       = "|c5865F2[AetherChat Messenger]|r v%s actif ! Appuyez sur votre touche ou tapez |cFFFFFF/aetherc|r pour ouvrir.",
        TT_COLLAPSE_SIDEBAR   = "Réduire / Agrandir la barre latérale",
        TT_COLLAPSE_SIDEBAR_SUB = "Clic gauche pour basculer en mode icônes compact et agrandir la zone de lecture.",
        TT_MINIMIZE_WINDOW    = "Réduire AetherChat",
        TT_MINIMIZE_WINDOW_SUB = "Clic gauche pour replier le chat en bouton discret sur le bord de l'écran.",
        TT_FLOATING_ICON      = "AetherChat",
        TT_SETTINGS_BTN       = "Paramètres AetherChat & Thèmes",
        TT_SETTINGS_BTN_SUB   = "Clic gauche pour ouvrir les options",
        TT_FRIENDS_BTN        = "Amis en Ligne",
        TT_FRIENDS_ONLINE     = "%d ami(s) connecté(s)",
        TT_FRIENDS_NONE       = "Aucun ami connecté",
        TT_FRIENDS_BTN_SUB    = "Clic gauche pour afficher la liste et envoyer un message",
        TT_MAIL_BTN           = "Courrier & Boîte aux lettres",
        TT_MAIL_UNREAD        = "%d message(s) non lu(s)",
        TT_MAIL_NONE          = "Aucun nouveau message",
        TT_MAIL_BTN_SUB       = "Clic gauche pour ouvrir la boîte aux lettres",
        TT_DONATE_BTN         = "Soutenir AetherChat & Faire un don",
        TT_DONATE_BTN_DESC    = "Envoyer de l'or en jeu (@AlexQuiet - Serveur EU), PayPal ou Crypto",
        TT_DONATE_BTN_SUB     = "Clic gauche pour ouvrir la fenêtre de don",
        BTN_FILTER_SETS_ON    = "[✓] Sets Uniquement",
        BTN_FILTER_SETS_OFF   = "[ ] Tous les butins",
        TT_FILTER_SETS        = "Filtre du Butin (Sets de Donjon)",
        TT_FILTER_SETS_DESC   = "Clic gauche pour basculer : afficher uniquement les pièces de set d'armure/armes ou tous les butins.",
        STATUS_UNCOLLECTED_SELF  = "[Non collecté]",
        STATUS_UNCOLLECTED_OTHER = "[Non collecté !]",
        STATUS_COLLECTED         = "[Collecté]",

        -- Context Menus
        MENU_NEED_GROUP       = "Demander dans le groupe (Need)",
        MENU_NEED_WHISPER_AT  = "Demander en MP à %s",
        MENU_NEED_WHISPER     = "Demander en chuchotement (MP)",
        MENU_LINK_CHAT        = "Lier dans le chat",
        MENU_DONATE_INGAME    = "Envoyer des pièces d'or en jeu (Serveur EU)",
        MENU_DONATE_OPTIONS   = "Ouvrir les options de don (PayPal / USDT Crypto)",
        MENU_NO_FRIENDS       = "Aucun ami en ligne actuellement",
        MENU_RELOAD_UI        = "Recharger l'interface (/reloadui)",

        -- Donation Modal Window
        MODAL_DONATE_TITLE    = "|cE5B558AetherChat|r — Dons & Soutien au Créateur",
        MODAL_DONATE_DESC     = "Vous pouvez soutenir le développement continu d'AetherChat (@AlexQuiet) via l'une des options ci-dessous :",
        MODAL_GOLD_TITLE      = "[#] Don de pièces d'or en jeu (Serveur EU)",
        MODAL_GOLD_SUB        = "Destinataire @AlexQuiet et objet Don AetherChat pré-remplis (montant et mot libres)",
        MODAL_GOLD_BTN        = "Envoyer Courrier",
        MODAL_PAYPAL_TITLE    = "[#] Don PayPal",
        MODAL_PAYPAL_BTN      = "Copier",
        MODAL_PAYPAL_CHAT     = "|c38BDF8[AetherChat]|r Adresse PayPal sélectionnée : |cFFFFFF%s|r (Appuyez sur Ctrl+C pour copier)",
        MODAL_USDT_TITLE      = "[#] Don Crypto USDT (Réseau ERC20)",
        MODAL_USDT_BTN        = "Copier USDT",
        MODAL_USDT_CHAT       = "|c57F287[AetherChat]|r Adresse USDT (ERC20) sélectionnée : |cFFFFFF%s|r (Appuyez sur Ctrl+C pour copier)",
        MODAL_CLOSE_BTN       = "Fermer",

        -- Settings Panel
        SET_PANEL_NAME        = "AetherChat",
        SET_INTRO_DESC        = "Interface de messagerie moderne inspirée de Bordeciel (Skyrim). Réorganisez vos onglets, gérez vos guildes, suivez vos loots en temps réel (Need 1-clic lié à LootLog) et recevez des notifications d'alertes instantanées.\n\n|cFFD700Conseil d'utilisation optimale :|r Assignez une touche de raccourci dans le menu |cFFFFFFÉchap -> Commandes -> AetherChat (Show/Hide)|r pour ouvrir et fermer votre messagerie à tout moment de façon ultra fluide !",
        SET_LANG_HEADER       = "Langue de l'Interface / Language",
        SET_LANG_LABEL        = "Langue choisie",
        SET_LANG_TT           = "Choisissez la langue d'AetherChat (Français ou Anglais).",
        SET_LANG_RELOAD_BTN   = "Appliquer la langue & Recharger (/reloadui)",
        SET_LANG_RELOAD_TT    = "Recharge immédiatement l'interface du jeu pour appliquer tous les textes dans la langue sélectionnée.",
        SET_DONATE_HEADER     = "Soutenir le Créateur & Faire un Don",
        SET_DONATE_DESC       = "Si vous appréciez AetherChat et souhaitez soutenir son développement continu, vous pouvez faire un don en or en jeu ou via PayPal / Crypto. Merci infiniment pour votre soutien !",
        SET_DONATE_INGAME_BTN = "Envoyer des pièces d'or en jeu (Serveur EU)",
        SET_DONATE_INGAME_TT  = "Ouvre automatiquement l'envoi de courrier vers @AlexQuiet (Serveur EU) pour envoyer le montant d'or de votre choix.",
        SET_THEME_HEADER      = "Ambiance & Thèmes Graphiques de Tamriel",
        SET_THEME_LABEL       = "Thème Visuel",
        SET_THEME_TT          = "Choisissez l'ambiance graphique et les couleurs d'accentuation d'AetherChat inspirées de Bordeciel et Tamriel.",
        SET_SOUND_HEADER      = "Alertes Sonores & Notifications",
        SET_SOUND_ENABLE      = "Activer les alertes sonores sur chuchotement",
        SET_SOUND_ENABLE_TT   = "Joue un son lors de la réception d'un nouveau chuchotement (MP).",
        SET_SOUND_SELECT      = "Sonnerie de Notification (Chuchotements)",
        SET_SOUND_SELECT_TT   = "Choisissez le son joué lors de la réception d'un message privé parmi un catalogue de sons à haute audibilité.",
        SET_SOUND_TEST_BTN    = "Écouter la sonnerie sélectionnée",
        SET_SOUND_TEST_TT     = "Joue immédiatement le son choisi pour le tester.",
        SET_BADGE_HEADER      = "Badges d'Alerte sur l'Icône Flottante HUD",
        SET_BADGE_WHISPER     = "Alerter pour les Chuchotements (MP)",
        SET_BADGE_WHISPER_TT  = "Affiche un badge rouge sur l'icône flottante lors de la réception d'un MP.",
        SET_BADGE_GUILD       = "Alerter pour les discussions de Guilde",
        SET_BADGE_GUILD_TT    = "Affiche un badge rouge sur l'icône flottante lors de nouveaux messages de guilde.",
        SET_BADGE_PARTY       = "Alerter pour les discussions de Groupe",
        SET_BADGE_PARTY_TT    = "Affiche un badge rouge sur l'icône flottante lors de nouveaux messages de groupe.",
        NOTIF_FRIEND_LOGIN    = "|c57F287[Amis]|r %s s'est connecté.",
        NOTIF_FRIEND_LOGOUT   = "|c888888[Amis]|r %s s'est déconnecté.",
        SET_NOTIF_FRIENDS_STATUS = "Alerter lors des connexions / déconnexions d'amis",
        SET_NOTIF_FRIENDS_STATUS_TT = "Affiche une notification dans le chat lorsqu'un ami se connecte ou se déconnecte du jeu avec la couleur de votre thème.",
        SET_NOTIF_SALES       = "Alerter lors des ventes d'objets (Boutique de Guilde)",
        SET_NOTIF_SALES_TT    = "Affiche une notification au centre de l'écran (CSA), joue un son de pièces d'or et inscrit la vente dans le canal Général lors d'une vente en boutique.",
        SET_LOOT_HEADER       = "Canal Butin & Demande de Set (Need)",
        SET_LOOT_TEMPLATE     = "Modèle de message 'Need / Demander l'objet'",
        SET_LOOT_TEMPLATE_TT  = "Message pré-rempli lors d'un clic droit sur un butin dans le canal Loot (utilisez <<item>> pour le lien de l'objet).",
        SET_HISTORY_HEADER    = "Conservation & Historique des Données",
        SET_HISTORY_DUR       = "Durée de conservation de l'historique",
        SET_HISTORY_DUR_TT    = "Définit combien de temps les loots et les messages reçus sont conservés en mémoire.",
        SET_HISTORY_SAVE      = "Sauvegarder l'historique entre les sessions",
        SET_HISTORY_SAVE_TT   = "Conserve l'historique des discussions et loots entre les sessions et les recharges d'interface.",
        SET_GEN_HEADER        = "Options Générales & Fenêtre",
        SET_WINDOW_ALPHA      = "Opacité de la Fenêtre",
        SET_WINDOW_ALPHA_TT   = "Ajuste la transparence du fond de la fenêtre de discussion.",
        SET_AUTO_COLLAPSE_MENUS = "Réduction automatique dans les menus",
        SET_AUTO_COLLAPSE_MENUS_TT = "Replie automatiquement le chat lors de l'ouverture de l'inventaire, de la carte ou des compétences.",
        SET_GEN_ICON          = "Afficher le bouton de réduction docké",
        SET_GEN_ICON_TT       = "Affiche un bouton discret sur le bord de l'écran lorsque le chat est replié.",
        SET_GEN_HIDE_ESO      = "Masquer le chat officiel d'ESO",
        SET_GEN_HIDE_ESO_TT   = "Masque complètement la boîte de chat officielle pour utiliser AetherChat comme chat unique.",
        SET_ACTIONS_HEADER    = "Actions, Outils & Tests",
        SET_RELOADUI_BTN      = "Recharger l'interface (/reloadui)",
        SET_RELOADUI_TT       = "Exécute instantanément la commande /reloadui pour rafraîchir l'interface du jeu.",
        SET_TEST_WHISPER_BTN  = "Tester la messagerie / Message de test",
        SET_TEST_WHISPER_TT   = "Simules la réception d'un MP pour tester l'interface et le son.",
        SET_RESET_BTN         = "Réinitialiser l'ordre des onglets & position",
        SET_RESET_TT          = "Réinitialise l'ordre par défaut des canaux et remet la fenêtre au centre.",
    },
    en = {
        -- Header & Branding
        HEADER_TITLE_SKYRIM   = "|c38BDF8AETHER|r|cFFFFFFCHAT|r",
        HEADER_TITLE_DWEMER   = "|cD4AF37AETHER|r|cFFFFFFCHAT|r",
        HEADER_TITLE_EMERALD  = "|c57F287AETHER|r|cFFFFFFCHAT|r",
        HEADER_TITLE_CRIMSON  = "|cF23F43AETHER|r|cFFFFFFCHAT|r",
        HEADER_TITLE_DARK     = "|c5865F2AETHER|r|cFFFFFFCHAT|r",
        HEADER_TITLE_DEFAULT  = "|cE5B558AETHER|r|cFFFFFFCHAT|r",

        -- Channel Names
        CH_LOOT               = "Loot & Drops",
        CH_ZONE               = "Zone Channel",
        CH_GENERAL            = "General & Sales",
        CH_PARTY              = "Party / Group",
        CH_GUILDS_FOLDER      = "Guilds",
        CH_GUILD_PREFIX       = "Guild",

        -- Zone Language Pills
        ZONE_LANG_ALL         = "All",
        ZONE_LANG_FR          = "FR",
        ZONE_LANG_EN          = "EN",
        ZONE_LANG_DE          = "DE",
        ZONE_LANG_ES          = "ES",
        ZONE_LANG_GLOBAL      = "Global",
        TT_ZONE_LANG          = "Zone Channel: %s",
        TT_ZONE_LANG_DESC     = "Click to filter this language and send your messages in this channel (/frzone, /enzone, /eszone...).",

        -- Tooltips & Buttons
        CHANNEL_GUILD         = "Guild Discussion",
        TT_UNREAD_COUNT       = "%d unread",
        TT_CLOSE_CONV         = "Close conversation",
        SALES_ALERT_TITLE     = "|c57F287[Item Sold]|r",
        SALES_STORE_AUTHOR    = "|cFFD700Guild Store|r",
        SALES_MSG_FORMAT      = "You sold an item: %s for |cFFD700%s|r!",
        BINDING_NAME          = "Toggle AetherChat Messenger",
        CHAT_LOADED_MSG       = "|c5865F2[AetherChat Messenger]|r v%s active! Press your hotkey or type |cFFFFFF/aetherc|r to open.",
        TT_COLLAPSE_SIDEBAR   = "Collapse / Expand Sidebar",
        TT_COLLAPSE_SIDEBAR_SUB = "Left-click to toggle compact icon-only mode and expand reading area.",
        TT_MINIMIZE_WINDOW    = "Minimize AetherChat",
        TT_MINIMIZE_WINDOW_SUB = "Left-click to collapse chat into a sleek dock button on the screen edge.",
        TT_FLOATING_ICON      = "AetherChat",
        TT_SETTINGS_BTN       = "AetherChat Settings & Themes",
        TT_SETTINGS_BTN_SUB   = "Left-click to open options",
        TT_FRIENDS_BTN        = "Online Friends",
        TT_FRIENDS_ONLINE     = "%d friend(s) online",
        TT_FRIENDS_NONE       = "No friends online",
        TT_FRIENDS_BTN_SUB    = "Left-click to show list and whisper",
        TT_MAIL_BTN           = "Mail & Inbox",
        TT_MAIL_UNREAD        = "%d unread message(s)",
        TT_MAIL_NONE          = "No new messages",
        TT_MAIL_BTN_SUB       = "Left-click to open mailbox",
        TT_DONATE_BTN         = "Support AetherChat & Donate",
        TT_DONATE_BTN_DESC    = "Send in-game gold (@AlexQuiet - EU Server), PayPal or Crypto",
        TT_DONATE_BTN_SUB     = "Left-click to open donation window",
        BTN_FILTER_SETS_ON    = "[✓] Set Items Only",
        BTN_FILTER_SETS_OFF   = "[ ] All Drops",
        TT_FILTER_SETS        = "Loot Filter (Dungeon Sets)",
        TT_FILTER_SETS_DESC   = "Left-click to toggle: show only armor/weapon set pieces or all drops.",
        STATUS_UNCOLLECTED_SELF  = "[Uncollected]",
        STATUS_UNCOLLECTED_OTHER = "[Uncollected !]",
        STATUS_COLLECTED         = "[Collected]",

        -- Context Menus
        MENU_NEED_GROUP       = "Ask in group (Need)",
        MENU_NEED_WHISPER_AT  = "Whisper %s (Need)",
        MENU_NEED_WHISPER     = "Ask in whisper (Need)",
        MENU_LINK_CHAT        = "Link in chat",
        MENU_DONATE_INGAME    = "Send in-game gold (EU Server)",
        MENU_DONATE_OPTIONS   = "Open donation options (PayPal / USDT Crypto)",
        MENU_NO_FRIENDS       = "No friends online currently",
        MENU_RELOAD_UI        = "Reload UI (/reloadui)",

        -- Donation Modal Window
        MODAL_DONATE_TITLE    = "|cE5B558AetherChat|r — Donations & Creator Support",
        MODAL_DONATE_DESC     = "You can support the ongoing development of AetherChat (@AlexQuiet) through any of the options below:",
        MODAL_GOLD_TITLE      = "[#] Send in-game Gold (EU Server)",
        MODAL_GOLD_SUB        = "Recipient @AlexQuiet and subject pre-filled (custom gold amount & message)",
        MODAL_GOLD_BTN        = "Send Mail",
        MODAL_PAYPAL_TITLE    = "[#] PayPal Donation",
        MODAL_PAYPAL_BTN      = "Copy",
        MODAL_PAYPAL_CHAT     = "|c38BDF8[AetherChat]|r PayPal email selected: |cFFFFFF%s|r (Press Ctrl+C to copy)",
        MODAL_USDT_TITLE      = "[#] Crypto Donation USDT (ERC20 Network)",
        MODAL_USDT_BTN        = "Copy USDT",
        MODAL_USDT_CHAT       = "|c57F287[AetherChat]|r USDT (ERC20) address selected: |cFFFFFF%s|r (Press Ctrl+C to copy)",
        MODAL_CLOSE_BTN       = "Close",

        -- Settings Panel
        SET_PANEL_NAME        = "AetherChat",
        SET_INTRO_DESC        = "Modern messenger interface inspired by Skyrim. Reorder tabs with drag-and-drop, manage guilds in collapsible folders, track loots with 1-click Need requests (synced with LootLog), and enjoy instant sound alerts.\n\n|cFFD700Best Experience Tip:|r Bind a keyboard shortcut in |cFFFFFFEsc -> Controls -> AetherChat (Show/Hide)|r to effortlessly open and close your chat at any moment!",
        SET_LANG_HEADER       = "Language / Langue",
        SET_LANG_LABEL        = "Interface Language",
        SET_LANG_TT           = "Select your preferred language (French or English).",
        SET_LANG_RELOAD_BTN   = "Apply Language & Reload UI (/reloadui)",
        SET_LANG_RELOAD_TT    = "Immediately reloads the UI to display all strings in your chosen language.",
        SET_DONATE_HEADER     = "Support the Creator & Donate",
        SET_DONATE_DESC       = "If you enjoy AetherChat and wish to support its continued development, you can donate in-game gold or via PayPal / Crypto. Thank you very much for your support!",
        SET_DONATE_INGAME_BTN = "Send in-game gold (EU Server)",
        SET_DONATE_INGAME_TT  = "Automatically opens mail compose to @AlexQuiet (EU Server) with your custom gold amount.",
        SET_THEME_HEADER      = "Tamriel Atmosphere & Visual Themes",
        SET_THEME_LABEL       = "Visual Theme",
        SET_THEME_TT          = "Choose AetherChat's visual theme and accent colors inspired by Skyrim and Tamriel.",
        SET_SOUND_HEADER      = "Sound Alerts & Notifications",
        SET_SOUND_ENABLE      = "Enable sound alerts on whispers",
        SET_SOUND_ENABLE_TT   = "Plays a sound upon receiving a new private message (whisper).",
        SET_SOUND_SELECT      = "Notification Ringtone (Whispers)",
        SET_SOUND_SELECT_TT   = "Choose the ringtone played on private messages from a high-audibility catalog.",
        SET_SOUND_TEST_BTN    = "Preview selected ringtone",
        SET_SOUND_TEST_TT     = "Immediately plays the selected ringtone to test it.",
        SET_BADGE_HEADER      = "Alert Badges on Floating HUD Icon",
        SET_BADGE_WHISPER     = "Alert for Whispers (PM)",
        SET_BADGE_WHISPER_TT  = "Displays a red badge on the floating icon when receiving a whisper.",
        SET_BADGE_GUILD       = "Alert for Guild discussions",
        SET_BADGE_GUILD_TT    = "Displays a red badge on the floating icon for new guild messages.",
        SET_BADGE_PARTY       = "Alert for Group discussions",
        SET_BADGE_PARTY_TT    = "Displays a red badge on the floating icon for new group messages.",
        NOTIF_FRIEND_LOGIN    = "|c57F287[Friends]|r %s logged on.",
        NOTIF_FRIEND_LOGOUT   = "|c888888[Friends]|r %s logged off.",
        SET_NOTIF_FRIENDS_STATUS = "Notify on Friend Login / Logout",
        SET_NOTIF_FRIENDS_STATUS_TT = "Displays a chat notification when a friend connects or disconnects, colored with your active theme.",
        SET_NOTIF_SALES       = "Alert on Guild Store Item Sales",
        SET_NOTIF_SALES_TT    = "Displays a center screen announcement (CSA), plays gold coins sound, and posts to the General channel when you sell an item in a guild store.",
        SET_LOOT_HEADER       = "Loot Channel & Need Template",
        SET_LOOT_TEMPLATE     = "'Need / Request item' message template",
        SET_LOOT_TEMPLATE_TT  = "Pre-filled message when right-clicking loot in the Loot tab (use <<item>> for item link).",
        SET_HISTORY_HEADER    = "Data Retention & History",
        SET_HISTORY_DUR       = "History retention duration",
        SET_HISTORY_DUR_TT    = "Sets how long received loots and messages remain in memory.",
        SET_HISTORY_SAVE      = "Save history between sessions",
        SET_HISTORY_SAVE_TT   = "Persists chat and loot history across game sessions and interface reloads.",
        SET_GEN_HEADER        = "General Window Options",
        SET_WINDOW_ALPHA      = "Window Opacity",
        SET_WINDOW_ALPHA_TT   = "Adjusts the background opacity of the chat window.",
        SET_AUTO_COLLAPSE_MENUS = "Auto-collapse on Menus",
        SET_AUTO_COLLAPSE_MENUS_TT = "Automatically minimizes the chat window when opening game menus (Inventory, Skills, Map...).",
        SET_GEN_ICON          = "Show docked collapse button",
        SET_GEN_ICON_TT       = "Displays a sleek dock button on the screen edge when chat is minimized.",
        SET_GEN_HIDE_ESO      = "Hide official ESO chat box",
        SET_GEN_HIDE_ESO_TT   = "Completely hides the native chat window to use AetherChat as your sole chat interface.",
        SET_ACTIONS_HEADER    = "Actions, Tools & Tests",
        SET_RELOADUI_BTN      = "Reload UI (/reloadui)",
        SET_RELOADUI_TT       = "Instantly reloads the game interface (/reloadui).",
        SET_TEST_WHISPER_BTN  = "Test Messenger / Test message",
        SET_TEST_WHISPER_TT   = "Simulates receiving a whisper to test the interface and sound.",
        SET_RESET_BTN         = "Reset channel order & position",
        SET_RESET_TT          = "Resets channels to default order and centers the messenger window.",
    },
}

function L10n.GetLanguage()
    local saved = AetherChat.Settings and AetherChat.Settings.Get('language', 'auto')
    if saved == 'fr' or saved == 'en' then
        return saved
    end

    local clientLang = GetCVar("language.2")
    if clientLang == "fr" then
        return "fr"
    end
    return "en"
end

function L10n.Get(key, ...)
    local lang = L10n.GetLanguage()
    local dict = STRINGS[lang] or STRINGS.en
    local str = dict[key] or STRINGS.en[key] or key

    if ... then
        return string.format(str, ...)
    end
    return str
end

-- Global helper alias
function AetherChat.L(key, ...)
    return L10n.Get(key, ...)
end
