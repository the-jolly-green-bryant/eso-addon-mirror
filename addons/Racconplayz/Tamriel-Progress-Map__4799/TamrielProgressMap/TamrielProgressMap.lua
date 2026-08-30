local ADDON_NAME = "TamrielProgressMap"
local DISPLAY_NAME = "Tamriel Progress Map"
local VERSION = "2.4.57"
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
    combatStatsByCharacter = {},
    economyStats = { trackingVersion = "2.0.10", currencies = {} }, -- legacy account-wide ledger from 2.0.10-2.0.14
    economyStatsByCharacter = {},
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
            entry.crimeTrackingVersion = entry.crimeTrackingVersion or "3.4.24"
        end
    end
    return stats
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
    elseif isWithdrawal and delta > 0 then
        entry.bankWithdrawn = math.max(0, Round((tonumber(entry.bankWithdrawn) or 0) + delta))
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

    if self.statisticsWindow and not self.statisticsWindow:IsHidden() and self.saved then
        if self.saved.statisticsPage == "economy" then
            self:RefreshEconomyStatisticsPage()
        elseif self.saved.statisticsPage == "history" then
            self:RefreshHistoryStatisticsPage()
        end
    end
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
    tracker.lastSeenAt = now
    tracker.participationEndedAt = nil
    tracker.endCounters = nil
    self:MarkDynamicEncounterActivity(id)
end

function TPM:UpdateWorldEventTrackerMetadata(worldEventInstanceId, stepDefId)
    local id = tonumber(worldEventInstanceId) or 0
    if id <= 0 or type(self.worldEventTrackers) ~= "table" then return end
    local tracker = self.worldEventTrackers[id]
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
        npcKillsDelta = math.max(0, (tonumber(endCounters.npcKills) or 0) - (tonumber(startCounters.npcKills) or 0)),
        bossKillsDelta = math.max(0, (tonumber(endCounters.bossKills) or 0) - (tonumber(startCounters.bossKills) or 0)),
        pveDeathsDelta = math.max(0, (tonumber(endCounters.pveDeaths) or 0) - (tonumber(startCounters.pveDeaths) or 0)),
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
    if type(tracker) ~= "table" or not tracker.everParticipated then return end

    local now = TPM_Now()
    -- If participation ended long before the event deactivated, the player
    -- walked away rather than completing it. Do not log that as a completion.
    local participationEndedAt = tonumber(tracker.participationEndedAt) or 0
    if not tracker.participating and participationEndedAt > 0 and now - participationEndedAt > 30 then
        self.worldEventTrackers[id] = nil
        return
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

function TPM:AddActivityLogEntry(entry)
    if type(entry) ~= "table" then return end
    if not TPM_IsMeaningfulDynamicEncounter(entry) then return end
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
        for i = #list, math.max(1, #list - 8), -1 do
            local previous = list[i]
            if type(previous) == "table" and tonumber(previous.worldEventInstanceId) == incomingId then return end
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
    self.statisticsCache = nil
    self.statisticsData = nil
    if rebuildZoneList then
        self.progressZoneIdsCache = nil
        self.sideQuestIndexBuilt = false
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
    -- not to the small info icon inside it. The old icon-relative anchor put
    -- the tooltip directly underneath our high-draw-level reward window, which
    -- is why large parts of "Belohnungsdetails" were hidden behind the panel.
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

    -- First apply the current width to the text controls, then measure. This is
    -- important for wrapped reward names and ESO-generated skill-point text.
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
    -- Release hardening: this top-level window belongs to the real world-map
    -- scene only. Minimap addons may keep ZO_WorldMap visible on the HUD, so
    -- control visibility alone must never reopen the quest reward window.
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
        -- ESO text/icon metrics can settle one frame after SetText(). Re-measure
        -- once more so the last reward line (notably skill points) is not clipped.
        zo_callLater(RecheckQuestRewardAutoSize, 1)
        zo_callLater(RecheckQuestRewardAutoSize, 50)
    end
end


-- v2.0.1 Tamriel Completion Journal / full statistics window -----------------
local function GetZoneNameSortKey(name)
    local key = zo_strlower(name or "")
    -- German umlauts should sort where players expect them in an A-Z list.
    key = key:gsub("ä", "ae"):gsub("ö", "oe"):gsub("ü", "ue"):gsub("ß", "ss")
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

