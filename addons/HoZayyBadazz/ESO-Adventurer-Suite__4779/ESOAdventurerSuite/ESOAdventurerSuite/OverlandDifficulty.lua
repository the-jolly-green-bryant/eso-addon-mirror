-- ESO Adventurer Suite - Automatic Challenge Difficulty
-- Uses ESO's native Challenge Difficulty API and keeps all rules inside the Suite.

ESOProgressionCoach = ESOProgressionCoach or {}
local EPC = ESOProgressionCoach

local ACD = {}
EPC.OverlandDifficulty = ACD

local function safeCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a, b, c, d, e, f = pcall(fn, ...)
    if not ok then return nil end
    return a, b, c, d, e, f
end

local function nowMs()
    return (type(GetFrameTimeMilliseconds) == "function" and GetFrameTimeMilliseconds()) or 0
end

local function norm(text)
    text = zo_strlower(tostring(text or ""))
    text = text:gsub("^the%s+", "")
    text = text:gsub("[^%w%s]", "")
    text = text:gsub("%s+", " ")
    return zo_strtrim(text)
end

local function enumValue(name, fallback)
    local v = rawget(_G, name)
    return type(v) == "number" and v or fallback
end

function ACD:GetDifficultyOrder()
    local values = {
        enumValue("OVERLAND_DIFFICULTY_TYPE_BASEGAME", 0),
        enumValue("OVERLAND_DIFFICULTY_TYPE_JOURNEYMAN", 1),
        enumValue("OVERLAND_DIFFICULTY_TYPE_ADVENTURER", 2),
        enumValue("OVERLAND_DIFFICULTY_TYPE_VETERAN", 3),
    }
    return values
end

function ACD:GetDifficultyName(value)
    if type(GetString) == "function" then
        local ok, text = pcall(GetString, "SI_OVERLANDDIFFICULTYTYPE", tonumber(value) or 0)
        if ok and text and text ~= "" then return text end
    end
    local names = { [0] = "Adventurer", [1] = "Seasoned", [2] = "Master", [3] = "Vestige" }
    return names[tonumber(value) or 0] or "Challenge"
end

function ACD:GetDifficultyIcon(value)
    local keys = { [0] = "basegame", [1] = "journeyman", [2] = "adventurer", [3] = "veteran" }
    local key = keys[tonumber(value) or 0] or "basegame"
    return string.format("EsoUI/Art/ChallengeDifficulty/challengeDifficulty_%s_up.dds", key)
end

