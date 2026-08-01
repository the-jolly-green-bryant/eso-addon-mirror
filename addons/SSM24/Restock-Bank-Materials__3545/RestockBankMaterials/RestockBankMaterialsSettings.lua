RestockBankMaterials = RestockBankMaterials or {}

RestockBankMaterials.defaults = {
    enabled = true,
    allowNonMaterials = false,
    autoOpenMaterials = true,
    restockBankKeybind = "UI_SHORTCUT_QUATERNARY"
}

local panelName = "RestockBankMaterials_Settings"
local LAM = LibAddonMenu2

function RestockBankMaterials.InitSettings()
    local saveData = RestockBankMaterials.savedVars
    local strings = RestockBankMaterials.strings.settings
    local panelData = {
        type = "panel",
        name = strings.name,
        displayName = strings.displayName,
        author = "SSM24",
        version = "1.0.1",
        slashCommand = "/rbm"
    }
    
    local optionsTable = {
        {
            type = "checkbox",
            name = strings.enabled.name,
            getFunc = function() return saveData.enabled end,
            setFunc = function(val) saveData.enabled = val end
        },
        {
            type = "header",
            name = strings.settingsHeader.name
        },
        {
            type = "checkbox",
            name = strings.allowNonMaterials.name,
            tooltip = strings.allowNonMaterials.tooltip,
            getFunc = function() return saveData.allowNonMaterials end,
            setFunc = function(val) saveData.allowNonMaterials = val end
        },
        {
            type = "checkbox",
            name = strings.autoOpenMaterials.name,
            tooltip = strings.autoOpenMaterials.tooltip,
            getFunc = function() return saveData.autoOpenMaterials end,
            setFunc = function(val) saveData.autoOpenMaterials = val end
        },
        {
            type = "dropdown",
            name = strings.restockBankKeybind.name,
            tooltip = strings.restockBankKeybind.tooltip,
            choices = {
                GetString(SI_BINDING_NAME_UI_SHORTCUT_QUATERNARY),
                strings.restockBankKeybind.choices.custom
            },
            choicesValues = {
                "UI_SHORTCUT_QUATERNARY",
                "RBM_RESTOCK_BANK"
            },
            getFunc = function() return saveData.restockBankKeybind end,
            setFunc = function(val)
                saveData.restockBankKeybind = val
                if (RestockBankMaterials.buttonGroup) then
                    RestockBankMaterials.buttonGroup[1].keybind = val
                end
            end
        }
    }

    LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, optionsTable)

    RestockBankMaterials.buttonGroup[1].keybind = saveData.restockBankKeybind
end