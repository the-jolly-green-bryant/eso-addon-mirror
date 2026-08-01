-- ============================================================
--  SmartPricer — Localisation
--  Ajouter une langue : créer un bloc SP_STRINGS["xx"] = {}
--  et renseigner toutes les clés présentes dans "en"
-- ============================================================

local SP_STRINGS = {}

-- ── Anglais (défaut) ─────────────────────────────────────────
SP_STRINGS["en"] = {
    -- Démarrage
    INIT_OK             = "XML OK — dynamic pool — ",
    INIT_NO_XML         = "SmartPricer : XML not loaded !",
    STARTUP             = "v1.1.0 — ",
    TTC_OK              = "TTC OK",
    TTC_ABSENT          = "TTC missing",
    -- Slash commands
    SLASH_ENABLED       = "SmartPricer : enabled.",
    SLASH_DISABLED      = "SmartPricer : disabled.",
    SLASH_CACHE_CLEAR   = "SmartPricer : cache cleared.",
    SLASH_DEBUG_ON      = "SmartPricer : debug |cFF8800ON|r",
    SLASH_DEBUG_OFF     = "SmartPricer : debug OFF",
    SLASH_HOOKED        = "SmartPricer : re-hooked.",
    SLASH_REFRESHED     = "SmartPricer : refreshed.",
    SLASH_SEUIL         = "SmartPricer : threshold → |cFFD700",
    SLASH_HELP          = "SmartPricer — /sp on|off|cache|debug|hook|threshold <n>|settings",
    -- LAM — panel
    LAM_PANEL_NAME      = "SmartPricer",
    LAM_AUTHOR          = "LimPack",
    -- LAM — général
    LAM_ENABLED         = "Enable SmartPricer",
    LAM_FILTER_EQUIP    = "Weapons, armor and jewelry only",
    LAM_FILTER_EQUIP_TT = "Enabled: icon shown only on weapons, armor and jewelry.\nDisabled: all items above the threshold are marked.",
    -- LAM — paliers
    LAM_TIER1_HEADER    = "|cFFD700Tier 1|r",
    LAM_TIER1_THRESHOLD = "Tier 1 threshold (gold)",
    LAM_TIER1_TT        = "Minimum price to display the tier 1 icon.",
    LAM_TIER2_HEADER    = "|cFFD700Tier 2|r",
    LAM_TIER2_ENABLE    = "Enable tier 2",
    LAM_TIER2_ENABLE_TT = "Shows a different icon when the price exceeds tier 2 threshold.",
    LAM_TIER2_THRESHOLD = "Tier 2 threshold (gold)",
    LAM_TIER3_HEADER    = "|cFFD700Tier 3|r",
    LAM_TIER3_ENABLE    = "Enable tier 3",
    LAM_TIER3_ENABLE_TT = "Shows a premium icon when the price exceeds tier 3 threshold.",
    LAM_TIER3_THRESHOLD = "Tier 3 threshold (gold)",
    -- LAM — bas de page
    LAM_DEBUG           = "|cFF8800Debug mode|r",
    LAM_REFRESH         = "Refresh icons",
    LAM_TTC_TITLE       = "TTC Status",
    LAM_TTC_OK          = "|c00FF7F✔ TTC functional|r",
    LAM_TTC_WARN        = "|cFFAA00⚠ TTC present but GetPriceInfo missing|r",
    LAM_TTC_KO          = "|cFF4444✘ TTC not detected|r",
}

-- ── Français ─────────────────────────────────────────────────
SP_STRINGS["fr"] = {
    -- Démarrage
    INIT_OK             = "XML OK — pool dynamique — ",
    INIT_NO_XML         = "SmartPricer : XML non chargé !",
    STARTUP             = "v1.1.0 — ",
    TTC_OK              = "TTC OK",
    TTC_ABSENT          = "TTC absent",
    -- Slash commands
    SLASH_ENABLED       = "SmartPricer : activé.",
    SLASH_DISABLED      = "SmartPricer : désactivé.",
    SLASH_CACHE_CLEAR   = "SmartPricer : cache vidé.",
    SLASH_DEBUG_ON      = "SmartPricer : debug |cFF8800ON|r",
    SLASH_DEBUG_OFF     = "SmartPricer : debug OFF",
    SLASH_HOOKED        = "SmartPricer : re-hookage.",
    SLASH_REFRESHED     = "SmartPricer : rafraîchi.",
    SLASH_SEUIL         = "SmartPricer : seuil → |cFFD700",
    SLASH_HELP          = "SmartPricer — /sp on|off|cache|debug|hook|seuil <n>|settings",
    -- LAM — panel
    LAM_PANEL_NAME      = "SmartPricer",
    LAM_AUTHOR          = "LimPack",
    -- LAM — général
    LAM_ENABLED         = "Activer SmartPricer",
    LAM_FILTER_EQUIP    = "Armes, armures et bijoux uniquement",
    LAM_FILTER_EQUIP_TT = "Activé : l'icône s'affiche uniquement sur les armes, armures et bijoux.\nDésactivé : tous les items dont le prix dépasse le seuil sont marqués.",
    -- LAM — paliers
    LAM_TIER1_HEADER    = "|cFFD700Palier 1|r",
    LAM_TIER1_THRESHOLD = "Seuil 1 (gold)",
    LAM_TIER1_TT        = "Prix minimum pour afficher l'icône palier 1.",
    LAM_TIER2_HEADER    = "|cFFD700Palier 2|r",
    LAM_TIER2_ENABLE    = "Activer le palier 2",
    LAM_TIER2_ENABLE_TT = "Affiche une icône différente quand le prix dépasse le seuil 2.",
    LAM_TIER2_THRESHOLD = "Seuil 2 (gold)",
    LAM_TIER3_HEADER    = "|cFFD700Palier 3|r",
    LAM_TIER3_ENABLE    = "Activer le palier 3",
    LAM_TIER3_ENABLE_TT = "Affiche une icône premium quand le prix dépasse le seuil 3.",
    LAM_TIER3_THRESHOLD = "Seuil 3 (gold)",
    -- LAM — bas de page
    LAM_DEBUG           = "|cFF8800Mode debug|r",
    LAM_REFRESH         = "Rafraîchir les icônes",
    LAM_TTC_TITLE       = "État TTC",
    LAM_TTC_OK          = "|c00FF7F✔ TTC fonctionnel|r",
    LAM_TTC_WARN        = "|cFFAA00⚠ TTC présent mais GetPriceInfo absent|r",
    LAM_TTC_KO          = "|cFF4444✘ TTC non détecté|r",
}

