local ADDON_NAME = "TamrielProgressMap"
local DISPLAY_NAME = "Tamriel Progress Map"
local VERSION = "2.0.6"
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
    statisticsSortMode = "progress",
    mapLabels203Migrated = false,
    percentColorBlack204Migrated = false,
    percentColorBlack205Migrated = false,
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
local ESO_GOLD_HEX = "E6C45C"
local SIDE_QUEST_SCAN_MAX_ID = 12000
local STATISTICS_VISIBLE_ZONE_ROWS = 7
local STATISTICS_PERCENT_GRAY_HEX = "B8B4A8"

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
    if string.sub(language, 1, 2) == "de" then
        return "de"
    end
    return "en"
end

function TPM:ResolveLanguage()
    local requested = self.saved and self.saved.language or "auto"
    if requested ~= "de" and requested ~= "en" then
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
        local total = GetNumZoneActivitiesForZoneCompletionType(zoneId, completionType) or 0
        if total > 0 then
            local completed = GetNumCompletedZoneActivitiesForZoneCompletionType(zoneId, completionType) or 0
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

    InitializeTooltip(InformationTooltip, control, LEFT, -8, 0, RIGHT)
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

    local titleTextHeight = self.questRewardTitle:GetTextHeight() or 0
    local titleHeight = Clamp(math.max(30, titleTextHeight + 4), 30, 64)
    self.questRewardTitle:SetHeight(titleHeight)

    local rewardTextHeight = self.questRewardLines:GetTextHeight() or 0
    local desiredHeight = Clamp(titleHeight + rewardTextHeight + 104, 160, 420)
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
    self:CreateQuestRewardControl()
    if not self.questRewardControl then return end

    -- The v2 statistics journal intentionally gets the full map viewport.
    -- Keep the movable quest-reward top-level window from floating above it.
    if self.statisticsWindow and not self.statisticsWindow:IsHidden() then
        self:HideQuestRewards()
        return
    end

    if not self.saved or not self.saved.enabled or not self.saved.showQuestRewards or not self:IsWorldMapVisible() then
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
        zo_callLater(function()
            if TPM and TPM.questRewardControl and not TPM.questRewardControl:IsHidden() then
                TPM:AutoSizeQuestRewardWindow()
            end
        end, 1)
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
        local total = GetNumZoneActivitiesForZoneCompletionType(zoneId, ZONE_COMPLETION_TYPE_PRIORITY_QUESTS) or 0
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
    -- completion percentage shown on the Tamriel map.
    local sideQuestStats = self:GetSideQuestStatistics(progressZoneIds)
    if sideQuestStats then
        stats.categories[#stats.categories + 1] = sideQuestStats
    end

    local sortMode = self.saved and self.saved.statisticsSortMode or "progress"
    table.sort(stats.zones, function(a, b)
        if sortMode == "name" then
            local an = GetZoneNameSortKey(a.name)
            local bn = GetZoneNameSortKey(b.name)
            if an == bn then return a.zoneId < b.zoneId end
            return an < bn
        end
        if a.percent == b.percent then
            local an = GetZoneNameSortKey(a.name)
            local bn = GetZoneNameSortKey(b.name)
            if an == bn then return a.zoneId < b.zoneId end
            return an < bn
        end
        return a.percent < b.percent
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

function TPM:CreateStatisticsSummaryCard(parent, name, x, width)
    local card = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    card:SetDimensions(width, 54)
    card:SetAnchor(TOPLEFT, parent, TOPLEFT, x, 118)
    card:SetCenterColor(0.055, 0.045, 0.03, 0.72)
    card:SetEdgeColor(0.48, 0.39, 0.20, 0.55)
    card:SetEdgeTexture(nil, 1, 1, 1)
    card:SetMouseEnabled(false)

    local title = WINDOW_MANAGER:CreateControl(name .. "Title", card, CT_LABEL)
    title:SetDimensions(width - 12, 18)
    title:SetAnchor(TOPLEFT, card, TOPLEFT, 6, 5)
    title:SetFont("$(MEDIUM_FONT)|18")
    title:SetColor(0.72, 0.68, 0.58, 1)
    title:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    title:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local value = WINDOW_MANAGER:CreateControl(name .. "Value", card, CT_LABEL)
    value:SetDimensions(width - 12, 25)
    value:SetAnchor(TOPLEFT, card, TOPLEFT, 6, 23)
    value:SetFont("$(BOLD_FONT)|21")
    value:SetColor(0.95, 0.82, 0.36, 1)
    value:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    value:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    return { control = card, title = title, value = value }
end

function TPM:CreateStatisticsCategoryRow(parent, index)
    local column = index <= 7 and 1 or 2
    local rowIndex = column == 1 and index or (index - 7)
    local x = column == 1 and 22 or 508
    local y = 255 + ((rowIndex - 1) * 25)

    local row = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatsCategory" .. tostring(index), parent, CT_CONTROL)
    row:SetDimensions(455, 22)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    row:SetMouseEnabled(false)

    local label = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    label:SetDimensions(178, 22)
    label:SetAnchor(LEFT, row, LEFT, 0, 0)
    label:SetFont("$(MEDIUM_FONT)|18")
    label:SetColor(0.92, 0.89, 0.80, 1)
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local count = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    count:SetDimensions(76, 22)
    count:SetAnchor(LEFT, row, LEFT, 180, 0)
    count:SetFont("$(MEDIUM_FONT)|17")
    count:SetColor(0.72, 0.68, 0.58, 1)
    count:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    count:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local bar = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
    bar:SetDimensions(148, 10)
    bar:SetAnchor(LEFT, row, LEFT, 270, 0)
    bar:SetCenterColor(0.03, 0.025, 0.02, 0.78)
    bar:SetEdgeColor(0.32, 0.27, 0.16, 0.68)
    bar:SetEdgeTexture(nil, 1, 1, 1)

    local fill = WINDOW_MANAGER:CreateControl(nil, bar, CT_BACKDROP)
    fill:SetDimensions(1, 8)
    fill:SetAnchor(LEFT, bar, LEFT, 1, 0)
    fill:SetCenterColor(0.75, 0.60, 0.22, 0.95)
    fill:SetEdgeColor(0, 0, 0, 0)

    local percent = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    percent:SetDimensions(34, 22)
    percent:SetAnchor(RIGHT, row, RIGHT, 0, 0)
    percent:SetFont("$(BOLD_FONT)|17")
    percent:SetColor(0.90, 0.80, 0.48, 1)
    percent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    percent:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    return { control = row, label = label, count = count, bar = bar, fill = fill, percent = percent }
end

function TPM:CreateStatisticsZoneRow(parent, index)
    local row = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatsZoneRow" .. tostring(index), parent, CT_CONTROL)
    row:SetDimensions(910, 30)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, (index - 1) * 31)
    row:SetMouseEnabled(true)

    local bg = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
    bg:SetAnchorFill(row)
    bg:SetCenterColor(0.045, 0.038, 0.028, index % 2 == 0 and 0.52 or 0.34)
    bg:SetEdgeColor(0.30, 0.25, 0.14, 0.18)
    bg:SetEdgeTexture(nil, 1, 1, 1)
    bg:SetMouseEnabled(false)
    row.bg = bg
    row.baseAlpha = index % 2 == 0 and 0.52 or 0.34

    local name = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    name:SetDimensions(380, 30)
    name:SetAnchor(LEFT, row, LEFT, 10, 0)
    name:SetFont("$(MEDIUM_FONT)|19")
    name:SetColor(0.94, 0.92, 0.86, 1)
    name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.nameLabel = name

    local percent = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    percent:SetDimensions(62, 30)
    percent:SetAnchor(LEFT, row, LEFT, 398, 0)
    percent:SetFont("$(BOLD_FONT)|19")
    percent:SetColor(0.72, 0.71, 0.67, 1)
    percent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    percent:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.percentLabel = percent

    local progressBg = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
    progressBg:SetDimensions(160, 10)
    progressBg:SetAnchor(LEFT, row, LEFT, 475, 0)
    progressBg:SetCenterColor(0.025, 0.022, 0.018, 0.85)
    progressBg:SetEdgeColor(0.30, 0.25, 0.14, 0.60)
    progressBg:SetEdgeTexture(nil, 1, 1, 1)
    row.progressBg = progressBg

    local progressFill = WINDOW_MANAGER:CreateControl(nil, progressBg, CT_BACKDROP)
    progressFill:SetDimensions(1, 8)
    progressFill:SetAnchor(LEFT, progressBg, LEFT, 1, 0)
    progressFill:SetCenterColor(0.75, 0.60, 0.22, 0.95)
    progressFill:SetEdgeColor(0, 0, 0, 0)
    row.progressFill = progressFill

    local done = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    done:SetDimensions(105, 30)
    done:SetAnchor(LEFT, row, LEFT, 655, 0)
    done:SetFont("$(MEDIUM_FONT)|18")
    done:SetColor(0.78, 0.76, 0.70, 1)
    done:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    done:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.doneLabel = done

    local open = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    open:SetDimensions(90, 30)
    open:SetAnchor(RIGHT, row, RIGHT, -12, 0)
    open:SetFont("$(MEDIUM_FONT)|18")
    open:SetColor(0.90, 0.72, 0.42, 1)
    open:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    open:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    row.openLabel = open

    row:SetHandler("OnMouseEnter", function(control)
        if control.bg then control.bg:SetCenterColor(0.20, 0.15, 0.065, 0.78) end
    end)
    row:SetHandler("OnMouseExit", function(control)
        if control.bg then control.bg:SetCenterColor(0.045, 0.038, 0.028, control.baseAlpha or 0.34) end
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

function TPM:CreateStatisticsWindow()
    if self.statisticsWindow then return end
    if not ZO_WorldMap or not ZO_WorldMapScroll then return end

    local control = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "StatisticsWindow")
    control:SetDimensions(1000, 750)
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
    backdrop:SetCenterColor(0.025, 0.021, 0.016, 1.00)
    backdrop:SetEdgeColor(0.72, 0.60, 0.29, 1.00)
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Border.dds", 128, 16, 2)
    backdrop:SetInsets(8, 8, -8, -8)
    backdrop:SetMouseEnabled(false)

    local inner = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    inner:SetAnchor(TOPLEFT, control, TOPLEFT, 5, 5)
    inner:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -5, -5)
    inner:SetCenterColor(0.075, 0.061, 0.038, 1.00)
    inner:SetEdgeColor(0.30, 0.24, 0.12, 0.65)
    inner:SetEdgeTexture(nil, 1, 1, 1)
    inner:SetMouseEnabled(false)

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

    local tamriel = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    tamriel:SetDimensions(110, 22)
    tamriel:SetAnchor(TOPLEFT, control, TOPLEFT, 24, 66)
    tamriel:SetFont("$(BOLD_FONT)|19")
    tamriel:SetColor(0.76, 0.72, 0.62, 1)
    tamriel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    tamriel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsTamrielLabel = tamriel

    local overall = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    overall:SetDimensions(110, 58)
    overall:SetAnchor(TOPLEFT, control, TOPLEFT, 24, 82)
    overall:SetFont("$(ANTIQUE_FONT)|48")
    overall:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    overall:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsOverall = overall

    local overallBar = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    overallBar:SetDimensions(820, 14)
    overallBar:SetAnchor(TOPLEFT, control, TOPLEFT, 150, 82)
    overallBar:SetCenterColor(0.025, 0.022, 0.018, 0.90)
    overallBar:SetEdgeColor(0.42, 0.34, 0.17, 0.78)
    overallBar:SetEdgeTexture(nil, 1, 1, 1)
    self.statisticsOverallBar = overallBar

    local overallFill = WINDOW_MANAGER:CreateControl(nil, overallBar, CT_BACKDROP)
    overallFill:SetDimensions(1, 12)
    overallFill:SetAnchor(LEFT, overallBar, LEFT, 1, 0)
    overallFill:SetCenterColor(0.75, 0.60, 0.22, 0.95)
    overallFill:SetEdgeColor(0, 0, 0, 0)
    self.statisticsOverallFill = overallFill

    local subtitle = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    subtitle:SetDimensions(820, 20)
    subtitle:SetAnchor(TOPLEFT, control, TOPLEFT, 150, 98)
    subtitle:SetFont("$(MEDIUM_FONT)|17")
    subtitle:SetColor(0.68, 0.65, 0.58, 1)
    subtitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    subtitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsSubtitle = subtitle

    self.statisticsCards =
    {
        self:CreateStatisticsSummaryCard(control, ADDON_NAME .. "StatsCardZones", 150, 194),
        self:CreateStatisticsSummaryCard(control, ADDON_NAME .. "StatsCardObjectives", 352, 194),
        self:CreateStatisticsSummaryCard(control, ADDON_NAME .. "StatsCardRemaining", 554, 194),
        self:CreateStatisticsSummaryCard(control, ADDON_NAME .. "StatsCardUntouched", 756, 214),
    }

    local playerProgress = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsPlayerProgress", control, CT_BACKDROP)
    playerProgress:SetDimensions(948, 34)
    playerProgress:SetAnchor(TOPLEFT, control, TOPLEFT, 22, 180)
    playerProgress:SetCenterColor(0.045, 0.037, 0.026, 0.78)
    playerProgress:SetEdgeColor(0.38, 0.31, 0.16, 0.48)
    playerProgress:SetEdgeTexture(nil, 1, 1, 1)
    playerProgress:SetMouseEnabled(false)
    self.statisticsPlayerProgress = playerProgress

    local playerTitle = WINDOW_MANAGER:CreateControl(nil, playerProgress, CT_LABEL)
    playerTitle:SetDimensions(155, 32)
    playerTitle:SetAnchor(LEFT, playerProgress, LEFT, 10, 0)
    playerTitle:SetFont("$(BOLD_FONT)|18")
    playerTitle:SetColor(0.90, 0.77, 0.34, 1)
    playerTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    playerTitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsPlayerTitle = playerTitle

    local playerText = WINDOW_MANAGER:CreateControl(nil, playerProgress, CT_LABEL)
    playerText:SetDimensions(345, 32)
    playerText:SetAnchor(LEFT, playerProgress, LEFT, 165, 0)
    playerText:SetFont("$(MEDIUM_FONT)|18")
    playerText:SetColor(0.84, 0.81, 0.73, 1)
    playerText:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    playerText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsPlayerText = playerText

    local playerBar = WINDOW_MANAGER:CreateControl(nil, playerProgress, CT_BACKDROP)
    playerBar:SetDimensions(365, 12)
    playerBar:SetAnchor(LEFT, playerProgress, LEFT, 520, 0)
    playerBar:SetCenterColor(0.022, 0.020, 0.018, 0.92)
    playerBar:SetEdgeColor(0.34, 0.28, 0.16, 0.68)
    playerBar:SetEdgeTexture(nil, 1, 1, 1)
    self.statisticsPlayerBar = playerBar

    local playerFill = WINDOW_MANAGER:CreateControl(nil, playerBar, CT_BACKDROP)
    playerFill:SetDimensions(1, 10)
    playerFill:SetAnchor(LEFT, playerBar, LEFT, 1, 0)
    playerFill:SetCenterColor(0.46, 0.095, 0.065, 0.82)
    playerFill:SetEdgeColor(0, 0, 0, 0)
    self.statisticsPlayerFill = playerFill

    local playerPercent = WINDOW_MANAGER:CreateControl(nil, playerProgress, CT_LABEL)
    playerPercent:SetDimensions(48, 32)
    playerPercent:SetAnchor(RIGHT, playerProgress, RIGHT, -8, 0)
    playerPercent:SetFont("$(BOLD_FONT)|18")
    playerPercent:SetColor(0.72, 0.71, 0.67, 1)
    playerPercent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    playerPercent:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsPlayerPercent = playerPercent

    local categoryTitle = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    categoryTitle:SetDimensions(450, 28)
    categoryTitle:SetAnchor(TOPLEFT, control, TOPLEFT, 22, 220)
    categoryTitle:SetFont("ZoFontWinH4")
    categoryTitle:SetColor(0.90, 0.77, 0.34, 1)
    categoryTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    categoryTitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsCategoryTitle = categoryTitle

    local categoryDivider = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    categoryDivider:SetDimensions(956, 1)
    categoryDivider:SetAnchor(TOPLEFT, control, TOPLEFT, 22, 248)
    categoryDivider:SetCenterColor(0.42, 0.34, 0.17, 0.52)
    categoryDivider:SetEdgeColor(0, 0, 0, 0)

    self.statisticsCategoryRows = {}
    for index = 1, (#COMPLETION_TYPES + 1) do
        self.statisticsCategoryRows[index] = self:CreateStatisticsCategoryRow(control, index)
    end

    local zoneSectionTop = 430
    local zoneTitle = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    zoneTitle:SetDimensions(410, 30)
    zoneTitle:SetAnchor(TOPLEFT, control, TOPLEFT, 22, zoneSectionTop)
    zoneTitle:SetFont("ZoFontWinH4")
    zoneTitle:SetColor(0.90, 0.77, 0.34, 1)
    zoneTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    zoneTitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsZoneTitle = zoneTitle

    local function CreateSortButton(name, rightOffset, sortMode)
        local button = WINDOW_MANAGER:CreateControl(name, control, CT_BUTTON)
        button:SetDimensions(132, 30)
        button:SetAnchor(TOPRIGHT, control, TOPRIGHT, rightOffset, zoneSectionTop)
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

    local header = WINDOW_MANAGER:CreateControl(nil, control, CT_BACKDROP)
    header:SetDimensions(930, 28)
    header:SetAnchor(TOPLEFT, control, TOPLEFT, 22, zoneSectionTop + 34)
    header:SetCenterColor(0.10, 0.075, 0.035, 0.78)
    header:SetEdgeColor(0.50, 0.40, 0.20, 0.52)
    header:SetEdgeTexture(nil, 1, 1, 1)

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
    local listArea = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsListArea", control, CT_CONTROL)
    listArea:SetDimensions(910, STATISTICS_VISIBLE_ZONE_ROWS * 31)
    listArea:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 4)
    listArea:SetMouseEnabled(true)
    listArea:SetHandler("OnMouseWheel", function(_, delta) TPM:ScrollStatistics(delta) end)
    self.statisticsListArea = listArea

    self.statisticsZoneRows = {}
    for slot = 1, STATISTICS_VISIBLE_ZONE_ROWS do
        self.statisticsZoneRows[slot] = self:CreateStatisticsZoneRow(listArea, slot)
    end

    local scrollBar = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "StatisticsScrollBar", control, CT_SLIDER)
    scrollBar:SetDimensions(18, STATISTICS_VISIBLE_ZONE_ROWS * 31)
    scrollBar:SetAnchor(TOPLEFT, listArea, TOPRIGHT, 8, 0)
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
        TPM.statisticsScrollOffset = Clamp(Round(value or 0), 0, TPM:GetStatisticsMaxScrollOffset())
        TPM:RefreshStatisticsZoneRows()
    end)
    self.statisticsScrollBar = scrollBar
    self.statisticsScrollOffset = self.statisticsScrollOffset or 0

    local hint = WINDOW_MANAGER:CreateControl(nil, control, CT_LABEL)
    hint:SetDimensions(930, 20)
    hint:SetAnchor(BOTTOMLEFT, control, BOTTOMLEFT, 22, -10)
    hint:SetFont("$(MEDIUM_FONT)|17")
    hint:SetColor(0.64, 0.61, 0.55, 1)
    hint:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    hint:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.statisticsHint = hint
