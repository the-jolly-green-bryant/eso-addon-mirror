local Addon = {}
local ADDON_NAME = "AOD"
local ADDON_DISPLAY_NAME = "Automatic Overland Difficulty"
local LAM_PANEL_NAME = "AutomaticOverlandDifficulty_LAM"
local ADDON_AUTHOR = "|cFFFF00Wrynch|r"
local ADDON_VERSION = "1.1.0"
local EVENT_NAMESPACE = ADDON_NAME
local SAVED_VARS_NAME = "AODifficulty_SavedVariables"
local SAVED_VARS_VERSION = 1

local NO_CHANGE = -1
local SAME_AS_WORLD_EVENTS = -2

local SITUATION_DELVES = "delves"
local SITUATION_PUBLIC_DUNGEONS = "publicDungeons"
local SITUATION_OLD_GROUP_DUNGEONS = "groupDungeons"
local SITUATION_OPEN_WORLD = "openWorld"

local NEARBY_PIN_DRAGONS = "dragons"
local NEARBY_PIN_WORLD_BOSSES = "worldBosses"
local NEARBY_PIN_WORLD_EVENTS = "worldEvents"
local NEARBY_UPDATE_NAMESPACE = EVENT_NAMESPACE .. "_NearbyPins"
local NEARBY_UPDATE_INTERVAL_MS = 2000
local DIFFICULTY_RETRY_UPDATE_NAMESPACE = EVENT_NAMESPACE .. "_DifficultyRetry"
-- The local ESO docs expose the cooldown alert text, but not a remaining-time API.
local DIFFICULTY_REQUEST_COOLDOWN_MS = 6000
local DEFAULT_NEARBY_PIN_RADIUS_METERS = 120
local MIN_NEARBY_PIN_RADIUS_METERS = 25
local MAX_NEARBY_PIN_RADIUS_METERS = 300
local NEARBY_PIN_RADIUS_STEP_METERS = 5

local ANNOUNCEMENT_CHAT = "chat"
local ANNOUNCEMENT_TITLE = "title"
local ANNOUNCEMENT_TITLE_SOUND = "titleSound"
local CENTER_SCREEN_ANNOUNCEMENT_LIFESPAN_MS = 3500

local NEARBY_PIN_SETTINGS =
{
    {
        key = NEARBY_PIN_WORLD_BOSSES,
        name = "World Bosses",
        zoneCompletionType = ZONE_COMPLETION_TYPE_GROUP_BOSSES,
    },
    {
        key = NEARBY_PIN_WORLD_EVENTS,
        name = "World Events",
        zoneCompletionType = ZONE_COMPLETION_TYPE_WORLD_EVENTS,
    },
    {
        key = NEARBY_PIN_DRAGONS,
        name = "Dragons",
    },
}

local SETTINGS_DEFAULTS =
{
    enabled = true,
    situations =
    {
        [SITUATION_DELVES] = NO_CHANGE,
        [SITUATION_PUBLIC_DUNGEONS] = NO_CHANGE,
        [SITUATION_OPEN_WORLD] = NO_CHANGE,
    },
    regions =
    {
        ["*"] = NO_CHANGE,
    },
    nearbyPins =
    {
        [NEARBY_PIN_DRAGONS] = SAME_AS_WORLD_EVENTS,
        [NEARBY_PIN_WORLD_BOSSES] = NO_CHANGE,
        [NEARBY_PIN_WORLD_EVENTS] = NO_CHANGE,
    },
    nearbyPinRadiusMeters = DEFAULT_NEARBY_PIN_RADIUS_METERS,
    announcements =
    {
        [ANNOUNCEMENT_CHAT] = false,
        [ANNOUNCEMENT_TITLE] = false,
        [ANNOUNCEMENT_TITLE_SOUND] = true,
    },
    migrations =
    {
        publicDungeonsFromGroupDungeons = false,
    },
}

local SCOPE_DEFAULTS =
{
    accountBoundSettings = true,
}

local SITUATION_BY_ZONE_DISPLAY_TYPE =
{
    [ZONE_DISPLAY_TYPE_DELVE] = SITUATION_DELVES,
    [ZONE_DISPLAY_TYPE_GROUP_DELVE] = SITUATION_DELVES,
    [ZONE_DISPLAY_TYPE_PUBLIC_DUNGEON] = SITUATION_PUBLIC_DUNGEONS,
    [ZONE_DISPLAY_TYPE_NONE] = SITUATION_OPEN_WORLD,
}

local VALID_DIFFICULTIES =
{
    [OVERLAND_DIFFICULTY_TYPE_BASEGAME] = true,
    [OVERLAND_DIFFICULTY_TYPE_JOURNEYMAN] = true,
    [OVERLAND_DIFFICULTY_TYPE_ADVENTURER] = true,
    [OVERLAND_DIFFICULTY_TYPE_VETERAN] = true,
}

local function IsValidDifficulty(value)
    return value == NO_CHANGE or VALID_DIFFICULTIES[value] == true
end

local function NormalizeDifficulty(value)
    if IsValidDifficulty(value) then
        return value
    end
    return NO_CHANGE
