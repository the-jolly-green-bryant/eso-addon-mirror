Cruxweaver = Cruxweaver or {}
Cruxweaver.Name = "Cruxweaver"
Cruxweaver.Version = "1.0.2"

local defaults = {
    ShowHighlight = true,
}

function Cruxweaver.InitSavedVariables()
    Cruxweaver.SavedVariables = ZO_SavedVars:NewAccountWide("CruxweaverVars", 1, GetWorldName(), defaults)
end

function Cruxweaver.InitSettings()
    local panelName = "CruxweaverSettingsPanel"
     
    local panelData = {
        type = "panel",
        name = Cruxweaver.Name,
        displayName = Cruxweaver.Name,
        version = string.format('|c00FF00%s|r', Cruxweaver.Version),
        author = "|cFFD700@helixanon|r",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    local optionsData = {
        {
            type = "checkbox",
            name = "Show highlight",
            getFunc = function() return Cruxweaver.SavedVariables.ShowHighlight end,
            setFunc = function(value) Cruxweaver.SavedVariables.ShowHighlight = value end,
        },
    }
    LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
    LibAddonMenu2:RegisterOptionControls(panelName, optionsData)
end