end

function TPM:GetStatisticsViewportBounds()
    local parent = GuiRoot
    local parentLeft = (parent and parent.GetLeft and parent:GetLeft()) or 0
    local parentTop = (parent and parent.GetTop and parent:GetTop()) or 0
    local parentWidth = (parent and parent.GetWidth and parent:GetWidth()) or 1920
    local parentHeight = (parent and parent.GetHeight and parent:GetHeight()) or 1080
    local width = (self.statisticsWindow and self.statisticsWindow:GetWidth()) or 1000
    local height = (self.statisticsWindow and self.statisticsWindow:GetHeight()) or 750
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
                local percentColor = self:GetStatisticsPercentTextColor(data.percent)
                row.percentLabel:SetText(string.format("|c%s%d%%|r", percentColor, data.percent))
                row.doneLabel:SetText(string.format("%d / %d", data.completed, data.total))
                row.openLabel:SetText(tostring(data.remaining))
                self:SetStatisticsBarPercent(row.progressFill, 158, data.percent)
            else
                row.zoneId = nil
                row.mapId = nil
            end
        end
    end
end

function TPM:ScrollStatistics(delta)
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
    local playerProgress = self:GetPlayerProgressData()
    if self.statisticsPlayerTitle then self.statisticsPlayerTitle:SetText(self:L("STAT_PLAYER_PROGRESS")) end
    if self.statisticsPlayerText then
        local cpText = playerProgress.championPoints > 0 and self:L("STAT_CP", playerProgress.championPoints) or ""
        local text
        if playerProgress.atChampionCap then
            text = self:L("STAT_PLAYER_CP_MAX_LINE", playerProgress.level, playerProgress.championPoints)
        elseif playerProgress.isChampionProgress then
            text = self:L("STAT_PLAYER_CP_LINE", playerProgress.level, playerProgress.championPoints, playerProgress.championPoints + 1)
        else
            text = self:L("STAT_PLAYER_LEVEL_LINE", playerProgress.level, playerProgress.level + 1)
            if cpText ~= "" then text = text .. "  •  " .. cpText end
        end
        self.statisticsPlayerText:SetText(text)
    end
    if self.statisticsPlayerPercent then
        local pc = self:GetStatisticsPercentTextColor(playerProgress.percent)
        self.statisticsPlayerPercent:SetText(string.format("|c%s%d%%|r", pc, playerProgress.percent))
    end
    self:SetStatisticsBarPercent(self.statisticsPlayerFill, 363, playerProgress.percent)