end

local function NormalizeNearbyPinDifficulty(nearbyPin, value)
    if nearbyPin == NEARBY_PIN_DRAGONS then
        if VALID_DIFFICULTIES[value] then
            return value
        end
        return SAME_AS_WORLD_EVENTS
    end

    return NormalizeDifficulty(value)
end

local function NormalizeNearbyPinRadiusMeters(value)
    local radiusMeters = tonumber(value)
    if not radiusMeters then
        return DEFAULT_NEARBY_PIN_RADIUS_METERS
    end

    if radiusMeters < MIN_NEARBY_PIN_RADIUS_METERS then
        radiusMeters = MIN_NEARBY_PIN_RADIUS_METERS
    elseif radiusMeters > MAX_NEARBY_PIN_RADIUS_METERS then
        radiusMeters = MAX_NEARBY_PIN_RADIUS_METERS
    end

    return math.floor((radiusMeters / NEARBY_PIN_RADIUS_STEP_METERS) + 0.5) * NEARBY_PIN_RADIUS_STEP_METERS
end

local function BuildDifficultyChoices()
    local choices =
    {
        "Do not change",
        GetString("SI_OVERLANDDIFFICULTYTYPE", OVERLAND_DIFFICULTY_TYPE_BASEGAME),
        GetString("SI_OVERLANDDIFFICULTYTYPE", OVERLAND_DIFFICULTY_TYPE_JOURNEYMAN),
        GetString("SI_OVERLANDDIFFICULTYTYPE", OVERLAND_DIFFICULTY_TYPE_ADVENTURER),
        GetString("SI_OVERLANDDIFFICULTYTYPE", OVERLAND_DIFFICULTY_TYPE_VETERAN),
    }

    local values =
    {
        NO_CHANGE,
        OVERLAND_DIFFICULTY_TYPE_BASEGAME,
        OVERLAND_DIFFICULTY_TYPE_JOURNEYMAN,
        OVERLAND_DIFFICULTY_TYPE_ADVENTURER,
        OVERLAND_DIFFICULTY_TYPE_VETERAN,
    }

    return choices, values
end

local function BuildDragonDifficultyChoices()
    local choices =
    {
        "Same as World Events",
        GetString("SI_OVERLANDDIFFICULTYTYPE", OVERLAND_DIFFICULTY_TYPE_BASEGAME),
        GetString("SI_OVERLANDDIFFICULTYTYPE", OVERLAND_DIFFICULTY_TYPE_JOURNEYMAN),
        GetString("SI_OVERLANDDIFFICULTYTYPE", OVERLAND_DIFFICULTY_TYPE_ADVENTURER),
        GetString("SI_OVERLANDDIFFICULTYTYPE", OVERLAND_DIFFICULTY_TYPE_VETERAN),
    }

    local values =
    {
        SAME_AS_WORLD_EVENTS,
        OVERLAND_DIFFICULTY_TYPE_BASEGAME,
        OVERLAND_DIFFICULTY_TYPE_JOURNEYMAN,
        OVERLAND_DIFFICULTY_TYPE_ADVENTURER,
        OVERLAND_DIFFICULTY_TYPE_VETERAN,
    }

    return choices, values
end

local function GetProfileName()
    return GetWorldName()
end

local function GetDifficultyName(difficulty)
    return GetString("SI_OVERLANDDIFFICULTYTYPE", difficulty)
end

function Addon.GetSituationSettings(situation)
    local savedVars = Addon.savedVars
    if not savedVars or not savedVars.situations then
        return NO_CHANGE
    end
    return NormalizeDifficulty(savedVars.situations[situation])
end

function Addon.SetSituationSettings(situation, difficulty)
    difficulty = NormalizeDifficulty(difficulty)
    if Addon.savedVars.situations[situation] ~= difficulty then
        Addon.savedVars.situations[situation] = difficulty
    end
    Addon.ApplyCurrentSituation()
end

function Addon.GetRegionSettings(regionId)
    local savedVars = Addon.savedVars
    if not savedVars or regionId == nil or type(savedVars.regions) ~= "table" then
        return NO_CHANGE
    end
    return NormalizeDifficulty(savedVars.regions[regionId])
end

function Addon.SetRegionSettings(regionId, difficulty)
    if regionId == nil then
        return
    end

    difficulty = NormalizeDifficulty(difficulty)
    if type(Addon.savedVars.regions) ~= "table" then
        Addon.savedVars.regions = {}
    end

    if difficulty == NO_CHANGE then
        if rawget(Addon.savedVars.regions, regionId) ~= nil then
            Addon.savedVars.regions[regionId] = nil
        end
    elseif Addon.savedVars.regions[regionId] ~= difficulty then
        Addon.savedVars.regions[regionId] = difficulty
    end

    Addon.ApplyCurrentSituation()
end

function Addon.ResetRegionSettings()
    if type(Addon.savedVars.regions) ~= "table" then
        Addon.savedVars.regions = {}
    else
        for regionId in pairs(Addon.savedVars.regions) do
            Addon.savedVars.regions[regionId] = nil
        end
    end

    Addon.ApplyCurrentSituation()
