TeamShadowsBuffs = TeamShadowsBuffs or {}

local TSB = TeamShadowsBuffs

local SETTINGS_PANEL_NAME = "TeamShadowsBuffsOptions"

local function RefreshUi()
    if TSB.NormalizeLayout then
        TSB.savedVars.layout = TSB.NormalizeLayout(TSB.savedVars.layout)
    end
    if TSB.modules and TSB.modules.MajorEffects and TSB.modules.MajorEffects.Scan then
        TSB.SafeCall("MajorEffects", "Scan", TSB.modules.MajorEffects.Scan, TSB.modules.MajorEffects)
    end
    if TSB.UI then
        TSB.SafeCall("UI", "ApplySettings", TSB.UI.ApplySettings, TSB.UI)
    end
end

local function SafeColor(color, fallback)
    color = type(color) == "table" and color or {}
    fallback = type(fallback) == "table" and fallback or {}
    return color.r or fallback.r or 1,
        color.g or fallback.g or 1,
        color.b or fallback.b or 1,
        color.a or fallback.a or 1
end

local function ColorDefault(color, alpha)
    color = type(color) == "table" and color or {}
    return {
        r = color.r or 1,
        g = color.g or 1,
        b = color.b or 1,
        a = color.a or alpha or 1,
    }
end

local function GetEffectColor(key)
    local effect = TSB.GetMajorEffectByKey and TSB.GetMajorEffectByKey(key)
    local base = effect and effect.color or { r = 1, g = 1, b = 1, a = 1 }
    local settings = TSB.GetEffectSettings and TSB.GetEffectSettings(key) or {}
    local color = settings.color or base
    return color.r or 1, color.g or 1, color.b or 1, color.a or 1
end

local function SetEffectColor(key, r, g, b, a)
    local effect = TSB.GetMajorEffectByKey and TSB.GetMajorEffectByKey(key)
    local dr, dg, db, da = SafeColor(effect and effect.color, { r = 1, g = 1, b = 1, a = 1 })
    local settings = TSB.GetEffectSettings(key)
    settings.color = {
        r = r or dr,
        g = g or dg,
        b = b or db,
        a = a or da or 1,
    }
    RefreshUi()
end

local function GetEffectEnabled(key)
    local settings = TSB.GetEffectSettings and TSB.GetEffectSettings(key) or {}
    return settings.enabled ~= false
end

local function SetEffectEnabled(key, value)
    local settings = TSB.GetEffectSettings(key)
    settings.enabled = value == true
    RefreshUi()
end

local function GetEffectName(key)
    local effect = TSB.GetMajorEffectByKey and TSB.GetMajorEffectByKey(key)
    local settings = TSB.GetEffectSettings and TSB.GetEffectSettings(key) or {}
    return settings.name or (effect and effect.name) or key
end

local function SetEffectName(key, value)
    local settings = TSB.GetEffectSettings(key)
    settings.name = tostring(value or "")
    RefreshUi()
end

local function GetEffectShortName(key)
    local effect = TSB.GetMajorEffectByKey and TSB.GetMajorEffectByKey(key)
    local settings = TSB.GetEffectSettings and TSB.GetEffectSettings(key) or {}
    return settings.shortName or (effect and effect.shortName) or key
end

local function SetEffectShortName(key, value)
    local settings = TSB.GetEffectSettings(key)
    settings.shortName = tostring(value or "")
    RefreshUi()
end

