--[[
================================================================================
 HTTT Data Module
 Contains zone data, constants, and lookup tables for travel functionality.
 
 This module provides:
 - Zone ID mappings for all overland zones in ESO
 - Fuzzy matching data for zone name lookups
 - Constants for favorite storage and limits
 - Error code translations for debug output
================================================================================
]]--

HTTT = HTTT or {}
HTTT.Data = {}

-- Initialize the data module
-- Builds lookup tables and prepares data structures
function HTTT.Data.Initialize()
    -- Build the zone mapping tables for fuzzy matching
    HTTT.Data.BuildZoneNameMapping()
end

-- Favorite types and storage keys
-- @ usage HTTT.Core.EnsureFavorites(HTTT.Data.FAVORITE_TYPES.ZONES)
HTTT.Data.FAVORITE_TYPES = {
    FRIEND_HOUSES = "favoriteFriendHouses", -- Friend house favorites
    ZONES = "favoriteZones",                -- Zone favorites
    FRIENDS = "favoriteFriends"             -- Friend favorites
}

-- Maximum number of favorite slots per category
HTTT.Data.MAX_SLOTS = {
    FRIEND_HOUSES = 10,  -- Max number of friend house favorites
    ZONES = 10,          -- Max number of zone favorites
    FRIENDS = 10         -- Max number of friend favorites
}

-- Priority expansion zone IDs (latest chapters first)
-- Used for smart teleport to prioritize newer zones when multiple options exist
HTTT.Data.PRIORITY_EXPANSION_ZONE_IDS = {
    1502, -- Solstice (2025)
    1443, -- West Weald (2024)
    1414, -- Telvanni Peninsula (2023)
    1318, -- High Isle (2022)
    1261, -- Blackwood (2021)
    1160, -- Western Skyrim (2020)
    1086, -- Northern Elsweyr (2019)
    1011, -- Summerset (2018)
    849,  -- Vvardenfell (2017)
}

-- List of all overland zone IDs for lookup
-- These are zones that players can travel to and from
-- @ usage if HTTT.Data.OVERLAND_ZONE_IDS[zoneId] then -- This is a valid overland zone
HTTT.Data.OVERLAND_ZONE_IDS = {
    -- Starter Islands
    [280]   = true,     -- Bleakrock Isle
    [281]   = true,     -- Bal Foyen
    [534]   = true,     -- Stros M'Kai
    [537]   = true,     -- Khenarthi's Roost
    [535]   = true,     -- Betnikh
    -- Aldmeri Dominion
    [381]   = true,     -- Auridon
    [383]   = true,     -- Grahtwood
    [108]   = true,     -- Greenshade
    [58]    = true,     -- Malabal Tor
    [382]   = true,     -- Reaper's March
    -- Daggerfall Covenant
    [3]     = true,     -- Glenumbra
    [19]    = true,     -- Stormhaven
    [20]    = true,     -- Rivenspire
    [104]   = true,     -- Alik'r Desert
    [92]    = true,     -- Bangkorai
    -- Ebonheart Pact
    [41]    = true,     -- Stonefalls
    [57]    = true,     -- Deshaan
    [117]   = true,     -- Shadowfen
    [101]   = true,     -- Eastmarch
    [103]   = true,     -- The Rift
    -- Coldharbour (main quest)
    [347]   = true,     -- Coldharbour
    -- Eyevea (Mages Guild)
    [267]   = true,     -- Eyevea
    -- Chapters & DLC (Overland)
    [888]   = true,     -- Craglorn                          Update: Base Game          May 2014
    [684]   = true,     -- Wrothgar                          DLC: Orsinium              November 2015
    [816]   = true,     -- Hew's Bane                        DLC: Thieves Guild         March 2016
    [823]   = true,     -- Gold Coast                        DLC: Dark Brotherhood      May 2016
    [849]   = true,     -- Vvardenfell                       Chapter: Morrowind         June 2017
    [980]   = true,     -- Clockwork City                    DLC: Clockwork City        October 2017
    [1011]  = true,     -- Summerset                         Chapter: Summerset         May 2018
    [726]   = true,     -- Murkmire                          DLC: Murkmire              October 2018
    [1086]  = true,     -- Northern Elsweyr                  Chapter: Elsweyr           May 2019
    [1133]  = true,     -- Southern Elsweyr                  DLC: Dragonhold            October 2019
    [1160]  = true,     -- Western Skyrim                    Chapter: Greymoor          May 2020
    [1161]  = true,     -- Blackreach: Greymoor Caverns      Chapter: Greymoor          May 2020
    [1208]  = true,     -- Blackreach: Arkthzand Cavern      DLC: Markarth              November 2020
    [1207]  = true,     -- The Reach                         DLC: Markarth              November 2020
    [1261]  = true,     -- Blackwood                         Chapter: Blackwood         June 2021
    [1282]  = true,     -- Fargrave                          DLC: Deadlands             November 2021
    [1286]  = true,     -- Deadlands                         DLC: Deadlands             November 2021
    [1318]  = true,     -- High Isle                         Chapter: High Isle         June 2022
    [1383]  = true,     -- Galen                             DLC: Firesong              November 2022
    [1414]  = true,     -- Telvanni Peninsula                Chapter: Necrom            June 2023
    [1463]  = true,     -- The Scholarium                    DLC: Scions of Ithelia     March 2024
    [1443]  = true,     -- West Weald                        Chapter: Gold Road         June 2024
    [1502]  = true,     -- Solstice                          Chapter: Solstice          June 2025
}

