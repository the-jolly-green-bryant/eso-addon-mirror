local LAM = LibAddonMenu2
AlchemyOpener = AlchemyOpener or {}
AlchemyOpenerSettings = AlchemyOpenerSettings or {}
local function AlchemyOpenerSettings_Initialize()
    local panelData = {
        type = "panel",
        name = "AlchemyOpener",
        displayName = "AlchemyOpener Settings",
        author = "Awh_Lina",
        version = AlchemyOpener.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }
    AlchemyOpenerSettings.settingsPanel = LAM:RegisterAddonPanel("AlchemyOpenerSettingsPanel", panelData)
    AlchemyOpener.db = ZO_SavedVars:New("AlchemyOpenerSettings", 1, nil, AlchemyOpener.defaults_db)
    local optionsData = {
        {
            type = "checkbox",
            name = "Enabled",
            tooltip = "Enable the Auto Opener?",
            getFunc = function ()
                return true
            end,
            setFunc = function(value)
                AlchemyOpener.db.enabled = value
            end,
            warning = "Will need to reload the UI."
        }
    }

    LAM:RegisterOptionControls("AlchemyOpenerSettingsPanel", optionsData)
    -- Refresh appearance on settings initialization
end
EVENT_MANAGER:RegisterForEvent("AlchemyOpenerSettings", EVENT_ADD_ON_LOADED, function(eventCode, addOnName)
    if addOnName == AlchemyOpener.name then
    if AlchemyOpener.isLoaded then
        AlchemyOpenerSettings_Initialize()
    end
    end
end)
