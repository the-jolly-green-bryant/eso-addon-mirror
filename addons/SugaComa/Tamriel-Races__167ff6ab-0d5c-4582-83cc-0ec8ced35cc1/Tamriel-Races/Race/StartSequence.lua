TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

TR.StartSequence = TR.StartSequence or {}
local StartSequence = TR.StartSequence

function StartSequence:StartRace()
    local state = TR.State

    if state.routeInvalid then
        return false, "race route invalidated"
    end
    if not state.routeCreated or not state.route or #state.route < 2 then
        return false, "create a race first"
    end
    if not state.startReady then
        return false, "reach the starting checkpoint first"
    end

    state.waitingAtStart = false
    state.startReady = false
    state.running = false
    state.countdownActive = true
    state.preRaceMapCountdown = true
    state.currentIndex = 1
    state.startTimeMs = nil

    local now = TR.Util.NowMs()
    state.preRaceMapEndsMs = now + 5000
    state.countdownEndsMs = state.preRaceMapEndsMs

    if SCENE_MANAGER then
        local opened = false
        if SCENE_MANAGER.GetScene and SCENE_MANAGER:GetScene("gamepad_worldMap") then
            opened = pcall(function() SCENE_MANAGER:Show("gamepad_worldMap") end)
        end
        if not opened and SCENE_MANAGER.GetScene and SCENE_MANAGER:GetScene("worldMap") then
            pcall(function() SCENE_MANAGER:Show("worldMap") end)
        end
    end

    self:StartTick()
    TR.Controller:CallModules("OnCountdownStarted")
    TR:NotifyChanged()
    TR.Diagnostics:Log("Five-second map flag countdown started", true)
    return true
end

function StartSequence:FinishCountdown()
    local state = TR.State
    if not state.countdownActive then return end

    state.countdownActive = false
    state.preRaceMapCountdown = false
    state.countdownEndsMs = nil
    state.preRaceMapEndsMs = nil

    if SCENE_MANAGER then
        pcall(function() SCENE_MANAGER:Hide("gamepad_worldMap") end)
        pcall(function() SCENE_MANAGER:Hide("worldMap") end)
        if SCENE_MANAGER.ShowBaseScene then
            pcall(function() SCENE_MANAGER:ShowBaseScene() end)
        end
    end

    state.running = true
    state.startTimeMs = TR.Util.NowMs()
    state.currentIndex = 2

    TR.Controller:CallModules("OnRaceStarted")
    TR:NotifyChanged()
    TR.Diagnostics:Log("GO! Race timer started", true)
end

function StartSequence:RaceTick()
    local state = TR.State
    if state.countdownActive and state.countdownEndsMs
        and TR.Util.NowMs() >= state.countdownEndsMs then
        self:FinishCountdown()
    end

    TR.Controller:CallModules("OnRaceTick", TR.Util.NowMs())
end

function StartSequence:StartTick()
    EVENT_MANAGER:UnregisterForUpdate(TR.Config.updateName)
    EVENT_MANAGER:RegisterForUpdate(TR.Config.updateName, TR.Config.updateMs, function()
        StartSequence:RaceTick()
    end)
end

function StartSequence:StopTick()
    EVENT_MANAGER:UnregisterForUpdate(TR.Config.updateName)
end

function StartSequence:ShutdownRace()
    self:StopTick()
    if SCENE_MANAGER then
        pcall(function() SCENE_MANAGER:Hide("gamepad_worldMap") end)
        pcall(function() SCENE_MANAGER:Hide("worldMap") end)
    end
end

TR.Controller:RegisterModule("StartSequence", StartSequence)
