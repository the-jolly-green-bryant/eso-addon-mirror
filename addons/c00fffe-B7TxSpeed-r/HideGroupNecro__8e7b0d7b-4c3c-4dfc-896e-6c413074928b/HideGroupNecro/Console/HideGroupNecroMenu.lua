local HG = HideGroupNecro
local LHAS = LibHarvensAddonSettings

-- Menu
function HG.loadMenu()
    local panel = LHAS:AddAddon(HG.label, {
        allowDefaults = true,
        allowRefresh = true
    })
    -- Enable toggle
    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = GetString(HG_MENU_ENABLED),
        tooltip = "Enable HideGroupNecro",
        getFunction = function() return HG.savedVariables.HideState end,
        setFunction = function(value) HG.hideMembers(value) end,
        default = false
    })
    -- Debug toggle
    panel:AddSetting({
        type = LibHarvensAddonSettings.ST_CHECKBOX,
        label = GetString(HG_MENU_DEBUG),
        tooltip = "Display debug messages",
        getFunction = function() return HG.savedVariables.Debug end,
        setFunction = function(value) HG.savedVariables.Debug = value end,
        default = false
    })
end
