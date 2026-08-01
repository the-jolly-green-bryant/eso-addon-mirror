local TamrielTomes_MapPins = "TamrielTomes_MapPins"

local TTMP = _G.TamrielTomesMapPins or {}
_G.TamrielTomesMapPins = TTMP

TTMP.addonName = TamrielTomes_MapPins
TTMP.savedVarsName = "TamrielTomesMapPins_SV"
TTMP.savedVarsVersion = 1
TTMP.pinType = "TAMRIEL_TOMES_MAP_PINS_CHALLENGE"
TTMP.compassPinType = "TAMRIEL_TOMES_COMPASS_PINS_CHALLENGE"
TTMP.challengeData = {}
TTMP.texturePath = "TamrielTomes_MapPins/textures/"
TTMP.activeChallengePins = {}
TTMP.activeMatchesByZoneId = {}
TTMP.activeDynamicMatchesByType = {}
TTMP.activeDynamicMatchCount = 0
TTMP.activeCompassZoneIndex = nil
TTMP.activeCompassZoneId = nil
TTMP.activeCompassZoneMatches = nil
TTMP.compassRegisteredTypes = {}
TTMP.compassOverlayMaxDistance = 0.55
TTMP.compassOverlayDrawLevel = 140
TTMP.nativePinTextureCallbacks = {}
TTMP.pinDebugCache = {}

local GLOBAL_MAP_TYPES = {
    [MAPTYPE_WORLD] = true,
    [MAPTYPE_COSMIC] = true,
}

TTMP.icons = {
    default = TTMP.texturePath .. "challenge_world_boss.dds",
    worldBoss = TTMP.texturePath .. "challenge_world_boss.dds",
    worldBossComplete = TTMP.texturePath .. "challenge_world_boss_complete.dds",
    worldBossIncomplete = TTMP.texturePath .. "challenge_world_boss_incomplete.dds",
    worldEvent = TTMP.texturePath .. "challenge_world_event_incomplete.dds",
    worldEventComplete = TTMP.texturePath .. "challenge_world_event_complete.dds",
    worldEventIncomplete = TTMP.texturePath .. "challenge_world_event_incomplete.dds",
    publicDungeon = TTMP.texturePath .. "challenge_public_dungeon_incomplete.dds",
    publicDungeonComplete = TTMP.texturePath .. "challenge_public_dungeon_complete.dds",
    publicDungeonIncomplete = TTMP.texturePath .. "challenge_public_dungeon_incomplete.dds",
    delveGeneric = TTMP.texturePath .. "challenge_delve_generic.dds",
    delveGenericComplete = TTMP.texturePath .. "challenge_delve_complete_generic.dds",
    delveGenericIncomplete = TTMP.texturePath .. "challenge_delve_generic.dds",
    groupDungeon = TTMP.texturePath .. "challenge_group_dungeon.dds",
    groupDungeonComplete = TTMP.texturePath .. "challenge_group_dungeon_complete.dds",
    groupDungeonIncomplete = TTMP.texturePath .. "challenge_group_dungeon_incomplete.dds",
    groupDungeonGeneric = TTMP.texturePath .. "challenge_group_dungeon_generic.dds",
    groupDungeonGenericComplete = TTMP.texturePath .. "challenge_group_dungeon_complete_generic.dds",
    groupDungeonGenericIncomplete = TTMP.texturePath .. "challenge_group_dungeon_incomplete_generic.dds",
    trial = TTMP.texturePath .. "challenge_trial.dds",
    trialComplete = TTMP.texturePath .. "challenge_trial_complete.dds",
    trialIncomplete = TTMP.texturePath .. "challenge_trial_incomplete.dds",
    trialGeneric = TTMP.texturePath .. "challenge_trial_generic.dds",
    trialGenericComplete = TTMP.texturePath .. "challenge_trial_complete_generic.dds",
    trialGenericIncomplete = TTMP.texturePath .. "challenge_trial_incomplete_generic.dds",
    arena = TTMP.texturePath .. "challenge_arena.dds",
    arenaComplete = TTMP.texturePath .. "challenge_arena_complete.dds",
    arenaIncomplete = TTMP.texturePath .. "challenge_arena_incomplete.dds",
    arenaGeneric = TTMP.texturePath .. "challenge_arena_generic.dds",
    arenaGenericComplete = TTMP.texturePath .. "challenge_arena_complete_generic.dds",
    arenaGenericIncomplete = TTMP.texturePath .. "challenge_arena_incomplete_generic.dds",
    cyrodiilKeep = TTMP.texturePath .. "challenge_cyrodiil_keep.dds",
    imperialCity = TTMP.texturePath .. "challenge_imperial_city.dds",
    bankGeneric = TTMP.texturePath .. "challenge_bank_generic.dds",
    dynamicEncounterGeneric = TTMP.texturePath .. "challenge_dynamic_encounter_generic.dds",
    fightersGuildGeneric = TTMP.texturePath .. "challenge_fighters_guild_generic.dds",
    guildTraderGeneric = TTMP.texturePath .. "challenge_guild_trader_generic.dds",
    magesGuildGeneric = TTMP.texturePath .. "challenge_mages_guild_generic.dds",
    mundusGeneric = TTMP.texturePath .. "challenge_mundus_generic.dds",
    thievesGuild = "/esoui/art/treeicons/tutorial_idexicon_thievesguild_up.dds",
    undauntedGeneric = TTMP.texturePath .. "challenge_undaunted_generic.dds",
    worldEventGeneric = TTMP.texturePath .. "challenge_world_event_incomplete_generic.dds",
    worldEventGenericComplete = TTMP.texturePath .. "challenge_world_event_complete_generic.dds",
    worldEventGenericIncomplete = TTMP.texturePath .. "challenge_world_event_incomplete_generic.dds",
}

TTMP.stateIconsByIcon = {
    [TTMP.icons.publicDungeon] = {
        complete = TTMP.icons.publicDungeonComplete,
        incomplete = TTMP.icons.publicDungeonIncomplete,
        undiscovered = TTMP.icons.publicDungeonIncomplete,
    },
    [TTMP.icons.worldBoss] = {
        complete = TTMP.icons.worldBossComplete,
        incomplete = TTMP.icons.worldBossIncomplete,
        undiscovered = TTMP.icons.worldBossIncomplete,
    },
    [TTMP.icons.worldEvent] = {
        complete = TTMP.icons.worldEventComplete,
        incomplete = TTMP.icons.worldEventIncomplete,
        undiscovered = TTMP.icons.worldEventIncomplete,
    },
    [TTMP.icons.groupDungeon] = {
        complete = TTMP.icons.groupDungeonComplete,
        incomplete = TTMP.icons.groupDungeonIncomplete,
        undiscovered = TTMP.icons.groupDungeonIncomplete,
    },
    [TTMP.icons.trial] = {
        complete = TTMP.icons.trialComplete,
        incomplete = TTMP.icons.trialIncomplete,
        undiscovered = TTMP.icons.trialIncomplete,
    },
    [TTMP.icons.arena] = {
        complete = TTMP.icons.arenaComplete,
        incomplete = TTMP.icons.arenaIncomplete,
        undiscovered = TTMP.icons.arenaIncomplete,
    },
}