local function AddEffectControls(options, headerName, list)
    table.insert(options, {
        type = "header",
        name = headerName,
    })

    for _, effect in ipairs(list or {}) do
        table.insert(options, {
            type = "submenu",
            name = effect.name,
            controls = {
                {
                    type = "checkbox",
                    name = "Afficher",
                    tooltip = effect.key,
                    getFunc = function()
                        return GetEffectEnabled(effect.key)
                    end,
                    setFunc = function(value)
                        SetEffectEnabled(effect.key, value)
                    end,
                    default = true,
                    width = "full",
                },
                {
                    type = "editbox",
                    name = "Nom",
                    tooltip = "Nom affiche a cote du cercle.",
                    getFunc = function()
                        return GetEffectName(effect.key)
                    end,
                    setFunc = function(value)
                        SetEffectName(effect.key, value)
                    end,
                    default = effect.name,
                    width = "half",
                },
                {
                    type = "editbox",
                    name = "Abreviation",
                    tooltip = "Texte court affiche dans le cercle.",
                    getFunc = function()
                        return GetEffectShortName(effect.key)
                    end,
                    setFunc = function(value)
                        SetEffectShortName(effect.key, value)
                    end,
                    default = effect.shortName,
                    width = "half",
                },
                {
                    type = "colorpicker",
                    name = "Couleur",
                    tooltip = effect.key,
                    getFunc = function()
                        return GetEffectColor(effect.key)
                    end,
                    setFunc = function(r, g, b, a)
                        SetEffectColor(effect.key, r, g, b, a)
                    end,
                    default = ColorDefault(effect.color),
                    width = "half",
                },
                {
                    type = "button",
                    name = "Reset",
                    func = function()
                        if TSB.ResetEffectSettings then
                            TSB.ResetEffectSettings(effect.key)
                        end
                        RefreshUi()
                    end,
                    width = "half",
                },
            },
        })
    end
end

