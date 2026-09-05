local owa = OWAssistant

local function L(key)
    return owa.GetString(key)
end

local function DevelopmentCheckbox(name, warning, displayedValue)
    return {
        type = "checkbox",
        name = name,
        getFunc = function()
            return displayedValue == true
        end,
        setFunc = function()
        end,
        default = displayedValue == true,
        disabled = true,
        warning = warning,
    }
end

function owa.CreateSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        d("[OWA] LibAddonMenu-2.0 not found.")
        return
    end

    local panelId = "OWAssistantSettings"
    local languageChoices, languageValues =
        owa.GetLanguageChoices()

    local panelData = {
        type = "panel",
        name = L("ADDON_NAME"),
        displayName = L("ADDON_NAME"),
        author = "@Invs",
        version = owa.version,
    }

    local options = {
        {
            type = "dropdown",
            name = L("LANGUAGE"),
            choices = languageChoices,
            choicesValues = languageValues,
            getFunc = function()
                return owa.GetLanguageCode()
            end,
            setFunc = function(value)
                owa.savedVariables.language = value
            end,
            default = owa.GetLanguageCode(),
            requiresReload = true,
            warning = L("RELOAD_UI_WARNING"),
        },
        DevelopmentCheckbox(
            L("ACCOUNT_WIDE"),
            L("ACCOUNT_WIDE_IN_DEVELOPMENT"),
            true
        ),
        DevelopmentCheckbox(
            L("BANKING"),
            L("MODULE_IN_DEVELOPMENT"),
            false
        ),
        {
            type = "checkbox",
            name = L("DECONSTRUCT"),
            getFunc = function()
                return owa.savedVariables.deconstructEnabled
            end,
            setFunc = function(value)
                owa.savedVariables.deconstructEnabled = value
            end,
            default = true,
            requiresReload = true,
            warning = L("RELOAD_UI_WARNING"),
        },
        DevelopmentCheckbox(
            L("MERCHANT"),
            L("MODULE_IN_DEVELOPMENT"),
            false
        ),
        {
            type = "checkbox",
            name = L("REPAIR"),
            tooltip = L("REPAIR_TOOLTIP"),
            getFunc = function()
                return owa.savedVariables.repairEnabled
            end,
            setFunc = function(value)
                owa.savedVariables.repairEnabled = value
            end,
            default = false,
            requiresReload = true,
            warning = L("RELOAD_UI_WARNING"),
        },
    }

    LAM:RegisterAddonPanel(panelId, panelData)
    LAM:RegisterOptionControls(panelId, options)
end