end

function Addon.GetNearbyPinSettings(nearbyPin)
    local savedVars = Addon.savedVars
    if not savedVars or type(savedVars.nearbyPins) ~= "table" then
        if nearbyPin == NEARBY_PIN_DRAGONS then
            return SAME_AS_WORLD_EVENTS
        end
        return NO_CHANGE
    end

    local value = savedVars.nearbyPins[nearbyPin]
    if nearbyPin == NEARBY_PIN_DRAGONS and value == nil then
        return SAME_AS_WORLD_EVENTS
    end

    return NormalizeNearbyPinDifficulty(nearbyPin, value)
end

function Addon.SetNearbyPinSettings(nearbyPin, difficulty)
    difficulty = NormalizeNearbyPinDifficulty(nearbyPin, difficulty)
    if type(Addon.savedVars.nearbyPins) ~= "table" then
        Addon.savedVars.nearbyPins = {}
    end

    if difficulty == NO_CHANGE and nearbyPin ~= NEARBY_PIN_DRAGONS then
        if rawget(Addon.savedVars.nearbyPins, nearbyPin) ~= nil then
            Addon.savedVars.nearbyPins[nearbyPin] = nil
        end
    elseif Addon.savedVars.nearbyPins[nearbyPin] ~= difficulty then
        Addon.savedVars.nearbyPins[nearbyPin] = difficulty
    end

    Addon.RefreshNearbyUpdateRegistration()
    Addon.ApplyCurrentSituation()
end

function Addon.GetEffectiveDragonSettings()
    local dragonDifficulty = Addon.GetNearbyPinSettings(NEARBY_PIN_DRAGONS)
    if dragonDifficulty == SAME_AS_WORLD_EVENTS then
        return Addon.GetNearbyPinSettings(NEARBY_PIN_WORLD_EVENTS)
    end
    return dragonDifficulty
end

function Addon.HasNearbyPinSettings()
    if not Addon.savedVars or type(Addon.savedVars.nearbyPins) ~= "table" then
        return false
    end

    for index = 1, #NEARBY_PIN_SETTINGS do
        local nearbyPin = NEARBY_PIN_SETTINGS[index].key
        if nearbyPin == NEARBY_PIN_DRAGONS then
            if Addon.GetEffectiveDragonSettings() ~= NO_CHANGE then
                return true
            end
        elseif Addon.GetNearbyPinSettings(nearbyPin) ~= NO_CHANGE then
            return true
        end
    end

    return false
end

function Addon.GetNearbyPinRadiusMeters()
    local savedVars = Addon.savedVars
    if not savedVars then
        return DEFAULT_NEARBY_PIN_RADIUS_METERS
    end
    return NormalizeNearbyPinRadiusMeters(savedVars.nearbyPinRadiusMeters)
end

function Addon.GetPlayerPositionForNearbyCheck()
    local gps = LibGPS3
    if not gps or not gps.GetCurrentMapMeasurement or not gps.GetLocalDistanceInMeters then
        return nil
    end

    if not DoesCurrentMapMatchMapForPlayerLocation() then
        return nil
    end

    if not gps:GetCurrentMapMeasurement() then
        return nil
    end

    local playerX, playerY, _, isPlayerShownInCurrentMap, isSymbolicLocation = GetMapPlayerPosition("player")
    if not playerX or not playerY or not isPlayerShownInCurrentMap or isSymbolicLocation then
        return nil
    end

    return gps, playerX, playerY
end

function Addon.SetNearbyPinRadiusMeters(radiusMeters)
    if not Addon.savedVars then
        return
    end

    radiusMeters = NormalizeNearbyPinRadiusMeters(radiusMeters)
    if Addon.savedVars.nearbyPinRadiusMeters ~= radiusMeters then
        Addon.savedVars.nearbyPinRadiusMeters = radiusMeters
    end
    Addon.ApplyCurrentSituation()
end

function Addon.GetAnnouncementSettings(announcementType)
    local savedVars = Addon.savedVars
    if not savedVars or type(savedVars.announcements) ~= "table" then
        return false
    end
    return savedVars.announcements[announcementType] == true
end

function Addon.SetAnnouncementSettings(announcementType, enabled)
    if type(Addon.savedVars.announcements) ~= "table" then
        Addon.savedVars.announcements = {}
    end

    Addon.savedVars.announcements[announcementType] = enabled == true
end

function Addon.GetPlayerRegionId()
    local zoneIndex = GetUnitZoneIndex("player")
    if not zoneIndex then
        return nil
    end

    local zoneId = GetZoneId(zoneIndex)
    local regionId = GetZoneStoryZoneIdForZoneId(zoneId)
    if regionId == 0 then
        return nil
    end

    return regionId
end

function Addon.IsCurrentPOIWithinRadius(zoneIndex, poiIndex)
    local gps, playerX, playerY = Addon.GetPlayerPositionForNearbyCheck()
    if not gps then
        return false
    end

    return Addon.IsPOIWithinRadius(zoneIndex, poiIndex, gps, playerX, playerY)
