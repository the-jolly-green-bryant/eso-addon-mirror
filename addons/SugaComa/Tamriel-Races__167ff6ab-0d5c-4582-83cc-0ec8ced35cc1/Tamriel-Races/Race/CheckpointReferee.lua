TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

TR.CheckpointReferee = TR.CheckpointReferee or {}
local Referee = TR.CheckpointReferee

local function NormalizeInteractableName(value)
    if type(value) ~= "string" then return "" end
    if zo_strformat then
        value = zo_strformat("<<C:1>>", value)
    end
    value = string.gsub(value, "|c%x%x%x%x%x%x", "")
    value = string.gsub(value, "|r", "")
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return string.lower(value)
end

function Referee:Initialize()
    if EVENT_START_FAST_TRAVEL_INTERACTION then
        TR.Events:Register("FinalCheckpointActivation", EVENT_START_FAST_TRAVEL_INTERACTION, function()
            Referee:OnFinalCheckpointActivated()
        end)
    end
end

function Referee:IsFinalCheckpoint()
    local state = TR.State
    local route = state.route or {}
    return state.running == true and #route > 0 and state.currentIndex >= #route
end

function Referee:SetFinalCheckpointReady(ready)
    local state = TR.State
    ready = ready == true

    if ready then
        state.finalCheckpointReadyMs = TR.Util.NowMs()
    else
        state.finalCheckpointReadyMs = nil
    end

    if state.finalCheckpointReady == ready then return end
    state.finalCheckpointReady = ready
    TR.Controller:CallModules("OnFinalCheckpointReadinessChanged", ready)
    TR:NotifyChanged()
end

function Referee:GetCurrentCheckpoint()
    return TR.State.route[TR.State.currentIndex]
end

function Referee:GetPlayerUniversalPosition()
    if not GetMapPlayerPosition then return nil end

    local state = TR.State
    local currentMapId = GetCurrentMapId and GetCurrentMapId() or nil
    if state.raceMapId and currentMapId and currentMapId ~= state.raceMapId then
        return nil
    end

    local x, y, _, shown, symbolic = GetMapPlayerPosition("player")
    if not shown or symbolic then return nil end

    local mapId = currentMapId or state.raceMapId
    if not mapId then return nil end

    return TR.Util.ToUniversal(mapId, x, y)
end

function Referee:IsPlayerAtCheckpoint(checkpoint)
    if not checkpoint then return false end
    local ux, uy = self:GetPlayerUniversalPosition()
    if not ux then return false end
    return TR.Util.Distance2D(ux, uy, checkpoint.ux, checkpoint.uy) <= TR.Config.arrivalRadius
end

function Referee:GetCurrentInteractableWayshrineName()
    if type(GetGameCameraInteractableActionInfo) ~= "function" then return nil end

    local action, interactableName, interactionBlocked = GetGameCameraInteractableActionInfo()
    if interactionBlocked then return nil end
    if type(interactableName) ~= "string" or interactableName == "" then return nil end

    return interactableName, action
end

function Referee:IsExpectedWayshrineInteraction()
    local checkpoint = self:GetCurrentCheckpoint()
    if not checkpoint then return false end

    local interactableName = self:GetCurrentInteractableWayshrineName()
    if not interactableName then return false end

    TR.State.lastInteractableName = interactableName
    local expected = NormalizeInteractableName(checkpoint.name)
    local actual = NormalizeInteractableName(interactableName)
    if expected == "" or actual == "" then return false end

    return actual == expected
        or string.find(actual, expected, 1, true) ~= nil
        or string.find(expected, actual, 1, true) ~= nil
end

function Referee:SetStartReady(ready)
    local state = TR.State
    ready = ready == true
    if state.startReady == ready then return end

    state.startReady = ready
    TR.Controller:CallModules("OnStartReadinessChanged", ready)
    TR:NotifyChanged()

    if ready then
        local checkpoint = self:GetCurrentCheckpoint()
        TR.Diagnostics:Log("ESO confirmed start wayshrine: " .. tostring(checkpoint and checkpoint.name), true)
    end
end

