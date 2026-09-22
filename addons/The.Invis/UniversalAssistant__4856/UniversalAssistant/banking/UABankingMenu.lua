local ua = UAssistant
local banking = ua.Banking
local currencies = banking.Currencies

local function L(key)
    return ua.GetString("BANKING_" .. key)
end

local MAX_CURRENCY_VALUE = 2147483647

local function RefreshControl(reference)
    local control = _G[reference]

    if control and control.UpdateValue then
        control:UpdateValue()
    end
end

local function SetMinimum(profile, value)
    local amount = zo_clamp(zo_floor(tonumber(value) or profile.minimum), 0, MAX_CURRENCY_VALUE)

    profile.minimum = amount

    if profile.maximum < amount then
        profile.maximum = amount
    end
end

local function SetMaximum(profile, value)
    local amount = zo_clamp(zo_floor(tonumber(value) or profile.maximum), 0, MAX_CURRENCY_VALUE)

    profile.maximum = amount

    if profile.minimum > amount then
        profile.minimum = amount
    end
end

local function CreateCurrencyControls(definition, profile, defaults)
    local currencyName = currencies.GetDisplayName(definition.currencyType)
    local referencePrefix = "UABanking" .. definition.key
    local minimumReference = referencePrefix .. "Minimum"
    local maximumReference = referencePrefix .. "Maximum"

    return {
        {
            type = "checkbox",
            name = L("ENABLE_TRANSFER"),
            tooltip = string.format(L("ENABLE_TRANSFER_TOOLTIP"), currencyName),
            getFunc = function()
                return profile.enabled
            end,
            setFunc = function(value)
                profile.enabled = value
                RefreshControl(minimumReference)
                RefreshControl(maximumReference)
            end,
            default = defaults.enabled,
        },
        {
            type = "editbox",
            name = L("MINIMUM_TO_KEEP"),
            tooltip = string.format(L("MINIMUM_TO_KEEP_TOOLTIP"), currencyName),
            width = "half",
            maxChars = 10,
            textType = TEXT_TYPE_NUMERIC,
            getFunc = function()
                return tostring(profile.minimum)
            end,
            setFunc = function(value)
                SetMinimum(profile, value)
                RefreshControl(maximumReference)
            end,
            default = tostring(defaults.minimum),
            reference = minimumReference,
            disabled = function()
                return not profile.enabled
            end,
        },
        {
            type = "editbox",
            name = L("MAXIMUM_TO_KEEP"),
            tooltip = string.format(L("MAXIMUM_TO_KEEP_TOOLTIP"), currencyName),
            width = "half",
            maxChars = 10,
            textType = TEXT_TYPE_NUMERIC,
            getFunc = function()
                return tostring(profile.maximum)
            end,
            setFunc = function(value)
                SetMaximum(profile, value)
                RefreshControl(minimumReference)
            end,
            default = tostring(defaults.maximum),
            reference = maximumReference,
            disabled = function()
                return not profile.enabled
            end,
        },
    }
end

function banking.CreateSettings()
    if not ua.savedVariables.bankingEnabled then
        return
    end

    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local settings = currencies.GetSettings()
    local options = {
        {
            type = "header",
            name = banking.GetGameString(SI_INVENTORY_CURRENCIES, L("CURRENCIES")),
        },
    }

    for _, definition in ipairs(currencies.definitions) do
        local profile = settings[definition.key]
        local defaults = currencies.GetDefaults(definition.key)
        local currencyName = currencies.GetDisplayName(definition.currencyType)

        table.insert(options, {
            type = "submenu",
            name = currencies.GetDisplayNameWithIcon(definition.currencyType),
            tooltip = string.format(L("CURRENCY_TOOLTIP"), currencyName),
            controls = CreateCurrencyControls(definition, profile, defaults),
        })
    end

    table.insert(options, { type = "divider" })

    for _, control in ipairs(banking.AutoBanking.CreateMenuControls()) do
        table.insert(options, control)
    end

    local panelId = "UABankingSettings"
    local panelData = {
        type = "panel",
        name = ua.GetString("BANKING_PANEL"),
        displayName = ua.GetString("BANKING_PANEL"),
        author = "@The.Invis",
        version = ua.version,
        registerForRefresh = true,
        registerForDefaults = true,
        resetFunc = function()
            ua.ResetBankingSettings()
        end,
    }

    LAM:RegisterAddonPanel(panelId, panelData)
    LAM:RegisterOptionControls(panelId, options)
end
