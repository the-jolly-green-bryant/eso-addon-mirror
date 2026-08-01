SustainMonitor = SustainMonitor or {}
local SM = SustainMonitor

---------------------------------------------------------------------------
SM.defaults = {
    enabled         = true,
    locked          = false,
    scale           = 1.0,
    posX            = 400,
    posY            = 800,

    displayStyle    = "simple",
    compactMode     = false,
    showMagicka     = true,
    showStamina     = true,
    showHealth      = false,
    showPotion      = true,
    showBars        = true,
    showRestzeit    = true,
    showGraph       = true,
    showCastsRemaining = true,

    smoothingAlpha  = 0.3,

    haEnabled       = true,
    haThreshold     = 8,
    haResourcePct   = 50,

    warningEnabled      = true,
    warningThreshold1   = 10,
    warningThreshold2   = 5,
    warningThreshold3   = 3,
    warningSound        = true,
    warningFlash        = true,

    hideOutOfCombat = true,
    fadeDelay       = 3,

    soundWarning     = "GENERAL_ALERT_ERROR",
    soundHeavyAttack = "CHAMPION_POINT_GAINED",
    soundPotionReady = "QUEST_COMPLETED",

    colorWarningYellow  = { 1, 0.84, 0, 1 },
    colorWarningOrange  = { 1, 0.55, 0, 1 },
    colorWarningRed     = { 1, 0, 0, 1 },
    alertFontSize       = 28,

    colorPotion         = { 0, 0.75, 1, 1 },
    colorPotionReady    = { 0.2, 0.8, 0.2, 1 },
    potionFontSize      = 22,

    resourceFocus   = "auto",
    graphStyle      = "line",
    debugMode       = false,
}

---------------------------------------------------------------------------
---------------------------------------------------------------------------
local styleValues     = { "simple", "analytical", "combat" }

---------------------------------------------------------------------------
---------------------------------------------------------------------------
local soundOptions = {
    { label = "General Alert Error",     key = "GENERAL_ALERT_ERROR" },
    { label = "Ability Failed",          key = "ABILITY_FAILED" },
    { label = "Not Enough Stamina",      key = "ABILITY_NOT_ENOUGH_STAMINA" },
    { label = "Not Enough Magicka",      key = "ABILITY_NOT_ENOUGH_MAGICKA" },
    { label = "Countdown Warning",       key = "COUNTDOWN_WARNING" },
    { label = "Duel Boundary Warning",   key = "DUEL_BOUNDARY_WARNING" },
    { label = "Champion Point Gained",   key = "CHAMPION_POINT_GAINED" },
    { label = "Ultimate Ready",          key = "ABILITY_ULTIMATE_READY" },
    { label = "Synergy Ready",           key = "ABILITY_SYNERGY_READY" },
    { label = "Combat Tip",              key = "ACTIVE_COMBAT_TIP_SHOWN" },
    { label = "Quest Completed",         key = "QUEST_COMPLETED" },
    { label = "Objective Complete",      key = "QUEST_OBJECTIVE_COMPLETE" },
    { label = "Achievement Awarded",     key = "ACHIEVEMENT_AWARDED" },
    { label = "Skill Point Gained",      key = "SKILL_POINT_GAINED" },
    { label = "Level Up",                key = "LEVEL_UP" },
    { label = "New Notification",        key = "NEW_NOTIFICATION" },
    { label = "Collectible Unlocked",    key = "COLLECTIBLE_UNLOCKED" },
    { label = "Endeavor Completed",      key = "ENDEAVOR_COMPLETED" },
    { label = "Armor Broken",            key = "HUD_ARMOR_BROKEN" },
    { label = "Battleground Warning",    key = "BATTLEGROUND_INACTIVITY_WARNING" },
    { label = "BG Capture (Own Team)",  key = "BATTLEGROUND_CAPTURE_AREA_CAPTURED_OWN_TEAM" },
    { label = "BG Capture (Other Team)", key = "BATTLEGROUND_CAPTURE_AREA_CAPTURED_OTHER_TEAM" },
    { label = "BG Countdown Finished", key = "BATTLEGROUND_COUNTDOWN_FINISH" },
}

