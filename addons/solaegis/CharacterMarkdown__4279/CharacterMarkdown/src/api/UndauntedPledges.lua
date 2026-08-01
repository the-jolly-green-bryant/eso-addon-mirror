-- CharacterMarkdown - API Layer - Undaunted Pledges
-- Abstraction for Undaunted keys and pledge-related data available via live APIs

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.undauntedPledges = {}

local api = CM.api.undauntedPledges

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

-- Legacy pledge/dungeon enumeration APIs were removed from the client.
-- Active pledges are quest journal entries (see Quests collector).

function api.GetDailyPledges()
    return { normal = {}, veteran = {} }
end

function api.GetWeeklyPledges()
    return { normal = {}, veteran = {} }
end

function api.GetPledgeKeys()
    return {
        daily = 0,
        weekly = 0,
    }
end

function api.GetDungeonProgress()
    return {
        normal = { total = 0, completed = 0, dungeons = {} },
        veteran = { total = 0, completed = 0, dungeons = {} },
        hardmode = { total = 0, completed = 0, dungeons = {} },
    }
end

function api.GetUndauntedKeys()
    local keyCount = 0
    if CM.api.inventory and CM.api.inventory.GetCurrency then
        keyCount = CM.api.inventory.GetCurrency(CURT_UNDAUNTED_KEYS, CURRENCY_LOCATION_ACCOUNT)
    elseif GetCurrencyAmount then
        keyCount = CM.SafeCall(GetCurrencyAmount, CURT_UNDAUNTED_KEYS, CURRENCY_LOCATION_ACCOUNT) or 0
    end

    return {
        total = keyCount,
        account = keyCount,
        categories = {},
    }
end

CM.DebugPrint("API", "UndauntedPledges API module loaded")
