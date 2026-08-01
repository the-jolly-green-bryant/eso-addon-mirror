if ESOAssistant == nil or ESOAssistant.internal == nil then
    assert(false,
        "Error on zone module startup: Main module missing!")
end
---@type table
local egint = ESOAssistant.internal
local logger = egint.logger

function egint.InitMenu()
    local LibHarvensAddonSettings = LibHarvensAddonSettings

    local options = {
        allowDefaults = false,
        allowRefresh = true,
        defaultsFunction = function() end,
    }

    local settings = LibHarvensAddonSettings:AddAddon(ESOAssistant.addonName, options)
    if not settings then
        return
    end

    local saveData = egint.sv

    settings:AddSetting(
        {
            type = LibHarvensAddonSettings.ST_CHECKBOX,
            label = GetString(SI_ESOASSISTANT_MENU_SHOW_QR),
            tooltip = GetString(SI_ESOASSISTANT_MENU_SHOW_QR_TT),
            default = saveData.showQR,
            setFunction = function(state) --this function is called when the setting is changed
                saveData.showQR = state
            end,
            getFunction = function() --this function is called to set initial state of the checkbox
                return saveData.showQR
            end,
        }
    )

    settings:AddSetting(
        {
            type = LibHarvensAddonSettings.ST_CHECKBOX,
            label = GetString(SI_ESOASSISTANT_MENU_OPEN_LINK),
            tooltip = GetString(SI_ESOASSISTANT_MENU_OPEN_LINK_TT),
            default = saveData.openLink,
            setFunction = function(state) --this function is called when the setting is changed
                saveData.openLink = state
            end,
            getFunction = function() --this function is called to set initial state of the checkbox
                return saveData.openLink
            end,
        }
    )
end