function Referee:FinishRace(elapsed)
    local state = TR.State
    state.running = false
    state.waitingAtStart = false
    state.routeCreated = false
    state.startReady = false
    self:SetFinalCheckpointReady(false)

    local zone = state.currentZoneName or "Unknown Zone"
    local forfeited = state.fastTravelViolation == true
    local reason = state.fastTravelViolationReason

    TR.sv.records = TR.sv.records or {}
    if not forfeited then
        local best = TR.sv.records[zone]
        if not best or elapsed < best then
            TR.sv.records[zone] = elapsed
        end
        TR.sv.racesCompleted = (tonumber(TR.sv.racesCompleted) or 0) + 1
    end

    local basicResult = {
        zone = zone,
        time = elapsed,
        checkpoints = #state.route,
        forfeited = forfeited,
        reason = reason,
    }

    local recordedResult = basicResult
    if TR.RaceRecords and type(TR.RaceRecords.StoreRace) == "function" then
        recordedResult = TR.RaceRecords:StoreRace(elapsed, basicResult)
    else
        TR.sv.lastRace = basicResult
        state.lastResult = basicResult
    end

    state.currentIndex = #state.route

    TR.StartSequence:StopTick()
    TR.Controller:CallModules("OnRaceFinished", elapsed, recordedResult)
    TR:NotifyChanged()
    if forfeited then
        TR.Diagnostics:Log(
            "Race finished in " .. TR.Util.FormatMs(elapsed) ..
            " — FORFEITED: " .. tostring(reason or "race integrity violation"),
            true
        )
    else
        TR.Diagnostics:Log("Race finished in " .. TR.Util.FormatMs(elapsed), true)
    end
end

function Referee:OnCheckpointReached()
    local state = TR.State
    local checkpoint = self:GetCurrentCheckpoint()
    if not checkpoint then return false end

    if state.waitingAtStart then
        self:SetStartReady(true)
        return true
    end

    if not state.running then return false end

    local elapsed = TR.Util.NowMs() - (state.startTimeMs or TR.Util.NowMs())
    state.splitTimes[state.currentIndex] = elapsed

    if state.currentIndex >= #state.route then
        self:SetFinalCheckpointReady(false)
        self:FinishRace(elapsed)
    else
        local reached = checkpoint.name
        state.currentIndex = state.currentIndex + 1
        self:SetFinalCheckpointReady(false)
        TR.Controller:CallModules("OnCheckpointAdvanced", state.currentIndex, reached, elapsed)
        TR:NotifyChanged()
        TR.Diagnostics:Log(string.format(
            "Checkpoint confirmed: %s; next %d/%d",
            tostring(reached), state.currentIndex, #state.route
        ), true)
    end

    return true
end

function Referee:ConfirmExpectedCheckpointFromESO()
    local confirmed = self:IsExpectedWayshrineInteraction()

    -- Ordinary checkpoints remain pass-through: seeing ESO's matching Use prompt
    -- confirms them. The finish line is different. It is only armed here and
    -- must be explicitly activated with X before the race can end.
    if self:IsFinalCheckpoint() then
        self:SetFinalCheckpointReady(confirmed)
        return false
    end

    if not confirmed then return false end
    return self:OnCheckpointReached()
end

function Referee:OnFinalCheckpointActivated()
    local state = TR.State
    if not self:IsFinalCheckpoint() then return false end

    -- EVENT_START_FAST_TRAVEL_INTERACTION is ESO's authoritative wayshrine
    -- activation event. The prompt may collapse on the same frame, so retain a
    -- very short readiness memory from the normal race tick.
    local confirmedNow = self:IsExpectedWayshrineInteraction()
    local readyMs = tonumber(state.finalCheckpointReadyMs) or 0
    local recentReady = state.finalCheckpointReady == true
        and readyMs > 0
        and (TR.Util.NowMs() - readyMs) <= (TR.Config.finalActivationMemoryMs or 2000)

    if not confirmedNow and not recentReady then return false end

    local checkpoint = self:GetCurrentCheckpoint()
    TR.Diagnostics:Log(
        "Final wayshrine activated: " .. tostring(checkpoint and checkpoint.name),
        true
    )
    self:SetFinalCheckpointReady(false)
    return self:OnCheckpointReached()
end

function Referee:OnRaceTick()
    local state = TR.State
    if state.countdownActive then return end

    if state.waitingAtStart then
        -- ESO's interactable name is authoritative. Proximity is used only to
        -- revoke readiness after the player walks away from the confirmed start.
        if self:IsExpectedWayshrineInteraction() then
            self:SetStartReady(true)
        elseif state.startReady and not self:IsPlayerAtCheckpoint(self:GetCurrentCheckpoint()) then
            self:SetStartReady(false)
        end
        return
    end

    if state.running then
        self:ConfirmExpectedCheckpointFromESO()
    end
end

function Referee:OnRouteCreated()
    self:SetFinalCheckpointReady(false)
    TR.StartSequence:StartTick()
end

function Referee:OnRaceStarted()
    self:SetFinalCheckpointReady(false)
end

function Referee:ShutdownRace()
    TR.State.lastInteractableName = nil
    self:SetFinalCheckpointReady(false)
end

TR.Controller:RegisterModule("CheckpointReferee", Referee)
