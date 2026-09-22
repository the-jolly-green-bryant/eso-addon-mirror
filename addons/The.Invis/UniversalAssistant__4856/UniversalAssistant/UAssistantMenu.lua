local ua = UAssistant

local function L(key)
    return ua.GetString(key)
end

function ua.CreateSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        d("|cFFFFFF[|r|c3A92FFU|r|cFFFF00A|r|cFFFFFF]|r LibAddonMenu-2.0 not found.")
        return
    end

    local panelId = "UAssistantSettings"
    local languageChoices, languageValues = ua.GetLanguageChoices()

    local panelData = {
        type = "panel",
        name = L("ADDON_NAME"),
        displayName = L("ADDON_NAME"),
        author = "@The.Invis",
        version = ua.version,
        registerForRefresh = true,
        registerForDefaults = true,
        resetFunc = function()
            ua.ResetAllSettings()
        end,
    }

    local options = {
        {
            type = "checkbox",
            name = L("SHOW_WELCOME"),
            tooltip = L("SHOW_WELCOME_TOOLTIP"),
            getFunc = function()
                return ua.profileStorage.showWelcome
            end,
            setFunc = function(value)
                ua.profileStorage.showWelcome = value
            end,
            default = false,
        },
        { type = "divider" },
        {
            type = "dropdown",
            name = L("LANGUAGE"),
            choices = languageChoices,
            choicesValues = languageValues,
            getFunc = function()
                return ua.GetLanguageCode()
            end,
            setFunc = function(value)
                ua.profileStorage.language = value
            end,
            default = ua.Localization.defaultLanguage,
            requiresReload = true,
        },
        { type = "divider" },
        ua.Profiles.CreateMenuControl(),
        { type = "divider" },
        {
            type = "checkbox",
            name = L("BANKING"),
            tooltip = L("BANKING_TOOLTIP"),
            getFunc = function()
                return ua.savedVariables.bankingEnabled
            end,
            setFunc = function(value)
                ua.savedVariables.bankingEnabled = value
            end,
            default = false,
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = L("DECONSTRUCT"),
            tooltip = L("DECONSTRUCT_TOOLTIP"),
            getFunc = function()
                return ua.savedVariables.deconstructEnabled
            end,
            setFunc = function(value)
                ua.savedVariables.deconstructEnabled = value
            end,
            default = false,
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = L("MERCHANT"),
            tooltip = L("MERCHANT_TOOLTIP"),
            getFunc = function()
                return ua.savedVariables.merchantEnabled
            end,
            setFunc = function(value)
                ua.savedVariables.merchantEnabled = value
            end,
            default = false,
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = L("REPAIR"),
            tooltip = L("REPAIR_TOOLTIP"),
            getFunc = function()
                return ua.savedVariables.repairEnabled
            end,
            setFunc = function(value)
                ua.savedVariables.repairEnabled = value
            end,
            default = false,
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = L("UNDAUNTED_PLEDGES"),
            tooltip = L("UNDAUNTED_PLEDGES_TOOLTIP"),
            getFunc = function()
                return ua.savedVariables.undauntedPledgesEnabled
            end,
            setFunc = function(value)
                ua.savedVariables.undauntedPledgesEnabled = value
            end,
            default = false,
            requiresReload = true,
        },
    }

    LAM:RegisterAddonPanel(panelId, panelData)
    LAM:RegisterOptionControls(panelId, options)
end