end

function Addon.IsPOIWithinRadius(zoneIndex, poiIndex, gps, playerX, playerY)
    local poiX, poiY, _, _, isPOIShownInCurrentMap = GetPOIMapInfo(zoneIndex, poiIndex)
    if not poiX or not poiY or not isPOIShownInCurrentMap then
        return false
    end

    return gps:GetLocalDistanceInMeters(playerX, playerY, poiX, poiY) <= Addon.GetNearbyPinRadiusMeters()
end

function Addon.IsCurrentWorldEventUnitWithinRadius(worldEventInstanceId, unitTag)
    local gps, playerX, playerY = Addon.GetPlayerPositionForNearbyCheck()
    if not gps then
        return false
    end

    local unitX, unitY, _, isUnitShownInCurrentMap, isSymbolicLocation = GetMapPlayerPosition(unitTag)
    if not unitX or not unitY or not isUnitShownInCurrentMap or isSymbolicLocation then
        return false
    end

    local pinType = GetWorldEventInstanceUnitPinType(worldEventInstanceId, unitTag)
    if pinType == MAP_PIN_TYPE_INVALID then
        return false
    end

    return gps:GetLocalDistanceInMeters(playerX, playerY, unitX, unitY) <= Addon.GetNearbyPinRadiusMeters()
end

function Addon.GetNearbyDragonDifficulty()
    local dragonDifficulty = Addon.GetEffectiveDragonSettings()
    if dragonDifficulty == NO_CHANGE and Addon.GetNearbyPinSettings(NEARBY_PIN_DRAGONS) == SAME_AS_WORLD_EVENTS then
        return nil
    end

    local worldEventInstanceId = GetNextWorldEventInstanceId(nil)
    while worldEventInstanceId do
        -- Verified in esoui/ingame/map/worldmap.lua: unit-context world events are currently dragons.
        if GetWorldEventLocationContext(worldEventInstanceId) == WORLD_EVENT_LOCATION_CONTEXT_UNIT then
            local numUnits = GetNumWorldEventInstanceUnits(worldEventInstanceId)
            for unitIndex = 1, numUnits do
                local unitTag = GetWorldEventInstanceUnitTag(worldEventInstanceId, unitIndex)
                if unitTag and Addon.IsCurrentWorldEventUnitWithinRadius(worldEventInstanceId, unitTag) then
                    return dragonDifficulty
                end
            end
        end

        worldEventInstanceId = GetNextWorldEventInstanceId(worldEventInstanceId)
    end

    return nil
end

function Addon.GetNearbyPinDifficulty()
    if not Addon.HasNearbyPinSettings() then
        return NO_CHANGE
    end

    local dragonDifficulty = Addon.GetNearbyDragonDifficulty()
    if dragonDifficulty ~= nil then
        return dragonDifficulty
    end

    local zoneIndex, poiIndex = GetCurrentSubZonePOIIndices()
    if not zoneIndex or not poiIndex then
        return Addon.GetNearbyMapPOIDifficulty()
    end

    local zoneCompletionType = GetPOIZoneCompletionType(zoneIndex, poiIndex)
    for settingsIndex = 1, #NEARBY_PIN_SETTINGS do
        local pinSettings = NEARBY_PIN_SETTINGS[settingsIndex]
        if pinSettings.zoneCompletionType and zoneCompletionType == pinSettings.zoneCompletionType and Addon.IsCurrentPOIWithinRadius(zoneIndex, poiIndex) then
            local difficulty = Addon.GetNearbyPinSettings(pinSettings.key)
            if difficulty ~= NO_CHANGE then
                return difficulty
            end
        end
    end

    return NO_CHANGE
end

function Addon.GetNearbyMapPOIDifficulty()
    local gps, playerX, playerY = Addon.GetPlayerPositionForNearbyCheck()
    if not gps then
        return NO_CHANGE
    end

    local zoneIndex = GetCurrentMapZoneIndex()
    if not zoneIndex then
        return NO_CHANGE
    end

    local numPOIs = GetNumPOIs(zoneIndex)
    for settingsIndex = 1, #NEARBY_PIN_SETTINGS do
        local pinSettings = NEARBY_PIN_SETTINGS[settingsIndex]
        local difficulty = Addon.GetNearbyPinSettings(pinSettings.key)
        if pinSettings.zoneCompletionType and difficulty ~= NO_CHANGE then
            for poiIndex = 1, numPOIs do
                if GetPOIZoneCompletionType(zoneIndex, poiIndex) == pinSettings.zoneCompletionType
                    and Addon.IsPOIWithinRadius(zoneIndex, poiIndex, gps, playerX, playerY) then
                    return difficulty
                end
            end
        end
    end

    return NO_CHANGE
end

