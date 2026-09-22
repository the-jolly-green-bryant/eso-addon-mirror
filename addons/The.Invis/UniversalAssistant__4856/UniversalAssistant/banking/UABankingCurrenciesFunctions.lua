local ua = UAssistant
local banking = ua.Banking

banking.Currencies = banking.Currencies or {}
local currencies = banking.Currencies

local EVENT_NAMESPACE = ua.addonName .. "BankingCurrencies"
local TRANSFER_DELAY_MS = 150
local MAX_CURRENCY_VALUE = 2147483647

local DEFAULT_CURRENCIES = {
    gold = {
        enabled = false,
        minimum = 1000,
        maximum = 5000,
    },
    alliancePoints = {
        enabled = false,
        minimum = 1000,
        maximum = 5000,
    },
    telVarStones = {
        enabled = false,
        minimum = 1000,
        maximum = 5000,
    },
    writVouchers = {
        enabled = false,
        minimum = 10,
        maximum = 100,
    },
}

currencies.definitions = {
    {
        key = "gold",
        currencyType = CURT_MONEY,
        nameKey = "CURRENCY_GOLD",
    },
    {
        key = "alliancePoints",
        currencyType = CURT_ALLIANCE_POINTS,
        nameKey = "CURRENCY_ALLIANCE_POINTS",
    },
    {
        key = "telVarStones",
        currencyType = CURT_TELVAR_STONES,
        nameKey = "CURRENCY_TEL_VAR_STONES",
    },
    {
        key = "writVouchers",
        currencyType = CURT_WRIT_VOUCHERS,
        nameKey = "CURRENCY_WRIT_VOUCHERS",
    },
}

local function NormalizeAmount(value, fallback)
    local amount = tonumber(value)

    if not amount then
        amount = fallback or 0
    end

    return zo_clamp(zo_floor(amount), 0, MAX_CURRENCY_VALUE)
end

function currencies.GetDefaults(key)
    return DEFAULT_CURRENCIES[key]
end

function currencies.GetSettings()
    local savedVariables = ua.savedVariables

    if not savedVariables.banking then
        savedVariables.banking = {}
    end

    if not savedVariables.banking.currencies then
        savedVariables.banking.currencies = {}
    end

    local settings = savedVariables.banking.currencies

    for key, defaults in pairs(DEFAULT_CURRENCIES) do
        if not settings[key] then
            settings[key] = {}
        end

        local profile = settings[key]

        if profile.enabled == nil then
            profile.enabled = profile.deposit == true or profile.withdraw == true
        end

        profile.deposit = nil
        profile.withdraw = nil
        profile.minimum = NormalizeAmount(profile.minimum, defaults.minimum)
        profile.maximum = NormalizeAmount(profile.maximum, defaults.maximum)

        if profile.minimum > profile.maximum then
            profile.maximum = profile.minimum
        end
    end

    return settings
end

function currencies.GetDisplayName(currencyType)
    if ua.GetLanguageCode() == "ua" then
        for _, definition in ipairs(currencies.definitions) do
            if definition.currencyType == currencyType then
                return ua.GetString("BANKING_" .. definition.nameKey)
            end
        end
    end

    local name = GetCurrencyName(currencyType)

    return zo_strformat("<<C:1>>", name)
end

function currencies.GetDisplayNameWithIcon(currencyType)
    local name = currencies.GetDisplayName(currencyType)
    local currencyData = ZO_CURRENCIES_DATA and ZO_CURRENCIES_DATA[currencyType]
    local icon = currencyData and currencyData.keyboardTexture

    if not icon or icon == "" then
        return name
    end

    return zo_iconFormat(icon, 24, 24) .. " " .. name
end

local function TransferAvailableCurrency(
    currencyType,
    requestedAmount,
    sourceLocation,
    destinationLocation
)
    local available = GetCurrencyAmount(currencyType, sourceLocation) or 0
    local transferable = GetMaxCurrencyTransfer(currencyType, sourceLocation, destinationLocation)
        or 0
    local amount = math.min(requestedAmount, available, transferable)

    amount = NormalizeAmount(amount, 0)

    if amount <= 0 then
        return
    end

    TransferCurrency(currencyType, amount, sourceLocation, destinationLocation)
end

local function ProcessCurrency(definition, profile)
    if not profile.enabled then
        return
    end

    local characterAmount = GetCurrencyAmount(definition.currencyType, CURRENCY_LOCATION_CHARACTER)
        or 0

    if characterAmount < profile.minimum then
        TransferAvailableCurrency(
            definition.currencyType,
            profile.minimum - characterAmount,
            CURRENCY_LOCATION_BANK,
            CURRENCY_LOCATION_CHARACTER
        )
        return
    end

    if characterAmount > profile.maximum then
        TransferAvailableCurrency(
            definition.currencyType,
            characterAmount - profile.maximum,
            CURRENCY_LOCATION_CHARACTER,
            CURRENCY_LOCATION_BANK
        )
    end
end

function currencies.Process(expectedGeneration, bankBagId)
    if
        expectedGeneration ~= currencies.transferGeneration
        or not ua.savedVariables.bankingEnabled
        or not IsBankOpen()
        or GetInteractionType() ~= INTERACTION_BANK
        or (bankBagId and IsHouseBankBag(bankBagId))
    then
        return
    end

    local settings = currencies.GetSettings()

    for _, definition in ipairs(currencies.definitions) do
        ProcessCurrency(definition, settings[definition.key])
    end
end

function currencies.Initialize()
    currencies.GetSettings()
    currencies.transferGeneration = 0

    EVENT_MANAGER:RegisterForEvent(
        EVENT_NAMESPACE .. "Open",
        EVENT_OPEN_BANK,
        function(_, bankBagId)
            currencies.transferGeneration = currencies.transferGeneration + 1
            local expectedGeneration = currencies.transferGeneration

            zo_callLater(function()
                currencies.Process(expectedGeneration, bankBagId)
            end, TRANSFER_DELAY_MS)
        end
    )

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "Close", EVENT_CLOSE_BANK, function()
        currencies.transferGeneration = currencies.transferGeneration + 1
    end)
end
