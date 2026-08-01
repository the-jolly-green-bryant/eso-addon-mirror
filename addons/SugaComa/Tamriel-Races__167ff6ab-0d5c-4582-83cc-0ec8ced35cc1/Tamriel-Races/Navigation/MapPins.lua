TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

TR.MapPins = TR.MapPins or {}
local MapPins = TR.MapPins

MapPins.registered = false
MapPins.pinTypes = {
    completed = {
        name = "TAMRIEL_RACES_MAP_COMPLETED",
        layout = {
            level = 48,
            size = 28,
            texture = "/esoui/art/compass/quest_assistedareapin.dds",
            tint = ZO_ColorDef:New(0.65, 0.65, 0.65, 0.55),
        },
    },
    future = {
        name = "TAMRIEL_RACES_MAP_FUTURE",
        layout = {
            level = 49,
            size = 31,
            texture = "/esoui/art/compass/quest_assistedareapin.dds",
            tint = ZO_ColorDef:New(1, 0.2, 0.2, 0.9),
        },
    },
    current = {
        name = "TAMRIEL_RACES_MAP_CURRENT",
        layout = {
            level = 50,
            size = 42,
            texture = "/esoui/art/compass/quest_assistedareapin.dds",
            tint = ZO_ColorDef:New(0.2, 1, 0.2, 1),
        },
    },
}

local function GetVisualCurrentIndex()
    local state = TR.State
    if state.countdownActive and type(state.route) == "table" and #state.route >= 2 then
        return 2
    end
    return tonumber(state.currentIndex) or 0
end

local function GetVisualState(index)
    local state = TR.State
    local currentIndex = GetVisualCurrentIndex()

    if not state.routeCreated and not state.waitingAtStart
        and not state.countdownActive and not state.running
        and state.lastResult ~= nil then
        return "completed"
    end

    if index < currentIndex then return "completed" end
    if index == currentIndex then return "current" end
    return "future"
end

local function GetStateTag(index, checkpoint)
    return {
        index = index,
        name = checkpoint.name,
        state = GetVisualState(index),
    }
end

local function CreatePinsForState(stateName)
    local LMP = LibMapPins
    local route = TR.State.route
    local definition = MapPins.pinTypes[stateName]
    if not LMP or not definition or type(route) ~= "table" or #route == 0 then return end
    if type(LMP.IsEnabled) == "function" and not LMP:IsEnabled(definition.name) then return end

    local currentMapId = GetCurrentMapId and GetCurrentMapId() or nil
    for index, checkpoint in ipairs(route) do
        if GetVisualState(index) == stateName then
            local x, y = TR.Util.GetCheckpointMapPosition(checkpoint, currentMapId)
            if x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
                LMP:CreatePin(
                    definition.name,
                    GetStateTag(index, checkpoint),
                    x,
                    y
                )
            end
        end
    end
end

function MapPins:Initialize()
    local LMP = LibMapPins
    if not LMP or type(LMP.AddPinType) ~= "function"
        or type(LMP.CreatePin) ~= "function" then
        TR.Diagnostics:Warn("LibMapPins unavailable; world-map race pins disabled")
        return
    end

    local ok, err = pcall(function()
        for stateName, definition in pairs(self.pinTypes) do
            local capturedState = stateName
            definition.id = LMP:AddPinType(
                definition.name,
                function()
                    CreatePinsForState(capturedState)
                end,
                nil,
                definition.layout,
                nil
            )

            if definition.id and type(LMP.SetEnabled) == "function" then
                LMP:SetEnabled(definition.id, true)
            end
        end
    end)

    if not ok then
        TR.Diagnostics:Warn("LibMapPins registration failed: " .. tostring(err))
        return
    end

    self.registered = true
    self:Refresh()
end

function MapPins:Refresh()
    local LMP = LibMapPins
    if not self.registered or not LMP or type(LMP.RefreshPins) ~= "function" then return end

    for _, definition in pairs(self.pinTypes) do
        pcall(function() LMP:RefreshPins(definition.name) end)
    end
end

function MapPins:OnRouteCreated() self:Refresh() end
function MapPins:OnStartReadinessChanged() self:Refresh() end
function MapPins:OnCountdownStarted() self:Refresh() end
function MapPins:OnRaceStarted() self:Refresh() end
function MapPins:OnCheckpointAdvanced() self:Refresh() end
function MapPins:OnRaceFinished() self:Refresh() end
function MapPins:OnPlayerActivated() self:Refresh() end
function MapPins:ShutdownRace() self:Refresh() end

TR.Controller:RegisterModule("MapPins", MapPins)
