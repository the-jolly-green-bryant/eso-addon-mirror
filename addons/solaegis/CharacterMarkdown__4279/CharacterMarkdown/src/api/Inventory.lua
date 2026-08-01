-- CharacterMarkdown - API Layer - Inventory
-- Abstraction for currency, bags, and bank

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.inventory = {}

local api = CM.api.inventory

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetCurrency(currencyType, location)
    location = location or CURRENCY_LOCATION_CHARACTER
    return CM.SafeCall(GetCurrencyAmount, currencyType, location) or 0
end

function api.GetMaxCurrency(currencyType, location)
    location = location or CURRENCY_LOCATION_CHARACTER
    return CM.SafeCall(GetMaxPossibleCurrency, currencyType, location) or 0
end

function api.GetAllCurrencies()
    local currencies = {
        gold = api.GetCurrency(CURT_MONEY),
        ap = api.GetCurrency(CURT_ALLIANCE_POINTS),
        telvar = api.GetCurrency(CURT_TELVAR_STONES),
        vouchers = api.GetCurrency(CURT_WRIT_VOUCHERS),
        transmute = api.GetCurrency(CURT_TRANSMUTE_CRYSTALS, CURRENCY_LOCATION_ACCOUNT),
        transmuteMax = api.GetMaxCurrency(CURT_TRANSMUTE_CRYSTALS, CURRENCY_LOCATION_ACCOUNT),
        crowns = api.GetCurrency(CURT_CROWNS, CURRENCY_LOCATION_ACCOUNT),
        gems = api.GetCurrency(CURT_CROWN_GEMS, CURRENCY_LOCATION_ACCOUNT),
        seals = api.GetCurrency(CURT_ENDEAVOR_SEALS, CURRENCY_LOCATION_ACCOUNT),
        eventTickets = api.GetCurrency(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT),
        eventTicketsMax = api.GetMaxCurrency(CURT_EVENT_TICKETS, CURRENCY_LOCATION_ACCOUNT),
        undauntedKeys = api.GetCurrency(CURT_UNDAUNTED_KEYS, CURRENCY_LOCATION_ACCOUNT),
        outfitTokens = api.GetCurrency(CURT_STYLE_STONES, CURRENCY_LOCATION_ACCOUNT),
        archivalFortunes = api.GetCurrency(CURT_ARCHIVAL_FORTUNES, CURRENCY_LOCATION_ACCOUNT),
        imperialFragments = api.GetCurrency(CURT_IMPERIAL_FRAGMENTS, CURRENCY_LOCATION_ACCOUNT),
    }

    return currencies
end

function api.GetBagStats(bagId)
    local size = CM.SafeCall(GetBagSize, bagId) or 0
    local used = CM.SafeCall(GetNumBagUsedSlots, bagId) or 0
    return {
        size = size,
        used = used,
        free = size - used,
    }
end

function api.GetCraftBagAccess()
    return CM.SafeCall(HasCraftBagAccess) or false
end

-- Composition functions moved to collector level