end

function TPM:RefreshStatisticsWindow()
    self:CreateStatisticsWindow()
    local control = self.statisticsWindow
    if not control or control:IsHidden() then return end

    if not self:IsWorldMapVisible() or not self:IsOverviewMap() then
        self:HideStatisticsWindow()
        return
    end

    local stats = self:GetStatisticsData()
    self.statisticsData = stats

    self.statisticsTitle:SetText(self:L("STATISTICS_TITLE"))
    self.statisticsMode:SetText(self:L("STAT_MODE", self.saved.calculationMode == "categories" and self:L("MODE_CATEGORIES") or self:L("MODE_OBJECTIVES")))
    self.statisticsTamrielLabel:SetText(self:L("TAMRIEL_TOTAL"))
    self.statisticsSubtitle:SetText(self:L("STATISTICS_SUBTITLE"))

    local color = self:GetStatisticsPercentTextColor(stats.percent)
    self.statisticsOverall:SetText(string.format("|c%s%d%%|r", color, stats.percent))
    self:SetStatisticsBarPercent(self.statisticsOverallFill, 818, stats.percent)

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

    self:RefreshStatisticsPlayerProgress()

    self.statisticsCategoryTitle:SetText(self:L("STAT_CATEGORIES"))
    for index, categoryControl in ipairs(self.statisticsCategoryRows or {}) do
        local data = stats.categories[index]
        categoryControl.control:SetHidden(data == nil)
        if data then
            categoryControl.label:SetText(data.name)
            categoryControl.count:SetText(string.format("%d/%d", data.completed, data.total))
            categoryControl.percent:SetText(string.format("|c%s%d%%|r", self:GetStatisticsPercentTextColor(data.percent), data.percent))
            self:SetStatisticsBarPercent(categoryControl.fill, 146, data.percent)
        end
    end

    self.statisticsZoneTitle:SetText(self:L("STAT_ZONE_PROGRESS", stats.totalZones))
    self.statisticsHeaderZone:SetText(self:L("STAT_ZONE"))
    self.statisticsHeaderProgress:SetText(self:L("STAT_PROGRESS"))
    self.statisticsHeaderDone:SetText(self:L("STAT_DONE"))
    self.statisticsHeaderOpen:SetText(self:L("STAT_OPEN"))
    self.statisticsHint:SetText(self:L("STAT_CLICK_ZONE"))

    local sortMode = self.saved and self.saved.statisticsSortMode or "progress"
    self.statisticsSortProgress:SetText((sortMode == "progress" and "|cE6C45C" or "") .. self:L("STAT_SORT_PROGRESS") .. (sortMode == "progress" and "|r" or ""))
    self.statisticsSortName:SetText((sortMode == "name" and "|cE6C45C" or "") .. self:L("STAT_SORT_NAME") .. (sortMode == "name" and "|r" or ""))

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
    if not self:IsWorldMapVisible() or not self:IsOverviewMap() then return false end
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
        and self:IsWorldMapVisible()
        and self:IsOverviewMap()
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
end