local soundLabels     = {}
local soundLabelToKey = {}
local soundKeyToLabel = {}
for _, opt in ipairs(soundOptions) do
    soundLabels[#soundLabels + 1] = opt.label
    soundLabelToKey[opt.label] = opt.key
    soundKeyToLabel[opt.key]   = opt.label
end

local function GetStyleChoices()
    local L = SM.L
    return {
        L.STYLE_SIMPLE,
        L.STYLE_ANALYTICAL,
        L.STYLE_COMBAT,
    }
end

local function StyleValueToDisplay(value)
    local L = SM.L
    local map = {
        simple     = L.STYLE_SIMPLE,
        analytical = L.STYLE_ANALYTICAL,
        combat     = L.STYLE_COMBAT,
    }
    return map[value] or L.STYLE_SIMPLE
end

local function StyleDisplayToValue(display)
    local L = SM.L
    local map = {
        [L.STYLE_SIMPLE]     = "simple",
        [L.STYLE_ANALYTICAL] = "analytical",
        [L.STYLE_COMBAT]     = "combat",
    }
    return map[display] or "simple"
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.InitSettings()
    local L = SM.L
    if not L then return end

    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = L.ADDON_NAME,
        displayName = "|cAAD1FF" .. L.ADDON_NAME .. "|r",
        author = "Miguel",
        version = SM.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(SM.name .. "Options", panelData)

    local optionsData = {
        -- General
        {
            type = "header",
            name = L.SETTINGS_GENERAL,
        },
        {
            type = "checkbox",
            name = L.SETTING_ENABLED,
            tooltip = L.SETTING_ENABLED_TT,
            getFunc = function() return SM.savedVars.enabled end,
            setFunc = function(value)
                SM.savedVars.enabled = value
                if value then
                    if SM.IsInCombat() then SM.ShowHUD()
                    elseif not SM.savedVars.hideOutOfCombat then SM.ShowHUD()
                    end
                else
                    SM.HideHUD()
                end
            end,
            default = SM.defaults.enabled,
        },
        {
            type = "checkbox",
            name = L.SETTING_LOCKED,
            tooltip = L.SETTING_LOCKED_TT,
            getFunc = function() return SM.savedVars.locked end,
            setFunc = function(value)
                SM.savedVars.locked = value
                SM.SetHUDLocked(value)
            end,
            default = SM.defaults.locked,
        },
        {
            type = "slider",
            name = L.SETTING_SCALE,
            tooltip = L.SETTING_SCALE_TT,
            min = 50,
            max = 200,
            step = 5,
            getFunc = function() return SM.savedVars.scale * 100 end,
            setFunc = function(value)
                SM.savedVars.scale = value / 100
                SM.SetHUDScale(SM.savedVars.scale)
            end,
            default = SM.defaults.scale * 100,
        },
        {
            type = "button",
            name = L.SETTING_RESET_POS,
            tooltip = L.SETTING_RESET_POS_TT,
            func = function() SM.ResetHUDPosition() end,
        },

        -- Display
        {
            type = "header",
            name = L.SETTINGS_DISPLAY,
        },
        {
            type = "dropdown",
            name = L.SETTING_STYLE,
            tooltip = L.SETTING_STYLE_TT,
            choices = GetStyleChoices(),
            getFunc = function() return StyleValueToDisplay(SM.savedVars.displayStyle) end,
            setFunc = function(display)
                SM.savedVars.displayStyle = StyleDisplayToValue(display)
                SM.RebuildHUD()
            end,
            default = StyleValueToDisplay(SM.defaults.displayStyle),
        },
        {
            type = "checkbox",
            name = L.SETTING_COMPACT,
            tooltip = L.SETTING_COMPACT_TT,
            getFunc = function() return SM.savedVars.compactMode end,
            setFunc = function(value)
                SM.savedVars.compactMode = value
                SM.RebuildHUD()
            end,
            default = SM.defaults.compactMode,
            disabled = function() return SM.savedVars.displayStyle ~= "simple" end,
        },
        {
            type = "checkbox",
            name = L.SETTING_SHOW_MAGICKA,
            tooltip = L.SETTING_SHOW_MAGICKA_TT,
            getFunc = function() return SM.savedVars.showMagicka end,
            setFunc = function(value)
                SM.savedVars.showMagicka = value
                SM.RebuildHUD()
            end,
            default = SM.defaults.showMagicka,
        },
        {
            type = "checkbox",
            name = L.SETTING_SHOW_STAMINA,
            tooltip = L.SETTING_SHOW_STAMINA_TT,
            getFunc = function() return SM.savedVars.showStamina end,
            setFunc = function(value)
                SM.savedVars.showStamina = value
                SM.RebuildHUD()
            end,
            default = SM.defaults.showStamina,
        },
        {
            type = "checkbox",
            name = L.SETTING_SHOW_HEALTH,
            tooltip = L.SETTING_SHOW_HEALTH_TT,
            getFunc = function() return SM.savedVars.showHealth end,
            setFunc = function(value)
                SM.savedVars.showHealth = value
                SM.RebuildHUD()
            end,
            default = SM.defaults.showHealth,
        },
        {
            type = "checkbox",
            name = L.SETTING_SHOW_POTION,
            tooltip = L.SETTING_SHOW_POTION_TT,
            getFunc = function() return SM.savedVars.showPotion end,
            setFunc = function(value)
                SM.savedVars.showPotion = value
                SM.RebuildHUD()
            end,
            default = SM.defaults.showPotion,
        },
        {
            type = "checkbox",
            name = L.SETTING_SHOW_BARS,
            tooltip = L.SETTING_SHOW_BARS_TT,
            getFunc = function() return SM.savedVars.showBars end,
            setFunc = function(value)
                SM.savedVars.showBars = value
                SM.RebuildHUD()
            end,
            default = SM.defaults.showBars,
            disabled = function() return SM.savedVars.displayStyle == "combat" end,
        },
        {
            type = "checkbox",
            name = L.SETTING_SHOW_TIME,
            tooltip = L.SETTING_SHOW_TIME_TT,
            getFunc = function() return SM.savedVars.showRestzeit end,
            setFunc = function(value)
                SM.savedVars.showRestzeit = value
                SM.RebuildHUD()
            end,
            default = SM.defaults.showRestzeit,
        },
        {
            type = "checkbox",
            name = L.SETTING_SHOW_GRAPH,
            tooltip = L.SETTING_SHOW_GRAPH_TT,
            getFunc = function() return SM.savedVars.showGraph end,
            setFunc = function(value)
                SM.savedVars.showGraph = value
                SM.RebuildHUD()
            end,
            default = SM.defaults.showGraph,
            disabled = function() return SM.savedVars.displayStyle ~= "analytical" end,
        },
        {
            type = "dropdown",
            name = L.SETTING_GRAPH_STYLE or "Graph Style",
            tooltip = L.SETTING_GRAPH_STYLE_TT or "Visual style for the resource history graph in Analytical mode",
            choices = { L.GRAPH_STYLE_LINE or "Line Graph", L.GRAPH_STYLE_BAR or "Bar Chart" },
            choicesValues = { "line", "bar" },
            getFunc = function() return SM.savedVars.graphStyle end,
            setFunc = function(v)
                SM.savedVars.graphStyle = v
                SM.RebuildHUD()
            end,
            default = SM.defaults.graphStyle,
            disabled = function() return not SM.savedVars.showGraph or SM.savedVars.displayStyle ~= "analytical" end,
        },
        {
            type = "checkbox",
            name = L.SETTING_SHOW_CASTS,
            tooltip = L.SETTING_SHOW_CASTS_TT,
            getFunc = function() return SM.savedVars.showCastsRemaining end,
            setFunc = function(value) SM.savedVars.showCastsRemaining = value end,
            default = SM.defaults.showCastsRemaining,
        },

        -- Calculation
        {
            type = "header",
            name = L.SETTINGS_CALCULATION,
        },
        {
            type = "slider",
            name = L.SETTING_SMOOTHING,
            tooltip = L.SETTING_SMOOTHING_TT,
            min = 5,
            max = 80,
            step = 5,
            getFunc = function() return SM.savedVars.smoothingAlpha * 100 end,
            setFunc = function(value)
                SM.savedVars.smoothingAlpha = value / 100
            end,
            default = SM.defaults.smoothingAlpha * 100,
        },

        -- Heavy Attack
        {
            type = "header",
            name = L.SETTINGS_HEAVY_ATTACK,
        },
        {
            type = "checkbox",
            name = L.SETTING_HA_ENABLED,
            tooltip = L.SETTING_HA_ENABLED_TT,
            getFunc = function() return SM.savedVars.haEnabled end,
            setFunc = function(value) SM.savedVars.haEnabled = value end,
            default = SM.defaults.haEnabled,
        },
        {
            type = "slider",
            name = L.SETTING_HA_THRESHOLD,
            tooltip = L.SETTING_HA_THRESHOLD_TT,
            min = 3,
            max = 20,
            step = 1,
            getFunc = function() return SM.savedVars.haThreshold end,
            setFunc = function(value) SM.savedVars.haThreshold = value end,
            default = SM.defaults.haThreshold,
            disabled = function() return not SM.savedVars.haEnabled end,
        },
        {
            type = "slider",
            name = L.SETTING_HA_RESOURCE_PCT,
            tooltip = L.SETTING_HA_RESOURCE_PCT_TT,
            min = 10,
            max = 80,
            step = 5,
            getFunc = function() return SM.savedVars.haResourcePct end,
            setFunc = function(value) SM.savedVars.haResourcePct = value end,
            default = SM.defaults.haResourcePct,
            disabled = function() return not SM.savedVars.haEnabled end,
        },

        -- Warnings
        {
            type = "header",
            name = L.SETTINGS_WARNINGS,
        },
        {
            type = "checkbox",
            name = L.SETTING_WARNINGS_ON,
            tooltip = L.SETTING_WARNINGS_ON_TT,
            getFunc = function() return SM.savedVars.warningEnabled end,
            setFunc = function(value) SM.savedVars.warningEnabled = value end,
            default = SM.defaults.warningEnabled,
        },
        {
            type = "dropdown",
            name = L.SETTING_FOCUS or "Resource Focus",
            tooltip = L.SETTING_FOCUS_TT or "Which resource to prioritize for warnings and alerts. Auto detects based on combat usage.",
            choices = {
                L.FOCUS_AUTO or "Auto (detect)",
                L.FOCUS_ALL or "All Resources",
                L.FOCUS_MAGICKA or "Magicka",
                L.FOCUS_STAMINA or "Stamina",
                L.FOCUS_HEALTH or "Health",
            },
            choicesValues = { "auto", "all", "magicka", "stamina", "health" },
            getFunc = function() return SM.savedVars.resourceFocus end,
            setFunc = function(v) SM.savedVars.resourceFocus = v end,
            default = SM.defaults.resourceFocus,
            disabled = function() return not SM.savedVars.warningEnabled end,
        },
        {
            type = "slider",
            name = L.SETTING_THRESH_1,
            tooltip = L.SETTING_THRESH_1_TT,
            min = 3,
            max = 30,
            step = 1,
            getFunc = function() return SM.savedVars.warningThreshold1 end,
            setFunc = function(value) SM.savedVars.warningThreshold1 = value end,
            default = SM.defaults.warningThreshold1,
        },
        {
            type = "slider",
            name = L.SETTING_THRESH_2,
            tooltip = L.SETTING_THRESH_2_TT,
            min = 2,
            max = 20,
            step = 1,
            getFunc = function() return SM.savedVars.warningThreshold2 end,
            setFunc = function(value) SM.savedVars.warningThreshold2 = value end,
            default = SM.defaults.warningThreshold2,
        },
        {
            type = "slider",
            name = L.SETTING_THRESH_3,
            tooltip = L.SETTING_THRESH_3_TT,
            min = 1,
            max = 10,
            step = 1,
            getFunc = function() return SM.savedVars.warningThreshold3 end,
            setFunc = function(value) SM.savedVars.warningThreshold3 = value end,
            default = SM.defaults.warningThreshold3,
        },
        {
            type = "checkbox",
            name = L.SETTING_WARN_SOUND,
            tooltip = L.SETTING_WARN_SOUND_TT,
            getFunc = function() return SM.savedVars.warningSound end,
            setFunc = function(value) SM.savedVars.warningSound = value end,
            default = SM.defaults.warningSound,
        },
        {
            type = "checkbox",
            name = L.SETTING_WARN_FLASH,
            tooltip = L.SETTING_WARN_FLASH_TT,
            getFunc = function() return SM.savedVars.warningFlash end,
            setFunc = function(value) SM.savedVars.warningFlash = value end,
            default = SM.defaults.warningFlash,
        },
        {
            type = "dropdown",
            name = L.SETTING_SOUND_WARNING,
            tooltip = L.SETTING_SOUND_WARNING_TT,
            choices = soundLabels,
            getFunc = function() return soundKeyToLabel[SM.savedVars.soundWarning] or "General Alert Error" end,
            setFunc = function(label)
                local key = soundLabelToKey[label]
                if key then
                    SM.savedVars.soundWarning = key
                    if SOUNDS[key] then PlaySound(SOUNDS[key]) end
                end
            end,
            default = soundKeyToLabel[SM.defaults.soundWarning],
            disabled = function() return not SM.savedVars.warningSound end,
        },
        {
            type = "dropdown",
            name = L.SETTING_SOUND_HEAVY,
            tooltip = L.SETTING_SOUND_HEAVY_TT,
            choices = soundLabels,
            getFunc = function() return soundKeyToLabel[SM.savedVars.soundHeavyAttack] or "Champion Point Gained" end,
            setFunc = function(label)
                local key = soundLabelToKey[label]
                if key then
                    SM.savedVars.soundHeavyAttack = key
                    if SOUNDS[key] then PlaySound(SOUNDS[key]) end
                end
            end,
            default = soundKeyToLabel[SM.defaults.soundHeavyAttack],
            disabled = function() return not SM.savedVars.warningSound end,
        },
        {
            type = "dropdown",
            name = L.SETTING_SOUND_POTION,
            tooltip = L.SETTING_SOUND_POTION_TT,
            choices = soundLabels,
            getFunc = function() return soundKeyToLabel[SM.savedVars.soundPotionReady] or "Quest Completed" end,
            setFunc = function(label)
                local key = soundLabelToKey[label]
                if key then
                    SM.savedVars.soundPotionReady = key
                    if SOUNDS[key] then PlaySound(SOUNDS[key]) end
                end
            end,
            default = soundKeyToLabel[SM.defaults.soundPotionReady],
            disabled = function() return not SM.savedVars.warningSound end,
        },

        -- Alert Appearance
        {
            type = "header",
            name = L.SETTINGS_ALERT_APPEARANCE,
        },
        {
            type = "colorpicker",
            name = L.SETTING_COLOR_WARN_YELLOW,
            tooltip = L.SETTING_COLOR_WARN_YELLOW_TT,
            getFunc = function()
                local c = SM.savedVars.colorWarningYellow
                return c[1], c[2], c[3], c[4]
            end,
            setFunc = function(r, g, b, a)
                SM.savedVars.colorWarningYellow = { r, g, b, a }
            end,
            default = {
                r = SM.defaults.colorWarningYellow[1],
                g = SM.defaults.colorWarningYellow[2],
                b = SM.defaults.colorWarningYellow[3],
                a = SM.defaults.colorWarningYellow[4],
            },
        },
        {
            type = "colorpicker",
            name = L.SETTING_COLOR_WARN_ORANGE,
            tooltip = L.SETTING_COLOR_WARN_ORANGE_TT,
            getFunc = function()
                local c = SM.savedVars.colorWarningOrange
                return c[1], c[2], c[3], c[4]
            end,
            setFunc = function(r, g, b, a)
                SM.savedVars.colorWarningOrange = { r, g, b, a }
            end,
            default = {
                r = SM.defaults.colorWarningOrange[1],
                g = SM.defaults.colorWarningOrange[2],
                b = SM.defaults.colorWarningOrange[3],
                a = SM.defaults.colorWarningOrange[4],
            },
        },
        {
            type = "colorpicker",
            name = L.SETTING_COLOR_WARN_RED,
            tooltip = L.SETTING_COLOR_WARN_RED_TT,
            getFunc = function()
                local c = SM.savedVars.colorWarningRed
                return c[1], c[2], c[3], c[4]
            end,
            setFunc = function(r, g, b, a)
                SM.savedVars.colorWarningRed = { r, g, b, a }
            end,
            default = {
                r = SM.defaults.colorWarningRed[1],
                g = SM.defaults.colorWarningRed[2],
                b = SM.defaults.colorWarningRed[3],
                a = SM.defaults.colorWarningRed[4],
            },
        },
        {
            type = "slider",
            name = L.SETTING_ALERT_FONT_SIZE,
            tooltip = L.SETTING_ALERT_FONT_SIZE_TT,
            min = 16,
            max = 40,
            step = 2,
            getFunc = function() return SM.savedVars.alertFontSize end,
            setFunc = function(value)
                SM.savedVars.alertFontSize = value
                SM.RebuildHUD()
            end,
            default = SM.defaults.alertFontSize,
        },

        -- Potion Appearance
        {
            type = "header",
            name = L.SETTINGS_POTION_APPEARANCE,
        },
        {
            type = "colorpicker",
            name = L.SETTING_COLOR_POTION,
            tooltip = L.SETTING_COLOR_POTION_TT,
            getFunc = function()
                local c = SM.savedVars.colorPotion
                return c[1], c[2], c[3], c[4]
            end,
            setFunc = function(r, g, b, a)
                SM.savedVars.colorPotion = { r, g, b, a }
                SM.RebuildHUD()
            end,
            default = {
                r = SM.defaults.colorPotion[1],
                g = SM.defaults.colorPotion[2],
                b = SM.defaults.colorPotion[3],
                a = SM.defaults.colorPotion[4],
            },
        },
        {
            type = "colorpicker",
            name = L.SETTING_COLOR_POTION_READY,
            tooltip = L.SETTING_COLOR_POTION_READY_TT,
            getFunc = function()
                local c = SM.savedVars.colorPotionReady
                return c[1], c[2], c[3], c[4]
            end,
            setFunc = function(r, g, b, a)
                SM.savedVars.colorPotionReady = { r, g, b, a }
            end,
            default = {
                r = SM.defaults.colorPotionReady[1],
                g = SM.defaults.colorPotionReady[2],
                b = SM.defaults.colorPotionReady[3],
                a = SM.defaults.colorPotionReady[4],
            },
        },
        {
            type = "slider",
            name = L.SETTING_POTION_FONT_SIZE,
            tooltip = L.SETTING_POTION_FONT_SIZE_TT,
            min = 14,
            max = 36,
            step = 2,
            getFunc = function() return SM.savedVars.potionFontSize end,
            setFunc = function(value)
                SM.savedVars.potionFontSize = value
                SM.RebuildHUD()
            end,
            default = SM.defaults.potionFontSize,
        },

        -- Behavior
        {
            type = "header",
            name = L.SETTINGS_BEHAVIOR,
        },
        {
            type = "checkbox",
            name = L.SETTING_HIDE_OOC,
            tooltip = L.SETTING_HIDE_OOC_TT,
            getFunc = function() return SM.savedVars.hideOutOfCombat end,
            setFunc = function(value)
                SM.savedVars.hideOutOfCombat = value
                if not value then
                    SM.ShowHUD()
                elseif not SM.IsInCombat() then
                    SM.HideHUD()
                end
            end,
            default = SM.defaults.hideOutOfCombat,
        },
        {
            type = "slider",
            name = L.SETTING_FADE_DELAY,
            tooltip = L.SETTING_FADE_DELAY_TT,
            min = 0,
            max = 15,
            step = 1,
            getFunc = function() return SM.savedVars.fadeDelay end,
            setFunc = function(value) SM.savedVars.fadeDelay = value end,
            default = SM.defaults.fadeDelay,
        },

        -- Debug
        {
            type = "header",
            name = L.SETTINGS_DEBUG,
        },
        {
            type = "checkbox",
            name = L.SETTING_DEBUG_MODE,
            tooltip = L.SETTING_DEBUG_MODE_TT,
            getFunc = function() return SM.savedVars.debugMode end,
            setFunc = function(value) SM.savedVars.debugMode = value end,
            default = SM.defaults.debugMode,
        },
    }

    LAM:RegisterOptionControls(SM.name .. "Options", optionsData)
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
function SM.RegisterSlashCommands()
    SLASH_COMMANDS["/sm"] = function(args)
        local arg = string.lower(args or "")

        if arg == "toggle" then
            SM.ToggleHUD()
        elseif arg == "reset" then
            SM.ResetHUDPosition()
            d("|cAAD1FF[SM]|r Position reset.")
        elseif arg == "simple" or arg == "analytical" or arg == "combat" then
            SM.savedVars.displayStyle = arg
            SM.RebuildHUD()
            d("|cAAD1FF[SM]|r Style: " .. arg)
        elseif arg == "sounds" then
            SM.PlayTestSounds()
        elseif arg == "debug" then
            SM.savedVars.debugMode = not SM.savedVars.debugMode
            d("|cAAD1FF[SM]|r Debug mode: " .. (SM.savedVars.debugMode and "|c00FF00ON|r" or "|cFF4444OFF|r"))
        elseif arg == "dump" then
            SM.DumpDebugInfo()
        elseif arg == "log" then
            local count = SM.logVars and SM.logVars.entries and #SM.logVars.entries or 0
            d("|cAAD1FF[SM]|r Combat log: " .. count .. " entries")
            d("|cAAD1FF[SM]|r Debug mode: " .. (SM.savedVars.debugMode and "|c00FF00ON|r" or "|cFF4444OFF|r"))
            if count > 0 then
                d("|cAAD1FF[SM]|r Log info: " .. tostring(SM.logVars.info))
                d("|cAAD1FF[SM]|r Type |cFFFF00/reloadui|r to save log to disk.")
                d("|cAAD1FF[SM]|r File: Documents/Elder Scrolls Online/live/SavedVariables/SustainMonitor.lua")
            else
                d("|cAAD1FF[SM]|r Enable debug mode with |cFFFF00/sm debug|r then enter combat.")
            end
        elseif arg == "clearlog" then
            if SM.logVars then
                SM.logVars.entries = {}
                SM.logVars.info = ""
            end
            d("|cAAD1FF[SM]|r Combat log cleared.")
        else
            d("|cAAD1FF[Sustain Monitor]|r Commands:")
            d("  /sm - Show this help")
            d("  /sm toggle - Toggle HUD visibility")
            d("  /sm reset - Reset HUD position")
            d("  /sm simple|analytical|combat - Switch display style")
            d("  /sm sounds - Play test sounds (3 distinct alerts)")
            d("  /sm debug - Toggle debug logging")
            d("  /sm dump - Print diagnostic info")
            d("  /sm log - Show combat log status")
            d("  /sm clearlog - Clear combat log")
        end
    end
end
