local Log = ImperialCartographer_Logger()

local EVENT_NAMESPACE = 'IMPERIAL_CARTOGRAPHER_MARKS_MANAGER_EVENT_NAMESPACE'
local EM = LibImplex.EVENT_MANAGER

local markerFactory = LibImplex.Objects('ImperialCartographer')

-- ----------------------------------------------------------------------------

local MarksManager = {}

-- TODO: settings
local FILTER_BY_DISTANCE = LibImplex.Systems.NewFilterByDistanceSystem(2, 225)
local CHANGE_ALPHA_WITH_DISTANCE = LibImplex.Systems.NewChangeAlphaWithDistanceSystem(2, 1, 225, 0.2)

-- ----------------------------------------------------------------------------

local MARK_WITH_WAYPOINT

function MarksManager:SetWaypointAt(wnX, wnZ)
    Log('SetWaypointAt')
    local zoneIndex = GetCurrentMapZoneIndex()

    local zoneId = GetZoneId(zoneIndex)
    local calibration = {ImperialCartographer.Coordinates.GetCalibration(zoneId)}
    local wpwX, wpwZ = ImperialCartographer.Coordinates.ConvertNormalizedToWorld(wnX, wnZ, calibration)

    local closestPOIId
    local minimalDistanceSq = math.huge

    -- TODO: improve detection
    for i = 1, GetNumPOIs(zoneIndex) do
        local nX, nZ = GetPOIMapInfo(zoneIndex, i)
        local poiwX, poiwZ = ImperialCartographer.Coordinates.ConvertNormalizedToWorld(nX, nZ, calibration)

        local dX, dZ = wpwX - poiwX, wpwZ - poiwZ
        local distanceSq = dX * dX + dZ * dZ

        if distanceSq < minimalDistanceSq then
            closestPOIId = ImperialCartographer.GetPOIId(zoneIndex, i)
            minimalDistanceSq = distanceSq
        end
    end

    if minimalDistanceSq > 4000 * 4000 then return end
    Log('Waypoint -> POI distance: %d', math.sqrt(minimalDistanceSq) / 100)

    for type, marks in ipairs(self.marks) do
        for i, mark in pairs(marks) do
            if self.markTags[type][i] == closestPOIId then
                MARK_WITH_WAYPOINT = mark
                break
            end
        end
    end

    if not MARK_WITH_WAYPOINT then return end

    MARK_WITH_WAYPOINT:RemoveSystem(FILTER_BY_DISTANCE)
    MARK_WITH_WAYPOINT:RemoveSystem(CHANGE_ALPHA_WITH_DISTANCE)

    IMP_CART_WaypointTexture:SetParent(MARK_WITH_WAYPOINT.control)
    IMP_CART_WaypointTexture:ClearAnchors()
    IMP_CART_WaypointTexture:SetAnchor(BOTTOM, MARK_WITH_WAYPOINT.control, TOP, 0, 4)
    IMP_CART_WaypointTexture:SetHidden(false)

    MARK_WITH_WAYPOINT.control:SetClampedToScreen(true)
    MARK_WITH_WAYPOINT.control:SetClampedToScreenInsets(-48, -48, 48, 48)
end

function MarksManager:RemoveExistingWaypointMarker()
    if not MARK_WITH_WAYPOINT then return end

    IMP_CART_WaypointTexture:ClearAnchors()
    IMP_CART_WaypointTexture:SetHidden(true)

    MARK_WITH_WAYPOINT.control:SetClampedToScreen(false)

    -- EM.UnregisterForEvent(EVENT_NAMESPACE .. 'Waypoint', EM.EVENT_AFTER_UPDATE)

    MARK_WITH_WAYPOINT:AddSystem(FILTER_BY_DISTANCE)
    MARK_WITH_WAYPOINT:AddSystem(CHANGE_ALPHA_WITH_DISTANCE)

    MARK_WITH_WAYPOINT = nil
end

function MarksManager:SetWaypoint()
    local wnX, wnY = GetMapPlayerWaypoint()

    if wnX ~= 0 or wnY ~= 0 then
        self:SetWaypointAt(wnX, wnY)
    end
end

function MarksManager:SetupWaypoint()
    ZO_PostHook(_G, 'PingMap', function(pinType, mapDisplayType, nX, nY)
        Log('Ping at %.2f, %.2f', nX * 100, nY * 100)
        if pinType ~= MAP_PIN_TYPE_PLAYER_WAYPOINT then return end

        self:RemoveExistingWaypointMarker()
        self:SetWaypointAt(nX, nY)
    end)

    ZO_PostHook(_G, 'RemovePlayerWaypoint', function() self:RemoveExistingWaypointMarker() end)
end

-- ----------------------------------------------------------------------------

local function POIMarkerOnMouseEnter(self)
    local poiId = self.m_Marker.poiId
    Log('Mouse enter, poiId: %s', tostring(poiId))

    if not poiId then return end

    ImperialCartographer_POILabel:SetAnchor(BOTTOM, self, TOP)
    ImperialCartographer_POILabel:GetNamedChild('POIName'):SetText(('[POI#%d] %s\nx:%d y:%d z:%d'):format(poiId, self:GetName(), unpack(self.m_Marker.position)))
    ImperialCartographer_POILabel:SetHidden(false)
end

local function POIMarkerOnMouseExit(self)
    local poiId = self.m_Marker.poiId
    Log('Mouse exit, poiId: %s', tostring(poiId))

    ImperialCartographer_POILabel:SetHidden(true)
end

local function addMouseOverHandler(marker, poiId)
    marker.poiId = poiId
    marker:SetHandler('OnMouseEnter', POIMarkerOnMouseEnter)
    marker:SetHandler('OnMouseExit', POIMarkerOnMouseExit)
    marker:SetMouseEnabled(true)
