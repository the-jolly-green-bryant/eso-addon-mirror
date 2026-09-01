local ADDON_NAME = "TamrielProgressMap"
local DISPLAY_NAME = "Tamriel Progress Map"
local VERSION = "2.6.72_Beta"
local AUTHOR = "Raccoonplayz"
local PIN_TYPE_STRING = "TamrielProgressMap_ZoneProgressPin"

TamrielProgressMap = TamrielProgressMap or {}
local TPM = TamrielProgressMap

TPM.overlayLabels = TPM.overlayLabels or {}
TPM.labelPool = TPM.labelPool or {}
TPM.displayedZoneIds = TPM.displayedZoneIds or {}
TPM.refreshQueued = false
TPM.pinRegistered = false
TPM.symbolicZonePositions = TPM.symbolicZonePositions or {}
TPM.symbolicZonePositionsMapId = TPM.symbolicZonePositionsMapId or 0
TPM.nextLabelId = TPM.nextLabelId or 0

local DEFAULTS =
{
    enabled = true,
    showZoneNames = false,
    showTooltip = true,
    showHeader = true,
    language = "auto",
    hideCompletedZones = false,
    calculationMode = "objectives",
    showCategoryPercentages = false,
    showQuestRewards = true,
    colorVanillaQuestsByReward = true,
    fontStyle = "classic",
    questFontStyle = "classic",
    blackPercentText = false, -- legacy migration from v1.4.x
    percentColorMode = "black",
    percentColorModeMigrated = false,
    customPercentColor = { r = 0.79, g = 0.64, b = 0.29 },
    mapPercentScale = 100,
    headerPercentScale = 100,
    hundredDisplayMode = "percent",
    hundredDisplayMigrated = false,
    showQuickFilters = true,
    quickFilter = "all",
    debugMode = false,
    questRewardAnchorX = 322,
    questRewardAnchorY = -90,
    questRewardWidth = 312,
    questRewardHeight = 186,
    questRewardLocked = false,
    questRewardAutoSize = true,
    questRewardPositionVersion = 5,
    statisticsWindowX = false,
    statisticsWindowY = false,
    statisticsWindowScale = 100,
    statisticsSortMode = "progress",
    statisticsPage = "progress",
    statisticsCompletionPage = 1, -- 2.6.0: 1=zone completion, 2=collections, 3=achievements
    statisticsCategorySortMode = "all", -- 2.6.8: all/name/asc/desc for the three completion sub-pages
    skyshardGoalEnabled = false, -- personal zone-aware Skyshard goal HUD
    skyshardGoalPosition = 1, -- 2.6.15: 1=directly above Tamriel Tomes, 2=directly below
    skyshardGoalCustomPosition = false, -- 2.6.21: user-dragged HUD position overrides automatic slot 1/2
    skyshardGoalCustomX = false,
    skyshardGoalCustomY = false,
    skyshardGoalCustomWidth = false, -- 2.6.25: optional user-sized HUD width
    skyshardGoalCustomHeight = false, -- 2.6.25: optional user-sized HUD height
    progressGoalCategoryType = false, -- 2.6.26: currently selected progress-category HUD row
    statisticsFocusZoneId = 0,
    alliancePlannerMapZoom = 1.0,
    alliancePlannerMapCenterX = 0.5,
    alliancePlannerMapCenterY = 0.5,
    alliancePlannerTerritoryColors = true,
 -- 2.6.14: 0=all Tamriel, otherwise one supported progress zone
    combatStatsByCharacter = {},
    economyStats = { trackingVersion = "2.0.10", currencies = {} }, -- legacy account-wide ledger from 2.0.10-2.0.14
    economyStatsByCharacter = {},
    economyZoneStatsByCharacter = {}, -- 2.6.32: zone-specific economy ledger; starts with this version
    economyZoneTrackingStartedAt = 0,
    economyDetailFocusZoneId = 0,
    economyDetailView = "overview",
    economyDetailX = false,
    economyDetailY = false,
    showAllianceTerritoryColors = false, -- 2.6.32 community: original alliance territory overlay
    allianceNeutralWhite = true,
    historyByCharacter = {},
    milestoneStateByCharacter = {},
    historyEnabled = true,
    showMilestones = true,
    historyRetentionDays = 730,
    goalPlannerMode = "near",
    goalPlannerCategory = "all",
    historyMetric = "npcKills",
    historyRangeDays = 30,
    mapLabels203Migrated = false,
    percentColorBlack204Migrated = false,
    percentColorBlack205Migrated = false,
    economyPlayerInit210Migrated = false,
}


local FONT_PROFILES =
{
    classic =
    {
        overlay = "$(ANTIQUE_FONT)|28",
        header = "$(ANTIQUE_FONT)|46",
        questTitle = "$(ANTIQUE_FONT)|20",
        questBody = "$(ANTIQUE_FONT)|18",
    },
    handwritten =
    {
        overlay = "$(HANDWRITTEN_FONT)|30",
        header = "$(HANDWRITTEN_FONT)|48",
        questTitle = "$(HANDWRITTEN_FONT)|22",
        questBody = "$(HANDWRITTEN_FONT)|20",
    },
    scroll =
    {
        overlay = "$(HANDWRITTEN_FONT)|32",
        header = "$(HANDWRITTEN_FONT)|50",
        questTitle = "$(HANDWRITTEN_FONT)|24",
        questBody = "$(HANDWRITTEN_FONT)|21",
    },
    stone =
    {
        overlay = "$(STONE_TABLET_FONT)|28",
        header = "$(STONE_TABLET_FONT)|46",
        questTitle = "$(STONE_TABLET_FONT)|22",
        questBody = "$(STONE_TABLET_FONT)|18",
    },
    standard =
    {
        overlay = "$(MEDIUM_FONT)|28",
        header = "$(MEDIUM_FONT)|46",
        questTitle = "$(MEDIUM_FONT)|21",
        questBody = "$(MEDIUM_FONT)|18",
    },
    bold =
    {
        overlay = "$(BOLD_FONT)|28",
        header = "$(BOLD_FONT)|46",
        questTitle = "$(BOLD_FONT)|21",
        questBody = "$(BOLD_FONT)|18",
    },
    chat =
    {
        overlay = "$(CHAT_FONT)|28",
        header = "$(CHAT_FONT)|46",
        questTitle = "$(CHAT_FONT)|21",
        questBody = "$(CHAT_FONT)|18",
    },
    title =
    {
        overlay = "$(BOLD_FONT)|30",
        header = "$(BOLD_FONT)|50",
        questTitle = "$(BOLD_FONT)|24",
        questBody = "$(MEDIUM_FONT)|18",
    },
    outline =
    {
        overlay = "$(BOLD_FONT)|28|thick-outline",
        header = "$(BOLD_FONT)|46|thick-outline",
        questTitle = "$(BOLD_FONT)|21|thick-outline",
        questBody = "$(BOLD_FONT)|18|thick-outline",
    },
    compact =
    {
        overlay = "$(MEDIUM_FONT)|25",
        header = "$(MEDIUM_FONT)|42",
        questTitle = "$(MEDIUM_FONT)|19",
        questBody = "$(MEDIUM_FONT)|16",
    },
}

local FONT_STYLE_ORDER =
{
    "classic",
    "handwritten",
    "scroll",
    "stone",
    "standard",
    "bold",
    "chat",
    "title",
    "outline",
    "compact",
}

local FONT_STYLE_NAME_KEYS =
{
    classic = "FONT_CLASSIC",
    handwritten = "FONT_HANDWRITTEN",
    scroll = "FONT_SCROLL",
    stone = "FONT_STONE",
    standard = "FONT_STANDARD",
    bold = "FONT_BOLD",
    chat = "FONT_CHAT",
    title = "FONT_TITLE",
    outline = "FONT_OUTLINE",
    compact = "FONT_COMPACT",
}


local AURBIS_SYMBOLIC_ZONE_IDS =
{
    [980] = true, -- Clockwork City
}

-- ESO's Aurbis map uses symbolic realm locations that are not derived from the
-- geographical center of the corresponding zone map. Clockwork City is the
-- known outlier that cannot be projected reliably through universal map
-- coordinates, so use its actual normalized symbol position on the current
-- Aurbis layout. Values are normalized to ZO_WorldMapContainer.
local AURBIS_FIXED_ZONE_POSITIONS =
{
    [980] = { x = 0.3672, y = 0.8294 }, -- Clockwork City
}

local COMPLETION_TYPES =
{
    ZONE_COMPLETION_TYPE_PRIORITY_QUESTS,
    ZONE_COMPLETION_TYPE_WAYSHRINES,
    ZONE_COMPLETION_TYPE_DELVES,
    ZONE_COMPLETION_TYPE_GROUP_DELVES,
    ZONE_COMPLETION_TYPE_POINTS_OF_INTEREST,
    ZONE_COMPLETION_TYPE_STRIKING_LOCALES,
    ZONE_COMPLETION_TYPE_SET_STATIONS,
    ZONE_COMPLETION_TYPE_MUNDUS_STONES,
    ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS,
    ZONE_COMPLETION_TYPE_WORLD_EVENTS,
    ZONE_COMPLETION_TYPE_GROUP_BOSSES,
    ZONE_COMPLETION_TYPE_SKYSHARDS,
    ZONE_COMPLETION_TYPE_MAGES_GUILD_BOOKS,
}

-- Progress sub-pages: zone completion, Collections and Achievements.
-- Keep the API constants as names and resolve them at runtime so a missing or
-- renamed category can never prevent the addon from loading after an ESO update.
-- These collection counters are informational only and NEVER change Tamriel %.
local COLLECTION_STAT_DEFINITIONS =
{
    { typeGlobal = "COLLECTIBLE_CATEGORY_TYPE_MOUNT",                labelKey = "STAT_COLLECTION_MOUNTS" },
    { typeGlobal = "COLLECTIBLE_CATEGORY_TYPE_VANITY_PET",           labelKey = "STAT_COLLECTION_PETS" },
    { typeGlobal = "COLLECTIBLE_CATEGORY_TYPE_COSTUME",              labelKey = "STAT_COLLECTION_COSTUMES" },
    { typeGlobal = "COLLECTIBLE_CATEGORY_TYPE_PERSONALITY",          labelKey = "STAT_COLLECTION_PERSONALITIES" },
    { typeGlobal = "COLLECTIBLE_CATEGORY_TYPE_POLYMORPH",            labelKey = "STAT_COLLECTION_POLYMORPHS" },
    { typeGlobal = "COLLECTIBLE_CATEGORY_TYPE_SKIN",                 labelKey = "STAT_COLLECTION_SKINS" },
    { typeGlobal = "COLLECTIBLE_CATEGORY_TYPE_MEMENTO",              labelKey = "STAT_COLLECTION_MEMENTOS" },
    { typeGlobal = "COLLECTIBLE_CATEGORY_TYPE_EMOTE",                labelKey = "STAT_COLLECTION_EMOTES" },
    { typeGlobal = "COLLECTIBLE_CATEGORY_TYPE_HOUSE",                labelKey = "STAT_COLLECTION_HOUSES" },
    { typeGlobal = "COLLECTIBLE_CATEGORY_TYPE_HAT",                  labelKey = "STAT_COLLECTION_HATS" },
    { typeGlobal = "COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING",         labelKey = "STAT_COLLECTION_BODY_MARKINGS" },
    { typeGlobal = "COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING",         labelKey = "STAT_COLLECTION_HEAD_MARKINGS" },
    { typeGlobal = "COLLECTIBLE_CATEGORY_TYPE_HAIR",                 labelKey = "STAT_COLLECTION_HAIR" },
    { typeGlobal = "COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY",     labelKey = "STAT_COLLECTION_FACIAL_ACCESSORIES" },
    { typeGlobal = "COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT", labelKey = "STAT_COLLECTION_FRAGMENTS" },
}

local COMPLETION_LOCALIZATION_KEYS =
{
    [ZONE_COMPLETION_TYPE_PRIORITY_QUESTS] = "CAT_QUESTS",
    [ZONE_COMPLETION_TYPE_WAYSHRINES] = "CAT_WAYSHRINES",
    [ZONE_COMPLETION_TYPE_DELVES] = "CAT_DELVES",
    [ZONE_COMPLETION_TYPE_GROUP_DELVES] = "CAT_GROUP_DELVES",
    [ZONE_COMPLETION_TYPE_POINTS_OF_INTEREST] = "CAT_POIS",
    [ZONE_COMPLETION_TYPE_STRIKING_LOCALES] = "CAT_STRIKING",
    [ZONE_COMPLETION_TYPE_SET_STATIONS] = "CAT_SET_STATIONS",
    [ZONE_COMPLETION_TYPE_MUNDUS_STONES] = "CAT_MUNDUS",
    [ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS] = "CAT_PUBLIC_DUNGEONS",
    [ZONE_COMPLETION_TYPE_WORLD_EVENTS] = "CAT_WORLD_EVENTS",
    [ZONE_COMPLETION_TYPE_GROUP_BOSSES] = "CAT_WORLD_BOSSES",
    [ZONE_COMPLETION_TYPE_SKYSHARDS] = "CAT_SKYSHARDS",
    [ZONE_COMPLETION_TYPE_MAGES_GUILD_BOOKS] = "CAT_LOREBOOKS",
}

local SIDE_QUEST_CATEGORY_KEY = "side_quests"
local CROWN_QUEST_CATEGORY_KEY = "crown_quests"
local ZONE_STABLE_MOUNT_CATEGORY_KEY = "zone_stable_mount"

-- Update 49 stablemaster mounts that are intentionally tied to specific zones.
-- This is an informational Zone Focus row only; it never changes ESO's native
-- Zone Guide percentage. Zone IDs are stable game identifiers, so the mapping
-- is independent from the client/TPM language.
local ZONE_STABLEMASTER_MOUNTS =
{
    [1011] = { name = "Highland Spotted Lynx", price = 100000 }, -- Summerset
    [888]  = { name = "Highland Spotted Lynx", price = 100000 }, -- Craglorn
    [381]  = { name = "Ja'zennji Siir Fox", price = 50000 }, -- Auridon
    [1261] = { name = "Ja'zennji Siir Fox", price = 50000 }, -- Blackwood
    [108]  = { name = "Noble Riverhold Senche-Lion", price = 50000 }, -- Greenshade
    [20]   = { name = "Noble Riverhold Senche-Lion", price = 50000 }, -- Rivenspire
    [383]  = { name = "Faunfrolic Great Elk", price = 200000 }, -- Grahtwood
    [58]   = { name = "Faunfrolic Great Elk", price = 200000 }, -- Malabal Tor
    [1318] = { name = "Faunfrolic Great Elk", price = 200000 }, -- High Isle
    [382]  = { name = "Senche-Cougar", price = 50000 }, -- Reaper's March
    [1086] = { name = "Spotted Duneracer Senche-raht", price = 200000 }, -- Northern Elsweyr
    [1133] = { name = "Spotted Duneracer Senche-raht", price = 200000 }, -- Southern Elsweyr
    [726]  = { name = "Shadowghost Guar", price = 50000 }, -- Murkmire
    [117]  = { name = "Shadowghost Guar", price = 50000 }, -- Shadowfen
    [41]   = { name = "Shadowghost Guar", price = 50000 }, -- Stonefalls
    [1502] = { name = "Frostborn Durzog Mangler", price = 100000 }, -- Solstice
    [347]  = { name = "Frostborn Durzog Mangler", price = 100000 }, -- Coldharbour
    [1282] = { name = "Frostborn Durzog Mangler", price = 100000 }, -- Fargrave
    [57]   = { name = "Hearthfire Kagouti", price = 100000 }, -- Deshaan
    [1414] = { name = "Rubyflare Torchnix", price = 100000 }, -- Telvanni Peninsula
    [849]  = { name = "Rubyflare Torchnix", price = 100000 }, -- Vvardenfell
    [103]  = { name = "Yorgrim River Ram", price = 100000 }, -- The Rift
    [101]  = { name = "Yorgrim River Ram", price = 100000 }, -- Eastmarch
    [19]   = { name = "Yorgrim River Ram", price = 100000 }, -- Stormhaven
    [1160] = { name = "Ashbone Sabre Cat", price = 100000 }, -- Western Skyrim
    [92]   = { name = "Ashbone Sabre Cat", price = 100000 }, -- Bangkorai
    [1207] = { name = "Snow Bear", price = 50000 }, -- The Reach
    [684]  = { name = "Snow Bear", price = 50000 }, -- Wrothgar
    [3]    = { name = "Bleakrock Snowdog", price = 50000 }, -- Glenumbra
    [1383] = { name = "Bleakrock Snowdog", price = 50000 }, -- Galen
    [104]  = { name = "Hammerfell Camel", price = 50000 }, -- Alik'r Desert
    [816]  = { name = "Hammerfell Camel", price = 50000 }, -- Hew's Bane
    [823]  = { name = "Sapiarchic Senche-Serval", price = 100000 }, -- Gold Coast
    [1443] = { name = "Sapiarchic Senche-Serval", price = 100000 }, -- West Weald
    [980]  = { name = "Ebon Dwarven Horse", price = 400000 }, -- Clockwork City
}

local STATISTICS_CATEGORY_ICON_TEXTURES =
{
    [ZONE_COMPLETION_TYPE_PRIORITY_QUESTS] = "TamrielProgressMap/art/cat_quests.dds",
    [ZONE_COMPLETION_TYPE_WAYSHRINES] = "TamrielProgressMap/art/cat_wayshrine.dds",
    [ZONE_COMPLETION_TYPE_DELVES] = "TamrielProgressMap/art/cat_delve.dds",
    [ZONE_COMPLETION_TYPE_GROUP_DELVES] = "TamrielProgressMap/art/cat_groupdelve.dds",
    [ZONE_COMPLETION_TYPE_POINTS_OF_INTEREST] = "TamrielProgressMap/art/cat_poi.dds",
    [ZONE_COMPLETION_TYPE_STRIKING_LOCALES] = "TamrielProgressMap/art/cat_striking.dds",
    [ZONE_COMPLETION_TYPE_SET_STATIONS] = "TamrielProgressMap/art/cat_setstation.dds",
    [ZONE_COMPLETION_TYPE_MUNDUS_STONES] = "TamrielProgressMap/art/cat_mundus.dds",
    [ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS] = "TamrielProgressMap/art/cat_publicdungeon.dds",
    [ZONE_COMPLETION_TYPE_WORLD_EVENTS] = "TamrielProgressMap/art/cat_event.dds",
    [ZONE_COMPLETION_TYPE_GROUP_BOSSES] = "TamrielProgressMap/art/cat_boss.dds",
    [ZONE_COMPLETION_TYPE_SKYSHARDS] = "TamrielProgressMap/art/cat_skyshard.dds",
    [ZONE_COMPLETION_TYPE_MAGES_GUILD_BOOKS] = "TamrielProgressMap/art/cat_book.dds",
    [SIDE_QUEST_CATEGORY_KEY] = "TamrielProgressMap/art/cat_sidequests.dds",
    [CROWN_QUEST_CATEGORY_KEY] = "TamrielProgressMap/art/cat_crown.dds",
    [ZONE_STABLE_MOUNT_CATEGORY_KEY] = "TamrielProgressMap/art/cat_crown.dds",
}
local ESO_GOLD_HEX = "E6C45C"
local SIDE_QUEST_SCAN_MAX_ID = 12000
local STATISTICS_VISIBLE_ZONE_ROWS = 7
local STATISTICS_PERCENT_GRAY_HEX = "B8B4A8"
local HISTORY_CHECKPOINT_MS = 600000 -- 10 minutes; SavedVariables are still physically written by ESO itself.
local HISTORY_RETENTION_DAYS = 730
local HISTORY_MAX_SESSIONS = 80
local HISTORY_MAX_CHART_POINTS = 60
local HISTORY_SAMPLE_INTERVAL_SECONDS = 300 -- detailed recent chart cadence; large changes can create an earlier point.
local HISTORY_SAMPLE_RETENTION_DAYS = 45 -- older history uses daily close + daily high/low.
local HISTORY_MAX_SAMPLES = 1400
local SESSION_CONTINUITY_SECONDS = 300

local GOAL_PLANNER_MODES = { "near", "recommended" }
local GOAL_CATEGORY_FILTERS =
{
    { key = "all", completionType = nil, labelKey = "GOAL_CATEGORY_ALL" },
    { key = "quests", completionType = ZONE_COMPLETION_TYPE_PRIORITY_QUESTS, labelKey = "GOAL_CATEGORY_QUESTS" },
    { key = "skyshards", completionType = ZONE_COMPLETION_TYPE_SKYSHARDS, labelKey = "GOAL_CATEGORY_SKYSHARDS" },
    { key = "bosses", completionType = ZONE_COMPLETION_TYPE_GROUP_BOSSES, labelKey = "GOAL_CATEGORY_BOSSES" },
}
local HISTORY_RANGES = { 7, 30, 90, 365, 730 }

local function Round(value)
    return math.floor((value or 0) + 0.5)
end

local function Clamp(value, minimum, maximum)
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

local function RGBToHex(r, g, b)
    local function Byte(value)
        return Clamp(math.floor(((tonumber(value) or 0) * 255) + 0.5), 0, 255)
    end
    return string.format("%02X%02X%02X", Byte(r), Byte(g), Byte(b))
end

local function HexToRGB(hex)
    hex = tostring(hex or "FFFFFF")
    if #hex < 6 then hex = "FFFFFF" end
    local r = (tonumber(string.sub(hex, 1, 2), 16) or 255) / 255
    local g = (tonumber(string.sub(hex, 3, 4), 16) or 255) / 255
    local b = (tonumber(string.sub(hex, 5, 6), 16) or 255) / 255
    return r, g, b
end

local function ScaleFontSpec(fontSpec, scalePercent)
    local scale = Clamp(tonumber(scalePercent) or 100, 70, 160) / 100
    local replaced = false
    return string.gsub(fontSpec or "", "|(%d+)", function(size)
        if replaced then return "|" .. size end
        replaced = true
        local scaled = Clamp(Round((tonumber(size) or 18) * scale), 10, 80)
        return "|" .. tostring(scaled)
    end, 1)
end

local function GetPercentColor(percent)
    if percent >= 100 then
        return "66FF66"
    elseif percent >= 75 then
        return "B8E65B"
    elseif percent >= 50 then
        return "FFE066"
    elseif percent >= 25 then
        return "FFB347"
    end
    return "FF6B6B"
end

function TPM:GetDisplayPercentColor(percent)
    local mode = self and self.saved and self.saved.percentColorMode or "black"
    if mode == "black" then
        return "000000"
    elseif mode == "brown" then
        return "5A3A22"
    elseif mode == "gold" then
        return "C9A24A"
    elseif mode == "custom" then
        local color = self.saved and self.saved.customPercentColor or DEFAULTS.customPercentColor
        return RGBToHex(color.r, color.g, color.b)
    end
    return GetPercentColor(percent)
end

function TPM:GetStatisticsPercentTextColor(percent)
    percent = Clamp(tonumber(percent) or 0, 0, 100)
    if percent >= 100 then return ESO_GOLD_HEX end
    return STATISTICS_PERCENT_GRAY_HEX
end

function TPM:GetStatisticsProgressColor(percent)
    -- Deliberately darker than the map-marker palette. The journal uses one
    -- continuous red -> ESO-gold ramp so the bars remain readable on the dark
    -- background without becoming neon.
    local t = Clamp(tonumber(percent) or 0, 0, 100) / 100
    local startR, startG, startB = 0.46, 0.095, 0.065
    local endR, endG, endB = HexToRGB(ESO_GOLD_HEX)
    local r = startR + ((endR - startR) * t)
    local g = startG + ((endG - startG) * t)
    local b = startB + ((endB - startB) * t)
    return r, g, b
end

local function FormatNumber(value)
    value = math.max(0, Round(tonumber(value) or 0))
    if type(ZO_CommaDelimitNumber) == "function" then
        return ZO_CommaDelimitNumber(value)
    end
    return tostring(value)
end

function TPM:GetPlayerProgressData()
    local level = type(GetUnitLevel) == "function" and (GetUnitLevel("player") or 0) or 0
    local cp = 0
    if type(GetPlayerChampionPointsEarned) == "function" then
        cp = GetPlayerChampionPointsEarned() or 0
    elseif type(GetUnitChampionPoints) == "function" then
        cp = GetUnitChampionPoints("player") or 0
    end

    local canGainCP = false
    if type(CanUnitGainChampionPoints) == "function" then
        canGainCP = CanUnitGainChampionPoints("player") == true
    elseif level >= 50 then
        canGainCP = true
    end

    local maxChampionPoints = 0
    if type(GetMaxSpendableChampionPointsInAttribute) == "function" then
        local perAttribute = GetMaxSpendableChampionPointsInAttribute() or 0
        if perAttribute > 0 then maxChampionPoints = perAttribute * 3 end
    end

    local atChampionCap = canGainCP and maxChampionPoints > 0 and cp >= maxChampionPoints
    local current, maximum = 0, 0
    if atChampionCap then
        current, maximum = 1, 1
    elseif canGainCP and type(GetPlayerChampionXP) == "function" then
        current = GetPlayerChampionXP() or 0
        if type(GetNumChampionXPInChampionPoint) == "function" then
            maximum = GetNumChampionXPInChampionPoint(math.max(cp, 1)) or 0
        elseif type(GetChampionXPInRank) == "function" then
            maximum = GetChampionXPInRank(math.max(cp, 1)) or 0
        end
    else
        if type(GetUnitXP) == "function" then current = GetUnitXP("player") or 0 end
        if type(GetUnitXPMax) == "function" then maximum = GetUnitXPMax("player") or 0 end
    end

    local percent = atChampionCap and 100 or 0
    if not atChampionCap and maximum > 0 then
        percent = Clamp(Round((current / maximum) * 100), 0, 100)
    end

    return {
        level = level,
        championPoints = cp,
        maxChampionPoints = maxChampionPoints,
        current = current,
        maximum = maximum,
        percent = percent,
        isChampionProgress = canGainCP,
        atChampionCap = atChampionCap,
    }
end

function TPM:GetCurrentCharacterStatsKey()
    if type(GetCurrentCharacterId) == "function" then
        local characterId = GetCurrentCharacterId()
        if characterId and characterId ~= 0 then
            return tostring(characterId)
        end
    end
    local name = type(GetUnitName) == "function" and (GetUnitName("player") or "") or ""
    if name ~= "" then return name end
    return "player"
end

local function TPM_Now()
    if type(GetTimeStamp) == "function" then
        return math.max(0, tonumber(GetTimeStamp()) or 0)
    end
    return 0
end

function TPM:GetPlayerCombatStats(characterKey)
    if not self.saved then
        return { pvpKills = 0, pvpDeaths = 0, npcKills = 0, pveDeaths = 0, bossKills = 0, playSeconds = 0, esoPlayedSeconds = 0 }
    end
    if type(self.saved.combatStatsByCharacter) ~= "table" then
        self.saved.combatStatsByCharacter = {}
    end

    local function NormalizeCounter(value)
        local numberValue = tonumber(value)
        if numberValue == nil or numberValue ~= numberValue or numberValue <= 0 then return 0 end
        return math.floor(numberValue + 0.5)
    end

    local key = characterKey or self:GetCurrentCharacterStatsKey()
    local stats = self.saved.combatStatsByCharacter[key]
    if type(stats) ~= "table" then
        local startedAt = 0
        if type(GetTimeStamp) == "function" then
            startedAt = tonumber(GetTimeStamp()) or 0
        end
        local startLevel = 1
        if type(GetUnitLevel) == "function" then
            startLevel = tonumber(GetUnitLevel("player")) or 1
        end
        stats = {
            pvpKills = 0,
            pvpDeaths = 0,
            npcKills = 0,
            pveDeaths = 0,
            bossKills = 0,
            playSeconds = 0,
            esoPlayedSeconds = 0,
            esoPlayedBaselineSeconds = nil,
            trackingVersion = VERSION,
            trackingStartedAt = math.max(0, startedAt),
            trackingStartLevel = math.max(1, math.floor(startLevel + 0.5)),
        }
        self.saved.combatStatsByCharacter[key] = stats
    end

    -- Lifetime combat counters are never reset automatically. Invalid/legacy
    -- SavedVariable values are repaired without relying on any later helper.
    stats.pvpKills = NormalizeCounter(stats.pvpKills)
    stats.pvpDeaths = NormalizeCounter(stats.pvpDeaths)
    stats.npcKills = NormalizeCounter(stats.npcKills)
    stats.pveDeaths = NormalizeCounter(stats.pveDeaths)
    stats.bossKills = NormalizeCounter(stats.bossKills)
    stats.playSeconds = NormalizeCounter(stats.playSeconds)
    stats.esoPlayedSeconds = NormalizeCounter(stats.esoPlayedSeconds)
    if stats.esoPlayedBaselineSeconds ~= nil then
        stats.esoPlayedBaselineSeconds = NormalizeCounter(stats.esoPlayedBaselineSeconds)
    end
    stats.trackingVersion = stats.trackingVersion or VERSION

    if tonumber(stats.trackingStartedAt) == nil then
        if type(GetTimeStamp) == "function" then
            stats.trackingStartedAt = math.max(0, tonumber(GetTimeStamp()) or 0)
        else
            stats.trackingStartedAt = 0
        end
    end
    local startLevel = tonumber(stats.trackingStartLevel)
    if startLevel == nil then
        startLevel = (type(GetUnitLevel) == "function" and tonumber(GetUnitLevel("player"))) or 1
    end
    stats.trackingStartLevel = math.max(1, math.floor((startLevel or 1) + 0.5))
    return stats
end

function TPM:SyncCurrentEsoPlayedTime()
    local key = self:GetCurrentCharacterStatsKey()
    local stats = self:GetPlayerCombatStats(key)
    if type(GetSecondsPlayed) == "function" then
        local ok, value = pcall(GetSecondsPlayed)
        if ok and type(value) == "number" and value >= 0 then
            local seconds = math.max(0, Round(value))
            stats.esoPlayedSeconds = math.max(stats.esoPlayedSeconds or 0, seconds)
            -- Preserve the locally tracked 3.0.0 time when migrating: derive a
            -- baseline from ESO's lifetime value instead of resetting the counter.
            if stats.esoPlayedBaselineSeconds == nil then
                stats.esoPlayedBaselineSeconds = math.max(0, seconds - (stats.playSeconds or 0))
            end
        end
    end
    return stats.esoPlayedSeconds or 0
end

function TPM:GetEsoPlayedSeconds()
    return self:SyncCurrentEsoPlayedTime()
end

function TPM:GetKnownAccountEsoPlayedSeconds()
    self:SyncCurrentEsoPlayedTime()
    local total = 0
    for _, stats in pairs((self.saved and self.saved.combatStatsByCharacter) or {}) do
        if type(stats) == "table" then
            total = total + math.max(0, Round(tonumber(stats.esoPlayedSeconds) or 0))
        end
    end
    return total
end

function TPM:GetPlayerCombatStatsView(characterKey)
    local stats = self:GetPlayerCombatStats(characterKey)
    local kd
    if stats.pvpDeaths <= 0 then
        kd = stats.pvpKills > 0 and stats.pvpKills or 0
    else
        kd = stats.pvpKills / stats.pvpDeaths
    end
    return {
        pvpKills = stats.pvpKills,
        pvpDeaths = stats.pvpDeaths,
        npcKills = stats.npcKills,
        pveDeaths = stats.pveDeaths or 0,
        bossKills = stats.bossKills,
        playSeconds = stats.playSeconds or 0,
        esoPlayedSeconds = stats.esoPlayedSeconds or 0,
        esoPlayedBaselineSeconds = stats.esoPlayedBaselineSeconds,
        kd = kd,
        trackingVersion = stats.trackingVersion or VERSION,
    }
end

function TPM:QueueCombatHistoryCheckpoint()
    if not self.saved or self.saved.historyEnabled == false or self.combatHistoryCheckpointQueued then return end
    self.combatHistoryCheckpointQueued = true
    zo_callLater(function()
        TPM.combatHistoryCheckpointQueued = false
        if not TPM.saved or TPM.saved.historyEnabled == false then return end
        local snapshot = TPM:CaptureHistorySnapshot(false)
        TPM:CheckpointHistory("combat", false, snapshot)
        if TPM.activeTrackedActivity and snapshot then
            TPM.activeTrackedActivity.lastSnapshot = snapshot
            TPM.activeTrackedActivity.lastSeenAt = snapshot.timestamp or TPM_Now()
        end
        if TPM.statisticsWindow and not TPM.statisticsWindow:IsHidden()
            and TPM.saved.statisticsPage == "history" then
            TPM:RefreshHistoryStatisticsPage()
        end
    end, 350)
end

function TPM:IncrementPlayerCombatStat(field, amount)
    local stats = self:GetPlayerCombatStats()
    if stats[field] == nil then return end
    stats[field] = math.max(0, Round((tonumber(stats[field]) or 0) + (tonumber(amount) or 1)))
    if field == "npcKills" or field == "pveDeaths" or field == "bossKills"
        or field == "pvpKills" or field == "pvpDeaths" then
        self:QueueCombatHistoryCheckpoint()
    end
    if self.statisticsWindow and not self.statisticsWindow:IsHidden() and self.saved then
        if self.saved.statisticsPage == "history" then
            self:RefreshHistoryStatisticsPage()
        end
    end
end

-- v2.0.15 Economy journal ------------------------------------------------------
-- Current balances come directly from ESO. Received/spent totals are kept per
-- active character from 2.0.15 onward. ESO does not expose a complete historic
-- transaction ledger retroactively, so older account-wide totals are not
-- assigned to a character. Personal-bank balances remain account-wide by ESO design.
function TPM:GetEconomyCurrencyDefinitions()
    if self.economyCurrencyDefinitions then return self.economyCurrencyDefinitions end

    local definitions = {}
    local function Add(key, currencyType, locationMode, fallbackKey)
        if type(currencyType) ~= "number" then return end
        definitions[#definitions + 1] = {
            key = key,
            currencyType = currencyType,
            locationMode = locationMode or "account",
            fallbackKey = fallbackKey,
        }
    end

    Add("gold", _G.CURT_MONEY, "walletBank", "ECON_GOLD")
    Add("crowns", _G.CURT_CROWNS, "account", "ECON_CROWNS")
    Add("crownGems", _G.CURT_CROWN_GEMS, "account", "ECON_CROWN_GEMS")
    Add("tradeBars", _G.CURT_TRADE_BARS, "account", "ECON_TRADE_BARS")
    Add("seals", _G.CURT_SEALS or _G.CURT_ENDEAVOR_SEALS, "account", "ECON_SEALS")
    Add("alliancePoints", _G.CURT_ALLIANCE_POINTS, "walletBank", "ECON_ALLIANCE_POINTS")
    Add("telVar", _G.CURT_TELVAR_STONES, "walletBank", "ECON_TELVAR")
    Add("writVouchers", _G.CURT_WRIT_VOUCHERS, "walletBank", "ECON_WRIT_VOUCHERS")
    Add("transmute", _G.CURT_TRANSMUTE_CRYSTALS or _G.CURT_CHAOTIC_CREATIA, "account", "ECON_TRANSMUTE")
    Add("undauntedKeys", _G.CURT_UNDAUNTED_KEYS, "account", "ECON_UNDAUNTED_KEYS")
    Add("archivalFortunes", _G.CURT_ARCHIVAL_FORTUNES, "account", "ECON_ARCHIVAL_FORTUNES")
    Add("tomePoints", _G.CURT_TOME_POINTS, "account", "ECON_TOME_POINTS")

    self.economyCurrencyDefinitions = definitions
    self.economyCurrencyByType = {}
    for _, definition in ipairs(definitions) do
        self.economyCurrencyByType[definition.currencyType] = definition
    end
    return definitions
end

function TPM:GetEconomyCurrencyName(definition)
    if not definition then return "" end
    -- Keep currency labels in the addon's selected language instead of forcing
    -- the ESO client language. All supported definitions have localized names.
    local localized = definition.fallbackKey and self:L(definition.fallbackKey) or ""
    if localized ~= "" and localized ~= definition.fallbackKey then return localized end
    if type(GetCurrencyName) == "function" then
        local ok, name = pcall(GetCurrencyName, definition.currencyType, false, false)
        if ok and type(name) == "string" and name ~= "" then return name end
    end
    return tostring(definition.key or "")
end

local function SafeCurrencyAmount(currencyType, location)
    if type(GetCurrencyAmount) ~= "function" or type(currencyType) ~= "number" or type(location) ~= "number" then
        return 0
    end
    local ok, amount = pcall(GetCurrencyAmount, currencyType, location)
    if not ok then return 0 end
    return math.max(0, Round(tonumber(amount) or 0))
end

function TPM:GetEconomyPrimaryLocation(definition)
    if not definition then return nil end

    -- ESO's own wallet asks the API where a currency is stored instead of
    -- hard-coding every account/character currency. Keep a fallback for older
    -- API versions and compatibility aliases.
    if type(GetCurrencyPlayerStoredLocation) == "function" then
        local ok, location = pcall(GetCurrencyPlayerStoredLocation, definition.currencyType)
        if ok and type(location) == "number" then
            return location
        end
    end

    if definition.locationMode == "walletBank" then
        return _G.CURRENCY_LOCATION_CHARACTER
    end
    return _G.CURRENCY_LOCATION_ACCOUNT or _G.CURRENCY_LOCATION_CHARACTER
end


function TPM:IsEconomyCurrencyBankable(definition)
    if not definition or type(definition.currencyType) ~= "number" then return false end
    local bankLocation = _G.CURRENCY_LOCATION_BANK
    if type(bankLocation) == "number" and type(CanCurrencyBeStoredInLocation) == "function" then
        local ok, canStore = pcall(CanCurrencyBeStoredInLocation, definition.currencyType, bankLocation)
        if ok then return canStore == true end
    end
    -- Fallback for API variants where CanCurrencyBeStoredInLocation is not exposed.
    return definition.locationMode == "walletBank"
end

function TPM:GetEconomyCurrentAmounts(definition)
    local amounts = { character = 0, bank = 0, total = 0, current = 0 }
    if not definition then return amounts end

    if self:IsEconomyCurrencyBankable(definition) then
        if type(_G.CURRENCY_LOCATION_CHARACTER) == "number" then
            amounts.character = SafeCurrencyAmount(definition.currencyType, _G.CURRENCY_LOCATION_CHARACTER)
        end
        if type(_G.CURRENCY_LOCATION_BANK) == "number" then
            amounts.bank = SafeCurrencyAmount(definition.currencyType, _G.CURRENCY_LOCATION_BANK)
        end
        amounts.total = amounts.character + amounts.bank
        amounts.current = amounts.total
        return amounts
    end

    local primaryLocation = self:GetEconomyPrimaryLocation(definition)
    if type(primaryLocation) == "number" then
        amounts.current = SafeCurrencyAmount(definition.currencyType, primaryLocation)
        amounts.total = amounts.current
        if primaryLocation == _G.CURRENCY_LOCATION_CHARACTER then
            amounts.character = amounts.current
        elseif primaryLocation == _G.CURRENCY_LOCATION_BANK then
            amounts.bank = amounts.current
        end
    end
    return amounts
end

function TPM:GetEconomyCurrentAmount(definition)
    return self:GetEconomyCurrentAmounts(definition).current
end

function TPM:GetEconomyStats()
    if not self.saved then return { trackingVersion = "2.0.15", currencies = {} } end
    if type(self.saved.economyStatsByCharacter) ~= "table" then
        self.saved.economyStatsByCharacter = {}
    end
    if type(self.saved.historyByCharacter) ~= "table" then
        self.saved.historyByCharacter = {}
    end
    if type(self.saved.milestoneStateByCharacter) ~= "table" then
        self.saved.milestoneStateByCharacter = {}
    end


    -- 2.6.46: preserve the oldest Economy cache if a previous build stored the
    -- character under the fallback name/"player" key. Never add caches together:
    -- pick the richest existing cache only when the current ID cache is missing
    -- or contains less historical activity. This prevents duplicate totals.
    local function EconomyCacheScore(cache)
        if type(cache) ~= "table" or type(cache.currencies) ~= "table" then return 0 end
        local score = 0
        for _, e in pairs(cache.currencies) do
            if type(e) == "table" then
                score = score + math.max(0, tonumber(e.received) or 0)
                score = score + math.max(0, tonumber(e.spent) or 0)
                score = score + math.max(0, tonumber(e.fenceSales) or 0)
                score = score + math.max(0, tonumber(e.stolenGold) or 0)
                score = score + math.max(0, tonumber(e.bountyPaid) or 0)
            end
        end
        return score
    end

    local currentKey = self:GetCurrentCharacterStatsKey()
    local currentCache = self.saved.economyStatsByCharacter[currentKey]
    local bestCache, bestScore = currentCache, EconomyCacheScore(currentCache)
    local fallbackKeys = { "player" }
    local rawName = type(GetUnitName) == "function" and (GetUnitName("player") or "") or ""
    if rawName ~= "" then
        fallbackKeys[#fallbackKeys + 1] = rawName
        if type(zo_strformat) == "function" then
            local formatted = zo_strformat("<<C:1>>", rawName)
            if formatted and formatted ~= "" then fallbackKeys[#fallbackKeys + 1] = formatted end
        end
    end
    for _, legacyKey in ipairs(fallbackKeys) do
        if legacyKey ~= currentKey then
            local candidate = self.saved.economyStatsByCharacter[legacyKey]
            local score = EconomyCacheScore(candidate)
            if score > bestScore then
                bestCache, bestScore = candidate, score
            end
        end
    end
    if bestCache and bestCache ~= currentCache then
        self.saved.economyStatsByCharacter[currentKey] = bestCache
    end
    local key = self:GetCurrentCharacterStatsKey()
    local stats = self.saved.economyStatsByCharacter[key]
    if type(stats) ~= "table" then
        stats = { trackingVersion = "2.0.15", currencies = {} }
        self.saved.economyStatsByCharacter[key] = stats
    end
    stats.trackingVersion = stats.trackingVersion or "2.0.15"
    if type(stats.currencies) ~= "table" then stats.currencies = {} end

    local characterName = type(GetUnitName) == "function" and (GetUnitName("player") or "") or ""
    if type(zo_strformat) == "function" and characterName ~= "" then
        characterName = zo_strformat("<<C:1>>", characterName)
    end
    stats.characterName = characterName ~= "" and characterName or stats.characterName or self:L("STAT_PLAYER_UNKNOWN")

    for _, definition in ipairs(self:GetEconomyCurrencyDefinitions()) do
        local entry = stats.currencies[definition.key]
        if type(entry) ~= "table" then
            entry = { received = 0, spent = 0, bankDeposited = 0, bankWithdrawn = 0, fenceSales = 0, stolenGold = 0 }
            stats.currencies[definition.key] = entry
        end
        entry.received = math.max(0, Round(tonumber(entry.received) or 0))
        entry.spent = math.max(0, Round(tonumber(entry.spent) or 0))
        entry.bankDeposited = math.max(0, Round(tonumber(entry.bankDeposited) or 0))
        entry.bankWithdrawn = math.max(0, Round(tonumber(entry.bankWithdrawn) or 0))
        if definition.key == "gold" then
            entry.fenceSales = math.max(0, Round(tonumber(entry.fenceSales) or 0))
            entry.stolenGold = math.max(0, Round(tonumber(entry.stolenGold) or 0))
            entry.bountyPaid = math.max(0, Round(tonumber(entry.bountyPaid) or 0))
            entry.crimeTrackingVersion = entry.crimeTrackingVersion or "3.4.24"
            entry.bountyTrackingVersion = entry.bountyTrackingVersion or "2.6.22"
        end
    end
    return stats
end


-- v2.6.32 Zone Economy ---------------------------------------------------------
-- Zone ledgers intentionally start with 2.6.32. Existing global Economy totals
-- remain untouched because ESO cannot reconstruct historical transactions by zone.
function TPM:GetEconomyTrackingZoneId()
    if type(GetUnitZoneIndex) ~= "function" or type(GetZoneId) ~= "function" then return 0 end
    local zoneIndex = GetUnitZoneIndex("player")
    if not zoneIndex or zoneIndex <= 0 then return 0 end
    local zoneId = tonumber(GetZoneId(zoneIndex)) or 0
    if zoneId <= 0 then return 0 end
    -- Prefer the stable parent zone for interiors/delves when ESO exposes it.
    if type(GetParentZoneId) == "function" then
        local parentId = tonumber(GetParentZoneId(zoneId)) or 0
        if parentId > 0 then zoneId = parentId end
    end
    return zoneId
end

function TPM:GetEconomyZoneStore()
    if not self.saved then return nil end
    if type(self.saved.economyZoneStatsByCharacter) ~= "table" then
        self.saved.economyZoneStatsByCharacter = {}
    end
    if not tonumber(self.saved.economyZoneTrackingStartedAt) or tonumber(self.saved.economyZoneTrackingStartedAt) <= 0 then
        self.saved.economyZoneTrackingStartedAt = (type(GetTimeStamp) == "function" and GetTimeStamp()) or 0
    end
    local charKey = self:GetCurrentCharacterStatsKey()
    local store = self.saved.economyZoneStatsByCharacter[charKey]
    if type(store) ~= "table" then
        store = { trackingVersion = "2.6.32", zones = {} }
        self.saved.economyZoneStatsByCharacter[charKey] = store
    end
    if type(store.zones) ~= "table" then store.zones = {} end
    return store
end

function TPM:GetEconomyZoneEntry(zoneId, create)
    zoneId = tonumber(zoneId) or 0
    if zoneId <= 0 then return nil end
    local store = self:GetEconomyZoneStore()
    if not store then return nil end
    local key = tostring(zoneId)
    local entry = store.zones[key]
    if type(entry) ~= "table" and create then
        entry = {
            zoneId = zoneId, received = 0, spent = 0, bankDeposited = 0, bankWithdrawn = 0,
            fenceSales = 0, stolenGold = 0, bountyPaid = 0, transactions = 0,
        }
        store.zones[key] = entry
    end
    if type(entry) == "table" then
        for _, field in ipairs({"received","spent","bankDeposited","bankWithdrawn","fenceSales","stolenGold","bountyPaid","transactions"}) do
            entry[field] = math.max(0, Round(tonumber(entry[field]) or 0))
        end
    end
    return entry
end

function TPM:RecordEconomyZoneDelta(delta, reason)
    delta = tonumber(delta) or 0
    if delta == 0 then return end
    local zoneId = self:GetEconomyTrackingZoneId()
    local entry = self:GetEconomyZoneEntry(zoneId, true)
    if not entry then return end
    entry.transactions = (entry.transactions or 0) + 1
    if delta > 0 then entry.received = (entry.received or 0) + delta
    else entry.spent = (entry.spent or 0) + math.abs(delta) end
    if delta > 0 then
        if _G.CURRENCY_CHANGE_REASON_SELL_STOLEN and reason == _G.CURRENCY_CHANGE_REASON_SELL_STOLEN then
            entry.fenceSales = (entry.fenceSales or 0) + delta
        elseif (_G.CURRENCY_CHANGE_REASON_LOOT_STOLEN and reason == _G.CURRENCY_CHANGE_REASON_LOOT_STOLEN)
            or (_G.CURRENCY_CHANGE_REASON_PICKPOCKET and reason == _G.CURRENCY_CHANGE_REASON_PICKPOCKET) then
            entry.stolenGold = (entry.stolenGold or 0) + delta
        end
    end
end

function TPM:RecordEconomyZoneBankTransfer(amount, isDeposit)
    amount = math.max(0, tonumber(amount) or 0)
    if amount <= 0 then return end
    local entry = self:GetEconomyZoneEntry(self:GetEconomyTrackingZoneId(), true)
    if not entry then return end
    if isDeposit then entry.bankDeposited = (entry.bankDeposited or 0) + amount
    else entry.bankWithdrawn = (entry.bankWithdrawn or 0) + amount end
end

function TPM:GetEconomyZoneName(zoneId)
    zoneId = tonumber(zoneId) or 0
    if zoneId <= 0 then return self:L("ECON_DETAIL_ALL_TAMRIEL") end

    -- Do not call the later local SafeZoneName() helper here: this Economy
    -- function is defined earlier in the file, so that local is not in lexical
    -- scope yet. Resolve the TPM-selected language directly through LibZone.
    local lang = self.langCode or "en"
    local libZone = _G.LibZone

    if libZone then
        local namesByLanguage = libZone.preloadedZoneNames
        local languageNames = namesByLanguage and namesByLanguage[lang]
        local localizedName = languageNames and languageNames[zoneId]
        if type(localizedName) == "string" and localizedName ~= "" then
            return localizedName
        end

        local savedLocalized = libZone.localizedZoneData and libZone.localizedZoneData[lang]
        localizedName = savedLocalized and savedLocalized[zoneId]
        if type(localizedName) == "string" and localizedName ~= "" then
            return localizedName
        end
    end

    -- Safe fallback for a new zone not yet known to LibZone.
    local name = type(GetZoneNameById) == "function" and GetZoneNameById(zoneId) or ""
    if name and name ~= "" then
        if type(ZO_CachedStrFormat) == "function" and type(SI_ZONE_NAME) ~= "nil" then
            local ok, formatted = pcall(ZO_CachedStrFormat, SI_ZONE_NAME, name)
            if ok and formatted and formatted ~= "" then return formatted end
        end
        if type(zo_strformat) == "function" then
            local ok, formatted = pcall(zo_strformat, "<<C:1>>", name)
            if ok and formatted and formatted ~= "" then return formatted end
        end
        return name
    end

    return tostring(zoneId)
end

function TPM:GetEconomyZoneChoices()
    local choices = { { zoneId = 0, name = self:L("ECON_DETAIL_ALL_TAMRIEL") } }
    local seen = {}

    -- Use TPM's already validated progress-zone catalogue so the selector is
    -- useful immediately after installation instead of only after a purchase.
    for zoneId in pairs(self:GetAllProgressZoneIds() or {}) do
        zoneId = tonumber(zoneId) or 0
        if zoneId > 0 and not seen[zoneId] then
            seen[zoneId] = true
            choices[#choices + 1] = { zoneId = zoneId, name = self:GetEconomyZoneName(zoneId) }
        end
    end

    -- Keep recorded zones available even if an unusual zone is not part of the
    -- normal completion catalogue.
    local store = self:GetEconomyZoneStore()
    for _, entry in pairs((store and store.zones) or {}) do
        local zid = tonumber(entry.zoneId) or 0
        if zid > 0 and not seen[zid] then
            seen[zid] = true
            choices[#choices + 1] = { zoneId = zid, name = self:GetEconomyZoneName(zid) }
        end
    end

    table.sort(choices, function(a,b)
        if a.zoneId == 0 then return true end
        if b.zoneId == 0 then return false end
        return string.lower(a.name or "") < string.lower(b.name or "")
    end)
    return choices
end

function TPM:GetEconomyDetailAggregate(zoneId)
    local result = { received=0, spent=0, bankDeposited=0, bankWithdrawn=0, fenceSales=0, stolenGold=0, bountyPaid=0, transactions=0 }
    local store = self:GetEconomyZoneStore()
    if not store then return result end
    for _, e in pairs(store.zones or {}) do
        if (tonumber(zoneId) or 0) == 0 or tonumber(e.zoneId) == tonumber(zoneId) then
            for k in pairs(result) do result[k] = result[k] + math.max(0, tonumber(e[k]) or 0) end
        end
    end
    result.net = result.received - result.spent
    return result
end

function TPM:IsEconomyBankTransferReason(reason)
    if _G.CURRENCY_CHANGE_REASON_BANK_DEPOSIT and reason == _G.CURRENCY_CHANGE_REASON_BANK_DEPOSIT then return true end
    if _G.CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL and reason == _G.CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL then return true end
    if _G.CURRENCY_CHANGE_REASON_GUILD_BANK_DEPOSIT and reason == _G.CURRENCY_CHANGE_REASON_GUILD_BANK_DEPOSIT then return true end
    if _G.CURRENCY_CHANGE_REASON_GUILD_BANK_WITHDRAWAL and reason == _G.CURRENCY_CHANGE_REASON_GUILD_BANK_WITHDRAWAL then return true end
    return false
end

function TPM:RecordEconomyPersonalBankTransfer(definition, currencyLocation, newAmount, oldAmount, reason)
    if not definition or not self:IsEconomyCurrencyBankable(definition) then return false end
    if type(_G.CURRENCY_LOCATION_CHARACTER) ~= "number" or currencyLocation ~= _G.CURRENCY_LOCATION_CHARACTER then
        return false
    end

    local delta = (tonumber(newAmount) or 0) - (tonumber(oldAmount) or 0)
    local isDeposit = _G.CURRENCY_CHANGE_REASON_BANK_DEPOSIT and reason == _G.CURRENCY_CHANGE_REASON_BANK_DEPOSIT
    local isWithdrawal = _G.CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL and reason == _G.CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL
    if not isDeposit and not isWithdrawal then return false end

    local stats = self:GetEconomyStats()
    local entry = stats.currencies and stats.currencies[definition.key]
    if not entry then return true end
    if isDeposit and delta < 0 then
        entry.bankDeposited = math.max(0, Round((tonumber(entry.bankDeposited) or 0) + math.abs(delta)))
        self:RecordEconomyZoneBankTransfer(math.abs(delta), true)
    elseif isWithdrawal and delta > 0 then
        entry.bankWithdrawn = math.max(0, Round((tonumber(entry.bankWithdrawn) or 0) + delta))
        self:RecordEconomyZoneBankTransfer(delta, false)
    end
    return true
end

function TPM:IsEconomyNonTransactionReason(reason, delta)
    -- PLAYER_INIT can report the player's existing balance as an update when
    -- entering the world. Counting that would add the whole wallet to
    -- "Received" on login/reload. ESO's own inventory code ignores it too.
    if _G.CURRENCY_CHANGE_REASON_PLAYER_INIT and reason == _G.CURRENCY_CHANGE_REASON_PLAYER_INIT then return true end
    if self:IsEconomyBankTransferReason(reason) then return true end

    -- These are losses/rollovers rather than deliberate spending. Positive PvP
    -- transfers remain valid income, but a negative transfer is not a purchase.
    if (tonumber(delta) or 0) < 0 then
        if _G.CURRENCY_CHANGE_REASON_DEATH and reason == _G.CURRENCY_CHANGE_REASON_DEATH then return true end
        if _G.CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER and reason == _G.CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER then return true end
        if _G.CURRENCY_CHANGE_REASON_TAMRIEL_TOMES_END_OF_SEASON_ROLLOVER_CAP
            and reason == _G.CURRENCY_CHANGE_REASON_TAMRIEL_TOMES_END_OF_SEASON_ROLLOVER_CAP then return true end
    end
    return false
end

function TPM:RecordEconomyCurrencyChange(currencyType, currencyLocation, newAmount, oldAmount, reason)
    self:GetEconomyCurrencyDefinitions()
    local definition = self.economyCurrencyByType and self.economyCurrencyByType[currencyType]
    if not definition then return end

    -- Personal bank transfers are not income/spending, but 3.0.6 records them
    -- separately so the Bank Gold development view can show Deposits and
    -- Withdrawals. Count the character-side event only to avoid double counts.
    if self:RecordEconomyPersonalBankTransfer(definition, currencyLocation, newAmount, oldAmount, reason) then
        if self.statisticsWindow and not self.statisticsWindow:IsHidden() and self.saved then
            if self.saved.statisticsPage == "economy" then self:RefreshEconomyStatisticsPage()
            elseif self.saved.statisticsPage == "history" then self:RefreshHistoryStatisticsPage() end
        end
        return
    end

    if self:IsEconomyCurrencyBankable(definition) then
        -- Track only the carried-wallet side. The matching bank event is a
        -- transfer and is deliberately ignored above, so deposits/withdrawals
        -- cannot inflate Received/Spent.
        if type(_G.CURRENCY_LOCATION_CHARACTER) == "number" and currencyLocation ~= _G.CURRENCY_LOCATION_CHARACTER then return end
    else
        local primaryLocation = self:GetEconomyPrimaryLocation(definition)
        if type(primaryLocation) == "number" and currencyLocation ~= primaryLocation then return end
    end

    local delta = (tonumber(newAmount) or 0) - (tonumber(oldAmount) or 0)
    if delta == 0 then return end
    if self:IsEconomyNonTransactionReason(reason, delta) then return end

    local stats = self:GetEconomyStats()
    local entry = stats.currencies[definition.key]
    if not entry then return end

    -- Gold crime subtotals. ESO exposes separate change reasons for selling
    -- stolen goods at a fence and for stealing/pickpocketing gold directly.
    -- These are subcategories of Received, not additional income on top of it.
    if definition.key == "gold" and delta > 0 then
        if _G.CURRENCY_CHANGE_REASON_SELL_STOLEN and reason == _G.CURRENCY_CHANGE_REASON_SELL_STOLEN then
            entry.fenceSales = math.max(0, Round((tonumber(entry.fenceSales) or 0) + delta))
        elseif (_G.CURRENCY_CHANGE_REASON_LOOT_STOLEN and reason == _G.CURRENCY_CHANGE_REASON_LOOT_STOLEN)
            or (_G.CURRENCY_CHANGE_REASON_PICKPOCKET and reason == _G.CURRENCY_CHANGE_REASON_PICKPOCKET) then
            entry.stolenGold = math.max(0, Round((tonumber(entry.stolenGold) or 0) + delta))
        end
    end

    if delta > 0 then
        entry.received = math.max(0, Round((tonumber(entry.received) or 0) + delta))
    else
        entry.spent = math.max(0, Round((tonumber(entry.spent) or 0) + math.abs(delta)))
    end
    -- 2.6.32: only Gold gets the detailed zone ledger. Other currencies keep
    -- their established global/character tracking to avoid implying a location
    -- ESO does not reliably provide for every currency source.
    if definition.key == "gold" then
        self:RecordEconomyZoneDelta(delta, reason)
    end

    if self.statisticsWindow and not self.statisticsWindow:IsHidden() and self.saved then
        if self.saved.statisticsPage == "economy" then
            self:RefreshEconomyStatisticsPage()
        elseif self.saved.statisticsPage == "history" then
            self:RefreshHistoryStatisticsPage()
        end
    end
end


-- v2.6.22 Justice / bounty payments -------------------------------------------
-- EVENT_JUSTICE_GOLD_REMOVED is ESO's dedicated notification for gold removed
-- by the Justice system. Keep it as a subcategory of normal Gold "Spent"; the
-- regular currency event already accounts for the wallet loss, so this function
-- must never add the amount to entry.spent a second time.
function TPM:RecordEconomyBountyPayment(goldAmount)
    goldAmount = math.max(0, Round(tonumber(goldAmount) or 0))
    if goldAmount <= 0 then return end

    local stats = self:GetEconomyStats()
    local entry = stats and stats.currencies and stats.currencies.gold
    if not entry then return end

    entry.bountyPaid = math.max(0, Round((tonumber(entry.bountyPaid) or 0) + goldAmount))
    local zoneEntry = self:GetEconomyZoneEntry(self:GetEconomyTrackingZoneId(), true)
    if zoneEntry then zoneEntry.bountyPaid = math.max(0, Round((tonumber(zoneEntry.bountyPaid) or 0) + goldAmount)) end
    entry.bountyTrackingVersion = entry.bountyTrackingVersion or "2.6.22"

    if self.statisticsWindow and not self.statisticsWindow:IsHidden() and self.saved then
        if self.saved.statisticsPage == "economy" then
            self:RefreshEconomyStatisticsPage()
        elseif self.saved.statisticsPage == "history" then
            self:RefreshHistoryStatisticsPage()
        end
    end
    self:QueueEconomyHistoryCheckpoint()
end


-- v3.0 History / development journal ------------------------------------------
-- ESO owns the actual SavedVariables disk write. TPM keeps its data current in
-- memory and creates explicit checkpoints on player deactivation, activation
-- transitions and periodically while playing so a normal logout/quit/reload has
-- a complete final state ready for ESO to persist.
local function TPM_DayKey(timestamp)
    return math.floor(math.max(0, tonumber(timestamp) or 0) / 86400)
end

local function TPM_FormatDuration(seconds)
    seconds = math.max(0, Round(tonumber(seconds) or 0))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    if hours > 0 then
        return string.format("%dh %02dm", hours, minutes)
    end
    return string.format("%dm", minutes)
end

local function TPM_SignedNumber(value)
    value = Round(tonumber(value) or 0)
    if value > 0 then return "+" .. FormatNumber(value) end
    if value < 0 then return "-" .. FormatNumber(math.abs(value)) end
    return "0"
end

local function TPM_SignedDuration(value)
    value = Round(tonumber(value) or 0)
    if value > 0 then return "+" .. TPM_FormatDuration(value) end
    if value < 0 then return "-" .. TPM_FormatDuration(math.abs(value)) end
    return TPM_FormatDuration(0)
end

-- 2.4.50: Legacy dynamicEncounter rows are no longer accepted at all.
-- World events are tracked exclusively through ESO's participation-based
-- world-event API added in 2.4.48. This prevents old zone-wide false positives
-- such as "Dynamische Begegnung: Steinfälle" from returning merely because a
-- kill or another counter changed while a world event existed in the zone.
local function TPM_IsMeaningfulDynamicEncounter(item)
    if type(item) ~= "table" then return false end
    return tostring(item.activityKind or "") ~= "dynamicEncounter"
end

function TPM:GetHistoryStore(characterKey)
    if not self.saved then return nil end
    if type(self.saved.historyByCharacter) ~= "table" then self.saved.historyByCharacter = {} end
    local key = characterKey or self:GetCurrentCharacterStatsKey()
    local store = self.saved.historyByCharacter[key]
    if type(store) ~= "table" then
        store = {
            trackingVersion = VERSION,
            daily = {},
            dailyExtrema = {},
            samples = {},
            sessions = {},
            activeSession = nil,
            characterName = "",
        }
        self.saved.historyByCharacter[key] = store
    end
    if type(store.daily) ~= "table" then store.daily = {} end
    if type(store.dailyExtrema) ~= "table" then store.dailyExtrema = {} end
    if type(store.samples) ~= "table" then store.samples = {} end
    if type(store.sessions) ~= "table" then store.sessions = {} end
    if type(store.activities) ~= "table" then store.activities = {} end
    if type(store.combatActivities) ~= "table" then
        store.combatActivities = {}
        -- 2.4.41 migration: previous builds mixed individual kills with quests /
        -- dungeons in one 100-row array. Move existing kill rows into their own
        -- 100-row combat log so ordinary kills can no longer push out quests.
        local keptActivities = {}
        for _, item in ipairs(store.activities) do
            if type(item) == "table" and self:IsCombatLogKind(item.activityKind) then
                store.combatActivities[#store.combatActivities + 1] = item
            else
                keptActivities[#keptActivities + 1] = item
            end
        end
        store.activities = keptActivities
    end
    -- 2.4.50: Purge all legacy dynamic encounter rows. World-event history now
    -- comes exclusively from the participation-based tracker, so the old
    -- dynamicEncounter category must never survive an update or affect counts.
    do
        local cleanedActivities = {}
        for _, item in ipairs(store.activities) do
            if TPM_IsMeaningfulDynamicEncounter(item) then
                cleanedActivities[#cleanedActivities + 1] = item
            end
        end
        store.activities = cleanedActivities
    end
    while #store.activities > 100 do table.remove(store.activities, 1) end
    while #store.combatActivities > 100 do table.remove(store.combatActivities, 1) end
    store.trackingVersion = store.trackingVersion or VERSION

    -- 3.0.0 stored only startedAt/lastSeenAt. Convert that shape to a paused
    -- segment so updating to 3.0.1 can never count offline/other-character time.
    if type(store.activeSession) == "table" then
        local active = store.activeSession
        if active.accumulatedSeconds == nil and active.segmentStartedAt == nil then
            local startedAt = tonumber(active.startedAt) or 0
            local lastSeenAt = tonumber(active.lastSeenAt) or startedAt
            active.accumulatedSeconds = math.max(0, lastSeenAt - startedAt)
            active.segmentStartedAt = nil
            active.deactivatedAt = lastSeenAt
        end
    end

    local currentKey = self:GetCurrentCharacterStatsKey()
    if key == currentKey then
        local characterName = type(GetUnitName) == "function" and (GetUnitName("player") or "") or ""
        if type(zo_strformat) == "function" and characterName ~= "" then
            characterName = zo_strformat("<<C:1>>", characterName)
        end
        if characterName ~= "" then store.characterName = characterName end
    end
    return store
end

function TPM:GetMilestoneState()
    if not self.saved then return nil end
    if type(self.saved.milestoneStateByCharacter) ~= "table" then self.saved.milestoneStateByCharacter = {} end
    local key = self:GetCurrentCharacterStatsKey()
    local state = self.saved.milestoneStateByCharacter[key]
    if type(state) ~= "table" then
        state = { initialized = false, tamriel = {}, zones = {}, records = {} }
        self.saved.milestoneStateByCharacter[key] = state
    end
    if type(state.tamriel) ~= "table" then state.tamriel = {} end
    if type(state.zones) ~= "table" then state.zones = {} end
    if type(state.records) ~= "table" then state.records = {} end
    return state
end

function TPM:GetSnapshotCategory(stats, completionType)
    for _, row in ipairs((stats and stats.categories) or {}) do
        if row.completionType == completionType then return row end
    end
    return nil
end


function TPM:GetCurrentPlayerZoneIdentity()
    local zoneIndex = nil
    if type(GetUnitZoneIndex) == "function" then
        local ok, value = pcall(GetUnitZoneIndex, "player")
        if ok and type(value) == "number" and value > 0 then zoneIndex = value end
    end

    local zoneId = 0
    if zoneIndex and type(GetZoneId) == "function" then
        local ok, value = pcall(GetZoneId, zoneIndex)
        if ok and type(value) == "number" then zoneId = value end
    end

    local zoneName = ""
    if zoneIndex and type(GetZoneNameByIndex) == "function" then
        local ok, value = pcall(GetZoneNameByIndex, zoneIndex)
        if ok and type(value) == "string" then zoneName = value end
    end
    if zoneName == "" and type(GetUnitZone) == "function" then
        local ok, value = pcall(GetUnitZone, "player")
        if ok and type(value) == "string" then zoneName = value end
    end
    if zoneName ~= "" and type(ZO_CachedStrFormat) == "function" and _G.SI_ZONE_NAME then
        local ok, formatted = pcall(ZO_CachedStrFormat, SI_ZONE_NAME, zoneName)
        if ok and type(formatted) == "string" and formatted ~= "" then zoneName = formatted end
    end
    return zoneId, zoneIndex, zoneName
end

function TPM:GetJumpActivityKind(zoneDisplayType)
    if type(zoneDisplayType) ~= "number" then return "adventure" end
    if _G.ZONE_DISPLAY_TYPE_BATTLEGROUND and zoneDisplayType == _G.ZONE_DISPLAY_TYPE_BATTLEGROUND then return "battleground" end
    if _G.ZONE_DISPLAY_TYPE_RAID and zoneDisplayType == _G.ZONE_DISPLAY_TYPE_RAID then return "trial" end
    if _G.ZONE_DISPLAY_TYPE_DUNGEON and zoneDisplayType == _G.ZONE_DISPLAY_TYPE_DUNGEON then return "dungeon" end
    if _G.ZONE_DISPLAY_TYPE_ENDLESS_DUNGEON and zoneDisplayType == _G.ZONE_DISPLAY_TYPE_ENDLESS_DUNGEON then return "dungeon" end
    return "adventure"
end

function TPM:IsWorldEventActivityKind(kind)
    return kind == "worldEvent" or kind == "dolmen" or kind == "geyser"
        or kind == "harrowstorm" or kind == "volcanicVent" or kind == "dragonHunt"
        or kind == "monsterHunt" or kind == "mirrormoor" or kind == "oblivionPortal"
end

function TPM:IsPersistentTrackedActivityKind(kind)
    return kind == "quest" or kind == "dungeon" or kind == "trial" or kind == "arena"
        or kind == "battleground" or kind == "pvp" or kind == "event"
        or self:IsWorldEventActivityKind(kind)
        or kind == "killAnimal" or kind == "killNpc" or kind == "killBoss" or kind == "killPlayer"
end

function TPM:IsCombatLogKind(kind)
    return kind == "killAnimal" or kind == "killNpc" or kind == "killBoss" or kind == "killPlayer"
end

function TPM:RememberJumpDestination(zoneName, zoneDisplayType, loadingTexture)
    local kind = self:GetJumpActivityKind(zoneDisplayType)
    local formattedName = tostring(zoneName or "")
    if formattedName ~= "" and type(ZO_CachedStrFormat) == "function" and _G.SI_ZONE_NAME then
        local ok, formatted = pcall(ZO_CachedStrFormat, SI_ZONE_NAME, formattedName)
        if ok and type(formatted) == "string" and formatted ~= "" then formattedName = formatted end
    end

    local now = TPM_Now()
    local active = self.activeTrackedActivity

    -- Finalize a dungeon/trial/BG BEFORE the loading screen starts. At this
    -- point ESO still exposes the old instance and all current combat totals,
    -- so the activity cannot get lost or be replaced by the destination zone.
    if type(active) == "table" and self:IsPersistentTrackedActivityKind(active.kind) then
        local activeName = tostring(active.name or "")
        local sameKind = active.kind == kind
        local sameName = formattedName ~= "" and activeName ~= "" and formattedName == activeName
        local stayingInSameActivity = sameKind and (sameName or formattedName == "")
        if not stayingInSameActivity then
            local endSnapshot = self:CaptureHistorySnapshot(false)
            if endSnapshot then
                active.lastSnapshot = endSnapshot
                active.lastSeenAt = endSnapshot.timestamp or now
            end
            self:FinalizeTrackedActivity(endSnapshot or active.lastSnapshot, now)
        end
    end

    self.pendingJumpActivity = {
        kind = kind,
        name = formattedName,
        at = now,
        displayType = zoneDisplayType,
        loadingTexture = tostring(loadingTexture or ""),
    }
end

function TPM:GetCurrentTrackedActivityKind()
    if self:IsCurrentBattlegroundActive() then return "battleground" end

    if type(IsPlayerInRaid) == "function" then
        local ok, inRaid = pcall(IsPlayerInRaid)
        if ok and inRaid then return "trial" end
    end

    -- Group dungeons are best identified by the current dungeon difficulty.
    -- IsUnitInDungeon() also returns true in delves/public dungeons, while
    -- NORMAL/VETERAN difficulty identifies a real group dungeon.
    if type(GetCurrentZoneDungeonDifficulty) == "function" then
        local ok, difficulty = pcall(GetCurrentZoneDungeonDifficulty)
        if ok and type(difficulty) == "number" then
            local none = tonumber(_G.DUNGEON_DIFFICULTY_NONE) or 0
            if difficulty > none then return "dungeon" end
        end
    end

    if self:IsInPvPEnvironment() then return "pvp" end

    -- Dynamic/world events are intentionally not inferred from the zone-wide
    -- active-event flag. ESO can report an active event anywhere in the zone,
    -- which caused ordinary play and dungeons to be stored as a dynamic
    -- encounter. Dedicated instance activities are tracked reliably below.
    return "adventure"
end

function TPM:MarkDynamicEncounterActivity(worldEventInstanceId)
    self.activeDynamicEncounterId = worldEventInstanceId or self.activeDynamicEncounterId
    self.lastDynamicEncounterAt = TPM_Now()
end

function TPM:ClearDynamicEncounterActivity(worldEventInstanceId)
    if worldEventInstanceId == nil or self.activeDynamicEncounterId == worldEventInstanceId then
        self.activeDynamicEncounterId = nil
    end
end

-- 2.4.48: World-event logging is participation based. EVENT_WORLD_EVENT_ACTIVATED
-- is zone-wide and therefore not proof the player joined an event. Only the
-- PARTICIPATION_BEGIN/END stream creates a tracker; DEACTIVATED finalizes it.
-- This prevents false rows such as repeated zero-value "Dynamic Encounter"
-- entries while still recording Dolmens, Geysers, Harrowstorms, Volcanic Vents
-- and other current/future ESO world events.
local function TPM_WorldEventNormalizeText(value)
    local text = tostring(value or "")
    text = text:gsub("%^%a+", "")
    if type(zo_strlower) == "function" then
        local ok, lowered = pcall(zo_strlower, text)
        if ok and type(lowered) == "string" then return lowered end
    end
    return string.lower(text)
end

local function TPM_WorldEventContains(text, ...)
    for i = 1, select("#", ...) do
        local needle = tostring(select(i, ...) or "")
        if needle ~= "" and string.find(text, needle, 1, true) then return true end
    end
    return false
end

function TPM:GetWorldEventMetadata(worldEventInstanceId, stepDefId)
    local metadata = {
        instanceId = tonumber(worldEventInstanceId) or 0,
        stepDefId = tonumber(stepDefId) or 0,
        worldEventId = 0,
        worldEventType = nil,
        locationContext = nil,
        zoneIndex = 0,
        poiIndex = 0,
        poiName = "",
        stepName = "",
        startDescription = "",
        finishedDescription = "",
        playerLocation = "",
        zoneName = "",
        icon = "",
    }

    if metadata.instanceId <= 0 then return metadata end

    if type(GetWorldEventId) == "function" then
        local ok, value = pcall(GetWorldEventId, metadata.instanceId)
        if ok and type(value) == "number" then metadata.worldEventId = value end
    end
    if metadata.worldEventId > 0 and type(GetWorldEventType) == "function" then
        local ok, value = pcall(GetWorldEventType, metadata.worldEventId)
        if ok then metadata.worldEventType = value end
    end

    if type(GetWorldEventLocationContext) == "function" then
        local ok, value = pcall(GetWorldEventLocationContext, metadata.instanceId)
        if ok then metadata.locationContext = value end
    end

    local canUsePoi = metadata.locationContext == nil
        or _G.WORLD_EVENT_LOCATION_CONTEXT_POINT_OF_INTEREST == nil
        or metadata.locationContext == _G.WORLD_EVENT_LOCATION_CONTEXT_POINT_OF_INTEREST
    if canUsePoi and type(GetWorldEventPOIInfo) == "function" then
        local ok, zoneIndex, poiIndex = pcall(GetWorldEventPOIInfo, metadata.instanceId)
        if ok then
            metadata.zoneIndex = tonumber(zoneIndex) or 0
            metadata.poiIndex = tonumber(poiIndex) or 0
            -- Update 50 dynamic world-event locations can report 1/1 when the
            -- event is a location rather than a real POI. Treat that sentinel
            -- as invalid instead of accidentally reading Stonefalls as a name.
            if metadata.zoneIndex == 1 and metadata.poiIndex == 1 then
                metadata.zoneIndex, metadata.poiIndex = 0, 0
            end
        end
    end

    if metadata.zoneIndex > 0 and metadata.poiIndex > 0 and type(GetPOIInfo) == "function" then
        local ok, poiName, _, startDescription, finishedDescription = pcall(GetPOIInfo, metadata.zoneIndex, metadata.poiIndex)
        if ok then
            metadata.poiName = tostring(poiName or "")
            metadata.startDescription = tostring(startDescription or "")
            metadata.finishedDescription = tostring(finishedDescription or "")
        end
    end
    if metadata.zoneIndex > 0 and metadata.poiIndex > 0 and type(GetPOIMapInfo) == "function" then
        local ok, _, _, _, icon = pcall(GetPOIMapInfo, metadata.zoneIndex, metadata.poiIndex)
        if ok then metadata.icon = tostring(icon or "") end
    end

    if metadata.stepDefId > 0 and type(GetWorldEventStepName) == "function" then
        local ok, value = pcall(GetWorldEventStepName, metadata.instanceId, metadata.stepDefId)
        if ok then metadata.stepName = tostring(value or "") end
    end
    if type(GetPlayerLocationName) == "function" then
        local ok, value = pcall(GetPlayerLocationName)
        if ok then metadata.playerLocation = tostring(value or "") end
    end
    if type(GetUnitZone) == "function" then
        local ok, value = pcall(GetUnitZone, "player")
        if ok then metadata.zoneName = tostring(value or "") end
    end

    local function FormatName(value)
        value = tostring(value or "")
        if value == "" then return "" end
        if type(ZO_CachedStrFormat) == "function" then
            local ok, formatted = pcall(ZO_CachedStrFormat, "<<C:1>>", value)
            if ok and type(formatted) == "string" and formatted ~= "" then return formatted end
        end
        return value:gsub("%^%a+", "")
    end
    metadata.poiName = FormatName(metadata.poiName)
    metadata.stepName = FormatName(metadata.stepName)
    metadata.playerLocation = FormatName(metadata.playerLocation)
    metadata.zoneName = FormatName(metadata.zoneName)
    return metadata
end

function TPM:ClassifyWorldEvent(metadata)
    metadata = metadata or {}
    local text = TPM_WorldEventNormalizeText(table.concat({
        metadata.poiName or "", metadata.stepName or "", metadata.startDescription or "",
        metadata.finishedDescription or "", metadata.playerLocation or "", metadata.zoneName or "",
        metadata.icon or "",
    }, " "))

    -- Dark Anchors/Dolmens have historically used the poi_portal icon. Text
    -- fallbacks cover localized names and future icon changes.
    if TPM_WorldEventContains(text, "poi_portal_", "dolmen", "dark anchor", "daedric anchor", "dunkler anker", "dunkle anker", "дольмен", "тёмный якор", "темный якор") then
        return "dolmen"
    end
    if TPM_WorldEventContains(text, "abyssal geyser", "abyssal geysers", "geyser", "geysir", "гейзер") then
        return "geyser"
    end
    if TPM_WorldEventContains(text, "harrowstorm", "harrow storm", "gramsturm", "gramstürm", "харроу") then
        return "harrowstorm"
    end
    if TPM_WorldEventContains(text, "volcanic vent", "volcanic vents", "vulkanschlot", "vulkanschlote", "вулканическ", "жерло") then
        return "volcanicVent"
    end
    if TPM_WorldEventContains(text, "mirrormoor", "spiegelmoor", "mirror moor", "зеркал") then
        return "mirrormoor"
    end
    if TPM_WorldEventContains(text, "oblivion portal", "portal to oblivion", "portal ins vergessen", "oblivion-portal", "обливион") then
        return "oblivionPortal"
    end
    if TPM_WorldEventContains(text, "dragon", "drache", "drachen", "дракон") then
        return "dragonHunt"
    end

    if _G.WORLD_EVENT_TYPE_MONSTER_HUNT and metadata.worldEventType == _G.WORLD_EVENT_TYPE_MONSTER_HUNT then
        return "monsterHunt"
    end
    return "worldEvent"
end

function TPM:GetWorldEventDisplayName(metadata, kind)
    metadata = metadata or {}
    local poiName = tostring(metadata.poiName or "")
    local location = tostring(metadata.playerLocation or "")
    local stepName = tostring(metadata.stepName or "")
    local zoneName = tostring(metadata.zoneName or "")

    if poiName ~= "" and poiName ~= zoneName then return poiName end
    if location ~= "" and location ~= zoneName then return location end
    if stepName ~= "" then return stepName end
    if zoneName ~= "" then return zoneName end
    return ""
end

function TPM:GetWorldEventCombatCounterSnapshot()
    local stats = self:GetPlayerCombatStats()
    return {
        npcKills = tonumber(stats and stats.npcKills) or 0,
        bossKills = tonumber(stats and stats.bossKills) or 0,
        pveDeaths = tonumber(stats and stats.pveDeaths) or 0,
        pvpKills = tonumber(stats and stats.pvpKills) or 0,
        pvpDeaths = tonumber(stats and stats.pvpDeaths) or 0,
    }
end

function TPM:PruneWorldEventTrackers()
    if type(self.worldEventTrackers) ~= "table" then return end
    local now = TPM_Now()
    for id, tracker in pairs(self.worldEventTrackers) do
        local lastSeen = tonumber(tracker.lastSeenAt or tracker.startedAt) or 0
        if lastSeen > 0 and now - lastSeen > 1800 then
            self.worldEventTrackers[id] = nil
        end
    end
end

-- 2.6.2: Some classic World Events (especially Dark Anchors/Dolmens) can
-- activate/deactivate without a reliable PARTICIPATION_BEGIN callback on every
-- client/event path. Keep a lightweight candidate from activation and promote it
-- only when ESO also gives evidence that the player is at that event (near/inside
-- its POI plus combat, XP or Gold). This avoids the old zone-wide false positives.
function TPM:DiscoverCurrentZoneWorldEventCandidates(force)
    if type(GetPOIWorldEventInstanceId) ~= "function" or type(GetNumPOIs) ~= "function" then return 0 end

    local nowMs = type(GetFrameTimeMilliseconds) == "function" and GetFrameTimeMilliseconds() or (TPM_Now() * 1000)
    if not force and tonumber(self.lastWorldEventPoiScanAtMs) and (nowMs - self.lastWorldEventPoiScanAtMs) < 700 then
        return tonumber(self.lastWorldEventPoiScanCount) or 0
    end
    self.lastWorldEventPoiScanAtMs = nowMs

    local _, playerZoneIndex = self:GetCurrentPlayerZoneIdentity()
    playerZoneIndex = tonumber(playerZoneIndex) or 0
    if playerZoneIndex <= 0 then
        self.lastWorldEventPoiScanCount = 0
        return 0
    end

    local okCount, poiCount = pcall(GetNumPOIs, playerZoneIndex)
    if not okCount or type(poiCount) ~= "number" or poiCount <= 0 then
        self.lastWorldEventPoiScanCount = 0
        return 0
    end

    local found = 0
    for poiIndex = 1, poiCount do
        local ok, instanceId = pcall(GetPOIWorldEventInstanceId, playerZoneIndex, poiIndex)
        instanceId = ok and (tonumber(instanceId) or 0) or 0
        if instanceId > 0 then
            found = found + 1
            self:ObserveWorldEventActivation(instanceId)
        end
    end
    self.lastWorldEventPoiScanCount = found
    return found
end

function TPM:IsWorldEventInPlayerZone(metadata)
    if type(metadata) ~= "table" then return false end
    local _, playerZoneIndex = self:GetCurrentPlayerZoneIdentity()
    playerZoneIndex = tonumber(playerZoneIndex) or 0
    local eventZoneIndex = tonumber(metadata.zoneIndex) or 0
    return playerZoneIndex > 0 and eventZoneIndex > 0 and playerZoneIndex == eventZoneIndex
end

function TPM:IsPlayerNearWorldEvent(metadata)
    if type(metadata) ~= "table" then return false end
    local zoneIndex = tonumber(metadata.zoneIndex) or 0
    local poiIndex = tonumber(metadata.poiIndex) or 0
    if zoneIndex <= 0 or poiIndex <= 0 then return false end

    if type(GetCurrentSubZonePOIIndices) == "function" then
        local ok, currentZoneIndex, currentPoiIndex = pcall(GetCurrentSubZonePOIIndices)
        if ok and tonumber(currentZoneIndex) == zoneIndex and tonumber(currentPoiIndex) == poiIndex then
            return true
        end
    end

    -- isNearby is independent of the player's discovery state and is a useful
    -- fallback when ESO does not expose the current sub-zone POI directly.
    if type(GetPOIMapInfo) == "function" then
        local ok, _, _, _, _, _, _, _, isNearby = pcall(GetPOIMapInfo, zoneIndex, poiIndex)
        if ok and isNearby == true then return true end
    end

    -- Some POIs (notably active Dark Anchors) do not always report isNearby at
    -- the exact moment combat/XP arrives. Matching ESO's current location name
    -- to the event POI is a safe additional local signal.
    local poiName = TPM_WorldEventNormalizeText(metadata.poiName)
    local playerLocation = TPM_WorldEventNormalizeText(metadata.playerLocation)
    if poiName ~= "" and playerLocation ~= "" and poiName == playerLocation then return true end
    return false
end

function TPM:ObserveWorldEventActivation(worldEventInstanceId, stepDefId)
    local id = tonumber(worldEventInstanceId) or 0
    if id <= 0 then return end
    self.worldEventTrackers = self.worldEventTrackers or {}
    self:PruneWorldEventTrackers()

    local tracker = self.worldEventTrackers[id]
    local metadata = self:GetWorldEventMetadata(id, stepDefId)
    if type(tracker) ~= "table" then
        local now = TPM_Now()
        tracker = {
            instanceId = id,
            startedAt = now,
            startCounters = self:GetWorldEventCombatCounterSnapshot(),
            goldEarned = 0,
            xpEarned = 0,
            observedNpcKills = 0,
            observedBossKills = 0,
            observedPveDeaths = 0,
            everParticipated = false,
            participating = false,
            activationCandidate = true,
            evidenceCount = 0,
            explicitParticipation = false,
        }
        self.worldEventTrackers[id] = tracker
    end
    tracker.metadata = metadata
    tracker.kind = self:ClassifyWorldEvent(metadata)
    tracker.name = self:GetWorldEventDisplayName(metadata, tracker.kind)
    tracker.stepDefId = tonumber(stepDefId) or tracker.stepDefId or 0
    tracker.lastSeenAt = TPM_Now()
end

function TPM:MarkNearbyWorldEventParticipationEvidence(evidenceKind)
    -- If the event was already active when the player entered the area, the
    -- activation callback may have happened before TPM could see it. Ask the
    -- current zone POIs for their live World Event instance ids as a fallback.
    self:DiscoverCurrentZoneWorldEventCandidates(false)
    if type(self.worldEventTrackers) ~= "table" then return false end

    local now = TPM_Now()
    local marked = false
    local sameZoneCandidates = {}

    local function MarkTracker(id, tracker)
        if type(tracker) ~= "table" or tracker.deactivatedAt then return false end
        tracker.everParticipated = true
        tracker.participating = true
        tracker.evidenceCount = (tonumber(tracker.evidenceCount) or 0) + 1
        tracker.lastEvidenceKind = tostring(evidenceKind or "unknown")
        tracker.lastEvidenceAt = now
        tracker.lastSeenAt = now
        self:MarkDynamicEncounterActivity(id)
        return true
    end

    for id, tracker in pairs(self.worldEventTrackers) do
        if type(tracker) == "table" and not tracker.deactivatedAt then
            self:UpdateWorldEventTrackerMetadata(id, tracker.stepDefId)
            if self:IsWorldEventInPlayerZone(tracker.metadata) then
                sameZoneCandidates[#sameZoneCandidates + 1] = { id = id, tracker = tracker }
                if self:IsPlayerNearWorldEvent(tracker.metadata) then
                    if MarkTracker(id, tracker) then marked = true end
                end
            end
        end
    end

    if marked then return true end

    -- Never infer participation merely because this is the only active World
    -- Event in the zone. Generic quest reward XP can otherwise create a false
    -- Dolmen entry while the player is doing an unrelated quest nearby.
    return false
end

function TPM:BeginWorldEventParticipation(worldEventInstanceId, stepDefId)
    local id = tonumber(worldEventInstanceId) or 0
    if id <= 0 then return end
    self.worldEventTrackers = self.worldEventTrackers or {}
    self:PruneWorldEventTrackers()

    local now = TPM_Now()
    local tracker = self.worldEventTrackers[id]
    local metadata = self:GetWorldEventMetadata(id, stepDefId)
    if type(tracker) ~= "table" then
        tracker = {
            instanceId = id,
            startedAt = now,
            startCounters = self:GetWorldEventCombatCounterSnapshot(),
            goldEarned = 0,
            xpEarned = 0,
            observedNpcKills = 0,
            observedBossKills = 0,
            observedPveDeaths = 0,
            everParticipated = true,
        }
        self.worldEventTrackers[id] = tracker
    end
    tracker.metadata = metadata
    tracker.kind = self:ClassifyWorldEvent(metadata)
    tracker.name = self:GetWorldEventDisplayName(metadata, tracker.kind)
    tracker.stepDefId = tonumber(stepDefId) or tracker.stepDefId or 0
    tracker.participating = true
    tracker.everParticipated = true
    tracker.explicitParticipation = true
    tracker.activationCandidate = tracker.activationCandidate == true
    tracker.evidenceCount = math.max(1, tonumber(tracker.evidenceCount) or 0)
    tracker.lastSeenAt = now
    tracker.participationEndedAt = nil
    tracker.endCounters = nil
    self:MarkDynamicEncounterActivity(id)
end

function TPM:UpdateWorldEventTrackerMetadata(worldEventInstanceId, stepDefId)
    local id = tonumber(worldEventInstanceId) or 0
    if id <= 0 then return end
    if type(self.worldEventTrackers) ~= "table" or type(self.worldEventTrackers[id]) ~= "table" then
        self:ObserveWorldEventActivation(id, stepDefId)
    end
    local tracker = type(self.worldEventTrackers) == "table" and self.worldEventTrackers[id] or nil
    if type(tracker) ~= "table" then return end

    local fresh = self:GetWorldEventMetadata(id, stepDefId or tracker.stepDefId)
    local metadata = tracker.metadata or {}
    -- Some values disappear immediately as DEACTIVATED fires. Merge only useful
    -- fresh fields so the POI name/type captured during participation is never
    -- replaced with an empty post-completion snapshot.
    for key, value in pairs(fresh) do
        if type(value) == "string" then
            if value ~= "" then metadata[key] = value end
        elseif value ~= nil and value ~= 0 then
            metadata[key] = value
        elseif metadata[key] == nil then
            metadata[key] = value
        end
    end
    tracker.metadata = metadata

    local classified = self:ClassifyWorldEvent(metadata)
    if tracker.kind == nil or tracker.kind == "worldEvent" or classified ~= "worldEvent" then
        tracker.kind = classified
    end
    local displayName = self:GetWorldEventDisplayName(metadata, tracker.kind)
    if displayName ~= "" then tracker.name = displayName end
    if stepDefId then tracker.stepDefId = stepDefId end
    tracker.lastSeenAt = TPM_Now()
end

function TPM:EndWorldEventParticipation(worldEventInstanceId)
    local id = tonumber(worldEventInstanceId) or 0
    if id <= 0 or type(self.worldEventTrackers) ~= "table" then return end
    local tracker = self.worldEventTrackers[id]
    if type(tracker) ~= "table" then return end
    tracker.participating = false
    tracker.participationEndedAt = TPM_Now()
    tracker.lastSeenAt = tracker.participationEndedAt
    tracker.endCounters = self:GetWorldEventCombatCounterSnapshot()
    self:ClearDynamicEncounterActivity(id)
end

function TPM:RecordWorldEventGoldGain(delta)
    delta = tonumber(delta) or 0
    if delta <= 0 or type(self.worldEventTrackers) ~= "table" then return end
    self:MarkNearbyWorldEventParticipationEvidence("gold")
    local now = TPM_Now()
    for _, tracker in pairs(self.worldEventTrackers) do
        local endedAt = tonumber(tracker.participationEndedAt or tracker.deactivatedAt) or 0
        if tracker.participating or (tracker.everParticipated and endedAt > 0 and now - endedAt <= 10) then
            tracker.goldEarned = math.max(0, (tonumber(tracker.goldEarned) or 0) + delta)
            tracker.lastSeenAt = now
        end
    end
end

function TPM:RecordWorldEventExperienceGain(gained, source)
    gained = tonumber(gained) or 0
    if gained <= 0 or type(self.worldEventTrackers) ~= "table" then return end
    source = tostring(source or "unknown")
    self:MarkNearbyWorldEventParticipationEvidence("xp")

    -- EVENT_EXPERIENCE_GAIN and EVENT_EXPERIENCE_UPDATE can describe the same
    -- XP change. Use both for reliability, but suppress only a matching value
    -- reported by the other source within a few frames. Repeated kills from the
    -- same source are never collapsed.
    local nowMs
    if type(GetFrameTimeMilliseconds) == "function" then
        nowMs = GetFrameTimeMilliseconds()
    else
        nowMs = TPM_Now() * 1000
    end
    local last = self.lastWorldEventExperienceSignal
    if type(last) == "table" and last.source ~= source and tonumber(last.value) == gained
        and math.abs(nowMs - (tonumber(last.atMs) or 0)) <= 450 then
        return
    end
    self.lastWorldEventExperienceSignal = { value = gained, source = source, atMs = nowMs }

    local now = TPM_Now()
    for _, tracker in pairs(self.worldEventTrackers) do
        local endedAt = tonumber(tracker.participationEndedAt or tracker.deactivatedAt) or 0
        if tracker.participating or (tracker.everParticipated and endedAt > 0 and now - endedAt <= 10) then
            tracker.xpEarned = math.max(0, (tonumber(tracker.xpEarned) or 0) + gained)
            tracker.lastSeenAt = now
        end
    end
end

-- 2.6.6: attribute combat events directly to a confirmed active World Event.
-- Counter snapshots remain as a fallback, but explicit event-local counters avoid
-- losing kills when ESO reports PARTICIPATION_BEGIN late during a Dolmen.
function TPM:RecordWorldEventPveKill(kind)
    if type(self.worldEventTrackers) ~= "table" then return end
    local now = TPM_Now()
    for _, tracker in pairs(self.worldEventTrackers) do
        if type(tracker) == "table" and tracker.everParticipated then
            local endedAt = tonumber(tracker.participationEndedAt or tracker.deactivatedAt) or 0
            if tracker.participating or (endedAt > 0 and now - endedAt <= 10) then
                tracker.observedNpcKills = math.max(0, (tonumber(tracker.observedNpcKills) or 0) + 1)
                if kind == "killBoss" then
                    tracker.observedBossKills = math.max(0, (tonumber(tracker.observedBossKills) or 0) + 1)
                end
                tracker.lastSeenAt = now
            end
        end
    end
end

function TPM:RecordWorldEventPveDeath()
    if type(self.worldEventTrackers) ~= "table" then return end
    local now = TPM_Now()
    for _, tracker in pairs(self.worldEventTrackers) do
        if type(tracker) == "table" and tracker.everParticipated then
            local endedAt = tonumber(tracker.participationEndedAt or tracker.deactivatedAt) or 0
            if tracker.participating or (endedAt > 0 and now - endedAt <= 10) then
                tracker.observedPveDeaths = math.max(0, (tonumber(tracker.observedPveDeaths) or 0) + 1)
                tracker.lastSeenAt = now
            end
        end
    end
end

function TPM:FinalizeWorldEventActivity(worldEventInstanceId)
    local id = tonumber(worldEventInstanceId) or 0
    if id <= 0 or type(self.worldEventTrackers) ~= "table" then return end
    local tracker = self.worldEventTrackers[id]
    if type(tracker) ~= "table" then return end
    self.worldEventTrackers[id] = nil
    if not tracker.everParticipated then return end

    local now = tonumber(tracker.deactivatedAt) or TPM_Now()
    local participationEnd = tonumber(tracker.participationEndedAt) or now
    local endCounters = tracker.endCounters or self:GetWorldEventCombatCounterSnapshot()
    local startCounters = tracker.startCounters or {}
    local duration = math.max(0, participationEnd - (tonumber(tracker.startedAt) or participationEnd))
    local metadata = tracker.metadata or self:GetWorldEventMetadata(id, tracker.stepDefId)
    local kind = tracker.kind or self:ClassifyWorldEvent(metadata)
    local name = tracker.name or self:GetWorldEventDisplayName(metadata, kind)

    -- Evidence-only trackers must show actual encounter involvement. This
    -- prevents ordinary quest XP (for example Bilsas Lieferung) from creating
    -- a nearby Dolmen/World Event completion in Quests & Activities.
    if tracker.explicitParticipation ~= true then
        local encounterEvidence =
            math.max(0, tonumber(tracker.observedNpcKills) or 0) +
            math.max(0, tonumber(tracker.observedBossKills) or 0) +
            math.max(0, tonumber(tracker.observedPveDeaths) or 0)
        if encounterEvidence <= 0 and math.max(0, tonumber(tracker.goldEarned) or 0) <= 0 then
            return
        end
    end

    self:AddActivityLogEntry({
        activityKind = kind,
        activityName = name,
        worldEventInstanceId = id,
        worldEventId = metadata and metadata.worldEventId or 0,
        goldEarned = math.max(0, tonumber(tracker.goldEarned) or 0),
        xpEarned = math.max(0, tonumber(tracker.xpEarned) or 0),
        rewardName = "",
        duration = duration,
        startedAt = tonumber(tracker.startedAt) or now,
        endedAt = now,
        timestamp = now,
        npcKillsDelta = (tonumber(tracker.observedNpcKills) or 0) > 0
            and math.max(0, tonumber(tracker.observedNpcKills) or 0)
            or math.max(0, (tonumber(endCounters.npcKills) or 0) - (tonumber(startCounters.npcKills) or 0)),
        bossKillsDelta = (tonumber(tracker.observedBossKills) or 0) > 0
            and math.max(0, tonumber(tracker.observedBossKills) or 0)
            or math.max(0, (tonumber(endCounters.bossKills) or 0) - (tonumber(startCounters.bossKills) or 0)),
        pveDeathsDelta = (tonumber(tracker.observedPveDeaths) or 0) > 0
            and math.max(0, tonumber(tracker.observedPveDeaths) or 0)
            or math.max(0, (tonumber(endCounters.pveDeaths) or 0) - (tonumber(startCounters.pveDeaths) or 0)),
        pvpKillsDelta = math.max(0, (tonumber(endCounters.pvpKills) or 0) - (tonumber(startCounters.pvpKills) or 0)),
        pvpDeathsDelta = math.max(0, (tonumber(endCounters.pvpDeaths) or 0) - (tonumber(startCounters.pvpDeaths) or 0)),
        participatedWorldEvent = true,
    })
end

function TPM:DeactivateWorldEvent(worldEventInstanceId)
    local id = tonumber(worldEventInstanceId) or 0
    if id <= 0 then return end
    local tracker = type(self.worldEventTrackers) == "table" and self.worldEventTrackers[id] or nil
    self:ClearDynamicEncounterActivity(id)
    if type(tracker) ~= "table" then return end

    -- Last chance for classic Dolmens: the player may still be standing inside
    -- the POI when DEACTIVATED arrives even if PARTICIPATION_BEGIN was omitted.
    if not tracker.everParticipated and (tonumber(tracker.evidenceCount) or 0) > 0 and self:IsPlayerNearWorldEvent(tracker.metadata) then
        tracker.everParticipated = true
        tracker.participating = true
    end
    if not tracker.everParticipated then
        self.worldEventTrackers[id] = nil
        return
    end

    local now = TPM_Now()
    -- If participation ended long before the event deactivated, the player
    -- walked away rather than completing it. Do not log that as a completion.
    local participationEndedAt = tonumber(tracker.participationEndedAt) or 0
    if not tracker.participating and participationEndedAt > 0 then
        local lastEvidenceAt = tonumber(tracker.lastEvidenceAt) or participationEndedAt
        -- PARTICIPATION_END can arrive noticeably before the visual World Event
        -- fully deactivates. Keep a wider completion grace, but still discard a
        -- tracker if the player has clearly been away for two minutes.
        if now - participationEndedAt > 120 and now - lastEvidenceAt > 120 then
            self.worldEventTrackers[id] = nil
            return
        end
    end

    if tracker.participating then
        tracker.participating = false
        tracker.participationEndedAt = now
        tracker.endCounters = self:GetWorldEventCombatCounterSnapshot()
    end
    tracker.deactivatedAt = now
    tracker.lastSeenAt = now
    self:UpdateWorldEventTrackerMetadata(id, tracker.stepDefId)

    local finalize = function()
        if TPM then TPM:FinalizeWorldEventActivity(id) end
    end
    if type(zo_callLater) == "function" then
        zo_callLater(finalize, 1600)
    else
        finalize()
    end
end

function TPM:ResumeParticipatingWorldEvent()
    if type(GetParticipatingWorldEventStep) ~= "function" then return end
    local ok, instanceId, stepDefId = pcall(GetParticipatingWorldEventStep)
    if ok and tonumber(instanceId) and tonumber(instanceId) > 0 then
        self:BeginWorldEventParticipation(instanceId, stepDefId)
    end
end


-- 2.4.41: per-kill combat log. ESO may emit ACTION_RESULT_DIED first and
-- ACTION_RESULT_DIED_XP immediately afterwards for the same target. Older TPM
-- builds finalized DIED too early, so the later XP event could no longer be
-- paired and the row displayed EP +0. Keep a short unit-id based pending queue
-- and only finalize after the XP event had enough time to arrive.
local function TPM_KillLogNowMs()
    if type(GetFrameTimeMilliseconds) == "function" then return GetFrameTimeMilliseconds() end
    return (type(GetTimeStamp) == "function" and GetTimeStamp() or 0) * 1000
end

function TPM:NormalizeCombatUnitName(name)
    local raw = tostring(name or "")
    if raw == "" then return "", "" end
    local clean = raw
    if type(ZO_CachedStrFormat) == "function" then
        local ok, value = pcall(ZO_CachedStrFormat, "<<C:1>>", raw)
        if ok and type(value) == "string" and value ~= "" then clean = value end
    end
    -- Combat events frequently expose ESO grammar suffixes (^m/^f/^n) while
    -- reticle names may already be formatted. Strip any marker that remains so
    -- both sources can be matched and the marker never leaks into the UI.
    clean = tostring(clean or ""):gsub("%^%a+", "")
    return clean, string.lower(clean)
end

function TPM:CaptureReticlePveTarget()
    if type(GetUnitName) ~= "function" then return end
    local rawName = tostring(GetUnitName("reticleover") or "")
    if rawName == "" then
        -- Keep recent valid target snapshots for a few seconds. ESO often moves
        -- the reticle away from a dead unit before EVENT_COMBAT_EVENT arrives.
        return
    end
    local cleanName, normalizedName = self:NormalizeCombatUnitName(rawName)
    if cleanName == "" then return end
    local snapshot = {
        name = cleanName,
        rawName = rawName,
        normalizedName = normalizedName,
        atMs = TPM_KillLogNowMs(),
        livestock = false,
        critter = false,
        difficulty = nil,
        reaction = nil,
    }
    if type(IsUnitLivestock) == "function" then
        local ok, value = pcall(IsUnitLivestock, "reticleover")
        snapshot.livestock = ok and value == true
    end
    if type(GetUnitDifficulty) == "function" then
        local ok, difficulty = pcall(GetUnitDifficulty, "reticleover")
        if ok and type(difficulty) == "number" then
            snapshot.difficulty = difficulty
            snapshot.critter = _G.MONSTER_DIFFICULTY_NONE ~= nil and difficulty == _G.MONSTER_DIFFICULTY_NONE
        end
    end
    if type(GetUnitReaction) == "function" then
        local ok, reaction = pcall(GetUnitReaction, "reticleover")
        if ok and type(reaction) == "number" then snapshot.reaction = reaction end
    end
    self.lastReticlePveTarget = snapshot
    self.recentReticlePveTargets = self.recentReticlePveTargets or {}
    table.insert(self.recentReticlePveTargets, 1, snapshot)
    local nowMs = snapshot.atMs
    for i = #self.recentReticlePveTargets, 1, -1 do
        local entry = self.recentReticlePveTargets[i]
        if i > 16 or type(entry) ~= "table" or (nowMs - (tonumber(entry.atMs) or 0)) > 6500 then
            table.remove(self.recentReticlePveTargets, i)
        end
    end
end

function TPM:IsKnownBossName(name)
    local _, normalizedName = self:NormalizeCombatUnitName(name)
    if normalizedName == "" or type(GetUnitName) ~= "function" then return false end
    for i = 1, 6 do
        local bossName = tostring(GetUnitName("boss" .. tostring(i)) or "")
        local _, normalizedBoss = self:NormalizeCombatUnitName(bossName)
        if normalizedBoss ~= "" and normalizedBoss == normalizedName then return true end
    end
    return false
end

function TPM:RememberPlayerPveCombatTarget(targetName, targetUnitId, targetType)
    local cleanName, normalizedName = self:NormalizeCombatUnitName(targetName)
    local numericTargetId = tonumber(targetUnitId) or 0
    if cleanName == "" and numericTargetId <= 0 then return end
    if _G.COMBAT_UNIT_TYPE_NONE ~= nil and targetType ~= nil and targetType ~= _G.COMBAT_UNIT_TYPE_NONE then return end

    self.recentPlayerPveCombatTargets = self.recentPlayerPveCombatTargets or {}
    local nowMs = TPM_KillLogNowMs()
    local snapshot = cleanName ~= "" and self:GetPveKillSnapshot(cleanName) or nil
    local entry = {
        name = cleanName,
        normalizedName = normalizedName,
        targetUnitId = numericTargetId,
        atMs = nowMs,
        difficulty = snapshot and snapshot.difficulty or nil,
        livestock = snapshot and snapshot.livestock or false,
        critter = snapshot and snapshot.critter or false,
    }
    table.insert(self.recentPlayerPveCombatTargets, 1, entry)
    for i = #self.recentPlayerPveCombatTargets, 1, -1 do
        local item = self.recentPlayerPveCombatTargets[i]
        if i > 64 or type(item) ~= "table" or (nowMs - (tonumber(item.atMs) or 0)) > 15000 then
            table.remove(self.recentPlayerPveCombatTargets, i)
        end
    end
end

function TPM:GetRecentPlayerPveCombatTarget(targetUnitId, targetName)
    local numericTargetId = tonumber(targetUnitId) or 0
    local _, normalizedName = self:NormalizeCombatUnitName(targetName)
    local nowMs = TPM_KillLogNowMs()
    for _, entry in ipairs(self.recentPlayerPveCombatTargets or {}) do
        if type(entry) == "table" then
            local age = nowMs - (tonumber(entry.atMs) or 0)
            if age >= 0 and age <= 15000 then
                local sameUnit = numericTargetId > 0 and tonumber(entry.targetUnitId) == numericTargetId
                local sameName = normalizedName ~= "" and entry.normalizedName == normalizedName
                if sameUnit or sameName then return entry end
            end
        end
    end
    return nil
end

function TPM:GetPveKillSnapshot(targetName)
    local cleanName, normalizedName = self:NormalizeCombatUnitName(targetName)
    if cleanName == "" then return nil end
    local nowMs = TPM_KillLogNowMs()

    local snapshot = self.lastReticlePveTarget
    if type(snapshot) == "table" and snapshot.normalizedName == normalizedName
        and (nowMs - (tonumber(snapshot.atMs) or 0)) <= 6500 then
        return snapshot
    end

    for _, recent in ipairs(self.recentReticlePveTargets or {}) do
        if type(recent) == "table" and recent.normalizedName == normalizedName
            and (nowMs - (tonumber(recent.atMs) or 0)) <= 6500 then
            return recent
        end
    end

    if type(GetUnitName) == "function" then
        local currentName = tostring(GetUnitName("reticleover") or "")
        local _, currentNormalized = self:NormalizeCombatUnitName(currentName)
        if currentNormalized ~= "" and currentNormalized == normalizedName then
            self:CaptureReticlePveTarget()
            snapshot = self.lastReticlePveTarget
            if type(snapshot) == "table" and snapshot.normalizedName == normalizedName then return snapshot end
        end
    end
    return nil
end

function TPM:GetPveKillActivityKind(targetName)
    local cleanName = self:NormalizeCombatUnitName(targetName)
    if self:IsKnownBossName(targetName) or self:IsKnownBossName(cleanName) then return "killBoss" end
    local snapshot = self:GetPveKillSnapshot(targetName)
    if type(snapshot) == "table" then
        if snapshot.livestock or snapshot.critter then return "killAnimal" end
        if _G.MONSTER_DIFFICULTY_DEADLY ~= nil and snapshot.difficulty == _G.MONSTER_DIFFICULTY_DEADLY then
            return "killBoss"
        end
    end
    return "killNpc"
end

function TPM:GetPveKillDifficulty(targetName, kind)
    if kind == "killBoss" then return _G.MONSTER_DIFFICULTY_DEADLY end
    local snapshot = self:GetPveKillSnapshot(targetName)
    if type(snapshot) == "table" and type(snapshot.difficulty) == "number" then return snapshot.difficulty end
    if kind == "killAnimal" then return _G.MONSTER_DIFFICULTY_EASY or _G.MONSTER_DIFFICULTY_NONE end
    return _G.MONSTER_DIFFICULTY_NORMAL
end

function TPM:FinalizePendingPveKillActivity(pending, xpEarned)
    if type(pending) ~= "table" or pending.finalized then return end
    pending.finalized = true
    local now = TPM_Now()
    self:AddActivityLogEntry({
        activityKind = pending.kind or "killNpc",
        activityName = tostring(pending.name or ""),
        xpEarned = math.max(0, tonumber(xpEarned) or 0),
        goldEarned = 0,
        difficulty = pending.difficulty,
        targetUnitId = pending.targetUnitId,
        duration = 0,
        startedAt = now,
        endedAt = now,
        timestamp = now,
        npcKillsDelta = 1,
        pveDeathsDelta = 0,
        pvpKillsDelta = 0,
        pvpDeathsDelta = 0,
    })
end

function TPM:QueuePveKillActivity(targetName, kind, expectsXp, targetUnitId, difficulty, sawXpDeathResult)
    targetName = select(1, self:NormalizeCombatUnitName(targetName))
    if targetName == "" then return nil end
    self.pendingPveKillActivities = self.pendingPveKillActivities or {}
    local nowMs = TPM_KillLogNowMs()
    local numericTargetId = tonumber(targetUnitId) or 0

    -- ESO distinguishes ACTION_RESULT_DIED from ACTION_RESULT_DIED_XP. Only the
    -- latter is a reliable signal that this particular death generated player XP.
    -- Keep both results on the same pending row, but never let a plain DIED row
    -- steal the next EVENT_EXPERIENCE_GAIN from an actual XP-granting kill.
    for i = #self.pendingPveKillActivities, 1, -1 do
        local existing = self.pendingPveKillActivities[i]
        if type(existing) == "table" and not existing.finalized then
            local sameUnit = numericTargetId > 0 and tonumber(existing.targetUnitId) == numericTargetId
            local sameFallback = numericTargetId <= 0 and (tonumber(existing.targetUnitId) or 0) <= 0
                and existing.name == targetName and (nowMs - (tonumber(existing.atMs) or 0)) <= 450
            if sameUnit or sameFallback then
                if kind == "killBoss" then existing.kind = "killBoss" end
                if expectsXp == true then existing.expectsXp = true end
                if sawXpDeathResult == true then
                    existing.sawXpDeathResult = true
                    existing.expectsXp = true
                    existing.xpResultAtMs = nowMs
                end
                existing.difficulty = difficulty or existing.difficulty
                if existing.sawXpDeathResult == true then self:ConsumeRecentExperienceForPendingKill(existing) end
                return existing
            end
        end
    end

    local pending = {
        name = targetName,
        kind = kind or "killNpc",
        expectsXp = expectsXp == true,
        sawXpDeathResult = sawXpDeathResult == true,
        targetUnitId = numericTargetId,
        difficulty = difficulty,
        atMs = nowMs,
        xpResultAtMs = sawXpDeathResult == true and nowMs or nil,
        finalized = false,
    }
    self.pendingPveKillActivities[#self.pendingPveKillActivities + 1] = pending
    while #self.pendingPveKillActivities > 24 do table.remove(self.pendingPveKillActivities, 1) end
    if pending.sawXpDeathResult == true then self:ConsumeRecentExperienceForPendingKill(pending) end

    -- Give DIED_XP + EVENT_EXPERIENCE_GAIN enough time to arrive. The row is
    -- finalized immediately as soon as its XP event is matched.
    local delay = 4000
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            if not pending.finalized then TPM:FinalizePendingPveKillActivity(pending, 0) end
        end, delay)
    else
        self:FinalizePendingPveKillActivity(pending, 0)
    end
    return pending
end

function TPM:MarkPendingPveKillXpResult(targetName, targetUnitId)
    if type(self.pendingPveKillActivities) ~= "table" then return nil end
    targetName = tostring(targetName or "")
    local numericTargetId = tonumber(targetUnitId) or 0
    local nowMs = TPM_KillLogNowMs()

    -- DIED_XP can arrive with an empty targetName in some combat situations.
    -- Pair it by targetUnitId first; only use a very recent name-less fallback
    -- when ESO did not expose a usable id.
    for i = #self.pendingPveKillActivities, 1, -1 do
        local pending = self.pendingPveKillActivities[i]
        if type(pending) == "table" and not pending.finalized then
            local age = nowMs - (tonumber(pending.atMs) or 0)
            local sameUnit = numericTargetId > 0 and tonumber(pending.targetUnitId) == numericTargetId
            local sameName = targetName ~= "" and pending.name == targetName and age >= 0 and age <= 1200
            if sameUnit or sameName then
                pending.sawXpDeathResult = true
                pending.expectsXp = true
                pending.xpResultAtMs = nowMs
                self:ConsumeRecentExperienceForPendingKill(pending)
                return pending
            end
        end
    end

    if numericTargetId <= 0 and targetName == "" then
        for i = #self.pendingPveKillActivities, 1, -1 do
            local pending = self.pendingPveKillActivities[i]
            local age = type(pending) == "table" and (nowMs - (tonumber(pending.atMs) or 0)) or -1
            if type(pending) == "table" and not pending.finalized and age >= 0 and age <= 350 then
                pending.sawXpDeathResult = true
                pending.expectsXp = true
                pending.xpResultAtMs = nowMs
                self:ConsumeRecentExperienceForPendingKill(pending)
                return pending
            end
        end
    end
    return nil
end

function TPM:PromoteOrQueueBossKillActivity(name)
    name = tostring(name or "")
    if name == "" then return end

    -- EVENT_UNIT_DEATH_STATE_CHANGED has the boss unit tag but no combat-event
    -- targetUnitId. If the matching DIED/DIED_XP row is already pending, promote
    -- that same row instead of creating a second boss entry.
    local nowMs = TPM_KillLogNowMs()
    for i = #(self.pendingPveKillActivities or {}), 1, -1 do
        local pending = self.pendingPveKillActivities[i]
        if type(pending) == "table" and not pending.finalized and pending.name == name
            and (nowMs - (tonumber(pending.atMs) or 0)) >= 0
            and (nowMs - (tonumber(pending.atMs) or 0)) <= 2400 then
            pending.kind = "killBoss"
            pending.difficulty = _G.MONSTER_DIFFICULTY_DEADLY
            return pending
        end
    end
    -- Boss identity alone does not prove that ESO granted XP. DIED_XP will
    -- promote the row when XP is actually awarded.
    return self:QueuePveKillActivity(name, "killBoss", false, 0, _G.MONSTER_DIFFICULTY_DEADLY, false)
end

function TPM:PruneRecentExperienceGains(nowMs)
    if type(self.recentExperienceGains) ~= "table" then return end
    nowMs = tonumber(nowMs) or TPM_KillLogNowMs()
    for i = #self.recentExperienceGains, 1, -1 do
        local entry = self.recentExperienceGains[i]
        local age = type(entry) == "table" and (nowMs - (tonumber(entry.atMs) or 0)) or 999999
        if age > 1800 or entry.consumed then table.remove(self.recentExperienceGains, i) end
    end
end

function TPM:StoreRecentExperienceGain(reason, level, previousExperience, currentExperience)
    local gained = self:CalculateExperienceGain(level, previousExperience, currentExperience)
    if gained <= 0 then return nil end
    return self:StoreRecentExperienceValue(gained, reason, "gain")
end

function TPM:StoreRecentExperienceValue(gained, reason, source)
    gained = math.max(0, tonumber(gained) or 0)
    if gained <= 0 then return nil end
    local nowMs = TPM_KillLogNowMs()
    self.recentExperienceGains = self.recentExperienceGains or {}
    self:PruneRecentExperienceGains(nowMs)

    -- EVENT_EXPERIENCE_GAIN and EVENT_EXPERIENCE_UPDATE can describe the same
    -- XP change. Do not keep the exact same gain twice within a few frames.
    for i = #self.recentExperienceGains, 1, -1 do
        local old = self.recentExperienceGains[i]
        if type(old) == "table" and not old.consumed then
            local age = nowMs - (tonumber(old.atMs) or 0)
            if age >= 0 and age <= 160 and tonumber(old.gained) == gained then
                return old
            end
        end
    end

    local entry = { gained = gained, reason = reason, source = source, atMs = nowMs, consumed = false }
    self.recentExperienceGains[#self.recentExperienceGains + 1] = entry
    while #self.recentExperienceGains > 16 do table.remove(self.recentExperienceGains, 1) end
    return entry
end

function TPM:AssignExperienceValueToPendingPveKill(gained, reason, source)
    gained = math.max(0, tonumber(gained) or 0)
    if gained <= 0 then return false end
    local nowMs = TPM_KillLogNowMs()

    if type(self.pendingPveKillActivities) == "table" then
        local bestPending, bestDistance = nil, nil
        for i = #self.pendingPveKillActivities, 1, -1 do
            local pending = self.pendingPveKillActivities[i]
            if type(pending) == "table" and not pending.finalized and pending.sawXpDeathResult == true then
                local markerMs = tonumber(pending.xpResultAtMs) or tonumber(pending.atMs) or 0
                local distance = math.abs(nowMs - markerMs)
                if distance <= 2200 and (bestDistance == nil or distance < bestDistance) then
                    bestPending, bestDistance = pending, distance
                end
            end
        end
        if bestPending then
            self:FinalizePendingPveKillActivity(bestPending, gained)
            return true
        end
    end

    -- XP can update before DIED_XP arrives, so retain it briefly for the death
    -- row to claim. This is especially important on fast/AoE kills.
    self:StoreRecentExperienceValue(gained, reason, source or "update")
    return false
end

function TPM:HandlePlayerExperienceUpdate(currentExp, maxExp, reason)
    currentExp = tonumber(currentExp)
    maxExp = tonumber(maxExp)
    if not currentExp then return false end

    local level = type(GetUnitLevel) == "function" and (tonumber(GetUnitLevel("player")) or 1) or 1
    local previousExp = tonumber(self.killLogLastPlayerExperience)
    local previousLevel = tonumber(self.killLogLastPlayerLevel) or level
    local previousMax = tonumber(self.killLogLastPlayerExperienceMax) or maxExp

    self.killLogLastPlayerExperience = currentExp
    self.killLogLastPlayerExperienceMax = maxExp
    self.killLogLastPlayerLevel = level

    if previousExp == nil then return false end

    local gained = 0
    if level == previousLevel then
        if currentExp >= previousExp then gained = currentExp - previousExp end
    elseif level > previousLevel then
        local levelMax = previousMax
        if (not levelMax or levelMax <= 0) and type(GetNumExperiencePointsInLevel) == "function" then
            local ok, value = pcall(GetNumExperiencePointsInLevel, previousLevel)
            if ok and type(value) == "number" then levelMax = value end
        end
        if levelMax and levelMax > previousExp then
            gained = (levelMax - previousExp) + currentExp
        else
            gained = currentExp
        end
    end

    if gained > 0 then
        self:RecordWorldEventExperienceGain(gained, "update")
        return self:AssignExperienceValueToPendingPveKill(gained, reason, "update")
    end
    return false
end

function TPM:ConsumeRecentExperienceForPendingKill(pending)
    if type(pending) ~= "table" or pending.finalized or pending.sawXpDeathResult ~= true then return false end
    if type(self.recentExperienceGains) ~= "table" then return false end
    local nowMs = TPM_KillLogNowMs()
    self:PruneRecentExperienceGains(nowMs)
    local referenceMs = tonumber(pending.xpResultAtMs) or tonumber(pending.atMs) or nowMs
    local bestIndex, bestDistance = nil, nil
    for i = #self.recentExperienceGains, 1, -1 do
        local entry = self.recentExperienceGains[i]
        if type(entry) == "table" and not entry.consumed and (tonumber(entry.gained) or 0) > 0 then
            local distance = math.abs((tonumber(entry.atMs) or 0) - referenceMs)
            -- XP and DIED_XP normally arrive almost together, but either may be
            -- first. 1.5s leaves enough room for UI/event scheduling without
            -- accidentally consuming old quest/discovery XP.
            if distance <= 1500 and (bestDistance == nil or distance < bestDistance) then
                bestIndex, bestDistance = i, distance
            end
        end
    end
    if bestIndex then
        local entry = self.recentExperienceGains[bestIndex]
        entry.consumed = true
        self:FinalizePendingPveKillActivity(pending, tonumber(entry.gained) or 0)
        self:PruneRecentExperienceGains(nowMs)
        return true
    end
    return false
end

function TPM:AssignExperienceToPendingPveKill(reason, level, previousExperience, currentExperience)
    local gained = self:CalculateExperienceGain(level, previousExperience, currentExperience)
    if gained <= 0 then return false end
    local nowMs = TPM_KillLogNowMs()

    -- DIED_XP already tells us that a death awarded XP. Do not reject the XP
    -- event just because ESO reports a different PROGRESS_REASON on some mobs.
    -- First try to attach the event to the oldest waiting DIED_XP kill.
    if type(self.pendingPveKillActivities) == "table" then
        for i = 1, #self.pendingPveKillActivities do
            local pending = self.pendingPveKillActivities[i]
            local markerMs = type(pending) == "table" and (tonumber(pending.xpResultAtMs) or tonumber(pending.atMs) or 0) or 0
            local age = nowMs - markerMs
            if type(pending) == "table" and not pending.finalized and pending.sawXpDeathResult == true
                and age >= -250 and age <= 1800 then
                self:FinalizePendingPveKillActivity(pending, gained)
                return true
            end
        end
    end

    -- Some client/event sequences deliver EVENT_EXPERIENCE_GAIN a few frames
    -- BEFORE ACTION_RESULT_DIED_XP. Keep it briefly so the later death event can
    -- claim the correct value instead of ending up as EP +0.
    self:StoreRecentExperienceGain(reason, level, previousExperience, currentExperience)
    return false
end

-- 3.4.7: real activity tracking. The old "sessions" list represented long
-- login sessions and therefore did not update when a dungeon was completed.
-- Activities are now tracked independently and finalized when the player leaves
-- the dungeon/BG/PvP activity.
function TPM:RecordTrackedActivityGoldGain(currencyType, currencyLocation, newAmount, oldAmount, reason)
    if type(_G.CURT_MONEY) ~= "number" or currencyType ~= _G.CURT_MONEY then return end
    if type(_G.CURRENCY_LOCATION_CHARACTER) == "number" and currencyLocation ~= _G.CURRENCY_LOCATION_CHARACTER then return end
    local delta = (tonumber(newAmount) or 0) - (tonumber(oldAmount) or 0)
    if delta <= 0 then return end
    if self:IsEconomyNonTransactionReason(reason, delta) then return end

    local active = self.activeTrackedActivity
    if type(active) == "table" and self:IsPersistentTrackedActivityKind(active.kind) then
        active.goldEarned = math.max(0, (tonumber(active.goldEarned) or 0) + delta)
    end
    self:RecordWorldEventGoldGain(delta)
end

function TPM:RecordTrackedActivityExperienceGain(reason, level, previousExperience, currentExperience)
    local gained = self:CalculateExperienceGain(level, previousExperience, currentExperience)
    if gained <= 0 then return end

    local active = self.activeTrackedActivity
    if type(active) == "table" and self:IsPersistentTrackedActivityKind(active.kind) then
        active.xpEarned = math.max(0, (tonumber(active.xpEarned) or 0) + gained)
    end
    self:RecordWorldEventExperienceGain(gained, "gain")
end

-- 3.4.32: Quest completion history. ESO removes a completed quest from the
-- journal immediately after turn-in, so cache the visible reward data while the
-- journal index is still valid. EVENT_QUEST_COMPLETE then consumes that cache.
function TPM:CalculateExperienceGain(level, previousExperience, currentExperience)
    local previous = tonumber(previousExperience)
    local current = tonumber(currentExperience)
    if not previous or not current then return 0 end
    if current >= previous then return math.max(0, current - previous) end

    local gained = current
    if type(GetNumExperiencePointsInLevel) == "function" then
        local previousLevel = math.max(1, (tonumber(level) or 1) - 1)
        local ok, levelMax = pcall(GetNumExperiencePointsInLevel, previousLevel)
        if ok and type(levelMax) == "number" and levelMax > previous then
            gained = (levelMax - previous) + current
        end
    end
    return math.max(0, tonumber(gained) or 0)
end

function TPM:CacheQuestCompletionData(journalIndex, fallbackQuestName)
    journalIndex = tonumber(journalIndex)
    if not journalIndex or type(IsValidQuestIndex) ~= "function" or not IsValidQuestIndex(journalIndex) then return end
    if type(GetJournalQuestRewardInfo) ~= "function" or type(GetJournalQuestNumRewards) ~= "function" then return end

    local questName = tostring(fallbackQuestName or "")
    if type(GetJournalQuestName) == "function" then
        local ok, value = pcall(GetJournalQuestName, journalIndex)
        if ok and type(value) == "string" and value ~= "" then questName = value end
    elseif type(GetJournalQuestInfo) == "function" then
        local ok, value = pcall(GetJournalQuestInfo, journalIndex)
        if ok and type(value) == "string" and value ~= "" then questName = value end
    end
    if questName == "" then return end

    self.questCompletionCache = self.questCompletionCache or {}
    local cached = {
        questName = questName,
        gold = 0,
        rewards = {},
        cachedAt = TPM_Now(),
    }

    local count = tonumber(GetJournalQuestNumRewards(journalIndex)) or 0
    for rewardIndex = 1, count do
        local rewardType, rewardName, amount, _, meetsUsageRequirement, _, itemType = GetJournalQuestRewardInfo(journalIndex, rewardIndex)
        amount = tonumber(amount) or 0
        local currencyType = nil
        if type(GetCurrencyTypeFromRewardType) == "function" then
            local ok, value = pcall(GetCurrencyTypeFromRewardType, rewardType)
            if ok then currencyType = value end
        elseif _G.REWARD_TYPE_MONEY and rewardType == _G.REWARD_TYPE_MONEY then
            currencyType = _G.CURT_MONEY
        end

        if currencyType and _G.CURT_MONEY and currencyType == _G.CURT_MONEY then
            cached.gold = cached.gold + math.max(0, amount)
        elseif not currencyType or currencyType == 0 or (_G.CURT_NONE and currencyType == _G.CURT_NONE) then
            local ownedCollectible = _G.REWARD_TYPE_AUTO_ITEM and _G.REWARD_ITEM_TYPE_COLLECTIBLE
                and rewardType == _G.REWARD_TYPE_AUTO_ITEM and itemType == _G.REWARD_ITEM_TYPE_COLLECTIBLE
                and meetsUsageRequirement == false
            if not ownedCollectible and type(rewardName) == "string" and rewardName ~= "" then
                local formatted = rewardName
                if type(zo_strformat) == "function" and _G.SI_TOOLTIP_ITEM_NAME then
                    local ok, value = pcall(zo_strformat, SI_TOOLTIP_ITEM_NAME, rewardName)
                    if ok and type(value) == "string" and value ~= "" then formatted = value end
                end
                cached.rewards[#cached.rewards + 1] = formatted
            end
        end
    end

    self.questCompletionCache[questName] = cached
end

function TPM:GetCachedQuestCompletionData(questName)
    self.questCompletionCache = self.questCompletionCache or {}
    local cached = self.questCompletionCache[tostring(questName or "")]
    if type(cached) ~= "table" then return nil end
    -- Never attach an ancient cache entry to a repeatable quest with the same name.
    if TPM_Now() - (tonumber(cached.cachedAt) or 0) > 3600 then
        self.questCompletionCache[tostring(questName or "")] = nil
        return nil
    end
    return cached
end

local function TPM_GetLocalTimestampParts(timestamp)
    timestamp = tonumber(timestamp) or TPM_Now()
    if timestamp <= 0 then return nil end

    -- Derive the player's current local offset from ESO's own local clock.
    local offset = 0
    if type(GetTimeStamp) == "function" and type(GetSecondsSinceMidnight) == "function" then
        local okStamp, nowStamp = pcall(GetTimeStamp)
        local okLocal, localSeconds = pcall(GetSecondsSinceMidnight)
        nowStamp = okStamp and tonumber(nowStamp) or nil
        localSeconds = okLocal and tonumber(localSeconds) or nil
        if nowStamp and localSeconds then
            local utcSeconds = nowStamp % 86400
            offset = localSeconds - utcSeconds
            if offset > 43200 then offset = offset - 86400 end
            if offset < -43200 then offset = offset + 86400 end
        end
    end

    local adjusted = timestamp + offset
    if type(os) == "table" and type(os.date) == "function" then
        local ok, parts = pcall(os.date, "!*t", adjusted)
        if ok and type(parts) == "table" then return parts end
    end

    -- Fallback: time portion can still be reconstructed without os.date.
    local seconds = adjusted % 86400
    return {
        hour = math.floor(seconds / 3600) % 24,
        min = math.floor(seconds / 60) % 60,
    }
end

local function TPM_GetLocalizedLogDateText(timestamp, lang)
    local p = TPM_GetLocalTimestampParts(timestamp)
    lang = tostring(lang or "en")

    if p and p.year and p.month and p.day then
        if lang == "en" then
            return string.format("%02d/%02d/%04d", p.month, p.day, p.year)
        elseif lang == "fr" then
            return string.format("%02d/%02d/%04d", p.day, p.month, p.year)
        elseif lang == "ru" then
            return string.format("%02d.%02d.%04d", p.day, p.month, p.year)
        end
        return string.format("%02d.%02d.%04d", p.day, p.month, p.year)
    end

    -- Only as a last resort use ESO's client-locale string.
    if type(GetDateStringFromTimestamp) == "function" then
        local ok, value = pcall(GetDateStringFromTimestamp, tonumber(timestamp) or TPM_Now())
        if ok and type(value) == "string" then return value end
    end
    return ""
end

local function TPM_GetLocalizedLogTimeText(timestamp, lang)
    local p = TPM_GetLocalTimestampParts(timestamp)
    if not p or p.hour == nil or p.min == nil then return "" end

    local hour = tonumber(p.hour) or 0
    local minute = tonumber(p.min) or 0
    if tostring(lang or "en") == "en" then
        local suffix = hour >= 12 and "PM" or "AM"
        local displayHour = hour % 12
        if displayHour == 0 then displayHour = 12 end
        return string.format("%d:%02d %s", displayHour, minute, suffix)
    end

    -- DE / FR / RU use a 24-hour clock.
    return string.format("%02d:%02d", hour, minute)
end

local function TPM_GetCurrentLogTimeText()
    local now = type(GetTimeStamp) == "function" and GetTimeStamp() or 0
    return TPM_GetLocalizedLogTimeText(now, TPM and TPM.langCode or "en")
end

local function TPM_GetLogTimeTextFromTimestamp(timestamp)
    return TPM_GetLocalizedLogTimeText(timestamp, TPM and TPM.langCode or "en")
end

function TPM:FormatLogTimestamp(entry)
    if type(entry) ~= "table" then return "" end

    local lang = self.langCode or "en"
    local timestamp = tonumber(entry.timestamp) or 0

    -- Always reformat from the stored timestamp. Older entries may contain
    -- German-formatted cached strings, which must not leak into EN/RU/FR.
    if timestamp > 0 then
        local dateText = TPM_GetLocalizedLogDateText(timestamp, lang)
        local timeText = TPM_GetLocalizedLogTimeText(timestamp, lang)
        if dateText ~= "" and timeText ~= "" then return dateText .. " • " .. timeText end
        return dateText ~= "" and dateText or timeText
    end

    -- Legacy fallback only for entries that predate timestamp storage.
    local dateText = tostring(entry.logDateText or "")
    local timeText = tostring(entry.logTimeText or "")
    if dateText ~= "" and timeText ~= "" then return dateText .. " • " .. timeText end
    return dateText ~= "" and dateText or timeText
end


function TPM:AddActivityLogEntry(entry)
    if type(entry) ~= "table" then return end
    if not TPM_IsMeaningfulDynamicEncounter(entry) then return end
    entry.timestamp = tonumber(entry.timestamp) or TPM_Now()
    if tostring(entry.logDateText or "") == "" then entry.logDateText = TPM_GetLocalizedLogDateText(entry.timestamp, self.langCode or "en") end
    if tostring(entry.logTimeText or "") == "" then entry.logTimeText = TPM_GetCurrentLogTimeText() end
    local store = self:GetHistoryStore()
    if not store then return end
    local isCombat = self:IsCombatLogKind(entry.activityKind)
    local listKey = isCombat and "combatActivities" or "activities"
    if type(store[listKey]) ~= "table" then store[listKey] = {} end
    local list = store[listKey]

    -- Guard against ESO firing the same completion twice. New world-event
    -- entries carry the stable instance id, so suppressing duplicates does not
    -- hide a later event with the same location/name.
    if self:IsWorldEventActivityKind(entry.activityKind) and tonumber(entry.worldEventInstanceId) and tonumber(entry.worldEventInstanceId) > 0 then
        local incomingId = tonumber(entry.worldEventInstanceId)
        local incomingTime = tonumber(entry.timestamp) or TPM_Now()
        for i = #list, math.max(1, #list - 8), -1 do
            local previous = list[i]
            if type(previous) == "table" and tonumber(previous.worldEventInstanceId) == incomingId then
                -- ESO may reuse the same World Event instance id when the same
                -- Dolmen/location activates again later. Only suppress callbacks
                -- from the *same completion*, not a later legitimate run.
                local previousTime = tonumber(previous.timestamp) or 0
                if previousTime > 0 and math.abs(incomingTime - previousTime) <= 15 then return end
            end
        end
    end

    list[#list + 1] = entry
    while #list > 100 do table.remove(list, 1) end
    if self.statisticsWindow and not self.statisticsWindow:IsHidden()
        and self.saved and self.saved.statisticsPage == "history" then
        self:RefreshCombatActivityPanel()
        local scroll = isCombat and self.statisticsCombatKillLogScroll or self.statisticsCombatActivityLogScroll
        if scroll and scroll.ResetToTop then scroll:ResetToTop() end
    end
end

function TPM:RecordQuestActivity(questName, level, previousExperience, currentExperience, championPoints, questType, zoneDisplayType)
    questName = tostring(questName or "")
    if questName == "" then return end
    local cached = self:GetCachedQuestCompletionData(questName)
    local rewards = cached and cached.rewards or nil
    local rewardText = ""
    if type(rewards) == "table" and #rewards > 0 then
        if #rewards == 1 then
            rewardText = rewards[1]
        elseif #rewards == 2 then
            rewardText = rewards[1] .. ", " .. rewards[2]
        else
            rewardText = rewards[1] .. ", " .. rewards[2] .. " +" .. tostring(#rewards - 2)
        end
    end

    local now = TPM_Now()
    local entry = {
        activityKind = "quest",
        activityName = questName,
        questType = questType,
        zoneDisplayType = zoneDisplayType,
        goldEarned = math.max(0, tonumber(cached and cached.gold) or 0),
        xpEarned = self:CalculateExperienceGain(level, previousExperience, currentExperience),
        rewardName = rewardText,
        duration = 0,
        startedAt = now,
        endedAt = now,
        timestamp = now,
        npcKillsDelta = 0,
        pveDeathsDelta = 0,
        pvpKillsDelta = 0,
        pvpDeathsDelta = 0,
    }
    self:AddActivityLogEntry(entry)
    if self.questCompletionCache then self.questCompletionCache[questName] = nil end
end

function TPM:StartTrackedActivity(snapshot)
    if not snapshot then return end
    local kind = snapshot.activityKind or "adventure"
    if kind == "adventure" then return end
    local now = tonumber(snapshot.timestamp) or TPM_Now()
    self.activeTrackedActivity = {
        kind = kind,
        name = snapshot.zoneName or "",
        zoneId = tonumber(snapshot.zoneId) or 0,
        startedAt = now,
        lastSeenAt = now,
        startSnapshot = snapshot,
        lastSnapshot = snapshot,
        texture = tostring(snapshot.activityTexture or ""),
        goldEarned = 0,
        xpEarned = 0,
    }
end

function TPM:FinalizeTrackedActivity(endSnapshot, endedAt)
    local active = self.activeTrackedActivity
    if type(active) ~= "table" or not active.startSnapshot then return end
    endSnapshot = endSnapshot or active.lastSnapshot or self:CaptureHistorySnapshot(false)
    if not endSnapshot then return end
    local endTime = tonumber(endedAt) or tonumber(endSnapshot.timestamp) or TPM_Now()
    local duration = math.max(0, endTime - (tonumber(active.startedAt) or endTime))
    local summary = self:BuildSessionSummary(active.startSnapshot, endSnapshot, active.startedAt, endTime, duration)
    if summary and duration >= 20 then
        summary.activityKind = active.kind or summary.activityKind or "adventure"
        summary.activityName = (active.name and active.name ~= "" and active.name) or summary.activityName or ""
        summary.activityTexture = (active.texture and active.texture ~= "" and active.texture) or summary.activityTexture or ""
        summary.goldEarned = math.max(0, tonumber(active.goldEarned) or 0)
        summary.xpEarned = math.max(0, tonumber(active.xpEarned) or 0)
        self:AddActivityLogEntry(summary)
    end
    self.activeTrackedActivity = nil
    self.pendingTrackedActivitySnapshot = nil
    if self.statisticsWindow and not self.statisticsWindow:IsHidden()
        and self.saved and self.saved.statisticsPage == "history" then
        self:RefreshCombatActivityPanel()
    end
end

function TPM:HandleTrackedActivityDeactivated(snapshot)
    local active = self.activeTrackedActivity
    if type(active) ~= "table" then return end
    snapshot = snapshot or self:CaptureHistorySnapshot(false)
    if snapshot then
        active.lastSnapshot = snapshot
        active.lastSeenAt = snapshot.timestamp or TPM_Now()
        self.pendingTrackedActivitySnapshot = snapshot
    end
end

function TPM:HandleTrackedActivityActivated()
    local snapshot = self:CaptureHistorySnapshot(false)
    if not snapshot then return end

    -- EVENT_PREPARE_FOR_JUMP gives us the destination's real display name and
    -- type before the loading screen. Prefer it for dungeon/raid/BG entries,
    -- because GetUnitZone() may expose only the parent overland zone.
    local jump = self.pendingJumpActivity
    if type(jump) == "table" and (TPM_Now() - (tonumber(jump.at) or 0)) <= 90 then
        if jump.kind and jump.kind ~= "adventure" then
            snapshot.activityKind = jump.kind
            if jump.name and jump.name ~= "" then snapshot.zoneName = jump.name end
            if jump.loadingTexture and jump.loadingTexture ~= "" then snapshot.activityTexture = jump.loadingTexture end
        end
    end
    self.pendingJumpActivity = nil

    local kind = snapshot.activityKind or "adventure"
    local name = snapshot.zoneName or ""
    local zoneId = tonumber(snapshot.zoneId) or 0
    local active = self.activeTrackedActivity

    if type(active) == "table" then
        local sameZone = zoneId > 0 and (tonumber(active.zoneId) or 0) > 0 and zoneId == tonumber(active.zoneId)
        local sameName = tostring(active.name or "") == tostring(name or "")
        -- A loading screen inside the same dungeon/activity is not completion.
        if active.kind == kind and (sameZone or sameName) then
            active.lastSnapshot = snapshot
            active.lastSeenAt = snapshot.timestamp or TPM_Now()
            if zoneId > 0 then active.zoneId = zoneId end
            if name ~= "" then active.name = name end
            if snapshot.activityTexture and snapshot.activityTexture ~= "" then active.texture = snapshot.activityTexture end
            self.pendingTrackedActivitySnapshot = nil
            return
        end

        -- We changed activity/zone. Finish the old activity using the snapshot
        -- captured before the loading screen so the correct dungeon counters
        -- and name are retained.
        local previousSnapshot = self.pendingTrackedActivitySnapshot or active.lastSnapshot
        self:FinalizeTrackedActivity(previousSnapshot, previousSnapshot and previousSnapshot.timestamp or TPM_Now())
    end

    self.pendingTrackedActivitySnapshot = nil
    if kind ~= "adventure" then
        self:StartTrackedActivity(snapshot)
    end
end

function TPM:CaptureHistorySnapshot(forceStatistics)
    local now = TPM_Now()
    local stats = self:GetStatisticsData(forceStatistics == true)
    local player = self:GetPlayerProgressData()
    local esoPlayedSeconds = self:SyncCurrentEsoPlayedTime()
    local combat = self:GetPlayerCombatStatsView()
    local currentZoneId, currentZoneIndex, currentZoneName = self:GetCurrentPlayerZoneIdentity()
    local snapshot = {
        timestamp = now,
        dayKey = TPM_DayKey(now),
        tamrielPercent = stats and stats.percent or 0,
        completedObjectives = stats and stats.completedObjectives or 0,
        totalObjectives = stats and stats.totalObjectives or 0,
        completedZones = stats and stats.completedZones or 0,
        totalZones = stats and stats.totalZones or 0,
        level = player.level or 0,
        cp = player.championPoints or 0,
        pvpKills = combat.pvpKills or 0,
        pvpDeaths = combat.pvpDeaths or 0,
        pvpKd = combat.kd or 0,
        npcKills = combat.npcKills or 0,
        pveDeaths = combat.pveDeaths or 0,
        bossKills = combat.bossKills or 0,
        playSeconds = self:GetCurrentPlaySeconds(),
        esoPlayedSeconds = esoPlayedSeconds or 0,
        currencies = {},
        categories = {},
        zoneId = currentZoneId or 0,
        zoneIndex = currentZoneIndex or 0,
        zoneName = currentZoneName or "",
        activityKind = self:GetCurrentTrackedActivityKind(),
    }

    local economyStats = self:GetEconomyStats()
    for _, definition in ipairs(self:GetEconomyCurrencyDefinitions()) do
        local amounts = self:GetEconomyCurrentAmounts(definition)
        local ledger = economyStats and economyStats.currencies and economyStats.currencies[definition.key] or nil
        snapshot.currencies[definition.key] = {
            current = amounts.current or 0,
            character = amounts.character or 0,
            bank = amounts.bank or 0,
            total = amounts.total or amounts.current or 0,
            -- Cumulative per-character ledger counters. Storing these in each
            -- history point lets the Development page calculate income/spending
            -- for any selected time range without keeping every transaction.
            received = ledger and (ledger.received or 0) or 0,
            spent = ledger and (ledger.spent or 0) or 0,
            bankDeposited = ledger and (ledger.bankDeposited or 0) or 0,
            bankWithdrawn = ledger and (ledger.bankWithdrawn or 0) or 0,
        }
    end

    local trackedCategories = {
        quests = ZONE_COMPLETION_TYPE_PRIORITY_QUESTS,
        skyshards = ZONE_COMPLETION_TYPE_SKYSHARDS,
        bosses = ZONE_COMPLETION_TYPE_GROUP_BOSSES,
        wayshrines = ZONE_COMPLETION_TYPE_WAYSHRINES,
    }
    for key, completionType in pairs(trackedCategories) do
        local row = self:GetSnapshotCategory(stats, completionType)
        snapshot.categories[key] = {
            completed = row and row.completed or 0,
            total = row and row.total or 0,
        }
    end
    return snapshot
end

function TPM:PruneHistory(store, now)
    if not store then return end
    now = tonumber(now) or TPM_Now()
    local retention = Clamp(Round(tonumber(self.saved and self.saved.historyRetentionDays) or HISTORY_RETENTION_DAYS), 30, 1460)
    local cutoffDay = TPM_DayKey(now) - retention
    for key, snapshot in pairs(store.daily or {}) do
        local day = tonumber(key) or tonumber(snapshot and snapshot.dayKey) or 0
        if day < cutoffDay then store.daily[key] = nil end
    end
    for key, extrema in pairs(store.dailyExtrema or {}) do
        local day = tonumber(key) or tonumber(extrema and extrema.dayKey) or 0
        if day < cutoffDay then store.dailyExtrema[key] = nil end
    end

    -- Keep recent intraday points for stock-like graphs. Older history remains
    -- compact as daily close plus daily extrema.
    local sampleCutoff = now - (math.min(retention, HISTORY_SAMPLE_RETENTION_DAYS) * 86400)
    local kept = {}
    for _, sample in ipairs(store.samples or {}) do
        if type(sample) == "table" and (tonumber(sample.timestamp) or 0) >= sampleCutoff then
            kept[#kept + 1] = sample
        end
    end
    while #kept > HISTORY_MAX_SAMPLES do table.remove(kept, 1) end
    store.samples = kept

    local sessions = store.sessions or {}
    while #sessions > HISTORY_MAX_SESSIONS do table.remove(sessions, 1) end
end

function TPM:BuildSessionSummary(startSnapshot, endSnapshot, startedAt, endedAt, activeDuration)
    if not startSnapshot or not endSnapshot then return nil end
    local function CurrencyDelta(key)
        local a = startSnapshot.currencies and startSnapshot.currencies[key]
        local b = endSnapshot.currencies and endSnapshot.currencies[key]
        return ((b and (b.total or b.current)) or 0) - ((a and (a.total or a.current)) or 0)
    end
    local function CategoryDelta(key)
        local a = startSnapshot.categories and startSnapshot.categories[key]
        local b = endSnapshot.categories and endSnapshot.categories[key]
        return ((b and b.completed) or 0) - ((a and a.completed) or 0)
    end
    return {
        startedAt = startedAt or startSnapshot.timestamp or 0,
        endedAt = endedAt or endSnapshot.timestamp or 0,
        duration = activeDuration ~= nil and math.max(0, tonumber(activeDuration) or 0) or math.max(0, (endedAt or 0) - (startedAt or 0)),
        tamrielDelta = (endSnapshot.tamrielPercent or 0) - (startSnapshot.tamrielPercent or 0),
        objectivesDelta = (endSnapshot.completedObjectives or 0) - (startSnapshot.completedObjectives or 0),
        goldDelta = CurrencyDelta("gold"),
        tradeBarsDelta = CurrencyDelta("tradeBars"),
        sealsDelta = CurrencyDelta("seals"),
        crownsDelta = CurrencyDelta("crowns"),
        questsDelta = CategoryDelta("quests"),
        skyshardsDelta = CategoryDelta("skyshards"),
        bossProgressDelta = CategoryDelta("bosses"),
        npcKillsDelta = (endSnapshot.npcKills or 0) - (startSnapshot.npcKills or 0),
        pveDeathsDelta = (endSnapshot.pveDeaths or 0) - (startSnapshot.pveDeaths or 0),
        bossKillsDelta = (endSnapshot.bossKills or 0) - (startSnapshot.bossKills or 0),
        pvpKillsDelta = (endSnapshot.pvpKills or 0) - (startSnapshot.pvpKills or 0),
        pvpDeathsDelta = (endSnapshot.pvpDeaths or 0) - (startSnapshot.pvpDeaths or 0),
        activityKind = endSnapshot.activityKind or startSnapshot.activityKind or "adventure",
        activityName = (endSnapshot.zoneName and endSnapshot.zoneName ~= "" and endSnapshot.zoneName) or startSnapshot.zoneName or "",
    }
end

function TPM:GetHistoryActiveElapsed(active, endAt)
    if type(active) ~= "table" then return 0 end
    local elapsed = math.max(0, tonumber(active.accumulatedSeconds) or 0)
    local segmentStartedAt = tonumber(active.segmentStartedAt)
    if segmentStartedAt and segmentStartedAt > 0 then
        local finish = tonumber(endAt) or TPM_Now()
        if finish >= segmentStartedAt then elapsed = elapsed + (finish - segmentStartedAt) end
    end
    return math.max(0, Round(elapsed))
end

function TPM:PauseHistorySession(store, now, snapshot)
    if not store or type(store.activeSession) ~= "table" then return end
    local active = store.activeSession
    now = tonumber(now) or TPM_Now()
    local segmentStartedAt = tonumber(active.segmentStartedAt)
    if segmentStartedAt and now >= segmentStartedAt then
        active.accumulatedSeconds = math.max(0, (tonumber(active.accumulatedSeconds) or 0) + (now - segmentStartedAt))
    else
        active.accumulatedSeconds = math.max(0, tonumber(active.accumulatedSeconds) or 0)
    end
    active.segmentStartedAt = nil
    active.deactivatedAt = now
    active.lastSeenAt = now
    if snapshot then active.lastSnapshot = snapshot end
end

function TPM:CommitFinishedSessionPlaytime(store, characterKey, activeDuration)
    if not store or type(store.activeSession) ~= "table" then return end
    local duration = math.max(0, Round(tonumber(activeDuration) or self:GetHistoryActiveElapsed(store.activeSession, store.activeSession.lastSeenAt)))
    if duration <= 0 then return end
    local combat = self:GetPlayerCombatStats(characterKey)
    -- Kept as a fallback for clients where GetSecondsPlayed is unavailable.
    -- On normal clients the visible "since TPM" value is derived from ESO's
    -- lifetime /played counter and its stored TPM baseline.
    combat.playSeconds = math.max(0, Round((combat.playSeconds or 0) + duration))
end

function TPM:FinalizeHistorySession(characterKey, store, endedAt)
    if not store or type(store.activeSession) ~= "table" then return end
    local active = store.activeSession
    local endTime = tonumber(endedAt) or tonumber(active.lastSeenAt) or TPM_Now()
    local duration = self:GetHistoryActiveElapsed(active, endTime)
    if active.startSnapshot and active.lastSnapshot then
        local summary = self:BuildSessionSummary(active.startSnapshot, active.lastSnapshot, active.startedAt, endTime, duration)
        if summary and summary.duration >= 60 then
            store.sessions[#store.sessions + 1] = summary
        end
    end
    self:CommitFinishedSessionPlaytime(store, characterKey, duration)
    store.activeSession = nil
    self:PruneHistory(store, endTime)
end

function TPM:FinalizeStaleHistorySession(store, now, characterKey)
    if not store or type(store.activeSession) ~= "table" then return end
    local active = store.activeSession
    now = tonumber(now) or TPM_Now()
    local lastSeen = tonumber(active.deactivatedAt) or tonumber(active.lastSeenAt) or tonumber(active.startedAt) or 0
    if lastSeen <= 0 or (now - lastSeen) <= SESSION_CONTINUITY_SECONDS then return end

    -- If ESO/the client stopped without a clean deactivation, only count up to
    -- our last confirmed checkpoint; never add the offline gap.
    if active.segmentStartedAt then
        local confirmedEnd = tonumber(active.lastSeenAt) or lastSeen
        local segmentStartedAt = tonumber(active.segmentStartedAt) or confirmedEnd
        if confirmedEnd >= segmentStartedAt then
            active.accumulatedSeconds = math.max(0, (tonumber(active.accumulatedSeconds) or 0) + (confirmedEnd - segmentStartedAt))
        end
        active.segmentStartedAt = nil
        active.deactivatedAt = confirmedEnd
        lastSeen = confirmedEnd
    end
    self:FinalizeHistorySession(characterKey or self:GetCurrentCharacterStatsKey(), store, lastSeen)
end

function TPM:FinalizeOtherCharacterHistorySessions(currentKey, now)
    if not self.saved or type(self.saved.historyByCharacter) ~= "table" then return end
    for key, rawStore in pairs(self.saved.historyByCharacter) do
        local store = self:GetHistoryStore(tostring(key)) or rawStore
        if tostring(key) ~= tostring(currentKey) and type(store) == "table" and type(store.activeSession) == "table" then
            -- A different character is now active. Whatever continuity window
            -- remains is irrelevant: the previous character's session is over.
            local active = store.activeSession
            local endTime = tonumber(active.deactivatedAt) or tonumber(active.lastSeenAt) or tonumber(now) or TPM_Now()
            if active.segmentStartedAt then
                local segmentStart = tonumber(active.segmentStartedAt) or endTime
                local confirmedEnd = tonumber(active.lastSeenAt) or endTime
                active.accumulatedSeconds = math.max(0, (tonumber(active.accumulatedSeconds) or 0) + math.max(0, confirmedEnd - segmentStart))
                active.segmentStartedAt = nil
                active.deactivatedAt = confirmedEnd
                endTime = confirmedEnd
            end
            self:FinalizeHistorySession(tostring(key), store, endTime)
        end
    end
end

function TPM:StartOrResumeHistorySession()
    local now = TPM_Now()
    local currentKey = self:GetCurrentCharacterStatsKey()
    self:SyncCurrentEsoPlayedTime()

    -- Finalize any session left by another character, including sessions that
    -- survived a character-select/reload cycle in SavedVariables.
    self:FinalizeOtherCharacterHistorySessions(currentKey, now)

    if not self.saved or self.saved.historyEnabled == false then
        if self.saved then
            local disabledStore = self:GetHistoryStore(currentKey)
            if disabledStore then self:FinalizeStaleHistorySession(disabledStore, now, currentKey) end
        end
        self.historySessionCharacterKey = currentKey
        return
    end
    local store = self:GetHistoryStore(currentKey)
    if not store then return end
    self:FinalizeStaleHistorySession(store, now, currentKey)
    local snapshot = self:CaptureHistorySnapshot(true)
    local active = store.activeSession
    if type(active) ~= "table" then
        active = {
            startedAt = now,
            startSnapshot = snapshot,
            lastSeenAt = now,
            lastSnapshot = snapshot,
            accumulatedSeconds = 0,
            segmentStartedAt = now,
            deactivatedAt = nil,
        }
        store.activeSession = active
    else
        active.accumulatedSeconds = math.max(0, tonumber(active.accumulatedSeconds) or 0)
        if not active.segmentStartedAt then active.segmentStartedAt = now end
        active.deactivatedAt = nil
        active.lastSeenAt = now
        active.lastSnapshot = snapshot
    end
    self.historySessionCharacterKey = currentKey
    self:UpsertDailyHistorySnapshot(snapshot)
    self:InitializeMilestoneBaseline(snapshot)
end

function TPM:UpdateHistoryExtremaForSnapshot(store, snapshot)
    if not store or not snapshot then return end
    if type(store.dailyExtrema) ~= "table" then store.dailyExtrema = {} end
    local dayKey = snapshot.dayKey or TPM_DayKey(snapshot.timestamp)
    local day = store.dailyExtrema[tostring(dayKey)]
    if type(day) ~= "table" then
        day = { dayKey = dayKey, metrics = {} }
        store.dailyExtrema[tostring(dayKey)] = day
    end
    if type(day.metrics) ~= "table" then day.metrics = {} end

    for _, definition in ipairs(self:GetHistoryMetricDefinitions()) do
        local value = tonumber(definition.getter(snapshot))
        if value ~= nil then
            local metric = day.metrics[definition.key]
            if type(metric) ~= "table" then
                metric = { high = value, low = value, highAt = snapshot.timestamp, lowAt = snapshot.timestamp }
                day.metrics[definition.key] = metric
            else
                if metric.high == nil or value > metric.high then
                    metric.high, metric.highAt = value, snapshot.timestamp
                end
                if metric.low == nil or value < metric.low then
                    metric.low, metric.lowAt = value, snapshot.timestamp
                end
            end
        end
    end
end

function TPM:MigrateHistoryExtrema(store)
    if not store or store.extremaVersion == "3.0.3" then return end
    for _, snapshot in pairs(store.daily or {}) do
        if type(snapshot) == "table" then self:UpdateHistoryExtremaForSnapshot(store, snapshot) end
    end
    local active = store.activeSession
    if type(active) == "table" then
        if type(active.startSnapshot) == "table" then self:UpdateHistoryExtremaForSnapshot(store, active.startSnapshot) end
        if type(active.lastSnapshot) == "table" then self:UpdateHistoryExtremaForSnapshot(store, active.lastSnapshot) end
    end
    store.extremaVersion = "3.0.3"
end

function TPM:CreateCompactHistorySample(snapshot)
    if not snapshot then return nil end
    local sample = {
        timestamp = snapshot.timestamp,
        dayKey = snapshot.dayKey,
        tamrielPercent = snapshot.tamrielPercent,
        level = snapshot.level,
        cp = snapshot.cp,
        esoPlayedSeconds = snapshot.esoPlayedSeconds,
        playSeconds = snapshot.playSeconds,
        pvpKd = snapshot.pvpKd,
        pvpKills = snapshot.pvpKills,
        pvpDeaths = snapshot.pvpDeaths,
        npcKills = snapshot.npcKills,
        pveDeaths = snapshot.pveDeaths,
        bossKills = snapshot.bossKills,
        currencies = {},
    }
    for key, currency in pairs(snapshot.currencies or {}) do
        sample.currencies[key] = {
            current = currency.current,
            character = currency.character,
            bank = currency.bank,
            total = currency.total,
            received = currency.received,
            spent = currency.spent,
        }
    end
    return sample
end

function TPM:HistorySnapshotsMeaningfullyDifferent(previous, current)
    if not previous or not current then return true end
    local directKeys = { "tamrielPercent", "level", "cp", "pvpKd", "pvpKills", "pvpDeaths", "npcKills", "pveDeaths", "bossKills" }
    for _, key in ipairs(directKeys) do
        if (tonumber(previous[key]) or 0) ~= (tonumber(current[key]) or 0) then return true end
    end
    for key, currentCurrency in pairs(current.currencies or {}) do
        local previousCurrency = previous.currencies and previous.currencies[key] or nil
        local a = tonumber(previousCurrency and (previousCurrency.total or previousCurrency.current)) or 0
        local b = tonumber(currentCurrency and (currentCurrency.total or currentCurrency.current)) or 0
        local delta = math.abs(b - a)
        local threshold = math.max(1, math.abs(a) * 0.01)
        if delta >= threshold then return true end
        local oldReceived = tonumber(previousCurrency and previousCurrency.received)
        local newReceived = tonumber(currentCurrency and currentCurrency.received)
        local oldSpent = tonumber(previousCurrency and previousCurrency.spent)
        local newSpent = tonumber(currentCurrency and currentCurrency.spent)
        if oldReceived ~= nil and newReceived ~= nil and oldReceived ~= newReceived then return true end
        if oldSpent ~= nil and newSpent ~= nil and oldSpent ~= newSpent then return true end

        if key == "gold" then
            local oldPlayer = tonumber(previousCurrency and previousCurrency.character) or 0
            local newPlayer = tonumber(currentCurrency.character) or 0
            local oldBank = tonumber(previousCurrency and previousCurrency.bank) or 0
            local newBank = tonumber(currentCurrency.bank) or 0
            if math.abs(newPlayer - oldPlayer) >= math.max(1, math.abs(oldPlayer) * 0.01)
                or math.abs(newBank - oldBank) >= math.max(1, math.abs(oldBank) * 0.01) then
                return true
            end
        end
    end
    return false
end

function TPM:RecordHistorySample(store, snapshot, force)
    if not store or not snapshot then return end
    if type(store.samples) ~= "table" then store.samples = {} end
    local compact = self:CreateCompactHistorySample(snapshot)
    if not compact then return end
    local samples = store.samples
    local last = samples[#samples]
    if not last then
        samples[#samples + 1] = compact
        return
    end

    local elapsed = (tonumber(compact.timestamp) or 0) - (tonumber(last.timestamp) or 0)
    local meaningful = self:HistorySnapshotsMeaningfullyDifferent(last, compact)
    if force == true or elapsed >= HISTORY_SAMPLE_INTERVAL_SECONDS or meaningful then
        if elapsed <= 1 and not meaningful then
            samples[#samples] = compact
        else
            samples[#samples + 1] = compact
        end
    else
        -- Tiny changes inside the cadence update the live endpoint without
        -- creating hundreds of points from individual loot ticks.
        samples[#samples] = compact
    end
    while #samples > HISTORY_MAX_SAMPLES do table.remove(samples, 1) end
end

function TPM:UpsertDailyHistorySnapshot(snapshot, forceSample)
    if not self.saved or self.saved.historyEnabled == false or not snapshot then return end
    local store = self:GetHistoryStore()
    if not store then return end
    self:MigrateHistoryExtrema(store)
    local dayKey = snapshot.dayKey or TPM_DayKey(snapshot.timestamp)
    self:UpdateHistoryExtremaForSnapshot(store, snapshot)
    store.daily[tostring(dayKey)] = snapshot
    self:RecordHistorySample(store, snapshot, forceSample == true)
    if type(store.activeSession) == "table" then
        store.activeSession.lastSeenAt = snapshot.timestamp
        store.activeSession.lastSnapshot = snapshot
    end
    self:PruneHistory(store, snapshot.timestamp)
end

function TPM:CheckpointHistory(reason, forceStatistics, suppliedSnapshot)
    self:SyncCurrentEsoPlayedTime()
    if not self.saved or self.saved.historyEnabled == false then return end
    local snapshot = suppliedSnapshot or self:CaptureHistorySnapshot(forceStatistics == true)
    local forceSample = reason == "activated" or reason == "deactivated" or reason == "manual" or reason == "progress"
    self:UpsertDailyHistorySnapshot(snapshot, forceSample)
    local store = self:GetHistoryStore()
    if store then
        store.lastCheckpointReason = tostring(reason or "checkpoint")
        store.lastCheckpointAt = snapshot.timestamp
    end
end

function TPM:QueueEconomyHistoryCheckpoint()
    if not self.saved or self.saved.historyEnabled == false or self.economyHistoryCheckpointQueued then return end
    self.economyHistoryCheckpointQueued = true
    zo_callLater(function()
        TPM.economyHistoryCheckpointQueued = false
        if not TPM.saved or TPM.saved.historyEnabled == false then return end
        local snapshot = TPM:CaptureHistorySnapshot(false)
        TPM:CheckpointHistory("currency", false, snapshot)
        if TPM.statisticsWindow and not TPM.statisticsWindow:IsHidden()
            and TPM.saved.statisticsPage == "history" then
            TPM:RefreshHistoryStatisticsPage()
        end
    end, 250)
end

function TPM:CheckpointHistoryOnDeactivated()
    self:SyncCurrentEsoPlayedTime()
    if not self.saved or self.saved.historyEnabled == false then return end
    local now = TPM_Now()
    local store = self:GetHistoryStore()
    if not store then return end
    -- Use the cache unless progress invalidation already requires a rebuild.
    -- EVENT_PLAYER_DEACTIVATED also fires on ordinary loading screens, so a
    -- forced full Tamriel scan here would be unnecessarily expensive.
    local snapshot = self:CaptureHistorySnapshot(false)
    self:UpsertDailyHistorySnapshot(snapshot)
    self:HandleTrackedActivityDeactivated(snapshot)
    self:PauseHistorySession(store, now, snapshot)
    store.lastCheckpointReason = "deactivated"
    store.lastCheckpointAt = now
end

function TPM:GetCurrentPlaySeconds(characterKey)
    local key = characterKey or self:GetCurrentCharacterStatsKey()
    local stats = self:GetPlayerCombatStats(key)
    local currentKey = self:GetCurrentCharacterStatsKey()

    if tostring(key) == tostring(currentKey) then
        self:SyncCurrentEsoPlayedTime()
    end

    if stats.esoPlayedBaselineSeconds ~= nil and (stats.esoPlayedSeconds or 0) >= stats.esoPlayedBaselineSeconds then
        return math.max(0, Round((stats.esoPlayedSeconds or 0) - stats.esoPlayedBaselineSeconds))
    end

    -- Fallback only: preserve locally accumulated 3.0.x time if the ESO
    -- /played API is unexpectedly unavailable.
    local seconds = stats.playSeconds or 0
    local store = self:GetHistoryStore(key)
    local active = store and store.activeSession
    if active then
        local endAt = active.segmentStartedAt and TPM_Now() or active.lastSeenAt
        seconds = seconds + self:GetHistoryActiveElapsed(active, endAt)
    end
    return math.max(0, Round(seconds))
end

function TPM:InitializeMilestoneBaseline(snapshot)
    if not snapshot then return end
    local state = self:GetMilestoneState()
    if not state or state.initialized then return end
    for _, threshold in ipairs({10, 25, 50, 75, 90, 100}) do
        if (snapshot.tamrielPercent or 0) >= threshold then state.tamriel[tostring(threshold)] = true end
    end
    local stats = self:GetStatisticsData(false)
    for _, zone in ipairs(stats and stats.zones or {}) do
        if zone.percent >= 100 then state.zones[tostring(zone.zoneId)] = true end
    end
    state.initialized = true
end

function TPM:ShowMilestoneMessage(text)
    if not self.saved or self.saved.showMilestones == false or not text or text == "" then return end
    local decorated = "|cE6C45CTamriel Progress Map|r  " .. text
    if type(ZO_Alert) == "function" and _G.UI_ALERT_CATEGORY_ALERT then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, decorated)
    elseif type(d) == "function" then
        d(decorated)
    end
end

function TPM:RecordMilestone(kind, key, label, timestamp)
    local state = self:GetMilestoneState()
    if not state then return end
    state.records[#state.records + 1] = {
        kind = kind,
        key = tostring(key),
        label = label,
        timestamp = timestamp or TPM_Now(),
    }
    while #state.records > 80 do table.remove(state.records, 1) end
end

function TPM:CheckMilestones(snapshot)
    if not self.saved then return end
    local notify = self.saved.showMilestones ~= false
    snapshot = snapshot or self:CaptureHistorySnapshot(false)
    local state = self:GetMilestoneState()
    if not state then return end
    if not state.initialized then
        self:InitializeMilestoneBaseline(snapshot)
        return
    end
    for _, threshold in ipairs({10, 25, 50, 75, 90, 100}) do
        local key = tostring(threshold)
        if (snapshot.tamrielPercent or 0) >= threshold and not state.tamriel[key] then
            state.tamriel[key] = true
            local text = self:L("MILESTONE_TAMRIEL", threshold)
            self:RecordMilestone("tamriel", key, text, snapshot.timestamp)
            if notify then self:ShowMilestoneMessage(text) end
        end
    end
    local stats = self:GetStatisticsData(false)
    for _, zone in ipairs(stats and stats.zones or {}) do
        local key = tostring(zone.zoneId)
        if zone.percent >= 100 and not state.zones[key] then
            state.zones[key] = true
            local text = self:L("MILESTONE_ZONE", zone.name)
            self:RecordMilestone("zone", key, text, snapshot.timestamp)
            if notify then self:ShowMilestoneMessage(text) end
        end
    end
end

function TPM:GetGoalPlannerModeIndex()
    local current = self.saved and self.saved.goalPlannerMode or "near"
    for i, value in ipairs(GOAL_PLANNER_MODES) do if value == current then return i end end
    return 1
end

function TPM:SetGoalPlannerMode(mode)
    local valid = false
    for _, value in ipairs(GOAL_PLANNER_MODES) do if value == mode then valid = true break end end
    if not valid then mode = "near" end
    self.saved.goalPlannerMode = mode
    if self.saved.statisticsPage == "goals" then self.saved.statisticsPage = "progress" end
end

function TPM:GetGoalPlannerCategoryDefinition(key)
    key = key or (self.saved and self.saved.goalPlannerCategory) or "all"
    for _, definition in ipairs(GOAL_CATEGORY_FILTERS) do
        if definition.key == key then return definition end
    end
    return GOAL_CATEGORY_FILTERS[1]
end

function TPM:SetGoalPlannerCategory(key)
    local definition = self:GetGoalPlannerCategoryDefinition(key)
    self.saved.goalPlannerCategory = definition.key
    if self.saved.statisticsPage == "goals" then self.saved.statisticsPage = "progress" end
end

function TPM:CycleGoalPlannerCategory(direction)
    local current = self:GetGoalPlannerCategoryDefinition()
    local index = 1
    for i, definition in ipairs(GOAL_CATEGORY_FILTERS) do
        if definition.key == current.key then index = i break end
    end
    local step = direction or 1
    index = ((index - 1 + step) % #GOAL_CATEGORY_FILTERS) + 1
    self:SetGoalPlannerCategory(GOAL_CATEGORY_FILTERS[index].key)
end

function TPM:GetGoalCategoryRemaining(zoneId, completionType)
    local breakdown = self:GetCompletionBreakdown(zoneId)
    for _, row in ipairs(breakdown or {}) do
        if row.completionType == completionType then
            return math.max(0, (row.total or 0) - (row.completed or 0)), row.total or 0
        end
    end
    return 0, 0
end

function TPM:GetGoalPlannerData(mode, categoryKey)
    mode = mode or (self.saved and self.saved.goalPlannerMode) or "near"
    categoryKey = categoryKey or (self.saved and self.saved.goalPlannerCategory) or "all"
    local categoryDefinition = self:GetGoalPlannerCategoryDefinition(categoryKey)
    local filterType = categoryDefinition.completionType
    local stats = self:GetStatisticsData(false)
    local rows = {}

    for _, zone in ipairs(stats and stats.zones or {}) do
        if zone.percent < 100 then
            local filterRemaining = 0
            if filterType then filterRemaining = self:GetGoalCategoryRemaining(zone.zoneId, filterType) end
            if not filterType or filterRemaining > 0 then
                local breakdown = self:GetCompletionBreakdown(zone.zoneId)
                local missing = {}
                for _, item in ipairs(breakdown or {}) do
                    local remaining = math.max(0, (item.total or 0) - (item.completed or 0))
                    if remaining > 0 then
                        missing[#missing + 1] = {
                            completionType = item.completionType,
                            remaining = remaining,
                            name = self:GetCompletionTypeName(item.completionType),
                        }
                    end
                end
                table.sort(missing, function(a, b)
                    if filterType then
                        local aSelected = a.completionType == filterType
                        local bSelected = b.completionType == filterType
                        if aSelected ~= bSelected then return aSelected end
                    end
                    if a.remaining == b.remaining then return a.name < b.name end
                    return a.remaining < b.remaining
                end)
                local details = {}
                for i = 1, math.min(3, #missing) do
                    details[#details + 1] = string.format("%s: %d", missing[i].name, missing[i].remaining)
                end
                rows[#rows + 1] = {
                    zoneId = zone.zoneId,
                    mapId = zone.mapId,
                    name = zone.name,
                    percent = zone.percent,
                    remaining = zone.remaining,
                    filterRemaining = filterRemaining,
                    detail = #details > 0 and table.concat(details, "  •  ") or self:L("GOAL_NO_DETAILS"),
                    missing = missing,
                }
            end
        end
    end

    table.sort(rows, function(a, b)
        if mode == "near" then
            -- "Nearly finished" answers one simple question: which zone needs
            -- the fewest remaining completion objectives? Percentage only breaks
            -- ties, so this view is intentionally different from Recommended.
            if a.remaining == b.remaining then
                if a.percent == b.percent then return a.name < b.name end
                return a.percent > b.percent
            end
            return a.remaining < b.remaining
        else
            -- Recommended favors overall completion first. When a category
            -- filter is active (e.g. Main quests), only zones missing that
            -- category are included and fewer missing category objectives break
            -- equal-percentage ties.
            if a.percent == b.percent then
                if filterType and a.filterRemaining ~= b.filterRemaining then
                    return a.filterRemaining < b.filterRemaining
                end
                if a.remaining == b.remaining then return a.name < b.name end
                return a.remaining < b.remaining
            end
            return a.percent > b.percent
        end
    end)
    return rows
end

function TPM:GetHistoryMetricDefinitions()
    if self.historyMetricDefinitions then return self.historyMetricDefinitions end
    -- 3.4.5: the old Development page is now a dedicated PvE/PvP page.
    -- Playtime lives on Progress and Total Gold is no longer exposed here.
    -- Hidden definitions remain only so previously stored history stays compatible.
    local definitions = {
        { key = "playTime", labelKey = "HISTORY_METRIC_PLAYTIME", kind = "duration", hidden = true, getter = function(s) return s.esoPlayedSeconds or s.playSeconds or 0 end },
        {
            key = "gold", labelKey = "HISTORY_METRIC_GOLD_TOTAL", kind = "number", currencyKey = "gold", hidden = true,
            getter = function(snapshot)
                local c = snapshot.currencies and snapshot.currencies.gold
                return c and (c.total or c.current) or 0
            end,
        },
        -- The combat dashboard uses npcKills as its navigation key; the graph
        -- itself still reads all four PvE/PvP counters.
        { key = "npcKills", labelKey = "HISTORY_COMBAT", kind = "number", getter = function(s) return s.npcKills or 0 end },
        { key = "pveDeaths", labelKey = "HISTORY_PVE_DEATHS", kind = "number", hidden = true, getter = function(s) return s.pveDeaths or 0 end },
        { key = "pvpKills", labelKey = "HISTORY_PVP_KILLS", kind = "number", hidden = true, getter = function(s) return s.pvpKills or 0 end },
        { key = "pvpDeaths", labelKey = "HISTORY_PVP_DEATHS", kind = "number", hidden = true, getter = function(s) return s.pvpDeaths or 0 end },
    }
    self.historyMetricDefinitions = definitions
    return definitions
end

function TPM:GetHistoryMetricDefinition(key)
    for _, definition in ipairs(self:GetHistoryMetricDefinitions()) do
        if definition.key == key then return definition end
    end
    return self:GetHistoryMetricDefinitions()[1]
end

function TPM:CycleHistoryMetric(direction)
    -- 3.4.5: PvE/PvP is the only visible combat page metric.
    if self.saved then self.saved.historyMetric = "npcKills" end
    self:RefreshHistoryStatisticsPage()
end

function TPM:SetHistoryRange(days)
    days = tonumber(days) or 30
    local valid = false
    for _, value in ipairs(HISTORY_RANGES) do if value == days then valid = true break end end
    self.saved.historyRangeDays = valid and days or 30
    self:RefreshHistoryStatisticsPage()
end

function TPM:ReduceHistoryPoints(points, maximum)
    maximum = math.max(4, tonumber(maximum) or HISTORY_MAX_CHART_POINTS)
    if #points <= maximum then return points end

    -- Preserve local highs/lows inside chronological buckets so spikes survive
    -- downsampling instead of disappearing from the chart.
    local reduced = { points[1] }
    local interior = #points - 2
    local bucketCount = math.max(1, math.floor((maximum - 2) / 2))
    for bucket = 1, bucketCount do
        local startIndex = 2 + math.floor(((bucket - 1) * interior) / bucketCount)
        local endIndex = 1 + math.floor((bucket * interior) / bucketCount)
        startIndex = Clamp(startIndex, 2, #points - 1)
        endIndex = Clamp(endIndex, startIndex, #points - 1)
        local lowIndex, highIndex = startIndex, startIndex
        for i = startIndex, endIndex do
            if points[i].value < points[lowIndex].value then lowIndex = i end
            if points[i].value > points[highIndex].value then highIndex = i end
        end
        if lowIndex == highIndex then
            reduced[#reduced + 1] = points[lowIndex]
        elseif lowIndex < highIndex then
            reduced[#reduced + 1] = points[lowIndex]
            reduced[#reduced + 1] = points[highIndex]
        else
            reduced[#reduced + 1] = points[highIndex]
            reduced[#reduced + 1] = points[lowIndex]
        end
    end
    reduced[#reduced + 1] = points[#points]
    while #reduced > maximum do table.remove(reduced, #reduced - 1) end
    return reduced
end

function TPM:GetHistorySeries(metricKey, rangeDays)
    local store = self:GetHistoryStore()
    if store then self:MigrateHistoryExtrema(store) end
    local def = self:GetHistoryMetricDefinition(metricKey)
    local points, seen = {}, {}
    local now = TPM_Now()
    local cutoffTimestamp = now - ((math.max(1, tonumber(rangeDays) or 30) - 1) * 86400)
    local cutoffDay = TPM_DayKey(cutoffTimestamp)

    local function AddPoint(timestamp, dayKey, value, snapshot, source)
        timestamp = tonumber(timestamp) or 0
        value = tonumber(value)
        if timestamp <= 0 or value == nil or timestamp < cutoffTimestamp then return end
        local dedupe = tostring(Round(timestamp)) .. ":" .. string.format("%.6f", value)
        if seen[dedupe] then return end
        seen[dedupe] = true
        points[#points + 1] = {
            timestamp = timestamp,
            dayKey = dayKey or TPM_DayKey(timestamp),
            value = value,
            snapshot = snapshot,
            source = source,
        }
    end

    for key, snapshot in pairs(store and store.daily or {}) do
        local day = tonumber(key) or tonumber(snapshot.dayKey) or 0
        if day >= cutoffDay then
            AddPoint(snapshot.timestamp or (day * 86400), day, def.getter(snapshot), snapshot, "daily")
        end
    end
    for _, sample in ipairs(store and store.samples or {}) do
        AddPoint(sample.timestamp, sample.dayKey, def.getter(sample), sample, "sample")
    end
    for key, dayExtrema in pairs(store and store.dailyExtrema or {}) do
        local day = tonumber(key) or tonumber(dayExtrema.dayKey) or 0
        if day >= cutoffDay and type(dayExtrema.metrics) == "table" then
            local metric = dayExtrema.metrics[metricKey]
            if type(metric) == "table" then
                AddPoint(metric.lowAt or (day * 86400), day, metric.low, nil, "low")
                AddPoint(metric.highAt or (day * 86400), day, metric.high, nil, "high")
            end
        end
    end

    table.sort(points, function(a,b)
        if a.timestamp == b.timestamp then return (a.value or 0) < (b.value or 0) end
        return a.timestamp < b.timestamp
    end)
    points = self:ReduceHistoryPoints(points, HISTORY_MAX_CHART_POINTS)
    return points, def
end


function TPM:GetDailyPlaytimeHistorySeries(rangeDays)
    local store = self:GetHistoryStore()
    local definition = self:GetHistoryMetricDefinition("playTime")
    local all, seen = {}, {}

    local function AddSnapshot(snapshot)
        if type(snapshot) ~= "table" then return end
        local timestamp = tonumber(snapshot.timestamp) or 0
        local played = tonumber(snapshot.esoPlayedSeconds or snapshot.playSeconds)
        if timestamp <= 0 or played == nil then return end
        local key = tostring(Round(timestamp)) .. ":" .. tostring(Round(played))
        if seen[key] then return end
        seen[key] = true
        all[#all + 1] = { timestamp = timestamp, dayKey = TPM_DayKey(timestamp), played = math.max(0, played) }
    end

    for _, snapshot in pairs(store and store.daily or {}) do AddSnapshot(snapshot) end
    for _, snapshot in ipairs(store and store.samples or {}) do AddSnapshot(snapshot) end
    local active = store and store.activeSession
    if type(active) == "table" then
        AddSnapshot(active.startSnapshot)
        AddSnapshot(active.lastSnapshot)
    end

    table.sort(all, function(a,b) return a.timestamp < b.timestamp end)
    local lastByDay, orderedDays = {}, {}
    for _, entry in ipairs(all) do
        if not lastByDay[entry.dayKey] then orderedDays[#orderedDays + 1] = entry.dayKey end
        lastByDay[entry.dayKey] = entry
    end
    table.sort(orderedDays)

    local cutoffDay = TPM_DayKey(TPM_Now()) - math.max(1, tonumber(rangeDays) or 30) + 1
    local previousPlayed = nil
    local points = {}
    for _, day in ipairs(orderedDays) do
        local entry = lastByDay[day]
        if previousPlayed ~= nil and day >= cutoffDay then
            local delta = math.max(0, (entry.played or 0) - previousPlayed)
            points[#points + 1] = {
                timestamp = entry.timestamp,
                dayKey = day,
                value = delta,
                source = "daily_playtime",
            }
        end
        previousPlayed = entry.played or previousPlayed
    end
    return self:ReduceHistoryPoints(points, HISTORY_MAX_CHART_POINTS), definition
end

function TPM:GetHistoryRangeExtrema(metricKey, rangeDays, points)
    local store = self:GetHistoryStore()
    if store then self:MigrateHistoryExtrema(store) end
    local now = TPM_Now()
    local cutoffDay = TPM_DayKey(now) - math.max(1, tonumber(rangeDays) or 30) + 1
    local high, low
    for key, dayExtrema in pairs(store and store.dailyExtrema or {}) do
        local day = tonumber(key) or tonumber(dayExtrema.dayKey) or 0
        if day >= cutoffDay and type(dayExtrema.metrics) == "table" then
            local metric = dayExtrema.metrics[metricKey]
            if type(metric) == "table" then
                if metric.high ~= nil then high = high == nil and metric.high or math.max(high, metric.high) end
                if metric.low ~= nil then low = low == nil and metric.low or math.min(low, metric.low) end
            end
        end
    end
    for _, point in ipairs(points or {}) do
        high = high == nil and point.value or math.max(high, point.value)
        low = low == nil and point.value or math.min(low, point.value)
    end
    return high or 0, low or 0
end

function TPM:GetHistoryCurrencyLedgerTotals(metricKey, rangeDays)
    local definition = self:GetHistoryMetricDefinition(metricKey)
    local currencyKey = definition and definition.currencyKey
    if not currencyKey then return nil end

    local bankTransferMetric = metricKey == "goldBank"
    local store = self:GetHistoryStore()
    if not store then return { income = 0, expenses = 0, net = 0, available = false, bankTransfers = bankTransferMetric } end

    local now = TPM_Now()
    local cutoff = now - ((math.max(1, tonumber(rangeDays) or 30) - 1) * 86400)
    local entries, seen = {}, {}

    local function AddSnapshot(snapshot)
        if type(snapshot) ~= "table" then return end
        local timestamp = tonumber(snapshot.timestamp) or 0
        if timestamp <= 0 or timestamp < cutoff then return end
        local currency = snapshot.currencies and snapshot.currencies[currencyKey]
        if type(currency) ~= "table" then return end
        local incoming = tonumber(bankTransferMetric and currency.bankDeposited or currency.received)
        local outgoing = tonumber(bankTransferMetric and currency.bankWithdrawn or currency.spent)
        if incoming == nil or outgoing == nil then return end
        local key = tostring(Round(timestamp)) .. ":" .. tostring(incoming) .. ":" .. tostring(outgoing)
        if seen[key] then return end
        seen[key] = true
        entries[#entries + 1] = { timestamp = timestamp, incoming = math.max(0, incoming), outgoing = math.max(0, outgoing) }
    end

    for _, snapshot in pairs(store.daily or {}) do AddSnapshot(snapshot) end
    for _, sample in ipairs(store.samples or {}) do AddSnapshot(sample) end
    local active = store.activeSession
    if type(active) == "table" then
        AddSnapshot(active.startSnapshot)
        AddSnapshot(active.lastSnapshot)
    end

    table.sort(entries, function(a, b)
        if a.timestamp == b.timestamp then return (a.incoming + a.outgoing) < (b.incoming + b.outgoing) end
        return a.timestamp < b.timestamp
    end)
    if #entries < 2 then
        return { income = 0, expenses = 0, net = 0, available = (#entries > 0), bankTransfers = bankTransferMetric }
    end

    local income, expenses = 0, 0
    local previous = entries[1]
    for i = 2, #entries do
        local current = entries[i]
        local incomingDelta = current.incoming - previous.incoming
        local outgoingDelta = current.outgoing - previous.outgoing
        income = income + (incomingDelta >= 0 and incomingDelta or current.incoming)
        expenses = expenses + (outgoingDelta >= 0 and outgoingDelta or current.outgoing)
        previous = current
    end

    income = math.max(0, Round(income))
    expenses = math.max(0, Round(expenses))
    return { income = income, expenses = expenses, net = income - expenses, available = true, bankTransfers = bankTransferMetric }
end

function TPM:GetHistoryRangeCombatStats(rangeDays)
    local store = self:GetHistoryStore()
    local result = { pvpKills = 0, pvpDeaths = 0, pvpKd = 0, npcKills = 0, pveDeaths = 0, bossKills = 0, playSeconds = 0 }
    if not store then return result end

    local now = TPM_Now()
    local cutoff = now - ((math.max(1, tonumber(rangeDays) or 30) - 1) * 86400)
    local entries, seen = {}, {}

    local function AddSnapshot(snapshot)
        if type(snapshot) ~= "table" then return end
        local timestamp = tonumber(snapshot.timestamp) or 0
        if timestamp <= 0 or timestamp < cutoff then return end
        local key = tostring(Round(timestamp)) .. ":" .. tostring(snapshot.pvpKills or 0) .. ":" .. tostring(snapshot.pvpDeaths or 0) .. ":" .. tostring(snapshot.npcKills or 0) .. ":" .. tostring(snapshot.bossKills or 0)
        if seen[key] then return end
        seen[key] = true
        entries[#entries + 1] = snapshot
    end

    for _, snapshot in pairs(store.daily or {}) do AddSnapshot(snapshot) end
    for _, snapshot in ipairs(store.samples or {}) do AddSnapshot(snapshot) end
    local active = store.activeSession
    if type(active) == "table" then
        AddSnapshot(active.startSnapshot)
        AddSnapshot(active.lastSnapshot)
    end

    table.sort(entries, function(a, b) return (tonumber(a.timestamp) or 0) < (tonumber(b.timestamp) or 0) end)
    if #entries < 1 then return result end

    local function SumCounter(field)
        local total = 0
        local previous = tonumber(entries[1][field]) or 0
        for i = 2, #entries do
            local current = tonumber(entries[i][field]) or 0
            local delta = current - previous
            total = total + (delta >= 0 and delta or current)
            previous = current
        end
        return math.max(0, Round(total))
    end

    result.pvpKills = SumCounter("pvpKills")
    result.pvpDeaths = SumCounter("pvpDeaths")
    result.npcKills = SumCounter("npcKills")
    result.pveDeaths = SumCounter("pveDeaths")
    result.bossKills = SumCounter("bossKills")

    local firstPlayed = tonumber(entries[1].esoPlayedSeconds or entries[1].playSeconds) or 0
    local lastPlayed = tonumber(entries[#entries].esoPlayedSeconds or entries[#entries].playSeconds) or firstPlayed
    result.playSeconds = math.max(0, Round(lastPlayed - firstPlayed))
    if result.pvpDeaths > 0 then
        result.pvpKd = result.pvpKills / result.pvpDeaths
    elseif result.pvpKills > 0 then
        result.pvpKd = math.huge
    else
        result.pvpKd = 0
    end
    return result
end

function TPM:GetLatestSessionSummary()
    local store = self:GetHistoryStore()
    local sessions = store and store.sessions or {}
    return sessions[#sessions]
end

function TPM:BuildDebugReport()
    local api = type(GetAPIVersion) == "function" and GetAPIVersion() or 0
    local lang = self.currentLanguage or "?"
    local key = self:GetCurrentCharacterStatsKey()
    local page = self.saved and self.saved.statisticsPage or "?"
    local mode = self.saved and self.saved.calculationMode or "?"
    return string.format("TPM %s | API %s | lang %s | char %s | page %s | mode %s", VERSION, tostring(api), tostring(lang), tostring(key), tostring(page), tostring(mode))
end

function TPM:IsCurrentBattlegroundActive()
    if type(GetCurrentBattlegroundId) == "function" then
        local battlegroundId = GetCurrentBattlegroundId() or 0
        if battlegroundId > 0 then return true end
    end
    if type(IsActiveWorldBattleground) == "function" and IsActiveWorldBattleground() then
        return true
    end
    return false
end

function TPM:IsInPvPEnvironment()
    if self:IsCurrentBattlegroundActive() then return true end
    if type(IsPlayerInAvAWorld) == "function" and IsPlayerInAvAWorld() then return true end
    if type(IsInCampaign) == "function" and IsInCampaign() then return true end
    return false
end

local function NormalizeDisplayName(name)
    return string.lower(tostring(name or ""))
end

function TPM:IsDuplicatePvPKillFeed(killerDisplayName, victimDisplayName, isKillLocation)
    local now = type(GetFrameTimeMilliseconds) == "function" and GetFrameTimeMilliseconds() or ((type(GetTimeStamp) == "function" and GetTimeStamp() or 0) * 1000)
    self.pvpKillFeedRecurrence = self.pvpKillFeedRecurrence or {}
    local suffix = NormalizeDisplayName(killerDisplayName) .. "|" .. NormalizeDisplayName(victimDisplayName)
    local sourcePrefix = isKillLocation == true and "B|" or "L|"
    local otherPrefix = isKillLocation == true and "L|" or "B|"
    local sourceKey = sourcePrefix .. suffix
    local otherKey = otherPrefix .. suffix
    local otherTime = self.pvpKillFeedRecurrence[otherKey]
    if otherTime and (now - otherTime) >= 0 and (now - otherTime) <= 10000 then
        -- ESO can raise the same PvP death once from the local unit state and
        -- once from the server kill-location feed. Vanilla ChatHandlers uses a
        -- 10-second counterpart recurrence window for exactly this case.
        self.pvpKillFeedRecurrence[otherKey] = nil
        return true
    end
    self.pvpKillFeedRecurrence[sourceKey] = now
    self.pvpKillFeedRecurrenceWrites = (self.pvpKillFeedRecurrenceWrites or 0) + 1
    if self.pvpKillFeedRecurrenceWrites >= 24 then
        self.pvpKillFeedRecurrenceWrites = 0
        for key, timestamp in pairs(self.pvpKillFeedRecurrence) do
            if (now - (timestamp or 0)) > 20000 then self.pvpKillFeedRecurrence[key] = nil end
        end
    end
    return false
end

function TPM:IsDuplicateCombatCounterEvent(key, windowMs)
    local now = type(GetFrameTimeMilliseconds) == "function" and GetFrameTimeMilliseconds() or ((type(GetTimeStamp) == "function" and GetTimeStamp() or 0) * 1000)
    self.combatCounterRecurrence = self.combatCounterRecurrence or {}
    local lastTime = self.combatCounterRecurrence[key]
    if lastTime and (now - lastTime) >= 0 and (now - lastTime) <= (windowMs or 1200) then
        return true
    end
    self.combatCounterRecurrence[key] = now

    -- Keep the recurrence table tiny even during long PvP sessions.
    self.combatCounterRecurrenceWrites = (self.combatCounterRecurrenceWrites or 0) + 1
    if self.combatCounterRecurrenceWrites >= 32 then
        self.combatCounterRecurrenceWrites = 0
        for oldKey, oldTime in pairs(self.combatCounterRecurrence) do
            if (now - (oldTime or 0)) > 12000 then
                self.combatCounterRecurrence[oldKey] = nil
            end
        end
    end
    return false
end

function TPM:RecordPvPResult(killerDisplayName, victimDisplayName, sourceTag, killerCharacterName, victimCharacterName)
    local me = NormalizeDisplayName(type(GetDisplayName) == "function" and GetDisplayName() or "")
    local killer = NormalizeDisplayName(killerDisplayName)
    local victim = NormalizeDisplayName(victimDisplayName)
    if me == "" or victim == "" then return end

    local key = string.format("%s|%s|%s", tostring(sourceTag or "pvp"), killer, victim)
    local duplicateWindow = sourceTag == "pvp" and 10000 or 1800
    if self:IsDuplicateCombatCounterEvent(key, duplicateWindow) then return end

    if victim == me then
        self:IncrementPlayerCombatStat("pvpDeaths", 1)
    end
    if killer == me and victim ~= me then
        self:IncrementPlayerCombatStat("pvpKills", 1)
        local name = tostring(victimCharacterName or "")
        if name == "" then name = tostring(victimDisplayName or "") end
        if type(zo_strformat) == "function" and name ~= "" then name = zo_strformat("<<C:1>>", name) end
        local now = TPM_Now()
        self:AddActivityLogEntry({
            activityKind = "killPlayer",
            activityName = name,
            xpEarned = 0,
            goldEarned = 0,
            difficulty = "player",
            duration = 0,
            startedAt = now,
            endedAt = now,
            timestamp = now,
            npcKillsDelta = 0,
            pveDeathsDelta = 0,
            pvpKillsDelta = 1,
            pvpDeathsDelta = 0,
        })
    end
end

function TPM:RecordBossDefeat(unitTag)
    if not unitTag or not string.match(unitTag, "^boss%d+$") then return end
    local name = type(GetUnitName) == "function" and (GetUnitName(unitTag) or "") or ""
    local key = string.format("boss|%s|%s", tostring(unitTag), tostring(name))
    if self:IsDuplicateCombatCounterEvent(key, 8000) then return end
    self:IncrementPlayerCombatStat("bossKills", 1)
    self:PromoteOrQueueBossKillActivity(name)
end

function TPM:GetOverviewPercentText(percent)
    percent = Clamp(Round(percent or 0), 0, 100)
    if percent >= 100 then
        local mode = self.saved and self.saved.hundredDisplayMode or "percent"
        if mode == "check" then
            local iconSize = Clamp((self.GetProgressFontSize and self:GetProgressFontSize("overlay")) or 24, 18, 48)
            if type(zo_iconFormatInheritColor) == "function" then
                return zo_iconFormatInheritColor("EsoUI/Art/Buttons/accept_up.dds", iconSize, iconSize)
            elseif type(zo_iconFormat) == "function" then
                return zo_iconFormat("EsoUI/Art/Buttons/accept_up.dds", iconSize, iconSize)
            end
            return "✓"
        elseif mode == "hidden" then
            -- The explicit 100% quick filter temporarily reveals completed
            -- zones so the filter remains useful even when they are normally hidden.
            if self.saved and self.saved.quickFilter == "complete" then
                return "100%"
            end
            return nil
        end
    end
    return string.format("%d%%", percent)
end

function TPM:MatchesQuickFilter(percent)
    local filter = self.saved and self.saved.quickFilter or "all"
    if filter == "incomplete" then
        return percent < 100
    elseif filter == "under50" then
        return percent < 50
    elseif filter == "complete" then
        return percent >= 100
    end
    return true
end

local function SafeZoneName(zoneId)
    -- ESO's native GetZoneNameById() always follows the game-client language.
    -- TPM can be switched independently between DE/EN/RU, so use LibZone's
    -- preloaded localized zone-name data first. This keeps the statistics list,
    -- map labels and tooltips in the language selected inside TPM.
    local lang = TPM and TPM.langCode or nil
    local libZone = _G.LibZone
    if libZone and lang then
        local namesByLanguage = libZone.preloadedZoneNames
        local languageNames = namesByLanguage and namesByLanguage[lang]
        local localizedName = languageNames and languageNames[zoneId]
        if type(localizedName) == "string" and localizedName ~= "" then
            return localizedName
        end

        -- LibZone may have learned a newly added zone in SavedVariables before
        -- its bundled table is updated. Use that as a second source when present.
        local savedLocalized = libZone.localizedZoneData and libZone.localizedZoneData[lang]
        localizedName = savedLocalized and savedLocalized[zoneId]
        if type(localizedName) == "string" and localizedName ~= "" then
            return localizedName
        end
    end

    -- Safe fallback for a brand-new zone not yet present in LibZone. In this
    -- case ESO can still show the zone, but it will use the client language.
    local name = GetZoneNameById(zoneId)
    if not name or name == "" then
        return tostring(zoneId)
    end
    return ZO_CachedStrFormat(SI_ZONE_NAME, name)
end

function TPM:IsProgressZoneAvailable(zoneId)
    if type(zoneId) ~= "number" or zoneId <= 0 then
        return false
    end

    -- DLC/chapter ownership is represented by the zone collectible lock.
    if type(GetZoneIndex) == "function" and type(IsZoneCollectibleLocked) == "function" then
        local zoneIndex = GetZoneIndex(zoneId)
        if zoneIndex and zoneIndex > 0 and IsZoneCollectibleLocked(zoneIndex) then
            return false
        end
    end

    -- Do not reject a zone merely because IsZoneStoryZoneAvailable() is false:
    -- several small/special maps can still expose valid completion counters via
    -- their own zone id or a fallback story zone. Ownership locking is the safe
    -- filter here.
    return true
end

function TPM:GetGameLanguage()
    local language = "en"
    if type(GetCVar) == "function" then
        language = zo_strlower(GetCVar("language.2") or "en")
    end
    if string.sub(language, 1, 2) == "de" then return "de" end
    if string.sub(language, 1, 2) == "ru" then return "ru" end
    if string.sub(language, 1, 2) == "fr" then return "fr" end
    return "en"
end

function TPM:ResolveLanguage()
    local requested = self.saved and self.saved.language or "auto"
    if requested ~= "de" and requested ~= "en" and requested ~= "ru" and requested ~= "fr" then
        requested = self:GetGameLanguage()
    end

    local translations = TamrielProgressMap_Localization or {}
    if not translations[requested] then
        requested = "en"
    end

    self.langCode = requested
    self.locale = translations[requested] or translations["en"] or {}
end

function TPM:L(key, ...)
    local locale = self.locale or (TamrielProgressMap_Localization and TamrielProgressMap_Localization["en"]) or {}
    local value = locale[key]
    if value == nil then
        local english = TamrielProgressMap_Localization and TamrielProgressMap_Localization["en"]
        value = english and english[key] or key
    end
    if select("#", ...) > 0 then
        return string.format(value, ...)
    end
    return value
end

function TPM:NormalizeFontStyle(style)
    if style == "map" then
        return "handwritten" -- legacy name used up to v1.5.4
    end
    if FONT_PROFILES[style] then
        return style
    end
    return nil
end

function TPM:GetFontProfile(style)
    style = self:NormalizeFontStyle(style or (self.saved and self.saved.fontStyle) or "classic") or "classic"
    return FONT_PROFILES[style] or FONT_PROFILES.classic
end

function TPM:GetFontStyleName(style)
    style = self:NormalizeFontStyle(style) or "classic"
    local key = FONT_STYLE_NAME_KEYS[style] or FONT_STYLE_NAME_KEYS.classic
    return self:L(key)
end

function TPM:IsValidFontStyle(style)
    return self:NormalizeFontStyle(style) ~= nil
end

function TPM:GetAdjacentFontStyle(style, direction)
    style = self:NormalizeFontStyle(style) or "classic"
    local currentIndex = 1
    for index, key in ipairs(FONT_STYLE_ORDER) do
        if key == style then
            currentIndex = index
            break
        end
    end
    local count = #FONT_STYLE_ORDER
    local newIndex = ((currentIndex - 1 + direction) % count) + 1
    return FONT_STYLE_ORDER[newIndex]
end

function TPM:GetProgressFontSpec(kind)
    local profile = self:GetFontProfile(self.saved and self.saved.fontStyle or "classic")
    local baseSpec = kind == "header" and profile.header or profile.overlay
    local scale = kind == "header"
        and (self.saved and self.saved.headerPercentScale or DEFAULTS.headerPercentScale)
        or (self.saved and self.saved.mapPercentScale or DEFAULTS.mapPercentScale)
    return ScaleFontSpec(baseSpec, scale)
end

function TPM:GetProgressFontSize(kind)
    local spec = self:GetProgressFontSpec(kind)
    return tonumber(string.match(spec or "", "|(%d+)")) or (kind == "header" and 46 or 28)
end

function TPM:ApplyProgressFont(control, kind)
    if not control then return end
    control:SetFont(self:GetProgressFontSpec(kind))
end

function TPM:ApplyProgressFonts()
    if self.headerLabel then
        self:ApplyProgressFont(self.headerLabel, "header")
    end
    for _, label in ipairs(self.overlayLabels) do
        self:ApplyProgressFont(label, "overlay")
    end
    for _, label in ipairs(self.labelPool) do
        self:ApplyProgressFont(label, "overlay")
    end
end

function TPM:ApplyQuestRewardFonts()
    local style = self.saved and self.saved.questFontStyle or "classic"
    local profile = self:GetFontProfile(style)
    if self.questRewardTitle then
        self.questRewardTitle:SetFont(profile.questTitle or FONT_PROFILES.classic.questTitle)
    end
    if self.questRewardLines then
        self.questRewardLines:SetFont(profile.questBody or FONT_PROFILES.classic.questBody)
    end
    self:UpdateQuestRewardLayout()
    if self.saved and self.saved.questRewardAutoSize then
        self:AutoSizeQuestRewardWindow()
    end
end

function TPM:IsWorldMapVisible()
    -- Track keyboard and gamepad map scenes independently. A stale false flag
    -- must never override ESO's actual scene/control visibility.
    if self.worldMapSceneVisible == true or self.gamepadWorldMapSceneVisible == true then
        return true
    end

    if WORLD_MAP_SCENE and WORLD_MAP_SCENE.IsShowing and WORLD_MAP_SCENE:IsShowing() then
        return true
    end
    if GAMEPAD_WORLD_MAP_SCENE and GAMEPAD_WORLD_MAP_SCENE.IsShowing and GAMEPAD_WORLD_MAP_SCENE:IsShowing() then
        return true
    end

    if SCENE_MANAGER and SCENE_MANAGER.IsShowing then
        if SCENE_MANAGER:IsShowing("worldMap") or SCENE_MANAGER:IsShowing("gamepad_worldMap") then
            return true
        end
    end

    if ZO_WorldMap and ZO_WorldMap.IsHidden then
        return not ZO_WorldMap:IsHidden()
    end
    return false
end

-- Unlike IsWorldMapVisible(), this intentionally ignores ZO_WorldMap control
-- visibility. Minimap addons such as Votan's Minimap can reuse/show that control
-- while the real world-map scene is closed. Full-map-only UI (quick filters)
-- must therefore use the scene state instead.
function TPM:IsFullWorldMapSceneVisible()
    if self.worldMapSceneVisible == true or self.gamepadWorldMapSceneVisible == true then
        return true
    end
    if WORLD_MAP_SCENE and WORLD_MAP_SCENE.IsShowing and WORLD_MAP_SCENE:IsShowing() then
        return true
    end
    if GAMEPAD_WORLD_MAP_SCENE and GAMEPAD_WORLD_MAP_SCENE.IsShowing and GAMEPAD_WORLD_MAP_SCENE:IsShowing() then
        return true
    end
    if SCENE_MANAGER and SCENE_MANAGER.IsShowing then
        if SCENE_MANAGER:IsShowing("worldMap") or SCENE_MANAGER:IsShowing("gamepad_worldMap") then
            return true
        end
    end
    return false
end

function TPM:GetCompletionTypeName(completionType)
    local key = COMPLETION_LOCALIZATION_KEYS[completionType]
    if key then
        return self:L(key)
    end
    local fallback = GetString("SI_ZONECOMPLETIONTYPE", completionType)
    if fallback and fallback ~= "" then
        return fallback
    end
    return tostring(completionType)
end

-- Update 50/51 Zone Guide compatibility. Update 51 exposes the ...AndIndex
-- variants; Update 50 uses the older two-argument names. Passing nil for the
-- optional index asks for the category total, matching the old behavior.
function TPM:GetZoneCompletionActivityTotal(zoneId, completionType)
    if type(_G.GetNumZoneActivitiesForZoneCompletionTypeAndIndex) == "function" then
        local ok, value = pcall(_G.GetNumZoneActivitiesForZoneCompletionTypeAndIndex, zoneId, completionType, nil)
        if ok and tonumber(value) then return math.max(0, tonumber(value) or 0) end
    end
    if type(_G.GetNumZoneActivitiesForZoneCompletionType) == "function" then
        local ok, value = pcall(_G.GetNumZoneActivitiesForZoneCompletionType, zoneId, completionType)
        if ok and tonumber(value) then return math.max(0, tonumber(value) or 0) end
    end
    return 0
end

function TPM:GetZoneCompletionActivityCompleted(zoneId, completionType)
    if type(_G.GetNumCompletedZoneActivitiesForZoneCompletionTypeAndIndex) == "function" then
        local ok, value = pcall(_G.GetNumCompletedZoneActivitiesForZoneCompletionTypeAndIndex, zoneId, completionType, nil)
        if ok and tonumber(value) then return math.max(0, tonumber(value) or 0) end
    end
    if type(_G.GetNumCompletedZoneActivitiesForZoneCompletionType) == "function" then
        local ok, value = pcall(_G.GetNumCompletedZoneActivitiesForZoneCompletionType, zoneId, completionType)
        if ok and tonumber(value) then return math.max(0, tonumber(value) or 0) end
    end
    return 0
end

function TPM:GetCompletionBreakdown(zoneId)
    local breakdown = {}
    local completedTotal = 0
    local availableTotal = 0
    local categoryRatioTotal = 0
    local categoryCount = 0

    if type(zoneId) ~= "number" or zoneId <= 0 then
        return breakdown, 0, 0, 0, 0, 0
    end

    for _, completionType in ipairs(COMPLETION_TYPES) do
        local total = self:GetZoneCompletionActivityTotal(zoneId, completionType)
        if total > 0 then
            local completed = self:GetZoneCompletionActivityCompleted(zoneId, completionType)
            completed = Clamp(completed, 0, total)
            local categoryPercent = Clamp(Round((completed / total) * 100), 0, 100)
            if completed < total and categoryPercent >= 100 then
                categoryPercent = 99
            end

            completedTotal = completedTotal + completed
            availableTotal = availableTotal + total
            categoryRatioTotal = categoryRatioTotal + (completed / total)
            categoryCount = categoryCount + 1

            breakdown[#breakdown + 1] =
            {
                completionType = completionType,
                completed = completed,
                total = total,
                percent = categoryPercent,
            }
        end
    end

    local objectivePercent = 0
    if availableTotal > 0 then
        objectivePercent = Round((completedTotal / availableTotal) * 100)
    end

    local categoryPercent = 0
    if categoryCount > 0 then
        categoryPercent = Round((categoryRatioTotal / categoryCount) * 100)
    end

    local mode = self.saved and self.saved.calculationMode or "objectives"
    local percent = mode == "categories" and categoryPercent or objectivePercent

    -- Never report 100% from rounding while at least one objective is still open.
    -- This also prevents "hide completed" from hiding a 99.x% zone.
    if availableTotal > 0 and completedTotal < availableTotal and percent >= 100 then
        percent = 99
    end

    return breakdown, completedTotal, availableTotal, Clamp(percent, 0, 100), categoryRatioTotal, categoryCount
end

function TPM:GetResolvedCompletion(zoneId)
    local breakdown, completedTotal, availableTotal, percent = self:GetCompletionBreakdown(zoneId)
    local progressZoneId = zoneId

    if availableTotal <= 0 and type(GetZoneStoryZoneIdForZoneId) == "function" then
        local storyZoneId = GetZoneStoryZoneIdForZoneId(zoneId)
        if storyZoneId and storyZoneId > 0 and storyZoneId ~= zoneId then
            local storyBreakdown, storyCompleted, storyAvailable, storyPercent = self:GetCompletionBreakdown(storyZoneId)
            if storyAvailable > 0 then
                breakdown = storyBreakdown
                completedTotal = storyCompleted
                availableTotal = storyAvailable
                percent = storyPercent
                progressZoneId = storyZoneId
            end
        end
    end

    return breakdown, completedTotal, availableTotal, percent, progressZoneId
end


-- 2.6.14: Match the native HUD lifecycle. Tamriel Tomes is visible on the
-- HUD/HUD-UI scenes, but disappears when the world map (M), game menu (ESC) or
-- another full-screen scene takes over. The Skyshard goal now follows exactly
-- that scene rule instead of being an always-on top-level overlay.
function TPM:IsStatisticsAllowedInCurrentScene()
    local sceneManager = _G.SCENE_MANAGER
    if not sceneManager or type(sceneManager.GetCurrentScene) ~= "function" then return true end
    local ok, currentScene = pcall(sceneManager.GetCurrentScene, sceneManager)
    if not ok or not currentScene then return true end
    return currentScene == _G.HUD_SCENE
        or currentScene == _G.HUD_UI_SCENE
        or currentScene == _G.WORLD_MAP_SCENE
        or currentScene == _G.GAMEPAD_WORLD_MAP_SCENE
end

function TPM:RefreshStandaloneStatisticsSceneVisibility()
    local window = self.statisticsWindow
    if not window or not self.statisticsOpenedStandalone then return end

    -- 2.6.34: ESC should close a standalone journal instead of merely hiding it.
    -- Compare both the scene object and its name for compatibility across UI revisions.
    local sceneManager = _G.SCENE_MANAGER
    local currentScene = nil
    if sceneManager and type(sceneManager.GetCurrentScene) == "function" then
        local ok, value = pcall(sceneManager.GetCurrentScene, sceneManager)
        if ok then currentScene = value end
    end
    local currentSceneName = ""
    if currentScene and type(currentScene.GetName) == "function" then
        local ok, value = pcall(currentScene.GetName, currentScene)
        if ok then currentSceneName = tostring(value or "") end
    end
    local lowerSceneName = zo_strlower(tostring(currentSceneName or ""))
    if currentScene == _G.GAME_MENU_SCENE or string.find(lowerSceneName, "gamemenu", 1, true) then
        self:HideStatisticsWindow()
        return
    end
    -- When ESC exits camera UI mode directly (HUD-UI -> HUD), close TPM as well.
    if self.statisticsOwnsUIMode and type(_G.IsGameCameraUIModeActive) == "function" then
        local ok, active = pcall(_G.IsGameCameraUIModeActive)
        local now = type(_G.GetFrameTimeMilliseconds) == "function" and (_G.GetFrameTimeMilliseconds() or 0) or 0
        local openedAt = tonumber(self.statisticsUIModeOpenedAt) or 0
        if ok and active == false and (openedAt <= 0 or now - openedAt > 200) then
            self:HideStatisticsWindow()
            return
        end
    end

    local allowed = self:IsStatisticsAllowedInCurrentScene()
    if allowed then
        if self.statisticsTemporarilyHiddenForScene then
            self.statisticsTemporarilyHiddenForScene = false
            window:SetHidden(false)
            self:RefreshStatisticsWindow()
            if self.economyDetailTemporarilyHiddenForScene and self.economyDetailWindow then
                self.economyDetailTemporarilyHiddenForScene = false
                self.economyDetailWindow:SetHidden(false)
                self:RefreshEconomyDetailWindow()
            end
        end
    elseif not window:IsHidden() then
        self.statisticsTemporarilyHiddenForScene = true
        self:HideStatisticsHoverTooltips()
        self:HideStatisticsFocusDropdown()
        -- 2.6.34: HideStatisticsHoverTooltips already hides the achievement tooltip.
        -- Do not call the later local TPM_HideAchievementTooltip here; it is nil at this point in Lua load order.
        if self.economyDetailWindow and not self.economyDetailWindow:IsHidden() then
            self.economyDetailTemporarilyHiddenForScene = true
            self.economyDetailWindow:SetHidden(true)
        end
        window:SetHidden(true)
    end
end

function TPM:IsSkyshardGoalHudSceneVisible()
    -- Use the scene manager's *current* scene first. A HUD scene can still be
    -- technically in a shown state while another full-screen scene is taking
    -- over. Requiring HUD/HUD-UI to be the current scene makes the TPM block
    -- disappear on M, ESC, inventory and other full-screen menus exactly like
    -- ESO's native tracker instead of behaving like an always-on overlay.
    local sceneManager = _G.SCENE_MANAGER
    if sceneManager and type(sceneManager.GetCurrentScene) == "function" then
        local ok, currentScene = pcall(sceneManager.GetCurrentScene, sceneManager)
        if ok and currentScene then
            if currentScene == _G.HUD_SCENE or currentScene == _G.HUD_UI_SCENE then
                return true
            end
            return false
        end
    end

    -- Compatibility fallback for clients where the scene manager is not yet
    -- fully initialized during addon startup.
    local function SceneVisible(scene)
        if not scene then return false end
        if type(scene.IsShowing) == "function" then
            local ok, visible = pcall(scene.IsShowing, scene)
            if ok and visible then return true end
        end
        if type(scene.GetState) == "function" then
            local ok, state = pcall(scene.GetState, scene)
            if ok and (state == _G.SCENE_SHOWING or state == _G.SCENE_SHOWN) then return true end
        end
        return false
    end
    return SceneVisible(_G.HUD_SCENE) or SceneVisible(_G.HUD_UI_SCENE)
end

-- 2.6.13: Personal Skyshard HUD renderer rebuilt around a true top-level
-- window. Earlier test builds used a normal GuiRoot child and tried to anchor
-- to ESO's quest tracker container. On current clients that container can have
-- scene-dependent geometry/visibility, so an enabled goal could exist but never
-- become effectively visible. The goal now owns its own top-level window and
-- uses an independently resolved HUD anchor.
function TPM:CreateSkyshardGoalWidget()
    if self.skyshardGoalWidget then return end
    if not WINDOW_MANAGER or not GuiRoot then return end

    local widgetName = ADDON_NAME .. "SkyshardGoalHUD"
    local widget = nil
    if type(WINDOW_MANAGER.CreateTopLevelWindow) == "function" then
        local ok, control = pcall(WINDOW_MANAGER.CreateTopLevelWindow, WINDOW_MANAGER, widgetName)
        if ok then widget = control end
    end
    if not widget then
        local ok, control = pcall(WINDOW_MANAGER.CreateControl, WINDOW_MANAGER, widgetName, GuiRoot, CT_CONTROL)
        if ok then widget = control end
    end
    if not widget then return end

    local savedWidth = self.saved and tonumber(self.saved.skyshardGoalCustomWidth) or nil
    local savedHeight = self.saved and tonumber(self.saved.skyshardGoalCustomHeight) or nil
    local initialWidth = Clamp(savedWidth or 360, 230, 760)
    local initialHeight = Clamp(savedHeight or 60, 60, 220)
    widget:SetDimensions(initialWidth, initialHeight)
    widget:SetMouseEnabled(false)
    if widget.SetMovable then widget:SetMovable(false) end
    if widget.SetClampedToScreen then widget:SetClampedToScreen(true) end
    if widget.SetAlpha then widget:SetAlpha(1) end
    if widget.SetDrawTier then widget:SetDrawTier(DT_HIGH) end
    if widget.SetDrawLayer then widget:SetDrawLayer(DL_OVERLAY) end
    if widget.SetDrawLevel then widget:SetDrawLevel(200) end

    -- 2.6.25: The HUD itself remains completely transparent in normal play.
    -- The golden editing frame appears only while the gear button is active.
    local editBackdrop = WINDOW_MANAGER:CreateControl(widgetName .. "EditBackdrop", widget, CT_BACKDROP)
    editBackdrop:SetAnchorFill(widget)
    editBackdrop:SetCenterColor(0.06, 0.05, 0.02, 0.16)
    editBackdrop:SetEdgeColor(1.00, 0.82, 0.24, 0.98)
    editBackdrop:SetEdgeTexture(nil, 1, 1, 2)
    editBackdrop:SetMouseEnabled(false)
    editBackdrop:SetHidden(true)

    local title = WINDOW_MANAGER:CreateControl(widgetName .. "Title", widget, CT_LABEL)
    title:SetAnchor(TOPLEFT, widget, TOPLEFT, 0, 0)
    title:SetAnchor(TOPRIGHT, widget, TOPRIGHT, 0, 0)
    title:SetHeight(24)
    title:SetFont("$(BOLD_FONT)|19|soft-shadow-thick")
    title:SetColor(1.00, 0.82, 0.24, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    title:SetMouseEnabled(false)

    local progress = WINDOW_MANAGER:CreateControl(widgetName .. "Progress", widget, CT_LABEL)
    -- 2.6.28: Match ESO's native tracker indentation. The white detail line
    -- begins slightly to the right of the yellow title/icon row, just like the
    -- Tamriel Tomes objective text beneath its yellow heading.
    progress:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 36, -1)
    progress:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, 28, -1)
    progress:SetHeight(23)
    progress:SetFont("$(BOLD_FONT)|17|soft-shadow-thick")
    progress:SetColor(1, 1, 1, 1)
    progress:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    progress:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    progress:SetMouseEnabled(false)

    -- Most of the frame moves the HUD. The lower-right corner is deliberately
    -- left free for the resize grip so moving and resizing can never compete.
    local dragSurface = WINDOW_MANAGER:CreateControl(widgetName .. "DragSurface", widget, CT_CONTROL)
    dragSurface:SetAnchor(TOPLEFT, widget, TOPLEFT, 0, 0)
    dragSurface:SetAnchor(BOTTOMRIGHT, widget, BOTTOMRIGHT, -20, -20)
    dragSurface:SetMouseEnabled(false)
    if dragSurface.SetDrawLayer then dragSurface:SetDrawLayer(DL_OVERLAY) end
    if dragSurface.SetDrawLevel then dragSurface:SetDrawLevel(15000) end

    local resizeGrip = WINDOW_MANAGER:CreateControl(widgetName .. "ResizeGrip", widget, CT_BACKDROP)
    resizeGrip:SetDimensions(18, 18)
    resizeGrip:SetAnchor(BOTTOMRIGHT, widget, BOTTOMRIGHT, -2, -2)
    resizeGrip:SetCenterColor(0.78, 0.59, 0.16, 0.88)
    resizeGrip:SetEdgeColor(1.00, 0.86, 0.30, 1)
    resizeGrip:SetEdgeTexture(nil, 1, 1, 1)
    resizeGrip:SetMouseEnabled(false)
    resizeGrip:SetHidden(true)
    if resizeGrip.SetDrawLayer then resizeGrip:SetDrawLayer(DL_OVERLAY) end
    if resizeGrip.SetDrawLevel then resizeGrip:SetDrawLevel(16000) end

    -- Three tiny dark marks make the corner read as a resize grip without
    -- relying on a Unicode arrow that may be missing in one of ESO's fonts.
    for i = 1, 3 do
        local mark = WINDOW_MANAGER:CreateControl(nil, resizeGrip, CT_BACKDROP)
        local size = 3 + (i - 1) * 3
        mark:SetDimensions(size, 2)
        mark:SetAnchor(BOTTOMRIGHT, resizeGrip, BOTTOMRIGHT, -2, -(2 + (i - 1) * 4))
        mark:SetCenterColor(0.08, 0.07, 0.04, 0.95)
        mark:SetEdgeColor(0, 0, 0, 0)
        mark:SetMouseEnabled(false)
    end

    self.skyshardGoalWidget = widget
    self.skyshardGoalZoneLabel = title
    self.skyshardGoalProgressLabel = progress
    self.skyshardGoalEditBackdrop = editBackdrop
    self.skyshardGoalDragSurface = dragSurface
    self.skyshardGoalResizeGrip = resizeGrip
    self.skyshardGoalTomesAnchor = nil
    self.skyshardGoalLastAnchorScan = 0

    local function StopMove()
        dragSurface:SetHandler("OnUpdate", nil)
        self.skyshardGoalDragging = false
    end

    local function StopResize()
        resizeGrip:SetHandler("OnUpdate", nil)
        self.skyshardGoalResizing = false
    end

    dragSurface:SetHandler("OnMouseDown", function(_, button)
        if TPM.skyshardGoalEditMode ~= true or button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        StopResize()
        if type(GetUIMousePosition) ~= "function" then return end
        local mouseX, mouseY = GetUIMousePosition()
        local left = type(widget.GetLeft) == "function" and tonumber(widget:GetLeft()) or nil
        local top = type(widget.GetTop) == "function" and tonumber(widget:GetTop()) or nil
        mouseX, mouseY = tonumber(mouseX), tonumber(mouseY)
        if not mouseX or not mouseY or not left or not top then return end

        TPM.skyshardGoalDragging = true
        TPM.skyshardGoalDragStartMouseX = mouseX
        TPM.skyshardGoalDragStartMouseY = mouseY
        TPM.skyshardGoalDragStartX = left
        TPM.skyshardGoalDragStartY = top

        dragSurface:SetHandler("OnUpdate", function()
            if TPM.skyshardGoalDragging ~= true or TPM.skyshardGoalEditMode ~= true then
                dragSurface:SetHandler("OnUpdate", nil)
                return
            end
            if type(GetUIMousePosition) ~= "function" then return end
            local currentX, currentY = GetUIMousePosition()
            currentX, currentY = tonumber(currentX), tonumber(currentY)
            if not currentX or not currentY then return end

            local x = (tonumber(TPM.skyshardGoalDragStartX) or 0) + currentX - (tonumber(TPM.skyshardGoalDragStartMouseX) or currentX)
            local y = (tonumber(TPM.skyshardGoalDragStartY) or 0) + currentY - (tonumber(TPM.skyshardGoalDragStartMouseY) or currentY)
            local rootW = type(GuiRoot.GetWidth) == "function" and (tonumber(GuiRoot:GetWidth()) or 0) or 0
            local rootH = type(GuiRoot.GetHeight) == "function" and (tonumber(GuiRoot:GetHeight()) or 0) or 0
            local widgetW = tonumber(widget:GetWidth()) or 360
            local widgetH = tonumber(widget:GetHeight()) or 60
            if rootW > 0 then x = Clamp(x, 0, math.max(0, rootW - widgetW)) end
            if rootH > 0 then y = Clamp(y, 0, math.max(0, rootH - widgetH)) end
            widget:ClearAnchors()
            widget:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
            TPM.skyshardGoalAnchorMode = "custom_edit_live"
        end)
    end)

    dragSurface:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then StopMove() end
    end)

    resizeGrip:SetHandler("OnMouseDown", function(_, button)
        if TPM.skyshardGoalEditMode ~= true or button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        StopMove()
        if type(GetUIMousePosition) ~= "function" then return end
        local mouseX, mouseY = GetUIMousePosition()
        mouseX, mouseY = tonumber(mouseX), tonumber(mouseY)
        if not mouseX or not mouseY then return end
        TPM.skyshardGoalResizing = true
        TPM.skyshardGoalResizeStartMouseX = mouseX
        TPM.skyshardGoalResizeStartMouseY = mouseY
        TPM.skyshardGoalResizeStartWidth = tonumber(widget:GetWidth()) or 360
        TPM.skyshardGoalResizeStartHeight = tonumber(widget:GetHeight()) or 60

        resizeGrip:SetHandler("OnUpdate", function()
            if TPM.skyshardGoalResizing ~= true or TPM.skyshardGoalEditMode ~= true then
                resizeGrip:SetHandler("OnUpdate", nil)
                return
            end
            local currentX, currentY = GetUIMousePosition()
            currentX, currentY = tonumber(currentX), tonumber(currentY)
            if not currentX or not currentY then return end
            local width = (tonumber(TPM.skyshardGoalResizeStartWidth) or 360) + currentX - (tonumber(TPM.skyshardGoalResizeStartMouseX) or currentX)
            local height = (tonumber(TPM.skyshardGoalResizeStartHeight) or 60) + currentY - (tonumber(TPM.skyshardGoalResizeStartMouseY) or currentY)
            local left = tonumber(widget:GetLeft()) or 0
            local top = tonumber(widget:GetTop()) or 0
            local rootW = type(GuiRoot.GetWidth) == "function" and (tonumber(GuiRoot:GetWidth()) or 0) or 0
            local rootH = type(GuiRoot.GetHeight) == "function" and (tonumber(GuiRoot:GetHeight()) or 0) or 0
            local maxWidth = rootW > 0 and math.max(230, rootW - left) or 760
            local maxHeight = rootH > 0 and math.max(60, rootH - top) or 220
            width = Clamp(width, 230, math.min(760, maxWidth))
            height = Clamp(height, 60, math.min(220, maxHeight))
            widget:SetDimensions(math.floor(width + 0.5), math.floor(height + 0.5))
        end)
    end)

    resizeGrip:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then StopResize() end
    end)

    self:UpdateSkyshardGoalAnchor(true)
    widget:SetHidden(true)
end

local function TPM_SkyshardStripControlText(text)
    text = tostring(text or "")
    text = string.gsub(text, "|c%x%x%x%x%x%x", "")
    text = string.gsub(text, "|r", "")
    text = zo_strlower(text)
    return text
end

local function TPM_IsUsableHudAnchorControl(control)
    if not control or not GuiRoot or control == GuiRoot then return false end
    if type(control.GetTop) ~= "function" or type(control.GetRight) ~= "function" then return false end

    local okTop, top = pcall(control.GetTop, control)
    local okRight, right = pcall(control.GetRight, control)
    top, right = okTop and tonumber(top) or nil, okRight and tonumber(right) or nil
    if not top or not right then return false end

    local rootWidth = type(GuiRoot.GetWidth) == "function" and tonumber(GuiRoot:GetWidth()) or 0
    local rootHeight = type(GuiRoot.GetHeight) == "function" and tonumber(GuiRoot:GetHeight()) or 0
    if right <= 0 or top < 0 then return false end
    if rootWidth > 0 and right > rootWidth + 5 then return false end
    if rootHeight > 0 and top > rootHeight + 5 then return false end

    -- 2.6.15: A control can report itself as visible while one of its scene
    -- parents is hidden. Walk the parent chain so an inactive duplicate tracker
    -- can never be selected as the anchor for the Skyshard HUD.
    local current = control
    for _ = 1, 12 do
        if type(current.IsHidden) == "function" then
            local okHidden, hidden = pcall(current.IsHidden, current)
            if okHidden and hidden == true then return false end
        end
        if type(current.GetParent) ~= "function" then break end
        local okParent, parent = pcall(current.GetParent, current)
        if not okParent or not parent or parent == current then break end
        if parent == GuiRoot then break end
        current = parent
    end
    return true
end

local function TPM_IsTamrielTomesHudText(text)
    text = TPM_SkyshardStripControlText(text)
    if text == "" then return false end
    return string.find(text, "tamrielfoliant", 1, true) ~= nil
        or string.find(text, "tamriel tome", 1, true) ~= nil
        or string.find(text, "tamriel-tome", 1, true) ~= nil
        or string.find(text, "tomes de tamriel", 1, true) ~= nil
        or string.find(text, "tome de tamriel", 1, true) ~= nil
        or (string.find(text, "том", 1, true) ~= nil and string.find(text, "тамри", 1, true) ~= nil)
end

local function TPM_GetControlText(control)
    local controlType = type(control)
    if (controlType ~= "table" and controlType ~= "userdata") or type(control.GetText) ~= "function" then return "" end
    local ok, value = pcall(control.GetText, control)
    return ok and tostring(value or "") or ""
end

local function TPM_GetNativeHudTrackerContainer(value)
    local valueType = type(value)
    if valueType ~= "table" and valueType ~= "userdata" then return nil end

    -- Native ZO_HUDTracker_Base objects expose owner.container/headerLabel.
    -- Resolve either an owner object or a control whose owner points at one.
    local objects = { value }
    local okOwner, owner = pcall(function() return value.owner end)
    if okOwner and owner and owner ~= value then objects[#objects + 1] = owner end

    for _, object in ipairs(objects) do
        local okContainer, container = pcall(function() return object.container end)
        local okHeader, header = pcall(function() return object.headerLabel end)
        container = okContainer and container or nil
        header = okHeader and header or nil
        if header and TPM_IsTamrielTomesHudText(TPM_GetControlText(header)) then
            -- 2.6.17: Return the actual visible title label first. The native
            -- tracker container can span the complete right-hand tracker column
            -- (quests + timed activities + Tamriel Tomes). Anchoring Position 1
            -- to that container placed the Skyshard goal far above the Tomes.
            if TPM_IsUsableHudAnchorControl(header) then return header end
            if TPM_IsUsableHudAnchorControl(container) then return container end
        end
    end

    if TPM_IsTamrielTomesHudText(TPM_GetControlText(value)) then
        -- If the scanned control itself is the visible Tamriel Tomes label,
        -- keep that exact control as the anchor instead of climbing to a large
        -- shared tracker container.
        if TPM_IsUsableHudAnchorControl(value) then return value end
        if okOwner and owner then
            local okContainer, container = pcall(function() return owner.container end)
            if okContainer and TPM_IsUsableHudAnchorControl(container) then return container end
        end
    end
    return nil
end

function TPM:FindTamrielTomesHudAnchor(force)
    if not GuiRoot then return nil end

    if not force and TPM_IsUsableHudAnchorControl(self.skyshardGoalTomesAnchor) then
        return self.skyshardGoalTomesAnchor
    end

    local nowMs = type(GetFrameTimeMilliseconds) == "function" and (tonumber(GetFrameTimeMilliseconds()) or 0) or 0
    if not force and nowMs > 0 and (nowMs - (tonumber(self.skyshardGoalLastAnchorScan) or 0)) < 5000 then
        return nil
    end
    self.skyshardGoalLastAnchorScan = nowMs

    -- Prefer ESO's native HUD tracker registry. This is more reliable than
    -- searching arbitrary globals and lets us anchor to the complete native
    -- Tamriel Tomes tracker container when it is registered there.
    if HUD_TRACKER_MANAGER and type(HUD_TRACKER_MANAGER.GetTrackers) == "function" then
        local okTrackers, trackers = pcall(HUD_TRACKER_MANAGER.GetTrackers, HUD_TRACKER_MANAGER)
        if okTrackers and type(trackers) == "table" then
            for tracker in pairs(trackers) do
                local anchor = TPM_GetNativeHudTrackerContainer(tracker)
                if TPM_IsUsableHudAnchorControl(anchor) then
                    self.skyshardGoalTomesAnchor = anchor
                    return anchor
                end
            end
        end
    end

    -- SECURITY NOTE (2.6.16): never enumerate _G here. ESO exposes private API
    -- functions in the global table (for example GetMarketProductInfo). Merely
    -- iterating over _G from addon code can cross the secure/private boundary and
    -- trigger a UI error before our filtering code even runs. The native tracker
    -- registry above plus the visible control-tree scan below are safe discovery
    -- paths and are sufficient for locating the Tamriel Tomes HUD block.

    -- Fallback: scan the visible UI tree. Keep the deeper 2.6.15 search, but do
    -- than the old version and also checks each control's native tracker owner.
    local queue = { { control = GuiRoot, depth = 0 } }
    local index, visited = 1, 0
    while index <= #queue and visited < 12000 do
        local item = queue[index]
        index = index + 1
        local control, depth = item.control, item.depth
        visited = visited + 1

        if control ~= GuiRoot then
            local ownerAnchor = TPM_GetNativeHudTrackerContainer(control)
            if TPM_IsUsableHudAnchorControl(ownerAnchor) then
                self.skyshardGoalTomesAnchor = ownerAnchor
                return ownerAnchor
            end

            if TPM_IsUsableHudAnchorControl(control) then
                local name = ""
                if type(control.GetName) == "function" then
                    local ok, value = pcall(control.GetName, control)
                    if ok then name = zo_strlower(tostring(value or "")) end
                end
                local textLooksLikeTomes = TPM_IsTamrielTomesHudText(TPM_GetControlText(control))
                local nameLooksLikeTomes = string.find(name, "tamrieltome", 1, true) ~= nil
                    or string.find(name, "tamriel_tome", 1, true) ~= nil
                if textLooksLikeTomes or (nameLooksLikeTomes and type(control.GetText) == "function") then
                    self.skyshardGoalTomesAnchor = control
                    return control
                end
            end
        end

        if depth < 14 and control and type(control.GetNumChildren) == "function" and type(control.GetChild) == "function" then
            local okCount, count = pcall(control.GetNumChildren, control)
            count = okCount and math.min(tonumber(count) or 0, 900) or 0
            for childIndex = 1, count do
                local okChild, child = pcall(control.GetChild, control, childIndex)
                if okChild and child then queue[#queue + 1] = { control = child, depth = depth + 1 } end
            end
        end
    end

    self.skyshardGoalTomesAnchor = nil
    return nil
end

local function TPM_GetTamrielTomesBlockAnchor(titleControl)
    if not TPM_IsUsableHudAnchorControl(titleControl) then return titleControl end

    -- If this is already a native HUD tracker container, do not climb into the
    -- shared tracker column. That is what caused Position 1 to land far above
    -- or around the middle of the screen in earlier builds.
    local okOwner, owner = pcall(function() return titleControl.owner end)
    if okOwner and owner then
        local okContainer, container = pcall(function() return owner.container end)
        if okContainer and container == titleControl then return titleControl end
    end

    local current = titleControl
    -- Pick the FIRST compact parent large enough to contain title + objective,
    -- instead of the highest matching parent in the whole HUD hierarchy.
    for _ = 1, 8 do
        if type(current.GetParent) ~= "function" then break end
        local ok, parent = pcall(current.GetParent, current)
        if not ok or not parent or parent == GuiRoot then break end
        if TPM_IsUsableHudAnchorControl(parent) then
            local width = type(parent.GetWidth) == "function" and tonumber(parent:GetWidth()) or 0
            local height = type(parent.GetHeight) == "function" and tonumber(parent:GetHeight()) or 0
            if width >= 150 and width <= 700 and height >= 45 and height <= 220 then
                return parent
            end
        end
        current = parent
    end
    return titleControl
end

local function TPM_GetRenderedLabelBounds(control)
    if not TPM_IsUsableHudAnchorControl(control) then return nil, nil end
    local okLeft, left = pcall(control.GetLeft, control)
    local okWidth, width = pcall(control.GetWidth, control)
    left = okLeft and tonumber(left) or nil
    width = okWidth and tonumber(width) or nil
    if not left then return nil, nil end

    local textWidth = nil
    if type(control.GetTextWidth) == "function" then
        local okTextWidth, value = pcall(control.GetTextWidth, control)
        textWidth = okTextWidth and tonumber(value) or nil
    end
    if not textWidth or textWidth <= 0 or not width or width <= 0 then
        local right = type(control.GetRight) == "function" and tonumber(control:GetRight()) or nil
        return left, right or (left + math.max(0, width or 0))
    end

    local alignment = nil
    if type(control.GetHorizontalAlignment) == "function" then
        local okAlignment, value = pcall(control.GetHorizontalAlignment, control)
        if okAlignment then alignment = value end
    end

    local renderedLeft = left
    if alignment == TEXT_ALIGN_RIGHT then
        renderedLeft = left + math.max(0, width - textWidth)
    elseif alignment == TEXT_ALIGN_CENTER then
        renderedLeft = left + math.max(0, (width - textWidth) * 0.5)
    end
    return renderedLeft, renderedLeft + textWidth
end

local function TPM_GetRenderedLabelLeft(control)
    local left = TPM_GetRenderedLabelBounds(control)
    return left
end

local function TPM_GetRenderedLabelRight(control)
    local _, right = TPM_GetRenderedLabelBounds(control)
    return right
end

function TPM:UpdateSkyshardGoalAnchor(forceScan)
    local widget = self.skyshardGoalWidget
    if not widget or not GuiRoot then return end

    local customLayout = self.saved and self.saved.skyshardGoalCustomPosition == true
    local width = customLayout and tonumber(self.saved.skyshardGoalCustomWidth) or 360
    local height = customLayout and tonumber(self.saved.skyshardGoalCustomHeight) or 60
    widget:SetDimensions(Clamp(width or 360, 230, 760), Clamp(height or 60, 60, 220))
    widget:ClearAnchors()

    -- A manually dragged position takes precedence over the automatic Tamriel
    -- Tomes slots. Selecting position 1/2 in settings resets this override.
    if self.saved and self.saved.skyshardGoalCustomPosition == true then
        local customX = tonumber(self.saved.skyshardGoalCustomX)
        local customY = tonumber(self.saved.skyshardGoalCustomY)
        if customX and customY then
            if self.skyshardGoalZoneLabel then self.skyshardGoalZoneLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT) end
            if self.skyshardGoalProgressLabel then self.skyshardGoalProgressLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT) end
            widget:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, customX, customY)
            self.skyshardGoalAnchorMode = "custom_saved"
            return
        end
    end

    local position = self.saved and tonumber(self.saved.skyshardGoalPosition) or 1
    position = position == 2 and 2 or 1

    local tomeTitle = self:FindTamrielTomesHudAnchor(forceScan == true)
    if TPM_IsUsableHudAnchorControl(tomeTitle) then
        -- 2.6.20: The screenshots exposed the exact geometry bug. The native
        -- Tamriel Tomes title label is a wide right/centre-aligned control. Its
        -- calculated rendered LEFT edge can therefore sit ~100 px left of the
        -- actual tracker column. Align our 360 px goal by the rendered RIGHT
        -- edge instead, and right-align both goal labels. This makes the visible
        -- text share the same right edge as Tamriel Tomes regardless of the
        -- hidden label-control width.
        local visualRight = tonumber(TPM_GetRenderedLabelRight(tomeTitle))
        local okTop, tomeTop = pcall(tomeTitle.GetTop, tomeTitle)
        tomeTop = okTop and tonumber(tomeTop) or nil
        if self.skyshardGoalZoneLabel then self.skyshardGoalZoneLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT) end
        if self.skyshardGoalProgressLabel then self.skyshardGoalProgressLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT) end
        if position == 2 then
            local tomeBlock = TPM_GetTamrielTomesBlockAnchor(tomeTitle)
            local okBottom, blockBottom = pcall(tomeBlock.GetBottom, tomeBlock)
            blockBottom = okBottom and tonumber(blockBottom) or nil
            if visualRight and blockBottom then
                widget:SetAnchor(TOPRIGHT, GuiRoot, TOPLEFT, visualRight, blockBottom + 8)
            else
                widget:SetAnchor(TOPRIGHT, tomeBlock, BOTTOMRIGHT, 0, 8)
            end
        else
            if visualRight and tomeTop then
                widget:SetAnchor(BOTTOMRIGHT, GuiRoot, TOPLEFT, visualRight, tomeTop - 4)
            else
                widget:SetAnchor(BOTTOMRIGHT, tomeTitle, TOPRIGHT, 0, -4)
            end
        end
        self.skyshardGoalAnchorMode = "tamriel_tomes_visual_right_pos" .. tostring(position)
        return
    end

    -- Last-resort slots. Position 1 now sits much closer to the usual Tamriel
    -- Tomes location instead of the old overly-high fallback.
    if self.skyshardGoalZoneLabel then self.skyshardGoalZoneLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT) end
    if self.skyshardGoalProgressLabel then self.skyshardGoalProgressLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT) end
    if position == 2 then
        widget:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -42, -90)
    else
        widget:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -42, -155)
    end
    self.skyshardGoalAnchorMode = "screen_fallback_pos" .. tostring(position)
end

function TPM:GetActiveProgressGoalCategoryType()
    if not self.saved then return nil end
    local value = self.saved.progressGoalCategoryType
    if value == nil or value == false or value == "" then
        return self.saved.skyshardGoalEnabled == true and _G.ZONE_COMPLETION_TYPE_SKYSHARDS or nil
    end
    local numeric = tonumber(value)
    if numeric ~= nil then return numeric end
    return value
end

function TPM:IsProgressGoalCategoryActive(completionType)
    if not self.saved or self.saved.skyshardGoalEnabled ~= true or completionType == nil then return false end
    return tostring(self:GetActiveProgressGoalCategoryType()) == tostring(completionType)
end

function TPM:GetProgressGoalCategoryDisplayName(completionType)
    if completionType == SIDE_QUEST_CATEGORY_KEY then return self:L("CAT_SIDE_QUESTS") end
    if completionType == CROWN_QUEST_CATEGORY_KEY then return self:L("CAT_CROWN_QUESTS") end
    if completionType == ZONE_STABLE_MOUNT_CATEGORY_KEY then return self:L("STAT_ZONE_STABLE_MOUNT") end
    return self:GetCompletionTypeName(completionType)
end

function TPM:GetProgressGoalCategoryIconTexture(completionType)
    -- 2.6.29: Use ESO's own Zone Stories completion icons in the HUD instead
    -- of TPM's custom category artwork. This is the same native icon resolver
    -- used by the game's Zone Guide / Zone Stories activity-completion tiles.
    local manager = _G.ZO_ZoneStories_Manager
    if type(completionType) == "number" and type(manager) == "table" and type(manager.GetCompletionTypeIcon) == "function" then
        local ok, texture = pcall(manager.GetCompletionTypeIcon, completionType)
        if ok and type(texture) == "string" and texture ~= "" then
            return texture
        end
    end

    -- Safe direct native fallbacks in case the manager has not initialized yet.
    local nativeIcons =
    {
        [ZONE_COMPLETION_TYPE_PRIORITY_QUESTS] = "EsoUI/Art/ZoneStories/completionTypeIcon_priorityQuest.dds",
        [ZONE_COMPLETION_TYPE_POINTS_OF_INTEREST] = "EsoUI/Art/ZoneStories/completionTypeIcon_pointOfInterest.dds",
        [ZONE_COMPLETION_TYPE_WAYSHRINES] = "EsoUI/Art/ZoneStories/completionTypeIcon_wayshrine.dds",
        [ZONE_COMPLETION_TYPE_DELVES] = "EsoUI/Art/ZoneStories/completionTypeIcon_delve.dds",
        [ZONE_COMPLETION_TYPE_GROUP_DELVES] = "EsoUI/Art/ZoneStories/completionTypeIcon_groupDelve.dds",
        [ZONE_COMPLETION_TYPE_SKYSHARDS] = "EsoUI/Art/ZoneStories/completionTypeIcon_skyshard.dds",
        [ZONE_COMPLETION_TYPE_WORLD_EVENTS] = "EsoUI/Art/ZoneStories/completionTypeIcon_worldEvents.dds",
        [ZONE_COMPLETION_TYPE_GROUP_BOSSES] = "EsoUI/Art/ZoneStories/completionTypeIcon_groupBoss.dds",
        [ZONE_COMPLETION_TYPE_STRIKING_LOCALES] = "EsoUI/Art/ZoneStories/completionTypeIcon_strikingLocales.dds",
        [ZONE_COMPLETION_TYPE_MAGES_GUILD_BOOKS] = "EsoUI/Art/ZoneStories/completionTypeIcon_lorebooks.dds",
        [ZONE_COMPLETION_TYPE_MUNDUS_STONES] = "EsoUI/Art/ZoneStories/completionTypeIcon_mundusStone.dds",
        [ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS] = "EsoUI/Art/ZoneStories/completionTypeIcon_publicDungeon.dds",
        [ZONE_COMPLETION_TYPE_SET_STATIONS] = "EsoUI/Art/ZoneStories/completionTypeIcon_setStation.dds",
    }
    return nativeIcons[completionType] or STATISTICS_CATEGORY_ICON_TEXTURES[completionType] or "TamrielProgressMap/art/cat_quests.dds"
end

function TPM:GetProgressGoalHudTitle(completionType)
    local name = self:GetProgressGoalCategoryDisplayName(completionType)
    local texture = self:GetProgressGoalCategoryIconTexture(completionType)
    -- ESO labels support inline textures. Keeping the icon inside the title
    -- makes it follow both the automatic right alignment near Tamriel Tomes and
    -- the user's custom left-aligned HUD position without separate anchor math.
    return string.format("|t22:22:%s|t  %s", texture, name)
end

function TPM:ToggleSkyshardGoalWidget(completionType)
    if not self.saved then return end
    local targetType = completionType or self:GetActiveProgressGoalCategoryType() or _G.ZONE_COMPLETION_TYPE_SKYSHARDS
    local sameActive = self.saved.skyshardGoalEnabled == true and tostring(self:GetActiveProgressGoalCategoryType()) == tostring(targetType)
    if sameActive then
        self.saved.skyshardGoalEnabled = false
    else
        self.saved.progressGoalCategoryType = targetType
        self.saved.skyshardGoalEnabled = true
    end
    if self.saved.skyshardGoalEnabled ~= true and self.skyshardGoalEditMode == true then
        self:SetSkyshardGoalEditMode(false, false)
    end
    self:RefreshSkyshardGoalWidget()
    if self.statisticsWindow and not self.statisticsWindow:IsHidden() then
        self:RefreshStatisticsWindow()
    end
end

local function TPM_TryZoneStoriesSkyshardProgress(zoneId)
    zoneId = tonumber(zoneId) or 0
    if zoneId <= 0 or not _G.ZONE_STORIES_MANAGER then return nil end

    local manager = _G.ZONE_STORIES_MANAGER
    local completionType = _G.ZONE_COMPLETION_TYPE_SKYSHARDS
    if completionType == nil then return nil end

    local function Accept(a, b)
        a, b = tonumber(a), tonumber(b)
        if a ~= nil and b ~= nil and b > 0 then
            return math.max(0, a), math.max(0, b)
        end
        return nil
    end

    -- ESO's own zone-story scoreboard uses these manager functions. Depending
    -- on client revision they can be exposed in dot-style or method-style, so
    -- safely support both call forms.
    local fn = manager.GetActivityCompletionProgressValues
    if type(fn) == "function" then
        local ok, a, b = pcall(fn, zoneId, completionType)
        if ok then
            local completed, total = Accept(a, b)
            if completed then return completed, total end
        end
        ok, a, b = pcall(fn, manager, zoneId, completionType)
        if ok then
            local completed, total = Accept(a, b)
            if completed then return completed, total end
        end
    end

    fn = manager.GetActivityCompletionProgressValuesAndText
    if type(fn) == "function" then
        local ok, a, b = pcall(fn, zoneId, completionType)
        if ok then
            local completed, total = Accept(a, b)
            if completed then return completed, total end
        end
        ok, a, b = pcall(fn, manager, zoneId, completionType)
        if ok then
            local completed, total = Accept(a, b)
            if completed then return completed, total end
        end
    end

    return nil
end

function TPM:GetCurrentSkyshardGoalData()
    local activeType = self:GetActiveProgressGoalCategoryType() or _G.ZONE_COMPLETION_TYPE_SKYSHARDS

    if activeType == CROWN_QUEST_CATEGORY_KEY then
        local crownStats = self:GetCrownQuestStatistics()
        if crownStats then
            return {
                zoneId = 0,
                name = self:L("TAMRIEL_TOTAL"),
                completed = crownStats.completed or 0,
                total = crownStats.total or 0,
                countText = crownStats.countText,
                informational = crownStats.informational,
                completionType = activeType,
                categoryName = crownStats.name or self:GetProgressGoalCategoryDisplayName(activeType),
            }
        end
    end

    local sourceZoneIds, seenSources = {}, {}
    local function AddSource(zoneId)
        zoneId = tonumber(zoneId) or 0
        if zoneId <= 0 or seenSources[zoneId] then return end
        seenSources[zoneId] = true
        sourceZoneIds[#sourceZoneIds + 1] = zoneId
    end

    if type(_G.ZO_ExplorationUtils_GetPlayerCurrentZoneId) == "function" then
        local ok, zoneId = pcall(_G.ZO_ExplorationUtils_GetPlayerCurrentZoneId)
        if ok then AddSource(zoneId) end
    end
    if type(GetUnitWorldPosition) == "function" then
        local ok, zoneId = pcall(GetUnitWorldPosition, "player")
        if ok then AddSource(zoneId) end
    end
    if type(GetUnitRawWorldPosition) == "function" then
        local ok, zoneId = pcall(GetUnitRawWorldPosition, "player")
        if ok then AddSource(zoneId) end
    end

    local currentZoneId = self:GetCurrentPlayerZoneIdentity()
    AddSource(currentZoneId)
    if #sourceZoneIds == 0 then return nil end

    local candidates, seenCandidates = {}, {}
    local function AddCandidate(zoneId)
        zoneId = tonumber(zoneId) or 0
        if zoneId <= 0 or seenCandidates[zoneId] then return end
        seenCandidates[zoneId] = true
        candidates[#candidates + 1] = zoneId
    end

    local function AddExpanded(zoneId)
        zoneId = tonumber(zoneId) or 0
        if zoneId <= 0 then return end
        local current = zoneId
        for _ = 1, 8 do
            if current <= 0 then break end
            if type(GetZoneStoryZoneIdForZoneId) == "function" then
                local ok, storyZoneId = pcall(GetZoneStoryZoneIdForZoneId, current)
                if ok then AddCandidate(storyZoneId) end
            end
            AddCandidate(current)
            if type(GetParentZoneId) ~= "function" then break end
            local ok, parentZoneId = pcall(GetParentZoneId, current)
            parentZoneId = ok and (tonumber(parentZoneId) or 0) or 0
            if parentZoneId <= 0 or parentZoneId == current then break end
            current = parentZoneId
        end
    end

    for _, zoneId in ipairs(sourceZoneIds) do AddExpanded(zoneId) end

    for _, zoneId in ipairs(candidates) do
        local stats = self:GetStatisticsData(false, zoneId)
        if stats and type(stats.categories) == "table" then
            for _, row in ipairs(stats.categories) do
                if tostring(row.completionType) == tostring(activeType) then
                    return {
                        zoneId = zoneId,
                        name = SafeZoneName(zoneId),
                        completed = row.completed or 0,
                        total = row.total or 0,
                        countText = row.countText,
                        informational = row.informational,
                        completionType = activeType,
                        categoryName = row.name or self:GetProgressGoalCategoryDisplayName(activeType),
                    }
                end
            end
        end
    end

    return nil
end

function TPM:RefreshSkyshardGoalWidget()
    if not self.skyshardGoalWidget then self:CreateSkyshardGoalWidget() end
    local widget = self.skyshardGoalWidget
    if not widget then return end

    -- 2.6.31 hotfix: the progress HUD must never reappear behind the
    -- Statistics journal. The 1.5 second safety refresh used to show it again
    -- after ShowStatisticsWindow() had explicitly hidden it.
    if self.statisticsWindow and not self.statisticsWindow:IsHidden() then
        widget:SetHidden(true)
        return
    end

    local editingPosition = self.skyshardGoalEditMode == true
    if (not self.saved or self.saved.skyshardGoalEnabled ~= true) and not editingPosition then
        widget:SetHidden(true)
        return
    end
    if not editingPosition and not self:IsSkyshardGoalHudSceneVisible() then
        widget:SetHidden(true)
        return
    end

    -- Render FIRST, then resolve progress. This makes the HUD independent from
    -- any Zone Stories/API failure. An enabled goal must always be visible.
    if widget.SetAlpha then widget:SetAlpha(1) end
    local activeType = self:GetActiveProgressGoalCategoryType() or _G.ZONE_COMPLETION_TYPE_SKYSHARDS
    self.skyshardGoalZoneLabel:SetText(self:GetProgressGoalHudTitle(activeType))

    local _, _, fallbackZoneName = self:GetCurrentPlayerZoneIdentity()
    fallbackZoneName = tostring(fallbackZoneName or "")
    if fallbackZoneName == "" then fallbackZoneName = "—" end
    self.skyshardGoalProgressLabel:SetText(fallbackZoneName .. "  —/—")
    if not editingPosition then
        self:UpdateSkyshardGoalAnchor(false)
    end
    widget:SetHidden(false)

    -- Data collection is isolated behind pcall. A bad/new API signature can no
    -- longer abort the refresh after the control was made visible.
    local okData, dataOrError = pcall(function()
        return self:GetCurrentSkyshardGoalData()
    end)
    self.skyshardGoalLastDataError = okData and nil or tostring(dataOrError or "unknown")

    local data = okData and dataOrError or nil
    if type(data) == "table" then
        local zoneName = tostring(data.name or fallbackZoneName or "—")
        if data.informational and data.countText and data.countText ~= "" then
            self.skyshardGoalProgressLabel:SetText(string.format("%s  %s", zoneName, tostring(data.countText)))
            self.skyshardGoalLastData = data
        elseif (tonumber(data.total) or 0) > 0 then
            self.skyshardGoalProgressLabel:SetText(self:L("SKYSHARD_GOAL_PROGRESS", zoneName, tonumber(data.completed) or 0, tonumber(data.total) or 0))
            self.skyshardGoalLastData = data
        else
            self.skyshardGoalLastData = nil
        end
    else
        self.skyshardGoalLastData = nil
    end

    -- A few UI systems can modify anchors during scene transitions. Re-assert
    -- the top-level window only if the HUD is still the current scene; otherwise
    -- a same-frame ESC/M transition must win over this refresh.
    if not editingPosition and not self:IsSkyshardGoalHudSceneVisible() then
        widget:SetHidden(true)
        return
    end
    if widget.SetAlpha then widget:SetAlpha(1) end
    widget:SetHidden(false)
end

function TPM:SetSkyshardGoalEditMode(enabled, commitChanges)
    enabled = enabled == true
    if enabled and self.saved and not self:GetActiveProgressGoalCategoryType() then
        self.saved.progressGoalCategoryType = _G.ZONE_COMPLETION_TYPE_SKYSHARDS
        self.saved.skyshardGoalEnabled = true
    end
    local wasEditing = self.skyshardGoalEditMode == true
    if not self.skyshardGoalWidget then self:CreateSkyshardGoalWidget() end
    local widget = self.skyshardGoalWidget
    if not widget then return end

    -- Clicking the gear a second time is the explicit SAVE action. Movement
    -- and resizing stay live but unsaved until this point.
    if wasEditing and not enabled and commitChanges ~= false and self.saved then
        local left = type(widget.GetLeft) == "function" and tonumber(widget:GetLeft()) or nil
        local top = type(widget.GetTop) == "function" and tonumber(widget:GetTop()) or nil
        local width = type(widget.GetWidth) == "function" and tonumber(widget:GetWidth()) or nil
        local height = type(widget.GetHeight) == "function" and tonumber(widget:GetHeight()) or nil
        if left and top and width and height then
            self.saved.skyshardGoalCustomPosition = true
            self.saved.skyshardGoalCustomX = math.floor(left + 0.5)
            self.saved.skyshardGoalCustomY = math.floor(top + 0.5)
            self.saved.skyshardGoalCustomWidth = math.floor(Clamp(width, 230, 760) + 0.5)
            self.saved.skyshardGoalCustomHeight = math.floor(Clamp(height, 60, 220) + 0.5)
            self.skyshardGoalAnchorMode = "custom_saved"
        end
    end

    self.skyshardGoalEditMode = enabled
    self.skyshardGoalDragging = false
    self.skyshardGoalResizing = false
    if self.skyshardGoalDragSurface then self.skyshardGoalDragSurface:SetHandler("OnUpdate", nil) end
    if self.skyshardGoalResizeGrip then self.skyshardGoalResizeGrip:SetHandler("OnUpdate", nil) end

    if enabled and not wasEditing then
        -- Start from the current automatic/saved location, then convert to an
        -- absolute TOPLEFT anchor so ESO's native tracker can no longer move it
        -- underneath the editor while the user is working.
        self:UpdateSkyshardGoalAnchor(true)
        local left = type(widget.GetLeft) == "function" and tonumber(widget:GetLeft()) or 0
        local top = type(widget.GetTop) == "function" and tonumber(widget:GetTop()) or 0
        widget:ClearAnchors()
        widget:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
        if self.skyshardGoalZoneLabel then self.skyshardGoalZoneLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT) end
        if self.skyshardGoalProgressLabel then self.skyshardGoalProgressLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT) end
        self.skyshardGoalAnchorMode = "custom_edit"
    end

    if self.skyshardGoalEditBackdrop then self.skyshardGoalEditBackdrop:SetHidden(not enabled) end
    if self.skyshardGoalResizeGrip then
        self.skyshardGoalResizeGrip:SetHidden(not enabled)
        self.skyshardGoalResizeGrip:SetMouseEnabled(enabled)
    end
    widget:SetMouseEnabled(enabled)
    if widget.SetMovable then widget:SetMovable(false) end
    if self.skyshardGoalDragSurface then self.skyshardGoalDragSurface:SetMouseEnabled(enabled) end
    if widget.SetDrawLevel then widget:SetDrawLevel(enabled and 14000 or 200) end

    if enabled then
        self:RefreshSkyshardGoalWidget()
        widget:SetHidden(false)
        if widget.BringWindowToTop then widget:BringWindowToTop() end
    else
        self:RefreshSkyshardGoalWidget()
    end

    if self.statisticsWindow and not self.statisticsWindow:IsHidden() then
        self:RefreshStatisticsWindow()
    end
end

function TPM:ToggleSkyshardGoalEditMode()
    self:SetSkyshardGoalEditMode(not (self.skyshardGoalEditMode == true))
end

function TPM:ResetSkyshardGoalCustomPosition()
    if not self.saved then return end
    self:SetSkyshardGoalEditMode(false, false)
    self.saved.skyshardGoalCustomPosition = false
    self.saved.skyshardGoalCustomX = false
    self.saved.skyshardGoalCustomY = false
    self.saved.skyshardGoalCustomWidth = false
    self.saved.skyshardGoalCustomHeight = false
    if self.skyshardGoalWidget then self.skyshardGoalWidget:SetDimensions(360, 60) end
    self:UpdateSkyshardGoalAnchor(true)
    self:RefreshSkyshardGoalWidget()
end

function TPM:PrintSkyshardGoalDebug()
    local widget = self.skyshardGoalWidget
    local enabled = self.saved and self.saved.skyshardGoalEnabled == true
    if not widget then
        d(string.format("TPM skydebug: enabled=%s widget=nil", tostring(enabled)))
        return
    end

    local function SafeControlNumber(methodName)
        local fn = widget[methodName]
        if type(fn) ~= "function" then return nil end
        local ok, value = pcall(fn, widget)
        return ok and tonumber(value) or nil
    end

    local hidden = nil
    if type(widget.IsHidden) == "function" then
        local ok, value = pcall(widget.IsHidden, widget)
        if ok then hidden = value end
    end
    local alpha = SafeControlNumber("GetAlpha")
    local left, top = SafeControlNumber("GetLeft"), SafeControlNumber("GetTop")
    local right, bottom = SafeControlNumber("GetRight"), SafeControlNumber("GetBottom")
    local rootW = GuiRoot and type(GuiRoot.GetWidth) == "function" and tonumber(GuiRoot:GetWidth()) or 0
    local rootH = GuiRoot and type(GuiRoot.GetHeight) == "function" and tonumber(GuiRoot:GetHeight()) or 0

    local _, _, zoneName = self:GetCurrentPlayerZoneIdentity()
    local data = self.skyshardGoalLastData
    d(string.format("TPM skydebug: enabled=%s hidden=%s alpha=%s anchor=%s pos=%.0f,%.0f-%.0f,%.0f root=%.0fx%.0f zone=%s progress=%s error=%s",
        tostring(enabled), tostring(hidden), tostring(alpha), tostring(self.skyshardGoalAnchorMode or "?"),
        tonumber(left) or -1, tonumber(top) or -1, tonumber(right) or -1, tonumber(bottom) or -1,
        tonumber(rootW) or 0, tonumber(rootH) or 0, tostring(zoneName or "?"),
        data and string.format("%s/%s", tostring(data.completed), tostring(data.total)) or "—/—",
        tostring(self.skyshardGoalLastDataError or "none")))
end

function TPM:SetSkyshardGoalPosition(position)
    if not self.saved then return end
    position = tonumber(position) == 2 and 2 or 1
    self.saved.skyshardGoalPosition = position
    self:SetSkyshardGoalEditMode(false, false)
    self.saved.skyshardGoalCustomPosition = false
    self.saved.skyshardGoalCustomX = false
    self.saved.skyshardGoalCustomY = false
    self.saved.skyshardGoalCustomWidth = false
    self.saved.skyshardGoalCustomHeight = false
    if self.skyshardGoalWidget then self.skyshardGoalWidget:SetDimensions(360, 60) end
    self:UpdateSkyshardGoalAnchor(true)
    self:RefreshSkyshardGoalWidget()
end

function TPM:GetAllProgressZoneIds(forceRebuild)
    if not forceRebuild and self.progressZoneIdsCache then
        return self.progressZoneIdsCache
    end

    local progressZoneIds = {}
    local sourceZoneIds = {}

    local function AddSourceZone(zoneId)
        if not zoneId or zoneId <= 0 or sourceZoneIds[zoneId] then return end
        sourceZoneIds[zoneId] = true

        local _, _, availableTotal, _, progressZoneId = self:GetResolvedCompletion(zoneId)
        if availableTotal > 0 and progressZoneId and progressZoneId > 0 and self:IsProgressZoneAvailable(progressZoneId) then
            progressZoneIds[progressZoneId] = true
        end
    end

    if type(GetNextZoneStoryZoneId) == "function" then
        local lastZoneId = nil
        local safety = 0
        while safety < 500 do
            local zoneId = GetNextZoneStoryZoneId(lastZoneId)
            if not zoneId or zoneId == 0 then break end
            AddSourceZone(zoneId)
            lastZoneId = zoneId
            safety = safety + 1
        end
    end

    if type(GetNumMaps) == "function" and type(GetMapInfoByIndex) == "function" then
        for mapIndex = 1, GetNumMaps() do
            local _, mapType, _, zoneIndex = GetMapInfoByIndex(mapIndex)
            if mapType == MAPTYPE_ZONE and zoneIndex and zoneIndex > 0 then
                AddSourceZone(GetZoneId(zoneIndex))
            end
        end
    end

    self.progressZoneIdsCache = progressZoneIds
    return progressZoneIds
end

function TPM:InvalidateStatisticsData(rebuildZoneList)
    -- Keep the global Tamriel cache separate from the optional zone-focus cache.
    -- History, milestones and the Goals page must always continue to use Tamriel.
    self.statisticsCache = nil
    self.statisticsFocusCache = nil
    self.statisticsFocusCacheZoneId = nil
    self.statisticsData = nil
    self.zoneAchievementSummaryCache = nil
    if rebuildZoneList then
        self.progressZoneIdsCache = nil
        self.sideQuestIdsByScope = nil
        self.sideQuestIndexBuilt = false -- legacy cleanup for pre-2.6.14 Saved/UI state
        self.sideQuestIds = nil
        self.crownQuestIndexBuilt = false
        self.crownQuestIds = nil
    end
end

function TPM:GetTamrielProgress()
    if self.statisticsCache then
        return self.statisticsCache.percent or 0,
            self.statisticsCache.completedObjectives or 0,
            self.statisticsCache.totalObjectives or 0,
            self.statisticsCache.totalZones or 0
    end

    local progressZoneIds = self:GetAllProgressZoneIds()
    local completedTotal = 0
    local availableTotal = 0
    local categoryRatioTotal = 0
    local categoryCount = 0
    local zoneCount = 0

    for zoneId in pairs(progressZoneIds) do
        local breakdown, completed, available = self:GetCompletionBreakdown(zoneId)
        if available > 0 then
            zoneCount = zoneCount + 1
            completedTotal = completedTotal + completed
            availableTotal = availableTotal + available
            for _, row in ipairs(breakdown) do
                if row.total > 0 then
                    categoryRatioTotal = categoryRatioTotal + (row.completed / row.total)
                    categoryCount = categoryCount + 1
                end
            end
        end
    end

    local percent = 0
    local mode = self.saved and self.saved.calculationMode or "objectives"
    if mode == "categories" then
        if categoryCount > 0 then
            percent = Round((categoryRatioTotal / categoryCount) * 100)
        end
    elseif availableTotal > 0 then
        percent = Round((completedTotal / availableTotal) * 100)
    end

    if availableTotal > 0 and completedTotal < availableTotal and percent >= 100 then
        percent = 99
    end

    return Clamp(percent, 0, 100), completedTotal, availableTotal, zoneCount
end

function TPM:BuildCategoryPercentText(breakdown)
    if not breakdown or #breakdown == 0 then return "" end

    local parts = {}
    for _, row in ipairs(breakdown) do
        parts[#parts + 1] = string.format("%s %d%%", self:GetCompletionTypeName(row.completionType), row.percent or 0)
    end

    -- Keep the category block readable in ESO's normal (non-fullscreen) map.
    -- Four entries per row prevents the old 1180px-wide text line from
    -- overflowing the default map viewport.
    local lines = {}
    local entriesPerLine = 4
    for index = 1, #parts, entriesPerLine do
        local row = {}
        for partIndex = index, math.min(index + entriesPerLine - 1, #parts) do
            row[#row + 1] = parts[partIndex]
        end
        lines[#lines + 1] = table.concat(row, "  |  ")
    end

    return table.concat(lines, "\n")
end

function TPM:GetMapRect(mapId)
    if type(mapId) ~= "number" or mapId <= 0 then return nil end

    local offsetX, offsetY, width, height = GetUniversallyNormalizedMapInfo(mapId)
    if not offsetX or not offsetY or not width or not height or width <= 0 or height <= 0 then
        return nil
    end

    return offsetX, offsetY, width, height
end

function TPM:UniversalToCurrentMap(universalX, universalY)
    local currentMapId = GetCurrentMapId()
    if not currentMapId or currentMapId <= 0 then return nil end

    local offsetX, offsetY, width, height = self:GetMapRect(currentMapId)
    if not offsetX then return nil end

    local x = (universalX - offsetX) / width
    local y = (universalY - offsetY) / height

    if x < 0 or x > 1 or y < 0 or y > 1 then return nil end
    return x, y
end

function TPM:IsOverviewMap()
    local mapType = GetMapType()
    return mapType == MAPTYPE_WORLD or mapType == MAPTYPE_COSMIC
end

function TPM:ShouldDisplayOverviewZone(zoneId, x, y, isSymbolicPosition)
    local mapType = GetMapType()
    if mapType ~= MAPTYPE_COSMIC then
        return true
    end

    if not x or not y then
        return false
    end

    -- Clockwork City's Aurbis symbol sits just inside the generic outer-ring
    -- radius. When ESO gives us its own symbolic current-map position, trust it
    -- instead of rejecting it with the geometric fallback below.
    if isSymbolicPosition and AURBIS_SYMBOLIC_ZONE_IDS[zoneId] then
        return true
    end

    -- The cosmic overview contains the Tamriel mainland in the center and the
    -- separate surrounding regions in the outer ring. On this map we only want
    -- labels for the outer ring regions, not the inner mainland zone labels.
    local dx = x - 0.5
    local dy = y - 0.52
    local distance = zo_sqrt((dx * dx) + (dy * dy))
    return distance >= 0.34
end


-- 2.6.32 COMMUNITY ALLIANCE TERRITORY OVERLAY
-- This is intentionally a subtle zone-center glow/border rather than a full
-- recolor of ESO's map art. It keeps TPM completion percentages readable and
-- avoids replacing or modifying ZOS map textures.
local TPM_NEUTRAL_BASEGAME_NAMES =
{
    -- English
    ["coldharbour"] = true,
    ["craglorn"] = true,
    ["cyrodiil"] = true,

    -- German
    ["kalthafen"] = true,
    ["kargstein"] = true,
    ["cyrodiil"] = true,

    -- French
    ["havreglace"] = true,
    ["raidelorn"] = true,
    ["cyrodiil"] = true,

    -- Russian
    ["хладная гавань"] = true,
    ["креглорн"] = true,
    ["сиродил"] = true,
}

function TPM:GetAllianceTerritoryGroup(zoneId)
    zoneId = tonumber(zoneId) or 0
    if zoneId <= 0 then return nil end

    -- 2.6.38: Stable and language-independent original alliance territory map.
    -- Do not use localized zone names here: changing TPM language must never
    -- change alliance percentages, zone counts or objective totals.
    local groups = {
        -- Daggerfall Covenant (7)
        [534] = "DC", -- Stros M'Kai
        [535] = "DC", -- Betnikh
        [3]   = "DC", -- Glenumbra
        [19]  = "DC", -- Stormhaven
        [20]  = "DC", -- Rivenspire
        [104] = "DC", -- Alik'r Desert
        [92]  = "DC", -- Bangkorai

        -- Aldmeri Dominion (6)
        [537] = "AD", -- Khenarthi's Roost
        [381] = "AD", -- Auridon
        [383] = "AD", -- Grahtwood
        [108] = "AD", -- Greenshade
        [58]  = "AD", -- Malabal Tor
        [382] = "AD", -- Reaper's March

        -- Ebonheart Pact (7)
        [280] = "EP", -- Bleakrock Isle
        [281] = "EP", -- Bal Foyen
        [41]  = "EP", -- Stonefalls
        [57]  = "EP", -- Deshaan
        [117] = "EP", -- Shadowfen
        [101] = "EP", -- Eastmarch
        [103] = "EP", -- The Rift

        -- Neutral base-game territories supported by the overlay
        [181] = "NEUTRAL", -- Cyrodiil
        [347] = "NEUTRAL", -- Coldharbour
        [888] = "NEUTRAL", -- Craglorn
    }
    return groups[zoneId]
end


-- 2.6.41: Experimental world-map territory borders.
-- ESO does not expose the drawn zone polygons as recolorable controls, so TPM
-- draws an independent border layer inside ZO_WorldMapContainer. Because the
-- controls are children of the map container they follow the map pan/zoom.

-- 2.6.45: Alliance territory visualization moved into the Alliance Statistics page.
-- The normal ESO World Map is deliberately left untouched.
function TPM:HideAllianceTerritoryBorders() end
function TPM:ReleaseAllianceTerritoryBorders() end
function TPM:RefreshAllianceTerritoryBorders() end


function TPM:GetAllianceTerritoryColor(zoneId)
    local group = self:GetAllianceTerritoryGroup(zoneId)
    if group == "DC" then
        return 0.20, 0.48, 1.00, 0.90
    elseif group == "AD" then
        return 1.00, 0.76, 0.12, 0.90
    elseif group == "EP" then
        return 1.00, 0.20, 0.20, 0.90
    elseif group == "NEUTRAL" and self.saved and self.saved.allianceNeutralWhite then
        return 0.96, 0.96, 0.96, 0.78
    end
    return nil
end

function TPM:EnsureAllianceTerritoryBackdrop(label)
    if not label then return nil end
    if label.allianceTerritoryBackdrop then
        return label.allianceTerritoryBackdrop
    end

    local backdrop = WINDOW_MANAGER:CreateControl(
        label:GetName() .. "AllianceTerritoryBackdrop",
        ZO_WorldMapContainer,
        CT_BACKDROP
    )
    backdrop:SetAnchor(CENTER, label, CENTER, 0, 0)
    backdrop:SetMouseEnabled(false)
    backdrop:SetDrawTier(DT_HIGH)
    backdrop:SetDrawLayer(DL_OVERLAY)
    if backdrop.SetDrawLevel then backdrop:SetDrawLevel(1) end
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 3)
    backdrop:SetHidden(true)

    -- Make sure the actual percentage label stays in front of the glow.
    if label.SetDrawLevel then label:SetDrawLevel(10) end

    label.allianceTerritoryBackdrop = backdrop
    return backdrop
end

function TPM:RefreshAllianceTerritoryBackdrop(label, zoneId)
    if not label then return end

    local backdrop = self:EnsureAllianceTerritoryBackdrop(label)
    if not backdrop then return end

    if not self.saved or not self.saved.showAllianceTerritoryColors then
        backdrop:SetHidden(true)
        return
    end

    local r, g, b, a = self:GetAllianceTerritoryColor(zoneId)
    if not r then
        backdrop:SetHidden(true)
        return
    end

    -- Slightly wider than the progress text so it reads as a territory marker,
    -- but remains subtle enough not to hide ESO's world-map art.
    local labelWidth = tonumber(label:GetWidth()) or 84
    local labelHeight = tonumber(label:GetHeight()) or 32
    local width = math.max(154, labelWidth + 34)
    local height = math.max(50, labelHeight + 16)

    backdrop:SetDimensions(width, height)
    backdrop:SetCenterColor(r, g, b, 0.14)
    backdrop:SetEdgeColor(r, g, b, math.min(1, (a or 0.9) + 0.08))
    backdrop:SetHidden(false)
end

function TPM:HideAllianceTerritoryBackdrop(label)
    if label and label.allianceTerritoryBackdrop then
        label.allianceTerritoryBackdrop:SetHidden(true)
    end
end

function TPM:AcquireOverlayLabel()
    local label = table.remove(self.labelPool)
    if label then
        label:SetHidden(false)
        self:ApplyProgressFont(label, "overlay")
        return label
    end

    self.nextLabelId = self.nextLabelId + 1
    label = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "NativeLabel" .. tostring(self.nextLabelId), ZO_WorldMapContainer, CT_LABEL)
    label:SetDimensions(84, 32)
    self:ApplyProgressFont(label, "overlay")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawTier(DT_HIGH)
    label:SetMouseEnabled(true)

    label:SetHandler("OnMouseEnter", function(control)
        if not TPM.saved or not TPM.saved.showTooltip or not control.zoneId then return end
        TPM:ShowTooltip(control)
    end)

    label:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)

    label:SetHandler("OnMouseUp", function(control, button, upInside)
        if not upInside or button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if control.mapId and WORLD_MAP_MANAGER and WORLD_MAP_MANAGER.SetMapById then
            WORLD_MAP_MANAGER:SetMapById(control.mapId)
        end
    end)

    return label
end

function TPM:ReleaseOverlayLabels()
    for _, label in ipairs(self.overlayLabels) do
        self:HideAllianceTerritoryBackdrop(label)
        label:SetHidden(true)
        label:ClearAnchors()
        label.zoneId = nil
        label.progressZoneId = nil
        label.mapId = nil
        label.breakdown = nil
        label.completedTotal = nil
        label.availableTotal = nil
        label.percent = nil
        self.labelPool[#self.labelPool + 1] = label
    end
    ZO_ClearNumericallyIndexedTable(self.overlayLabels)
end

function TPM:ShowTooltip(control)
    if not control.zoneId then return end

    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -8, TOP)
    InformationTooltip:AddLine(SafeZoneName(control.zoneId), "ZoFontWinH2")
    InformationTooltip:AddLine(self:L("OVERALL_PROGRESS", control.percent or 0), "ZoFontGameBold")

    if control.progressZoneId and control.progressZoneId ~= control.zoneId then
        InformationTooltip:AddLine(self:L("ESO_PROGRESS_ZONE", SafeZoneName(control.progressZoneId)), "ZoFontGameSmall")
    end

    if control.completedTotal and control.availableTotal then
        InformationTooltip:AddLine(self:L("OBJECTIVES_COMPLETE", control.completedTotal, control.availableTotal), "ZoFontGame")
    end

    if control.breakdown then
        InformationTooltip:AddVerticalPadding(7)
        local missingCount = 0
        for _, row in ipairs(control.breakdown) do
            if row.total > 0 and row.completed < row.total then
                if missingCount == 0 then
                    InformationTooltip:AddLine(self:L("TOOLTIP_MISSING_HEADER"), "ZoFontGameBold")
                end
                missingCount = missingCount + 1
                InformationTooltip:AddLine(
                    self:L(
                        "TOOLTIP_MISSING_LINE",
                        self:GetCompletionTypeName(row.completionType),
                        row.completed,
                        row.total
                    ),
                    "ZoFontGame"
                )
            end
        end
        if missingCount == 0 then
            InformationTooltip:AddLine(self:L("TOOLTIP_ALL_COMPLETE"), "ZoFontGameBold")
        end
    end

    if self.saved and self.saved.debugMode then
        InformationTooltip:AddVerticalPadding(8)
        InformationTooltip:AddLine(self:L("DEBUG_HEADER"), "ZoFontGameBold")
        InformationTooltip:AddLine(self:L("DEBUG_CURRENT_MAP", tostring((GetCurrentMapId and GetCurrentMapId()) or 0)), "ZoFontGameSmall")
        InformationTooltip:AddLine(self:L("DEBUG_TARGET_MAP", tostring(control.mapId or 0)), "ZoFontGameSmall")
        InformationTooltip:AddLine(self:L("DEBUG_ZONE_ID", tostring(control.zoneId or 0)), "ZoFontGameSmall")
        InformationTooltip:AddLine(self:L("DEBUG_PROGRESS_ZONE_ID", tostring(control.progressZoneId or 0)), "ZoFontGameSmall")
        InformationTooltip:AddLine(self:L("DEBUG_MAP_TYPE", tostring((GetMapType and GetMapType()) or 0)), "ZoFontGameSmall")
    end

    InformationTooltip:AddVerticalPadding(6)
    InformationTooltip:AddLine(self:L("LEFT_CLICK_OPEN"), "ZoFontGameSmall")
end


function TPM:BuildSymbolicZonePositionCache()
    ZO_ClearTable(self.symbolicZonePositions)
    self.symbolicZonePositionsMapId = GetCurrentMapId() or 0

    if GetMapType() ~= MAPTYPE_COSMIC then return end
    if type(GetNumFastTravelNodes) ~= "function" or type(GetFastTravelNodeInfo) ~= "function" then return end
    if type(GetFastTravelNodePOIIndicies) ~= "function" or type(GetZoneId) ~= "function" then return end

    local numNodes = GetNumFastTravelNodes() or 0
    for nodeIndex = 1, numNodes do
        local _, _, x, y, _, _, _, isShownInCurrentMap = GetFastTravelNodeInfo(nodeIndex)
        if isShownInCurrentMap and type(x) == "number" and type(y) == "number" and x > 0 and x < 1 and y > 0 and y < 1 then
            local zoneIndex = GetFastTravelNodePOIIndicies(nodeIndex)
            if zoneIndex and zoneIndex > 0 then
                local sourceZoneId = GetZoneId(zoneIndex)
                if sourceZoneId and sourceZoneId > 0 then
                    local function Store(candidateZoneId)
                        if candidateZoneId and candidateZoneId > 0 and AURBIS_SYMBOLIC_ZONE_IDS[candidateZoneId]
                           and not self.symbolicZonePositions[candidateZoneId] then
                            self.symbolicZonePositions[candidateZoneId] = { x = x, y = y }
                        end
                    end

                    Store(sourceZoneId)

                    if type(GetZoneStoryZoneIdForZoneId) == "function" then
                        Store(GetZoneStoryZoneIdForZoneId(sourceZoneId))
                    end

                    if type(GetParentZoneId) == "function" then
                        Store(GetParentZoneId(sourceZoneId))
                    end
                end
            end
        end
    end
end

function TPM:GetSymbolicZonePinPosition(zoneId)
    if GetMapType() ~= MAPTYPE_COSMIC or not AURBIS_SYMBOLIC_ZONE_IDS[zoneId] then
        return nil
    end

    local currentMapId = GetCurrentMapId() or 0
    if self.symbolicZonePositionsMapId ~= currentMapId then
        self:BuildSymbolicZonePositionCache()
    end

    local position = self.symbolicZonePositions[zoneId]
    if not position then return nil end
    return position.x, position.y
end

function TPM:GetZonePinPosition(zoneId)
    local mapId = GetMapIdByZoneId(zoneId)
    if not mapId or mapId <= 0 then return nil end

    -- Clockwork City's Aurbis symbol is a deliberate UI location rather than a
    -- geographical projection. Use the known normalized symbol center first so
    -- it cannot disappear because of fast-travel visibility or map projection.
    if GetMapType() == MAPTYPE_COSMIC then
        local fixedPosition = AURBIS_FIXED_ZONE_POSITIONS[zoneId]
        if fixedPosition then
            return fixedPosition.x, fixedPosition.y, mapId, true
        end
    end

    -- Aurbis has symbolic locations whose on-screen position does not match the
    -- universally-normalized center of their actual zone map. Prefer ESO's own
    -- current-map fast-travel position for explicitly known special realms.
    local symbolicX, symbolicY = self:GetSymbolicZonePinPosition(zoneId)
    if symbolicX and symbolicY then
        return symbolicX, symbolicY, mapId, true
    end

    local zoneOffsetX, zoneOffsetY, zoneWidth, zoneHeight = self:GetMapRect(mapId)
    if not zoneOffsetX then return nil end

    local universalX = zoneOffsetX + (zoneWidth * 0.5)
    local universalY = zoneOffsetY + (zoneHeight * 0.5)
    local x, y = self:UniversalToCurrentMap(universalX, universalY)
    if not x or not y then return nil end

    return x, y, mapId, false
end

function TPM:CreateZoneNativePin(pinManager, zoneId)
    local x, y, mapId, isSymbolicPosition = self:GetZonePinPosition(zoneId)
    if not x then return end
    if not self:ShouldDisplayOverviewZone(zoneId, x, y, isSymbolicPosition) then return end

    local breakdown, completedTotal, availableTotal, percent, progressZoneId = self:GetResolvedCompletion(zoneId)
    if availableTotal <= 0 then return end
    if not self:IsProgressZoneAvailable(progressZoneId) then return end
    if not self:MatchesQuickFilter(percent) then return end

    local displayText = self:GetOverviewPercentText(percent)
    if not displayText then return end

    local pinType = _G[PIN_TYPE_STRING]
    if not pinType then return end

    local pin = pinManager:CreatePin(pinType, zoneId, x, y)
    if not pin then return end

    local pinControl = pin:GetControl()
    if not pinControl then return end

    -- The native map pin is only an anchor. ESO owns its position and updates it
    -- in the same zoom/pan cycle as every other map pin. Our label is anchored to
    -- that control, so no per-frame coordinate calculation is needed anymore.
    -- Alpha is reset by ESO's map-pin pool. Do not change MouseEnabled here: the
    -- same pooled control can later be reused by a normal ESO pin.
    pinControl:SetAlpha(0)

    local label = self:AcquireOverlayLabel()
    label:ClearAnchors()
    label:SetAnchor(CENTER, pinControl, CENTER, 0, 0)

    -- World-map percentage labels deliberately use the same rendering path as
    -- v1.6.0. Font, size and color are fully controlled by the user's map
    -- percentage settings for every value, including 100%. The ESO-gold 100%
    -- treatment is reserved for the statistics journal only.
    local color = self:GetDisplayPercentColor(percent)
    local fontSize = self:GetProgressFontSize("overlay")
    if self.saved.showZoneNames then
        label:SetDimensions(math.max(280, fontSize * 11), math.max(34, fontSize + 10))
        label:SetText(string.format("|cD8C58C%s|r  |c%s%s|r", SafeZoneName(zoneId), color, displayText))
    else
        -- Keep the mouse hitbox close to the actual percentage text so map
        -- dragging/clicking is not blocked by large invisible label areas.
        label:SetDimensions(math.max(84, fontSize * 3), math.max(32, fontSize + 10))
        label:SetText(string.format("|c%s%s|r", color, displayText))
    end

    self:RefreshAllianceTerritoryBackdrop(label, zoneId)

    label.zoneId = zoneId
    label.progressZoneId = progressZoneId
    label.mapId = mapId
    label.breakdown = breakdown
    label.completedTotal = completedTotal
    label.availableTotal = availableTotal
    label.percent = percent

    self.overlayLabels[#self.overlayLabels + 1] = label
end

function TPM:BuildNativePins(pinManager)
    if not self.saved or not self.saved.enabled or not self:IsOverviewMap() then return end

    ZO_ClearTable(self.displayedZoneIds)

    local function TryAdd(zoneId)
        if not zoneId or zoneId <= 0 or TPM.displayedZoneIds[zoneId] then return end
        TPM.displayedZoneIds[zoneId] = true
        TPM:CreateZoneNativePin(pinManager, zoneId)
    end

    -- Clockwork City (zoneId 980) is a symbolic Aurbis realm and is not
    -- guaranteed to be returned through the same map enumeration path as normal
    -- MAPTYPE_ZONE regions. Queue it explicitly on the cosmic overview.
    if GetMapType() == MAPTYPE_COSMIC then
        TryAdd(980)
    end

    if type(GetNextZoneStoryZoneId) == "function" then
        local lastZoneId = nil
        local safety = 0
        while safety < 500 do
            local zoneId = GetNextZoneStoryZoneId(lastZoneId)
            if not zoneId or zoneId == 0 then break end
            TryAdd(zoneId)
            lastZoneId = zoneId
            safety = safety + 1
        end
    end

    if type(GetNumMaps) == "function" and type(GetMapInfoByIndex) == "function" then
        for mapIndex = 1, GetNumMaps() do
            local _, mapType, _, zoneIndex = GetMapInfoByIndex(mapIndex)
            if mapType == MAPTYPE_ZONE and zoneIndex and zoneIndex > 0 then
                TryAdd(GetZoneId(zoneIndex))
            end
        end
    end
end

function TPM:RegisterCustomPin()
    if self.pinRegistered then return true end
    if type(ZO_WorldMap_GetPinManager) ~= "function" then return false end

    local pinManager = ZO_WorldMap_GetPinManager()
    if not pinManager or not pinManager.AddCustomPin then return false end

    pinManager:AddCustomPin(
        PIN_TYPE_STRING,
        function(manager) TPM:BuildNativePins(manager) end,
        nil,
        {
            level = 200,
            size = 1,
            minSize = 1,
            texture = "",
        },
        nil
    )

    local pinType = _G[PIN_TYPE_STRING]
    if not pinType then return false end

    pinManager:SetCustomPinEnabled(pinType, true)
    self.pinRegistered = true
    return true
end

function TPM:GetFocusedQuestIndex()
    if QUEST_JOURNAL_MANAGER and QUEST_JOURNAL_MANAGER.GetFocusedQuestIndex then
        local questIndex = QUEST_JOURNAL_MANAGER:GetFocusedQuestIndex()
        if questIndex and questIndex > 0 and IsValidQuestIndex(questIndex) then
            return questIndex
        end
    end

    -- Prefer ESO's assisted tracked quest.
    if type(GetNumTracked) == "function" and type(GetTrackedByIndex) == "function" and type(GetTrackedIsAssisted) == "function" then
        for trackedIndex = 1, GetNumTracked() do
            local trackType, arg1, arg2 = GetTrackedByIndex(trackedIndex)
            if (not TRACK_TYPE_QUEST or trackType == TRACK_TYPE_QUEST) and GetTrackedIsAssisted(trackType, arg1, arg2) then
                if arg1 and arg1 > 0 and IsValidQuestIndex(arg1) then
                    return arg1
                end
            end
        end
    end

    -- Journal quest indices are sparse, so do not iterate only to
    -- GetNumJournalQuests(). Scan the full journal range and use ESO's tracked
    -- flag as a final fallback.
    if type(GetJournalQuestInfo) == "function" then
        local maxQuests = MAX_JOURNAL_QUESTS or 25
        for questIndex = 1, maxQuests do
            if IsValidQuestIndex(questIndex) then
                local _, _, _, _, _, _, tracked = GetJournalQuestInfo(questIndex)
                if tracked then
                    return questIndex
                end
            end
        end
    end

    return nil
end

function TPM:GetQuestRewardLines(questIndex)
    local lines = {}
    local details = {}
    if not questIndex or not IsValidQuestIndex(questIndex) then return lines, details end
    if type(GetJournalQuestNumRewards) ~= "function" or type(GetJournalQuestRewardInfo) ~= "function" then return lines, details end

    local numRewards = GetJournalQuestNumRewards(questIndex) or 0
    for rewardIndex = 1, numRewards do
        local rewardType, name, amount, iconOrCurrencyOptions, meetsUsageRequirement, itemDisplayQuality, itemType = GetJournalQuestRewardInfo(questIndex, rewardIndex)
        amount = amount or 0

        local isOwnedCollectible = REWARD_TYPE_AUTO_ITEM and REWARD_ITEM_TYPE_COLLECTIBLE
            and rewardType == REWARD_TYPE_AUTO_ITEM
            and itemType == REWARD_ITEM_TYPE_COLLECTIBLE
            and meetsUsageRequirement == false

        if not isOwnedCollectible then
            local line = nil
            local currencyType = nil
            local itemId = 0
            if type(GetJournalQuestRewardItemId) == "function" then
                itemId = GetJournalQuestRewardItemId(questIndex, rewardIndex) or 0
            end

            -- ESO uses the fourth GetJournalQuestRewardInfo() return value as
            -- currency formatting data for currency rewards, not as an icon
            -- texture. Detect all currency reward types through ESO's API so
            -- values such as Alliance Points, Tel Var, vouchers and keys cannot
            -- accidentally be passed into zo_iconFormat().
            if type(GetCurrencyTypeFromRewardType) == "function" then
                currencyType = GetCurrencyTypeFromRewardType(rewardType)
                if CURT_NONE and currencyType == CURT_NONE then
                    currencyType = nil
                end
            elseif REWARD_TYPE_MONEY and rewardType == REWARD_TYPE_MONEY then
                currencyType = CURT_MONEY
            end

            if currencyType and currencyType ~= 0 then
                if type(ZO_Currency_FormatPlatform) == "function" then
                    line = ZO_Currency_FormatPlatform(currencyType, amount, ZO_CURRENCY_FORMAT_WHITE_AMOUNT_ICON)
                else
                    line = string.format("%d %s", amount, self:L("QUEST_REWARD_CURRENCY"))
                end
            elseif REWARD_TYPE_PARTIAL_SKILL_POINTS and rewardType == REWARD_TYPE_PARTIAL_SKILL_POINTS then
                if type(ZO_QuestReward_GetSkillPointText) == "function" then
                    line = ZO_QuestReward_GetSkillPointText(amount)
                else
                    line = string.format("%s x%d", self:L("QUEST_REWARD_SKILL_POINTS"), amount)
                end
            else
                local rewardName = name or ""

                if REWARD_TYPE_SKILL_LINE and rewardType == REWARD_TYPE_SKILL_LINE and rewardName ~= "" and type(ZO_QuestReward_GetSkillLineEarnedText) == "function" then
                    rewardName = ZO_QuestReward_GetSkillLineEarnedText(rewardName)
                elseif rewardName ~= "" then
                    rewardName = zo_strformat(SI_TOOLTIP_ITEM_NAME, rewardName)
                else
                    rewardName = self:L("QUEST_REWARD_GENERIC")
                end

                -- Quest reward item names now follow ESO item-quality colors.
                -- Only apply quality colors when ESO exposes a real reward item id.
                if itemId > 0 and itemDisplayQuality and type(GetItemQualityColor) == "function" then
                    local qualityColor = GetItemQualityColor(itemDisplayQuality)
                    if qualityColor and qualityColor.Colorize then
                        rewardName = qualityColor:Colorize(rewardName)
                    end
                end

                local icon = iconOrCurrencyOptions
                local iconText = ""
                -- Only strings are valid texture paths. Some reward types use
                -- this API slot for non-texture data.
                if type(icon) == "string" and icon ~= "" and type(zo_iconFormat) == "function" then
                    iconText = zo_iconFormat(icon, 24, 24) .. " "
                end

                local amountText = amount > 1 and string.format(" x%d", amount) or ""
                line = iconText .. rewardName .. amountText
            end

            if line and line ~= "" then
                lines[#lines + 1] = line
                details[#details + 1] =
                {
                    line = line,
                    rewardIndex = rewardIndex,
                    rewardType = rewardType,
                    amount = amount,
                    itemId = itemId,
                    itemDisplayQuality = itemDisplayQuality,
                    itemType = itemType,
                    currencyType = currencyType,
                }
            end
        end
    end

    return lines, details
end

function TPM:ShowQuestRewardDetailsTooltip(control)
    local details = self.currentQuestRewardDetails or {}
    if #details == 0 then return end

    -- Anchor the details tooltip to the OUTER edge of the whole quest window,
    -- not to the small info icon inside it. This keeps the tooltip above/outside
    -- the high-draw-level reward panel instead of hiding it behind that panel.
    local owner = self.questRewardControl or control
    local rootWidth = (GuiRoot and GuiRoot.GetWidth and GuiRoot:GetWidth()) or 1920
    local ownerLeft = (owner and owner.GetLeft and owner:GetLeft()) or 0
    local ownerRight = (owner and owner.GetRight and owner:GetRight()) or ownerLeft
    local leftSpace = math.max(0, ownerLeft)
    local rightSpace = math.max(0, rootWidth - ownerRight)

    ClearTooltip(InformationTooltip)
    if rightSpace >= leftSpace then
        InitializeTooltip(InformationTooltip, owner, TOPLEFT, 12, 0, TOPRIGHT)
    else
        InitializeTooltip(InformationTooltip, owner, TOPRIGHT, -12, 0, TOPLEFT)
    end

    InformationTooltip:AddLine(self:L("QUEST_REWARD_DETAILS"), "ZoFontWinH3")
    InformationTooltip:AddLine(self:L("QUEST_REWARD_DETAILS_TT"), "ZoFontGameSmall")
    InformationTooltip:AddVerticalPadding(6)

    for _, detail in ipairs(details) do
        InformationTooltip:AddLine(detail.line, "ZoFontGame")
        if self.saved and self.saved.debugMode and detail.itemId and detail.itemId > 0 then
            InformationTooltip:AddLine(self:L("DEBUG_ITEM_ID", detail.itemId, detail.rewardIndex or 0), "ZoFontGameSmall")
        end
    end
end

function TPM:GetQuestRewardAnchorParent()
    return GuiRoot
end

function TPM:GetQuestRewardViewportBounds()
    local parent = GuiRoot
    local parentLeft = (parent and parent.GetLeft and parent:GetLeft()) or 0
    local parentTop = (parent and parent.GetTop and parent:GetTop()) or 0
    local parentWidth = (parent and parent.GetWidth and parent:GetWidth()) or 1920
    local parentHeight = (parent and parent.GetHeight and parent:GetHeight()) or 1080

    local width = (self.questRewardControl and self.questRewardControl:GetWidth()) or DEFAULTS.questRewardWidth
    local height = (self.questRewardControl and self.questRewardControl:GetHeight()) or DEFAULTS.questRewardHeight
    local margin = 8

    local minX = margin
    local minY = margin
    local maxX = math.max(minX, parentWidth - width - margin)
    local maxY = math.max(minY, parentHeight - height - margin)
    return parent, parentLeft, parentTop, minX, minY, maxX, maxY
end

function TPM:GetQuestRewardDefaultScreenPosition()
    local _, rootLeft, rootTop, minX, minY, maxX = self:GetQuestRewardViewportBounds()
    local width = (self.questRewardControl and self.questRewardControl:GetWidth()) or DEFAULTS.questRewardWidth

    -- Start near the upper-right of the actual parchment when possible, but
    -- keep the control in GuiRoot coordinates so the user can later drag it
    -- anywhere on the screen, including outside the map.
    local x = maxX
    local y = minY + 90
    if ZO_WorldMapScroll then
        local mapRight = ZO_WorldMapScroll:GetRight()
        local mapTop = ZO_WorldMapScroll:GetTop()
        if mapRight and mapTop then
            x = (mapRight - rootLeft) - width - 24
            y = (mapTop - rootTop) + 90
        end
    end
    return self:ClampQuestRewardScreenPosition(x, y)
end

function TPM:ClampQuestRewardScreenPosition(x, y)
    local _, _, _, minX, minY, maxX, maxY = self:GetQuestRewardViewportBounds()
    x = Clamp(tonumber(x) or minX, minX, maxX)
    y = Clamp(tonumber(y) or minY, minY, maxY)
    return x, y
end

function TPM:MigrateQuestRewardScreenPosition()
    if not self.saved then return end

    local positionVersion = tonumber(self.saved.questRewardPositionVersion) or 1
    if positionVersion >= 5
        and type(self.saved.questRewardScreenX) == "number"
        and type(self.saved.questRewardScreenY) == "number" then
        return
    end

    local x, y
    local rootLeft = (GuiRoot and GuiRoot:GetLeft()) or 0
    local rootTop = (GuiRoot and GuiRoot:GetTop()) or 0

    -- v1.5.13/1.5.14 stored the position relative to ZO_WorldMap. Convert that
    -- position once into absolute GuiRoot coordinates so the user's last
    -- visible placement is preserved while removing the map-boundary clamp.
    if positionVersion == 4
        and type(self.saved.questRewardScreenX) == "number"
        and type(self.saved.questRewardScreenY) == "number"
        and ZO_WorldMap then
        local mapLeft = ZO_WorldMap:GetLeft()
        local mapTop = ZO_WorldMap:GetTop()
        if mapLeft and mapTop then
            x = (mapLeft - rootLeft) + self.saved.questRewardScreenX
            y = (mapTop - rootTop) + self.saved.questRewardScreenY
        end
    end

    if not x or not y then
        x, y = self:GetQuestRewardDefaultScreenPosition()
    end

    x, y = self:ClampQuestRewardScreenPosition(x, y)
    self.saved.questRewardScreenX = x
    self.saved.questRewardScreenY = y
    self.saved.questRewardPositionVersion = 5
end

function TPM:ApplyQuestRewardPosition()
    local control = self.questRewardControl
    if not control or not self.saved or not GuiRoot then return end

    self:MigrateQuestRewardScreenPosition()
    local x, y = self:ClampQuestRewardScreenPosition(
        self.saved.questRewardScreenX,
        self.saved.questRewardScreenY
    )

    self.saved.questRewardScreenX = x
    self.saved.questRewardScreenY = y
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

function TPM:SaveQuestRewardPosition()
    local control = self.questRewardControl
    if not control or not self.saved or not GuiRoot then return end

    local left = control:GetLeft()
    local top = control:GetTop()
    local rootLeft = GuiRoot:GetLeft() or 0
    local rootTop = GuiRoot:GetTop() or 0
    if not left or not top then return end

    local x, y = self:ClampQuestRewardScreenPosition(left - rootLeft, top - rootTop)
    self.saved.questRewardScreenX = Round(x)
    self.saved.questRewardScreenY = Round(y)
    self.saved.questRewardPositionVersion = 5
    self:ApplyQuestRewardPosition()
end

function TPM:UpdateQuestRewardLockState()
    local locked = self.saved and self.saved.questRewardLocked or false
    if self.questRewardResizeHandle then
        self.questRewardResizeHandle:SetHidden(locked)
        self.questRewardResizeHandle:SetMouseEnabled(not locked)
    end
    if self.questRewardDragHandle then
        self.questRewardDragHandle:SetMouseEnabled(not locked)
    end
end

function TPM:StartMovingQuestRewardWindow()
    local control = self.questRewardControl
    if not control or self.questRewardMoving or self.questRewardResizing then return end
    if self.saved and self.saved.questRewardLocked then return end
    if type(GetUIMousePosition) ~= "function" then return end

    local mouseX, mouseY = GetUIMousePosition()
    local _, parentLeft, parentTop = self:GetQuestRewardViewportBounds()
    local left = control:GetLeft()
    local top = control:GetTop()
    if not left or not top then return end

    self.questRewardMoving = true
    self.questRewardMoveStartMouseX = mouseX
    self.questRewardMoveStartMouseY = mouseY
    self.questRewardMoveStartX = left - parentLeft
    self.questRewardMoveStartY = top - parentTop

    local driver = self.questRewardDragHandle or control
    driver:SetHandler("OnUpdate", function()
        if not TPM.questRewardMoving then return end

        local currentX, currentY = GetUIMousePosition()
        local x = TPM.questRewardMoveStartX + (currentX - TPM.questRewardMoveStartMouseX)
        local y = TPM.questRewardMoveStartY + (currentY - TPM.questRewardMoveStartMouseY)
        x, y = TPM:ClampQuestRewardScreenPosition(x, y)

        local parent = TPM:GetQuestRewardAnchorParent()
        control:ClearAnchors()
        control:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    end)
end

function TPM:StopMovingQuestRewardWindow()
    if not self.questRewardMoving then return end

    self.questRewardMoving = false
    local driver = self.questRewardDragHandle or self.questRewardControl
    if driver then
        driver:SetHandler("OnUpdate", nil)
    end
    self:SaveQuestRewardPosition()
end

function TPM:UpdateQuestRewardLayout()
    local control = self.questRewardControl
    if not control then return end

    local width = control:GetWidth() or DEFAULTS.questRewardWidth
    local contentWidth = math.max(252, width - 28)

    if self.questRewardTitle then
        local titleWidth = self.questRewardInfoButton and math.max(210, contentWidth - 30) or contentWidth
        self.questRewardTitle:SetWidth(titleWidth)
    end
    if self.questRewardDragHandle then
        local titleHeight = (self.questRewardTitle and self.questRewardTitle:GetHeight()) or 38
        self.questRewardDragHandle:SetHeight(math.max(42, titleHeight + 14))
    end
    if self.questRewardDivider then
        self.questRewardDivider:SetWidth(contentWidth)
    end
    if self.questRewardScrollContainer then
        self.questRewardScrollContainer:ClearAnchors()
        self.questRewardScrollContainer:SetAnchor(TOPLEFT, self.questRewardDivider, BOTTOMLEFT, 0, 8)
        self.questRewardScrollContainer:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -8, -24)
    end
    if self.questRewardLines then
        self.questRewardLines:SetWidth(math.max(220, contentWidth - ZO_SCROLL_BAR_WIDTH - 6))
        local textHeight = self.questRewardLines:GetTextHeight() or 0
        self.questRewardLines:SetHeight(math.max(1, textHeight + 4))
    end
    if self.questRewardScrollContainer and self.questRewardScrollContainer.UpdateScrollBar then
        self.questRewardScrollContainer:UpdateScrollBar()
    end
end

function TPM:ApplyQuestRewardSize()
    local control = self.questRewardControl
    if not control then return end

    local width = Clamp((self.saved and self.saved.questRewardWidth) or DEFAULTS.questRewardWidth, 280, 720)
    local height = Clamp((self.saved and self.saved.questRewardHeight) or DEFAULTS.questRewardHeight, 160, 650)
    control:SetDimensions(width, height)
    self:UpdateQuestRewardLayout()
end

function TPM:SaveQuestRewardSize()
    local control = self.questRewardControl
    if not control or not self.saved then return end

    self.saved.questRewardWidth = Round(Clamp(control:GetWidth() or DEFAULTS.questRewardWidth, 280, 720))
    self.saved.questRewardHeight = Round(Clamp(control:GetHeight() or DEFAULTS.questRewardHeight, 160, 650))
    self:ApplyQuestRewardSize()
    self:ApplyQuestRewardPosition()
end

function TPM:AutoSizeQuestRewardWindow()
    if not self.saved or not self.saved.questRewardAutoSize then return end
    local control = self.questRewardControl
    if not control or not self.questRewardLines or not self.questRewardTitle then return end

    -- Apply the current width before measuring wrapped text. This matters for
    -- long ESO-generated reward names and skill-point lines.
    self:UpdateQuestRewardLayout()

    local titleTextHeight = self.questRewardTitle:GetTextHeight() or 0
    local titleHeight = Clamp(math.max(30, titleTextHeight + 4), 30, 72)
    self.questRewardTitle:SetHeight(titleHeight)

    self:UpdateQuestRewardLayout()
    local rewardTextHeight = self.questRewardLines:GetTextHeight() or 0
    local rootHeight = (GuiRoot and GuiRoot.GetHeight and GuiRoot:GetHeight()) or 1080
    local maxAutoHeight = Clamp(rootHeight - 32, 160, 650)
    local desiredHeight = Clamp(titleHeight + rewardTextHeight + 112, 160, maxAutoHeight)
    control:SetHeight(desiredHeight)
    self.saved.questRewardHeight = Round(desiredHeight)
    self:UpdateQuestRewardLayout()
    self:ApplyQuestRewardPosition()
end

function TPM:StartResizingQuestRewardWindow()
    if self.questRewardResizing or type(GetUIMousePosition) ~= "function" then return end
    if self.saved and self.saved.questRewardLocked then return end

    local control = self.questRewardControl
    local handle = self.questRewardResizeHandle
    if not control or not handle then return end

    local mouseX, mouseY = GetUIMousePosition()
    self.questRewardResizing = true
    self.questRewardResizeStartMouseX = mouseX
    self.questRewardResizeStartMouseY = mouseY
    self.questRewardResizeStartWidth = control:GetWidth() or DEFAULTS.questRewardWidth
    self.questRewardResizeStartHeight = control:GetHeight() or DEFAULTS.questRewardHeight
    if self.saved then
        self.saved.questRewardAutoSize = false
    end

    handle:SetHandler("OnUpdate", function()
        if not TPM.questRewardResizing then return end
        local currentX, currentY = GetUIMousePosition()
        local newWidth = Clamp(TPM.questRewardResizeStartWidth + (currentX - TPM.questRewardResizeStartMouseX), 280, 720)
        local newHeight = Clamp(TPM.questRewardResizeStartHeight + (currentY - TPM.questRewardResizeStartMouseY), 160, 650)
        control:SetDimensions(newWidth, newHeight)
        TPM:UpdateQuestRewardLayout()
    end)
end

function TPM:StopResizingQuestRewardWindow()
    if not self.questRewardResizing then return end
    self.questRewardResizing = false
    if self.questRewardResizeHandle then
        self.questRewardResizeHandle:SetHandler("OnUpdate", nil)
    end
    self:SaveQuestRewardSize()
end

function TPM:ResetQuestRewardWindow()
    if not self.saved then return end
    self.saved.questRewardAnchorX = DEFAULTS.questRewardAnchorX
    self.saved.questRewardAnchorY = DEFAULTS.questRewardAnchorY
    self.saved.questRewardWidth = DEFAULTS.questRewardWidth
    self.saved.questRewardHeight = DEFAULTS.questRewardHeight
    self.saved.questRewardAutoSize = true
    self.saved.questRewardPositionVersion = 5

    self:ApplyQuestRewardSize()
    local x, y = self:GetQuestRewardDefaultScreenPosition()
    x, y = self:ClampQuestRewardScreenPosition(x, y)
    self.saved.questRewardScreenX = x
    self.saved.questRewardScreenY = y
    self:ApplyQuestRewardPosition()
    self:UpdateQuestRewardLockState()
    self:QueueRefresh(10)
end

function TPM:CreateQuestRewardControl()
    if self.questRewardControl then return end
    if not GuiRoot or not WINDOW_MANAGER or not WINDOW_MANAGER.CreateTopLevelWindow then return end

    local control = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "QuestRewardControl")
    if control.SetDrawLayer then control:SetDrawLayer(DL_OVERLAY) end
    if control.SetDrawTier then control:SetDrawTier(DT_HIGH) end
    if control.SetDrawLevel then control:SetDrawLevel(100000) end
    control:SetMouseEnabled(true)
    control:SetClampedToScreen(true)
    control:SetMovable(false)
    control:SetHidden(true)
    self.questRewardControl = control
    self:ApplyQuestRewardSize()
    self:ApplyQuestRewardPosition()

    local backdrop = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "QuestRewardBackdrop", control, CT_BACKDROP)
    backdrop:SetAnchorFill(control)
    backdrop:SetDrawLayer(DL_BACKGROUND)
    backdrop:SetDrawTier(DT_LOW)
    backdrop:SetCenterColor(0.035, 0.03, 0.025, 0.88)
    backdrop:SetEdgeColor(0.72, 0.64, 0.40, 0.92)
    backdrop:SetEdgeTexture(nil, 1, 1, 2)
    backdrop:SetMouseEnabled(false)
    self.questRewardBackdrop = backdrop

    local inner = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "QuestRewardInnerBackdrop", control, CT_BACKDROP)
    inner:SetAnchor(TOPLEFT, control, TOPLEFT, 4, 4)
    inner:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -4, -4)
    inner:SetDrawLayer(DL_BACKGROUND)
    inner:SetDrawTier(DT_LOW)
    inner:SetCenterColor(0.09, 0.075, 0.05, 0.48)
    inner:SetEdgeColor(0.08, 0.06, 0.04, 0.0)
    inner:SetMouseEnabled(false)
    self.questRewardInnerBackdrop = inner

    local title = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "QuestRewardTitle", control, CT_LABEL)
    title:SetWidth(284)
    title:SetHeight(38)
    title:SetAnchor(TOPLEFT, control, TOPLEFT, 14, 10)
    title:SetFont(FONT_PROFILES.classic.questTitle)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetVerticalAlignment(TEXT_ALIGN_TOP)
    title:SetColor(0.95, 0.82, 0.36, 1)
    title:SetDrawLayer(DL_OVERLAY)
    title:SetDrawTier(DT_HIGH)
    title:SetMouseEnabled(false)
    self.questRewardTitle = title

    -- Dedicated drag area over the quest title. The scroll container consumes
    -- mouse input for scrolling, so dragging the whole parent control is not
    -- reliable. Keeping movement on the title bar makes it deterministic.
    local dragHandle = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "QuestRewardDragHandle", control, CT_CONTROL)
    dragHandle:SetAnchor(TOPLEFT, control, TOPLEFT, 6, 5)
    dragHandle:SetAnchor(TOPRIGHT, control, TOPRIGHT, -6, 5)
    dragHandle:SetHeight(52)
    dragHandle:SetDrawLayer(DL_OVERLAY)
    dragHandle:SetDrawTier(DT_HIGH)
    if dragHandle.SetDrawLevel then dragHandle:SetDrawLevel(5100) end
    dragHandle:SetMouseEnabled(true)
    dragHandle:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            TPM:StartMovingQuestRewardWindow()
        end
    end)
    dragHandle:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            TPM:StopMovingQuestRewardWindow()
        end
    end)
    self.questRewardDragHandle = dragHandle

    local infoButton = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "QuestRewardInfoButton", control, CT_LABEL)
    infoButton:SetDimensions(24, 24)
    infoButton:SetAnchor(TOPRIGHT, control, TOPRIGHT, -10, 10)
    infoButton:SetFont("ZoFontGameBold")
    infoButton:SetText("|cE6C45Ci|r")
    infoButton:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    infoButton:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    infoButton:SetDrawLayer(DL_OVERLAY)
    infoButton:SetDrawTier(DT_HIGH)
    if infoButton.SetDrawLevel then infoButton:SetDrawLevel(5200) end
    infoButton:SetMouseEnabled(true)
    infoButton:SetHidden(true)
    infoButton:SetHandler("OnMouseEnter", function(btn)
        TPM:ShowQuestRewardDetailsTooltip(btn)
    end)
    infoButton:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
    self.questRewardInfoButton = infoButton

    local divider = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "QuestRewardDivider", control, CT_BACKDROP)
    divider:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 6)
    divider:SetDimensions(284, 1)
    divider:SetDrawLayer(DL_OVERLAY)
    divider:SetDrawTier(DT_HIGH)
    divider:SetCenterColor(0.68, 0.60, 0.36, 0.68)
    divider:SetEdgeColor(0.74, 0.64, 0.39, 0.0)
    divider:SetMouseEnabled(false)
    self.questRewardDivider = divider

    local scrollContainer = WINDOW_MANAGER:CreateControlFromVirtual(
        ADDON_NAME .. "QuestRewardScrollContainer",
        control,
        "ZO_ScrollContainer_Shared"
    )
    scrollContainer:SetDrawLayer(DL_OVERLAY)
    scrollContainer:SetDrawTier(DT_HIGH)
    self.questRewardScrollContainer = scrollContainer
    self.questRewardScroll = scrollContainer:GetNamedChild("Scroll")
    self.questRewardScrollChild = self.questRewardScroll and self.questRewardScroll:GetNamedChild("Child") or nil

    local rewardParent = self.questRewardScrollChild or control
    local rewards = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "QuestRewardLines", rewardParent, CT_LABEL)
    rewards:SetAnchor(TOPLEFT, rewardParent, TOPLEFT, 0, 0)
    rewards:SetWidth(250)
    rewards:SetFont(FONT_PROFILES.classic.questBody)
    rewards:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    rewards:SetVerticalAlignment(TEXT_ALIGN_TOP)
    rewards:SetColor(1, 1, 1, 1)
    rewards:SetDrawLayer(DL_OVERLAY)
    rewards:SetDrawTier(DT_HIGH)
    rewards:SetMouseEnabled(false)
    self.questRewardLines = rewards

    local resizeHandle = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "QuestRewardResizeHandle", control, CT_LABEL)
    resizeHandle:SetDimensions(30, 24)
    resizeHandle:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -5, -3)
    resizeHandle:SetFont("ZoFontGameSmall")
    resizeHandle:SetText("|cC9B76A///|r")
    resizeHandle:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    resizeHandle:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    resizeHandle:SetDrawLayer(DL_OVERLAY)
    resizeHandle:SetDrawTier(DT_HIGH)
    resizeHandle:SetMouseEnabled(true)
    resizeHandle:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            TPM:StartResizingQuestRewardWindow()
        end
    end)
    resizeHandle:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            TPM:StopResizingQuestRewardWindow()
        end
    end)
    self.questRewardResizeHandle = resizeHandle

    self:UpdateQuestRewardLockState()
    self:ApplyQuestRewardFonts()
    self:UpdateQuestRewardLayout()
end

function TPM:HideQuestRewards()
    self.currentQuestRewardDetails = nil
    if self.questRewardInfoButton then
        self.questRewardInfoButton:SetHidden(true)
    end
    if self.questRewardControl then
        self.questRewardControl:SetHidden(true)
    end
end

function TPM:RefreshQuestRewards()
    -- Full-map-only UI: minimap addons may keep ZO_WorldMap visible on the HUD.
    -- The reward window belongs to the actual world-map scene only.
    if not self:IsFullWorldMapSceneVisible() then
        if self.questRewardControl then self:HideQuestRewards() end
        return
    end

    self:CreateQuestRewardControl()
    if not self.questRewardControl then return end

    -- 3.3.3: this legacy reward window belongs to the world map only.
    -- Queued refreshes can fire just after the map closes, so guard here as
    -- well as in the scene callback to prevent the window reopening on the HUD.

    -- The v2 statistics journal intentionally gets the full map viewport.
    -- Keep the movable quest-reward top-level window from floating above it.
    if self.statisticsWindow and not self.statisticsWindow:IsHidden() then
        self:HideQuestRewards()
        return
    end

    if not self.saved or not self.saved.showQuestRewards then
        self:HideQuestRewards()
        return
    end

    -- Keep the window visible whenever the map is open and the feature is
    -- enabled. Missing focus/reward data should show a useful status message
    -- instead of making the entire window disappear.
    local questIndex = self:GetFocusedQuestIndex()
    local questName = ""
    local rewardText = ""
    local rewardDetails = {}

    if not questIndex then
        questName = self:L("QUEST_REWARDS")
        rewardText = self:L("QUEST_NO_FOCUSED_QUEST")
    else
        questName = GetJournalQuestName(questIndex) or ""
        if questName == "" then
            questName = GetString(SI_QUEST_JOURNAL_UNKNOWN_QUEST_NAME)
        end

        local lines, details = self:GetQuestRewardLines(questIndex)
        rewardDetails = details or {}
        if #lines > 0 then
            rewardText = table.concat(lines, "\n")
        else
            rewardText = self:L("QUEST_NO_REWARD_DATA")
        end
    end

    self.currentQuestRewardDetails = rewardDetails
    if self.questRewardInfoButton then
        self.questRewardInfoButton:SetHidden(#rewardDetails == 0)
    end

    self.questRewardTitle:SetText(string.format("|cE6C45C%s|r", zo_strformat(SI_TOOLTIP_ITEM_NAME, questName)))
    self.questRewardLines:SetText(string.format("|cFFFFFF%s|r\n%s", self:L("QUEST_REWARDS"), rewardText))

    local titleTextHeight = self.questRewardTitle:GetTextHeight() or 0
    self.questRewardTitle:SetHeight(Clamp(math.max(30, titleTextHeight + 4), 30, 64))
    self:UpdateQuestRewardLayout()
    self:UpdateQuestRewardLockState()
    self:ApplyQuestRewardPosition()

    -- Show first, then auto-size. This also makes the one-frame auto-size
    -- callback reliable for a control that starts hidden after addon load.
    self.questRewardControl:SetAlpha(1)
    if self.questRewardControl.SetDrawLevel then self.questRewardControl:SetDrawLevel(100000) end
    self.questRewardControl:SetHidden(false)

    if self.questRewardScrollContainer and self.questRewardScrollContainer.ResetToTop then
        self.questRewardScrollContainer:ResetToTop()
    end

    if self.saved.questRewardAutoSize then
        local function RecheckQuestRewardAutoSize()
            if TPM and TPM.questRewardControl and not TPM.questRewardControl:IsHidden() then
                TPM:AutoSizeQuestRewardWindow()
            end
        end
        -- ESO text/icon metrics can settle after SetText(). Re-measure twice so
        -- long reward lines (especially skill points) are not clipped.
        zo_callLater(RecheckQuestRewardAutoSize, 1)
        zo_callLater(RecheckQuestRewardAutoSize, 50)
    end
end


-- v2.0.1 Tamriel Completion Journal / full statistics window -----------------
local function GetZoneNameSortKey(name)
    local key = zo_strlower(name or "")
    -- Keep A-Z intuitive for the addon languages. Cyrillic already follows a
    -- stable Unicode order; normalize common German/French accented letters so
    -- localized TPM labels sort where players expect them.
    key = key:gsub("ä", "ae"):gsub("ö", "oe"):gsub("ü", "ue"):gsub("ß", "ss")
    key = key:gsub("à", "a"):gsub("â", "a"):gsub("á", "a"):gsub("ä", "a")
    key = key:gsub("ç", "c")
    key = key:gsub("é", "e"):gsub("è", "e"):gsub("ê", "e"):gsub("ë", "e")
    key = key:gsub("î", "i"):gsub("ï", "i"):gsub("í", "i")
    key = key:gsub("ô", "o"):gsub("ö", "o"):gsub("ó", "o")
    key = key:gsub("ù", "u"):gsub("û", "u"):gsub("ü", "u"):gsub("ú", "u")
    key = key:gsub("ÿ", "y")
    return key
end

function TPM:GetPriorityQuestIdSet(progressZoneIds)
    local ids = {}
    if type(GetZoneActivityIdForZoneCompletionType) ~= "function" then return ids end
    for zoneId in pairs(progressZoneIds or {}) do
        local total = self:GetZoneCompletionActivityTotal(zoneId, ZONE_COMPLETION_TYPE_PRIORITY_QUESTS)
        for activityIndex = 1, total do
            local questId = GetZoneActivityIdForZoneCompletionType(zoneId, ZONE_COMPLETION_TYPE_PRIORITY_QUESTS, activityIndex)
            if questId and questId > 0 then ids[questId] = true end
        end
    end
    return ids
end

function TPM:IsLikelySideQuestName(name)
    if not name or name == "" then return false end
    local upper = zo_strupper(name)
    -- The quest master table contains a few development/dummy records.
    if upper:find("OUTOFDATE", 1, true) then return false end
    if upper:find("QUEST IO BUG", 1, true) then return false end
    if upper:find("DEBUG QUEST", 1, true) then return false end
    if upper:find("TEST QUEST", 1, true) then return false end
    if upper:find("PLACEHOLDER QUEST", 1, true) then return false end
    return true
end

local function TPM_GetProgressZoneScopeKey(progressZoneIds)
    local ids = {}
    for zoneId in pairs(progressZoneIds or {}) do ids[#ids + 1] = tonumber(zoneId) or 0 end
    table.sort(ids)
    if #ids == 0 then return "none" end
    if #ids == 1 then return "zone:" .. tostring(ids[1]) end
    -- The normal all-Tamriel scope is stable for a client build. A compact key
    -- avoids rescanning the entire quest master table whenever zone focus changes.
    return "zones:" .. table.concat(ids, ",")
end

function TPM:BuildSideQuestIndex(progressZoneIds)
    self.sideQuestIdsByScope = self.sideQuestIdsByScope or {}
    local scopeKey = TPM_GetProgressZoneScopeKey(progressZoneIds)
    if self.sideQuestIdsByScope[scopeKey] then
        return self.sideQuestIdsByScope[scopeKey]
    end

    local sideQuestIds = {}
    if type(GetQuestName) ~= "function"
        or type(GetQuestZoneId) ~= "function"
        or type(GetQuestType) ~= "function"
        or type(GetQuestRepeatableType) ~= "function"
        or type(HasCompletedQuest) ~= "function" then
        return sideQuestIds
    end

    local priorityQuestIds = self:GetPriorityQuestIdSet(progressZoneIds)
    local notRepeatable = _G.QUEST_REPEAT_NOT_REPEATABLE
    local normalQuestType = _G.QUEST_TYPE_NONE
    if notRepeatable == nil or normalQuestType == nil then return sideQuestIds end

    for questId = 1, SIDE_QUEST_SCAN_MAX_ID do
        if not priorityQuestIds[questId] then
            local zoneId = GetQuestZoneId(questId) or 0
            if zoneId > 0 then
                local progressZoneId = zoneId
                if not progressZoneIds[progressZoneId] and type(GetZoneStoryZoneIdForZoneId) == "function" then
                    local storyZoneId = GetZoneStoryZoneIdForZoneId(zoneId)
                    if storyZoneId and storyZoneId > 0 then progressZoneId = storyZoneId end
                end

                if progressZoneIds[progressZoneId]
                    and GetQuestRepeatableType(questId) == notRepeatable
                    and GetQuestType(questId) == normalQuestType then
                    local name = GetQuestName(questId) or ""
                    if self:IsLikelySideQuestName(name) then
                        sideQuestIds[#sideQuestIds + 1] = questId
                    end
                end
            end
        end
    end

    self.sideQuestIdsByScope[scopeKey] = sideQuestIds
    return sideQuestIds
end

function TPM:GetSideQuestStatistics(progressZoneIds)
    local sideQuestIds = self:BuildSideQuestIndex(progressZoneIds) or {}
    local total = #sideQuestIds
    if total <= 0 then return nil end
    local completed = 0
    for _, questId in ipairs(sideQuestIds) do
        if HasCompletedQuest(questId) then completed = completed + 1 end
    end
    local percent = Clamp(Round((completed / total) * 100), 0, 100)
    if completed < total and percent >= 100 then percent = 99 end
    return {
        completionType = SIDE_QUEST_CATEGORY_KEY,
        name = self:L("CAT_SIDE_QUESTS"),
        completed = completed,
        total = total,
        remaining = math.max(0, total - completed),
        percent = percent,
    }
end

-- ESO intentionally does not expose the live Crown Store catalog to addons.
-- We therefore track a curated list of permanent/current Crown Store quest
-- starters by their localized DE/EN quest names. Completion itself is read
-- from HasCompletedQuest, so already-finished quests are detected retroactively.
-- Rotating limited-time quest starters are deliberately not counted here.
local CROWN_QUEST_STARTER_NAMES =
{
    -- Permanent/current Crown Store Quest Starters known for 2.0.8 (DE + EN).
    ["the demon weapon"] = true,
    ["die dämonenwaffe"] = true,
    ["the dragonguard's legacy"] = true,
    ["das erbe der drachengarde"] = true,
    ["the coven conspiracy"] = true,
    ["die zirkelverschwörung"] = true,
    ["the ravenwatch inquiry"] = true,
    ["die rabenwacht-untersuchung"] = true,
    ["a mortal's touch"] = true,
    ["berührung eines sterblichen"] = true,
    ["an apocalyptic situation"] = true,
    ["eine apokalyptische lage"] = true,
    ["through a veil darkly"] = true,
    ["durch einen dunklen schleier"] = true,
    ["ruthless competition"] = true,
    ["skrupellose konkurrenz"] = true,
    ["the missing prophecy"] = true,
    ["die fehlende prophezeiung"] = true,
    ["ascending doubt"] = true,
    ["emporstrebender zweifel"] = true,
    ["sojourn of the druid king"] = true,
    ["das verweilen des druidenkönigs"] = true,
    ["eye of fate"] = true,
    ["auge des schicksals"] = true,
    ["prisoner of fate"] = true,
    ["gefangene des schicksals"] = true,
    ["a guild in crisis"] = true,
    ["eine gilde in der krise"] = true,
    ["room to spare"] = true,
    ["zimmer frei"] = true,
    ["wohnprospekt: zimmer frei"] = true,
    ["the margins of ire"] = true,
    ["die randnotizen der wut"] = true,
    ["a study in discipline"] = true,
    ["eine studie in sachen disziplin"] = true,
    ["the second era of scribing"] = true,
    ["die zweite ära der schriftlehre"] = true,
}


local function NormalizeQuestStarterName(name)
    if not name or name == "" then return "" end
    local value = zo_strlower(name)
    value = value:gsub("[%c]", " ")
    value = value:gsub("%s+", " ")
    value = value:gsub("^%s+", ""):gsub("%s+$", "")
    return value
end

function TPM:BuildCrownQuestIndex()
    if self.crownQuestIndexBuilt then return end
    self.crownQuestIds = {}

    if type(GetQuestName) ~= "function" or type(HasCompletedQuest) ~= "function" then
        return
    end

    local notRepeatable = _G.QUEST_REPEAT_NOT_REPEATABLE
    self.crownQuestIndexBuilt = true

    local seen = {}
    for questId = 1, SIDE_QUEST_SCAN_MAX_ID do
        local name = GetQuestName(questId) or ""
        local include = name ~= "" and CROWN_QUEST_STARTER_NAMES[NormalizeQuestStarterName(name)] == true

        if include and notRepeatable ~= nil and type(GetQuestRepeatableType) == "function" then
            include = GetQuestRepeatableType(questId) == notRepeatable
        end

        if include and not seen[questId] then
            seen[questId] = true
            self.crownQuestIds[#self.crownQuestIds + 1] = questId
        end
    end
end

function TPM:GetCrownQuestStatistics()
    self:BuildCrownQuestIndex()
    local total = #(self.crownQuestIds or {})
    if total <= 0 then return nil end

    local completed = 0
    for _, questId in ipairs(self.crownQuestIds) do
        if HasCompletedQuest(questId) then completed = completed + 1 end
    end

    local remaining = math.max(0, total - completed)
    local percent = Clamp(Round((completed / total) * 100), 0, 100)
    if completed < total and percent >= 100 then percent = 99 end

    return {
        completionType = CROWN_QUEST_CATEGORY_KEY,
        name = self:L("CAT_CROWN_QUESTS"),
        completed = completed,
        total = total,
        remaining = remaining,
        percent = percent,
        countText = self:L("STAT_CROWN_QUEST_COUNT", completed, remaining),
        tooltipText = self:L("STAT_CROWN_QUEST_TT", completed, remaining),
    }
end

function TPM:GetStatisticsFocusZoneId()
    local zoneId = self.saved and tonumber(self.saved.statisticsFocusZoneId) or 0
    zoneId = Round(zoneId or 0)
    if zoneId <= 0 then return 0 end

    local available = self:GetAllProgressZoneIds()
    if not available[zoneId] then
        if self.saved then self.saved.statisticsFocusZoneId = 0 end
        return 0
    end
    return zoneId
end

function TPM:SetStatisticsFocusZone(zoneId)
    if not self.saved then return false end
    zoneId = Round(tonumber(zoneId) or 0)
    if zoneId > 0 and not self:GetAllProgressZoneIds()[zoneId] then return false end
    if tonumber(self.saved.statisticsFocusZoneId) == zoneId then return true end

    self.saved.statisticsFocusZoneId = zoneId
    -- 2.6.20: Keep the current 1/3, 2/3 or 3/3 page while changing zone
    -- focus. Pages 2 and 3 now have their own honest zone-aware presentation,
    -- so forcing the player back to page 1 made the selector feel jumpy.
    self.statisticsScrollOffset = 0
    self.statisticsFocusCache = nil
    self.statisticsFocusCacheZoneId = nil
    self.statisticsData = nil
    if self.statisticsWindow and not self.statisticsWindow:IsHidden() then
        -- Refresh one frame later so the custom selector can finish its click
        -- handler before the progress data and zone rows are rebuilt.
        if type(zo_callLater) == "function" then
            zo_callLater(function()
                if TPM and TPM.statisticsWindow and not TPM.statisticsWindow:IsHidden() then
                    TPM:RefreshStatisticsWindow()
                end
            end, 0)
        else
            self:RefreshStatisticsWindow()
        end
    end
    return true
end

function TPM:GetStatisticsFocusZoneChoices()
    local rows = {}
    for zoneId in pairs(self:GetAllProgressZoneIds()) do
        rows[#rows + 1] = { zoneId = zoneId, name = SafeZoneName(zoneId) }
    end
    table.sort(rows, function(a, b)
        local an, bn = GetZoneNameSortKey(a.name), GetZoneNameSortKey(b.name)
        if an == bn then return a.zoneId < b.zoneId end
        return an < bn
    end)
    return rows
end

function TPM:HideStatisticsFocusDropdown()
    if self.statisticsFocusDropdown then self.statisticsFocusDropdown:SetHidden(true) end
end

function TPM:RefreshStatisticsFocusDropdownRows()
    local dropdown = self.statisticsFocusDropdown
    local rows = self.statisticsFocusDropdownRows
    local choices = self.statisticsFocusChoices or {}
    if not dropdown or not rows then return end

    local visibleRows = #rows
    local maxOffset = math.max(0, #choices - visibleRows)
    self.statisticsFocusDropdownOffset = Clamp(Round(tonumber(self.statisticsFocusDropdownOffset) or 0), 0, maxOffset)
    local offset = self.statisticsFocusDropdownOffset
    local selectedZoneId = self:GetStatisticsFocusZoneId()

    for rowIndex, row in ipairs(rows) do
        local choice = choices[offset + rowIndex]
        if choice then
            row.TPMZoneId = choice.zoneId
            row:SetHidden(false)
            row.label:SetText(choice.name or "")
            row.selected = tonumber(choice.zoneId) == tonumber(selectedZoneId)
            if row.selected then
                row.bg:SetCenterColor(0.16, 0.125, 0.040, 0.98)
                row.label:SetColor(1.00, 0.84, 0.26, 1)
                if row.selectedMark then row.selectedMark:SetText("X") end
            else
                row.bg:SetCenterColor(0.025, 0.022, 0.017, 0.98)
                row.label:SetColor(0.91, 0.88, 0.78, 1)
                if row.selectedMark then row.selectedMark:SetText("") end
            end
        else
            row.TPMZoneId = nil
            row.selected = false
            if row.selectedMark then row.selectedMark:SetText("") end
            row:SetHidden(true)
        end
    end

    if self.statisticsFocusScrollBar then
        self.statisticsFocusScrollBarRefreshing = true
        self.statisticsFocusScrollBar:SetMinMax(0, maxOffset)
        self.statisticsFocusScrollBar:SetValueStep(1)
        self.statisticsFocusScrollBar:SetValue(offset)
        self.statisticsFocusScrollBar:SetHidden(maxOffset <= 0)
        self.statisticsFocusScrollBarRefreshing = false
    end
end

function TPM:ScrollStatisticsFocusDropdown(delta)
    if not self.statisticsFocusDropdown or self.statisticsFocusDropdown:IsHidden() then return end
    delta = Round(tonumber(delta) or 0)
    if delta == 0 then return end
    local choices = self.statisticsFocusChoices or {}
    local visibleRows = self.statisticsFocusDropdownRows and #self.statisticsFocusDropdownRows or 9
    local maxOffset = math.max(0, #choices - visibleRows)
    self.statisticsFocusDropdownOffset = Clamp((tonumber(self.statisticsFocusDropdownOffset) or 0) - delta, 0, maxOffset)
    if self.statisticsFocusScrollBar then
        self.statisticsFocusScrollBar:SetValue(self.statisticsFocusDropdownOffset)
    else
        self:RefreshStatisticsFocusDropdownRows()
    end
end

function TPM:ToggleStatisticsFocusDropdown()
    local dropdown = self.statisticsFocusDropdown
    if not dropdown then return end
    if not dropdown:IsHidden() then
        self:HideStatisticsFocusDropdown()
        return
    end

    self.statisticsFocusChoices = { { zoneId = 0, name = self:L("STAT_FOCUS_TAMRIEL") } }
    for _, zone in ipairs(self:GetStatisticsFocusZoneChoices()) do
        self.statisticsFocusChoices[#self.statisticsFocusChoices + 1] = zone
    end

    local selectedZoneId = self:GetStatisticsFocusZoneId()
    local selectedIndex = 1
    for index, choice in ipairs(self.statisticsFocusChoices) do
        if tonumber(choice.zoneId) == tonumber(selectedZoneId) then
            selectedIndex = index
            break
        end
    end
    local visibleRows = self.statisticsFocusDropdownRows and #self.statisticsFocusDropdownRows or 9
    local maxOffset = math.max(0, #self.statisticsFocusChoices - visibleRows)
    self.statisticsFocusDropdownOffset = Clamp(selectedIndex - math.ceil(visibleRows / 2), 0, maxOffset)
    self:RefreshStatisticsFocusDropdownRows()
    dropdown:SetHidden(false)
end

function TPM:RefreshStatisticsFocusSelector()
    local selectedLabel = self.statisticsFocusSelectedLabel
    if not selectedLabel then return end

    local selectedZoneId = self:GetStatisticsFocusZoneId()
    if selectedZoneId > 0 then
        selectedLabel:SetText(SafeZoneName(selectedZoneId))
    else
        selectedLabel:SetText(self:L("STAT_FOCUS_TAMRIEL"))
    end

    -- Rebuild names whenever the statistics window refreshes so client/LibZone
    -- localization changes are reflected immediately without reopening TPM.
    self.statisticsFocusChoices = { { zoneId = 0, name = self:L("STAT_FOCUS_TAMRIEL") } }
    for _, zone in ipairs(self:GetStatisticsFocusZoneChoices()) do
        self.statisticsFocusChoices[#self.statisticsFocusChoices + 1] = zone
    end
    if self.statisticsFocusDropdown and not self.statisticsFocusDropdown:IsHidden() then
        self:RefreshStatisticsFocusDropdownRows()
    end
end

function TPM:GetStatisticsData(forceRefresh, focusZoneId)
    focusZoneId = Round(tonumber(focusZoneId) or 0)
    if focusZoneId > 0 then
        if not forceRefresh and self.statisticsFocusCache and self.statisticsFocusCacheZoneId == focusZoneId then
            return self.statisticsFocusCache
        end
    elseif not forceRefresh and self.statisticsCache then
        return self.statisticsCache
    end

    local stats =
    {
        percent = 0,
        completedObjectives = 0,
        totalObjectives = 0,
        remainingObjectives = 0,
        totalZones = 0,
        completedZones = 0,
        incompleteZones = 0,
        under50Zones = 0,
        untouchedZones = 0,
        zones = {},
        categories = {},
        focusZoneId = focusZoneId,
        isZoneFocus = focusZoneId > 0,
    }

    local categoryTotals = {}
    for _, completionType in ipairs(COMPLETION_TYPES) do
        categoryTotals[completionType] = { completed = 0, total = 0 }
    end

    local categoryRatioTotal = 0
    local categoryCount = 0
    local progressZoneIds = self:GetAllProgressZoneIds()
    if focusZoneId > 0 then
        -- Strict one-zone data source: page 1 categories, summary cards and the
        -- lower zone table are all built from this single Zone Story only.
        progressZoneIds = { [focusZoneId] = true }
        stats.focusName = SafeZoneName(focusZoneId)
    end
    for zoneId in pairs(progressZoneIds) do
        local breakdown, completed, total, percent = self:GetCompletionBreakdown(zoneId)
        if total > 0 then
            stats.totalZones = stats.totalZones + 1
            stats.completedObjectives = stats.completedObjectives + completed
            stats.totalObjectives = stats.totalObjectives + total

            if percent >= 100 then
                stats.completedZones = stats.completedZones + 1
            else
                stats.incompleteZones = stats.incompleteZones + 1
            end
            if percent < 50 then
                stats.under50Zones = stats.under50Zones + 1
            end
            if completed <= 0 then
                stats.untouchedZones = stats.untouchedZones + 1
            end

            local mapId = 0
            if type(GetMapIdByZoneId) == "function" then
                mapId = GetMapIdByZoneId(zoneId) or 0
            end

            stats.zones[#stats.zones + 1] =
            {
                zoneId = zoneId,
                mapId = mapId,
                name = SafeZoneName(zoneId),
                completed = completed,
                total = total,
                remaining = math.max(0, total - completed),
                percent = percent,
            }

            for _, row in ipairs(breakdown) do
                local aggregate = categoryTotals[row.completionType]
                if aggregate then
                    aggregate.completed = aggregate.completed + (row.completed or 0)
                    aggregate.total = aggregate.total + (row.total or 0)
                end
                if row.total and row.total > 0 then
                    categoryRatioTotal = categoryRatioTotal + ((row.completed or 0) / row.total)
                    categoryCount = categoryCount + 1
                end
            end
        end
    end

    stats.remainingObjectives = math.max(0, stats.totalObjectives - stats.completedObjectives)
    local mode = self.saved and self.saved.calculationMode or "objectives"
    if mode == "categories" then
        if categoryCount > 0 then
            stats.percent = Round((categoryRatioTotal / categoryCount) * 100)
        end
    elseif stats.totalObjectives > 0 then
        stats.percent = Round((stats.completedObjectives / stats.totalObjectives) * 100)
    end
    if stats.totalObjectives > 0 and stats.completedObjectives < stats.totalObjectives and stats.percent >= 100 then
        stats.percent = 99
    end
    stats.percent = Clamp(stats.percent, 0, 100)

    for _, completionType in ipairs(COMPLETION_TYPES) do
        local aggregate = categoryTotals[completionType]
        if aggregate and aggregate.total > 0 then
            local percent = Round((aggregate.completed / aggregate.total) * 100)
            if aggregate.completed < aggregate.total and percent >= 100 then percent = 99 end
            stats.categories[#stats.categories + 1] =
            {
                completionType = completionType,
                name = self:GetCompletionTypeName(completionType),
                completed = aggregate.completed,
                total = aggregate.total,
                remaining = math.max(0, aggregate.total - aggregate.completed),
                percent = Clamp(percent, 0, 100),
            }
        end
    end

    -- Side quests are statistics-only. They do not change the native Zone Guide
    -- completion percentage shown on the Tamriel map. Keep them directly under
    -- Main Quests in the journal because both are quest progress categories.
    local sideQuestStats = self:GetSideQuestStatistics(progressZoneIds)
    if sideQuestStats then
        local insertAt = 1
        for index, category in ipairs(stats.categories) do
            if category.completionType == ZONE_COMPLETION_TYPE_PRIORITY_QUESTS then
                insertAt = index + 1
                break
            end
        end
        table.insert(stats.categories, insertAt, sideQuestStats)
    end

    -- Crown Store quest starters are a journal-only statistic. They never alter
    -- ESO's native zone-completion percentage. Keep them next to Main/Side Quests.
    -- Crown Store quest starters are account-wide and cannot be attributed
    -- reliably to one Zone Story, so hide that one journal-only row while a
    -- specific-zone focus is active. Native and zone-attributable rows remain.
    if focusZoneId <= 0 then
        local crownQuestStats = self:GetCrownQuestStatistics()
        if crownQuestStats then
            local insertAt = 1
            for index, category in ipairs(stats.categories) do
                if category.completionType == SIDE_QUEST_CATEGORY_KEY then
                    insertAt = index + 1
                    break
                elseif category.completionType == ZONE_COMPLETION_TYPE_PRIORITY_QUESTS then
                    insertAt = index + 1
                end
            end
            table.insert(stats.categories, insertAt, crownQuestStats)
        end
    else
        -- 2.6.19: Zone Focus also surfaces the Update 49 special mount sold by
        -- that zone's Stablemaster. This row is informational only and does not
        -- count toward Tamriel/Zone Guide completion.
        local mount = ZONE_STABLEMASTER_MOUNTS[focusZoneId]
        if mount then
            stats.categories[#stats.categories + 1] =
            {
                completionType = ZONE_STABLE_MOUNT_CATEGORY_KEY,
                name = self:L("STAT_ZONE_STABLE_MOUNT"),
                completed = 0,
                total = 0,
                remaining = 0,
                percent = 0,
                informational = true,
                countText = self:L("STAT_ZONE_STABLE_MOUNT_AVAILABLE", 4),
                tooltipText = self:L("STAT_ZONE_STABLE_MOUNT_TT", mount.name, ZO_CommaDelimitNumber and ZO_CommaDelimitNumber(mount.price) or tostring(mount.price)),
            }
        end
    end

    -- Zone list remains alphabetical. Completion-category ordering is now
    -- controlled independently by the 2.6.8 sort bar (All / A-Z / 0->100 / 100->0).
    table.sort(stats.zones, function(a, b)
        local an = GetZoneNameSortKey(a.name)
        local bn = GetZoneNameSortKey(b.name)
        if an == bn then return a.zoneId < b.zoneId end
        return an < bn
    end)

    if focusZoneId > 0 then
        self.statisticsFocusCache = stats
        self.statisticsFocusCacheZoneId = focusZoneId
    else
        self.statisticsCache = stats
    end
    return stats
end

function TPM:SetStatisticsBarPercent(fill, width, percent)
    if not fill then return end
    width = math.max(1, tonumber(width) or 1)
    percent = Clamp(tonumber(percent) or 0, 0, 100)
    fill:SetWidth(math.max(1, width * (percent / 100)))
    local r, g, b = self:GetStatisticsProgressColor(percent)
    fill:SetCenterColor(r, g, b, 0.82)
end

function TPM:CreateStatisticsSummaryCard(parent, name, x, width, iconTexture)
    local card = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    card:SetDimensions(width, 74)
    card:SetAnchor(TOPLEFT, parent, TOPLEFT, x, 116)
    card:SetCenterColor(0.020, 0.019, 0.016, 0.98)
    card:SetEdgeColor(0.56, 0.43, 0.16, 0.92)
    card:SetEdgeTexture(nil, 1, 1, 1)
    card:SetMouseEnabled(false)

    local topGlow = WINDOW_MANAGER:CreateControl(nil, card, CT_BACKDROP)
    topGlow:SetDimensions(width - 2, 2)
    topGlow:SetAnchor(TOPLEFT, card, TOPLEFT, 1, 1)
    topGlow:SetCenterColor(0.88, 0.67, 0.18, 0.55)
    topGlow:SetEdgeColor(0, 0, 0, 0)

    local compact = width <= 150
    local iconSize = compact and 30 or 38
    local iconX = compact and 7 or 10
    local textX = compact and 39 or 52
    local textWidth = width - textX - 5

    local icon = WINDOW_MANAGER:CreateControl(nil, card, CT_TEXTURE)
    icon:SetDimensions(iconSize, iconSize)
    icon:SetAnchor(LEFT, card, LEFT, iconX, 0)
    icon:SetTexture(iconTexture or "TamrielProgressMap/art/stat_objectives.dds")
    icon:SetColor(0.94, 0.76, 0.26, 0.96)

    local title = WINDOW_MANAGER:CreateControl(name .. "Title", card, CT_LABEL)
    title:SetDimensions(textWidth, compact and 34 or 32)
    title:SetAnchor(TOPLEFT, card, TOPLEFT, textX, compact and 4 or 7)
    title:SetFont(compact and "$(MEDIUM_FONT)|12" or "$(MEDIUM_FONT)|14")
    title:SetColor(0.79, 0.74, 0.64, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local value = WINDOW_MANAGER:CreateControl(name .. "Value", card, CT_LABEL)
    value:SetDimensions(textWidth, 28)
    value:SetAnchor(TOPLEFT, card, TOPLEFT, textX, compact and 39 or 39)
    value:SetFont(compact and "$(BOLD_FONT)|18" or "$(BOLD_FONT)|21")
    value:SetColor(0.98, 0.82, 0.28, 1)
    value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    value:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    return { control = card, title = title, value = value, icon = icon, topGlow = topGlow }
end

function TPM:CreateProgressPlaytimeCard(parent, name, x, width)
    local card = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    card:SetDimensions(width, 74)
    card:SetAnchor(TOPLEFT, parent, TOPLEFT, x, 116)
    card:SetCenterColor(0.020, 0.019, 0.016, 0.98)
    card:SetEdgeColor(0.48, 0.66, 0.22, 0.92)
    card:SetEdgeTexture(nil, 1, 1, 1)
    card:SetMouseEnabled(false)

    local topGlow = WINDOW_MANAGER:CreateControl(nil, card, CT_BACKDROP)
    topGlow:SetDimensions(width - 2, 2)
    topGlow:SetAnchor(TOPLEFT, card, TOPLEFT, 1, 1)
    topGlow:SetCenterColor(0.64, 0.88, 0.28, 0.58)
    topGlow:SetEdgeColor(0, 0, 0, 0)

    local icon = WINDOW_MANAGER:CreateControl(nil, card, CT_TEXTURE)
    icon:SetDimensions(30, 30)
    icon:SetAnchor(LEFT, card, LEFT, 7, -4)
    icon:SetTexture("TamrielProgressMap/art/tamriel_wreath.dds")
    icon:SetColor(0.68, 0.92, 0.34, 0.96)

    local title = WINDOW_MANAGER:CreateControl(name .. "Title", card, CT_LABEL)
    title:SetDimensions(width - 44, 20)
    title:SetAnchor(TOPLEFT, card, TOPLEFT, 40, 4)
    title:SetFont("$(BOLD_FONT)|12")
    title:SetColor(0.82, 0.78, 0.68, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local value = WINDOW_MANAGER:CreateControl(name .. "Value", card, CT_LABEL)
    value:SetDimensions(width - 44, 25)
    value:SetAnchor(TOPLEFT, card, TOPLEFT, 40, 24)
    value:SetFont("$(ANTIQUE_FONT)|19")
    value:SetColor(0.68, 0.94, 0.28, 1)
    value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    value:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local detail = WINDOW_MANAGER:CreateControl(name .. "Detail", card, CT_LABEL)
    detail:SetDimensions(width - 12, 18)
    detail:SetAnchor(BOTTOM, card, BOTTOM, 0, -5)
    detail:SetFont("$(MEDIUM_FONT)|11")
    detail:SetColor(0.74, 0.70, 0.60, 1)
    detail:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    detail:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    detail:SetHidden(false)

    return { control = card, title = title, value = value, detail = detail, icon = icon, topGlow = topGlow }
end

function TPM:CreateStatisticsCategoryRow(parent, index, controlPrefix)
    local column = index <= 8 and 1 or 2
    local rowIndex = column == 1 and index or (index - 8)
    local x = column == 1 and 30 or 518
    local y = 234 + ((rowIndex - 1) * 20)

    local prefix = controlPrefix or "StatsCategory"
    local row = WINDOW_MANAGER:CreateControl(ADDON_NAME .. prefix .. tostring(index), parent, CT_CONTROL)
    row:SetDimensions(442, 20)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    row:SetMouseEnabled(false)

    local rowBg = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
    rowBg:SetAnchorFill(row)
    rowBg:SetCenterColor(0.035, 0.031, 0.024, rowIndex % 2 == 0 and 0.34 or 0.18)
    rowBg:SetEdgeColor(0.28, 0.23, 0.12, 0.20)
    rowBg:SetEdgeTexture(nil, 1, 1, 1)
    rowBg:SetMouseEnabled(false)

    local icon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    icon:SetDimensions(18, 18)
    icon:SetAnchor(LEFT, row, LEFT, 5, 0)
    icon:SetTexture("TamrielProgressMap/art/cat_quests.dds")
    icon:SetColor(0.86, 0.70, 0.28, 0.82)

    local label = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    label:SetDimensions(166, 20)
    label:SetAnchor(LEFT, row, LEFT, 29, 0)
    label:SetFont("$(MEDIUM_FONT)|16")
    label:SetColor(0.92, 0.89, 0.81, 1)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local count = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    count:SetDimensions(92, 20)
    count:SetAnchor(LEFT, row, LEFT, 188, 0)
    count:SetFont("$(MEDIUM_FONT)|15")
    count:SetColor(0.72, 0.68, 0.58, 1)
    count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    count:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local bar = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
    bar:SetDimensions(98, 8)
    bar:SetAnchor(LEFT, row, LEFT, 292, 0)
    bar:SetCenterColor(0.018, 0.016, 0.013, 0.92)
    bar:SetEdgeColor(0.38, 0.30, 0.13, 0.72)
    bar:SetEdgeTexture(nil, 1, 1, 1)

    local fill = WINDOW_MANAGER:CreateControl(nil, bar, CT_BACKDROP)
    fill:SetDimensions(1, 6)
    fill:SetAnchor(LEFT, bar, LEFT, 1, 0)
    fill:SetCenterColor(0.78, 0.59, 0.16, 0.96)
    fill:SetEdgeColor(0, 0, 0, 0)

    local percent = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    percent:SetDimensions(42, 20)
    percent:SetAnchor(RIGHT, row, RIGHT, -3, 0)
    percent:SetFont("$(BOLD_FONT)|15")
    percent:SetColor(0.90, 0.80, 0.48, 1)
    percent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    percent:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    -- 2.6.25: The old information button is now a real settings gear. One
    -- click enters the HUD editor; clicking the gear again saves position and
    -- size. No help popup is shown here anymore.
    local gearButton = WINDOW_MANAGER:CreateControl(nil, row, CT_BUTTON)
    gearButton:SetDimensions(18, 18)
    gearButton:SetAnchor(LEFT, row, RIGHT, 4, 0)
    gearButton:SetMouseEnabled(true)
    gearButton:SetHidden(true)
    local gearIcon = WINDOW_MANAGER:CreateControl(nil, gearButton, CT_TEXTURE)
    gearIcon:SetDimensions(16, 16)
    gearIcon:SetAnchor(CENTER, gearButton, CENTER, 0, 0)
    gearIcon:SetTexture("TamrielProgressMap/art/settings_gear.dds")
    gearIcon:SetColor(0.88, 0.82, 0.64, 0.92)
    gearIcon:SetMouseEnabled(false)
    gearButton.TPMIcon = gearIcon

    return { control = row, label = label, count = count, bar = bar, fill = fill, percent = percent, icon = icon, bg = rowBg, gearButton = gearButton }
end

-- Returns the live account collection count reported by ESO for one
-- CollectibleCategoryType. The category-type API is intentionally used here:
-- GetCollectibleCategoryInfo expects a Collections-book top-level index, not a
-- CollectibleCategoryType. Using ESO's dedicated type counters avoids both that
-- mismatch and an expensive scan across all collectible IDs.
function TPM:GetCollectionStatisticData(definition)
    if type(definition) ~= "table" then return nil end

    local categoryType = _G[definition.typeGlobal]
    local data =
    {
        name = self:L(definition.labelKey),
        owned = 0,
        total = 0,
        percent = 0,
        icon = nil,
        available = false,
    }

    if type(categoryType) ~= "number"
        or type(GetTotalCollectiblesByCategoryType) ~= "function"
        or type(GetTotalUnlockedCollectiblesByCategoryType) ~= "function" then
        return data
    end

    local total = tonumber(GetTotalCollectiblesByCategoryType(categoryType)) or 0
    local owned = tonumber(GetTotalUnlockedCollectiblesByCategoryType(categoryType)) or 0
    if total < 0 then total = 0 end
    owned = Clamp(owned, 0, total)

    -- Use real ESO collectible art for the collection rows. Some category-icon
    -- lookups return ESO's generic question-mark placeholder for categories such
    -- as markings, hair or fragments. Prefer an actual collectible icon first;
    -- only fall back to the Collections-book category icon when needed.
    local function IsUsableCollectionIcon(texture)
        if type(texture) ~= "string" or texture == "" then return false end
        local lower = zo_strlower(texture)
        if lower == zo_strlower(tostring(ZO_NO_TEXTURE_FILE or "")) then return false end
        if string.find(lower, "question", 1, true)
            or string.find(lower, "unknown", 1, true)
            or string.find(lower, "missing", 1, true)
            or string.find(lower, "placeholder", 1, true) then
            return false
        end
        return true
    end

    if total > 0 and type(GetCollectibleIdFromType) == "function" then
        local collectibleId = nil
        -- A few collection types can have an unusable first slot. Look through a
        -- handful of entries and keep the first one with real artwork.
        local probeCount = math.min(total, 12)
        for collectibleIndex = 1, probeCount do
            local candidateId = GetCollectibleIdFromType(categoryType, collectibleIndex)
            if candidateId and candidateId > 0 then
                collectibleId = candidateId
                if type(GetCollectibleIcon) == "function" then
                    local collectibleIcon = GetCollectibleIcon(candidateId)
                    if IsUsableCollectionIcon(collectibleIcon) then
                        data.icon = collectibleIcon
                        break
                    end
                end
            end
        end

        if collectibleId and not data.icon
            and type(GetCategoryInfoFromCollectibleId) == "function"
            and type(GetCollectibleCategoryKeyboardIcons) == "function" then
            local topLevelIndex, categoryIndex = GetCategoryInfoFromCollectibleId(collectibleId)
            if topLevelIndex then
                local normalIcon = GetCollectibleCategoryKeyboardIcons(topLevelIndex, categoryIndex)
                if IsUsableCollectionIcon(normalIcon) then
                    data.icon = normalIcon
                end
            end
        end
    end

    data.total = total
    data.owned = owned
    data.percent = total > 0 and Round((owned / total) * 100) or 0
    data.available = true
    return data
end

-- 2.6.14: Achievement category names returned by ESO follow the GAME client
-- language, while TPM intentionally supports its own live DE/EN/RU/FR language
-- switch. Normalize the known top-level category names from all four supported
-- client languages and route them through TPM localization. Unknown/new ESO
-- categories safely fall back to the API name instead of being hidden.
local function TPM_NormalizeAchievementCategoryName(name)
    local value = zo_strlower(tostring(name or ""))
    value = value:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    value = value:gsub("[’'`´]", "")
    value = value:gsub("[%s%-%–%—_/%.,:&]+", "")
    return value
end

local ACHIEVEMENT_CATEGORY_LOCALIZATION_ALIASES = {}
local function TPM_RegisterAchievementCategoryAliases(key, aliases)
    for _, alias in ipairs(aliases or {}) do
        ACHIEVEMENT_CATEGORY_LOCALIZATION_ALIASES[TPM_NormalizeAchievementCategoryName(alias)] = key
    end
end

TPM_RegisterAchievementCategoryAliases("STAT_ACH_CAT_CHARACTER", {
    "Charakter", "Character", "Personnage", "Персонаж",
})
TPM_RegisterAchievementCategoryAliases("STAT_ACH_CAT_RECENT_SEASONS", {
    "Jüngste Seasons", "Jüngste Saisons", "Recent Seasons", "Saisons récentes", "Последние сезоны",
})
TPM_RegisterAchievementCategoryAliases("STAT_ACH_CAT_QUESTS", {
    "Quests", "Quêtes", "Задания", "Квесты",
})
TPM_RegisterAchievementCategoryAliases("STAT_ACH_CAT_CRAFTING", {
    "Handwerk", "Crafting", "Artisanat", "Ремесло",
})
TPM_RegisterAchievementCategoryAliases("STAT_ACH_CAT_EXPLORATION", {
    "Erkunden", "Exploration", "Исследование",
})
TPM_RegisterAchievementCategoryAliases("STAT_ACH_CAT_PVP", {
    "Spieler gegen Spieler", "Player vs Player", "Player versus Player", "Joueur contre joueur", "Игрок против игрока",
})
TPM_RegisterAchievementCategoryAliases("STAT_ACH_CAT_DUNGEONS", {
    "Verliese", "Dungeons", "Donjons", "Подземелья",
})
TPM_RegisterAchievementCategoryAliases("STAT_ACH_CAT_HOUSING", {
    "Wohnen", "Housing", "Logement", "Жильё", "Жилье",
})
TPM_RegisterAchievementCategoryAliases("STAT_ACH_CAT_FESTIVALS", {
    "Feste und Feiern", "Festivals and Celebrations", "Festivals & Events", "Events", "Fêtes et événements", "Fêtes et célébrations", "Праздники и события", "Праздники",
})
TPM_RegisterAchievementCategoryAliases("STAT_ACH_CAT_ARENAS", {
    "Arenen", "Arenas", "Arènes", "Арены",
})
TPM_RegisterAchievementCategoryAliases("STAT_ACH_CAT_DLC_DUNGEONS", {
    "DLC-Verliese", "DLC Dungeons", "Donjons de DLC", "DLC-подземелья", "Подземелья DLC",
})
TPM_RegisterAchievementCategoryAliases("STAT_ACH_CAT_ENDLESS_ARCHIVE", {
    "Endloses Archiv", "Endless Archive", "Archives infinies", "Бесконечный архив",
})
TPM_RegisterAchievementCategoryAliases("STAT_ACH_CAT_NIGHT_MARKET", {
    "Nachtmarkt", "Night Market", "Marché nocturne", "Ночной рынок",
})
TPM_RegisterAchievementCategoryAliases("STAT_ACH_CAT_TRIALS", {
    "Prüfungen", "Trials", "Épreuves", "Испытания",
})
TPM_RegisterAchievementCategoryAliases("STAT_ACHIEVEMENT_OTHER", {
    "Weitere Errungenschaften", "Other Achievements", "Autres succès", "Другие достижения",
})

function TPM:GetLocalizedAchievementCategoryName(apiName)
    local key = ACHIEVEMENT_CATEGORY_LOCALIZATION_ALIASES[TPM_NormalizeAchievementCategoryName(apiName)]
    if key then return self:L(key) end
    return zo_strformat("<<C:1>>", tostring(apiName or ""))
end

-- 2.6.20: Conservative zone-focused achievement summary. ESO does not expose
-- one universal "all achievements for zoneId" API, so we do not pretend it does.
-- Instead we use ESO's own achievement hierarchy plus the client-localized zone
-- name: achievements in a matching subcategory, or whose own name/description
-- explicitly references the zone, are aggregated into one safe zone row.
local function TPM_NormalizeZoneAchievementText(value)
    local text = zo_strlower(tostring(value or ""))
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("[’'`´]", "")
    text = text:gsub("[%s%-%–%—_/%.,:&]+", "")
    return text
end

function TPM:GetZoneAchievementSummary(zoneId)
    zoneId = Round(tonumber(zoneId) or 0)
    if zoneId <= 0 then return nil end
    self.zoneAchievementSummaryCache = self.zoneAchievementSummaryCache or {}
    if self.zoneAchievementSummaryCache[zoneId] then
        return self.zoneAchievementSummaryCache[zoneId]
    end
    if type(GetNumAchievementCategories) ~= "function"
        or type(GetAchievementCategoryInfo) ~= "function"
        or type(GetAchievementSubCategoryInfo) ~= "function"
        or type(GetAchievementId) ~= "function"
        or type(GetAchievementInfo) ~= "function" then
        return nil
    end

    local needles = {}
    local function AddNeedle(name)
        local key = TPM_NormalizeZoneAchievementText(name)
        if key ~= "" then needles[key] = true end
    end
    AddNeedle(SafeZoneName(zoneId))
    if type(GetZoneNameById) == "function" then AddNeedle(GetZoneNameById(zoneId)) end

    local function TextMatches(value)
        local haystack = TPM_NormalizeZoneAchievementText(value)
        if haystack == "" then return false end
        for needle in pairs(needles) do
            if #needle >= 4 and string.find(haystack, needle, 1, true) then return true end
        end
        return false
    end

    local seen = {}
    local earnedPoints, totalPoints, matchedCount, completedCount = 0, 0, 0, 0
    local function AddAchievement(achievementId, forceMatch)
        achievementId = tonumber(achievementId) or 0
        if achievementId <= 0 or seen[achievementId] then return end
        local name, description, points, icon, completed = GetAchievementInfo(achievementId)
        if not forceMatch and not TextMatches(name) and not TextMatches(description) then return end
        seen[achievementId] = true
        points = math.max(0, tonumber(points) or 0)
        totalPoints = totalPoints + points
        matchedCount = matchedCount + 1
        if completed == true then
            earnedPoints = earnedPoints + points
            completedCount = completedCount + 1
        end
    end

    local numCategories = tonumber(GetNumAchievementCategories()) or 0
    for topIndex = 1, numCategories do
        local _, numSubCategories, numTopAchievements = GetAchievementCategoryInfo(topIndex)
        numSubCategories = tonumber(numSubCategories) or 0
        numTopAchievements = tonumber(numTopAchievements) or 0
        for achievementIndex = 1, numTopAchievements do
            AddAchievement(GetAchievementId(topIndex, nil, achievementIndex), false)
        end
        for subIndex = 1, numSubCategories do
            local subName, numAchievements = GetAchievementSubCategoryInfo(topIndex, subIndex)
            local forceSubcategory = TextMatches(subName)
            numAchievements = tonumber(numAchievements) or 0
            for achievementIndex = 1, numAchievements do
                AddAchievement(GetAchievementId(topIndex, subIndex, achievementIndex), forceSubcategory)
            end
        end
    end

    local percent = totalPoints > 0 and Clamp(Round((earnedPoints / totalPoints) * 100), 0, 100) or 0
    local result =
    {
        name = self:L("STAT_ZONE_ACHIEVEMENTS"),
        earned = earnedPoints,
        total = totalPoints,
        percent = percent,
        icon = "TamrielProgressMap/art/stat_complete.dds",
        isTotal = true,
        tooltipText = self:L("STAT_ZONE_ACHIEVEMENTS_TT", completedCount, matchedCount),
    }
    self.zoneAchievementSummaryCache[zoneId] = result
    return result
end

-- 2.6.0: Achievement completion page. ESO exposes earned/total points per
-- top-level achievement category, so TPM can stay update-safe without keeping
-- a hard-coded achievement-id database. These values are informational only and
-- NEVER affect the normal Tamriel completion percentage.
function TPM:GetAchievementStatisticsData()
    local rows = {}
    if type(GetNumAchievementCategories) ~= "function"
        or type(GetAchievementCategoryInfo) ~= "function" then
        return rows
    end

    local categories = {}
    local summedEarned, summedTotal = 0, 0
    local numCategories = tonumber(GetNumAchievementCategories()) or 0

    for categoryIndex = 1, numCategories do
        local name, _, _, earnedPoints, totalPoints = GetAchievementCategoryInfo(categoryIndex)
        earnedPoints = math.max(0, tonumber(earnedPoints) or 0)
        totalPoints = math.max(0, tonumber(totalPoints) or 0)
        if totalPoints > 0 and type(name) == "string" and name ~= "" then
            local icon = nil
            if type(GetAchievementCategoryKeyboardIcons) == "function" then
                icon = select(1, GetAchievementCategoryKeyboardIcons(categoryIndex))
            end
            categories[#categories + 1] =
            {
                name = self:GetLocalizedAchievementCategoryName(name),
                earned = math.min(earnedPoints, totalPoints),
                total = totalPoints,
                percent = Clamp(Round((earnedPoints / totalPoints) * 100), 0, 100),
                icon = icon,
            }
            summedEarned = summedEarned + math.min(earnedPoints, totalPoints)
            summedTotal = summedTotal + totalPoints
        end
    end

    local totalEarned = type(GetEarnedAchievementPoints) == "function" and tonumber(GetEarnedAchievementPoints()) or summedEarned
    local totalPoints = type(GetTotalAchievementPoints) == "function" and tonumber(GetTotalAchievementPoints()) or summedTotal
    totalEarned = math.max(0, totalEarned or 0)
    totalPoints = math.max(0, totalPoints or 0)
    if totalPoints > 0 then totalEarned = math.min(totalEarned, totalPoints) end

    rows[#rows + 1] =
    {
        name = self:L("STAT_ACHIEVEMENT_TOTAL"),
        earned = totalEarned,
        total = totalPoints,
        percent = totalPoints > 0 and Clamp(Round((totalEarned / totalPoints) * 100), 0, 100) or 0,
        icon = "TamrielProgressMap/art/stat_complete.dds",
        isTotal = true,
    }

    -- The shared category grid has 16 slots. Reserve one for the account-wide
    -- total. If ESO ever exposes more than 15 top-level categories, combine the
    -- overflow instead of letting rows spill outside the panel.
    local maxCategoryRows = 15
    if #categories <= maxCategoryRows then
        for _, data in ipairs(categories) do rows[#rows + 1] = data end
    else
        for index = 1, maxCategoryRows - 1 do
            rows[#rows + 1] = categories[index]
        end
        local otherEarned, otherTotal = 0, 0
        for index = maxCategoryRows, #categories do
            otherEarned = otherEarned + categories[index].earned
            otherTotal = otherTotal + categories[index].total
        end
        rows[#rows + 1] =
        {
            name = self:L("STAT_ACHIEVEMENT_OTHER"),
            earned = otherEarned,
            total = otherTotal,
            percent = otherTotal > 0 and Clamp(Round((otherEarned / otherTotal) * 100), 0, 100) or 0,
            icon = "TamrielProgressMap/art/stat_objectives.dds",
        }
    end

    return rows
end

function TPM:SetStatisticsCompletionPage(page)
    self:HideStatisticsHoverTooltips()
    self:HideStatisticsFocusDropdown()
    page = Clamp(Round(tonumber(page) or 1), 1, 3)
    if self.saved then self.saved.statisticsCompletionPage = page end
    self.statisticsCompletionPage = page
    if self.statisticsWindow and not self.statisticsWindow:IsHidden() then
        self:RefreshStatisticsWindow()
    end
end

function TPM:GetStatisticsCompletionPage()
    local page = self.saved and tonumber(self.saved.statisticsCompletionPage) or tonumber(self.statisticsCompletionPage) or 1
    return Clamp(Round(page), 1, 3)
end

-- 2.6.8: The three completion sub-pages share one compact sort control.
-- "all" preserves each page's natural/original order. A-Z always sorts the
-- names currently displayed to the player, so TPM-localized category names
-- automatically follow the selected addon language.
function TPM:GetStatisticsCategorySortMode()
    local mode = self.saved and self.saved.statisticsCategorySortMode or "all"
    if mode ~= "all" and mode ~= "name" and mode ~= "asc" and mode ~= "desc" then
        mode = "all"
    end
    return mode
end

function TPM:SetStatisticsCategorySortMode(mode)
    if mode ~= "all" and mode ~= "name" and mode ~= "asc" and mode ~= "desc" then return false end
    if self.saved then self.saved.statisticsCategorySortMode = mode end
    self:HideStatisticsHoverTooltips()
    if self.statisticsWindow and not self.statisticsWindow:IsHidden() then
        self:RefreshStatisticsWindow()
    end
    return true
end

local function TPM_CopyArray(rows)
    local copy = {}
    for index, row in ipairs(rows or {}) do copy[index] = row end
    return copy
end

function TPM:SortStatisticsCategoryData(rows, keepTotalFirst)
    local mode = self:GetStatisticsCategorySortMode()
    local copy = TPM_CopyArray(rows)
    if mode == "all" or #copy <= 1 then return copy end

    local pinnedTotal = nil
    if keepTotalFirst then
        for index, row in ipairs(copy) do
            if row and row.isTotal then
                pinnedTotal = row
                table.remove(copy, index)
                break
            end
        end
    end

    -- Informational rows (for example the zone Stablemaster mount) are not
    -- completion percentages and therefore must not jump to the top in 0->100
    -- sorting. Keep them at the bottom regardless of the selected sort mode.
    local informationalRows = {}
    for index = #copy, 1, -1 do
        local row = copy[index]
        if row and row.informational then
            table.insert(informationalRows, 1, row)
            table.remove(copy, index)
        end
    end

    local function NameKey(row)
        return GetZoneNameSortKey(tostring(row and row.name or ""))
    end
    table.sort(copy, function(a, b)
        if mode == "name" then
            local an, bn = NameKey(a), NameKey(b)
            if an == bn then return tostring(a.name or "") < tostring(b.name or "") end
            return an < bn
        end

        local ap = Clamp(tonumber(a and a.percent) or 0, 0, 100)
        local bp = Clamp(tonumber(b and b.percent) or 0, 0, 100)
        if ap == bp then
            local an, bn = NameKey(a), NameKey(b)
            if an == bn then return tostring(a.name or "") < tostring(b.name or "") end
            return an < bn
        end
        if mode == "desc" then return ap > bp end
        return ap < bp
    end)

    if pinnedTotal then table.insert(copy, 1, pinnedTotal) end
    for _, row in ipairs(informationalRows) do copy[#copy + 1] = row end
    return copy
end

function TPM:RefreshStatisticsCategorySortControls()
    local mode = self:GetStatisticsCategorySortMode()
    local buttons = self.statisticsCategorySortButtons or {}
    local labels =
    {
        all = self:L("FILTER_ALL"),
        name = self:L("STAT_SORT_ALPHABETICAL"),
        asc = "0→100%",
        desc = "100→0%",
    }
    for key, button in pairs(buttons) do
        if button then
            button:SetText(labels[key] or key)
            local selected = key == mode
            button:SetNormalFontColor(selected and 1.00 or 0.76, selected and 0.84 or 0.72, selected and 0.26 or 0.58, 1)
            if button.TPMBackdrop then
                button.TPMBackdrop:SetCenterColor(selected and 0.16 or 0.035, selected and 0.12 or 0.031, selected and 0.025 or 0.024, selected and 0.96 or 0.72)
                button.TPMBackdrop:SetEdgeColor(selected and 0.78 or 0.30, selected and 0.60 or 0.24, selected and 0.12 or 0.12, selected and 0.90 or 0.45)
            end
        end
    end
end

-- 2.6.1: All hover panels that belong to the Tamriel Statistics journal use
-- the same screen position and draw above the journal. This prevents ESO's
-- shared InformationTooltip from being hidden behind the statistics window.
function TPM:AnchorStatisticsHoverTooltip(tip, yOffset)
    if not tip then return end
    tip:ClearAnchors()
    if self.statisticsWindow and not self.statisticsWindow:IsHidden() then
        tip:SetAnchor(TOPLEFT, self.statisticsWindow, TOPRIGHT, 10, tonumber(yOffset) or 58)
    elseif GuiRoot then
        tip:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -18, 80)
    end
    if tip.BringWindowToTop then tip:BringWindowToTop() end
    tip:SetHidden(false)
end

function TPM:HideStatisticsHoverTooltips()
    local tooltips =
    {
        self.statisticsHoverTooltip,
        self.statisticsAchievementTooltip,
        self.statisticsLogHelpTooltip,
    }
    for _, tip in ipairs(tooltips) do
        if tip then
            tip.TPMSourceControl = nil
            tip:SetHidden(true)
        end
    end
    if InformationTooltip then ClearTooltip(InformationTooltip) end
end

-- 2.6.4: Do not rely only on OnMouseExit for statistics hover panels. ESO can
-- skip that callback when small nested controls are clicked or hidden during a
-- refresh. Each hover panel remembers the control that opened it and closes
-- itself as soon as the cursor is no longer above that control.
local function TPM_ArmStatisticsHoverTooltip(tip, sourceControl)
    if not tip then return end
    tip.TPMSourceControl = sourceControl
    if tip.TPMAutoHideInstalled then return end
    tip.TPMAutoHideInstalled = true
    tip:SetHandler("OnUpdate", function(panel)
        if panel:IsHidden() then return end
        if not TPM.statisticsWindow or TPM.statisticsWindow:IsHidden() then
            panel.TPMSourceControl = nil
            panel:SetHidden(true)
            return
        end
        local source = panel.TPMSourceControl
        if source and type(MouseIsOver) == "function" then
            local ok, hovered = pcall(MouseIsOver, source)
            if ok and not hovered then
                panel.TPMSourceControl = nil
                panel:SetHidden(true)
            end
        end
    end)
end

local function TPM_EnsureStatisticsHoverTooltip()
    if TPM.statisticsHoverTooltip then return TPM.statisticsHoverTooltip end
    if not WINDOW_MANAGER or not GuiRoot then return nil end

    local tip = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "StatisticsHoverTooltip")
    tip:SetDimensions(360, 96)
    tip:SetHidden(true)
    tip:SetMouseEnabled(false)
    tip:SetMovable(false)
    if tip.SetClampedToScreen then tip:SetClampedToScreen(true) end
    if tip.SetDrawTier and DT_HIGH then tip:SetDrawTier(DT_HIGH) end
    if tip.SetDrawLayer and DL_OVERLAY then tip:SetDrawLayer(DL_OVERLAY) end
    if tip.SetDrawLevel then tip:SetDrawLevel(13000) end

    local bg = WINDOW_MANAGER:CreateControl(nil, tip, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.035, 0.031, 0.026, 0.985)
    bg:SetEdgeColor(0.92, 0.76, 0.14, 0.96)
    bg:SetEdgeTexture(nil, 1, 1, 1)

    local title = WINDOW_MANAGER:CreateControl(nil, tip, CT_LABEL)
    title:SetAnchor(TOPLEFT, tip, TOPLEFT, 14, 12)
    title:SetAnchor(TOPRIGHT, tip, TOPRIGHT, -14, 12)
    title:SetHeight(28)
    title:SetFont("ZoFontWinH3")
    title:SetColor(0.98, 0.96, 0.90, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local body = WINDOW_MANAGER:CreateControl(nil, tip, CT_LABEL)
    body:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 8)
    body:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, 0, 8)
    body:SetHeight(42)
    body:SetFont("$(MEDIUM_FONT)|13")
    body:SetColor(0.86, 0.84, 0.78, 1)
    body:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    body:SetVerticalAlignment(TEXT_ALIGN_TOP)

    tip.TPMTitle = title
    tip.TPMBody = body
    TPM.statisticsHoverTooltip = tip
    return tip
end

function TPM:ShowStatisticsHoverTooltip(titleText, bodyText, sourceControl)
    local tip = TPM_EnsureStatisticsHoverTooltip()
    if not tip then return end
    self:HideStatisticsHoverTooltips()

    titleText = tostring(titleText or "")
    bodyText = tostring(bodyText or "")

    -- 2.6.24: Longer help text (especially the Skyshard positioning guide)
    -- gets a wider panel instead of being squeezed into the old 360 px box.
    -- Height is still calculated from the rendered text below, so translated
    -- DE/EN/RU/FR instructions can grow naturally without clipping.
    local lineBreaks = 0
    for _ in string.gmatch(bodyText, "\n") do lineBreaks = lineBreaks + 1 end
    local longHelp = #bodyText >= 170 or lineBreaks >= 3
    local tooltipWidth = longHelp and 440 or 360
    if tip.SetWidth then tip:SetWidth(tooltipWidth) end
    if tip.TPMBody.SetHorizontalAlignment then
        tip.TPMBody:SetHorizontalAlignment(longHelp and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER)
    end

    tip.TPMTitle:SetText(titleText)
    tip.TPMBody:SetText(bodyText)
    tip.TPMBody:SetHidden(bodyText == "")

    local titleHeight = 28
    local bodyHeight = 0
    if tip.TPMTitle.GetTextHeight then
        titleHeight = math.max(28, math.ceil(tonumber(tip.TPMTitle:GetTextHeight()) or 28))
    end
    if bodyText ~= "" then
        bodyHeight = 34
        if tip.TPMBody.GetTextHeight then
            bodyHeight = math.max(34, math.ceil(tonumber(tip.TPMBody:GetTextHeight()) or 34))
        end
    end
    tip.TPMTitle:SetHeight(titleHeight)
    tip.TPMBody:SetHeight(math.max(1, bodyHeight))
    tip:SetHeight(12 + titleHeight + (bodyHeight > 0 and (8 + bodyHeight) or 0) + 12)

    TPM_ArmStatisticsHoverTooltip(tip, sourceControl)
    self:AnchorStatisticsHoverTooltip(tip, 58)
end

local function TPM_EnsureAchievementTooltip()
    if TPM.statisticsAchievementTooltip then return TPM.statisticsAchievementTooltip end
    if not WINDOW_MANAGER or not GuiRoot then return nil end

    local tip = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "AchievementTooltip")
    tip:SetDimensions(320, 126)
    tip:SetHidden(true)
    tip:SetMouseEnabled(false)
    tip:SetMovable(false)
    if tip.SetClampedToScreen then tip:SetClampedToScreen(true) end
    if tip.SetDrawTier and DT_HIGH then tip:SetDrawTier(DT_HIGH) end
    if tip.SetDrawLayer and DL_OVERLAY then tip:SetDrawLayer(DL_OVERLAY) end
    -- Statistics itself uses draw level 7200. Keep this panel clearly above it.
    if tip.SetDrawLevel then tip:SetDrawLevel(12000) end

    local bg = WINDOW_MANAGER:CreateControl(nil, tip, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.035, 0.031, 0.026, 0.985)
    bg:SetEdgeColor(0.92, 0.76, 0.14, 0.96)
    bg:SetEdgeTexture(nil, 1, 1, 1)

    local title = WINDOW_MANAGER:CreateControl(nil, tip, CT_LABEL)
    title:SetAnchor(TOPLEFT, tip, TOPLEFT, 14, 12)
    title:SetAnchor(TOPRIGHT, tip, TOPRIGHT, -14, 12)
    title:SetHeight(28)
    title:SetFont("ZoFontWinH3")
    title:SetColor(0.98, 0.96, 0.90, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local points = WINDOW_MANAGER:CreateControl(nil, tip, CT_LABEL)
    points:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 8)
    points:SetAnchor(TOPRIGHT, title, BOTTOMRIGHT, 0, 8)
    points:SetHeight(24)
    points:SetFont("$(MEDIUM_FONT)|16")
    points:SetColor(0.94, 0.92, 0.86, 1)
    points:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    points:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local note = WINDOW_MANAGER:CreateControl(nil, tip, CT_LABEL)
    note:SetAnchor(TOPLEFT, points, BOTTOMLEFT, 0, 8)
    note:SetAnchor(TOPRIGHT, points, BOTTOMRIGHT, 0, 8)
    note:SetHeight(44)
    note:SetFont("$(MEDIUM_FONT)|12")
    note:SetColor(0.78, 0.75, 0.68, 1)
    note:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    note:SetVerticalAlignment(TEXT_ALIGN_TOP)

    tip.TPMTitle = title
    tip.TPMPoints = points
    tip.TPMNote = note
    TPM.statisticsAchievementTooltip = tip
    return tip
end

local function TPM_ShowAchievementTooltip(data, sourceControl)
    if not data or not TPM.statisticsWindow then return end
    local tip = TPM_EnsureAchievementTooltip()
    if not tip then return end
    TPM:HideStatisticsHoverTooltips()

    tip.TPMTitle:SetText(data.name or "")
    tip.TPMPoints:SetText(TPM:L("STAT_ACHIEVEMENT_POINTS_TT", data.earned or 0, data.total or 0))
    tip.TPMNote:SetText(TPM:L("STAT_ACHIEVEMENT_LANGUAGE_NOTE"))

    -- Let long translated category names and notes grow instead of clipping.
    local titleHeight = 28
    local pointsHeight = 24
    local noteHeight = 38
    if tip.TPMTitle.GetTextHeight then
        titleHeight = math.max(28, math.ceil(tonumber(tip.TPMTitle:GetTextHeight()) or 28))
    end
    if tip.TPMPoints.GetTextHeight then
        pointsHeight = math.max(24, math.ceil(tonumber(tip.TPMPoints:GetTextHeight()) or 24))
    end
    if tip.TPMNote.GetTextHeight then
        noteHeight = math.max(34, math.ceil(tonumber(tip.TPMNote:GetTextHeight()) or 38))
    end
    tip.TPMTitle:SetHeight(titleHeight)
    tip.TPMPoints:SetHeight(pointsHeight)
    tip.TPMNote:SetHeight(noteHeight)
    tip:SetHeight(12 + titleHeight + 8 + pointsHeight + 8 + noteHeight + 12)

    -- Always place achievement details beside the journal, aligned near its
    -- upper-right corner rather than attaching them to an individual row.
    TPM_ArmStatisticsHoverTooltip(tip, sourceControl)
    TPM:AnchorStatisticsHoverTooltip(tip, 58)
end

local function TPM_HideAchievementTooltip()
    local tip = TPM.statisticsAchievementTooltip
    if tip then tip:SetHidden(true) end
end

function TPM:RefreshStatisticsCollectionPager()
    local page = self:GetStatisticsCompletionPage()
    self.statisticsCompletionPage = page
    self:RefreshStatisticsCategorySortControls()

    if self.statisticsCategoryPageIndicator then
        self.statisticsCategoryPageIndicator:SetText(string.format("%d / 3", page))
    end
    if self.statisticsCategoryPrev then
        self.statisticsCategoryPrev:SetEnabled(page > 1)
        self.statisticsCategoryPrev:SetAlpha(page > 1 and 1 or 0.32)
    end
    if self.statisticsCategoryNext then
        self.statisticsCategoryNext:SetEnabled(page < 3)
        self.statisticsCategoryNext:SetAlpha(page < 3 and 1 or 0.32)
    end

    -- Hide both optional pages first. Page 1 rows have already been refreshed by
    -- RefreshStatisticsWindow and are only hidden when page 2 or 3 is selected.
    for _, row in ipairs(self.statisticsCollectionRows or {}) do
        row.control:SetHidden(true)
    end
    for _, row in ipairs(self.statisticsAchievementRows or {}) do
        row.control:SetHidden(true)
    end

    if page == 1 then
        if self.statisticsCategoryTitle then
            local focusZoneId = self:GetStatisticsFocusZoneId()
            if focusZoneId > 0 then
                self.statisticsCategoryTitle:SetText(string.format("%s — %s", self:L("STAT_CATEGORIES"), SafeZoneName(focusZoneId)))
            else
                self.statisticsCategoryTitle:SetText(self:L("STAT_CATEGORIES"))
            end
        end
        return
    end

    for _, row in ipairs(self.statisticsCategoryRows or {}) do
        row.control:SetHidden(true)
    end

    if page == 2 then
        local focusZoneId = self:GetStatisticsFocusZoneId()
        if self.statisticsCategoryTitle then
            self.statisticsCategoryTitle:SetText(focusZoneId > 0
                and string.format("%s — %s", self:L("STAT_COLLECTIONS"), SafeZoneName(focusZoneId))
                or self:L("STAT_COLLECTIONS"))
        end
        local collectionData = {}
        if focusZoneId > 0 then
            -- Only show collection data TPM can attribute to this zone without
            -- guessing. At the moment that is the Stablemaster stock introduced
            -- with Update 49. Global account collection totals remain available
            -- immediately by switching focus back to All Tamriel.
            local mount = ZONE_STABLEMASTER_MOUNTS[focusZoneId]
            if mount then
                collectionData[#collectionData + 1] =
                {
                    name = self:L("STAT_ZONE_STABLE_MOUNT"),
                    owned = 0, total = 0, percent = 0, available = true, informational = true,
                    countText = self:L("STAT_ZONE_STABLE_MOUNT_AVAILABLE", 4),
                    tooltipText = self:L("STAT_ZONE_STABLE_MOUNT_TT", mount.name, ZO_CommaDelimitNumber and ZO_CommaDelimitNumber(mount.price) or tostring(mount.price)),
                    icon = "TamrielProgressMap/art/cat_crown.dds",
                }
            end
        else
            for _, definition in ipairs(COLLECTION_STAT_DEFINITIONS) do
                local data = self:GetCollectionStatisticData(definition)
                if data then collectionData[#collectionData + 1] = data end
            end
            collectionData = self:SortStatisticsCategoryData(collectionData, false)
        end
        for index, row in ipairs(self.statisticsCollectionRows or {}) do
            local data = collectionData[index]
            row.control:SetHidden(data == nil)
            row.control:SetMouseEnabled(data ~= nil and data.tooltipText ~= nil)
            if data then
                row.label:SetText(data.name)
                if data.informational then
                    row.count:SetText(data.countText or "—")
                    row.percent:SetText("—")
                    self:SetStatisticsBarPercent(row.fill, 96, 0)
                elseif data.available then
                    row.count:SetText(string.format("%d / %d", data.owned, data.total))
                    row.percent:SetText(string.format("|c%s%d%%|r", self:GetStatisticsPercentTextColor(data.percent), data.percent))
                    self:SetStatisticsBarPercent(row.fill, 96, data.percent)
                else
                    row.count:SetText("—")
                    row.percent:SetText("—")
                    self:SetStatisticsBarPercent(row.fill, 96, 0)
                end
                if row.icon then
                    row.icon:SetTexture(data.icon or "TamrielProgressMap/art/cat_quests.dds")
                    local ir, ig, ib = self:GetStatisticsProgressColor(data.percent)
                    row.icon:SetColor(ir, ig, ib, data.available and 0.96 or 0.45)
                end
                if data.tooltipText then
                    row.control:SetHandler("OnMouseEnter", function(control)
                        TPM:ShowStatisticsHoverTooltip(data.name, data.tooltipText, control)
                    end)
                    row.control:SetHandler("OnMouseExit", function() TPM:HideStatisticsHoverTooltips() end)
                else
                    row.control:SetHandler("OnMouseEnter", nil)
                    row.control:SetHandler("OnMouseExit", nil)
                end
            else
                row.control:SetHandler("OnMouseEnter", nil)
                row.control:SetHandler("OnMouseExit", nil)
            end
        end
        self:RefreshStatisticsCategorySortControls()
        return
    end

    local focusZoneId = self:GetStatisticsFocusZoneId()
    if self.statisticsCategoryTitle then
        self.statisticsCategoryTitle:SetText(focusZoneId > 0
            and string.format("%s — %s", self:L("STAT_ACHIEVEMENTS"), SafeZoneName(focusZoneId))
            or self:L("STAT_ACHIEVEMENTS"))
    end
    local achievementRows
    if focusZoneId > 0 then
        local summary = self:GetZoneAchievementSummary(focusZoneId)
        achievementRows = summary and { summary } or {}
    else
        achievementRows = self:SortStatisticsCategoryData(self:GetAchievementStatisticsData(), true)
    end
    for index, row in ipairs(self.statisticsAchievementRows or {}) do
        local data = achievementRows[index]
        row.control:SetHidden(data == nil)
        row.control:SetMouseEnabled(data ~= nil)
        if data then
            row.label:SetText(data.name)
            row.count:SetText(string.format("%d / %d", data.earned or 0, data.total or 0))
            row.percent:SetText(string.format("|c%s%d%%|r", self:GetStatisticsPercentTextColor(data.percent or 0), data.percent or 0))
            self:SetStatisticsBarPercent(row.fill, 96, data.percent or 0)
            if row.icon then
                row.icon:SetTexture(data.icon or "TamrielProgressMap/art/stat_objectives.dds")
                local ir, ig, ib = self:GetStatisticsProgressColor(data.percent or 0)
                row.icon:SetColor(ir, ig, ib, 0.96)
            end
            row.control:SetHandler("OnMouseEnter", function(control)
                if data.tooltipText then
                    TPM:ShowStatisticsHoverTooltip(data.name, data.tooltipText, control)
                else
                    TPM_ShowAchievementTooltip(data, control)
                end
            end)
            row.control:SetHandler("OnMouseExit", function()
                TPM_HideAchievementTooltip()
                TPM:HideStatisticsHoverTooltips()
            end)
        else
            row.control:SetHandler("OnMouseEnter", nil)
            row.control:SetHandler("OnMouseExit", nil)
        end
    end
end

function TPM:CreateStatisticsZoneRow(parent, index)
    local row = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatsZoneRow" .. tostring(index), parent, CT_CONTROL)
    row:SetDimensions(918, 30)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, (index - 1) * 31)
    row:SetMouseEnabled(true)

    local bg = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
    bg:SetAnchorFill(row)
    bg:SetCenterColor(0.035, 0.031, 0.024, index % 2 == 0 and 0.58 or 0.34)
    bg:SetEdgeColor(0.30, 0.25, 0.14, 0.22)
    bg:SetEdgeTexture(nil, 1, 1, 1)
    bg:SetMouseEnabled(false)
    row.bg = bg
    row.baseR, row.baseG, row.baseB = 0.035, 0.031, 0.024
    row.baseAlpha = index % 2 == 0 and 0.58 or 0.34

    local completeIcon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    completeIcon:SetDimensions(18, 18)
    completeIcon:SetAnchor(LEFT, row, LEFT, 8, 0)
    completeIcon:SetTexture("EsoUI/Art/Buttons/accept_up.dds")
    completeIcon:SetColor(0.78, 0.86, 0.20, 1)
    completeIcon:SetHidden(true)
    row.completeIcon = completeIcon

    local name = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    name:SetDimensions(390, 30)
    name:SetAnchor(LEFT, row, LEFT, 10, 0)
    name:SetFont("$(MEDIUM_FONT)|18")
    name:SetColor(0.94, 0.92, 0.86, 1)
    name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.nameLabel = name

    local percent = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    percent:SetDimensions(62, 30)
    percent:SetAnchor(LEFT, row, LEFT, 398, 0)
    percent:SetFont("$(BOLD_FONT)|18")
    percent:SetColor(0.72, 0.71, 0.67, 1)
    percent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    percent:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.percentLabel = percent

    local progressBg = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
    progressBg:SetDimensions(172, 10)
    progressBg:SetAnchor(LEFT, row, LEFT, 476, 0)
    progressBg:SetCenterColor(0.018, 0.016, 0.013, 0.90)
    progressBg:SetEdgeColor(0.34, 0.27, 0.12, 0.70)
    progressBg:SetEdgeTexture(nil, 1, 1, 1)
    row.progressBg = progressBg

    local progressFill = WINDOW_MANAGER:CreateControl(nil, progressBg, CT_BACKDROP)
    progressFill:SetDimensions(1, 8)
    progressFill:SetAnchor(LEFT, progressBg, LEFT, 1, 0)
    progressFill:SetCenterColor(0.78, 0.59, 0.16, 0.96)
    progressFill:SetEdgeColor(0, 0, 0, 0)
    row.progressFill = progressFill

    local done = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    done:SetDimensions(116, 30)
    done:SetAnchor(LEFT, row, LEFT, 664, 0)
    done:SetFont("$(MEDIUM_FONT)|17")
    done:SetColor(0.80, 0.77, 0.69, 1)
    done:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    done:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.doneLabel = done

    local open = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    open:SetDimensions(88, 30)
    open:SetAnchor(RIGHT, row, RIGHT, -14, 0)
    open:SetFont("$(BOLD_FONT)|17")
    open:SetColor(0.95, 0.75, 0.24, 1)
    open:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    open:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.openLabel = open

    row:SetHandler("OnMouseEnter", function(control)
        if control.bg then control.bg:SetCenterColor(0.16, 0.125, 0.050, 0.86) end
    end)
    row:SetHandler("OnMouseExit", function(control)
        if control.bg then control.bg:SetCenterColor(control.baseR or 0.035, control.baseG or 0.031, control.baseB or 0.024, control.baseAlpha or 0.34) end
    end)
    row:SetHandler("OnMouseWheel", function(_, delta)
        TPM:ScrollStatistics(delta)
    end)
    row:SetHandler("OnMouseUp", function(control, button, upInside)
        if not upInside or button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if control.mapId and control.mapId > 0 then
            TPM:OpenWorldMapFromStatistics(control.mapId)
        end
    end)

    return row
end


function TPM:ApplyThemedValueCard(card, options)
    if not card or not card.control then return end
    options = options or {}
    local control = card.control
    local width, height = control:GetDimensions()
    local accent = options.accentColor or { 0.86, 0.66, 0.18 }
    local center = options.centerColor or { 0.016 + accent[1] * 0.045, 0.015 + accent[2] * 0.034, 0.014 + accent[3] * 0.024, 0.980 }
    local edge = options.edgeColor or { math.min(1, accent[1] + 0.10), math.min(1, accent[2] + 0.10), math.min(1, accent[3] + 0.10), 0.88 }
    local iconSize = options.iconSize or math.min(height - 18, 48)
    local iconOffset = options.iconOffset or 10
    local leftTextX = options.leftTextX or (iconOffset + iconSize + 12)
    local titleWidth = math.max(10, width - leftTextX - 12)
    local valueWidth = math.max(10, width - leftTextX - 12)

    control:SetCenterColor(center[1], center[2], center[3], center[4] or 1)
    control:SetEdgeColor(edge[1], edge[2], edge[3], edge[4] or 1)
    control:SetEdgeTexture(nil, 1, 1, 1)

    if not control.TPMAccent then
        local bar = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
        bar:SetDimensions(4, math.max(10, height))
        bar:SetAnchor(LEFT, control, LEFT, 0, 0)
        bar:SetEdgeColor(0, 0, 0, 0)
        control.TPMAccent = bar
    end
    control.TPMAccent:ClearAnchors()
    control.TPMAccent:SetDimensions(4, math.max(10, height))
    control.TPMAccent:SetAnchor(LEFT, control, LEFT, 0, 0)
    control.TPMAccent:SetCenterColor(accent[1], accent[2], accent[3], 0.82)

    if not control.TPMIconBack then
        local back = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
        back:SetEdgeTexture(nil, 1, 1, 1)
        control.TPMIconBack = back
    end
    control.TPMIconBack:ClearAnchors()
    control.TPMIconBack:SetDimensions(iconSize, iconSize)
    control.TPMIconBack:SetAnchor(LEFT, control, LEFT, iconOffset, 0)
    control.TPMIconBack:SetCenterColor(math.min(1, accent[1] * 0.28 + 0.05), math.min(1, accent[2] * 0.28 + 0.05), math.min(1, accent[3] * 0.28 + 0.05), 0.99)
    control.TPMIconBack:SetEdgeColor(accent[1], accent[2], accent[3], 0.96)

    if not control.TPMIconFrame then
        local frame = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
        frame:SetEdgeTexture(nil, 1, 1, 1)
        frame:SetMouseEnabled(false)
        control.TPMIconFrame = frame
    end
    control.TPMIconFrame:ClearAnchors()
    control.TPMIconFrame:SetDimensions(iconSize + 4, iconSize + 4)
    control.TPMIconFrame:SetAnchor(CENTER, control.TPMIconBack, CENTER, 0, 0)
    control.TPMIconFrame:SetCenterColor(accent[1] * 0.14, accent[2] * 0.14, accent[3] * 0.14, 0.30)
    control.TPMIconFrame:SetEdgeColor(accent[1], accent[2], accent[3], 0.66)

    if not control.TPMInnerTint then
        local tint = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
        tint:SetEdgeTexture(nil, 1, 1, 1)
        tint:SetMouseEnabled(false)
        control.TPMInnerTint = tint
    end
    control.TPMInnerTint:ClearAnchors()
    control.TPMInnerTint:SetAnchor(TOPLEFT, control, TOPLEFT, 1, 1)
    control.TPMInnerTint:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -1, -1)
    control.TPMInnerTint:SetCenterColor(accent[1] * 0.09, accent[2] * 0.075, accent[3] * 0.060, 0.14)
    control.TPMInnerTint:SetEdgeColor(0, 0, 0, 0)

    if not control.TPMTopBand then
        local band = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
        band:SetEdgeColor(0, 0, 0, 0)
        band:SetMouseEnabled(false)
        control.TPMTopBand = band
    end
    control.TPMTopBand:ClearAnchors()
    control.TPMTopBand:SetDimensions(math.max(18, width - 2), 1)
    control.TPMTopBand:SetAnchor(TOPLEFT, control, TOPLEFT, 1, 1)
    control.TPMTopBand:SetCenterColor(accent[1], accent[2], accent[3], 0.58)

    if not control.TPMIcon then
        local icon = WINDOW_MANAGER:CreateControl(nil, control.TPMIconBack, CT_TEXTURE)
        icon:SetAnchor(CENTER, control.TPMIconBack, CENTER, 0, 0)
        control.TPMIcon = icon
    end
    control.TPMIcon:SetDimensions(iconSize - 8, iconSize - 8)

    if not control.TPMMonogram then
        local mono = WINDOW_MANAGER:CreateControl(nil, control.TPMIconBack, CT_LABEL)
        mono:SetAnchor(CENTER, control.TPMIconBack, CENTER, 0, 0)
        mono:SetFont("$(BOLD_FONT)|18")
        mono:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        mono:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        control.TPMMonogram = mono
    end
    control.TPMMonogram:SetColor(accent[1], math.min(1, accent[2] + 0.06), math.min(1, accent[3] + 0.10), 1)
    control.TPMMonogram:SetText(options.monogram or "")

    if options.iconTexture and options.iconTexture ~= "" then
        control.TPMIcon:SetTexture(options.iconTexture)
        control.TPMIcon:SetColor(1, 1, 1, 1)
        if options.currencyIcon == true then
            control.TPMIcon:SetDimensions(iconSize - 4, iconSize - 4)
        else
            control.TPMIcon:SetDimensions(iconSize - 8, iconSize - 8)
        end
        control.TPMIcon:SetHidden(false)
        control.TPMMonogram:SetHidden(true)
    else
        control.TPMIcon:SetHidden(true)
        control.TPMMonogram:SetHidden(false)
    end

    if card.title then
        card.title:ClearAnchors()
        card.title:SetDimensions(titleWidth, 20)
        card.title:SetAnchor(TOPLEFT, control, TOPLEFT, leftTextX, 8)
        card.title:SetFont(options.titleFont or "$(BOLD_FONT)|15")
        card.title:SetColor(math.min(1, accent[1] * 0.55 + 0.40), math.min(1, accent[2] * 0.50 + 0.38), math.min(1, accent[3] * 0.40 + 0.34), 1)
        card.title:SetHorizontalAlignment(options.titleAlign or TEXT_ALIGN_LEFT)
        card.title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end
    if card.value then
        card.value:ClearAnchors()
        card.value:SetDimensions(valueWidth, options.valueHeight or 34)
        card.value:SetAnchor(TOPLEFT, control, TOPLEFT, leftTextX, options.valueY or 31)
        card.value:SetFont(options.valueFont or "$(ANTIQUE_FONT)|29")
        if options.valueColor then
            card.value:SetColor(options.valueColor[1], options.valueColor[2], options.valueColor[3], options.valueColor[4] or 1)
        else
            card.value:SetColor(accent[1], math.min(1, accent[2] + 0.12), math.min(1, accent[3] + 0.18), 1)
        end
        card.value:SetHorizontalAlignment(options.valueAlign or TEXT_ALIGN_LEFT)
        card.value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    end
    if card.detail then
        card.detail:ClearAnchors()
        card.detail:SetDimensions(valueWidth, 16)
        card.detail:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, leftTextX, -7)
        card.detail:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        card.detail:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        card.detail:SetColor(0.88, 0.86, 0.80, 1)
        if options.detailFont then
            card.detail:SetFont(options.detailFont)
        end
    end
end

function TPM:GetEconomyCardVisual(definition)
    if not definition then
        return { texture = nil, accent = { 0.86, 0.66, 0.18 }, mono = "?", isEsoCurrencyIcon = false }
    end

    local currencyType = definition.currencyType
    local iconPath = nil

    -- Prefer ESO's own platform/keyboard currency artwork. This keeps TPM in
    -- sync with the live client instead of shipping look-alike currency icons.
    if type(ZO_Currency_GetPlatformCurrencyIcon) == "function" and type(currencyType) == "number" then
        local ok, path = pcall(ZO_Currency_GetPlatformCurrencyIcon, currencyType)
        if ok and type(path) == "string" and path ~= "" then
            iconPath = path
        end
    end
    if not iconPath and type(GetCurrencyKeyboardIcon) == "function" and type(currencyType) == "number" then
        local ok, path = pcall(GetCurrencyKeyboardIcon, currencyType)
        if ok and type(path) == "string" and path ~= "" then
            iconPath = path
        end
    end

    -- Use a curated color palette per currency instead of relying on ESO's
    -- API color, because several currencies return neutral/white tones that do
    -- not visually match the actual currency well enough inside TPM's UI cards.
    local presets = {
        gold             = { texture = "TamrielProgressMap/art/currency_gold_hd.dds",          accent = { 0.95, 0.78, 0.16 }, mono = "G" },
        crowns           = { texture = "TamrielProgressMap/art/stat_complete.dds",  accent = { 0.68, 0.76, 0.88 }, mono = "C" },
        crownGems        = { texture = "TamrielProgressMap/art/cat_skyshard.dds",   accent = { 0.78, 0.36, 0.98 }, mono = "CG" },
        tradeBars        = { texture = "TamrielProgressMap/art/cat_setstation.dds", accent = { 0.92, 0.76, 0.18 }, mono = "TB" },
        seals            = { texture = "TamrielProgressMap/art/cat_quests.dds",     accent = { 0.78, 0.66, 0.34 }, mono = "S" },
        alliancePoints   = { texture = "TamrielProgressMap/art/pvp_kills.dds",      accent = { 0.18, 0.95, 0.18 }, mono = "AP" },
        telVar           = { texture = "TamrielProgressMap/art/pve_kills.dds",      accent = { 0.18, 0.80, 1.00 }, mono = "TV" },
        writVouchers     = { texture = "TamrielProgressMap/art/cat_sidequests.dds", accent = { 0.92, 0.77, 0.34 }, mono = "WV" },
        transmute        = { texture = "TamrielProgressMap/art/cat_mundus.dds",     accent = { 0.32, 0.82, 1.00 }, mono = "TC" },
        undauntedKeys    = { texture = "TamrielProgressMap/art/cat_delve.dds",      accent = { 0.96, 0.76, 0.24 }, mono = "UK" },
        archivalFortunes = { texture = "TamrielProgressMap/art/cat_book.dds",       accent = { 0.76, 0.68, 0.28 }, mono = "AF" },
        tomePoints       = { texture = "TamrielProgressMap/art/cat_book.dds",       accent = { 0.48, 0.92, 0.86 }, mono = "TP" },
    }

    local preset = presets[definition.key] or { texture = nil, accent = { 0.86, 0.66, 0.18 }, mono = "?" }

    -- Gold is intentionally rendered from TPM's sharpened 1024px copy of the
    -- ESO coin artwork. The native currency texture is tiny and becomes visibly
    -- soft in the large Gold summary card. Keep all other currencies live from ESO.
    if definition.key == "gold" then
        iconPath = preset.texture
    end

    return {
        texture = iconPath or preset.texture,
        accent = preset.accent,
        mono = preset.mono,
        isEsoCurrencyIcon = iconPath ~= nil,
    }
end

function TPM:CreatePlayerStatCard(parent, name, x, y, width)
    local card = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    card:SetDimensions(width, 100)
    card:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    card:SetCenterColor(0.030, 0.027, 0.021, 0.985)
    card:SetEdgeColor(0.42, 0.34, 0.17, 0.82)
    card:SetEdgeTexture(nil, 1, 1, 1)
    card:SetMouseEnabled(false)

    local title = WINDOW_MANAGER:CreateControl(name .. "Title", card, CT_LABEL)
    title:SetDimensions(width - 18, 26)
    title:SetAnchor(TOPLEFT, card, TOPLEFT, 9, 9)
    title:SetFont("$(BOLD_FONT)|17")
    title:SetColor(0.78, 0.72, 0.58, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local value = WINDOW_MANAGER:CreateControl(name .. "Value", card, CT_LABEL)
    value:SetDimensions(width - 18, 44)
    value:SetAnchor(TOPLEFT, card, TOPLEFT, 9, 36)
    value:SetFont("$(ANTIQUE_FONT)|30")
    value:SetColor(0.95, 0.82, 0.36, 1)
    value:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    value:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    return { control = card, title = title, value = value }
end

function TPM:CreatePlayerStatisticsPage(control)
    if self.statisticsPlayerPage then return end

    local page = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsPlayerPage", control, CT_BACKDROP)
    page:SetAnchor(TOPLEFT, control, TOPLEFT, 14, 60)
    page:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -14, -55)
    page:SetCenterColor(0.055, 0.046, 0.030, 1.00)
    page:SetEdgeColor(0.34, 0.27, 0.12, 0.94)
    page:SetEdgeTexture(nil, 1, 1, 1)
    page:SetMouseEnabled(true)
    page:SetHidden(true)
    self.statisticsPlayerPage = page

    local title = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
    title:SetDimensions(920, 34)
    title:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 14)
    title:SetFont("ZoFontWinH3")
    title:SetColor(0.90, 0.77, 0.34, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    title:SetHidden(true) -- Main journal header already shows the active page title.
    self.statisticsPlayerPageTitle = title

    local subtitle = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
    subtitle:SetDimensions(920, 24)
    subtitle:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 16)
    subtitle:SetFont("$(MEDIUM_FONT)|18")
    subtitle:SetColor(0.70, 0.67, 0.60, 1)
    subtitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    subtitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsPlayerPageSubtitle = subtitle

    local profile = WINDOW_MANAGER:CreateControl(nil, page, CT_BACKDROP)
    profile:SetDimensions(932, 62)
    profile:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 50)
    profile:SetCenterColor(0.045, 0.037, 0.026, 0.96)
    profile:SetEdgeColor(0.42, 0.34, 0.17, 0.72)
    profile:SetEdgeTexture(nil, 1, 1, 1)
    profile:SetMouseEnabled(false)

    local profileTitle = WINDOW_MANAGER:CreateControl(nil, profile, CT_LABEL)
    profileTitle:SetDimensions(210, 58)
    profileTitle:SetAnchor(LEFT, profile, LEFT, 14, 0)
    profileTitle:SetFont("$(BOLD_FONT)|19")
    profileTitle:SetColor(0.90, 0.77, 0.34, 1)
    profileTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    profileTitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsPlayerProfileTitle = profileTitle

    local profileText = WINDOW_MANAGER:CreateControl(nil, profile, CT_LABEL)
    profileText:SetDimensions(680, 58)
    profileText:SetAnchor(RIGHT, profile, RIGHT, -16, 0)
    profileText:SetFont("$(MEDIUM_FONT)|20")
    profileText:SetColor(0.88, 0.85, 0.77, 1)
    profileText:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    profileText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsPlayerProfileText = profileText

    local pvpTitle = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
    pvpTitle:SetDimensions(920, 30)
    pvpTitle:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 126)
    pvpTitle:SetFont("ZoFontWinH4")
    pvpTitle:SetColor(0.90, 0.77, 0.34, 1)
    pvpTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    pvpTitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsPlayerPvpTitle = pvpTitle

    local pvpDivider = WINDOW_MANAGER:CreateControl(nil, page, CT_BACKDROP)
    pvpDivider:SetDimensions(932, 1)
    pvpDivider:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 156)
    pvpDivider:SetCenterColor(0.42, 0.34, 0.17, 0.56)
    pvpDivider:SetEdgeColor(0, 0, 0, 0)

    self.statisticsPlayerCards = {
        pvpKills = self:CreatePlayerStatCard(page, ADDON_NAME .. "PlayerPvpKills", 20, 170, 292),
        pvpDeaths = self:CreatePlayerStatCard(page, ADDON_NAME .. "PlayerPvpDeaths", 330, 170, 292),
        pvpKd = self:CreatePlayerStatCard(page, ADDON_NAME .. "PlayerPvpKd", 640, 170, 292),
        npcKills = self:CreatePlayerStatCard(page, ADDON_NAME .. "PlayerNpcKills", 20, 354, 292),
        bossKills = self:CreatePlayerStatCard(page, ADDON_NAME .. "PlayerBossKills", 330, 354, 292),
        playTime = self:CreatePlayerStatCard(page, ADDON_NAME .. "PlayerPlayTime", 640, 354, 292),
    }

    -- The play-time card shows ESO's lifetime /played value. A smaller second
    -- line keeps the locally derived "since TPM" and known-account totals visible.
    if self.statisticsPlayerCards.playTime then
        local playCard = self.statisticsPlayerCards.playTime
        playCard.value:SetDimensions(274, 34)
        playCard.value:ClearAnchors()
        playCard.value:SetAnchor(TOPLEFT, playCard.control, TOPLEFT, 9, 32)
        playCard.value:SetFont("$(ANTIQUE_FONT)|27")
        local detail = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "PlayerPlayTimeDetail", playCard.control, CT_LABEL)
        detail:SetDimensions(274, 24)
        detail:SetAnchor(BOTTOMLEFT, playCard.control, BOTTOMLEFT, 9, -5)
        detail:SetFont("$(MEDIUM_FONT)|13")
        detail:SetColor(0.70, 0.67, 0.60, 1)
        detail:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        detail:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        playCard.detail = detail
    end

    local playerCardStyles = {
        pvpKills = { iconTexture = "TamrielProgressMap/art/pvp_kills.dds", accentColor = { 0.36, 0.66, 0.95 } },
        pvpDeaths = { iconTexture = "TamrielProgressMap/art/pvp_deaths.dds", accentColor = { 0.92, 0.40, 0.24 } },
        pvpKd = { iconTexture = "TamrielProgressMap/art/pvp_kills.dds", accentColor = { 0.42, 0.78, 0.96 } },
        npcKills = { iconTexture = "TamrielProgressMap/art/pve_kills.dds", accentColor = { 0.54, 0.82, 0.24 } },
        bossKills = { iconTexture = "TamrielProgressMap/art/cat_boss.dds", accentColor = { 0.96, 0.74, 0.24 } },
        playTime = { iconTexture = "TamrielProgressMap/art/tamriel_wreath.dds", accentColor = { 0.68, 0.92, 0.38 }, valueFont = "$(ANTIQUE_FONT)|26", valueY = 29, detailFont = "$(MEDIUM_FONT)|12" },
    }
    for key, style in pairs(playerCardStyles) do
        if self.statisticsPlayerCards[key] then
            self:ApplyThemedValueCard(self.statisticsPlayerCards[key], style)
        end
    end

    local pveTitle = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
    pveTitle:SetDimensions(920, 30)
    pveTitle:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 310)
    pveTitle:SetFont("ZoFontWinH4")
    pveTitle:SetColor(0.90, 0.77, 0.34, 1)
    pveTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    pveTitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsPlayerPveTitle = pveTitle

    local pveDivider = WINDOW_MANAGER:CreateControl(nil, page, CT_BACKDROP)
    pveDivider:SetDimensions(932, 1)
    pveDivider:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 340)
    pveDivider:SetCenterColor(0.42, 0.34, 0.17, 0.56)
    pveDivider:SetEdgeColor(0, 0, 0, 0)

    local note = WINDOW_MANAGER:CreateControl(nil, page, CT_BACKDROP)
    note:SetDimensions(932, 94)
    note:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 474)
    note:SetCenterColor(0.035, 0.030, 0.024, 0.94)
    note:SetEdgeColor(0.34, 0.29, 0.18, 0.64)
    note:SetEdgeTexture(nil, 1, 1, 1)
    note:SetMouseEnabled(false)

    local noteTitle = WINDOW_MANAGER:CreateControl(nil, note, CT_LABEL)
    noteTitle:SetDimensions(900, 24)
    noteTitle:SetAnchor(TOPLEFT, note, TOPLEFT, 14, 9)
    noteTitle:SetFont("$(BOLD_FONT)|18")
    noteTitle:SetColor(0.90, 0.77, 0.34, 1)
    noteTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    noteTitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsPlayerTrackingTitle = noteTitle

    local noteText = WINDOW_MANAGER:CreateControl(nil, note, CT_LABEL)
    noteText:SetDimensions(900, 52)
    noteText:SetAnchor(TOPLEFT, note, TOPLEFT, 14, 34)
    noteText:SetFont("$(MEDIUM_FONT)|17")
    noteText:SetColor(0.72, 0.69, 0.62, 1)
    noteText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    noteText:SetVerticalAlignment(TEXT_ALIGN_TOP)
    self.statisticsPlayerTrackingText = noteText
end

function TPM:CreateEconomyCurrencyCard(parent, name, x, y, width)
    local card = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    card:SetDimensions(width, 60)
    card:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    card:SetCenterColor(0.022, 0.021, 0.019, 0.99)
    card:SetEdgeColor(0.20, 0.18, 0.14, 0.72)
    card:SetEdgeTexture(nil, 1, 1, 1)
    card:SetMouseEnabled(false)

    local accent = WINDOW_MANAGER:CreateControl(nil, card, CT_BACKDROP)
    accent:SetDimensions(3, 58)
    accent:SetAnchor(LEFT, card, LEFT, 0, 0)
    accent:SetCenterColor(0.86, 0.66, 0.18, 0.90)
    accent:SetEdgeColor(0, 0, 0, 0)

    local iconBack = WINDOW_MANAGER:CreateControl(nil, card, CT_BACKDROP)
    iconBack:SetDimensions(50, 50)
    iconBack:SetAnchor(LEFT, card, LEFT, 9, 0)
    iconBack:SetCenterColor(0.035, 0.032, 0.026, 0.98)
    iconBack:SetEdgeColor(0.50, 0.40, 0.18, 0.72)
    iconBack:SetEdgeTexture(nil, 1, 1, 1)

    local icon = WINDOW_MANAGER:CreateControl(nil, iconBack, CT_TEXTURE)
    icon:SetDimensions(44, 44)
    icon:SetAnchor(CENTER, iconBack, CENTER, 0, 0)

    local title = WINDOW_MANAGER:CreateControl(name .. "Title", card, CT_LABEL)
    title:SetDimensions(width - 82, 20)
    title:SetAnchor(TOPLEFT, card, TOPLEFT, 70, 5)
    title:SetFont("$(BOLD_FONT)|16")
    title:SetColor(0.90, 0.77, 0.34, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local line = WINDOW_MANAGER:CreateControl(name .. "Line", card, CT_LABEL)
    line:SetDimensions(width - 82, 18)
    line:SetAnchor(TOPLEFT, card, TOPLEFT, 70, 24)
    line:SetFont("$(MEDIUM_FONT)|14")
    line:SetColor(0.80, 0.77, 0.70, 1)
    line:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    line:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local detail = WINDOW_MANAGER:CreateControl(name .. "Detail", card, CT_LABEL)
    detail:SetDimensions(width - 82, 15)
    detail:SetAnchor(TOPLEFT, card, TOPLEFT, 70, 42)
    detail:SetFont("$(MEDIUM_FONT)|12")
    detail:SetColor(0.70, 0.68, 0.62, 1)
    detail:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    detail:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    return {
        control = card,
        accent = accent,
        iconBack = iconBack,
        icon = icon,
        title = title,
        line = line,
        detail = detail,
        isGoldCard = false,
    }
end

function TPM:CreateEconomyGoldCard(parent, name, x, y, width)
    local card = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    card:SetDimensions(width, 132)
    card:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    card:SetCenterColor(0.060, 0.046, 0.018, 0.995)
    card:SetEdgeColor(0.82, 0.62, 0.14, 0.92)
    card:SetEdgeTexture(nil, 1, 1, 1)
    card:SetMouseEnabled(true)

    local topBand = WINDOW_MANAGER:CreateControl(nil, card, CT_BACKDROP)
    topBand:SetDimensions(width - 2, 2)
    topBand:SetAnchor(TOPLEFT, card, TOPLEFT, 1, 1)
    topBand:SetCenterColor(0.95, 0.76, 0.16, 0.82)
    topBand:SetEdgeColor(0, 0, 0, 0)

    local iconBack = WINDOW_MANAGER:CreateControl(nil, card, CT_BACKDROP)
    iconBack:SetDimensions(78, 78)
    iconBack:SetAnchor(LEFT, card, LEFT, 28, 0)
    iconBack:SetCenterColor(0.095, 0.068, 0.018, 0.99)
    iconBack:SetEdgeColor(0.92, 0.72, 0.18, 0.88)
    iconBack:SetEdgeTexture(nil, 1, 1, 1)

    local icon = WINDOW_MANAGER:CreateControl(nil, iconBack, CT_TEXTURE)
    icon:SetDimensions(70, 70)
    icon:SetAnchor(CENTER, iconBack, CENTER, 0, 0)

    local title = WINDOW_MANAGER:CreateControl(name .. "Title", card, CT_LABEL)
    title:SetDimensions(740, 28)
    title:SetAnchor(TOPLEFT, card, TOPLEFT, 142, 8)
    title:SetFont("$(BOLD_FONT)|23")
    title:SetColor(1.00, 0.88, 0.28, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local function CreateTopMetric(key, xPos)
        local label = WINDOW_MANAGER:CreateControl(nil, card, CT_LABEL)
        label:SetDimensions(190, 18)
        label:SetAnchor(TOPLEFT, card, TOPLEFT, xPos, 39)
        label:SetFont("$(MEDIUM_FONT)|13")
        label:SetColor(0.78, 0.72, 0.58, 1)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        local value = WINDOW_MANAGER:CreateControl(nil, card, CT_LABEL)
        value:SetDimensions(190, 26)
        value:SetAnchor(TOPLEFT, card, TOPLEFT, xPos, 55)
        value:SetFont("$(ANTIQUE_FONT)|24")
        value:SetColor(0.96, 0.84, 0.38, 1)
        value:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        return { label = label, value = value }
    end

    local cash = CreateTopMetric("cash", 142)
    local bank = CreateTopMetric("bank", 390)
    local total = CreateTopMetric("total", 638)

    for _, xPos in ipairs({ 370, 618 }) do
        local divider = WINDOW_MANAGER:CreateControl(nil, card, CT_BACKDROP)
        divider:SetDimensions(1, 42)
        divider:SetAnchor(TOPLEFT, card, TOPLEFT, xPos, 38)
        divider:SetCenterColor(0.44, 0.32, 0.10, 0.68)
        divider:SetEdgeColor(0, 0, 0, 0)
    end

    local midDivider = WINDOW_MANAGER:CreateControl(nil, card, CT_BACKDROP)
    midDivider:SetDimensions(width - 158, 1)
    midDivider:SetAnchor(TOPLEFT, card, TOPLEFT, 142, 84)
    midDivider:SetCenterColor(0.62, 0.46, 0.12, 0.72)
    midDivider:SetEdgeColor(0, 0, 0, 0)
    midDivider:SetHidden(false)

    local function CreateBottomMetric(xPos, valueColor)
        local label = WINDOW_MANAGER:CreateControl(nil, card, CT_LABEL)
        label:SetDimensions(142, 16)
        label:SetAnchor(TOPLEFT, card, TOPLEFT, xPos, 91)
        label:SetFont("$(MEDIUM_FONT)|12")
        label:SetColor(0.76, 0.71, 0.61, 1)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        local value = WINDOW_MANAGER:CreateControl(nil, card, CT_LABEL)
        value:SetDimensions(142, 20)
        value:SetAnchor(TOPLEFT, card, TOPLEFT, xPos, 106)
        value:SetFont("$(BOLD_FONT)|14")
        value:SetColor(valueColor[1], valueColor[2], valueColor[3], 1)
        value:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        return { label = label, value = value }
    end

    -- Five compact ledger subtotals fit across the promoted Gold card.
    -- Bounty paid is a Justice subset of Spent, not additional spending.
    local received = CreateBottomMetric(142, { 0.48, 0.92, 0.40 })
    local spent = CreateBottomMetric(292, { 0.94, 0.52, 0.32 })
    local fence = CreateBottomMetric(442, { 0.86, 0.70, 0.30 })
    local stolen = CreateBottomMetric(592, { 0.96, 0.60, 0.32 })
    local bounty = CreateBottomMetric(742, { 0.94, 0.72, 0.28 })
    for _, metric in ipairs({ received, spent, fence, stolen, bounty }) do
        metric.label:SetHidden(false)
        metric.value:SetHidden(false)
    end

    return {
        control = card,
        iconBack = iconBack,
        icon = icon,
        title = title,
        cash = cash,
        bank = bank,
        total = total,
        received = received,
        spent = spent,
        fence = fence,
        stolen = stolen,
        bounty = bounty,
        isGoldCard = true,
    }
end


function TPM:CreateEconomyDetailWindow()
    if self.economyDetailWindow then return end
    local parent = self.statisticsWindow or GuiRoot
    local w = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "EconomyDetailWindow")
    w:SetDimensions(760, 520)
    local savedX=tonumber(self.saved and self.saved.economyDetailX)
    local savedY=tonumber(self.saved and self.saved.economyDetailY)
    if savedX and savedY then
        w:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedX, savedY)
    else
        w:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    w:SetClampedToScreen(true)
    w:SetMouseEnabled(true)
    w:SetMovable(true)
    w:SetHandler("OnMoveStop", function(control)
        if TPM.saved then
            TPM.saved.economyDetailX=Round(tonumber(control:GetLeft()) or 0)
            TPM.saved.economyDetailY=Round(tonumber(control:GetTop()) or 0)
        end
    end)
    w:SetHidden(true)
    if w.SetDrawTier then w:SetDrawTier(DT_HIGH) end
    if w.SetDrawLayer then w:SetDrawLayer(DL_OVERLAY) end

    local bg = WINDOW_MANAGER:CreateControl(nil, w, CT_BACKDROP)
    bg:SetAnchorFill(w)
    bg:SetCenterColor(0.025,0.022,0.016,0.995)
    bg:SetEdgeColor(0.78,0.61,0.18,0.95)
    bg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds",128,16,2)
    bg:SetInsets(4,4,-4,-4)

    local title = WINDOW_MANAGER:CreateControl(nil,w,CT_LABEL)
    title:SetAnchor(TOPLEFT,w,TOPLEFT,22,16); title:SetDimensions(600,30)
    title:SetFont("ZoFontWinH2"); title:SetColor(0.95,0.79,0.28,1)
    self.economyDetailTitle = title

    local close = WINDOW_MANAGER:CreateControl(nil,w,CT_BUTTON)
    close:SetDimensions(34,30); close:SetAnchor(TOPRIGHT,w,TOPRIGHT,-14,12)
    close:SetFont("$(BOLD_FONT)|22"); close:SetText("×")
    close:SetHandler("OnClicked", function() w:SetHidden(true) end)

    local focusLabel = WINDOW_MANAGER:CreateControl(nil,w,CT_LABEL)
    focusLabel:SetAnchor(TOPLEFT,w,TOPLEFT,24,62); focusLabel:SetDimensions(60,24)
    focusLabel:SetFont("$(MEDIUM_FONT)|14"); focusLabel:SetColor(.75,.71,.62,1)
    focusLabel:SetText(self:L("ECON_DETAIL_FOCUS"))

    local function MakeSelector(name, x, width, click)
        local c=WINDOW_MANAGER:CreateControl(name,w,CT_BUTTON)
        c:SetDimensions(width,28); c:SetAnchor(TOPLEFT,w,TOPLEFT,x,60)
        c:SetFont("$(MEDIUM_FONT)|15"); c:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        c:SetNormalFontColor(.94,.90,.80,1); c:SetMouseOverFontColor(1,.84,.30,1)
        c:SetHandler("OnClicked",click)
        return c
    end
    self.economyDetailZoneButton=MakeSelector(ADDON_NAME.."EconomyDetailZone",84,260,function(button) TPM:ShowEconomyDetailZoneMenu(button) end)

    local viewLabel=WINDOW_MANAGER:CreateControl(nil,w,CT_LABEL)
    viewLabel:SetAnchor(TOPLEFT,w,TOPLEFT,370,62); viewLabel:SetDimensions(45,24)
    viewLabel:SetFont("$(MEDIUM_FONT)|14"); viewLabel:SetColor(.75,.71,.62,1)
    viewLabel:SetText(self:L("ECON_DETAIL_VIEW"))
    self.economyDetailViewButton=MakeSelector(ADDON_NAME.."EconomyDetailView",415,210,function(button) TPM:ShowEconomyDetailViewMenu(button) end)

    local info=WINDOW_MANAGER:CreateControl(nil,w,CT_BUTTON)
    info:SetDimensions(30,28); info:SetAnchor(TOPLEFT,w,TOPLEFT,640,60)
    info:SetFont("$(BOLD_FONT)|16"); info:SetText("(?)")
    info:SetHandler("OnMouseEnter",function(c)
        InitializeTooltip(InformationTooltip,c,TOPRIGHT,0,0,TOPLEFT)
        SetTooltipText(InformationTooltip,TPM:GetEconomyTrackingTooltip())
    end)
    info:SetHandler("OnMouseExit",function() ClearTooltip(InformationTooltip) end)

    self.economyDetailBody=WINDOW_MANAGER:CreateControl(nil,w,CT_LABEL)
    self.economyDetailBody:SetAnchor(TOPLEFT,w,TOPLEFT,28,112)
    self.economyDetailBody:SetDimensions(704,370)
    self.economyDetailBody:SetFont("$(MEDIUM_FONT)|18")
    self.economyDetailBody:SetColor(.91,.88,.79,1)
    self.economyDetailBody:SetVerticalAlignment(TEXT_ALIGN_TOP)
    self.economyDetailWindow=w
end

function TPM:GetEconomyTrackingTooltip()
    local stamp=tonumber(self.saved and self.saved.economyZoneTrackingStartedAt) or 0
    local dateText=self:L("ECON_DETAIL_UNKNOWN_DATE")
    if stamp>0 and type(FormatShortDate)=="function" then
        local ok,res=pcall(FormatShortDate,stamp)
        if ok and res and res~="" then dateText=res end
    elseif stamp>0 and type(os)=="table" and type(os.date)=="function" then
        dateText=os.date("%d.%m.%Y",stamp)
    end
    return self:L("ECON_DETAIL_TRACKING_TT",dateText)
end

function TPM:SetEconomyDetailZone(zoneId)
    if not self.saved then return end
    zoneId=tonumber(zoneId) or 0
    self.saved.economyDetailFocusZoneId=zoneId
    self:HideEconomyFocusDropdown()
    self:RefreshEconomyDetailWindow()
    self:RefreshEconomyStatisticsPage()
end

function TPM:SetEconomyDetailView(view)
    if not self.saved then return end
    local valid={overview=true,records=true,crime=true,bank=true}
    if not valid[view] then view="overview" end
    self.saved.economyDetailView=view
    self:RefreshEconomyDetailWindow()
end

function TPM:BringPopupMenuToFront()
    local candidates = {
        _G.ZO_Menu,
        _G.ZO_MenuItems,
        _G.ZO_ComboBox_Menu,
        _G.ZO_ComboBoxDropdown,
    }
    for _, control in ipairs(candidates) do
        if control then
            if control.SetDrawTier then control:SetDrawTier(DT_HIGH) end
            if control.SetDrawLayer then control:SetDrawLayer(DL_OVERLAY) end
            if control.SetDrawLevel then control:SetDrawLevel(10000) end
        end
    end
end


function TPM:GetEconomyFocusDropdownChoices()
    local result = {}
    result[#result+1] = {zoneId=0, name=self:L("ECON_DETAIL_ALL_TAMRIEL")}
    local currentId=self:GetEconomyTrackingZoneId()
    if currentId and currentId>0 then
        result[#result+1] = {
            zoneId=currentId,
            name=self:L("ECON_DETAIL_CURRENT_ZONE", self:GetEconomyZoneName(currentId))
        }
    end
    for _,choice in ipairs(self:GetEconomyZoneChoices() or {}) do
        if choice.zoneId and choice.zoneId>0 and choice.zoneId~=currentId then
            result[#result+1] = {zoneId=choice.zoneId, name=choice.name}
        end
    end
    return result
end

function TPM:RefreshEconomyFocusDropdown()
    local dropdown=self.economyFocusDropdown
    if not dropdown then return end
    local choices=self:GetEconomyFocusDropdownChoices()
    self.economyFocusDropdownChoices=choices

    local visibleRows=9
    local maxOffset=math.max(1,#choices-visibleRows+1)
    self.economyFocusDropdownOffset=Clamp(tonumber(self.economyFocusDropdownOffset) or 1,1,maxOffset)
    local selectedId=tonumber(self.saved and self.saved.economyDetailFocusZoneId) or 0

    for i,row in ipairs(self.economyFocusDropdownRows or {}) do
        local choice=choices[self.economyFocusDropdownOffset+i-1]
        if choice then
            row.zoneId=choice.zoneId
            if row.rowText then row.rowText:SetText(tostring(choice.name or "")) end
            row:SetHidden(false)
            if row.rowBack then row.rowBack:SetHidden(false) end

            local selected=tonumber(choice.zoneId) == selectedId
            if row.rowBack then
                if selected then
                    row.rowBack:SetCenterColor(0.080,0.060,0.020,0.98)
                    row.rowBack:SetEdgeColor(0.92,0.72,0.20,0.95)
                else
                    row.rowBack:SetCenterColor(0.018,0.016,0.012,0.94)
                    row.rowBack:SetEdgeColor(0.18,0.15,0.09,0.75)
                end
            end
            if row.rowText then row.rowText:SetColor(selected and 1.00 or 0.86, selected and 0.84 or 0.82, selected and 0.30 or 0.72, 1) end
        else
            row.zoneId=nil
            if row.rowText then row.rowText:SetText("") end
            row:SetHidden(true)
            if row.rowBack then row.rowBack:SetHidden(true) end
        end
    end

    -- Thumb size and position reflect the visible fraction/list offset.
    if self.economyFocusScrollThumb and self.economyFocusScrollRail then
        local railH=236
        local fraction=math.min(1, visibleRows / math.max(visibleRows,#choices))
        local thumbH=math.max(32, math.floor(railH*fraction))
        self.economyFocusScrollThumb:SetHeight(thumbH)
        local travel=math.max(0,railH-thumbH)
        local ratio=(maxOffset<=1) and 0 or ((self.economyFocusDropdownOffset-1)/(maxOffset-1))
        self.economyFocusScrollThumb:ClearAnchors()
        self.economyFocusScrollThumb:SetAnchor(TOP, self.economyFocusScrollRail, TOP, 0, 1 + math.floor(travel*ratio))
        self.economyFocusScrollRail:SetHidden(#choices<=visibleRows)
        self.economyFocusScrollThumb:SetHidden(#choices<=visibleRows)
    end
end

function TPM:HideEconomyFocusDropdown()
    if self.economyFocusDropdown then self.economyFocusDropdown:SetHidden(true) end
    if self.statisticsEconomyFocusArrow then self.statisticsEconomyFocusArrow:SetText("⌄") end
end

function TPM:ToggleEconomyFocusDropdown()
    local dropdown=self.economyFocusDropdown
    if not dropdown then return end
    if dropdown:IsHidden() then
        self.economyFocusDropdownOffset=1
        self:RefreshEconomyFocusDropdown()
        dropdown:SetDrawTier(DT_HIGH)
        dropdown:SetDrawLayer(DL_OVERLAY)
        if dropdown.SetDrawLevel then dropdown:SetDrawLevel(20000) end
        if dropdown.BringWindowToTop then dropdown:BringWindowToTop() end
        dropdown:SetHidden(false)
        if self.statisticsEconomyFocusArrow then self.statisticsEconomyFocusArrow:SetText("⌃") end
    else
        self:HideEconomyFocusDropdown()
    end
end

function TPM:ScrollEconomyFocusDropdown(delta)
    if not self.economyFocusDropdown or self.economyFocusDropdown:IsHidden() then return end
    local choices=self.economyFocusDropdownChoices or self:GetEconomyFocusDropdownChoices()
    local visibleRows=9
    local maxOffset=math.max(1,#choices-visibleRows+1)
    local step=(tonumber(delta) or 0)>0 and -1 or 1
    self.economyFocusDropdownOffset=Clamp((tonumber(self.economyFocusDropdownOffset) or 1)+step,1,maxOffset)
    self:RefreshEconomyFocusDropdown()
end

function TPM:ShowEconomyDetailZoneMenu(anchor)
    -- 2.6.47: Economy now uses TPM's own top-level dropdown. The standard ESO
    -- menu could render behind the high-level Statistics journal.
    if self.economyFocusDropdown then
        self:ToggleEconomyFocusDropdown()
        return
    end
end

function TPM:ShowEconomyDetailViewMenu(anchor)
    if _G.ClearMenu then ClearMenu() end
    local views={
        {"overview","ECON_DETAIL_OVERVIEW"},
        {"records","ECON_DETAIL_RECORDS"},
        {"crime","ECON_DETAIL_CRIME"},
        {"bank","ECON_DETAIL_BANK"},
    }
    local canMenu=type(ClearMenu)=="function" and type(AddMenuItem)=="function" and type(ShowMenu)=="function"
    if canMenu then
        ClearMenu()
        for _,item in ipairs(views) do
            local view,key=item[1],item[2]
            AddMenuItem(self:L(key), function() TPM:SetEconomyDetailView(view) end)
        end
        ShowMenu(anchor)
        return
    end

    local current=self.saved.economyDetailView or "overview"
    local idx=1
    for i,item in ipairs(views) do if item[1]==current then idx=i break end end
    self:SetEconomyDetailView(views[(idx % #views)+1][1])
    self:BringPopupMenuToFront()
end

function TPM:GetEconomyZoneRanking(field)
    local rows={}
    local store=self:GetEconomyZoneStore()
    for _,e in pairs((store and store.zones) or {}) do
        local value = field=="net"
            and ((tonumber(e.received) or 0)-(tonumber(e.spent) or 0))
            or (tonumber(e[field]) or 0)
        -- Empty zones make rankings noisy. "Most profitable" also only includes
        -- genuinely profitable zones; losses remain visible in the overview.
        if (field=="net" and value>0) or (field~="net" and value>0) then
            rows[#rows+1]={zoneId=e.zoneId,name=self:GetEconomyZoneName(e.zoneId),value=value}
        end
    end
    table.sort(rows,function(a,b)
        if a.value == b.value then return string.lower(a.name or "") < string.lower(b.name or "") end
        return a.value>b.value
    end)
    return rows
end

function TPM:GetEconomyZoneRank(zoneId, field)
    zoneId=tonumber(zoneId) or 0
    if zoneId<=0 then return nil end
    for i,row in ipairs(self:GetEconomyZoneRanking(field)) do
        if tonumber(row.zoneId)==zoneId then return i end
    end
    return nil
end

function TPM:RefreshEconomyDetailWindow()
    local w=self.economyDetailWindow
    if not w or w:IsHidden() then return end
    self:GetEconomyZoneStore()
    local zoneId=tonumber(self.saved.economyDetailFocusZoneId) or 0
    local view=self.saved.economyDetailView or "overview"
    self.economyDetailTitle:SetText(self:L("ECON_DETAIL_TITLE"))
    self.economyDetailZoneButton:SetText(self:GetEconomyZoneName(zoneId).."  ▼")
    local viewKeys={overview="ECON_DETAIL_OVERVIEW",records="ECON_DETAIL_RECORDS",crime="ECON_DETAIL_CRIME",bank="ECON_DETAIL_BANK"}
    self.economyDetailViewButton:SetText(self:L(viewKeys[view] or "ECON_DETAIL_OVERVIEW").."  ▼")
    local a=self:GetEconomyDetailAggregate(zoneId)
    local body={}
    if view=="overview" then
        body[#body+1]=self:L("ECON_DETAIL_INCOME")..": |c70D060+"..FormatNumber(a.received).."|r"
        body[#body+1]=self:L("ECON_DETAIL_EXPENSES")..": |cE07050-"..FormatNumber(a.spent).."|r"
        local sign=a.net>=0 and "+" or "-"
        body[#body+1]=self:L("ECON_DETAIL_NET")..": "..sign..FormatNumber(math.abs(a.net))
        body[#body+1]=""
        body[#body+1]=self:L("ECON_DETAIL_TRANSACTIONS")..": "..FormatNumber(a.transactions)
        body[#body+1]=self:L("ECON_DETAIL_FENCE")..": +"..FormatNumber(a.fenceSales)
        body[#body+1]=self:L("ECON_DETAIL_STOLEN")..": +"..FormatNumber(a.stolenGold)
        body[#body+1]=self:L("ECON_DETAIL_BOUNTY")..": -"..FormatNumber(a.bountyPaid)
    elseif view=="crime" then
        body[#body+1]=self:L("ECON_DETAIL_FENCE")..": +"..FormatNumber(a.fenceSales)
        body[#body+1]=self:L("ECON_DETAIL_STOLEN")..": +"..FormatNumber(a.stolenGold)
        body[#body+1]=self:L("ECON_DETAIL_BOUNTY")..": -"..FormatNumber(a.bountyPaid)
        body[#body+1]=""
        local crimeNet=(a.fenceSales or 0)+(a.stolenGold or 0)-(a.bountyPaid or 0)
        local crimeSign=crimeNet>=0 and "+" or "-"
        body[#body+1]=self:L("ECON_DETAIL_CRIME_NET")..": "..crimeSign..FormatNumber(math.abs(crimeNet))
    elseif view=="bank" then
        body[#body+1]=self:L("ECON_DETAIL_DEPOSITS")..": "..FormatNumber(a.bankDeposited)
        body[#body+1]=self:L("ECON_DETAIL_WITHDRAWALS")..": "..FormatNumber(a.bankWithdrawn)
    else
        local fields={{"net","ECON_DETAIL_PROFIT_RANK"},{"received","ECON_DETAIL_REVENUE_RANK"},{"spent","ECON_DETAIL_SPENDING_RANK"},
                      {"fenceSales","ECON_DETAIL_FENCE_RANK"},{"stolenGold","ECON_DETAIL_THEFT_RANK"},{"bountyPaid","ECON_DETAIL_BOUNTY_RANK"}}
        for _,f in ipairs(fields) do
            body[#body+1]="|cE6C45C"..self:L(f[2]).."|r"
            local rows=self:GetEconomyZoneRanking(f[1])
            if #rows==0 then
                body[#body+1]=self:L("ECON_DETAIL_NO_DATA")
            else
                for i=1,math.min(5,#rows) do
                    local r=rows[i]
                    body[#body+1]=string.format("%d. %s   %s",i,r.name,FormatNumber(r.value))
                end
                if zoneId>0 then
                    local rank=self:GetEconomyZoneRank(zoneId,f[1])
                    if rank and rank>5 then
                        body[#body+1]=self:L("ECON_DETAIL_SELECTED_RANK", self:GetEconomyZoneName(zoneId), rank)
                    end
                end
            end
            body[#body+1]=""
        end
    end
    self.economyDetailBody:SetText(table.concat(body,"\n"))
end

function TPM:ShowEconomyDetailWindow()
    self:CreateEconomyDetailWindow()
    self:GetEconomyZoneStore()
    self.economyDetailWindow:SetHidden(false)
    self:RefreshEconomyDetailWindow()
end

function TPM:CreateEconomyStatisticsPage(control)
    if self.statisticsEconomyPage then return end

    local page = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsEconomyPage", control, CT_BACKDROP)
    page:SetAnchor(TOPLEFT, control, TOPLEFT, 14, 60)
    page:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -14, -55)
    page:SetCenterColor(0.036, 0.032, 0.025, 1.00)
    page:SetEdgeColor(0.28, 0.22, 0.10, 0.90)
    page:SetEdgeTexture(nil, 1, 1, 1)
    page:SetMouseEnabled(true)
    page:SetHidden(true)
    self.statisticsEconomyPage = page

    local title = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
    title:SetDimensions(920, 34)
    title:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 14)
    title:SetFont("ZoFontWinH3")
    title:SetColor(0.90, 0.77, 0.34, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    title:SetHidden(true)
    self.statisticsEconomyPageTitle = title

    local subtitle = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
    subtitle:SetDimensions(920, 24)
    subtitle:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 14)
    subtitle:SetFont("$(MEDIUM_FONT)|18")
    subtitle:SetColor(0.74, 0.70, 0.62, 1)
    subtitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    subtitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsEconomyPageSubtitle = subtitle
    subtitle:SetDimensions(505, 24)

    -- Compact journal-style zone focus selector.
    local focusGroup = WINDOW_MANAGER:CreateControl(ADDON_NAME.."EconomyFocusGroup", page, CT_CONTROL)
    focusGroup:SetDimensions(300, 30)
    focusGroup:SetAnchor(TOPRIGHT, page, TOPRIGHT, -18, 9)
    focusGroup:SetMouseEnabled(false)

    local focusLabel = WINDOW_MANAGER:CreateControl(nil, focusGroup, CT_LABEL)
    focusLabel:SetDimensions(52, 28)
    focusLabel:SetAnchor(LEFT, focusGroup, LEFT, 0, 0)
    focusLabel:SetFont("$(MEDIUM_FONT)|12")
    focusLabel:SetColor(0.76,0.72,0.64,1)
    focusLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    focusLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    focusLabel:SetText(self:L("ECON_DETAIL_FOCUS"))
    self.statisticsEconomyFocusLabel = focusLabel

    local selector = WINDOW_MANAGER:CreateControl(ADDON_NAME.."EconomyFocusSelector", focusGroup, CT_CONTROL)
    selector:SetDimensions(240, 26)
    selector:SetAnchor(RIGHT, focusGroup, RIGHT, 0, 0)
    selector:SetMouseEnabled(true)

    local selectorBg = WINDOW_MANAGER:CreateControl(nil, selector, CT_BACKDROP)
    selectorBg:SetAnchorFill(selector)
    selectorBg:SetCenterColor(0.026,0.023,0.017,0.98)
    selectorBg:SetEdgeColor(0.62,0.49,0.17,0.90)
    selectorBg:SetEdgeTexture(nil,1,1,1)
    selectorBg:SetMouseEnabled(false)

    local selected = WINDOW_MANAGER:CreateControl(nil, selector, CT_LABEL)
    selected:SetDimensions(204,24)
    selected:SetAnchor(LEFT, selector, LEFT, 10, 0)
    selected:SetFont("$(MEDIUM_FONT)|13")
    selected:SetColor(0.92,0.87,0.73,1)
    selected:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    selected:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local arrowBack = WINDOW_MANAGER:CreateControl(nil, selector, CT_BACKDROP)
    arrowBack:SetDimensions(24,22)
    arrowBack:SetAnchor(RIGHT, selector, RIGHT, -3, 0)
    arrowBack:SetCenterColor(0.045,0.036,0.018,0.96)
    arrowBack:SetEdgeColor(0.50,0.38,0.12,0.80)
    arrowBack:SetEdgeTexture(nil,1,1,1)
    arrowBack:SetMouseEnabled(false)

    local arrow = WINDOW_MANAGER:CreateControl(nil, arrowBack, CT_LABEL)
    arrow:SetDimensions(20,20)
    arrow:SetAnchor(CENTER, arrowBack, CENTER, 0, 0)
    arrow:SetFont("$(BOLD_FONT)|14")
    arrow:SetColor(0.96,0.79,0.24,1)
    arrow:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    arrow:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    arrow:SetText("⌄")
    selector:SetHandler("OnMouseEnter", function()
        selectorBg:SetCenterColor(0.070,0.054,0.022,0.98)
        selectorBg:SetEdgeColor(0.92,0.72,0.20,1)
    end)
    selector:SetHandler("OnMouseExit", function()
        selectorBg:SetCenterColor(0.026,0.023,0.017,0.98)
        selectorBg:SetEdgeColor(0.62,0.49,0.17,0.90)
    end)
    selector:SetHandler("OnMouseUp", function(_, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
            TPM:ToggleEconomyFocusDropdown()
        end
    end)
    selector:SetHandler("OnMouseWheel", function(_, delta)
        if TPM.economyFocusDropdown and not TPM.economyFocusDropdown:IsHidden() then
            TPM:ScrollEconomyFocusDropdown(delta)
        end
    end)

    self.statisticsEconomyFocusSelector = selector
    self.statisticsEconomyFocusButton = selected
    self.statisticsEconomyFocusArrow = arrow

    -- Real top-level popup: this fixes ESO hit-testing where a visible child
    -- control can still sit behind the Statistics journal for mouse input.
    local dropdown = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME.."EconomyFocusDropdown")
    dropdown:SetDimensions(260, 260)
    dropdown:SetAnchor(TOPRIGHT, selector, BOTTOMRIGHT, 0, 3)
    dropdown:SetMouseEnabled(true)
    dropdown:SetClampedToScreen(true)
    dropdown:SetHidden(true)
    dropdown:SetDrawTier(DT_HIGH)
    dropdown:SetDrawLayer(DL_OVERLAY)
    if dropdown.SetDrawLevel then dropdown:SetDrawLevel(20000) end
    dropdown:SetHandler("OnMouseWheel", function(_, delta) TPM:ScrollEconomyFocusDropdown(delta) end)

    local dropBg = WINDOW_MANAGER:CreateControl(nil, dropdown, CT_BACKDROP)
    dropBg:SetAnchorFill(dropdown)
    dropBg:SetCenterColor(0.010,0.009,0.007,0.998)
    dropBg:SetEdgeColor(0.88,0.69,0.19,1)
    dropBg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds",128,16,2)
    dropBg:SetInsets(2,2,-2,-2)
    dropBg:SetMouseEnabled(false)

    self.economyFocusDropdownRows = {}
    for rowIndex=1,9 do
        local row = WINDOW_MANAGER:CreateControl(ADDON_NAME.."EconomyFocusRow"..tostring(rowIndex), dropdown, CT_BUTTON)
        row:SetDimensions(224,25)
        row:SetAnchor(TOPLEFT, dropdown, TOPLEFT, 7, 6 + ((rowIndex-1)*27))
        row:SetMouseEnabled(true)
        row:SetClickSound(SOUNDS.DEFAULT_CLICK)

        local rowBack = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
        rowBack:SetAnchorFill(row)
        rowBack:SetCenterColor(0.018,0.016,0.012,0.94)
        rowBack:SetEdgeColor(0.18,0.15,0.09,0.75)
        rowBack:SetEdgeTexture(nil,1,1,1)
        rowBack:SetMouseEnabled(false)

        local rowText = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
        rowText:SetDimensions(204,25)
        rowText:SetAnchor(LEFT, row, LEFT, 8, 0)
        rowText:SetFont("$(MEDIUM_FONT)|13")
        rowText:SetColor(0.86,0.82,0.72,1)
        rowText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        rowText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        rowText:SetMouseEnabled(false)

        row.rowBack = rowBack
        row.rowText = rowText

        row:SetHandler("OnMouseEnter", function(btn)
            if btn.rowBack then
                btn.rowBack:SetCenterColor(0.095,0.070,0.022,0.98)
                btn.rowBack:SetEdgeColor(0.88,0.67,0.18,0.95)
            end
            if btn.rowText then btn.rowText:SetColor(1,0.88,0.38,1) end
        end)
        row:SetHandler("OnMouseExit", function(btn)
            local selectedId = tonumber(TPM.saved and TPM.saved.economyDetailFocusZoneId) or 0
            local selected = btn.zoneId ~= nil and tonumber(btn.zoneId) == selectedId
            if btn.rowBack then
                if selected then
                    btn.rowBack:SetCenterColor(0.080,0.060,0.020,0.98)
                    btn.rowBack:SetEdgeColor(0.92,0.72,0.20,0.95)
                else
                    btn.rowBack:SetCenterColor(0.018,0.016,0.012,0.94)
                    btn.rowBack:SetEdgeColor(0.18,0.15,0.09,0.75)
                end
            end
            if btn.rowText then
                btn.rowText:SetColor(selected and 1.00 or 0.86, selected and 0.84 or 0.82, selected and 0.30 or 0.72, 1)
            end
        end)
        row:SetHandler("OnMouseUp", function(btn, button, upInside)
            if upInside and button == MOUSE_BUTTON_INDEX_LEFT and btn.zoneId ~= nil then
                TPM:SetEconomyDetailZone(btn.zoneId)
            end
        end)
        row:SetHandler("OnClicked", function(btn)
            if btn.zoneId ~= nil then
                TPM:SetEconomyDetailZone(btn.zoneId)
            end
        end)

        self.economyFocusDropdownRows[rowIndex] = row
    end

    -- Visible scroll rail + thumb.
    local scrollRail = WINDOW_MANAGER:CreateControl(nil, dropdown, CT_BACKDROP)
    scrollRail:SetDimensions(10, 238)
    scrollRail:SetAnchor(TOPRIGHT, dropdown, TOPRIGHT, -8, 8)
    scrollRail:SetCenterColor(0.035,0.030,0.020,0.95)
    scrollRail:SetEdgeColor(0.30,0.24,0.10,0.85)
    scrollRail:SetEdgeTexture(nil,1,1,1)
    scrollRail:SetMouseEnabled(false)

    local scrollThumb = WINDOW_MANAGER:CreateControl(nil, scrollRail, CT_BACKDROP)
    scrollThumb:SetDimensions(8, 48)
    scrollThumb:SetAnchor(TOP, scrollRail, TOP, 0, 1)
    scrollThumb:SetCenterColor(0.72,0.56,0.17,0.95)
    scrollThumb:SetEdgeColor(0.95,0.77,0.25,1)
    scrollThumb:SetEdgeTexture(nil,1,1,1)
    scrollThumb:SetMouseEnabled(false)

    local up = WINDOW_MANAGER:CreateControl(nil, dropdown, CT_LABEL)
    up:SetDimensions(16,16)
    up:SetAnchor(TOPRIGHT, dropdown, TOPRIGHT, -5, -1)
    up:SetFont("$(BOLD_FONT)|12")
    up:SetText("▲")
    up:SetColor(0.82,0.67,0.22,1)
    up:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    up:SetMouseEnabled(true)
    up:SetHandler("OnMouseUp", function(_,button,inside)
        if inside and button==MOUSE_BUTTON_INDEX_LEFT then TPM:ScrollEconomyFocusDropdown(1) end
    end)

    local down = WINDOW_MANAGER:CreateControl(nil, dropdown, CT_LABEL)
    down:SetDimensions(16,16)
    down:SetAnchor(BOTTOMRIGHT, dropdown, BOTTOMRIGHT, -5, 1)
    down:SetFont("$(BOLD_FONT)|12")
    down:SetText("▼")
    down:SetColor(0.82,0.67,0.22,1)
    down:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    down:SetMouseEnabled(true)
    down:SetHandler("OnMouseUp", function(_,button,inside)
        if inside and button==MOUSE_BUTTON_INDEX_LEFT then TPM:ScrollEconomyFocusDropdown(-1) end
    end)

    self.economyFocusDropdown = dropdown
    self.economyFocusDropdownOffset = 1
    self.economyFocusScrollRail = scrollRail
    self.economyFocusScrollThumb = scrollThumb


    self.statisticsEconomyCards = {}
    self.statisticsEconomyCards[1] = self:CreateEconomyGoldCard(page, ADDON_NAME .. "EconomyCardGold", 20, 48, 914)

    -- Layout mirrors the clean journal mock-up: six compact cards on the left,
    -- five on the right, with Gold promoted to a full-width summary card.
    local layout = {
        [2]  = { 0, 1 }, -- Crowns
        [3]  = { 0, 0 }, -- Crown Gems
        [4]  = { 0, 2 }, -- Trade Bars
        [5]  = { 0, 5 }, -- Seals
        [6]  = { 1, 0 }, -- Alliance Points
        [7]  = { 0, 3 }, -- Tel Var
        [8]  = { 1, 1 }, -- Writ Vouchers
        [9]  = { 0, 4 }, -- Transmute Crystals
        [10] = { 1, 2 }, -- Undaunted Keys
        [11] = { 1, 3 }, -- Archival Fortunes
        [12] = { 1, 4 }, -- Tome Points
    }
    local cardWidth = 448
    local startY = 190
    local rowHeight = 64
    for index = 2, 12 do
        local placement = layout[index]
        local column = placement[1]
        local row = placement[2]
        local x = 20 + column * 466
        local y = startY + row * rowHeight
        self.statisticsEconomyCards[index] = self:CreateEconomyCurrencyCard(page, ADDON_NAME .. "EconomyCard" .. tostring(index), x, y, cardWidth)
    end

    local note = WINDOW_MANAGER:CreateControl(nil, page, CT_BACKDROP)
    note:SetDimensions(856, 52)
    note:SetAnchor(TOP, page, TOP, 0, 582)
    note:SetCenterColor(0.026, 0.024, 0.021, 0.97)
    note:SetEdgeColor(0.30, 0.25, 0.15, 0.62)
    note:SetEdgeTexture(nil, 1, 1, 1)
    note:SetMouseEnabled(false)

    local infoBack = WINDOW_MANAGER:CreateControl(nil, note, CT_BACKDROP)
    infoBack:SetDimensions(34, 34)
    infoBack:SetAnchor(LEFT, note, LEFT, 12, 0)
    infoBack:SetCenterColor(0.055, 0.047, 0.032, 1)
    infoBack:SetEdgeColor(0.66, 0.52, 0.22, 0.82)
    infoBack:SetEdgeTexture(nil, 1, 1, 1)

    local info = WINDOW_MANAGER:CreateControl(nil, infoBack, CT_LABEL)
    info:SetDimensions(32, 32)
    info:SetAnchor(CENTER, infoBack, CENTER, 0, 0)
    info:SetFont("$(BOLD_FONT)|20")
    info:SetColor(0.86, 0.72, 0.38, 1)
    info:SetText("i")
    info:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    info:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local noteTitle = WINDOW_MANAGER:CreateControl(nil, note, CT_LABEL)
    noteTitle:SetDimensions(790, 20)
    noteTitle:SetAnchor(TOPLEFT, note, TOPLEFT, 58, 4)
    noteTitle:SetFont("$(BOLD_FONT)|17")
    noteTitle:SetColor(0.90, 0.77, 0.34, 1)
    noteTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    noteTitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsEconomyTrackingTitle = noteTitle

    local noteText = WINDOW_MANAGER:CreateControl(nil, note, CT_LABEL)
    noteText:SetDimensions(790, 27)
    noteText:SetAnchor(TOPLEFT, note, TOPLEFT, 58, 23)
    noteText:SetFont("$(MEDIUM_FONT)|13")
    noteText:SetColor(0.70, 0.68, 0.62, 1)
    noteText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    noteText:SetVerticalAlignment(TEXT_ALIGN_TOP)
    self.statisticsEconomyTrackingText = noteText
end

function TPM:RefreshEconomyStatisticsPage()
    if self.economyDetailWindow and not self.economyDetailWindow:IsHidden() then self:RefreshEconomyDetailWindow() end
    if not self.statisticsEconomyPage or self.statisticsEconomyPage:IsHidden() then return end
    local stats = self:GetEconomyStats()
    local definitions = self:GetEconomyCurrencyDefinitions()

    self.statisticsEconomyPageTitle:SetText(self:L("STAT_ECONOMY_PAGE_TITLE"))
    self.statisticsEconomyPageSubtitle:SetText(self:L("STAT_ECONOMY_PAGE_SUBTITLE_CHARACTER", stats.characterName or self:L("STAT_PLAYER_UNKNOWN")))
    self.statisticsEconomyTrackingTitle:SetText(self:L("STAT_ECONOMY_TRACKING"))
    self.statisticsEconomyTrackingText:SetText(self:L("STAT_ECONOMY_TRACKING_NOTE", stats.trackingVersion or "2.0.15"))

    local focusZoneId = tonumber(self.saved and self.saved.economyDetailFocusZoneId) or 0
    local zoneAggregate = self:GetEconomyDetailAggregate(focusZoneId)
    if self.statisticsEconomyFocusButton then
        self.statisticsEconomyFocusButton:SetText(self:GetEconomyZoneName(focusZoneId) .. "  ▼")
    end


    for index, card in ipairs(self.statisticsEconomyCards or {}) do
        local definition = definitions[index]
        card.control:SetHidden(definition == nil)
        if definition then
            local entry = stats.currencies[definition.key] or { received = 0, spent = 0 }
            local amounts = self:GetEconomyCurrentAmounts(definition)
            local visual = self:GetEconomyCardVisual(definition)

            if card.isGoldCard then
                card.title:SetText(self:GetEconomyCurrencyName(definition))
                if visual.texture and visual.texture ~= "" then
                    card.icon:SetTexture(visual.texture)
                    card.icon:SetColor(1, 1, 1, 1)
                end

                card.cash.label:SetText(self:L("STAT_ECONOMY_LABEL_CASH"))
                card.bank.label:SetText(self:L("STAT_ECONOMY_LABEL_BANK"))
                card.total.label:SetText(self:L("STAT_ECONOMY_LABEL_TOTAL"))
                card.cash.value:SetText(FormatNumber(amounts.character))
                card.bank.value:SetText(FormatNumber(amounts.bank))
                card.total.value:SetText(FormatNumber(amounts.total))

                card.received.label:SetText(self:L("STAT_ECONOMY_LABEL_RECEIVED"))
                card.spent.label:SetText(self:L("STAT_ECONOMY_LABEL_SPENT"))
                card.fence.label:SetText(self:L("STAT_ECONOMY_FENCE_SHORT"))
                card.stolen.label:SetText(self:L("STAT_ECONOMY_STOLEN_SHORT"))
                if card.bounty then card.bounty.label:SetText(self:L("STAT_ECONOMY_BOUNTY_PAID_SHORT")) end
                card.received.value:SetText("+" .. FormatNumber((focusZoneId == 0 and entry.received or zoneAggregate.received) or 0))
                card.spent.value:SetText("-" .. FormatNumber((focusZoneId == 0 and entry.spent or zoneAggregate.spent) or 0))
                card.fence.value:SetText("+" .. FormatNumber((focusZoneId == 0 and entry.fenceSales or zoneAggregate.fenceSales) or 0))
                card.stolen.value:SetText("+" .. FormatNumber((focusZoneId == 0 and entry.stolenGold or zoneAggregate.stolenGold) or 0))
                if card.bounty then card.bounty.value:SetText("-" .. FormatNumber((focusZoneId == 0 and entry.bountyPaid or zoneAggregate.bountyPaid) or 0)) end
            else
                local accent = visual.accent or { 0.86, 0.66, 0.18 }
                local accentHex = RGBToHex(accent[1], accent[2], accent[3])
                local bulletHex = "786846"

                card.control:SetCenterColor(
                    0.020 + accent[1] * 0.014,
                    0.020 + accent[2] * 0.012,
                    0.018 + accent[3] * 0.010,
                    0.992
                )
                card.control:SetEdgeColor(accent[1], accent[2], accent[3], 0.48)
                card.accent:SetCenterColor(accent[1], accent[2], accent[3], 0.92)
                card.iconBack:SetCenterColor(
                    0.025 + accent[1] * 0.10,
                    0.024 + accent[2] * 0.09,
                    0.022 + accent[3] * 0.08,
                    0.98
                )
                card.iconBack:SetEdgeColor(accent[1], accent[2], accent[3], 0.70)

                if visual.texture and visual.texture ~= "" then
                    card.icon:SetTexture(visual.texture)
                    card.icon:SetColor(1, 1, 1, 1)
                    card.icon:SetHidden(false)
                else
                    card.icon:SetHidden(true)
                end

                card.title:SetText(self:GetEconomyCurrencyName(definition))
                card.title:SetColor(
                    math.min(1, 0.52 + accent[1] * 0.52),
                    math.min(1, 0.48 + accent[2] * 0.52),
                    math.min(1, 0.44 + accent[3] * 0.50),
                    1
                )

                if self:IsEconomyCurrencyBankable(definition) then
                    local primaryLabel = self:L("STAT_ECONOMY_LABEL_CHARACTER")
                    card.line:SetText(string.format("|c%s%s: %s|r   |c%s•|r   |c%s%s: %s|r   |c%s•|r   |c%s%s: %s|r",
                        accentHex, primaryLabel, FormatNumber(amounts.character),
                        bulletHex,
                        accentHex, self:L("STAT_ECONOMY_LABEL_BANK"), FormatNumber(amounts.bank),
                        bulletHex,
                        accentHex, self:L("STAT_ECONOMY_LABEL_TOTAL"), FormatNumber(amounts.total)))
                else
                    local primaryLocation = self:GetEconomyPrimaryLocation(definition)
                    local primaryLabel = self:L("STAT_ECONOMY_LABEL_CURRENT")
                    if type(_G.CURRENCY_LOCATION_ACCOUNT) == "number" and primaryLocation == _G.CURRENCY_LOCATION_ACCOUNT then
                        primaryLabel = self:L("STAT_ECONOMY_LABEL_ACCOUNT")
                    end
                    card.line:SetText(string.format("|c%s%s: %s|r", accentHex, primaryLabel, FormatNumber(amounts.current)))
                end

                card.detail:SetText(string.format("|c8FD0A5%s: +%s|r   |c%s•|r   |cD9B48A%s: -%s|r",
                    self:L("STAT_ECONOMY_LABEL_RECEIVED"),
                    FormatNumber(entry.received or 0),
                    bulletHex,
                    self:L("STAT_ECONOMY_LABEL_SPENT"),
                    FormatNumber(entry.spent or 0)))
            end
        end
    end
end

-- 2.6.34 Community: Alliance statistics page -----------------------------------
function TPM:GetAllianceStatisticsData()
    local result = {
        DC = { completed = 0, total = 0, zonesCompleted = 0, zonesTotal = 0 },
        AD = { completed = 0, total = 0, zonesCompleted = 0, zonesTotal = 0 },
        EP = { completed = 0, total = 0, zonesCompleted = 0, zonesTotal = 0 },
    }
    local stats = self:GetStatisticsData(false, 0)
    for _, zone in ipairs((stats and stats.zones) or {}) do
        local group = self:GetAllianceTerritoryGroup(zone.zoneId)
        local row = group and result[group] or nil
        if row then
            row.completed = row.completed + (tonumber(zone.completed) or 0)
            row.total = row.total + (tonumber(zone.total) or 0)
            row.zonesTotal = row.zonesTotal + 1
            if (tonumber(zone.percent) or 0) >= 100 then row.zonesCompleted = row.zonesCompleted + 1 end
        end
    end
    for _, row in pairs(result) do
        row.percent = row.total > 0 and Clamp(Round((row.completed / row.total) * 100), 0, 100) or 0
        if row.completed < row.total and row.percent >= 100 then row.percent = 99 end
    end
    return result
end

function TPM:GetPlayerAllianceDisplay()
    local allianceId = 0
    if type(_G.GetUnitAlliance) == "function" then
        local ok, value = pcall(_G.GetUnitAlliance, "player")
        if ok then allianceId = tonumber(value) or 0 end
    end
    local name = ""
    if allianceId > 0 and type(_G.GetAllianceName) == "function" then
        local ok, value = pcall(_G.GetAllianceName, allianceId)
        if ok then name = tostring(value or "") end
    end
    if name == "" then
        name = self:L("STAT_ALLIANCE_UNKNOWN")
    else
        -- ESO localized names can carry grammar metadata (for example "^n").
        -- Those suffixes are useful to the formatter but should never be visible in TPM.
        name = name:gsub("%^%a+", "")
        if type(zo_strformat) == "function" then
            local ok, formatted = pcall(zo_strformat, "<<C:1>>", name)
            if ok and type(formatted) == "string" and formatted ~= "" then name = formatted end
        end
    end
    local group = nil
    if allianceId == _G.ALLIANCE_DAGGERFALL_COVENANT then group = "DC"
    elseif allianceId == _G.ALLIANCE_ALDMERI_DOMINION then group = "AD"
    elseif allianceId == _G.ALLIANCE_EBONHEART_PACT then group = "EP" end
    return allianceId, name, group
end


function TPM:GetAllianceCategoryStatisticsData(group)
    -- Some ESO clients/API revisions do not expose every completion-type
    -- constant. Never use a nil completion type as a table key.
    local defs = {
        { key = "CAT_QUESTS", completionType = _G.ZONE_COMPLETION_TYPE_PRIORITY_QUESTS },
        { key = "CAT_SIDE_QUESTS", completionType = _G.ZONE_COMPLETION_TYPE_SIDE_QUESTS },
        { key = "CAT_SKYSHARDS", completionType = _G.ZONE_COMPLETION_TYPE_SKYSHARDS },
        { key = "CAT_WAYSHRINES", completionType = _G.ZONE_COMPLETION_TYPE_WAYSHRINES },
        { key = "CAT_DELVES", completionType = _G.ZONE_COMPLETION_TYPE_DELVES },
        { key = "CAT_PUBLIC_DUNGEONS", completionType = _G.ZONE_COMPLETION_TYPE_PUBLIC_DUNGEONS },
        { key = "CAT_WORLD_BOSSES", completionType = _G.ZONE_COMPLETION_TYPE_GROUP_BOSSES },
        { key = "CAT_WORLD_EVENTS", completionType = _G.ZONE_COMPLETION_TYPE_WORLD_EVENTS },
    }

    local totals = {}
    for _, def in ipairs(defs) do
        if def.completionType ~= nil then
            totals[def.completionType] = { completed = 0, total = 0 }
        end
    end

    local progressZoneIds = self:GetAllProgressZoneIds() or {}
    for zoneId in pairs(progressZoneIds) do
        if self:GetAllianceTerritoryGroup(zoneId) == group then
            local breakdown = self:GetCompletionBreakdown(zoneId)
            for _, row in ipairs(breakdown or {}) do
                local completionType = row and row.completionType
                local dst = completionType ~= nil and totals[completionType] or nil
                if dst then
                    dst.completed = dst.completed + (tonumber(row.completed) or 0)
                    dst.total = dst.total + (tonumber(row.total) or 0)
                end
            end
        end
    end

    local rows = {}
    for _, def in ipairs(defs) do
        if def.completionType ~= nil then
            local t = totals[def.completionType] or { completed = 0, total = 0 }
            local percent = t.total > 0 and Clamp(Round((t.completed / t.total) * 100), 0, 100) or 0
            rows[#rows + 1] = {
                label = self:L(def.key),
                completed = t.completed,
                total = t.total,
                percent = percent,
            }
        end
    end
    return rows
end


function TPM:GetAllianceZoneProgressData(group)
    local zoneIdsByGroup = {
        DC = {534,535,3,19,20,104,92},
        AD = {537,381,383,108,58,382},
        EP = {280,281,41,57,117,101,103},
    }
    local result = {}
    for _, zoneId in ipairs(zoneIdsByGroup[group] or {}) do
        local _, completed, total, percent = self:GetResolvedCompletion(zoneId)
        local name = (type(SafeZoneName) == "function" and SafeZoneName(zoneId)) or self:GetEconomyZoneName(zoneId)
        completed = tonumber(completed) or 0
        total = tonumber(total) or 0
        percent = Clamp(tonumber(percent) or 0, 0, 100)
        result[#result+1] = {
            zoneId = zoneId,
            name = (name and name ~= "") and name or tostring(zoneId),
            completed = completed,
            total = total,
            remaining = math.max(0, total - completed),
            percent = percent,
            complete = percent >= 100,
        }
    end

    -- Community planner order: unfinished zones first, closest to 100% first.
    -- Fully completed zones move to the bottom so the next useful target is
    -- always immediately visible.
    table.sort(result, function(a,b)
        if a.complete ~= b.complete then return not a.complete end
        if a.percent ~= b.percent then return a.percent > b.percent end
        if a.remaining ~= b.remaining then return a.remaining < b.remaining end
        return tostring(a.name) < tostring(b.name)
    end)
    return result
end

function TPM:GetAlliancePlannerRecommendations(group)
    local zones = self:GetAllianceZoneProgressData(group)
    local nextTarget, biggestGap = nil, nil
    for _, zone in ipairs(zones) do
        if not zone.complete then
            if not nextTarget then nextTarget = zone end
            if not biggestGap or zone.percent < biggestGap.percent
                or (zone.percent == biggestGap.percent and zone.remaining > biggestGap.remaining) then
                biggestGap = zone
            end
        end
    end
    return nextTarget, biggestGap, zones
end

function TPM:OpenAllianceZoneInProgress(zoneId)
    zoneId = tonumber(zoneId) or 0
    if zoneId <= 0 or not self.saved then return end
    self.saved.statisticsFocusZoneId = zoneId
    self.statisticsScrollOffset = 0
    self:SetStatisticsPage("progress")
    self:RefreshStatisticsFocusSelector()
    self:RefreshStatisticsWindow()
end


function TPM:GetAlliancePlannerColor(group)
    if group == "DC" then return 0.20, 0.48, 1.00 end
    if group == "AD" then return 1.00, 0.76, 0.12 end
    if group == "EP" then return 1.00, 0.20, 0.20 end
    return 0.82, 0.76, 0.58
end

function TPM:RefreshAlliancePlannerMapView()
    local texture = self.statisticsAllianceMapTexture
    if not texture then return end

    local zoom = tonumber(self.saved and self.saved.alliancePlannerMapZoom) or 1.0
    zoom = Clamp(zoom, 1.0, 2.5)
    if self.saved then self.saved.alliancePlannerMapZoom = zoom end

    local span = 1 / zoom
    local halfSpan = span * 0.5

    local centerX = tonumber(self.saved and self.saved.alliancePlannerMapCenterX) or 0.5
    local centerY = tonumber(self.saved and self.saved.alliancePlannerMapCenterY) or 0.5

    if zoom <= 1.001 then
        centerX, centerY = 0.5, 0.5
    else
        centerX = Clamp(centerX, halfSpan, 1 - halfSpan)
        centerY = Clamp(centerY, halfSpan, 1 - halfSpan)
    end

    if self.saved then
        self.saved.alliancePlannerMapCenterX = centerX
        self.saved.alliancePlannerMapCenterY = centerY
    end

    texture:SetTextureCoords(
        centerX - halfSpan,
        centerX + halfSpan,
        centerY - halfSpan,
        centerY + halfSpan
    )

    if self.statisticsAllianceMapZoomLabel then
        self.statisticsAllianceMapZoomLabel:SetText(string.format("%d%%", math.floor(zoom * 100 + 0.5)))
    end

    if self.statisticsAllianceMapDragHint then
        self.statisticsAllianceMapDragHint:SetHidden(zoom <= 1.001)
    end
end

function TPM:ZoomAlliancePlannerMapAtMouse(step)
    if not self.saved or not self.statisticsAllianceMapTexture then return end

    local texture = self.statisticsAllianceMapTexture
    local oldZoom = Clamp(tonumber(self.saved.alliancePlannerMapZoom) or 1.0, 1.0, 2.5)
    local newZoom = Clamp(oldZoom + (tonumber(step) or 0), 1.0, 2.5)
    if math.abs(newZoom - oldZoom) < 0.001 then return end

    local oldSpan = 1 / oldZoom
    local newSpan = 1 / newZoom
    local centerX = tonumber(self.saved.alliancePlannerMapCenterX) or 0.5
    local centerY = tonumber(self.saved.alliancePlannerMapCenterY) or 0.5

    if type(GetUIMousePosition) == "function" then
        local mouseX, mouseY = GetUIMousePosition()
        local left, top = texture:GetScreenRect()
        local width, height = texture:GetDimensions()
        width = math.max(1, tonumber(width) or 1)
        height = math.max(1, tonumber(height) or 1)

        local relX = Clamp(((tonumber(mouseX) or 0) - (tonumber(left) or 0)) / width, 0, 1)
        local relY = Clamp(((tonumber(mouseY) or 0) - (tonumber(top) or 0)) / height, 0, 1)

        local oldLeft = centerX - oldSpan * 0.5
        local oldTop = centerY - oldSpan * 0.5
        local anchorU = oldLeft + relX * oldSpan
        local anchorV = oldTop + relY * oldSpan

        centerX = anchorU - (relX - 0.5) * newSpan
        centerY = anchorV - (relY - 0.5) * newSpan
    end

    local halfSpan = newSpan * 0.5
    centerX = Clamp(centerX, halfSpan, 1 - halfSpan)
    centerY = Clamp(centerY, halfSpan, 1 - halfSpan)

    self.saved.alliancePlannerMapZoom = newZoom
    self.saved.alliancePlannerMapCenterX = centerX
    self.saved.alliancePlannerMapCenterY = centerY
    self:RefreshAlliancePlannerMapView()
end

function TPM:SetAlliancePlannerMapZoom(value)
    if not self.saved then return end
    local zoom = Clamp(tonumber(value) or 1.0, 1.0, 2.5)
    self.saved.alliancePlannerMapZoom = zoom
    if zoom <= 1.001 then
        self.saved.alliancePlannerMapCenterX = 0.5
        self.saved.alliancePlannerMapCenterY = 0.5
    end
    self:RefreshAlliancePlannerMapView()
end

function TPM:StepAlliancePlannerMapZoom(delta)
    self:ZoomAlliancePlannerMapAtMouse(tonumber(delta) or 0)
end

function TPM:BeginAlliancePlannerMapPan()
    if not self.saved or not self.statisticsAllianceMapTexture then return end
    local zoom = tonumber(self.saved.alliancePlannerMapZoom) or 1.0
    if zoom <= 1.001 or type(GetUIMousePosition) ~= "function" then return end

    local mouseX, mouseY = GetUIMousePosition()
    self.alliancePlannerMapDragging = true
    self.alliancePlannerMapDragStartX = tonumber(mouseX) or 0
    self.alliancePlannerMapDragStartY = tonumber(mouseY) or 0
    self.alliancePlannerMapDragCenterX = tonumber(self.saved.alliancePlannerMapCenterX) or 0.5
    self.alliancePlannerMapDragCenterY = tonumber(self.saved.alliancePlannerMapCenterY) or 0.5
end

function TPM:UpdateAlliancePlannerMapPan()
    if not self.alliancePlannerMapDragging or type(GetUIMousePosition) ~= "function" then return end
    local texture = self.statisticsAllianceMapTexture
    if not texture or not self.saved then return end

    local zoom = tonumber(self.saved.alliancePlannerMapZoom) or 1.0
    if zoom <= 1.001 then
        self.alliancePlannerMapDragging = false
        return
    end

    local mouseX, mouseY = GetUIMousePosition()
    local width, height = texture:GetDimensions()
    width = math.max(1, tonumber(width) or 1)
    height = math.max(1, tonumber(height) or 1)

    local span = 1 / zoom
    local halfSpan = span * 0.5
    local dx = (tonumber(mouseX) or 0) - (tonumber(self.alliancePlannerMapDragStartX) or 0)
    local dy = (tonumber(mouseY) or 0) - (tonumber(self.alliancePlannerMapDragStartY) or 0)

    -- Drag the map itself: pulling right/down moves the visible image in the
    -- same direction, so the sampled texture center moves left/up.
    local centerX = (tonumber(self.alliancePlannerMapDragCenterX) or 0.5) - (dx / width) * span
    local centerY = (tonumber(self.alliancePlannerMapDragCenterY) or 0.5) - (dy / height) * span

    self.saved.alliancePlannerMapCenterX = Clamp(centerX, halfSpan, 1 - halfSpan)
    self.saved.alliancePlannerMapCenterY = Clamp(centerY, halfSpan, 1 - halfSpan)
    self:RefreshAlliancePlannerMapView()
end

function TPM:EndAlliancePlannerMapPan()
    self.alliancePlannerMapDragging = false
end

function TPM:ToggleAlliancePlannerTerritoryColors()
    if not self.saved then return end
    self.saved.alliancePlannerTerritoryColors = not (self.saved.alliancePlannerTerritoryColors == true)
    self:RefreshAllianceStatisticsPage()
end

function TPM:CreateAllianceStatisticsPage(control)
    if self.statisticsAlliancePage then return end

    local page=WINDOW_MANAGER:CreateControl(ADDON_NAME.."StatisticsAlliancePage",control,CT_BACKDROP)
    page:SetAnchor(TOPLEFT,control,TOPLEFT,14,60)
    page:SetAnchor(BOTTOMRIGHT,control,BOTTOMRIGHT,-14,-55)
    page:SetCenterColor(0.025,0.023,0.019,1.00)
    page:SetEdgeColor(0.52,0.40,0.12,0.92)
    page:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds",128,16,2)
    page:SetHidden(true)
    self.statisticsAlliancePage=page

    -- Own alliance ------------------------------------------------------------
    local own=WINDOW_MANAGER:CreateControl(nil,page,CT_BACKDROP)
    own:SetDimensions(914,76)
    own:SetAnchor(TOPLEFT,page,TOPLEFT,20,12)
    own:SetCenterColor(0.045,0.040,0.028,0.99)
    own:SetEdgeColor(0.70,0.55,0.18,0.90)
    own:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds",128,16,2)

    local ownTitle=WINDOW_MANAGER:CreateControl(nil,own,CT_LABEL)
    ownTitle:SetDimensions(220,18)
    ownTitle:SetAnchor(TOPLEFT,own,TOPLEFT,16,7)
    ownTitle:SetFont("$(BOLD_FONT)|15")
    ownTitle:SetColor(0.95,0.78,0.26,1)

    local ownName=WINDOW_MANAGER:CreateControl(nil,own,CT_LABEL)
    ownName:SetDimensions(560,24)
    ownName:SetAnchor(TOPLEFT,own,TOPLEFT,16,25)
    ownName:SetFont("$(BOLD_FONT)|20")
    ownName:SetColor(0.96,0.91,0.78,1)

    local ownPercent=WINDOW_MANAGER:CreateControl(nil,own,CT_LABEL)
    ownPercent:SetDimensions(130,34)
    ownPercent:SetAnchor(TOPRIGHT,own,TOPRIGHT,-16,13)
    ownPercent:SetFont("$(ANTIQUE_FONT)|31")
    ownPercent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    ownPercent:SetColor(0.95,0.82,0.32,1)

    local ownBarBack=WINDOW_MANAGER:CreateControl(nil,own,CT_BACKDROP)
    ownBarBack:SetDimensions(880,8)
    ownBarBack:SetAnchor(BOTTOMLEFT,own,BOTTOMLEFT,16,-9)
    ownBarBack:SetCenterColor(0.08,0.07,0.05,1)
    ownBarBack:SetEdgeColor(0.40,0.33,0.18,0.9)
    ownBarBack:SetEdgeTexture(nil,1,1,1)

    local ownBar=WINDOW_MANAGER:CreateControl(nil,ownBarBack,CT_BACKDROP)
    ownBar:SetDimensions(1,6)
    ownBar:SetAnchor(LEFT,ownBarBack,LEFT,1,0)
    ownBar:SetEdgeColor(0,0,0,0)

    self.statisticsAllianceOwnTitle=ownTitle
    self.statisticsAllianceOwnName=ownName
    self.statisticsAllianceOwnPercent=ownPercent
    self.statisticsAllianceOwnBarBack=ownBarBack
    self.statisticsAllianceOwnBar=ownBar

    -- Alliance selector -------------------------------------------------------
    local defs={
        {key="DC",label="STAT_ALLIANCE_DC",color={0.20,0.48,1.00}},
        {key="AD",label="STAT_ALLIANCE_AD",color={1.00,0.76,0.12}},
        {key="EP",label="STAT_ALLIANCE_EP",color={1.00,0.20,0.20}},
    }
    self.statisticsAllianceCards={}
    for i,def in ipairs(defs) do
        local card=WINDOW_MANAGER:CreateControl(nil,page,CT_BACKDROP)
        card:SetDimensions(220,88)
        card:SetAnchor(TOPLEFT,page,TOPLEFT,20,100+((i-1)*96))
        card:SetCenterColor(0.018,0.018,0.017,0.99)
        card:SetEdgeColor(def.color[1],def.color[2],def.color[3],0.82)
        card:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds",128,16,2)
        card:SetMouseEnabled(true)
        card.allianceGroup=def.key
        card:SetHandler("OnMouseUp",function(c,button,inside)
            if inside and button==MOUSE_BUTTON_INDEX_LEFT then
                TPM.statisticsAllianceSelectedGroup=c.allianceGroup
                TPM:RefreshAllianceStatisticsPage()
            end
        end)

        local accent=WINDOW_MANAGER:CreateControl(nil,card,CT_BACKDROP)
        accent:SetDimensions(216,4)
        accent:SetAnchor(TOP,card,TOP,0,2)
        accent:SetCenterColor(def.color[1],def.color[2],def.color[3],0.96)
        accent:SetEdgeColor(0,0,0,0)

        local title=WINDOW_MANAGER:CreateControl(nil,card,CT_LABEL)
        title:SetDimensions(150,20)
        title:SetAnchor(TOPLEFT,card,TOPLEFT,12,9)
        title:SetFont("$(BOLD_FONT)|15")
        title:SetColor(def.color[1],def.color[2],def.color[3],1)

        local badge=WINDOW_MANAGER:CreateControl(nil,card,CT_LABEL)
        badge:SetDimensions(115,15)
        badge:SetAnchor(TOPLEFT,card,TOPLEFT,12,29)
        badge:SetFont("$(BOLD_FONT)|10")
        badge:SetColor(0.95,0.82,0.32,1)

        local percent=WINDOW_MANAGER:CreateControl(nil,card,CT_LABEL)
        percent:SetDimensions(62,28)
        percent:SetAnchor(TOPRIGHT,card,TOPRIGHT,-10,10)
        percent:SetFont("$(ANTIQUE_FONT)|26")
        percent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        percent:SetColor(0.95,0.84,0.38,1)

        local barBack=WINDOW_MANAGER:CreateControl(nil,card,CT_BACKDROP)
        barBack:SetDimensions(194,7)
        barBack:SetAnchor(TOPLEFT,card,TOPLEFT,12,47)
        barBack:SetCenterColor(0.07,0.065,0.055,1)
        barBack:SetEdgeColor(0.32,0.29,0.22,0.9)
        barBack:SetEdgeTexture(nil,1,1,1)

        local bar=WINDOW_MANAGER:CreateControl(nil,barBack,CT_BACKDROP)
        bar:SetDimensions(1,5)
        bar:SetAnchor(LEFT,barBack,LEFT,1,0)
        bar:SetCenterColor(def.color[1],def.color[2],def.color[3],0.95)
        bar:SetEdgeColor(0,0,0,0)

        local zones=WINDOW_MANAGER:CreateControl(nil,card,CT_LABEL)
        zones:SetDimensions(94,16)
        zones:SetAnchor(TOPLEFT,card,TOPLEFT,12,61)
        zones:SetFont("$(MEDIUM_FONT)|11")
        zones:SetColor(0.83,0.79,0.69,1)

        local objectives=WINDOW_MANAGER:CreateControl(nil,card,CT_LABEL)
        objectives:SetDimensions(94,16)
        objectives:SetAnchor(TOPRIGHT,card,TOPRIGHT,-12,61)
        objectives:SetFont("$(MEDIUM_FONT)|11")
        objectives:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        objectives:SetColor(0.70,0.68,0.62,1)

        self.statisticsAllianceCards[def.key]={
            control=card,title=title,badge=badge,percent=percent,zones=zones,objectives=objectives,
            barBack=barBack,bar=bar,label=def.label,color=def.color,
        }
    end

    -- Selected alliance quick summary -----------------------------------------
    local quick=WINDOW_MANAGER:CreateControl(nil,page,CT_BACKDROP)
    quick:SetDimensions(220,112)
    quick:SetAnchor(TOPLEFT,page,TOPLEFT,20,394)
    quick:SetCenterColor(0.020,0.019,0.016,0.99)
    quick:SetEdgeColor(0.42,0.34,0.15,0.90)
    quick:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds",128,16,2)

    local quickTitle=WINDOW_MANAGER:CreateControl(nil,quick,CT_LABEL)
    quickTitle:SetDimensions(194,18)
    quickTitle:SetAnchor(TOPLEFT,quick,TOPLEFT,12,7)
    quickTitle:SetFont("$(BOLD_FONT)|13")
    quickTitle:SetColor(0.91,0.75,0.30,1)
    quickTitle:SetText(self:L("STAT_ALLIANCE_OVERVIEW"))

    local quickDone=WINDOW_MANAGER:CreateControl(nil,quick,CT_LABEL)
    quickDone:SetDimensions(194,18)
    quickDone:SetAnchor(TOPLEFT,quick,TOPLEFT,12,31)
    quickDone:SetFont("$(MEDIUM_FONT)|11")
    quickDone:SetColor(0.86,0.83,0.74,1)
    self.statisticsAllianceQuickDone=quickDone

    local quickOpen=WINDOW_MANAGER:CreateControl(nil,quick,CT_LABEL)
    quickOpen:SetDimensions(194,18)
    quickOpen:SetAnchor(TOPLEFT,quick,TOPLEFT,12,52)
    quickOpen:SetFont("$(MEDIUM_FONT)|11")
    quickOpen:SetColor(0.86,0.83,0.74,1)
    self.statisticsAllianceQuickOpen=quickOpen

    local quickNext=WINDOW_MANAGER:CreateControl(nil,quick,CT_LABEL)
    quickNext:SetDimensions(194,28)
    quickNext:SetAnchor(TOPLEFT,quick,TOPLEFT,12,73)
    quickNext:SetFont("$(BOLD_FONT)|10")
    quickNext:SetColor(0.95,0.82,0.32,1)
    quickNext:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    self.statisticsAllianceQuickNext=quickNext

    -- Large map ---------------------------------------------------------------
    local planner=WINDOW_MANAGER:CreateControl(nil,page,CT_BACKDROP)
    planner:SetDimensions(486,412)
    planner:SetAnchor(TOPLEFT,page,TOPLEFT,252,100)
    planner:SetCenterColor(0.012,0.012,0.011,0.99)
    planner:SetEdgeColor(0.25,0.22,0.16,0.90)
    planner:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds",128,16,2)
    self.statisticsAllianceMapPanel=planner

    local mapTitle=WINDOW_MANAGER:CreateControl(nil,planner,CT_LABEL)
    mapTitle:SetDimensions(448,22)
    mapTitle:SetAnchor(TOPLEFT,planner,TOPLEFT,14,7)
    mapTitle:SetFont("$(BOLD_FONT)|15")
    mapTitle:SetColor(0.91,0.75,0.30,1)
    self.statisticsAllianceMapTitle=mapTitle

    -- Source map aspect is 916:663 (~1.3816). 468x339 preserves it.
    local mapFrame=WINDOW_MANAGER:CreateControl(nil,planner,CT_BACKDROP)
    mapFrame:SetDimensions(460,334)
    mapFrame:SetAnchor(TOPLEFT,planner,TOPLEFT,13,31)
    mapFrame:SetCenterColor(0.005,0.005,0.004,0.08)
    mapFrame:SetEdgeColor(0.50,0.40,0.18,0.92)
    mapFrame:SetEdgeTexture(nil,1,1,1)
    mapFrame:SetMouseEnabled(false)
    if mapFrame.SetDrawLevel then mapFrame:SetDrawLevel(2) end
    self.statisticsAllianceMapFrame=mapFrame

    local mapTexture=WINDOW_MANAGER:CreateControl(nil,mapFrame,CT_TEXTURE)
    mapTexture:SetDimensions(454,328)
    mapTexture:SetAnchor(CENTER,mapFrame,CENTER,0,0)
    mapTexture:SetTexture("TamrielProgressMap/art/alliance_community_map.dds")
    mapTexture:SetTextureCoords(0,1,0,1)
    mapTexture:SetAlpha(1)
    mapTexture:SetMouseEnabled(true)
    if mapTexture.SetDrawLevel then mapTexture:SetDrawLevel(10) end
    mapTexture:SetHandler("OnMouseWheel",function(_,delta)
        TPM:ZoomAlliancePlannerMapAtMouse((tonumber(delta) or 0)>0 and 0.25 or -0.25)
    end)
    mapTexture:SetHandler("OnMouseDown",function(_,button)
        if button==MOUSE_BUTTON_INDEX_LEFT then TPM:BeginAlliancePlannerMapPan() end
    end)
    mapTexture:SetHandler("OnMouseUp",function(_,button)
        if button==MOUSE_BUTTON_INDEX_LEFT then TPM:EndAlliancePlannerMapPan() end
    end)
    mapTexture:SetHandler("OnUpdate",function() TPM:UpdateAlliancePlannerMapPan() end)
    self.statisticsAllianceMapTexture=mapTexture

    -- Recommendations below map, inside planner.
    local nextBox=WINDOW_MANAGER:CreateControl(nil,planner,CT_BACKDROP)
    nextBox:SetDimensions(216,32)
    nextBox:SetAnchor(BOTTOMLEFT,planner,BOTTOMLEFT,13,-5)
    nextBox:SetCenterColor(0.035,0.032,0.025,0.96)
    nextBox:SetEdgeColor(0.35,0.29,0.14,0.85)
    nextBox:SetEdgeTexture(nil,1,1,1)

    local nextTitle=WINDOW_MANAGER:CreateControl(nil,nextBox,CT_LABEL)
    nextTitle:SetDimensions(208,12)
    nextTitle:SetAnchor(TOPLEFT,nextBox,TOPLEFT,7,2)
    nextTitle:SetFont("$(BOLD_FONT)|9")
    nextTitle:SetColor(0.87,0.72,0.26,1)
    self.statisticsAllianceNextTitle=nextTitle

    local nextValue=WINDOW_MANAGER:CreateControl(nil,nextBox,CT_LABEL)
    nextValue:SetDimensions(208,13)
    nextValue:SetAnchor(TOPLEFT,nextBox,TOPLEFT,7,14)
    nextValue:SetFont("$(MEDIUM_FONT)|10")
    nextValue:SetColor(0.90,0.86,0.75,1)
    self.statisticsAllianceNextValue=nextValue

    local gapBox=WINDOW_MANAGER:CreateControl(nil,planner,CT_BACKDROP)
    gapBox:SetDimensions(216,32)
    gapBox:SetAnchor(BOTTOMRIGHT,planner,BOTTOMRIGHT,-13,-5)
    gapBox:SetCenterColor(0.035,0.032,0.025,0.96)
    gapBox:SetEdgeColor(0.35,0.29,0.14,0.85)
    gapBox:SetEdgeTexture(nil,1,1,1)

    local gapTitle=WINDOW_MANAGER:CreateControl(nil,gapBox,CT_LABEL)
    gapTitle:SetDimensions(208,12)
    gapTitle:SetAnchor(TOPLEFT,gapBox,TOPLEFT,7,2)
    gapTitle:SetFont("$(BOLD_FONT)|9")
    gapTitle:SetColor(0.87,0.72,0.26,1)
    self.statisticsAllianceGapTitle=gapTitle

    local gapValue=WINDOW_MANAGER:CreateControl(nil,gapBox,CT_LABEL)
    gapValue:SetDimensions(208,13)
    gapValue:SetAnchor(TOPLEFT,gapBox,TOPLEFT,7,14)
    gapValue:SetFont("$(MEDIUM_FONT)|10")
    gapValue:SetColor(0.90,0.86,0.75,1)
    self.statisticsAllianceGapValue=gapValue

    -- Right: legend + zoom ----------------------------------------------------
    local tools=WINDOW_MANAGER:CreateControl(nil,page,CT_BACKDROP)
    tools:SetDimensions(190,180)
    tools:SetAnchor(TOPLEFT,page,TOPLEFT,748,100)
    tools:SetCenterColor(0.020,0.019,0.016,0.99)
    tools:SetEdgeColor(0.42,0.34,0.15,0.90)
    tools:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds",128,16,2)

    local toolsTitle=WINDOW_MANAGER:CreateControl(nil,tools,CT_LABEL)
    toolsTitle:SetDimensions(164,20)
    toolsTitle:SetAnchor(TOPLEFT,tools,TOPLEFT,12,7)
    toolsTitle:SetFont("$(BOLD_FONT)|14")
    toolsTitle:SetColor(0.91,0.75,0.30,1)
    toolsTitle:SetText(self:L("STAT_ALLIANCE_TOOLS_TITLE"))

    local legend=WINDOW_MANAGER:CreateControl(nil,tools,CT_LABEL)
    legend:SetDimensions(166,78)
    legend:SetAnchor(TOPLEFT,tools,TOPLEFT,12,27)
    legend:SetFont("$(MEDIUM_FONT)|11")
    legend:SetColor(0.88,0.85,0.78,1)
    legend:SetText("|c4E9BFF■|r  "..self:L("STAT_ALLIANCE_DC")..
        "\n|cFFD13C■|r  "..self:L("STAT_ALLIANCE_AD")..
        "\n|cFF594A■|r  "..self:L("STAT_ALLIANCE_EP")..
        "\n|cBDB8AA■|r  "..self:L("STAT_ALLIANCE_NEUTRAL"))
    self.statisticsAllianceLegend=legend

    local zoomTitle=WINDOW_MANAGER:CreateControl(nil,tools,CT_LABEL)
    zoomTitle:SetDimensions(60,18)
    zoomTitle:SetAnchor(TOPLEFT,tools,TOPLEFT,12,98)
    zoomTitle:SetFont("$(BOLD_FONT)|12")
    zoomTitle:SetColor(0.88,0.82,0.68,1)
    zoomTitle:SetText(self:L("STAT_ALLIANCE_ZOOM"))

    local zoomLabel=WINDOW_MANAGER:CreateControl(nil,tools,CT_LABEL)
    zoomLabel:SetDimensions(70,18)
    zoomLabel:SetAnchor(TOPRIGHT,tools,TOPRIGHT,-12,97)
    zoomLabel:SetFont("$(ANTIQUE_FONT)|20")
    zoomLabel:SetColor(0.95,0.82,0.32,1)
    zoomLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    zoomLabel:SetText("100%")
    self.statisticsAllianceMapZoomLabel=zoomLabel

    local zoomMinus=WINDOW_MANAGER:CreateControl(nil,tools,CT_BUTTON)
    zoomMinus:SetDimensions(32,22)
    zoomMinus:SetAnchor(BOTTOMLEFT,tools,BOTTOMLEFT,12,-8)
    zoomMinus:SetFont("$(BOLD_FONT)|15")
    zoomMinus:SetNormalFontColor(0.95,0.85,0.55,1)
    zoomMinus:SetMouseOverFontColor(1,1,0.80,1)
    zoomMinus:SetText("−")
    zoomMinus:SetHandler("OnClicked",function() TPM:ZoomAlliancePlannerMapAtMouse(-0.25) end)

    local resetZoom=WINDOW_MANAGER:CreateControl(nil,tools,CT_BUTTON)
    resetZoom:SetDimensions(64,22)
    resetZoom:SetAnchor(BOTTOM,tools,BOTTOM,0,-8)
    resetZoom:SetFont("$(BOLD_FONT)|10")
    resetZoom:SetNormalFontColor(0.90,0.84,0.70,1)
    resetZoom:SetMouseOverFontColor(1,0.88,0.36,1)
    resetZoom:SetText("100%")
    resetZoom:SetHandler("OnClicked",function() TPM:SetAlliancePlannerMapZoom(1.0) end)

    local zoomPlus=WINDOW_MANAGER:CreateControl(nil,tools,CT_BUTTON)
    zoomPlus:SetDimensions(32,22)
    zoomPlus:SetAnchor(BOTTOMRIGHT,tools,BOTTOMRIGHT,-12,-8)
    zoomPlus:SetFont("$(BOLD_FONT)|15")
    zoomPlus:SetNormalFontColor(0.95,0.85,0.55,1)
    zoomPlus:SetMouseOverFontColor(1,1,0.80,1)
    zoomPlus:SetText("+")
    zoomPlus:SetHandler("OnClicked",function() TPM:ZoomAlliancePlannerMapAtMouse(0.25) end)

    -- Right: zone progress -----------------------------------------------------
    local zonePanel=WINDOW_MANAGER:CreateControl(nil,page,CT_BACKDROP)
    zonePanel:SetDimensions(190,232)
    zonePanel:SetAnchor(TOPLEFT,page,TOPLEFT,748,288)
    zonePanel:SetCenterColor(0.020,0.019,0.016,0.99)
    zonePanel:SetEdgeColor(0.42,0.34,0.15,0.90)
    zonePanel:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds",128,16,2)

    local zoneTitle=WINDOW_MANAGER:CreateControl(nil,zonePanel,CT_LABEL)
    zoneTitle:SetDimensions(164,20)
    zoneTitle:SetAnchor(TOPLEFT,zonePanel,TOPLEFT,12,7)
    zoneTitle:SetFont("$(BOLD_FONT)|14")
    zoneTitle:SetColor(0.91,0.75,0.30,1)
    self.statisticsAllianceZoneTitle=zoneTitle

    local zoneHint=WINDOW_MANAGER:CreateControl(nil,zonePanel,CT_LABEL)
    zoneHint:SetDimensions(164,28)
    zoneHint:SetAnchor(TOPLEFT,zonePanel,TOPLEFT,12,25)
    zoneHint:SetFont("$(MEDIUM_FONT)|9")
    zoneHint:SetColor(0.62,0.59,0.52,1)
    zoneHint:SetVerticalAlignment(TEXT_ALIGN_TOP)
    self.statisticsAllianceZoneHint=zoneHint

    self.statisticsAllianceZoneRows={}
    for i=1,7 do
        local row=WINDOW_MANAGER:CreateControl(nil,zonePanel,CT_BUTTON)
        row:SetDimensions(164,25)
        row:SetAnchor(TOPLEFT,zonePanel,TOPLEFT,12,52+((i-1)*25))
        row:SetMouseEnabled(true)

        local hover=WINDOW_MANAGER:CreateControl(nil,row,CT_BACKDROP)
        hover:SetAnchorFill(row)
        hover:SetCenterColor(0.018,0.016,0.012,0)
        hover:SetEdgeColor(0.22,0.18,0.10,0)
        hover:SetEdgeTexture(nil,1,1,1)
        hover:SetMouseEnabled(false)

        local name=WINDOW_MANAGER:CreateControl(nil,row,CT_LABEL)
        name:SetDimensions(118,13)
        name:SetAnchor(TOPLEFT,row,TOPLEFT,0,0)
        name:SetFont("$(MEDIUM_FONT)|10")
        name:SetColor(0.87,0.83,0.74,1)
        name:SetMouseEnabled(false)

        local pct=WINDOW_MANAGER:CreateControl(nil,row,CT_LABEL)
        pct:SetDimensions(44,13)
        pct:SetAnchor(TOPRIGHT,row,TOPRIGHT,0,0)
        pct:SetFont("$(BOLD_FONT)|10")
        pct:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        pct:SetMouseEnabled(false)

        local barBack=WINDOW_MANAGER:CreateControl(nil,row,CT_BACKDROP)
        barBack:SetDimensions(164,6)
        barBack:SetAnchor(TOPLEFT,row,TOPLEFT,0,15)
        barBack:SetCenterColor(0.060,0.055,0.045,1)
        barBack:SetEdgeColor(0.25,0.22,0.16,0.9)
        barBack:SetEdgeTexture(nil,1,1,1)
        barBack:SetMouseEnabled(false)

        local fill=WINDOW_MANAGER:CreateControl(nil,barBack,CT_BACKDROP)
        fill:SetDimensions(1,4)
        fill:SetAnchor(LEFT,barBack,LEFT,1,0)
        fill:SetEdgeColor(0,0,0,0)

        local count=WINDOW_MANAGER:CreateControl(nil,row,CT_LABEL)
        count:SetDimensions(164,9)
        count:SetAnchor(TOPLEFT,row,TOPLEFT,0,20)
        count:SetFont("$(MEDIUM_FONT)|8")
        count:SetColor(0.57,0.55,0.50,1)
        count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        count:SetMouseEnabled(false)

        row.hover=hover
        row:SetHandler("OnMouseEnter",function(btn)
            btn.hover:SetCenterColor(0.075,0.057,0.020,0.70)
            btn.hover:SetEdgeColor(0.70,0.54,0.16,0.75)
        end)
        row:SetHandler("OnMouseExit",function(btn)
            btn.hover:SetCenterColor(0.018,0.016,0.012,0)
            btn.hover:SetEdgeColor(0.22,0.18,0.10,0)
        end)
        row:SetHandler("OnClicked",function(btn)
            if btn.zoneId then TPM:OpenAllianceZoneInProgress(btn.zoneId) end
        end)

        self.statisticsAllianceZoneRows[i]={control=row,name=name,pct=pct,bar=fill,count=count}
    end

    -- Bottom details: fully above tab bar -------------------------------------
    local details=WINDOW_MANAGER:CreateControl(nil,page,CT_BACKDROP)
    details:SetDimensions(914,88)
    details:SetAnchor(TOPLEFT,page,TOPLEFT,20,532)
    details:SetCenterColor(0.020,0.019,0.016,0.99)
    details:SetEdgeColor(0.45,0.36,0.16,0.92)
    details:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds",128,16,2)

    local detailsTitle=WINDOW_MANAGER:CreateControl(nil,details,CT_LABEL)
    detailsTitle:SetDimensions(860,18)
    detailsTitle:SetAnchor(TOPLEFT,details,TOPLEFT,14,5)
    detailsTitle:SetFont("$(BOLD_FONT)|14")
    detailsTitle:SetColor(0.91,0.75,0.30,1)
    self.statisticsAllianceDetailsTitle=detailsTitle

    self.statisticsAllianceDetailRows={}
    for i=1,8 do
        local col=(i-1)%4
        local rowIndex=math.floor((i-1)/4)
        local cell=WINDOW_MANAGER:CreateControl(nil,details,CT_CONTROL)
        cell:SetDimensions(215,30)
        cell:SetAnchor(TOPLEFT,details,TOPLEFT,14+col*224,25+rowIndex*31)

        local label=WINDOW_MANAGER:CreateControl(nil,cell,CT_LABEL)
        label:SetDimensions(130,11)
        label:SetAnchor(TOPLEFT,cell,TOPLEFT,0,0)
        label:SetFont("$(MEDIUM_FONT)|8")
        label:SetColor(0.80,0.77,0.69,1)

        local value=WINDOW_MANAGER:CreateControl(nil,cell,CT_LABEL)
        value:SetDimensions(78,11)
        value:SetAnchor(TOPRIGHT,cell,TOPRIGHT,0,0)
        value:SetFont("$(BOLD_FONT)|8")
        value:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        value:SetColor(0.93,0.82,0.42,1)

        local back=WINDOW_MANAGER:CreateControl(nil,cell,CT_BACKDROP)
        back:SetDimensions(215,5)
        back:SetAnchor(TOPLEFT,cell,TOPLEFT,0,13)
        back:SetCenterColor(0.055,0.050,0.040,1)
        back:SetEdgeColor(0.22,0.19,0.13,0.85)
        back:SetEdgeTexture(nil,1,1,1)

        local fill=WINDOW_MANAGER:CreateControl(nil,back,CT_BACKDROP)
        fill:SetDimensions(1,4)
        fill:SetAnchor(LEFT,back,LEFT,1,0)
        fill:SetEdgeColor(0,0,0,0)

        local remain=WINDOW_MANAGER:CreateControl(nil,cell,CT_LABEL)
        remain:SetDimensions(215,9)
        remain:SetAnchor(TOPLEFT,cell,TOPLEFT,0,19)
        remain:SetFont("$(MEDIUM_FONT)|7")
        remain:SetColor(0.57,0.55,0.50,1)
        remain:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

        self.statisticsAllianceDetailRows[i]={label=label,value=value,bar=fill,remain=remain}
    end

    self.statisticsAllianceNote=WINDOW_MANAGER:CreateControl(nil,page,CT_LABEL)
    self.statisticsAllianceNote:SetDimensions(900,10)
    self.statisticsAllianceNote:SetAnchor(BOTTOM,page,BOTTOM,0,1)
    self.statisticsAllianceNote:SetFont("$(MEDIUM_FONT)|7")
    self.statisticsAllianceNote:SetColor(0.48,0.46,0.42,1)
    self.statisticsAllianceNote:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
end

function TPM:RefreshAllianceStatisticsPage()
    if not self.statisticsAlliancePage or self.statisticsAlliancePage:IsHidden() then return end

    local _,allianceName,ownGroup=self:GetPlayerAllianceDisplay()
    local data=self:GetAllianceStatisticsData()
    local ownRow=ownGroup and data[ownGroup] or nil

    self.statisticsAllianceOwnTitle:SetText(self:L("STAT_ALLIANCE_YOURS"))
    self.statisticsAllianceOwnName:SetText(allianceName)
    self.statisticsAllianceOwnPercent:SetText(string.format("%d%%",ownRow and ownRow.percent or 0))

    local ownColor={0.78,0.62,0.22}
    if ownGroup and self.statisticsAllianceCards and self.statisticsAllianceCards[ownGroup] then
        ownColor=self.statisticsAllianceCards[ownGroup].color or ownColor
    end
    self.statisticsAllianceOwnBar:SetCenterColor(ownColor[1],ownColor[2],ownColor[3],0.95)
    local ownPct=Clamp(tonumber(ownRow and ownRow.percent) or 0,0,100)
    self.statisticsAllianceOwnBar:SetWidth(math.max(1,math.floor(878*ownPct/100)))

    if not self.statisticsAllianceSelectedGroup then
        self.statisticsAllianceSelectedGroup=ownGroup or "DC"
    end

    for group,card in pairs(self.statisticsAllianceCards or {}) do
        local row=data[group] or {percent=0,zonesCompleted=0,zonesTotal=0,completed=0,total=0}
        card.title:SetText(self:L(card.label))
        card.badge:SetText(ownGroup==group and self:L("STAT_ALLIANCE_YOURS_SHORT") or "")
        card.percent:SetText(string.format("%d%%",row.percent or 0))
        card.zones:SetText(string.format("%d/%d %s",row.zonesCompleted or 0,row.zonesTotal or 0,self:L("STAT_ALLIANCE_ZONES_SHORT")))
        card.objectives:SetText(string.format("%d/%d",row.completed or 0,row.total or 0))
        local pct=Clamp(tonumber(row.percent) or 0,0,100)
        card.bar:SetWidth(math.max(1,math.floor(192*pct/100)))

        local selected=self.statisticsAllianceSelectedGroup==group
        if selected then
            card.control:SetCenterColor(math.min(0.12,card.color[1]*0.10),math.min(0.12,card.color[2]*0.10),math.min(0.12,card.color[3]*0.10),1)
            card.control:SetEdgeColor(card.color[1],card.color[2],card.color[3],1)
        else
            card.control:SetCenterColor(0.022,0.021,0.018,0.99)
            card.control:SetEdgeColor(card.color[1],card.color[2],card.color[3],0.68)
        end
    end

    local selectedGroup=self.statisticsAllianceSelectedGroup or ownGroup or "DC"
    if selectedGroup~="DC" and selectedGroup~="AD" and selectedGroup~="EP" then
        selectedGroup=ownGroup or "DC"
        self.statisticsAllianceSelectedGroup=selectedGroup
    end

    local selectedCard=self.statisticsAllianceCards and self.statisticsAllianceCards[selectedGroup]
    local selectedName=selectedCard and self:L(selectedCard.label) or selectedGroup
    local selectedColor=selectedCard and selectedCard.color or {0.78,0.62,0.22}
    local territoryColors = true

    if self.statisticsAllianceMapFrame then
        if territoryColors then
            self.statisticsAllianceMapFrame:SetEdgeColor(selectedColor[1],selectedColor[2],selectedColor[3],1)
        else
            self.statisticsAllianceMapFrame:SetEdgeColor(0.72,0.56,0.18,0.95)
        end
    end
    if self.statisticsAllianceLegend then
        self.statisticsAllianceLegend:SetHidden(false)
    end
    if self.statisticsAllianceMapPanel then
        self.statisticsAllianceMapPanel:SetEdgeColor(selectedColor[1],selectedColor[2],selectedColor[3],0.82)
    end
    if self.statisticsAllianceMapTexture then
        self.statisticsAllianceMapTexture:SetTexture("TamrielProgressMap/art/alliance_community_map.dds")
    end
    if self.statisticsAllianceMapTitle then
        self.statisticsAllianceMapTitle:SetText(self:L("STAT_ALLIANCE_PLANNER_TITLE",selectedName))
    end
    local nextTarget,biggestGap,zoneRows=self:GetAlliancePlannerRecommendations(selectedGroup)

    local selectedStats=data[selectedGroup] or {zonesCompleted=0,zonesTotal=0,completed=0,total=0}
    local zoneOpen=math.max(0,(selectedStats.zonesTotal or 0)-(selectedStats.zonesCompleted or 0))
    local objOpen=math.max(0,(selectedStats.total or 0)-(selectedStats.completed or 0))
    if self.statisticsAllianceQuickDone then
        self.statisticsAllianceQuickDone:SetText(self:L("STAT_ALLIANCE_QUICK_DONE",
            selectedStats.zonesCompleted or 0, selectedStats.zonesTotal or 0))
    end
    if self.statisticsAllianceQuickOpen then
        self.statisticsAllianceQuickOpen:SetText(self:L("STAT_ALLIANCE_QUICK_OPEN",
            zoneOpen, objOpen))
    end
    if self.statisticsAllianceQuickNext then
        if nextTarget then
            self.statisticsAllianceQuickNext:SetText(self:L("STAT_ALLIANCE_QUICK_NEXT",
                nextTarget.name, nextTarget.percent))
        else
            self.statisticsAllianceQuickNext:SetText(self:L("STAT_ALLIANCE_COMPLETE"))
        end
    end
    if self.statisticsAllianceNextTitle then self.statisticsAllianceNextTitle:SetText(self:L("STAT_ALLIANCE_NEXT_TARGET")) end
    if self.statisticsAllianceGapTitle then self.statisticsAllianceGapTitle:SetText(self:L("STAT_ALLIANCE_BIGGEST_GAP")) end
    if self.statisticsAllianceNextValue then
        if nextTarget then
            self.statisticsAllianceNextValue:SetText(string.format("%s  %d%%  •  %d %s",
                nextTarget.name,nextTarget.percent,nextTarget.remaining,self:L("STAT_ALLIANCE_REMAINING_SHORT")))
        else
            self.statisticsAllianceNextValue:SetText(self:L("STAT_ALLIANCE_COMPLETE"))
        end
    end
    if self.statisticsAllianceGapValue then
        if biggestGap then
            self.statisticsAllianceGapValue:SetText(string.format("%s  %d%%  •  %d %s",
                biggestGap.name,biggestGap.percent,biggestGap.remaining,self:L("STAT_ALLIANCE_REMAINING_SHORT")))
        else
            self.statisticsAllianceGapValue:SetText(self:L("STAT_ALLIANCE_COMPLETE"))
        end
    end

    if self.statisticsAllianceZoneTitle then
        self.statisticsAllianceZoneTitle:SetText(self:L("STAT_ALLIANCE_ZONE_PROGRESS"))
    end
    if self.statisticsAllianceZoneHint then
        self.statisticsAllianceZoneHint:SetText(self:L("STAT_ALLIANCE_ZONE_CLICK_HINT"))
    end

    for i,controls in ipairs(self.statisticsAllianceZoneRows or {}) do
        local z=zoneRows[i]
        if z then
            controls.control:SetHidden(false)
            controls.control.zoneId=z.zoneId
            controls.name:SetText(z.name)
            controls.pct:SetText(string.format("%d%%",z.percent))
            controls.count:SetText(string.format("%d/%d  •  %d %s",z.completed,z.total,z.remaining,self:L("STAT_ALLIANCE_REMAINING_SHORT")))
            controls.bar:SetWidth(math.max(1,math.floor(162*z.percent/100)))
            if z.complete then
                controls.pct:SetColor(0.95,0.82,0.30,1)
                controls.bar:SetCenterColor(0.90,0.72,0.20,0.98)
            elseif z.percent>=75 then
                controls.pct:SetColor(0.72,0.90,0.36,1)
                controls.bar:SetCenterColor(0.58,0.80,0.24,0.95)
            elseif z.percent>=40 then
                controls.pct:SetColor(0.92,0.74,0.30,1)
                if territoryColors then
                    controls.bar:SetCenterColor(selectedColor[1],selectedColor[2],selectedColor[3],0.96)
                else
                    controls.bar:SetCenterColor(0.70,0.52,0.18,0.92)
                end
            else
                controls.pct:SetColor(0.96,0.45,0.30,1)
                controls.bar:SetCenterColor(0.82,0.28,0.16,0.92)
            end
        else
            controls.control.zoneId=nil
            controls.control:SetHidden(true)
        end
    end

    self.statisticsAllianceDetailsTitle:SetText(selectedName.."  •  "..self:L("STAT_ALLIANCE_PROGRESS_DETAILS"))
    local detailRows=self:GetAllianceCategoryStatisticsData(selectedGroup)
    for i,controls in ipairs(self.statisticsAllianceDetailRows or {}) do
        local row=detailRows[i]
        if row then
            local remaining=math.max(0,(row.total or 0)-(row.completed or 0))
            controls.label:SetText(row.label)
            controls.value:SetText(string.format("%d/%d  %d%%",row.completed or 0,row.total or 0,row.percent or 0))
            controls.remain:SetText(string.format("%d %s",remaining,self:L("STAT_ALLIANCE_REMAINING_SHORT")))
            controls.bar:SetWidth(math.max(1,math.floor(213*(row.percent or 0)/100)))
            if (row.percent or 0)>=100 then
                controls.bar:SetCenterColor(0.90,0.72,0.20,0.98)
            else
                controls.bar:SetCenterColor(selectedColor[1],selectedColor[2],selectedColor[3],0.92)
            end
        else
            controls.label:SetText("")
            controls.value:SetText("")
            controls.remain:SetText("")
            controls.bar:SetWidth(1)
        end
    end

    self:RefreshAlliancePlannerMapView()
    self.statisticsAllianceNote:SetText(self:L("STAT_ALLIANCE_PLANNER_NOTE"))
end

function TPM:IsValidStatisticsPage(page)
    return page == "progress" or page == "economy" or page == "history" or page == "alliance"
end

function TPM:UpdateStatisticsPageVisibility(page)
    if not self:IsValidStatisticsPage(page) then page = "progress" end
    if self.statisticsProgressPage then self.statisticsProgressPage:SetHidden(page ~= "progress") end
    if self.statisticsPlayerPage then self.statisticsPlayerPage:SetHidden(true) end
    if self.statisticsEconomyPage then self.statisticsEconomyPage:SetHidden(page ~= "economy") end
    if self.statisticsHistoryPage then self.statisticsHistoryPage:SetHidden(page ~= "history") end
    if self.statisticsAlliancePage then self.statisticsAlliancePage:SetHidden(page ~= "alliance") end
    if self.statisticsListArea then self.statisticsListArea:SetMouseEnabled(page == "progress") end
    if self.statisticsScrollBar then self.statisticsScrollBar:SetMouseEnabled(page == "progress") end
end

function TPM:RefreshStatisticsPageTabs()
    local page = self.saved and self.saved.statisticsPage or "progress"
    if not self:IsValidStatisticsPage(page) then page = "progress" end
    local tabs = {
        { self.statisticsProgressTab, "progress", "STAT_TAB_PROGRESS" },
        { self.statisticsEconomyTab, "economy", "STAT_TAB_ECONOMY" },
        { self.statisticsHistoryTab, "history", "STAT_TAB_HISTORY" },
        { self.statisticsAllianceTab, "alliance", "STAT_TAB_ALLIANCE" },
    }
    for _, item in ipairs(tabs) do
        local control, key, labelKey = item[1], item[2], item[3]
        if control then
            local selected = page == key
            local label = self:L(labelKey)
            control:SetText((selected and "|cE6C45C" or "") .. label .. (selected and "|r" or ""))
            if control.TPMAccent then control.TPMAccent:SetHidden(not selected) end
            if control.TPMBackdrop then
                if selected then
                    control.TPMBackdrop:SetCenterColor(0.095, 0.072, 0.024, 0.98)
                    control.TPMBackdrop:SetEdgeColor(0.86, 0.66, 0.18, 0.96)
                else
                    control.TPMBackdrop:SetCenterColor(0.026, 0.023, 0.018, 0.94)
                    control.TPMBackdrop:SetEdgeColor(0.36, 0.29, 0.14, 0.70)
                end
            end
        end
    end
end

function TPM:SetStatisticsPage(page)
    self:HideEconomyFocusDropdown()
    self:HideStatisticsHoverTooltips()
    self:HideStatisticsFocusDropdown()
    if not self:IsValidStatisticsPage(page) then page = "progress" end
    if self.saved then self.saved.statisticsPage = page end
    self:UpdateStatisticsPageVisibility(page)
    self:RefreshStatisticsPageTabs()
    self:RefreshStatisticsLanguageBar()
    self:RefreshStatisticsWindow()
end
function TPM:SetProgressStatisticsControlsHidden(hidden)
    if self.statisticsProgressPage then self.statisticsProgressPage:SetHidden(hidden) end
    if self.statisticsListArea then self.statisticsListArea:SetMouseEnabled(not hidden) end
    if self.statisticsScrollBar then self.statisticsScrollBar:SetMouseEnabled(not hidden) end
end

function TPM:RefreshPlayerStatisticsPage()
    if not self.statisticsPlayerPage or self.statisticsPlayerPage:IsHidden() then return end
    local stats = self:GetPlayerCombatStatsView()
    local progress = self:GetPlayerProgressData()
    local characterName = type(GetUnitName) == "function" and (GetUnitName("player") or "") or ""
    if type(zo_strformat) == "function" and characterName ~= "" then
        characterName = zo_strformat("<<C:1>>", characterName)
    end
    if characterName == "" then characterName = self:L("STAT_PLAYER_UNKNOWN") end

    self.statisticsPlayerPageTitle:SetText(self:L("STAT_PLAYER_PAGE_TITLE"))
    self.statisticsPlayerPageSubtitle:SetText(self:L("STAT_PLAYER_PAGE_SUBTITLE"))
    self.statisticsPlayerProfileTitle:SetText(self:L("STAT_PLAYER_PROFILE"))
    self.statisticsPlayerProfileText:SetText(self:L("STAT_PLAYER_PROFILE_LINE", characterName, progress.level, progress.championPoints))
    self.statisticsPlayerPvpTitle:SetText(self:L("STAT_PLAYER_PVP"))
    self.statisticsPlayerPveTitle:SetText(self:L("STAT_PLAYER_PVE"))
    self.statisticsPlayerTrackingTitle:SetText(self:L("STAT_PLAYER_TRACKING"))
    self.statisticsPlayerTrackingText:SetText(self:L("STAT_PLAYER_TRACKING_NOTE", stats.trackingVersion))

    local cards = self.statisticsPlayerCards or {}
    if cards.pvpKills then
        cards.pvpKills.title:SetText(self:L("STAT_PVP_KILLS"))
        cards.pvpKills.value:SetText(FormatNumber(stats.pvpKills))
    end
    if cards.pvpDeaths then
        cards.pvpDeaths.title:SetText(self:L("STAT_PVP_DEATHS"))
        cards.pvpDeaths.value:SetText(FormatNumber(stats.pvpDeaths))
    end
    if cards.pvpKd then
        cards.pvpKd.title:SetText(self:L("STAT_PVP_KD"))
        local kdText
        if stats.pvpDeaths <= 0 and stats.pvpKills > 0 then
            kdText = "∞"
        else
            kdText = string.format("%.2f", stats.kd or 0)
        end
        cards.pvpKd.value:SetText(kdText)
    end
    if cards.npcKills then
        cards.npcKills.title:SetText(self:L("STAT_NPC_KILLS"))
        cards.npcKills.value:SetText(FormatNumber(stats.npcKills))
    end
    if cards.bossKills then
        cards.bossKills.title:SetText(self:L("STAT_BOSS_KILLS"))
        cards.bossKills.value:SetText(FormatNumber(stats.bossKills))
    end
    if cards.playTime then
        local esoPlayed = self:GetEsoPlayedSeconds()
        local sinceTpm = self:GetCurrentPlaySeconds()
        local accountKnown = self:GetKnownAccountEsoPlayedSeconds()
        cards.playTime.title:SetText(self:L("STAT_PLAY_TIME"))
        cards.playTime.value:SetText(TPM_FormatDuration(esoPlayed))
        if cards.playTime.detail then
            cards.playTime.detail:SetText(self:L("STAT_PLAY_TIME_DETAIL", TPM_FormatDuration(sinceTpm), TPM_FormatDuration(accountKnown)))
        end
    end
end


function TPM:CreateGoalCard(parent, name, y)
    local card = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    card:SetDimensions(932, 82)
    card:SetAnchor(TOPLEFT, parent, TOPLEFT, 20, y)
    card:SetCenterColor(0.045, 0.037, 0.026, 0.96)
    card:SetEdgeColor(0.42, 0.34, 0.17, 0.72)
    card:SetEdgeTexture(nil, 1, 1, 1)
    card:SetMouseEnabled(true)

    local nameLabel = WINDOW_MANAGER:CreateControl(nil, card, CT_LABEL)
    nameLabel:SetDimensions(570, 28)
    nameLabel:SetAnchor(TOPLEFT, card, TOPLEFT, 14, 9)
    nameLabel:SetFont("$(BOLD_FONT)|20")
    nameLabel:SetColor(0.90, 0.82, 0.60, 1)
    nameLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    nameLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    card.nameLabel = nameLabel

    local percent = WINDOW_MANAGER:CreateControl(nil, card, CT_LABEL)
    percent:SetDimensions(120, 30)
    percent:SetAnchor(TOPRIGHT, card, TOPRIGHT, -14, 8)
    percent:SetFont("$(ANTIQUE_FONT)|26")
    percent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    percent:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    card.percentLabel = percent

    local detail = WINDOW_MANAGER:CreateControl(nil, card, CT_LABEL)
    detail:SetDimensions(710, 28)
    detail:SetAnchor(TOPLEFT, card, TOPLEFT, 14, 42)
    detail:SetFont("$(MEDIUM_FONT)|16")
    detail:SetColor(0.70, 0.67, 0.60, 1)
    detail:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    detail:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    card.detailLabel = detail

    local open = WINDOW_MANAGER:CreateControl(nil, card, CT_LABEL)
    open:SetDimensions(190, 26)
    open:SetAnchor(BOTTOMRIGHT, card, BOTTOMRIGHT, -14, -10)
    open:SetFont("$(BOLD_FONT)|16")
    open:SetColor(0.90, 0.72, 0.42, 1)
    open:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    open:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    card.openLabel = open

    card:SetHandler("OnMouseEnter", function(c)
        c:SetCenterColor(0.11, 0.085, 0.040, 0.98)
        local data = c.goalData
        if data then
            local lines = { TPM:L("GOAL_TOOLTIP_HEADER", data.percent or 0, data.remaining or 0) }
            for _, item in ipairs(data.missing or {}) do
                lines[#lines + 1] = TPM:L("GOAL_TOOLTIP_LINE", item.name or "", item.remaining or 0)
            end
            TPM:ShowStatisticsHoverTooltip(data.name or "", table.concat(lines, "\n"), c)
        end
    end)
    card:SetHandler("OnMouseExit", function(c)
        c:SetCenterColor(0.045, 0.037, 0.026, 0.96)
        TPM:HideStatisticsHoverTooltips()
    end)
    card:SetHandler("OnMouseUp", function(c, button, upInside)
        if not upInside or button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if c.mapId and c.mapId > 0 then
            TPM:OpenWorldMapFromStatistics(c.mapId)
        end
    end)
    return card
end

function TPM:CreateGoalsStatisticsPage(control)
    if self.statisticsGoalsPage then return end
    local page = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsGoalsPage", control, CT_BACKDROP)
    page:SetAnchor(TOPLEFT, control, TOPLEFT, 14, 60)
    page:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -14, -55)
    page:SetCenterColor(0.075, 0.061, 0.038, 1.00)
    page:SetEdgeColor(0.26, 0.21, 0.12, 0.90)
    page:SetEdgeTexture(nil, 1, 1, 1)
    page:SetMouseEnabled(true)
    page:SetHidden(true)
    self.statisticsGoalsPage = page

    local title = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
    title:SetDimensions(920, 34)
    title:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 14)
    title:SetFont("ZoFontWinH3")
    title:SetColor(0.90, 0.77, 0.34, 1)
    title:SetHidden(true)
    self.statisticsGoalsTitle = title

    local subtitle = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
    subtitle:SetDimensions(920, 24)
    subtitle:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 16)
    subtitle:SetFont("$(MEDIUM_FONT)|17")
    subtitle:SetColor(0.70, 0.67, 0.60, 1)
    self.statisticsGoalsSubtitle = subtitle

    self.statisticsGoalModeButtons = {}
    local labels = { near = "GOAL_MODE_NEAR", recommended = "GOAL_MODE_RECOMMENDED" }
    for i, mode in ipairs(GOAL_PLANNER_MODES) do
        local button = WINDOW_MANAGER:CreateControl(nil, page, CT_BUTTON)
        button:SetDimensions(190, 30)
        button:SetAnchor(TOPLEFT, page, TOPLEFT, 20 + ((i - 1) * 200), 52)
        button:SetFont("$(BOLD_FONT)|16")
        button:SetNormalFontColor(0.78, 0.72, 0.58, 1)
        button:SetMouseOverFontColor(1.00, 0.84, 0.36, 1)
        button:SetPressedFontColor(0.90, 0.72, 0.28, 1)
        button.mode = mode
        button.labelKey = labels[mode]
        button:SetHandler("OnClicked", function(btn) TPM:SetGoalPlannerMode(btn.mode) end)
        self.statisticsGoalModeButtons[#self.statisticsGoalModeButtons + 1] = button
    end

    local categoryButton = WINDOW_MANAGER:CreateControl(nil, page, CT_BUTTON)
    categoryButton:SetDimensions(300, 30)
    categoryButton:SetAnchor(TOPRIGHT, page, TOPRIGHT, -20, 52)
    categoryButton:SetFont("$(BOLD_FONT)|16")
    categoryButton:SetNormalFontColor(0.78, 0.72, 0.58, 1)
    categoryButton:SetMouseOverFontColor(1.00, 0.84, 0.36, 1)
    categoryButton:SetPressedFontColor(0.90, 0.72, 0.28, 1)
    categoryButton:SetHandler("OnClicked", function() TPM:CycleGoalPlannerCategory(1) end)
    self.statisticsGoalCategoryButton = categoryButton

    self.statisticsGoalCards = {}
    for i = 1, 5 do
        self.statisticsGoalCards[i] = self:CreateGoalCard(page, ADDON_NAME .. "GoalCard" .. tostring(i), 94 + ((i - 1) * 90))
    end

    local note = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
    note:SetDimensions(930, 42)
    note:SetAnchor(BOTTOMLEFT, page, BOTTOMLEFT, 20, -18)
    note:SetFont("$(MEDIUM_FONT)|15")
    note:SetColor(0.65, 0.62, 0.55, 1)
    note:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    note:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsGoalsNote = note
end

function TPM:RefreshGoalsStatisticsPage()
    if not self.statisticsGoalsPage or self.statisticsGoalsPage:IsHidden() then return end
    local mode = self.saved and self.saved.goalPlannerMode or "near"
    local category = self:GetGoalPlannerCategoryDefinition()
    self.statisticsGoalsTitle:SetText(self:L("GOAL_PAGE_TITLE"))
    self.statisticsGoalsSubtitle:SetText(self:L("GOAL_PAGE_SUBTITLE"))
    self.statisticsGoalsNote:SetText(self:L("GOAL_PAGE_NOTE"))
    for _, button in ipairs(self.statisticsGoalModeButtons or {}) do
        local label = self:L(button.labelKey)
        if button.mode == mode then label = "|cE6C45C" .. label .. "|r" end
        button:SetText(label)
    end
    if self.statisticsGoalCategoryButton then
        self.statisticsGoalCategoryButton:SetText(self:L("GOAL_CATEGORY_FILTER", self:L(category.labelKey)))
    end
    local rows = self:GetGoalPlannerData(mode, category.key)
    for i, card in ipairs(self.statisticsGoalCards or {}) do
        local row = rows[i]
        card:SetHidden(row == nil)
        if row then
            card.mapId = row.mapId
            card.zoneId = row.zoneId
            card.goalData = row
            card.nameLabel:SetText(row.name)
            card.percentLabel:SetText(string.format("|c%s%d%%|r", self:GetStatisticsPercentTextColor(row.percent), row.percent))
            card.detailLabel:SetText(row.detail)
            card.openLabel:SetText(self:L("GOAL_OPEN_MAP", row.remaining))
        else
            card.mapId, card.zoneId, card.goalData = nil, nil, nil
        end
    end
end

function TPM:CreateHistorySummaryCard(parent, name, x, width)
    local card = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    card:SetDimensions(width, 74)
    card:SetAnchor(TOPLEFT, parent, TOPLEFT, x, 82)
    card:SetCenterColor(0.028, 0.024, 0.018, 0.985)
    card:SetEdgeColor(0.48, 0.36, 0.12, 0.82)
    card:SetEdgeTexture(nil, 1, 1, 1)
    local title = WINDOW_MANAGER:CreateControl(nil, card, CT_LABEL)
    title:SetDimensions(width - 16, 22)
    title:SetAnchor(TOPLEFT, card, TOPLEFT, 8, 7)
    title:SetFont("$(BOLD_FONT)|15")
    title:SetColor(0.82, 0.78, 0.70, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    local value = WINDOW_MANAGER:CreateControl(nil, card, CT_LABEL)
    value:SetDimensions(width - 16, 34)
    value:SetAnchor(TOPLEFT, card, TOPLEFT, 8, 30)
    value:SetFont("$(ANTIQUE_FONT)|25")
    value:SetColor(0.95, 0.82, 0.36, 1)
    value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    return { control = card, title = title, value = value }
end

function TPM:CreateHistoryStatisticsPage(control)
    if self.statisticsHistoryPage then return end
    local page = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsHistoryPage", control, CT_BACKDROP)
    page:SetAnchor(TOPLEFT, control, TOPLEFT, 14, 60)
    page:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -14, -55)
    page:SetCenterColor(0.040, 0.035, 0.026, 1.00)
    page:SetEdgeColor(0.44, 0.34, 0.10, 0.95)
    page:SetEdgeTexture(nil, 1, 1, 1)
    page:SetMouseEnabled(true)
    page:SetHidden(true)
    self.statisticsHistoryPage = page

    local title = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
    title:SetDimensions(380, 34)
    title:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 14)
    title:SetFont("ZoFontWinH3")
    title:SetColor(0.90, 0.77, 0.34, 1)
    title:SetHidden(true)
    self.statisticsHistoryTitle = title

    local prev = WINDOW_MANAGER:CreateControl(nil, page, CT_BUTTON)
    prev:SetDimensions(42, 28)
    prev:SetAnchor(TOPLEFT, page, TOPLEFT, 145, 15)
    prev:SetFont("$(BOLD_FONT)|22")
    prev:SetText("<")
    prev:SetHandler("OnClicked", function() TPM:CycleHistoryMetric(-1) end)
    prev:SetHidden(true)
    prev:SetMouseEnabled(false)
    self.statisticsHistoryPrevButton = prev

    local metric = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
    metric:SetDimensions(760, 30)
    metric:SetAnchor(TOP, page, TOP, 0, 15)
    metric:SetFont("$(BOLD_FONT)|18")
    metric:SetColor(0.92, 0.82, 0.55, 1)
    metric:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsHistoryMetricLabel = metric

    local next = WINDOW_MANAGER:CreateControl(nil, page, CT_BUTTON)
    next:SetDimensions(42, 28)
    next:SetAnchor(TOPLEFT, page, TOPLEFT, 748, 15)
    next:SetFont("$(BOLD_FONT)|22")
    next:SetText(">")
    next:SetHandler("OnClicked", function() TPM:CycleHistoryMetric(1) end)
    next:SetHidden(true)
    next:SetMouseEnabled(false)
    self.statisticsHistoryNextButton = next

    self.statisticsHistoryRangeButtons = {}
    self.statisticsHistoryRangeBackdrops = {}
    for i, days in ipairs({7, 30, 90, 365, 730}) do
        local bg = WINDOW_MANAGER:CreateControl(nil, page, CT_BACKDROP)
        bg:SetDimensions(66, 28)
        bg:SetAnchor(TOPRIGHT, page, TOPRIGHT, -18 - ((5 - i) * 68), 48)
        bg:SetCenterColor(0.035, 0.031, 0.025, 0.96)
        bg:SetEdgeColor(0.30, 0.25, 0.15, 0.95)
        bg:SetEdgeTexture(nil, 1, 1, 1)
        self.statisticsHistoryRangeBackdrops[i] = bg

        local button = WINDOW_MANAGER:CreateControl(nil, page, CT_BUTTON)
        button:SetDimensions(66, 28)
        button:SetAnchor(CENTER, bg, CENTER, 0, 0)
        button:SetFont("$(BOLD_FONT)|15")
        button.days = days
        button:SetHandler("OnClicked", function(btn) TPM:SetHistoryRange(btn.days) end)
        self.statisticsHistoryRangeButtons[#self.statisticsHistoryRangeButtons + 1] = button
    end

    local pveHeading = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
    pveHeading:SetDimensions(440, 28)
    pveHeading:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 48)
    pveHeading:SetFont("$(BOLD_FONT)|18")
    pveHeading:SetColor(0.55, 0.82, 0.24, 1)
    pveHeading:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    pveHeading:SetText(self:L("HISTORY_PVE_HEADING"))
    pveHeading:SetHidden(true)
    self.statisticsCombatPveHeading = pveHeading

    local bossBadge = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "CombatBossBadge", page, CT_BACKDROP)
    bossBadge:SetDimensions(174, 28)
    bossBadge:SetAnchor(TOPLEFT, page, TOPLEFT, 286, 48)
    bossBadge:SetCenterColor(0.045, 0.036, 0.020, 0.98)
    bossBadge:SetEdgeColor(0.82, 0.62, 0.16, 0.82)
    bossBadge:SetEdgeTexture(nil, 1, 1, 1)
    bossBadge:SetHidden(true)
    bossBadge:SetMouseEnabled(false)

    local bossIcon = WINDOW_MANAGER:CreateControl(nil, bossBadge, CT_TEXTURE)
    bossIcon:SetDimensions(24, 24)
    bossIcon:SetAnchor(LEFT, bossBadge, LEFT, 5, 0)
    bossIcon:SetTexture("EsoUI/Art/LFG/Gamepad/LFG_activityIcon_veteranDungeon.dds")
    -- Preserve the original ESO artwork instead of recoloring the texture itself.
    bossIcon:SetColor(1, 1, 1, 1)

    local bossText = WINDOW_MANAGER:CreateControl(nil, bossBadge, CT_LABEL)
    bossText:SetDimensions(136, 24)
    bossText:SetAnchor(LEFT, bossIcon, RIGHT, 6, 0)
    bossText:SetFont("$(BOLD_FONT)|14")
    bossText:SetColor(0.92, 0.84, 0.62, 1)
    bossText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    bossText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsCombatBossBadge = bossBadge
    self.statisticsCombatBossText = bossText

    -- Leave room in the PvE heading for the compact boss counter.
    pveHeading:SetDimensions(250, 28)

    local pvpHeading = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
    pvpHeading:SetDimensions(440, 28)
    pvpHeading:SetAnchor(TOPRIGHT, page, TOPRIGHT, -20, 48)
    pvpHeading:SetFont("$(BOLD_FONT)|18")
    pvpHeading:SetColor(0.34, 0.67, 0.95, 1)
    pvpHeading:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    pvpHeading:SetText(self:L("HISTORY_PVP_HEADING"))
    pvpHeading:SetHidden(true)
    self.statisticsCombatPvpHeading = pvpHeading

    self.statisticsHistorySummaryCards = {
        current = self:CreateHistorySummaryCard(page, ADDON_NAME .. "HistoryCurrent", 20, 218),
        change = self:CreateHistorySummaryCard(page, ADDON_NAME .. "HistoryChange", 252, 218),
        income = self:CreateHistorySummaryCard(page, ADDON_NAME .. "HistoryIncome", 20, 142),
        expenses = self:CreateHistorySummaryCard(page, ADDON_NAME .. "HistoryExpenses", 174, 142),
        net = self:CreateHistorySummaryCard(page, ADDON_NAME .. "HistoryNet", 328, 142),
        high = self:CreateHistorySummaryCard(page, ADDON_NAME .. "HistoryHigh", 484, 218),
        low = self:CreateHistorySummaryCard(page, ADDON_NAME .. "HistoryLow", 716, 236),
    }

    -- 3.4.18: Prefer original ESO UI artwork for the combat dashboard.
    -- These textures ship with the game and therefore match the native UI.
    local combatAssets = {
        current = "EsoUI/Art/LFG/LFG_dps_down_no_glow_64.dds",
        change = "EsoUI/Art/DeathRecap/deathRecap_killingBlow_icon.dds",
        high = "EsoUI/Art/Battlegrounds/Gamepad/gp_battlegrounds_tabIcon_deathmatch.dds",
        low = "EsoUI/Art/DeathRecap/deathRecap_killingBlow_icon.dds",
    }
    self.statisticsCombatCardExtras = {}
    local combatAccent = {
        current = {0.49,0.78,0.27},
        change  = {0.94,0.31,0.24},
        high    = {0.36,0.62,0.91},
        low     = {0.94,0.31,0.24},
    }
    for key, texturePath in pairs(combatAssets) do
        local card = self.statisticsHistorySummaryCards[key]
        local accentColor = combatAccent[key] or {0.90,0.77,0.34}
        local accent = WINDOW_MANAGER:CreateControl(nil, card.control, CT_BACKDROP)
        accent:SetDimensions(4, 82)
        accent:SetAnchor(LEFT, card.control, LEFT, 0, 0)
        accent:SetCenterColor(accentColor[1], accentColor[2], accentColor[3], 0.92)
        accent:SetEdgeColor(0,0,0,0)
        accent:SetHidden(true)

        local iconBack = WINDOW_MANAGER:CreateControl(nil, card.control, CT_BACKDROP)
        iconBack:SetDimensions(72, 72)
        iconBack:SetAnchor(LEFT, card.control, LEFT, 12, 0)
        iconBack:SetCenterColor(accentColor[1] * 0.10, accentColor[2] * 0.10, accentColor[3] * 0.10, 0.98)
        iconBack:SetEdgeColor(accentColor[1], accentColor[2], accentColor[3], 0.72)
        iconBack:SetEdgeTexture(nil, 1, 1, 1)
        iconBack:SetHidden(true)

        local icon = WINDOW_MANAGER:CreateControl(nil, card.control, CT_TEXTURE)
        icon:SetDimensions(66, 66)
        icon:SetAnchor(CENTER, iconBack, CENTER, 0, 0)
        icon:SetTexture(texturePath)
        icon:SetColor(1, 1, 1, 1)
        icon:SetHidden(true)

        local delta = WINDOW_MANAGER:CreateControl(nil, card.control, CT_LABEL)
        delta:SetDimensions(128, 22)
        delta:SetAnchor(BOTTOMRIGHT, card.control, BOTTOMRIGHT, -9, -8)
        delta:SetFont("$(BOLD_FONT)|14")
        delta:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        delta:SetHidden(true)
        self.statisticsCombatCardExtras[key] = { icon = icon, iconBack = iconBack, accent = accent, delta = delta }
    end

    local chart = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "HistoryChart", page, CT_BACKDROP)
    chart:SetDimensions(932, 292)
    chart:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 198)
    chart:SetCenterColor(0.014, 0.014, 0.013, 0.995)
    chart:SetEdgeColor(0.52, 0.39, 0.10, 0.98)
    chart:SetEdgeTexture(nil, 1, 1, 1)
    self.statisticsHistoryChart = chart

    local chartTitle = WINDOW_MANAGER:CreateControl(nil, chart, CT_LABEL)
    chartTitle:SetDimensions(500, 28)
    chartTitle:SetAnchor(TOP, chart, TOP, 0, 10)
    chartTitle:SetFont("$(BOLD_FONT)|19")
    chartTitle:SetColor(0.90, 0.77, 0.34, 1)
    chartTitle:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    chartTitle:SetHidden(true)
    self.statisticsCombatChartTitle = chartTitle

    self.statisticsHistoryGrid = {}
    for i = 1, 4 do
        local line = WINDOW_MANAGER:CreateControl(nil, chart, CT_BACKDROP)
        line:SetDimensions(872, 1)
        line:SetAnchor(TOPLEFT, chart, TOPLEFT, 30, 66 + ((i - 1) * 61))
        line:SetCenterColor(0.32, 0.29, 0.23, 0.34)
        line:SetEdgeColor(0,0,0,0)
        self.statisticsHistoryGrid[#self.statisticsHistoryGrid + 1] = line
    end

    self.statisticsHistorySegments = {}
    self.statisticsHistoryPoints = {}
    for i = 1, HISTORY_MAX_CHART_POINTS do
        if i < HISTORY_MAX_CHART_POINTS then
            local segment = WINDOW_MANAGER:CreateControl(nil, chart, CT_LINE)
            segment:SetTexture("EsoUI/Art/Champion/champion_star_link.dds")
            segment:SetColor(0.90, 0.77, 0.34, 1)
            if segment.SetThickness then segment:SetThickness(3) end
            segment:SetHidden(true)
            self.statisticsHistorySegments[i] = segment
        end
        local dot = WINDOW_MANAGER:CreateControl(nil, chart, CT_TEXTURE)
        dot:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericFill_tall.dds")
        dot:SetDimensions(7, 7)
        dot:SetColor(0.95, 0.82, 0.36, 1)
        dot:SetHidden(true)
        self.statisticsHistoryPoints[i] = dot
    end

    local empty = WINDOW_MANAGER:CreateControl(nil, chart, CT_LABEL)
    empty:SetDimensions(880, 60)
    empty:SetAnchor(CENTER, chart, CENTER, 0, 12)
    empty:SetFont("$(MEDIUM_FONT)|18")
    empty:SetColor(0.68, 0.65, 0.58, 1)
    empty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    empty:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsHistoryEmpty = empty

    local minLabel = WINDOW_MANAGER:CreateControl(nil, chart, CT_LABEL)
    minLabel:SetDimensions(90, 22)
    minLabel:SetAnchor(BOTTOMLEFT, chart, BOTTOMLEFT, 10, -28)
    minLabel:SetFont("$(MEDIUM_FONT)|13")
    minLabel:SetColor(0.56, 0.54, 0.50, 1)
    self.statisticsHistoryMinAxis = minLabel

    local maxLabel = WINDOW_MANAGER:CreateControl(nil, chart, CT_LABEL)
    maxLabel:SetDimensions(90, 22)
    maxLabel:SetAnchor(TOPLEFT, chart, TOPLEFT, 10, 50)
    maxLabel:SetFont("$(MEDIUM_FONT)|13")
    maxLabel:SetColor(0.56, 0.54, 0.50, 1)
    self.statisticsHistoryMaxAxis = maxLabel

    local startAxis = WINDOW_MANAGER:CreateControl(nil, chart, CT_LABEL)
    startAxis:SetDimensions(180, 18)
    startAxis:SetAnchor(BOTTOMLEFT, chart, BOTTOMLEFT, 82, -8)
    startAxis:SetFont("$(MEDIUM_FONT)|12")
    startAxis:SetColor(0.56, 0.54, 0.50, 1)
    startAxis:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.statisticsHistoryStartAxis = startAxis

    local endAxis = WINDOW_MANAGER:CreateControl(nil, chart, CT_LABEL)
    endAxis:SetDimensions(180, 18)
    endAxis:SetAnchor(BOTTOMRIGHT, chart, BOTTOMRIGHT, -16, -8)
    endAxis:SetFont("$(MEDIUM_FONT)|12")
    endAxis:SetColor(0.56, 0.54, 0.50, 1)
    endAxis:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self.statisticsHistoryEndAxis = endAxis

    -- 3.1.7: clearer chart axes. Five horizontal value labels and up to five
    -- calendar labels make PvE/PvP, Gold and Playtime readable at a glance.
    self.statisticsHistoryYTicks = self.statisticsHistoryYTicks or {}
    for i = 1, 5 do
        local tick = WINDOW_MANAGER:CreateControl(nil, chart, CT_LABEL)
        tick:SetDimensions(54, 18)
        tick:SetFont("$(MEDIUM_FONT)|12")
        tick:SetColor(0.62, 0.60, 0.55, 1)
        tick:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
        self.statisticsHistoryYTicks[i] = tick
    end
    self.statisticsHistoryXTicks = self.statisticsHistoryXTicks or {}
    for i = 1, 5 do
        local tick = WINDOW_MANAGER:CreateControl(nil, chart, CT_LABEL)
        tick:SetDimensions(118, 18)
        tick:SetFont("$(MEDIUM_FONT)|11")
        tick:SetColor(0.62, 0.60, 0.55, 1)
        tick:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        self.statisticsHistoryXTicks[i] = tick
    end

    local session = WINDOW_MANAGER:CreateControl(nil, page, CT_BACKDROP)
    session:SetDimensions(932, 112)
    session:SetAnchor(TOPLEFT, page, TOPLEFT, 20, 500)
    session:SetCenterColor(0.028, 0.026, 0.021, 0.98)
    session:SetEdgeColor(0.44, 0.34, 0.10, 0.95)
    session:SetEdgeTexture(nil, 1, 1, 1)
    self.statisticsHistorySessionBox = session

    local sessionTitle = WINDOW_MANAGER:CreateControl(nil, session, CT_LABEL)
    sessionTitle:SetDimensions(430, 25)
    sessionTitle:SetAnchor(TOPLEFT, session, TOPLEFT, 14, 8)
    sessionTitle:SetFont("$(BOLD_FONT)|18")
    sessionTitle:SetColor(0.90, 0.77, 0.34, 1)
    self.statisticsHistorySessionTitle = sessionTitle

    local activityImage = WINDOW_MANAGER:CreateControl(nil, session, CT_TEXTURE)
    activityImage:SetDimensions(164, 72)
    activityImage:SetAnchor(TOPLEFT, session, TOPLEFT, 14, 34)
    activityImage:SetTexture("TamrielProgressMap/art/activity_dungeon.dds")
    activityImage:SetHidden(true)
    self.statisticsHistoryActivityImage = activityImage

    local sessionText = WINDOW_MANAGER:CreateControl(nil, session, CT_LABEL)
    sessionText:SetDimensions(690, 68)
    sessionText:SetAnchor(TOPLEFT, session, TOPLEFT, 14, 34)
    sessionText:SetFont("$(MEDIUM_FONT)|15")
    sessionText:SetColor(0.78, 0.74, 0.65, 1)
    sessionText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    sessionText:SetVerticalAlignment(TEXT_ALIGN_TOP)
    self.statisticsHistorySessionText = sessionText

    local divider = WINDOW_MANAGER:CreateControl(nil, session, CT_BACKDROP)
    divider:SetDimensions(1, 94)
    divider:SetAnchor(TOPLEFT, session, TOPLEFT, 456, 9)
    divider:SetCenterColor(0.44, 0.34, 0.10, 0.75)
    divider:SetEdgeColor(0,0,0,0)
    divider:SetHidden(true)
    self.statisticsCombatActivityDivider = divider

    local examplesTitle = WINDOW_MANAGER:CreateControl(nil, session, CT_LABEL)
    examplesTitle:SetDimensions(438, 24)
    examplesTitle:SetAnchor(TOPLEFT, session, TOPLEFT, 476, 8)
    examplesTitle:SetFont("$(BOLD_FONT)|17")
    examplesTitle:SetColor(0.90, 0.77, 0.34, 1)
    examplesTitle:SetText(self:L("HISTORY_MORE_ACTIVITIES"))
    examplesTitle:SetHidden(true)
    self.statisticsCombatExamplesTitle = examplesTitle

    self.statisticsCombatRecentRows = {}
    for i = 1, 3 do
        local row = WINDOW_MANAGER:CreateControl(nil, session, CT_LABEL)
        row:SetDimensions(438, 22)
        row:SetAnchor(TOPLEFT, session, TOPLEFT, 476, 35 + ((i - 1) * 23))
        row:SetFont("$(MEDIUM_FONT)|14")
        row:SetColor(0.78, 0.74, 0.65, 1)
        row:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        row:SetHidden(true)
        self.statisticsCombatRecentRows[i] = row
    end

    local hint = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
    hint:SetDimensions(900, 18)
    hint:SetAnchor(BOTTOMLEFT, page, BOTTOMLEFT, 14, -4)
    hint:SetFont("$(MEDIUM_FONT)|13")
    hint:SetColor(0.60, 0.58, 0.52, 1)
    hint:SetText("")
    hint:SetHidden(true)
    self.statisticsCombatHint = hint
end

-- 3.1.0 combat-dashboard helpers ------------------------------------------------
function TPM:CreateCombatHistoryLineSet(chart, suffix, r, g, b)
    local set = { segments = {}, points = {}, color = {r,g,b} }
    for i = 1, HISTORY_MAX_CHART_POINTS do
        if i < HISTORY_MAX_CHART_POINTS then
            local segment = WINDOW_MANAGER:CreateControl(nil, chart, CT_LINE)
            segment:SetTexture("EsoUI/Art/Champion/champion_star_link.dds")
            segment:SetColor(r,g,b,1)
            if segment.SetThickness then segment:SetThickness(2) end
            segment:SetHidden(true)
            set.segments[i] = segment
        end
        local dot = WINDOW_MANAGER:CreateControl(nil, chart, CT_TEXTURE)
        dot:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericFill_tall.dds")
        dot:SetDimensions(7,7)
        dot:SetColor(r,g,b,1)
        dot:SetHidden(true)
        set.points[i] = dot
    end
    return set
end

function TPM:EnsureCombatDashboardControls()
    if self.statisticsCombatLegendLeft then return end
    local chart = self.statisticsHistoryChart
    if not chart then return end
    self.statisticsCombatLineSets = {
        pveKills = { segments=self.statisticsHistorySegments, points=self.statisticsHistoryPoints, color={0.49,0.78,0.27} },
        pveDeaths = self:CreateCombatHistoryLineSet(chart, "PveDeaths", 0.94,0.31,0.24),
        pvpKills = self:CreateCombatHistoryLineSet(chart, "PvpKills", 0.36,0.62,0.91),
        pvpDeaths = self:CreateCombatHistoryLineSet(chart, "PvpDeaths", 0.90,0.24,0.20),
    }
    for _, c in ipairs(self.statisticsHistorySegments or {}) do c:SetColor(0.49,0.78,0.27,1) end
    for _, c in ipairs(self.statisticsHistoryPoints or {}) do c:SetColor(0.49,0.78,0.27,1) end

    local left = WINDOW_MANAGER:CreateControl(nil, chart, CT_LABEL)
    left:SetDimensions(360,22); left:SetAnchor(TOPLEFT, chart, TOPLEFT, 18, 38)
    left:SetFont("$(MEDIUM_FONT)|14"); left:SetColor(0.84,0.80,0.70,1)
    left:SetText(self:L("HISTORY_COMBAT_LEGEND_PVE"))
    left:SetHidden(true)
    self.statisticsCombatLegendLeft = left

    local right = WINDOW_MANAGER:CreateControl(nil, chart, CT_LABEL)
    right:SetDimensions(360,22); right:SetAnchor(TOPRIGHT, chart, TOPRIGHT, -18, 38)
    right:SetFont("$(MEDIUM_FONT)|14"); right:SetColor(0.84,0.80,0.70,1)
    right:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    right:SetText(self:L("HISTORY_COMBAT_LEGEND_PVP"))
    right:SetHidden(true)
    self.statisticsCombatLegendRight = right
end

function TPM:SetCombatDashboardVisible(visible)
    local show = visible == true
    if self.statisticsCombatPveHeading then self.statisticsCombatPveHeading:SetHidden(not show) end
    if self.statisticsCombatBossBadge then self.statisticsCombatBossBadge:SetHidden(not show) end
    if self.statisticsCombatPvpHeading then self.statisticsCombatPvpHeading:SetHidden(not show) end
    -- 3.4.9: the PvE/PvP page is a lifetime dashboard, not a history chart.
    if self.statisticsCombatChartTitle then self.statisticsCombatChartTitle:SetHidden(true) end
    if self.statisticsCombatLegendLeft then self.statisticsCombatLegendLeft:SetHidden(true) end
    if self.statisticsCombatLegendRight then self.statisticsCombatLegendRight:SetHidden(true) end
    if self.statisticsHistoryActivityImage then self.statisticsHistoryActivityImage:SetHidden(true) end
    if self.statisticsCombatActivityDivider then self.statisticsCombatActivityDivider:SetHidden(not show) end
    if self.statisticsCombatExamplesTitle then self.statisticsCombatExamplesTitle:SetHidden(true) end
    if self.statisticsCombatActivityLogScroll then self.statisticsCombatActivityLogScroll:SetHidden(not show) end
    if self.statisticsCombatActivityLogCount then self.statisticsCombatActivityLogCount:SetHidden(not show) end
    if self.statisticsCombatActivityLogClearButton then self.statisticsCombatActivityLogClearButton:SetHidden(not show) end
    if self.statisticsCombatActivityLogInfoButton then self.statisticsCombatActivityLogInfoButton:SetHidden(not show) end
    if self.statisticsCombatKillLogScroll then self.statisticsCombatKillLogScroll:SetHidden(not show) end
    if self.statisticsCombatKillLogCount then self.statisticsCombatKillLogCount:SetHidden(not show) end
    if self.statisticsCombatKillLogClearButton then self.statisticsCombatKillLogClearButton:SetHidden(not show) end
    if self.statisticsCombatKillLogInfoButton then self.statisticsCombatKillLogInfoButton:SetHidden(not show) end
    if self.statisticsCombatActivityRightTitle then self.statisticsCombatActivityRightTitle:SetHidden(not show) end
    if self.statisticsCombatKillLogEmpty then self.statisticsCombatKillLogEmpty:SetHidden(not show) end
    if self.statisticsCombatActivityLogEmpty then self.statisticsCombatActivityLogEmpty:SetHidden(not show) end
    if self.statisticsCombatPlayerProgressLabel then self.statisticsCombatPlayerProgressLabel:SetHidden(not show) end
    if self.statisticsCombatPlayerProgressDetail then self.statisticsCombatPlayerProgressDetail:SetHidden(not show) end
    if self.statisticsCombatPlayerProgressBack then self.statisticsCombatPlayerProgressBack:SetHidden(not show) end
    if self.statisticsCombatCompanionProgressLabel then self.statisticsCombatCompanionProgressLabel:SetHidden(not show) end
    if self.statisticsCombatCompanionProgressDetail then self.statisticsCombatCompanionProgressDetail:SetHidden(not show) end
    if self.statisticsCombatCompanionProgressBack then self.statisticsCombatCompanionProgressBack:SetHidden(not show) end
    if self.statisticsCombatHint then self.statisticsCombatHint:SetHidden(true) end
    for _, row in ipairs(self.statisticsCombatRecentRows or {}) do row:SetHidden(true) end
    for _, extra in pairs(self.statisticsCombatCardExtras or {}) do
        if extra.icon then extra.icon:SetHidden(not show) end
        if extra.iconBack then extra.iconBack:SetHidden(not show) end
        if extra.accent then extra.accent:SetHidden(not show) end
        if extra.delta then extra.delta:SetHidden(true) end
    end
end

function TPM:GetRecentSessionSummaries(limit)
    local store = self:GetHistoryStore()
    local activities = store and store.activities or nil
    local result = {}
    limit = math.max(1, tonumber(limit) or 4)

    -- Only show activities we can identify reliably. Legacy dynamicEncounter
    -- rows are no longer accepted; world events come exclusively from the
    -- participation-based tracker.
    if type(activities) == "table" then
        for i = #activities, 1, -1 do
            local item = activities[i]
            if type(item) == "table" and self:IsPersistentTrackedActivityKind(item.activityKind)
                and TPM_IsMeaningfulDynamicEncounter(item) then
                result[#result + 1] = item
                if #result >= limit then break end
            end
        end
    end
    return result
end

function TPM:GetActivityDisplayName(session)
    if not session then return self:L("HISTORY_ACTIVITY_ADVENTURE") end
    local zone = session.activityName or ""
    local kind = session.activityKind or "adventure"
    if kind ~= "quest" and not self:IsWorldEventActivityKind(kind) and zone ~= "" and type(ZO_CachedStrFormat) == "function" and _G.SI_ZONE_NAME then
        zone = ZO_CachedStrFormat(SI_ZONE_NAME, zone)
    end
    local prefix
    if kind == "quest" then prefix = self:L("HISTORY_ACTIVITY_QUEST")
    elseif kind == "killAnimal" then prefix = self:L("HISTORY_ACTIVITY_KILL_ANIMAL")
    elseif kind == "killNpc" then prefix = self:L("HISTORY_ACTIVITY_KILL_NPC")
    elseif kind == "killBoss" then prefix = self:L("HISTORY_ACTIVITY_KILL_BOSS")
    elseif kind == "killPlayer" then prefix = self:L("HISTORY_ACTIVITY_KILL_PLAYER")
    elseif kind == "battleground" then prefix = self:L("HISTORY_ACTIVITY_BATTLEGROUND")
    elseif kind == "pvp" then prefix = self:L("HISTORY_ACTIVITY_PVP")
    elseif kind == "dungeon" then prefix = self:L("HISTORY_ACTIVITY_DUNGEON")
    elseif kind == "trial" then prefix = self:L("HISTORY_ACTIVITY_TRIAL")
    elseif kind == "arena" then prefix = self:L("HISTORY_ACTIVITY_ARENA")
    elseif kind == "dolmen" then prefix = self:L("HISTORY_ACTIVITY_DOLMEN")
    elseif kind == "geyser" then prefix = self:L("HISTORY_ACTIVITY_GEYSER")
    elseif kind == "harrowstorm" then prefix = self:L("HISTORY_ACTIVITY_HARROWSTORM")
    elseif kind == "volcanicVent" then prefix = self:L("HISTORY_ACTIVITY_VOLCANIC_VENT")
    elseif kind == "dragonHunt" then prefix = self:L("HISTORY_ACTIVITY_DRAGON_HUNT")
    elseif kind == "monsterHunt" then prefix = self:L("HISTORY_ACTIVITY_MONSTER_HUNT")
    elseif kind == "mirrormoor" then prefix = self:L("HISTORY_ACTIVITY_MIRRORMOOR")
    elseif kind == "oblivionPortal" then prefix = self:L("HISTORY_ACTIVITY_OBLIVION_PORTAL")
    elseif kind == "worldEvent" or kind == "event" then prefix = self:L("HISTORY_ACTIVITY_WORLD_EVENT")
    else prefix = self:L("HISTORY_ACTIVITY_ADVENTURE") end
    if zone ~= "" then return prefix .. ": " .. zone end
    return prefix
end

function TPM:EnsureCombatProgressionControls()
    if self.statisticsCombatPlayerProgressBack or not self.statisticsHistoryPage then return end
    local page = self.statisticsHistoryPage

    local function CreateProgressRow(prefix, y, accent)
        local label = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
        label:SetDimensions(440, 18)
        label:SetAnchor(TOPLEFT, page, TOPLEFT, 20, y)
        label:SetFont("$(BOLD_FONT)|14")
        label:SetColor(0.92, 0.90, 0.84, 1)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

        local detail = WINDOW_MANAGER:CreateControl(nil, page, CT_LABEL)
        detail:SetDimensions(470, 18)
        detail:SetAnchor(TOPRIGHT, page, TOPRIGHT, -20, y)
        detail:SetFont("$(MEDIUM_FONT)|13")
        detail:SetColor(0.78, 0.76, 0.70, 1)
        detail:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

        local back = WINDOW_MANAGER:CreateControl(nil, page, CT_BACKDROP)
        back:SetDimensions(932, 7)
        back:SetAnchor(TOPLEFT, page, TOPLEFT, 20, y + 19)
        back:SetCenterColor(0.025, 0.024, 0.021, 0.98)
        back:SetEdgeColor(0.28, 0.25, 0.18, 0.85)
        back:SetEdgeTexture(nil, 1, 1, 1)

        local fill = WINDOW_MANAGER:CreateControl(nil, back, CT_BACKDROP)
        fill:SetDimensions(1, 5)
        fill:SetAnchor(LEFT, back, LEFT, 1, 0)
        fill:SetCenterColor(accent[1], accent[2], accent[3], 0.94)
        fill:SetEdgeColor(0, 0, 0, 0)

        return label, detail, back, fill
    end

    self.statisticsCombatPlayerProgressLabel,
    self.statisticsCombatPlayerProgressDetail,
    self.statisticsCombatPlayerProgressBack,
    self.statisticsCombatPlayerProgressFill = CreateProgressRow("player", 38, {0.90, 0.74, 0.22})

    self.statisticsCombatCompanionProgressLabel,
    self.statisticsCombatCompanionProgressDetail,
    self.statisticsCombatCompanionProgressBack,
    self.statisticsCombatCompanionProgressFill = CreateProgressRow("companion", 66, {0.46, 0.80, 0.92})
end

function TPM:SetCombatProgressBar(fill, current, maximum)
    if not fill then return end
    current = math.max(0, tonumber(current) or 0)
    maximum = math.max(0, tonumber(maximum) or 0)
    if maximum <= 0 then
        fill:SetHidden(true)
        return
    end
    fill:SetHidden(false)
    local ratio = math.max(0, math.min(1, current / maximum))
    fill:SetWidth(math.max(1, math.floor(930 * ratio)))
end

function TPM:RefreshCombatProgressionBars()
    self:EnsureCombatProgressionControls()
    local level = type(GetUnitLevel) == "function" and (tonumber(GetUnitLevel("player")) or 0) or 0
    local maxLevel = type(GetMaxLevel) == "function" and (tonumber(GetMaxLevel()) or 50) or 50
    local currentXP, maxXP, displayLevel
    if level > 0 and level < maxLevel then
        currentXP = type(GetUnitXP) == "function" and (tonumber(GetUnitXP("player")) or 0) or 0
        maxXP = type(GetUnitXPMax) == "function" and (tonumber(GetUnitXPMax("player")) or 0) or 0
        displayLevel = self:L("HISTORY_CHARACTER_LEVEL", level)
    else
        local cp = type(GetUnitChampionPoints) == "function" and (tonumber(GetUnitChampionPoints("player")) or 0)
            or (type(GetPlayerChampionPointsEarned) == "function" and (tonumber(GetPlayerChampionPointsEarned()) or 0) or 0)
        currentXP = type(GetPlayerChampionXP) == "function" and (tonumber(GetPlayerChampionXP()) or 0) or 0
        maxXP = type(GetNumChampionXPInChampionPoint) == "function" and (tonumber(GetNumChampionXPInChampionPoint(cp)) or 0) or 0
        displayLevel = self:L("HISTORY_CHARACTER_CP", cp)
    end
    local remaining = math.max(0, maxXP - currentXP)
    if self.statisticsCombatPlayerProgressLabel then self.statisticsCombatPlayerProgressLabel:SetText(displayLevel) end
    if self.statisticsCombatPlayerProgressDetail then
        self.statisticsCombatPlayerProgressDetail:SetText(self:L("HISTORY_XP_TO_NEXT", FormatNumber(currentXP), FormatNumber(maxXP), FormatNumber(remaining)))
    end
    self:SetCombatProgressBar(self.statisticsCombatPlayerProgressFill, currentXP, maxXP)

    local hasCompanion = type(HasActiveCompanion) == "function" and HasActiveCompanion()
    if hasCompanion and type(GetActiveCompanionDefId) == "function" and type(GetActiveCompanionLevelInfo) == "function" then
        local companionId = tonumber(GetActiveCompanionDefId()) or 0
        local name = type(GetCompanionName) == "function" and tostring(GetCompanionName(companionId) or "") or ""
        if type(zo_strformat) == "function" and name ~= "" then name = zo_strformat("<<C:1>>", name) end
        local companionLevel, companionXP = GetActiveCompanionLevelInfo()
        companionLevel = tonumber(companionLevel) or 0
        companionXP = tonumber(companionXP) or 0
        local companionMax = type(GetNumExperiencePointsInCompanionLevel) == "function"
            and (tonumber(GetNumExperiencePointsInCompanionLevel(companionLevel)) or 0) or 0
        local companionRemaining = math.max(0, companionMax - companionXP)
        if self.statisticsCombatCompanionProgressLabel then
            self.statisticsCombatCompanionProgressLabel:SetText(self:L("HISTORY_COMPANION_LEVEL", name ~= "" and name or self:L("HISTORY_COMPANION_GENERIC"), companionLevel))
        end
        if self.statisticsCombatCompanionProgressDetail then
            self.statisticsCombatCompanionProgressDetail:SetText(self:L("HISTORY_XP_TO_NEXT", FormatNumber(companionXP), FormatNumber(companionMax), FormatNumber(companionRemaining)))
        end
        self:SetCombatProgressBar(self.statisticsCombatCompanionProgressFill, companionXP, companionMax)
    else
        if self.statisticsCombatCompanionProgressLabel then self.statisticsCombatCompanionProgressLabel:SetText(self:L("HISTORY_COMPANION_NONE")) end
        if self.statisticsCombatCompanionProgressDetail then self.statisticsCombatCompanionProgressDetail:SetText("") end
        if self.statisticsCombatCompanionProgressFill then self.statisticsCombatCompanionProgressFill:SetHidden(true) end
    end
end

function TPM:GetCombatDifficultyVisual(item)
    local kind = item and item.activityKind or "killNpc"
    local difficulty = item and item.difficulty or nil
    if kind == "killBoss" then return "E54835", self:L("HISTORY_DIFFICULTY_BOSS") end
    if kind == "killPlayer" then return "58B9F2", self:L("HISTORY_DIFFICULTY_PLAYER") end
    if kind == "killAnimal" then return "75D64B", self:L("HISTORY_DIFFICULTY_EASY") end
    if _G.MONSTER_DIFFICULTY_DEADLY ~= nil and difficulty == _G.MONSTER_DIFFICULTY_DEADLY then return "E54835", self:L("HISTORY_DIFFICULTY_DEADLY") end
    if _G.MONSTER_DIFFICULTY_HARD ~= nil and difficulty == _G.MONSTER_DIFFICULTY_HARD then return "F29A38", self:L("HISTORY_DIFFICULTY_HARD") end
    if _G.MONSTER_DIFFICULTY_EASY ~= nil and difficulty == _G.MONSTER_DIFFICULTY_EASY then return "75D64B", self:L("HISTORY_DIFFICULTY_EASY") end
    if _G.MONSTER_DIFFICULTY_NONE ~= nil and difficulty == _G.MONSTER_DIFFICULTY_NONE then return "75D64B", self:L("HISTORY_DIFFICULTY_TRIVIAL") end
    return "E6C45C", self:L("HISTORY_DIFFICULTY_NORMAL")
end

function TPM:GetCombatLogTitle(item)
    if type(item) ~= "table" then return "" end
    local prefix
    if item.activityKind == "killAnimal" then prefix = self:L("HISTORY_ACTIVITY_KILL_ANIMAL")
    elseif item.activityKind == "killBoss" then prefix = self:L("HISTORY_ACTIVITY_KILL_BOSS")
    elseif item.activityKind == "killPlayer" then prefix = self:L("HISTORY_ACTIVITY_KILL_PLAYER")
    else prefix = self:L("HISTORY_ACTIVITY_KILL_NPC") end
    local colorHex = self:GetCombatDifficultyVisual(item)
    local target = tostring(item.activityName or "")
    if target == "" then target = "—" end
    return "|cF2F0EA" .. prefix .. ":|r |c" .. tostring(colorHex) .. target .. "|r"
end

function TPM:FormatCombatLogDetail(item)
    local colorHex, difficultyText = self:GetCombatDifficultyVisual(item)
    local xp = math.max(0, tonumber(item and item.xpEarned) or 0)
    return string.format("|cF2F0EA%s|r +%s   •   |cF2F0EA%s:|r |c%s%s|r",
        self:L("HISTORY_XP_SHORT"), FormatNumber(xp), self:L("HISTORY_DIFFICULTY"), colorHex, difficultyText)
end

function TPM:ClearCombatActivityList(isCombat)
    local store = self:GetHistoryStore()
    if not store then return end
    if isCombat then
        store.combatActivities = {}
    else
        store.activities = {}
    end
    self:RefreshCombatActivityPanel()
    local scroll = isCombat and self.statisticsCombatKillLogScroll or self.statisticsCombatActivityLogScroll
    if scroll and scroll.ResetToTop then scroll:ResetToTop() end
end

local function TPM_EnsureLogHelpTooltip()
    if TPM.statisticsLogHelpTooltip then return TPM.statisticsLogHelpTooltip end
    if not WINDOW_MANAGER or not GuiRoot then return nil end

    local tip = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "LogHelpTooltip")
    -- Width is stable; height is recalculated from localized text when shown.
    tip:SetDimensions(380, 126)
    tip:SetHidden(true)
    tip:SetMouseEnabled(false)
    tip:SetMovable(false)
    if tip.SetClampedToScreen then tip:SetClampedToScreen(true) end
    if tip.SetDrawTier and DT_HIGH then tip:SetDrawTier(DT_HIGH) end
    if tip.SetDrawLayer and DL_OVERLAY then tip:SetDrawLayer(DL_OVERLAY) end
    if tip.SetDrawLevel then tip:SetDrawLevel(10000) end

    local bg = WINDOW_MANAGER:CreateControl(nil, tip, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0.035, 0.031, 0.026, 0.98)
    bg:SetEdgeColor(0.92, 0.76, 0.14, 0.96)
    bg:SetEdgeTexture(nil, 1, 1, 1)

    local titleLabel = WINDOW_MANAGER:CreateControl(nil, tip, CT_LABEL)
    titleLabel:SetAnchor(TOPLEFT, tip, TOPLEFT, 12, 10)
    titleLabel:SetAnchor(TOPRIGHT, tip, TOPRIGHT, -12, 10)
    titleLabel:SetHeight(24)
    titleLabel:SetFont("$(BOLD_FONT)|16")
    titleLabel:SetColor(0.96, 0.84, 0.30, 1)

    local body = WINDOW_MANAGER:CreateControl(nil, tip, CT_LABEL)
    body:SetAnchor(TOPLEFT, titleLabel, BOTTOMLEFT, 0, 5)
    body:SetAnchor(TOPRIGHT, titleLabel, BOTTOMRIGHT, 0, 5)
    body:SetHeight(100)
    body:SetFont("$(MEDIUM_FONT)|13")
    body:SetColor(0.92, 0.91, 0.87, 1)

    tip.TPMTitle = titleLabel
    tip.TPMBody = body
    TPM.statisticsLogHelpTooltip = tip
    return tip
end

local function TPM_ShowLogHelpTooltip(control, title, text)
    if not control or not text or text == "" then return end
    local tip = TPM_EnsureLogHelpTooltip()
    if not tip then return end
    TPM:HideStatisticsHoverTooltips()

    tip.TPMTitle:SetText(title or "")
    tip.TPMBody:SetText(text)

    -- Re-measure after assigning translated strings. Different UI scales and
    -- languages wrap differently and must not overflow the frame.
    local titleHeight = 24
    local bodyHeight = 78
    if tip.TPMTitle.GetTextHeight then
        titleHeight = math.max(24, math.ceil(tonumber(tip.TPMTitle:GetTextHeight()) or 24))
    end
    if tip.TPMBody.GetTextHeight then
        bodyHeight = math.max(54, math.ceil(tonumber(tip.TPMBody:GetTextHeight()) or 78))
    end
    tip.TPMTitle:SetHeight(titleHeight)
    tip.TPMBody:SetHeight(bodyHeight)
    tip:SetHeight(10 + titleHeight + 5 + bodyHeight + 12)

    -- Keep every statistics-related hover panel in the same place: directly
    -- to the upper-right of the Tamriel Statistics journal.
    TPM_ArmStatisticsHoverTooltip(tip, control)
    TPM:AnchorStatisticsHoverTooltip(tip, 58)
end

local function TPM_HideLogHelpTooltip()
    local tip = TPM.statisticsLogHelpTooltip
    if tip then tip:SetHidden(true) end
end

local function TPM_CreateHeaderIconButton(parent, width, height, iconKind)
    local button = WINDOW_MANAGER:CreateControl(nil, parent, CT_BUTTON)
    button:SetDimensions(width, height)
    button:SetMouseEnabled(true)

    if iconKind == "clear" then
        -- Use ESO's native close-button art instead of a text glyph in a box.
        button:SetNormalTexture("EsoUI/Art/Buttons/closeButton_up.dds")
        button:SetPressedTexture("EsoUI/Art/Buttons/closeButton_down.dds")
        button:SetMouseOverTexture("EsoUI/Art/Buttons/closeButton_mouseOver.dds")
        if button.SetDisabledTexture then
            button:SetDisabledTexture("EsoUI/Art/Buttons/closeButton_disabled.dds")
        end
        if button.SetTextureCoords then
            button:SetTextureCoords(0, 0.625, 0, 0.625)
        end
    else
        -- LibAddonMenu and ESO themselves use this native help icon.
        local icon = WINDOW_MANAGER:CreateControl(nil, button, CT_TEXTURE)
        icon:SetDimensions(math.max(16, width - 3), math.max(16, height - 3))
        icon:SetAnchor(CENTER, button, CENTER, 0, 0)
        icon:SetTexture("EsoUI/Art/Miscellaneous/help_icon.dds")
        icon:SetColor(0.88, 0.82, 0.64, 0.92)
        icon:SetMouseEnabled(false)
        button.TPMIcon = icon
    end

    button:SetHandler("OnMouseEnter", function(selfButton)
        if selfButton.TPMIcon then
            selfButton.TPMIcon:SetColor(1.00, 0.86, 0.30, 1)
        end
        if selfButton.TPMHelpTitle and selfButton.TPMHelpText then
            TPM_ShowLogHelpTooltip(selfButton, selfButton.TPMHelpTitle, selfButton.TPMHelpText)
        end
    end)
    button:SetHandler("OnMouseExit", function(selfButton)
        if selfButton.TPMIcon then
            selfButton.TPMIcon:SetColor(0.88, 0.82, 0.64, 0.92)
        end
        TPM:HideStatisticsHoverTooltips()
    end)
    return button
end

function TPM:EnsureCombatActivityLogControls()
    if self.statisticsCombatActivityLogScroll or not self.statisticsHistorySessionBox then return end
    local session = self.statisticsHistorySessionBox

    if self.statisticsHistoryActivityImage then self.statisticsHistoryActivityImage:SetHidden(true) end
    if self.statisticsHistorySessionText then self.statisticsHistorySessionText:SetHidden(true) end
    if self.statisticsCombatExamplesTitle then self.statisticsCombatExamplesTitle:SetHidden(true) end
    for _, row in ipairs(self.statisticsCombatRecentRows or {}) do row:SetHidden(true) end

    -- Left: individual NPC / animal / boss / player kills.
    if self.statisticsHistorySessionTitle then
        self.statisticsHistorySessionTitle:ClearAnchors()
        self.statisticsHistorySessionTitle:SetDimensions(360, 24)
        self.statisticsHistorySessionTitle:SetAnchor(TOPLEFT, session, TOPLEFT, 14, 8)
    end

    local combatCount = WINDOW_MANAGER:CreateControl(nil, session, CT_LABEL)
    combatCount:SetDimensions(76, 22)
    combatCount:SetAnchor(TOPLEFT, session, TOPLEFT, 364, 9)
    combatCount:SetFont("$(MEDIUM_FONT)|12")
    combatCount:SetColor(0.72, 0.70, 0.65, 1)
    combatCount:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self.statisticsCombatKillLogCount = combatCount

    local combatClear = TPM_CreateHeaderIconButton(session, 22, 22, "clear")
    combatClear:SetAnchor(TOPLEFT, session, TOPLEFT, 307, 7)
    combatClear.TPMHelpTitle = self:L("HISTORY_CLEAR_COMBAT_LOG")
    combatClear.TPMHelpText = self:L("HISTORY_CLEAR_TOOLTIP")
    combatClear:SetHandler("OnClicked", function()
        self:HideStatisticsHoverTooltips()
        self:ClearCombatActivityList(true)
    end)
    self.statisticsCombatKillLogClearButton = combatClear

    local combatInfo = TPM_CreateHeaderIconButton(session, 21, 21, "info")
    combatInfo:SetAnchor(TOPLEFT, session, TOPLEFT, 335, 8)
    combatInfo.TPMHelpTitle = self:L("HISTORY_LOG_INFO_TITLE")
    combatInfo.TPMHelpText = self:L("HISTORY_LOG_INFO_TOOLTIP")
    self.statisticsCombatKillLogInfoButton = combatInfo

    local divider = self.statisticsCombatActivityDivider
    if divider then
        divider:ClearAnchors()
        divider:SetDimensions(1, 326)
        divider:SetAnchor(TOP, session, TOP, 0, 38)
        divider:SetCenterColor(0.34, 0.52, 0.72, 0.74)
        divider:SetHidden(false)
    end

    local rightTitle = WINDOW_MANAGER:CreateControl(nil, session, CT_LABEL)
    rightTitle:SetDimensions(350, 24)
    rightTitle:SetAnchor(TOPLEFT, session, TOPLEFT, 480, 8)
    rightTitle:SetFont("$(BOLD_FONT)|18")
    rightTitle:SetColor(0.72, 0.82, 0.94, 1)
    self.statisticsCombatActivityRightTitle = rightTitle

    local activityCount = WINDOW_MANAGER:CreateControl(nil, session, CT_LABEL)
    activityCount:SetDimensions(76, 22)
    activityCount:SetAnchor(TOPRIGHT, session, TOPRIGHT, -14, 9)
    activityCount:SetFont("$(MEDIUM_FONT)|12")
    activityCount:SetColor(0.72, 0.70, 0.65, 1)
    activityCount:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self.statisticsCombatActivityLogCount = activityCount

    local activityClear = TPM_CreateHeaderIconButton(session, 22, 22, "clear")
    activityClear:SetAnchor(TOPRIGHT, session, TOPRIGHT, -124, 7)
    activityClear.TPMHelpTitle = self:L("HISTORY_CLEAR_ACTIVITY_LOG")
    activityClear.TPMHelpText = self:L("HISTORY_CLEAR_TOOLTIP")
    activityClear:SetHandler("OnClicked", function()
        self:HideStatisticsHoverTooltips()
        self:ClearCombatActivityList(false)
    end)
    self.statisticsCombatActivityLogClearButton = activityClear

    local activityInfo = TPM_CreateHeaderIconButton(session, 21, 21, "info")
    activityInfo:SetAnchor(TOPRIGHT, session, TOPRIGHT, -96, 8)
    activityInfo.TPMHelpTitle = self:L("HISTORY_LOG_INFO_TITLE")
    activityInfo.TPMHelpText = self:L("HISTORY_LOG_INFO_TOOLTIP")
    self.statisticsCombatActivityLogInfoButton = activityInfo

    local function CreateLogScroll(name, x, width, isCombat)
        local scrollContainer = WINDOW_MANAGER:CreateControlFromVirtual(name, session, "ZO_ScrollContainer_Shared")
        scrollContainer:SetAnchor(TOPLEFT, session, TOPLEFT, x, 36)
        scrollContainer:SetDimensions(width, 330)
        local scroll = scrollContainer:GetNamedChild("Scroll")
        local child = scroll and scroll:GetNamedChild("Child") or nil
        local rows = {}
        local parent = child or session
        local rowWidth = width - 20
        for i = 1, 100 do
            local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
            row:SetDimensions(rowWidth, 48)
            row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, (i - 1) * 50)
            row:SetCenterColor(0.022, 0.021, 0.018, (i % 2 == 0) and 0.84 or 0.66)
            row:SetEdgeColor(0.25, 0.23, 0.18, 0.50)
            row:SetEdgeTexture(nil, 1, 1, 1)
            row:SetHidden(true)

            local accent = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
            accent:SetDimensions(3, 46)
            accent:SetAnchor(LEFT, row, LEFT, 0, 0)
            accent:SetEdgeColor(0, 0, 0, 0)
            row.TPMAccent = accent

            local title = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
            title:SetDimensions(rowWidth - 160, 21)
            title:SetAnchor(TOPLEFT, row, TOPLEFT, 10, 3)
            title:SetFont("$(BOLD_FONT)|13")
            title:SetColor(0.95, 0.94, 0.91, 1)
            title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            if title.SetWrapMode and _G.TEXT_WRAP_MODE_TRUNCATE then title:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE) end
            row.TPMTitle = title

            local timestamp = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
            timestamp:SetDimensions(142, 19)
            timestamp:SetAnchor(TOPRIGHT, row, TOPRIGHT, -8, 4)
            timestamp:SetFont("$(MEDIUM_FONT)|10")
            timestamp:SetColor(0.68, 0.66, 0.60, 1)
            timestamp:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            timestamp:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            row.TPMTimestamp = timestamp

            local detail = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
            detail:SetDimensions(rowWidth - 18, 19)
            detail:SetAnchor(TOPLEFT, row, TOPLEFT, 10, 25)
            detail:SetFont("$(MEDIUM_FONT)|12")
            detail:SetColor(0.94, 0.93, 0.90, 1)
            detail:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            detail:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            row.TPMDetail = detail
            rows[i] = row
        end
        return scrollContainer, child, rows, rowWidth
    end

    self.statisticsCombatKillLogScroll,
    self.statisticsCombatKillLogScrollChild,
    self.statisticsCombatKillLogRows,
    self.statisticsCombatKillLogRowWidth = CreateLogScroll(ADDON_NAME .. "CombatKillLogScroll", 10, 450, true)

    self.statisticsCombatActivityLogScroll,
    self.statisticsCombatActivityLogScrollChild,
    self.statisticsCombatActivityLogRows,
    self.statisticsCombatActivityLogRowWidth = CreateLogScroll(ADDON_NAME .. "CombatActivityLogScroll", 472, 450, false)

    local leftEmpty = WINDOW_MANAGER:CreateControl(nil, session, CT_LABEL)
    leftEmpty:SetDimensions(400, 50)
    leftEmpty:SetAnchor(TOPLEFT, session, TOPLEFT, 28, 72)
    leftEmpty:SetFont("$(MEDIUM_FONT)|14")
    leftEmpty:SetColor(0.70, 0.69, 0.65, 1)
    leftEmpty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    leftEmpty:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    leftEmpty:SetHidden(true)
    self.statisticsCombatKillLogEmpty = leftEmpty

    local rightEmpty = WINDOW_MANAGER:CreateControl(nil, session, CT_LABEL)
    rightEmpty:SetDimensions(400, 50)
    rightEmpty:SetAnchor(TOPLEFT, session, TOPLEFT, 492, 72)
    rightEmpty:SetFont("$(MEDIUM_FONT)|14")
    rightEmpty:SetColor(0.70, 0.69, 0.65, 1)
    rightEmpty:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    rightEmpty:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    rightEmpty:SetHidden(true)
    self.statisticsCombatActivityLogEmpty = rightEmpty
end

function TPM:GetCombatLogSummaries(limit)
    local store = self:GetHistoryStore()
    local activities = store and store.combatActivities or nil
    local result = {}
    limit = math.max(1, math.min(100, tonumber(limit) or 100))
    if type(activities) == "table" then
        for i = #activities, 1, -1 do
            local item = activities[i]
            if type(item) == "table" and self:IsCombatLogKind(item.activityKind) then
                result[#result + 1] = item
                if #result >= limit then break end
            end
        end
    end
    return result
end

function TPM:GetActivityLogSummaries(limit)
    local store = self:GetHistoryStore()
    local activities = store and store.activities or nil
    local result = {}
    limit = math.max(1, math.min(100, tonumber(limit) or 100))
    if type(activities) == "table" then
        for i = #activities, 1, -1 do
            local item = activities[i]
            if type(item) == "table" and self:IsPersistentTrackedActivityKind(item.activityKind)
                and not self:IsCombatLogKind(item.activityKind) and TPM_IsMeaningfulDynamicEncounter(item) then
                result[#result + 1] = item
                if #result >= limit then break end
            end
        end
    end
    return result
end

function TPM:GetActivityLogStyle(kind)
    if kind == "battleground" or kind == "pvp" then return { 0.24, 0.68, 0.96 } end
    if kind == "killAnimal" then return { 0.58, 0.86, 0.24 } end
    if kind == "killNpc" then return { 0.82, 0.72, 0.30 } end
    if kind == "killBoss" then return { 0.96, 0.28, 0.18 } end
    if kind == "killPlayer" then return { 0.28, 0.68, 0.96 } end
    if kind == "quest" then return { 0.90, 0.75, 0.22 } end
    if kind == "dungeon" or kind == "trial" or kind == "arena" then return { 0.55, 0.82, 0.24 } end
    if kind == "dolmen" then return { 0.72, 0.40, 0.94 } end
    if kind == "geyser" then return { 0.26, 0.78, 0.94 } end
    if kind == "harrowstorm" then return { 0.82, 0.30, 0.50 } end
    if kind == "volcanicVent" then return { 0.96, 0.48, 0.18 } end
    if kind == "dragonHunt" or kind == "monsterHunt" then return { 0.94, 0.34, 0.20 } end
    if kind == "mirrormoor" or kind == "oblivionPortal" or kind == "worldEvent" then return { 0.70, 0.54, 0.92 } end
    return { 0.78, 0.66, 0.30 }
end

function TPM:FormatActivityLogDetail(item)
    local parts = {}
    parts[#parts + 1] = string.format("|cE5C454%s|r +%s", self:L("HISTORY_GOLD_SHORT"), FormatNumber(math.max(0, tonumber(item.goldEarned) or 0)))
    parts[#parts + 1] = string.format("|c78BDF2%s|r +%s", self:L("HISTORY_XP_SHORT"), FormatNumber(math.max(0, tonumber(item.xpEarned) or 0)))

    local kind = item.activityKind or "adventure"
    if kind == "quest" then
        local reward = tostring(item.rewardName or "")
        if reward == "" then reward = "—" end
        parts[#parts + 1] = "|cC993EA" .. self:L("HISTORY_REWARD") .. ":|r " .. reward
    elseif kind == "battleground" or kind == "pvp" then
        parts[#parts + 1] = string.format("|c78BDF2%s|r %d", self:L("HISTORY_KILLS_SHORT"), math.max(0, tonumber(item.pvpKillsDelta) or 0))
        parts[#parts + 1] = string.format("|cE66A5A%s|r %d", self:L("HISTORY_DEATHS_SHORT"), math.max(0, tonumber(item.pvpDeathsDelta) or 0))
        if (tonumber(item.duration) or 0) > 0 then parts[#parts + 1] = self:L("HISTORY_DURATION_SHORT") .. " " .. TPM_FormatDuration(item.duration) end
    else
        parts[#parts + 1] = string.format("|c7DCA45%s|r %d", self:L("HISTORY_KILLS_SHORT"), math.max(0, tonumber(item.npcKillsDelta) or 0))
        parts[#parts + 1] = string.format("|cF07B68%s|r %d", self:L("HISTORY_DEATHS_SHORT"), math.max(0, tonumber(item.pveDeathsDelta) or 0))
        if (tonumber(item.duration) or 0) > 0 then parts[#parts + 1] = self:L("HISTORY_DURATION_SHORT") .. " " .. TPM_FormatDuration(item.duration) end
    end
    return table.concat(parts, "   •   ")
end

function TPM:RefreshCombatActivityPanel()
    self:EnsureCombatActivityLogControls()
    local combatActivities = self:GetCombatLogSummaries(100)
    local activities = self:GetActivityLogSummaries(100)

    if self.statisticsHistorySessionTitle then self.statisticsHistorySessionTitle:SetText(self:L("HISTORY_COMBAT_LOG")) end
    if self.statisticsCombatActivityRightTitle then self.statisticsCombatActivityRightTitle:SetText(self:L("HISTORY_ACTIVITY_LIST")) end
    if self.statisticsCombatKillLogCount then self.statisticsCombatKillLogCount:SetText(string.format("%d / 100", #combatActivities)) end
    if self.statisticsCombatActivityLogCount then self.statisticsCombatActivityLogCount:SetText(string.format("%d / 100", #activities)) end

    if self.statisticsHistoryActivityImage then self.statisticsHistoryActivityImage:SetHidden(true) end
    if self.statisticsHistorySessionText then self.statisticsHistorySessionText:SetHidden(true) end
    if self.statisticsCombatExamplesTitle then self.statisticsCombatExamplesTitle:SetHidden(true) end
    for _, row in ipairs(self.statisticsCombatRecentRows or {}) do row:SetHidden(true) end

    local combatRows = self.statisticsCombatKillLogRows or {}
    for i, row in ipairs(combatRows) do
        local item = combatActivities[i]
        row:SetHidden(item == nil)
        if item then
            local hex = self:GetCombatDifficultyVisual(item)
            local r = tonumber(hex:sub(1,2), 16) / 255
            local g = tonumber(hex:sub(3,4), 16) / 255
            local b = tonumber(hex:sub(5,6), 16) / 255
            if row.TPMAccent then row.TPMAccent:SetCenterColor(r, g, b, 0.92) end
            if row.TPMTitle then row.TPMTitle:SetText(self:GetCombatLogTitle(item)) end
            if row.TPMTimestamp then row.TPMTimestamp:SetText(self:FormatLogTimestamp(item)) end
            if row.TPMDetail then row.TPMDetail:SetText(self:FormatCombatLogDetail(item)) end
        end
    end

    local activityRows = self.statisticsCombatActivityLogRows or {}
    for i, row in ipairs(activityRows) do
        local item = activities[i]
        row:SetHidden(item == nil)
        if item then
            local style = self:GetActivityLogStyle(item.activityKind)
            if row.TPMAccent then row.TPMAccent:SetCenterColor(style[1], style[2], style[3], 0.92) end
            if row.TPMTitle then
                row.TPMTitle:SetColor(0.95, 0.94, 0.91, 1)
                row.TPMTitle:SetText(self:GetActivityDisplayName(item))
            end
            if row.TPMTimestamp then row.TPMTimestamp:SetText(self:FormatLogTimestamp(item)) end
            if row.TPMDetail then row.TPMDetail:SetText(self:FormatActivityLogDetail(item)) end
        end
    end

    if self.statisticsCombatKillLogScrollChild then
        self.statisticsCombatKillLogScrollChild:SetDimensions(self.statisticsCombatKillLogRowWidth or 430, math.max(1, #combatActivities) * 50)
    end
    if self.statisticsCombatActivityLogScrollChild then
        self.statisticsCombatActivityLogScrollChild:SetDimensions(self.statisticsCombatActivityLogRowWidth or 430, math.max(1, #activities) * 50)
    end

    if self.statisticsCombatKillLogEmpty then
        self.statisticsCombatKillLogEmpty:SetText(self:L("HISTORY_NO_COMBAT_LOG"))
        self.statisticsCombatKillLogEmpty:SetHidden(#combatActivities > 0)
    end
    if self.statisticsCombatActivityLogEmpty then
        self.statisticsCombatActivityLogEmpty:SetText(self:L("HISTORY_NO_ACTIVITY"))
        self.statisticsCombatActivityLogEmpty:SetHidden(#activities > 0)
    end
end

local function TPM_FormatChartDate(timestamp, rangeDays)
    timestamp = tonumber(timestamp) or 0
    if timestamp <= 0 then return "" end
    -- ESO's formatter is locale-aware and safe in the addon sandbox.
    if type(GetDateStringFromTimestamp) == "function" then
        local ok, value = pcall(GetDateStringFromTimestamp, timestamp)
        if ok and type(value) == "string" and value ~= "" then
            local d, m, y = value:match("(%d+)[%.%/%-](%d+)[%.%/%-](%d+)")
            if d and m and y then
                y = tonumber(y) or 0
                if y >= 2000 then y = y % 100 end
                return string.format("%02d.%02d.%02d", tonumber(d) or 0, tonumber(m) or 0, y)
            end
            return value
        end
    end
    return tostring(TPM_DayKey(timestamp))
end

local function TPM_NiceStep(rawStep)
    rawStep = math.max(0.000001, tonumber(rawStep) or 1)
    local exponent = math.floor(math.log(rawStep) / math.log(10))
    local fraction = rawStep / (10 ^ exponent)
    local niceFraction
    if fraction <= 1 then niceFraction = 1
    elseif fraction <= 2 then niceFraction = 2
    elseif fraction <= 2.5 then niceFraction = 2.5
    elseif fraction <= 5 then niceFraction = 5
    else niceFraction = 10 end
    return niceFraction * (10 ^ exponent)
end

function TPM:GetNiceHistoryBounds(dataMin, dataMax, definition, forceZero)
    dataMin, dataMax = tonumber(dataMin) or 0, tonumber(dataMax) or 0
    if forceZero then dataMin = math.min(0, dataMin) end
    if dataMax <= dataMin then
        if definition and definition.kind == "duration" then
            dataMin = 0
            dataMax = math.max(3600, dataMax)
        else
            dataMin = forceZero and 0 or math.floor(dataMin)
            dataMax = math.max(dataMin + 4, dataMax + 1)
        end
    end
    local rawStep = (dataMax - dataMin) / 4
    local step = TPM_NiceStep(rawStep)

    -- Duration axes should use human-friendly quarter/half/full hour steps.
    if definition and definition.kind == "duration" then
        if rawStep <= 300 then step = 300
        elseif rawStep <= 900 then step = 900
        elseif rawStep <= 1800 then step = 1800
        elseif rawStep <= 3600 then step = 3600
        elseif rawStep <= 7200 then step = 7200
        else step = TPM_NiceStep(rawStep) end
    end

    local niceMin = forceZero and 0 or (math.floor(dataMin / step) * step)
    local niceMax = math.ceil(dataMax / step) * step
    if niceMax <= niceMin then niceMax = niceMin + (step * 4) end
    return niceMin, niceMax
end

function TPM:GetHistoryTimeBounds(firstTime, lastTime, rangeDays)
    local now = TPM_Now()
    if rangeDays and rangeDays < 730 then
        return now - math.max(0, rangeDays - 1) * 86400, now
    end
    firstTime = tonumber(firstTime) or now
    lastTime = tonumber(lastTime) or now
    if lastTime <= firstTime then lastTime = firstTime + 86400 end
    return firstTime, lastTime
end

function TPM:RefreshHistoryAxisTicks(minValue, maxValue, firstTime, lastTime, definition, rangeDays, left, top, width, height)
    local chart = self.statisticsHistoryChart
    if not chart then return end
    left, top, width, height = left or 38, top or 76, width or 850, height or 158
    local axisFirst, axisLast = self:GetHistoryTimeBounds(firstTime, lastTime, rangeDays)
    for i = 1, 5 do
        local ratio = (i - 1) / 4
        local yTick = self.statisticsHistoryYTicks and self.statisticsHistoryYTicks[i]
        if yTick then
            local value = maxValue - ((maxValue - minValue) * ratio)
            yTick:ClearAnchors()
            yTick:SetAnchor(RIGHT, chart, TOPLEFT, left - 8, top + height * ratio)
            yTick:SetText(self:FormatHistoryMetricValue(value, definition))
            yTick:SetHidden(false)
        end
        local xTick = self.statisticsHistoryXTicks and self.statisticsHistoryXTicks[i]
        if xTick then
            local ts = axisFirst + ((axisLast - axisFirst) * ratio)
            xTick:ClearAnchors()
            xTick:SetAnchor(TOP, chart, TOPLEFT, left + width * ratio, top + height + 8)
            xTick:SetText(TPM_FormatChartDate(ts, rangeDays))
            xTick:SetHidden(false)
        end
    end
    return axisFirst, axisLast
end

function TPM:RefreshCombatHistoryChart(rangeDays)
    self:EnsureCombatDashboardControls()
    self:SetCombatDashboardVisible(true)
    if self.statisticsCombatChartTitle then
        local rangeText = rangeDays >= 730 and self:L("HISTORY_ALL") or self:L("HISTORY_RANGE_DAYS", rangeDays)
        self.statisticsCombatChartTitle:SetText(self:L("HISTORY_CHART_TITLE", rangeText))
    end
    local chart = self.statisticsHistoryChart
    if not chart or not self.statisticsCombatLineSets then return end

    local seriesDefs = {
        { historyKey = "npcKills",  setKey = "pveKills"  },
        { historyKey = "pveDeaths", setKey = "pveDeaths" },
        { historyKey = "pvpKills",  setKey = "pvpKills"  },
        { historyKey = "pvpDeaths", setKey = "pvpDeaths" },
    }
    local series = {}
    local globalMin, globalMax, firstTime, lastTime
    for _, def in ipairs(seriesDefs) do
        local pts = self:GetHistorySeries(def.historyKey, rangeDays) or {}
        series[def.setKey] = pts
        for _, p in ipairs(pts) do
            local value = tonumber(p.value) or 0
            globalMin = globalMin and math.min(globalMin, value) or value
            globalMax = globalMax and math.max(globalMax, value) or value
            local ts = tonumber(p.timestamp) or 0
            if ts > 0 then
                firstTime = firstTime and math.min(firstTime, ts) or ts
                lastTime = lastTime and math.max(lastTime, ts) or ts
            end
        end
    end

    for _, set in pairs(self.statisticsCombatLineSets or {}) do
        for _, c in ipairs(set.segments or {}) do c:SetHidden(true) end
        for _, c in ipairs(set.points or {}) do c:SetHidden(true) end
    end

    if not globalMin or (tonumber(globalMax) or 0) <= 0 then
        self.statisticsHistoryEmpty:SetHidden(false)
        self.statisticsHistoryEmpty:SetText(self:L("HISTORY_NO_COMBAT_DATA"))
        local minValue, maxValue = 0, 4
        local axisFirst, axisLast = self:GetHistoryTimeBounds(firstTime, lastTime, rangeDays)
        self:RefreshHistoryAxisTicks(minValue, maxValue, axisFirst, axisLast, nil, rangeDays, 38, 76, 850, 158)
        self.statisticsHistoryMinAxis:SetText("")
        self.statisticsHistoryMaxAxis:SetText("")
        self.statisticsHistoryStartAxis:SetText("")
        self.statisticsHistoryEndAxis:SetText("")
        return
    end
    self.statisticsHistoryEmpty:SetHidden(true)

    local minValue, maxValue = self:GetNiceHistoryBounds(globalMin, globalMax, nil, true)
    local valueRange = math.max(1, maxValue - minValue)
    local axisFirst, axisLast = self:GetHistoryTimeBounds(firstTime, lastTime, rangeDays)
    local timeRange = math.max(1, axisLast - axisFirst)
    local left, top, width, height = 38, 76, 850, 158

    for _, def in ipairs(seriesDefs) do
        local set = self.statisticsCombatLineSets[def.setKey]
        local coords = {}
        if set then
            for i, p in ipairs(series[def.setKey] or {}) do
                if i > HISTORY_MAX_CHART_POINTS then break end
                local ts = tonumber(p.timestamp) or axisFirst
                local x = left + Clamp((ts - axisFirst) / timeRange, 0, 1) * width
                local y = top + (1 - Clamp(((tonumber(p.value) or 0) - minValue) / valueRange, 0, 1)) * height
                coords[i] = { x = x, y = y }
                local dot = set.points and set.points[i]
                if dot then
                    dot:ClearAnchors()
                    dot:SetAnchor(CENTER, chart, TOPLEFT, x, y)
                    dot:SetHidden(false)
                end
            end
            for i = 1, #coords - 1 do
                local a, b = coords[i], coords[i + 1]
                local seg = set.segments and set.segments[i]
                if seg then
                    seg:ClearAnchors()
                    seg:SetAnchor(TOPLEFT, chart, TOPLEFT, a.x, a.y)
                    seg:SetAnchor(BOTTOMRIGHT, chart, TOPLEFT, b.x, b.y)
                    seg:SetHidden(false)
                end
            end
        end
    end

    self.statisticsHistoryMinAxis:SetText("")
    self.statisticsHistoryMaxAxis:SetText("")
    self.statisticsHistoryStartAxis:SetText("")
    self.statisticsHistoryEndAxis:SetText("")
    self:RefreshHistoryAxisTicks(minValue, maxValue, axisFirst, axisLast, nil, rangeDays, left, top, width, height)
end

function TPM:GetLastActivityText(session)
    if not session then return self:L("HISTORY_NO_ACTIVITY") end
    return self:GetActivityDisplayName(session)
end

function TPM:FormatHistoryAxisLabel(timestamp)
    timestamp = tonumber(timestamp) or 0
    if timestamp <= 0 then return "" end
    if type(GetDateStringFromTimestamp) == "function" then
        local ok, value = pcall(GetDateStringFromTimestamp, timestamp)
        if ok and type(value) == "string" and value ~= "" then return value end
    end
    return tostring(TPM_DayKey(timestamp))
end

function TPM:FormatHistoryMetricValue(value, definition)
    value = tonumber(value) or 0
    if definition and definition.kind == "percent" then return string.format("%.1f%%", value) end
    if definition and definition.kind == "decimal" then return string.format("%.2f", value) end
    if definition and definition.kind == "duration" then return TPM_FormatDuration(value) end
    return FormatNumber(value)
end

function TPM:RefreshHistoryChart(points, definition, rangeDays)
    local chart = self.statisticsHistoryChart
    if not chart then return end
    for _, seg in ipairs(self.statisticsHistorySegments or {}) do seg:SetHidden(true) end
    for _, dot in ipairs(self.statisticsHistoryPoints or {}) do dot:SetHidden(true) end

    if #points < 1 then
        self.statisticsHistoryEmpty:SetHidden(false)
        self.statisticsHistoryEmpty:SetText(self:L("HISTORY_EMPTY"))
        self.statisticsHistoryMinAxis:SetText("")
        self.statisticsHistoryMaxAxis:SetText("")
        if self.statisticsHistoryStartAxis then self.statisticsHistoryStartAxis:SetText("") end
        if self.statisticsHistoryEndAxis then self.statisticsHistoryEndAxis:SetText("") end
        return
    end
    self.statisticsHistoryEmpty:SetHidden(true)

    local dataMin, dataMax = points[1].value, points[1].value
    local firstTime, lastTime = points[1].timestamp or 0, points[#points].timestamp or 0
    for _, point in ipairs(points) do
        dataMin = math.min(dataMin, point.value)
        dataMax = math.max(dataMax, point.value)
    end
    local forceZero = definition and definition.kind == "duration"
    local minValue, maxValue = self:GetNiceHistoryBounds(dataMin, dataMax, definition, forceZero)
    local range = math.max(1, maxValue - minValue)
    local axisFirst, axisLast = self:GetHistoryTimeBounds(firstTime, lastTime, rangeDays)
    local timeRange = math.max(1, axisLast - axisFirst)
    local left, top, width, height = 44, 34, 850, 262
    local coords = {}
    for i, point in ipairs(points) do
        local xRatio = Clamp(((point.timestamp or axisFirst) - axisFirst) / timeRange, 0, 1)
        local x = left + (xRatio * width)
        local normalized = (point.value - minValue) / range
        local y = top + ((1 - normalized) * height)
        coords[i] = { x=x, y=y }
        local dot = self.statisticsHistoryPoints[i]
        if dot then
            dot:ClearAnchors()
            dot:SetAnchor(CENTER, chart, TOPLEFT, x, y)
            dot:SetHidden(false)
        end
    end
    for i = 1, #coords - 1 do
        local a, b = coords[i], coords[i+1]
        local segment = self.statisticsHistorySegments[i]
        if segment then
            segment:ClearAnchors()
            -- CT_LINE connects its two anchors directly. Unlike rotating a thin
            -- CT_TEXTURE, this does not clip diagonal segments inside a horizontal
            -- control rectangle.
            segment:SetAnchor(TOPLEFT, chart, TOPLEFT, a.x, a.y)
            segment:SetAnchor(BOTTOMRIGHT, chart, TOPLEFT, b.x, b.y)
            segment:SetHidden(false)
        end
    end
    self.statisticsHistoryMinAxis:SetText("")
    self.statisticsHistoryMaxAxis:SetText("")
    if self.statisticsHistoryStartAxis then self.statisticsHistoryStartAxis:SetText("") end
    if self.statisticsHistoryEndAxis then self.statisticsHistoryEndAxis:SetText("") end
    self:RefreshHistoryAxisTicks(minValue, maxValue, axisFirst, axisLast, definition, rangeDays, left, top, width, height)
end

function TPM:LayoutHistorySummaryCards(layoutKind)
    local cards = self.statisticsHistorySummaryCards or {}
    local compact = layoutKind == "currency"
    local combat = layoutKind == "counter"
    local function Place(card, x, width, hidden)
        if not card or not card.control then return end
        card.control:SetHidden(hidden == true)
        if hidden then return end
        card.control:ClearAnchors()
        card.control:SetDimensions(width, combat and 98 or 72)
        card.control:SetAnchor(TOPLEFT, self.statisticsHistoryPage, TOPLEFT, x, combat and 124 or 82)
        card.control:SetCenterColor(0.022, 0.021, 0.018, 0.995)
        card.control:SetEdgeColor(0.44, 0.34, 0.10, 0.95)
        if card.title then
            card.title:ClearAnchors()
            card.title:SetDimensions(combat and 126 or (width - 16), 22)
            card.title:SetAnchor(TOPRIGHT, card.control, TOPRIGHT, -8, combat and 11 or 7)
            card.title:SetFont(compact and "$(BOLD_FONT)|14" or "$(BOLD_FONT)|15")
            card.title:SetColor(0.86,0.82,0.73,1)
            card.title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        end
        if card.value then
            card.value:ClearAnchors()
            card.value:SetDimensions(combat and 126 or (width - 16), combat and 40 or 34)
            card.value:SetAnchor(TOPRIGHT, card.control, TOPRIGHT, -8, combat and 35 or 30)
            card.value:SetFont(combat and "$(ANTIQUE_FONT)|31" or (compact and "$(ANTIQUE_FONT)|23" or "$(ANTIQUE_FONT)|25"))
            card.value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        end
    end

    if layoutKind == "currency" then
        Place(cards.current, 20, 172, false)
        Place(cards.income, 206, 172, false)
        Place(cards.expenses, 392, 172, false)
        Place(cards.high, 578, 172, false)
        Place(cards.low, 764, 188, false)
        Place(cards.net, 0, 1, true)
        Place(cards.change, 0, 1, true)
    elseif layoutKind == "playtime" then
        Place(cards.current, 20, 450, false)
        Place(cards.change, 482, 470, false)
        Place(cards.high, 0, 1, true)
        Place(cards.low, 0, 1, true)
        Place(cards.income, 0, 1, true)
        Place(cards.expenses, 0, 1, true)
        Place(cards.net, 0, 1, true)
    elseif layoutKind == "counter" then
        Place(cards.current, 20, 218, false)
        Place(cards.change, 252, 218, false)
        Place(cards.high, 484, 218, false)
        Place(cards.low, 716, 236, false)
        Place(cards.income, 0, 1, true)
        Place(cards.expenses, 0, 1, true)
        Place(cards.net, 0, 1, true)
    else
        Place(cards.current, 20, 218, false)
        Place(cards.change, 252, 218, false)
        Place(cards.high, 484, 218, false)
        Place(cards.low, 716, 236, false)
        Place(cards.income, 0, 1, true)
        Place(cards.expenses, 0, 1, true)
        Place(cards.net, 0, 1, true)
    end

    -- Combat cards get subtle category tinting without sacrificing ESO readability.
    if combat then
        local tint = {
            current={0.035,0.060,0.022,0.995, 0.49,0.78,0.27},
            change ={0.060,0.025,0.020,0.995, 0.94,0.31,0.24},
            high   ={0.020,0.038,0.060,0.995, 0.36,0.62,0.91},
            low    ={0.060,0.025,0.020,0.995, 0.94,0.31,0.24},
        }
        for key, c in pairs(tint) do
            local card = cards[key]
            if card and card.control then
                card.control:SetCenterColor(c[1],c[2],c[3],c[4])
                card.control:SetEdgeColor(c[5],c[6],c[7],0.70)
            end
        end
    end

    local chart = self.statisticsHistoryChart
    local box = self.statisticsHistorySessionBox
    if chart then
        chart:ClearAnchors()
        chart:SetDimensions(932, combat and 282 or 350)
        chart:SetAnchor(TOPLEFT, self.statisticsHistoryPage, TOPLEFT, 20, combat and 198 or 170)
        if combat then chart:SetHidden(true) end
    end
    if box then
        box:ClearAnchors()
        if combat then
            box:SetDimensions(932, 378)
            box:SetAnchor(TOPLEFT, self.statisticsHistoryPage, TOPLEFT, 20, 232)
        elseif layoutKind == "currency" or layoutKind == "playtime" then
            box:SetDimensions(932, 220)
            box:SetAnchor(TOPLEFT, self.statisticsHistoryPage, TOPLEFT, 20, 230)
        else
            box:SetDimensions(932, 84)
            box:SetAnchor(TOPLEFT, self.statisticsHistoryPage, TOPLEFT, 20, 530)
        end
    end

    -- Range selector lives in the graph header. This removes the old overlap with
    -- the PvP heading and makes the control read like one cohesive toolbar.
    if chart then
        for i, bg in ipairs(self.statisticsHistoryRangeBackdrops or {}) do
            bg:ClearAnchors()
            bg:SetAnchor(TOPRIGHT, chart, TOPRIGHT, -14 - ((5 - i) * 68), 8)
        end
    end

    if not combat then
        self:SetCombatDashboardVisible(false)
        if self.statisticsHistorySessionText and box then
            self.statisticsHistorySessionText:ClearAnchors()
            self.statisticsHistorySessionText:SetDimensions(900, 44)
            self.statisticsHistorySessionText:SetAnchor(TOPLEFT, box, TOPLEFT, 14, 33)
        end
    end
end


function TPM:SetHistoryChartAreaVisible(visible)
    local show = visible == true
    if self.statisticsHistoryChart then self.statisticsHistoryChart:SetHidden(not show) end
    for _, button in ipairs(self.statisticsHistoryRangeButtons or {}) do button:SetHidden(not show) end
    for _, bg in ipairs(self.statisticsHistoryRangeBackdrops or {}) do bg:SetHidden(not show) end
    for _, tick in ipairs(self.statisticsHistoryYTicks or {}) do tick:SetHidden(not show) end
    for _, tick in ipairs(self.statisticsHistoryXTicks or {}) do tick:SetHidden(not show) end
    if self.statisticsHistoryMinAxis then self.statisticsHistoryMinAxis:SetHidden(not show) end
    if self.statisticsHistoryMaxAxis then self.statisticsHistoryMaxAxis:SetHidden(not show) end
    if self.statisticsHistoryStartAxis then self.statisticsHistoryStartAxis:SetHidden(not show) end
    if self.statisticsHistoryEndAxis then self.statisticsHistoryEndAxis:SetHidden(not show) end
    if self.statisticsHistoryEmpty then self.statisticsHistoryEmpty:SetHidden(not show) end
end

function TPM:GetTodayPlaySeconds()
    local currentPlayed = math.max(0, tonumber(self:SyncCurrentEsoPlayedTime()) or 0)
    local today = TPM_DayKey(TPM_Now())
    local store = self:GetHistoryStore()
    local latestBeforeToday, earliestToday = nil, nil

    local function Inspect(snapshot)
        if type(snapshot) ~= "table" then return end
        local ts = tonumber(snapshot.timestamp) or 0
        local played = tonumber(snapshot.esoPlayedSeconds or snapshot.playSeconds)
        if ts <= 0 or played == nil then return end
        local day = TPM_DayKey(ts)
        local entry = { timestamp = ts, played = math.max(0, played) }
        if day < today then
            if not latestBeforeToday or ts > latestBeforeToday.timestamp then latestBeforeToday = entry end
        elseif day == today then
            if not earliestToday or ts < earliestToday.timestamp then earliestToday = entry end
        end
    end

    for _, snapshot in pairs(store and store.daily or {}) do Inspect(snapshot) end
    for _, snapshot in ipairs(store and store.samples or {}) do Inspect(snapshot) end
    local active = store and store.activeSession
    if type(active) == "table" then
        Inspect(active.startSnapshot)
        Inspect(active.lastSnapshot)
    end

    if latestBeforeToday and currentPlayed >= latestBeforeToday.played then
        return math.max(0, Round(currentPlayed - latestBeforeToday.played))
    end

    local fallback = 0
    if earliestToday and currentPlayed >= earliestToday.played then
        fallback = math.max(0, Round(currentPlayed - earliestToday.played))
    end
    if type(active) == "table" then
        local endAt = active.segmentStartedAt and TPM_Now() or active.lastSeenAt
        fallback = math.max(fallback, self:GetHistoryActiveElapsed(active, endAt))
    end
    return math.max(0, Round(fallback))
end

function TPM:GetPlaytimePeriodTotal(days)
    local points = self:GetDailyPlaytimeHistorySeries(days)
    local total = 0
    if type(points) == "table" and points[1] and points[1].value ~= nil then
        -- Function may return points, definition. Sum daily values only once per day.
        local seen = {}
        for _, p in ipairs(points) do
            local dayKey = p.dayKey or TPM_DayKey(p.timestamp or 0)
            if not seen[dayKey] then
                seen[dayKey] = true
                total = total + math.max(0, tonumber(p.value) or 0)
            end
        end
    end
    return math.max(0, Round(total))
end

function TPM:RefreshHistoryStatisticsPage()
    if not self.statisticsHistoryPage or self.statisticsHistoryPage:IsHidden() then return end

    -- PvE / PvP is now a lifetime dashboard. Keep history only for the recent
    -- activity panel; do not calculate hidden chart/range data in the background.
    self:CheckpointHistory("combat_view", false)
    self.saved.historyMetric = "npcKills"
    self.statisticsHistoryTitle:SetText(self:L("HISTORY_PAGE_TITLE"))
    self.statisticsHistoryMetricLabel:SetText(self:L("HISTORY_COMBAT"))

    -- 3.4.34: these controls used to receive their text only once when the page
    -- was created. Changing DE/EN/RU at runtime therefore left stale headings.
    -- Re-localize every static combat label on every refresh.
    self:RefreshCombatProgressionBars()
    if self.statisticsCombatPveHeading then
        self.statisticsCombatPveHeading:ClearAnchors()
        self.statisticsCombatPveHeading:SetAnchor(TOPLEFT, self.statisticsHistoryPage, TOPLEFT, 20, 94)
        self.statisticsCombatPveHeading:SetText(self:L("HISTORY_PVE_HEADING"))
        self.statisticsCombatPveHeading:SetFont(self.langCode == "ru" and "$(BOLD_FONT)|15" or "$(BOLD_FONT)|18")
        self.statisticsCombatPveHeading:SetDimensions(self.langCode == "ru" and 260 or 250, 28)
    end
    if self.statisticsCombatBossBadge then
        self.statisticsCombatBossBadge:ClearAnchors()
        self.statisticsCombatBossBadge:SetAnchor(TOPLEFT, self.statisticsHistoryPage, TOPLEFT, 286, 94)
    end
    if self.statisticsCombatPvpHeading then
        self.statisticsCombatPvpHeading:ClearAnchors()
        self.statisticsCombatPvpHeading:SetAnchor(TOPRIGHT, self.statisticsHistoryPage, TOPRIGHT, -20, 94)
        self.statisticsCombatPvpHeading:SetText(self:L("HISTORY_PVP_HEADING"))
    end
    if self.statisticsCombatLegendLeft then
        self.statisticsCombatLegendLeft:SetText(self:L("HISTORY_COMBAT_LEGEND_PVE"))
    end
    if self.statisticsCombatLegendRight then
        self.statisticsCombatLegendRight:SetText(self:L("HISTORY_COMBAT_LEGEND_PVP"))
    end

    if self.statisticsHistoryPrevButton then self.statisticsHistoryPrevButton:SetHidden(true) end
    if self.statisticsHistoryNextButton then self.statisticsHistoryNextButton:SetHidden(true) end
    self:SetHistoryChartAreaVisible(false)
    self:EnsureCombatDashboardControls()
    self:LayoutHistorySummaryCards("counter")

    local combat = self:GetPlayerCombatStatsView()
    local cards = self.statisticsHistorySummaryCards or {}
    local combatTitleFont = self.langCode == "ru" and "$(BOLD_FONT)|13" or "$(BOLD_FONT)|15"
    for _, card in pairs({ cards.current, cards.change, cards.high, cards.low }) do
        if card and card.title then card.title:SetFont(combatTitleFont) end
    end
    if cards.current then
        cards.current.title:SetText(self:L("HISTORY_PVE_KILLS"))
        cards.current.value:SetText(FormatNumber(combat.npcKills or 0))
        cards.current.value:SetColor(0.55,0.82,0.24,1)
    end
    if cards.change then
        cards.change.title:SetText(self:L("HISTORY_PVE_DEATHS"))
        cards.change.value:SetText(FormatNumber(combat.pveDeaths or 0))
        cards.change.value:SetColor(0.90,0.28,0.24,1)
    end
    if cards.high then
        cards.high.title:SetText(self:L("HISTORY_PVP_KILLS"))
        cards.high.value:SetText(FormatNumber(combat.pvpKills or 0))
        cards.high.value:SetColor(0.36,0.66,0.95,1)
    end
    if cards.low then
        cards.low.title:SetText(self:L("HISTORY_PVP_DEATHS"))
        cards.low.value:SetText(FormatNumber(combat.pvpDeaths or 0))
        cards.low.value:SetColor(0.90,0.28,0.24,1)
    end
    if self.statisticsCombatBossText then
        self.statisticsCombatBossText:SetText(self:L("STAT_BOSS_KILLS") .. ": " .. FormatNumber(combat.bossKills or 0))
    end

    self:SetCombatDashboardVisible(true)

    -- With the chart removed, use the free space for recent activity instead of
    -- leaving the old chart-sized hole in the middle of the page.
    if self.statisticsHistorySessionBox then
        self.statisticsHistorySessionBox:ClearAnchors()
        self.statisticsHistorySessionBox:SetDimensions(932, 378)
        self.statisticsHistorySessionBox:SetAnchor(TOPLEFT, self.statisticsHistoryPage, TOPLEFT, 20, 232)
    end
    self:RefreshCombatActivityPanel()
end

function TPM:CreateStatisticsWindow()
    if self.statisticsWindow then return end
    if not WINDOW_MANAGER or not GuiRoot then return end

    local control = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "StatisticsWindow")
    control:SetDimensions(1000, 750)
    control:SetScale(Clamp(tonumber(self.saved and self.saved.statisticsWindowScale) or 100, 80, 120) / 100)
    control:SetDrawLayer(DL_OVERLAY)
    control:SetDrawTier(DT_HIGH)
    if control.SetDrawLevel then control:SetDrawLevel(7200) end
    control:SetMouseEnabled(true)
    control:SetMovable(true)
    control:SetClampedToScreen(true)
    control:SetHidden(true)

    if self.saved and type(self.saved.statisticsWindowX) == "number" and type(self.saved.statisticsWindowY) == "number" then
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.saved.statisticsWindowX, self.saved.statisticsWindowY)
    else
        -- 2.6.31_Beta: Statistics is a real standalone journal now. Anchor to
        -- GuiRoot instead of the world-map viewport so it can exist while the
        -- map scene is completely closed.
        control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    self.statisticsWindow = control

    local backdrop = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    backdrop:SetAnchorFill(control)
    -- Solid backdrop: do not use the semi-transparent tooltip center texture.
    backdrop:SetCenterColor(0.012, 0.011, 0.009, 1.00)
    backdrop:SetEdgeColor(0.78, 0.62, 0.24, 1.00)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 2)
    backdrop:SetInsets(8, 8, -8, -8)
    backdrop:SetMouseEnabled(false)

    local inner = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    inner:SetAnchor(TOPLEFT, control, TOPLEFT, 5, 5)
    inner:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -5, -5)
    inner:SetCenterColor(0.035, 0.031, 0.024, 1.00)
    inner:SetEdgeColor(0.38, 0.29, 0.12, 0.78)
    inner:SetEdgeTexture(nil, 1, 1, 1)
    inner:SetMouseEnabled(false)

    self.statisticsCornerOrnaments = {}
    local cornerDefs = {
        { point = TOPLEFT, rel = TOPLEFT, x = 7, y = 7, texture = "TamrielProgressMap/art/journal_corner_tl.dds" },
        { point = TOPRIGHT, rel = TOPRIGHT, x = -7, y = 7, texture = "TamrielProgressMap/art/journal_corner_tr.dds" },
        { point = BOTTOMLEFT, rel = BOTTOMLEFT, x = 7, y = -7, texture = "TamrielProgressMap/art/journal_corner_bl.dds" },
        { point = BOTTOMRIGHT, rel = BOTTOMRIGHT, x = -7, y = -7, texture = "TamrielProgressMap/art/journal_corner_br.dds" },
    }
    for _, def in ipairs(cornerDefs) do
        local ornament = WINDOW_MANAGER:CreateControl(nil, control, CT_TEXTURE)
        ornament:SetDimensions(30, 30)
        ornament:SetAnchor(def.point, control, def.rel, def.x, def.y)
        ornament:SetTexture(def.texture)
        ornament:SetColor(0.96, 0.78, 0.30, 0.88)
        if ornament.SetDrawLevel then ornament:SetDrawLevel(30) end
        ornament:SetMouseEnabled(false)
        self.statisticsCornerOrnaments[#self.statisticsCornerOrnaments + 1] = ornament
    end

    local title = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    title:SetDimensions(620, 42)
    title:SetAnchor(TOPLEFT, control, TOPLEFT, 22, 12)
    title:SetFont("ZoFontWinH2")
    title:SetColor(0.95, 0.82, 0.36, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsTitle = title

    local versionLabel = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    versionLabel:SetDimensions(126, 26)
    -- Keep build information with the title, before the language selector.
    versionLabel:SetAnchor(TOPLEFT, control, TOPLEFT, 212, 13)
    versionLabel:SetFont("$(MEDIUM_FONT)|15")
    versionLabel:SetColor(0.96, 0.96, 0.94, 1)
    versionLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    versionLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    versionLabel:SetText("")
    versionLabel:SetHidden(true)
    self.statisticsVersionLabel = versionLabel

    local dragHandle = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsDragHandle", control, CT_CONTROL)
    dragHandle:SetDimensions(720, 56)
    dragHandle:SetAnchor(TOPLEFT, control, TOPLEFT, 8, 4)
    dragHandle:SetMouseEnabled(true)
    dragHandle:SetHandler("OnMouseDown", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            TPM.statisticsWindowMoving = true
            control:StartMoving()
        end
    end)
    dragHandle:SetHandler("OnMouseUp", function(_, button)
        if button == MOUSE_BUTTON_INDEX_LEFT then
            TPM:StopMovingStatisticsWindow()
        end
    end)
    self.statisticsDragHandle = dragHandle

    local mode = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    mode:SetDimensions(280, 30)
    mode:SetAnchor(TOPRIGHT, control, TOPRIGHT, -58, 18)
    mode:SetFont("$(MEDIUM_FONT)|18")
    mode:SetColor(0.74, 0.71, 0.63, 1)
    mode:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    mode:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsMode = mode

    local langBar = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsLanguageBar", control, CT_CONTROL)
    langBar:SetDimensions(242, 28)
    langBar:SetAnchor(TOP, control, TOP, 0, 17)
    langBar:SetMouseEnabled(false)
    self.statisticsLanguageBar = langBar
    self.statisticsLanguageButtons = {}
    local langDefs = { {code="de",text="DE"}, {code="en",text="EN"}, {code="ru",text="RU"}, {code="fr",text="FR"} }
    for i, def in ipairs(langDefs) do
        local btn = WINDOW_MANAGER:CreateControl(nil, langBar, CT_LABEL)
        btn:SetDimensions(42, 24)
        btn:SetAnchor(LEFT, langBar, LEFT, (i - 1) * 48 + 4, 0)
        btn:SetFont("$(BOLD_FONT)|15")
        btn:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        btn:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        btn:SetMouseEnabled(true)
        btn.langCode = def.code
        btn:SetText(def.text)
        btn:SetHandler("OnMouseEnter", function(b) b:SetColor(1, 0.88, 0.38, 1) end)
        btn:SetHandler("OnMouseExit", function() TPM:RefreshStatisticsLanguageBar() end)
        btn:SetHandler("OnMouseUp", function(b, button, upInside)
            if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
                TPM:SetLanguage(b.langCode, true)
                TPM:RefreshStatisticsLanguageBar()
            end
        end)
        self.statisticsLanguageButtons[#self.statisticsLanguageButtons + 1] = btn
    end
    self:RefreshStatisticsLanguageBar()

    local close = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    close:SetDimensions(34, 34)
    close:SetAnchor(TOPRIGHT, control, TOPRIGHT, -12, 12)
    close:SetFont("ZoFontWinH3")
    close:SetText("X")
    close:SetColor(0.78, 0.72, 0.58, 1)
    close:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    close:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    close:SetMouseEnabled(true)
    close:SetHandler("OnMouseEnter", function(btn) btn:SetColor(1, 0.84, 0.38, 1) end)
    close:SetHandler("OnMouseExit", function(btn) btn:SetColor(0.78, 0.72, 0.58, 1) end)
    close:SetHandler("OnMouseUp", function(_, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then TPM:HideStatisticsWindow() end
    end)

    local topDivider = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    topDivider:SetDimensions(956, 1)
    topDivider:SetAnchor(TOPLEFT, control, TOPLEFT, 22, 56)
    topDivider:SetCenterColor(0.68, 0.56, 0.27, 0.68)
    topDivider:SetEdgeColor(0, 0, 0, 0)

    -- Dedicated container for the complete Progress page.  All progress-only
    -- controls are children of this control, so hiding the page hides every
    -- row/header/bar atomically and later row refreshes cannot bleed through
    -- to the Player or Economy pages.
    local progressPage = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsProgressPage", control, CT_CONTROL)
    progressPage:SetAnchorFill(control)
    progressPage:SetMouseEnabled(false)
    progressPage:SetHidden(false)
    self.statisticsProgressPage = progressPage

    -- Tamriel completion medallion: label above the ESO Ouroboros and the
    -- overall percentage centered cleanly inside the ring.
    local tamriel = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_LABEL)
    tamriel:SetDimensions(170, 24)
    tamriel:SetAnchor(TOPLEFT, control, TOPLEFT, 7, 55)
    tamriel:SetFont("$(BOLD_FONT)|19")
    tamriel:SetColor(0.88, 0.80, 0.60, 1)
    tamriel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    tamriel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsTamrielLabel = tamriel

    local medallion = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_TEXTURE)
    medallion:SetDimensions(132, 132)
    medallion:SetAnchor(TOPLEFT, control, TOPLEFT, 26, 68)
    medallion:SetTexture("TamrielProgressMap/art/tamriel_ouroboros.dds")
    -- Keep the original artwork colors instead of tinting the user-supplied ESO ring.
    medallion:SetColor(1.00, 1.00, 1.00, 0.98)
    medallion:SetMouseEnabled(false)
    self.statisticsTamrielMedallion = medallion

    local overall = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_LABEL)
    overall:SetDimensions(106, 44)
    overall:SetAnchor(CENTER, medallion, CENTER, 0, 3)
    overall:SetFont("$(ANTIQUE_FONT)|32")
    overall:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    overall:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsOverall = overall

    local tamrielDivider = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_BACKDROP)
    tamrielDivider:SetDimensions(1, 116)
    tamrielDivider:SetAnchor(TOPLEFT, control, TOPLEFT, 184, 72)
    tamrielDivider:SetCenterColor(0.46, 0.36, 0.16, 0.42)
    tamrielDivider:SetEdgeColor(0, 0, 0, 0)
    self.statisticsTamrielDivider = tamrielDivider

    local overallBar = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_BACKDROP)
    overallBar:SetDimensions(760, 20)
    overallBar:SetAnchor(TOPLEFT, control, TOPLEFT, 208, 72)
    overallBar:SetCenterColor(0.014, 0.013, 0.011, 0.96)
    overallBar:SetEdgeColor(0.58, 0.45, 0.17, 0.92)
    overallBar:SetEdgeTexture(nil, 1, 1, 1)
    self.statisticsOverallBar = overallBar

    local overallFill = WINDOW_MANAGER:CreateControl(nil, overallBar, CT_BACKDROP)
    overallFill:SetDimensions(1, 18)
    overallFill:SetAnchor(LEFT, overallBar, LEFT, 1, 0)
    overallFill:SetCenterColor(0.82, 0.62, 0.18, 0.98)
    overallFill:SetEdgeColor(0, 0, 0, 0)
    self.statisticsOverallFill = overallFill

    local overallFillShine = WINDOW_MANAGER:CreateControl(nil, overallFill, CT_BACKDROP)
    overallFillShine:SetAnchor(TOPLEFT, overallFill, TOPLEFT, 0, 0)
    overallFillShine:SetAnchor(TOPRIGHT, overallFill, TOPRIGHT, 0, 0)
    overallFillShine:SetHeight(3)
    overallFillShine:SetCenterColor(1.00, 0.90, 0.48, 0.34)
    overallFillShine:SetEdgeColor(0, 0, 0, 0)

    local overallBarPercent = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_LABEL)
    overallBarPercent:SetDimensions(62, 26)
    overallBarPercent:SetAnchor(RIGHT, overallBar, RIGHT, -8, 0)
    overallBarPercent:SetFont("$(BOLD_FONT)|19")
    overallBarPercent:SetColor(0.98, 0.82, 0.28, 1)
    overallBarPercent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    overallBarPercent:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsOverallBarPercent = overallBarPercent

    local subtitle = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_LABEL)
    subtitle:SetDimensions(760, 18)
    subtitle:SetAnchor(TOPLEFT, control, TOPLEFT, 208, 94)
    subtitle:SetFont("$(MEDIUM_FONT)|15")
    subtitle:SetColor(0.64, 0.61, 0.54, 1)
    subtitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    subtitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    subtitle:SetWidth(390)
    self.statisticsSubtitle = subtitle

    -- 2.6.14: Native-style zone focus selector. "Tamriel" preserves the old
    -- all-zone view; any supported Zone Story narrows the summary, categories
    -- and zone table to that one zone without affecting global history/goals.
    local focusLabel = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_LABEL)
    focusLabel:SetDimensions(72, 24)
    focusLabel:SetAnchor(TOPLEFT, control, TOPLEFT, 598, 92)
    focusLabel:SetFont("$(MEDIUM_FONT)|14")
    focusLabel:SetColor(0.74, 0.70, 0.62, 1)
    focusLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    focusLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsFocusLabel = focusLabel

    -- 2.6.15: Own TPM selector instead of ZO_ComboBox. The virtual combo could
    -- render correctly but not receive/open its dropdown in the world-map
    -- overlay. This control is fully mouse-driven and its popup lives directly
    -- on the statistics top-level window, so it cannot be clipped by the page.
    local focusSelector = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsFocusSelector", progressPage, CT_CONTROL)
    focusSelector:SetDimensions(286, 26)
    focusSelector:SetAnchor(TOPLEFT, control, TOPLEFT, 678, 91)
    focusSelector:SetMouseEnabled(true)
    local focusSelectorBg = WINDOW_MANAGER:CreateControl(nil, focusSelector, CT_BACKDROP)
    focusSelectorBg:SetAnchorFill(focusSelector)
    focusSelectorBg:SetCenterColor(0.022, 0.020, 0.016, 0.98)
    focusSelectorBg:SetEdgeColor(0.72, 0.58, 0.17, 0.95)
    focusSelectorBg:SetEdgeTexture(nil, 1, 1, 1)
    focusSelectorBg:SetMouseEnabled(false)
    local focusSelected = WINDOW_MANAGER:CreateControl(nil, focusSelector, CT_LABEL)
    focusSelected:SetDimensions(250, 24)
    focusSelected:SetAnchor(LEFT, focusSelector, LEFT, 8, 0)
    focusSelected:SetFont("$(MEDIUM_FONT)|16")
    focusSelected:SetColor(0.94, 0.91, 0.82, 1)
    focusSelected:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    focusSelected:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    local focusArrow = WINDOW_MANAGER:CreateControl(nil, focusSelector, CT_LABEL)
    focusArrow:SetDimensions(22, 24)
    focusArrow:SetAnchor(RIGHT, focusSelector, RIGHT, -4, 0)
    focusArrow:SetFont("$(BOLD_FONT)|15")
    focusArrow:SetColor(0.95, 0.78, 0.20, 1)
    focusArrow:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    focusArrow:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    focusArrow:SetText("▼")
    focusSelector:SetHandler("OnMouseEnter", function()
        focusSelectorBg:SetCenterColor(0.085, 0.066, 0.025, 0.98)
        focusSelectorBg:SetEdgeColor(0.95, 0.76, 0.20, 1)
    end)
    focusSelector:SetHandler("OnMouseExit", function()
        focusSelectorBg:SetCenterColor(0.022, 0.020, 0.016, 0.98)
        focusSelectorBg:SetEdgeColor(0.72, 0.58, 0.17, 0.95)
    end)
    focusSelector:SetHandler("OnMouseUp", function(_, button, upInside)
        if upInside and button == MOUSE_BUTTON_INDEX_LEFT then TPM:ToggleStatisticsFocusDropdown() end
    end)
    focusSelector:SetHandler("OnMouseWheel", function(_, delta)
        if TPM.statisticsFocusDropdown and not TPM.statisticsFocusDropdown:IsHidden() then
            TPM:ScrollStatisticsFocusDropdown(delta)
        end
    end)
    self.statisticsFocusSelector = focusSelector
    self.statisticsFocusSelectedLabel = focusSelected
    self.statisticsFocusArrow = focusArrow

    local focusDropdown = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsFocusDropdown", control, CT_CONTROL)
    focusDropdown:SetDimensions(286, 242)
    focusDropdown:SetAnchor(TOPLEFT, control, TOPLEFT, 678, 120)
    focusDropdown:SetMouseEnabled(true)
    focusDropdown:SetHidden(true)
    if focusDropdown.SetDrawTier then focusDropdown:SetDrawTier(DT_HIGH) end
    if focusDropdown.SetDrawLayer then focusDropdown:SetDrawLayer(DL_OVERLAY) end
    if focusDropdown.SetDrawLevel then focusDropdown:SetDrawLevel(7600) end
    focusDropdown:SetHandler("OnMouseWheel", function(_, delta) TPM:ScrollStatisticsFocusDropdown(delta) end)
    local focusDropdownBg = WINDOW_MANAGER:CreateControl(nil, focusDropdown, CT_BACKDROP)
    focusDropdownBg:SetAnchorFill(focusDropdown)
    focusDropdownBg:SetCenterColor(0.010, 0.009, 0.007, 0.995)
    focusDropdownBg:SetEdgeColor(0.88, 0.70, 0.18, 1)
    focusDropdownBg:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 2)
    focusDropdownBg:SetInsets(2, 2, -2, -2)
    focusDropdownBg:SetMouseEnabled(false)

    self.statisticsFocusDropdownRows = {}
    for rowIndex = 1, 9 do
        local row = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsFocusRow" .. tostring(rowIndex), focusDropdown, CT_BUTTON)
        row:SetDimensions(258, 25)
        row:SetAnchor(TOPLEFT, focusDropdown, TOPLEFT, 4, 4 + ((rowIndex - 1) * 26))
        row:SetMouseEnabled(true)
        if row.SetDrawLayer then row:SetDrawLayer(DL_OVERLAY) end
        if row.SetDrawLevel then row:SetDrawLevel(7610 + rowIndex) end
        local rowBg = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
        rowBg:SetAnchorFill(row)
        rowBg:SetCenterColor(0.025, 0.022, 0.017, 0.98)
        rowBg:SetEdgeColor(0.23, 0.19, 0.10, 0.85)
        rowBg:SetEdgeTexture(nil, 1, 1, 1)
        rowBg:SetMouseEnabled(false)
        local rowLabel = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
        rowLabel:SetDimensions(220, 23)
        rowLabel:SetAnchor(LEFT, row, LEFT, 8, 0)
        rowLabel:SetFont("$(MEDIUM_FONT)|15")
        rowLabel:SetColor(0.91, 0.88, 0.78, 1)
        rowLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        rowLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        local selectedMark = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
        selectedMark:SetDimensions(24, 23)
        selectedMark:SetAnchor(RIGHT, row, RIGHT, -6, 0)
        selectedMark:SetFont("$(BOLD_FONT)|16")
        selectedMark:SetColor(1.00, 0.84, 0.26, 1)
        selectedMark:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        selectedMark:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        selectedMark:SetText("")
        row.bg, row.label, row.selectedMark = rowBg, rowLabel, selectedMark
        row:SetHandler("OnMouseEnter", function(r)
            r.bg:SetCenterColor(0.13, 0.10, 0.035, 0.99)
            r.label:SetColor(1.00, 0.84, 0.26, 1)
        end)
        row:SetHandler("OnMouseExit", function(r)
            if r.selected then
                r.bg:SetCenterColor(0.16, 0.125, 0.040, 0.98)
                r.label:SetColor(1.00, 0.84, 0.26, 1)
            else
                r.bg:SetCenterColor(0.025, 0.022, 0.017, 0.98)
                r.label:SetColor(0.91, 0.88, 0.78, 1)
            end
        end)
        row:SetHandler("OnMouseWheel", function(_, delta) TPM:ScrollStatisticsFocusDropdown(delta) end)
        -- 2.6.19: use the native button click event. OnMouseUp/upInside on a
        -- custom CT_CONTROL was unreliable while the popup overlapped the main
        -- progress controls, which made every zone look unselectable.
        row:SetHandler("OnClicked", function(r, button)
            if button and button ~= MOUSE_BUTTON_INDEX_LEFT then return end
            if r.TPMZoneId == nil then return end
            local zoneId = tonumber(r.TPMZoneId) or 0

            -- Apply and paint the choice before closing the popup. In 2.6.19
            -- the popup was hidden first, so the old OnMouseExit state could
            -- briefly erase the highlight and make selection feel unreliable.
            if TPM:SetStatisticsFocusZone(zoneId) then
                if TPM.statisticsFocusSelectedLabel then
                    TPM.statisticsFocusSelectedLabel:SetText(zoneId > 0 and SafeZoneName(zoneId) or TPM:L("STAT_FOCUS_TAMRIEL"))
                end
                TPM:RefreshStatisticsFocusDropdownRows()
            end
            TPM:HideStatisticsFocusDropdown()
        end)
        self.statisticsFocusDropdownRows[rowIndex] = row
    end

    -- 2.6.18: one real vertical scroll rail instead of tiny up/down buttons.
    -- It can be dragged just like the main zone-list scrollbar and mouse-wheel
    -- scrolling remains available anywhere inside the popup.
    local focusScrollBar = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsFocusScrollBar", focusDropdown, CT_SLIDER)
    focusScrollBar:SetDimensions(14, 226)
    focusScrollBar:SetAnchor(TOPRIGHT, focusDropdown, TOPRIGHT, -5, 8)
    focusScrollBar:SetOrientation(ORIENTATION_VERTICAL)
    focusScrollBar:SetMouseEnabled(true)
    local focusElevator = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
    focusScrollBar:SetThumbTexture(focusElevator, focusElevator, focusElevator, 18, 44, 0, 0, 1, 1)
    if focusScrollBar.SetBackgroundMiddleTexture then
        focusScrollBar:SetBackgroundMiddleTexture("/esoui/art/chatwindow/chat_scrollbar_track.dds", 0, 0, 1, 1)
    end
    focusScrollBar:SetValueStep(1)
    focusScrollBar:SetMinMax(0, 0)
    focusScrollBar:SetValue(0)
    focusScrollBar:SetHandler("OnValueChanged", function(_, value)
        if TPM.statisticsFocusScrollBarRefreshing then return end
        TPM.statisticsFocusDropdownOffset = Round(tonumber(value) or 0)
        TPM:RefreshStatisticsFocusDropdownRows()
    end)
    self.statisticsFocusDropdown = focusDropdown
    self.statisticsFocusScrollBar = focusScrollBar
    self.statisticsFocusScrollUp = nil
    self.statisticsFocusScrollDown = nil

    self.statisticsCards =
    {
        self:CreateStatisticsSummaryCard(progressPage, ADDON_NAME .. "StatsCardZones", 208, 146, "TamrielProgressMap/art/stat_complete.dds"),
        self:CreateStatisticsSummaryCard(progressPage, ADDON_NAME .. "StatsCardObjectives", 361, 146, "TamrielProgressMap/art/stat_objectives.dds"),
        self:CreateStatisticsSummaryCard(progressPage, ADDON_NAME .. "StatsCardRemaining", 514, 146, "TamrielProgressMap/art/stat_remaining.dds"),
        self:CreateStatisticsSummaryCard(progressPage, ADDON_NAME .. "StatsCardUntouched", 667, 146, "TamrielProgressMap/art/stat_untouched.dds"),
    }
    self.statisticsPlaytimeCard = self:CreateProgressPlaytimeCard(progressPage, ADDON_NAME .. "StatsCardPlaytime", 820, 146)

    -- Level / CP remains on Player. ESO play time is now part of the main
    -- Progress overview so Development can stay focused on Gold and PvE/PvP.

    local categoryTitle = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_LABEL)
    categoryTitle:SetDimensions(450, 28)
    categoryTitle:SetAnchor(TOPLEFT, control, TOPLEFT, 22, 202)
    categoryTitle:SetFont("ZoFontWinH4")
    categoryTitle:SetColor(0.90, 0.77, 0.34, 1)
    categoryTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    categoryTitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsCategoryTitle = categoryTitle

    local categoryGearButton = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_BUTTON)
    categoryGearButton:SetDimensions(18, 18)
    categoryGearButton:SetAnchor(TOPLEFT, control, TOPLEFT, 472, 207)
    categoryGearButton:SetMouseEnabled(true)
    local categoryGearIcon = WINDOW_MANAGER:CreateControl(nil, categoryGearButton, CT_TEXTURE)
    categoryGearIcon:SetDimensions(16, 16)
    categoryGearIcon:SetAnchor(CENTER, categoryGearButton, CENTER, 0, 0)
    categoryGearIcon:SetTexture("TamrielProgressMap/art/settings_gear.dds")
    categoryGearIcon:SetColor(0.55, 0.52, 0.46, 0.80)
    categoryGearIcon:SetMouseEnabled(false)
    categoryGearButton.TPMIcon = categoryGearIcon
    self.statisticsCategoryGearButton = categoryGearButton
    self.statisticsCategoryGearIcon = categoryGearIcon

    -- 2.6.5: Use one clean divider without a center glyph. The font-based
    -- diamond could look optically off-center at different UI scales even
    -- when its control was mathematically centered.
    local categoryDivider = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_BACKDROP)
    categoryDivider:SetDimensions(956, 1)
    categoryDivider:SetAnchor(TOPLEFT, control, TOPLEFT, 22, 227)
    categoryDivider:SetCenterColor(0.42, 0.34, 0.17, 0.52)
    categoryDivider:SetEdgeColor(0, 0, 0, 0)
    self.statisticsCategoryDivider = categoryDivider

    local categoryPanelLeft = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_BACKDROP)
    categoryPanelLeft:SetDimensions(456, 164)
    categoryPanelLeft:SetAnchor(TOPLEFT, control, TOPLEFT, 22, 232)
    categoryPanelLeft:SetCenterColor(0.022, 0.020, 0.016, 0.64)
    categoryPanelLeft:SetEdgeColor(0.34, 0.27, 0.12, 0.58)
    categoryPanelLeft:SetEdgeTexture(nil, 1, 1, 1)
    categoryPanelLeft:SetMouseEnabled(false)
    self.statisticsCategoryPanelLeft = categoryPanelLeft

    local categoryPanelRight = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_BACKDROP)
    categoryPanelRight:SetDimensions(456, 164)
    categoryPanelRight:SetAnchor(TOPLEFT, control, TOPLEFT, 510, 232)
    categoryPanelRight:SetCenterColor(0.022, 0.020, 0.016, 0.64)
    categoryPanelRight:SetEdgeColor(0.34, 0.27, 0.12, 0.58)
    categoryPanelRight:SetEdgeTexture(nil, 1, 1, 1)
    categoryPanelRight:SetMouseEnabled(false)
    self.statisticsCategoryPanelRight = categoryPanelRight

    self.statisticsCategoryRows = {}
    for index = 1, (#COMPLETION_TYPES + 2) do
        self.statisticsCategoryRows[index] = self:CreateStatisticsCategoryRow(progressPage, index)
    end

    -- 2.5.0 TEST: collection rows occupy the exact same grid and are only
    -- shown on page 2. Page 1 controls above are intentionally unchanged.
    self.statisticsCollectionRows = {}
    for index = 1, #COLLECTION_STAT_DEFINITIONS do
        local row = self:CreateStatisticsCategoryRow(progressPage, index, "StatsCollection")
        row.label:SetFont("$(MEDIUM_FONT)|14")
        row.control:SetHidden(true)
        self.statisticsCollectionRows[index] = row
    end

    -- 2.6.0: Page 3 uses the same 8 + 8 grid for ESO achievement categories.
    self.statisticsAchievementRows = {}
    for index = 1, 16 do
        local row = self:CreateStatisticsCategoryRow(progressPage, index, "StatsAchievement")
        row.label:SetFont("$(MEDIUM_FONT)|14")
        row.count:SetFont("$(MEDIUM_FONT)|13")
        row.control:SetHidden(true)
        self.statisticsAchievementRows[index] = row
    end

    -- 2.6.8: Compact sort bar shared by Completion / Collections / Achievements.
    local categorySortBox = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatsCategorySortBox", progressPage, CT_BACKDROP)
    categorySortBox:SetDimensions(326, 26)
    categorySortBox:SetAnchor(TOPLEFT, control, TOPLEFT, 505, 201)
    categorySortBox:SetCenterColor(0.024, 0.021, 0.016, 0.82)
    categorySortBox:SetEdgeColor(0.34, 0.27, 0.12, 0.62)
    categorySortBox:SetEdgeTexture(nil, 1, 1, 1)
    categorySortBox:SetMouseEnabled(false)
    self.statisticsCategorySortBox = categorySortBox
    self.statisticsCategorySortButtons = {}

    local function CreateCategorySortButton(key, x, width)
        local back = WINDOW_MANAGER:CreateControl(nil, categorySortBox, CT_BACKDROP)
        back:SetDimensions(width, 22)
        back:SetAnchor(LEFT, categorySortBox, LEFT, x, 0)
        back:SetCenterColor(0.035, 0.031, 0.024, 0.72)
        back:SetEdgeColor(0.30, 0.24, 0.12, 0.45)
        back:SetEdgeTexture(nil, 1, 1, 1)
        back:SetMouseEnabled(false)

        local button = WINDOW_MANAGER:CreateControl(nil, categorySortBox, CT_BUTTON)
        button:SetDimensions(width, 22)
        button:SetAnchorFill(back)
        button:SetFont("$(BOLD_FONT)|13")
        button:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        button:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        button:SetMouseOverFontColor(1.00, 0.90, 0.40, 1)
        button:SetPressedFontColor(1.00, 0.72, 0.18, 1)
        button:SetHandler("OnClicked", function() TPM:SetStatisticsCategorySortMode(key) end)
        button.TPMBackdrop = back
        self.statisticsCategorySortButtons[key] = button
    end

    CreateCategorySortButton("all", 2, 64)
    CreateCategorySortButton("name", 68, 66)
    CreateCategorySortButton("asc", 136, 92)
    CreateCategorySortButton("desc", 230, 94)
    self:RefreshStatisticsCategorySortControls()

    local categoryPrev = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatsCategoryPrev", progressPage, CT_BUTTON)
    categoryPrev:SetDimensions(28, 24)
    categoryPrev:SetAnchor(TOPRIGHT, control, TOPRIGHT, -116, 202)
    categoryPrev:SetFont("$(BOLD_FONT)|20")
    categoryPrev:SetText("‹")
    categoryPrev:SetNormalFontColor(0.86, 0.72, 0.28, 1)
    categoryPrev:SetMouseOverFontColor(1.00, 0.88, 0.42, 1)
    categoryPrev:SetPressedFontColor(1.00, 0.70, 0.14, 1)
    categoryPrev:SetHandler("OnClicked", function() TPM:SetStatisticsCompletionPage(TPM:GetStatisticsCompletionPage() - 1) end)
    categoryPrev:SetHandler("OnMouseEnter", function(control)
        local targetPage = math.max(1, TPM:GetStatisticsCompletionPage() - 1)
        local key = targetPage == 1 and "STAT_PAGE_COMPLETION" or "STAT_PAGE_COLLECTIONS"
        TPM:ShowStatisticsHoverTooltip(TPM:L(key), "", control)
    end)
    categoryPrev:SetHandler("OnMouseExit", function() TPM:HideStatisticsHoverTooltips() end)
    self.statisticsCategoryPrev = categoryPrev

    local categoryPageIndicator = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_LABEL)
    categoryPageIndicator:SetDimensions(54, 24)
    categoryPageIndicator:SetAnchor(TOPRIGHT, control, TOPRIGHT, -58, 202)
    categoryPageIndicator:SetFont("$(BOLD_FONT)|14")
    categoryPageIndicator:SetColor(0.78, 0.72, 0.58, 1)
    categoryPageIndicator:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    categoryPageIndicator:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    categoryPageIndicator:SetText("1 / 3")
    self.statisticsCategoryPageIndicator = categoryPageIndicator

    local categoryNext = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatsCategoryNext", progressPage, CT_BUTTON)
    categoryNext:SetDimensions(28, 24)
    categoryNext:SetAnchor(TOPRIGHT, control, TOPRIGHT, -22, 202)
    categoryNext:SetFont("$(BOLD_FONT)|20")
    categoryNext:SetText("›")
    categoryNext:SetNormalFontColor(0.86, 0.72, 0.28, 1)
    categoryNext:SetMouseOverFontColor(1.00, 0.88, 0.42, 1)
    categoryNext:SetPressedFontColor(1.00, 0.70, 0.14, 1)
    categoryNext:SetHandler("OnClicked", function() TPM:SetStatisticsCompletionPage(TPM:GetStatisticsCompletionPage() + 1) end)
    categoryNext:SetHandler("OnMouseEnter", function(control)
        local targetPage = math.min(3, TPM:GetStatisticsCompletionPage() + 1)
        local key = targetPage == 2 and "STAT_PAGE_COLLECTIONS" or "STAT_PAGE_ACHIEVEMENTS"
        TPM:ShowStatisticsHoverTooltip(TPM:L(key), "", control)
    end)
    categoryNext:SetHandler("OnMouseExit", function() TPM:HideStatisticsHoverTooltips() end)
    self.statisticsCategoryNext = categoryNext

    local zoneSectionTop = 402
    local zoneTitle = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_LABEL)
    zoneTitle:SetDimensions(410, 30)
    zoneTitle:SetAnchor(TOPLEFT, control, TOPLEFT, 22, zoneSectionTop)
    zoneTitle:SetFont("ZoFontWinH4")
    zoneTitle:SetColor(0.90, 0.77, 0.34, 1)
    zoneTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    zoneTitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsZoneTitle = zoneTitle

    local function CreateSortButton(name, rightOffset, sortMode)
        local button = WINDOW_MANAGER:CreateControl(name, progressPage, CT_BUTTON)
        button:SetDimensions(132, 30)
        button:SetAnchor(TOPRIGHT, progressPage, TOPRIGHT, rightOffset, zoneSectionTop)
        button:SetFont("$(BOLD_FONT)|19")
        button:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        button:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        button:SetNormalFontColor(0.86, 0.78, 0.58, 1)
        button:SetMouseOverFontColor(1.00, 0.84, 0.36, 1)
        button:SetPressedFontColor(0.90, 0.72, 0.28, 1)
        button:SetMouseEnabled(true)
        button:SetHandler("OnClicked", function()
            TPM.saved.statisticsSortMode = sortMode
            TPM.statisticsScrollOffset = 0
            TPM:InvalidateStatisticsData(false)
            TPM:RefreshStatisticsWindow()
        end)
        return button
    end

    local sortProgress = CreateSortButton(ADDON_NAME .. "StatsSortProgress", -164, "progress")
    self.statisticsSortProgress = sortProgress

    local sortName = CreateSortButton(ADDON_NAME .. "StatsSortName", -22, "name")
    self.statisticsSortName = sortName

    local zonePanel = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_BACKDROP)
    zonePanel:SetDimensions(944, 250)
    zonePanel:SetAnchor(TOPLEFT, control, TOPLEFT, 22, zoneSectionTop + 32)
    zonePanel:SetCenterColor(0.014, 0.014, 0.012, 0.92)
    zonePanel:SetEdgeColor(0.54, 0.41, 0.15, 0.82)
    zonePanel:SetEdgeTexture(nil, 1, 1, 1)
    zonePanel:SetMouseEnabled(false)
    self.statisticsZonePanel = zonePanel

    local header = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_BACKDROP)
    header:SetDimensions(936, 28)
    header:SetAnchor(TOPLEFT, control, TOPLEFT, 22, zoneSectionTop + 34)
    header:SetCenterColor(0.090, 0.066, 0.025, 0.96)
    header:SetEdgeColor(0.62, 0.48, 0.18, 0.74)
    header:SetEdgeTexture(nil, 1, 1, 1)
    self.statisticsHeaderBackdrop = header

    local function HeaderLabel(width, x, align)
        local label = WINDOW_MANAGER:CreateControl(nil, header, CT_LABEL)
        label:SetDimensions(width, 28)
        label:SetAnchor(LEFT, header, LEFT, x, 0)
        label:SetFont("$(BOLD_FONT)|19")
        label:SetColor(0.78, 0.72, 0.58, 1)
        label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        return label
    end
    self.statisticsHeaderZone = HeaderLabel(380, 10, TEXT_ALIGN_LEFT)
    self.statisticsHeaderProgress = HeaderLabel(238, 398, TEXT_ALIGN_RIGHT)
    self.statisticsHeaderDone = HeaderLabel(115, 655, TEXT_ALIGN_RIGHT)
    self.statisticsHeaderOpen = HeaderLabel(90, 815, TEXT_ALIGN_RIGHT)

    -- Use a dedicated slider + seven reusable rows instead of ZO_ScrollContainer.
    -- This makes the thumb directly draggable and avoids the generic map scroll
    -- container swallowing mouse input.
    local listArea = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsListArea", progressPage, CT_CONTROL)
    listArea:SetDimensions(918, STATISTICS_VISIBLE_ZONE_ROWS * 31)
    listArea:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 4)
    listArea:SetMouseEnabled(true)
    listArea:SetHandler("OnMouseWheel", function(_, delta) TPM:ScrollStatistics(delta) end)
    self.statisticsListArea = listArea

    self.statisticsZoneRows = {}
    for slot = 1, STATISTICS_VISIBLE_ZONE_ROWS do
        self.statisticsZoneRows[slot] = self:CreateStatisticsZoneRow(listArea, slot)
    end

    local scrollBar = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsScrollBar", progressPage, CT_SLIDER)
    scrollBar:SetDimensions(14, STATISTICS_VISIBLE_ZONE_ROWS * 31)
    scrollBar:SetAnchor(TOPLEFT, listArea, TOPRIGHT, 5, 0)
    scrollBar:SetOrientation(ORIENTATION_VERTICAL)
    scrollBar:SetMouseEnabled(true)
    local elevator = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
    scrollBar:SetThumbTexture(elevator, elevator, elevator, 18, 48, 0, 0, 1, 1)
    if scrollBar.SetBackgroundMiddleTexture then
        scrollBar:SetBackgroundMiddleTexture("/esoui/art/chatwindow/chat_scrollbar_track.dds", 0, 0, 1, 1)
    end
    scrollBar:SetValueStep(1)
    scrollBar:SetMinMax(0, 0)
    scrollBar:SetValue(0)
    scrollBar:SetHandler("OnValueChanged", function(_, value)
        if TPM.saved and TPM.saved.statisticsPage ~= "progress" then return end
        TPM.statisticsScrollOffset = Clamp(Round(value or 0), 0, TPM:GetStatisticsMaxScrollOffset())
        TPM:RefreshStatisticsZoneRows()
    end)
    self.statisticsScrollBar = scrollBar
    self.statisticsScrollOffset = self.statisticsScrollOffset or 0

    local hint = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    hint:SetDimensions(930, 18)
    hint:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, 22, -48)
    hint:SetFont("$(MEDIUM_FONT)|15")
    hint:SetColor(0.64, 0.61, 0.55, 1)
    hint:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    hint:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    hint:SetHidden(true)
    self.statisticsHint = hint

    -- Every journal section is a real, independent page container in 3.0.
    -- Only one page is visible at a time, preventing refreshes from bleeding
    -- controls into another section.
    -- 3.4.6: Player is no longer a separate statistics page. Its combat
    -- counters remain internal and feed the PvE / PvP page.
    self:CreateEconomyStatisticsPage(control)
    self:CreateHistoryStatisticsPage(control)
    self:CreateAllianceStatisticsPage(control)

    local footerDivider = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    footerDivider:SetDimensions(956, 1)
    footerDivider:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, 22, -41)
    footerDivider:SetCenterColor(0.46, 0.35, 0.14, 0.62)
    footerDivider:SetEdgeColor(0, 0, 0, 0)
    self.statisticsFooterDivider = footerDivider

    local function CreatePageTab(name, x, pageName, width)
        width = tonumber(width) or 292
        local tabBg = WINDOW_MANAGER:CreateControl(name .. "Bg", control, CT_BACKDROP)
        tabBg:SetDimensions(width, 34)
        tabBg:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, x, -4)
        tabBg:SetCenterColor(0.026, 0.023, 0.018, 0.94)
        tabBg:SetEdgeColor(0.36, 0.29, 0.14, 0.70)
        tabBg:SetEdgeTexture(nil, 1, 1, 1)
        tabBg:SetMouseEnabled(false)

        local button = WINDOW_MANAGER:CreateControl(name, control, CT_BUTTON)
        button:SetDimensions(width, 34)
        button:SetAnchorFill(tabBg)
        button:SetFont("$(BOLD_FONT)|18")
        button:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        button:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        button:SetNormalFontColor(0.78, 0.72, 0.58, 1)
        button:SetMouseOverFontColor(1.00, 0.84, 0.36, 1)
        button:SetPressedFontColor(0.95, 0.75, 0.24, 1)
        button:SetMouseEnabled(true)
        button:SetHandler("OnClicked", function() TPM:SetStatisticsPage(pageName) end)
        local accent = WINDOW_MANAGER:CreateControl(nil, tabBg, CT_BACKDROP)
        accent:SetDimensions(math.max(20, width - 10), 2)
        accent:SetAnchor(TOP, tabBg, TOP, 0, 1)
        accent:SetCenterColor(0.90, 0.68, 0.18, 0.88)
        accent:SetEdgeColor(0, 0, 0, 0)
        accent:SetHidden(true)
        button.TPMBackdrop = tabBg
        button.TPMAccent = accent
        button.TPMPageName = pageName
        return button
    end

    self.statisticsProgressTab = CreatePageTab(ADDON_NAME .. "StatsTabProgress", 42, "progress", 216)
    self.statisticsPlayerTab = nil
    self.statisticsEconomyTab = CreatePageTab(ADDON_NAME .. "StatsTabEconomy", 278, "economy", 216)
    self.statisticsHistoryTab = CreatePageTab(ADDON_NAME .. "StatsTabHistory", 514, "history", 216)
    self.statisticsAllianceTab = CreatePageTab(ADDON_NAME .. "StatsTabAlliance", 750, "alliance", 216)
    self:RefreshStatisticsPageTabs()
end

function TPM:GetStatisticsViewportBounds()
    local parent = GuiRoot
    local parentLeft = (parent and parent.GetLeft and parent:GetLeft()) or 0
    local parentTop = (parent and parent.GetTop and parent:GetTop()) or 0
    local parentWidth = (parent and parent.GetWidth and parent:GetWidth()) or 1920
    local parentHeight = (parent and parent.GetHeight and parent:GetHeight()) or 1080
    local scale = (self.statisticsWindow and self.statisticsWindow.GetScale and self.statisticsWindow:GetScale()) or 1
    local width = ((self.statisticsWindow and self.statisticsWindow:GetWidth()) or 1000) * scale
    local height = ((self.statisticsWindow and self.statisticsWindow:GetHeight()) or 750) * scale
    local margin = 8
    local maxX = math.max(margin, parentWidth - width - margin)
    local maxY = math.max(margin, parentHeight - height - margin)
    return parentLeft, parentTop, margin, margin, maxX, maxY
end

function TPM:ClampStatisticsScreenPosition(x, y)
    local _, _, minX, minY, maxX, maxY = self:GetStatisticsViewportBounds()
    return Clamp(tonumber(x) or minX, minX, maxX), Clamp(tonumber(y) or minY, minY, maxY)
end

function TPM:ClampStatisticsWindowToScreen()
    local control = self.statisticsWindow
    if not control or not GuiRoot then return end
    local left, top = control:GetLeft(), control:GetTop()
    if not left or not top then return end
    local rootLeft, rootTop = GuiRoot:GetLeft() or 0, GuiRoot:GetTop() or 0
    local x, y = self:ClampStatisticsScreenPosition(left - rootLeft, top - rootTop)
    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    if self.saved then
        self.saved.statisticsWindowX = Round(x)
        self.saved.statisticsWindowY = Round(y)
    end
end

function TPM:ResetStatisticsWindowPosition()
    if self.saved then
        self.saved.statisticsWindowX = false
        self.saved.statisticsWindowY = false
    end
    local control = self.statisticsWindow
    if not control then return end
    control:ClearAnchors()
    control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    self:ClampStatisticsWindowToScreen()
end

function TPM:SaveStatisticsWindowPosition()
    self:ClampStatisticsWindowToScreen()
end

function TPM:StopMovingStatisticsWindow()
    if not self.statisticsWindowMoving then return end
    self.statisticsWindowMoving = false
    if self.statisticsWindow then
        self.statisticsWindow:StopMovingOrResizing()
    end
    self:SaveStatisticsWindowPosition()
end

function TPM:GetStatisticsMaxScrollOffset()
    local total = self.statisticsData and #(self.statisticsData.zones or {}) or 0
    return math.max(0, total - STATISTICS_VISIBLE_ZONE_ROWS)
end

function TPM:RefreshStatisticsZoneRows()
    if self.saved and self.saved.statisticsPage ~= "progress" then return end
    local stats = self.statisticsData
    if not stats then return end
    local maxOffset = self:GetStatisticsMaxScrollOffset()
    local offset = Clamp(Round(self.statisticsScrollOffset or 0), 0, maxOffset)
    self.statisticsScrollOffset = offset

    for slot = 1, STATISTICS_VISIBLE_ZONE_ROWS do
        local row = self.statisticsZoneRows and self.statisticsZoneRows[slot]
        local data = stats.zones[offset + slot]
        if row then
            row:SetHidden(data == nil)
            if data then
                row.zoneId = data.zoneId
                row.mapId = data.mapId
                row.nameLabel:SetText(data.name)
                local isComplete = data.percent >= 100
                if row.completeIcon then row.completeIcon:SetHidden(not isComplete) end
                row.nameLabel:ClearAnchors()
                row.nameLabel:SetAnchor(LEFT, row, LEFT, isComplete and 32 or 10, 0)

                if isComplete then
                    row.baseR, row.baseG, row.baseB, row.baseAlpha = 0.10, 0.095, 0.018, 0.72
                    row.bg:SetCenterColor(row.baseR, row.baseG, row.baseB, row.baseAlpha)
                    row.bg:SetEdgeColor(0.68, 0.62, 0.06, 0.78)
                    row.nameLabel:SetColor(0.88, 0.93, 0.20, 1)
                else
                    row.baseR, row.baseG, row.baseB = 0.035, 0.031, 0.024
                    row.baseAlpha = slot % 2 == 0 and 0.58 or 0.34
                    row.bg:SetCenterColor(row.baseR, row.baseG, row.baseB, row.baseAlpha)
                    row.bg:SetEdgeColor(0.30, 0.25, 0.14, 0.22)
                    row.nameLabel:SetColor(0.94, 0.92, 0.86, 1)
                end

                local percentColor = self:GetStatisticsPercentTextColor(data.percent)
                row.percentLabel:SetText(string.format("|c%s%d%%|r", percentColor, data.percent))
                row.doneLabel:SetText(string.format("%d / %d", data.completed, data.total))
                row.openLabel:SetText(tostring(data.remaining))
                if data.remaining <= 0 then
                    row.openLabel:SetColor(0.62, 0.86, 0.24, 1)
                elseif data.remaining <= 10 then
                    row.openLabel:SetColor(0.98, 0.82, 0.28, 1)
                else
                    row.openLabel:SetColor(0.95, 0.70, 0.20, 1)
                end
                self:SetStatisticsBarPercent(row.progressFill, 170, data.percent)
            else
                row.zoneId = nil
                row.mapId = nil
            end
        end
    end
end

function TPM:ScrollStatistics(delta)
    if self.saved and self.saved.statisticsPage ~= "progress" then return end
    local maxOffset = self:GetStatisticsMaxScrollOffset()
    local current = Clamp(Round(self.statisticsScrollOffset or 0), 0, maxOffset)
    -- ESO sends positive delta when scrolling up.
    local nextValue = Clamp(current - (tonumber(delta) or 0), 0, maxOffset)
    self.statisticsScrollOffset = nextValue
    if self.statisticsScrollBar then
        self.statisticsScrollBar:SetValue(nextValue)
    end
    self:RefreshStatisticsZoneRows()
end

function TPM:RefreshStatisticsPlayerProgress()
    if not self.statisticsWindow or self.statisticsWindow:IsHidden() then return end
    -- Player progression is shown only on the dedicated Player page.
    -- The Progress page intentionally contains world-completion data only.
    if self.saved and self.saved.statisticsPage == "player" then
        self:RefreshPlayerStatisticsPage()
    end
end

function TPM:RefreshStatisticsLanguageBar()
    local active = self.langCode
    for _, btn in ipairs(self.statisticsLanguageButtons or {}) do
        if btn.langCode == active then btn:SetColor(1.00, 0.84, 0.20, 1)
        else btn:SetColor(0.72, 0.69, 0.62, 1) end
    end
end

function TPM:RefreshStatisticsWindow()
    if self.statisticsHint then self.statisticsHint:SetHidden(true) end
    -- Keep the large journal lazy. ShowStatisticsWindow/ToggleStatisticsWindow
    -- create it on demand; routine map refreshes should not allocate it.
    local control = self.statisticsWindow
    if not control or control:IsHidden() then return end

    local page = self.saved and self.saved.statisticsPage or "progress"
    if not self:IsValidStatisticsPage(page) then
        page = "progress"
        if self.saved then self.saved.statisticsPage = page end
    end
    self:UpdateStatisticsPageVisibility(page)
    self:RefreshStatisticsPageTabs()

    if page == "economy" then
        self.statisticsTitle:SetText(self:L("STAT_ECONOMY_PAGE_TITLE"))
        self.statisticsMode:SetText(self:L("STAT_ECONOMY_PAGE_MODE"))
        self:RefreshEconomyStatisticsPage()
        return
    elseif page == "history" then
        self.statisticsTitle:SetText(self:L("HISTORY_PAGE_TITLE"))
        local historyStore = self:GetHistoryStore()
        local historyName = historyStore and historyStore.characterName or self:L("STAT_PLAYER_UNKNOWN")
        self.statisticsMode:SetText(self:L("HISTORY_PAGE_MODE_CHARACTER", historyName))
        self:RefreshHistoryStatisticsPage()
        return
    elseif page == "alliance" then
        self.statisticsTitle:SetText(self:L("STAT_ALLIANCE_PAGE_TITLE"))
        self.statisticsMode:SetText(self:L("STAT_ALLIANCE_ALPHA_TEST"))
        self:RefreshAllianceStatisticsPage()
        return
    end

    self:SetProgressStatisticsControlsHidden(false)
    local focusZoneId = self:GetStatisticsFocusZoneId()
    local stats = self:GetStatisticsData(false, focusZoneId)
    self.statisticsData = stats

    self.statisticsTitle:SetText(string.format("%s-v2.6.72-Beta", self:L("STATISTICS_TITLE")))
    self.statisticsMode:SetText(self:L("STAT_MODE", self.saved.calculationMode == "categories" and self:L("MODE_CATEGORIES") or self:L("MODE_OBJECTIVES")))
    if self.statisticsFocusLabel then self.statisticsFocusLabel:SetText(self:L("STAT_FOCUS_LABEL")) end
    self:RefreshStatisticsFocusSelector()
    if focusZoneId > 0 then
        local focusName = stats.focusName or SafeZoneName(focusZoneId)
        self.statisticsTamrielLabel:SetText(focusName)
        self.statisticsSubtitle:SetText(self:L("STATISTICS_SUBTITLE_ZONE", focusName))
    else
        self.statisticsTamrielLabel:SetText(self:L("TAMRIEL_TOTAL"))
        self.statisticsSubtitle:SetText(self:L("STATISTICS_SUBTITLE"))
    end

    local color = self:GetStatisticsPercentTextColor(stats.percent)
    self.statisticsOverall:SetText(string.format("|c%s%d%%|r", color, stats.percent))
    self:SetStatisticsBarPercent(self.statisticsOverallFill, 758, stats.percent)
    if self.statisticsOverallBarPercent then
        self.statisticsOverallBarPercent:SetText(string.format("%d%%", stats.percent))
    end

    local cards = self.statisticsCards or {}
    if cards[1] then
        cards[1].title:SetText(self:L("STAT_COMPLETE_ZONES"))
        cards[1].value:SetText(self:L("STAT_OF_ZONES", stats.completedZones, stats.totalZones))
    end
    if cards[2] then
        cards[2].title:SetText(self:L("STAT_OBJECTIVES"))
        cards[2].value:SetText(self:L("STAT_OF_OBJECTIVES", stats.completedObjectives, stats.totalObjectives))
    end
    if cards[3] then
        cards[3].title:SetText(self:L("STAT_REMAINING"))
        cards[3].value:SetText(tostring(stats.remainingObjectives))
    end
    if cards[4] then
        cards[4].title:SetText(self:L("STAT_UNTOUCHED"))
        cards[4].value:SetText(tostring(stats.untouchedZones))
    end
    if self.statisticsPlaytimeCard then
        -- Keep this live without bringing the old Development playtime page back.
        self:CheckpointHistory("progress_view", false)
        local totalPlayed = self:SyncCurrentEsoPlayedTime()
        local todayPlayed = self:GetTodayPlaySeconds()
        self.statisticsPlaytimeCard.title:SetText(self:L("STAT_CHARACTER_PLAY_TIME"))
        self.statisticsPlaytimeCard.value:SetText(TPM_FormatDuration(totalPlayed or 0))
        self.statisticsPlaytimeCard.detail:SetText(self:L("STAT_CHARACTER_PLAY_TIME_TODAY", TPM_FormatDuration(todayPlayed or 0)))
    end

    self:RefreshStatisticsPlayerProgress()

    self.statisticsCategoryTitle:SetText(self:L("STAT_CATEGORIES"))
    self:RefreshStatisticsCategorySortControls()
    local displayedCategories = self:SortStatisticsCategoryData(stats.categories, false)
    for index, categoryControl in ipairs(self.statisticsCategoryRows or {}) do
        local data = displayedCategories[index]
        categoryControl.control:SetHidden(data == nil)
        if data then
            categoryControl.label:SetText(data.name)
            categoryControl.count:SetText(data.countText or string.format("%d/%d", data.completed, data.total))
            if data.informational then
                categoryControl.percent:SetText("—")
                self:SetStatisticsBarPercent(categoryControl.fill, 96, 0)
                categoryControl.fill:SetHidden(true)
            else
                categoryControl.percent:SetText(string.format("|c%s%d%%|r", self:GetStatisticsPercentTextColor(data.percent), data.percent))
                categoryControl.fill:SetHidden(false)
                self:SetStatisticsBarPercent(categoryControl.fill, 96, data.percent)
            end
            if categoryControl.icon then
                local iconTexture = STATISTICS_CATEGORY_ICON_TEXTURES[data.completionType] or "TamrielProgressMap/art/cat_quests.dds"
                categoryControl.icon:SetTexture(iconTexture)
                local ir, ig, ib = self:GetStatisticsProgressColor(data.percent)
                categoryControl.icon:SetColor(ir, ig, ib, 0.96)
            end
            local hudRowActive = self:IsProgressGoalCategoryActive(data.completionType)
            if categoryControl.gearButton then
                categoryControl.gearButton:SetHidden(true)
                categoryControl.gearButton:SetHandler("OnMouseEnter", nil)
                categoryControl.gearButton:SetHandler("OnMouseExit", nil)
                categoryControl.gearButton:SetHandler("OnClicked", nil)
                categoryControl.gearButton:SetHandler("OnMouseUp", nil)
            end
            categoryControl.label:SetColor(hudRowActive and 1.00 or 0.92, hudRowActive and 1.00 or 0.89, hudRowActive and 1.00 or 0.81, 1)
            categoryControl.bg:SetEdgeColor(hudRowActive and 0.82 or 0.28, hudRowActive and 0.74 or 0.23, hudRowActive and 0.48 or 0.12, hudRowActive and 0.70 or 0.20)

            local tooltipName = data.name
            local tooltipText = data.tooltipText or ""
            categoryControl.control:SetMouseEnabled(true)
            categoryControl.control:SetHandler("OnMouseEnter", function()
                TPM:ShowStatisticsHoverTooltip(tooltipName, tooltipText, categoryControl.control)
            end)
            categoryControl.control:SetHandler("OnMouseExit", function() TPM:HideStatisticsHoverTooltips() end)
            categoryControl.control:SetHandler("OnMouseUp", function(_, button, upInside)
                if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
                    TPM:HideStatisticsHoverTooltips()
                    TPM:ToggleSkyshardGoalWidget(data.completionType)
                end
            end)
        end
    end

    -- Apply page 1/2/3 visibility only after the unchanged completion rows have
    -- refreshed, so switching pages cannot alter their data or Tamriel %.
    self:RefreshStatisticsCollectionPager()

    if self.statisticsCategoryGearButton then
        local activeType = self:GetActiveProgressGoalCategoryType()
        local showGear = (tonumber(self.saved.statisticsCompletionPage) or 1) == 1 and activeType ~= nil
        local editing = self.skyshardGoalEditMode == true
        self.statisticsCategoryGearButton:SetHidden(not showGear)
        self.statisticsCategoryGearButton:SetMouseEnabled(showGear)
        if self.statisticsCategoryGearIcon then
            self.statisticsCategoryGearIcon:SetColor(showGear and (editing and 1.00 or 0.88) or 0.55, showGear and (editing and 0.82 or 0.82) or 0.52, showGear and (editing and 0.24 or 0.64) or 0.46, showGear and (editing and 1.00 or 0.92) or 0.80)
        end
        self.statisticsCategoryGearButton:SetHandler("OnMouseEnter", showGear and function(button)
            if button.TPMIcon then button.TPMIcon:SetColor(1.00, 0.86, 0.30, 1) end
            local completionType = TPM:GetActiveProgressGoalCategoryType()
            local title = TPM:L("STAT_GOAL_HUD_GEAR_TITLE", TPM:GetProgressGoalCategoryDisplayName(completionType))
            local body = TPM:L("STAT_GOAL_HUD_GEAR_TT")
            TPM:ShowStatisticsHoverTooltip(title, body, button)
        end or nil)
        self.statisticsCategoryGearButton:SetHandler("OnMouseExit", showGear and function(button)
            local activeEditor = TPM.skyshardGoalEditMode == true
            if button.TPMIcon then
                button.TPMIcon:SetColor(activeEditor and 1.00 or 0.88, activeEditor and 0.82 or 0.82, activeEditor and 0.24 or 0.64, activeEditor and 1.00 or 0.92)
            end
            TPM:HideStatisticsHoverTooltips()
        end or nil)
        self.statisticsCategoryGearButton:SetHandler("OnClicked", showGear and function()
            TPM:HideStatisticsHoverTooltips()
            TPM:ToggleSkyshardGoalEditMode()
        end or nil)
        self.statisticsCategoryGearButton:SetHandler("OnMouseUp", showGear and function(_, button, upInside)
            if upInside and button == MOUSE_BUTTON_INDEX_RIGHT then
                TPM:ResetSkyshardGoalCustomPosition()
            end
        end or nil)
    end

    self.statisticsZoneTitle:SetText(self:L("STAT_ZONE_PROGRESS", stats.totalZones))
    self.statisticsHeaderZone:SetText(self:L("STAT_ZONE"))
    self.statisticsHeaderProgress:SetText(self:L("STAT_PROGRESS"))
    self.statisticsHeaderDone:SetText(self:L("STAT_DONE"))
    self.statisticsHeaderOpen:SetText(self:L("STAT_OPEN"))

    if self.statisticsSortProgress then self.statisticsSortProgress:SetHidden(true) end
    if self.statisticsSortName then
        self.statisticsSortName:SetHidden(false)
        self.statisticsSortName:SetMouseEnabled(false)
        self.statisticsSortName:SetText(self:L("STAT_SORT_ALPHABETICAL"))
    end

    local maxOffset = self:GetStatisticsMaxScrollOffset()
    self.statisticsScrollOffset = Clamp(Round(self.statisticsScrollOffset or 0), 0, maxOffset)
    if self.statisticsScrollBar then
        self.statisticsScrollBar:SetMinMax(0, maxOffset)
        self.statisticsScrollBar:SetValueStep(1)
        self.statisticsScrollBar:SetValue(self.statisticsScrollOffset)
        self.statisticsScrollBar:SetHidden(maxOffset <= 0)
    end
    self:RefreshStatisticsZoneRows()
end
function TPM:OpenWorldMapFromStatistics(mapId)
    mapId = tonumber(mapId) or 0
    if mapId <= 0 then return false end

    -- Clicking a zone is the one place where the standalone journal should
    -- deliberately transition into ESO's map. Close the journal first, show
    -- the correct keyboard/gamepad map scene, then select the requested map
    -- after ESO has initialized the scene.
    self.statisticsOpenedStandalone = false
    self:HideStatisticsWindow()

    local function SelectMap()
        if TPM and WORLD_MAP_MANAGER and WORLD_MAP_MANAGER.SetMapById then
            WORLD_MAP_MANAGER:SetMapById(mapId)
            TPM:QueueRefresh(30)
        end
    end

    if self:IsFullWorldMapSceneVisible() then
        SelectMap()
        return true
    end

    if SCENE_MANAGER and SCENE_MANAGER.Show then
        local sceneName = "worldMap"
        if type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode() then
            sceneName = "gamepad_worldMap"
        end
        SCENE_MANAGER:Show(sceneName)
        if type(zo_callLater) == "function" then
            zo_callLater(SelectMap, 120)
        else
            SelectMap()
        end
        return true
    end
    return false
end

-- 2.6.34: Standalone Statistics owns UI mouse mode only while opened by TPM.
function TPM:SetStandaloneStatisticsUIMode(enabled)
    enabled = enabled == true
    if type(_G.SetGameCameraUIMode) ~= "function" then return end

    if enabled then
        local alreadyInUiMode = false
        if type(_G.IsGameCameraUIModeActive) == "function" then
            local ok, value = pcall(_G.IsGameCameraUIModeActive)
            if ok then alreadyInUiMode = value == true end
        end

        self.statisticsUIModeWasAlreadyActive = alreadyInUiMode

        -- Always request UI mode. A remapped key can share behavior with a
        -- gameplay key and ESO may finish processing that key after the binding
        -- callback, so one immediate request is not always enough.
        local ok = pcall(_G.SetGameCameraUIMode, true)
        self.statisticsOwnsUIMode = ok and not alreadyInUiMode
        self.statisticsUIModeOpenedAt =
            type(_G.GetFrameTimeMilliseconds) == "function"
            and (_G.GetFrameTimeMilliseconds() or 0) or 0

        -- Re-assert on the next UI ticks. This makes custom bindings such as
        -- 9 behave exactly like the original NumPad5 standalone opener.
        if type(zo_callLater) == "function" then
            zo_callLater(function()
                if TPM and TPM.statisticsOpenedStandalone
                    and TPM.statisticsWindow and not TPM.statisticsWindow:IsHidden() then
                    pcall(_G.SetGameCameraUIMode, true)
                end
            end, 0)
            zo_callLater(function()
                if TPM and TPM.statisticsOpenedStandalone
                    and TPM.statisticsWindow and not TPM.statisticsWindow:IsHidden() then
                    pcall(_G.SetGameCameraUIMode, true)
                    TPM.statisticsUIModeOpenedAt =
                        type(_G.GetFrameTimeMilliseconds) == "function"
                        and (_G.GetFrameTimeMilliseconds() or 0) or TPM.statisticsUIModeOpenedAt
                end
            end, 80)
        end
    else
        if self.statisticsOwnsUIMode then
            pcall(_G.SetGameCameraUIMode, false)
        end
        self.statisticsOwnsUIMode = false
        self.statisticsUIModeWasAlreadyActive = false
        self.statisticsUIModeOpenedAt = 0
    end
end

function TPM:ShowStatisticsWindow(openStandalone)
    self:CreateStatisticsWindow()
    if not self.statisticsWindow then return false end
    if openStandalone == nil then
        openStandalone = not self:IsFullWorldMapSceneVisible()
    end
    self.statisticsOpenedStandalone = openStandalone == true
    self.statisticsTemporarilyHiddenForScene = false
    self.statisticsWindow:SetHidden(false)
    if self.statisticsOpenedStandalone then
        self:SetStandaloneStatisticsUIMode(true)
    end
    self:ClampStatisticsWindowToScreen()
    self:HideQuestRewards()
    if self.skyshardGoalWidget then self.skyshardGoalWidget:SetHidden(true) end
    -- Always take a fresh snapshot when the journal is opened. While it stays
    -- open, completion events invalidate the cache as needed.
    self:InvalidateStatisticsData(false)
    self:RefreshStatisticsWindow()
    self:RefreshQuickFilterBar()
    self:QueueRefresh(20)
    if self.statisticsOpenedStandalone then
        self:RefreshStandaloneStatisticsSceneVisibility()
    end
    return true
end

function TPM:HideStatisticsWindow()
    self:HideEconomyFocusDropdown()
    self:HideStatisticsHoverTooltips()
    self:HideStatisticsFocusDropdown()
    TPM_HideAchievementTooltip()
    -- Keep the Skyshard HUD editor alive when the world map closes. The gear
    -- button is the explicit editor toggle: moving/resizing stays active until
    -- the user clicks the gear again to save.
    if self.statisticsWindowMoving then
        self:StopMovingStatisticsWindow()
    end
    if self.statisticsWindow then
        self.statisticsWindow:SetHidden(true)
    end
    if self.economyDetailWindow then
        self.economyDetailWindow:SetHidden(true)
    end
    self.economyDetailTemporarilyHiddenForScene = false
    self:SetStandaloneStatisticsUIMode(false)
    self.statisticsOpenedStandalone = false
    self.statisticsTemporarilyHiddenForScene = false
    self:RefreshQuickFilterBar()
    if type(zo_callLater) == "function" then
        zo_callLater(function() if TPM then TPM:RefreshSkyshardGoalWidget() end end, 30)
    end
    if self:IsWorldMapVisible() then
        self:RefreshQuestRewards()
        self:QueueRefresh(20)
    end
end
function TPM:ToggleStatisticsWindow(openStandalone)
    self:CreateStatisticsWindow()
    if not self.statisticsWindow then return end
    -- A standalone journal may be temporarily hidden while an ESO fullscreen
    -- menu is active. Treat it as logically open so pressing the key again
    -- actually closes it instead of reopening a hidden copy.
    if self.statisticsOpenedStandalone and self.statisticsTemporarilyHiddenForScene then
        self:HideStatisticsWindow()
    elseif self.statisticsWindow:IsHidden() then
        self:ShowStatisticsWindow(openStandalone)
    else
        self:HideStatisticsWindow()
    end
end

function TPM:ToggleStatisticsFromKeybind()
    -- Keybind/slash openings are always standalone. Handle the open path
    -- explicitly so every remapped binding acquires mouse/UI mode reliably.
    self:CreateStatisticsWindow()
    if not self.statisticsWindow then return end

    if self.statisticsOpenedStandalone and self.statisticsTemporarilyHiddenForScene then
        self:HideStatisticsWindow()
        return
    end

    if self.statisticsWindow:IsHidden() then
        self:ShowStatisticsWindow(true)
        -- ShowStatisticsWindow already requests UI mode; explicitly request it
        -- again here so a custom Controls binding cannot leave the journal open
        -- in gameplay-camera mode with no mouse cursor.
        self:SetStandaloneStatisticsUIMode(true)
    else
        self:HideStatisticsWindow()
    end
end

function TamrielProgressMap_KeybindToggleStatistics()
    if TPM then TPM:ToggleStatisticsFromKeybind() end
end

function TPM:GetQuestBestRewardDisplayQuality(questIndex)
    if not questIndex or not IsValidQuestIndex(questIndex) then return nil end
    if type(GetJournalQuestNumRewards) ~= "function" or type(GetJournalQuestRewardInfo) ~= "function" then return nil end
    local bestQuality = nil
    local numRewards = GetJournalQuestNumRewards(questIndex) or 0
    for rewardIndex = 1, numRewards do
        local rewardType, _, _, _, _, itemDisplayQuality = GetJournalQuestRewardInfo(questIndex, rewardIndex)
        local currencyType = nil
        if type(GetCurrencyTypeFromRewardType) == "function" then
            local ok, value = pcall(GetCurrencyTypeFromRewardType, rewardType)
            if ok then currencyType = value end
            if CURT_NONE and currencyType == CURT_NONE then currencyType = nil end
        end
        local itemId = 0
        if type(GetJournalQuestRewardItemId) == "function" then
            local ok, value = pcall(GetJournalQuestRewardItemId, questIndex, rewardIndex)
            if ok then itemId = tonumber(value) or 0 end
        end
        -- Only actual item rewards determine the quest color. Gold, XP,
        -- currencies, skill points and other non-item rewards therefore remain
        -- white exactly as the feature promises.
        if (not currencyType or currencyType == 0) and itemId > 0 then
            local quality = tonumber(itemDisplayQuality)
            if quality and quality >= 0 then
                if bestQuality == nil or quality > bestQuality then bestQuality = quality end
            end
        end
    end
    return bestQuality
end

function TPM:GetQuestRewardColorDef(questIndex)
    if not self.saved or self.saved.colorVanillaQuestsByReward == false then return nil end
    local quality = self:GetQuestBestRewardDisplayQuality(questIndex)
    if quality ~= nil and type(GetItemQualityColor) == "function" then
        local ok, color = pcall(GetItemQualityColor, quality)
        if ok and color then return color end
    end
    -- Currency-only/no-item quests stay white as requested instead of inheriting
    -- ESO's level/con difficulty color.
    if ZO_ColorDef then
        self.questRewardWhiteColor = self.questRewardWhiteColor or ZO_ColorDef:New(1, 1, 1, 1)
        return self.questRewardWhiteColor
    end
    return nil
end

function TPM:ApplyWorldMapQuestRewardColor(control, data)
    if not control or not data then return end
    local nameControl = GetControl(control, "Name")
    if not nameControl then return end
    local color = self:GetQuestRewardColorDef(data.questIndex)
    if color and type(ZO_SelectableLabel_SetNormalColor) == "function" then
        ZO_SelectableLabel_SetNormalColor(nameControl, color)
    end
end
function TPM:ApplyFocusedQuestRewardColor(questHeader)
    if not questHeader or not questHeader.m_Data then return end
    local questIndex = nil
    if questHeader.m_Data.GetJournalIndex then
        questIndex = questHeader.m_Data:GetJournalIndex()
    else
        questIndex = questHeader.m_Data.arg1
    end
    if not questIndex then return end
    if self.saved and self.saved.colorVanillaQuestsByReward ~= false then
        local color = self:GetQuestRewardColorDef(questIndex)
        if color and color.UnpackRGBA then questHeader:SetColor(color:UnpackRGBA()) end
    else
        questHeader:SetColor(GetConColor(questHeader.m_Data.level))
    end
end
function TPM:RefreshVanillaQuestRewardColors()
    if WORLD_MAP_QUESTS and WORLD_MAP_QUESTS.RefreshHeaders then
        WORLD_MAP_QUESTS:RefreshHeaders()
    end
    if FOCUSED_QUEST_TRACKER and FOCUSED_QUEST_TRACKER.headerPool then
        for _, header in pairs(FOCUSED_QUEST_TRACKER.headerPool:GetActiveObjects() or {}) do
            self:ApplyFocusedQuestRewardColor(header)
        end
    end
end
function TPM:RegisterVanillaQuestRewardColorHooks()
    if self.questRewardColorHooksRegistered or type(ZO_PostHook) ~= "function" then return end

    if not self.questRewardWorldMapHooked and WORLD_MAP_QUESTS and WORLD_MAP_QUESTS.SetupQuestHeader then
        ZO_PostHook(WORLD_MAP_QUESTS, "SetupQuestHeader", function(_, control, data)
            TPM:ApplyWorldMapQuestRewardColor(control, data)
        end)
        self.questRewardWorldMapHooked = true
    end

    if not self.questRewardFocusedHooked and ZO_Tracker and ZO_Tracker.InitializeQuestHeader then
        ZO_PostHook(ZO_Tracker, "InitializeQuestHeader", function(_, _, _, questHeader)
            TPM:ApplyFocusedQuestRewardColor(questHeader)
        end)
        if ZO_Tracker.RefreshHeaderConColors then
            ZO_PostHook(ZO_Tracker, "RefreshHeaderConColors", function(tracker)
                if tracker and tracker.headerPool then
                    for _, header in pairs(tracker.headerPool:GetActiveObjects() or {}) do
                        TPM:ApplyFocusedQuestRewardColor(header)
                    end
                end
            end)
        end
        self.questRewardFocusedHooked = true
    end

    self.questRewardColorHooksRegistered = self.questRewardWorldMapHooked and self.questRewardFocusedHooked
    if self.questRewardWorldMapHooked or self.questRewardFocusedHooked then
        self:RefreshVanillaQuestRewardColors()
    end
    if not self.questRewardColorHooksRegistered and type(zo_callLater) == "function" then
        zo_callLater(function() if TPM then TPM:RegisterVanillaQuestRewardColorHooks() end end, 1000)
    end
end

function TPM:SetQuickFilter(value)
    if value ~= "all" and value ~= "incomplete" and value ~= "under50" and value ~= "complete" then
        return false
    end
    self.saved.quickFilter = value
    self:RefreshQuickFilterBar()
    self:QueueRefresh(10)
    return true
end

function TPM:CreateQuickFilterBar()
    if self.quickFilterBar then return end
    if not ZO_WorldMap or not ZO_WorldMapScroll then return end

    local bar = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "QuickFilterBar", ZO_WorldMap, CT_CONTROL)
    bar:SetDimensions(506, 38)
    bar:SetAnchor(TOPLEFT, ZO_WorldMapScroll, TOPLEFT, 10, 10)
    bar:SetDrawLayer(DL_OVERLAY)
    bar:SetDrawTier(DT_HIGH)
    if bar.SetDrawLevel then bar:SetDrawLevel(4500) end
    bar:SetMouseEnabled(false)
    bar:SetHidden(true)
    self.quickFilterBar = bar

    local bg = WINDOW_MANAGER:CreateControl(nil, bar, CT_BACKDROP)
    bg:SetAnchorFill(bar)
    bg:SetCenterColor(0.03, 0.025, 0.02, 0.72)
    bg:SetEdgeColor(0.55, 0.46, 0.28, 0.75)
    bg:SetEdgeTexture(nil, 1, 1, 1)
    bg:SetMouseEnabled(false)

    local definitions =
    {
        { key = "all", labelKey = "FILTER_ALL" },
        { key = "incomplete", labelKey = "FILTER_INCOMPLETE" },
        { key = "under50", labelKey = "FILTER_UNDER_50" },
        { key = "complete", labelKey = "FILTER_COMPLETE" },
    }

    bar.buttons = {}
    for index, data in ipairs(definitions) do
        local button = WINDOW_MANAGER:CreateControlFromVirtual(nil, bar, "ZO_DefaultButton")
        button:SetDimensions(92, 28)
        button:SetAnchor(LEFT, bar, LEFT, 5 + ((index - 1) * 96), 0)
        button.filterKey = data.key
        button.filterLabelKey = data.labelKey
        button:SetHandler("OnClicked", function(btn)
            TPM:SetQuickFilter(btn.filterKey)
        end)
        bar.buttons[#bar.buttons + 1] = button
    end

    local statsButton = WINDOW_MANAGER:CreateControlFromVirtual(nil, bar, "ZO_DefaultButton")
    statsButton:SetDimensions(112, 28)
    statsButton:SetAnchor(LEFT, bar, LEFT, 389, 0)
    statsButton:SetHandler("OnClicked", function()
        TPM:ToggleStatisticsWindow()
    end)
    bar.statisticsButton = statsButton
end

function TPM:RefreshQuickFilterBar()
    self:CreateQuickFilterBar()
    local bar = self.quickFilterBar
    if not bar then return end

    local visible = self.saved
        and self.saved.enabled
        and self.saved.showQuickFilters
        and self:IsFullWorldMapSceneVisible()
    bar:SetHidden(not visible)
    if not visible then return end

    local current = self.saved.quickFilter or "all"
    for _, button in ipairs(bar.buttons or {}) do
        local text = self:L(button.filterLabelKey)
        if button.filterKey == current then
            text = "|cE6C45C" .. text .. "|r"
        end
        button:SetText(text)
    end

    if bar.statisticsButton then
        local text = self:L("STATISTICS_BUTTON")
        if self.statisticsWindow and not self.statisticsWindow:IsHidden() then
            text = "|cE6C45C" .. text .. "|r"
        end
        bar.statisticsButton:SetText(text)
    end
end

function TPM:CreateHeaderProgressLabel()
    if self.headerLabel then return end
    if not ZO_WorldMap or not ZO_WorldMapScroll then return end

    -- Keep header UI fixed to the map viewport. ZO_WorldMapContainer itself is
    -- the zoomable/pannable map content.
    local label = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "HeaderProgress", ZO_WorldMap, CT_LABEL)
    local headerFontSize = self:GetProgressFontSize("header")
    label:SetDimensions(math.max(220, headerFontSize * 5), math.max(54, headerFontSize + 12))
    self:ApplyProgressFont(label, "header")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawTier(DT_HIGH)
    label:SetMouseEnabled(false)
    label:SetAnchor(TOP, ZO_WorldMapScroll, TOP, 0, 34)
    label:SetHidden(true)
    self.headerLabel = label

    local categoryLabel = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "HeaderCategories", ZO_WorldMap, CT_LABEL)
    categoryLabel:SetDimensions(650, 88)
    categoryLabel:SetFont("ZoFontGameSmall")
    categoryLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    categoryLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    categoryLabel:SetDrawLayer(DL_OVERLAY)
    categoryLabel:SetDrawTier(DT_HIGH)
    categoryLabel:SetMouseEnabled(false)
    categoryLabel:SetAnchor(TOP, label, BOTTOM, 0, 2)
    categoryLabel:SetHidden(true)
    self.headerCategoryLabel = categoryLabel
end

function TPM:ApplyHeaderProgressAnchor()
    if not self.headerLabel or not ZO_WorldMapScroll then return end

    local gamepadMap = self.gamepadWorldMapSceneVisible == true
    if not gamepadMap and GAMEPAD_WORLD_MAP_SCENE and GAMEPAD_WORLD_MAP_SCENE.IsShowing then
        gamepadMap = GAMEPAD_WORLD_MAP_SCENE:IsShowing()
    end

    self.headerLabel:ClearAnchors()
    if gamepadMap then
        self.headerLabel:SetAnchor(TOPRIGHT, ZO_WorldMapScroll, TOPRIGHT, -120, 76)
        self.headerLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    else
        self.headerLabel:SetAnchor(TOP, ZO_WorldMapScroll, TOP, 0, 34)
        self.headerLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    end

    if self.headerCategoryLabel then
        self.headerCategoryLabel:ClearAnchors()
        self.headerCategoryLabel:SetAnchor(TOP, self.headerLabel, BOTTOM, 0, 2)
    end
end

function TPM:HideHeaderProgress()
    if self.headerLabel then
        self.headerLabel:SetHidden(true)
        self.headerLabel.zoneId = nil
        self.headerLabel.progressZoneId = nil
        self.headerLabel.percent = nil
    end
    if self.headerCategoryLabel then
        self.headerCategoryLabel:SetHidden(true)
        self.headerCategoryLabel:SetText("")
    end
end

function TPM:RefreshHeaderProgress()
    self:CreateHeaderProgressLabel()
    if not self.headerLabel then return end

    local headerFontSize = self:GetProgressFontSize("header")
    self.headerLabel:SetDimensions(math.max(220, headerFontSize * 5), math.max(54, headerFontSize + 12))
    self:ApplyProgressFont(self.headerLabel, "header")
    self:ApplyHeaderProgressAnchor()

    if not self.saved or not self.saved.enabled or not self.saved.showHeader or not self:IsWorldMapVisible() then
        self:HideHeaderProgress()
        return
    end

    local mapType = GetMapType()

    if mapType == MAPTYPE_WORLD or mapType == MAPTYPE_COSMIC then
        local percent, completedTotal, availableTotal, zoneCount = self:GetTamrielProgress()
        if availableTotal <= 0 and zoneCount <= 0 then
            self:HideHeaderProgress()
            return
        end

        local color = self:GetDisplayPercentColor(percent)
        self.headerLabel:SetText(string.format("|c%s%d%%|r", color, percent))
        self.headerLabel.zoneId = nil
        self.headerLabel.progressZoneId = nil
        self.headerLabel.completedTotal = completedTotal
        self.headerLabel.availableTotal = availableTotal
        self.headerLabel.percent = percent
        self.headerLabel:SetHidden(false)
        if self.headerCategoryLabel then
            self.headerCategoryLabel:SetHidden(true)
            self.headerCategoryLabel:SetText("")
        end
        return
    end

    if mapType ~= MAPTYPE_ZONE then
        self:HideHeaderProgress()
        return
    end

    local zoneIndex = GetCurrentMapZoneIndex()
    if not zoneIndex or zoneIndex <= 0 then
        self:HideHeaderProgress()
        return
    end

    local zoneId = GetZoneId(zoneIndex)
    if not zoneId or zoneId <= 0 then
        self:HideHeaderProgress()
        return
    end

    local breakdown, completedTotal, availableTotal, percent, progressZoneId = self:GetResolvedCompletion(zoneId)
    if availableTotal <= 0 then
        self:HideHeaderProgress()
        return
    end

    local color = self:GetDisplayPercentColor(percent)
    self.headerLabel:SetText(string.format("|c%s%d%%|r", color, percent))
    self.headerLabel.zoneId = zoneId
    self.headerLabel.progressZoneId = progressZoneId
    self.headerLabel.completedTotal = completedTotal
    self.headerLabel.availableTotal = availableTotal
    self.headerLabel.percent = percent
    self.headerLabel:SetHidden(false)

    if self.headerCategoryLabel then
        self.headerCategoryLabel:SetHidden(true)
        self.headerCategoryLabel:SetText("")
    end
end

function TPM:Refresh()
    self.refreshQueued = false

    -- Most TPM rendering belongs exclusively to the world map. The Statistics
    -- journal is the exception since 2.6.31: when opened standalone it must keep
    -- receiving live completion updates even while the map is closed.
    if not self:IsWorldMapVisible() then
        self:ReleaseOverlayLabels()
        self:HideAllianceTerritoryBorders()
        self:HideHeaderProgress()
        if self.questRewardControl then self:HideQuestRewards() end
        if self.statisticsWindow and not self.statisticsWindow:IsHidden() then
            self:RefreshStatisticsWindow()
        end
        return
    end

    self:ReleaseOverlayLabels()
    self:RefreshHeaderProgress()
    self:RefreshQuestRewards()
    self:RefreshQuickFilterBar()
    self:RefreshAllianceTerritoryBorders()

    if not self.pinRegistered then
        self:RegisterCustomPin()
    end

    -- Rebuild map percentages before the heavier statistics pass. This keeps the
    -- Tamriel markers visible even while the journal is open/refreshed.
    if self.pinRegistered and type(ZO_WorldMap_GetPinManager) == "function" then
        local pinManager = ZO_WorldMap_GetPinManager()
        local pinType = _G[PIN_TYPE_STRING]
        if pinManager and pinType then
            pinManager:SetCustomPinEnabled(pinType, self.saved and self.saved.enabled or false)
            pinManager:RefreshCustomPins(pinType)
        end
    end

    self:RefreshStatisticsWindow()
end

function TPM:QueueRefresh(delayMs)
    if self.refreshQueued then return end
    self.refreshQueued = true
    zo_callLater(function()
        if TPM then TPM:Refresh() end
    end, delayMs or 80)
end

function TPM:PrintHelp()
    d(string.format("|cE6C45C%s|r v%s - %s", DISPLAY_NAME, VERSION, AUTHOR))
    d(self:L("HELP_TOGGLE"))
    d(self:L("HELP_NAMES"))
    d(self:L("HELP_REFRESH"))
    d(self:L("HELP_LANG"))
    d(self:L("HELP_MODE"))
    d(self:L("HELP_COMPLETED"))
    d(self:L("HELP_FONT"))
    d(self:L("HELP_QUEST_FONT"))
    d(self:L("HELP_REWARDS"))
    d(self:L("HELP_STATS"))
    d(self:L("HELP_PAGE"))
    d(self:L("HELP_DEBUG_REPORT"))
end

function TPM:RefreshBindingStrings()
    local stringId = _G.SI_BINDING_NAME_TPM_TOGGLE_STATISTICS
    if stringId and type(SafeAddString) == "function" then
        SafeAddString(stringId, self:L("KEYBIND_TOGGLE_STATS"), 2)
    end
end

function TPM:SetLanguage(value, silent)
    if value ~= "auto" and value ~= "de" and value ~= "en" and value ~= "ru" and value ~= "fr" then
        return false
    end
    self.saved.language = value
    self:ResolveLanguage()
    self:RefreshBindingStrings()
    self:InvalidateStatisticsData(false)
    self:RefreshCustomSettingsControls()
    if self.settingsPanel and self.settingsPanel.RefreshPanel then
        self.settingsPanel:RefreshPanel()
    end
    self:RefreshStatisticsWindow()
    -- Rebuild Economy focus choices immediately so an already-open dropdown
    -- changes its zone names together with DE/EN/FR/RU.
    if self.economyFocusDropdown then
        self.economyFocusDropdownChoices = nil
        self:RefreshEconomyFocusDropdown()
    end
    self:RefreshQuickFilterBar()
    self:RefreshQuestRewards()
    self:RefreshSkyshardGoalWidget()
    self:QueueRefresh(10)
    -- LAM/map controls can settle a frame after switching language. Refresh a
    -- second time so no stale labels remain.
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            if TPM then
                TPM:RefreshCustomSettingsControls()
                TPM:RefreshStatisticsWindow()
                if TPM.economyFocusDropdown then
                    TPM.economyFocusDropdownChoices = nil
                    TPM:RefreshEconomyFocusDropdown()
                end
                TPM:RefreshQuickFilterBar()
                TPM:RefreshQuestRewards()
                TPM:QueueRefresh(10)
            end
        end, 60)
    end
    if not silent then
        d(self:L("LANGUAGE_SET", self.locale.LANGUAGE_NAME or self.langCode))
    end
    return true
end

function TPM:HandleSlashCommand(text)
    text = zo_strlower(zo_strtrim(text or ""))

    if text == "version" then
        if type(d) == "function" then d(DISPLAY_NAME .. " " .. VERSION) end
    elseif text == "toggle" then
        self.saved.enabled = not self.saved.enabled
        d(string.format("%s: %s", DISPLAY_NAME, self.saved.enabled and self:L("ON") or self:L("OFF")))
        self:QueueRefresh(10)
    elseif text == "names" then
        self.saved.showZoneNames = not self.saved.showZoneNames
        d(string.format("%s %s: %s", DISPLAY_NAME, self:L("ZONE_NAMES"), self.saved.showZoneNames and self:L("ON") or self:L("OFF")))
        self:QueueRefresh(10)
    elseif text == "completed" then
        local hide = (self.saved.hundredDisplayMode or "percent") ~= "hidden"
        self:SetHundredDisplayMode(hide and "hidden" or "percent")
        d(string.format("%s: %s", self:L("HIDE_COMPLETED"), hide and self:L("ON") or self:L("OFF")))
    elseif text == "rewards" then
        self.saved.showQuestRewards = not self.saved.showQuestRewards
        d(string.format("%s: %s", self:L("QUEST_REWARDS"), self.saved.showQuestRewards and self:L("ON") or self:L("OFF")))
        self:QueueRefresh(10)
    elseif text == "skydebug" then
        self:RefreshSkyshardGoalWidget()
        self:PrintSkyshardGoalDebug()
    elseif text == "rewarddebug" then
        local questIndex = self:GetFocusedQuestIndex()
        local lines = questIndex and self:GetQuestRewardLines(questIndex) or {}
        d(string.format("TPM rewarddebug: quest=%s rewards=%d window=%s",
            tostring(questIndex or "nil"), #(lines or {}), tostring(self.questRewardControl ~= nil)))
        self:RefreshQuestRewards()
    elseif text == "refresh" then
        self:QueueRefresh(10)
    elseif text == "stats" or text == "statistics" then
        self:ToggleStatisticsFromKeybind()
    elseif text == "debugreport" then
        d(self:BuildDebugReport())
    elseif text == "checkpoint" then
        self:CheckpointHistory("manual", true)
        d(self:L("HISTORY_CHECKPOINT_SAVED"))
    else
        local page = string.match(text, "^page%s+(%S+)$")
        if page and self:IsValidStatisticsPage(page) then
            self.saved.statisticsPage = page
            if self:ShowStatisticsWindow() then self:SetStatisticsPage(page) end
            return
        end
        local mode = string.match(text, "^mode%s+(%S+)$")
        if mode == "objectives" or mode == "categories" then
            self:SetCalculationMode(mode)
            d(self:L("CALCULATION_MODE_SET", mode == "categories" and self:L("MODE_CATEGORIES") or self:L("MODE_OBJECTIVES")))
            return
        end
        local fontStyle = string.match(text, "^font%s+(%S+)$")
        if fontStyle and self:SetFontStyle(fontStyle) then
            d(self:L("FONT_STYLE_SET", self:GetFontStyleName(fontStyle)))
            return
        end
        local questFontStyle = string.match(text, "^questfont%s+(%S+)$")
        if questFontStyle and self:SetQuestFontStyle(questFontStyle) then
            d(self:L("QUEST_FONT_STYLE_SET", self:GetFontStyleName(questFontStyle)))
            return
        end
        local lang = string.match(text, "^lang%s+(%S+)$")
        if lang and self:SetLanguage(lang) then
            return
        end
        self:PrintHelp()
    end
end


function TPM:RefreshLAMSettingsLocalization()
    local panel = self.settingsPanel
    local controls = panel and panel.controlsToRefresh
    if type(controls) ~= "table" then return end

    local util = LibAddonMenu2 and LibAddonMenu2.util
    local function Resolve(value)
        if util and util.GetStringFromValue then
            return util.GetStringFromValue(value)
        end
        if type(value) == "function" then
            local ok, result = pcall(value)
            return ok and result or ""
        end
        if type(value) == "number" and type(GetString) == "function" then
            return GetString(value)
        end
        return value
    end

    for _, control in ipairs(controls) do
        local data = control and control.data
        if data then
            local name = data.name ~= nil and Resolve(data.name) or nil
            if name ~= nil then
                if control.label and control.label.SetText then control.label:SetText(name) end
                if control.header and control.header.SetText then control.header:SetText(name) end
                if control.button and control.button.SetText then control.button:SetText(name) end
            end
            if control.desc and data.text ~= nil and control.desc.SetText then
                control.desc:SetText(Resolve(data.text) or "")
            end
            if control.title and data.title ~= nil and control.title.SetText then
                control.title:SetText(Resolve(data.title) or "")
            end
            if data.tooltip ~= nil then
                local tooltipText = Resolve(data.tooltip) or ""
                data.tooltipText = tooltipText
                if control.button and type(control.button.data) == "table" then
                    control.button.data.tooltipText = tooltipText
                end
            end
            if control.checkbox then
                control.checkedText = self:L("ON")
                control.uncheckedText = self:L("OFF")
                if control.UpdateValue then control:UpdateValue() end
            end
            if control.UpdateWarning then control:UpdateWarning() end
        end
    end
end

function TPM:RefreshCustomSettingsControls()
    if TamrielProgressMapLanguageControl then
        self:UpdateLanguageCustomControl(TamrielProgressMapLanguageControl)
    end
    if TamrielProgressMapCalculationControl then
        self:UpdateCalculationCustomControl(TamrielProgressMapCalculationControl)
    end
    if TamrielProgressMapFontStyleControl then
        self:UpdateFontStyleCustomControl(TamrielProgressMapFontStyleControl)
    end
    if TamrielProgressMapQuestFontStyleControl then
        self:UpdateQuestFontStyleCustomControl(TamrielProgressMapQuestFontStyleControl)
    end
    if TamrielProgressMapPercentColorControl then
        self:UpdatePercentColorCustomControl(TamrielProgressMapPercentColorControl)
    end
    if TamrielProgressMapPercentSizeControl then
        self:UpdatePercentSizeCustomControl(TamrielProgressMapPercentSizeControl)
    end
    if TamrielProgressMapHundredDisplayControl then
        self:UpdateHundredDisplayCustomControl(TamrielProgressMapHundredDisplayControl)
    end
    self:RefreshLAMSettingsLocalization()
end

function TPM:SetupLanguageCustomControl(control)
    if not control then return end
    control:SetHeight(72)

    if not control.TPMLanguageTitle then
        local title = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        title:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
        title:SetFont("ZoFontWinH4")
        title:SetColor(1, 1, 1, 1)
        control.TPMLanguageTitle = title

        local tip = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        tip:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 2)
        tip:SetFont("ZoFontGameSmall")
        tip:SetColor(0.75, 0.75, 0.75, 1)
        control.TPMLanguageTooltip = tip

        local function CreateLanguageButton(key, x)
            local button = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultButton")
            button:SetDimensions(145, 28)
            button:SetAnchor(TOPLEFT, control, TOPLEFT, x, 40)
            button.languageKey = key
            button:SetHandler("OnClicked", function(btn)
                TPM:SetLanguage(btn.languageKey, true)
            end)
            return button
        end

        -- Five compact buttons: Auto / DE / EN / RU / FR.
        local function PlaceLanguageButton(key, x, width)
            local button = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultButton")
            button:SetDimensions(width or 110, 28)
            button:SetAnchor(TOPLEFT, control, TOPLEFT, x, 40)
            button.languageKey = key
            button:SetHandler("OnClicked", function(btn) TPM:SetLanguage(btn.languageKey, true) end)
            return button
        end
        control.TPMAutoButton = PlaceLanguageButton("auto", 0, 120)
        control.TPMGermanButton = PlaceLanguageButton("de", 126, 86)
        control.TPMEnglishButton = PlaceLanguageButton("en", 218, 86)
        control.TPMRussianButton = PlaceLanguageButton("ru", 310, 86)
        control.TPMFrenchButton = PlaceLanguageButton("fr", 402, 94)
    end

    self:UpdateLanguageCustomControl(control)
end

function TPM:UpdateLanguageCustomControl(control)
    if not control then return end
    if control.TPMLanguageTitle then control.TPMLanguageTitle:SetText(self:L("SETTINGS_LANGUAGE")) end
    if control.TPMLanguageTooltip then control.TPMLanguageTooltip:SetText(self:L("SETTINGS_LANGUAGE_TT")) end

    local current = self.saved and self.saved.language or "auto"
    local labels =
    {
        auto = self:L("SETTINGS_LANGUAGE_AUTO"),
        de = self:L("SETTINGS_LANGUAGE_DE"),
        en = self:L("SETTINGS_LANGUAGE_EN"),
        ru = self:L("SETTINGS_LANGUAGE_RU"),
        fr = self:L("SETTINGS_LANGUAGE_FR"),
    }
    local buttons = { control.TPMAutoButton, control.TPMGermanButton, control.TPMEnglishButton, control.TPMRussianButton, control.TPMFrenchButton }
    for _, button in ipairs(buttons) do
        if button then
            local text = labels[button.languageKey] or button.languageKey
            local selected = button.languageKey == current
            button:SetText(selected and ("|cE6C45C" .. text .. "|r") or text)
        end
    end
end

function TPM:SetCalculationMode(value)
    if value ~= "objectives" and value ~= "categories" then return false end
    self.saved.calculationMode = value
    self:InvalidateStatisticsData(false)
    if TamrielProgressMapCalculationControl then
        self:UpdateCalculationCustomControl(TamrielProgressMapCalculationControl)
    end
    self:QueueRefresh(10)
    return true
end

function TPM:SetupCalculationCustomControl(control)
    if not control then return end
    control:SetHeight(72)

    if not control.TPMCalculationTitle then
        local title = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        title:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
        title:SetFont("ZoFontWinH4")
        title:SetColor(1, 1, 1, 1)
        control.TPMCalculationTitle = title

        local tip = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        tip:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 2)
        tip:SetFont("ZoFontGameSmall")
        tip:SetColor(0.75, 0.75, 0.75, 1)
        control.TPMCalculationTooltip = tip

        local function CreateModeButton(key, x)
            local button = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultButton")
            button:SetDimensions(220, 28)
            button:SetAnchor(TOPLEFT, control, TOPLEFT, x, 40)
            button.modeKey = key
            button:SetHandler("OnClicked", function(btn)
                TPM:SetCalculationMode(btn.modeKey)
            end)
            return button
        end

        control.TPMObjectivesButton = CreateModeButton("objectives", 0)
        control.TPMCategoriesButton = CreateModeButton("categories", 230)
    end

    self:UpdateCalculationCustomControl(control)
end

function TPM:UpdateCalculationCustomControl(control)
    if not control then return end
    if control.TPMCalculationTitle then control.TPMCalculationTitle:SetText(self:L("SETTINGS_CALCULATION")) end
    if control.TPMCalculationTooltip then control.TPMCalculationTooltip:SetText(self:L("SETTINGS_CALCULATION_TT")) end

    local current = self.saved and self.saved.calculationMode or "objectives"
    local labels =
    {
        objectives = self:L("MODE_OBJECTIVES"),
        categories = self:L("MODE_CATEGORIES"),
    }
    local buttons = { control.TPMObjectivesButton, control.TPMCategoriesButton }
    for _, button in ipairs(buttons) do
        if button then
            local text = labels[button.modeKey] or button.modeKey
            local selected = button.modeKey == current
            button:SetText(selected and ("|cE6C45C" .. text .. "|r") or text)
        end
    end
end

function TPM:SetFontStyle(value)
    value = self:NormalizeFontStyle(value)
    if not value then
        return false
    end

    self.saved.fontStyle = value
    self:ApplyProgressFonts()
    if TamrielProgressMapFontStyleControl then
        self:UpdateFontStyleCustomControl(TamrielProgressMapFontStyleControl)
    end
    self:QueueRefresh(10)
    return true
end

function TPM:SetQuestFontStyle(value)
    value = self:NormalizeFontStyle(value)
    if not value then
        return false
    end

    self.saved.questFontStyle = value
    self:ApplyQuestRewardFonts()
    if TamrielProgressMapQuestFontStyleControl then
        self:UpdateQuestFontStyleCustomControl(TamrielProgressMapQuestFontStyleControl)
    end
    self:QueueRefresh(10)
    return true
end

function TPM:SetupFontSelectorCustomControl(control, isQuestFont)
    if not control then return end
    control:SetHeight(96)

    if not control.TPMFontSelectorTitle then
        local title = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        title:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
        title:SetFont("ZoFontWinH4")
        title:SetColor(1, 1, 1, 1)
        control.TPMFontSelectorTitle = title

        local tip = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        tip:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 2)
        tip:SetFont("ZoFontGameSmall")
        tip:SetColor(0.75, 0.75, 0.75, 1)
        control.TPMFontSelectorTooltip = tip

        local prev = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultButton")
        prev:SetDimensions(46, 32)
        prev:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 50)
        prev:SetText("<")
        control.TPMFontPrevButton = prev

        local nextButton = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultButton")
        nextButton:SetDimensions(46, 32)
        nextButton:SetAnchor(TOPLEFT, control, TOPLEFT, 414, 50)
        nextButton:SetText(">")
        control.TPMFontNextButton = nextButton

        local preview = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        preview:SetDimensions(350, 38)
        preview:SetAnchor(TOPLEFT, control, TOPLEFT, 55, 47)
        preview:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        preview:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        preview:SetColor(0.90, 0.77, 0.36, 1)
        control.TPMFontPreview = preview

        prev:SetHandler("OnClicked", function()
            local current = isQuestFont and (TPM.saved.questFontStyle or "classic") or (TPM.saved.fontStyle or "classic")
            local value = TPM:GetAdjacentFontStyle(current, -1)
            if isQuestFont then TPM:SetQuestFontStyle(value) else TPM:SetFontStyle(value) end
        end)
        nextButton:SetHandler("OnClicked", function()
            local current = isQuestFont and (TPM.saved.questFontStyle or "classic") or (TPM.saved.fontStyle or "classic")
            local value = TPM:GetAdjacentFontStyle(current, 1)
            if isQuestFont then TPM:SetQuestFontStyle(value) else TPM:SetFontStyle(value) end
        end)
    end

    control.TPMFontSelectorIsQuest = isQuestFont
    if isQuestFont then
        self:UpdateQuestFontStyleCustomControl(control)
    else
        self:UpdateFontStyleCustomControl(control)
    end
end

function TPM:SetupFontStyleCustomControl(control)
    self:SetupFontSelectorCustomControl(control, false)
end

function TPM:UpdateFontStyleCustomControl(control)
    if not control then return end
    local style = self.saved and self.saved.fontStyle or "classic"
    local profile = self:GetFontProfile(style)
    if control.TPMFontSelectorTitle then control.TPMFontSelectorTitle:SetText(self:L("SETTINGS_FONT")) end
    if control.TPMFontSelectorTooltip then control.TPMFontSelectorTooltip:SetText(self:L("SETTINGS_FONT_TT")) end
    if control.TPMFontPreview then
        control.TPMFontPreview:SetFont(profile.overlay)
        control.TPMFontPreview:SetText(string.format("75%%  -  %s", self:GetFontStyleName(style)))
    end
end

function TPM:SetupQuestFontStyleCustomControl(control)
    self:SetupFontSelectorCustomControl(control, true)
end

function TPM:UpdateQuestFontStyleCustomControl(control)
    if not control then return end
    local style = self.saved and self.saved.questFontStyle or "classic"
    local profile = self:GetFontProfile(style)
    if control.TPMFontSelectorTitle then control.TPMFontSelectorTitle:SetText(self:L("SETTINGS_QUEST_FONT")) end
    if control.TPMFontSelectorTooltip then control.TPMFontSelectorTooltip:SetText(self:L("SETTINGS_QUEST_FONT_TT")) end
    if control.TPMFontPreview then
        control.TPMFontPreview:SetFont(profile.questTitle)
        control.TPMFontPreview:SetText(string.format("%s  -  %s", self:L("QUEST_REWARDS"), self:GetFontStyleName(style)))
    end
end

function TPM:SetPercentColorMode(value)
    if value ~= "progress" and value ~= "black" and value ~= "brown" and value ~= "gold" and value ~= "custom" then
        return false
    end
    self.saved.percentColorMode = value
    self.saved.blackPercentText = value == "black" -- keep old SavedVariables meaningful
    if TamrielProgressMapPercentColorControl then
        self:UpdatePercentColorCustomControl(TamrielProgressMapPercentColorControl)
    end
    self:QueueRefresh(10)
    return true
end

function TPM:OpenCustomPercentColorPicker()
    local savedColor = self.saved.customPercentColor or DEFAULTS.customPercentColor
    local r = Clamp(tonumber(savedColor.r) or DEFAULTS.customPercentColor.r, 0, 1)
    local g = Clamp(tonumber(savedColor.g) or DEFAULTS.customPercentColor.g, 0, 1)
    local b = Clamp(tonumber(savedColor.b) or DEFAULTS.customPercentColor.b, 0, 1)

    local picker = nil
    if type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode() and COLOR_PICKER_GAMEPAD then
        picker = COLOR_PICKER_GAMEPAD
    else
        picker = COLOR_PICKER
    end

    if not picker or not picker.Show then
        self:SetPercentColorMode("custom")
        return false
    end

    picker:Show(function(newR, newG, newB)
        TPM.saved.customPercentColor =
        {
            r = Clamp(newR or r, 0, 1),
            g = Clamp(newG or g, 0, 1),
            b = Clamp(newB or b, 0, 1),
        }
        TPM:SetPercentColorMode("custom")
        if TamrielProgressMapPercentColorControl then
            TPM:UpdatePercentColorCustomControl(TamrielProgressMapPercentColorControl)
        end
    end, r, g, b)
    return true
end

function TPM:SetupPercentColorCustomControl(control)
    if not control then return end
    control:SetHeight(72)

    if not control.TPMColorTitle then
        local title = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        title:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
        title:SetFont("ZoFontWinH4")
        title:SetColor(1, 1, 1, 1)
        control.TPMColorTitle = title

        local tip = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        tip:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 2)
        tip:SetFont("ZoFontGameSmall")
        tip:SetColor(0.75, 0.75, 0.75, 1)
        control.TPMColorTooltip = tip

        local function CreateColorButton(key, x)
            local button = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultButton")
            button:SetDimensions(92, 28)
            button:SetAnchor(TOPLEFT, control, TOPLEFT, x, 40)
            button.colorKey = key
            button:SetHandler("OnClicked", function(btn)
                if btn.colorKey == "custom" then
                    TPM:OpenCustomPercentColorPicker()
                else
                    TPM:SetPercentColorMode(btn.colorKey)
                end
                TPM:UpdatePercentColorCustomControl(control)
            end)
            return button
        end

        control.TPMProgressColorButton = CreateColorButton("progress", 0)
        control.TPMBlackColorButton = CreateColorButton("black", 98)
        control.TPMBrownColorButton = CreateColorButton("brown", 196)
        control.TPMGoldColorButton = CreateColorButton("gold", 294)
        control.TPMCustomColorButton = CreateColorButton("custom", 392)
    end

    self:UpdatePercentColorCustomControl(control)
end

function TPM:UpdatePercentColorCustomControl(control)
    if not control then return end
    if control.TPMColorTitle then control.TPMColorTitle:SetText(self:L("SETTINGS_PERCENT_COLOR")) end
    if control.TPMColorTooltip then control.TPMColorTooltip:SetText(self:L("SETTINGS_PERCENT_COLOR_TT")) end

    local current = self.saved and self.saved.percentColorMode or "black"
    local labels = {
        progress = self:L("COLOR_PROGRESS"),
        black = self:L("COLOR_BLACK"),
        brown = self:L("COLOR_BROWN"),
        gold = self:L("COLOR_GOLD"),
        custom = self:L("COLOR_CUSTOM"),
    }
    local buttons = {
        control.TPMProgressColorButton,
        control.TPMBlackColorButton,
        control.TPMBrownColorButton,
        control.TPMGoldColorButton,
        control.TPMCustomColorButton,
    }
    for _, button in ipairs(buttons) do
        if button then
            local text = labels[button.colorKey] or button.colorKey
            local selected = button.colorKey == current
            if button.colorKey == "custom" then
                local color = self.saved and self.saved.customPercentColor or DEFAULTS.customPercentColor
                local colorHex = RGBToHex(color.r, color.g, color.b)
                text = "|c" .. colorHex .. text .. "|r"
                if selected then
                    text = "|cE6C45C[|r" .. text .. "|cE6C45C]|r"
                end
            elseif selected then
                text = "|cE6C45C" .. text .. "|r"
            end
            button:SetText(text)
        end
    end
end

function TPM:SetPercentScale(kind, value)
    value = Clamp(Round(tonumber(value) or 100), 70, 160)
    if kind == "header" then
        self.saved.headerPercentScale = value
    else
        self.saved.mapPercentScale = value
    end
    self:ApplyProgressFonts()
    if TamrielProgressMapPercentSizeControl then
        self:UpdatePercentSizeCustomControl(TamrielProgressMapPercentSizeControl)
    end
    self:QueueRefresh(10)
end

function TPM:SetupPercentSizeCustomControl(control)
    if not control then return end
    control:SetHeight(102)

    if not control.TPMPercentSizeTitle then
        local title = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        title:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
        title:SetFont("ZoFontWinH4")
        title:SetColor(1, 1, 1, 1)
        control.TPMPercentSizeTitle = title

        local tip = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        tip:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 2)
        tip:SetFont("ZoFontGameSmall")
        tip:SetColor(0.75, 0.75, 0.75, 1)
        control.TPMPercentSizeTooltip = tip

        local function CreateRow(prefix, y, kind)
            local label = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
            label:SetDimensions(285, 28)
            label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, y)
            label:SetFont("ZoFontGame")
            label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            control[prefix .. "Label"] = label

            local minus = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultButton")
            minus:SetDimensions(42, 28)
            minus:SetAnchor(TOPLEFT, control, TOPLEFT, 300, y)
            minus:SetText("-")
            minus:SetHandler("OnClicked", function()
                local current = kind == "header" and TPM.saved.headerPercentScale or TPM.saved.mapPercentScale
                TPM:SetPercentScale(kind, (current or 100) - 5)
            end)

            local plus = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultButton")
            plus:SetDimensions(42, 28)
            plus:SetAnchor(TOPLEFT, control, TOPLEFT, 350, y)
            plus:SetText("+")
            plus:SetHandler("OnClicked", function()
                local current = kind == "header" and TPM.saved.headerPercentScale or TPM.saved.mapPercentScale
                TPM:SetPercentScale(kind, (current or 100) + 5)
            end)
        end

        CreateRow("TPMMapPercentSize", 42, "map")
        CreateRow("TPMHeaderPercentSize", 72, "header")
    end

    self:UpdatePercentSizeCustomControl(control)
end

function TPM:UpdatePercentSizeCustomControl(control)
    if not control then return end
    if control.TPMPercentSizeTitle then control.TPMPercentSizeTitle:SetText(self:L("SETTINGS_PERCENT_SIZE")) end
    if control.TPMPercentSizeTooltip then control.TPMPercentSizeTooltip:SetText(self:L("SETTINGS_PERCENT_SIZE_TT")) end
    if control.TPMMapPercentSizeLabel then
        control.TPMMapPercentSizeLabel:SetText(string.format("%s: %d%%", self:L("SETTINGS_MAP_PERCENT_SIZE"), self.saved.mapPercentScale or 100))
    end
    if control.TPMHeaderPercentSizeLabel then
        control.TPMHeaderPercentSizeLabel:SetText(string.format("%s: %d%%", self:L("SETTINGS_HEADER_PERCENT_SIZE"), self.saved.headerPercentScale or 100))
    end
end

function TPM:SetHundredDisplayMode(value)
    if value ~= "percent" and value ~= "check" and value ~= "hidden" then return false end
    self.saved.hundredDisplayMode = value
    self.saved.hideCompletedZones = value == "hidden" -- legacy SavedVariable compatibility
    if TamrielProgressMapHundredDisplayControl then
        self:UpdateHundredDisplayCustomControl(TamrielProgressMapHundredDisplayControl)
    end
    self:QueueRefresh(10)
    return true
end

function TPM:SetupHundredDisplayCustomControl(control)
    if not control then return end
    control:SetHeight(72)

    if not control.TPMHundredTitle then
        local title = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        title:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
        title:SetFont("ZoFontWinH4")
        title:SetColor(1, 1, 1, 1)
        control.TPMHundredTitle = title

        local tip = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
        tip:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 2)
        tip:SetFont("ZoFontGameSmall")
        tip:SetColor(0.75, 0.75, 0.75, 1)
        control.TPMHundredTooltip = tip

        local function CreateModeButton(key, x)
            local button = WINDOW_MANAGER:CreateControlFromVirtual(nil, control, "ZO_DefaultButton")
            button:SetDimensions(145, 28)
            button:SetAnchor(TOPLEFT, control, TOPLEFT, x, 40)
            button.modeKey = key
            button:SetHandler("OnClicked", function(btn)
                TPM:SetHundredDisplayMode(btn.modeKey)
            end)
            return button
        end

        control.TPMHundredPercentButton = CreateModeButton("percent", 0)
        control.TPMHundredCheckButton = CreateModeButton("check", 154)
        control.TPMHundredHiddenButton = CreateModeButton("hidden", 308)
    end

    self:UpdateHundredDisplayCustomControl(control)
end

function TPM:UpdateHundredDisplayCustomControl(control)
    if not control then return end
    if control.TPMHundredTitle then control.TPMHundredTitle:SetText(self:L("SETTINGS_HUNDRED_DISPLAY")) end
    if control.TPMHundredTooltip then control.TPMHundredTooltip:SetText(self:L("SETTINGS_HUNDRED_DISPLAY_TT")) end

    local current = self.saved and self.saved.hundredDisplayMode or "percent"
    local labels =
    {
        percent = self:L("HUNDRED_PERCENT"),
        check = self:L("HUNDRED_CHECK"),
        hidden = self:L("HUNDRED_HIDDEN"),
    }
    local buttons = { control.TPMHundredPercentButton, control.TPMHundredCheckButton, control.TPMHundredHiddenButton }
    for _, button in ipairs(buttons) do
        if button then
            local text = labels[button.modeKey] or button.modeKey
            local selected = button.modeKey == current
            button:SetText(selected and ("|cE6C45C" .. text .. "|r") or text)
        end
    end
end


function TPM:ResetCurrentCharacterCombatStats()
    -- 3.4.9: lifetime combat counters are intentionally permanent per character.
    -- Keep this method as a compatibility no-op for older settings/control references.
    return false
end

function TPM:ResetCurrentCharacterEconomyStats()
    if not self.saved then return end
    local key = self:GetCurrentCharacterStatsKey()
    self.saved.economyStatsByCharacter[key] = { trackingVersion = VERSION, currencies = {} }
    self:RefreshEconomyStatisticsPage()
end

function TPM:ResetCurrentCharacterHistory()
    if not self.saved then return end
    local key = self:GetCurrentCharacterStatsKey()
    self.saved.historyByCharacter[key] = nil
    self.saved.milestoneStateByCharacter[key] = nil
    self:StartOrResumeHistorySession()
    self:RefreshHistoryStatisticsPage()
end

function TPM:RegisterSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelDisplayName = string.format("%s v%s", DISPLAY_NAME, VERSION)

    local panelData =
    {
        type = "panel",
        name = panelDisplayName,
        displayName = "|cE6C45C" .. panelDisplayName .. "|r",
        author = AUTHOR,
        version = VERSION,
        registerForRefresh = true,
        registerForDefaults = false,
    }

    self.settingsPanel = LAM:RegisterAddonPanel(ADDON_NAME .. "Options", panelData)

    local optionData =
    {
        { type = "header", name = function() return TPM:L("SETTINGS_SECTION_LANGUAGE") end, width = "full" },
        {
            type = "custom",
            reference = "TamrielProgressMapLanguageControl",
            refreshFunc = function(control) TPM:SetupLanguageCustomControl(control) end,
            width = "full",
        },
        { type = "description", text = function() return TPM:L("SETTINGS_RELOAD_NOTE") end, width = "full" },

        { type = "header", name = function() return TPM:L("SETTINGS_SECTION_MAP") end, width = "full" },
        {
            type = "checkbox",
            name = function() return TPM:L("SETTINGS_ENABLED") end,
            tooltip = function() return TPM:L("SETTINGS_ENABLED_TT") end,
            getFunc = function() return TPM.saved.enabled end,
            setFunc = function(value) TPM.saved.enabled = value; TPM:QueueRefresh(10) end,
            default = DEFAULTS.enabled,
            width = "full",
        },
        {
            type = "checkbox",
            name = function() return TPM:L("SETTINGS_QUICK_FILTERS") end,
            tooltip = function() return TPM:L("SETTINGS_QUICK_FILTERS_TT") end,
            getFunc = function() return TPM.saved.showQuickFilters end,
            setFunc = function(value) TPM.saved.showQuickFilters = value; TPM:RefreshQuickFilterBar() end,
            default = DEFAULTS.showQuickFilters,
            width = "full",
        },
        {
            type = "checkbox",
            name = function() return TPM:L("SETTINGS_NAMES") end,
            tooltip = function() return TPM:L("SETTINGS_NAMES_TT") end,
            getFunc = function() return TPM.saved.showZoneNames end,
            setFunc = function(value) TPM.saved.showZoneNames = value; TPM:QueueRefresh(10) end,
            default = DEFAULTS.showZoneNames,
            width = "full",
        },

        {
            type = "checkbox",
            name = function() return TPM:L("SETTINGS_ALLIANCE_TERRITORY") end,
            tooltip = function() return TPM:L("SETTINGS_ALLIANCE_TERRITORY_TT") end,
            getFunc = function() return TPM.saved.showAllianceTerritoryColors end,
            setFunc = function(value)
                TPM.saved.showAllianceTerritoryColors = value and true or false
                TPM:QueueRefresh(10)
            end,
            default = DEFAULTS.showAllianceTerritoryColors,
            width = "full",
        },
        {
            type = "checkbox",
            name = function() return TPM:L("SETTINGS_ALLIANCE_NEUTRAL_WHITE") end,
            tooltip = function() return TPM:L("SETTINGS_ALLIANCE_NEUTRAL_WHITE_TT") end,
            getFunc = function() return TPM.saved.allianceNeutralWhite end,
            setFunc = function(value)
                TPM.saved.allianceNeutralWhite = value and true or false
                TPM:QueueRefresh(10)
            end,
            default = DEFAULTS.allianceNeutralWhite,
            disabled = function() return not TPM.saved.showAllianceTerritoryColors end,
            width = "full",
        },
        {
            type = "checkbox",
            name = function() return TPM:L("SETTINGS_TOOLTIP") end,
            tooltip = function() return TPM:L("SETTINGS_TOOLTIP_TT") end,
            getFunc = function() return TPM.saved.showTooltip end,
            setFunc = function(value) TPM.saved.showTooltip = value end,
            default = DEFAULTS.showTooltip,
            width = "full",
        },
        {
            type = "checkbox",
            name = function() return TPM:L("SETTINGS_HEADER") end,
            tooltip = function() return TPM:L("SETTINGS_HEADER_TT") end,
            getFunc = function() return TPM.saved.showHeader end,
            setFunc = function(value) TPM.saved.showHeader = value; TPM:QueueRefresh(10) end,
            default = DEFAULTS.showHeader,
            width = "full",
        },

        { type = "header", name = function() return TPM:L("SETTINGS_SECTION_DISPLAY") end, width = "full" },
        {
            type = "custom",
            reference = "TamrielProgressMapFontStyleControl",
            refreshFunc = function(control) TPM:SetupFontStyleCustomControl(control) end,
            width = "full",
        },
        {
            type = "custom",
            reference = "TamrielProgressMapPercentSizeControl",
            refreshFunc = function(control) TPM:SetupPercentSizeCustomControl(control) end,
            width = "full",
        },
        {
            type = "custom",
            reference = "TamrielProgressMapPercentColorControl",
            refreshFunc = function(control) TPM:SetupPercentColorCustomControl(control) end,
            width = "full",
        },
        {
            type = "custom",
            reference = "TamrielProgressMapHundredDisplayControl",
            refreshFunc = function(control) TPM:SetupHundredDisplayCustomControl(control) end,
            width = "full",
        },
        {
            type = "slider",
            name = function() return TPM:L("SETTINGS_STATISTICS_SCALE") end,
            tooltip = function() return TPM:L("SETTINGS_STATISTICS_SCALE_TT") end,
            min = 80, max = 120, step = 5,
            getFunc = function() return TPM.saved.statisticsWindowScale or 100 end,
            setFunc = function(value)
                TPM.saved.statisticsWindowScale = Clamp(Round(value), 80, 120)
                if TPM.statisticsWindow then
                    TPM.statisticsWindow:SetScale(TPM.saved.statisticsWindowScale / 100)
                    TPM:ClampStatisticsWindowToScreen()
                end
            end,
            default = DEFAULTS.statisticsWindowScale,
            width = "full",
        },
        {
            type = "button",
            name = function() return TPM:L("SETTINGS_STATISTICS_RESET") end,
            tooltip = function() return TPM:L("SETTINGS_STATISTICS_RESET_TT") end,
            func = function() TPM:ResetStatisticsWindowPosition() end,
            width = "half",
        },
        {
            type = "description",
            text = function() return TPM:L("SETTINGS_STATISTICS_KEYBIND_INFO") end,
            width = "full",
        },

        { type = "header", name = function() return TPM:L("SETTINGS_SECTION_PROGRESS") end, width = "full" },
        {
            type = "custom",
            reference = "TamrielProgressMapCalculationControl",
            refreshFunc = function(control) TPM:SetupCalculationCustomControl(control) end,
            width = "full",
        },
        {
            type = "dropdown",
            name = function() return TPM:L("SETTINGS_SKYSHARD_POSITION") end,
            tooltip = function() return TPM:L("SETTINGS_SKYSHARD_POSITION_TT") end,
            choices = { "1", "2" },
            choicesValues = { 1, 2 },
            getFunc = function() return tonumber(TPM.saved.skyshardGoalPosition) == 2 and 2 or 1 end,
            setFunc = function(value) TPM:SetSkyshardGoalPosition(value) end,
            default = DEFAULTS.skyshardGoalPosition,
            width = "full",
        },

        { type = "header", name = function() return TPM:L("SETTINGS_SECTION_QUEST") end, width = "full" },
        {
            type = "custom",
            reference = "TamrielProgressMapQuestFontStyleControl",
            refreshFunc = function(control) TPM:SetupQuestFontStyleCustomControl(control) end,
            width = "full",
        },
        {
            type = "checkbox",
            name = function() return TPM:L("SETTINGS_QUEST_REWARDS") end,
            tooltip = function() return TPM:L("SETTINGS_QUEST_REWARDS_TT") end,
            getFunc = function() return TPM.saved.showQuestRewards end,
            setFunc = function(value) TPM.saved.showQuestRewards = value; TPM:QueueRefresh(10) end,
            default = DEFAULTS.showQuestRewards,
            width = "full",
        },
        {
            type = "checkbox",
            name = function() return TPM:L("SETTINGS_QUEST_REWARD_COLORS") end,
            tooltip = function() return TPM:L("SETTINGS_QUEST_REWARD_COLORS_TT") end,
            getFunc = function() return TPM.saved.colorVanillaQuestsByReward ~= false end,
            setFunc = function(value)
                TPM.saved.colorVanillaQuestsByReward = value
                TPM:RefreshVanillaQuestRewardColors()
            end,
            default = DEFAULTS.colorVanillaQuestsByReward,
            width = "full",
        },
        {
            type = "checkbox",
            name = function() return TPM:L("SETTINGS_QUEST_AUTO_SIZE") end,
            tooltip = function() return TPM:L("SETTINGS_QUEST_AUTO_SIZE_TT") end,
            getFunc = function() return TPM.saved.questRewardAutoSize end,
            setFunc = function(value) TPM.saved.questRewardAutoSize = value; TPM:QueueRefresh(10) end,
            default = DEFAULTS.questRewardAutoSize,
            width = "full",
        },
        {
            type = "checkbox",
            name = function() return TPM:L("SETTINGS_QUEST_LOCK") end,
            tooltip = function() return TPM:L("SETTINGS_QUEST_LOCK_TT") end,
            getFunc = function() return TPM.saved.questRewardLocked end,
            setFunc = function(value) TPM.saved.questRewardLocked = value; TPM:UpdateQuestRewardLockState() end,
            default = DEFAULTS.questRewardLocked,
            width = "full",
        },
        {
            type = "button",
            name = function() return TPM:L("SETTINGS_QUEST_RESET") end,
            tooltip = function() return TPM:L("SETTINGS_QUEST_RESET_TT") end,
            func = function() TPM:ResetQuestRewardWindow() end,
            width = "half",
        },

        { type = "header", name = function() return TPM:L("SETTINGS_SECTION_JOURNAL") end, width = "full" },
        {
            type = "checkbox",
            name = function() return TPM:L("SETTINGS_HISTORY_ENABLED") end,
            tooltip = function() return TPM:L("SETTINGS_HISTORY_ENABLED_TT") end,
            getFunc = function() return TPM.saved.historyEnabled ~= false end,
            setFunc = function(value)
                if value then
                    TPM.saved.historyEnabled = true
                    TPM:StartOrResumeHistorySession()
                else
                    -- Pause before disabling so time spent with history disabled
                    -- can never be added to a later session when it is re-enabled.
                    TPM:CheckpointHistoryOnDeactivated()
                    TPM.saved.historyEnabled = false
                end
            end,
            default = DEFAULTS.historyEnabled,
            width = "full",
        },
        {
            type = "checkbox",
            name = function() return TPM:L("SETTINGS_MILESTONES") end,
            tooltip = function() return TPM:L("SETTINGS_MILESTONES_TT") end,
            getFunc = function() return TPM.saved.showMilestones ~= false end,
            setFunc = function(value) TPM.saved.showMilestones = value end,
            default = DEFAULTS.showMilestones,
            width = "full",
        },
        {
            type = "button",
            name = function() return TPM:L("SETTINGS_RESET_ECONOMY") end,
            tooltip = function() return TPM:L("SETTINGS_RESET_ECONOMY_TT") end,
            func = function() TPM:ResetCurrentCharacterEconomyStats() end,
            width = "half",
        },
        {
            type = "button",
            name = function() return TPM:L("SETTINGS_RESET_HISTORY") end,
            tooltip = function() return TPM:L("SETTINGS_RESET_HISTORY_TT") end,
            func = function() TPM:ResetCurrentCharacterHistory() end,
            width = "half",
        },

        { type = "header", name = function() return TPM:L("SETTINGS_SECTION_ADVANCED") end, width = "full" },
        {
            type = "checkbox",
            name = function() return TPM:L("SETTINGS_DEBUG") end,
            tooltip = function() return TPM:L("SETTINGS_DEBUG_TT") end,
            getFunc = function() return TPM.saved.debugMode end,
            setFunc = function(value) TPM.saved.debugMode = value end,
            default = DEFAULTS.debugMode,
            width = "full",
        },

        { type = "description", text = function() return TPM:L("SETTINGS_CHANGELOG") end, width = "full" },
    }

    LAM:RegisterOptionControls(ADDON_NAME .. "Options", optionData)

    if not self.lamControlsCreatedCallbackRegistered then
        self.lamControlsCreatedCallbackRegistered = true
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
            if panel ~= TPM.settingsPanel then return end

            -- Build the direct ESO button controls on first panel creation.
            if TamrielProgressMapLanguageControl then
                TPM:SetupLanguageCustomControl(TamrielProgressMapLanguageControl)
            end
            if TamrielProgressMapCalculationControl then
                TPM:SetupCalculationCustomControl(TamrielProgressMapCalculationControl)
            end
            if TamrielProgressMapFontStyleControl then
                TPM:SetupFontStyleCustomControl(TamrielProgressMapFontStyleControl)
            end
            if TamrielProgressMapQuestFontStyleControl then
                TPM:SetupQuestFontStyleCustomControl(TamrielProgressMapQuestFontStyleControl)
            end
            if TamrielProgressMapPercentColorControl then
                TPM:SetupPercentColorCustomControl(TamrielProgressMapPercentColorControl)
            end
            if TamrielProgressMapPercentSizeControl then
                TPM:SetupPercentSizeCustomControl(TamrielProgressMapPercentSizeControl)
            end
            if TamrielProgressMapHundredDisplayControl then
                TPM:SetupHundredDisplayCustomControl(TamrielProgressMapHundredDisplayControl)
            end
            TPM:RefreshLAMSettingsLocalization()
        end)
    end
end


function TPM:QueueProgressHistoryCheckpoint()
    if self.progressHistoryCheckpointQueued then return end
    self.progressHistoryCheckpointQueued = true
    zo_callLater(function()
        if not TPM then return end
        TPM.progressHistoryCheckpointQueued = false
        local snapshot = TPM:CaptureHistorySnapshot(false)
        TPM:CheckMilestones(snapshot)
        TPM:CheckpointHistory("progress", false, snapshot)
        if TPM.statisticsWindow and not TPM.statisticsWindow:IsHidden()
            and TPM.saved and TPM.saved.statisticsPage == "history" then
            TPM:RefreshHistoryStatisticsPage()
        end
    end, 250)
end

function TPM:Initialize()
    -- Define NumPad 5 as TPM's default binding without forcing it as a custom
    -- bind. ESO will use this as the default and players can freely replace it
    -- under Controls > Keybindings > Tamriel Progress Map.
    if type(CreateDefaultActionBind) == "function" and _G.KEY_NUMPAD5 ~= nil then
        local noModifier = _G.KEY_INVALID or 0
        pcall(CreateDefaultActionBind, "TPM_TOGGLE_STATISTICS", _G.KEY_NUMPAD5, noModifier, noModifier, noModifier, noModifier)
    end

    self.saved = ZO_SavedVars:NewAccountWide("TamrielProgressMap_SavedVariables", 1, nil, DEFAULTS)
    if not self.saved.percentColorModeMigrated then
        if self.saved.blackPercentText then
            self.saved.percentColorMode = "black"
        end
        self.saved.percentColorModeMigrated = true
    end
    if self.saved.percentColorMode ~= "progress" and self.saved.percentColorMode ~= "black"
        and self.saved.percentColorMode ~= "brown" and self.saved.percentColorMode ~= "gold"
        and self.saved.percentColorMode ~= "custom" then
        self.saved.percentColorMode = DEFAULTS.percentColorMode
    end

    -- v2.0.4: Black is now the standard map-percentage color. Existing users
    -- who were still on the old default "progress" palette are migrated once.
    -- Explicit Brown/Gold/Custom choices are preserved.
    if not self.saved.percentColorBlack204Migrated then
        if self.saved.percentColorMode == "progress" then
            self.saved.percentColorMode = "black"
            self.saved.blackPercentText = true
        end
        self.saved.percentColorBlack204Migrated = true
    end

    -- v2.0.5: force the map percentage color to true black once on upgrade.
    -- Some 2.0.x installs already had Gold/Custom saved from testing, so merely
    -- changing the default in 2.0.4 could not affect those existing SavedVars.
    -- After this one-time reset the user can freely choose another color again.
    if not self.saved.percentColorBlack205Migrated then
        self.saved.percentColorMode = "black"
        self.saved.blackPercentText = true
        self.saved.percentColorBlack205Migrated = true
    end

    if type(self.saved.customPercentColor) ~= "table" then
        self.saved.customPercentColor = { r = DEFAULTS.customPercentColor.r, g = DEFAULTS.customPercentColor.g, b = DEFAULTS.customPercentColor.b }
    else
        self.saved.customPercentColor.r = Clamp(tonumber(self.saved.customPercentColor.r) or DEFAULTS.customPercentColor.r, 0, 1)
        self.saved.customPercentColor.g = Clamp(tonumber(self.saved.customPercentColor.g) or DEFAULTS.customPercentColor.g, 0, 1)
        self.saved.customPercentColor.b = Clamp(tonumber(self.saved.customPercentColor.b) or DEFAULTS.customPercentColor.b, 0, 1)
    end

    self.saved.mapPercentScale = Clamp(Round(tonumber(self.saved.mapPercentScale) or DEFAULTS.mapPercentScale), 70, 160)
    self.saved.headerPercentScale = Clamp(Round(tonumber(self.saved.headerPercentScale) or DEFAULTS.headerPercentScale), 70, 160)
    self.saved.statisticsWindowScale = Clamp(Round(tonumber(self.saved.statisticsWindowScale) or DEFAULTS.statisticsWindowScale), 80, 120)

    if not self.saved.hundredDisplayMigrated then
        self.saved.hundredDisplayMode = self.saved.hideCompletedZones and "hidden" or "percent"
        self.saved.hundredDisplayMigrated = true
    end
    if self.saved.hundredDisplayMode ~= "percent" and self.saved.hundredDisplayMode ~= "check" and self.saved.hundredDisplayMode ~= "hidden" then
        self.saved.hundredDisplayMode = DEFAULTS.hundredDisplayMode
    end
    self.saved.hideCompletedZones = self.saved.hundredDisplayMode == "hidden"

    if self.saved.quickFilter ~= "all" and self.saved.quickFilter ~= "incomplete"
        and self.saved.quickFilter ~= "under50" and self.saved.quickFilter ~= "complete" then
        self.saved.quickFilter = DEFAULTS.quickFilter
    end

    if self.saved.statisticsSortMode ~= "progress" and self.saved.statisticsSortMode ~= "name" then
        self.saved.statisticsSortMode = DEFAULTS.statisticsSortMode
    end
    if not self:IsValidStatisticsPage(self.saved.statisticsPage) then
        self.saved.statisticsPage = DEFAULTS.statisticsPage
    end
    if tonumber(self.saved.statisticsCompletionPage) ~= 1 and tonumber(self.saved.statisticsCompletionPage) ~= 2 and tonumber(self.saved.statisticsCompletionPage) ~= 3 then
        self.saved.statisticsCompletionPage = DEFAULTS.statisticsCompletionPage
    else
        self.saved.statisticsCompletionPage = tonumber(self.saved.statisticsCompletionPage)
    end
    if self.saved.statisticsCategorySortMode ~= "all" and self.saved.statisticsCategorySortMode ~= "name"
        and self.saved.statisticsCategorySortMode ~= "asc" and self.saved.statisticsCategorySortMode ~= "desc" then
        self.saved.statisticsCategorySortMode = DEFAULTS.statisticsCategorySortMode
    end
    self.saved.statisticsFocusZoneId = math.max(0, Round(tonumber(self.saved.statisticsFocusZoneId) or 0))
    self.saved.skyshardGoalPosition = tonumber(self.saved.skyshardGoalPosition) == 2 and 2 or 1
    self.saved.skyshardGoalCustomPosition = self.saved.skyshardGoalCustomPosition == true
    if type(self.saved.skyshardGoalCustomX) ~= "number" or type(self.saved.skyshardGoalCustomY) ~= "number" then
        self.saved.skyshardGoalCustomPosition = false
        self.saved.skyshardGoalCustomX = false
        self.saved.skyshardGoalCustomY = false
    end
    if type(self.saved.skyshardGoalCustomWidth) ~= "number" or type(self.saved.skyshardGoalCustomHeight) ~= "number" then
        self.saved.skyshardGoalCustomWidth = false
        self.saved.skyshardGoalCustomHeight = false
    else
        self.saved.skyshardGoalCustomWidth = math.floor(Clamp(self.saved.skyshardGoalCustomWidth, 230, 760) + 0.5)
        self.saved.skyshardGoalCustomHeight = math.floor(Clamp(self.saved.skyshardGoalCustomHeight, 60, 220) + 0.5)
    end
    if not self.saved.skyshardGoalCustomPosition then
        self.saved.skyshardGoalCustomWidth = false
        self.saved.skyshardGoalCustomHeight = false
    end
    if self.saved.progressGoalCategoryType ~= SIDE_QUEST_CATEGORY_KEY
        and self.saved.progressGoalCategoryType ~= CROWN_QUEST_CATEGORY_KEY
        and self.saved.progressGoalCategoryType ~= ZONE_STABLE_MOUNT_CATEGORY_KEY then
        local numericGoalType = tonumber(self.saved.progressGoalCategoryType)
        self.saved.progressGoalCategoryType = numericGoalType or false
    end
    if self.saved.skyshardGoalEnabled == true and not self.saved.progressGoalCategoryType then
        self.saved.progressGoalCategoryType = _G.ZONE_COMPLETION_TYPE_SKYSHARDS
    end
    -- 3.0.6 simplifies Goals to two meaningful modes. Preserve old category
    -- tabs as the new compact category filter during migration.
    if self.saved.goalPlannerMode == "quests" or self.saved.goalPlannerMode == "skyshards" or self.saved.goalPlannerMode == "bosses" then
        self.saved.goalPlannerCategory = self.saved.goalPlannerMode
        self.saved.goalPlannerMode = "recommended"
    elseif self.saved.goalPlannerMode == "lowest" then
        self.saved.goalPlannerMode = "recommended"
    end
    local validGoalMode = false
    for _, value in ipairs(GOAL_PLANNER_MODES) do if self.saved.goalPlannerMode == value then validGoalMode = true break end end
    if not validGoalMode then self.saved.goalPlannerMode = DEFAULTS.goalPlannerMode end
    local goalCategory = self:GetGoalPlannerCategoryDefinition(self.saved.goalPlannerCategory)
    self.saved.goalPlannerCategory = goalCategory.key
    local validRange = false
    for _, value in ipairs(HISTORY_RANGES) do if tonumber(self.saved.historyRangeDays) == value then validRange = true break end end
    if not validRange then self.saved.historyRangeDays = DEFAULTS.historyRangeDays end
    local validHistoryMetric = false
    for _, definition in ipairs(self:GetHistoryMetricDefinitions()) do
        if definition.key == self.saved.historyMetric then validHistoryMetric = true break end
    end
    if not validHistoryMetric then self.saved.historyMetric = DEFAULTS.historyMetric end
    self.saved.historyRetentionDays = Clamp(Round(tonumber(self.saved.historyRetentionDays) or HISTORY_RETENTION_DAYS), 30, 1460)
    if type(self.saved.combatStatsByCharacter) ~= "table" then
        self.saved.combatStatsByCharacter = {}
    end
    if type(self.saved.economyStats) ~= "table" then
        self.saved.economyStats = { trackingVersion = "2.0.10", currencies = {} }
    end
    if type(self.saved.economyStatsByCharacter) ~= "table" then
        self.saved.economyStatsByCharacter = {}
    end
    if type(self.saved.historyByCharacter) ~= "table" then self.saved.historyByCharacter = {} end
    if type(self.saved.milestoneStateByCharacter) ~= "table" then self.saved.milestoneStateByCharacter = {} end

    -- v2.0.10: 2.0.9 did not ignore CURRENCY_CHANGE_REASON_PLAYER_INIT.
    -- Depending on login timing ESO can emit the already-existing wallet balance
    -- as an initialization update, which could falsely inflate "Received". 2.0.9
    -- was a development build, so reset those new economy counters once and start
    -- the reliable ledger from 2.0.10. Current balances are never affected.
    if not self.saved.economyPlayerInit210Migrated then
        self.saved.economyStats = { trackingVersion = "2.0.10", currencies = {} }
        self.saved.economyPlayerInit210Migrated = true
    end

    -- v2.0.3: 2.0.2 could leave the 100%-only quick filter active while users
    -- were testing the new statistics window, which makes every incomplete
    -- world-map label disappear by design. Reset it once on upgrade so the
    -- overview immediately returns to the familiar v1.6 "Alle" view. After
    -- this migration, quick-filter choices behave and persist normally again.
    if not self.saved.mapLabels203Migrated then
        self.saved.quickFilter = "all"
        self.saved.mapLabels203Migrated = true
    end

    -- v1.5.5 expands the old 3-style selector to 10 styles. Preserve the old
    -- "map" choice by migrating it to the new Handwritten style.
    self.saved.fontStyle = self:NormalizeFontStyle(self.saved.fontStyle) or DEFAULTS.fontStyle
    self.saved.questFontStyle = self:NormalizeFontStyle(self.saved.questFontStyle) or DEFAULTS.questFontStyle

    -- 2.6.46 migration: show the preserved historical Economy totals first.
    -- Users can still select any zone afterwards for the zone ledger.
    if self.saved and not self.saved.economyFocusCacheRestore2646 then
        self.saved.economyDetailFocusZoneId = 0
        self.saved.economyFocusCacheRestore2646 = true
    end

    self:ResolveLanguage()
    self:RefreshBindingStrings()
    self:CreateHeaderProgressLabel()
    self:CreateQuestRewardControl()
    self:CreateStatisticsWindow()
    self:CreateSkyshardGoalWidget()
    self:RegisterSettings()
    self:RegisterVanillaQuestRewardColorHooks()

    if not self:RegisterCustomPin() then
        zo_callLater(function()
            if TPM and TPM:RegisterCustomPin() then
                TPM:QueueRefresh(10)
            end
        end, 500)
    end

    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
        TPM:ReleaseOverlayLabels()
        ZO_ClearTable(TPM.symbolicZonePositions)
        TPM.symbolicZonePositionsMapId = 0
        TPM:InvalidateStatisticsData(false)
        TPM:QueueRefresh(80)
    end)

    if WORLD_MAP_SCENE then
        WORLD_MAP_SCENE:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWING then
                TPM.worldMapSceneVisible = true
                if TPM.skyshardGoalWidget then TPM.skyshardGoalWidget:SetHidden(true) end
                TPM:RefreshAllianceTerritoryBorders()
                TPM:QueueRefresh(40)
            elseif newState == SCENE_SHOWN then
                TPM.worldMapSceneVisible = true
                TPM:RefreshAllianceTerritoryBorders()
                -- Do not let a refresh queued during SCENE_SHOWING suppress the
                -- final refresh after ESO has finished showing the map.
                TPM.refreshQueued = false
                TPM:QueueRefresh(20)
            elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
                TPM.worldMapSceneVisible = false
                TPM.refreshQueued = false
                TPM:ReleaseOverlayLabels()
                TPM:HideAllianceTerritoryBorders()
                TPM:HideHeaderProgress()
                TPM:HideQuestRewards()
                -- A journal opened from the world-map button belongs to that
                -- scene and closes with it. A standalone journal opened by
                -- keybind or /tpm stats remains visible when the map closes.
                if not TPM.statisticsOpenedStandalone then
                    TPM:HideStatisticsWindow()
                end
                zo_callLater(function() if TPM then TPM:RefreshSkyshardGoalWidget() end end, 50)
                -- Minimap addons can reuse ZO_WorldMap after the real scene closes.
                TPM:RefreshQuickFilterBar()
            end
        end)

        if WORLD_MAP_SCENE.IsShowing and WORLD_MAP_SCENE:IsShowing() then
            self.worldMapSceneVisible = true
        else
            self.worldMapSceneVisible = false
        end
    end

    if GAMEPAD_WORLD_MAP_SCENE then
        GAMEPAD_WORLD_MAP_SCENE:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWING then
                TPM.gamepadWorldMapSceneVisible = true
                if TPM.skyshardGoalWidget then TPM.skyshardGoalWidget:SetHidden(true) end
                TPM:RefreshAllianceTerritoryBorders()
                TPM:QueueRefresh(40)
            elseif newState == SCENE_SHOWN then
                TPM.gamepadWorldMapSceneVisible = true
                TPM:RefreshAllianceTerritoryBorders()
                TPM.refreshQueued = false
                TPM:QueueRefresh(20)
            elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
                TPM.gamepadWorldMapSceneVisible = false
                TPM.refreshQueued = false
                TPM:ReleaseOverlayLabels()
                TPM:HideAllianceTerritoryBorders()
                TPM:HideHeaderProgress()
                TPM:HideQuestRewards()
                -- A journal opened from the world-map button belongs to that
                -- scene and closes with it. A standalone journal opened by
                -- keybind or /tpm stats remains visible when the map closes.
                if not TPM.statisticsOpenedStandalone then
                    TPM:HideStatisticsWindow()
                end
                zo_callLater(function() if TPM then TPM:RefreshSkyshardGoalWidget() end end, 50)
                -- Minimap addons can reuse ZO_WorldMap after the real scene closes.
                TPM:RefreshQuickFilterBar()
            end
        end)

        if GAMEPAD_WORLD_MAP_SCENE.IsShowing and GAMEPAD_WORLD_MAP_SCENE:IsShowing() then
            self.gamepadWorldMapSceneVisible = true
        else
            self.gamepadWorldMapSceneVisible = false
        end
    end

    if _G.EVENT_PREPARE_FOR_JUMP then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ActivityPrepareForJump", EVENT_PREPARE_FOR_JUMP,
            function(_, zoneName, zoneDescription, loadingTexture, zoneDisplayType)
                TPM:RememberJumpDestination(zoneName, zoneDisplayType, loadingTexture)
            end)
    end

    -- Keep the Skyshard goal synchronized with the same HUD scene lifecycle
    -- used by native trackers. This makes M/ESC hiding immediate, not dependent
    -- on the 1.5s safety refresh timer.
    local function RegisterSkyshardHudScene(scene)
        if scene and type(scene.RegisterCallback) == "function" then
            scene:RegisterCallback("StateChange", function()
                zo_callLater(function() if TPM then TPM:RefreshSkyshardGoalWidget() end end, 0)
            end)
        end
    end
    RegisterSkyshardHudScene(_G.HUD_SCENE)
    RegisterSkyshardHudScene(_G.HUD_UI_SCENE)

    -- React to *every* scene transition, not only the world map. This is the
    -- reliable part for ESC: as soon as the current scene stops being HUD or
    -- HUD-UI, the Skyshard block is hidden. Returning to the HUD restores it.
    if _G.SCENE_MANAGER and type(_G.SCENE_MANAGER.RegisterCallback) == "function" then
        _G.SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
            if TPM and TPM.skyshardGoalWidget and not TPM:IsSkyshardGoalHudSceneVisible() then
                TPM.skyshardGoalWidget:SetHidden(true)
            end
            zo_callLater(function()
                if TPM then
                    TPM:RefreshStandaloneStatisticsSceneVisibility()
                    TPM:RefreshSkyshardGoalWidget()
                end
            end, 0)
        end)
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        -- Ownership and available zone-story data can change between sessions.
        -- Economy tracking is character-scoped from 2.0.15 onward, so this also
        -- ensures the active character ledger is selected immediately after login.
        TPM:InvalidateStatisticsData(true)
        TPM:GetEconomyStats()
        TPM:SyncCurrentEsoPlayedTime()
        TPM:StartOrResumeHistorySession()
        TPM:HandleTrackedActivityActivated()
        TPM:ResumeParticipatingWorldEvent()
        TPM:DiscoverCurrentZoneWorldEventCandidates(true)
        zo_callLater(function() if TPM then TPM:HandleTrackedActivityActivated() end end, 350)
        zo_callLater(function() if TPM then TPM:ResumeParticipatingWorldEvent(); TPM:DiscoverCurrentZoneWorldEventCandidates(true) end end, 500)
        zo_callLater(function() if TPM then TPM:RefreshQuestRewards() end end, 250)
        zo_callLater(function() if TPM then TPM:RefreshSkyshardGoalWidget() end end, 450)
        if TPM.statisticsWindow and not TPM.statisticsWindow:IsHidden()
            and TPM.saved and TPM.saved.statisticsPage == "economy" then
            TPM:RefreshEconomyStatisticsPage()
        end
        TPM:QueueRefresh(100)
    end)

    if _G.EVENT_PLAYER_DEACTIVATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "HistoryPlayerDeactivated", EVENT_PLAYER_DEACTIVATED, function()
            TPM:CheckpointHistoryOnDeactivated()
        end)
    end

    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "HistoryCheckpoint", HISTORY_CHECKPOINT_MS, function()
        if TPM.saved and TPM.saved.historyEnabled ~= false then
            TPM:CheckpointHistory("periodic", false)
        end
    end)

    if _G.EVENT_TIMED_ACTIVITY_TRACKING_UPDATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "SkyshardTomeTracking", _G.EVENT_TIMED_ACTIVITY_TRACKING_UPDATED, function()
            -- ESO rebuilds/reanchors the native Tome HUD when the tracked Tome
            -- changes. Throw away our cached control and resolve the new native
            -- tracker twice: once immediately, once after its layout settles.
            TPM.skyshardGoalTomesAnchor = nil
            TPM.skyshardGoalLastAnchorScan = 0
            zo_callLater(function()
                if TPM then TPM:UpdateSkyshardGoalAnchor(true); TPM:RefreshSkyshardGoalWidget() end
            end, 50)
            zo_callLater(function()
                if TPM then TPM:UpdateSkyshardGoalAnchor(true); TPM:RefreshSkyshardGoalWidget() end
            end, 450)
        end)
    end

    if _G.EVENT_ZONE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "SkyshardGoalZoneChanged", _G.EVENT_ZONE_CHANGED, function()
            zo_callLater(function() if TPM then TPM:RefreshSkyshardGoalWidget() end end, 100)
        end)
    end
    if _G.EVENT_SKYSHARD_GAINED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "SkyshardGoalGained", _G.EVENT_SKYSHARD_GAINED, function()
            TPM:InvalidateStatisticsData(false)
            zo_callLater(function() if TPM then TPM:RefreshSkyshardGoalWidget() end end, 100)
        end)
    end
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "SkyshardGoalHudRefresh", 1500, function()
        if TPM and TPM.saved and TPM.saved.skyshardGoalEnabled == true then
            TPM:RefreshSkyshardGoalWidget()
        end
    end)

    if EVENT_GLOBAL_MOUSE_UP then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "GlobalMouseUp", EVENT_GLOBAL_MOUSE_UP, function(_, button)
            if button == MOUSE_BUTTON_INDEX_LEFT then
                if TPM.questRewardResizing then
                    TPM:StopResizingQuestRewardWindow()
                end
                if TPM.questRewardMoving then
                    TPM:StopMovingQuestRewardWindow()
                end
                if TPM.statisticsWindowMoving then
                    TPM:StopMovingStatisticsWindow()
                end
            end
        end)
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "QuestFocus", EVENT_QUEST_SHOW_JOURNAL_ENTRY, function()
        TPM:QueueRefresh(30)
        zo_callLater(function() if TPM then TPM:RefreshQuestRewards() end end, 30)
    end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "QuestList", EVENT_QUEST_LIST_UPDATED, function()
        TPM:InvalidateStatisticsData(false)
        TPM:QueueRefresh(50)
        zo_callLater(function() if TPM then TPM:RefreshVanillaQuestRewardColors() end end, 20)
    end)
    if FOCUSED_QUEST_TRACKER and FOCUSED_QUEST_TRACKER.RegisterCallback then
        FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerAssistStateChanged", function()
            TPM:QueueRefresh(30)
            zo_callLater(function() if TPM then TPM:RefreshQuestRewards() end end, 30)
        end)
    end

    -- Keep the embedded reward block synchronized with ESO's tracker layout.
    -- 500 ms is intentionally lightweight and also covers UI rebuilds where no
    -- assist-state callback fires (reloadui, tracker collapse/expand, zone load).
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "FocusedRewardPanel", 500, function()
        if TPM and TPM.saved and TPM.saved.showQuestRewards
            and TPM:IsFullWorldMapSceneVisible() then
            TPM:RefreshQuestRewards()
        end
    end)

    -- Lightweight live updates for the v2 statistics journal. Event names are
    -- guarded so the same build stays compatible across API 101050/101051.
    local function RegisterCompletionRefreshEvent(suffix, eventCode)
        if not eventCode then return end
        local namespace = ADDON_NAME .. "Progress" .. suffix
        EVENT_MANAGER:RegisterForEvent(namespace, eventCode, function()
            TPM:InvalidateStatisticsData(false)
            if TPM:IsWorldMapVisible() or (TPM.statisticsWindow and not TPM.statisticsWindow:IsHidden()) then
                TPM:QueueRefresh(60)
            end
            TPM:QueueProgressHistoryCheckpoint()
        end)
    end

    -- Collection unlocks are rare events. Refresh page 2 immediately when
    -- ESO changes the account Collections data; no polling is required.
    local function RegisterCollectionRefreshEvent(suffix, eventCode)
        if not eventCode then return end
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "Collections" .. suffix, eventCode, function()
            if TPM.statisticsWindow and not TPM.statisticsWindow:IsHidden()
                and TPM.saved and TPM.saved.statisticsPage == "progress"
                and tonumber(TPM.saved.statisticsCompletionPage) == 2 then
                TPM:RefreshStatisticsWindow()
            end
        end)
    end
    RegisterCollectionRefreshEvent("Collection", _G.EVENT_COLLECTION_UPDATED)
    RegisterCollectionRefreshEvent("Collectible", _G.EVENT_COLLECTIBLE_UPDATED)
    RegisterCollectionRefreshEvent("Collectibles", _G.EVENT_COLLECTIBLES_UPDATED)

    if _G.EVENT_QUEST_COMPLETE_DIALOG then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ActivityQuestRewardCacheDialog", EVENT_QUEST_COMPLETE_DIALOG,
            function(_, journalIndex)
                TPM:CacheQuestCompletionData(journalIndex)
            end)
    end
    if _G.EVENT_QUEST_ADVANCED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ActivityQuestRewardCacheAdvanced", EVENT_QUEST_ADVANCED,
            function(_, journalIndex, questName, isPushed, isComplete)
                if isComplete then TPM:CacheQuestCompletionData(journalIndex, questName) end
            end)
    end
    if _G.EVENT_QUEST_COMPLETE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ActivityQuestComplete", EVENT_QUEST_COMPLETE,
            function(_, questName, level, previousExperience, currentExperience, championPoints, questType, zoneDisplayType)
                TPM:RecordQuestActivity(questName, level, previousExperience, currentExperience, championPoints, questType, zoneDisplayType)
            end)
    end

    RegisterCompletionRefreshEvent("QuestComplete", _G.EVENT_QUEST_COMPLETE)
    RegisterCompletionRefreshEvent("ObjectiveComplete", _G.EVENT_OBJECTIVE_COMPLETED)
    RegisterCompletionRefreshEvent("PoiUpdated", _G.EVENT_POI_UPDATED)
    RegisterCompletionRefreshEvent("LoreBook", _G.EVENT_LORE_BOOK_LEARNED)
    RegisterCompletionRefreshEvent("Achievement", _G.EVENT_ACHIEVEMENT_UPDATED)
    RegisterCompletionRefreshEvent("ZoneStory", _G.EVENT_ZONE_STORY_ACTIVITY_COMPLETED)
    RegisterCompletionRefreshEvent("Skyshard", _G.EVENT_SKYSHARD_GAINED)

    local function RegisterPlayerProgressEvent(suffix, eventCode, filterPlayer)
        if not eventCode then return end
        local namespace = ADDON_NAME .. "PlayerProgress" .. suffix
        EVENT_MANAGER:RegisterForEvent(namespace, eventCode, function()
            if TPM.saved and TPM.saved.historyEnabled ~= false then
                TPM:CheckpointHistory("player_progress", false)
            end
            if TPM.statisticsWindow and not TPM.statisticsWindow:IsHidden() then
                if TPM.saved and TPM.saved.statisticsPage == "history" then
                    TPM:RefreshHistoryStatisticsPage()
                else
                    TPM:RefreshStatisticsPlayerProgress()
                end
            end
        end)
        if filterPlayer and REGISTER_FILTER_UNIT_TAG and EVENT_MANAGER.AddFilterForEvent then
            EVENT_MANAGER:AddFilterForEvent(namespace, eventCode, REGISTER_FILTER_UNIT_TAG, "player")
        end
    end

    RegisterPlayerProgressEvent("XP", _G.EVENT_EXPERIENCE_UPDATE, true)
    RegisterPlayerProgressEvent("Level", _G.EVENT_LEVEL_UPDATE, true)
    RegisterPlayerProgressEvent("CP", _G.EVENT_UNSPENT_CHAMPION_POINTS_CHANGED, false)
    RegisterPlayerProgressEvent("CPGain", _G.EVENT_CHAMPION_POINT_GAINED, false)

    -- Finalize queued dungeons/trials as soon as ESO reports the activity complete.
    -- Manual dungeon entries still use the existing leave-instance fallback.
    if _G.EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ActivityFinderCompleted", EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE,
            function()
                if TPM.activeTrackedActivity and TPM:IsPersistentTrackedActivityKind(TPM.activeTrackedActivity.kind) then
                    local snapshot = TPM:CaptureHistorySnapshot(false)
                    TPM:FinalizeTrackedActivity(snapshot, TPM_Now())
                end
            end)
    end
    if _G.EVENT_BATTLEGROUND_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ActivityBattlegroundCompleted", EVENT_BATTLEGROUND_STATE_CHANGED,
            function(_, previousState, currentState)
                if _G.BATTLEGROUND_STATE_FINISHED and currentState == _G.BATTLEGROUND_STATE_FINISHED
                    and TPM.activeTrackedActivity and TPM.activeTrackedActivity.kind == "battleground" then
                    local snapshot = TPM:CaptureHistorySnapshot(false)
                    TPM:FinalizeTrackedActivity(snapshot, TPM_Now())
                end
            end)
    end

    -- v2.0.7 personal combat statistics. ESO does not expose complete lifetime
    -- kill/death totals to addons, so these counters are accumulated locally
    -- from this version onward and stored per character.
    if _G.EVENT_BATTLEGROUND_KILL then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CombatStatsBG", EVENT_BATTLEGROUND_KILL,
            function(_, killedCharacterName, killedDisplayName, killedAlliance, killingCharacterName, killingDisplayName)
                TPM:RecordPvPResult(killingDisplayName, killedDisplayName, "bg", killingCharacterName, killedCharacterName)
            end)
    end

    if _G.EVENT_PVP_KILL_FEED_DEATH then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CombatStatsPvPFeed", EVENT_PVP_KILL_FEED_DEATH,
            function(_, killLocation, killerDisplayName, killerCharacterName, killerAlliance, killerRank,
                victimDisplayName, victimCharacterName, victimAlliance, victimRank, isKillLocation)
                -- Battlegrounds have their own server-backed kill event and should
                -- not be counted a second time through the generic PvP feed.
                if TPM:IsCurrentBattlegroundActive() then return end
                if TPM:IsDuplicatePvPKillFeed(killerDisplayName, victimDisplayName, isKillLocation) then return end
                TPM:RecordPvPResult(killerDisplayName, victimDisplayName, "pvp", killerCharacterName, victimCharacterName)
            end)
    end

    if _G.EVENT_RETICLE_TARGET_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "KillLogReticle", EVENT_RETICLE_TARGET_CHANGED, function()
            TPM:CaptureReticlePveTarget()
        end)
        TPM:CaptureReticlePveTarget()
    end

    if _G.EVENT_COMBAT_EVENT then
        -- 3.4.7 PvE kill tracking:
        -- Count NPC deaths caused by the player, their pet/companion OR a group
        -- member. This makes group dungeons reflect the enemies the party actually
        -- defeats instead of only the rare final killing blows credited to you.
        local function OnPveNpcDeath(_, result, isError, abilityName, abilityId, abilityActionSlotType,
            sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log,
            sourceUnitId, targetUnitId)
            if TPM:IsInPvPEnvironment() then return end

            local isXpDeathResult = _G.ACTION_RESULT_DIED_XP ~= nil and result == _G.ACTION_RESULT_DIED_XP
            local numericTargetId = tonumber(targetUnitId) or 0
            local recentTarget = TPM:GetRecentPlayerPveCombatTarget(numericTargetId, targetName)

            if isXpDeathResult then
                -- ESO commonly blanks targetName on DIED_XP when somebody else
                -- lands the final hit. targetUnitId is often still available,
                -- so promote an already pending row before resolving the name.
                TPM:MarkPendingPveKillXpResult(targetName, numericTargetId)
            end

            local cleanTargetName = select(1, TPM:NormalizeCombatUnitName(targetName))
            if cleanTargetName == "" and type(recentTarget) == "table" then
                cleanTargetName = tostring(recentTarget.name or "")
            end

            -- If ESO still withholds the name, do not silently drop a confirmed
            -- XP death. Show an explicit Unknown Enemy row instead so the combat
            -- log reflects every death participation the API actually reports.
            if cleanTargetName == "" and isXpDeathResult then
                cleanTargetName = TPM:L("HISTORY_UNKNOWN_ENEMY")
            end
            if cleanTargetName == "" then return end

            -- NPC/mob/animal targets normally use COMBAT_UNIT_TYPE_NONE. On
            -- privacy-limited death events ESO can blank unit metadata; DIED_XP
            -- plus a recently player-hit target is still valid PvE evidence.
            local targetLooksPve = _G.COMBAT_UNIT_TYPE_NONE == nil
                or targetType == _G.COMBAT_UNIT_TYPE_NONE
                or isXpDeathResult
                or recentTarget ~= nil
            if not targetLooksPve then return end

            local personalSource = sourceType == _G.COMBAT_UNIT_TYPE_PLAYER
                or sourceType == _G.COMBAT_UNIT_TYPE_PLAYER_PET
                or (_G.COMBAT_UNIT_TYPE_PLAYER_COMPANION ~= nil and sourceType == _G.COMBAT_UNIT_TYPE_PLAYER_COMPANION)
            local groupSource = sourceType == _G.COMBAT_UNIT_TYPE_GROUP
            local participated = personalSource or groupSource or isXpDeathResult or recentTarget ~= nil
            if not participated then return end

            -- Death/XP at a currently active World Event is strong participation
            -- evidence. The helper can now discover an already-active Dolmen by
            -- its live POI instance id even if activation happened earlier.
            TPM:MarkNearbyWorldEventParticipationEvidence(isXpDeathResult and "death_xp" or "combat")

            -- Log every death participation ESO exposes, not just kills where
            -- the player dealt the final blow. This covers public-event mobs
            -- killed by another player after we damaged them, and grouped kills.
            local kind = TPM:GetPveKillActivityKind(cleanTargetName)
            if type(recentTarget) == "table" then
                if recentTarget.livestock or recentTarget.critter then kind = "killAnimal" end
                if _G.MONSTER_DIFFICULTY_DEADLY ~= nil and recentTarget.difficulty == _G.MONSTER_DIFFICULTY_DEADLY then kind = "killBoss" end
            end
            local difficulty = (type(recentTarget) == "table" and recentTarget.difficulty) or TPM:GetPveKillDifficulty(cleanTargetName, kind)
            TPM:QueuePveKillActivity(cleanTargetName, kind, isXpDeathResult, numericTargetId, difficulty, isXpDeathResult)

            if numericTargetId > 0 then
                local deathKey = "pve_npc_death|" .. tostring(numericTargetId)
                if TPM:IsDuplicateCombatCounterEvent(deathKey, 1800) then return end
            end
            TPM:IncrementPlayerCombatStat("npcKills", 1)
            TPM:RecordWorldEventPveKill(kind)
        end

        -- Cache NPCs affected by the player/pet/companion. ESO can blank
        -- targetName on the later DIED_XP event if another player lands the
        -- killing blow; targetUnitId lets us recover the name from this cache.
        local function OnPlayerPveCombatTarget(_, result, isError, abilityName, abilityId, abilityActionSlotType,
            sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log,
            sourceUnitId, targetUnitId)
            if TPM:IsInPvPEnvironment() then return end
            if not targetName or targetName == "" then return end
            if _G.COMBAT_UNIT_TYPE_NONE ~= nil and targetType ~= _G.COMBAT_UNIT_TYPE_NONE then return end
            TPM:RememberPlayerPveCombatTarget(targetName, targetUnitId, targetType)
        end

        local function RegisterPlayerTargetSource(suffix, combatUnitType)
            if type(combatUnitType) ~= "number" then return end
            local namespace = ADDON_NAME .. "CombatTargetCache" .. suffix
            EVENT_MANAGER:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, OnPlayerPveCombatTarget)
            if EVENT_MANAGER.AddFilterForEvent and _G.REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE then
                EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, combatUnitType)
            end
        end
        RegisterPlayerTargetSource("Player", _G.COMBAT_UNIT_TYPE_PLAYER)
        RegisterPlayerTargetSource("Pet", _G.COMBAT_UNIT_TYPE_PLAYER_PET)
        RegisterPlayerTargetSource("Companion", _G.COMBAT_UNIT_TYPE_PLAYER_COMPANION)

        local registeredDeathResult = false
        local function RegisterPveDeathResult(suffix, resultCode)
            if type(resultCode) ~= "number" then return end
            local namespace = ADDON_NAME .. "CombatStatsPvE" .. suffix
            EVENT_MANAGER:RegisterForEvent(namespace, EVENT_COMBAT_EVENT, OnPveNpcDeath)
            if EVENT_MANAGER.AddFilterForEvent and _G.REGISTER_FILTER_COMBAT_RESULT then
                EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, resultCode)
            end
            registeredDeathResult = true
        end

        -- DIED / DIED_XP represent the actual NPC death and are much more useful
        -- in group content than ACTION_RESULT_KILLING_BLOW.
        RegisterPveDeathResult("Died", _G.ACTION_RESULT_DIED)
        RegisterPveDeathResult("DiedXP", _G.ACTION_RESULT_DIED_XP)

        -- Compatibility fallback for an API variant without the death results.
        if not registeredDeathResult then
            RegisterPveDeathResult("KillingBlow", _G.ACTION_RESULT_KILLING_BLOW)
        end
    end


    -- 2.6.2 World Events. PARTICIPATION_BEGIN remains the strongest signal,
    -- but activation is now kept as a candidate so classic Dark Anchors can be
    -- promoted by local combat/XP/Gold evidence when that callback is missing.
    if _G.EVENT_WORLD_EVENT_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "WorldEventActivated", EVENT_WORLD_EVENT_ACTIVATED,
            function(_, worldEventInstanceId)
                TPM:ObserveWorldEventActivation(worldEventInstanceId)
            end)
    end
    if _G.EVENT_WORLD_EVENT_PARTICIPATION_BEGIN then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "WorldEventParticipationBegin", EVENT_WORLD_EVENT_PARTICIPATION_BEGIN,
            function(_, worldEventInstanceId, stepDefId)
                TPM:BeginWorldEventParticipation(worldEventInstanceId, stepDefId)
            end)
    end
    if _G.EVENT_WORLD_EVENT_PARTICIPATION_END then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "WorldEventParticipationEnd", EVENT_WORLD_EVENT_PARTICIPATION_END,
            function(_, worldEventInstanceId)
                TPM:EndWorldEventParticipation(worldEventInstanceId)
            end)
    end
    if _G.EVENT_WORLD_EVENT_STEP_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "WorldEventStepChanged", EVENT_WORLD_EVENT_STEP_CHANGED,
            function(_, worldEventInstanceId, newStepDefId)
                TPM:UpdateWorldEventTrackerMetadata(worldEventInstanceId, newStepDefId)
            end)
    end
    if _G.EVENT_WORLD_EVENT_ACTIVE_LOCATION_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "WorldEventLocationChanged", EVENT_WORLD_EVENT_ACTIVE_LOCATION_CHANGED,
            function(_, worldEventInstanceId)
                TPM:ObserveWorldEventActivation(worldEventInstanceId)
                TPM:UpdateWorldEventTrackerMetadata(worldEventInstanceId)
            end)
    end
    if _G.EVENT_WORLD_EVENT_DEACTIVATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "WorldEventDeactivated", EVENT_WORLD_EVENT_DEACTIVATED,
            function(_, worldEventInstanceId)
                TPM:DeactivateWorldEvent(worldEventInstanceId)
            end)
    end

    if _G.EVENT_UNIT_DEATH_STATE_CHANGED then
        local namespace = ADDON_NAME .. "CombatStatsPlayerDeath"
        EVENT_MANAGER:RegisterForEvent(namespace, EVENT_UNIT_DEATH_STATE_CHANGED, function(_, unitTag, isDead)
            if unitTag == "player" and isDead and not TPM:IsInPvPEnvironment() and not TPM:IsDuplicateCombatCounterEvent("pve_player_death", 2500) then
                TPM:MarkNearbyWorldEventParticipationEvidence("player_death")
                TPM:IncrementPlayerCombatStat("pveDeaths", 1)
                TPM:RecordWorldEventPveDeath()
            end
        end)
        if EVENT_MANAGER.AddFilterForEvent and _G.REGISTER_FILTER_UNIT_TAG then EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player") end
    end

    if _G.EVENT_UNIT_DEATH_STATE_CHANGED then
        local function OnBossDeath(_, unitTag, isDead)
            if isDead then TPM:RecordBossDefeat(unitTag) end
        end
        if EVENT_MANAGER.AddFilterForEvent and _G.REGISTER_FILTER_UNIT_TAG then
            for bossIndex = 1, 6 do
                local unitTag = "boss" .. tostring(bossIndex)
                local namespace = ADDON_NAME .. "CombatStatsBoss" .. tostring(bossIndex)
                EVENT_MANAGER:RegisterForEvent(namespace, EVENT_UNIT_DEATH_STATE_CHANGED, OnBossDeath)
                EVENT_MANAGER:AddFilterForEvent(namespace, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, unitTag)
            end
        else
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CombatStatsBoss", EVENT_UNIT_DEATH_STATE_CHANGED, OnBossDeath)
        end
    end

    -- v2.0.15 per-character economy tracker. EVENT_CURRENCY_UPDATE provides the
    -- old/new balance and reason. Player initialization and bank transfers are ignored so
    -- moving gold/AP/Tel Var/vouchers between wallet and bank does not inflate
    -- received/spent totals.
    if _G.EVENT_CURRENCY_UPDATE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "EconomyCurrency", EVENT_CURRENCY_UPDATE,
            function(_, currencyType, currencyLocation, newAmount, oldAmount, reason, reasonSupplementaryInfo)
                TPM:RecordTrackedActivityGoldGain(currencyType, currencyLocation, newAmount, oldAmount, reason)
                TPM:RecordEconomyCurrencyChange(currencyType, currencyLocation, newAmount, oldAmount, reason)
                TPM:GetEconomyCurrencyDefinitions()
                if TPM.economyCurrencyByType and TPM.economyCurrencyByType[currencyType]
                    and (not _G.CURRENCY_CHANGE_REASON_PLAYER_INIT or reason ~= _G.CURRENCY_CHANGE_REASON_PLAYER_INIT) then
                    TPM:QueueEconomyHistoryCheckpoint()
                end
            end)
    end

    -- v2.6.22: track how much gold this character has actually lost to the
    -- Justice system (bounty payoff). This event does not represent passive
    -- bounty decay, and the amount is stored only as a Gold spending sub-total.
    if _G.EVENT_JUSTICE_GOLD_REMOVED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "EconomyBountyPaid", EVENT_JUSTICE_GOLD_REMOVED,
            function(_, goldAmount)
                TPM:RecordEconomyBountyPayment(goldAmount)
            end)
    end

    if _G.EVENT_EXPERIENCE_GAIN then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ActivityExperienceGain", EVENT_EXPERIENCE_GAIN,
            function(_, reason, level, previousExperience, currentExperience)
                -- Keep this event for activity totals. Individual kill XP is
                -- matched from EVENT_EXPERIENCE_UPDATE below, which reflects
                -- every actual player XP-state change more reliably.
                TPM:RecordTrackedActivityExperienceGain(reason, level, previousExperience, currentExperience)
                if TPM.saved and TPM.saved.statisticsPage == "history" then TPM:RefreshCombatProgressionBars() end
            end)
    end

    if _G.EVENT_EXPERIENCE_UPDATE then
        -- Seed the baseline before the first kill so the first XP update can be
        -- measured as a real delta instead of being lost.
        if type(GetUnitXP) == "function" then
            local ok, value = pcall(GetUnitXP, "player")
            if ok and type(value) == "number" then TPM.killLogLastPlayerExperience = value end
        end
        if type(GetUnitXPMax) == "function" then
            local ok, value = pcall(GetUnitXPMax, "player")
            if ok and type(value) == "number" then TPM.killLogLastPlayerExperienceMax = value end
        end
        if type(GetUnitLevel) == "function" then
            local ok, value = pcall(GetUnitLevel, "player")
            if ok and type(value) == "number" then TPM.killLogLastPlayerLevel = value end
        end

        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CombatProgressXP", EVENT_EXPERIENCE_UPDATE,
            function(_, unitTag, currentExp, maxExp, reason)
                if unitTag ~= "player" then return end
                TPM:HandlePlayerExperienceUpdate(currentExp, maxExp, reason)
                if TPM.saved and TPM.saved.statisticsPage == "history" then TPM:RefreshCombatProgressionBars() end
            end)
        if EVENT_MANAGER.AddFilterForEvent and _G.REGISTER_FILTER_UNIT_TAG then
            EVENT_MANAGER:AddFilterForEvent(ADDON_NAME .. "CombatProgressXP", EVENT_EXPERIENCE_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
        end
    end
    if _G.EVENT_LEVEL_UPDATE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CombatProgressLevel", EVENT_LEVEL_UPDATE, function(_, unitTag)
            if unitTag == "player" and TPM.saved and TPM.saved.statisticsPage == "history" then TPM:RefreshCombatProgressionBars() end
        end)
    end
    if _G.EVENT_CHAMPION_POINT_UPDATE then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CombatProgressCP", EVENT_CHAMPION_POINT_UPDATE, function(_, unitTag)
            if unitTag == "player" and TPM.saved and TPM.saved.statisticsPage == "history" then TPM:RefreshCombatProgressionBars() end
        end)
    end
    if _G.EVENT_COMPANION_EXPERIENCE_GAIN then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CombatProgressCompanionXP", EVENT_COMPANION_EXPERIENCE_GAIN, function()
            if TPM.saved and TPM.saved.statisticsPage == "history" then TPM:RefreshCombatProgressionBars() end
        end)
    end
    if _G.EVENT_COMPANION_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CombatProgressCompanionOn", EVENT_COMPANION_ACTIVATED, function()
            if TPM.saved and TPM.saved.statisticsPage == "history" then TPM:RefreshCombatProgressionBars() end
        end)
    end
    if _G.EVENT_COMPANION_DEACTIVATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "CombatProgressCompanionOff", EVENT_COMPANION_DEACTIVATED, function()
            if TPM.saved and TPM.saved.statisticsPage == "history" then TPM:RefreshCombatProgressionBars() end
        end)
    end

    if _G.EVENT_SCREEN_RESIZED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "ScreenResized", EVENT_SCREEN_RESIZED, function()
            if TPM.statisticsWindow then TPM:ClampStatisticsWindowToScreen() end
            if TPM.questRewardControl then TPM:ApplyQuestRewardPosition() end
            if TPM.skyshardGoalWidget then TPM:UpdateSkyshardGoalAnchor(true); TPM:RefreshSkyshardGoalWidget() end
        end)
    end

    SLASH_COMMANDS["/tpm"] = function(text) TPM:HandleSlashCommand(text) end
    SLASH_COMMANDS["/tamrielprogress"] = function(text) TPM:HandleSlashCommand(text) end
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= ADDON_NAME then return end
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    TPM:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
