--[[
    Triple Triad ESO - Zone Data
    Maps ESO zones to difficulty ranks and card pools.
    Any interactable NPC gets a difficulty based on their zone,
    and draws cards from their zone's themed card pool.

    Zone difficulty is based on level/progression:
        Rank 1: Starter islands, tutorial zones
        Rank 2: Alliance base zones, early story
        Rank 3: Mid-game zones, guild questlines
        Rank 4: DLC zones, trials areas
        Rank 5: Endgame DLC, Daedric realms
]]--

local TT = TripleTriadESO

TT.ZoneData = {}

-- ─────────────────────────────────────────────
-- Zone name -> { rank, cardPool }
-- cardPool is an array of card IDs the zone draws from
-- NPCs pick 5 cards from their zone pool weighted by rank
-- ─────────────────────────────────────────────

-- Card groups by tier for easy pool building
local TIER1 = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 51, 52, 53, 54 }  -- ★1 cards (16)
local TIER2 = { 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 55, 56, 57 }  -- ★2 cards (15)
local TIER3 = { 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36 }  -- ★3 cards
local TIER4 = { 37, 38, 39, 40, 41, 42, 43, 44 }                   -- ★4 cards
local TIER5 = { 45, 46, 47, 48, 49, 50 }                            -- ★5 cards

-- Helper to merge multiple tables
local function MergeCards(...)
    local result = {}
    for _, tbl in ipairs({...}) do
        for _, v in ipairs(tbl) do
            table.insert(result, v)
        end
    end
    return result
end

-- ─────────────────────────────────────────────
-- Zone Database
-- Keys are LOWERCASE zone names for matching
-- ─────────────────────────────────────────────
local zones = {
    -- ═══════════════════════════════════════
    -- RANK 1 — Starter / Tutorial Zones
    -- ═══════════════════════════════════════
    ["bleakrock isle"]      = { rank = 1, cards = TIER1 },
    ["bal foyen"]           = { rank = 1, cards = TIER1 },
    ["khenarthi's roost"]   = { rank = 1, cards = TIER1 },
    ["stros m'kai"]         = { rank = 1, cards = TIER1 },
    ["betnikh"]             = { rank = 1, cards = TIER1 },
    ["fiord's legacy"]      = { rank = 1, cards = TIER1 },

    -- ═══════════════════════════════════════
    -- RANK 2 — Alliance Base Zones
    -- ═══════════════════════════════════════
    -- Ebonheart Pact
    ["stonefalls"]          = { rank = 2, cards = MergeCards(TIER1, TIER2) },
    ["deshaan"]             = { rank = 2, cards = MergeCards(TIER1, TIER2) },
    ["shadowfen"]           = { rank = 2, cards = MergeCards(TIER1, TIER2) },
    ["eastmarch"]           = { rank = 2, cards = MergeCards(TIER1, TIER2) },
    ["the rift"]            = { rank = 2, cards = MergeCards(TIER1, TIER2) },
    -- Aldmeri Dominion
    ["auridon"]             = { rank = 2, cards = MergeCards(TIER1, TIER2) },
    ["grahtwood"]           = { rank = 2, cards = MergeCards(TIER1, TIER2) },
    ["greenshade"]          = { rank = 2, cards = MergeCards(TIER1, TIER2) },
    ["malabal tor"]         = { rank = 2, cards = MergeCards(TIER1, TIER2) },
    ["reaper's march"]      = { rank = 2, cards = MergeCards(TIER1, TIER2) },
    -- Daggerfall Covenant
    ["glenumbra"]           = { rank = 2, cards = MergeCards(TIER1, TIER2) },
    ["stormhaven"]          = { rank = 2, cards = MergeCards(TIER1, TIER2) },
    ["rivenspire"]          = { rank = 2, cards = MergeCards(TIER1, TIER2) },
    ["alik'r desert"]       = { rank = 2, cards = MergeCards(TIER1, TIER2) },
    ["bangkorai"]           = { rank = 2, cards = MergeCards(TIER1, TIER2) },

    -- ═══════════════════════════════════════
    -- RANK 3 — Mid-game / Shared Zones
    -- ═══════════════════════════════════════
    ["coldharbour"]         = { rank = 3, cards = MergeCards(TIER2, TIER3) },
    ["craglorn"]            = { rank = 3, cards = MergeCards(TIER2, TIER3) },
    ["cyrodiil"]            = { rank = 3, cards = MergeCards(TIER2, TIER3) },
    ["the gold coast"]      = { rank = 3, cards = MergeCards(TIER2, TIER3) },
    ["gold coast"]          = { rank = 3, cards = MergeCards(TIER2, TIER3) },
    ["hew's bane"]          = { rank = 3, cards = MergeCards(TIER2, TIER3) },
    ["wrothgar"]            = { rank = 3, cards = MergeCards(TIER2, TIER3) },
    ["orsinium"]            = { rank = 3, cards = MergeCards(TIER2, TIER3) },

    -- ═══════════════════════════════════════
    -- RANK 4 — Chapter / DLC Zones
    -- ═══════════════════════════════════════
    ["vvardenfell"]         = { rank = 4, cards = MergeCards(TIER2, TIER3, TIER4) },
    ["morrowind"]           = { rank = 4, cards = MergeCards(TIER2, TIER3, TIER4) },
    ["summerset"]           = { rank = 4, cards = MergeCards(TIER2, TIER3, TIER4) },
    ["artaeum"]             = { rank = 4, cards = MergeCards(TIER3, TIER4) },
    ["murkmire"]            = { rank = 4, cards = MergeCards(TIER2, TIER3, TIER4) },
    ["northern elsweyr"]    = { rank = 4, cards = MergeCards(TIER2, TIER3, TIER4) },
    ["elsweyr"]             = { rank = 4, cards = MergeCards(TIER2, TIER3, TIER4) },
    ["southern elsweyr"]    = { rank = 4, cards = MergeCards(TIER3, TIER4) },
    ["western skyrim"]      = { rank = 4, cards = MergeCards(TIER2, TIER3, TIER4) },
    ["the reach"]           = { rank = 4, cards = MergeCards(TIER3, TIER4) },
    ["blackwood"]           = { rank = 4, cards = MergeCards(TIER2, TIER3, TIER4) },
    ["deadlands"]           = { rank = 4, cards = MergeCards(TIER3, TIER4) },
    ["the deadlands"]       = { rank = 4, cards = MergeCards(TIER3, TIER4) },
    ["high isle"]           = { rank = 4, cards = MergeCards(TIER2, TIER3, TIER4) },
    ["galen"]               = { rank = 4, cards = MergeCards(TIER2, TIER3, TIER4) },
    ["telvanni peninsula"]  = { rank = 4, cards = MergeCards(TIER3, TIER4) },
    ["apocrypha"]           = { rank = 4, cards = MergeCards(TIER3, TIER4) },
    ["west weald"]          = { rank = 4, cards = MergeCards(TIER2, TIER3, TIER4) },
    ["gold road"]           = { rank = 4, cards = MergeCards(TIER2, TIER3, TIER4) },

    -- ═══════════════════════════════════════
    -- RANK 5 — Daedric Realms / Endgame
    -- ═══════════════════════════════════════
    ["clockwork city"]      = { rank = 5, cards = MergeCards(TIER3, TIER4, TIER5) },
    ["the clockwork city"]  = { rank = 5, cards = MergeCards(TIER3, TIER4, TIER5) },
    ["fargrave"]            = { rank = 5, cards = MergeCards(TIER3, TIER4, TIER5) },
    ["the shambles"]        = { rank = 5, cards = MergeCards(TIER4, TIER5) },
    ["the scholarium"]      = { rank = 5, cards = MergeCards(TIER3, TIER4, TIER5) },
}