end

-- ----------------------------------------------------------------------------

function MarksManager:Initialize(addon)
    self.types = {}
    self.marks = {}
    self.markTags = {}

    self.markIndicies = {}
    setmetatable(self.markIndicies, {__mode = 'k'})

    self.sv = addon.sv
    self.on = nil

    self:SetupWaypoint()

    self:UpdatePOILabelFontSize()

    self:SetHideInCombat(self.sv.hideInCombat)
    self:_turnOn(self.sv.active)
end

function MarksManager:UpdatePOILabelFontSize()
    ImperialCartographer_POILabel:GetNamedChild('POIName'):SetFont(('$(BOLD_FONT)|$(KB_%d)|soft-shadow-thick'):format(self.sv.labelFontSize))
end

function MarksManager:SetActive(state)
    self.sv.active = state
    self:_turnOn(state)
end

function MarksManager:SetHideInCombat(hideInCombat)
    self.sv.hideInCombat = hideInCombat

    if hideInCombat then
        self:_turnOn(not IsUnitInCombat('player'))
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
            self:_turnOn(not inCombat)
        end)
    else
        self:_turnOn(true)
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE, EVENT_PLAYER_COMBAT_STATE)
    end
end

function MarksManager:ShouldShowMarks()
    return not ((self.sv.hideInCombat and IsUnitInCombat('player')) or not self.sv.active)
end

function MarksManager:_turnOn(turnOn)
    if self.on == turnOn then return end

    local shouldTurnOn = self:ShouldShowMarks()
    self.on = shouldTurnOn

    if shouldTurnOn then
        self:AddAll()
    else
        self:Clear()
    end
end

function MarksManager:AddMarkType(updateFunc, showDistanceLabel, distanceFunc, reticleOverFunc, distanceLabelFontSize, ...)
    local typeIndex = #self.types + 1

    self.types[typeIndex] = {
        updateFunc = updateFunc,
        showDistanceLabel = showDistanceLabel,
        markerUpdateSystems = {...},
        reticleOverSystem = LibImplex.Systems.OnReticleOver(reticleOverFunc, ImperialCartographer_POILabel:GetNamedChild('POIName')),
        distanceLabelFontSize = distanceLabelFontSize or 20,
    }

    if distanceFunc then
        table.insert(self.types[typeIndex].markerUpdateSystems, FILTER_BY_DISTANCE)
        table.insert(self.types[typeIndex].markerUpdateSystems, CHANGE_ALPHA_WITH_DISTANCE)
    end

    self.marks[typeIndex] = {}
    self.markTags[typeIndex] = {}

    return typeIndex
end

function MarksManager:SetDistanceLabelFontSize(type, fontSize)
    self.types[type].distanceLabelFontSize = fontSize
end

function MarksManager:AddMark(type, tag, position, texture, size, color)
    local markTypeData = self.types[type]

    if not markTypeData then return end

    local mark = markerFactory._2D()
    mark.control:SetClampedToScreen(false)  -- this is specifically for currentquesttraker, optimize 
    mark:SetPosition(unpack(position))
    mark:SetTexture(texture)
    mark:SetDimensions(size, size)

    if markTypeData.showDistanceLabel then
        mark:AddSystem(LibImplex.Systems.UpdateDistanceLabel)
        mark.distanceLabel:SetHidden(false)
        mark.distanceLabel:SetFont(('$(BOLD_FONT)|$(KB_%d)|soft-shadow-thick'):format(markTypeData.distanceLabelFontSize))
    end

    if markTypeData.reticleOverSystem then
        mark:AddSystem(markTypeData.reticleOverSystem)
    end

    for _, system in ipairs(markTypeData.markerUpdateSystems) do
        mark:AddSystem(system)
    end

    local index = #self.marks[type] + 1
    self.marks[type][index] = mark
    self.markTags[type][index] = tag

    self.markIndicies[mark] = {type, index}

    return mark, index
end

function MarksManager:GetMarkIndicies(mark)
    return unpack(self.markIndicies[mark])
end

function MarksManager:GetMarkTag(mark)
    local type, index = self:GetMarkIndicies(mark)
    return self.markTags[type][index]
end

function MarksManager:SetTag(mark, tag)
    local type, index = self:GetMarkIndicies(mark)
    self.markTags[type][index] = tag
end

function MarksManager:RemoveMarks(type)
    local marks = self.marks[type]

    if marks then
        for i = 1, #marks do
            marks[i]:Delete()
            marks[i] = nil
        end
    end
end

function MarksManager:RemoveMark(type, index)
    local marks = self.marks[type]

    if not marks[index] then return end

    marks[index]:Delete()
    marks[index] = nil
end

function MarksManager:UpdateMarks(type)
    if not type then return end

    self:RemoveMarks(type)

    if not self:ShouldShowMarks() then return end
    self.types[type].updateFunc()

    self:SetWaypoint()
end

function MarksManager:Clear()
    local types = self.types

    for i = 1, #types do
        self:RemoveMarks(i)
    end
end

function MarksManager:AddAll()
    if not self:ShouldShowMarks() then return end

    local types = self.types

    for i = 1, #types do
        types[i].updateFunc()
    end
end

assert(ImperialCartographer, 'ImperaialCartographer main.lua is not initialized')
ImperialCartographer.MarksManager = MarksManager

function ImperialCartographer_MarksManager_ToggleActive()
    MarksManager:SetActive(not MarksManager.sv.active)
    if IMP_CART_LAM_SETTING_ACTIVE then
        IMP_CART_LAM_SETTING_ACTIVE:UpdateValue()
    end
end