function TSB.RegisterSettingsPanel()
    local LAM = LibAddonMenu2 or LibAddonMenu
    if not LAM then
        TSB.Chat("Lib manquante optionnelle: LibAddonMenu-2.0. Installe-la via Minion pour les reglages ESO. Commandes dispo: /tsbuffs")
        return
    end

    local panelData = {
        type = "panel",
        name = TSB.displayName,
        displayName = "|c55AAFFTeam Shadows Buffs|r",
        author = "TeamFky - EyrOn",
        version = TSB.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options = {
        {
            type = "checkbox",
            name = "Activer l'addon",
            getFunc = function() return TSB.savedVars.enabled end,
            setFunc = function(value)
                TSB.savedVars.enabled = value
                if value then
                    TSB.LoadModules()
                else
                    TSB.UnloadModules()
                    if TSB.UI then TSB.UI:Shutdown() end
                end
                RefreshUi()
            end,
            default = TSB.defaults.enabled,
        },
        {
            type = "checkbox",
            name = "Deverrouiller les fenetres",
            tooltip = "Permet de deplacer les trackers. Les positions sont sauvegardees automatiquement.",
            getFunc = function() return TSB.savedVars.unlocked end,
            setFunc = function(value)
                TSB.savedVars.unlocked = value
                RefreshUi()
            end,
            default = TSB.defaults.unlocked,
        },
        {
            type = "dropdown",
            name = "Disposition",
            choices = { "Meme fenetre", "Deux fenetres: Buffs / Debuffs", "Chaque tracker separe" },
            choicesValues = { "combined", "separate", "individual" },
            getFunc = function() return TSB.NormalizeLayout and TSB.NormalizeLayout(TSB.savedVars.layout) or TSB.savedVars.layout end,
            setFunc = function(value)
                TSB.savedVars.layout = TSB.NormalizeLayout and TSB.NormalizeLayout(value) or value
                RefreshUi()
            end,
            default = TSB.defaults.layout,
        },
        {
            type = "submenu",
            name = "Apparence",
            controls = {
                {
                    type = "header",
                    name = "Apercu",
                },
                {
                    type = "checkbox",
                    name = "Apercu pendant les reglages",
                    tooltip = "Affiche des trackers exemple seulement pendant que ce panneau de reglages est ouvert.",
                    getFunc = function() return TSB.savedVars.previewEnabled end,
                    setFunc = function(value)
                        TSB.savedVars.previewEnabled = value
                        RefreshUi()
                    end,
                    default = TSB.defaults.previewEnabled,
                },
                {
                    type = "header",
                    name = "Dimensions",
                },
                {
                    type = "slider",
                    name = "Taille cellule buff/debuff",
                    tooltip = "Redimensionne toute une ligne: carre acronyme, nom, timer, barre, espacements et fenetre.",
                    min = 20,
                    max = 72,
                    step = 1,
                    getFunc = function() return TSB.savedVars.circleSize end,
                    setFunc = function(value)
                        TSB.savedVars.circleSize = value
                        RefreshUi()
                    end,
                    default = TSB.defaults.circleSize,
                },
                {
                    type = "header",
                    name = "Fond",
                },
                {
                    type = "colorpicker",
                    name = "Couleur fond fenetre",
                    getFunc = function()
                        return SafeColor(TSB.savedVars.frameColor, TSB.defaults.frameColor)
                    end,
                    setFunc = function(r, g, b, a)
                        TSB.savedVars.frameColor = { r = r or 0, g = g or 0, b = b or 0, a = a or 1 }
                        RefreshUi()
                    end,
                    default = ColorDefault(TSB.defaults.frameColor),
                },
                {
                    type = "slider",
                    name = "Transparence fond",
                    min = 0,
                    max = 1,
                    step = 0.05,
                    getFunc = function() return TSB.savedVars.frameAlpha end,
                    setFunc = function(value)
                        TSB.savedVars.frameAlpha = value
                        RefreshUi()
                    end,
                    default = TSB.defaults.frameAlpha,
                },
                {
                    type = "header",
                    name = "Bordure",
                },
                {
                    type = "checkbox",
                    name = "Afficher le bord",
                    getFunc = function() return TSB.savedVars.borderEnabled ~= false end,
                    setFunc = function(value)
                        TSB.savedVars.borderEnabled = value
                        RefreshUi()
                    end,
                    default = TSB.defaults.borderEnabled,
                },
                {
                    type = "slider",
                    name = "Epaisseur du bord",
                    min = 2,
                    max = 6,
                    step = 1,
                    getFunc = function() return TSB.savedVars.borderThickness end,
                    setFunc = function(value)
                        TSB.savedVars.borderThickness = value
                        RefreshUi()
                    end,
                    default = TSB.defaults.borderThickness,
                },
                {
                    type = "colorpicker",
                    name = "Couleur du bord",
                    getFunc = function()
                        local r, g, b = SafeColor(TSB.savedVars.borderColor, TSB.defaults.borderColor)
                        return r, g, b, TSB.savedVars.borderAlpha or TSB.defaults.borderAlpha or 1
                    end,
                    setFunc = function(r, g, b, a)
                        TSB.savedVars.borderColor = { r = r or 1, g = g or 1, b = b or 1 }
                        TSB.savedVars.borderAlpha = a or 1
                        RefreshUi()
                    end,
                    default = ColorDefault(TSB.defaults.borderColor, TSB.defaults.borderAlpha),
                },
                {
                    type = "header",
                    name = "Textes",
                },
                {
                    type = "slider",
                    name = "Transparence textes",
                    tooltip = "Regle la transparence des noms et timers. Le texte du carre suit la transparence du carre.",
                    min = 0,
                    max = 1,
                    step = 0.05,
                    getFunc = function() return TSB.savedVars.textAlpha end,
                    setFunc = function(value)
                        TSB.savedVars.textAlpha = value
                        RefreshUi()
                    end,
                    default = TSB.defaults.textAlpha,
                },
                {
                    type = "colorpicker",
                    name = "Couleur des noms",
                    getFunc = function()
                        return SafeColor(TSB.savedVars.nameTextColor, TSB.defaults.nameTextColor)
                    end,
                    setFunc = function(r, g, b, a)
                        TSB.savedVars.nameTextColor = { r = r or 1, g = g or 1, b = b or 1, a = a or 1 }
                        RefreshUi()
                    end,
                    default = ColorDefault(TSB.defaults.nameTextColor),
                },
                {
                    type = "colorpicker",
                    name = "Couleur des timers",
                    getFunc = function()
                        return SafeColor(TSB.savedVars.timerTextColor, TSB.defaults.timerTextColor)
                    end,
                    setFunc = function(r, g, b, a)
                        TSB.savedVars.timerTextColor = { r = r or 1, g = g or 1, b = b or 1, a = a or 1 }
                        RefreshUi()
                    end,
                    default = ColorDefault(TSB.defaults.timerTextColor),
                },
                {
                    type = "slider",
                    name = "Taille des timers",
                    min = 0.5,
                    max = 3,
                    step = 0.05,
                    getFunc = function() return TSB.savedVars.timerTextScale end,
                    setFunc = function(value)
                        TSB.savedVars.timerTextScale = value
                        RefreshUi()
                    end,
                    default = TSB.defaults.timerTextScale,
                },
                {
                    type = "header",
                    name = "Carre",
                },
                {
                    type = "slider",
                    name = "Transparence carre",
                    tooltip = "Regle la transparence de l'icone, du carre, du contour et de l'acronyme.",
                    min = 0,
                    max = 1,
                    step = 0.05,
                    getFunc = function() return TSB.savedVars.badgeAlpha end,
                    setFunc = function(value)
                        TSB.savedVars.badgeAlpha = value
                        RefreshUi()
                    end,
                    default = TSB.defaults.badgeAlpha,
                },
                {
                    type = "checkbox",
                    name = "Afficher acronyme",
                    tooltip = "Affiche ou masque les lettres dans le carre, par-dessus l'icone.",
                    getFunc = function() return TSB.savedVars.showAcronyms ~= false end,
                    setFunc = function(value)
                        TSB.savedVars.showAcronyms = value
                        RefreshUi()
                    end,
                    default = TSB.defaults.showAcronyms,
                },
                {
                    type = "colorpicker",
                    name = "Couleur texte carre",
                    getFunc = function()
                        return SafeColor(TSB.savedVars.acronymTextColor, TSB.defaults.acronymTextColor)
                    end,
                    setFunc = function(r, g, b, a)
                        TSB.savedVars.acronymTextColor = { r = r or 1, g = g or 1, b = b or 1, a = a or 1 }
                        RefreshUi()
                    end,
                    default = ColorDefault(TSB.defaults.acronymTextColor),
                },
                {
                    type = "header",
                    name = "Jauge",
                },
                {
                    type = "checkbox",
                    name = "Afficher la jauge",
                    tooltip = "Desactive la barre de duree. Avec les noms masques, le timer reste colle a l'icone.",
                    getFunc = function() return TSB.savedVars.showBar ~= false end,
                    setFunc = function(value)
                        TSB.savedVars.showBar = value
                        RefreshUi()
                    end,
                    default = TSB.defaults.showBar,
                },
                {
                    type = "slider",
                    name = "Transparence jauge",
                    tooltip = "Regle la transparence de la barre de duree et de son fond.",
                    min = 0,
                    max = 1,
                    step = 0.05,
                    getFunc = function() return TSB.savedVars.barAlpha end,
                    setFunc = function(value)
                        TSB.savedVars.barAlpha = value
                        RefreshUi()
                    end,
                    default = TSB.defaults.barAlpha,
                },
                {
                    type = "header",
                    name = "Affichage",
                },
                {
                    type = "checkbox",
                    name = "Afficher les noms",
                    tooltip = "Desactive pour garder seulement acronyme, timer et barre.",
                    getFunc = function() return TSB.savedVars.showNames end,
                    setFunc = function(value)
                        TSB.savedVars.showNames = value
                        RefreshUi()
                    end,
                    default = TSB.defaults.showNames,
                },
                {
                    type = "checkbox",
                    name = "Afficher les timers",
                    tooltip = "Affiche le compteur a droite de la ligne.",
                    getFunc = function() return TSB.savedVars.showTimers end,
                    setFunc = function(value)
                        TSB.savedVars.showTimers = value
                        RefreshUi()
                    end,
                    default = TSB.defaults.showTimers,
                },
            },
        },
        {
            type = "slider",
            name = "Zoom global fenetres",
            min = 0.6,
            max = 1.8,
            step = 0.05,
            getFunc = function() return TSB.savedVars.scale end,
            setFunc = function(value)
                TSB.savedVars.scale = value
                RefreshUi()
            end,
            default = TSB.defaults.scale,
        },
        {
            type = "editbox",
            name = "Ordre buffs",
            tooltip = "Liste separee par des virgules. Les cles inconnues sont ignorees.",
            getFunc = function() return TSB.savedVars.playerOrder end,
            setFunc = function(value)
                TSB.savedVars.playerOrder = value
                RefreshUi()
            end,
            default = TSB.defaults.playerOrder,
            width = "full",
        },
        {
            type = "editbox",
            name = "Ordre debuffs",
            tooltip = "Liste separee par des virgules. Les cles inconnues sont ignorees.",
            getFunc = function() return TSB.savedVars.bossOrder end,
            setFunc = function(value)
                TSB.savedVars.bossOrder = value
                RefreshUi()
            end,
            default = TSB.defaults.bossOrder,
            width = "full",
        },
        {
            type = "button",
            name = "Remettre trackers par defaut",
            func = function()
                if TSB.ResetAllEffectSettings then
                    TSB.ResetAllEffectSettings()
                end
                RefreshUi()
            end,
            width = "full",
        },
        {
            type = "header",
            name = "Modules",
        },
        {
            type = "checkbox",
            name = "MajorEffects",
            tooltip = "Buffs joueur et debuffs boss majeurs. Isole du reste de l'addon.",
            getFunc = function() return TSB.GetModuleSavedVars("MajorEffects").enabled ~= false end,
            setFunc = function(value)
                local vars = TSB.GetModuleSavedVars("MajorEffects")
                vars.enabled = value
                if value then
                    if TSB.moduleStates.MajorEffects then TSB.moduleStates.MajorEffects.failed = false end
                    TSB.LoadModule("MajorEffects")
                else
                    TSB.UnloadModule("MajorEffects")
                end
                RefreshUi()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Suivre buffs joueur",
            getFunc = function() return TSB.GetModuleSavedVars("MajorEffects").trackPlayerBuffs ~= false end,
            setFunc = function(value)
                TSB.GetModuleSavedVars("MajorEffects").trackPlayerBuffs = value
                RefreshUi()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Suivre debuffs boss",
            getFunc = function() return TSB.GetModuleSavedVars("MajorEffects").trackBossDebuffs ~= false end,
            setFunc = function(value)
                TSB.GetModuleSavedVars("MajorEffects").trackBossDebuffs = value
                RefreshUi()
            end,
            default = true,
        },
        {
            type = "checkbox",
            name = "Debug erreurs modules",
            getFunc = function() return TSB.savedVars.debug end,
            setFunc = function(value) TSB.savedVars.debug = value end,
            default = TSB.defaults.debug,
        },
    }

    local definitions = TSB.GetMajorEffectDefinitions and TSB.GetMajorEffectDefinitions()
    if definitions then
        AddEffectControls(options, "Major - Buffs", definitions.playerBuffs)
        AddEffectControls(options, "Major - Debuffs", definitions.bossDebuffs)
    end

    local panel = LAM:RegisterAddonPanel(SETTINGS_PANEL_NAME, panelData)
    TSB.settingsPanel = panel
    if panel then
        panel:SetHandler("OnShow", function()
            TSB.settingsPanelOpen = true
            RefreshUi()
        end)
        panel:SetHandler("OnHide", function()
            TSB.settingsPanelOpen = false
            RefreshUi()
        end)
    end
    LAM:RegisterOptionControls(SETTINGS_PANEL_NAME, options)
end

function TSB.OpenSettingsPanel()
    local LAM = LibAddonMenu2 or LibAddonMenu
    if not LAM then
        TSB.Chat("Lib manquante optionnelle: LibAddonMenu-2.0. Installe-la via Minion pour les reglages ESO.")
        return
    end

    if LAM.OpenToPanel and TSB.settingsPanel then
        LAM:OpenToPanel(TSB.settingsPanel)
    else
        TSB.Chat("Ouvre le menu Extensions puis Team Shadows Buffs.")
    end
end