function ACD:GetDifficultyChoices()
    local names, values = {}, {}
    for _, value in ipairs(self:GetDifficultyOrder()) do
        names[#names + 1] = self:GetDifficultyName(value)
        values[#values + 1] = value
    end
    return names, values
end

-- Curated progression levels. Base-game alliance progression follows the original
-- 1-50 journey; later chapter/DLC adventure zones are level 50 destinations.
ACD.zoneLevels = {
    ["stros mkai"] = 1, ["betnikh"] = 4,
    ["glenumbra"] = 6, ["stormhaven"] = 16, ["rivenspire"] = 26, ["alikr desert"] = 36, ["bangkorai"] = 43,
    ["khenarthis roost"] = 1, ["auridon"] = 6, ["grahtwood"] = 16, ["greenshade"] = 26, ["malabal tor"] = 36, ["reapers march"] = 43,
    ["bleakrock isle"] = 1, ["bal foyen"] = 4, ["stonefalls"] = 6, ["deshaan"] = 16, ["shadowfen"] = 26, ["eastmarch"] = 36, ["the rift"] = 43,
    ["coldharbour"] = 45, ["craglorn"] = 50,
    ["wrothgar"] = 50, ["hews bane"] = 50, ["gold coast"] = 50,
    ["vvardenfell"] = 50, ["clockwork city"] = 50, ["summerset"] = 50, ["murkmire"] = 50,
    ["northern elsweyr"] = 50, ["southern elsweyr"] = 50,
    ["western skyrim"] = 50, ["the reach"] = 50, ["blackwood"] = 50, ["the deadlands"] = 50,
    ["high isle"] = 50, ["galen"] = 50, ["telvanni peninsula"] = 50, ["apocrypha"] = 50,
    ["west weald"] = 50, ["solstice"] = 50,
}

function ACD:GetZoneLevel(zoneName)
    local key = norm(zoneName)
    local exact = self.zoneLevels[key]
    if exact then return exact end
    -- Subzones inherit the parent-like named zone when possible.
    for known, level in pairs(self.zoneLevels) do
        if key:find(known, 1, true) then return level end
    end
    return 50
end

function ACD:GetCurrentZoneInfo()
    local zoneIndex = safeCall(GetUnitZoneIndex, "player") or 0
    local zoneId = safeCall(GetZoneId, zoneIndex) or 0
    local zoneName = safeCall(GetUnitZone, "player")
    if not zoneName or zoneName == "" then zoneName = safeCall(GetZoneNameByIndex, zoneIndex) or "Unknown Zone" end
    local subzone = safeCall(GetUnitSubZoneName, "player") or ""
    return zoneIndex, zoneId, zoneName, subzone
end

function ACD:GetPlayerLevel()
    local level = safeCall(GetUnitLevel, "player") or 1
    if type(CanUnitGainChampionPoints) == "function" and CanUnitGainChampionPoints("player") then
        level = 50
    end
    return math.max(1, math.min(50, tonumber(level) or 1))
end

function ACD:IsCompanionActive()
    if type(HasActiveCompanion) == "function" then
        local active = safeCall(HasActiveCompanion)
        if active == true then return true end
    end
    if type(GetActiveCompanionDefId) == "function" then
        local defId = tonumber(safeCall(GetActiveCompanionDefId)) or 0
        if defId > 0 then return true end
    end
    if type(DoesUnitExist) == "function" and safeCall(DoesUnitExist, "companion") == true then
        if type(IsUnitOnline) ~= "function" or safeCall(IsUnitOnline, "companion") ~= false then return true end
    end
    return false
end

function ACD:HoldWorldBoss(zoneId)
    local holdSeconds = tonumber(EPC.saved and EPC.saved.overlandDifficultyWorldBossHoldSeconds) or 45
    holdSeconds = math.max(15, math.min(120, holdSeconds))
    self.worldBossHoldZoneId = tonumber(zoneId) or 0
    self.worldBossHoldUntil = nowMs() + (holdSeconds * 1000)
end

function ACD:IsWorldBossHoldActive(zoneId)
    return tonumber(zoneId) == tonumber(self.worldBossHoldZoneId)
        and nowMs() < (tonumber(self.worldBossHoldUntil) or 0)
end

function ACD:GetJourneyDifficulty(zoneName)
    local order = self:GetDifficultyOrder()
    local playerLevel = self:GetPlayerLevel()
    local zoneLevel = self:GetZoneLevel(zoneName)
    local delta = playerLevel - zoneLevel
    if delta < -4 then return order[1], zoneLevel end
    if delta < 5 then return order[2], zoneLevel end
    if delta < 15 then return order[3], zoneLevel end
    return order[4], zoneLevel
end

local EVENT_WORDS = {
    "dark anchor", "dolmen", "harrowstorm", "abyssal geyser", "volcanic vent",
    "mirrormoor", "world event", "incursion",
}

function ACD:NearestPOIContext(zoneIndex)
    if type(GetNumPOIs) ~= "function" or type(GetPOIMapInfo) ~= "function" or type(GetMapPlayerPosition) ~= "function" then return nil end
    if type(ZO_WorldMap_IsWorldMapShowing) == "function" and ZO_WorldMap_IsWorldMapShowing() then return nil end

    local playerX, playerY = GetMapPlayerPosition("player")
    if not playerX or not playerY or (playerX == 0 and playerY == 0) then return nil end
    local radiusMeters = tonumber(EPC.saved.overlandDifficultyPoiRadius) or 85
    -- Normalized map distance is converted using LibGPS if available; otherwise
    -- a conservative map-space radius is used.
    local gps = rawget(_G, "LibGPS3") or rawget(_G, "LibGPS")
    local bestKind, bestMeters
    local count = safeCall(GetNumPOIs, zoneIndex) or 0

    for poiIndex = 1, count do
        local x, y, _, icon, _, _, discovered = safeCall(GetPOIMapInfo, zoneIndex, poiIndex)
        if x and y and x > 0 and y > 0 then
            local dx, dy = x - playerX, y - playerY
            local distMap = math.sqrt(dx * dx + dy * dy)
            local meters
            if gps and type(gps.GetLocalDistanceInMeters) == "function" then
                meters = safeCall(gps.GetLocalDistanceInMeters, gps, playerX, playerY, x, y)
            end
            meters = tonumber(meters) or (distMap * 10000)
            if meters <= radiusMeters and (not bestMeters or meters < bestMeters) then
                local poiName = safeCall(GetPOIInfo, zoneIndex, poiIndex) or ""
                local poiType = safeCall(GetPOIType, zoneIndex, poiIndex)
                local nameKey = norm(poiName)
                local kind
                if rawget(_G, "POI_TYPE_PUBLIC_DUNGEON") and poiType == POI_TYPE_PUBLIC_DUNGEON then
                    kind = "PUBLIC_DUNGEON"
                elseif rawget(_G, "POI_TYPE_GROUP_BOSS") and poiType == POI_TYPE_GROUP_BOSS then
                    kind = "WORLD_BOSS"
                elseif nameKey:find("dragon", 1, true) then
                    kind = "DRAGON"
                else
                    for _, word in ipairs(EVENT_WORDS) do
                        if nameKey:find(word, 1, true) then kind = "WORLD_EVENT" break end
                    end
                end
                if kind then bestKind, bestMeters = kind, meters end
            end
        end
    end
    return bestKind
end

function ACD:DetectSituation()
    local zoneIndex, zoneId, zoneName, subzone = self:GetCurrentZoneInfo()
    local mapContent = safeCall(GetMapContentType)
    local sub = norm(subzone)
    local zone = norm(zoneName)
    local isDungeonContent = rawget(_G, "MAP_CONTENT_DUNGEON") and mapContent == MAP_CONTENT_DUNGEON

    -- A visible boss target is more reliable than subzone text. This fixes multi-wave
    -- World Boss sites (including Blackreach) that are not reported as their own subzone.
    local reticleIsBoss = type(IsUnitBoss) == "function" and safeCall(IsUnitBoss, "reticleover") == true
    if reticleIsBoss then
        if not isDungeonContent then
            self:HoldWorldBoss(zoneId)
            return "WORLD_BOSS", zoneIndex, zoneId, zoneName
        elseif EPC.saved.overlandDifficultyHistoryBosses then
            return "HISTORY_BOSS", zoneIndex, zoneId, zoneName
        end
    end

    -- POI detection still provides pre-pull switching when the zone exposes the boss/event correctly.
    local poiSituation = self:NearestPOIContext(zoneIndex)
    if poiSituation then
        if poiSituation == "WORLD_BOSS" then self:HoldWorldBoss(zoneId) end
        return poiSituation, zoneIndex, zoneId, zoneName
    end

    -- Keep the World Boss rule through intermissions/waves after the boss temporarily disappears.
    if self:IsWorldBossHoldActive(zoneId) then
        return "WORLD_BOSS", zoneIndex, zoneId, zoneName
    end

    -- Delves are instanced dungeon-content maps that are not group/public dungeons.
    if isDungeonContent then
        if sub:find("public dungeon", 1, true) or zone:find("public dungeon", 1, true) then
            return "PUBLIC_DUNGEON", zoneIndex, zoneId, zoneName
        end
        return "DELVE", zoneIndex, zoneId, zoneName
    end

    return "OPEN_WORLD", zoneIndex, zoneId, zoneName
end

function ACD:GetRuleValue(situation, zoneId, zoneName)
    local saved = EPC.saved

    -- Companions are not scaled by Challenge Difficulty. When enabled, use the
    -- player's selected companion difficulty while a companion is active.
    local companionRuleEnabled = saved.overlandDifficultyCompanionEnabled == true
    -- One-time compatibility with v0.27.94 installs that used a Vestige-only boolean.
    if saved.overlandDifficultyForceVestigeWithCompanion == true and saved.overlandDifficultyCompanionMigrated ~= true then
        saved.overlandDifficultyCompanionEnabled = true
        saved.overlandDifficultyCompanion = self:GetDifficultyOrder()[#self:GetDifficultyOrder()]
        saved.overlandDifficultyCompanionMigrated = true
        companionRuleEnabled = true
    end
    if companionRuleEnabled and self:IsCompanionActive() then
        local value = tonumber(saved.overlandDifficultyCompanion)
        if value == nil then value = self:GetDifficultyOrder()[#self:GetDifficultyOrder()] end
        return value, nil, "COMPANION"
    end

    if saved.overlandDifficultyLevelingJourney then
        local value, zoneLevel = self:GetJourneyDifficulty(zoneName)
        if situation == "WORLD_BOSS" then
            local master = self:GetDifficultyOrder()[3]
            if value > master then value = master end
        end
        return value, zoneLevel, "JOURNEY"
    end

    local keyBySituation = {
        DELVE = "overlandDifficultyDelve",
        PUBLIC_DUNGEON = "overlandDifficultyPublicDungeon",
        WORLD_BOSS = "overlandDifficultyWorldBoss",
        WORLD_EVENT = "overlandDifficultyWorldEvent",
        DRAGON = "overlandDifficultyDragon",
        HISTORY_BOSS = "overlandDifficultyHistoryBoss",
    }
    if situation == "OPEN_WORLD" then
        local overrides = saved.overlandDifficultyZoneOverrides
        local override = type(overrides) == "table" and overrides[tostring(zoneId)] or nil
        if override ~= nil then return tonumber(override), nil, "ZONE" end
        return tonumber(saved.overlandDifficultyOpenWorld), nil, "RULE"
    end
    local key = keyBySituation[situation]
    return tonumber(key and saved[key] or saved.overlandDifficultyOpenWorld), nil, "RULE"
end

function ACD:IsChangeAllowed()
    if type(RequestChangePlayerOverlandDifficulty) ~= "function" or type(GetOverlandDifficulty) ~= "function" then return false end
    if IsUnitInCombat and IsUnitInCombat("player") then return false end
    if type(GetOverlandDifficultyDisabledReason) == "function" then
        local reason = GetOverlandDifficultyDisabledReason()
        local none = rawget(_G, "OVERLAND_DIFFICULTY_DISABLED_REASON_NONE") or 0
        if reason ~= none then return false end
    end
    return true
end

function ACD:RequestRefresh(delayMs)
    if not EPC.saved or EPC.saved.overlandDifficultyEnabled ~= true then return end
    self.refreshToken = (self.refreshToken or 0) + 1
    local token = self.refreshToken
    zo_callLater(function()
        if token ~= self.refreshToken then return end
        self:Refresh()
    end, tonumber(delayMs) or 800)
end

function ACD:Refresh()
    if not EPC.saved or EPC.saved.overlandDifficultyEnabled ~= true then
        self:RefreshMapLevelLabel()
        if EPC.ChallengeDifficultyOverlay and EPC.ChallengeDifficultyOverlay.Refresh then EPC.ChallengeDifficultyOverlay:Refresh() end
        return
    end
    local situation, zoneIndex, zoneId, zoneName = self:DetectSituation()
    local target, zoneLevel = self:GetRuleValue(situation, zoneId, zoneName)
    if target == nil then return end
    self.lastSituation = situation
    self.lastTarget = target

    local current = safeCall(GetOverlandDifficulty)
    if current == target then if EPC.ChallengeDifficultyOverlay and EPC.ChallengeDifficultyOverlay.Refresh then EPC.ChallengeDifficultyOverlay:Refresh() end return end
    if not self:IsChangeAllowed() then return end

    local t = nowMs()
    if t - (self.lastRequestMs or -100000) < 10500 then
        self:RequestRefresh(10500 - (t - (self.lastRequestMs or 0)) + 250)
        return
    end

    self.lastRequestMs = t
    safeCall(RequestChangePlayerOverlandDifficulty, target)
    if EPC.ChallengeDifficultyOverlay and EPC.ChallengeDifficultyOverlay.Refresh then EPC.ChallengeDifficultyOverlay:Refresh() end
end

function ACD:AnnounceZone()
    if not EPC.saved or EPC.saved.overlandDifficultyZoneMessages ~= true then return end
    local _, _, zoneName = self:GetCurrentZoneInfo()
    local target, zoneLevel = self:GetJourneyDifficulty(zoneName)
    if not EPC.saved.overlandDifficultyLevelingJourney then
        local situation, _, zoneId = self:DetectSituation()
        target = self:GetRuleValue(situation, zoneId, zoneName)
        zoneLevel = self:GetZoneLevel(zoneName)
    end
    local icon = self:GetDifficultyIcon(target)
    local text = string.format("%s  |cFFFFFF%s|r  |cD6B875Level %d|r  %s", zo_iconFormat(icon, 28, 28), zoneName, zoneLevel or 50, self:GetDifficultyName(target))
    if type(ZO_Alert) == "function" then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
    elseif EPC.Print then
        EPC:Print(text)
    end
end

function ACD:SetCurrentZoneOverride(value)
    local _, zoneId = self:GetCurrentZoneInfo()
    EPC.saved.overlandDifficultyZoneOverrides = EPC.saved.overlandDifficultyZoneOverrides or {}
    if value == nil then
        EPC.saved.overlandDifficultyZoneOverrides[tostring(zoneId)] = nil
    else
        EPC.saved.overlandDifficultyZoneOverrides[tostring(zoneId)] = tonumber(value)
    end
    self:RequestRefresh(100)
end

function ACD:GetCurrentZoneOverride()
    local _, zoneId = self:GetCurrentZoneInfo()
    local t = EPC.saved.overlandDifficultyZoneOverrides or {}
    return t[tostring(zoneId)]
end

function ACD:RefreshMapLevelLabel()
    if not self.mapLevelLabel then return end
    local show = EPC.saved and EPC.saved.overlandDifficultyLevelingJourney and EPC.saved.overlandDifficultyShowZoneLevelsMap ~= false
    if not show then self.mapLevelLabel:SetHidden(true) return end
    local mapName = safeCall(GetMapName) or safeCall(GetUnitZone, "player") or ""
    local level = self:GetZoneLevel(mapName)
    self.mapLevelLabel:SetText(string.format("|cD6B875Zone Level: %d|r", level))
    self.mapLevelLabel:SetHidden(false)
end

function ACD:CreateMapLevelLabel()
    if self.mapLevelLabel or not ZO_WorldMap then return end
    local label = WINDOW_MANAGER:CreateControl("ESOAdventurerSuiteZoneLevelLabel", ZO_WorldMap, CT_LABEL)
    label:SetFont("ZoFontWinH3")
    label:SetAnchor(TOPLEFT, ZO_WorldMap, TOPLEFT, 72, 88)
    label:SetDrawTier(DT_HIGH)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetHidden(true)
    self.mapLevelLabel = label
    if CALLBACK_MANAGER and type(CALLBACK_MANAGER.RegisterCallback) == "function" then
        CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function() self:RefreshMapLevelLabel() end)
    end
end

function ACD:Initialize()
    self:CreateMapLevelLabel()
    local prefix = "ESOAdventurerSuite_AutomaticDifficulty"
    EVENT_MANAGER:RegisterForEvent(prefix, EVENT_PLAYER_ACTIVATED, function()
        self:RefreshMapLevelLabel()
        self:RequestRefresh(1200)
        self:AnnounceZone()
    end)
    if EVENT_ZONE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Zone", EVENT_ZONE_CHANGED, function(_, unitTag)
            if unitTag and unitTag ~= "player" then return end
            self:RefreshMapLevelLabel()
            self:RequestRefresh(1500)
            zo_callLater(function() self:AnnounceZone() end, 1700)
        end)
    elseif EVENT_ZONE_UPDATE then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Zone", EVENT_ZONE_UPDATE, function()
            self:RefreshMapLevelLabel()
            self:RequestRefresh(1500)
        end)
    end
    EVENT_MANAGER:RegisterForEvent(prefix .. "_Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if not inCombat then self:RequestRefresh(500) end
    end)
    if EVENT_RETICLE_TARGET_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Reticle", EVENT_RETICLE_TARGET_CHANGED, function()
            self:RequestRefresh(50)
        end)
    end
    if EVENT_COMPANION_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_CompanionOn", EVENT_COMPANION_ACTIVATED, function() self:RequestRefresh(250) end)
    end
    if EVENT_COMPANION_DEACTIVATED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_CompanionOff", EVENT_COMPANION_DEACTIVATED, function() self:RequestRefresh(250) end)
    end
    if EVENT_OVERLAND_DIFFICULTY_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Difficulty", EVENT_OVERLAND_DIFFICULTY_CHANGED, function()
            self:RequestRefresh(11000)
        end)
    end
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Context", 1500, function()
        if EPC.saved and EPC.saved.overlandDifficultyEnabled then self:RequestRefresh(0) end
    end)
    self:RequestRefresh(1000)
end