TTMP.poiIconOverrides = {
    ["esoui/art/icons/poi/poi_groupboss_complete.dds"] = TTMP.icons.worldBossComplete,
    ["esoui/art/icons/poi/poi_groupboss_incomplete.dds"] = TTMP.icons.worldBossIncomplete,
    ["esoui/art/icons/poi/poi_dungeon_complete.dds"] = TTMP.icons.publicDungeonComplete,
    ["esoui/art/icons/poi/poi_dungeon_incomplete.dds"] = TTMP.icons.publicDungeonIncomplete,
    ["esoui/art/icons/poi/poi_publicdungeon_complete.dds"] = TTMP.icons.publicDungeonComplete,
    ["esoui/art/icons/poi/poi_publicdungeon_incomplete.dds"] = TTMP.icons.publicDungeonIncomplete,
}

TTMP.poiIconKinds = {
    ["esoui/art/icons/mapkey/mapkey_dynamic_world_event.dds"] = "dynamicEncounter",
    ["esoui/art/icons/mapkey/mapkey_guildkiosk.dds"] = "guildTrader",
    ["esoui/art/icons/poi/poi_delve_complete.dds"] = "delve",
    ["esoui/art/icons/poi/poi_delve_incomplete.dds"] = "delve",
    ["esoui/art/icons/poi/poi_group_portal_complete.dds"] = "worldEvent",
    ["esoui/art/icons/poi/poi_group_portal_incomplete.dds"] = "worldEvent",
    ["esoui/art/icons/poi/poi_groupinstance_complete.dds"] = "groupDungeon",
    ["esoui/art/icons/poi/poi_groupinstance_incomplete.dds"] = "groupDungeon",
    ["esoui/art/icons/poi/poi_groupboss_complete.dds"] = "worldBoss",
    ["esoui/art/icons/poi/poi_groupboss_incomplete.dds"] = "worldBoss",
    ["esoui/art/icons/poi/poi_mundus_complete.dds"] = "mundus",
    ["esoui/art/icons/poi/poi_mundus_incomplete.dds"] = "mundus",
    ["esoui/art/icons/poi/poi_portal_complete.dds"] = "worldEvent",
    ["esoui/art/icons/poi/poi_portal_incomplete.dds"] = "worldEvent",
    ["esoui/art/icons/poi/poi_raiddungeon_complete.dds"] = "trial",
    ["esoui/art/icons/poi/poi_raiddungeon_incomplete.dds"] = "trial",
    ["esoui/art/icons/servicemappins/servicepin_bank.dds"] = "bank",
    ["esoui/art/icons/servicemappins/servicepin_fightersguild.dds"] = "fightersGuild",
    ["esoui/art/icons/servicemappins/servicepin_guildkiosk.dds"] = "guildTrader",
    ["esoui/art/icons/servicemappins/servicepin_magesguild.dds"] = "magesGuild",
    ["esoui/art/icons/servicemappins/servicepin_undaunted.dds"] = "undaunted",
    ["esoui/art/icons/servicemappins/u50_poi_dynamic_world_event.dds"] = "dynamicEncounter",
}

TTMP.compassIconTypes = {
    { suffix = "WORLD_BOSS", icon = TTMP.icons.worldBoss },
    { suffix = "WORLD_BOSS_COMPLETE", icon = TTMP.icons.worldBossComplete },
    { suffix = "WORLD_BOSS_INCOMPLETE", icon = TTMP.icons.worldBossIncomplete },
    { suffix = "WORLD_EVENT", icon = TTMP.icons.worldEvent },
    { suffix = "WORLD_EVENT_COMPLETE", icon = TTMP.icons.worldEventComplete },
    { suffix = "WORLD_EVENT_INCOMPLETE", icon = TTMP.icons.worldEventIncomplete },
    { suffix = "WORLD_EVENT_GENERIC", icon = TTMP.icons.worldEventGeneric },
    { suffix = "PUBLIC_DUNGEON", icon = TTMP.icons.publicDungeon },
    { suffix = "PUBLIC_DUNGEON_COMPLETE", icon = TTMP.icons.publicDungeonComplete },
    { suffix = "DELVE_GENERIC", icon = TTMP.icons.delveGeneric },
    { suffix = "DELVE_GENERIC_COMPLETE", icon = TTMP.icons.delveGenericComplete },
    { suffix = "GROUP_DUNGEON", icon = TTMP.icons.groupDungeon },
    { suffix = "GROUP_DUNGEON_COMPLETE", icon = TTMP.icons.groupDungeonComplete },
    { suffix = "GROUP_DUNGEON_INCOMPLETE", icon = TTMP.icons.groupDungeonIncomplete },
    { suffix = "GROUP_DUNGEON_GENERIC", icon = TTMP.icons.groupDungeonGeneric },
    { suffix = "GROUP_DUNGEON_GENERIC_COMPLETE", icon = TTMP.icons.groupDungeonGenericComplete },
    { suffix = "GROUP_DUNGEON_GENERIC_INCOMPLETE", icon = TTMP.icons.groupDungeonGenericIncomplete },
    { suffix = "TRIAL", icon = TTMP.icons.trial },
    { suffix = "TRIAL_COMPLETE", icon = TTMP.icons.trialComplete },
    { suffix = "TRIAL_INCOMPLETE", icon = TTMP.icons.trialIncomplete },
    { suffix = "TRIAL_GENERIC", icon = TTMP.icons.trialGeneric },
    { suffix = "TRIAL_GENERIC_COMPLETE", icon = TTMP.icons.trialGenericComplete },
    { suffix = "TRIAL_GENERIC_INCOMPLETE", icon = TTMP.icons.trialGenericIncomplete },
    { suffix = "ARENA", icon = TTMP.icons.arena },
    { suffix = "ARENA_COMPLETE", icon = TTMP.icons.arenaComplete },
    { suffix = "ARENA_INCOMPLETE", icon = TTMP.icons.arenaIncomplete },
    { suffix = "ARENA_GENERIC", icon = TTMP.icons.arenaGeneric },
    { suffix = "ARENA_GENERIC_COMPLETE", icon = TTMP.icons.arenaGenericComplete },
    { suffix = "ARENA_GENERIC_INCOMPLETE", icon = TTMP.icons.arenaGenericIncomplete },
    { suffix = "CYRODIIL_KEEP", icon = TTMP.icons.cyrodiilKeep },
    { suffix = "IMPERIAL_CITY", icon = TTMP.icons.imperialCity },
    { suffix = "BANK_GENERIC", icon = TTMP.icons.bankGeneric },
    { suffix = "DYNAMIC_ENCOUNTER_GENERIC", icon = TTMP.icons.dynamicEncounterGeneric },
    { suffix = "FIGHTERS_GUILD_GENERIC", icon = TTMP.icons.fightersGuildGeneric },
    { suffix = "GUILD_TRADER_GENERIC", icon = TTMP.icons.guildTraderGeneric },
    { suffix = "MAGES_GUILD_GENERIC", icon = TTMP.icons.magesGuildGeneric },
    { suffix = "MUNDUS_GENERIC", icon = TTMP.icons.mundusGeneric },
    { suffix = "THIEVES_GUILD", icon = TTMP.icons.thievesGuild },
    { suffix = "UNDAUNTED_GENERIC", icon = TTMP.icons.undauntedGeneric },
}

