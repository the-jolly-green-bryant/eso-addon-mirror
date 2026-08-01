-- Addon Settings Menu File
local LAM = LibAddonMenu2

function TamrielAmbulance.InitializeLAM()
    -- LibAddonMenu-2.0 Setup
    local saveData = TamrielAmbulance.savedVariables

    -- Test if addon is launched for first time for each value picked by user
    if saveData.showOnlyInGroup == nil then
        saveData.showOnlyInGroup = false
    end
    if saveData.resetOnGroupJoined == nil then
        saveData.resetOnGroupJoined = false
    end
    if saveData.displayByPlayer == nil then
        saveData.displayByPlayer = false
    end
    if saveData.selectedFontSize == nil then
        saveData.selectedFontSize = "Medium"
    end
    if saveData.maximumPlayerDisplayCount == nil then
        saveData.maximumPlayerDisplayCount = 12
    end

    local settingsPanel
    local settingsPanelName = TamrielAmbulance.name .. "SettingsPanel"
    local settingsPanelData = {
        type = "panel",
        name = TamrielAmbulance.prettyName,
        author = TamrielAmbulance.author,
        version = TamrielAmbulance.version,
        website = TamrielAmbulance.website
    }

    local settingsOptionsData = {{
        type = "header",
        name = "general"
    }, {
        type = "checkbox",
        name = "Show only when you are in a group",
        tooltip = "Enable this option to display resurrections count only if you are in a group",
        getFunc = function()
            return saveData.showOnlyInGroup
        end,
        setFunc = function(value)
            saveData.showOnlyInGroup = value
            TamrielAmbulance.UpdateDisplayCondition()
        end
    }, {
        type = "checkbox",
        name = "Reset the counter when joining a group",
        tooltip = "Enable this option to reset the counter whenever you join a group",
        getFunc = function()
            return saveData.resetOnGroupJoined
        end,
        setFunc = function(value)
            saveData.resetOnGroupJoined = value
        end
    }, {
        type = "checkbox",
        name = "Display resurrections count by player",
        tooltip = "Enable this option to display resurrections count as a list for each player instead of just one common number",
        getFunc = function()
            return saveData.displayByPlayer
        end,
        setFunc = function(value)
            saveData.displayByPlayer = value
            TamrielAmbulance.UpdateWindow()
        end
    }, {
        type = "dropdown",
        name = "Font Size",
        tooltip = "The size of the displayed text",
        choices = {"Large", "Medium", "Small"},
        getFunc = function()
            return saveData.selectedFontSize
        end,
        setFunc = function(value)
            saveData.selectedFontSize = value
            TamrielAmbulance.UpdateFontSize()
        end
    }, {
        type = "slider",
        name = "Maximum displayed player in list mode",
        tooltip = "The maximum lines that can be displayed.",
        min = 4,
        max = 32,
        getFunc = function()
            return saveData.maximumPlayerDisplayCount
        end,
        setFunc = function(value)
            saveData.maximumPlayerDisplayCount = value
            TamrielAmbulance.UpdateWindow()
        end
    }}

    settingsPanel = LAM:RegisterAddonPanel(settingsPanelName, settingsPanelData)
    LAM:RegisterOptionControls(settingsPanelName, settingsOptionsData)
end
