--[[
    Nemesis - Settings
    Optional LibHarvensAddonSettings / LibVotans settings panel.
    Falls back to slash commands if the library isn't installed.
]]

Nemesis = Nemesis or {}
local N = Nemesis
N.Settings = {}

local SV

local function AddCheckbox(panel, label, tooltip, key)
    panel:AddSetting({
        type = L.ST_CHECKBOX,
        label = label,
        tooltip = tooltip,
        getFunction = function() return SV[key] end,
        setFunction = function(value)
            SV[key] = value
            if N.UI and N.UI.ApplyVisibility then
                N.UI.ApplyVisibility()
            end
        end,
        default = true,
    })
end

function N.Settings.Init(savedVars)
    SV = savedVars
    if not LibHarvensAddonSettings then return end

    local L = LibHarvensAddonSettings
    local panel = L:AddAddon("Nemesis", { allowDefaults = false })

    panel:AddSetting({
        type = L.ST_CHECKBOX,
        label = "Show Dossier",
        tooltip = "Show the rival dossier popup when you target a player.",
        getFunction = function() return SV.showDossier end,
        setFunction = function(value)
            SV.showDossier = value
            if not value and N.UI and N.UI.HideDossier then
                N.UI.HideDossier()
            end
        end,
        default = true,
    })

    panel:AddSetting({
        type = L.ST_CHECKBOX,
        label = "Show Banners",
        tooltip = "Show center-screen Nemesis / Vengeance announcements.",
        getFunction = function() return SV.banners end,
        setFunction = function(value) SV.banners = value end,
        default = true,
    })

    panel:AddSetting({
        type = L.ST_CHECKBOX,
        label = "Play Sounds",
        tooltip = "Play a sound with Nemesis banners.",
        getFunction = function() return SV.sounds end,
        setFunction = function(value) SV.sounds = value end,
        default = true,
    })

    panel:AddSetting({
        type = L.ST_CHECKBOX,
        label = "Group Build Sharing",
        tooltip = "Share and receive bar/CP/set data with grouped Nemesis users.",
        getFunction = function() return SV.scrim end,
        setFunction = function(value)
            SV.scrim = value
            N.Msg("Build sharing changed. /reloadui to apply.")
        end,
        default = true,
    })

    -- Dossier position & scale
    panel:AddSetting({ type = L.ST_SECTION, label = "Dossier Position & Scale" })

    panel:AddSetting({
        type = L.ST_SLIDER,
        label = "Horizontal Position",
        tooltip = "Offset from screen center. Positive = right, negative = left.",
        min = -1500,
        max = 1500,
        step = 10,
        format = "%d",
        unit = " px",
        getFunction = function() return SV.dossierX end,
        setFunction = function(value)
            SV.dossierX = value
            if N.UI and N.UI.ApplyPositionAndScale then N.UI.ApplyPositionAndScale() end
        end,
        default = 230,
    })

    panel:AddSetting({
        type = L.ST_SLIDER,
        label = "Vertical Position",
        tooltip = "Offset from screen center. Positive = down, negative = up.",
        min = -1000,
        max = 1000,
        step = 10,
        format = "%d",
        unit = " px",
        getFunction = function() return SV.dossierY end,
        setFunction = function(value)
            SV.dossierY = value
            if N.UI and N.UI.ApplyPositionAndScale then N.UI.ApplyPositionAndScale() end
        end,
        default = 20,
    })

    panel:AddSetting({
        type = L.ST_SLIDER,
        label = "Dossier Scale",
        tooltip = "Resize the whole dossier popup.",
        min = 0.50,
        max = 2.00,
        step = 0.05,
        format = "%.2f",
        unit = "x",
        getFunction = function() return SV.dossierScale end,
        setFunction = function(value)
            SV.dossierScale = value
            if N.UI and N.UI.ApplyPositionAndScale then N.UI.ApplyPositionAndScale() end
        end,
        default = 1.0,
    })

    panel:AddSetting({
        type = L.ST_BUTTON,
        label = "Reset Dossier Position",
        buttonText = "Reset",
        tooltip = "Reset position and scale to default.",
        clickHandler = function()
            if N.UI and N.UI.ResetPosition then N.UI.ResetPosition() end
        end,
    })

    -- Dossier feature toggles
    panel:AddSetting({ type = L.ST_SECTION, label = "Dossier Features" })

    AddCheckbox(panel, "Show Class / Race / CP / Rank", "Show the info line under the player name.", "showDossierInfo")
    AddCheckbox(panel, "Show Live HP", "Show the target's current health percentage.", "showDossierHP")
    AddCheckbox(panel, "Show K/D Record", "Show your kill/death record against this player.", "showDossierKD")
    AddCheckbox(panel, "Show Win Chance", "Show the estimated win chance percentage.", "showDossierWin")
    AddCheckbox(panel, "Show Known Moves", "Show the enemy's most-used abilities.", "showDossierMoves")
    AddCheckbox(panel, "Show Detected Sets", "Show proc sets detected from combat.", "showDossierSets")
    AddCheckbox(panel, "Show Footer", "Show the 'Seen ...' / streak / location footer.", "showDossierFooter")
end