function Addon.MigrateSavedVars()
    local savedVars = Addon.savedVars
    savedVars.situations = savedVars.situations or {}
    if type(savedVars.regions) ~= "table" then
        savedVars.regions = {}
    end
    if type(savedVars.nearbyPins) ~= "table" then
        savedVars.nearbyPins = {}
    end
    if type(savedVars.announcements) ~= "table" then
        savedVars.announcements = {}
    end
    savedVars.migrations = savedVars.migrations or {}
    savedVars.nearbyPinRadiusMeters = NormalizeNearbyPinRadiusMeters(savedVars.nearbyPinRadiusMeters)

    for regionId, difficulty in pairs(savedVars.regions) do
        if NormalizeDifficulty(difficulty) == NO_CHANGE then
            savedVars.regions[regionId] = nil
        end
    end

    for nearbyPin, difficulty in pairs(savedVars.nearbyPins) do
        if nearbyPin == NEARBY_PIN_DRAGONS then
            savedVars.nearbyPins[nearbyPin] = NormalizeNearbyPinDifficulty(nearbyPin, difficulty)
        elseif NormalizeDifficulty(difficulty) == NO_CHANGE then
            savedVars.nearbyPins[nearbyPin] = nil
        end
    end
    if rawget(savedVars.nearbyPins, NEARBY_PIN_DRAGONS) == nil then
        savedVars.nearbyPins[NEARBY_PIN_DRAGONS] = SETTINGS_DEFAULTS.nearbyPins[NEARBY_PIN_DRAGONS]
    end

    savedVars.announcements[ANNOUNCEMENT_CHAT] = savedVars.announcements[ANNOUNCEMENT_CHAT] == true
    savedVars.announcements[ANNOUNCEMENT_TITLE] = savedVars.announcements[ANNOUNCEMENT_TITLE] == true
    if savedVars.announcements[ANNOUNCEMENT_TITLE_SOUND] == nil then
        savedVars.announcements[ANNOUNCEMENT_TITLE_SOUND] = SETTINGS_DEFAULTS.announcements[ANNOUNCEMENT_TITLE_SOUND]
    else
        savedVars.announcements[ANNOUNCEMENT_TITLE_SOUND] = savedVars.announcements[ANNOUNCEMENT_TITLE_SOUND] == true
    end

    if savedVars.migrations.publicDungeonsFromGroupDungeons then
        return
    end

    local oldDifficulty = NormalizeDifficulty(savedVars.situations[SITUATION_OLD_GROUP_DUNGEONS])
    if oldDifficulty ~= NO_CHANGE and Addon.GetSituationSettings(SITUATION_PUBLIC_DUNGEONS) == NO_CHANGE then
        savedVars.situations[SITUATION_PUBLIC_DUNGEONS] = oldDifficulty
    end

    savedVars.migrations.publicDungeonsFromGroupDungeons = true
end

function Addon.GetCurrentSituation()
    return SITUATION_BY_ZONE_DISPLAY_TYPE[Addon.currentZoneDisplayType or ZONE_DISPLAY_TYPE_NONE]
end

function Addon.SetPendingZoneDisplayType(zoneDisplayType)
    Addon.pendingZoneDisplayType = zoneDisplayType
    Addon.hasPendingZoneDisplayType = true
end

function Addon.AnnounceDifficultyChanged(difficulty)
    if not VALID_DIFFICULTIES[difficulty] then
        return
    end

    local difficultyName = GetDifficultyName(difficulty)
    local message = string.format("%s: Difficulty changed to %s.", ADDON_DISPLAY_NAME, difficultyName)

    if Addon.GetAnnouncementSettings(ANNOUNCEMENT_CHAT) and CHAT_ROUTER then
        CHAT_ROUTER:AddSystemMessage(message)
    end

    if Addon.GetAnnouncementSettings(ANNOUNCEMENT_TITLE) and CENTER_SCREEN_ANNOUNCE then
        local titleSound = Addon.GetAnnouncementSettings(ANNOUNCEMENT_TITLE_SOUND) and SOUNDS.DISPLAY_ANNOUNCEMENT or nil
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, titleSound)
        messageParams:SetText("Difficulty Changed", difficultyName)
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
        messageParams:SetLifespanMS(CENTER_SCREEN_ANNOUNCEMENT_LIFESPAN_MS)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end
end

function Addon.UnregisterDifficultyRetry()
    if Addon.difficultyRetryRegistered then
        EVENT_MANAGER:UnregisterForUpdate(DIFFICULTY_RETRY_UPDATE_NAMESPACE)
        Addon.difficultyRetryRegistered = false
    end
end

function Addon.ClearDeferredDifficultyRequest()
    Addon.hasDeferredDifficultyRequest = false
    Addon.UnregisterDifficultyRetry()
end

function Addon.ScheduleDeferredDifficultyRequest(delayMs)
    Addon.hasDeferredDifficultyRequest = true
    Addon.UnregisterDifficultyRetry()

    EVENT_MANAGER:RegisterForUpdate(DIFFICULTY_RETRY_UPDATE_NAMESPACE, math.max(delayMs or 0, 1), function()
        Addon.difficultyRetryRegistered = false
        if not Addon.hasDeferredDifficultyRequest then
            return
        end

        Addon.hasDeferredDifficultyRequest = false
        Addon.ApplyCurrentSituation()
    end, true)
    Addon.difficultyRetryRegistered = true