function TPM:BuildSideQuestIndex(progressZoneIds)
    if self.sideQuestIndexBuilt then return end
    self.sideQuestIds = {}

    if type(GetQuestName) ~= "function"
        or type(GetQuestZoneId) ~= "function"
        or type(GetQuestType) ~= "function"
        or type(GetQuestRepeatableType) ~= "function"
        or type(HasCompletedQuest) ~= "function" then
        return
    end

    local priorityQuestIds = self:GetPriorityQuestIdSet(progressZoneIds)
    local notRepeatable = _G.QUEST_REPEAT_NOT_REPEATABLE
    local normalQuestType = _G.QUEST_TYPE_NONE
    if notRepeatable == nil or normalQuestType == nil then return end

    -- Mark the index as built only after all required quest APIs/constants are
    -- available. This avoids permanently caching an empty index during early load.
    self.sideQuestIndexBuilt = true
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
                        self.sideQuestIds[#self.sideQuestIds + 1] = questId
                    end
                end
            end
        end
    end
end

function TPM:GetSideQuestStatistics(progressZoneIds)
    self:BuildSideQuestIndex(progressZoneIds)
    local total = #(self.sideQuestIds or {})
    if total <= 0 then return nil end
    local completed = 0
    for _, questId in ipairs(self.sideQuestIds) do
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

function TPM:GetStatisticsData(forceRefresh)
    if not forceRefresh and self.statisticsCache then
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
    }

    local categoryTotals = {}
    for _, completionType in ipairs(COMPLETION_TYPES) do
        categoryTotals[completionType] = { completed = 0, total = 0 }
    end

    local categoryRatioTotal = 0
    local categoryCount = 0
    local progressZoneIds = self:GetAllProgressZoneIds()
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

    -- 3.1.9 Progress page: categories and zones are always alphabetical in
    -- the addon's selected language. Rebuild after a language switch so the
    -- translated category names are sorted again.
    table.sort(stats.categories, function(a, b)
        local an = zo_strlower(tostring(a.name or ""))
        local bn = zo_strlower(tostring(b.name or ""))
        if an == bn then return tostring(a.completionType) < tostring(b.completionType) end
        return an < bn
    end)
    table.sort(stats.zones, function(a, b)
        local an = GetZoneNameSortKey(a.name)
        local bn = GetZoneNameSortKey(b.name)
        if an == bn then return a.zoneId < b.zoneId end
        return an < bn
    end)

    self.statisticsCache = stats
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

    return { control = card, title = title, value = value, detail = detail, icon = icon, topGlow = topGlow }
end