TTMP.defaults = {
    showPins = true,
    [TTMP.compassPinType] = true,
    debug = false,
    verboseDebug = false,
    pinDebug = false,
}

TTMP.pinLayoutData = {
    level = 75,
    texture = function(pin)
        local pinTag = pin.m_PinTag
        if type(pinTag) == "table" and pinTag.icon then
            return pinTag.icon
        end
        return TTMP.icons.default
    end,
    size = 32,
    minSize = 24,
    mouseLevel = 120,
}

local function Trim(value)
    return (value or ""):match("^%s*(.-)%s*$")
end

local function Normalize(value)
    return string.lower(zo_strformat("<<1>>", value or ""))
end

local function NormalizeTexturePath(value)
    return string.lower((value or ""):gsub("\\", "/"):gsub("^/", ""))
end

local function GetChallengeLookupKey(zoneId, poiIndex)
    return zoneId .. ":" .. poiIndex
end

local function IsValidNormalizedMapPoint(x, y)
    return x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1
end

local function GetPOIIconState(poiIcon)
    local normalizedIcon = NormalizeTexturePath(poiIcon)
    if string.sub(normalizedIcon, -14) == "incomplete.dds" then
        return "incomplete"
    elseif string.sub(normalizedIcon, -12) == "complete.dds" then
        return "complete"
    end
    return nil
end

local function GetPOIStateFromPinType(pinType)
    if pinType == MAP_PIN_TYPE_POI_SUGGESTED then
        return "undiscovered"
    elseif pinType == MAP_PIN_TYPE_POI_SEEN then
        return "incomplete"
    elseif pinType == MAP_PIN_TYPE_POI_COMPLETE then
        return "complete"
    end

    return nil
end

local function GetPOIStateFromMapInfo(poiPinType, _isShownInCurrentMap, isDiscovered)
    local poiState = GetPOIStateFromPinType(poiPinType)
    if poiState then
        return poiState
    end

    if isDiscovered == false then
        return "undiscovered"
    end

    return nil
end

local pinTypeNames = {}

local function AddPinTypeName(pinType, name)
    if pinType then
        pinTypeNames[pinType] = name
    end
end

AddPinTypeName(MAP_PIN_TYPE_POI_SUGGESTED, "MAP_PIN_TYPE_POI_SUGGESTED")
AddPinTypeName(MAP_PIN_TYPE_POI_SEEN, "MAP_PIN_TYPE_POI_SEEN")
AddPinTypeName(MAP_PIN_TYPE_POI_COMPLETE, "MAP_PIN_TYPE_POI_COMPLETE")
AddPinTypeName(MAP_PIN_TYPE_WORLD_EVENT_POI_ACTIVE, "MAP_PIN_TYPE_WORLD_EVENT_POI_ACTIVE")
AddPinTypeName(MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE, "MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE")
AddPinTypeName(MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE_CURRENT_LOC, "MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE_CURRENT_LOC")

local function GetPinTypeName(pinType)
    return pinTypeNames[pinType] or tostring(pinType)
end

local function GetGenericChallengeIcon(entry, pin, poiIcon, poiState)
    if pin and pin.icon and pin.icon ~= entry.icon then
        local stateIcons = TTMP.stateIconsByIcon[pin.icon]
        local state = poiState or GetPOIIconState(poiIcon)
        if state and stateIcons and stateIcons[state] then
            return stateIcons[state]
        end
        return pin.icon
    end

    local genericIcons = entry.genericIcons
    if genericIcons then
        local state = poiState or GetPOIIconState(poiIcon)
        if state == "undiscovered" and genericIcons.undiscovered then
            return genericIcons.undiscovered
        elseif state == "undiscovered" and genericIcons.incomplete then
            return genericIcons.incomplete
        end
        if state and genericIcons[state] then
            return genericIcons[state]
        end
        if genericIcons.default then
            return genericIcons.default
        end
    end

    return entry.icon or TTMP.icons.default
end

function TTMP:GetChallengeIcon(entry, pin, poiIcon, poiState)
    if entry.genericChallenge then
        return GetGenericChallengeIcon(entry, pin, poiIcon, poiState)
    end

    local stateIcons = self.stateIconsByIcon[pin.icon or entry.icon]
    if poiState and stateIcons and stateIcons[poiState] then
        return stateIcons[poiState]
    end

    local iconOverride = poiIcon and self.poiIconOverrides[NormalizeTexturePath(poiIcon)]
    if iconOverride then
        return iconOverride
    end

    return pin.icon or entry.icon or self.icons.default
end

function TTMP:GetCompassTexturePath(icon)
    icon = icon or self.icons.default
    if string.sub(icon, 1, 1) == "/" then
        return icon
    end

    return "/" .. icon
end

function TTMP:IsPinFilterEnabled()
    if self.savedVars.showPins == false then
        return false
    end

    if self.pinTypeId then
        return self.lmp:IsEnabled(self.pinTypeId) ~= false
    end

    return true
end

function TTMP:IsCompassPinFilterEnabled()
    if not self:IsPinFilterEnabled() then
        return false
    end

    if self.savedVars[self.compassPinType] == false then
        return false
    end

    if self.compassPins and self.compassPins.IsCompassPinEnabled then
        return self.compassPins:IsCompassPinEnabled(self.compassPinType) ~= false
    end

    return true
end

function TTMP:SetAllCompassPinTypesEnabled(enabled)
    self.savedVars[self.compassPinType] = enabled

    if not self.compassPins or not self.compassPins.SetCompassPinEnabled then
        return
    end

    for _, pinType in ipairs(self.compassRegisteredTypes) do
        self.compassPins:SetCompassPinEnabled(pinType, enabled)
        self.savedVars[pinType] = enabled
    end
end