-- Zone alias lookup data for fuzzy matching
-- Format: {zoneId, {alias1, alias2, ...}}
-- Includes city names and common misspellings for improved usability
HTTT.Data.ALIAS_ZONE_BUILD = {
    -- {zoneId, {aliases...}}
    {381,  {"auridon", "vulkhel guard", "skywatch", "firsthold"}},
    {383,  {"grahtwood", "elden root", "eldon root", "redfur trading post"}},
    {108,  {"greenshade", "marbruk", "woodhearth"}},
    {58,   {"malabal tor", "vulkwasten", "baandari trading post"}},
    {382,  {"reapers march", "rawl'kha", "rawlkha", "dune"}},
    {3,    {"glenumbra", "daggerfall", "crosswych"}},
    {19,   {"stormhaven", "wayrest", "koeglin village"}},
    {20,   {"rivenspire", "shornhelm", "northpoint", "hoarfrost downs"}},
    {104,  {"alik'r desert", "alikr", "sentinel", "kozanset"}},
    {92,   {"bankorai", "bangkorai", "evermore", "hallin's stand", "hallins stand"}},
    {41,   {"stonefalls", "davon's watch", "davons watch", "ebonheart"}},
    {57,   {"deshaan", "mournhold", "narsis"}},
    {117,  {"shadowfen", "stormhold", "alten corimont"}},
    {101,  {"eastmarch", "windhelm", "fort amol"}},
    {103,  {"the rift", "riften", "nimalten"}},
    {347,  {"coldharbour", "hollow city", "the hollow city"}},
    {267,  {"eyevea"}},
    {888,  {"craglorn", "belkarth"}},
    {684,  {"wrothgar", "orsinium", "morkul stronghold"}},
    {816,  {"hew's bane", "hews bane", "hew'sbane", "hewsbane", "abhahs landing", "abah's landing", "abahs landing"}},
    {823,  {"gold coast", "anvil", "kvatch"}},
    {849,  {"vvardenfell", "vivec", "vivec city", "balmora", "sadrith mora", "molag mar", "surin", "ald ruhn", "tel mora"}},
    {980,  {"clockwork city", "brass fortress", "slagtown"}},
    {1011, {"summerset", "alinor", "lillandril", "shimmerene", "sunhold"}},
    {726,  {"murkmire", "lilmoth", "bright-throat village", "dead-water village"}},
    {1086, {"northern elsweyr", "rimmen", "riverhold", "star haven"}},
    {1133, {"southern elsweyr", "senchal", "black heights"}},
    {1160, {"western skyrim", "solitude", "morthal", "dragon bridge"}},
    {1161, {"blackreach", "greymoor", "dusktown"}},
    {1207, {"the reach", "markarth", "karthwasten"}},
    {1261, {"blackwood", "leyawiin", "gideon", "borderwatch"}},
    {1282, {"fargrave"}},
    {1286, {"deadlands", "fort sanguine"}},
    {1318, {"high isle", "gonfalon", "gonfalon bay", "amenos"}},
    {1383, {"galen", "vastyr"}},
    {1414, {"telvanni peninsula", "necrom", "kemel-ze"}},
    {1443, {"west weald", "skingrad", "vashabar"}},
    {1502, {"solstice"}}
}

-- Map of jump result codes to human-readable error messages
-- Used for debug output when a zone jump fails
-- @ usage local reason = HTTT.Data.JUMP_RESULT_REASON_MAP[jumpResult] or "Unknown error"
HTTT.Data.JUMP_RESULT_REASON_MAP = {
    [JUMP_TO_PLAYER_RESULT_CROSS_ALLIANCE_LOCKED]      = "Alliance locked",
    [JUMP_TO_PLAYER_RESULT_GENERIC_FAILURE]            = "Generic failure",
    [JUMP_TO_PLAYER_RESULT_PLAYER_DIFFICULTY_LOCKED]   = "Difficulty locked",
    [JUMP_TO_PLAYER_RESULT_PLAYER_OFFLINE]             = "Player offline",
    [JUMP_TO_PLAYER_RESULT_SOLO_ZONE]                  = "Solo/instanced zone",
    [JUMP_TO_PLAYER_RESULT_ZONE_COLLECTIBLE_LOCKED]    = "DLC/Chapter not owned",
    [JUMP_TO_PLAYER_RESULT_SUCCESS]                    = "Success",
}

-- Lookup tables built during initialization
HTTT.Data.ALIAS_ZONE_NAMES = {} -- Maps zone alias to zoneId
HTTT.Data.ZONE_NAME_TO_ID = {}  -- Maps simplified zone name to zoneId

-- Builds the zone name lookup tables from ALIAS_ZONE_BUILD data
-- Called once during initialization
-- @ return nil
function HTTT.Data.BuildZoneNameMapping()
    -- Build alias lookup: lowercase alias to zoneId for fuzzy zone matching
    -- This enables lookup by city name, common misspellings, etc.
    for _, entry in ipairs(HTTT.Data.ALIAS_ZONE_BUILD) do
        local zoneId, names = entry[1], entry[2]
        for _, alias in ipairs(names) do
            HTTT.Data.ALIAS_ZONE_NAMES[alias:lower()] = zoneId
        end
    end
    
    -- Build mapping for simplified zone names to their IDs for fuzzy search
    -- Removes special characters to allow more flexible matching
    for id in pairs(HTTT.Data.OVERLAND_ZONE_IDS) do
        local name = GetZoneNameById(id)
        if name and name ~= "" then
            local simplified = name:lower():gsub("[^%w]", "")
            HTTT.Data.ZONE_NAME_TO_ID[simplified] = id
        end
    end
end