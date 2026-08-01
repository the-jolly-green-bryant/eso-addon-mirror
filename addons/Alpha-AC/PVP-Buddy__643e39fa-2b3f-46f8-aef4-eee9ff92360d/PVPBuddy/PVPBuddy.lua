local ADDON_NAME = "PVPBuddy"
local UPDATE_NAME = ADDON_NAME .. "_Update"
local SCAN_NAME = ADDON_NAME .. "_Scan"

PVPBuddy = {}
local CHX = PVPBuddy

CHX.version = "0.1.92"
CHX.author = "Alpha AC"
CHX.rows = {}
CHX.entries = {}
CHX.flagStates = {}
CHX.movingObjectives = {}
CHX.killLocations = {}
CHX.queue = {}
CHX.queueTest = false
CHX.bonusTest = false
CHX.testMode = false
CHX.debug = {
    lastError = "",
    lastZone = "",
    lastCampaign = "",
    lastScanCount = 0,
    lastVisibleCount = 0,
    lastScoreTime = "",
    lastScoreAD = 0,
    lastScoreEP = 0,
    lastScoreDC = 0,
    lastLowPopBonus = "",
    lastLowScoreLeader = "",
    lastScoreBonusMode = "",
    lastScrollCountAD = 0,
    lastScrollCountEP = 0,
    lastScrollCountDC = 0,
    lastScrollCountScanned = 0,
    lastScrollCountMode = "",
    lastScrollCapturedCount = 0,
    lastScrollBaseCount = 0,
    lastScrollHeldCount = 0,
    lastScrollKnownTempleCount = 0,
    lastNewBattleCount = 0,
    lastFinishedBattleCount = 0,
    lastResourceIconCount = 0,
    lastScrollIconCount = 0,
    lastFlagArrowCount = 0,
    lastFlagEvent = "",
    lastFlagState = "",
    lastFlagControlEvent = "",
    lastFlagHoldingAlliance = "",
    lastFlagAttackingAlliance = "",
    lastFlagNameAlliance = "",
    lastMovingObjectiveCount = 0,
    lastMovingObjectiveEvent = "",
    lastMovingObjectivePayload = "",
    lastMovingObjectiveScan = "",
    artifactEventExists = false,
    daedricEventExists = false,
    scrollStateEventExists = false,
    killFeedEventExists = false,
    queueEventExists = false,
    queuePositionEventExists = false,
    lastQueueEvent = "",
    lastQueueCampaign = "",
    lastQueueCampaignName = "",
    lastQueuePosition = "",
    lastQueueState = "",
    lastQueueIsGroup = "",
    lastQueueScan = "",
    lastQueueApiMode = "",
    lastQueueBrowserRows = "",
    lastQueueCallbacks = "",
    lastQueueHold = "",
    queueWindowSuppressed = "",
    lastKillLocationCount = 0,
    lastKillFeedEvent = "",
    lastKillFeedPayload = "",
    lastKillFeedRaw = "",
    lastKillFeedArgs = 0,
    lastKillFeedCallCount = 0,
    eventsRegistered = false,
    trackerSceneAvailable = false,
    trackerSceneActive = false,
    trackerSceneError = "",
    campaignSceneName = "",
    campaignKeybindAdded = false,
    campaignKeybindError = "",
}

local AD = ALLIANCE_ALDMERI_DOMINION or 1
local EP = ALLIANCE_EBONHEART_PACT or 2
local DC = ALLIANCE_DAGGERFALL_COVENANT or 3
local NONE = ALLIANCE_NONE or 0
local BG = BGQUERY_LOCAL or 1
local RESOURCE_FOOD = RESOURCETYPE_FOOD or 1
local RESOURCE_ORE = RESOURCETYPE_ORE or 2
local RESOURCE_WOOD = RESOURCETYPE_WOOD or 3

CHX.defaults = {
    enabled = true,
    enableInCyrodiil = true,
    enableInImperialCity = true,
    windowVisible = true,
    locked = false,
    x = 70,
    y = 80,
    scale = 1.0,
    maxRows = 5,
    showScoring = true,
    showScoreBonusIcons = true,
    showScrollCounts = true,
    showSiege = true,
    showGatesAndBridges = true,
    showTestRows = false,
    showKeepResources = true,
    showScrollIcons = true,
    showFlagArrows = true,
    showFlagNameColoring = true,
    flagStateLifetimeSeconds = 90,
    showMovingObjectives = true,
    scanKnownScrollMovement = true,
    movingObjectiveHoldSeconds = 300,
    showKillLocations = true,
    killWindowVisible = true,
    killWindowLocked = false,
    killWindowX = 2200,
    killWindowY = 1200,
    killWindowScale = 1.0,
    maxKillRows = 4,
    queueWindowEnabled = true,
    queueWindowSuppressed = false,
    queueWindowLocked = false,
    queueWindowX = 52,
    queueWindowY = 150,
    queueWindowScale = 1.0,
    rankProgressVisible = true,
    rankProgressLocked = false,
    rankProgressX = 0,
    rankProgressY = 0,
    rankProgressScale = 1.0,
    rankProgressMode = "alliance",
    killLocationHoldSeconds = 180,
    showFinishedBattles = true,
    newBattleFadeSeconds = 30,
    finishedBattleHoldSeconds = 20,
    pvpStatsWasInPvp = false,
    pvpStatsSession = nil,
    pvpStatsLifetime = nil,
    statsPanelWindowVisible = false,
    statsPanelPage = 1,
}

local WINDOW_WIDTH = 322
local STATS_ROW_HEIGHT = 22
local SCORE_HEIGHT = 78
local ROW_HEIGHT = 35
local KILL_WINDOW_WIDTH = 290
local KILL_ROW_HEIGHT = 35
local QUEUE_WINDOW_WIDTH = 228
local QUEUE_WINDOW_HEIGHT = 58
local QUEUE_TITLE_WIDTH = 148
local QUEUE_NUMBER_X = 158
local QUEUE_NUMBER_WIDTH = 60
local ICON_SIZE = 40
local SCORE_ICON_SIZE = 30
local TRACKER_WINDOW_WIDTH = 1580
local TRACKER_WINDOW_HEIGHT = 860
local TRACKER_PAGE_Y = 52
local TRACKER_PAGE_HEIGHT = 798
local FONT_MAIN = "$(CHAT_FONT)|16|soft-shadow-thick"
local FONT_SMALL = "$(CHAT_FONT)|12|thick-outline"
local BORDER_R = 0.5373
local BORDER_G = 0.5176
local BORDER_B = 0.4157
local BORDER_A = 0.72
local ROW_BORDER_A = 0.38
local ESO_FRAME_GOLD_R = 0.5373
local ESO_FRAME_GOLD_G = 0.5176
local ESO_FRAME_GOLD_B = 0.4157
local ESO_FRAME_DARK_R = 0.16
local ESO_FRAME_DARK_G = 0.15
local ESO_FRAME_DARK_B = 0.12


CHX.keepIds = {}
CHX.scrollTempleIds = { 118, 119, 120, 121, 122, 123 }
CHX.pvpStats = CHX.pvpStats or { recentKBs = { count = 0 } }


