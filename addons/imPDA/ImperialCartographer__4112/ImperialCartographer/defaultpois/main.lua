local Vector = LibImplex.Vector

local EVENT_NAMESPACE = 'IMPERIAL_CARTOGRAPHER_DEFAULT_POIS_MAIN_EVENT_NAMESPACE'

local Log = ImperialCartographer_Logger()  -- TODO: hide if not loaded with debugging
local MM = ImperialCartographer.MarksManager

local ConvertWtoRW = ImperialCartographer.Calculations.ConvertWtoRW
local ClearCalibrations = ImperialCartographer.Calculations.ClearCalibrations

-- ----------------------------------------------------------------------------

local MARK_TYPE_DEFAULT_POI

local DefaultPOIs = {}

local poiIndexToMark = {}

-- ----------------------------------------------------------------------------

function DefaultPOIs:Initialize(parent)
    self.parent = parent

    if parent.sv.defaultPois == nil then
        parent.sv.defaultPois = {}
    end
    self.sv = parent.sv.defaultPois

    self.data = ImperialCartographer.DefaultPOIsData

    MARK_TYPE_DEFAULT_POI = MM:AddMarkType(
        function() self:Update() end,
        true,
        true,
        function(mark)
            local poiId = MM:GetMarkTag(mark)
            local objectiveName = GetPOIInfo(GetPOIIndices(poiId))

            return zo_strformat(SI_WORLD_MAP_LOCATION_NAME, objectiveName)
        end,
        self.sv.fontSize
    )

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
        MM:UpdateMarks(MARK_TYPE_DEFAULT_POI)
    end)

    local function editOne(zoneIndex, poiIndex)
        local poiNX, poiNZ, pinType, texture, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered = GetPOIMapInfo(zoneIndex, poiIndex)

        local mark = poiIndexToMark[poiIndex]
        if mark then mark:SetTexture(texture) end
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_POI_UPDATED, function(_, zoneIndex, poiIndex)
        Log('EVENT_POI_UPDATED: zoneIndex: %d, poiIndex: %d', zoneIndex, poiIndex)
        editOne(zoneIndex, poiIndex)
    end)

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_FAST_TRAVEL_NETWORK_UPDATED, function(_, nodeIndex)
        local zoneIndex, poiIndex = GetFastTravelNodePOIIndicies(nodeIndex)
        editOne(zoneIndex, poiIndex)
    end)

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_SKYSHARDS_UPDATED, function(_)
        MM:UpdateMarks(MARK_TYPE_DEFAULT_POI)  -- TODO: how to update skyshards only?
    end)

    if not IsConsoleUI() then
        local currentPanel = WORLD_MAP_FILTERS.currentPanel
        local pinFilterCheckBoxes = currentPanel.pinFilterCheckBoxes

        for _, checkBox in ipairs(pinFilterCheckBoxes) do
            ZO_PostHook(checkBox, 'toggleFunction', function()
                MM:UpdateMarks(MARK_TYPE_DEFAULT_POI)
            end)
        end
    end
end

-- function DefaultPOIs:GetMarkerColorByPinType(pinType)
--     return self.sv.markerColor or {1, 1, 1}
-- end

-- TODO: BY PIN TYPE?
function DefaultPOIs:GetMarkerSizeByPinType(pinType)
    return self.sv.markerSize or 36
end

local function getFilters()
    local isShowingWayshrines = ZO_WorldMap_IsPinGroupShown(MAP_FILTER_WAYSHRINES)
    local isShowingDungeons = ZO_WorldMap_IsPinGroupShown(MAP_FILTER_DUNGEONS)
    local isShowingTrials = ZO_WorldMap_IsPinGroupShown(MAP_FILTER_TRIALS)
    local isShowingArenas = ZO_WorldMap_IsPinGroupShown(MAP_FILTER_ARENAS)
    local isShowingHouses = ZO_WorldMap_IsPinGroupShown(MAP_FILTER_HOUSES)
    local isShowingObjectives = ZO_WorldMap_IsPinGroupShown(MAP_FILTER_OBJECTIVES)

    local function passesFilters(zoneIndex, poiIndex)
        local poiType = GetPOIType(zoneIndex, poiIndex)
        local instanceType = GetPOIInstanceType(zoneIndex, poiIndex)
        local mapFilterOverride = GetPOIMapFilterOverride(zoneIndex, poiIndex)

        if mapFilterOverride ~= MAP_FILTER_NONE then
            if mapFilterOverride == MAP_FILTER_WAYSHRINES then
                return isShowingWayshrines
            elseif mapFilterOverride == MAP_FILTER_DUNGEONS then
                return isShowingDungeons
            elseif mapFilterOverride == MAP_FILTER_ARENAS then
                return isShowingArenas
            elseif mapFilterOverride == MAP_FILTER_TRIALS then
                return isShowingTrials
            elseif mapFilterOverride == MAP_FILTER_HOUSES then
                return isShowingHouses
            end
        elseif poiType == POI_TYPE_HOUSE then
            return isShowingHouses
        elseif poiType == POI_TYPE_WAYSHRINE then
            return isShowingWayshrines
        elseif instanceType == INSTANCE_TYPE_RAID then  -- INSTANCE_TYPE_GROUP
            return isShowingTrials
        elseif poiType == POI_TYPE_GROUP_DUNGEON then
            return isShowingDungeons
        else
            -- poiType == POI_TYPE_OBJECTIVE or poiType == POI_TYPE_PUBLIC_DUNGEON or poiType == POI_TYPE_ACHIEVEMENT
            return isShowingObjectives
        end
    end

    return passesFilters
