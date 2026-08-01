FineClubIcons = FineClubIcons or {}
local LAM = LibAddonMenu2

--- Menu
function FineClubIcons.loadMenu()
    local panelData = {
        type = "panel",
        name = FineClubIcons.name,
        author = FineClubIcons.author,
        version = FineClubIcons.version,
    }
    local panel = LAM:RegisterAddonPanel(FineClubIcons.name .. "Menu", panelData)

    local optionsData = {
        {
            type = "header",
            name = function() return GetString(FCI_MENU_GLOBAL_SETTINGS) end,
        },
        {
            reference = "FineClubIconsDebugEnabled",
            type = "checkbox",
            name = function()
                return string.format(FineClubIcons.savedVariables.debug and "|c00FF00%s|r" or "|cFF0000%s|r", GetString(FCI_MENU_DEBUG))
            end,
            default = false,
            getFunc = function()
                return FineClubIcons.savedVariables.debug
            end,
            setFunc = function(value)
                FineClubIcons.savedVariables.debug = value
                FineClubIconsDebugEnabled.label:SetText(string.format(FineClubIcons.savedVariables.debug and "|c00FF00%s|r" or "|cFF0000%s|r", GetString(FCI_MENU_DEBUG)))
            end,
        },
        {
            type = "header",
            name = function() return GetString(FCI_MENU_KA) end,
        },
        {
            type = "checkbox",
            name = function() return GetString(FCI_MENU_KA_FALGRAVN_1ST_FLOOR) end,
            getFunc = function() return FineClubIcons.savedVariables.kynesaegis.showFalgravn1stFloorIcons end,
            setFunc = function(value)
                FineClubIcons.savedVariables.kynesaegis.showFalgravn1stFloorIcons = value
                FineClubIcons.OnPlayerActivated()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = function() return GetString(FCI_MENU_KA_FALGRAVN_2ND_FLOOR) end,
            getFunc = function() return FineClubIcons.savedVariables.kynesaegis.showFalgravn2ndFloorIcons end,
            setFunc = function(value)
                FineClubIcons.savedVariables.kynesaegis.showFalgravn2ndFloorIcons = value
                FineClubIcons.OnPlayerActivated()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = function() return GetString(FCI_MENU_KA_FALGRAVN_LIGHTNING) end,
            getFunc = function() return FineClubIcons.savedVariables.kynesaegis.showFalgravnLightningPos end,
            setFunc = function(value)
                FineClubIcons.savedVariables.kynesaegis.showFalgravnLightningPos = value
                FineClubIcons.OnPlayerActivated()
            end,
            width = "full",
        },
        {
            type = "slider",
            name = function() return GetString(FCI_MENU_KA_FALGRAVN_ICON_SIZE) end,
            min = 20,
            max = 300,
            step = 10,
            default = 150,
            width = full,
            getFunc = function() return FineClubIcons.savedVariables.kynesaegis.falgravnIconsSize end,
            setFunc = function(value)
                FineClubIcons.savedVariables.kynesaegis.falgravnIconsSize = value
                FineClubIcons.OnPlayerActivated()
            end,
        },
    }
    LAM:RegisterOptionControls(FineClubIcons.name.."Menu", optionsData)
end
