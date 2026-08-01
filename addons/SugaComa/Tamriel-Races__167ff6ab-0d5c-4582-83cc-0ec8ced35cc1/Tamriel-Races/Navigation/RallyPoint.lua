TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

TR.RallyPoint = TR.RallyPoint or {}
local RallyPoint = TR.RallyPoint

RallyPoint.active = false
RallyPoint.lastIndex = nil

function RallyPoint:GetTargetIndex()
    local state = TR.State
    local route = state.route
    if type(route) ~= "table" or #route == 0 then return nil end

    if state.countdownActive then
        return #route >= 2 and 2 or 1
    end

    if state.routeCreated or state.waitingAtStart or state.running then
        return tonumber(state.currentIndex) or 1
    end

    return nil
end

function RallyPoint:GetTarget()
    local index = self:GetTargetIndex()
    if not index then return nil end
    return TR.State.route[index], index
end

function RallyPoint:Clear()
    if type(RemoveRallyPoint) == "function" then
        pcall(RemoveRallyPoint)
    end
    self.active = false
    self.lastIndex = nil
end

function RallyPoint:PlaceCurrentTarget()
    local checkpoint, index = self:GetTarget()
    if not checkpoint then
        self:Clear()
        return false
    end

    local currentMapId = GetCurrentMapId and GetCurrentMapId() or nil
    local x, y = TR.Util.GetCheckpointMapPosition(checkpoint, currentMapId)
    if not x or not y then
        TR.Diagnostics:Warn("Could not project rally point for " .. tostring(checkpoint.name))
        return false
    end

    self:Clear()

    if type(PingMap) ~= "function"
        or MAP_PIN_TYPE_RALLY_POINT == nil
        or MAP_TYPE_LOCATION_CENTERED == nil then
        TR.Diagnostics:Warn("Native rally-point API unavailable")
        return false
    end

    local ok, result = pcall(
        PingMap,
        MAP_PIN_TYPE_RALLY_POINT,
        MAP_TYPE_LOCATION_CENTERED,
        x,
        y,
        nil
    )

    if not ok then
        TR.Diagnostics:Warn("Rally point placement failed: " .. tostring(result))
        return false
    end

    self.active = true
    self.lastIndex = index
    TR.Diagnostics:Log(string.format(
        "Rally map anchor placed: %d - %s",
        index,
        tostring(checkpoint.name)
    ), true)
    return true
end

function RallyPoint:Initialize()
    self:Clear()
end

function RallyPoint:OnRouteCreated()
    self:PlaceCurrentTarget()
end

function RallyPoint:OnStartReadinessChanged()
    self:PlaceCurrentTarget()
end

function RallyPoint:OnCountdownStarted()
    -- StartSequence opens the map before this callback. Place checkpoint 2 while
    -- that map context is active so ESO has the full five-second countdown to
    -- register the next destination.
    self:PlaceCurrentTarget()
end

function RallyPoint:OnRaceStarted()
    self:PlaceCurrentTarget()
end

function RallyPoint:OnCheckpointAdvanced()
    self:PlaceCurrentTarget()
end

function RallyPoint:OnPlayerActivated()
    if TR.State:IsRaceActive() or TR.State.routeCreated then
        self:PlaceCurrentTarget()
    else
        self:Clear()
    end
end

function RallyPoint:OnRaceFinished()
    self:Clear()
end

function RallyPoint:ShutdownRace()
    self:Clear()
end

TR.Controller:RegisterModule("RallyPoint", RallyPoint)
