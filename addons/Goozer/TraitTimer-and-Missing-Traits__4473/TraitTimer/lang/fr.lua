-- TraitTimer French Localization

-- Craft type names
SafeAddString(TT_CRAFT_BLACKSMITHING, "Forge", 1)
SafeAddString(TT_CRAFT_CLOTHIER, "Couture", 1)
SafeAddString(TT_CRAFT_WOODWORKING, "Travail du bois", 1)
SafeAddString(TT_CRAFT_JEWELRY, "Joaillerie", 1)

-- Status labels
SafeAddString(TT_STATUS_DONE, "TERMINE !", 1)
SafeAddString(TT_STATUS_NO_RESEARCH, "Aucune recherche active", 1)
SafeAddString(TT_STATUS_SLOTS_USED, "<<1>>/<<2>> emplacements", 1)

-- Alerts
SafeAddString(TT_ALERT_COMPLETE, "Recherche terminee : <<1>> - <<2>>", 1)
SafeAddString(TT_ALERT_CHAT, "|cFFFF00[TraitTimer]|r Recherche terminee : <<1>> - <<2>> (<<3>>)", 1)
SafeAddString(TT_ALERT_FREE_SLOT, "|cFFFF00[TraitTimer]|r <<1>> a un emplacement de recherche libre !", 1)

-- Time format
SafeAddString(TT_TIME_DAYS, "<<1>>j <<2>>h <<3>>m", 1)
SafeAddString(TT_TIME_HOURS, "<<1>>h <<2>>m <<3>>s", 1)
SafeAddString(TT_TIME_MINUTES, "<<1>>m <<2>>s", 1)

-- Minimized summary
SafeAddString(TT_SUMMARY_ACTIVE, "<<1>> en cours", 1)

-- Column headers
SafeAddString(TT_COL_ITEM, "Item", 1)
SafeAddString(TT_COL_TRAIT, "Trait", 1)
SafeAddString(TT_COL_TIME, "Temps", 1)
SafeAddString(TT_COL_MISSING, "Manquants", 1)

-- View modes
SafeAddString(TT_MODE_TIMERS, "Recherches", 1)
SafeAddString(TT_MODE_MISSING, "Traits manquants", 1)
SafeAddString(TT_MISSING_HEADER, "<<1>>/<<2>> connus", 1)
SafeAddString(TT_MISSING_NONE, "Tous les traits recherches !", 1)
SafeAddString(TT_MISSING_COUNT, "<<1>> manquant(s)", 1)

-- Slash command feedback
SafeAddString(TT_CMD_LOCKED, "|cFFFF00[TraitTimer]|r Widget verrouille.", 1)
SafeAddString(TT_CMD_UNLOCKED, "|cFFFF00[TraitTimer]|r Widget deverrouille.", 1)
SafeAddString(TT_CMD_SHOWN, "|cFFFF00[TraitTimer]|r Widget affiche.", 1)
SafeAddString(TT_CMD_HIDDEN, "|cFFFF00[TraitTimer]|r Widget masque.", 1)
SafeAddString(TT_CMD_HELP, "|cFFFF00[TraitTimer]|r Commandes : /tt (afficher/masquer) | /tt lock | /tt scan | /tt missing | /tt width <n>", 1)
SafeAddString(TT_CMD_SCAN_HEADER, "|cFFFF00[TraitTimer]|r --- Resume des recherches ---", 1)
SafeAddString(TT_CMD_SCAN_LINE, "|cFFFF00[TraitTimer]|r <<1>> : <<2>> - <<3>> (<<4>>)", 1)
SafeAddString(TT_CMD_SCAN_NONE, "|cFFFF00[TraitTimer]|r Aucune recherche active.", 1)
SafeAddString(TT_CMD_WIDTH_SET, "|cFFFF00[TraitTimer]|r Largeur reglee a <<1>>.", 1)
SafeAddString(TT_CMD_WIDTH_RANGE, "|cFFFF00[TraitTimer]|r La largeur doit etre entre <<1>> et <<2>>.", 1)
SafeAddString(TT_CMD_WIDTH_CURRENT, "|cFFFF00[TraitTimer]|r Largeur actuelle : <<1>>. Utilisation : /tt width 500", 1)

-- Settings panel (LibAddonMenu)
SafeAddString(TT_SETTINGS_GENERAL, "General", 1)
SafeAddString(TT_SETTINGS_HIDE_COMBAT, "Masquer en combat", 1)
SafeAddString(TT_SETTINGS_HIDE_COMBAT_TT, "Masquer le widget en entrant en combat.", 1)
SafeAddString(TT_SETTINGS_LOCK, "Verrouiller la position", 1)
SafeAddString(TT_SETTINGS_LOCK_TT, "Empecher le deplacement du widget.", 1)
SafeAddString(TT_SETTINGS_VIEW_MODE, "Vue par defaut", 1)
SafeAddString(TT_SETTINGS_VIEW_MODE_TT, "Vue affichee a la connexion.", 1)
SafeAddString(TT_SETTINGS_BG_ALPHA, "Opacite du fond", 1)
SafeAddString(TT_SETTINGS_BG_ALPHA_TT, "Ajuster la transparence du fond (0 = invisible, 100 = opaque).", 1)
SafeAddString(TT_SETTINGS_RESET, "Reinitialiser position et taille", 1)
SafeAddString(TT_SETTINGS_RESET_TT, "Reinitialiser le widget a sa position et taille par defaut.", 1)
