--[[
    Nemesis - Settings
    Optional LibHarvensAddonSettings panel (shipped as "LibVotans" on console).
    Falls back to /nemesis slash commands if the library isn't installed.
]]

Nemesis = Nemesis or {}
local N = Nemesis
N.Settings = {}

local SV

local DEFAULTS = {
    showDossier = true,
    banners = true,
    sounds = true,
    scrim = true,
    dossierX = 230,
    dossierY = 20,
    dossierScale = 1.0,
}

local function RefreshUI()
    if N.UI and N.UI.ApplyVisibility then N.UI.ApplyVisibility() end
end

local function Checkbox(LHAS, label, tooltip, key, setFunction)
    return {
        type = LHAS.ST_CHECKBOX,
        label = label,
        tooltip = tooltip,
        getFunction = function() return SV[key] end,
        setFunction = setFunction or function(value)
            SV[key] = value
            RefreshUI()
        end,
        default = DEFAULTS[key] ~= nil and DEFAULTS[key] or true,
    }
end

local function Slider(LHAS, label, tooltip, key, min, max, step, format, unit)
    return {
        type = LHAS.ST_SLIDER,
        label = label,
        tooltip = tooltip,
        min = min,
        max = max,
        step = step,
        format = format,
        unit = unit,
        getFunction = function() return SV[key] end,
        setFunction = function(value)
            SV[key] = value
            if N.UI and N.UI.ApplyPositionAndScale then N.UI.ApplyPositionAndScale() end
        end,
        default = DEFAULTS[key],
    }
end

function N.Settings.Init(savedVars)
    SV = savedVars

    local LHAS = LibHarvensAddonSettings or LibVotans
    if not LHAS or not LHAS.AddAddon then return end

    local panel = LHAS:AddAddon("Nemesis", { allowDefaults = true, allowRefresh = true })
    if not panel then return end

    local settings = {
        { type = LHAS.ST_SECTION, label = "General" },

        Checkbox(LHAS, "Show Dossier",
            "Show the rival dossier popup when you target a player in PvP.",
            "showDossier",
            function(value)
                SV.showDossier = value
                if not value and N.UI and N.UI.HideDossier then N.UI.HideDossier() end
            end),

        Checkbox(LHAS, "Show Banners",
            "Show center-screen Nemesis / Vengeance announcements.", "banners",
            function(value) SV.banners = value end),

        Checkbox(LHAS, "Play Sounds",
            "Play a sound with Nemesis banners.", "sounds",
            function(value) SV.sounds = value end),

        Checkbox(LHAS, "Group Build Sharing",
            "Share and receive bar/CP/set data with grouped Nemesis users. Takes effect after a UI reload. Disabled automatically if another addon owns the group broadcast channel.",
            "scrim",
            function(value)
                SV.scrim = value
                N.Msg("Build sharing " .. (value and "enabled" or "disabled") .. " - takes effect after a UI reload.")
            end),

        { type = LHAS.ST_SECTION, label = "Dossier Position & Scale" },

        Slider(LHAS, "Horizontal Position",
            "Offset from screen center. Positive = right, negative = left.",
            "dossierX", -1500, 1500, 10, "%d", " px"),

        Slider(LHAS, "Vertical Position",
            "Offset from screen center. Positive = down, negative = up.",
            "dossierY", -1000, 1000, 10, "%d", " px"),

        Slider(LHAS, "Dossier Scale",
            "Resize the whole dossier popup.",
            "dossierScale", 0.50, 2.00, 0.05, "%.2f", "x"),

        {
            type = LHAS.ST_BUTTON,
            label = "Reset Dossier Position",
            tooltip = "Reset position and scale to default.",
            buttonText = "Reset",
            clickHandler = function()
                if N.UI and N.UI.ResetPosition then N.UI.ResetPosition() end
            end,
        },

        { type = LHAS.ST_SECTION, label = "Dossier Sections" },

        Checkbox(LHAS, "Class / Race / CP / Rank", "Show the info line under the player name.", "showDossierInfo"),
        Checkbox(LHAS, "Live Health Bar", "Show the target's current health bar.", "showDossierHP"),
        Checkbox(LHAS, "Head-to-Head Record", "Show your kill/death record against this player.", "showDossierKD"),
        Checkbox(LHAS, "Win Chance", "Show the estimated win chance percentage.", "showDossierWin"),
        Checkbox(LHAS, "Known Moves", "Show the enemy's most-used abilities against you.", "showDossierMoves"),
        Checkbox(LHAS, "Detected Sets", "Show proc sets detected from combat.", "showDossierSets"),
        Checkbox(LHAS, "Footer", "Show the last-seen / streak / location footer.", "showDossierFooter"),
    }

    if panel.AddSettings then
        panel:AddSettings(settings)
    else
        for i = 1, #settings do
            panel:AddSetting(settings[i])
        end
    end
end
