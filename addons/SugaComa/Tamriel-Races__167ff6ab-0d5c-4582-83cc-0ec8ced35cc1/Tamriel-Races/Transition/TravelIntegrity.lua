TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

TR.TravelIntegrity = TR.TravelIntegrity or {}
local TravelIntegrity = TR.TravelIntegrity

function TravelIntegrity:Initialize()
    if EVENT_START_FAST_TRAVEL_INTERACTION then
        TR.Events:Register("FastTravelStart", EVENT_START_FAST_TRAVEL_INTERACTION, function()
            TravelIntegrity:OnFastTravelStarted()
        end)
    end

    if EVENT_END_FAST_TRAVEL_INTERACTION then
        TR.Events:Register("FastTravelEnd", EVENT_END_FAST_TRAVEL_INTERACTION, function()
            TravelIntegrity:OnFastTravelEnded()
        end)
    end

    if EVENT_PLAYER_ACTIVATED then
        TR.Events:Register("FastTravelActivation", EVENT_PLAYER_ACTIVATED, function()
            TravelIntegrity:OnPlayerActivated()
        end)
    end
end

function TravelIntegrity:OnFastTravelStarted()
    local state = TR.State
    if not state.running then return end

    state.fastTravelInteractionPending = true
    state.fastTravelInteractionStartedMs = TR.Util.NowMs()
    TR.Diagnostics:Log("Fast travel interaction started during active race.")
end

function TravelIntegrity:OnFastTravelEnded()
    local state = TR.State
    if not state.running or not state.fastTravelInteractionPending then return end

    -- Deliberately retain the pending marker until EVENT_PLAYER_ACTIVATED.
    -- Doors, caves and gauntlet transitions do not produce the explicit
    -- fast-travel start event, so they remain legal race movement.
    state.fastTravelInteractionEndedMs = TR.Util.NowMs()
    TR.Diagnostics:Log("Fast travel interaction confirmed; awaiting player activation.")
end

function TravelIntegrity:OnPlayerActivated()
    local state = TR.State
    if not state.fastTravelInteractionPending then return end

    local now = TR.Util.NowMs()
    local started = tonumber(state.fastTravelInteractionStartedMs) or 0
    local withinWindow = started > 0
        and (now - started) <= (TR.Config.fastTravelActivationWindowMs or 15000)

    if state.running and withinWindow then
        state.fastTravelViolation = true
        state.fastTravelViolationReason = "Fast travel detected"
        state.fastTravelViolationConfirmedMs = now
        TR.Controller:CallModules("OnRaceIntegrityChanged", false, state.fastTravelViolationReason)
        TR.Diagnostics:Log("Race marked for post-finish forfeiture: fast travel detected.", true)
    end

    self:ClearPending()
end

function TravelIntegrity:ClearPending()
    local state = TR.State
    state.fastTravelInteractionPending = false
    state.fastTravelInteractionStartedMs = nil
    state.fastTravelInteractionEndedMs = nil
end

function TravelIntegrity:OnRouteCreated()
    self:ClearPending()
    TR.State.fastTravelViolation = false
    TR.State.fastTravelViolationReason = nil
    TR.State.fastTravelViolationConfirmedMs = nil
end

function TravelIntegrity:OnRaceStarted()
    self:ClearPending()
    TR.State.fastTravelViolation = false
    TR.State.fastTravelViolationReason = nil
    TR.State.fastTravelViolationConfirmedMs = nil
end

function TravelIntegrity:OnRaceFinished()
    -- The finish wayshrine is deliberately activated with X. Depending on
    -- callback order, the fast-travel start event may briefly set this marker
    -- before the referee completes the race. Never carry it beyond the finish.
    self:ClearPending()
end

function TravelIntegrity:ShutdownRace()
    self:ClearPending()
end

TR.Controller:RegisterModule("TravelIntegrity", TravelIntegrity)