local function AddKeepId(id)
    CHX.keepIds[#CHX.keepIds + 1] = id
end

for id = 3, 87 do AddKeepId(id) end
for id = 132, 134 do AddKeepId(id) end
for id = 163, 165 do AddKeepId(id) end
AddKeepId(149)
AddKeepId(151)
AddKeepId(152)
for id = 154, 162 do AddKeepId(id) end
for id = 124, 129 do AddKeepId(id) end
for id = 141, 148 do AddKeepId(id) end

local function Print(message)
    d("|c66CCFFPvP Buddy:|r " .. tostring(message))
end

local function SafeCall(label, fn, default, ...)
    if type(fn) ~= "function" then
        return default
    end

    local ok, a, b, c, d = pcall(fn, ...)

    if ok then
        return a, b, c, d
    end

    CHX.debug.lastError = tostring(label or "call") .. ": " .. tostring(a)
    return default
end

local function FormatNumber(value)
    value = tonumber(value) or 0
    value = math.floor(value + 0.5)

    local sign = ""

    if value < 0 then
        sign = "-"
        value = -value
    end

    local text = tostring(value)

    while true do
        local changed
        text, changed = string.gsub(text, "^(-?%d+)(%d%d%d)", "%1,%2")

        if changed == 0 then
            break
        end
    end

    return sign .. text
end

local function FormatTime(seconds)
    seconds = tonumber(seconds) or 0

    if seconds < 0 then seconds = 0 end

    local mins = math.floor(seconds / 60)
    local secs = math.floor(seconds % 60)

    if mins <= 0 then
        return tostring(secs) .. "s"
    end

    if secs < 10 then
        secs = "0" .. tostring(secs)
    end

    return tostring(mins) .. ":" .. tostring(secs)
end

local function GetNow()
    if type(GetTimeStamp) == "function" then
        return GetTimeStamp()
    end

    return 0
end

local function GetDeltaSeconds(startTime)
    local now = GetNow()
    startTime = tonumber(startTime) or now

    if type(GetDiffBetweenTimeStamps) == "function" then
        return GetDiffBetweenTimeStamps(now, startTime)
    end

    return math.max(0, now - startTime)
end

local function GetAllianceShort(alliance)
    if alliance == AD then return "AD" end
    if alliance == EP then return "EP" end
    if alliance == DC then return "DC" end
    return "--"
end

local function GetAllianceColorSafe(alliance)
    if type(GetAllianceColor) == "function" then
        local color = GetAllianceColor(alliance)

        if color and type(color.UnpackRGBA) == "function" then
            return color:UnpackRGBA()
        end
    end

    if alliance == AD then
        return 0.95, 0.80, 0.20, 1
    elseif alliance == EP then
        return 0.90, 0.18, 0.18, 1
    elseif alliance == DC then
        return 0.28, 0.48, 1.00, 1
    end

    return 0.85, 0.85, 0.85, 1
end

local function GetAllianceEmblem(alliance)
    if alliance == AD then return "/esoui/art/ava/ava_hud_emblem_aldmeri.dds" end
    if alliance == EP then return "/esoui/art/ava/ava_hud_emblem_ebonheart.dds" end
    if alliance == DC then return "/esoui/art/ava/ava_hud_emblem_daggerfall.dds" end
    return "/esoui/art/ava/ava_hud_emblem_neutral.dds"
end

local function SetLabelAllianceColor(label, alliance)
    if not label then return end

    label:SetColor(GetAllianceColorSafe(alliance))
end

local function StripControlCodes(text)
    text = tostring(text or "")
    text = string.gsub(text, "%^%a", "")
    text = string.gsub(text, ",..$", "")
    return text
end

local function ShortenKeepName(text)
    text = StripControlCodes(text)
    text = string.gsub(text, "Castle ", "")
    text = string.gsub(text, "Fort ", "")
    text = string.gsub(text, "Keep", "")
    text = string.gsub(text, "Scroll Temple of ", "Temple ")
    text = string.gsub(text, " District", "")
    text = string.gsub(text, "Lumbermill", "Lumber")
    text = string.gsub(text, "Lumber ", "")
    text = string.gsub(text, "Farm ", "")
    text = string.gsub(text, "Mine ", "")
    text = string.gsub(text, "%s+$", "")
    text = string.gsub(text, "^%s+", "")
    return text
end

local function GetKeepTypePriority(keepType)
    if keepType == KEEPTYPE_KEEP then return 1 end
    if keepType == KEEPTYPE_OUTPOST then return 2 end
    if keepType == KEEPTYPE_TOWN then return 3 end
    if keepType == KEEPTYPE_RESOURCE then return 4 end
    if keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT then return 5 end
    if keepType == KEEPTYPE_ARTIFACT_GATE then return 6 end
    if keepType == KEEPTYPE_BRIDGE or keepType == KEEPTYPE_MILEGATE then return 7 end
    return 9
end

local function GetKeepTypeName(keepType)
    if keepType == KEEPTYPE_KEEP then return "Keep" end
    if keepType == KEEPTYPE_OUTPOST then return "Outpost" end
    if keepType == KEEPTYPE_TOWN then return "Town" end
    if keepType == KEEPTYPE_RESOURCE then return "Resource" end
    if keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT then return "District" end
    if keepType == KEEPTYPE_ARTIFACT_GATE then return "Gate" end
    if keepType == KEEPTYPE_BRIDGE then return "Bridge" end
    if keepType == KEEPTYPE_MILEGATE then return "Milegate" end
    return "Objective"
end

local function IsGateOrBridge(keepType)
    return keepType == KEEPTYPE_ARTIFACT_GATE
        or keepType == KEEPTYPE_BRIDGE
        or keepType == KEEPTYPE_MILEGATE
end

local function IsOpenOrImpassablePin(pinType)
    return pinType == MAP_PIN_TYPE_ARTIFACT_GATE_OPEN_ALDMERI_DOMINION
        or pinType == MAP_PIN_TYPE_ARTIFACT_GATE_OPEN_DAGGERFALL_COVENANT
        or pinType == MAP_PIN_TYPE_ARTIFACT_GATE_OPEN_EBONHEART_PACT
        or pinType == MAP_PIN_TYPE_KEEP_BRIDGE_IMPASSABLE
        or pinType == MAP_PIN_TYPE_KEEP_MILEGATE_IMPASSABLE
        or pinType == MAP_PIN_TYPE_KEEP_MILEGATE_CENTER_DESTROYED
end

local function IsInAvAWorldSafe()
    return SafeCall("IsPlayerInAvAWorld", IsPlayerInAvAWorld, false) == true
end

local function IsInImperialCitySafe()
    return SafeCall("IsInImperialCity", IsInImperialCity, false) == true
end

local function IsGameplayHudShowing()
    if type(IsGameCameraUIModeActive) == "function" and IsGameCameraUIModeActive() then
        return false
    end

    if SCENE_MANAGER and type(SCENE_MANAGER.GetCurrentScene) == "function" then
        local scene = SCENE_MANAGER:GetCurrentScene()
        local name = nil

        if scene and type(scene.GetName) == "function" then
            name = scene:GetName()
        end

        if name and name ~= "hud" and name ~= "hudui" and name ~= "ingame" then
            return false
        end
    end

    return true
end


local function IsSupportedPvpStatsZone()
    return IsInAvAWorldSafe() or SafeCall("IsActiveWorldBattleground", IsActiveWorldBattleground, false) == true
end

local EnsureStatsTable
local EnsureAllianceCountTable

local function CreateEmptyPvpStatsSession()
    local now = GetNow()

    return {
        startTime = now,
        combatSeconds = 0,
        combatStartTime = nil,
        inCombat = false,

        kills = 0,
        deaths = 0,
        killingBlows = 0,
        alliancePoints = 0,

        killStreak = 0,
        kbStreak = 0,
        deathStreak = 0,
        bestKillStreak = 0,
        bestKBStreak = 0,
        worstDeathStreak = 0,

        avengeKills = 0,
        revengeKills = 0,

        allianceKills = { [AD] = 0, [EP] = 0, [DC] = 0 },
        allianceDeaths = { [AD] = 0, [EP] = 0, [DC] = 0 },
        allianceKBs = { [AD] = 0, [EP] = 0, [DC] = 0 },

        classKills = {},
        classDeaths = {},
        classKBs = {},

        opponents = {},
        abilities = {},
        deathAbilities = {},
        recentEvents = {},
        recentStatEvents = {},
        targets = {},

        lastKill = "",
        lastDeath = "",
        lastKBAbility = "",
        lastDeathAbility = "",
        biggestHitDone = 0,
        biggestHitTaken = 0,
    }
end

local function EnsurePvpStatsState()
    if not CHX.saved then return nil end

    if type(CHX.saved.pvpStatsSession) ~= "table" then
        CHX.saved.pvpStatsSession = CreateEmptyPvpStatsSession()
    end

    CHX.pvpStats = CHX.pvpStats or {}
    CHX.pvpStats.session = CHX.saved.pvpStatsSession
    CHX.pvpStats.recentKBs = CHX.pvpStats.recentKBs or { count = 0 }
    CHX.pvpStats.playerName = zo_strformat("<<1>>", GetUnitName("player") or "")

    local session = CHX.saved.pvpStatsSession
    session.startTime = tonumber(session.startTime) or GetNow()
    session.combatSeconds = tonumber(session.combatSeconds) or 0
    session.kills = tonumber(session.kills) or 0
    session.deaths = tonumber(session.deaths) or 0
    session.killingBlows = tonumber(session.killingBlows) or 0
    session.alliancePoints = tonumber(session.alliancePoints) or 0
    session.killStreak = tonumber(session.killStreak) or 0
    session.kbStreak = tonumber(session.kbStreak) or 0
    session.deathStreak = tonumber(session.deathStreak) or 0
    session.bestKillStreak = tonumber(session.bestKillStreak) or 0
    session.bestKBStreak = tonumber(session.bestKBStreak) or 0
    session.worstDeathStreak = tonumber(session.worstDeathStreak) or 0
    session.avengeKills = tonumber(session.avengeKills) or 0
    session.revengeKills = tonumber(session.revengeKills) or 0
    session.allianceKills = EnsureAllianceCountTable(session.allianceKills)
    session.allianceDeaths = EnsureAllianceCountTable(session.allianceDeaths)
    session.allianceKBs = EnsureAllianceCountTable(session.allianceKBs)
    session.classKills = EnsureStatsTable(session.classKills)
    session.classDeaths = EnsureStatsTable(session.classDeaths)
    session.classKBs = EnsureStatsTable(session.classKBs)
    session.opponents = EnsureStatsTable(session.opponents)
    session.abilities = EnsureStatsTable(session.abilities)
    session.deathAbilities = EnsureStatsTable(session.deathAbilities)
    session.recentEvents = EnsureStatsTable(session.recentEvents)
    session.recentStatEvents = EnsureStatsTable(session.recentStatEvents)
    session.targets = EnsureStatsTable(session.targets)
    session.lastKill = tostring(session.lastKill or "")
    session.lastDeath = tostring(session.lastDeath or "")
    session.lastKBAbility = tostring(session.lastKBAbility or "")
    session.lastDeathAbility = tostring(session.lastDeathAbility or "")
    session.biggestHitDone = tonumber(session.biggestHitDone) or 0
    session.biggestHitTaken = tonumber(session.biggestHitTaken) or 0

    return CHX.pvpStats
end

local UpdateLifetimeRecordsFromSession

local function ResetPvpStatsSession()
    if not CHX.saved then return end

    UpdateLifetimeRecordsFromSession()

    CHX.saved.pvpStatsSession = CreateEmptyPvpStatsSession()
    CHX.pvpStats = CHX.pvpStats or {}
    CHX.pvpStats.session = CHX.saved.pvpStatsSession
    CHX.pvpStats.recentKBs = { count = 0 }
end

local function RefreshPvpStatsZoneState()
    if not CHX.saved then return end

    local inPvp = IsSupportedPvpStatsZone()
    local wasInPvp = CHX.saved.pvpStatsWasInPvp == true

    if inPvp and not wasInPvp then
        ResetPvpStatsSession()
    elseif type(CHX.saved.pvpStatsSession) ~= "table" then
        EnsurePvpStatsState()
    end

    CHX.saved.pvpStatsWasInPvp = inPvp
end


local function CreateEmptyPvpStatsLifetime()
    return {
        kills = 0,
        deaths = 0,
        killingBlows = 0,
        alliancePoints = 0,

        bestKillStreak = 0,
        bestKBStreak = 0,
        worstDeathStreak = 0,

        bestSessionKills = 0,
        bestSessionKBs = 0,
        bestSessionAP = 0,

        avengeKills = 0,
        revengeKills = 0,

        allianceKills = { [AD] = 0, [EP] = 0, [DC] = 0 },
        allianceDeaths = { [AD] = 0, [EP] = 0, [DC] = 0 },
        allianceKBs = { [AD] = 0, [EP] = 0, [DC] = 0 },

        classKills = {},
        classDeaths = {},
        classKBs = {},

        opponents = {},
        abilities = {},
        deathAbilities = {},

        biggestHitDone = 0,
        biggestHitTaken = 0,

        lastKnownExternalKills = nil,
        lastKnownExternalKillsSource = "",
    }
end

EnsureStatsTable = function(value)
    if type(value) ~= "table" then
        return {}
    end

    return value
end

EnsureAllianceCountTable = function(value)
    value = EnsureStatsTable(value)
    value[AD] = tonumber(value[AD]) or 0
    value[EP] = tonumber(value[EP]) or 0
    value[DC] = tonumber(value[DC]) or 0
    return value
end

local function EnsurePvpStatsLifetime()
    if not CHX.saved then return nil end

    if type(CHX.saved.pvpStatsLifetime) ~= "table" then
        CHX.saved.pvpStatsLifetime = CreateEmptyPvpStatsLifetime()
    end

    local lifetime = CHX.saved.pvpStatsLifetime

    lifetime.kills = tonumber(lifetime.kills) or 0
    lifetime.deaths = tonumber(lifetime.deaths) or 0
    lifetime.killingBlows = tonumber(lifetime.killingBlows) or 0
    lifetime.alliancePoints = tonumber(lifetime.alliancePoints) or 0

    lifetime.bestKillStreak = tonumber(lifetime.bestKillStreak) or 0
    lifetime.bestKBStreak = tonumber(lifetime.bestKBStreak) or 0
    lifetime.worstDeathStreak = tonumber(lifetime.worstDeathStreak) or 0

    lifetime.bestSessionKills = tonumber(lifetime.bestSessionKills) or 0
    lifetime.bestSessionKBs = tonumber(lifetime.bestSessionKBs) or 0
    lifetime.bestSessionAP = tonumber(lifetime.bestSessionAP) or 0

    lifetime.avengeKills = tonumber(lifetime.avengeKills) or 0
    lifetime.revengeKills = tonumber(lifetime.revengeKills) or 0

    lifetime.allianceKills = EnsureAllianceCountTable(lifetime.allianceKills)
    lifetime.allianceDeaths = EnsureAllianceCountTable(lifetime.allianceDeaths)
    lifetime.allianceKBs = EnsureAllianceCountTable(lifetime.allianceKBs)

    lifetime.classKills = EnsureStatsTable(lifetime.classKills)
    lifetime.classDeaths = EnsureStatsTable(lifetime.classDeaths)
    lifetime.classKBs = EnsureStatsTable(lifetime.classKBs)

    lifetime.opponents = EnsureStatsTable(lifetime.opponents)
    lifetime.abilities = EnsureStatsTable(lifetime.abilities)
    lifetime.deathAbilities = EnsureStatsTable(lifetime.deathAbilities)

    lifetime.biggestHitDone = tonumber(lifetime.biggestHitDone) or 0
    lifetime.biggestHitTaken = tonumber(lifetime.biggestHitTaken) or 0

    return lifetime
end

local function StatsCleanText(value)
    value = tostring(value or "")
    value = string.gsub(value, "%%^%%a", "")
    value = string.gsub(value, "%%^%%w%%w%%w%%w%%w%%w", "")
    value = string.gsub(value, ",..$", "")
    return value
end

local function StatsCleanPlayerName(value)
    value = StatsCleanText(value)
    value = string.gsub(value, "|c%%x%%x%%x%%x%%x%%x", "")
    value = string.gsub(value, "|r", "")
    value = string.gsub(value, "@", "")
    value = string.gsub(value, "^%%s+", "")
    value = string.gsub(value, "%%s+$", "")
    return value
end

local function StatsIsValidAlliance(alliance)
    alliance = tonumber(alliance) or NONE
    return alliance == AD or alliance == EP or alliance == DC
end

local function NormalizeTrackedName(name)
    name = zo_strformat("<<1>>", name or "")
    name = StatsCleanPlayerName(name)
    name = tostring(name or "")
    if name == "" then return "" end
    return name
end

local function GetPlayerStatIdentity()
    local characterName = ""
    local displayName = ""

    if type(GetUnitName) == "function" then
        characterName = NormalizeTrackedName(GetUnitName("player") or "")
    end

    if type(GetDisplayName) == "function" then
        local ok, value = pcall(GetDisplayName)
        if ok then
            displayName = NormalizeTrackedName(value or "")
        end
    end

    return characterName, displayName
end

local function IsPlayerStatName(displayName, characterName)
    local playerCharacterName, playerDisplayName = GetPlayerStatIdentity()
    local cleanDisplayName = NormalizeTrackedName(displayName or "")
    local cleanCharacterName = NormalizeTrackedName(characterName or "")

    if cleanCharacterName ~= "" and playerCharacterName ~= "" and cleanCharacterName == playerCharacterName then return true end
    if cleanDisplayName ~= "" and playerDisplayName ~= "" and cleanDisplayName == playerDisplayName then return true end
    if cleanDisplayName ~= "" and playerCharacterName ~= "" and cleanDisplayName == playerCharacterName then return true end
    if cleanCharacterName ~= "" and playerDisplayName ~= "" and cleanCharacterName == playerDisplayName then return true end

    return false
end

local function WasRecentStatEvent(session, key, windowSeconds)
    if type(session) ~= "table" then return false end

    session.recentStatEvents = EnsureStatsTable(session.recentStatEvents)
    key = tostring(key or "")
    if key == "" then return false end

    local now = GetNow()
    windowSeconds = tonumber(windowSeconds) or 8

    for eventKey, timestamp in pairs(session.recentStatEvents) do
        if GetDeltaSeconds(timestamp) > windowSeconds then
            session.recentStatEvents[eventKey] = nil
        end
    end

    if session.recentStatEvents[key] and GetDeltaSeconds(session.recentStatEvents[key]) <= windowSeconds then
        return true
    end

    session.recentStatEvents[key] = now
    return false
end

local function GetOpponentInfo(name)
    local state = EnsurePvpStatsState()
    if not state or not state.session then return nil end

    name = NormalizeTrackedName(name)
    if name == "" then return nil end

    local session = state.session
    session.targets = EnsureStatsTable(session.targets)

    return session.targets[name]
end

local function CountTableEntries(t)
    local count = 0

    if type(t) ~= "table" then return 0 end

    for _ in pairs(t) do
        count = count + 1
    end

    return count
end

local function IncrementNumericField(t, key, amount)
    if type(t) ~= "table" then return end
    amount = tonumber(amount) or 1
    t[key] = (tonumber(t[key]) or 0) + amount
end

local function IncrementNestedCount(t, key, amount)
    if type(t) ~= "table" then return end
    if key == nil or key == "" then return end
    amount = tonumber(amount) or 1
    t[key] = (tonumber(t[key]) or 0) + amount
end

local function SecondsToClock(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    if hours > 0 then
        return string.format("%d:%02d:%02d", hours, minutes, secs)
    end

    return string.format("%d:%02d", minutes, secs)
end

local function GetSessionElapsedSeconds(session)
    session = session or {}
    return GetDeltaSeconds(tonumber(session.startTime) or GetNow())
end

local function GetSessionCombatSeconds(session)
    session = session or {}
    local seconds = tonumber(session.combatSeconds) or 0

    if session.inCombat == true and session.combatStartTime then
        seconds = seconds + GetDeltaSeconds(session.combatStartTime)
    end

    return seconds
end

local function FormatRatio(kills, deaths)
    kills = tonumber(kills) or 0
    deaths = tonumber(deaths) or 0

    if deaths <= 0 then
        if kills <= 0 then return "0.00" end
        return string.format("%.2f", kills)
    end

    return string.format("%.2f", kills / deaths)
end

local function GetTopKeyByCount(t)
    local bestKey = nil
    local bestValue = -1

    if type(t) ~= "table" then return "--", 0 end

    for key, value in pairs(t) do
        local numeric = tonumber(value) or 0
        if numeric > bestValue then
            bestKey = key
            bestValue = numeric
        end
    end

    if bestKey == nil then return "--", 0 end
    return tostring(bestKey), bestValue
end

local function GetTopOpponentByField(opponents, field)
    local best = nil
    local bestValue = -1

    if type(opponents) ~= "table" then return nil end

    for _, opponent in pairs(opponents) do
        if type(opponent) == "table" then
            local value = tonumber(opponent[field]) or 0
            if value > bestValue then
                best = opponent
                bestValue = value
            end
        end
    end

    return best, bestValue
end

local function GetSortedOpponents(opponents)
    local rows = {}

    if type(opponents) == "table" then
        for _, opponent in pairs(opponents) do
            if type(opponent) == "table" then
                rows[#rows + 1] = opponent
            end
        end
    end

    table.sort(rows, function(a, b)
        local aScore = (tonumber(a.kills) or 0) + (tonumber(a.deaths) or 0) + (tonumber(a.killingBlows) or 0)
        local bScore = (tonumber(b.kills) or 0) + (tonumber(b.deaths) or 0) + (tonumber(b.killingBlows) or 0)

        if aScore ~= bScore then return aScore > bScore end
        return tostring(a.name or "") < tostring(b.name or "")
    end)

    return rows
end

local function FormatOrdinal(value)
    value = tonumber(value) or 0

    if value == 1 then return "1st" end
    if value == 2 then return "2nd" end
    if value == 3 then return "3rd" end

    return tostring(value) .. "th"
end

local function GetSortedLifetimeDeathRivals(opponents)
    local rows = {}

    if type(opponents) == "table" then
        for _, opponent in pairs(opponents) do
            if type(opponent) == "table" and (tonumber(opponent.deaths) or 0) > 0 then
                rows[#rows + 1] = opponent
            end
        end
    end

    table.sort(rows, function(a, b)
        local aDeaths = tonumber(a.deaths) or 0
        local bDeaths = tonumber(b.deaths) or 0

        if aDeaths ~= bDeaths then return aDeaths > bDeaths end

        local aKills = tonumber(a.kills) or 0
        local bKills = tonumber(b.kills) or 0

        if aKills ~= bKills then return aKills > bKills end

        return tostring(a.name or "") < tostring(b.name or "")
    end)

    return rows
end

local function GetSortedAbilityStats(stats)
    local rows = {}

    if type(stats) == "table" then
        for abilityName, data in pairs(stats) do
            if type(data) == "table" then
                data.name = data.name or abilityName
                rows[#rows + 1] = data
            end
        end
    end

    table.sort(rows, function(a, b)
        local aScore = (tonumber(a.kills) or 0) + (tonumber(a.deaths) or 0) + (tonumber(a.killingBlows) or 0)
        local bScore = (tonumber(b.kills) or 0) + (tonumber(b.deaths) or 0) + (tonumber(b.killingBlows) or 0)

        if aScore ~= bScore then return aScore > bScore end
        return tostring(a.name or "") < tostring(b.name or "")
    end)

    return rows
end

local function GetTopAbilityNameByField(stats, field)
    local best = nil
    local bestValue = -1

    if type(stats) ~= "table" then return "--", 0 end

    for abilityName, data in pairs(stats) do
        if type(data) == "table" then
            local value = tonumber(data[field]) or 0
            if value > bestValue then
                best = data.name or abilityName
                bestValue = value
            end
        end
    end

    if not best then return "--", 0 end
    return tostring(best), bestValue
end

local function EnsureOpponentRecord(container, name)
    if type(container) ~= "table" then return nil end

    name = NormalizeTrackedName(name)
    if name == "" then return nil end

    local key = string.lower(name)
    local record = container[key]

    if type(record) ~= "table" then
        record = {
            name = name,
            kills = 0,
            deaths = 0,
            killingBlows = 0,
            alliance = NONE,
            className = "",
            account = "",
            firstSeen = GetNow(),
            lastSeen = GetNow(),
            lastEvent = "",
        }

        container[key] = record
    end

    record.name = record.name or name
    record.lastSeen = GetNow()

    return record
end

local function CopyKnownOpponentInfo(record, info)
    if type(record) ~= "table" or type(info) ~= "table" then return end

    if info.alliance and StatsIsValidAlliance(info.alliance) then
        record.alliance = info.alliance
    end

    if info.className and tostring(info.className) ~= "" then
        record.className = tostring(info.className)
    end

    if info.account and tostring(info.account) ~= "" then
        record.account = tostring(info.account)
    end
end

local function GetAbilityRecord(container, abilityName)
    if type(container) ~= "table" then return nil end

    abilityName = tostring(abilityName or "")
    if abilityName == "" then abilityName = "Unknown" end

    local key = string.lower(abilityName)
    local record = container[key]

    if type(record) ~= "table" then
        record = {
            name = abilityName,
            kills = 0,
            deaths = 0,
            killingBlows = 0,
            totalDamage = 0,
            maxDamage = 0,
            hits = 0,
            crits = 0,
            lastSeen = GetNow(),
        }

        container[key] = record
    end

    record.name = record.name or abilityName
    record.lastSeen = GetNow()

    return record
end

local function AddRecentEvent(session, textValue)
    if type(session) ~= "table" then return end

    session.recentEvents = EnsureStatsTable(session.recentEvents)
    table.insert(session.recentEvents, 1, tostring(textValue or ""))

    while #session.recentEvents > 12 do
        table.remove(session.recentEvents)
    end
end

local function GetAllianceNameShort(alliance)
    if alliance == AD then return "AD" end
    if alliance == EP then return "EP" end
    if alliance == DC then return "DC" end
    return "--"
end

local function TryGetExternalLifetimeKills()
    local candidates = {
        { name = "GetNumAllianceKills", args = {} },
        { name = "GetNumAllianceKills", args = { GetUnitAlliance and GetUnitAlliance("player") or nil } },
        { name = "GetAllianceKills", args = {} },
        { name = "GetAllianceKills", args = { GetUnitAlliance and GetUnitAlliance("player") or nil } },
        { name = "GetLifetimeAllianceKills", args = {} },
        { name = "GetPlayerAllianceKills", args = {} },
        { name = "GetUnitAllianceKills", args = { "player" } },
        { name = "GetUnitAvAKills", args = { "player" } },
        { name = "GetNumAvAKills", args = {} },
    }

    for i = 1, #candidates do
        local item = candidates[i]
        local fn = _G and _G[item.name]

        if type(fn) == "function" then
            local ok, value = pcall(fn, unpack(item.args or {}))

            if ok and tonumber(value) and tonumber(value) >= 0 then
                return tonumber(value), item.name
            end
        end
    end

    return nil, "saved"
end

UpdateLifetimeRecordsFromSession = function()
    local state = EnsurePvpStatsState()
    local lifetime = EnsurePvpStatsLifetime()
    if not state or not state.session or not lifetime then return end

    local session = state.session

    lifetime.bestSessionKills = math.max(tonumber(lifetime.bestSessionKills) or 0, tonumber(session.kills) or 0)
    lifetime.bestSessionKBs = math.max(tonumber(lifetime.bestSessionKBs) or 0, tonumber(session.killingBlows) or 0)
    lifetime.bestSessionAP = math.max(tonumber(lifetime.bestSessionAP) or 0, tonumber(session.alliancePoints) or 0)
    lifetime.bestKillStreak = math.max(tonumber(lifetime.bestKillStreak) or 0, tonumber(session.bestKillStreak) or 0)
    lifetime.bestKBStreak = math.max(tonumber(lifetime.bestKBStreak) or 0, tonumber(session.bestKBStreak) or 0)
    lifetime.worstDeathStreak = math.max(tonumber(lifetime.worstDeathStreak) or 0, tonumber(session.worstDeathStreak) or 0)
    lifetime.biggestHitDone = math.max(tonumber(lifetime.biggestHitDone) or 0, tonumber(session.biggestHitDone) or 0)
    lifetime.biggestHitTaken = math.max(tonumber(lifetime.biggestHitTaken) or 0, tonumber(session.biggestHitTaken) or 0)
end

local function TrackerSetText(controlName, value)
    local control = _G and _G[controlName]

    if control and type(control.SetText) == "function" then
        control:SetText(tostring(value or ""))
    end
end

local function TrackerSetAllianceIcon(controlName, alliance)
    local control = _G and _G[controlName]

    if not control then return end

    alliance = tonumber(alliance) or NONE

    if alliance ~= AD and alliance ~= EP and alliance ~= DC then
        if type(control.SetHidden) == "function" then
            control:SetHidden(true)
        end

        return
    end

    if type(control.SetTexture) == "function" then
        control:SetTexture(GetAllianceEmblem(alliance))
    end

    if type(control.SetColor) == "function" then
        control:SetColor(GetAllianceColorSafe(alliance))
    end

    if type(control.SetHidden) == "function" then
        control:SetHidden(false)
    end
end

local function TrackerSetVisible(controlName, visible)
    local control = _G and _G[controlName]

    if control and type(control.SetHidden) == "function" then
        control:SetHidden(visible ~= true)
    end
end

local function TrackerAllianceCountsText(killTable, deathTable, kbTable, alliance)
    return tostring(tonumber(killTable and killTable[alliance]) or 0) ..
        " / " .. tostring(tonumber(deathTable and deathTable[alliance]) or 0) ..
        " / " .. tostring(tonumber(kbTable and kbTable[alliance]) or 0)
end

local function IsKillFeedPlaceholderAbility(abilityName)
    return string.lower(tostring(abilityName or "")) == "pvp kill feed"
end

local function RemoveKillFeedPlaceholderAbilityData(stats)
    if type(stats) ~= "table" then return end

    if type(stats.deathAbilities) == "table" then
        local bad = stats.deathAbilities["pvp kill feed"]

        if type(bad) == "table" then
            local badDeaths = tonumber(bad.deaths) or 0
            if badDeaths > 0 then
                stats.deaths = math.max(0, (tonumber(stats.deaths) or 0) - badDeaths)
            end
        end

        stats.deathAbilities["pvp kill feed"] = nil
    end

    if type(stats.abilities) == "table" then
        stats.abilities["pvp kill feed"] = nil
    end

    if type(stats.recentEvents) == "table" then
        local clean = {}

        for i = 1, #stats.recentEvents do
            local value = tostring(stats.recentEvents[i] or "")

            if not string.find(value, "PvP Kill Feed", 1, true) then
                clean[#clean + 1] = stats.recentEvents[i]
            end
        end

        stats.recentEvents = clean
    end
end

local function CleanOldKillFeedPlaceholderStats()
    local state = EnsurePvpStatsState()
    local lifetime = EnsurePvpStatsLifetime()

    if state and state.session then
        RemoveKillFeedPlaceholderAbilityData(state.session)
    end

    if lifetime then
        RemoveKillFeedPlaceholderAbilityData(lifetime)
    end
end

local function UpdateStatsPanelStatsPages()
    if not CHX.ui or not CHX.ui.statsPanel then return end

    CleanOldKillFeedPlaceholderStats()

    local state = EnsurePvpStatsState()
    local lifetime = EnsurePvpStatsLifetime()

    if not state or not state.session or not lifetime then return end

    local session = state.session
    UpdateLifetimeRecordsFromSession()

    local elapsed = GetSessionElapsedSeconds(session)
    local combatSeconds = GetSessionCombatSeconds(session)
    local kills = tonumber(session.kills) or 0
    local deaths = tonumber(session.deaths) or 0
    local kbs = tonumber(session.killingBlows) or 0
    local ap = tonumber(session.alliancePoints) or 0
    local apm = elapsed > 0 and math.floor((ap / math.max(elapsed, 1)) * 60 + 0.5) or 0

    -- Page 1: Session Overview.
    TrackerSetText("PVPBuddy_CT1_Time_Value", SecondsToClock(elapsed))
    TrackerSetText("PVPBuddy_CT1_Combat_Value", SecondsToClock(combatSeconds))
    TrackerSetText("PVPBuddy_CT1_Kills_Value", kills)
    TrackerSetText("PVPBuddy_CT1_Deaths_Value", deaths)
    TrackerSetText("PVPBuddy_CT1_KB_Value", kbs)
    TrackerSetText("PVPBuddy_CT1_KDR_Value", FormatRatio(kills, deaths))
    TrackerSetText("PVPBuddy_CT1_AP_Value", FormatNumber(ap))
    TrackerSetText("PVPBuddy_CT1_APM_Value", FormatNumber(apm))

    TrackerSetText("PVPBuddy_CT1_CurKill_Value", tonumber(session.killStreak) or 0)
    TrackerSetText("PVPBuddy_CT1_BestKill_Value", tonumber(session.bestKillStreak) or 0)
    TrackerSetText("PVPBuddy_CT1_CurKB_Value", tonumber(session.kbStreak) or 0)
    TrackerSetText("PVPBuddy_CT1_BestKB_Value", tonumber(session.bestKBStreak) or 0)
    TrackerSetText("PVPBuddy_CT1_CurDeath_Value", tonumber(session.deathStreak) or 0)
    TrackerSetText("PVPBuddy_CT1_WorstDeath_Value", tonumber(session.worstDeathStreak) or 0)
    TrackerSetText("PVPBuddy_CT1_Avenge_Value", tonumber(session.avengeKills) or 0)
    TrackerSetText("PVPBuddy_CT1_Revenge_Value", tonumber(session.revengeKills) or 0)

    TrackerSetText("PVPBuddy_CT1_ADK", tonumber(session.allianceKills and session.allianceKills[AD]) or 0)
    TrackerSetText("PVPBuddy_CT1_ADD", tonumber(session.allianceDeaths and session.allianceDeaths[AD]) or 0)
    TrackerSetText("PVPBuddy_CT1_ADKB", tonumber(session.allianceKBs and session.allianceKBs[AD]) or 0)
    TrackerSetText("PVPBuddy_CT1_EPK", tonumber(session.allianceKills and session.allianceKills[EP]) or 0)
    TrackerSetText("PVPBuddy_CT1_EPD", tonumber(session.allianceDeaths and session.allianceDeaths[EP]) or 0)
    TrackerSetText("PVPBuddy_CT1_EPKB", tonumber(session.allianceKBs and session.allianceKBs[EP]) or 0)
    TrackerSetText("PVPBuddy_CT1_DCK", tonumber(session.allianceKills and session.allianceKills[DC]) or 0)
    TrackerSetText("PVPBuddy_CT1_DCD", tonumber(session.allianceDeaths and session.allianceDeaths[DC]) or 0)
    TrackerSetText("PVPBuddy_CT1_DCKB", tonumber(session.allianceKBs and session.allianceKBs[DC]) or 0)

    local topClassKilled = GetTopKeyByCount(session.classKills)
    local topClassDanger = GetTopKeyByCount(session.classDeaths)
    TrackerSetText("PVPBuddy_CT1_Class1V", topClassKilled)
    TrackerSetText("PVPBuddy_CT1_Class2V", topClassDanger)

    TrackerSetText("PVPBuddy_CT1_Event1V", session.lastKill ~= "" and session.lastKill or "--")
    TrackerSetText("PVPBuddy_CT1_Event2V", session.lastDeath ~= "" and session.lastDeath or "--")
    TrackerSetText("PVPBuddy_CT1_Event3V", session.lastKBAbility ~= "" and session.lastKBAbility or "--")
    TrackerSetText("PVPBuddy_CT1_Event4V", session.lastDeathAbility ~= "" and session.lastDeathAbility or "--")
    TrackerSetText("PVPBuddy_CT1_Event5V", FormatNumber(session.biggestHitDone or 0))
    TrackerSetText("PVPBuddy_CT1_Event6V", FormatNumber(session.biggestHitTaken or 0))

    local sessionOpponents = GetSortedOpponents(session.opponents)
    for i = 1, 8 do
        local row = sessionOpponents[i]
        TrackerSetText("PVPBuddy_CT1_OppR" .. tostring(i) .. "Name", row and row.name or "")
        TrackerSetText("PVPBuddy_CT1_OppR" .. tostring(i) .. "Alliance", row and GetAllianceNameShort(row.alliance) or "")
        TrackerSetText("PVPBuddy_CT1_OppR" .. tostring(i) .. "Class", row and (row.className or "") or "")
        TrackerSetText("PVPBuddy_CT1_OppR" .. tostring(i) .. "K", row and (row.kills or 0) or "")
        TrackerSetText("PVPBuddy_CT1_OppR" .. tostring(i) .. "D", row and (row.deaths or 0) or "")
        TrackerSetText("PVPBuddy_CT1_OppR" .. tostring(i) .. "KB", row and (row.killingBlows or 0) or "")
        TrackerSetText("PVPBuddy_CT1_OppR" .. tostring(i) .. "Last", row and SecondsToClock(GetDeltaSeconds(row.lastSeen or GetNow())) .. " ago" or "")
    end

    -- Page 2: PvP Buddy Lifetime.
    local displayLifetimeKills = tonumber(lifetime.kills) or 0

    TrackerSetText("PVPBuddy_CT2_LKills_Value", FormatNumber(displayLifetimeKills))
    TrackerSetText("PVPBuddy_CT2_LDeaths_Value", FormatNumber(lifetime.deaths or 0))
    TrackerSetText("PVPBuddy_CT2_LKB_Value", FormatNumber(lifetime.killingBlows or 0))
    TrackerSetText("PVPBuddy_CT2_LKDR_Value", FormatRatio(displayLifetimeKills, lifetime.deaths))
    TrackerSetText("PVPBuddy_CT2_LAP_Value", FormatNumber(lifetime.alliancePoints or 0))
    TrackerSetText("PVPBuddy_CT2_LUnique_Value", CountTableEntries(lifetime.opponents))
    TrackerSetText("PVPBuddy_CT2_LTopClass_Value", GetTopKeyByCount(lifetime.classKills))
    TrackerSetText("PVPBuddy_CT2_LDangerClass_Value", GetTopKeyByCount(lifetime.classDeaths))

    TrackerSetText("PVPBuddy_CT2_BestKill_Value", lifetime.bestKillStreak or 0)
    TrackerSetText("PVPBuddy_CT2_BestKB_Value", lifetime.bestKBStreak or 0)
    TrackerSetText("PVPBuddy_CT2_WorstDeath_Value", lifetime.worstDeathStreak or 0)
    TrackerSetText("PVPBuddy_CT2_BestSessionKills_Value", lifetime.bestSessionKills or 0)
    TrackerSetText("PVPBuddy_CT2_BestSessionKB_Value", lifetime.bestSessionKBs or 0)
    TrackerSetText("PVPBuddy_CT2_BestSessionAP_Value", FormatNumber(lifetime.bestSessionAP or 0))
    TrackerSetText("PVPBuddy_CT2_BigHit_Value", FormatNumber(lifetime.biggestHitDone or 0))
    TrackerSetText("PVPBuddy_CT2_BigTaken_Value", FormatNumber(lifetime.biggestHitTaken or 0))

    TrackerSetText("PVPBuddy_CT2_ADV", TrackerAllianceCountsText(lifetime.allianceKills, lifetime.allianceDeaths, lifetime.allianceKBs, AD))
    TrackerSetText("PVPBuddy_CT2_EPV", TrackerAllianceCountsText(lifetime.allianceKills, lifetime.allianceDeaths, lifetime.allianceKBs, EP))
    TrackerSetText("PVPBuddy_CT2_DCV", TrackerAllianceCountsText(lifetime.allianceKills, lifetime.allianceDeaths, lifetime.allianceKBs, DC))
    TrackerSetText("PVPBuddy_CT2_Source1", "Source: PvP Buddy tracked stats")
    TrackerSetText("PVPBuddy_CT2_Source2", "Counts start from when PvP Buddy is installed/updated.")

    local lifetimeDeathRivals = GetSortedLifetimeDeathRivals(lifetime.opponents)

    for i = 1, 10 do
        local row = lifetimeDeathRivals[i]
        local alliance = row and row.alliance or NONE

        TrackerSetText("PVPBuddy_CT2_RivalR" .. tostring(i) .. "Rank", FormatOrdinal(i))
        TrackerSetText("PVPBuddy_CT2_RivalR" .. tostring(i) .. "Name", row and row.name or "")
        TrackerSetAllianceIcon("PVPBuddy_CT2_RivalR" .. tostring(i) .. "AllianceIcon", alliance)
        TrackerSetText("PVPBuddy_CT2_RivalR" .. tostring(i) .. "Alliance", row and GetAllianceNameShort(alliance) or "")
        TrackerSetText("PVPBuddy_CT2_RivalR" .. tostring(i) .. "Deaths", row and FormatNumber(row.deaths or 0) or "")
    end

    -- Page 3: Opponents / Rivals.
    local topKilled = GetTopOpponentByField(lifetime.opponents, "kills")
    local topDanger = GetTopOpponentByField(lifetime.opponents, "deaths")
    local topKB = GetTopOpponentByField(lifetime.opponents, "killingBlows")
    TrackerSetText("PVPBuddy_CT3_TopKill_Value", topKilled and topKilled.name or "--")
    TrackerSetText("PVPBuddy_CT3_TopDanger_Value", topDanger and topDanger.name or "--")
    TrackerSetText("PVPBuddy_CT3_TopKB_Value", topKB and topKB.name or "--")
    TrackerSetText("PVPBuddy_CT3_Unique_Value", CountTableEntries(lifetime.opponents))
    TrackerSetText("PVPBuddy_CT3_Revenge_Value", lifetime.revengeKills or 0)
    TrackerSetText("PVPBuddy_CT3_Avenge_Value", lifetime.avengeKills or 0)
    TrackerSetText("PVPBuddy_CT3_LastKiller_Value", session.lastDeath ~= "" and session.lastDeath or "--")
    TrackerSetText("PVPBuddy_CT3_LastVictim_Value", session.lastKill ~= "" and session.lastKill or "--")
    TrackerSetText("PVPBuddy_CT3_TopRival_Value", topDanger and topDanger.name or "--")
    TrackerSetText("PVPBuddy_CT3_RivalClass_Value", topDanger and topDanger.className or "--")
    TrackerSetText("PVPBuddy_CT3_RivalAlliance_Value", topDanger and GetAllianceNameShort(topDanger.alliance) or "--")
    TrackerSetText("PVPBuddy_CT3_Encounters_Value", topDanger and ((tonumber(topDanger.kills) or 0) + (tonumber(topDanger.deaths) or 0)) or 0)

    local lifetimeOpponents = GetSortedOpponents(lifetime.opponents)
    local details = lifetimeOpponents[1]
    TrackerSetText("PVPBuddy_CT3_DetailNote", details and (details.name .. "  " .. GetAllianceNameShort(details.alliance) .. "  " .. tostring(details.className or "") .. "  K:" .. tostring(details.kills or 0) .. " D:" .. tostring(details.deaths or 0)) or "No opponent data yet.")

    for i = 1, 8 do
        local row = lifetimeOpponents[i]
        TrackerSetText("PVPBuddy_CT3_TabR" .. tostring(i) .. "Name", row and row.name or "")
        TrackerSetText("PVPBuddy_CT3_TabR" .. tostring(i) .. "Alliance", row and GetAllianceNameShort(row.alliance) or "")
        TrackerSetText("PVPBuddy_CT3_TabR" .. tostring(i) .. "Class", row and (row.className or "") or "")
        TrackerSetText("PVPBuddy_CT3_TabR" .. tostring(i) .. "K", row and (row.kills or 0) or "")
        TrackerSetText("PVPBuddy_CT3_TabR" .. tostring(i) .. "D", row and (row.deaths or 0) or "")
        TrackerSetText("PVPBuddy_CT3_TabR" .. tostring(i) .. "KB", row and (row.killingBlows or 0) or "")
        TrackerSetText("PVPBuddy_CT3_TabR" .. tostring(i) .. "Last", row and SecondsToClock(GetDeltaSeconds(row.lastSeen or GetNow())) .. " ago" or "")
    end

    for i = 1, 8 do
        TrackerSetText("PVPBuddy_CT3_EventR" .. tostring(i) .. "Time", session.recentEvents and session.recentEvents[i] and SecondsToClock(i - 1) or "")
        TrackerSetText("PVPBuddy_CT3_EventR" .. tostring(i) .. "Text", session.recentEvents and session.recentEvents[i] or "")
    end

    -- Page 4: Abilities / Death Causes.
    local topAbility = GetTopAbilityNameByField(lifetime.abilities, "killingBlows")
    local topDeathAbility = GetTopAbilityNameByField(lifetime.deathAbilities, "deaths")
    TrackerSetText("PVPBuddy_CT4_TotalKills_Value", FormatNumber(lifetime.kills or 0))
    TrackerSetText("PVPBuddy_CT4_TotalKB_Value", FormatNumber(lifetime.killingBlows or 0))
    TrackerSetText("PVPBuddy_CT4_TopKBAbility_Value", topAbility)
    TrackerSetText("PVPBuddy_CT4_BigKB_Value", FormatNumber(lifetime.biggestHitDone or 0))
    TrackerSetText("PVPBuddy_CT4_AvgKB_Value", "0")
    TrackerSetText("PVPBuddy_CT4_UltKB_Value", "0")
    TrackerSetText("PVPBuddy_CT4_ProcKB_Value", "0")
    TrackerSetText("PVPBuddy_CT4_TotalDeaths_Value", FormatNumber(lifetime.deaths or 0))
    TrackerSetText("PVPBuddy_CT4_TopDeathAbility_Value", topDeathAbility)
    TrackerSetText("PVPBuddy_CT4_LastDeathAbility_Value", session.lastDeathAbility ~= "" and session.lastDeathAbility or "--")
    TrackerSetText("PVPBuddy_CT4_SiegeDeaths_Value", "0")
    TrackerSetText("PVPBuddy_CT4_UltDeaths_Value", "0")
    TrackerSetText("PVPBuddy_CT4_ProcDeaths_Value", "0")

    local deathAbilityRows = GetSortedAbilityStats(lifetime.deathAbilities)
    for i = 1, 8 do
        local row = deathAbilityRows[i]
        TrackerSetText("PVPBuddy_CT4_CauseR" .. tostring(i) .. "Ability", row and row.name or "")
        TrackerSetText("PVPBuddy_CT4_CauseR" .. tostring(i) .. "Type", row and "Death" or "")
        TrackerSetText("PVPBuddy_CT4_CauseR" .. tostring(i) .. "Count", row and (row.deaths or 0) or "")
        TrackerSetText("PVPBuddy_CT4_CauseR" .. tostring(i) .. "Last", row and SecondsToClock(GetDeltaSeconds(row.lastSeen or GetNow())) .. " ago" or "")
    end

    for i = 1, 8 do
        local eventText = session.recentEvents and session.recentEvents[i] or ""
        TrackerSetText("PVPBuddy_CT4_DeathR" .. tostring(i) .. "Killer", eventText ~= "" and eventText or "")
        TrackerSetText("PVPBuddy_CT4_DeathR" .. tostring(i) .. "Ability", "")
        TrackerSetText("PVPBuddy_CT4_DeathR" .. tostring(i) .. "Time", "")
    end

    local abilityRows = GetSortedAbilityStats(lifetime.abilities)
    for i = 1, 8 do
        local row = abilityRows[i]
        TrackerSetText("PVPBuddy_CT4_AbiR" .. tostring(i) .. "Ability", row and row.name or "")
        TrackerSetText("PVPBuddy_CT4_AbiR" .. tostring(i) .. "K", row and (row.kills or 0) or "")
        TrackerSetText("PVPBuddy_CT4_AbiR" .. tostring(i) .. "KB", row and (row.killingBlows or 0) or "")
        TrackerSetText("PVPBuddy_CT4_AbiR" .. tostring(i) .. "Deaths", row and (row.deaths or 0) or "")
        TrackerSetText("PVPBuddy_CT4_AbiR" .. tostring(i) .. "Avg", row and ((tonumber(row.hits) or 0) > 0 and FormatNumber(math.floor((tonumber(row.totalDamage) or 0) / math.max(1, tonumber(row.hits) or 1))) or "0") or "")
        TrackerSetText("PVPBuddy_CT4_AbiR" .. tostring(i) .. "Max", row and FormatNumber(row.maxDamage or 0) or "")
        TrackerSetText("PVPBuddy_CT4_AbiR" .. tostring(i) .. "Crits", row and (row.crits or 0) or "")
    end
end

local function RecordOpponentKill(targetName, abilityName, hitValue)
    local state = EnsurePvpStatsState()
    local lifetime = EnsurePvpStatsLifetime()
    if not state or not state.session or not lifetime then return end

    local session = state.session
    targetName = NormalizeTrackedName(targetName)
    if targetName == "" then return end

    local known = GetOpponentInfo(targetName)
    local accountName = known and NormalizeTrackedName(known.account or "") or ""

    if accountName ~= "" then
        targetName = accountName
        known = GetOpponentInfo(targetName) or known
    end

    local alliance = known and known.alliance or NONE
    local className = known and known.className or ""

    local sessionOpponent = EnsureOpponentRecord(session.opponents, targetName)
    local lifetimeOpponent = EnsureOpponentRecord(lifetime.opponents, targetName)
    CopyKnownOpponentInfo(sessionOpponent, known)
    CopyKnownOpponentInfo(lifetimeOpponent, known)

    IncrementNumericField(sessionOpponent, "kills", 1)
    IncrementNumericField(lifetimeOpponent, "kills", 1)

    session.kills = (tonumber(session.kills) or 0) + 1
    lifetime.kills = (tonumber(lifetime.kills) or 0) + 1

    session.killStreak = (tonumber(session.killStreak) or 0) + 1
    session.deathStreak = 0
    session.bestKillStreak = math.max(tonumber(session.bestKillStreak) or 0, tonumber(session.killStreak) or 0)
    lifetime.bestKillStreak = math.max(tonumber(lifetime.bestKillStreak) or 0, tonumber(session.killStreak) or 0)

    if StatsIsValidAlliance(alliance) then
        IncrementNumericField(session.allianceKills, alliance, 1)
        IncrementNumericField(lifetime.allianceKills, alliance, 1)
    end

    if className ~= "" then
        IncrementNestedCount(session.classKills, className, 1)
        IncrementNestedCount(lifetime.classKills, className, 1)
    end

    session.lastKill = targetName

    if not IsKillFeedPlaceholderAbility(abilityName) then
        local ability = GetAbilityRecord(session.abilities, abilityName)
        local lifetimeAbility = GetAbilityRecord(lifetime.abilities, abilityName)

        if ability then
            IncrementNumericField(ability, "kills", 1)
            IncrementNumericField(ability, "hits", 1)
            ability.totalDamage = (tonumber(ability.totalDamage) or 0) + (tonumber(hitValue) or 0)
            ability.maxDamage = math.max(tonumber(ability.maxDamage) or 0, tonumber(hitValue) or 0)
        end

        if lifetimeAbility then
            IncrementNumericField(lifetimeAbility, "kills", 1)
            IncrementNumericField(lifetimeAbility, "hits", 1)
            lifetimeAbility.totalDamage = (tonumber(lifetimeAbility.totalDamage) or 0) + (tonumber(hitValue) or 0)
            lifetimeAbility.maxDamage = math.max(tonumber(lifetimeAbility.maxDamage) or 0, tonumber(hitValue) or 0)
        end
    end

    session.biggestHitDone = math.max(tonumber(session.biggestHitDone) or 0, tonumber(hitValue) or 0)
    lifetime.biggestHitDone = math.max(tonumber(lifetime.biggestHitDone) or 0, tonumber(hitValue) or 0)
    AddRecentEvent(session, "Kill: " .. targetName)
end

local function RecordKillingBlow(targetName, abilityName, hitValue)
    local state = EnsurePvpStatsState()
    local lifetime = EnsurePvpStatsLifetime()
    if not state or not state.session or not lifetime then return end

    local session = state.session
    targetName = NormalizeTrackedName(targetName)
    if targetName == "" then return end

    local known = GetOpponentInfo(targetName)
    local accountName = known and NormalizeTrackedName(known.account or "") or ""

    if accountName ~= "" then
        targetName = accountName
        known = GetOpponentInfo(targetName) or known
    end

    local alliance = known and known.alliance or NONE
    local className = known and known.className or ""

    local sessionOpponent = EnsureOpponentRecord(session.opponents, targetName)
    local lifetimeOpponent = EnsureOpponentRecord(lifetime.opponents, targetName)
    CopyKnownOpponentInfo(sessionOpponent, known)
    CopyKnownOpponentInfo(lifetimeOpponent, known)

    IncrementNumericField(sessionOpponent, "killingBlows", 1)
    IncrementNumericField(lifetimeOpponent, "killingBlows", 1)

    session.killingBlows = (tonumber(session.killingBlows) or 0) + 1
    lifetime.killingBlows = (tonumber(lifetime.killingBlows) or 0) + 1

    session.kbStreak = (tonumber(session.kbStreak) or 0) + 1
    session.bestKBStreak = math.max(tonumber(session.bestKBStreak) or 0, tonumber(session.kbStreak) or 0)
    lifetime.bestKBStreak = math.max(tonumber(lifetime.bestKBStreak) or 0, tonumber(session.kbStreak) or 0)

    if StatsIsValidAlliance(alliance) then
        IncrementNumericField(session.allianceKBs, alliance, 1)
        IncrementNumericField(lifetime.allianceKBs, alliance, 1)
    end

    if className ~= "" then
        IncrementNestedCount(session.classKBs, className, 1)
        IncrementNestedCount(lifetime.classKBs, className, 1)
    end

    if not IsKillFeedPlaceholderAbility(abilityName) then
        session.lastKBAbility = tostring(abilityName or "Unknown")

        local ability = GetAbilityRecord(session.abilities, abilityName)
        local lifetimeAbility = GetAbilityRecord(lifetime.abilities, abilityName)

        if ability then
            IncrementNumericField(ability, "killingBlows", 1)
        end

        if lifetimeAbility then
            IncrementNumericField(lifetimeAbility, "killingBlows", 1)
        end

        AddRecentEvent(session, "KB: " .. targetName .. " (" .. tostring(abilityName or "Unknown") .. ")")
    else
        AddRecentEvent(session, "KB: " .. targetName)
    end
end

local function RecordPlayerDeath(deathBlow)
    local state = EnsurePvpStatsState()
    local lifetime = EnsurePvpStatsLifetime()
    if not state or not state.session or not lifetime then return end

    local session = state.session
    local killerCharacterName = deathBlow and NormalizeTrackedName(deathBlow.name) or ""
    local killerAccountName = deathBlow and NormalizeTrackedName(deathBlow.account) or ""
    local killerName = killerAccountName ~= "" and killerAccountName or killerCharacterName
    if killerName == "" then killerName = "Unknown" end

    local known = GetOpponentInfo(killerName) or GetOpponentInfo(killerCharacterName)
    local alliance = (deathBlow and deathBlow.alliance) or (known and known.alliance) or NONE
    local className = known and known.className or ""

    local sessionOpponent = EnsureOpponentRecord(session.opponents, killerName)
    local lifetimeOpponent = EnsureOpponentRecord(lifetime.opponents, killerName)
    CopyKnownOpponentInfo(sessionOpponent, known)
    CopyKnownOpponentInfo(lifetimeOpponent, known)

    if killerAccountName ~= "" then
        sessionOpponent.account = killerAccountName
        lifetimeOpponent.account = killerAccountName
    end

    if killerCharacterName ~= "" then
        sessionOpponent.characterName = killerCharacterName
        lifetimeOpponent.characterName = killerCharacterName
    end

    if StatsIsValidAlliance(alliance) then
        sessionOpponent.alliance = alliance
        lifetimeOpponent.alliance = alliance
    end

    IncrementNumericField(sessionOpponent, "deaths", 1)
    IncrementNumericField(lifetimeOpponent, "deaths", 1)

    session.deaths = (tonumber(session.deaths) or 0) + 1
    lifetime.deaths = (tonumber(lifetime.deaths) or 0) + 1

    session.deathStreak = (tonumber(session.deathStreak) or 0) + 1
    session.killStreak = 0
    session.kbStreak = 0
    session.worstDeathStreak = math.max(tonumber(session.worstDeathStreak) or 0, tonumber(session.deathStreak) or 0)
    lifetime.worstDeathStreak = math.max(tonumber(lifetime.worstDeathStreak) or 0, tonumber(session.deathStreak) or 0)

    if StatsIsValidAlliance(alliance) then
        IncrementNumericField(session.allianceDeaths, alliance, 1)
        IncrementNumericField(lifetime.allianceDeaths, alliance, 1)
    end

    if className ~= "" then
        IncrementNestedCount(session.classDeaths, className, 1)
        IncrementNestedCount(lifetime.classDeaths, className, 1)
    end

    session.lastDeath = killerName

    local abilityName = deathBlow and deathBlow.abilityName or "Unknown"
    local damage = deathBlow and tonumber(deathBlow.damage) or 0

    if not IsKillFeedPlaceholderAbility(abilityName) then
        session.lastDeathAbility = tostring(abilityName or "Unknown")

        local ability = GetAbilityRecord(session.deathAbilities, abilityName)
        local lifetimeAbility = GetAbilityRecord(lifetime.deathAbilities, abilityName)

        if ability then
            IncrementNumericField(ability, "deaths", 1)
            ability.totalDamage = (tonumber(ability.totalDamage) or 0) + damage
            ability.maxDamage = math.max(tonumber(ability.maxDamage) or 0, damage)
            ability.hits = (tonumber(ability.hits) or 0) + 1
        end

        if lifetimeAbility then
            IncrementNumericField(lifetimeAbility, "deaths", 1)
            lifetimeAbility.totalDamage = (tonumber(lifetimeAbility.totalDamage) or 0) + damage
            lifetimeAbility.maxDamage = math.max(tonumber(lifetimeAbility.maxDamage) or 0, damage)
            lifetimeAbility.hits = (tonumber(lifetimeAbility.hits) or 0) + 1
        end

        AddRecentEvent(session, "Death: " .. killerName .. " (" .. tostring(abilityName or "Unknown") .. ")")
    else
        AddRecentEvent(session, "Death: " .. killerName)
    end

    session.biggestHitTaken = math.max(tonumber(session.biggestHitTaken) or 0, damage)
    lifetime.biggestHitTaken = math.max(tonumber(lifetime.biggestHitTaken) or 0, damage)
end

local function OnPvpStatsCombatState(eventCode, inCombat)
    local state = EnsurePvpStatsState()
    if not state or not state.session then return end

    local session = state.session
    local now = GetNow()

    if inCombat == true and session.inCombat ~= true then
        session.inCombat = true
        session.combatStartTime = now
    elseif inCombat == false and session.inCombat == true then
        session.combatSeconds = (tonumber(session.combatSeconds) or 0) + GetDeltaSeconds(session.combatStartTime or now)
        session.combatStartTime = nil
        session.inCombat = false
    end

    UpdateStatsPanelStatsPages()
end

local function OnPvpStatsReticleTargetChanged(eventCode)
    if not IsSupportedPvpStatsZone() then return end
    if type(DoesUnitExist) ~= "function" or not DoesUnitExist("reticleover") then return end
    if type(IsUnitPlayer) == "function" and not IsUnitPlayer("reticleover") then return end

    local state = EnsurePvpStatsState()
    if not state or not state.session then return end

    local characterName = NormalizeTrackedName(type(GetUnitName) == "function" and GetUnitName("reticleover") or "")
    local accountName = NormalizeTrackedName(type(GetUnitDisplayName) == "function" and GetUnitDisplayName("reticleover") or "")
    local name = accountName ~= "" and accountName or characterName
    if name == "" then return end

    state.session.targets = EnsureStatsTable(state.session.targets)

    local info = state.session.targets[name] or state.session.targets[characterName] or {}
    info.name = name
    info.characterName = characterName
    info.account = accountName
    info.alliance = type(GetUnitAlliance) == "function" and GetUnitAlliance("reticleover") or info.alliance or NONE
    info.className = type(GetUnitClass) == "function" and StatsCleanText(GetUnitClass("reticleover") or "") or info.className or ""
    info.classId = type(GetUnitClassId) == "function" and GetUnitClassId("reticleover") or info.classId or 0
    info.cp = type(GetUnitChampionPoints) == "function" and GetUnitChampionPoints("reticleover") or info.cp or 0
    info.rank = type(GetUnitAvARank) == "function" and GetUnitAvARank("reticleover") or info.rank or 0
    info.lastSeen = GetNow()

    state.session.targets[name] = info

    if characterName ~= "" and characterName ~= name then
        state.session.targets[characterName] = info
    end
end

local function OnPvpStatsAvengeKill(eventCode, ...)
    local state = EnsurePvpStatsState()
    local lifetime = EnsurePvpStatsLifetime()
    if not state or not state.session or not lifetime then return end

    state.session.avengeKills = (tonumber(state.session.avengeKills) or 0) + 1
    lifetime.avengeKills = (tonumber(lifetime.avengeKills) or 0) + 1
    AddRecentEvent(state.session, "Avenge Kill")
    UpdateStatsPanelStatsPages()
end

local function OnPvpStatsRevengeKill(eventCode, ...)
    local state = EnsurePvpStatsState()
    local lifetime = EnsurePvpStatsLifetime()
    if not state or not state.session or not lifetime then return end

    state.session.revengeKills = (tonumber(state.session.revengeKills) or 0) + 1
    lifetime.revengeKills = (tonumber(lifetime.revengeKills) or 0) + 1
    AddRecentEvent(state.session, "Revenge Kill")
    UpdateStatsPanelStatsPages()
end

local function ShowLifetimeDebug()
    local lifetime = EnsurePvpStatsLifetime() or {}
    Print("pvp buddy lifetime: kills=" .. tostring(lifetime.kills or 0) ..
        " deaths=" .. tostring(lifetime.deaths or 0) ..
        " kbs=" .. tostring(lifetime.killingBlows or 0) ..
        " ap=" .. tostring(lifetime.alliancePoints or 0))
end

local function FormatPvpStatsStatsText()
    local state = EnsurePvpStatsState()

    if not state or not state.session then
        return "|c8ad6ffK:|r 0   |cf0a070D:|r 0   |cdd4137KB:|r 0   |c5df56dAP:|r 0"
    end

    local stats = state.session
    local kills = tonumber(stats.kills) or 0
    local deaths = tonumber(stats.deaths) or 0
    local killingBlows = tonumber(stats.killingBlows) or 0
    local alliancePoints = tonumber(stats.alliancePoints) or 0

    return string.format(
        "|c8ad6ffK:|r %d   |cf0a070D:|r %d   |cdd4137KB:|r %d   |c5df56dAP:|r %s",
        kills,
        deaths,
        killingBlows,
        FormatNumber(alliancePoints)
    )
end

local function FormatPvpStatsPerformanceText()
    local ping = 0
    local fps = 0

    if type(GetLatency) == "function" then
        ping = SafeCall("GetLatency", GetLatency, 0) or 0
    end

    if type(GetFramerate) == "function" then
        fps = SafeCall("GetFramerate", GetFramerate, 0) or 0
    end

    ping = math.max(0, math.floor((tonumber(ping) or 0) + 0.5))
    fps = math.max(0, math.floor((tonumber(fps) or 0) + 0.5))

    return string.format("|c8ad6ffP:|r %d  |c5df56dF:|r %d", ping, fps)
end

local function ShouldAutoShowHere()
    if not CHX.saved or not CHX.saved.enabled then
        return false
    end

    if not IsGameplayHudShowing() then
        return false
    end

    if not IsInAvAWorldSafe() then
        return CHX.saved.showTestRows == true
    end

    if IsInImperialCitySafe() then
        return CHX.saved.enableInImperialCity == true
    end

    return CHX.saved.enableInCyrodiil == true
end

local function GetCurrentCampaignIdSafe()
    local id = SafeCall("GetCurrentCampaignId", GetCurrentCampaignId, 0)

    if id and id ~= 0 then
        return id
    end

    return SafeCall("GetAssignedCampaignId", GetAssignedCampaignId, 0) or 0
end


local function QueryCampaignSelectionDataSafe(reason)
    if type(QueryCampaignSelectionData) == "function" then
        SafeCall("QueryCampaignSelectionData " .. tostring(reason or ""), QueryCampaignSelectionData, nil)
    end
end

local function GetCampaignDataFromManager(campaignId)
    campaignId = tonumber(campaignId) or 0

    if campaignId == 0 then
        return nil
    end

    if CAMPAIGN_BROWSER_MANAGER and type(CAMPAIGN_BROWSER_MANAGER.GetDataByCampaignId) == "function" then
        local data = SafeCall(
            "CAMPAIGN_BROWSER_MANAGER:GetDataByCampaignId",
            function()
                return CAMPAIGN_BROWSER_MANAGER:GetDataByCampaignId(campaignId)
            end,
            nil
        )

        if data then
            return data
        end
    end

    return nil
end

local function GetCampaignSelectionIndex(campaignId)
    campaignId = tonumber(campaignId) or 0

    if campaignId == 0 then
        return 0
    end

    if type(GetNumSelectionCampaigns) == "function" and type(GetSelectionCampaignId) == "function" then
        local num = SafeCall("GetNumSelectionCampaigns", GetNumSelectionCampaigns, 0) or 0

        for i = 1, num do
            local id = SafeCall("GetSelectionCampaignId", GetSelectionCampaignId, 0, i) or 0

            if tonumber(id) == campaignId then
                return i
            end
        end
    end

    return 0
end

local function GetCampaignNameSafe(campaignId)
    campaignId = tonumber(campaignId) or 0

    if campaignId == 0 then
        return ""
    end

    local managerData = GetCampaignDataFromManager(campaignId)

    if managerData and managerData.name and tostring(managerData.name) ~= "" then
        return tostring(managerData.name)
    end

    local name = SafeCall("GetCampaignName", GetCampaignName, "", campaignId)

    if name and tostring(name) ~= "" then
        return tostring(name)
    end

    return "Campaign " .. tostring(campaignId)
end

local function CreateLabel(parent, name, anchorTo, x, y, w, h, font, align)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGameSmall")
    label:SetColor(1, 1, 1, 1)
    label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetAnchor(TOPLEFT, anchorTo or parent, TOPLEFT, x or 0, y or 0)
    label:SetDimensions(w or 100, h or 22)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    return label
end

local function CreateBackdrop(parent, name, x, y, w, h, centerAlpha)
    local bg = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, parent, TOPLEFT, x or 0, y or 0)
    bg:SetDimensions(w or 100, h or 22)
    bg:SetCenterColor(0, 0, 0, centerAlpha or 0.72)
    bg:SetEdgeColor(0.82, 0.82, 0.82, 0.85)
    return bg
end

local function TrackerCleanText(value)
    value = tostring(value or "")
    value = string.gsub(value, "%^%a", "")
    value = string.gsub(value, "%^%w%w%w%w%w%w", "")
    value = string.gsub(value, ",..$", "")
    return value
end

local function TrackerStripAt(value)
    value = tostring(value or "")
    if string.sub(value, 1, 1) == "@" then
        return string.sub(value, 2)
    end
    return value
end

local function TrackerIsTexturePath(value)
    value = tostring(value or "")
    if value == "" then return false end

    local lower = string.lower(value)
    return lower:find("%.dds", 1, true) ~= nil
        or lower:find("%.png", 1, true) ~= nil
        or lower:find("/art/", 1, true) ~= nil
        or lower:find("esoui/", 1, true) ~= nil
end

local function TrackerCreateBackdrop(parent, name, x, y, w, h, cr, cg, cb, ca, er, eg, eb, ea)
    local bg = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, parent, TOPLEFT, x or 0, y or 0)
    bg:SetDimensions(w or 100, h or 22)
    bg:SetCenterColor(cr or 0, cg or 0, cb or 0, ca or 0.82)
    bg:SetEdgeColor(er or 0.70, eg or 0.70, eb or 0.70, ea or 0.95)
    return bg
end

local TRACKER_FONT_TRIES = {
    ZoFontWinH2 = {
        "$(GAMEPAD_BOLD_FONT)|36|soft-shadow-thick",
        "$(BOLD_FONT)|36|soft-shadow-thick",
        "ZoFontWinH2",
    },

    ZoFontGameLargeBold = {
        "$(GAMEPAD_BOLD_FONT)|27|soft-shadow-thick",
        "$(BOLD_FONT)|27|soft-shadow-thick",
        "ZoFontGameLargeBold",
    },

    ZoFontGameLarge = {
        "$(GAMEPAD_MEDIUM_FONT)|24|soft-shadow-thick",
        "$(MEDIUM_FONT)|24|soft-shadow-thick",
        "ZoFontGameLarge",
    },

    ZoFontGameBold = {
        "$(GAMEPAD_BOLD_FONT)|22|soft-shadow-thick",
        "$(BOLD_FONT)|22|soft-shadow-thick",
        "ZoFontGameBold",
    },

    ZoFontGame = {
        "$(GAMEPAD_MEDIUM_FONT)|21|soft-shadow-thick",
        "$(MEDIUM_FONT)|21|soft-shadow-thick",
        "ZoFontGame",
    },

    ZoFontGameSmall = {
        "$(GAMEPAD_MEDIUM_FONT)|18|soft-shadow-thick",
        "$(MEDIUM_FONT)|18|soft-shadow-thick",
        "ZoFontGameSmall",
    },
}

local function TrackerApplyReadableFont(control, font)
    local tries = TRACKER_FONT_TRIES[font] or { font or "ZoFontGameLarge", "ZoFontGameLarge" }

    for i = 1, #tries do
        local candidate = tries[i]

        if candidate and pcall(function()
            control:SetFont(candidate)
        end) then
            return
        end
    end

    pcall(function()
        control:SetFont("ZoFontGameLarge")
    end)
end

local function TrackerCreateLabel(parent, name, x, y, w, h, font, align, r, g, b, a)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, x or 0, y or 0)
    label:SetDimensions(w or 100, h or 22)
    TrackerApplyReadableFont(label, font or "ZoFontGame")
    label:SetHorizontalAlignment(align or TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetColor(r or 1, g or 1, b or 1, a or 1)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    label:SetText("")
    return label
end

local function TrackerCreateTexture(parent, name, x, y, w, h)
    local texture = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
    texture:SetAnchor(TOPLEFT, parent, TOPLEFT, x or 0, y or 0)
    texture:SetDimensions(w or 32, h or 32)
    texture:SetHidden(true)
    return texture
end

local function TrackerCreateHeader(parent, name, x, y, w, h, text)
    local label = TrackerCreateLabel(parent, name, x, y, w, h, "ZoFontGameLargeBold", TEXT_ALIGN_LEFT, 0.95, 0.85, 0.55, 1)
    label:SetText(text or "")
    return label
end

local function TrackerCreateColumn(parent, name, x, y, w, h, text, align)
    local label = TrackerCreateLabel(parent, name, x, y, w, h, "ZoFontGameBold", align or TEXT_ALIGN_LEFT, 0.92, 0.92, 0.92, 1)
    label:SetText(text or "")
    return label
end

local function TrackerCallNoArgs(name)
    local fn = _G and _G[name]
    if type(fn) ~= "function" then return nil end

    local ok, value = pcall(fn)
    if ok and value ~= nil and tostring(value) ~= "" then
        return value
    end

    return nil
end

local function TrackerGetCharacterName()
    if type(GetUnitName) == "function" then
        local ok, name = pcall(GetUnitName, "player")
        if ok and name and name ~= "" then
            return TrackerCleanText(name)
        end
    end

    return ""
end

local function TrackerGetAccountName()
    if type(GetDisplayName) == "function" then
        local ok, name = pcall(GetDisplayName)
        if ok and name and name ~= "" then
            return TrackerStripAt(name)
        end
    end

    return ""
end

local function TrackerGetChampionPoints()
    local candidates = {
        "GetPlayerChampionPointsEarned",
        "GetUnitChampionPoints",
        "GetPlayerChampionPoints",
    }

    for i = 1, #candidates do
        local fn = _G and _G[candidates[i]]
        if type(fn) == "function" then
            local ok, value = pcall(fn, "player")
            if ok and tonumber(value) then return tonumber(value) end

            ok, value = pcall(fn)
            if ok and tonumber(value) then return tonumber(value) end
        end
    end

    return 0
end

local function TrackerParseClassInfo(...)
    local info = { name = "", icon = "", id = nil }

    for i = 1, select("#", ...) do
        local value = select(i, ...)

        if type(value) == "string" then
            if info.icon == "" and TrackerIsTexturePath(value) then
                info.icon = value
            elseif info.name == "" and not TrackerIsTexturePath(value) and value ~= "" then
                info.name = TrackerCleanText(value)
            end
        elseif type(value) == "number" then
            info.id = value
        end
    end

    return info
end

local function TrackerGetClassInfo()
    local className = ""
    local classId = nil

    if type(GetUnitClass) == "function" then
        local ok, name, id = pcall(GetUnitClass, "player")
        if ok then
            if name and name ~= "" then className = TrackerCleanText(name) end
            if id then classId = id end
        end
    end

    if type(GetUnitClassId) == "function" then
        local ok, id = pcall(GetUnitClassId, "player")
        if ok and id then classId = id end
    end

    if classId and className == "" and type(GetClassName) == "function" then
        local ok, name = pcall(GetClassName, 0, classId)
        if ok and name and name ~= "" then className = TrackerCleanText(name) end
    end

    local classIcon = ""

    if type(GetClassInfo) == "function" then
        for i = 1, 20 do
            local ok, a, b, c, d, e, f, g, h = pcall(GetClassInfo, i)
            if ok then
                local info = TrackerParseClassInfo(a, b, c, d, e, f, g, h)
                local matchesId = classId and info.id == classId
                local matchesName = className ~= "" and string.lower(info.name or "") == string.lower(className)

                if info.icon ~= "" and (matchesId or matchesName) then
                    classIcon = info.icon
                    break
                end
            end
        end
    end

    return className, classIcon
end

local function TrackerGetClockText()
    local value = TrackerCallNoArgs("GetTimeString")
    if value and tostring(value) ~= "" then return tostring(value) end

    local timestamp = nil
    if type(GetTimeStamp) == "function" then
        local ok, ts = pcall(GetTimeStamp)
        if ok and tonumber(ts) then timestamp = tonumber(ts) end
    end

    if timestamp and os and type(os.date) == "function" then
        local ok, formatted = pcall(os.date, "%H:%M", timestamp)
        if ok and formatted and formatted ~= "" then return formatted end
    end

    return "--:--"
end

local function TrackerGetDateText()
    local value = TrackerCallNoArgs("GetDateString")
    if value and tostring(value) ~= "" then return tostring(value) end

    local timestamp = nil
    if type(GetTimeStamp) == "function" then
        local ok, ts = pcall(GetTimeStamp)
        if ok and tonumber(ts) then timestamp = tonumber(ts) end
    end

    if timestamp then
        if type(GetDateStringFromTimestamp) == "function" then
            local ok, formatted = pcall(GetDateStringFromTimestamp, timestamp)
            if ok and formatted and tostring(formatted) ~= "" then return tostring(formatted) end
        end

        if os and type(os.date) == "function" then
            local ok, formatted = pcall(os.date, "%d/%m/%Y", timestamp)
            if ok and formatted and formatted ~= "" then return formatted end
        end
    end

    return "--/--/----"
end

local function TrackerGetPatchText()
    local candidates = {
        "GetESOVersionString",
        "GetESOVersion",
        "GetBuildVersion",
        "GetBuildNumber",
        "GetClientVersion",
    }

    for i = 1, #candidates do
        local value = TrackerCallNoArgs(candidates[i])
        if value and tostring(value) ~= "" then
            return "Patch: " .. tostring(value)
        end
    end

    if type(GetAPIVersion) == "function" then
        local ok, api = pcall(GetAPIVersion)
        if ok and api ~= nil then
            return "Patch: API " .. tostring(api)
        end
    end

    return "Patch: --"
end

local function CreateFrameLine(parent, name, anchorPoint, relativePoint, x, y, w, h, r, g, b, a)
    local line = WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)
    line:SetAnchor(anchorPoint, parent, relativePoint, x or 0, y or 0)
    line:SetDimensions(w or 1, h or 1)
    line:SetColor(r or ESO_FRAME_GOLD_R, g or ESO_FRAME_GOLD_G, b or ESO_FRAME_GOLD_B, a or 1)
    line:SetDrawLayer(2)
    return line
end

local function CreateESOFrame(parent, prefix, width, height)
    local frame = {}

    frame.outer = WINDOW_MANAGER:CreateControl(prefix .. "_Outer", parent, CT_BACKDROP)
    frame.outer:SetAnchor(TOPLEFT, parent, TOPLEFT, -4, -4)
    frame.outer:SetDimensions(math.max(1, (width or 1) + 8), math.max(1, (height or 1) + 8))
    frame.outer:SetCenterColor(0, 0, 0, 0)
    frame.outer:SetEdgeColor(ESO_FRAME_DARK_R, ESO_FRAME_DARK_G, ESO_FRAME_DARK_B, 0.92)

    frame.inner = WINDOW_MANAGER:CreateControl(prefix .. "_Inner", parent, CT_BACKDROP)
    frame.inner:SetAnchor(TOPLEFT, parent, TOPLEFT, -3, -3)
    frame.inner:SetDimensions(math.max(1, (width or 1) + 6), math.max(1, (height or 1) + 6))
    frame.inner:SetCenterColor(0, 0, 0, 0)
    frame.inner:SetEdgeColor(ESO_FRAME_GOLD_R, ESO_FRAME_GOLD_G, ESO_FRAME_GOLD_B, 0.72)

    frame.top = CreateFrameLine(parent, prefix .. "_Top", TOPLEFT, TOPLEFT, -2, -2, math.max(1, (width or 1) + 4), 1, 0.5373, 0.5176, 0.4157, 0.72)
    frame.left = CreateFrameLine(parent, prefix .. "_Left", TOPLEFT, TOPLEFT, -2, -2, 1, math.max(1, (height or 1) + 4), 0.5373, 0.5176, 0.4157, 0.72)
    frame.right = CreateFrameLine(parent, prefix .. "_Right", TOPRIGHT, TOPRIGHT, 2, -2, 1, math.max(1, (height or 1) + 4), 0.5373, 0.5176, 0.4157, 0.72)
    frame.bottom = CreateFrameLine(parent, prefix .. "_Bottom", BOTTOMLEFT, BOTTOMLEFT, -2, 2, math.max(1, (width or 1) + 4), 1, 0.5373, 0.5176, 0.4157, 0.72)

    return frame
end

local function ResizeESOFrame(frame, width, height)
    if not frame then return end

    width = math.max(1, tonumber(width) or 1)
    height = math.max(1, tonumber(height) or 1)

    if frame.outer then
        frame.outer:SetDimensions(math.max(1, width + 8), math.max(1, height + 8))
    end

    if frame.inner then
        frame.inner:SetDimensions(math.max(1, width + 6), math.max(1, height + 6))
    end

    if frame.top then frame.top:SetDimensions(math.max(1, width + 4), 1) end
    if frame.left then frame.left:SetDimensions(1, math.max(1, height + 4)) end
    if frame.right then frame.right:SetDimensions(1, math.max(1, height + 4)) end
    if frame.bottom then frame.bottom:SetDimensions(math.max(1, width + 4), 1) end
end

local TRACKER_PAGE_TITLES = {
    "Session Overview",
    "PvP Buddy Lifetime",
    "Opponents / Rivals",
    "Abilities / Death Causes",
}

local function TrackerCreateModuleBox(parent, prefix, x, y, w, h, title)
    local box = TrackerCreateBackdrop(parent, prefix .. "_Box", x, y, w, h, 0, 0, 0, 0.74, 0.85, 0.85, 0.85, 0.90)
    local header = TrackerCreateHeader(parent, prefix .. "_Header", x + 12, y + 8, w - 24, 28, title or "")
    return box, header
end

local function TrackerCreateStatRow(parent, prefix, x, y, labelText, valueText, labelWidth, valueWidth)
    local label = TrackerCreateLabel(parent, prefix .. "_Label", x, y, labelWidth or 220, 24, "ZoFontGame", TEXT_ALIGN_LEFT, 0.95, 0.85, 0.55, 1)
    label:SetText(labelText or "")

    local value = TrackerCreateLabel(parent, prefix .. "_Value", x + (labelWidth or 220) + 6, y, valueWidth or 120, 24, "ZoFontGame", TEXT_ALIGN_RIGHT, 0.92, 0.92, 0.92, 1)
    value:SetText(valueText or "")
    return label, value
end

local function TrackerCreateSubHeader(parent, prefix, x, y, w, textValue)
    local label = TrackerCreateLabel(parent, prefix, x, y, w, 24, "ZoFontGameBold", TEXT_ALIGN_LEFT, 0.90, 0.90, 0.90, 1)
    label:SetText(textValue or "")
    return label
end

local function TrackerCreateTinyValue(parent, prefix, x, y, w, textValue, align)
    local label = TrackerCreateLabel(parent, prefix, x, y, w, 22, "ZoFontGameSmall", align or TEXT_ALIGN_LEFT, 0.92, 0.92, 0.92, 1)
    label:SetText(textValue or "")
    return label
end

local function TrackerCreateDivider(parent, prefix, x, y, w)
    local line = WINDOW_MANAGER:CreateControl(prefix, parent, CT_TEXTURE)
    line:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    line:SetDimensions(w, 1)
    line:SetColor(0.35, 0.35, 0.35, 0.65)
    return line
end

local function TrackerSetCurrentPage(page)
    if not CHX.ui or not CHX.ui.statsPanel then return end

    local tracker = CHX.ui.statsPanel
    local totalPages = #TRACKER_PAGE_TITLES
    local targetPage = math.floor(tonumber(page) or 1)

    if targetPage < 1 then targetPage = totalPages end
    if targetPage > totalPages then targetPage = 1 end

    tracker.currentPage = targetPage

    if tracker.pages then
        for i = 1, #tracker.pages do
            if tracker.pages[i] then
                tracker.pages[i]:SetHidden(i ~= targetPage)
            end
        end
    end

    if tracker.pageText then
        tracker.pageText:SetText(string.format("Page %d / %d", targetPage, totalPages))
    end

    if tracker.fightTitle then
        tracker.fightTitle:SetText(TRACKER_PAGE_TITLES[targetPage] or "")
    end

    if tracker.bottomStatusText then
        tracker.bottomStatusText:SetText("")
    end

    if CHX.saved then
        CHX.saved.statsPanelPage = targetPage
    end
end

local function TrackerCyclePage(delta)
    if not CHX.ui or not CHX.ui.statsPanel then return end
    local tracker = CHX.ui.statsPanel
    local current = tonumber(tracker.currentPage) or tonumber(CHX.saved and CHX.saved.statsPanelPage) or 1
    TrackerSetCurrentPage(current + (tonumber(delta) or 0))
end

local SetStatsPanelWindowVisible

local function AddStatsPanelSceneKeybinds()
    if not KEYBIND_STRIP or type(KEYBIND_STRIP.AddKeybindButtonGroup) ~= "function" then return end

    CHX.statsPanelSceneKeybinds = CHX.statsPanelSceneKeybinds or {
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = "Previous Page",
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            visible = function()
                return CHX.trackerSceneActive == true
            end,
            callback = function()
                TrackerCyclePage(-1)
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = "Next Page",
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            visible = function()
                return CHX.trackerSceneActive == true
            end,
            callback = function()
                TrackerCyclePage(1)
            end,
        },
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = "Close",
            keybind = "UI_SHORTCUT_NEGATIVE",
            visible = function()
                return CHX.trackerSceneActive == true
            end,
            callback = function()
                SetStatsPanelWindowVisible(false)
            end,
        },
    }

    if CHX.statsPanelSceneKeybindAdded then
        if type(KEYBIND_STRIP.UpdateKeybindButtonGroup) == "function" then
            pcall(function()
                KEYBIND_STRIP:UpdateKeybindButtonGroup(CHX.statsPanelSceneKeybinds)
            end)
        end
        return
    end

    local ok = pcall(function()
        KEYBIND_STRIP:AddKeybindButtonGroup(CHX.statsPanelSceneKeybinds)
    end)

    if ok then
        CHX.statsPanelSceneKeybindAdded = true
    end
end

local function RemoveStatsPanelSceneKeybinds()
    if not KEYBIND_STRIP or type(KEYBIND_STRIP.RemoveKeybindButtonGroup) ~= "function" then
        CHX.statsPanelSceneKeybindAdded = false
        return
    end

    if not CHX.statsPanelSceneKeybindAdded or not CHX.statsPanelSceneKeybinds then
        return
    end

    pcall(function()
        KEYBIND_STRIP:RemoveKeybindButtonGroup(CHX.statsPanelSceneKeybinds)
    end)

    CHX.statsPanelSceneKeybindAdded = false
end

local function GetCurrentSceneNameSafe()
    if not SCENE_MANAGER then return "" end

    if type(SCENE_MANAGER.GetCurrentSceneName) == "function" then
        local ok, name = pcall(function()
            return SCENE_MANAGER:GetCurrentSceneName()
        end)
        if ok and name then return tostring(name) end
    end

    if type(SCENE_MANAGER.GetCurrentScene) == "function" then
        local ok, scene = pcall(function()
            return SCENE_MANAGER:GetCurrentScene()
        end)

        if ok and scene then
            if type(scene.GetName) == "function" then
                local okName, name = pcall(function()
                    return scene:GetName()
                end)
                if okName and name then return tostring(name) end
            end

            if scene.name then return tostring(scene.name) end
        end
    end

    if SCENE_MANAGER.currentScene then
        local scene = SCENE_MANAGER.currentScene

        if type(scene.GetName) == "function" then
            local ok, name = pcall(function()
                return scene:GetName()
            end)
            if ok and name then return tostring(name) end
        end

        if scene.name then return tostring(scene.name) end
    end

    return ""
end

local function SceneNameLooksLikeCampaigns(sceneName)
    sceneName = string.lower(tostring(sceneName or ""))
    if sceneName == "" then return false end
    if string.find(sceneName, "pvpbuddy") or string.find(sceneName, "statspanel") then return false end

    return string.find(sceneName, "campaign") ~= nil
        or string.find(sceneName, "ava") ~= nil
        or string.find(sceneName, "alliancewar") ~= nil
end

local function IsKnownCampaignSceneShowing()
    if not SCENE_MANAGER then return false end

    local sceneNames = {
        "gamepad_campaign_browser",
        "campaignBrowserGamepad",
        "campaign_browser_gamepad",
        "gamepad_campaign_overview",
        "campaignOverviewGamepad",
        "campaign_overview_gamepad",
        "gamepad_campaigns",
        "campaignsGamepad",
        "campaigns_gamepad",
        "campaign_root_gamepad",
        "gamepad_campaign_root",
        "allianceWarGamepad",
        "gamepad_alliance_war",
    }

    for i = 1, #sceneNames do
        local name = sceneNames[i]

        if type(SCENE_MANAGER.IsShowing) == "function" then
            local ok, showing = pcall(function()
                return SCENE_MANAGER:IsShowing(name)
            end)
            if ok and showing then
                CHX.debug.campaignSceneName = name
                return true
            end
        end

        if type(SCENE_MANAGER.GetScene) == "function" then
            local ok, scene = pcall(function()
                return SCENE_MANAGER:GetScene(name)
            end)

            if ok and scene and type(scene.GetState) == "function" then
                local okState, state = pcall(function()
                    return scene:GetState()
                end)
                if okState and (state == SCENE_SHOWING or state == SCENE_SHOWN) then
                    CHX.debug.campaignSceneName = name
                    return true
                end
            end
        end
    end

    return false
end

local function IsCampaignMenuSceneActive()
    if CHX.trackerSceneActive then return false end

    local currentSceneName = GetCurrentSceneNameSafe()
    CHX.debug.campaignSceneName = currentSceneName

    if SceneNameLooksLikeCampaigns(currentSceneName) then
        return true
    end

    if IsKnownCampaignSceneShowing() then
        return true
    end

    return false
end

local function BuildCampaignMenuKeybinds()
    CHX.campaignMenuKeybinds = CHX.campaignMenuKeybinds or {
        {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            name = "Open PvP Buddy",
            keybind = "UI_SHORTCUT_TERTIARY",
            visible = function()
                return IsCampaignMenuSceneActive()
            end,
            callback = function()
                SetStatsPanelWindowVisible(true)
            end,
        },
    }

    return CHX.campaignMenuKeybinds
end

local function AddCampaignMenuKeybind()
    if not KEYBIND_STRIP or type(KEYBIND_STRIP.AddKeybindButtonGroup) ~= "function" then
        CHX.debug.campaignKeybindError = "KEYBIND_STRIP missing"
        return false
    end

    if not IsCampaignMenuSceneActive() then
        return false
    end

    local keybinds = BuildCampaignMenuKeybinds()

    if CHX.campaignMenuKeybindAdded then
        if type(KEYBIND_STRIP.UpdateKeybindButtonGroup) == "function" then
            pcall(function()
                KEYBIND_STRIP:UpdateKeybindButtonGroup(keybinds)
            end)
        end
        CHX.debug.campaignKeybindAdded = true
        return true
    end

    local ok, err = pcall(function()
        KEYBIND_STRIP:AddKeybindButtonGroup(keybinds)
    end)

    if ok then
        CHX.campaignMenuKeybindAdded = true
        CHX.debug.campaignKeybindAdded = true
        CHX.debug.campaignKeybindError = ""
        return true
    end

    CHX.debug.campaignKeybindError = tostring(err)
    return false
end

local function RemoveCampaignMenuKeybind()
    if not KEYBIND_STRIP or type(KEYBIND_STRIP.RemoveKeybindButtonGroup) ~= "function" then
        CHX.campaignMenuKeybindAdded = false
        CHX.debug.campaignKeybindAdded = false
        return
    end

    if not CHX.campaignMenuKeybindAdded then return end

    pcall(function()
        KEYBIND_STRIP:RemoveKeybindButtonGroup(BuildCampaignMenuKeybinds())
    end)

    CHX.campaignMenuKeybindAdded = false
    CHX.debug.campaignKeybindAdded = false
end

local function CampaignMenuKeybindUpdate()
    if IsCampaignMenuSceneActive() then
        AddCampaignMenuKeybind()
    else
        RemoveCampaignMenuKeybind()
    end
end

local function StartCampaignMenuKeybindWatcher()
    if not EVENT_MANAGER then
        CHX.debug.campaignKeybindError = "EVENT_MANAGER missing"
        return false
    end

    EVENT_MANAGER:RegisterForUpdate(
        ADDON_NAME .. "_CampaignMenuKeybindWatcher",
        400,
        CampaignMenuKeybindUpdate
    )

    CHX.debug.campaignKeybindError = "campaign keybind watcher enabled"
    return true
end

local function UpdateStatsPanelShellInfo()
    if not CHX.ui or not CHX.ui.statsPanel then return end

    local tracker = CHX.ui.statsPanel
    local className, classIcon = TrackerGetClassInfo()
    local characterName = TrackerGetCharacterName()
    local cp = TrackerGetChampionPoints()
    local accountName = TrackerGetAccountName()

    if tracker.classIcon then
        if classIcon and classIcon ~= "" then
            tracker.classIcon:SetTexture(classIcon)
            tracker.classIcon:SetHidden(false)
        else
            tracker.classIcon:SetHidden(true)
        end
    end

    if tracker.identityText then
        local identity = characterName

        if cp and cp > 0 then
            if identity ~= "" then identity = identity .. "  •  " end
            identity = identity .. "CP " .. tostring(cp)
        end

        if className and className ~= "" then
            if identity ~= "" then identity = identity .. "  •  " end
            identity = identity .. className
        end

        tracker.identityText:SetText(identity)
    end

    if tracker.accountText then
        tracker.accountText:SetText(accountName or "")
    end

    if tracker.dateTimeText then
        tracker.dateTimeText:SetText(TrackerGetPatchText() .. "  " .. TrackerGetDateText() .. "  " .. TrackerGetClockText())
    end

    TrackerSetCurrentPage((CHX.saved and CHX.saved.statsPanelPage) or tracker.currentPage or 1)
end

local function CreateStatsPanelPageOne(parent)
    local page = WINDOW_MANAGER:CreateControl("PVPBuddy_StatsPanel_Page1", parent, CT_CONTROL)
    page:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, TRACKER_PAGE_Y)
    page:SetDimensions(TRACKER_WINDOW_WIDTH, TRACKER_PAGE_HEIGHT)

    TrackerCreateModuleBox(page, "PVPBuddy_CT1_Summary", 14, 8, 500, 330, "Session Overview")
    TrackerCreateStatRow(page, "PVPBuddy_CT1_Time", 28, 48, "Time In PvP:", "0:00", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT1_Combat", 28, 78, "In Combat:", "0:00", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT1_Kills", 28, 118, "Kills:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT1_Deaths", 28, 148, "Deaths:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT1_KB", 28, 178, "Killing Blows:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT1_KDR", 28, 208, "K/D Ratio:", "0.00", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT1_AP", 28, 238, "AP Gained:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT1_APM", 28, 268, "AP / Min:", "0", 220, 210)

    TrackerCreateModuleBox(page, "PVPBuddy_CT1_Streaks", 522, 8, 380, 330, "Session Streaks")
    TrackerCreateStatRow(page, "PVPBuddy_CT1_CurKill", 536, 48, "Current Kill Streak:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT1_BestKill", 536, 78, "Best Kill Streak:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT1_CurKB", 536, 118, "Current KB Streak:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT1_BestKB", 536, 148, "Best KB Streak:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT1_CurDeath", 536, 188, "Current Death Streak:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT1_WorstDeath", 536, 218, "Worst Death Streak:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT1_Avenge", 536, 258, "Avenge Kills:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT1_Revenge", 536, 288, "Revenge Kills:", "0", 190, 128)

    TrackerCreateModuleBox(page, "PVPBuddy_CT1_Breakdown", 910, 8, 656, 330, "Session Breakdown")
    TrackerCreateSubHeader(page, "PVPBuddy_CT1_AllianceSub", 924, 48, 220, "Alliance Breakdown")
    TrackerCreateColumn(page, "PVPBuddy_CT1_AllianceCol0", 924, 76, 180, 24, "Alliance", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT1_AllianceCol1", 1128, 76, 70, 24, "K", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT1_AllianceCol2", 1206, 76, 70, 24, "D", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT1_AllianceCol3", 1284, 76, 70, 24, "KB", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_ADRow", 924, 104, 180, "Aldmeri Dominion")
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_ADK", 1128, 104, 70, "0", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_ADD", 1206, 104, 70, "0", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_ADKB", 1284, 104, 70, "0", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_EPRow", 924, 128, 180, "Ebonheart Pact")
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_EPK", 1128, 128, 70, "0", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_EPD", 1206, 128, 70, "0", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_EPKB", 1284, 128, 70, "0", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_DCRow", 924, 152, 180, "Daggerfall Covenant")
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_DCK", 1128, 152, 70, "0", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_DCD", 1206, 152, 70, "0", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_DCKB", 1284, 152, 70, "0", TEXT_ALIGN_RIGHT)
    TrackerCreateDivider(page, "PVPBuddy_CT1_BreakDivider", 924, 188, 606)
    TrackerCreateSubHeader(page, "PVPBuddy_CT1_ClassSub", 924, 204, 220, "Class Snapshot")
    TrackerCreateColumn(page, "PVPBuddy_CT1_ClassCol0", 924, 232, 240, 24, "Class", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT1_ClassCol1", 1180, 232, 84, 24, "K", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT1_ClassCol2", 1270, 232, 84, 24, "D", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT1_ClassCol3", 1360, 232, 84, 24, "KB", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Class1", 924, 260, 240, "Most Killed Class")
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Class1V", 1180, 260, 264, "--", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Class2", 924, 284, 240, "Most Dangerous Class")
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Class2V", 1180, 284, 264, "--", TEXT_ALIGN_RIGHT)

    TrackerCreateModuleBox(page, "PVPBuddy_CT1_Events", 14, 348, 500, 430, "Recent Session Events")
    TrackerCreateColumn(page, "PVPBuddy_CT1_EventCol0", 28, 380, 250, 24, "Event", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT1_EventCol1", 292, 380, 180, 24, "Value", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Event1", 28, 414, 220, "Last Kill")
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Event1V", 254, 414, 218, "--", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Event2", 28, 438, 220, "Last Death")
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Event2V", 254, 438, 218, "--", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Event3", 28, 462, 220, "Last KB Ability")
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Event3V", 254, 462, 218, "--", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Event4", 28, 486, 220, "Last Death Ability")
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Event4V", 254, 486, 218, "--", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Event5", 28, 510, 220, "Biggest Hit Done")
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Event5V", 254, 510, 218, "0", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Event6", 28, 534, 220, "Biggest Hit Taken")
    TrackerCreateTinyValue(page, "PVPBuddy_CT1_Event6V", 254, 534, 218, "0", TEXT_ALIGN_RIGHT)

    TrackerCreateModuleBox(page, "PVPBuddy_CT1_Opponents", 522, 348, 1044, 430, "Session Opponents")
    TrackerCreateColumn(page, "PVPBuddy_CT1_OppCol0", 536, 380, 290, 24, "Name", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT1_OppCol1", 832, 380, 120, 24, "Alliance", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT1_OppCol2", 960, 380, 140, 24, "Class", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT1_OppCol3", 1110, 380, 56, 24, "K", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT1_OppCol4", 1172, 380, 56, 24, "D", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT1_OppCol5", 1234, 380, 62, 24, "KB", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT1_OppCol6", 1302, 380, 110, 24, "Last Seen", TEXT_ALIGN_RIGHT)
    for i = 1, 8 do
        local y = 410 + ((i - 1) * 26)
        TrackerCreateTinyValue(page, "PVPBuddy_CT1_OppR" .. tostring(i) .. "Name", 536, y, 290, "")
        TrackerCreateTinyValue(page, "PVPBuddy_CT1_OppR" .. tostring(i) .. "Alliance", 832, y, 120, "")
        TrackerCreateTinyValue(page, "PVPBuddy_CT1_OppR" .. tostring(i) .. "Class", 960, y, 140, "")
        TrackerCreateTinyValue(page, "PVPBuddy_CT1_OppR" .. tostring(i) .. "K", 1110, y, 56, "", TEXT_ALIGN_RIGHT)
        TrackerCreateTinyValue(page, "PVPBuddy_CT1_OppR" .. tostring(i) .. "D", 1172, y, 56, "", TEXT_ALIGN_RIGHT)
        TrackerCreateTinyValue(page, "PVPBuddy_CT1_OppR" .. tostring(i) .. "KB", 1234, y, 62, "", TEXT_ALIGN_RIGHT)
        TrackerCreateTinyValue(page, "PVPBuddy_CT1_OppR" .. tostring(i) .. "Last", 1302, y, 110, "", TEXT_ALIGN_RIGHT)
    end
    return page