-- ── Allemand ─────────────────────────────────────────────────
SP_STRINGS["de"] = {
    -- Démarrage
    INIT_OK             = "XML OK — dynamischer Pool — ",
    INIT_NO_XML         = "SmartPricer : XML nicht geladen !",
    STARTUP             = "v1.1.0 — ",
    TTC_OK              = "TTC OK",
    TTC_ABSENT          = "TTC fehlt",
    -- Slash commands
    SLASH_ENABLED       = "SmartPricer : aktiviert.",
    SLASH_DISABLED      = "SmartPricer : deaktiviert.",
    SLASH_CACHE_CLEAR   = "SmartPricer : Cache geleert.",
    SLASH_DEBUG_ON      = "SmartPricer : Debug |cFF8800AN|r",
    SLASH_DEBUG_OFF     = "SmartPricer : Debug AUS",
    SLASH_HOOKED        = "SmartPricer : neu gehookt.",
    SLASH_REFRESHED     = "SmartPricer : aktualisiert.",
    SLASH_SEUIL         = "SmartPricer : Schwellenwert → |cFFD700",
    SLASH_HELP          = "SmartPricer — /sp on|off|cache|debug|hook|schwelle <n>|settings",
    -- LAM — panel
    LAM_PANEL_NAME      = "SmartPricer",
    LAM_AUTHOR          = "LimPack",
    -- LAM — général
    LAM_ENABLED         = "SmartPricer aktivieren",
    LAM_FILTER_EQUIP    = "Nur Waffen, Rüstungen und Schmuck",
    LAM_FILTER_EQUIP_TT = "Aktiviert: Symbol nur bei Waffen, Rüstungen und Schmuck.\nDeaktiviert: Alle Items über dem Schwellenwert werden markiert.",
    -- LAM — paliers
    LAM_TIER1_HEADER    = "|cFFD700Stufe 1|r",
    LAM_TIER1_THRESHOLD = "Schwellenwert Stufe 1 (Gold)",
    LAM_TIER1_TT        = "Mindestpreis für das Symbol der Stufe 1.",
    LAM_TIER2_HEADER    = "|cFFD700Stufe 2|r",
    LAM_TIER2_ENABLE    = "Stufe 2 aktivieren",
    LAM_TIER2_ENABLE_TT = "Zeigt ein anderes Symbol wenn der Preis den Schwellenwert der Stufe 2 überschreitet.",
    LAM_TIER2_THRESHOLD = "Schwellenwert Stufe 2 (Gold)",
    LAM_TIER3_HEADER    = "|cFFD700Stufe 3|r",
    LAM_TIER3_ENABLE    = "Stufe 3 aktivieren",
    LAM_TIER3_ENABLE_TT = "Zeigt ein Premium-Symbol wenn der Preis den Schwellenwert der Stufe 3 überschreitet.",
    LAM_TIER3_THRESHOLD = "Schwellenwert Stufe 3 (Gold)",
    -- LAM — bas de page
    LAM_DEBUG           = "|cFF8800Debug-Modus|r",
    LAM_REFRESH         = "Symbole aktualisieren",
    LAM_TTC_TITLE       = "TTC-Status",
    LAM_TTC_OK          = "|c00FF7F✔ TTC funktioniert|r",
    LAM_TTC_WARN        = "|cFFAA00⚠ TTC vorhanden aber GetPriceInfo fehlt|r",
    LAM_TTC_KO          = "|cFF4444✘ TTC nicht erkannt|r",
}

-- ── Résolution de la langue active ───────────────────────────
local _lang = nil
local function SP_STR(key)
    if not _lang then
        local code = GetCVar("language.2") or "en"
        _lang = SP_STRINGS[code] or SP_STRINGS["en"]
    end
    return _lang[key] or SP_STRINGS["en"][key] or ("?" .. key .. "?")
end

-- Export global
SmartPricer_STR = SP_STR