function TTMP:RebuildActiveChallengeLookup()
    local lookup = {}
    local byZoneId = {}
    local dynamicMatchesByType = {}
    local dynamicMatchCount = 0
    local matches = self:GetActiveChallengeEntries()

    local function AddStaticPins(match)
        for _, pin in ipairs(match.entry.pins) do
            if pin.zoneId and pin.poiIndex then
                local key = GetChallengeLookupKey(pin.zoneId, pin.poiIndex)
                if not lookup[key] then
                    local pinMatch = { match = match, entry = match.entry, pin = pin }
                    local zoneMatches = byZoneId[pin.zoneId]
                    lookup[key] = pinMatch
                    if zoneMatches then
                        zoneMatches[#zoneMatches + 1] = pinMatch
                    else
                        byZoneId[pin.zoneId] = { pinMatch }
                    end
                end
            end
        end
    end

    for _, match in ipairs(matches) do
        if match.entry.dynamicPinType then
            local dynamicPinType = match.entry.dynamicPinType
            local dynamicMatches = dynamicMatchesByType[dynamicPinType]
            if dynamicMatches then
                dynamicMatches[#dynamicMatches + 1] = match
            else
                dynamicMatchesByType[dynamicPinType] = { match }
            end
            dynamicMatchCount = dynamicMatchCount + 1
        elseif not match.entry.genericChallenge then
            AddStaticPins(match)
        end
    end

    for _, match in ipairs(matches) do
        if match.entry.genericChallenge and not match.entry.dynamicPinType then
            AddStaticPins(match)
        end
    end

    self.activeChallengePins = lookup
    self.activeMatchesByZoneId = byZoneId
    self.activeDynamicMatchesByType = dynamicMatchesByType
    self.activeDynamicMatchCount = dynamicMatchCount
    self.activeChallengeLookupBuilt = true
    return lookup
end

function TTMP:GetPOIChallengeKind(zoneIndex, poiIndex, poiIcon)
    local normalizedIcon = NormalizeTexturePath(poiIcon)
    if normalizedIcon == "" then
        normalizedIcon = NormalizeTexturePath(select(4, GetPOIMapInfo(zoneIndex, poiIndex)))
    end

    local iconKind = self.poiIconKinds[normalizedIcon]
    if iconKind then
        return iconKind
    end

    local worldEventInstanceId = GetPOIWorldEventInstanceId(zoneIndex, poiIndex)
    if worldEventInstanceId ~= 0 then
        return "worldEvent"
    end

    local mapFilterOverride = GetPOIMapFilterOverride(zoneIndex, poiIndex)
    if mapFilterOverride == MAP_FILTER_TRIALS then
        return "trial"
    elseif mapFilterOverride == MAP_FILTER_ARENAS then
        return "arena"
    elseif mapFilterOverride == MAP_FILTER_DUNGEONS then
        return "groupDungeon"
    end

    local poiType = GetPOIType(zoneIndex, poiIndex)
    if poiType == POI_TYPE_PUBLIC_DUNGEON then
        return "publicDungeon"
    end

    if GetPOIInstanceType(zoneIndex, poiIndex) == INSTANCE_TYPE_RAID then
        return "trial"
    end

    if poiType == POI_TYPE_GROUP_DUNGEON then
        return "groupDungeon"
    end

    return nil
end

function TTMP:GetDynamicPinIcon(entry, zoneId)
    if zoneId and entry.bonusZoneIds and entry.bonusZoneIds[zoneId] and entry.bonusIcon then
        return entry.bonusIcon
    end

    return entry.icon
end

function TTMP:CreateDynamicPinMatch(match, zoneIndex, poiIndex)
    local zoneId = GetZoneId(zoneIndex)
    local pin = {
        type = "poi",
        zoneId = zoneId,
        poiIndex = poiIndex,
        label = match.entry.pinLabel or match.entry.label,
        icon = self:GetDynamicPinIcon(match.entry, zoneId),
    }

    return {
        match = match,
        entry = match.entry,
        pin = pin,
    }
end

function TTMP:GetDynamicMatchForPOI(zoneIndex, poiIndex, poiIcon)
    if self.activeDynamicMatchCount == 0 then
        return nil
    end

    local challengeKind = self:GetPOIChallengeKind(zoneIndex, poiIndex, poiIcon)
    local matches = challengeKind and self.activeDynamicMatchesByType[challengeKind]
    if not matches then
        return nil
    end

    local zoneId = GetZoneId(zoneIndex)
    local fallbackMatch
    for _, match in ipairs(matches) do
        local pinMatch = self:CreateDynamicPinMatch(match, zoneIndex, poiIndex)
        if match.entry.bonusIcon and match.entry.bonusZoneIds and match.entry.bonusZoneIds[zoneId] then
            return pinMatch
        end
        fallbackMatch = fallbackMatch or pinMatch
    end

    return fallbackMatch
end

function TTMP:GetActiveChallengeMatchesForZone(zoneId)
    if not self.activeChallengeLookupBuilt then
        self:RebuildActiveChallengeLookup()
    end

    return self.activeMatchesByZoneId[zoneId] or {}
end

function TTMP:GetZoneIndexByZoneId(zoneId)
    if not zoneId or zoneId == 0 then
        return nil
    end

    local mapId = GetMapIdByZoneId(zoneId)
    if mapId and mapId ~= 0 then
        local zoneIndex = GetZoneIndexByMapId(mapId)
        if zoneIndex and zoneIndex > 0 then
            return zoneIndex
        end
    end

    local mapIndex = GetMapIndexByZoneId(zoneId)
    if mapIndex then
        local _, _, _, zoneIndex = GetMapInfoByIndex(mapIndex)
        if zoneIndex and zoneIndex > 0 then
            return zoneIndex
        end
    end

    return nil
end

function TTMP:GetGlobalMapCoordinates(zoneId, zoneX, zoneY)
    if not IsValidNormalizedMapPoint(zoneX, zoneY) then
        return nil, nil
    end

    local mapId = GetMapIdByZoneId(zoneId)
    if not mapId or mapId == 0 then
        return nil, nil
    end

    local offsetX, offsetZ, width, height = GetUniversallyNormalizedMapInfo(mapId)
    if not offsetX or not offsetZ or not width or not height or width <= 0 or height <= 0 then
        return nil, nil
    end

    local currentMapId = GetCurrentMapId()
    if not currentMapId or currentMapId == 0 then
        return nil, nil
    end

    local currentOffsetX, currentOffsetZ, currentWidth, currentHeight = GetUniversallyNormalizedMapInfo(currentMapId)
    if not currentOffsetX or not currentOffsetZ or not currentWidth or not currentHeight or currentWidth <= 0 or currentHeight <= 0 then
        return nil, nil
    end

    local universalX = offsetX + zoneX * width
    local universalZ = offsetZ + zoneY * height
    local globalX = (universalX - currentOffsetX) / currentWidth
    local globalY = (universalZ - currentOffsetZ) / currentHeight
    if IsValidNormalizedMapPoint(globalX, globalY) then
        return globalX, globalY
    end

    return nil, nil
end

function TTMP:GetFastTravelCoordinatesForPOI(zoneIndex, poiIndex)
    if not zoneIndex or not poiIndex then
        return nil, nil, nil
    end

    for nodeIndex = 1, GetNumFastTravelNodes() do
        local nodeZoneIndex, nodePOIIndex = GetFastTravelNodePOIIndicies(nodeIndex)
        if nodeZoneIndex == zoneIndex and nodePOIIndex == poiIndex then
            local known, _, normalizedX, normalizedY, icon, _, _, isShownInCurrentMap = GetFastTravelNodeInfo(nodeIndex)
            if known and isShownInCurrentMap and IsValidNormalizedMapPoint(normalizedX, normalizedY) then
                return normalizedX, normalizedY, icon
            end
        end
    end

    return nil, nil, nil
end

function TTMP:GetZoneStoryCoordinatesForPOI(zoneId, zoneIndex, poiIndex)
    if not zoneId or zoneId == 0 or not zoneIndex or not poiIndex then
        return nil, nil, nil
    end

    local zoneCompletionType = GetPOIZoneCompletionType(zoneIndex, poiIndex)
    if not zoneCompletionType or zoneCompletionType == ZONE_COMPLETION_TYPE_NONE then
        return nil, nil, nil
    end

    local numActivities = GetNumZoneActivitiesForZoneCompletionType(zoneId, zoneCompletionType)
    for activityIndex = 1, numActivities do
        local activityId = GetZoneActivityIdForZoneCompletionType(zoneId, zoneCompletionType, activityIndex)
        local activityZoneIndex, activityPOIIndex
        if activityId and activityId ~= 0 then
            activityZoneIndex, activityPOIIndex = GetPOIIndices(activityId)
        end
        if activityZoneIndex == zoneIndex and activityPOIIndex == poiIndex then
            local normalizedX, normalizedY, _, isShownInCurrentMap = GetNormalizedPositionForZoneStoryActivityId(zoneId, zoneCompletionType, activityId)
            if isShownInCurrentMap and IsValidNormalizedMapPoint(normalizedX, normalizedY) then
                return normalizedX, normalizedY, zoneCompletionType
            end
        end
    end

    return nil, nil, nil
end

function TTMP:GetMatchForPOI(zoneIndex, poiIndex, poiIcon)
    if not zoneIndex or not poiIndex then
        return nil
    end

    if not self.activeChallengeLookupBuilt then
        self:RebuildActiveChallengeLookup()
    end

    local zoneId = GetZoneId(zoneIndex)
    return self.activeChallengePins[GetChallengeLookupKey(zoneId, poiIndex)] or self:GetDynamicMatchForPOI(zoneIndex, poiIndex, poiIcon)
end

function TTMP:GetNativePinZoneAndPOI(pin)
    local pinType = pin:GetPinType()

    if pin:IsPOI() or pinType == MAP_PIN_TYPE_POI_SUGGESTED then
        return pin:GetPOIZoneIndex(), pin:GetPOIIndex()
    end

    if pin:IsFastTravelWayShrine() then
        local nodeIndex = pin:GetFastTravelNodeIndex()
        if nodeIndex then
            return GetFastTravelNodePOIIndicies(nodeIndex)
        end
    end

    if pin:IsWorldEventPOIPin() then
        return pin:GetPOIZoneIndex(), pin:GetPOIIndex()
    end

    return nil, nil
end

function TTMP:GetNativePinPOIState(pin, zoneIndex, poiIndex)
    local pinType = pin:GetPinType()
    local pinState = GetPOIStateFromPinType(pinType)
    if pinState then
        return pinState
    end

    if zoneIndex and zoneIndex > 0 and poiIndex and poiIndex > 0 then
        local poiPinType = select(3, GetPOIMapInfo(zoneIndex, poiIndex))
        local poiState = GetPOIStateFromPinType(poiPinType)
        if poiState then
            return poiState
        end
    end

    return nil
end

function TTMP:GetMatchForNativePin(pin, poiIcon)
    if not self:IsPinFilterEnabled() then
        return nil
    end

    if not self.activeChallengeLookupBuilt then
        self:RebuildActiveChallengeLookup()
    end

    local zoneIndex, poiIndex = self:GetNativePinZoneAndPOI(pin)
    return self:GetMatchForPOI(zoneIndex, poiIndex, poiIcon), self:GetNativePinPOIState(pin, zoneIndex, poiIndex)
end

function TTMP:ClearPinDebugCache()
    self.pinDebugCache = {}
end

function TTMP:DebugNativePin(pin, originalIcon, match, poiState, challengeIcon)
    if not self.savedVars or not self.savedVars.pinDebug then
        return
    end

    local zoneIndex, poiIndex = self:GetNativePinZoneAndPOI(pin)
    if not zoneIndex or not poiIndex then
        return
    end

    local pinType = pin:GetPinType()
    local zoneId = zoneIndex > 0 and GetZoneId(zoneIndex) or 0
    local poiPinType
    local mapIcon = ""
    if zoneIndex > 0 and poiIndex > 0 then
        poiPinType = select(3, GetPOIMapInfo(zoneIndex, poiIndex))
        mapIcon = select(4, GetPOIMapInfo(zoneIndex, poiIndex)) or ""
    end

    local matchName = "none"
    if match then
        matchName = match.entry.key or match.entry.label or match.entry.pinLabel or match.pin.label or "match"
    end

    local debugKey = string.format("%s:%s:%s:%s:%s:%s:%s",
        tostring(pinType),
        tostring(zoneId),
        tostring(poiIndex),
        tostring(poiPinType),
        tostring(poiState),
        matchName,
        tostring(challengeIcon))

    if self.pinDebugCache[debugKey] then
        return
    end
    self.pinDebugCache[debugKey] = true

    self:Print(string.format("pin type=%s(%s) zoneId=%s poi=%s mapType=%s(%s) state=%s orig=%s mapIcon=%s match=%s icon=%s",
        GetPinTypeName(pinType),
        tostring(pinType),
        tostring(zoneId),
        tostring(poiIndex),
        GetPinTypeName(poiPinType),
        tostring(poiPinType),
        tostring(poiState),
        tostring(originalIcon),
        tostring(mapIcon),
        matchName,
        tostring(challengeIcon)))
end

function TTMP:RefreshNativePins()
    if not self.initialized then
        return
    end

    ZO_WorldMap_RefreshAllPOIs()
    ZO_WorldMap_RefreshWayshrines()
end

local function GetNativePinTexture(originalTexture, pin)
    if type(originalTexture) == "function" then
        return originalTexture(pin)
    elseif type(originalTexture) == "string" then
        return originalTexture
    end

    return nil
end

function TTMP:HookNativePinTexture(pinType)
    local pinData = ZO_MapPin.PIN_DATA[pinType]
    if not pinData or self.nativePinTextureCallbacks[pinType] then
        return false
    end

    local originalTexture = pinData.texture
    self.nativePinTextureCallbacks[pinType] = originalTexture

    pinData.texture = function(pin)
        local originalIcon, pulseTexture, glowTexture = GetNativePinTexture(originalTexture, pin)
        local match, poiState = TTMP:GetMatchForNativePin(pin, originalIcon)
        local challengeIcon
        if match then
            challengeIcon = TTMP:GetChallengeIcon(match.entry, match.pin, originalIcon, poiState)
            if challengeIcon then
                TTMP:DebugNativePin(pin, originalIcon, match, poiState, challengeIcon)
                return challengeIcon
            end
        end

        TTMP:DebugNativePin(pin, originalIcon, match, poiState, challengeIcon)
        return originalIcon, pulseTexture, glowTexture
    end

    return true
end

function TTMP:RegisterNativeTextureHooks()
    if self.nativeTextureHooksRegistered then
        return
    end

    self.nativeTextureHooksRegistered = true
    self:HookNativePinTexture(MAP_PIN_TYPE_POI_SUGGESTED)
    self:HookNativePinTexture(MAP_PIN_TYPE_POI_SEEN)
    self:HookNativePinTexture(MAP_PIN_TYPE_POI_COMPLETE)
    self:HookNativePinTexture(MAP_PIN_TYPE_WORLD_EVENT_POI_ACTIVE)
    self:HookNativePinTexture(MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE)
    self:HookNativePinTexture(MAP_PIN_TYPE_FAST_TRAVEL_WAYSHRINE_CURRENT_LOC)
end

function TTMP:CreatePinForMatch(match, pin, x, y, poiIcon, poiState)
    local entry = match.entry
    local pinTag = {
        id = string.format("%s:%s:%s", entry.key or "challenge", pin.zoneId or 0, pin.poiIndex or 0),
        label = pin.label or entry.label,
        icon = self:GetChallengeIcon(entry, pin, poiIcon, poiState),
        activityName = match.activityName,
        activityDescription = match.activityDescription,
    }

    self.lmp:CreatePin(self.pinType, pinTag, x, y)
end

function TTMP:AddManualPinForMatch(match, pin, zoneIndex, seen)
    if not pin.poiIndex then
        return 0
    end

    local key = GetChallengeLookupKey(pin.zoneId, pin.poiIndex)
    if seen[key] then
        return 0
    end
    seen[key] = true

    local x, y, poiIcon, poiPinType, isShownInCurrentMap, isDiscovered = self:GetPOICoordinates(zoneIndex, pin.poiIndex, true)
    local poiState = GetPOIStateFromMapInfo(poiPinType, isShownInCurrentMap, isDiscovered)
    if x and y and poiState == "undiscovered" then
        self:CreatePinForMatch(match, pin, x, y, poiIcon, poiState)
        return 1
    end

    return 0
end

function TTMP:AddGlobalPinForMatch(match, pin, zoneIndex, seen)
    if not pin.zoneId or not pin.poiIndex then
        return 0
    end

    local key = GetChallengeLookupKey(pin.zoneId, pin.poiIndex)
    if seen[key] then
        return 0
    end
    seen[key] = true

    local x, y, poiIcon, poiPinType, isShownInCurrentMap, isDiscovered = self:GetPOICoordinates(zoneIndex, pin.poiIndex, true)
    local globalX, globalY, fastTravelIcon = self:GetFastTravelCoordinatesForPOI(zoneIndex, pin.poiIndex)
    if not globalX then
        globalX, globalY = self:GetZoneStoryCoordinatesForPOI(pin.zoneId, zoneIndex, pin.poiIndex)
    end
    if not globalX then
        globalX, globalY = self:GetGlobalMapCoordinates(pin.zoneId, x, y)
    end

    if globalX and globalY then
        local poiState = GetPOIStateFromMapInfo(poiPinType, isShownInCurrentMap, isDiscovered)
        self:CreatePinForMatch(match, pin, globalX, globalY, fastTravelIcon or poiIcon, poiState)
        return 1
    end

    return 0
end

function TTMP:AddGlobalPins()
    if not self.activeChallengeLookupBuilt then
        self:RebuildActiveChallengeLookup()
    end

    local seen = {}
    local created = 0

    for zoneId, pinMatches in pairs(self.activeMatchesByZoneId) do
        local zoneIndex = self:GetZoneIndexByZoneId(zoneId)
        if zoneIndex then
            for _, pinMatch in ipairs(pinMatches) do
                created = created + self:AddGlobalPinForMatch(pinMatch.match, pinMatch.pin, zoneIndex, seen)
            end
        end
    end

    self:Debug(string.format("Created %d global challenge pin(s).", created), true)
end

function TTMP:AddPins()
    if not self:IsPinFilterEnabled() then
        return
    end

    if GLOBAL_MAP_TYPES[GetMapType()] then
        self:AddGlobalPins()
        return
    end

    local zoneIndex = GetCurrentMapZoneIndex()
    local zoneId = zoneIndex and GetZoneId(zoneIndex)
    if not zoneId or zoneId == 0 then
        return
    end

    if not self.activeChallengeLookupBuilt then
        self:RebuildActiveChallengeLookup()
    end

    local seen = {}
    local created = 0

    for _, pinMatch in ipairs(self:GetActiveChallengeMatchesForZone(zoneId)) do
        created = created + self:AddManualPinForMatch(pinMatch.match, pinMatch.pin, zoneIndex, seen)
    end

    if self.activeDynamicMatchCount > 0 then
        for poiIndex = 1, GetNumPOIs(zoneIndex) do
            local key = GetChallengeLookupKey(zoneId, poiIndex)
            if not seen[key] then
                local x, y, poiIcon, poiPinType, isShownInCurrentMap, isDiscovered = self:GetPOICoordinates(zoneIndex, poiIndex, true)
                local poiState = GetPOIStateFromMapInfo(poiPinType, isShownInCurrentMap, isDiscovered)
                if x and y and poiState == "undiscovered" then
                    local pinMatch = self:GetDynamicMatchForPOI(zoneIndex, poiIndex, poiIcon)
                    if pinMatch then
                        self:CreatePinForMatch(pinMatch.match, pinMatch.pin, x, y, poiIcon, poiState)
                        created = created + 1
                    end
                end
            end
        end
    end

    self:Debug(string.format("Created %d undiscovered challenge pin(s) for zoneId %s.", created, tostring(zoneId)), true)
end

function TTMP:CreateTooltip(pin)
    local _, pinTag = pin:GetPinTypeAndTag()
    if type(pinTag) ~= "table" then
        return
    end

    InformationTooltip:AddLine(pinTag.label or "Tome Challenge")

    if pinTag.activityName and pinTag.activityName ~= "" then
        InformationTooltip:AddLine(pinTag.activityName)
    end

    if pinTag.activityDescription and pinTag.activityDescription ~= "" then
        InformationTooltip:AddLine(pinTag.activityDescription)
    end
end

function TTMP:SetWaypointFromPin(pin)
    local x, y = pin:GetNormalizedPosition()
    if x and y then
        PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, x, y)
    end
end

function TTMP:CreateCompassPinTag(match, pin, poiIcon, poiState)
    local entry = match.entry
    local icon = self:GetChallengeIcon(entry, pin, poiIcon, poiState)
    return {
        label = pin.label or entry.label,
        compassIcon = self:GetCompassTexturePath(icon),
    }
end

function TTMP:GetCompassZoneMatches(zoneIndex, zoneId)
    if self.activeCompassZoneIndex == zoneIndex and self.activeCompassZoneId == zoneId and self.activeCompassZoneMatches then
        return self.activeCompassZoneMatches
    end

    local zoneMatches = {}
    local seen = {}

    local function AddCompassZoneMatch(pinMatch, x, y, poiIcon, poiState)
        local pinTag = self:CreateCompassPinTag(pinMatch.match, pinMatch.pin, poiIcon, poiState)
        zoneMatches[#zoneMatches + 1] = {
            pinTag = pinTag,
            x = x,
            y = y,
        }
    end

    for _, pinMatch in ipairs(self:GetActiveChallengeMatchesForZone(zoneId)) do
        local x, y, poiIcon, poiPinType, isShownInCurrentMap, isDiscovered = self:GetPOICoordinates(zoneIndex, pinMatch.pin.poiIndex)
        if x and y then
            AddCompassZoneMatch(pinMatch, x, y, poiIcon, GetPOIStateFromMapInfo(poiPinType, isShownInCurrentMap, isDiscovered))
        end
        seen[GetChallengeLookupKey(pinMatch.pin.zoneId, pinMatch.pin.poiIndex)] = true
    end

    if self.activeDynamicMatchCount > 0 then
        for poiIndex = 1, GetNumPOIs(zoneIndex) do
            local key = GetChallengeLookupKey(zoneId, poiIndex)
            if not seen[key] then
                local x, y, poiIcon, poiPinType, isShownInCurrentMap, isDiscovered = self:GetPOICoordinates(zoneIndex, poiIndex)
                if x and y then
                    local pinMatch = self:GetDynamicMatchForPOI(zoneIndex, poiIndex, poiIcon)
                    if pinMatch then
                        seen[key] = true
                        AddCompassZoneMatch(pinMatch, x, y, poiIcon, GetPOIStateFromMapInfo(poiPinType, isShownInCurrentMap, isDiscovered))
                    end
                end
            end
        end
    end

    self.activeCompassZoneIndex = zoneIndex
    self.activeCompassZoneId = zoneId
    self.activeCompassZoneMatches = zoneMatches
    return zoneMatches
end

function TTMP:AddCompassPinsForType(compassPinType, compassIcon)
    if not self.compassPins or not self:IsCompassPinFilterEnabled() then
        return
    end

    if GetMapType() > MAPTYPE_ZONE then
        return
    end

    local zoneIndex = GetCurrentMapZoneIndex()
    local zoneId = GetZoneId(zoneIndex)
    if not zoneId or zoneId == 0 then
        return
    end

    local zoneMatches = self:GetCompassZoneMatches(zoneIndex, zoneId)
    local created = 0

    for _, zoneMatch in ipairs(zoneMatches) do
        local pinTag = zoneMatch.pinTag
        if pinTag.compassIcon == compassIcon then
            self.compassPins:CreatePin(compassPinType, pinTag, zoneMatch.x, zoneMatch.y, pinTag.label)
            created = created + 1
        end
    end

    self:Debug(string.format("Created %d compass challenge pin(s) for zoneId %s.", created, tostring(zoneId)), true)
end

function TTMP:RefreshCompassPins()
    if self.compassPins and self.compassRegistered then
        for _, pinType in ipairs(self.compassRegisteredTypes) do
            self.compassPins:RefreshPins(pinType)
        end
    end
end

function TTMP:RegisterCompassPins()
    self.compassPins = COMPASS_PINS
    if not self.compassPins or not self.compassPins.AddCustomPin then
        self:Debug("CustomCompassPins is not loaded; compass pins are disabled.", true)
        return false
    end

    if self.compassRegistered then
        return true
    end

    if self.savedVars[self.compassPinType] == nil then
        self.savedVars[self.compassPinType] = self.savedVars.showPins ~= false
    end

    for _, iconType in ipairs(self.compassIconTypes) do
        local compassIcon = self:GetCompassTexturePath(iconType.icon)
        local compassPinType = self.compassPinType .. "_" .. iconType.suffix
        self.compassRegisteredTypes[#self.compassRegisteredTypes + 1] = compassPinType

        if self.savedVars[compassPinType] == nil then
            self.savedVars[compassPinType] = self.savedVars[self.compassPinType] ~= false
        end

        local compassLayout = {
            maxDistance = self.compassOverlayMaxDistance,
            texture = compassIcon,
            mapPinTypeString = self.pinType,
            onToggleCallback = function(pinTypeString, enabled)
                TTMP:SetAllCompassPinTypesEnabled(enabled)
                TTMP:RefreshCompassPins()
            end,
            additionalLayout = {
                update = function(compassPin)
                    local background = compassPin:GetNamedChild("Background")
                    if background then
                        background:SetTexture(compassIcon)
                        background:SetDrawLevel(TTMP.compassOverlayDrawLevel)
                    end
                    compassPin:SetDrawLayer(DL_OVERLAY)
                    compassPin:SetDrawLevel(TTMP.compassOverlayDrawLevel)
                end,
                reset = function(compassPin)
                    local background = compassPin:GetNamedChild("Background")
                    if background then
                        background:SetTexture(compassIcon)
                        background:SetColor(1, 1, 1, 1)
                    end
                end,
            },
        }

        self.compassPins:AddCustomPin(compassPinType, function()
            TTMP:AddCompassPinsForType(compassPinType, compassIcon)
        end, compassLayout, self.savedVars)
    end

    self.compassRegistered = true
    return true
end

function TTMP:ResetActiveChallengeCache()
    self.activeChallengePins = {}
    self.activeMatchesByZoneId = {}
    self.activeDynamicMatchesByType = {}
    self.activeDynamicMatchCount = 0
    self.activeCompassZoneIndex = nil
    self.activeCompassZoneId = nil
    self.activeCompassZoneMatches = nil
    self.activeChallengeLookupBuilt = false
end

function TTMP:RegisterChallengeData(data)
    for _, entry in ipairs(data) do
        entry.normalizedMatch = {}
        for _, term in ipairs(entry.match) do
            local normalizedTerm = Normalize(term)
            if normalizedTerm ~= "" then
                entry.normalizedMatch[#entry.normalizedMatch + 1] = normalizedTerm
            end
        end
        self.challengeData[#self.challengeData + 1] = entry
    end
    self:ResetActiveChallengeCache()
end

function TTMP:Print(message)
    CHAT_SYSTEM:AddMessage(string.format("|cFFD700[Tamriel Tomes Pins]|r %s", message))
end

function TTMP:Debug(message, verbose)
    if not self.savedVars or not self.savedVars.debug then
        return
    end

    if verbose and not self.savedVars.verboseDebug then
        return
    end

    self:Print(message)
end

function TTMP:EntryMatchesActivityId(entry, activityId)
    if not activityId or not entry.activityIds then
        return false
    end

    for _, expectedId in ipairs(entry.activityIds) do
        if expectedId == activityId then
            return true
        end
    end

    return false
end

function TTMP:EntryMatchesText(entry, activityText)
    for _, normalizedTerm in ipairs(entry.normalizedMatch) do
        if string.find(activityText, normalizedTerm, 1, true) then
            return true
        end
    end

    return false
end

function TTMP:IsActivityIncomplete(index)
    local claimed = GetTimedActivityNumTimesClaimed(index) or 0
    local claimable = GetTimedActivityTotalNumTimesClaimable(index) or 0

    return claimable == 0 or claimed < claimable
end

function TTMP:GetActiveChallengeEntries()
    local matches = {}

    if not IsTimedActivitySystemAvailable() then
        return matches
    end

    local numActivities = GetNumTimedActivities()
    for index = 1, numActivities do
        if self:IsActivityIncomplete(index) then
            local activityId = GetTimedActivityId(index)
            local activityName = GetTimedActivityName(index) or ""
            local activityDescription = GetTimedActivityDescription(index) or ""
            local activityText

            for _, entry in ipairs(self.challengeData) do
                local matched = self:EntryMatchesActivityId(entry, activityId)
                if not matched then
                    if not activityText then
                        activityText = Normalize(activityName) .. " " .. Normalize(activityDescription)
                    end
                    matched = self:EntryMatchesText(entry, activityText)
                end

                if matched then
                    matches[#matches + 1] = {
                        entry = entry,
                        activityId = activityId,
                        activityName = activityName,
                        activityDescription = activityDescription,
                    }
                end
            end
        end
    end

    return matches
end

function TTMP:GetPOICoordinates(zoneIndex, poiIndex, includeHidden)
    if not zoneIndex or not poiIndex then
        return nil, nil
    end

    local normalizedX, normalizedY, poiPinType, icon, isShownInCurrentMap, _, isDiscovered = GetPOIMapInfo(zoneIndex, poiIndex)
    if not includeHidden and isShownInCurrentMap == false then
        return nil, nil
    end

    if not normalizedX or not normalizedY or normalizedX <= 0 or normalizedY <= 0 then
        return nil, nil
    end

    return normalizedX, normalizedY, icon, poiPinType, isShownInCurrentMap, isDiscovered
end

function TTMP:RefreshPins()
    if not self.initialized then
        return
    end

    self:RebuildActiveChallengeLookup()
    self.activeCompassZoneIndex = nil
    self.activeCompassZoneId = nil
    self.activeCompassZoneMatches = nil
    self:ClearPinDebugCache()
    self:RefreshNativePins()

    self.lmp:RefreshPins(self.pinType)

    self:RefreshCompassPins()
end

function TTMP:QueueRefreshPins(delayMs)
    if self.refreshQueued then
        return
    end

    self.refreshQueued = true
    local refresh = function()
        TTMP.refreshQueued = false
        TTMP:RefreshPins()
    end

    zo_callLater(refresh, delayMs or 100)
end

function TTMP:RegisterPins()
    self.lmp = LibMapPins

    local tooltipCreator = {
        creator = function(pin)
            TTMP:CreateTooltip(pin)
        end,
        tooltip = ZO_MAP_TOOLTIP_MODE.INFORMATION,
    }

    local leftClickHandler = {
        {
            name = "Set Waypoint",
            callback = function(pin)
                TTMP:SetWaypointFromPin(pin)
            end,
        },
    }

    self.pinTypeId = self.lmp:AddPinType(self.pinType, function()
        TTMP:AddPins()
    end, nil, self.pinLayoutData, tooltipCreator)

    self.lmp:SetClickHandlers(self.pinTypeId, leftClickHandler, nil)
    self.lmp:AddPinFilter(self.pinTypeId, "Tome Challenge Pins", false, self.savedVars, "showPins")

    return true
end

function TTMP:RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(self.addonName, EVENT_TIMED_ACTIVITIES_UPDATED, function()
        TTMP:QueueRefreshPins()
    end)

    EVENT_MANAGER:RegisterForEvent(self.addonName, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, function()
        TTMP:QueueRefreshPins()
    end)

    EVENT_MANAGER:RegisterForEvent(self.addonName, EVENT_TIMED_ACTIVITY_TRACKING_UPDATED, function()
        TTMP:QueueRefreshPins()
    end)

    EVENT_MANAGER:RegisterForEvent(self.addonName, EVENT_TIMED_ACTIVITY_SYSTEM_STATUS_UPDATED, function()
        TTMP:QueueRefreshPins()
    end)

    EVENT_MANAGER:RegisterForEvent(self.addonName, EVENT_PLAYER_ACTIVATED, function()
        TTMP:QueueRefreshPins()
    end)

    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", function()
        TTMP:QueueRefreshPins()
    end)
end

function TTMP:DumpActivities()
    if not IsTimedActivitySystemAvailable() then
        self:Print("The Timed Activity system is not available right now.")
        return
    end

    local numActivities = GetNumTimedActivities()
    if numActivities == 0 then
        self:Print("No active Tome Challenges found.")
        return
    end

    for index = 1, numActivities do
        local activityId = GetTimedActivityId(index)
        local encodedId = GetTimedActivityEncodedId(index)
        local name = GetTimedActivityName(index) or ""
        local description = GetTimedActivityDescription(index) or ""
        local progress = GetTimedActivityProgress(index) or 0
        local maxProgress = GetTimedActivityMaxProgress(index) or 0
        self:Print(string.format("[%d] id=%s encoded=%s progress=%d/%d name=%s desc=%s", index, tostring(activityId), tostring(encodedId), progress, maxProgress, name, description))
    end
end

function TTMP:PrintStatus()
    local matches = self:GetActiveChallengeEntries()
    self:Print(string.format("%d active challenge match(es). Commands: /ttpins refresh, /ttpins dump, /ttpins debug, /ttpins verbose, /ttpins pindebug.", #matches))
end

function TTMP:HandleSlash(rawText)
    local command = string.lower(Trim(rawText))

    if command == "refresh" then
        self:RefreshPins()
        self:Print("Pins refreshed.")
    elseif command == "dump" then
        self:DumpActivities()
    elseif command == "debug" then
        self.savedVars.debug = not self.savedVars.debug
        self:Print(string.format("Debug is now %s.", self.savedVars.debug and "on" or "off"))
    elseif command == "verbose" then
        self.savedVars.verboseDebug = not self.savedVars.verboseDebug
        self:Print(string.format("Verbose debug is now %s.", self.savedVars.verboseDebug and "on" or "off"))
    elseif command == "pindebug" or command == "pindebug on" then
        self.savedVars.pinDebug = command == "pindebug on" or not self.savedVars.pinDebug
        self:ClearPinDebugCache()
        self:RefreshPins()
        self:Print(string.format("Pin debug is now %s.", self.savedVars.pinDebug and "on" or "off"))
    elseif command == "pindebug off" then
        self.savedVars.pinDebug = false
        self:ClearPinDebugCache()
        self:RefreshPins()
        self:Print("Pin debug is now off.")
    else
        self:PrintStatus()
    end
end

function TTMP:Initialize()
    self.savedVars = ZO_SavedVars:NewAccountWide(self.savedVarsName, self.savedVarsVersion, GetWorldName(), self.defaults)
    self:RegisterNativeTextureHooks()

    self:RegisterPins()
    self:RegisterCompassPins()

    SLASH_COMMANDS["/ttpins"] = function(rawText)
        TTMP:HandleSlash(rawText)
    end

    self:RegisterEvents()
    self.initialized = true

    zo_callLater(function()
        TTMP:RefreshPins()
    end, 1000)
end

function TTMP.OnAddOnLoaded(eventCode, addonName)
    if addonName ~= TTMP.addonName then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(TTMP.addonName, EVENT_ADD_ON_LOADED)
    TTMP:Initialize()
end

EVENT_MANAGER:RegisterForEvent(TTMP.addonName, EVENT_ADD_ON_LOADED, TTMP.OnAddOnLoaded)