function TPM:SetLanguage(value, silent)
    if value ~= "auto" and value ~= "de" and value ~= "en" then
        return false
    end
    self.saved.language = value
    self:ResolveLanguage()
    self:InvalidateStatisticsData(false)
    self:RefreshCustomSettingsControls()
    if self.settingsPanel and self.settingsPanel.RefreshPanel then
        self.settingsPanel:RefreshPanel()
    end
    self:RefreshStatisticsWindow()
    self:RefreshQuickFilterBar()
    self:RefreshQuestRewards()
    self:QueueRefresh(10)
    if not silent then
        d(self:L("LANGUAGE_SET", self.locale.LANGUAGE_NAME or self.langCode))
    end
    return true
end

function TPM:HandleSlashCommand(text)
    text = zo_strlower(zo_strtrim(text or ""))

    if text == "toggle" then
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
    elseif text == "refresh" then
        self:QueueRefresh(10)
    elseif text == "stats" or text == "statistics" then
        self:ToggleStatisticsWindow()
    else
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

        control.TPMAutoButton = CreateLanguageButton("auto", 0)
        control.TPMGermanButton = CreateLanguageButton("de", 154)
        control.TPMEnglishButton = CreateLanguageButton("en", 308)
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
    }
    local buttons = { control.TPMAutoButton, control.TPMGermanButton, control.TPMEnglishButton }
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
        end)
    end
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
    self:CreateHeaderProgressLabel()
    self:CreateQuestRewardControl()
    self:CreateStatisticsWindow()
    self:RegisterSettings()

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
            end
        end)

        if GAMEPAD_WORLD_MAP_SCENE.IsShowing and GAMEPAD_WORLD_MAP_SCENE:IsShowing() then
            self.gamepadWorldMapSceneVisible = true
        else
            self.gamepadWorldMapSceneVisible = false
        end
    end

    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
        -- Ownership and available zone-story data can change between sessions.
        TPM:InvalidateStatisticsData(true)
        TPM:QueueRefresh(100)
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
    end)
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "QuestList", EVENT_QUEST_LIST_UPDATED, function()
        TPM:InvalidateStatisticsData(false)
        TPM:QueueRefresh(50)
    end)
    if FOCUSED_QUEST_TRACKER and FOCUSED_QUEST_TRACKER.RegisterCallback then
        FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerAssistStateChanged", function()
            TPM:QueueRefresh(30)
        end)
    end

    -- Lightweight live updates for the v2 statistics journal. Event names are
    -- guarded so the same build stays compatible across API 101050/101051.
    local function RegisterCompletionRefreshEvent(suffix, eventCode)
        if not eventCode then return end
        local namespace = ADDON_NAME .. "Progress" .. suffix
        EVENT_MANAGER:RegisterForEvent(namespace, eventCode, function()
            TPM:InvalidateStatisticsData(false)
            if TPM:IsWorldMapVisible() then TPM:QueueRefresh(60) end
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
            if TPM.statisticsWindow and not TPM.statisticsWindow:IsHidden() then
                TPM:RefreshStatisticsPlayerProgress()
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
