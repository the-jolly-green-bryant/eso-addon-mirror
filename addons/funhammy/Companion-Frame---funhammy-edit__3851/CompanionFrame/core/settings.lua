CF.LAM = _G.LibAddonMenu2
local panel = {
    type = "panel",
    name = "Companion Frame",
    displayName = "Companion Frame",
    author = "Flat Badger",
    version = "1.12.0"
}

local fonts = {}
for key, _ in pairs(CF.Drawing.Fonts) do
    table.insert(fonts, key)
end

table.sort(fonts)

local options = {
    [1] = {
        type = "header",
        name = GetString(_G.SI_KEYBINDINGS_LAYER_GENERAL),
        width = "full"
    },
    [2] = {
        type = "checkbox",
        name = GetString(COMPANIONFRAME_SHOWDISMISS),
        getFunc = function()
            return CF.Vars.ShowDismiss
        end,
        setFunc = function(value)
            CF.Vars.ShowDismiss = value
            CF.CompanionFrame.Dismiss:SetHidden(not value)
            CF.CompanionFrame.Toggle:SetHidden(not value)
        end,
        width = "full",
        default = CF.Defaults.ShowDismiss
    },
    [3] = {
        type = "checkbox",
        name = GetString(COMPANIONFRAME_HIDEWHENGROUPED),
        tooltip = GetString(COMPANIONFRAME_HIDEWHENGROUPEDTOOLTIP),
        getFunc = function()
            return CF.Vars.HideWhenGrouped
        end,
        setFunc = function(value)
            CF.Vars.HideWhenGrouped = value
        end,
        width = "full",
        requiresReload = true,
        default = CF.Defaults.HideWhenGrouped
    },
    [4] = {
        type = "checkbox",
        name = GetString(COMPANIONFRAME_SHOWLEVEL),
        getFunc = function()
            return CF.Vars.ShowLevel
        end,
        setFunc = function(value)
            CF.Vars.ShowLevel = value
            CF.UpdateCompanionNameAndLevel()
        end,
        width = "full",
        default = CF.Defaults.ShowLevel
    },
    [5] = {
        type = "checkbox",
        name = GetString(COMPANIONFRAME_SHOWNAME),
        getFunc = function()
            return CF.Vars.ShowName
        end,
        setFunc = function(value)
            CF.Vars.ShowName = value
            CF.UpdateCompanionNameAndLevel()
        end,
        width = "full",
        default = CF.Defaults.ShowName
    },
    [6] = {
        type = "dropdown",
        name = GetString(COMPANIONFRAME_FONTNAME),
        choices = fonts,
        getFunc = function()
            return CF.Vars.FrameFont
        end,
        setFunc = function(value)
            CF.Vars.FrameFont = value
        end,
        width = "full",
        requiresReload = true,
        default = CF.Defaults.FrameFont
    },
    [7] = {
        type = "slider",
        name = GetString(COMPANIONFRAME_FONTSIZE),
        min = 8,
        max = 24,
        step = 1,
        getFunc = function()
            return CF.Vars.FrameFontSize
        end,
        setFunc = function(value)
            CF.Vars.FrameFontSize = value
        end,
        width = "full",
        requiresReload = true,
        default = CF.Defaults.FrameFontSize
    },
    [8] = {
        type = "colorpicker",
        name = GetString(COMPANIONFRAME_FONTCOLOUR),
        getFunc = function()
            return unpack(CF.Vars.FrameFontColour)
        end,
        setFunc = function(r, g, b, a)
            CF.Vars.FrameFontColour = {r, g, b, a}
        end,
        width = "full",
        requiresReload = true,
        default = unpack(CF.Defaults.FrameFontColour)
    },
    [9] = {
        type = "slider",
        name = GetString(COMPANIONFRAME_UNITFRAMEWIDTH),
        min = 100,
        max = 500,
        step = 25,
        getFunc = function()
            return CF.Vars.FrameWidth
        end,
        setFunc = function(value)
            CF.Vars.FrameWidth = value
        end,
        width = "full",
        requiresReload = true,
        default = CF.Defaults.FrameWidth
    },
    [10] = {
        type = "slider",
        name = GetString(COMPANIONFRAME_UNITFRAMEHEIGHT),
        min = 60,
        max = 240,
        step = 15,
        getFunc = function()
            return CF.Vars.FrameHeight
        end,
        setFunc = function(value)
            CF.Vars.FrameHeight = value
        end,
        width = "full",
        requiresReload = true,
        default = CF.Defaults.FrameHeight
    },
    [11] = {
        type = "checkbox",
        name = GetString(COMPANIONFRAME_RESUMMON),
        tooltip = GetString(COMPANIONFRAME_RESUMMONTOOLTIP),
        getFunc = function()
            return CF.Vars.Resummon
        end,
        setFunc = function(value)
            CF.Vars.Resummon = value
        end,
        width = "full",
        default = CF.Defaults.Resummon
    },
    [12] = {
        type = "checkbox",
        name = GetString(COMPANIONFRAME_LOCKPOSITION),
        getFunc = function()
            return CF.Vars.LockPosition
        end,
        setFunc = function(value)
            CF.Vars.LockPosition = value
            CF.CompanionFrame:SetMovable(not value)
            CF.SetLockState(CF.CompanionFrame, value)
        end,
        width = "full",
        default = CF.Defaults.LockPosition
    },
    [13] = {
        type = "header",
        name = GetString(COMPANIONFRAME_SUMMONING),
        width = "full"
    },
    [14] = {
        type = "checkbox",
        name = GetString(COMPANIONFRAME_SHOWSUMMONING),
        getFunc = function()
            return CF.Vars.Summoning
        end,
        setFunc = function(value)
            CF.Vars.Summoning = value
        end,
        width = "full",
        default = CF.Defaults.Summoning
    },
    [15] = {
        type = "colorpicker",
        name = GetString(COMPANIONFRAME_SUMMONINGCOLOUR),
        getFunc = function()
            return unpack(CF.Vars.SummoningColour)
        end,
        setFunc = function(r, g, b, a)
            CF.Vars.SummoningColour = {r, g, b, a}
            CF.SummoningFrame.Message:SetColor(r, g, b, a)
        end,
        width = "full",
        default = unpack(CF.Defaults.SummoningColour)
    },
    [16] = {
        type = "header",
        name = GetString(COMPANIONFRAME_COMPANIONBUTTONS),
        width = "full"
    },
    [17] = {
        type = "checkbox",
        name = GetString(COMPANIONFRAME_SHOWCOMPANIONBUTTONS),
        getFunc = function()
            return CF.Vars.ShowButtons
        end,
        setFunc = function(value)
            CF.Vars.ShowButtons = value
            CF.ButtonFrame.Fragment:SetHiddenForReason("disabled", not CF.Vars.ShowButtons)
        end,
        width = "full",
        default = CF.Defaults.ShowButtons
    },
    [18] = {
        type = "checkbox",
        name = GetString(COMPANIONFRAME_LOCKCOMPANIONBUTTONS),
        getFunc = function()
            return CF.Vars.ButtonLockPosition
        end,
        setFunc = function(value)
            CF.Vars.ButtonLockPosition = value
            CF.SetLockState(CF.ButtonFrame, value)
        end
    },
    [19] = {
        type = "header",
        name = GetString(_G.SI_ATTRIBUTES1),
        width = "full"
    },
    [20] = {
        type = "colorpicker",
        name = GetString(COMPANIONFRAME_HEALTHBARCOLOUR),
        getFunc = function()
            return unpack(CF.Vars.FrameHealthColour)
        end,
        setFunc = function(r, g, b, _)
            CF.Vars.FrameHealthColour = {r, g, b}
            CF.CompanionFrame.Health.Background:SetCenterColor(r / 5, g / 5, b / 5, 0.6)
            CF.CompanionFrame.Health.Bar:SetColor(r, g, b, 0.6)
        end,
        width = "full",
        default = unpack(CF.Defaults.FrameHealthColour)
    },
    [21] = {
        type = "header",
        name = GetString(_G.SI_COMPANION_OVERVIEW_RAPPORT),
        width = "full"
    },
    [22] = {
        type = "checkbox",
        name = GetString(COMPANIONFRAME_SHOWRAPPORT),
        getFunc = function()
            return CF.Vars.ShowRapport
        end,
        setFunc = function(value)
            CF.Vars.ShowRapport = value
            CF.AdjustAnchors()
        end,
        width = "full",
        default = CF.Defaults.ShowRapport
    },
    [23] = {
        type = "checkbox",
        name = GetString(COMPANIONFRAME_SHOWRAPPORTICON),
        getFunc = function()
            return CF.Vars.ShowRapportIcon
        end,
        setFunc = function(value)
            CF.Vars.ShowRapportIcon = value
            CF.CompanionFrame.Rapport.Icon:SetHidden(not value)
        end,
        width = "full",
        default = CF.Defaults.ShowRapportIcon
    },
    [24] = {
        type = "colorpicker",
        name = GetString(COMPANIONFRAME_RAPPORTLIKE),
        tooltip = GetString(COMPANIONFRAME_RAPPORTTOOLTIP),
        getFunc = function()
            return unpack(CF.Vars.RapportLikeColour)
        end,
        setFunc = function(r, g, b, _)
            CF.Vars.RapportLikeColour = {r, g, b}
            CF.OnCompanionRapportUpdate()
        end,
        width = "full",
        default = unpack(CF.Defaults.RapportLikeColour)
    },
    [25] = {
        type = "colorpicker",
        name = GetString(COMPANIONFRAME_RAPPORTMODERATE),
        tooltip = GetString(COMPANIONFRAME_RAPPORTTOOLTIP),
        getFunc = function()
            return unpack(CF.Vars.RapportModerateColour)
        end,
        setFunc = function(r, g, b, _)
            CF.Vars.RapportModerateColour = {r, g, b}
            CF.OnCompanionRapportUpdate()
        end,
        width = "full",
        default = unpack(CF.Defaults.RapportModerateColour)
    },
    [26] = {
        type = "colorpicker",
        name = GetString(COMPANIONFRAME_RAPPORTDISLIKE),
        tooltip = GetString(COMPANIONFRAME_RAPPORTTOOLTIP),
        getFunc = function()
            return unpack(CF.Vars.RapportDislikeColour)
        end,
        setFunc = function(r, g, b, _)
            CF.Vars.RapportDislikeColour = {r, g, b}
            CF.OnCompanionRapportUpdate()
        end,
        width = "full",
        default = unpack(CF.Defaults.RapportDislikeColour)
    },
    [27] = {
        type = "header",
        name = GetString(_G.SI_REWARDS_EXPERIENCE),
        width = "full"
    },
    [28] = {
        type = "checkbox",
        name = GetString(COMPANIONFRAME_SHOWEXPERIENCE),
        getFunc = function()
            return CF.Vars.ShowExperience
        end,
        setFunc = function(value)
            CF.Vars.ShowExperience = value
            CF.AdjustAnchors()
        end,
        width = "full",
        default = CF.Defaults.ShowExperience
    },
    [29] = {
        type = "colorpicker",
        name = GetString(COMPANIONFRAME_EXPERIENCEBARCOLOUR),
        getFunc = function()
            return unpack(CF.Vars.FrameExperienceColour)
        end,
        setFunc = function(r, g, b, _)
            CF.Vars.FrameExperienceColour = {r, g, b}
            CF.CompanionFrame.Experience.Background:SetCenterColor(r / 5, g / 5, b / 5, 0.6)
            CF.CompanionFrame.Experience.Bar:SetColor(r, g, b, 0.6)
        end,
        width = "full",
        default = unpack(CF.Defaults.FrameExperienceColour)
    },
    [30] = {
        type = "header",
        name = "",
        wdith = "full"
    },
    [31] = {
        type = "button",
        name = GetString(_G.SI_INTERFACE_OPTIONS_RESET_TO_DEFAULT_TOOLTIP),
        func = function()
            for key, value in pairs(CF.Defaults) do
                CF.Vars[key] = value
            end
            ReloadUI()
        end,
        warning = GetString(COMPANIONFRAME_RELOAD),
        requiresReload = true
    }
}

function CF.RegisterSettings()
    CF.LAM:RegisterAddonPanel("CompanionFrameOptionsPanel", panel)
    CF.LAM:RegisterOptionControls("CompanionFrameOptionsPanel", options)
end