function TPM:CreateStatisticsCategoryRow(parent, index)
    local column = index <= 8 and 1 or 2
    local rowIndex = column == 1 and index or (index - 8)
    local x = column == 1 and 30 or 518
    local y = 232 + ((rowIndex - 1) * 20)

    local row = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatsCategory" .. tostring(index), parent, CT_CONTROL)
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

    return { control = row, label = label, count = count, bar = bar, fill = fill, percent = percent, icon = icon, bg = rowBg }
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
        if control.mapId and control.mapId > 0 and WORLD_MAP_MANAGER and WORLD_MAP_MANAGER.SetMapById then
            TPM:HideStatisticsWindow()
            WORLD_MAP_MANAGER:SetMapById(control.mapId)
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
    card:SetMouseEnabled(false)

    local topBand = WINDOW_MANAGER:CreateControl(nil, card, CT_BACKDROP)
    topBand:SetDimensions(width - 2, 2)
    topBand:SetAnchor(TOPLEFT, card, TOPLEFT, 1, 1)
    topBand:SetCenterColor(0.95, 0.76, 0.16, 0.82)
    topBand:SetEdgeColor(0, 0, 0, 0)

    local iconBack = WINDOW_MANAGER:CreateControl(nil, card, CT_BACKDROP)
    iconBack:SetDimensions(104, 104)
    iconBack:SetAnchor(LEFT, card, LEFT, 18, 0)
    iconBack:SetCenterColor(0.095, 0.068, 0.018, 0.99)
    iconBack:SetEdgeColor(0.92, 0.72, 0.18, 0.88)
    iconBack:SetEdgeTexture(nil, 1, 1, 1)

    local icon = WINDOW_MANAGER:CreateControl(nil, iconBack, CT_TEXTURE)
    icon:SetDimensions(94, 94)
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

    local function CreateBottomMetric(xPos, valueColor)
        local label = WINDOW_MANAGER:CreateControl(nil, card, CT_LABEL)
        label:SetDimensions(160, 16)
        label:SetAnchor(TOPLEFT, card, TOPLEFT, xPos, 91)
        label:SetFont("$(MEDIUM_FONT)|12")
        label:SetColor(0.76, 0.71, 0.61, 1)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        local value = WINDOW_MANAGER:CreateControl(nil, card, CT_LABEL)
        value:SetDimensions(160, 20)
        value:SetAnchor(TOPLEFT, card, TOPLEFT, xPos, 106)
        value:SetFont("$(BOLD_FONT)|14")
        value:SetColor(valueColor[1], valueColor[2], valueColor[3], 1)
        value:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        value:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        return { label = label, value = value }
    end

    local received = CreateBottomMetric(142, { 0.48, 0.92, 0.40 })
    local spent = CreateBottomMetric(332, { 0.94, 0.52, 0.32 })
    local fence = CreateBottomMetric(522, { 0.86, 0.70, 0.30 })
    local stolen = CreateBottomMetric(712, { 0.96, 0.60, 0.32 })

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
        isGoldCard = true,
    }
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
    note:SetAnchor(TOP, page, TOP, 0, 578)
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
    if not self.statisticsEconomyPage or self.statisticsEconomyPage:IsHidden() then return end
    local stats = self:GetEconomyStats()
    local definitions = self:GetEconomyCurrencyDefinitions()

    self.statisticsEconomyPageTitle:SetText(self:L("STAT_ECONOMY_PAGE_TITLE"))
    self.statisticsEconomyPageSubtitle:SetText(self:L("STAT_ECONOMY_PAGE_SUBTITLE_CHARACTER", stats.characterName or self:L("STAT_PLAYER_UNKNOWN")))
    self.statisticsEconomyTrackingTitle:SetText(self:L("STAT_ECONOMY_TRACKING"))
    self.statisticsEconomyTrackingText:SetText(self:L("STAT_ECONOMY_TRACKING_NOTE", stats.trackingVersion or "2.0.15"))

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
                card.received.value:SetText("+" .. FormatNumber(entry.received or 0))
                card.spent.value:SetText("-" .. FormatNumber(entry.spent or 0))
                card.fence.value:SetText("+" .. FormatNumber(entry.fenceSales or 0))
                card.stolen.value:SetText("+" .. FormatNumber(entry.stolenGold or 0))
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

function TPM:IsValidStatisticsPage(page)
    return page == "progress" or page == "economy" or page == "history"
end

