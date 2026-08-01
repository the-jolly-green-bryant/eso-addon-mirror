local HG = HideGroupNecro
local LAM = LibAddonMenu2

--- Menu
function HG.loadMenu()
    local panelData = {
        type = "panel",
        name = HG.label,
        author = HG.author,
        version = HG.version,
    }
    local panel = LAM:RegisterAddonPanel(HG.name.."Menu", panelData)

    local optionsData = {
        {
            type = "header",
            name = function() return GetString(HG_MENU_GLOBAL_SETTINGS) end,
        },
        {
            reference = "HideGroupEnabled",
            type = "checkbox",
            name = function()
                return string.format(HG.savedVariables.HideState and "|c00FF00%s|r" or "|cFF0000%s|r", GetString(HG_MENU_ENABLED))
            end,
            default = false,
            getFunc = function()
                return HG.savedVariables.HideState
            end,
            setFunc = function(value)
                HG.hideMembers(value)
                HideGroupEnabled.label:SetText(string.format(HG.savedVariables.HideState and "|c00FF00%s|r" or "|cFF0000%s|r", GetString(HG_MENU_ENABLED)))
            end,
            width = "half",
        },
        {
            reference = "DebugEnabled",
            type = "checkbox",
            name = function() return GetString(HG_MENU_DEBUG) end,
            default = false,
            getFunc = function() return HG.savedVariables.Debug end,
            setFunc = function(value) HG.savedVariables.Debug = value end,
            width = "half",
        },
        {
            type = "header",
            name = function() return GetString(HG_MENU_OPTIONAL_SETTINGS) end,
        },
        {
            type = "checkbox",
            name = function() return GetString(HG_MENU_HIDE_NAMEPLATES) end,
            getFunc = function() return HG.savedVariables.HideNameplates end,
            setFunc = function(value)
                HG.savedVariables.HideNameplates = value
                if HG.savedVariables.HideState then SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_NAMEPLATES, HG.nameplateChoice(value)) end
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = function() return GetString(HG_MENU_HIDE_HEALTHBARS) end,
            getFunc = function() return HG.savedVariables.HideHealthBars end,
            setFunc = function(value)
                HG.savedVariables.HideHealthBars = value
                if HG.savedVariables.HideState then SetSetting(SETTING_TYPE_NAMEPLATES, NAMEPLATE_TYPE_GROUP_MEMBER_HEALTHBARS, HG.nameplateChoice(value)) end
            end,
            width = "half",
        },
    }
    LAM:RegisterOptionControls(HG.name.."Menu", optionsData)
end