-- ─────────────────────────────────────────────
-- Lookup Functions
-- ─────────────────────────────────────────────

--- Get zone data for a zone name. Falls back to partial matching.
function TT.ZoneData.GetZoneInfo(zoneName)
    if not zoneName or zoneName == "" then return nil end

    local lower = string.lower(zoneName)

    -- Exact match first
    if zones[lower] then
        return zones[lower]
    end

    -- Partial match (zone name might have extra text like "City of Vivec" inside "Vvardenfell")
    for zoneKey, data in pairs(zones) do
        if string.find(lower, zoneKey, 1, true) or string.find(zoneKey, lower, 1, true) then
            return data
        end
    end

    return nil
end

--- Build a random 5-card deck from a zone's card pool at the given rank.
--- Higher ranks bias toward stronger cards in the pool.
function TT.ZoneData.BuildNPCDeck(zoneInfo)
    if not zoneInfo or not zoneInfo.cards or #zoneInfo.cards < 5 then
        -- Fallback: basic tier 1 cards
        return { 1, 2, 3, 4, 5 }
    end

    local pool = zoneInfo.cards
    local rank = zoneInfo.rank or 1
    local deck = {}
    local used = {}

    for i = 1, 5 do
        local attempts = 0
        local cardId

        repeat
            -- Higher rank = bias toward picking from later in the pool (stronger cards)
            local idx
            if rank >= 4 and math.random() < 0.6 then
                -- Bias toward the upper half of the pool
                local halfStart = math.floor(#pool / 2) + 1
                idx = math.random(halfStart, #pool)
            elseif rank >= 3 and math.random() < 0.4 then
                local thirdStart = math.floor(#pool * 0.6) + 1
                idx = math.random(thirdStart, #pool)
            else
                idx = math.random(1, #pool)
            end

            cardId = pool[idx]
            attempts = attempts + 1
        until not used[cardId] or attempts > 50

        used[cardId] = true
        table.insert(deck, cardId)
    end

    return deck
end

--- Get a rank name string for display
function TT.ZoneData.GetRankName(rank)
    local names = {
        [1] = "Novice",
        [2] = "Apprentice",
        [3] = "Journeyman",
        [4] = "Expert",
        [5] = "Master",
    }
    return names[rank] or "Unknown"
end

--- Get a fallback zone info for when zone is unknown
function TT.ZoneData.GetDefaultZoneInfo()
    return { rank = 2, cards = MergeCards(TIER1, TIER2) }
end
