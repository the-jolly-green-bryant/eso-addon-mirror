TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

TR.CompassPins = TR.CompassPins or {}
local CompassPins = TR.CompassPins

CompassPins.pinType = "TAMRIEL_RACES_COMPASS"
CompassPins.registered = false

function CompassPins:GetTarget()
    local state = TR.State
    if not (state.routeCreated or state.waitingAtStart or state.countdownActive or state.running) then
        return nil
    end
    return state.route and state.route[state.currentIndex] or nil
end

function CompassPins:Initialize()
    if not COMPASS_PINS or type(COMPASS_PINS.AddCustomPin) ~= "function" then
        TR.Diagnostics:Warn("CustomCompassPins unavailable; compass race target disabled")
        return
    end

    local layout = {
        texture = "/esoui/art/compass/quest_assistedareapin.dds",
        maxDistance = 1,
        size = 48,
        additionalLayout = {
            update = function(pin)
                local icon = pin:GetNamedChild("Background")
                if icon then icon:SetColor(0.2, 1, 0.2, 1) end
            end,
            reset = function(pin)
                local icon = pin:GetNamedChild("Background")
                if icon then icon:SetColor(1, 1, 1, 1) end
            end,
        },
    }

    local ok, err = pcall(function()
        COMPASS_PINS:AddCustomPin(self.pinType, function(pinManager)
            local checkpoint = CompassPins:GetTarget()
            if not checkpoint then return end

            local currentMapId = GetCurrentMapId and GetCurrentMapId() or nil
            local x, y = TR.Util.GetCheckpointMapPosition(checkpoint, currentMapId)
            if not x or not y then return end

            pinManager:CreatePin(
                CompassPins.pinType,
                "race-current",
                x,
                y,
                checkpoint.name
            )
        end, layout)
    end)

    if not ok then
        TR.Diagnostics:Warn("CustomCompassPins registration failed: " .. tostring(err))
        return
    end

    self.registered = true
    self:Refresh()
end

function CompassPins:Clear()
    if not self.registered or not COMPASS_PINS or type(COMPASS_PINS.RemovePins) ~= "function" then return end
    pcall(function() COMPASS_PINS:RemovePins(self.pinType) end)
end

function CompassPins:Refresh()
    if not self.registered or not COMPASS_PINS or type(COMPASS_PINS.RefreshPins) ~= "function" then return end
    pcall(function() COMPASS_PINS:RefreshPins(self.pinType) end)
end

function CompassPins:OnRouteCreated() self:Refresh() end
function CompassPins:OnStartReadinessChanged() self:Refresh() end
function CompassPins:OnCountdownStarted() self:Refresh() end
function CompassPins:OnRaceStarted() self:Refresh() end
function CompassPins:OnCheckpointAdvanced() self:Refresh() end
function CompassPins:OnPlayerActivated() self:Refresh() end
function CompassPins:OnRaceFinished() self:Clear() end
function CompassPins:ShutdownRace() self:Clear() end

TR.Controller:RegisterModule("CompassPins", CompassPins)