end

function DefaultPOIs:AddPOI(zoneIndex, poiIndex)
    local poiId = ImperialCartographer.GetPOIId(zoneIndex, poiIndex)
    local objectiveName, objectiveLevel, startDescription, finishedDescription = GetPOIInfo(zoneIndex, poiIndex)

    if not poiId then return Log('%d - poiId: not in a database (%s)', poiIndex, objectiveName) end
    if not self.data[poiId] then return Log('%d - poiId: %d - %s - no data about position', poiIndex, poiId, objectiveName) end

    local poiData = self.data[poiId]

    if not poiData then return end

    local poiNX, poiNZ, pinType, texture, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered = GetPOIMapInfo(zoneIndex, poiIndex)

    if not self.passesFilters(zoneIndex, poiIndex) then return Log('%d - poiId: %d - %s - Filtered', poiIndex, poiId, objectiveName) end

    local zoneId = GetZoneId(zoneIndex)
    local wX, wY, wZ = ConvertWtoRW(zoneId, unpack(poiData))

    local size = self:GetMarkerSizeByPinType(pinType)
    -- local color = self:GetMarkerColorByPinType(pinType)

    local tag = poiId

    local mark = MM:AddMark(MARK_TYPE_DEFAULT_POI, tag, Vector({wX, wY, wZ}), texture, size)
    poiIndexToMark[poiIndex] = mark

    Log('%d - poiId: %d - %s - OK', poiIndex, poiId, objectiveName)
end

function DefaultPOIs:AddSkyshard(skyshardId)
    local skyshardZoneId, wX, wY, wZ = GetWorldPositionForSkyshardId(skyshardId)  -- rw or just w? looks like rw
    local zoneId = skyshardZoneId  -- TODO: can it differ?

    local rwX, rwY, rwZ = ConvertWtoRW(zoneId, wX, wY, wZ)

    local size = self:GetMarkerSizeByPinType()

    local tag = skyshardId
    local texture
    local status = GetSkyshardDiscoveryStatus(skyshardId)
    if status == SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
        texture = 'EsoUI/Art/MapPins/skyshard_complete.dds'
    else  -- SKYSHARD_DISCOVERY_STATUS_UNDISCOVERED | SKYSHARD_DISCOVERY_STATUS_DISCOVERED
        texture = 'EsoUI/Art/MapPins/skyshard_seen.dds'
    end

    local mark = MM:AddMark(MARK_TYPE_DEFAULT_POI, tag, Vector({rwX, rwY, rwZ}), texture, size)
end

function DefaultPOIs:Update()
    ClearCalibrations()

    for k in pairs(poiIndexToMark) do
        poiIndexToMark[k] = nil
    end

    local zoneIndex = GetUnitZoneIndex('player')
    if not zoneIndex then Log('`zoneIndex` was not received for player') return end

    self.passesFilters = getFilters()

    Log('Loaded in [index:%d, id:%d] %s', zoneIndex, GetZoneId(zoneIndex), GetZoneNameByIndex(zoneIndex))

    for i = 1, GetNumPOIs(zoneIndex) do
        self:AddPOI(zoneIndex, i)
    end

    self:AddSkyshards()

    -- IMP_CART_UpdateScrollListControl()  -- TODO: FIX
end

local SKYSHARDS = {}
do
    for s = 1, GetNumSkyshards() do
        local skyshardId = GetSkyshardId(s)
        local zoneId = GetWorldPositionForSkyshardId(skyshardId)

        local skyshards = SKYSHARDS[zoneId] or {}
        skyshards[#skyshards+1] = skyshardId
        SKYSHARDS[zoneId] = skyshards

        if not SKYSHARDS[zoneId] then
            SKYSHARDS[zoneId] = {}
        end
        table.insert(SKYSHARDS[zoneId], skyshardId)
    end
end

function DefaultPOIs:AddSkyshards()
    local zoneId = GetUnitRawWorldPosition('player')

    local skyshards = SKYSHARDS[zoneId]
    if not skyshards or #skyshards < 1 then return end

    for s = 1, #skyshards do
        local skyshardId = skyshards[s]

        local skyshardZoneId, wX, wY, wZ = GetWorldPositionForSkyshardId(skyshardId)  -- rw or just w? looks like rw
        local status = GetSkyshardDiscoveryStatus(skyshardId)
        if status ~= SKYSHARD_DISCOVERY_STATUS_ACQUIRED and skyshardZoneId == zoneId then
            self:AddSkyshard(skyshardId)
        end
    end
end

function DefaultPOIs:TriggerFullUpdate()
    self.parent.MarksManager:UpdateMarks(MARK_TYPE_DEFAULT_POI)
end

function DefaultPOIs:SetDistanceLabelFontSize(fontSize)
    self.parent.MarksManager:SetDistanceLabelFontSize(MARK_TYPE_DEFAULT_POI, fontSize)
    self.parent.MarksManager:UpdateMarks(MARK_TYPE_DEFAULT_POI)
end

assert(ImperialCartographer, 'ImperaialCartographer main.lua is not initialized')
ImperialCartographer.DefaultPOIs = DefaultPOIs