end

function Addon.ApplyCurrentSituation()
    if not Addon.savedVars or not Addon.savedVars.enabled then
        Addon.ClearDeferredDifficultyRequest()
        return
    end

    local desiredDifficulty = Addon.GetNearbyPinDifficulty()
    if desiredDifficulty == NO_CHANGE then
        local situation = Addon.GetCurrentSituation()
        if not situation then
            Addon.ClearDeferredDifficultyRequest()
            return
        end

        if situation == SITUATION_OPEN_WORLD then
            desiredDifficulty = Addon.GetRegionSettings(Addon.GetPlayerRegionId())
        end

        if desiredDifficulty == NO_CHANGE then
            desiredDifficulty = Addon.GetSituationSettings(situation)
            if desiredDifficulty == NO_CHANGE then
                Addon.ClearDeferredDifficultyRequest()
                return
            end
        end
    end

    if GetOverlandDifficultyDisabledReason() ~= OVERLAND_DIFFICULTY_DISABLED_REASON_NONE then
        Addon.ClearDeferredDifficultyRequest()
        return
    end

    local currentDifficulty = GetOverlandDifficulty()
    if currentDifficulty ~= desiredDifficulty then
        if IsUnitInCombat("player") then
            Addon.hasDeferredDifficultyRequest = true
            Addon.UnregisterDifficultyRetry()
            Addon.lastRequestedDifficulty = nil
            return
        end

        local nowMs = GetFrameTimeMilliseconds()
        if Addon.nextDifficultyRequestTimeMS and nowMs < Addon.nextDifficultyRequestTimeMS then
            Addon.lastRequestedDifficulty = nil
            Addon.ScheduleDeferredDifficultyRequest(Addon.nextDifficultyRequestTimeMS - nowMs)
            return
        end

        Addon.ClearDeferredDifficultyRequest()
        Addon.lastRequestedDifficulty = desiredDifficulty
        Addon.nextDifficultyRequestTimeMS = nowMs + DIFFICULTY_REQUEST_COOLDOWN_MS
        RequestChangePlayerOverlandDifficulty(desiredDifficulty)
    else
        Addon.ClearDeferredDifficultyRequest()
        Addon.lastRequestedDifficulty = nil
    end
end

function Addon.OnPlayerActivated()
    if Addon.hasPendingZoneDisplayType then
        Addon.currentZoneDisplayType = Addon.pendingZoneDisplayType
        Addon.pendingZoneDisplayType = nil
        Addon.hasPendingZoneDisplayType = false
    end

    Addon.ApplyCurrentSituation()
end

function Addon.OnPrepareForJump(_, _, _, _, zoneDisplayType)
    Addon.SetPendingZoneDisplayType(zoneDisplayType)
end

function Addon.OnAreaLoadStarted(_, _, _, _, _, _, zoneDisplayType)
    Addon.SetPendingZoneDisplayType(zoneDisplayType)
end

function Addon.OnZoneChanged()
    Addon.ApplyCurrentSituation()
end

function Addon.OnPlayerCombatState(_, inCombat)
    if inCombat or not Addon.hasDeferredDifficultyRequest then
        return
    end

    Addon.hasDeferredDifficultyRequest = false
    Addon.ApplyCurrentSituation()
end

function Addon.OnOverlandDifficultyChanged(_, newDifficulty)
    local isAddonRequestedDifficulty = newDifficulty == Addon.lastRequestedDifficulty
    if isAddonRequestedDifficulty then
        Addon.lastRequestedDifficulty = nil
    end

    if VALID_DIFFICULTIES[newDifficulty] then
        Addon.nextDifficultyRequestTimeMS = GetFrameTimeMilliseconds() + DIFFICULTY_REQUEST_COOLDOWN_MS

        if newDifficulty ~= Addon.lastObservedDifficulty then
            Addon.lastObservedDifficulty = newDifficulty
            if GetOverlandDifficultyDisabledReason() == OVERLAND_DIFFICULTY_DISABLED_REASON_NONE
                and GetOverlandDifficulty() == newDifficulty then
                Addon.AnnounceDifficultyChanged(newDifficulty)
            end
        end
    end

    if not isAddonRequestedDifficulty then
        Addon.ApplyCurrentSituation()
    end
end

function Addon.CreateSituationDropdown(situation, name, choices, values)
    return
    {
        type = "dropdown",
        name = name,
        choices = choices,
        choicesValues = values,
        sort = "numericvalue-up",
        getFunc = function()
            return Addon.GetSituationSettings(situation)
        end,
        setFunc = function(value)
            Addon.SetSituationSettings(situation, value)
        end,
        default = SETTINGS_DEFAULTS.situations[situation],
        width = "full",
    }
end

function Addon.CreateNearbyPinDropdown(nearbyPinSettings, choices, values)
    return
    {
        type = "dropdown",
        name = nearbyPinSettings.name,
        choices = choices,
        choicesValues = values,
        sort = "numericvalue-up",
        getFunc = function()
            return Addon.GetNearbyPinSettings(nearbyPinSettings.key)
        end,
        setFunc = function(value)
            Addon.SetNearbyPinSettings(nearbyPinSettings.key, value)
        end,
        default = SETTINGS_DEFAULTS.nearbyPins[nearbyPinSettings.key],
        width = "full",
    }