end

local function CreateStatsPanelPageTwo(parent)
    local page = WINDOW_MANAGER:CreateControl("PVPBuddy_StatsPanel_Page2", parent, CT_CONTROL)
    page:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, TRACKER_PAGE_Y)
    page:SetDimensions(TRACKER_WINDOW_WIDTH, TRACKER_PAGE_HEIGHT)

    TrackerCreateModuleBox(page, "PVPBuddy_CT2_Overview", 14, 8, 500, 330, "PvP Buddy Lifetime")
    TrackerCreateStatRow(page, "PVPBuddy_CT2_LKills", 28, 48, "PvP Buddy Kills:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT2_LDeaths", 28, 78, "PvP Buddy Deaths:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT2_LKB", 28, 108, "PvP Buddy KBs:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT2_LKDR", 28, 138, "PvP Buddy K/D Ratio:", "0.00", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT2_LAP", 28, 168, "PvP Buddy AP:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT2_LUnique", 28, 198, "Unique Opponents:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT2_LTopClass", 28, 238, "Top Killed Class:", "--", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT2_LDangerClass", 28, 268, "Most Dangerous Class:", "--", 220, 210)

    TrackerCreateModuleBox(page, "PVPBuddy_CT2_Records", 522, 8, 380, 330, "PvP Buddy Records")
    TrackerCreateStatRow(page, "PVPBuddy_CT2_BestKill", 536, 48, "Best Kill Streak:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT2_BestKB", 536, 78, "Best KB Streak:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT2_WorstDeath", 536, 108, "Worst Death Streak:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT2_BestSessionKills", 536, 148, "Most Kills / Session:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT2_BestSessionKB", 536, 178, "Most KBs / Session:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT2_BestSessionAP", 536, 208, "Most AP / Session:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT2_BigHit", 536, 248, "Biggest Hit Done:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT2_BigTaken", 536, 278, "Biggest Hit Taken:", "0", 190, 128)

    TrackerCreateModuleBox(page, "PVPBuddy_CT2_Breakdown", 910, 8, 656, 330, "PvP Buddy Breakdown")
    TrackerCreateSubHeader(page, "PVPBuddy_CT2_AllianceSub", 924, 48, 220, "Alliance Totals")
    TrackerCreateColumn(page, "PVPBuddy_CT2_AllianceCol0", 924, 76, 180, 24, "Alliance", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT2_AllianceCol1", 1128, 76, 70, 24, "K", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT2_AllianceCol2", 1206, 76, 70, 24, "D", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT2_AllianceCol3", 1284, 76, 70, 24, "KB", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT2_ADRow", 924, 104, 180, "Aldmeri Dominion")
    TrackerCreateTinyValue(page, "PVPBuddy_CT2_ADV", 1128, 104, 226, "0 / 0 / 0", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT2_EPRow", 924, 128, 180, "Ebonheart Pact")
    TrackerCreateTinyValue(page, "PVPBuddy_CT2_EPV", 1128, 128, 226, "0 / 0 / 0", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT2_DCRow", 924, 152, 180, "Daggerfall Covenant")
    TrackerCreateTinyValue(page, "PVPBuddy_CT2_DCV", 1128, 152, 226, "0 / 0 / 0", TEXT_ALIGN_RIGHT)
    TrackerCreateDivider(page, "PVPBuddy_CT2_BreakDivider", 924, 188, 606)
    TrackerCreateSubHeader(page, "PVPBuddy_CT2_SourceSub", 924, 204, 220, "Data Source")
    TrackerCreateTinyValue(page, "PVPBuddy_CT2_Source1", 924, 232, 360, "Source: PvP Buddy tracked stats")
    TrackerCreateTinyValue(page, "PVPBuddy_CT2_Source2", 924, 256, 520, "Counts start from when PvP Buddy is installed/updated.")

    TrackerCreateModuleBox(page, "PVPBuddy_CT2_Notes", 14, 348, 500, 430, "Lifetime Rival Tracking")
    TrackerCreateColumn(page, "PVPBuddy_CT2_RivalCol0", 28, 382, 58, 24, "Rank", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT2_RivalCol1", 92, 382, 224, 24, "Player", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT2_RivalCol2", 326, 382, 82, 24, "Alliance", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT2_RivalCol3", 420, 382, 60, 24, "Deaths", TEXT_ALIGN_RIGHT)

    for i = 1, 10 do
        local y = 410 + ((i - 1) * 30)

        TrackerCreateTinyValue(page, "PVPBuddy_CT2_RivalR" .. tostring(i) .. "Rank", 28, y, 58, FormatOrdinal(i))
        TrackerCreateTinyValue(page, "PVPBuddy_CT2_RivalR" .. tostring(i) .. "Name", 92, y, 224, "")
        TrackerCreateTexture(page, "PVPBuddy_CT2_RivalR" .. tostring(i) .. "AllianceIcon", 326, y + 1, 20, 20)
        TrackerCreateTinyValue(page, "PVPBuddy_CT2_RivalR" .. tostring(i) .. "Alliance", 350, y, 50, "")
        TrackerCreateTinyValue(page, "PVPBuddy_CT2_RivalR" .. tostring(i) .. "Deaths", 420, y, 60, "", TEXT_ALIGN_RIGHT)
    end

    TrackerCreateModuleBox(page, "PVPBuddy_CT2_SummaryTable", 522, 348, 1044, 430, "PvP Buddy Summary Table")
    TrackerCreateColumn(page, "PVPBuddy_CT2_SumCol0", 536, 380, 320, 24, "Statistic", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT2_SumCol1", 864, 380, 180, 24, "Value", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT2_SumCol2", 1052, 380, 230, 24, "Source", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT2_SumCol3", 1290, 380, 200, 24, "Notes", TEXT_ALIGN_LEFT)
    return page
end

local function CreateStatsPanelPageThree(parent)
    local page = WINDOW_MANAGER:CreateControl("PVPBuddy_StatsPanel_Page3", parent, CT_CONTROL)
    page:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, TRACKER_PAGE_Y)
    page:SetDimensions(TRACKER_WINDOW_WIDTH, TRACKER_PAGE_HEIGHT)

    TrackerCreateModuleBox(page, "PVPBuddy_CT3_Summary", 14, 8, 500, 330, "Rival Summary")
    TrackerCreateStatRow(page, "PVPBuddy_CT3_TopKill", 28, 48, "Most Killed Enemy:", "--", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT3_TopDanger", 28, 78, "Enemy Killed You Most:", "--", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT3_TopKB", 28, 108, "Most KB'd Enemy:", "--", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT3_Unique", 28, 138, "Unique Opponents:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT3_Revenge", 28, 178, "Revenge Kills:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT3_Avenge", 28, 208, "Avenge Kills:", "0", 220, 210)

    TrackerCreateModuleBox(page, "PVPBuddy_CT3_Current", 522, 8, 380, 330, "Current / Last Rival")
    TrackerCreateStatRow(page, "PVPBuddy_CT3_LastKiller", 536, 48, "Last Killer:", "--", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT3_LastVictim", 536, 78, "Last Victim:", "--", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT3_TopRival", 536, 108, "Top Rival:", "--", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT3_RivalClass", 536, 148, "Rival Class:", "--", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT3_RivalAlliance", 536, 178, "Rival Alliance:", "--", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT3_Encounters", 536, 208, "Encounters:", "0", 190, 128)

    TrackerCreateModuleBox(page, "PVPBuddy_CT3_Details", 910, 8, 656, 330, "Enemy Details")
    TrackerCreateColumn(page, "PVPBuddy_CT3_DetailCol0", 924, 52, 220, 24, "Player", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT3_DetailCol1", 1148, 52, 110, 24, "Alliance", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT3_DetailCol2", 1262, 52, 120, 24, "Class", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT3_DetailCol3", 1386, 52, 60, 24, "K", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT3_DetailCol4", 1450, 52, 60, 24, "D", TEXT_ALIGN_RIGHT)
    TrackerCreateTinyValue(page, "PVPBuddy_CT3_DetailNote", 924, 92, 400, "Select an opponent row later to populate this box.")

    TrackerCreateModuleBox(page, "PVPBuddy_CT3_Events", 14, 348, 500, 430, "Recent Rival Events")
    TrackerCreateColumn(page, "PVPBuddy_CT3_EventCol0", 28, 380, 110, 24, "Time", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT3_EventCol1", 146, 380, 326, 24, "Event", TEXT_ALIGN_LEFT)
    for i = 1, 8 do
        local y = 410 + ((i - 1) * 26)
        TrackerCreateTinyValue(page, "PVPBuddy_CT3_EventR" .. tostring(i) .. "Time", 28, y, 110, "")
        TrackerCreateTinyValue(page, "PVPBuddy_CT3_EventR" .. tostring(i) .. "Text", 146, y, 326, "")
    end

    TrackerCreateModuleBox(page, "PVPBuddy_CT3_Table", 522, 348, 1044, 430, "Opponent Table")
    TrackerCreateColumn(page, "PVPBuddy_CT3_TabCol0", 536, 380, 292, 24, "Name", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT3_TabCol1", 834, 380, 114, 24, "Alliance", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT3_TabCol2", 954, 380, 130, 24, "Class", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT3_TabCol3", 1090, 380, 56, 24, "K", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT3_TabCol4", 1152, 380, 56, 24, "D", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT3_TabCol5", 1214, 380, 62, 24, "KB", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT3_TabCol6", 1282, 380, 92, 24, "Last Seen", TEXT_ALIGN_RIGHT)
    for i = 1, 8 do
        local y = 410 + ((i - 1) * 26)
        TrackerCreateTinyValue(page, "PVPBuddy_CT3_TabR" .. tostring(i) .. "Name", 536, y, 292, "")
        TrackerCreateTinyValue(page, "PVPBuddy_CT3_TabR" .. tostring(i) .. "Alliance", 834, y, 114, "")
        TrackerCreateTinyValue(page, "PVPBuddy_CT3_TabR" .. tostring(i) .. "Class", 954, y, 130, "")
        TrackerCreateTinyValue(page, "PVPBuddy_CT3_TabR" .. tostring(i) .. "K", 1090, y, 56, "", TEXT_ALIGN_RIGHT)
        TrackerCreateTinyValue(page, "PVPBuddy_CT3_TabR" .. tostring(i) .. "D", 1152, y, 56, "", TEXT_ALIGN_RIGHT)
        TrackerCreateTinyValue(page, "PVPBuddy_CT3_TabR" .. tostring(i) .. "KB", 1214, y, 62, "", TEXT_ALIGN_RIGHT)
        TrackerCreateTinyValue(page, "PVPBuddy_CT3_TabR" .. tostring(i) .. "Last", 1282, y, 92, "", TEXT_ALIGN_RIGHT)
    end
    return page
end

local function CreateStatsPanelPageFour(parent)
    local page = WINDOW_MANAGER:CreateControl("PVPBuddy_StatsPanel_Page4", parent, CT_CONTROL)
    page:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, TRACKER_PAGE_Y)
    page:SetDimensions(TRACKER_WINDOW_WIDTH, TRACKER_PAGE_HEIGHT)

    TrackerCreateModuleBox(page, "PVPBuddy_CT4_KillSummary", 14, 8, 500, 330, "Kill Summary")
    TrackerCreateStatRow(page, "PVPBuddy_CT4_TotalKills", 28, 48, "Total Kills:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT4_TotalKB", 28, 78, "Total KBs:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT4_TopKBAbility", 28, 118, "Top KB Ability:", "--", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT4_BigKB", 28, 148, "Biggest KB:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT4_AvgKB", 28, 178, "Average KB Hit:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT4_UltKB", 28, 208, "Ultimate KBs:", "0", 220, 210)
    TrackerCreateStatRow(page, "PVPBuddy_CT4_ProcKB", 28, 238, "Proc KBs:", "0", 220, 210)

    TrackerCreateModuleBox(page, "PVPBuddy_CT4_DeathSummary", 522, 8, 380, 330, "Death Summary")
    TrackerCreateStatRow(page, "PVPBuddy_CT4_TotalDeaths", 536, 48, "Total Deaths:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT4_TopDeathAbility", 536, 78, "Top Death Ability:", "--", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT4_LastDeathAbility", 536, 108, "Last Death Ability:", "--", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT4_SiegeDeaths", 536, 148, "Siege Deaths:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT4_UltDeaths", 536, 178, "Ultimate Deaths:", "0", 190, 128)
    TrackerCreateStatRow(page, "PVPBuddy_CT4_ProcDeaths", 536, 208, "Proc Deaths:", "0", 190, 128)

    TrackerCreateModuleBox(page, "PVPBuddy_CT4_CauseBox", 910, 8, 656, 330, "Recent Death Causes")
    TrackerCreateColumn(page, "PVPBuddy_CT4_CauseCol0", 924, 52, 280, 24, "Ability", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT4_CauseCol1", 1210, 52, 120, 24, "Type", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT4_CauseCol2", 1336, 52, 64, 24, "Count", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT4_CauseCol3", 1406, 52, 104, 24, "Last", TEXT_ALIGN_RIGHT)
    for i = 1, 8 do
        local y = 82 + ((i - 1) * 26)
        TrackerCreateTinyValue(page, "PVPBuddy_CT4_CauseR" .. tostring(i) .. "Ability", 924, y, 280, "")
        TrackerCreateTinyValue(page, "PVPBuddy_CT4_CauseR" .. tostring(i) .. "Type", 1210, y, 120, "")
        TrackerCreateTinyValue(page, "PVPBuddy_CT4_CauseR" .. tostring(i) .. "Count", 1336, y, 64, "", TEXT_ALIGN_RIGHT)
        TrackerCreateTinyValue(page, "PVPBuddy_CT4_CauseR" .. tostring(i) .. "Last", 1406, y, 104, "", TEXT_ALIGN_RIGHT)
    end

    TrackerCreateModuleBox(page, "PVPBuddy_CT4_RecentDeaths", 14, 348, 500, 430, "Recent Deaths")
    TrackerCreateColumn(page, "PVPBuddy_CT4_DeathCol0", 28, 380, 172, 24, "Killer", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT4_DeathCol1", 206, 380, 180, 24, "Ability", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT4_DeathCol2", 392, 380, 80, 24, "Time", TEXT_ALIGN_RIGHT)
    for i = 1, 8 do
        local y = 410 + ((i - 1) * 26)
        TrackerCreateTinyValue(page, "PVPBuddy_CT4_DeathR" .. tostring(i) .. "Killer", 28, y, 172, "")
        TrackerCreateTinyValue(page, "PVPBuddy_CT4_DeathR" .. tostring(i) .. "Ability", 206, y, 180, "")
        TrackerCreateTinyValue(page, "PVPBuddy_CT4_DeathR" .. tostring(i) .. "Time", 392, y, 80, "", TEXT_ALIGN_RIGHT)
    end

    TrackerCreateModuleBox(page, "PVPBuddy_CT4_AbilityTable", 522, 348, 1044, 430, "Ability Table")
    TrackerCreateColumn(page, "PVPBuddy_CT4_AbiCol0", 536, 380, 264, 24, "Ability", TEXT_ALIGN_LEFT)
    TrackerCreateColumn(page, "PVPBuddy_CT4_AbiCol1", 806, 380, 50, 24, "K", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT4_AbiCol2", 862, 380, 58, 24, "KB", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT4_AbiCol3", 926, 380, 90, 24, "Deaths", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT4_AbiCol4", 1022, 380, 90, 24, "Avg", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT4_AbiCol5", 1118, 380, 90, 24, "Max", TEXT_ALIGN_RIGHT)
    TrackerCreateColumn(page, "PVPBuddy_CT4_AbiCol6", 1214, 380, 94, 24, "Crits", TEXT_ALIGN_RIGHT)
    for i = 1, 8 do
        local y = 410 + ((i - 1) * 26)
        TrackerCreateTinyValue(page, "PVPBuddy_CT4_AbiR" .. tostring(i) .. "Ability", 536, y, 264, "")
        TrackerCreateTinyValue(page, "PVPBuddy_CT4_AbiR" .. tostring(i) .. "K", 806, y, 50, "", TEXT_ALIGN_RIGHT)
        TrackerCreateTinyValue(page, "PVPBuddy_CT4_AbiR" .. tostring(i) .. "KB", 862, y, 58, "", TEXT_ALIGN_RIGHT)
        TrackerCreateTinyValue(page, "PVPBuddy_CT4_AbiR" .. tostring(i) .. "Deaths", 926, y, 90, "", TEXT_ALIGN_RIGHT)
        TrackerCreateTinyValue(page, "PVPBuddy_CT4_AbiR" .. tostring(i) .. "Avg", 1022, y, 90, "", TEXT_ALIGN_RIGHT)
        TrackerCreateTinyValue(page, "PVPBuddy_CT4_AbiR" .. tostring(i) .. "Max", 1118, y, 90, "", TEXT_ALIGN_RIGHT)
        TrackerCreateTinyValue(page, "PVPBuddy_CT4_AbiR" .. tostring(i) .. "Crits", 1214, y, 94, "", TEXT_ALIGN_RIGHT)
    end
    return page
end

local function CreateStatsPanelShell()
    if CHX.ui and CHX.ui.statsPanelWindow then
        return true
    end

    if not WINDOW_MANAGER or not GuiRoot then
        return false
    end

    CHX.ui = CHX.ui or {}

    local win = WINDOW_MANAGER:CreateTopLevelWindow("PVPBuddy_StatsPanelWindow")
    CHX.ui.statsPanelWindow = win

    win:SetDimensions(TRACKER_WINDOW_WIDTH, TRACKER_WINDOW_HEIGHT)
    win:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    win:SetHidden(true)
    win:SetMouseEnabled(true)
    win:SetMovable(false)
    win:SetClampedToScreen(true)

    if type(win.SetKeyboardEnabled) == "function" then
        win:SetKeyboardEnabled(true)
    end

    win:SetHandler("OnKeyDown", function(control, key)
        if key == 134 then
            if CHX.saved then
                CHX.saved.statsPanelWindowVisible = false
            end
            control:SetHidden(true)
        elseif key == 131 then
            TrackerCyclePage(-1)
        elseif key == 132 then
            TrackerCyclePage(1)
        end
    end)

    TrackerCreateBackdrop(win, "PVPBuddy_StatsPanel_Backdrop", 0, 0, TRACKER_WINDOW_WIDTH, TRACKER_WINDOW_HEIGHT, 0, 0, 0, 0.84, 0.85, 0.85, 0.85, 0.95)

    local classIcon = TrackerCreateTexture(win, "PVPBuddy_StatsPanel_ClassIcon", 18, 0, 48, 48)
    local identityText = TrackerCreateLabel(win, "PVPBuddy_StatsPanel_IdentityText", 80, 8, 760, 34, "ZoFontGameLargeBold", TEXT_ALIGN_LEFT, 0.92, 0.92, 0.92)
    local fightTitle = TrackerCreateLabel(win, "PVPBuddy_StatsPanel_FightTitle", 520, 10, 540, 38, "ZoFontGameLargeBold", TEXT_ALIGN_CENTER, 1, 1, 1)
    fightTitle:SetText("")

    local pageText = TrackerCreateLabel(win, "PVPBuddy_StatsPanel_PageText", 1280, 12, 270, 34, "ZoFontGameLargeBold", TEXT_ALIGN_RIGHT, 0.95, 0.85, 0.55)
    local pageHint = TrackerCreateLabel(win, "PVPBuddy_StatsPanel_PageHint", 1090, 16, 180, 28, "ZoFontGame", TEXT_ALIGN_RIGHT, 0.76, 0.76, 0.76)
    pageHint:SetText("LB/RB Page  •  B Close")
    local rawInputText = TrackerCreateLabel(win, "PVPBuddy_StatsPanel_RawInputText", 540, 42, 720, 24, "ZoFontGame", TEXT_ALIGN_CENTER, 0.76, 0.76, 0.76)
    rawInputText:SetText("")

    local accountText = TrackerCreateLabel(win, "PVPBuddy_StatsPanel_AccountText", 18, 830, 360, 28, "ZoFontGame", TEXT_ALIGN_LEFT, 0.76, 0.76, 0.76)
    local bottomStatusText = TrackerCreateLabel(win, "PVPBuddy_StatsPanel_BottomStatusText", 520, 830, 540, 28, "ZoFontGameLargeBold", TEXT_ALIGN_CENTER, 0.95, 0.85, 0.55)
    local dateTimeText = TrackerCreateLabel(win, "PVPBuddy_StatsPanel_DateTimeText", 940, 830, 610, 28, "ZoFontGame", TEXT_ALIGN_RIGHT, 0.76, 0.76, 0.76)

    local page1 = CreateStatsPanelPageOne(win)
    local page2 = CreateStatsPanelPageTwo(win)
    local page3 = CreateStatsPanelPageThree(win)
    local page4 = CreateStatsPanelPageFour(win)

    CHX.ui.statsPanel = {
        window = win,
        pages = { page1, page2, page3, page4 },
        classIcon = classIcon,
        identityText = identityText,
        accountText = accountText,
        fightTitle = fightTitle,
        bottomStatusText = bottomStatusText,
        dateTimeText = dateTimeText,
        pageText = pageText,
        pageHint = pageHint,
        rawInputText = rawInputText,
        currentPage = 1,
    }

    UpdateStatsPanelShellInfo()
    return true
end

local function RegisterStatsPanelScene()
    if CHX.statsPanelScene then return true end
    if not CHX.ui or not CHX.ui.statsPanelWindow then return false end

    if not SCENE_MANAGER or not ZO_Scene or not ZO_FadeSceneFragment then
        CHX.debug.trackerSceneAvailable = false
        CHX.debug.trackerSceneError = "scene API missing"
        return false
    end

    local ok, result = pcall(function()
        local scene = ZO_Scene:New(CHX.trackerSceneName, SCENE_MANAGER)
        local fragment = ZO_FadeSceneFragment:New(CHX.ui.statsPanelWindow)

        scene:AddFragment(fragment)

        scene:RegisterCallback("StateChange", function(oldState, newState)
            if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
                CHX.trackerSceneActive = true
                CHX.debug.trackerSceneActive = true
                CHX.debug.trackerSceneAvailable = true

                if CHX.saved then
                    CHX.saved.statsPanelWindowVisible = true
                end

                if CHX.ui and CHX.ui.statsPanelWindow then
                    CHX.ui.statsPanelWindow:SetHidden(false)
                    if type(CHX.ui.statsPanelWindow.TakeFocus) == "function" then
                        CHX.ui.statsPanelWindow:TakeFocus()
                    end
                end

                RemoveCampaignMenuKeybind()
                AddStatsPanelSceneKeybinds()
                UpdateStatsPanelShellInfo()

            elseif newState == SCENE_HIDING then
                RemoveStatsPanelSceneKeybinds()

            elseif newState == SCENE_HIDDEN then
                CHX.trackerSceneActive = false
                CHX.debug.trackerSceneActive = false
                RemoveStatsPanelSceneKeybinds()

                if CHX.saved then
                    CHX.saved.statsPanelWindowVisible = false
                end

                if CHX.ui and CHX.ui.statsPanelWindow then
                    CHX.ui.statsPanelWindow:SetHidden(true)
                end
            end
        end)

        return { scene = scene, fragment = fragment }
    end)

    if not ok then
        CHX.debug.trackerSceneAvailable = false
        CHX.debug.trackerSceneError = tostring(result)
        return false
    end

    CHX.statsPanelScene = result.scene
    CHX.statsPanelSceneFragment = result.fragment
    CHX.debug.trackerSceneAvailable = true
    CHX.debug.trackerSceneError = ""
    return true
end

SetStatsPanelWindowVisible = function(visible)
    if not CreateStatsPanelShell() then return end

    visible = visible == true

    if CHX.saved then
        CHX.saved.statsPanelWindowVisible = visible
    end

    UpdateStatsPanelShellInfo()

    if visible then
        RemoveCampaignMenuKeybind()

        if RegisterStatsPanelScene() and SCENE_MANAGER and type(SCENE_MANAGER.Show) == "function" then
            local ok = pcall(function()
                SCENE_MANAGER:Show(CHX.trackerSceneName)
            end)

            if ok then
                CHX.trackerSceneActive = true
                CHX.debug.trackerSceneActive = true
                AddStatsPanelSceneKeybinds()
                return
            end
        end

        -- Fallback if the scene system is blocked.
        CHX.debug.trackerSceneAvailable = false
        CHX.ui.statsPanelWindow:SetHidden(false)
        if type(CHX.ui.statsPanelWindow.TakeFocus) == "function" then
            CHX.ui.statsPanelWindow:TakeFocus()
        end
        return
    end

    if RegisterStatsPanelScene() and SCENE_MANAGER and type(SCENE_MANAGER.Hide) == "function" then
        local ok = pcall(function()
            SCENE_MANAGER:Hide(CHX.trackerSceneName)
        end)

        if ok then
            RemoveStatsPanelSceneKeybinds()
            return
        end
    end

    CHX.trackerSceneActive = false
    CHX.debug.trackerSceneActive = false
    RemoveStatsPanelSceneKeybinds()

    if CHX.ui and CHX.ui.statsPanelWindow then
        CHX.ui.statsPanelWindow:SetHidden(true)
    end
end

local function ToggleStatsPanelWindow()
    if not CreateStatsPanelShell() then return end

    local currentlyVisible = not CHX.ui.statsPanelWindow:IsHidden()
    SetStatsPanelWindowVisible(not currentlyVisible)
end

local function CreateUI()
    if CHX.ui then
        return true
    end

    if not WINDOW_MANAGER or not GuiRoot then
        CHX.debug.lastError = "WINDOW_MANAGER or GuiRoot missing"
        return false
    end

    local win = WINDOW_MANAGER:CreateTopLevelWindow("PVPBuddy_Window")
    win:SetDimensions(WINDOW_WIDTH, SCORE_HEIGHT + (ROW_HEIGHT * 6))
    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetClampedToScreen(true)
    win:SetHidden(true)
    win:SetHandler("OnMoveStop", function(control)
        if not CHX.saved then return end
        CHX.saved.x = control:GetLeft()
        CHX.saved.y = control:GetTop()
    end)

    -- Very light backing only for movement/legibility. The actual look is the
    -- compact PvP Buddy-style floating list, not a big framed panel.
    local bg = WINDOW_MANAGER:CreateControl("PVPBuddy_Window_BG", win, CT_BACKDROP)
    bg:SetAnchorFill(win)
    bg:SetCenterColor(0, 0, 0, 0.18)
    bg:SetEdgeColor(ESO_FRAME_DARK_R, ESO_FRAME_DARK_G, ESO_FRAME_DARK_B, 0.92)

    local mainFrame = CreateESOFrame(win, "PVPBuddy_Window_Frame", WINDOW_WIDTH, SCORE_HEIGHT + ROW_HEIGHT)

    local scoreBg = WINDOW_MANAGER:CreateControl("PVPBuddy_Score_BG", win, CT_BACKDROP)
    scoreBg:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
    scoreBg:SetDimensions(WINDOW_WIDTH, SCORE_HEIGHT)
    scoreBg:SetCenterColor(0, 0, 0, 0.34)
    scoreBg:SetEdgeColor(BORDER_R, BORDER_G, BORDER_B, ROW_BORDER_A)

    local pvpStatsRowBg = WINDOW_MANAGER:CreateControl("PVPBuddy_PvpStats_RowBG", win, CT_BACKDROP)
    pvpStatsRowBg:SetAnchor(TOPLEFT, win, TOPLEFT, 0, 0)
    pvpStatsRowBg:SetDimensions(WINDOW_WIDTH, STATS_ROW_HEIGHT)
    pvpStatsRowBg:SetCenterColor(0, 0, 0, 0.38)
    pvpStatsRowBg:SetEdgeColor(BORDER_R, BORDER_G, BORDER_B, ROW_BORDER_A)

    local pvpStatsText = CreateLabel(win, "PVPBuddy_PvpStats_Text", win, 8, 1, 190, STATS_ROW_HEIGHT, FONT_MAIN, TEXT_ALIGN_LEFT)
    pvpStatsText:SetColor(0.95, 0.95, 0.95, 1)
    pvpStatsText:SetText(FormatPvpStatsStatsText())

    local pvpStatsPerfText = CreateLabel(win, "PVPBuddy_PvpStats_PerfText", win, 206, 1, 108, STATS_ROW_HEIGHT, FONT_MAIN, TEXT_ALIGN_RIGHT)
    pvpStatsPerfText:SetColor(0.95, 0.95, 0.95, 1)
    pvpStatsPerfText:SetText(FormatPvpStatsPerformanceText())

    local scoreTime = CreateLabel(win, "PVPBuddy_Score_Time", win, 10, 44, 80, 28, FONT_MAIN, TEXT_ALIGN_LEFT)

    local scoreScrollIconDC = WINDOW_MANAGER:CreateControl("PVPBuddy_Score_ScrollIcon_DC", win, CT_TEXTURE)
    scoreScrollIconDC:SetAnchor(TOPLEFT, win, TOPLEFT, 76, 22)
    scoreScrollIconDC:SetDimensions(24, 24)
    scoreScrollIconDC:SetTexture("/esoui/art/campaign/overview_scrollicon_daggefall.dds")
    scoreScrollIconDC:SetColor(GetAllianceColorSafe(DC))

    local scoreScrollIconEP = WINDOW_MANAGER:CreateControl("PVPBuddy_Score_ScrollIcon_EP", win, CT_TEXTURE)
    scoreScrollIconEP:SetAnchor(TOPLEFT, win, TOPLEFT, 158, 22)
    scoreScrollIconEP:SetDimensions(24, 24)
    scoreScrollIconEP:SetTexture("/esoui/art/campaign/overview_scrollicon_ebonheart.dds")
    scoreScrollIconEP:SetColor(GetAllianceColorSafe(EP))

    local scoreScrollIconAD = WINDOW_MANAGER:CreateControl("PVPBuddy_Score_ScrollIcon_AD", win, CT_TEXTURE)
    scoreScrollIconAD:SetAnchor(TOPLEFT, win, TOPLEFT, 236, 22)
    scoreScrollIconAD:SetDimensions(24, 24)
    scoreScrollIconAD:SetTexture("/esoui/art/campaign/overview_scrollicon_aldmeri.dds")
    scoreScrollIconAD:SetColor(GetAllianceColorSafe(AD))

    local scoreScrollDC = CreateLabel(win, "PVPBuddy_Score_Scroll_DC", win, 98, 22, 26, 22, FONT_MAIN, TEXT_ALIGN_LEFT)
    local scoreScrollEP = CreateLabel(win, "PVPBuddy_Score_Scroll_EP", win, 180, 22, 26, 22, FONT_MAIN, TEXT_ALIGN_LEFT)
    local scoreScrollAD = CreateLabel(win, "PVPBuddy_Score_Scroll_AD", win, 258, 22, 26, 22, FONT_MAIN, TEXT_ALIGN_LEFT)

    local scoreIconDC = WINDOW_MANAGER:CreateControl("PVPBuddy_Score_Icon_DC", win, CT_TEXTURE)
    scoreIconDC:SetAnchor(TOPLEFT, win, TOPLEFT, 75, 44)
    scoreIconDC:SetDimensions(SCORE_ICON_SIZE, SCORE_ICON_SIZE)
    scoreIconDC:SetTexture(GetAllianceEmblem(DC))
    scoreIconDC:SetColor(GetAllianceColorSafe(DC))

    local scoreIconEP = WINDOW_MANAGER:CreateControl("PVPBuddy_Score_Icon_EP", win, CT_TEXTURE)
    scoreIconEP:SetAnchor(TOPLEFT, win, TOPLEFT, 163, 44)
    scoreIconEP:SetDimensions(SCORE_ICON_SIZE, SCORE_ICON_SIZE)
    scoreIconEP:SetTexture(GetAllianceEmblem(EP))
    scoreIconEP:SetColor(GetAllianceColorSafe(EP))

    local scoreIconAD = WINDOW_MANAGER:CreateControl("PVPBuddy_Score_Icon_AD", win, CT_TEXTURE)
    scoreIconAD:SetAnchor(TOPLEFT, win, TOPLEFT, 241, 44)
    scoreIconAD:SetDimensions(SCORE_ICON_SIZE, SCORE_ICON_SIZE)
    scoreIconAD:SetTexture(GetAllianceEmblem(AD))
    scoreIconAD:SetColor(GetAllianceColorSafe(AD))

    local scoreDC = CreateLabel(win, "PVPBuddy_Score_DC", win, 100, 44, 50, 28, FONT_MAIN, TEXT_ALIGN_LEFT)
    local scoreEP = CreateLabel(win, "PVPBuddy_Score_EP", win, 188, 44, 50, 28, FONT_MAIN, TEXT_ALIGN_LEFT)
    local scoreAD = CreateLabel(win, "PVPBuddy_Score_AD", win, 266, 44, 50, 28, FONT_MAIN, TEXT_ALIGN_LEFT)

    local lowPopTexture = "/esoui/art/ava/overview_icon_underdog_population.dds"
    local lowScoreTexture = "/esoui/art/ava/overview_icon_underdog_score.dds"

    local scoreLowPopDC = WINDOW_MANAGER:CreateControl("PVPBuddy_Score_LowPop_DC", win, CT_TEXTURE)
    scoreLowPopDC:SetAnchor(TOPLEFT, win, TOPLEFT, 50, 47)
    scoreLowPopDC:SetDimensions(24, 24)
    scoreLowPopDC:SetTexture(lowPopTexture)
    scoreLowPopDC:SetDrawLayer(3)
    scoreLowPopDC:SetColor(GetAllianceColorSafe(DC))
    scoreLowPopDC:SetHidden(true)

    local scoreLowScoreDC = WINDOW_MANAGER:CreateControl("PVPBuddy_Score_LowScore_DC", win, CT_TEXTURE)
    scoreLowScoreDC:SetAnchor(TOPLEFT, win, TOPLEFT, 52, 17)
    scoreLowScoreDC:SetDimensions(24, 24)
    scoreLowScoreDC:SetTexture(lowScoreTexture)
    scoreLowScoreDC:SetDrawLayer(3)
    scoreLowScoreDC:SetColor(GetAllianceColorSafe(DC))
    scoreLowScoreDC:SetHidden(true)

    local scoreLowPopEP = WINDOW_MANAGER:CreateControl("PVPBuddy_Score_LowPop_EP", win, CT_TEXTURE)
    scoreLowPopEP:SetAnchor(TOPLEFT, win, TOPLEFT, 138, 47)
    scoreLowPopEP:SetDimensions(24, 24)
    scoreLowPopEP:SetTexture(lowPopTexture)
    scoreLowPopEP:SetDrawLayer(3)
    scoreLowPopEP:SetColor(GetAllianceColorSafe(EP))
    scoreLowPopEP:SetHidden(true)

    local scoreLowScoreEP = WINDOW_MANAGER:CreateControl("PVPBuddy_Score_LowScore_EP", win, CT_TEXTURE)
    scoreLowScoreEP:SetAnchor(TOPLEFT, win, TOPLEFT, 134, 17)
    scoreLowScoreEP:SetDimensions(24, 24)
    scoreLowScoreEP:SetTexture(lowScoreTexture)
    scoreLowScoreEP:SetDrawLayer(3)
    scoreLowScoreEP:SetColor(GetAllianceColorSafe(EP))
    scoreLowScoreEP:SetHidden(true)

    local scoreLowPopAD = WINDOW_MANAGER:CreateControl("PVPBuddy_Score_LowPop_AD", win, CT_TEXTURE)
    scoreLowPopAD:SetAnchor(TOPLEFT, win, TOPLEFT, 216, 47)
    scoreLowPopAD:SetDimensions(24, 24)
    scoreLowPopAD:SetTexture(lowPopTexture)
    scoreLowPopAD:SetDrawLayer(3)
    scoreLowPopAD:SetColor(GetAllianceColorSafe(AD))
    scoreLowPopAD:SetHidden(true)

    local scoreLowScoreAD = WINDOW_MANAGER:CreateControl("PVPBuddy_Score_LowScore_AD", win, CT_TEXTURE)
    scoreLowScoreAD:SetAnchor(TOPLEFT, win, TOPLEFT, 212, 17)
    scoreLowScoreAD:SetDimensions(24, 24)
    scoreLowScoreAD:SetTexture(lowScoreTexture)
    scoreLowScoreAD:SetDrawLayer(3)
    scoreLowScoreAD:SetColor(GetAllianceColorSafe(AD))
    scoreLowScoreAD:SetHidden(true)

    scoreTime:SetColor(0.85, 0.85, 0.85, 1)
    scoreAD:SetColor(GetAllianceColorSafe(AD))
    scoreEP:SetColor(GetAllianceColorSafe(EP))
    scoreDC:SetColor(GetAllianceColorSafe(DC))
    scoreScrollAD:SetColor(GetAllianceColorSafe(AD))
    scoreScrollEP:SetColor(GetAllianceColorSafe(EP))
    scoreScrollDC:SetColor(GetAllianceColorSafe(DC))

    local killWin = WINDOW_MANAGER:CreateTopLevelWindow("PVPBuddy_KillWindow")
    killWin:SetDimensions(KILL_WINDOW_WIDTH, KILL_ROW_HEIGHT * 4)
    killWin:SetMouseEnabled(true)
    killWin:SetMovable(true)
    killWin:SetClampedToScreen(true)
    killWin:SetHidden(true)
    killWin:SetHandler("OnMoveStop", function(control)
        if not CHX.saved then return end
        CHX.saved.killWindowX = control:GetLeft()
        CHX.saved.killWindowY = control:GetTop()
    end)

    local killBg = WINDOW_MANAGER:CreateControl("PVPBuddy_KillWindow_BG", killWin, CT_BACKDROP)
    killBg:SetAnchorFill(killWin)
    killBg:SetCenterColor(0, 0, 0, 0.18)
    killBg:SetEdgeColor(ESO_FRAME_DARK_R, ESO_FRAME_DARK_G, ESO_FRAME_DARK_B, 0.92)
    local killFrame = CreateESOFrame(killWin, "PVPBuddy_KillWindow_Frame", KILL_WINDOW_WIDTH, KILL_ROW_HEIGHT)

    local queueWin = WINDOW_MANAGER:CreateTopLevelWindow("PVPBuddy_QueueWindow")
    queueWin:SetDimensions(QUEUE_WINDOW_WIDTH, QUEUE_WINDOW_HEIGHT)
    queueWin:SetMouseEnabled(true)
    queueWin:SetMovable(true)
    queueWin:SetClampedToScreen(true)
    queueWin:SetHidden(true)
    queueWin:SetHandler("OnMoveStop", function(control)
        if not CHX.saved then return end
        CHX.saved.queueWindowX = control:GetLeft()
        CHX.saved.queueWindowY = control:GetTop()
    end)

    local queueBg = WINDOW_MANAGER:CreateControl("PVPBuddy_QueueWindow_BG", queueWin, CT_BACKDROP)
    queueBg:SetAnchorFill(queueWin)
    queueBg:SetCenterColor(0, 0, 0, 0.44)
    queueBg:SetEdgeColor(ESO_FRAME_DARK_R, ESO_FRAME_DARK_G, ESO_FRAME_DARK_B, 0.92)
    local queueFrame = CreateESOFrame(queueWin, "PVPBuddy_QueueWindow_Frame", QUEUE_WINDOW_WIDTH, QUEUE_WINDOW_HEIGHT)

    local queueTitle = CreateLabel(queueWin, "PVPBuddy_Queue_Title", queueWin, 8, 2, QUEUE_TITLE_WIDTH, 22, FONT_MAIN, TEXT_ALIGN_LEFT)
    local queuePosition = CreateLabel(queueWin, "PVPBuddy_Queue_Position", queueWin, 8, 27, QUEUE_TITLE_WIDTH, 24, FONT_MAIN, TEXT_ALIGN_LEFT)
    local queueNumber = CreateLabel(queueWin, "PVPBuddy_Queue_Number", queueWin, QUEUE_NUMBER_X, 4, QUEUE_NUMBER_WIDTH, 48, "$(CHAT_FONT)|30|soft-shadow-thick", TEXT_ALIGN_RIGHT)
    queueTitle:SetColor(0.90, 0.90, 0.90, 1)
    queuePosition:SetColor(0.80, 0.90, 1.00, 1)
    queueNumber:SetColor(0.80, 0.90, 1.00, 1)

    CHX.ui = {
        window = win,
        bg = bg,
        mainFrame = mainFrame,
        pvpStatsRowBg = pvpStatsRowBg,
        pvpStatsText = pvpStatsText,
        pvpStatsPerfText = pvpStatsPerfText,
        scoreTime = scoreTime,
        scoreIconAD = scoreIconAD,
        scoreIconEP = scoreIconEP,
        scoreIconDC = scoreIconDC,
        scoreAD = scoreAD,
        scoreEP = scoreEP,
        scoreDC = scoreDC,
        scoreScrollIconAD = scoreScrollIconAD,
        scoreScrollIconEP = scoreScrollIconEP,
        scoreScrollIconDC = scoreScrollIconDC,
        scoreScrollAD = scoreScrollAD,
        scoreScrollEP = scoreScrollEP,
        scoreScrollDC = scoreScrollDC,
        scoreLowPopAD = scoreLowPopAD,
        scoreLowPopEP = scoreLowPopEP,
        scoreLowPopDC = scoreLowPopDC,
        scoreLowScoreAD = scoreLowScoreAD,
        scoreLowScoreEP = scoreLowScoreEP,
        scoreLowScoreDC = scoreLowScoreDC,
        rows = {},
        killWindow = killWin,
        killBg = killBg,
        killFrame = killFrame,
        killRows = {},
        queueWindow = queueWin,
        queueBg = queueBg,
        queueFrame = queueFrame,
        queueTitle = queueTitle,
        queuePosition = queuePosition,
        queueNumber = queueNumber,
    }

    return true
end

local function EnsureRow(index)
    if not CreateUI() then return nil end

    if CHX.ui.rows[index] then
        return CHX.ui.rows[index]
    end

    local y = SCORE_HEIGHT + ((index - 1) * ROW_HEIGHT)
    local row = WINDOW_MANAGER:CreateControl("PVPBuddy_Row_" .. tostring(index), CHX.ui.window, CT_CONTROL)
    row:SetAnchor(TOPLEFT, CHX.ui.window, TOPLEFT, 0, y)
    row:SetDimensions(WINDOW_WIDTH, ROW_HEIGHT)

    row.bg = WINDOW_MANAGER:CreateControl("PVPBuddy_Row_BG_" .. tostring(index), row, CT_BACKDROP)
    row.bg:SetAnchorFill(row)
    row.bg:SetCenterColor(0, 0, 0, 0.30)
    row.bg:SetEdgeColor(BORDER_R, BORDER_G, BORDER_B, ROW_BORDER_A)

    row.ua = WINDOW_MANAGER:CreateControl("PVPBuddy_Row_UA_" .. tostring(index), row, CT_TEXTURE)
    row.ua:SetAnchor(TOPLEFT, row, TOPLEFT, -2, -2)
    row.ua:SetDimensions(40, 40)
    row.ua:SetTexture("/esoui/art/mappins/ava_attackburst_64.dds")
    row.ua:SetHidden(true)

    row.icon = WINDOW_MANAGER:CreateControl("PVPBuddy_Row_Icon_" .. tostring(index), row, CT_TEXTURE)
    row.icon:SetAnchor(TOPLEFT, row, TOPLEFT, -2, -2)
    row.icon:SetDimensions(40, 40)
    row.icon:SetTexture("/esoui/art/mappins/ava_largekeep_neutral.dds")

    row.lumber = WINDOW_MANAGER:CreateControl("PVPBuddy_Row_Lumber_" .. tostring(index), row, CT_TEXTURE)
    row.lumber:SetAnchor(TOPLEFT, row, TOPLEFT, -5, -5)
    row.lumber:SetDimensions(20, 20)
    row.lumber:SetTexture("/esoui/art/mappins/ava_lumbermill_neutral.dds")
    row.lumber:SetHidden(true)

    row.mine = WINDOW_MANAGER:CreateControl("PVPBuddy_Row_Mine_" .. tostring(index), row, CT_TEXTURE)
    row.mine:SetAnchor(TOPLEFT, row, TOPLEFT, -5, 20)
    row.mine:SetDimensions(20, 20)
    row.mine:SetTexture("/esoui/art/mappins/ava_mine_neutral.dds")
    row.mine:SetHidden(true)

    row.farm = WINDOW_MANAGER:CreateControl("PVPBuddy_Row_Farm_" .. tostring(index), row, CT_TEXTURE)
    row.farm:SetAnchor(TOPLEFT, row, TOPLEFT, 22, 20)
    row.farm:SetDimensions(20, 20)
    row.farm:SetTexture("/esoui/art/mappins/ava_farm_neutral.dds")
    row.farm:SetHidden(true)

    row.scroll = WINDOW_MANAGER:CreateControl("PVPBuddy_Row_Scroll_" .. tostring(index), row, CT_TEXTURE)
    row.scroll:SetAnchor(TOPLEFT, row, TOPLEFT, -6, -6)
    row.scroll:SetDimensions(50, 50)
    row.scroll:SetTexture("/esoui/art/campaign/overview_scrollicon_aldmeri.dds")
    row.scroll:SetHidden(true)

    row.arrow = WINDOW_MANAGER:CreateControl("PVPBuddy_Row_Arrow_" .. tostring(index), row, CT_TEXTURE)
    row.arrow:SetAnchor(TOPLEFT, row, TOPLEFT, 33, 9)
    row.arrow:SetDimensions(14, 14)
    row.arrow:SetTexture("/esoui/art/unitattributevisualizer/attributebar_arrow.dds")
    row.arrow:SetTransformRotationZ(math.rad(180))
    row.arrow:SetHidden(true)

    row.name = CreateLabel(row, "PVPBuddy_Row_Name_" .. tostring(index), row, 49, 5, 136, 30, FONT_MAIN, TEXT_ALIGN_LEFT)

    row.attIcon = WINDOW_MANAGER:CreateControl("PVPBuddy_Row_AttIcon_" .. tostring(index), row, CT_TEXTURE)
    row.attIcon:SetAnchor(TOPLEFT, row, TOPLEFT, 180, 0)
    row.attIcon:SetDimensions(30, 30)
    row.attIcon:SetTexture("/esoui/art/icons/ava_siege_weapon_001.dds")
    row.attIcon:SetColor(1, 1, 1, 1)

    row.attSiege = CreateLabel(row, "PVPBuddy_Row_AttSiege_" .. tostring(index), row, 190, 5, 30, 30, FONT_MAIN, TEXT_ALIGN_CENTER)

    row.defIcon = WINDOW_MANAGER:CreateControl("PVPBuddy_Row_DefIcon_" .. tostring(index), row, CT_TEXTURE)
    row.defIcon:SetAnchor(TOPLEFT, row, TOPLEFT, 210, 0)
    row.defIcon:SetDimensions(30, 30)
    row.defIcon:SetTexture("/esoui/art/icons/ava_siege_weapon_002.dds")
    row.defIcon:SetColor(1, 1, 1, 1)

    row.defSiege = CreateLabel(row, "PVPBuddy_Row_DefSiege_" .. tostring(index), row, 224, 5, 30, 30, FONT_MAIN, TEXT_ALIGN_CENTER)

    row.time = CreateLabel(row, "PVPBuddy_Row_Time_" .. tostring(index), row, 266, 5, 50, 30, FONT_MAIN, TEXT_ALIGN_LEFT)

    row.killSub = CreateLabel(row, "PVPBuddy_Row_KillSub_" .. tostring(index), row, 35, 21, 205, 12, FONT_SMALL, TEXT_ALIGN_LEFT)
    row.killSub:SetHidden(true)

    CHX.ui.rows[index] = row
    return row
end

local function EnsureKillRow(index)
    if not CreateUI() then return nil end

    if CHX.ui.killRows[index] then
        return CHX.ui.killRows[index]
    end

    local y = (index - 1) * KILL_ROW_HEIGHT
    local row = WINDOW_MANAGER:CreateControl("PVPBuddy_KillRow_" .. tostring(index), CHX.ui.killWindow, CT_CONTROL)
    row:SetAnchor(TOPLEFT, CHX.ui.killWindow, TOPLEFT, 0, y)
    row:SetDimensions(KILL_WINDOW_WIDTH, KILL_ROW_HEIGHT)

    row.bg = WINDOW_MANAGER:CreateControl("PVPBuddy_KillRow_BG_" .. tostring(index), row, CT_BACKDROP)
    row.bg:SetAnchorFill(row)
    row.bg:SetCenterColor(0, 0, 0, 0.30)
    row.bg:SetEdgeColor(BORDER_R, BORDER_G, BORDER_B, ROW_BORDER_A)

    row.icon = WINDOW_MANAGER:CreateControl("PVPBuddy_KillRow_Icon_" .. tostring(index), row, CT_TEXTURE)
    row.icon:SetAnchor(TOPLEFT, row, TOPLEFT, 6, 7)
    row.icon:SetDimensions(20, 20)
    row.icon:SetTexture("/esoui/art/icons/ava_siege_weapon_001.dds")
    row.icon:SetColor(0.85, 0.85, 0.85, 0.90)

    row.name = CreateLabel(row, "PVPBuddy_KillRow_Name_" .. tostring(index), row, 30, 0, 127, 22, FONT_MAIN, TEXT_ALIGN_LEFT)
    row.kills = CreateLabel(row, "PVPBuddy_KillRow_Kills_" .. tostring(index), row, 158, 2, 82, 18, FONT_SMALL, TEXT_ALIGN_LEFT)
    row.deaths = CreateLabel(row, "PVPBuddy_KillRow_Deaths_" .. tostring(index), row, 30, 21, 210, 12, FONT_SMALL, TEXT_ALIGN_LEFT)
    row.time = CreateLabel(row, "PVPBuddy_KillRow_Time_" .. tostring(index), row, 245, 5, 35, 30, FONT_MAIN, TEXT_ALIGN_RIGHT)

    CHX.ui.killRows[index] = row
    return row
end


local function GetKeepIcon(keepType, keepId)
    if keepType == KEEPTYPE_RESOURCE then
        if type(GetKeepResourceType) == "function" and keepId then
            local resourceType = SafeCall("GetKeepResourceType", GetKeepResourceType, nil, keepId)

            if resourceType == RESOURCE_WOOD then return "/esoui/art/mappins/ava_lumbermill_neutral.dds" end
            if resourceType == RESOURCE_ORE then return "/esoui/art/mappins/ava_mine_neutral.dds" end
            if resourceType == RESOURCE_FOOD then return "/esoui/art/mappins/ava_farm_neutral.dds" end
        end

        return "/esoui/art/mappins/ava_farm_neutral.dds"
    end

    if keepType == KEEPTYPE_OUTPOST then return "/esoui/art/mappins/ava_outpost_neutral.dds" end
    if keepType == KEEPTYPE_TOWN then return "/esoui/art/mappins/ava_town_neutral.dds" end
    if keepType == KEEPTYPE_IMPERIAL_CITY_DISTRICT then return "/esoui/art/mappins/ava_imperialdistrict_neutral.dds" end
    if keepType == KEEPTYPE_ARTIFACT_GATE then return "/esoui/art/mappins/ava_artifactgate_closed.dds" end
    if keepType == KEEPTYPE_BRIDGE then return "/esoui/art/mappins/ava_bridge_intact.dds" end
    if keepType == KEEPTYPE_MILEGATE then return "/esoui/art/mappins/ava_milegate_intact.dds" end

    return "/esoui/art/mappins/ava_largekeep_neutral.dds"
end

local function GetResourceIcon(resourceType)
    if resourceType == RESOURCE_WOOD then return "/esoui/art/mappins/ava_lumbermill_neutral.dds" end
    if resourceType == RESOURCE_ORE then return "/esoui/art/mappins/ava_mine_neutral.dds" end
    if resourceType == RESOURCE_FOOD then return "/esoui/art/mappins/ava_farm_neutral.dds" end
    return "/esoui/art/mappins/ava_farm_neutral.dds"
end

local function GetKeepResourceAlliance(keepId, resourceType)
    if type(GetResourceKeepForKeep) ~= "function" then
        return nil
    end

    local resourceKeepId = SafeCall(
        "GetResourceKeepForKeep",
        GetResourceKeepForKeep,
        0,
        keepId,
        resourceType
    ) or 0

    if resourceKeepId <= 0 then
        return nil
    end

    return SafeCall(
        "GetKeepAlliance resource",
        GetKeepAlliance,
        NONE,
        resourceKeepId,
        BG
    ) or NONE
end

local function FillKeepResourceData(entry, keepId, keepType)
    entry.resources = nil

    if not CHX.saved or not CHX.saved.showKeepResources then
        return
    end

    if keepType ~= KEEPTYPE_KEEP then
        return
    end

    entry.resources = {
        lumber = {
            icon = GetResourceIcon(RESOURCE_WOOD),
            alliance = GetKeepResourceAlliance(keepId, RESOURCE_WOOD),
        },
        mine = {
            icon = GetResourceIcon(RESOURCE_ORE),
            alliance = GetKeepResourceAlliance(keepId, RESOURCE_ORE),
        },
        farm = {
            icon = GetResourceIcon(RESOURCE_FOOD),
            alliance = GetKeepResourceAlliance(keepId, RESOURCE_FOOD),
        },
    }
end

local function GetScrollTextureFromPin(pinType)
    if pinType ~= nil and ZO_MapPin and ZO_MapPin.PIN_DATA and ZO_MapPin.PIN_DATA[pinType] and ZO_MapPin.PIN_DATA[pinType].texture then
        return ZO_MapPin.PIN_DATA[pinType].texture
    end

    return nil
end

local function GetFallbackScrollTexture(alliance)
    if alliance == AD then return "/esoui/art/campaign/overview_scrollicon_aldmeri.dds" end
    if alliance == EP then return "/esoui/art/campaign/overview_scrollicon_ebonheart.dds" end
    if alliance == DC then return "/esoui/art/campaign/overview_scrollicon_daggefall.dds" end
    return "/esoui/art/campaign/overview_scrollicon_aldmeri.dds"
end

local function GetObjectiveDetails(objectiveKeepId, objectiveId, bgContext)
    local objectiveName, objectiveType, objectiveState = "", nil, nil

    if type(GetObjectiveInfo) == "function" then
        objectiveName, objectiveType, objectiveState = SafeCall(
            "GetObjectiveInfo scroll",
            GetObjectiveInfo,
            "",
            objectiveKeepId,
            objectiveId,
            bgContext
        )
    end

    if objectiveState == nil and type(GetObjectiveControlState) == "function" then
        objectiveState = SafeCall(
            "GetObjectiveControlState scroll",
            GetObjectiveControlState,
            nil,
            objectiveKeepId,
            objectiveId,
            bgContext
        )
    end

    return objectiveName, objectiveType, objectiveState
end

local function GetObjectivePinTexture(objectiveKeepId, objectiveId, bgContext)
    if type(GetObjectivePinInfo) ~= "function" then
        return nil
    end

    local pinType = SafeCall(
        "GetObjectivePinInfo scroll",
        GetObjectivePinInfo,
        nil,
        objectiveKeepId,
        objectiveId,
        bgContext
    )

    return GetScrollTextureFromPin(pinType)
end

local function GetAllianceFromScrollTexture(texture)
    texture = string.lower(tostring(texture or ""))

    if string.find(texture, "aldmeri") then
        return AD
    end

    if string.find(texture, "ebonheart") then
        return EP
    end

    if string.find(texture, "daggerfall") or string.find(texture, "daggefall") then
        return DC
    end

    return NONE
end

local function IsArtifactScrollObjective(objectiveKeepId, objectiveId, bgContext)
    if not objectiveKeepId or not objectiveId then
        return false
    end

    local objectiveName, objectiveType = GetObjectiveDetails(objectiveKeepId, objectiveId, bgContext)

    if OBJECTIVE_ARTIFACT_DEFENSIVE ~= nil and objectiveType == OBJECTIVE_ARTIFACT_DEFENSIVE then
        return true
    end

    if OBJECTIVE_ARTIFACT_OFFENSIVE ~= nil and objectiveType == OBJECTIVE_ARTIFACT_OFFENSIVE then
        return true
    end

    -- Do not count Volendrung as an Elder Scroll.
    if OBJECTIVE_DAEDRIC_WEAPON ~= nil and objectiveType == OBJECTIVE_DAEDRIC_WEAPON then
        return false
    end

    if type(GetKeepArtifactObjectiveId) == "function" then
        local artifactObjectiveId = SafeCall(
            "GetKeepArtifactObjectiveId scroll identify",
            GetKeepArtifactObjectiveId,
            nil,
            objectiveKeepId
        )

        if artifactObjectiveId and artifactObjectiveId == objectiveId then
            return true
        end
    end

    local texture = GetObjectivePinTexture(objectiveKeepId, objectiveId, bgContext)

    if texture and string.find(string.lower(tostring(texture)), "scroll") then
        return true
    end

    objectiveName = string.lower(tostring(objectiveName or ""))

    if string.find(objectiveName, "scroll") then
        return true
    end

    return false
end

local function IsBaseScrollState(state)
    return (OBJECTIVE_CONTROL_STATE_FLAG_AT_BASE ~= nil and state == OBJECTIVE_CONTROL_STATE_FLAG_AT_BASE)
        or (OBJECTIVE_CONTROL_STATE_FLAG_AT_ENEMY_BASE ~= nil and state == OBJECTIVE_CONTROL_STATE_FLAG_AT_ENEMY_BASE)
end

local function IsHeldOrDroppedScrollState(state)
    return (OBJECTIVE_CONTROL_STATE_FLAG_HELD ~= nil and state == OBJECTIVE_CONTROL_STATE_FLAG_HELD)
        or (OBJECTIVE_CONTROL_STATE_FLAG_DROPPED ~= nil and state == OBJECTIVE_CONTROL_STATE_FLAG_DROPPED)
end

local function GetObjectiveScrollTexture(objectiveKeepId, objectiveId, bgContext, alliance)
    local texture = GetObjectivePinTexture(objectiveKeepId, objectiveId, bgContext)

    if texture then
        return texture
    end

    return GetFallbackScrollTexture(alliance)
end

local function BuildKnownScrollObjectiveList()
    local out = {}

    if type(GetKeepArtifactObjectiveId) ~= "function" then
        return out
    end

    for i = 1, #CHX.scrollTempleIds do
        local templeKeepId = CHX.scrollTempleIds[i]
        local objectiveId = SafeCall(
            "GetKeepArtifactObjectiveId known temple",
            GetKeepArtifactObjectiveId,
            nil,
            templeKeepId
        )

        if objectiveId then
            out[#out + 1] = {
                objectiveKeepId = templeKeepId,
                objectiveId = objectiveId,
                bgContext = BG,
            }
        end
    end

    return out
end

local function GetScrollObjectiveCapturedKeep(objectiveKeepId, objectiveId, bgContext)
    if type(GetKeepThatHasCapturedThisArtifactScrollObjective) ~= "function" then
        return 0
    end

    return SafeCall(
        "GetKeepThatHasCapturedThisArtifactScrollObjective known temple",
        GetKeepThatHasCapturedThisArtifactScrollObjective,
        0,
        objectiveKeepId,
        objectiveId,
        bgContext or BG
    ) or 0
end

local function GetBaseScrollAlliance(objectiveKeepId, objectiveId, bgContext)
    local textureAlliance = GetAllianceFromScrollTexture(GetObjectivePinTexture(objectiveKeepId, objectiveId, bgContext))

    if textureAlliance ~= NONE then
        return textureAlliance
    end

    local keepAlliance = SafeCall(
        "GetKeepAlliance base scroll",
        GetKeepAlliance,
        NONE,
        objectiveKeepId,
        bgContext or BG
    ) or NONE

    return keepAlliance
end

local function TryGetObjectiveScrollTexture(objectiveKeepId, objectiveId, bgContext)
    if not IsArtifactScrollObjective(objectiveKeepId, objectiveId, bgContext) then
        return nil
    end

    local alliance = GetBaseScrollAlliance(objectiveKeepId, objectiveId, bgContext)
    return GetObjectiveScrollTexture(objectiveKeepId, objectiveId, bgContext, alliance)
end

local function FillScrollData(entry, keepId, keepType)
    entry.scrollTexture = nil
    entry.scrollOnTemple = false

    if not CHX.saved or not CHX.saved.showScrollIcons then
        return
    end

    local knownScrollObjectives = BuildKnownScrollObjectiveList()

    for i = 1, #knownScrollObjectives do
        local objectiveKeepId = knownScrollObjectives[i].objectiveKeepId
        local objectiveId = knownScrollObjectives[i].objectiveId
        local bgContext = knownScrollObjectives[i].bgContext or BG

        local capturedKeepId = GetScrollObjectiveCapturedKeep(objectiveKeepId, objectiveId, bgContext)

        if capturedKeepId == keepId then
            entry.scrollTexture = TryGetObjectiveScrollTexture(objectiveKeepId, objectiveId, bgContext)
            return
        end
    end

    if type(GetNumObjectives) == "function"
        and type(GetAvAObjectiveKeysByIndex) == "function"
        and type(GetKeepThatHasCapturedThisArtifactScrollObjective) == "function" then

        local numObjectives = SafeCall("GetNumObjectives", GetNumObjectives, 0) or 0

        for i = 1, numObjectives do
            local objectiveKeepId, objectiveId, bgContext = SafeCall(
                "GetAvAObjectiveKeysByIndex",
                GetAvAObjectiveKeysByIndex,
                nil,
                i
            )

            if objectiveKeepId and objectiveId and IsArtifactScrollObjective(objectiveKeepId, objectiveId, bgContext) then
                local capturedKeepId = SafeCall(
                    "GetKeepThatHasCapturedThisArtifactScrollObjective",
                    GetKeepThatHasCapturedThisArtifactScrollObjective,
                    0,
                    objectiveKeepId,
                    objectiveId,
                    bgContext
                ) or 0

                if capturedKeepId == keepId then
                    entry.scrollTexture = TryGetObjectiveScrollTexture(objectiveKeepId, objectiveId, bgContext)
                    return
                end
            end
        end
    end

    -- Scroll gates: when the corresponding temple still has a scroll and the gate is open,
    -- PvP Buddy shows the temple/scroll on the gate row. Artifact gate ids line up as gate - 6.
    if keepType == KEEPTYPE_ARTIFACT_GATE
        and type(GetKeepArtifactObjectiveId) == "function"
        and type(GetObjectiveControlState) == "function"
        and type(GetObjectivePinInfo) == "function" then

        local templeKeepId = keepId - 6
        local objectiveId = SafeCall("GetKeepArtifactObjectiveId", GetKeepArtifactObjectiveId, nil, templeKeepId)

        if objectiveId and IsArtifactScrollObjective(templeKeepId, objectiveId, BG) then
            local _, _, objectiveState = GetObjectiveDetails(templeKeepId, objectiveId, BG)

            if IsBaseScrollState(objectiveState) then
                entry.scrollTexture = TryGetObjectiveScrollTexture(templeKeepId, objectiveId, BG)
                entry.scrollOnTemple = true
            end
        end
    end
end


local function IsValidAlliance(alliance)
    alliance = tonumber(alliance) or NONE
    return alliance == AD or alliance == EP or alliance == DC
end

local function ShortenObjectiveName(text)
    text = StripControlCodes(text)
    text = string.gsub(text, "Elder Scroll of ", "")
    text = string.gsub(text, "The Elder Scroll of ", "")
    text = string.gsub(text, "Volendrung", "Volendrung")
    text = string.gsub(text, "%s+$", "")
    text = string.gsub(text, "^%s+", "")

    if text == "" then
        return "Moving Objective"
    end

    return text
end

local function IsMovingObjectiveType(objectiveType)
    return (OBJECTIVE_ARTIFACT_DEFENSIVE ~= nil and objectiveType == OBJECTIVE_ARTIFACT_DEFENSIVE)
        or (OBJECTIVE_ARTIFACT_OFFENSIVE ~= nil and objectiveType == OBJECTIVE_ARTIFACT_OFFENSIVE)
        or (OBJECTIVE_DAEDRIC_WEAPON ~= nil and objectiveType == OBJECTIVE_DAEDRIC_WEAPON)
end

local function GetObjectiveTypeFallbackIcon(objectiveType, alliance)
    if OBJECTIVE_DAEDRIC_WEAPON ~= nil and objectiveType == OBJECTIVE_DAEDRIC_WEAPON then
        return "/esoui/art/campaign/gamepad/gp_overview_menuicon_emperor.dds"
    end

    return GetFallbackScrollTexture(alliance)
end

local function GetObjectiveEventText(objectiveControlEvent, objectiveControlState)
    if OBJECTIVE_CONTROL_EVENT_FLAG_TAKEN ~= nil and objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_TAKEN then
        return "taken"
    end

    if OBJECTIVE_CONTROL_EVENT_FLAG_DROPPED ~= nil and objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_DROPPED then
        return "dropped"
    end

    if OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED ~= nil and objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED then
        return "spawned"
    end

    if OBJECTIVE_CONTROL_STATE_FLAG_HELD ~= nil and objectiveControlState == OBJECTIVE_CONTROL_STATE_FLAG_HELD then
        return "held"
    end

    if OBJECTIVE_CONTROL_STATE_FLAG_DROPPED ~= nil and objectiveControlState == OBJECTIVE_CONTROL_STATE_FLAG_DROPPED then
        return "dropped"
    end

    if OBJECTIVE_CONTROL_STATE_FLAG_AT_BASE ~= nil and objectiveControlState == OBJECTIVE_CONTROL_STATE_FLAG_AT_BASE then
        return "at base"
    end

    return "updated"
end

local function StoreMovingObjective(key, data)
    if not key then
        return
    end

    data = data or {}
    data.key = key
    data.updated = GetNow()
    data.started = data.started or data.updated
    data.elapsed = 0
    data.isMovingObjective = true
    data.priority = data.priority or 0
    data.owner = data.alliance or data.holdingAlliance or NONE
    data.attSiege = ""
    data.defSiege = ""
    data.attAlliance = NONE
    data.underAttack = false

    CHX.movingObjectives[key] = data
    CHX.debug.lastMovingObjectiveEvent = tostring(data.eventText or "updated")
    CHX.debug.lastMovingObjectivePayload = tostring(data.name or "") .. " / " .. tostring(data.holder or "") .. " / " .. tostring(data.alliance or data.holdingAlliance or NONE)
end

local function StoreMovingObjectiveFromObjective(eventCode, objectiveKeepId, objectiveId, battlegroundContext, objectiveName, objectiveType, objectiveControlEvent, objectiveControlState, holdingAlliance, attackingAlliance, pinType)
    if not IsMovingObjectiveType(objectiveType) then
        return false
    end

    local alliance = holdingAlliance

    if not IsValidAlliance(alliance) then
        alliance = attackingAlliance
    end

    if not IsValidAlliance(alliance) then
        alliance = GetAllianceFromScrollTexture(GetScrollTextureFromPin(pinType))
    end

    local texture = GetScrollTextureFromPin(pinType) or GetObjectiveTypeFallbackIcon(objectiveType, alliance)
    local eventText = GetObjectiveEventText(objectiveControlEvent, objectiveControlState)
    local name = ShortenObjectiveName(objectiveName or "")

    local key = tostring(objectiveId or objectiveName or "moving")

    StoreMovingObjective(key, {
        objectiveKeepId = objectiveKeepId,
        objectiveId = objectiveId,
        bgContext = battlegroundContext,
        name = name,
        holder = "",
        alliance = alliance,
        holdingAlliance = holdingAlliance,
        attackingAlliance = attackingAlliance,
        objectiveType = objectiveType,
        objectiveControlEvent = objectiveControlEvent,
        objectiveControlState = objectiveControlState,
        eventText = eventText,
        icon = texture,
    })

    return true
end

local function OnArtifactControlState(eventCode, artifactName, keepId, characterName, playerAlliance, objectiveControlEvent, objectiveControlState, campaignId, displayName)
    if campaignId ~= nil and campaignId == 0 then
        return
    end

    local alliance = playerAlliance

    if not IsValidAlliance(alliance) then
        alliance = GetAllianceFromScrollTexture(tostring(artifactName or ""))
    end

    local eventText = GetObjectiveEventText(objectiveControlEvent, objectiveControlState)
    local holder = displayName or characterName or ""

    if holder == "" and eventText == "spawned" then
        holder = "?"
    end

    local name = ShortenObjectiveName(artifactName or "Artifact")
    local key = "artifact:" .. tostring(artifactName or keepId or name)

    StoreMovingObjective(key, {
        keepId = keepId,
        name = name,
        holder = holder,
        alliance = alliance,
        objectiveControlEvent = objectiveControlEvent,
        objectiveControlState = objectiveControlState,
        eventText = eventText,
        icon = GetFallbackScrollTexture(alliance),
    })
end

local function OnDaedricArtifactObjectiveStateChanged(eventCode, objectiveKeepId, objectiveId, battlegroundContext, objectiveControlEvent, objectiveControlState, holderAlliance, lastHolderAlliance, pinType, daedricArtifactId, lastObjectiveControlState)
    local name = "Volendrung"

    if type(GetDaedricArtifactDisplayName) == "function" and daedricArtifactId ~= nil then
        name = SafeCall("GetDaedricArtifactDisplayName", GetDaedricArtifactDisplayName, "Volendrung", daedricArtifactId) or "Volendrung"
    end

    local alliance = holderAlliance

    if not IsValidAlliance(alliance) then
        alliance = lastHolderAlliance
    end

    StoreMovingObjective("daedric:" .. tostring(daedricArtifactId or objectiveId or -1), {
        objectiveKeepId = objectiveKeepId,
        objectiveId = objectiveId,
        bgContext = battlegroundContext,
        name = ShortenObjectiveName(name),
        holder = "",
        alliance = alliance,
        objectiveType = OBJECTIVE_DAEDRIC_WEAPON,
        objectiveControlEvent = objectiveControlEvent,
        objectiveControlState = objectiveControlState,
        eventText = GetObjectiveEventText(objectiveControlEvent, objectiveControlState),
        icon = GetScrollTextureFromPin(pinType) or "/esoui/art/campaign/gamepad/gp_overview_menuicon_emperor.dds",
    })
end

local function OnDaedricArtifactSpawned(eventCode, daedricArtifactId)
    local name = "Volendrung"

    if type(GetDaedricArtifactDisplayName) == "function" and daedricArtifactId ~= nil then
        name = SafeCall("GetDaedricArtifactDisplayName", GetDaedricArtifactDisplayName, "Volendrung", daedricArtifactId) or "Volendrung"
    end

    StoreMovingObjective("daedric:" .. tostring(daedricArtifactId or -1), {
        name = ShortenObjectiveName(name),
        holder = "?",
        alliance = NONE,
        objectiveType = OBJECTIVE_DAEDRIC_WEAPON,
        objectiveControlEvent = OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED,
        objectiveControlState = OBJECTIVE_CONTROL_STATE_FLAG_DROPPED,
        eventText = "spawned",
        icon = "/esoui/art/campaign/gamepad/gp_overview_menuicon_emperor.dds",
    })
end

local function OnArtifactScrollStateChanged(eventCode, ...)
    CHX.debug.lastMovingObjectiveEvent = "scroll state changed"
    CHX.debug.lastMovingObjectivePayload = tostring(select(1, ...)) .. "/" .. tostring(select(2, ...)) .. "/" .. tostring(select(3, ...))
end

local function GetFlagStateName(state)
    if OBJECTIVE_CONTROL_STATE_AREA_MAX_CONTROL ~= nil and state == OBJECTIVE_CONTROL_STATE_AREA_MAX_CONTROL then
        return "max control"
    end

    if OBJECTIVE_CONTROL_STATE_AREA_ABOVE_CONTROL_THRESHOLD ~= nil and state == OBJECTIVE_CONTROL_STATE_AREA_ABOVE_CONTROL_THRESHOLD then
        return "above threshold"
    end

    if OBJECTIVE_CONTROL_STATE_AREA_NO_CONTROL ~= nil and state == OBJECTIVE_CONTROL_STATE_AREA_NO_CONTROL then
        return "neutral/no control"
    end

    if OBJECTIVE_CONTROL_STATE_AREA_BELOW_CONTROL_THRESHOLD ~= nil and state == OBJECTIVE_CONTROL_STATE_AREA_BELOW_CONTROL_THRESHOLD then
        return "below threshold"
    end

    return tostring(state or "")
end

local function GetFlagControlEventName(eventValue)
    if OBJECTIVE_CONTROL_EVENT_UNDER_ATTACK ~= nil and eventValue == OBJECTIVE_CONTROL_EVENT_UNDER_ATTACK then
        return "under attack"
    end

    if OBJECTIVE_CONTROL_EVENT_CAPTURED ~= nil and eventValue == OBJECTIVE_CONTROL_EVENT_CAPTURED then
        return "captured"
    end

    if OBJECTIVE_CONTROL_EVENT_FLAG_TAKEN ~= nil and eventValue == OBJECTIVE_CONTROL_EVENT_FLAG_TAKEN then
        return "flag taken"
    end

    if OBJECTIVE_CONTROL_EVENT_FLAG_DROPPED ~= nil and eventValue == OBJECTIVE_CONTROL_EVENT_FLAG_DROPPED then
        return "flag dropped"
    end

    if OBJECTIVE_CONTROL_EVENT_FLAG_RETURNED ~= nil and eventValue == OBJECTIVE_CONTROL_EVENT_FLAG_RETURNED then
        return "flag returned"
    end

    if OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED ~= nil and eventValue == OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED then
        return "flag spawned"
    end

    return tostring(eventValue or "")
end

local function GetFlagNameAlliance(owner, holdingAlliance, attackingAlliance, state)
    owner = tonumber(owner) or NONE
    holdingAlliance = tonumber(holdingAlliance) or NONE
    attackingAlliance = tonumber(attackingAlliance) or NONE

    -- If a flag is in the neutral middle state, show the attacking alliance if known;
    -- otherwise show a neutral/white name.
    if OBJECTIVE_CONTROL_STATE_AREA_NO_CONTROL ~= nil and state == OBJECTIVE_CONTROL_STATE_AREA_NO_CONTROL then
        if IsValidAlliance(attackingAlliance) then
            return attackingAlliance, false
        end

        return NONE, true
    end

    -- During an active push, make the name show who is flipping it, not only who owns it.
    if IsValidAlliance(attackingAlliance) and attackingAlliance ~= owner then
        return attackingAlliance, false
    end

    if IsValidAlliance(holdingAlliance) then
        return holdingAlliance, false
    end

    if IsValidAlliance(owner) then
        return owner, false
    end

    return NONE, true
end

local function SetObjectiveNameColor(row, entry)
    if not row or not row.name or not entry then
        return
    end

    if entry.flagNameNeutral then
        row.name:SetColor(0.85, 0.85, 0.85, 1)
        return
    end

    if IsValidAlliance(entry.flagNameAlliance) then
        row.name:SetColor(GetAllianceColorSafe(entry.flagNameAlliance))
        return
    end

    row.name:SetColor(GetAllianceColorSafe(entry.owner or NONE))
end

local function FillFlagStateData(entry, keepId, owner)
    entry.flagAlliance = nil
    entry.flagHoldingAlliance = nil
    entry.flagState = nil
    entry.flagNameAlliance = nil
    entry.flagNameNeutral = nil

    if not CHX.saved or (not CHX.saved.showFlagArrows and not CHX.saved.showFlagNameColoring) then
        return
    end

    local flag = CHX.flagStates and CHX.flagStates[keepId]

    if not flag then
        return
    end

    local lifetime = tonumber(CHX.saved.flagStateLifetimeSeconds) or CHX.defaults.flagStateLifetimeSeconds

    if lifetime > 0 and GetDeltaSeconds(flag.updated or 0) > lifetime then
        CHX.flagStates[keepId] = nil
        return
    end

    local arrowAlliance = tonumber(flag.attackingAlliance) or NONE
    local holdingAlliance = tonumber(flag.holdingAlliance) or NONE

    if not IsValidAlliance(arrowAlliance) then
        arrowAlliance = holdingAlliance
    end

    if CHX.saved.showFlagArrows and IsValidAlliance(arrowAlliance) then
        entry.flagAlliance = arrowAlliance
        entry.flagHoldingAlliance = holdingAlliance
        entry.flagState = flag.state
    end

    if CHX.saved.showFlagNameColoring then
        local nameAlliance, neutral = GetFlagNameAlliance(owner, holdingAlliance, flag.attackingAlliance, flag.state)
        entry.flagNameAlliance = nameAlliance
        entry.flagNameNeutral = neutral == true
        entry.flagState = flag.state
        CHX.debug.lastFlagNameAlliance = tostring(nameAlliance)
    end
end

local function OnObjectiveControlState(eventCode, keepId, objectiveId, battlegroundContext, objectiveName, objectiveType, objectiveControlEvent, state, holdingAlliance, attackingAlliance, pinType)
    if IsMovingObjectiveType(objectiveType) then
        StoreMovingObjectiveFromObjective(eventCode, keepId, objectiveId, battlegroundContext, objectiveName, objectiveType, objectiveControlEvent, state, holdingAlliance, attackingAlliance, pinType)
        return
    end

    if keepId == nil then
        return
    end

    if OBJECTIVE_CAPTURE_AREA ~= nil and objectiveType ~= OBJECTIVE_CAPTURE_AREA then
        return
    end

    CHX.flagStates[keepId] = {
        objectiveId = objectiveId,
        updated = GetNow(),
        objectiveName = objectiveName,
        objectiveType = objectiveType,
        objectiveControlEvent = objectiveControlEvent,
        state = state,
        holdingAlliance = holdingAlliance,
        attackingAlliance = attackingAlliance,
        pinType = pinType,
    }

    CHX.debug.lastFlagEvent = tostring(keepId) .. ":" .. tostring(holdingAlliance) .. ">" .. tostring(attackingAlliance)
    CHX.debug.lastFlagState = GetFlagStateName(state)
    CHX.debug.lastFlagControlEvent = GetFlagControlEventName(objectiveControlEvent)
    CHX.debug.lastFlagHoldingAlliance = tostring(holdingAlliance)
    CHX.debug.lastFlagAttackingAlliance = tostring(attackingAlliance)

    -- Do not call ScanAndUpdate() from here. This handler is defined before the
    -- local ScanAndUpdate function exists, so Xbox resolves it as nil.
    -- The normal 1s/5s update loops will refresh the rows safely.
end

local function GetSiegeData(keepId, ownerAlliance)
    if not CHX.saved or not CHX.saved.showSiege then
        return "", "", NONE
    end

    local ad = SafeCall("GetNumSieges AD", GetNumSieges, 0, keepId, BG, AD) or 0
    local ep = SafeCall("GetNumSieges EP", GetNumSieges, 0, keepId, BG, EP) or 0
    local dc = SafeCall("GetNumSieges DC", GetNumSieges, 0, keepId, BG, DC) or 0

    local def = 0
    local att = 0
    local attAlliance = NONE

    if ownerAlliance == AD then
        def = ad
        att = ep + dc

        if ep > 0 and dc == 0 then attAlliance = EP
        elseif dc > 0 and ep == 0 then attAlliance = DC
        else attAlliance = NONE end
    elseif ownerAlliance == EP then
        def = ep
        att = ad + dc

        if ad > 0 and dc == 0 then attAlliance = AD
        elseif dc > 0 and ad == 0 then attAlliance = DC
        else attAlliance = NONE end
    elseif ownerAlliance == DC then
        def = dc
        att = ad + ep

        if ad > 0 and ep == 0 then attAlliance = AD
        elseif ep > 0 and ad == 0 then attAlliance = EP
        else attAlliance = NONE end
    else
        att = ad + ep + dc
        attAlliance = NONE
    end

    if att == 0 then att = "" end
    if def == 0 then def = "" end

    return tostring(att), tostring(def), attAlliance
end

local function GetSiegeText(keepId, ownerAlliance)
    local att, def = GetSiegeData(keepId, ownerAlliance)

    if att == "" and def == "" then
        return ""
    end

    return tostring(att) .. "/" .. tostring(def)
end

local function ApplyKeepDataToEntry(existing, keepId, keepType, name, owner, underAttack, gateOpenOrImpassable)
    existing.name = ShortenKeepName(name)
    existing.keepType = keepType
    existing.owner = owner
    existing.underAttack = underAttack
    existing.gateOpenOrImpassable = gateOpenOrImpassable
    existing.attSiege, existing.defSiege, existing.attAlliance = GetSiegeData(keepId, owner)
    existing.siege = GetSiegeText(keepId, owner)
    existing.typeName = GetKeepTypeName(keepType)
    existing.priority = GetKeepTypePriority(keepType)
    existing.icon = GetKeepIcon(keepType, keepId)
    FillKeepResourceData(existing, keepId, keepType)
    FillScrollData(existing, keepId, keepType)
    FillFlagStateData(existing, keepId, owner)
end

local function GetEntryForKeep(keepId)
    local keepType = SafeCall("GetKeepType", GetKeepType, 0, keepId) or 0

    if IsGateOrBridge(keepType) and not CHX.saved.showGatesAndBridges then
        CHX.entries[keepId] = nil
        return nil
    end

    local pinType = SafeCall("GetKeepPinInfo", GetKeepPinInfo, 0, keepId, BG) or 0
    local underAttack = SafeCall("GetKeepUnderAttack", GetKeepUnderAttack, false, keepId, BG) == true
    local gateOpenOrImpassable = IsGateOrBridge(keepType) and IsOpenOrImpassablePin(pinType)
    local active = underAttack or gateOpenOrImpassable
    local existing = CHX.entries[keepId]
    local now = GetNow()

    if not active then
        if not existing then
            return nil
        end

        if not CHX.saved.showFinishedBattles then
            CHX.entries[keepId] = nil
            return nil
        end

        if not existing.finishedAt then
            existing.finishedAt = now
            existing.finishedElapsed = GetDeltaSeconds(existing.started or now)
        end

        local holdSeconds = tonumber(CHX.saved.finishedBattleHoldSeconds) or CHX.defaults.finishedBattleHoldSeconds

        if GetDeltaSeconds(existing.finishedAt) > holdSeconds then
            CHX.entries[keepId] = nil
            return nil
        end

        local name = SafeCall("GetKeepName", GetKeepName, existing.name or ("Objective " .. tostring(keepId)), keepId)
        local owner = SafeCall("GetKeepAlliance", GetKeepAlliance, existing.owner or NONE, keepId, BG) or NONE

        ApplyKeepDataToEntry(existing, keepId, keepType, name, owner, false, false)

        existing.active = false
        existing.finished = true
        existing.elapsed = existing.finishedElapsed or GetDeltaSeconds(existing.started or now)

        return existing
    end

    local name = SafeCall("GetKeepName", GetKeepName, "Objective " .. tostring(keepId), keepId)
    local owner = SafeCall("GetKeepAlliance", GetKeepAlliance, NONE, keepId, BG) or NONE

    if not existing then
        existing = {
            keepId = keepId,
            started = now,
            firstSeen = now,
        }

        CHX.entries[keepId] = existing
    elseif existing.finishedAt then
        -- Same objective became active again after being marked finished.
        existing.started = now
        existing.firstSeen = now
        existing.finishedAt = nil
        existing.finishedElapsed = nil
    end

    ApplyKeepDataToEntry(existing, keepId, keepType, name, owner, underAttack, gateOpenOrImpassable)

    existing.active = true
    existing.finished = false
    existing.lastActive = now
    existing.elapsed = GetDeltaSeconds(existing.started or now)

    return existing
end

local function AddTestRows(out)
    local now = GetNow()

    out[#out + 1] = {
        keepId = -100,
        started = now - 63,
        firstSeen = now - 63,
        name = "Test Scroll",
        holder = "@holder",
        eventText = "held",
        owner = DC,
        alliance = DC,
        priority = 0,
        icon = "/esoui/art/campaign/overview_scrollicon_daggefall.dds",
        elapsed = 63,
        underAttack = false,
        active = true,
        finished = false,
        isMovingObjective = true,
        attSiege = "",
        defSiege = "",
    }


    out[#out + 1] = {
        keepId = -1,
        started = now - 8,
        firstSeen = now - 8,
        name = "Test Alessia",
        keepType = KEEPTYPE_KEEP,
        typeName = "Keep",
        owner = AD,
        siege = "8/3",
        attSiege = "8",
        defSiege = "3",
        attAlliance = EP,
        priority = 1,
        icon = "/esoui/art/mappins/ava_largekeep_neutral.dds",
        resources = {
            lumber = {
                icon = GetResourceIcon(RESOURCE_WOOD),
                alliance = AD,
            },
            mine = {
                icon = GetResourceIcon(RESOURCE_ORE),
                alliance = EP,
            },
            farm = {
                icon = GetResourceIcon(RESOURCE_FOOD),
                alliance = DC,
            },
        },
        scrollTexture = "/esoui/art/campaign/overview_scrollicon_aldmeri.dds",
        flagAlliance = EP,
        flagHoldingAlliance = AD,
        flagNameAlliance = EP,
        flagNameNeutral = false,
        flagState = "test",
        elapsed = 8,
        underAttack = true,
        active = true,
        finished = false,
    }

    out[#out + 1] = {
        keepId = -2,
        started = now - 96,
        firstSeen = now - 96,
        name = "Test Sejanus",
        keepType = KEEPTYPE_OUTPOST,
        typeName = "Outpost",
        owner = EP,
        siege = "4/1",
        attSiege = "4",
        defSiege = "1",
        attAlliance = DC,
        priority = 2,
        icon = "/esoui/art/mappins/ava_outpost_neutral.dds",
        elapsed = 96,
        underAttack = true,
        active = true,
        finished = false,
    }

    out[#out + 1] = {
        keepId = -3,
        started = now - 205,
        firstSeen = now - 205,
        finishedAt = now - 8,
        finishedElapsed = 197,
        name = "Test Finished",
        keepType = KEEPTYPE_BRIDGE,
        typeName = "Bridge",
        owner = DC,
        siege = "",
        priority = 7,
        icon = "/esoui/art/mappins/ava_bridge_intact.dds",
        elapsed = 197,
        underAttack = false,
        active = false,
        finished = true,
    }
end


local function ScanKnownScrollMovement()
    if not CHX.saved or not CHX.saved.showMovingObjectives or not CHX.saved.scanKnownScrollMovement then
        CHX.debug.lastMovingObjectiveScan = "disabled"
        return
    end

    if type(GetKeepArtifactObjectiveId) ~= "function" then
        CHX.debug.lastMovingObjectiveScan = "missing GetKeepArtifactObjectiveId"
        return
    end

    local scanned = 0
    local active = 0

    for i = 1, #CHX.scrollTempleIds do
        local templeKeepId = CHX.scrollTempleIds[i]
        local objectiveId = SafeCall(
            "GetKeepArtifactObjectiveId moving scan",
            GetKeepArtifactObjectiveId,
            nil,
            templeKeepId
        )

        if objectiveId then
            scanned = scanned + 1

            local objectiveName, objectiveType, objectiveState = GetObjectiveDetails(templeKeepId, objectiveId, BG)

            if IsArtifactScrollObjective(templeKeepId, objectiveId, BG) and IsHeldOrDroppedScrollState(objectiveState) then
                local holdingAlliance, lastHoldingAlliance = NONE, NONE

                if type(GetCarryableObjectiveHoldingAllianceInfo) == "function" then
                    holdingAlliance, lastHoldingAlliance = SafeCall(
                        "GetCarryableObjectiveHoldingAllianceInfo moving scan",
                        GetCarryableObjectiveHoldingAllianceInfo,
                        NONE,
                        templeKeepId,
                        objectiveId,
                        BG
                    )
                end

                local alliance = holdingAlliance

                if not IsValidAlliance(alliance) then
                    alliance = lastHoldingAlliance
                end

                if not IsValidAlliance(alliance) then
                    alliance = GetBaseScrollAlliance(templeKeepId, objectiveId, BG)
                end

                local stateText = GetObjectiveEventText(nil, objectiveState)
                local texture = TryGetObjectiveScrollTexture(templeKeepId, objectiveId, BG) or GetFallbackScrollTexture(alliance)
                local key = "knownscroll:" .. tostring(templeKeepId) .. ":" .. tostring(objectiveId)

                StoreMovingObjective(key, {
                    objectiveKeepId = templeKeepId,
                    objectiveId = objectiveId,
                    bgContext = BG,
                    name = ShortenObjectiveName(objectiveName or ("Scroll " .. tostring(objectiveId))),
                    holder = "",
                    alliance = alliance,
                    holdingAlliance = holdingAlliance,
                    objectiveType = objectiveType,
                    objectiveControlState = objectiveState,
                    eventText = stateText,
                    icon = texture,
                    started = (CHX.movingObjectives[key] and CHX.movingObjectives[key].started) or GetNow(),
                })

                active = active + 1
            end
        end
    end

    CHX.debug.lastMovingObjectiveScan = "known scrolls " .. tostring(active) .. "/" .. tostring(scanned)
end

local function ShortenKillLocationName(text)
    text = StripControlCodes(text)
    text = string.gsub(text, "%^%a", "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")

    if text == "" or text == "0" then
        return "PvP Battle"
    end

    return text
end

local function CleanPlayerNameForKillFeed(name)
    name = StripControlCodes(name)
    name = string.gsub(name, "%^%a+", "")
    name = string.gsub(name, "^%s+", "")
    name = string.gsub(name, "%s+$", "")

    return name
end

local function GetAllianceInitial(alliance)
    if alliance == DC then return "D" end
    if alliance == EP then return "E" end
    if alliance == AD then return "A" end
    return "-"
end

local function GetKillLocationKey(killLocation)
    return tostring(killLocation or "unknown")
end

local function StoreKillLocation(killLocation, killerAlliance, victimAlliance, killerName, victimName)
    if not CHX.saved or not CHX.saved.showKillLocations then
        return
    end

    local key = GetKillLocationKey(killLocation)
    local now = GetNow()

    killerName = CleanPlayerNameForKillFeed(killerName or "")
    victimName = CleanPlayerNameForKillFeed(victimName or "")

    local entry = CHX.killLocations[key]

    if not entry then
        entry = {
            keepId = "kill:" .. key,
            name = ShortenKillLocationName(killLocation),
            started = now,
            firstSeen = now,
            updated = now,
            priority = 0.5,
            owner = NONE,
            icon = "/esoui/art/icons/ava_siege_weapon_001.dds",
            kills = {
                [AD] = 0,
                [EP] = 0,
                [DC] = 0,
            },
            deaths = {
                [AD] = 0,
                [EP] = 0,
                [DC] = 0,
            },
            totalKills = 0,
            isKillLocation = true,
            underAttack = false,
            attSiege = "",
            defSiege = "",
            attAlliance = NONE,
        }

        CHX.killLocations[key] = entry
    end

    entry.updated = now
    entry.elapsed = GetDeltaSeconds(entry.started or now)
    entry.totalKills = (tonumber(entry.totalKills) or 0) + 1

    if IsValidAlliance(killerAlliance) then
        entry.kills[killerAlliance] = (entry.kills[killerAlliance] or 0) + 1
    end

    if IsValidAlliance(victimAlliance) then
        entry.deaths[victimAlliance] = (entry.deaths[victimAlliance] or 0) + 1
        entry.owner = victimAlliance
    end

    entry.lastKiller = killerName or ""
    entry.lastVictim = victimName or ""
    entry.lastKillText = GetAllianceInitial(killerAlliance) .. " " .. tostring(killerName or "") .. " > " .. GetAllianceInitial(victimAlliance) .. " " .. tostring(victimName or "")

    CHX.debug.lastKillFeedEvent = tostring(entry.name)
    CHX.debug.lastKillFeedPayload =
        tostring(killerName or "") .. "(" .. tostring(killerAlliance or "") .. ") > " ..
        tostring(victimName or "") .. "(" .. tostring(victimAlliance or "") .. ")"
end


local function DebugValue(value)
    if value == nil then
        return "nil"
    end

    return tostring(value)
end

local function JoinKillFeedRaw(...)
    local n = select("#", ...)
    local parts = {}

    for i = 1, n do
        parts[#parts + 1] = tostring(i) .. "=" .. DebugValue(select(i, ...))
    end

    return table.concat(parts, " | "), n
end

local UpdatePvpStatsRow

local function OnPvpKillFeedDeath(eventCode, ...)
    CHX.debug.lastKillFeedCallCount = (tonumber(CHX.debug.lastKillFeedCallCount) or 0) + 1

    local raw, argCount = JoinKillFeedRaw(...)
    CHX.debug.lastKillFeedRaw = raw
    CHX.debug.lastKillFeedArgs = argCount

    -- Xbox payload observed:
    -- 1 location
    -- 2 killer display name
    -- 3 killer character name
    -- 4 killer alliance
    -- 5 killer rank
    -- 6 victim display name
    -- 7 victim character name
    -- 8 victim alliance
    -- 9 victim rank
    -- 10 player kill boolean
    local killLocation = select(1, ...)
    local killerDisplayName = select(2, ...)
    local killerCharacterName = select(3, ...)
    local killerAlliance = select(4, ...)
    local victimDisplayName = select(6, ...)
    local victimCharacterName = select(7, ...)
    local victimAlliance = select(8, ...)

    local killerName = killerDisplayName or killerCharacterName or ""
    local victimName = victimDisplayName or victimCharacterName or ""

    CHX.debug.lastKillFeedEvent = tostring(killLocation or "")
    CHX.debug.lastKillFeedPayload =
        tostring(CleanPlayerNameForKillFeed(killerName or "")) .. "(" .. tostring(killerAlliance or "") .. ") > " ..
        tostring(CleanPlayerNameForKillFeed(victimName or "")) .. "(" .. tostring(victimAlliance or "") .. ")"

    StoreKillLocation(killLocation, killerAlliance, victimAlliance, killerName, victimName)

    local state = EnsurePvpStatsState()
    local session = state and state.session

    if session then
        local playerIsKiller = IsPlayerStatName(killerDisplayName, killerCharacterName)
        local playerIsVictim = IsPlayerStatName(victimDisplayName, victimCharacterName)
        local cleanKiller = NormalizeTrackedName(killerName)
        local cleanVictim = NormalizeTrackedName(victimName)

        -- On Xbox, the PvP kill-feed payload is more reliable than combat-event
        -- killing-blow payloads for "Alliance VS Alliance Kills" style tracking.
        if playerIsKiller and cleanVictim ~= "" then
            local killKey = "killfeed:kill:" .. string.lower(cleanVictim)

            if not WasRecentStatEvent(session, killKey, 8) then
                RecordKillingBlow(cleanVictim, "PvP Kill Feed", 0)
                RecordOpponentKill(cleanVictim, "PvP Kill Feed", 0)

                local known = EnsureOpponentRecord(session.opponents, cleanVictim)
                if known and StatsIsValidAlliance(victimAlliance) then
                    known.alliance = victimAlliance
                end

                local lifetime = EnsurePvpStatsLifetime()
                local lifetimeOpponent = lifetime and EnsureOpponentRecord(lifetime.opponents, cleanVictim)
                if lifetimeOpponent and StatsIsValidAlliance(victimAlliance) then
                    lifetimeOpponent.alliance = victimAlliance
                end
            end
        elseif playerIsVictim and cleanKiller ~= "" then
            -- Do not count deaths from the kill feed. EVENT_PLAYER_DEAD gives the
            -- real death ability; counting the feed too duplicates the death and
            -- creates a fake "PvP Kill Feed" death cause.
            local known = EnsureOpponentRecord(session.opponents, cleanKiller)
            if known and StatsIsValidAlliance(killerAlliance) then
                known.alliance = killerAlliance
            end

            local lifetime = EnsurePvpStatsLifetime()
            local lifetimeOpponent = lifetime and EnsureOpponentRecord(lifetime.opponents, cleanKiller)
            if lifetimeOpponent and StatsIsValidAlliance(killerAlliance) then
                lifetimeOpponent.alliance = killerAlliance
            end
        end

        UpdatePvpStatsRow()
    end
end


local function FormatAllianceCounts(prefix, counts)
    counts = counts or {}

    local dc = tonumber(counts[DC]) or 0
    local ep = tonumber(counts[EP]) or 0
    local ad = tonumber(counts[AD]) or 0

    return prefix .. tostring(dc) .. "/" .. tostring(ep) .. "/" .. tostring(ad)
end



local function GetPvpStatsDeathBlowInfo()
    if type(GetNumKillingAttacks) ~= "function" or type(GetKillingAttackInfo) ~= "function" or type(GetKillingAttackerInfo) ~= "function" then
        return nil
    end

    local numKillingAttacks = GetNumKillingAttacks()

    for i = numKillingAttacks, 1, -1 do
        local attackName, attackDamage, attackIcon, wasKillingBlow = GetKillingAttackInfo(i)

        if wasKillingBlow == true then
            local attackerName, attackerChampionPoints, attackerLevel, attackerAvARank, isPlayer, isBoss, alliance, minionName, attackerDisplayName = GetKillingAttackerInfo(i)

            return {
                name = attackerName,
                isPlayer = isPlayer,
                abilityName = attackName,
                abilityIcon = attackIcon,
                account = attackerDisplayName,
                alliance = alliance,
            }
        end
    end

    return nil
end

UpdatePvpStatsRow = function()
    if not CreateUI() or not CHX.ui or not CHX.ui.pvpStatsText then return end

    CHX.ui.pvpStatsText:SetText(FormatPvpStatsStatsText())

    if CHX.ui.pvpStatsPerfText then
        CHX.ui.pvpStatsPerfText:SetText(FormatPvpStatsPerformanceText())
    end

    UpdateStatsPanelStatsPages()
end

local function OnPvpStatsAlliancePointUpdate(eventCode, alliancePoints, playSound, difference, reason)
    if not IsSupportedPvpStatsZone() then return end
    if reason == CURRENCY_CHANGE_REASON_BANK_DEPOSIT or reason == CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL or reason == CURRENCY_CHANGE_REASON_VENDOR then return end
    difference = tonumber(difference) or 0
    if difference < 0 then return end
    local state = EnsurePvpStatsState()
    local lifetime = EnsurePvpStatsLifetime()
    if not state or not state.session or not lifetime then return end
    state.session.alliancePoints = (tonumber(state.session.alliancePoints) or 0) + difference
    lifetime.alliancePoints = (tonumber(lifetime.alliancePoints) or 0) + difference
    UpdateLifetimeRecordsFromSession()
    UpdatePvpStatsRow()
end

local function OnPvpStatsPlayerDead(eventCode)
    if not IsSupportedPvpStatsZone() then return end
    local deathBlow = GetPvpStatsDeathBlowInfo()
    if deathBlow and deathBlow.isPlayer == false then return end

    local state = EnsurePvpStatsState()
    local killerName = deathBlow and NormalizeTrackedName(deathBlow.account or "") or ""
    if killerName == "" then
        killerName = deathBlow and NormalizeTrackedName(deathBlow.name) or "unknown"
    end
    local deathKey = "death:" .. string.lower(killerName)

    if state and state.session and WasRecentStatEvent(state.session, deathKey, 8) then
        return
    end

    RecordPlayerDeath(deathBlow)
    UpdatePvpStatsRow()
end

local function OnPvpStatsCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if result ~= ACTION_RESULT_KILLING_BLOW then return end
    if not IsSupportedPvpStatsZone() then return end
    local state = EnsurePvpStatsState()
    if not state or not state.session then return end
    sourceName = zo_strformat("<<1>>", sourceName or "")
    targetName = zo_strformat("<<1>>", targetName or "")
    local playerName = state.playerName or ""
    if sourceName ~= playerName and targetName ~= playerName then return end
    if sourceName == playerName then
        state.playerUnitId = sourceUnitId
    elseif targetName == playerName then
        state.playerUnitId = targetUnitId
    end
    if targetType ~= COMBAT_UNIT_TYPE_OTHER then return end
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER and sourceType ~= COMBAT_UNIT_TYPE_PLAYER_PET then return end
    if abilityName == "" then abilityName = nil end

    local cleanTargetName = NormalizeTrackedName(targetName)
    local killKey = "combat:kill:" .. string.lower(cleanTargetName)

    if WasRecentStatEvent(state.session, killKey, 8) then
        return
    end

    if not abilityName then
        if state.recentKBs[targetName] ~= nil then
            state.recentKBs[targetName] = nil
            return
        end
        state.recentKBs.count = 0
        state.session.kbStreak = 0
    else
        state.recentKBs.count = (tonumber(state.recentKBs.count) or 0) + 1
        state.recentKBs[targetName] = abilityName
        RecordKillingBlow(targetName, abilityName, hitValue)
    end

    RecordOpponentKill(targetName, abilityName, hitValue)
    UpdatePvpStatsRow()
end

local function FormatAllianceLetterCounts(counts)
    counts = counts or {}

    local dc = tonumber(counts[DC]) or 0
    local ep = tonumber(counts[EP]) or 0
    local ad = tonumber(counts[AD]) or 0

    return "D" .. tostring(dc) .. " E" .. tostring(ep) .. " A" .. tostring(ad)
end

local function AddKillLocationRows(out)
    if not CHX.saved or not CHX.saved.showKillLocations then
        CHX.debug.lastKillLocationCount = 0
        return
    end

    local now = GetNow()
    local holdSeconds = tonumber(CHX.saved.killLocationHoldSeconds) or CHX.defaults.killLocationHoldSeconds
    local count = 0

    for key, entry in pairs(CHX.killLocations) do
        local updated = tonumber(entry.updated) or now
        local age = GetDeltaSeconds(updated)

        if holdSeconds > 0 and age > holdSeconds then
            CHX.killLocations[key] = nil
        else
            entry.elapsed = GetDeltaSeconds(entry.started or updated)
            entry.killCountText = FormatAllianceLetterCounts(entry.kills)
            entry.deathCountText = "Deaths " .. FormatAllianceLetterCounts(entry.deaths)
            entry.attSiege = entry.killCountText
            entry.defSiege = entry.deathCountText
            entry.attAlliance = NONE
            entry.isKillLocation = true
            entry.priority = entry.priority or 8
            out[#out + 1] = entry
            count = count + 1
        end
    end

    CHX.debug.lastKillLocationCount = count
end

local function AddTestKillRows(out)
    if not CHX.saved or not CHX.saved.showTestRows then
        return
    end

    local now = GetNow()

    out[#out + 1] = {
        keepId = -101,
        started = now - 88,
        firstSeen = now - 88,
        updated = now - 5,
        name = "Test Kill Location",
        owner = NONE,
        priority = 0.5,
        icon = "/esoui/art/icons/ava_siege_weapon_001.dds",
        elapsed = 88,
        underAttack = false,
        active = true,
        finished = false,
        isKillLocation = true,
        kills = {
            [AD] = 2,
            [EP] = 1,
            [DC] = 4,
        },
        deaths = {
            [AD] = 3,
            [EP] = 2,
            [DC] = 1,
        },
        killCountText = "D4 E1 A2",
        deathCountText = "Deaths D1 E2 A3",
        attSiege = "D4 E1 A2",
        defSiege = "Deaths D1 E2 A3",
        attAlliance = NONE,
    }
end

local function BuildKillLocationEntries()
    local out = {}

    AddKillLocationRows(out)
    AddTestKillRows(out)

    table.sort(out, function(a, b)
        if (a.updated or 0) ~= (b.updated or 0) then
            return (a.updated or 0) > (b.updated or 0)
        end

        return tostring(a.name) < tostring(b.name)
    end)

    return out
end


local function AddMovingObjectiveRows(out)
    ScanKnownScrollMovement()

    if not CHX.saved or not CHX.saved.showMovingObjectives then
        CHX.debug.lastMovingObjectiveCount = 0
        return
    end

    local now = GetNow()
    local holdSeconds = tonumber(CHX.saved.movingObjectiveHoldSeconds) or CHX.defaults.movingObjectiveHoldSeconds
    local count = 0

    for key, obj in pairs(CHX.movingObjectives) do
        local updated = tonumber(obj.updated) or now
        local age = GetDeltaSeconds(updated)

        if holdSeconds > 0 and age > holdSeconds then
            CHX.movingObjectives[key] = nil
        else
            obj.elapsed = GetDeltaSeconds(obj.started or updated)
            obj.priority = obj.priority or 0
            obj.isMovingObjective = true
            obj.owner = obj.alliance or obj.holdingAlliance or NONE
            obj.attSiege = ""
            obj.defSiege = ""
            obj.attAlliance = NONE
            obj.underAttack = false

            out[#out + 1] = obj
            count = count + 1
        end
    end

    CHX.debug.lastMovingObjectiveCount = count
end

local function BuildVisibleEntries()
    local out = {}

    if CHX.saved and CHX.saved.showTestRows then
        AddTestRows(out)
    end

    AddMovingObjectiveRows(out)

    if IsInAvAWorldSafe() then
        for i = 1, #CHX.keepIds do
            local entry = GetEntryForKeep(CHX.keepIds[i])

            if entry then
                out[#out + 1] = entry
            end
        end
    end

    table.sort(out, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        end

        if a.isKillLocation and b.isKillLocation then
            return (a.updated or 0) > (b.updated or 0)
        end

        if a.started ~= b.started then
            return a.started < b.started
        end

        return tostring(a.name) < tostring(b.name)
    end)

    local newCount = 0
    local finishedCount = 0
    local resourceIconCount = 0
    local scrollIconCount = 0
    local flagArrowCount = 0
    local movingObjectiveCount = 0
    local killLocationCount = 0

    for i = 1, #out do
        if out[i].isMovingObjective then
            movingObjectiveCount = movingObjectiveCount + 1
        end

        if out[i].isKillLocation then
            killLocationCount = killLocationCount + 1
        end

        if out[i].finished then
            finishedCount = finishedCount + 1
        else
            local fadeSeconds = tonumber(CHX.saved.newBattleFadeSeconds) or CHX.defaults.newBattleFadeSeconds

            if (out[i].elapsed or 9999) < fadeSeconds then
                newCount = newCount + 1
            end

            if out[i].resources then
                if out[i].resources.lumber and out[i].resources.lumber.alliance then resourceIconCount = resourceIconCount + 1 end
                if out[i].resources.mine and out[i].resources.mine.alliance then resourceIconCount = resourceIconCount + 1 end
                if out[i].resources.farm and out[i].resources.farm.alliance then resourceIconCount = resourceIconCount + 1 end
            end

            if out[i].scrollTexture then
                scrollIconCount = scrollIconCount + 1
            end

            if out[i].flagAlliance then
                flagArrowCount = flagArrowCount + 1
            end
        end
    end

    CHX.debug.lastScanCount = #CHX.keepIds
    CHX.debug.lastVisibleCount = #out
    CHX.debug.lastNewBattleCount = newCount
    CHX.debug.lastFinishedBattleCount = finishedCount
    CHX.debug.lastResourceIconCount = resourceIconCount
    CHX.debug.lastScrollIconCount = scrollIconCount
    CHX.debug.lastFlagArrowCount = flagArrowCount

    if movingObjectiveCount > CHX.debug.lastMovingObjectiveCount then
        CHX.debug.lastMovingObjectiveCount = movingObjectiveCount
    end

    if killLocationCount > CHX.debug.lastKillLocationCount then
        CHX.debug.lastKillLocationCount = killLocationCount
    end

    return out
end

local function SetScoreText(label, alliance, potential)
    if not label then return end

    label:SetColor(GetAllianceColorSafe(alliance))

    potential = tonumber(potential) or 0

    if potential > 0 then
        label:SetText("+" .. FormatNumber(potential) .. "p")
    else
        label:SetText("+0p")
    end
end

local function SetScoreHeaderHidden(hidden)
    if not CHX.ui then return end

    local controls = {
        CHX.ui.scoreTime,
        CHX.ui.scoreIconAD,
        CHX.ui.scoreIconEP,
        CHX.ui.scoreIconDC,
        CHX.ui.scoreAD,
        CHX.ui.scoreEP,
        CHX.ui.scoreDC,
        CHX.ui.scoreScrollIconAD,
        CHX.ui.scoreScrollIconEP,
        CHX.ui.scoreScrollIconDC,
        CHX.ui.scoreScrollAD,
        CHX.ui.scoreScrollEP,
        CHX.ui.scoreScrollDC,
        CHX.ui.scoreLowPopAD,
        CHX.ui.scoreLowPopEP,
        CHX.ui.scoreLowPopDC,
        CHX.ui.scoreLowScoreAD,
        CHX.ui.scoreLowScoreEP,
        CHX.ui.scoreLowScoreDC,
    }

    for i = 1, #controls do
        if controls[i] then
            controls[i]:SetHidden(hidden)
        end
    end
end

local function GetNextScoreTimeText(campaign)
    local nextScore = SafeCall(
        "GetSecondsUntilCampaignScoreReevaluation",
        GetSecondsUntilCampaignScoreReevaluation,
        0,
        campaign
    ) or 0

    CHX.debug.lastScoreTime = FormatTime(nextScore)

    if nextScore <= 0 then
        return "0:00"
    end

    return FormatTime(nextScore)
end

local function SetScoreScrollCounts(ad, ep, dc)
    ad = tonumber(ad) or 0
    ep = tonumber(ep) or 0
    dc = tonumber(dc) or 0

    CHX.debug.lastScrollCountAD = ad
    CHX.debug.lastScrollCountEP = ep
    CHX.debug.lastScrollCountDC = dc

    if not CHX.ui then return end

    local hidden = not (CHX.saved and CHX.saved.showScrollCounts)

    if CHX.ui.scoreScrollIconAD then CHX.ui.scoreScrollIconAD:SetHidden(hidden) end
    if CHX.ui.scoreScrollIconEP then CHX.ui.scoreScrollIconEP:SetHidden(hidden) end
    if CHX.ui.scoreScrollIconDC then CHX.ui.scoreScrollIconDC:SetHidden(hidden) end
    if CHX.ui.scoreScrollAD then CHX.ui.scoreScrollAD:SetHidden(hidden) end
    if CHX.ui.scoreScrollEP then CHX.ui.scoreScrollEP:SetHidden(hidden) end
    if CHX.ui.scoreScrollDC then CHX.ui.scoreScrollDC:SetHidden(hidden) end

    if hidden then
        return
    end

    CHX.ui.scoreScrollAD:SetText(tostring(ad))
    CHX.ui.scoreScrollEP:SetText(tostring(ep))
    CHX.ui.scoreScrollDC:SetText(tostring(dc))
end


local function SetScoreBonusIcon(control, shouldShow)
    if control then
        control:SetHidden(not shouldShow)
    end
end

local function SetScoreBonusIconsForValues(lowPopAD, lowPopEP, lowPopDC, lowScoreAD, lowScoreEP, lowScoreDC, mode, leader)
    if not CHX.ui then return end

    local hidden = not (CHX.saved and CHX.saved.showScoreBonusIcons)

    if hidden then
        lowPopAD, lowPopEP, lowPopDC = false, false, false
        lowScoreAD, lowScoreEP, lowScoreDC = false, false, false
    end

    SetScoreBonusIcon(CHX.ui.scoreLowPopAD, lowPopAD == true)
    SetScoreBonusIcon(CHX.ui.scoreLowPopEP, lowPopEP == true)
    SetScoreBonusIcon(CHX.ui.scoreLowPopDC, lowPopDC == true)
    SetScoreBonusIcon(CHX.ui.scoreLowScoreAD, lowScoreAD == true)
    SetScoreBonusIcon(CHX.ui.scoreLowScoreEP, lowScoreEP == true)
    SetScoreBonusIcon(CHX.ui.scoreLowScoreDC, lowScoreDC == true)

    CHX.debug.lastLowPopBonus = "D" .. tostring(lowPopDC == true) .. " E" .. tostring(lowPopEP == true) .. " A" .. tostring(lowPopAD == true)
    CHX.debug.lastLowScoreLeader = tostring(leader or "")
    CHX.debug.lastScoreBonusMode = tostring(mode or "")
end

local function UpdateScoreBonusIcons(campaign)
    if CHX.bonusTest then
        SetScoreBonusIconsForValues(true, true, true, true, true, true, "bonus test", AD)
        return
    end

    if not CHX.saved or not CHX.saved.showScoreBonusIcons or not campaign or campaign == 0 then
        SetScoreBonusIconsForValues(false, false, false, false, false, false, "hidden", "")
        return
    end

    local adLowPop = SafeCall("IsUnderpopBonusEnabled AD", IsUnderpopBonusEnabled, false, campaign, AD) == true
    local epLowPop = SafeCall("IsUnderpopBonusEnabled EP", IsUnderpopBonusEnabled, false, campaign, EP) == true
    local dcLowPop = SafeCall("IsUnderpopBonusEnabled DC", IsUnderpopBonusEnabled, false, campaign, DC) == true

    local leader = SafeCall("GetCampaignUnderdogLeaderAlliance", GetCampaignUnderdogLeaderAlliance, NONE, campaign) or NONE
    local mode = "campaign"

    -- Some UI data is only loaded through the campaign selection browser. Use it as fallback.
    if (not IsValidAlliance(leader)) and type(GetSelectionCampaignUnderdogLeaderAlliance) == "function" then
        local selectionIndex = GetCampaignSelectionIndex(campaign)

        if selectionIndex ~= 0 then
            local selectionLeader = SafeCall("GetSelectionCampaignUnderdogLeaderAlliance", GetSelectionCampaignUnderdogLeaderAlliance, NONE, selectionIndex) or NONE

            if IsValidAlliance(selectionLeader) then
                leader = selectionLeader
                mode = "selection"
            end
        end
    end

    local adLowScore = false
    local epLowScore = false
    local dcLowScore = false

    if IsValidAlliance(leader) then
        adLowScore = leader ~= AD
        epLowScore = leader ~= EP
        dcLowScore = leader ~= DC
    end

    SetScoreBonusIconsForValues(adLowPop, epLowPop, dcLowPop, adLowScore, epLowScore, dcLowScore, mode, leader)
end

local function CountScrollForAlliance(alliance, ad, ep, dc)
    if alliance == AD then
        ad = ad + 1
    elseif alliance == EP then
        ep = ep + 1
    elseif alliance == DC then
        dc = dc + 1
    end

    return ad, ep, dc
end

local function CountOneScrollObjective(objectiveKeepId, objectiveId, bgContext, ad, ep, dc)
    local counted = false
    local capturedCount = 0
    local baseCount = 0
    local heldCount = 0
    local _, _, objectiveState = GetObjectiveDetails(objectiveKeepId, objectiveId, bgContext)

    -- Scroll stored in a keep: count the alliance that owns that keep.
    local capturedKeepId = GetScrollObjectiveCapturedKeep(objectiveKeepId, objectiveId, bgContext)

    if capturedKeepId ~= 0 then
        local alliance = SafeCall(
            "GetKeepAlliance captured scroll count",
            GetKeepAlliance,
            NONE,
            capturedKeepId,
            bgContext or BG
        ) or NONE

        if alliance == NONE then
            alliance = GetAllianceFromScrollTexture(GetObjectivePinTexture(objectiveKeepId, objectiveId, bgContext))
        end

        if alliance == AD or alliance == EP or alliance == DC then
            ad, ep, dc = CountScrollForAlliance(alliance, ad, ep, dc)
            capturedCount = 1
            counted = true
        end
    end

    -- Scroll being carried/dropped: count current/last holding alliance.
    if not counted and IsHeldOrDroppedScrollState(objectiveState) and type(GetCarryableObjectiveHoldingAllianceInfo) == "function" then
        local holdingAlliance, lastHoldingAlliance = SafeCall(
            "GetCarryableObjectiveHoldingAllianceInfo scroll count",
            GetCarryableObjectiveHoldingAllianceInfo,
            NONE,
            objectiveKeepId,
            objectiveId,
            bgContext
        )

        local alliance = holdingAlliance

        if alliance ~= AD and alliance ~= EP and alliance ~= DC then
            alliance = lastHoldingAlliance
        end

        if alliance == AD or alliance == EP or alliance == DC then
            ad, ep, dc = CountScrollForAlliance(alliance, ad, ep, dc)
            heldCount = 1
            counted = true
        end
    end

    -- Scroll at home/enemy temple: count by scroll pin alliance first,
    -- then objective keep alliance.
    if not counted then
        local alliance = GetBaseScrollAlliance(objectiveKeepId, objectiveId, bgContext)

        if alliance == AD or alliance == EP or alliance == DC then
            ad, ep, dc = CountScrollForAlliance(alliance, ad, ep, dc)
            baseCount = 1
            counted = true
        end
    end

    return ad, ep, dc, capturedCount, baseCount, heldCount
end

local function GetOwnedScrollCounts()
    local ad = 0
    local ep = 0
    local dc = 0
    local scanned = 0
    local capturedCount = 0
    local baseCount = 0
    local heldCount = 0
    local knownTempleCount = 0
    local mode = "none"

    -- Xbox/managed builds can have GetNumObjectives unavailable. The six scroll
    -- temple keep IDs are stable, so scan those directly first.
    local knownScrollObjectives = BuildKnownScrollObjectiveList()

    for i = 1, #knownScrollObjectives do
        local objectiveKeepId = knownScrollObjectives[i].objectiveKeepId
        local objectiveId = knownScrollObjectives[i].objectiveId
        local bgContext = knownScrollObjectives[i].bgContext or BG

        scanned = scanned + 1
        knownTempleCount = knownTempleCount + 1

        local c1, b1, h1
        ad, ep, dc, c1, b1, h1 = CountOneScrollObjective(objectiveKeepId, objectiveId, bgContext, ad, ep, dc)
        capturedCount = capturedCount + (c1 or 0)
        baseCount = baseCount + (b1 or 0)
        heldCount = heldCount + (h1 or 0)
        mode = "known temples"
    end

    -- Only use the PC-style objective enumeration if the direct temple method
    -- found nothing.
    if scanned == 0 then
        if type(GetNumObjectives) ~= "function"
            or type(GetAvAObjectiveKeysByIndex) ~= "function" then
            CHX.debug.lastScrollCountScanned = scanned
            CHX.debug.lastScrollCountMode = "missing objective API"
            CHX.debug.lastScrollKnownTempleCount = knownTempleCount
            CHX.debug.lastScrollCapturedCount = capturedCount
            CHX.debug.lastScrollBaseCount = baseCount
            CHX.debug.lastScrollHeldCount = heldCount
            return ad, ep, dc
        end

        local numObjectives = SafeCall("GetNumObjectives scroll count", GetNumObjectives, 0) or 0

        for i = 1, numObjectives do
            local objectiveKeepId, objectiveId, bgContext = SafeCall(
                "GetAvAObjectiveKeysByIndex scroll count",
                GetAvAObjectiveKeysByIndex,
                nil,
                i
            )

            if objectiveKeepId and objectiveId and IsArtifactScrollObjective(objectiveKeepId, objectiveId, bgContext) then
                scanned = scanned + 1

                local c1, b1, h1
                ad, ep, dc, c1, b1, h1 = CountOneScrollObjective(objectiveKeepId, objectiveId, bgContext, ad, ep, dc)
                capturedCount = capturedCount + (c1 or 0)
                baseCount = baseCount + (b1 or 0)
                heldCount = heldCount + (h1 or 0)
                mode = "objective API"
            end
        end
    end

    CHX.debug.lastScrollCountScanned = scanned
    CHX.debug.lastScrollCountMode = mode
    CHX.debug.lastScrollCapturedCount = capturedCount
    CHX.debug.lastScrollBaseCount = baseCount
    CHX.debug.lastScrollHeldCount = heldCount
    CHX.debug.lastScrollKnownTempleCount = knownTempleCount

    return ad, ep, dc
end


local function UpdateScoreLabel()
    if not CHX.ui then return end

    if not CHX.saved or not CHX.saved.showScoring then
        SetScoreHeaderHidden(true)
        return
    end

    SetScoreHeaderHidden(false)

    local campaign = GetCurrentCampaignIdSafe()
    CHX.debug.lastCampaign = tostring(campaign)

    if CHX.saved.showTestRows and (not campaign or campaign == 0) then
        CHX.ui.scoreTime:SetText("4:55")
        SetScoreText(CHX.ui.scoreDC, DC, 58)
        SetScoreText(CHX.ui.scoreEP, EP, 211)
        SetScoreText(CHX.ui.scoreAD, AD, 79)
        SetScoreScrollCounts(3, 2, 1)
        SetScoreBonusIconsForValues(true, false, true, false, true, true, "test", AD)

        CHX.debug.lastScoreTime = "4:55"
        CHX.debug.lastScoreDC = 58
        CHX.debug.lastScoreEP = 211
        CHX.debug.lastScoreAD = 79
        return
    end

    if not campaign or campaign == 0 then
        CHX.ui.scoreTime:SetText("--:--")
        SetScoreText(CHX.ui.scoreDC, DC, 0)
        SetScoreText(CHX.ui.scoreEP, EP, 0)
        SetScoreText(CHX.ui.scoreAD, AD, 0)
        SetScoreScrollCounts(0, 0, 0)
        SetScoreBonusIconsForValues(false, false, false, false, false, false, "no campaign", "")

        CHX.debug.lastScoreTime = "--:--"
        CHX.debug.lastScoreDC = 0
        CHX.debug.lastScoreEP = 0
        CHX.debug.lastScoreAD = 0
        return
    end

    local adPotential = SafeCall("GetCampaignAlliancePotentialScore AD", GetCampaignAlliancePotentialScore, 0, campaign, AD) or 0
    local epPotential = SafeCall("GetCampaignAlliancePotentialScore EP", GetCampaignAlliancePotentialScore, 0, campaign, EP) or 0
    local dcPotential = SafeCall("GetCampaignAlliancePotentialScore DC", GetCampaignAlliancePotentialScore, 0, campaign, DC) or 0

    CHX.ui.scoreTime:SetText(GetNextScoreTimeText(campaign))
    SetScoreText(CHX.ui.scoreDC, DC, dcPotential)
    SetScoreText(CHX.ui.scoreEP, EP, epPotential)
    SetScoreText(CHX.ui.scoreAD, AD, adPotential)

    local scrollAD, scrollEP, scrollDC = GetOwnedScrollCounts()
    SetScoreScrollCounts(scrollAD, scrollEP, scrollDC)
    UpdateScoreBonusIcons(campaign)

    CHX.debug.lastScoreDC = dcPotential
    CHX.debug.lastScoreEP = epPotential
    CHX.debug.lastScoreAD = adPotential
end


local function HideRowResources(row)
    if row.lumber then row.lumber:SetHidden(true) end
    if row.mine then row.mine:SetHidden(true) end
    if row.farm then row.farm:SetHidden(true) end
end

local function ApplyRowResourceIcon(control, data)
    if not control then return false end

    if not data or not data.alliance then
        control:SetHidden(true)
        return false
    end

    control:SetTexture(data.icon or "/esoui/art/mappins/ava_farm_neutral.dds")
    control:SetColor(GetAllianceColorSafe(data.alliance))
    control:SetHidden(false)
    return true
end

local function UpdateRowResources(row, entry)
    if not row then return 0 end

    if not CHX.saved or not CHX.saved.showKeepResources or not entry or not entry.resources or entry.finished then
        HideRowResources(row)
        return 0
    end

    local count = 0

    if ApplyRowResourceIcon(row.lumber, entry.resources.lumber) then count = count + 1 end
    if ApplyRowResourceIcon(row.mine, entry.resources.mine) then count = count + 1 end
    if ApplyRowResourceIcon(row.farm, entry.resources.farm) then count = count + 1 end

    return count
end

local function HideRowScroll(row)
    if row.scroll then
        row.scroll:SetHidden(true)
    end
end

local function UpdateRowScroll(row, entry)
    if not row or not row.scroll then return false end

    if not CHX.saved or not CHX.saved.showScrollIcons or not entry or not entry.scrollTexture or entry.finished then
        row.scroll:SetHidden(true)
        return false
    end

    row.scroll:SetTexture(entry.scrollTexture)
    row.scroll:SetHidden(false)
    return true
end

local function SetRowNameAnchor(row, x, width)
    if not row or not row.name then return end

    row.name:ClearAnchors()
    row.name:SetAnchor(TOPLEFT, row, TOPLEFT, x or 35, 5)
    row.name:SetDimensions(width or 150, 30)
end

local function SetRowLabelAnchor(control, row, x, y, width, height)
    if not control or not row then return end

    control:ClearAnchors()
    control:SetAnchor(TOPLEFT, row, TOPLEFT, x or 0, y or 0)
    control:SetDimensions(width or 30, height or 30)
end

local function SetLabelFontSafe(control, font)
    if control and type(control.SetFont) == "function" then
        control:SetFont(font)
    end
end

local function ResetRowIconLayout(row)
    if not row or not row.icon then return end

    row.icon:ClearAnchors()
    row.icon:SetAnchor(TOPLEFT, row, TOPLEFT, -2, -2)
    row.icon:SetDimensions(40, 40)
    row.icon:SetDrawLayer(0)
    row.icon:SetHidden(false)
end

local function SetKillRowIconLayout(row)
    if not row or not row.icon then return end

    row.icon:ClearAnchors()
    row.icon:SetAnchor(TOPLEFT, row, TOPLEFT, 6, 7)
    row.icon:SetDimensions(20, 20)
    row.icon:SetDrawLayer(2)
    row.icon:SetTexture("/esoui/art/icons/ava_siege_weapon_001.dds")
    row.icon:SetColor(0.85, 0.85, 0.85, 0.90)
    row.icon:SetHidden(false)
end

local function ResetRowTextLayout(row)
    if not row then return end

    SetRowNameAnchor(row, 35, 150)
    SetRowLabelAnchor(row.attSiege, row, 190, 5, 30, 30)
    SetRowLabelAnchor(row.defSiege, row, 224, 5, 30, 30)
    SetRowLabelAnchor(row.time, row, 266, 5, 50, 30)

    SetLabelFontSafe(row.name, FONT_MAIN)
    SetLabelFontSafe(row.attSiege, FONT_MAIN)
    SetLabelFontSafe(row.defSiege, FONT_MAIN)
    SetLabelFontSafe(row.time, FONT_MAIN)
    if row.time then row.time:SetHorizontalAlignment(TEXT_ALIGN_LEFT) end

    if row.killSub then
        row.killSub:SetHidden(true)
        row.killSub:SetText("")
    end
end

local function SetKillRowLayout(row)
    if not row then return end

    SetRowLabelAnchor(row.name, row, 30, 0, 127, 22)
    SetRowLabelAnchor(row.attSiege, row, 158, 2, 82, 18)
    SetRowLabelAnchor(row.defSiege, row, 224, 5, 1, 1)
    SetRowLabelAnchor(row.time, row, 266, 5, 50, 30)

    SetLabelFontSafe(row.name, FONT_MAIN)
    SetLabelFontSafe(row.attSiege, FONT_SMALL)
    SetLabelFontSafe(row.defSiege, FONT_SMALL)
    SetLabelFontSafe(row.time, FONT_MAIN)
    if row.time then row.time:SetHorizontalAlignment(TEXT_ALIGN_LEFT) end

    if row.killSub then
        SetLabelFontSafe(row.killSub, FONT_SMALL)
        SetRowLabelAnchor(row.killSub, row, 30, 21, 210, 12)
        row.killSub:SetHidden(false)
    end
end

local function HideRowArrow(row)
    if row and row.arrow then
        row.arrow:SetHidden(true)
        row.arrow:SetAlpha(0)
    end

    SetRowNameAnchor(row, 35, 150)
end

local function UpdateRowArrow(row, entry)
    if not row or not row.arrow then return false end

    if not CHX.saved or not CHX.saved.showFlagArrows or not entry or not entry.flagAlliance or entry.finished then
        HideRowArrow(row)
        return false
    end

    row.arrow:SetColor(GetAllianceColorSafe(entry.flagAlliance))
    row.arrow:SetTransformRotationZ(math.rad(180))

    -- Soft pulse, but not disappearing enough to look broken/flickery.
    local pulse = 0.95

    if (GetNow() % 2) == 0 then
        pulse = 0.70
    end

    row.arrow:SetAlpha(pulse)
    row.arrow:SetHidden(false)

    -- Keep the text readable and stop the arrow covering the first letters.
    SetRowNameAnchor(row, 49, 136)

    return true
end

local function UpdateRow(index, entry)
    local row = EnsureRow(index)

    if not row then return end

    row:SetHidden(false)
    ResetRowTextLayout(row)
    ResetRowIconLayout(row)
    row.icon:SetTexture(entry.icon or "/esoui/art/mappins/ava_largekeep_neutral.dds")
    row.icon:SetColor(GetAllianceColorSafe(entry.owner or NONE))

    if entry.isMovingObjective then
        HideRowResources(row)
        HideRowScroll(row)
        HideRowArrow(row)

        if row.ua then row.ua:SetHidden(true) end

        local label = tostring(entry.name or "Moving Objective")
        local holder = tostring(entry.holder or "")
        local eventText = tostring(entry.eventText or "")

        if holder ~= "" then
            label = label .. " " .. holder
        elseif eventText ~= "" then
            label = label .. " " .. eventText
        end

        row.name:SetText(label)
        row.name:SetColor(GetAllianceColorSafe(entry.owner or NONE))

        row.attSiege:SetText("")
        row.defSiege:SetText("")
        row.attIcon:SetHidden(true)
        row.defIcon:SetHidden(true)
        row.time:SetText(FormatTime(entry.elapsed or 0))
        row.time:SetColor(0.85, 0.85, 0.85, 1)
        row.bg:SetCenterColor(0, 0, 0, 0.30)
        return
    end

    if entry.isKillLocation then
        HideRowResources(row)
        HideRowScroll(row)
        HideRowArrow(row)
        SetKillRowLayout(row)
        SetKillRowIconLayout(row)

        if row.ua then row.ua:SetHidden(true) end

        row.name:SetText(tostring(entry.name or "PvP Battle"))
        row.name:SetColor(0.90, 0.90, 0.90, 1)

        local killText = tostring(entry.killCountText or entry.attSiege or "")
        local deathText = tostring(entry.deathCountText or entry.defSiege or "")

        row.attSiege:SetText(killText)
        row.attSiege:SetColor(0.80, 0.90, 1.00, 1)
        row.attIcon:SetHidden(true)

        row.defSiege:SetText("")
        row.defSiege:SetHidden(true)
        row.defIcon:SetHidden(true)

        if row.killSub then
            row.killSub:SetText(deathText)
            row.killSub:SetColor(1.00, 0.75, 0.75, 1)
            row.killSub:SetHidden(false)
        end

        row.time:SetText(FormatTime(entry.elapsed or 0))
        row.time:SetColor(0.85, 0.85, 0.85, 1)
        row.bg:SetCenterColor(0, 0, 0, 0.30)
        return
    end

    UpdateRowResources(row, entry)
    UpdateRowScroll(row, entry)
    UpdateRowArrow(row, entry)

    if row.ua then
        row.ua:SetHidden(not entry.underAttack)
    end

    row.name:SetText(tostring(entry.name or "Objective"))

    SetObjectiveNameColor(row, entry)

    local attText = tostring(entry.attSiege or "")
    local defText = tostring(entry.defSiege or "")

    row.attSiege:SetText(attText)
    row.attSiege:SetColor(GetAllianceColorSafe(entry.attAlliance or NONE))
    row.attIcon:SetColor(GetAllianceColorSafe(entry.attAlliance or NONE))
    row.attIcon:SetHidden(attText == "")

    row.defSiege:SetHidden(false)
    row.defSiege:SetText(defText)
    row.defSiege:SetColor(GetAllianceColorSafe(entry.owner or NONE))
    row.defIcon:SetColor(GetAllianceColorSafe(entry.owner or NONE))
    row.defIcon:SetHidden(defText == "")

    row.time:SetText(FormatTime(entry.elapsed or 0))

    if entry.finished then
        row.time:SetColor(0.70, 0.70, 0.70, 1)
        row.name:SetColor(0.70, 0.70, 0.70, 1)

        if row.ua then
            row.ua:SetHidden(true)
        end

        HideRowArrow(row)

        row.bg:SetCenterColor(0.45, 0.45, 0.45, 0.24)
    else
        row.time:SetColor(0.85, 0.85, 0.85, 1)

        local fadeSeconds = tonumber(CHX.saved.newBattleFadeSeconds) or CHX.defaults.newBattleFadeSeconds
        local elapsed = tonumber(entry.elapsed) or 9999
        local fade = 0

        if fadeSeconds > 0 and elapsed < fadeSeconds then
            fade = 1 - (elapsed / fadeSeconds)
        end

        if fade > 0 then
            -- New battle: red fades back to the normal black row backing.
            row.bg:SetCenterColor(0.50 * fade, 0, 0, 0.30)
        else
            row.bg:SetCenterColor(0, 0, 0, 0.30)
        end
    end
end

local function HideUnusedRows(fromIndex)
    if not CHX.ui or not CHX.ui.rows then return end

    for i = fromIndex, #CHX.ui.rows do
        HideRowArrow(CHX.ui.rows[i])
        if CHX.ui.rows[i].killSub then
            CHX.ui.rows[i].killSub:SetHidden(true)
            CHX.ui.rows[i].killSub:SetText("")
        end
        CHX.ui.rows[i]:SetHidden(true)
    end
end

local function SetQueueState(campaignId, isGroup, position, state, eventName, name)
    campaignId = tonumber(campaignId) or 0

    if campaignId == 0 then
        return
    end

    if not CHX.queue then
        CHX.queue = {}
    end

    if position == nil then
        position = SafeCall("GetCampaignQueuePosition", GetCampaignQueuePosition, nil, campaignId, isGroup == true)
    end

    if state == nil then
        state = SafeCall("GetCampaignQueueState", GetCampaignQueueState, nil, campaignId, isGroup == true)
    end

    CHX.queue.campaignId = campaignId
    CHX.queue.isGroup = isGroup == true
    CHX.queue.position = tonumber(position) or 0
    CHX.queue.state = state
    CHX.queue.name = (name and tostring(name) ~= "" and tostring(name)) or GetCampaignNameSafe(campaignId)
    CHX.queue.updated = GetNow()

    CHX.debug.lastQueueEvent = tostring(eventName or "")
    CHX.debug.lastQueueCampaign = tostring(campaignId)
    CHX.debug.lastQueueCampaignName = tostring(CHX.queue.name or "")
    CHX.debug.lastQueuePosition = tostring(CHX.queue.position or "")
    CHX.debug.lastQueueState = tostring(CHX.queue.state or "")
    CHX.debug.lastQueueIsGroup = tostring(CHX.queue.isGroup)
end

local function ClearQueueState(eventName)
    CHX.queue = nil
    CHX.debug.lastQueueEvent = tostring(eventName or "cleared")
    CHX.debug.lastQueueCampaign = ""
    CHX.debug.lastQueueCampaignName = ""
    CHX.debug.lastQueuePosition = ""
    CHX.debug.lastQueueState = ""
    CHX.debug.lastQueueIsGroup = ""
    CHX.debug.lastQueueApiMode = ""
    CHX.debug.lastQueueHold = ""
end

local function IsQueueInfoActive(campaignId, isGroup, position, state)
    local queued = SafeCall("IsQueuedForCampaign", IsQueuedForCampaign, false, campaignId, isGroup == true)

    if queued == true then
        return true
    end

    local pos = tonumber(position) or 0

    if pos > 0 then
        return true
    end

    -- Do NOT treat queue state alone as active. On Xbox/console UI data,
    -- campaign rows can carry non-zero/non-empty state values even when the
    -- player is not actually queued. That is what made the fake/test window
    -- reopen as "CP Imperial City".
    return false
end

local function CheckOneCampaignQueue(campaignId, isGroup, name)
    campaignId = tonumber(campaignId) or 0

    if campaignId == 0 then
        return false
    end

    local position = SafeCall("GetCampaignQueuePosition", GetCampaignQueuePosition, nil, campaignId, isGroup == true)
    local state = SafeCall("GetCampaignQueueState", GetCampaignQueueState, nil, campaignId, isGroup == true)

    if IsQueueInfoActive(campaignId, isGroup == true, position, state) then
        SetQueueState(campaignId, isGroup == true, position, state, "scan-api", name)
        CHX.debug.lastQueueApiMode = "api"
        return true
    end

    return false
end

local function TryQueueDataFromEntry(data, source)
    if type(data) ~= "table" then
        return false
    end

    local queueData = nil
    local name = data.name

    if data.queue and (data.queue.isQueued == true or tonumber(data.queue.position or 0) > 0) then
        queueData = data.queue
        name = data.name
    elseif data.isQueued == true or tonumber(data.position or 0) > 0 then
        queueData = data
        name = data.name
    end

    if not queueData then
        return false
    end

    local id = tonumber(queueData.id or data.id or queueData.campaignId or data.campaignId) or 0

    if id == 0 then
        return false
    end

    local isGroup = queueData.isGroup == true or data.isGroup == true
    local position = queueData.position or SafeCall("GetCampaignQueuePosition " .. tostring(source or "entry"), GetCampaignQueuePosition, nil, id, isGroup)
    local state = queueData.state or SafeCall("GetCampaignQueueState " .. tostring(source or "entry"), GetCampaignQueueState, nil, id, isGroup)
    local queued = queueData.isQueued == true or SafeCall("IsQueuedForCampaign " .. tostring(source or "entry"), IsQueuedForCampaign, false, id, isGroup) == true

    if queued or IsQueueInfoActive(id, isGroup, position, state) then
        SetQueueState(id, isGroup, position, state, tostring(source or "entry"), name)
        CHX.debug.lastQueueApiMode = tostring(source or "entry")
        return true
    end

    return false
end

local function ScanQueueList(list, source)
    if type(list) ~= "table" then
        return false
    end

    local rows = 0

    for _, data in pairs(list) do
        rows = rows + 1

        if TryQueueDataFromEntry(data, source) then
            CHX.debug.lastQueueBrowserRows = tostring(source or "") .. ":" .. tostring(rows)
            return true
        end
    end

    CHX.debug.lastQueueBrowserRows = tostring(source or "") .. ":" .. tostring(rows)
    return false
end

local function ScanCampaignBrowserManagerQueue()
    if CAMPAIGN_BROWSER_MANAGER and type(CAMPAIGN_BROWSER_MANAGER.GetCampaignDataList) == "function" then
        local list = SafeCall(
            "CAMPAIGN_BROWSER_MANAGER:GetCampaignDataList",
            function()
                return CAMPAIGN_BROWSER_MANAGER:GetCampaignDataList()
            end,
            nil
        )

        if ScanQueueList(list, "manager") then
            return true
        end
    end

    if CAMPAIGN_BROWSER and type(CAMPAIGN_BROWSER.masterList) == "table" then
        if ScanQueueList(CAMPAIGN_BROWSER.masterList, "browser-master") then
            return true
        end
    end

    if CAMPAIGN_BROWSER and type(CAMPAIGN_BROWSER.filteredList) == "table" then
        if ScanQueueList(CAMPAIGN_BROWSER.filteredList, "browser-filtered") then
            return true
        end
    end

    if CAMPAIGN_BROWSER and CAMPAIGN_BROWSER.list and type(ZO_ScrollList_GetDataList) == "function" then
        local scrollData = SafeCall("ZO_ScrollList_GetDataList campaign browser", ZO_ScrollList_GetDataList, nil, CAMPAIGN_BROWSER.list)

        if ScanQueueList(scrollData, "browser-scroll") then
            return true
        end
    end

    return false
end

local function ScanCampaignQueueStatus()
    if IsInAvAWorldSafe() then
        return nil
    end

    QueryCampaignSelectionDataSafe("queue scan")
    CHX.debug.lastQueueScan = tostring(GetNow())

    if CHX.queueTest and CHX.saved then
        CHX.queue = {
            campaignId = -1,
            isGroup = false,
            position = 12,
            state = "test",
            name = "QUEUE TEST WINDOW",
            updated = GetNow(),
        }

        CHX.debug.lastQueueEvent = "test"
        CHX.debug.lastQueueCampaign = "-1"
        CHX.debug.lastQueueCampaignName = "QUEUE TEST WINDOW"
        CHX.debug.lastQueuePosition = "12"
        CHX.debug.lastQueueState = "test"
        CHX.debug.lastQueueIsGroup = "false"
        CHX.debug.lastQueueApiMode = "test"
        return CHX.queue
    end

    if ScanCampaignBrowserManagerQueue() then
        return CHX.queue
    end

    if CHX.queue and CHX.queue.campaignId then
        local id = tonumber(CHX.queue.campaignId) or 0

        if id ~= 0 and CheckOneCampaignQueue(id, CHX.queue.isGroup == true, CHX.queue.name) then
            return CHX.queue
        end

        -- Some console builds fire the queue event/callback but do not return a
        -- useful queue position/state through the polling API immediately. Keep
        -- showing the last known queue until the leave event, entry into AvA, or
        -- a long stale timeout clears it.
        local age = GetDeltaSeconds(CHX.queue.updated or 0)

        if id == -1 and not CHX.queueTest then
            ClearQueueState("test cleared")
            return nil
        end

        if id ~= 0 and age < 1800 then
            CHX.debug.lastQueueHold = "held " .. tostring(age)
            return CHX.queue
        end
    end

    if type(GetNumSelectionCampaigns) == "function" and type(GetSelectionCampaignId) == "function" then
        local num = SafeCall("GetNumSelectionCampaigns", GetNumSelectionCampaigns, 0) or 0

        for i = 1, num do
            local id = SafeCall("GetSelectionCampaignId", GetSelectionCampaignId, 0, i) or 0
            local managerData = GetCampaignDataFromManager(id)
            local name = managerData and managerData.name or nil

            if CheckOneCampaignQueue(id, false, name) then
                return CHX.queue
            end

            if CheckOneCampaignQueue(id, true, name) then
                return CHX.queue
            end
        end
    end

    return nil
end

local function ApplyQueueWindowSettings()
    if not CreateUI() or not CHX.saved then return end

    local win = CHX.ui.queueWindow
    win:SetDimensions(QUEUE_WINDOW_WIDTH, QUEUE_WINDOW_HEIGHT)
    CHX.ui.queueBg:SetDimensions(QUEUE_WINDOW_WIDTH, QUEUE_WINDOW_HEIGHT)
    ResizeESOFrame(CHX.ui.queueFrame, QUEUE_WINDOW_WIDTH, QUEUE_WINDOW_HEIGHT)
    win:SetScale(tonumber(CHX.saved.queueWindowScale) or CHX.defaults.queueWindowScale)
    win:SetMovable(not CHX.saved.queueWindowLocked)
    win:SetMouseEnabled(not CHX.saved.queueWindowLocked)
    win:ClearAnchors()
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CHX.saved.queueWindowX or CHX.defaults.queueWindowX, CHX.saved.queueWindowY or CHX.defaults.queueWindowY)
end

local function UpdateQueueWindow()
    if not CreateUI() or not CHX.saved then return end

    ApplyQueueWindowSettings()

    if not IsGameplayHudShowing() then
        CHX.ui.queueWindow:SetHidden(true)
        return
    end

    if not CHX.saved.queueWindowEnabled or CHX.saved.queueWindowSuppressed then
        CHX.ui.queueWindow:SetHidden(true)
        CHX.debug.queueWindowSuppressed = tostring(CHX.saved.queueWindowSuppressed)
        return
    end

    CHX.debug.queueWindowSuppressed = tostring(CHX.saved.queueWindowSuppressed)
    local queue = ScanCampaignQueueStatus()

    if not queue or not queue.campaignId or IsInAvAWorldSafe() then
        CHX.ui.queueWindow:SetHidden(true)
        return
    end

    local campaignName = tostring(queue.name or GetCampaignNameSafe(queue.campaignId))
    local position = tonumber(queue.position) or 0
    local groupText = queue.isGroup and "Group queue" or "Solo queue"

    CHX.ui.queueTitle:SetText("Queued: " .. campaignName)

    if position > 0 then
        CHX.ui.queuePosition:SetText(groupText .. " in queue")
        CHX.ui.queueNumber:SetText("#" .. tostring(position))
        CHX.ui.queueNumber:SetHidden(false)
    else
        -- Do not show GetSecondsInCampaignQueue here. On Xbox this can briefly
        -- return a huge bogus value before the real queue position arrives.
        CHX.ui.queuePosition:SetText(groupText .. " waiting for position")
        CHX.ui.queueNumber:SetText("")
        CHX.ui.queueNumber:SetHidden(true)
    end

    CHX.ui.queueWindow:SetHidden(false)
end

local function ApplyKillWindowSettings()
    if not CreateUI() or not CHX.saved then return end

    local win = CHX.ui.killWindow
    local maxRows = tonumber(CHX.saved.maxKillRows) or CHX.defaults.maxKillRows
    local safeRows = math.max(1, maxRows)
    local height = safeRows * KILL_ROW_HEIGHT

    win:SetDimensions(KILL_WINDOW_WIDTH, height)
    CHX.ui.killBg:SetDimensions(KILL_WINDOW_WIDTH, height)
    ResizeESOFrame(CHX.ui.killFrame, KILL_WINDOW_WIDTH, height)
    win:SetScale(tonumber(CHX.saved.killWindowScale) or CHX.defaults.killWindowScale)
    win:SetMovable(not CHX.saved.killWindowLocked)
    win:SetMouseEnabled(not CHX.saved.killWindowLocked)
    win:ClearAnchors()
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CHX.saved.killWindowX or CHX.defaults.killWindowX, CHX.saved.killWindowY or CHX.defaults.killWindowY)
end

local function UpdateKillWindowRow(index, entry)
    local row = EnsureKillRow(index)

    if not row then return end

    row:SetHidden(false)
    row.icon:SetTexture(entry.icon or "/esoui/art/icons/ava_siege_weapon_001.dds")
    row.icon:SetColor(0.85, 0.85, 0.85, 0.90)
    row.name:SetText(tostring(entry.name or "PvP Battle"))
    row.name:SetColor(0.90, 0.90, 0.90, 1)
    row.kills:SetText(tostring(entry.killCountText or entry.attSiege or ""))
    row.kills:SetColor(0.80, 0.90, 1.00, 1)
    row.deaths:SetText(tostring(entry.deathCountText or entry.defSiege or ""))
    row.deaths:SetColor(1.00, 0.75, 0.75, 1)
    row.time:SetText(FormatTime(entry.elapsed or 0))
    row.time:SetColor(0.85, 0.85, 0.85, 1)
    row.bg:SetCenterColor(0, 0, 0, 0.30)
end

local function HideUnusedKillRows(fromIndex)
    if not CHX.ui or not CHX.ui.killRows then return end

    for i = fromIndex, #CHX.ui.killRows do
        CHX.ui.killRows[i]:SetHidden(true)
    end
end

local function UpdateKillWindow()
    if not CreateUI() or not CHX.saved then return end

    ApplyKillWindowSettings()

    local shouldShow = CHX.saved.showKillLocations and CHX.saved.killWindowVisible and ShouldAutoShowHere()
    CHX.ui.killWindow:SetHidden(not shouldShow)

    if not shouldShow then
        return
    end

    local visible = BuildKillLocationEntries()
    local maxRows = tonumber(CHX.saved.maxKillRows) or CHX.defaults.maxKillRows
    local count = math.min(#visible, maxRows)

    for i = 1, count do
        UpdateKillWindowRow(i, visible[i])
    end

    HideUnusedKillRows(count + 1)

    if #visible == 0 then
        CHX.ui.killWindow:SetHidden(true)
    end
end

local function ApplyWindowSettings(visibleRows)
    if not CreateUI() then return end

    local win = CHX.ui.window
    local rows = tonumber(visibleRows) or 0
    rows = math.max(0, rows)
    local height = SCORE_HEIGHT + (rows * ROW_HEIGHT)

    win:SetDimensions(WINDOW_WIDTH, height)
    CHX.ui.bg:SetDimensions(WINDOW_WIDTH, height)
    ResizeESOFrame(CHX.ui.mainFrame, WINDOW_WIDTH, height)

    if CHX.ui.pvpStatsRowBg then
        CHX.ui.pvpStatsRowBg:SetDimensions(WINDOW_WIDTH, STATS_ROW_HEIGHT)
    end

    if CHX.ui.pvpStatsText then
        CHX.ui.pvpStatsText:SetDimensions(190, STATS_ROW_HEIGHT)
    end

    if CHX.ui.pvpStatsPerfText then
        CHX.ui.pvpStatsPerfText:SetDimensions(108, STATS_ROW_HEIGHT)
    end

    win:SetScale(tonumber(CHX.saved.scale) or 1.0)
    win:SetMovable(not CHX.saved.locked)
    win:SetMouseEnabled(not CHX.saved.locked)
    win:ClearAnchors()
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CHX.saved.x or CHX.defaults.x, CHX.saved.y or CHX.defaults.y)
end

local function UpdateDisplay()
    if not CreateUI() or not CHX.saved then return end

    RefreshPvpStatsZoneState()
    UpdatePvpStatsRow()
    UpdateStatsPanelShellInfo()
    UpdateKillWindow()
    UpdateQueueWindow()

    local shouldShow = CHX.saved.windowVisible and ShouldAutoShowHere()

    if not shouldShow then
        CHX.ui.window:SetHidden(true)
        return
    end

    UpdateScoreLabel()

    local visible = BuildVisibleEntries()
    local maxRows = tonumber(CHX.saved.maxRows) or CHX.defaults.maxRows
    local count = math.min(#visible, maxRows)

    ApplyWindowSettings(count)
    CHX.ui.window:SetHidden(false)

    for i = 1, count do
        UpdateRow(i, visible[i])
    end

    HideUnusedRows(count + 1)
end

local function OnCampaignQueueJoined(eventCode, campaignId, isGroup)
    if campaignId ~= nil then
        SetQueueState(campaignId, isGroup == true, nil, nil, "joined")
    else
        ScanCampaignQueueStatus()
    end

    UpdateDisplay()
end

local function OnCampaignQueueLeft(eventCode, campaignId, isGroup)
    ClearQueueState("left")
    QueryCampaignSelectionDataSafe("queue left")
    UpdateDisplay()
end

local function OnCampaignQueuePositionChanged(eventCode, campaignId, isGroup, position)
    if campaignId ~= nil then
        SetQueueState(campaignId, isGroup == true, position, nil, "position")
    else
        ScanCampaignQueueStatus()
    end

    UpdateDisplay()
end

local function OnCampaignQueueStateChanged(eventCode, campaignId, isGroup, state)
    if campaignId ~= nil then
        SetQueueState(campaignId, isGroup == true, nil, state, "state")
    else
        ScanCampaignQueueStatus()
    end

    UpdateDisplay()
end

local function OnCampaignBonusChanged()
    QueryCampaignSelectionDataSafe("bonus changed")
    UpdateDisplay()
end

local function OnCampaignBrowserQueueStateUpdated(callbackManager, campaignData)
    CHX.debug.lastQueueCallbacks = "state"
    CHX.saved.queueWindowSuppressed = false
    TryQueueDataFromEntry(campaignData, "callback-state")
    UpdateDisplay()
end

local function OnCampaignBrowserDataUpdated()
    CHX.debug.lastQueueCallbacks = "data"
    ScanCampaignBrowserManagerQueue()
    UpdateDisplay()
end

local function ScanAndUpdate()
    UpdateDisplay()
end

local function RegisterEvents()
    if CHX.debug.eventsRegistered then return end

    if EVENT_MANAGER then
        CHX.debug.artifactEventExists = EVENT_ARTIFACT_CONTROL_STATE ~= nil
        CHX.debug.daedricEventExists = EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED ~= nil or EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED ~= nil
        CHX.debug.scrollStateEventExists = EVENT_ARTIFACT_SCROLL_STATE_CHANGED ~= nil
        CHX.debug.killFeedEventExists = EVENT_PVP_KILL_FEED_DEATH ~= nil
        CHX.debug.queueEventExists = EVENT_CAMPAIGN_QUEUE_JOINED ~= nil or EVENT_CAMPAIGN_QUEUE_LEFT ~= nil
        CHX.debug.queuePositionEventExists = EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED ~= nil

        EVENT_MANAGER:RegisterForUpdate(SCAN_NAME, 5000, ScanAndUpdate)
        EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 50, UpdateDisplay)

        if EVENT_KEEP_UNDER_ATTACK_CHANGED ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Attack", EVENT_KEEP_UNDER_ATTACK_CHANGED, function()
                ScanAndUpdate()
            end)
        end

        if EVENT_KEEP_GATE_STATE_CHANGED ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Gate", EVENT_KEEP_GATE_STATE_CHANGED, function()
                ScanAndUpdate()
            end)
        end

        if EVENT_KEEP_IS_PASSABLE_CHANGED ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Passable", EVENT_KEEP_IS_PASSABLE_CHANGED, function()
                ScanAndUpdate()
            end)
        end

        if EVENT_OBJECTIVE_CONTROL_STATE ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Objective", EVENT_OBJECTIVE_CONTROL_STATE, OnObjectiveControlState)
        end

        if EVENT_ARTIFACT_CONTROL_STATE ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Artifact", EVENT_ARTIFACT_CONTROL_STATE, OnArtifactControlState)
        end

        if EVENT_ARTIFACT_SCROLL_STATE_CHANGED ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_ScrollState", EVENT_ARTIFACT_SCROLL_STATE_CHANGED, OnArtifactScrollStateChanged)
        end

        if EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_DaedricState", EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED, OnDaedricArtifactObjectiveStateChanged)
        end

        if EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_DaedricSpawn", EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED, OnDaedricArtifactSpawned)
        end

        if EVENT_PVP_KILL_FEED_DEATH ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_KillFeed", EVENT_PVP_KILL_FEED_DEATH, OnPvpKillFeedDeath)
        end

        if EVENT_COMBAT_EVENT ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_PvpStatsCombat", EVENT_COMBAT_EVENT, OnPvpStatsCombatEvent)
        end

        if EVENT_PLAYER_COMBAT_STATE ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_PvpStatsCombatState", EVENT_PLAYER_COMBAT_STATE, OnPvpStatsCombatState)
        end

        if EVENT_RETICLE_TARGET_CHANGED ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_PvpStatsReticle", EVENT_RETICLE_TARGET_CHANGED, OnPvpStatsReticleTargetChanged)
        end

        if EVENT_AVENGE_KILL ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_PvpStatsAvenge", EVENT_AVENGE_KILL, OnPvpStatsAvengeKill)
        end

        if EVENT_REVENGE_KILL ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_PvpStatsRevenge", EVENT_REVENGE_KILL, OnPvpStatsRevengeKill)
        end

        if EVENT_PLAYER_DEAD ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_PvpStatsDead", EVENT_PLAYER_DEAD, OnPvpStatsPlayerDead)
        end

        if EVENT_ALLIANCE_POINT_UPDATE ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_PvpStatsAP", EVENT_ALLIANCE_POINT_UPDATE, OnPvpStatsAlliancePointUpdate)
        end

        if EVENT_CAMPAIGN_QUEUE_JOINED ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_QueueJoined", EVENT_CAMPAIGN_QUEUE_JOINED, OnCampaignQueueJoined)
        end

        if EVENT_CAMPAIGN_QUEUE_LEFT ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_QueueLeft", EVENT_CAMPAIGN_QUEUE_LEFT, OnCampaignQueueLeft)
        end

        if EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_QueuePosition", EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED, OnCampaignQueuePositionChanged)
        end

        if EVENT_CAMPAIGN_QUEUE_STATE_CHANGED ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_QueueState", EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, OnCampaignQueueStateChanged)
        end

        if EVENT_CAMPAIGN_UNDERPOP_BONUS_CHANGE_NOTIFICATION ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_UnderpopBonus", EVENT_CAMPAIGN_UNDERPOP_BONUS_CHANGE_NOTIFICATION, OnCampaignBonusChanged)
        end

        if EVENT_CAMPAIGN_SCORE_DATA_CHANGED ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_ScoreChanged", EVENT_CAMPAIGN_SCORE_DATA_CHANGED, OnCampaignBonusChanged)
        end

        if EVENT_CAMPAIGN_SELECTION_DATA_CHANGED ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_SelectionChanged", EVENT_CAMPAIGN_SELECTION_DATA_CHANGED, OnCampaignBonusChanged)
        end

        if EVENT_PLAYER_ACTIVATED ~= nil then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
                EnsurePvpStatsState()
                RefreshPvpStatsZoneState()
                UpdatePvpStatsRow()
                ScanAndUpdate()
            end)
        end
    end

    if CAMPAIGN_BROWSER_MANAGER and type(CAMPAIGN_BROWSER_MANAGER.RegisterCallback) == "function" then
        SafeCall("CampaignBrowserManager RegisterCallback data", function()
            CAMPAIGN_BROWSER_MANAGER:RegisterCallback("OnCampaignDataUpdated", OnCampaignBrowserDataUpdated)
        end, nil)

        SafeCall("CampaignBrowserManager RegisterCallback queue", function()
            CAMPAIGN_BROWSER_MANAGER:RegisterCallback("OnCampaignQueueStateUpdated", OnCampaignBrowserQueueStateUpdated)
        end, nil)
    end

    CHX.debug.eventsRegistered = true
end

local function UnregisterEvents()
    if not EVENT_MANAGER then return end

    EVENT_MANAGER:UnregisterForUpdate(SCAN_NAME)
    EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAME)

    if EVENT_KEEP_UNDER_ATTACK_CHANGED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_Attack", EVENT_KEEP_UNDER_ATTACK_CHANGED)
    end

    if EVENT_KEEP_GATE_STATE_CHANGED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_Gate", EVENT_KEEP_GATE_STATE_CHANGED)
    end

    if EVENT_KEEP_IS_PASSABLE_CHANGED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_Passable", EVENT_KEEP_IS_PASSABLE_CHANGED)
    end

    if EVENT_OBJECTIVE_CONTROL_STATE ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_Objective", EVENT_OBJECTIVE_CONTROL_STATE)
    end

    if EVENT_ARTIFACT_CONTROL_STATE ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_Artifact", EVENT_ARTIFACT_CONTROL_STATE)
    end

    if EVENT_ARTIFACT_SCROLL_STATE_CHANGED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_ScrollState", EVENT_ARTIFACT_SCROLL_STATE_CHANGED)
    end

    if EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_DaedricState", EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED)
    end

    if EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_DaedricSpawn", EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED)
    end

    if EVENT_PVP_KILL_FEED_DEATH ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_KillFeed", EVENT_PVP_KILL_FEED_DEATH)
    end

    if EVENT_COMBAT_EVENT ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_PvpStatsCombat", EVENT_COMBAT_EVENT)
    end

    if EVENT_PLAYER_COMBAT_STATE ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_PvpStatsCombatState", EVENT_PLAYER_COMBAT_STATE)
    end

    if EVENT_RETICLE_TARGET_CHANGED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_PvpStatsReticle", EVENT_RETICLE_TARGET_CHANGED)
    end

    if EVENT_AVENGE_KILL ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_PvpStatsAvenge", EVENT_AVENGE_KILL)
    end

    if EVENT_REVENGE_KILL ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_PvpStatsRevenge", EVENT_REVENGE_KILL)
    end

    if EVENT_PLAYER_DEAD ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_PvpStatsDead", EVENT_PLAYER_DEAD)
    end

    if EVENT_ALLIANCE_POINT_UPDATE ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_PvpStatsAP", EVENT_ALLIANCE_POINT_UPDATE)
    end

    if EVENT_CAMPAIGN_QUEUE_JOINED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_QueueJoined", EVENT_CAMPAIGN_QUEUE_JOINED)
    end

    if EVENT_CAMPAIGN_QUEUE_LEFT ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_QueueLeft", EVENT_CAMPAIGN_QUEUE_LEFT)
    end

    if EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_QueuePosition", EVENT_CAMPAIGN_QUEUE_POSITION_CHANGED)
    end

    if EVENT_CAMPAIGN_QUEUE_STATE_CHANGED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_QueueState", EVENT_CAMPAIGN_QUEUE_STATE_CHANGED)
    end

    if EVENT_CAMPAIGN_UNDERPOP_BONUS_CHANGE_NOTIFICATION ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_UnderpopBonus", EVENT_CAMPAIGN_UNDERPOP_BONUS_CHANGE_NOTIFICATION)
    end

    if EVENT_CAMPAIGN_SCORE_DATA_CHANGED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_ScoreChanged", EVENT_CAMPAIGN_SCORE_DATA_CHANGED)
    end

    if EVENT_CAMPAIGN_SELECTION_DATA_CHANGED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_SelectionChanged", EVENT_CAMPAIGN_SELECTION_DATA_CHANGED)
    end

    if EVENT_PLAYER_ACTIVATED ~= nil then
        EVENT_MANAGER:UnregisterForEvent(ADDON_NAME .. "_Activated", EVENT_PLAYER_ACTIVATED)
    end

    if CAMPAIGN_BROWSER_MANAGER and type(CAMPAIGN_BROWSER_MANAGER.UnregisterCallback) == "function" then
        SafeCall("CampaignBrowserManager UnregisterCallback data", function()
            CAMPAIGN_BROWSER_MANAGER:UnregisterCallback("OnCampaignDataUpdated", OnCampaignBrowserDataUpdated)
        end, nil)

        SafeCall("CampaignBrowserManager UnregisterCallback queue", function()
            CAMPAIGN_BROWSER_MANAGER:UnregisterCallback("OnCampaignQueueStateUpdated", OnCampaignBrowserQueueStateUpdated)
        end, nil)
    end

    CHX.debug.eventsRegistered = false
end

local function SetWindowVisible(value)
    CHX.saved.windowVisible = value == true
    UpdateDisplay()
end

local function ToggleWindow()
    CHX.saved.windowVisible = not CHX.saved.windowVisible
    UpdateDisplay()
    Print(CHX.saved.windowVisible and "window shown" or "window hidden")
end

local function ToggleKillWindow()
    CHX.saved.killWindowVisible = not CHX.saved.killWindowVisible
    UpdateDisplay()
    Print(CHX.saved.killWindowVisible and "kill window shown" or "kill window hidden")
end

local function ToggleQueueTest()
    CHX.queueTest = not CHX.queueTest

    if CHX.queueTest then
        CHX.saved.queueWindowEnabled = true
        CHX.saved.queueWindowSuppressed = false
    else
        CHX.saved.queueWindowSuppressed = true
        ClearQueueState("test hidden")
    end

    UpdateDisplay()
    Print(CHX.queueTest and "queue test shown" or "queue test hidden")
end

local function ToggleBonusTest()
    CHX.bonusTest = not CHX.bonusTest
    UpdateDisplay()
    Print(CHX.bonusTest and "score bonus test shown" or "score bonus test hidden")
end

local function ClearQueueWindow()
    CHX.queueTest = false
    CHX.saved.queueWindowSuppressed = true
    ClearQueueState("manual clear")
    UpdateDisplay()
end

local function ForceQueueTestOff()
    CHX.queueTest = false
    CHX.saved.queueWindowSuppressed = true
    ClearQueueState("test force off")
    UpdateDisplay()
end

local function EnableQueueWindow()
    CHX.saved.queueWindowEnabled = true
    CHX.saved.queueWindowSuppressed = false
    UpdateDisplay()
end

local function ApplyRankProgressSettings()
    if PVPBuddyRankProgress and type(PVPBuddyRankProgress.SetDisplayMode) == "function" then
        PVPBuddyRankProgress:SetDisplayMode(CHX.saved.rankProgressMode or CHX.defaults.rankProgressMode)
    end

    if PVPBuddyRankProgress and type(PVPBuddyRankProgress.ZoneCheck) == "function" then
        PVPBuddyRankProgress:ZoneCheck()
    end
end

local function ResetKillWindowPosition()
    CHX.saved.killWindowX = CHX.defaults.killWindowX
    CHX.saved.killWindowY = CHX.defaults.killWindowY
    UpdateDisplay()
end

local function ResetQueueWindowPosition()
    CHX.saved.queueWindowX = CHX.defaults.queueWindowX
    CHX.saved.queueWindowY = CHX.defaults.queueWindowY
    UpdateDisplay()
end


local function ResetPosition()
    CHX.saved.x = CHX.defaults.x
    CHX.saved.y = CHX.defaults.y
    CHX.saved.scale = CHX.defaults.scale
    UpdateDisplay()
end

local function ShowDebug()
    Print("debug")
    d("Version: " .. tostring(CHX.version))
    d("Enabled: " .. tostring(CHX.saved and CHX.saved.enabled))
    d("Window visible saved: " .. tostring(CHX.saved and CHX.saved.windowVisible))
    d("In AvA: " .. tostring(IsInAvAWorldSafe()))
    d("In Imperial City: " .. tostring(IsInImperialCitySafe()))
    d("Campaign: " .. tostring(CHX.debug.lastCampaign))
    d("Score timer: " .. tostring(CHX.debug.lastScoreTime))
    d("Potential DC/EP/AD: " .. tostring(CHX.debug.lastScoreDC) .. "/" .. tostring(CHX.debug.lastScoreEP) .. "/" .. tostring(CHX.debug.lastScoreAD))
    d("Low pop D/E/A: " .. tostring(CHX.debug.lastLowPopBonus))
    d("Low score leader/mode: " .. tostring(CHX.debug.lastLowScoreLeader) .. "/" .. tostring(CHX.debug.lastScoreBonusMode))
    d("Owned scrolls DC/EP/AD: " .. tostring(CHX.debug.lastScrollCountDC) .. "/" .. tostring(CHX.debug.lastScrollCountEP) .. "/" .. tostring(CHX.debug.lastScrollCountAD))
    d("Scroll objectives scanned: " .. tostring(CHX.debug.lastScrollCountScanned))
    d("Known scroll temples scanned: " .. tostring(CHX.debug.lastScrollKnownTempleCount))
    d("Scroll counted captured/base/held: " .. tostring(CHX.debug.lastScrollCapturedCount) .. "/" .. tostring(CHX.debug.lastScrollBaseCount) .. "/" .. tostring(CHX.debug.lastScrollHeldCount))
    d("Scroll count mode: " .. tostring(CHX.debug.lastScrollCountMode))
    d("New battle rows: " .. tostring(CHX.debug.lastNewBattleCount))
    d("Finished battle rows: " .. tostring(CHX.debug.lastFinishedBattleCount))
    d("Resource icons: " .. tostring(CHX.debug.lastResourceIconCount))
    d("Scroll icons: " .. tostring(CHX.debug.lastScrollIconCount))
    d("Flag arrows: " .. tostring(CHX.debug.lastFlagArrowCount))
    d("Last flag event: " .. tostring(CHX.debug.lastFlagEvent))
    d("Last flag state: " .. tostring(CHX.debug.lastFlagState))
    d("Last flag control event: " .. tostring(CHX.debug.lastFlagControlEvent))
    d("Last flag holding/attacking: " .. tostring(CHX.debug.lastFlagHoldingAlliance) .. "/" .. tostring(CHX.debug.lastFlagAttackingAlliance))
    d("Last flag name alliance: " .. tostring(CHX.debug.lastFlagNameAlliance))
    d("Moving objective rows: " .. tostring(CHX.debug.lastMovingObjectiveCount))
    d("Known scroll moving scan: " .. tostring(CHX.debug.lastMovingObjectiveScan))
    d("Last moving objective event: " .. tostring(CHX.debug.lastMovingObjectiveEvent))
    d("Last moving objective payload: " .. tostring(CHX.debug.lastMovingObjectivePayload))
    d("Artifact event exists: " .. tostring(CHX.debug.artifactEventExists))
    d("Daedric event exists: " .. tostring(CHX.debug.daedricEventExists))
    d("Scroll state event exists: " .. tostring(CHX.debug.scrollStateEventExists))
    d("Kill feed event exists: " .. tostring(CHX.debug.killFeedEventExists))
    d("Queue events exist: " .. tostring(CHX.debug.queueEventExists) .. " position=" .. tostring(CHX.debug.queuePositionEventExists))
    d("Queue event/campaign/name: " .. tostring(CHX.debug.lastQueueEvent) .. "/" .. tostring(CHX.debug.lastQueueCampaign) .. "/" .. tostring(CHX.debug.lastQueueCampaignName))
    d("Queue pos/state/group: " .. tostring(CHX.debug.lastQueuePosition) .. "/" .. tostring(CHX.debug.lastQueueState) .. "/" .. tostring(CHX.debug.lastQueueIsGroup))
    d("Queue scan/mode: " .. tostring(CHX.debug.lastQueueScan) .. "/" .. tostring(CHX.debug.lastQueueApiMode))
    d("Queue browser rows/callbacks/hold: " .. tostring(CHX.debug.lastQueueBrowserRows) .. "/" .. tostring(CHX.debug.lastQueueCallbacks) .. "/" .. tostring(CHX.debug.lastQueueHold))
    d("Queue window suppressed: " .. tostring(CHX.saved and CHX.saved.queueWindowSuppressed))
    d("Queue window X/Y: " .. tostring(CHX.saved and CHX.saved.queueWindowX) .. "/" .. tostring(CHX.saved and CHX.saved.queueWindowY))
    d("Kill window visible: " .. tostring(CHX.saved and CHX.saved.killWindowVisible))
    d("Kill window X/Y: " .. tostring(CHX.saved and CHX.saved.killWindowX) .. "/" .. tostring(CHX.saved and CHX.saved.killWindowY))
    d("Kill location rows: " .. tostring(CHX.debug.lastKillLocationCount))
    d("Last kill feed event: " .. tostring(CHX.debug.lastKillFeedEvent))
    d("Last kill feed payload: " .. tostring(CHX.debug.lastKillFeedPayload))
    d("Kill feed call count: " .. tostring(CHX.debug.lastKillFeedCallCount))
    d("Last kill feed args: " .. tostring(CHX.debug.lastKillFeedArgs))
    d("Last kill feed raw: " .. tostring(CHX.debug.lastKillFeedRaw))
    d("Kill feed parse: Xbox order location/display/character/alliance/rank")
    d("Resource API exists: " .. tostring(type(GetResourceKeepForKeep) == "function"))
    d("Scroll API exists: " .. tostring(type(GetNumObjectives) == "function" and type(GetKeepThatHasCapturedThisArtifactScrollObjective) == "function"))
    d("Scan count: " .. tostring(CHX.debug.lastScanCount))
    d("Visible rows: " .. tostring(CHX.debug.lastVisibleCount))
    d("Events registered: " .. tostring(CHX.debug.eventsRegistered))
    d("Last error: " .. tostring(CHX.debug.lastError or ""))
    d("Window X/Y: " .. tostring(CHX.saved and CHX.saved.x) .. ", " .. tostring(CHX.saved and CHX.saved.y))
end

local function RegisterSettingsMenu()
    local LAM = LibAddonMenu2

    if not LAM then
        Print("LibAddonMenu-2.0 not found. Use /pb commands instead.")
        return
    end

    local panelData = {
        type = "panel",
        name = "PvP Buddy",
        displayName = "PvP Buddy",
        author = CHX.author,
        version = CHX.version,
        slashCommand = "/pb",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel(ADDON_NAME .. "_Options", panelData)

    local function Header(name)
        return { type = "header", name = name }
    end

    local function Description(text)
        return { type = "description", text = text }
    end

    local function Checkbox(name, key, default, tooltip, onSet)
        return {
            type = "checkbox",
            name = name,
            tooltip = tooltip,
            getFunc = function()
                return CHX.saved[key]
            end,
            setFunc = function(value)
                CHX.saved[key] = value
                if onSet then
                    onSet(value)
                else
                    UpdateDisplay()
                end
            end,
            default = default,
        }
    end

    local function Slider(name, key, default, min, max, step, tooltip, onSet)
        return {
            type = "slider",
            name = name,
            tooltip = tooltip,
            min = min,
            max = max,
            step = step,
            getFunc = function()
                local value = CHX.saved[key]
                if value == nil then value = default end
                return value
            end,
            setFunc = function(value)
                CHX.saved[key] = value
                if onSet then
                    onSet(value)
                else
                    UpdateDisplay()
                end
            end,
            default = default,
        }
    end

    local function ScaleSlider(name, key, default, tooltip, onSet)
        return {
            type = "slider",
            name = name,
            tooltip = tooltip,
            min = 50,
            max = 150,
            step = 5,
            getFunc = function()
                return math.floor((tonumber(CHX.saved[key]) or default or 1.0) * 100)
            end,
            setFunc = function(value)
                CHX.saved[key] = (tonumber(value) or 100) / 100
                if onSet then
                    onSet(value)
                else
                    UpdateDisplay()
                end
            end,
            default = math.floor((default or 1.0) * 100),
        }
    end

    local function Button(name, tooltip, func)
        return {
            type = "button",
            name = name,
            tooltip = tooltip,
            func = func,
        }
    end

    local optionsData = {
        {
            type = "submenu",
            name = "UI",
            controls = {
                Description("Window visibility, lock state, placement, scale, and row counts."),

                Header("Main PvP Buddy Window"),
                Checkbox("Show Window", "windowVisible", CHX.defaults.windowVisible, "Shows the main PvP Buddy objective/score window.", UpdateDisplay),
                Checkbox("Lock Window", "locked", CHX.defaults.locked, "Locks the main PvP Buddy window so it cannot be dragged.", function() ApplyWindowSettings() end),
                Slider("X Location", "x", CHX.defaults.x, 0, 2600, 1, "Moves the main PvP Buddy window left or right.", function() ApplyWindowSettings() end),
                Slider("Y Location", "y", CHX.defaults.y, 0, 1600, 1, "Moves the main PvP Buddy window up or down.", function() ApplyWindowSettings() end),
                ScaleSlider("Scale", "scale", CHX.defaults.scale, "Scales the main PvP Buddy window.", function() ApplyWindowSettings() end),
                Slider("Max Rows", "maxRows", CHX.defaults.maxRows, 1, 20, 1, "Maximum objective rows shown in the main PvP Buddy window.", UpdateDisplay),
                Button("Reset Position", "Moves the main PvP Buddy window back to its default position.", ResetPosition),

                Header("Kill Window"),
                Checkbox("Show Window", "killWindowVisible", CHX.defaults.killWindowVisible, "Shows the separate kill-location window.", UpdateDisplay),
                Checkbox("Lock Window", "killWindowLocked", CHX.defaults.killWindowLocked, "Locks the kill window so it cannot be dragged.", UpdateDisplay),
                Slider("X Location", "killWindowX", CHX.defaults.killWindowX, 0, 2600, 1, "Moves the kill window left or right.", UpdateDisplay),
                Slider("Y Location", "killWindowY", CHX.defaults.killWindowY, 0, 1600, 1, "Moves the kill window up or down.", UpdateDisplay),
                ScaleSlider("Scale", "killWindowScale", CHX.defaults.killWindowScale, "Scales the kill window.", UpdateDisplay),
                Slider("Max Rows", "maxKillRows", CHX.defaults.maxKillRows, 1, 8, 1, "Maximum rows shown in the kill window.", UpdateDisplay),
                Button("Reset Position", "Moves the kill window back to its default position.", ResetKillWindowPosition),

                Header("Campaign Queue Window"),
                Checkbox("Show Window", "queueWindowEnabled", CHX.defaults.queueWindowEnabled, "Automatically shows the campaign queue window while queued.", function(value)
                    if value then
                        CHX.saved.queueWindowSuppressed = false
                    else
                        CHX.queueTest = false
                        CHX.saved.queueWindowSuppressed = true
                        ClearQueueState("disabled")
                    end

                    UpdateDisplay()
                end),
                Checkbox("Lock Window", "queueWindowLocked", CHX.defaults.queueWindowLocked, "Locks the queue window so it cannot be dragged.", UpdateDisplay),
                Slider("X Location", "queueWindowX", CHX.defaults.queueWindowX, 0, 2600, 1, "Moves the queue window left or right.", UpdateDisplay),
                Slider("Y Location", "queueWindowY", CHX.defaults.queueWindowY, 0, 1600, 1, "Moves the queue window up or down.", UpdateDisplay),
                ScaleSlider("Scale", "queueWindowScale", CHX.defaults.queueWindowScale, "Scales the queue window.", UpdateDisplay),
                Button("Reset Position", "Moves the campaign queue window back to its default position.", ResetQueueWindowPosition),
                Button("Toggle Queue Test Window", "Shows or hides a fake queue window so you can place it.", ToggleQueueTest),
                Button("Clear Queue Window", "Force hides/suppresses stale queue data until the next fresh queue event.", ForceQueueTestOff),
                Button("Enable Queue Window Again", "Re-enables automatic queue-window detection after clearing it.", EnableQueueWindow),
            },
        },

        {
            type = "submenu",
            name = "Overlay Settings",
            controls = {
                Description("Controls what the PvP Buddy overlay tracks and displays in Cyrodiil / Imperial City."),

                Header("Zone / Overlay"),
                Checkbox("Enable In Cyrodiil", "enableInCyrodiil", CHX.defaults.enableInCyrodiil, nil, UpdateDisplay),
                Checkbox("Enable In Imperial City", "enableInImperialCity", CHX.defaults.enableInImperialCity, nil, UpdateDisplay),
                Checkbox("Show Scoring Bar", "showScoring", CHX.defaults.showScoring, nil, UpdateDisplay),
                Checkbox("Show Low Pop / Low Score Bonuses", "showScoreBonusIcons", CHX.defaults.showScoreBonusIcons, "Shows underpop and low-score bonus icons in the score header.", UpdateDisplay),
                Button("Toggle Score Bonus Test Icons", "Shows fake low-pop and low-score icons so you can confirm placement.", ToggleBonusTest),
                Checkbox("Show Owned Scroll Counts", "showScrollCounts", CHX.defaults.showScrollCounts, "Shows the number of Elder Scrolls owned above each alliance emblem.", UpdateDisplay),
                Checkbox("Show Siege Counts", "showSiege", CHX.defaults.showSiege, "Shows attacking/defending siege as A/D where available.", UpdateDisplay),
                Checkbox("Show Keep Resources", "showKeepResources", CHX.defaults.showKeepResources, "Shows lumbermill, mine, and farm ownership icons around keep icons.", UpdateDisplay),
                Checkbox("Show Scroll Icons", "showScrollIcons", CHX.defaults.showScrollIcons, "Shows an Elder Scroll overlay on detected scroll objectives.", UpdateDisplay),
                Checkbox("Show Flag Flip Arrows", "showFlagArrows", CHX.defaults.showFlagArrows, "Shows a colored arrow next to the objective name when a capture flag event is detected.", UpdateDisplay),
                Checkbox("Show Flag Name Coloring", "showFlagNameColoring", CHX.defaults.showFlagNameColoring, "Colors the objective name by the alliance flipping/holding the flag state.", UpdateDisplay),
                Slider("Flag Event Hold Seconds", "flagStateLifetimeSeconds", CHX.defaults.flagStateLifetimeSeconds, 5, 180, 5, "How long a flag flip arrow stays visible after the last flag event.", UpdateDisplay),
                Checkbox("Show Moving Objectives", "showMovingObjectives", CHX.defaults.showMovingObjectives, "Shows rows for carried, dropped, or spawned Elder Scrolls and Volendrung.", UpdateDisplay),
                Checkbox("Scan Known Scroll Movement", "scanKnownScrollMovement", CHX.defaults.scanKnownScrollMovement, "Scans the six known scroll temple objectives for held/dropped scroll state.", UpdateDisplay),
                Slider("Moving Objective Hold Seconds", "movingObjectiveHoldSeconds", CHX.defaults.movingObjectiveHoldSeconds, 30, 900, 30, "How long an event-driven moving objective row remains visible after its last update.", UpdateDisplay),
                Checkbox("Show Kill Locations", "showKillLocations", CHX.defaults.showKillLocations, "Tracks and displays event-driven PvP kill locations in the kill window.", UpdateDisplay),
                Slider("Kill Location Hold Seconds", "killLocationHoldSeconds", CHX.defaults.killLocationHoldSeconds, 30, 600, 30, "How long a kill-location row remains visible after the latest kill there.", UpdateDisplay),
                Checkbox("Show Gates / Bridges / Milegates", "showGatesAndBridges", CHX.defaults.showGatesAndBridges, nil, UpdateDisplay),
                Checkbox("Show Test Rows", "showTestRows", CHX.defaults.showTestRows, "Shows fake rows outside Cyrodiil so you can place and test the window.", UpdateDisplay),

                Header("Alliance Rank / Veterancy Rank"),
                Checkbox("Show Window", "rankProgressVisible", CHX.defaults.rankProgressVisible, "Shows the Alliance Rank / Veterancy Rank progress HUD in Cyrodiil.", ApplyRankProgressSettings),
                Checkbox("Lock Window", "rankProgressLocked", CHX.defaults.rankProgressLocked, "Locks the Alliance Rank / Veterancy Rank progress HUD.", ApplyRankProgressSettings),
                {
                    type = "dropdown",
                    name = "Progress Display",
                    tooltip = "Choose whether this HUD tracks Alliance Rank or PvP Veterancy Rank.",
                    choices = { "Alliance Rank", "Veterancy Rank" },
                    choicesValues = { "alliance", "veterancy" },
                    getFunc = function()
                        return CHX.saved.rankProgressMode or CHX.defaults.rankProgressMode
                    end,
                    setFunc = function(value)
                        if value ~= "veterancy" then value = "alliance" end
                        CHX.saved.rankProgressMode = value
                        ApplyRankProgressSettings()
                    end,
                    default = CHX.defaults.rankProgressMode,
                },
            },
        },

        {
            type = "submenu",
            name = "Debug",
            controls = {
                Button("Debug Info", nil, ShowDebug),
                Button("Force Refresh", nil, function()
                    ScanAndUpdate()
                    Print("refreshed")
                end),
            },
        },
    }

    LAM:RegisterOptionControls(ADDON_NAME .. "_Options", optionsData)
end

local function SlashCommand(text)
    text = string.lower(tostring(text or ""))

    if text == "" or text == "toggle" then
        ToggleWindow()
    elseif text == "show" then
        SetWindowVisible(true)
        Print("window shown")
    elseif text == "hide" then
        SetWindowVisible(false)
        Print("window hidden")
    elseif text == "refresh" then
        ScanAndUpdate()
        Print("refreshed")
    elseif text == "kills" or text == "kill" then
        ToggleKillWindow()
    elseif text == "kills show" or text == "kill show" then
        CHX.saved.killWindowVisible = true
        UpdateDisplay()
        Print("kill window shown")
    elseif text == "kills hide" or text == "kill hide" then
        CHX.saved.killWindowVisible = false
        UpdateDisplay()
        Print("kill window hidden")
    elseif text == "kills reset" or text == "kill reset" then
        ResetKillWindowPosition()
        Print("kill window position reset")
    elseif text == "queue test" then
        ToggleQueueTest()
    elseif text == "queue test off" then
        ForceQueueTestOff()
        Print("queue test hidden")
    elseif text == "queue show" then
        CHX.queueTest = true
        CHX.saved.queueWindowEnabled = true
        CHX.saved.queueWindowSuppressed = false
        UpdateDisplay()
        Print("queue test shown")
    elseif text == "queue on" then
        EnableQueueWindow()
        Print("queue window enabled")
    elseif text == "queue hide" or text == "queue clear" or text == "queue off" then
        ForceQueueTestOff()
        Print("queue window cleared")
    elseif text == "bonus test" then
        ToggleBonusTest()
    elseif text == "queue reset" then
        ResetQueueWindowPosition()
        Print("queue window position reset")
    elseif string.sub(text, 1, 12) == "tracker page" or string.sub(text, 1, 7) == "ct page" or string.sub(text, 1, 12) == "combat page" then
        local page = tonumber(string.match(text, "(%d+)"))
        if page then
            SetStatsPanelWindowVisible(true)
            TrackerSetCurrentPage(page)
            Print("PvP Buddy stats panel page " .. tostring(page))
        else
            Print("usage: /pb tracker page 1-4")
        end
    elseif text == "tracker next" or text == "ct next" or text == "combat next" then
        SetStatsPanelWindowVisible(true)
        TrackerCyclePage(1)
        Print("PvP Buddy stats panel next page")
    elseif text == "tracker prev" or text == "ct prev" or text == "combat prev" then
        SetStatsPanelWindowVisible(true)
        TrackerCyclePage(-1)
        Print("PvP Buddy stats panel previous page")
    elseif text == "tracker" or text == "stats" then
        ToggleStatsPanelWindow()
        Print("PvP Buddy stats panel window " .. tostring(CHX.saved and CHX.saved.statsPanelWindowVisible))
    elseif text == "tracker show" or text == "combat show" or text == "ct show" then
        SetStatsPanelWindowVisible(true)
        Print("PvP Buddy stats panel window shown")
    elseif text == "tracker hide" or text == "combat hide" or text == "ct hide" then
        SetStatsPanelWindowVisible(false)
        Print("PvP Buddy stats panel window hidden")
    elseif text == "lifetime debug" or text == "tracker debug" or text == "stats debug" then
        ShowLifetimeDebug()
    elseif text == "debug" then
        ShowDebug()
    elseif text == "test" then
        CHX.saved.showTestRows = not CHX.saved.showTestRows
        UpdateDisplay()
        Print("test rows " .. tostring(CHX.saved.showTestRows))
    else
        Print("commands: /pb show, /pb hide, /pb kills, /pb tracker, /pb tracker page 1-4, /pb tracker next, /pb tracker prev, /pb lifetime debug, /pb queue on, /pb queue off, /pb queue test, /pb queue test off, /pb queue clear, /pb bonus test, /pb queue reset, /pb refresh, /pb debug, /pb test")
    end
end

local function Initialize()
    CHX.saved = ZO_SavedVars:NewAccountWide(
        "PVPBuddySaved",
        1,
        nil,
        CHX.defaults
    )

    if CHX.saved.x == nil or tonumber(CHX.saved.x) == nil or tonumber(CHX.saved.x) < 0 then
        CHX.saved.x = CHX.defaults.x
    end

    if CHX.saved.y == nil or tonumber(CHX.saved.y) == nil then
        CHX.saved.y = CHX.defaults.y
    end

    if CHX.saved.maxRows == nil then
        CHX.saved.maxRows = CHX.defaults.maxRows
    end

    SLASH_COMMANDS["/cyrohudx"] = SlashCommand
    if CHX.saved.showKeepResources == nil then
        CHX.saved.showKeepResources = CHX.defaults.showKeepResources
    end

    if CHX.saved.showScrollCounts == nil then
        CHX.saved.showScrollCounts = CHX.defaults.showScrollCounts
    end

    if CHX.saved.showScoreBonusIcons == nil then
        CHX.saved.showScoreBonusIcons = CHX.defaults.showScoreBonusIcons
    end

    if CHX.saved.showScrollIcons == nil then
        CHX.saved.showScrollIcons = CHX.defaults.showScrollIcons
    end

    if CHX.saved.showFlagArrows == nil then
        CHX.saved.showFlagArrows = CHX.defaults.showFlagArrows
    end

    if CHX.saved.showFlagNameColoring == nil then
        CHX.saved.showFlagNameColoring = CHX.defaults.showFlagNameColoring
    end

    if CHX.saved.flagStateLifetimeSeconds == nil then
        CHX.saved.flagStateLifetimeSeconds = CHX.defaults.flagStateLifetimeSeconds
    end

    if CHX.saved.showMovingObjectives == nil then
        CHX.saved.showMovingObjectives = CHX.defaults.showMovingObjectives
    end

    if CHX.saved.scanKnownScrollMovement == nil then
        CHX.saved.scanKnownScrollMovement = CHX.defaults.scanKnownScrollMovement
    end

    if CHX.saved.movingObjectiveHoldSeconds == nil then
        CHX.saved.movingObjectiveHoldSeconds = CHX.defaults.movingObjectiveHoldSeconds
    end

    if CHX.saved.showKillLocations == nil then
        CHX.saved.showKillLocations = CHX.defaults.showKillLocations
    end

    if CHX.saved.killWindowVisible == nil then
        CHX.saved.killWindowVisible = CHX.defaults.killWindowVisible
    end

    if CHX.saved.killWindowLocked == nil then
        CHX.saved.killWindowLocked = CHX.defaults.killWindowLocked
    end

    if CHX.saved.killWindowScale == nil or tonumber(CHX.saved.killWindowScale) == nil then
        CHX.saved.killWindowScale = CHX.defaults.killWindowScale
    end

    if CHX.saved.killWindowX == nil or tonumber(CHX.saved.killWindowX) == nil then
        CHX.saved.killWindowX = CHX.defaults.killWindowX
    end

    if CHX.saved.killWindowY == nil or tonumber(CHX.saved.killWindowY) == nil then
        CHX.saved.killWindowY = CHX.defaults.killWindowY
    end

    if CHX.saved.maxKillRows == nil then
        CHX.saved.maxKillRows = CHX.defaults.maxKillRows
    end

    if CHX.saved.queueWindowEnabled == nil then
        CHX.saved.queueWindowEnabled = CHX.defaults.queueWindowEnabled
    end

    if CHX.saved.queueWindowSuppressed == nil then
        CHX.saved.queueWindowSuppressed = CHX.defaults.queueWindowSuppressed
    end

    if CHX.saved.queueWindowLocked == nil then
        CHX.saved.queueWindowLocked = CHX.defaults.queueWindowLocked
    end

    if CHX.saved.queueWindowScale == nil or tonumber(CHX.saved.queueWindowScale) == nil then
        CHX.saved.queueWindowScale = CHX.defaults.queueWindowScale
    end

    if CHX.saved.queueWindowX == nil or tonumber(CHX.saved.queueWindowX) == nil then
        CHX.saved.queueWindowX = CHX.defaults.queueWindowX
    end

    if CHX.saved.queueWindowY == nil or tonumber(CHX.saved.queueWindowY) == nil then
        CHX.saved.queueWindowY = CHX.defaults.queueWindowY
    end

    if CHX.saved.rankProgressMode ~= "alliance" and CHX.saved.rankProgressMode ~= "veterancy" then
        CHX.saved.rankProgressMode = CHX.defaults.rankProgressMode
    end

    if CHX.saved.rankProgressVisible == nil then
        CHX.saved.rankProgressVisible = CHX.defaults.rankProgressVisible
    end

    if CHX.saved.rankProgressLocked == nil then
        CHX.saved.rankProgressLocked = CHX.defaults.rankProgressLocked
    end

    if CHX.saved.rankProgressX == nil or tonumber(CHX.saved.rankProgressX) == nil then
        CHX.saved.rankProgressX = CHX.defaults.rankProgressX
    end

    if CHX.saved.rankProgressY == nil or tonumber(CHX.saved.rankProgressY) == nil then
        CHX.saved.rankProgressY = CHX.defaults.rankProgressY
    end

    if CHX.saved.rankProgressScale == nil or tonumber(CHX.saved.rankProgressScale) == nil then
        CHX.saved.rankProgressScale = CHX.defaults.rankProgressScale
    end

    if CHX.saved.killLocationHoldSeconds == nil then
        CHX.saved.killLocationHoldSeconds = CHX.defaults.killLocationHoldSeconds
    end

    if CHX.saved.showFinishedBattles == nil then
        CHX.saved.showFinishedBattles = CHX.defaults.showFinishedBattles
    end

    if CHX.saved.newBattleFadeSeconds == nil then
        CHX.saved.newBattleFadeSeconds = CHX.defaults.newBattleFadeSeconds
    end

    if CHX.saved.finishedBattleHoldSeconds == nil then
        CHX.saved.finishedBattleHoldSeconds = CHX.defaults.finishedBattleHoldSeconds
    end

    if CHX.saved.statsPanelWindowVisible == nil then
        CHX.saved.statsPanelWindowVisible = CHX.defaults.statsPanelWindowVisible
    end

    if CHX.saved.statsPanelPage == nil then
        CHX.saved.statsPanelPage = CHX.defaults.statsPanelPage
    end

    if type(CHX.saved.pvpStatsSession) ~= "table" then
        CHX.saved.pvpStatsSession = CreateEmptyPvpStatsSession()
    end

    if type(CHX.saved.pvpStatsLifetime) ~= "table" then
        CHX.saved.pvpStatsLifetime = CreateEmptyPvpStatsLifetime()
    end

    EnsurePvpStatsLifetime()

    if CHX.saved.pvpStatsWasInPvp == nil then
        CHX.saved.pvpStatsWasInPvp = CHX.defaults.pvpStatsWasInPvp
    end

    EnsurePvpStatsState()
    RefreshPvpStatsZoneState()

    SLASH_COMMANDS["/pvpbuddy"] = SlashCommand
    SLASH_COMMANDS["/pb"] = SlashCommand

    QueryCampaignSelectionDataSafe("initialize")

    CreateUI()
    CreateStatsPanelShell()
    SetStatsPanelWindowVisible(CHX.saved.statsPanelWindowVisible == true)
    StartCampaignMenuKeybindWatcher()
    RegisterSettingsMenu()
    RegisterEvents()

    ApplyRankProgressSettings()

    UpdateDisplay()

    Print("loaded " .. CHX.version)
end

local function OnAddonLoaded(eventCode, addonName)
    if addonName ~= ADDON_NAME then return end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
    Initialize()
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
