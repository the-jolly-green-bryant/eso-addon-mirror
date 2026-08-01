-- CharacterMarkdown - Economy Data Collector
-- Composition logic moved from API layer (uses Inventory API for currency)

local CM = CharacterMarkdown

local function CollectEconomyData()
    -- Use API layer granular functions (composition at collector level)
    local currencies = CM.api.inventory.GetAllCurrencies()

    local economy = {}

    -- Transform API data to expected format (backward compatibility)
    economy.gold = currencies.gold or 0
    economy.ap = currencies.ap or 0
    economy.telvar = currencies.telvar or 0
    economy.vouchers = currencies.vouchers or 0
    economy.transmute = currencies.transmute or 0
    economy.transmuteMax = currencies.transmuteMax or 0
    economy.crowns = currencies.crowns or 0
    economy.gems = currencies.gems or 0
    economy.seals = currencies.seals or 0
    economy.eventTickets = currencies.eventTickets or 0
    economy.eventTicketsMax = currencies.eventTicketsMax or 0
    economy.undauntedKeys = currencies.undauntedKeys or 0
    economy.outfitTokens = currencies.outfitTokens or 0
    economy.archivalFortunes = currencies.archivalFortunes or 0
    economy.imperialFragments = currencies.imperialFragments or 0

    -- Add computed summary
    local totalValue = economy.gold -- Primary currency

    -- Helper to check if any other currency has value
    local function HasValue(val)
        return (val or 0) > 0
    end

    local hasOtherCurrencies = HasValue(economy.ap)
        or HasValue(economy.telvar)
        or HasValue(economy.vouchers)
        or HasValue(economy.transmute)
        or HasValue(economy.crowns)
        or HasValue(economy.gems)
        or HasValue(economy.seals)
        or HasValue(economy.eventTickets)
        or HasValue(economy.undauntedKeys)
        or HasValue(economy.outfitTokens)
        or HasValue(economy.archivalFortunes)
        or HasValue(economy.imperialFragments)

    -- Count types
    local typeCount = 1 -- Gold
    if HasValue(economy.ap) then
        typeCount = typeCount + 1
    end
    if HasValue(economy.telvar) then
        typeCount = typeCount + 1
    end
    if HasValue(economy.vouchers) then
        typeCount = typeCount + 1
    end
    if HasValue(economy.transmute) then
        typeCount = typeCount + 1
    end
    if HasValue(economy.crowns) then
        typeCount = typeCount + 1
    end
    if HasValue(economy.gems) then
        typeCount = typeCount + 1
    end
    if HasValue(economy.seals) then
        typeCount = typeCount + 1
    end
    if HasValue(economy.eventTickets) then
        typeCount = typeCount + 1
    end
    if HasValue(economy.undauntedKeys) then
        typeCount = typeCount + 1
    end
    if HasValue(economy.outfitTokens) then
        typeCount = typeCount + 1
    end
    if HasValue(economy.archivalFortunes) then
        typeCount = typeCount + 1
    end
    if HasValue(economy.imperialFragments) then
        typeCount = typeCount + 1
    end

    economy.summary = {
        totalGold = economy.gold,
        hasOtherCurrencies = hasOtherCurrencies,
        currencyTypes = typeCount,
    }

    return economy
end

CM.collectors.CollectEconomyData = CollectEconomyData
CM.collectors.CollectCurrencyData = CollectEconomyData -- Alias for compatibility

CM.DebugPrint("COLLECTOR", "Economy collector module loaded")