end

function Addon.CreateNearbyPinRadiusSlider()
    return
    {
        type = "slider",
        name = "POI Radius",
        tooltip = "How close you must be to a world boss or world event map pin before this addon uses that pin's difficulty setting. Smaller numbers mean closer.",
        min = MIN_NEARBY_PIN_RADIUS_METERS,
        max = MAX_NEARBY_PIN_RADIUS_METERS,
        step = NEARBY_PIN_RADIUS_STEP_METERS,
        decimals = 0,
        getFunc = function()
            return Addon.GetNearbyPinRadiusMeters()
        end,
        setFunc = function(value)
            Addon.SetNearbyPinRadiusMeters(value)
        end,
        default = SETTINGS_DEFAULTS.nearbyPinRadiusMeters,
        width = "full",
    }
end

function Addon.CreateAnnouncementCheckbox(announcementType, name, disabled)
    return
    {
        type = "checkbox",
        name = name,
        disabled = disabled,
        getFunc = function()
            return Addon.GetAnnouncementSettings(announcementType)
        end,
        setFunc = function(value)
            Addon.SetAnnouncementSettings(announcementType, value)
        end,
        default = SETTINGS_DEFAULTS.announcements[announcementType],
        width = "full",
    }
end

function Addon.CreateResetRegionsButton()
    return
    {
        type = "button",
        name = "Reset Zones",
        func = function()
            Addon.ResetRegionSettings()
        end,
        isDangerous = true,
        warning = "Reset all zone difficulty settings to Do not change?",
        width = "full",
    }
end

function Addon.CreateRegionDropdown(regionId, regionName, choices, values)
    return
    {
        type = "dropdown",
        name = regionName,
        choices = choices,
        choicesValues = values,
        sort = "numericvalue-up",
        getFunc = function()
            return Addon.GetRegionSettings(regionId)
        end,
        setFunc = function(value)
            Addon.SetRegionSettings(regionId, value)
        end,
        default = NO_CHANGE,
        width = "full",
    }
end

