local Vector = LibImplex.Vector

local EVENT_NAMESPACE = 'IMPERIAL_CARTOGRAPHER_UNDISCOVERED_POIS_MAIN_EVENT_NAMESPACE'

local Log = ImperialCartographer_Logger()  -- TODO: hide if not loaded with debugging

-- ----------------------------------------------------------------------------

local function keepOnPlayersHeight(marker, distance, prwX, prwY, prwZ)
    marker[2] = prwY + 100
end

local function onReticleOver(marker)
    local poiId = marker.poiId
    if not poiId then return end

    local zoneIndex, poiIndex = GetPOIIndices(poiId)
    local objectiveName, objectiveLevel, startDescription, finishedDescription = GetPOIInfo(zoneIndex, poiIndex)

    -- ImperialCartographer_POILabel:SetAnchor(BOTTOM, marker.control, TOP)
    ImperialCartographer_POILabel:GetNamedChild('POIName'):SetText(zo_strformat(SI_WORLD_MAP_LOCATION_NAME, objectiveName))
    ImperialCartographer_POILabel:SetHidden(false)
end

-- ----------------------------------------------------------------------------

local MARK_TYPE_UNDISCOVERED_POI

local UndiscoveredPOIs = {}

function UndiscoveredPOIs:Initialize(addon)
    if not addon.sv.undiscoveredPOIs.enabled then return end

    MARK_TYPE_UNDISCOVERED_POI = ImperialCartographer.MarksManager:AddMarkType(
        function() self:Update() end,
        true,
        keepOnPlayersHeight,
        onReticleOver,
        ImperialCartographer.sv.defaultPois.fontSize -- TODO: change in the future
    )

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, function()
        ImperialCartographer.MarksManager:UpdateMarks(MARK_TYPE_UNDISCOVERED_POI)
    end)

    self.undiscovered = {}
    local function isBecameDiscovered(zoneIndex, poiIndex)
        local poiNX, poiNZ, pinType, texture, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered = GetPOIMapInfo(zoneIndex, poiIndex)
        if self.undiscovered[poiIndex] == isDiscovered then return true end
    end

    -- TODO: too heavy solution, refactor
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_POI_UPDATED, function(_, zoneIndex, poiIndex)
        if not isBecameDiscovered(zoneIndex, poiIndex) then return end

        Log('Updating undiscovered markers because of %d', poiIndex)
        ImperialCartographer.MarksManager:UpdateMarks(MARK_TYPE_UNDISCOVERED_POI)
    end)

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_FAST_TRAVEL_NETWORK_UPDATED, function(_, nodeIndex)
        local zoneIndex, poiIndex = GetFastTravelNodePOIIndicies(nodeIndex)
        if not isBecameDiscovered(zoneIndex, poiIndex) then return end

        Log('Updating markers because of %d', poiIndex)
        ImperialCartographer.MarksManager:UpdateMarks(MARK_TYPE_UNDISCOVERED_POI)
    end)

    if not IsConsoleUI() then
        local currentPanel = WORLD_MAP_FILTERS.currentPanel
        local pinFilterCheckBoxes = currentPanel.pinFilterCheckBoxes

        for _, checkBox in ipairs(pinFilterCheckBoxes) do
            ZO_PostHook(checkBox, 'toggleFunction', function()
                ImperialCartographer.MarksManager:UpdateMarks(MARK_TYPE_UNDISCOVERED_POI)
            end)
        end
    end
end

local function getMarkerColorByPinType(pinType)
    return {1, 66/255, 0}
end

local function getMarkerSizeByPinType(pinType)
    return 36
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

function UndiscoveredPOIs:AddPOI(zoneIndex, poiIndex)
    local poiId = ImperialCartographer.GetPOIId(zoneIndex, poiIndex)
    local objectiveName, objectiveLevel, startDescription, finishedDescription = GetPOIInfo(zoneIndex, poiIndex)

    local poiNX, poiNZ, pinType, texture, isShownInCurrentMap, linkedCollectibleIsLocked, isDiscovered = GetPOIMapInfo(zoneIndex, poiIndex)

    if not self.passesFilters(zoneIndex, poiIndex) then return Log('%d - poiId: %d - %s - Filtered', poiIndex, poiId, objectiveName) end

    local zoneId = GetZoneId(zoneIndex)
    -- local wX, wY, wZ = ImperialCartographer.Calculations.ConvertWtoRW(zoneId, unpack(poiData))

    local calibration = {ImperialCartographer.Coordinates.GetCalibration(zoneId)}
    local rwX, rwZ = ImperialCartographer.Coordinates.ConvertNormalizedToWorld(poiNX, poiNZ, calibration)
    local rwY = 14000

    local size = getMarkerSizeByPinType(pinType)
    local color = getMarkerColorByPinType(pinType)

    local mark, index = ImperialCartographer.MarksManager:AddMark(MARK_TYPE_UNDISCOVERED_POI, {poiId}, Vector({rwX, rwY, rwZ}), texture, size, color)
    mark.poiId = poiId  -- extra field TODO: avoid

    Log('%d - poiId: %d - %s - undiscovered', poiIndex, poiId, objectiveName)
end

function UndiscoveredPOIs:Update()
    ImperialCartographer.Calculations.ClearCalibrations()

    local zoneIndex = GetUnitZoneIndex('player')
    if not zoneIndex then Log('`zoneIndex` was not received for player') return end

    self.passesFilters = getFilters()

    Log('Loaded in [index:%d, id:%d] %s', zoneIndex, GetZoneId(zoneIndex), GetZoneNameByIndex(zoneIndex))

    for i, _ in pairs(self.undiscovered) do
        self.undiscovered[i] = nil
    end

    for poiIndex = 1, GetNumPOIs(zoneIndex) do
        local poiId = ImperialCartographer.GetPOIId(zoneIndex, poiIndex)
        if poiId and not ImperialCartographer.DefaultPOIsData[poiId] then
            self.undiscovered[poiId] = true
            self:AddPOI(zoneIndex, poiIndex)
        end
    end

    -- for i = 1, GetNumPOIs(zoneIndex) do
    --     self:AddPOI(zoneIndex, i)
    -- end

    -- IMP_CART_UpdateScrollListControl()  -- TODO
end

function UndiscoveredPOIs.GetCloseMark()
    for index, mark in pairs(ImperialCartographer.MarksManager.marks[MARK_TYPE_UNDISCOVERED_POI]) do
        if #(mark.position - {select(2, GetUnitRawWorldPosition('player'))}) <= 200 then
            local poiId = mark.poiId
            local pos = mark.position

            local zoneIndex, poiIndex = GetPOIIndices(poiId)
            local objectiveName = GetPOIInfo(zoneIndex, poiIndex)

            Log('Closest mark: %s (poiId: %d) - %.8f %d %.8f', objectiveName, poiId, pos[1], pos[2], pos[3])
            df('Closest mark: %s (poiId: %d) - %.8f %d %.8f', objectiveName, poiId, pos[1], pos[2], pos[3])
            return
        end
    end
end

assert(ImperialCartographer, 'ImperaialCartographer main.lua is not initialized')
ImperialCartographer.UndiscoveredPOIs = UndiscoveredPOIs


-- SLASH_COMMANDS['/impcshow'] = function(args)
--     local poiId = tonumber(args)
--     local marks = ImperialCartographer.MarksManager.marks[2]
--     for i = 1, #marks do
--         if marks[i].poiId == poiId then
--             local str = '[%d] = {%s},'
--             df(str, poiId, table.concat({marks[i].position[1], marks[i][2]-100, marks[i].position[3]}, ', '))
--             return
--         end
--     end
-- end