function TPM:UpdateStatisticsPageVisibility(page)
    if not self:IsValidStatisticsPage(page) then page = "progress" end
    if self.statisticsProgressPage then self.statisticsProgressPage:SetHidden(page ~= "progress") end
    if self.statisticsPlayerPage then self.statisticsPlayerPage:SetHidden(true) end
    if self.statisticsEconomyPage then self.statisticsEconomyPage:SetHidden(page ~= "economy") end
    if self.statisticsHistoryPage then self.statisticsHistoryPage:SetHidden(page ~= "history") end
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
        if data and InformationTooltip then
            InitializeTooltip(InformationTooltip, c, LEFT, -8, 0, RIGHT)
            InformationTooltip:AddLine(data.name or "", "ZoFontWinH3")
            InformationTooltip:AddLine(TPM:L("GOAL_TOOLTIP_HEADER", data.percent or 0, data.remaining or 0), "ZoFontGame")
            for _, item in ipairs(data.missing or {}) do
                InformationTooltip:AddLine(TPM:L("GOAL_TOOLTIP_LINE", item.name or "", item.remaining or 0), "ZoFontGame")
            end
        end
    end)
    card:SetHandler("OnMouseExit", function(c)
        c:SetCenterColor(0.045, 0.037, 0.026, 0.96)
        if InformationTooltip then ClearTooltip(InformationTooltip) end
    end)
    card:SetHandler("OnMouseUp", function(c, button, upInside)
        if not upInside or button ~= MOUSE_BUTTON_INDEX_LEFT then return end
        if c.mapId and c.mapId > 0 and WORLD_MAP_MANAGER and WORLD_MAP_MANAGER.SetMapById then
            TPM:HideStatisticsWindow()
            WORLD_MAP_MANAGER:SetMapById(c.mapId)
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
    -- Keep the tooltip width stable, but calculate its height from the localized
    -- title/body text when it is shown. The previous fixed 350x126 layout could
    -- clip or visually overflow at different UI scales and with longer strings.
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

    tip.TPMTitle:SetText(title or "")
    tip.TPMBody:SetText(text)

    -- Re-measure after assigning the localized strings. ESO labels can wrap
    -- differently depending on language, UI scale and font rendering.
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

    tip:ClearAnchors()

    -- Top-level + GuiRoot keeps the help panel above the statistics window.
    -- Anchor above the hovered icon and let ESO clamp it to the screen.
    tip:SetAnchor(BOTTOMRIGHT, control, TOPRIGHT, 0, -6)
    if tip.BringWindowToTop then tip:BringWindowToTop() end
    tip:SetHidden(false)
end

local function TPM_HideLogHelpTooltip()
    local tip = TPM.statisticsLogHelpTooltip
    if tip then tip:SetHidden(true) end
end

local function TPM_CreateHeaderIconButton(parent, width, height, glyph, normalR, normalG, normalB, hoverR, hoverG, hoverB)
    -- Separate backdrop parent keeps the border behind the button glyph.
    local frame = WINDOW_MANAGER:CreateControl(nil, parent, CT_BACKDROP)
    frame:SetDimensions(width, height)
    frame:SetMouseEnabled(false)
    frame:SetCenterColor(0.065, 0.055, 0.042, 0.92)
    frame:SetEdgeColor(0.52, 0.43, 0.18, 0.92)
    frame:SetEdgeTexture(nil, 1, 1, 1)

    local button = WINDOW_MANAGER:CreateControl(nil, frame, CT_BUTTON)
    button:SetAnchorFill()
    button:SetFont("$(BOLD_FONT)|15")
    button:SetText(glyph)
    if button.SetNormalFontColor then button:SetNormalFontColor(normalR, normalG, normalB, 1) end
    if button.SetMouseOverFontColor then button:SetMouseOverFontColor(hoverR, hoverG, hoverB, 1) end
    if button.SetPressedFontColor then button:SetPressedFontColor(0.96, 0.84, 0.30, 1) end
    button.TPMFrame = frame

    button:SetHandler("OnMouseEnter", function(selfButton)
        if selfButton.TPMFrame then
            selfButton.TPMFrame:SetCenterColor(0.12, 0.095, 0.055, 0.98)
            selfButton.TPMFrame:SetEdgeColor(0.92, 0.76, 0.14, 1)
        end
    end)
    button:SetHandler("OnMouseExit", function(selfButton)
        if selfButton.TPMFrame then
            selfButton.TPMFrame:SetCenterColor(0.065, 0.055, 0.042, 0.92)
            selfButton.TPMFrame:SetEdgeColor(0.52, 0.43, 0.18, 0.92)
        end
        TPM_HideLogHelpTooltip()
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

    local combatClear = TPM_CreateHeaderIconButton(session, 24, 20, "✖", 0.88, 0.64, 0.57, 1.00, 0.34, 0.24)
    combatClear.TPMFrame:SetAnchor(TOPLEFT, session, TOPLEFT, 306, 8)
    combatClear:SetHandler("OnClicked", function() self:ClearCombatActivityList(true) end)
    combatClear:SetHandler("OnMouseEnter", function(control)
        if control.TPMFrame then
            control.TPMFrame:SetCenterColor(0.16, 0.055, 0.04, 0.98)
            control.TPMFrame:SetEdgeColor(0.98, 0.34, 0.24, 1)
        end
        TPM_ShowLogHelpTooltip(control, self:L("HISTORY_CLEAR_COMBAT_LOG"), self:L("HISTORY_CLEAR_TOOLTIP"))
    end)
    self.statisticsCombatKillLogClearButton = combatClear

    local combatInfo = TPM_CreateHeaderIconButton(session, 24, 20, "ⓘ", 0.82, 0.80, 0.70, 1.00, 0.86, 0.30)
    combatInfo.TPMFrame:SetAnchor(TOPLEFT, session, TOPLEFT, 334, 8)
    combatInfo:SetHandler("OnMouseEnter", function(control)
        if control.TPMFrame then
            control.TPMFrame:SetCenterColor(0.12, 0.095, 0.055, 0.98)
            control.TPMFrame:SetEdgeColor(0.96, 0.84, 0.30, 1)
        end
        TPM_ShowLogHelpTooltip(control, self:L("HISTORY_LOG_INFO_TITLE"), self:L("HISTORY_LOG_INFO_TOOLTIP"))
    end)
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

    local activityClear = TPM_CreateHeaderIconButton(session, 24, 20, "✖", 0.88, 0.64, 0.57, 1.00, 0.34, 0.24)
    activityClear.TPMFrame:SetAnchor(TOPRIGHT, session, TOPRIGHT, -124, 8)
    activityClear:SetHandler("OnClicked", function() self:ClearCombatActivityList(false) end)
    activityClear:SetHandler("OnMouseEnter", function(control)
        if control.TPMFrame then
            control.TPMFrame:SetCenterColor(0.16, 0.055, 0.04, 0.98)
            control.TPMFrame:SetEdgeColor(0.98, 0.34, 0.24, 1)
        end
        TPM_ShowLogHelpTooltip(control, self:L("HISTORY_CLEAR_ACTIVITY_LOG"), self:L("HISTORY_CLEAR_TOOLTIP"))
    end)
    self.statisticsCombatActivityLogClearButton = activityClear

    local activityInfo = TPM_CreateHeaderIconButton(session, 24, 20, "ⓘ", 0.82, 0.80, 0.70, 1.00, 0.86, 0.30)
    activityInfo.TPMFrame:SetAnchor(TOPRIGHT, session, TOPRIGHT, -96, 8)
    activityInfo:SetHandler("OnMouseEnter", function(control)
        if control.TPMFrame then
            control.TPMFrame:SetCenterColor(0.12, 0.095, 0.055, 0.98)
            control.TPMFrame:SetEdgeColor(0.96, 0.84, 0.30, 1)
        end
        TPM_ShowLogHelpTooltip(control, self:L("HISTORY_LOG_INFO_TITLE"), self:L("HISTORY_LOG_INFO_TOOLTIP"))
    end)
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
            title:SetDimensions(rowWidth - 18, 21)
            title:SetAnchor(TOPLEFT, row, TOPLEFT, 10, 3)
            title:SetFont("$(BOLD_FONT)|13")
            title:SetColor(0.95, 0.94, 0.91, 1)
            title:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            title:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            row.TPMTitle = title

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
    if self.statisticsCombatKillLogInfoButton then self.statisticsCombatKillLogInfoButton:SetText("ⓘ") end
    if self.statisticsCombatActivityLogInfoButton then self.statisticsCombatActivityLogInfoButton:SetText("ⓘ") end
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
    if not ZO_WorldMap or not ZO_WorldMapScroll then return end

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
        control:SetAnchor(CENTER, ZO_WorldMapScroll, CENTER, 0, 8)
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
    overall:SetDimensions(118, 58)
    overall:SetAnchor(TOPLEFT, control, TOPLEFT, 33, 107)
    overall:SetFont("$(ANTIQUE_FONT)|42")
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
    self.statisticsSubtitle = subtitle

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

    local categoryDivider = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_BACKDROP)
    categoryDivider:SetDimensions(956, 1)
    categoryDivider:SetAnchor(TOPLEFT, control, TOPLEFT, 22, 227)
    categoryDivider:SetCenterColor(0.42, 0.34, 0.17, 0.52)
    categoryDivider:SetEdgeColor(0, 0, 0, 0)
    self.statisticsCategoryDivider = categoryDivider

    local categoryDiamond = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_LABEL)
    categoryDiamond:SetDimensions(20, 20)
    categoryDiamond:SetAnchor(CENTER, categoryDivider, CENTER, 0, 0)
    categoryDiamond:SetFont("$(BOLD_FONT)|14")
    categoryDiamond:SetText("◆")
    categoryDiamond:SetColor(0.80, 0.62, 0.22, 0.78)
    categoryDiamond:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    categoryDiamond:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local categoryPanelLeft = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_BACKDROP)
    categoryPanelLeft:SetDimensions(456, 164)
    categoryPanelLeft:SetAnchor(TOPLEFT, control, TOPLEFT, 22, 230)
    categoryPanelLeft:SetCenterColor(0.022, 0.020, 0.016, 0.64)
    categoryPanelLeft:SetEdgeColor(0.34, 0.27, 0.12, 0.58)
    categoryPanelLeft:SetEdgeTexture(nil, 1, 1, 1)
    categoryPanelLeft:SetMouseEnabled(false)
    self.statisticsCategoryPanelLeft = categoryPanelLeft

    local categoryPanelRight = WINDOW_MANAGER:CreateControl(nil, progressPage, CT_BACKDROP)
    categoryPanelRight:SetDimensions(456, 164)
    categoryPanelRight:SetAnchor(TOPLEFT, control, TOPLEFT, 510, 230)
    categoryPanelRight:SetCenterColor(0.022, 0.020, 0.016, 0.64)
    categoryPanelRight:SetEdgeColor(0.34, 0.27, 0.12, 0.58)
    categoryPanelRight:SetEdgeTexture(nil, 1, 1, 1)
    categoryPanelRight:SetMouseEnabled(false)
    self.statisticsCategoryPanelRight = categoryPanelRight

    self.statisticsCategoryRows = {}
    for index = 1, (#COMPLETION_TYPES + 2) do
        self.statisticsCategoryRows[index] = self:CreateStatisticsCategoryRow(progressPage, index)
    end

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

    self.statisticsProgressTab = CreatePageTab(ADDON_NAME .. "StatsTabProgress", 42, "progress", 292)
    self.statisticsPlayerTab = nil
    self.statisticsEconomyTab = CreatePageTab(ADDON_NAME .. "StatsTabEconomy", 354, "economy", 292)
    self.statisticsHistoryTab = CreatePageTab(ADDON_NAME .. "StatsTabHistory", 666, "history", 292)
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
    if ZO_WorldMapScroll then
        control:SetAnchor(CENTER, ZO_WorldMapScroll, CENTER, 0, 8)
    else
        control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
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

    if not self:IsFullWorldMapSceneVisible() then
        self:HideStatisticsWindow()
        return
    end

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
    end

    self:SetProgressStatisticsControlsHidden(false)
    local stats = self:GetStatisticsData()
    self.statisticsData = stats

    self.statisticsTitle:SetText(self:L("STATISTICS_TITLE"))
    self.statisticsMode:SetText(self:L("STAT_MODE", self.saved.calculationMode == "categories" and self:L("MODE_CATEGORIES") or self:L("MODE_OBJECTIVES")))
    self.statisticsTamrielLabel:SetText(self:L("TAMRIEL_TOTAL"))
    self.statisticsSubtitle:SetText(self:L("STATISTICS_SUBTITLE"))

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
        local todayPlayed = self:GetPlaytimePeriodTotal(1)
        self.statisticsPlaytimeCard.title:SetText(self:L("STAT_CHARACTER_PLAY_TIME"))
        self.statisticsPlaytimeCard.value:SetText(TPM_FormatDuration(totalPlayed or 0))
        self.statisticsPlaytimeCard.detail:SetText(self:L("STAT_CHARACTER_PLAY_TIME_TODAY", TPM_FormatDuration(todayPlayed or 0)))
    end

    self:RefreshStatisticsPlayerProgress()

    self.statisticsCategoryTitle:SetText(self:L("STAT_CATEGORIES"))
    for index, categoryControl in ipairs(self.statisticsCategoryRows or {}) do
        local data = stats.categories[index]
        categoryControl.control:SetHidden(data == nil)
        if data then
            categoryControl.label:SetText(data.name)
            categoryControl.count:SetText(data.countText or string.format("%d/%d", data.completed, data.total))
            categoryControl.percent:SetText(string.format("|c%s%d%%|r", self:GetStatisticsPercentTextColor(data.percent), data.percent))
            self:SetStatisticsBarPercent(categoryControl.fill, 96, data.percent)
            if categoryControl.icon then
                local iconTexture = STATISTICS_CATEGORY_ICON_TEXTURES[data.completionType] or "TamrielProgressMap/art/cat_quests.dds"
                categoryControl.icon:SetTexture(iconTexture)
                local ir, ig, ib = self:GetStatisticsProgressColor(data.percent)
                categoryControl.icon:SetColor(ir, ig, ib, 0.96)
            end
            if data.tooltipText then
                local tooltipName = data.name
                local tooltipText = data.tooltipText
                categoryControl.control:SetMouseEnabled(true)
                categoryControl.control:SetHandler("OnMouseEnter", function(row)
                    InitializeTooltip(InformationTooltip, row, LEFT, -8, 0, RIGHT)
                    InformationTooltip:AddLine(tooltipName, "ZoFontWinH3")
                    InformationTooltip:AddLine(tooltipText, "ZoFontGame")
                end)
                categoryControl.control:SetHandler("OnMouseExit", function() ClearTooltip(InformationTooltip) end)
            else
                categoryControl.control:SetMouseEnabled(false)
                categoryControl.control:SetHandler("OnMouseEnter", nil)
                categoryControl.control:SetHandler("OnMouseExit", nil)
            end
        end
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

function TPM:ShowStatisticsWindow()
    if not self:IsFullWorldMapSceneVisible() then return false end
    self:CreateStatisticsWindow()
    if not self.statisticsWindow then return false end
    self.statisticsWindow:SetHidden(false)
    self:ClampStatisticsWindowToScreen()
    self:HideQuestRewards()
    -- Always take a fresh snapshot when the journal is opened. While it stays
    -- open, completion events invalidate the cache as needed.
    self:InvalidateStatisticsData(false)
    self:RefreshStatisticsWindow()
    self:RefreshQuickFilterBar()
    self:QueueRefresh(20)
    return true
end

function TPM:HideStatisticsWindow()
    if self.statisticsWindowMoving then
        self:StopMovingStatisticsWindow()
    end
    if self.statisticsWindow then
        self.statisticsWindow:SetHidden(true)
    end
    self:RefreshQuickFilterBar()
    if self:IsWorldMapVisible() then
        self:RefreshQuestRewards()
        self:QueueRefresh(20)
    end
end

function TPM:ToggleStatisticsWindow()
    self:CreateStatisticsWindow()
    if not self.statisticsWindow then return end
    if self.statisticsWindow:IsHidden() then
        self:ShowStatisticsWindow()
    else
        self:HideStatisticsWindow()
    end
end

function TPM:ToggleStatisticsFromKeybind()
    if self:IsFullWorldMapSceneVisible() then
        self:ToggleStatisticsWindow()
        return
    end

    if SCENE_MANAGER and SCENE_MANAGER.Show then
        local sceneName = "worldMap"
        if type(IsInGamepadPreferredMode) == "function" and IsInGamepadPreferredMode() then
            sceneName = "gamepad_worldMap"
        end
        SCENE_MANAGER:Show(sceneName)
        if type(zo_callLater) == "function" then
            zo_callLater(function()
                if TPM and TPM:IsFullWorldMapSceneVisible() then TPM:ShowStatisticsWindow() end
            end, 120)
        end
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
        -- ESO's gamepad map places the zone title around the upper centre. Move
        -- TPM's large percentage to the upper-right so both remain readable.
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

    -- Most TPM rendering belongs exclusively to the world map. Avoid rebuilding
    -- pins/labels/journal controls for events that fire while the map is closed.
    if not self:IsWorldMapVisible() then
        self:ReleaseOverlayLabels()
        self:HideHeaderProgress()
        if self.questRewardControl then self:HideQuestRewards() end
        return
    end

    self:ReleaseOverlayLabels()
    self:RefreshHeaderProgress()
    self:RefreshQuestRewards()
    self:RefreshQuickFilterBar()

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
        -- Incremented version allows an already-created string id to be replaced.
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
    self:RefreshQuickFilterBar()
    self:RefreshQuestRewards()
    self:QueueRefresh(10)
    -- Some LAM/map controls rebuild a frame after the language button is used.
    -- Refresh them again after layout settles so no stale DE/EN/RU labels remain.
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            if TPM then
                TPM:RefreshCustomSettingsControls()
                TPM:RefreshStatisticsWindow()
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

            -- LAM resolves tooltip functions only when a standard control is
            -- created. Re-resolve them after TPM's own live language switch.
            if data.tooltip ~= nil then
                local tooltipText = Resolve(data.tooltip) or ""
                data.tooltipText = tooltipText
                if control.button and type(control.button.data) == "table" then
                    control.button.data.tooltipText = tooltipText
                end
            end

            -- LAM's checkbox ON/OFF words follow the ESO client language. TPM
            -- has an independent language selector, so keep these words in the
            -- currently selected TPM language as well.
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

        { type = "header", name = function() return TPM:L("SETTINGS_SECTION_PROGRESS") end, width = "full" },
        {
            type = "custom",
            reference = "TamrielProgressMapCalculationControl",
            refreshFunc = function(control) TPM:SetupCalculationCustomControl(control) end,
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

    self:ResolveLanguage()
    self:RefreshBindingStrings()
    self:CreateHeaderProgressLabel()
    self:CreateQuestRewardControl()
    self:CreateStatisticsWindow()
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
                TPM:QueueRefresh(40)
            elseif newState == SCENE_SHOWN then
                TPM.worldMapSceneVisible = true
                -- Do not let a refresh queued during SCENE_SHOWING suppress the
                -- final refresh after ESO has finished showing the map.
                TPM.refreshQueued = false
                TPM:QueueRefresh(20)
            elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
                TPM.worldMapSceneVisible = false
                TPM.refreshQueued = false
                TPM:ReleaseOverlayLabels()
                TPM:HideHeaderProgress()
                TPM:HideQuestRewards()
                TPM:HideStatisticsWindow()
                -- Explicitly hide full-map controls before minimap addons can
                -- reuse ZO_WorldMap outside the real world-map scene.
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
                TPM:QueueRefresh(40)
            elseif newState == SCENE_SHOWN then
                TPM.gamepadWorldMapSceneVisible = true
                TPM.refreshQueued = false
                TPM:QueueRefresh(20)
            elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
                TPM.gamepadWorldMapSceneVisible = false
                TPM.refreshQueued = false
                TPM:ReleaseOverlayLabels()
                TPM:HideHeaderProgress()
                TPM:HideQuestRewards()
                TPM:HideStatisticsWindow()
                -- Explicitly hide full-map controls before minimap addons can
                -- reuse ZO_WorldMap outside the real world-map scene.
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
        zo_callLater(function() if TPM then TPM:HandleTrackedActivityActivated() end end, 350)
        zo_callLater(function() if TPM then TPM:ResumeParticipatingWorldEvent() end end, 500)
        zo_callLater(function() if TPM then TPM:RefreshQuestRewards() end end, 250)
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
            if TPM:IsWorldMapVisible() then TPM:QueueRefresh(60) end
            TPM:QueueProgressHistoryCheckpoint()
        end)
    end

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
            if isXpDeathResult then
                -- DIED_XP may have a blank targetName; promote the DIED row by
                -- unit id before applying the normal name/source filters.
                TPM:MarkPendingPveKillXpResult(targetName, targetUnitId)
            end
            if not targetName or targetName == "" then return end

            -- ZOS defines COMBAT_UNIT_TYPE_NONE as a unit that is not a player,
            -- group member, pet or target dummy. That is the PvE NPC/mob/animal
            -- bucket we want. COMBAT_UNIT_TYPE_OTHER is another real player and
            -- must never be counted as PvE.
            if _G.COMBAT_UNIT_TYPE_NONE ~= nil and targetType ~= _G.COMBAT_UNIT_TYPE_NONE then return end

            local sourceCounts = sourceType == _G.COMBAT_UNIT_TYPE_PLAYER
                or sourceType == _G.COMBAT_UNIT_TYPE_GROUP
                or sourceType == _G.COMBAT_UNIT_TYPE_PLAYER_PET
                or (_G.COMBAT_UNIT_TYPE_PLAYER_COMPANION ~= nil and sourceType == _G.COMBAT_UNIT_TYPE_PLAYER_COMPANION)
            if not sourceCounts then return end

            local numericTargetId = tonumber(targetUnitId) or 0

            -- Keep the combat counter group-aware, but only add individual log
            -- rows for kills credited to the player/pet/companion. Queue BEFORE
            -- the duplicate counter gate so DIED_XP can still promote the same
            -- pending unit-id row created by DIED.
            local personalSource = sourceType == _G.COMBAT_UNIT_TYPE_PLAYER
                or sourceType == _G.COMBAT_UNIT_TYPE_PLAYER_PET
                or (_G.COMBAT_UNIT_TYPE_PLAYER_COMPANION ~= nil and sourceType == _G.COMBAT_UNIT_TYPE_PLAYER_COMPANION)
            if personalSource then
                local kind = TPM:GetPveKillActivityKind(targetName)
                local difficulty = TPM:GetPveKillDifficulty(targetName, kind)
                local expectsXp = isXpDeathResult
                TPM:QueuePveKillActivity(targetName, kind, expectsXp, numericTargetId, difficulty, isXpDeathResult)
            end

            if numericTargetId > 0 then
                local deathKey = "pve_npc_death|" .. tostring(numericTargetId)
                if TPM:IsDuplicateCombatCounterEvent(deathKey, 1800) then return end
            end

            TPM:IncrementPlayerCombatStat("npcKills", 1)

        end

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


    -- 2.4.48 World Events. Activation is only zone-wide presence; real log
    -- tracking starts exclusively when ESO reports player participation.
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
                TPM:IncrementPlayerCombatStat("pveDeaths", 1)
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