function Addon.BuildRegionDropdownControls(choices, values)
    local regions = {}
    local regionId = GetNextZoneStoryZoneId(nil)

    while regionId do
        local regionName = GetZoneNameById(regionId)
        if regionName ~= nil and regionName ~= "" then
            regions[#regions + 1] =
            {
                id = regionId,
                name = ZO_CachedStrFormat(SI_ZONE_NAME, regionName),
            }
        end

        regionId = GetNextZoneStoryZoneId(regionId)
    end

    table.sort(regions, function(left, right)
        if left.name == right.name then
            return left.id < right.id
        end
        return left.name < right.name
    end)

    local controls =
    {
        Addon.CreateResetRegionsButton(),
    }

    for index = 1, #regions do
        local region = regions[index]
        controls[#controls + 1] = Addon.CreateRegionDropdown(region.id, region.name, choices, values)
    end

    return controls
end

function Addon.LoadActiveSettings()
    local profileName = GetProfileName()
    if Addon.scopeVars.accountBoundSettings ~= false then
        Addon.savedVars = ZO_SavedVars:NewAccountWide(SAVED_VARS_NAME, SAVED_VARS_VERSION, "Settings", SETTINGS_DEFAULTS, profileName)
    else
        Addon.savedVars = ZO_SavedVars:NewCharacterIdSettings(SAVED_VARS_NAME, SAVED_VARS_VERSION, "Settings", SETTINGS_DEFAULTS, profileName)
    end

    Addon.MigrateSavedVars()
    Addon.RefreshNearbyUpdateRegistration()
end

function Addon.LoadScopeSettings()
    local profileName = GetProfileName()
    Addon.scopeVars = ZO_SavedVars:NewCharacterIdSettings(SAVED_VARS_NAME, SAVED_VARS_VERSION, "Scope", nil, profileName)

    if Addon.scopeVars.accountBoundSettings == nil then
        -- This selector used to be account-wide. Copy the old value once when a character first gets its own scope.
        local legacyScopeVars = ZO_SavedVars:NewAccountWide(SAVED_VARS_NAME, SAVED_VARS_VERSION, "Scope", nil, profileName)
        if legacyScopeVars.accountBoundSettings ~= nil then
            Addon.scopeVars.accountBoundSettings = legacyScopeVars.accountBoundSettings ~= false
        end
    end

    Addon.scopeVars = ZO_SavedVars:NewCharacterIdSettings(SAVED_VARS_NAME, SAVED_VARS_VERSION, "Scope", SCOPE_DEFAULTS, profileName)
end

function Addon.RegisterSettings()
    local LAM = LibAddonMenu2

    local choices, values = BuildDifficultyChoices()
    local dragonChoices, dragonValues = BuildDragonDifficultyChoices()

    local panelData =
    {
        type = "panel",
        name = ADDON_DISPLAY_NAME,
        displayName = ADDON_DISPLAY_NAME,
        author = ADDON_AUTHOR,
        version = ADDON_VERSION,
        slashCommand = "/aodifficulty",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsTable =
    {
        {
            type = "checkbox",
            name = "Enabled",
            getFunc = function()
                return Addon.savedVars.enabled
            end,
            setFunc = function(value)
                if Addon.savedVars.enabled ~= value then
                    Addon.savedVars.enabled = value
                end
                Addon.RefreshNearbyUpdateRegistration()
                Addon.ApplyCurrentSituation()
            end,
            default = SETTINGS_DEFAULTS.enabled,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Account Bound Settings",
            getFunc = function()
                return Addon.scopeVars.accountBoundSettings ~= false
            end,
            setFunc = function(value)
                Addon.scopeVars.accountBoundSettings = value
                Addon.LoadActiveSettings()
                Addon.ApplyCurrentSituation()
            end,
            default = SCOPE_DEFAULTS.accountBoundSettings,
            width = "full",
        },
        {
            type = "header",
            name = "Situations",
            width = "full",
        },
        Addon.CreateSituationDropdown(
            SITUATION_DELVES,
            "Delves",
            choices,
            values
        ),
        Addon.CreateSituationDropdown(
            SITUATION_PUBLIC_DUNGEONS,
            "Public Dungeons",
            choices,
            values
        ),
        Addon.CreateSituationDropdown(
            SITUATION_OPEN_WORLD,
            "Open World",
            choices,
            values
        ),
        Addon.CreateNearbyPinDropdown(NEARBY_PIN_SETTINGS[1], choices, values),
        Addon.CreateNearbyPinDropdown(NEARBY_PIN_SETTINGS[2], choices, values),
        Addon.CreateNearbyPinDropdown(NEARBY_PIN_SETTINGS[3], dragonChoices, dragonValues),
        Addon.CreateNearbyPinRadiusSlider(),
        {
            type = "header",
            name = "Announcements",
            width = "full",
        },
        Addon.CreateAnnouncementCheckbox(
            ANNOUNCEMENT_CHAT,
            "Chat"
        ),
        Addon.CreateAnnouncementCheckbox(
            ANNOUNCEMENT_TITLE,
            "ESO Title Announcement"
        ),
        Addon.CreateAnnouncementCheckbox(
            ANNOUNCEMENT_TITLE_SOUND,
            "ESO Title Announcement Sound",
            function()
                return not Addon.GetAnnouncementSettings(ANNOUNCEMENT_TITLE)
            end
        ),
        {
            type = "submenu",
            name = "Zones",
            controls = Addon.BuildRegionDropdownControls(choices, values),
        },
    }

    LAM:RegisterAddonPanel(LAM_PANEL_NAME, panelData)
    LAM:RegisterOptionControls(LAM_PANEL_NAME, optionsTable)
end

function Addon.RefreshNearbyUpdateRegistration()
    local shouldRegister = Addon.savedVars and Addon.savedVars.enabled and Addon.HasNearbyPinSettings()
    if shouldRegister and not Addon.nearbyUpdateRegistered then
        EVENT_MANAGER:RegisterForUpdate(NEARBY_UPDATE_NAMESPACE, NEARBY_UPDATE_INTERVAL_MS, function()
            Addon.ApplyCurrentSituation()
        end)
        Addon.nearbyUpdateRegistered = true
    elseif not shouldRegister and Addon.nearbyUpdateRegistered then
        EVENT_MANAGER:UnregisterForUpdate(NEARBY_UPDATE_NAMESPACE)
        Addon.nearbyUpdateRegistered = false
    end
end

function Addon.RegisterEvents()
    local eventManager = EVENT_MANAGER

    eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function(...)
        Addon.OnPlayerActivated(...)
    end)

    eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_ZONE_CHANGED, function(...)
        Addon.OnZoneChanged(...)
    end)

    eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_PREPARE_FOR_JUMP, function(...)
        Addon.OnPrepareForJump(...)
    end)

    -- Verified in esoui/app/loadingscreen/sharedloadingscreen.lua. This event is not listed in ESOUIDocumentation.txt.
    if EVENT_AREA_LOAD_STARTED ~= nil then
        eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_AREA_LOAD_STARTED, function(...)
            Addon.OnAreaLoadStarted(...)
        end)
    end

    eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_OVERLAND_DIFFICULTY_CHANGED, function(...)
        Addon.OnOverlandDifficultyChanged(...)
    end)

    eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_OVERLAND_DIFFICULTY_DISABLED_BY_SERVER_CHANGED, function()
        Addon.ApplyCurrentSituation()
    end)

    eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE, function(...)
        Addon.OnPlayerCombatState(...)
    end)
end

function Addon.Initialize()
    Addon.LoadScopeSettings()
    Addon.LoadActiveSettings()
    Addon.lastObservedDifficulty = GetOverlandDifficulty()
    Addon.RegisterSettings()
    Addon.RegisterEvents()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED)
    Addon.Initialize()
end

EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
