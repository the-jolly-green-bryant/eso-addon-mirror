TamrielRaces = TamrielRaces or {}
local TR = TamrielRaces

TR.Presentations = TR.Presentations or {}
local Presentations = TR.Presentations

local function IsSTARSJournalShowing()
    if not SCENE_MANAGER or not SCENE_MANAGER.GetCurrentScene then return false end
    local scene = SCENE_MANAGER:GetCurrentScene()
    if not scene or not scene.GetName then return false end
    return scene:GetName() == "starsJournalGamepad"
end

local raceModule = {
    id = "tamriel_races",
    name = "Tamriel Races - STARS Edition",
    version = TR.Config.version,
    apiVersion = 1,
    presentationType = "game",
    description = "Create random wayshrine races across Tamriel and compete against the clock.",
    defaultActive = true,
    entryIndex = 1,
}

function Presentations:GetChroniclePresentation()
    local state = TR.State
    local zone = state.currentZoneName or (GetUnitZone and GetUnitZone("player")) or "Unknown Zone"
    local last = TR.sv and TR.sv.lastRace
    local stats = TR.sv and TR.sv.statistics or {}
    local zoneCount = TR.RaceRecords and TR.RaceRecords:GetZoneCount() or 0

    local lines = {
        "Total Races: " .. tostring(stats.totalRaces or 0),
        "Valid Finishes: " .. tostring(stats.validFinishes or TR.sv.racesCompleted or 0),
        "Forfeits: " .. tostring(stats.forfeits or 0),
        "Zones Raced: " .. tostring(zoneCount),
    }

    if last then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "LAST RECORDED RACE"
        lines[#lines + 1] = tostring(last.modeName or "Point-to-Point") .. " • " .. tostring(last.raceTypeName or "Wayshrine Route")
        lines[#lines + 1] = "Zone: " .. tostring(last.zone or "Unknown")
        lines[#lines + 1] = "Difficulty: " .. tostring(last.difficultyName or "Unknown")
        lines[#lines + 1] = "Mount: " .. tostring(last.mountName or "Unknown")
        lines[#lines + 1] = "Route: " .. tostring(last.startName or "?") .. " → " .. tostring(last.finishName or "?")
        lines[#lines + 1] = "Checkpoints: " .. tostring(last.checkpointCount or last.checkpoints or 0)
        lines[#lines + 1] = "Time: " .. TR.Util.FormatMs(last.time)
        if last.forfeited then
            lines[#lines + 1] = "Result: FORFEITED — " .. tostring(last.reason or "race integrity violation")
        else
            lines[#lines + 1] = "Result: VALID"
        end
    else
        lines[#lines + 1] = ""
        lines[#lines + 1] = "Complete your first race to begin your Tamriel racing legacy."
    end

    return {
        title = "TAMRIEL RACE RECORDS",
        subtitle = "YOUR RACING LEGACY",
        lines = lines,
    }
end

function Presentations:GetRaceControlPresentation()
    local state = TR.State
    local zone = state.currentZoneName or (GetUnitZone and GetUnitZone("player")) or "Unknown Zone"
    local current = state.route[state.currentIndex]
    local lines = { "Zone: " .. tostring(zone) }

    if not state.routeCreated and not state.running and not state.countdownActive then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "No race created."
        lines[#lines + 1] = ""
        lines[#lines + 1] = "Press X to Create Race."
        lines[#lines + 1] = "The route chooses distant Start and Finish endpoints"
        lines[#lines + 1] = "with progressive checkpoints between them."
    elseif state.waitingAtStart and current then
        local finish = state.route[#state.route]
        lines[#lines + 1] = ""
        lines[#lines + 1] = state.startReady and "START READY" or "GO TO START"
        lines[#lines + 1] = "Start: " .. tostring(current.name)
        lines[#lines + 1] = "Finish: " .. tostring(finish and finish.name or "?")
        lines[#lines + 1] = "Checkpoints: " .. tostring(#state.route)
        lines[#lines + 1] = ""
        if state.startReady then
            lines[#lines + 1] = "Press X to Start Race."
        else
            lines[#lines + 1] = "Fast travel is allowed while travelling to the start."
            lines[#lines + 1] = "Face and target the named starting wayshrine to ready the race."
        end
    elseif state.countdownActive then
        local remaining = math.max(0, (state.countdownEndsMs or 0) - TR.Util.NowMs())
        lines[#lines + 1] = ""
        lines[#lines + 1] = "COUNTDOWN ACTIVE"
        lines[#lines + 1] = "Flag drops in: " .. string.format("%.1f", remaining / 1000)
    elseif state.running and current then
        local elapsed = TR.Util.NowMs() - (state.startTimeMs or TR.Util.NowMs())
        lines[#lines + 1] = ""
        lines[#lines + 1] = string.format("Checkpoint: %d / %d", state.currentIndex, #state.route)
        if state.currentIndex >= #state.route then
            lines[#lines + 1] = "Finish: " .. tostring(current.name)
            lines[#lines + 1] = state.finalCheckpointReady
                and "Press X to activate the wayshrine and finish."
                or "Reach and activate the named wayshrine to finish."
        else
            lines[#lines + 1] = "Next: " .. tostring(current.name)
        end
        lines[#lines + 1] = "Time: " .. TR.Util.FormatMs(elapsed)
    end

    return {
        title = "TAMRIEL RACE",
        subtitle = state.running and "RACE ACTIVE"
            or (state.countdownActive and "STARTING"
            or (state.waitingAtStart and "ROUTE READY" or "RACE CONTROL")),
        lines = lines,
    }
end

function raceModule:GetEntryCount()
    return 2
end

function raceModule:ChangeEntry(delta)
    self.entryIndex = ((tonumber(self.entryIndex) or 1) - 1 + delta) % 2 + 1
    return true
end

function raceModule:GetActions()
    local state = TR.State
    return {
        primary = {
            name = state.routeCreated and "Start Race" or "Create Race",
            visible = function()
                if not IsSTARSJournalShowing() then return false end
                if not TR.State.routeCreated then
                    return not TR.State.running and not TR.State.countdownActive
                end
                return TR.State.startReady == true
            end,
            enabled = function()
                return not TR.State.routeCreated or TR.State.startReady == true
            end,
            callback = function()
                if TR.State.routeCreated then
                    return TR.StartSequence:StartRace()
                end
                return TR.RouteGenerator:GenerateRoute()
            end,
        },
        secondary = {
            name = "Restart Race",
            visible = function()
                return IsSTARSJournalShowing() and (TR.State:IsRaceActive() or TR.State.routeCreated)
            end,
            callback = function()
                TR.RouteGenerator:CancelRoute("race restarted")
                return TR.RouteGenerator:GenerateRoute()
            end,
        },
        tertiary = {
            name = "Cancel Race",
            visible = function()
                return IsSTARSJournalShowing() and (TR.State:IsRaceActive() or TR.State.routeCreated)
            end,
            callback = function() return TR.RouteGenerator:CancelRoute("race cancelled") end,
        },
        utility = {
            name = "New Route",
            visible = function()
                return IsSTARSJournalShowing()
                    and TR.State.routeCreated and not TR.State.running and not TR.State.countdownActive
            end,
            callback = function()
                TR.RouteGenerator:CancelRoute("new route requested")
                return TR.RouteGenerator:GenerateRoute()
            end,
        },
    }
end

function raceModule:GetPresentationData()
    if self.entryIndex == 1 then
        return Presentations:GetChroniclePresentation()
    end
    return Presentations:GetRaceControlPresentation()
end

function Presentations:Initialize()
    if not LibSTARSConnect or type(LibSTARSConnect.RegisterModule) ~= "function" then
        TR.Diagnostics:Warn("LibSTARSConnect unavailable; race module not registered")
        return
    end

    local ok, err = LibSTARSConnect:RegisterModule(raceModule)
    if not ok then
        TR.Diagnostics:Warn("STARS module registration failed: " .. tostring(err))
        return
    end

    TR.Diagnostics:Log("Tamriel Race module registered with STARS", true)
end

function Presentations:OnRouteCreated()
    TR:NotifyChanged()
end

function Presentations:OnCountdownStarted()
    TR:NotifyChanged()
end

function Presentations:OnRaceStarted()
    TR:NotifyChanged()
end

function Presentations:OnRaceTick()
    if TR.State.countdownActive or TR.State.running then
        TR:NotifyChanged()
    end
end

function Presentations:OnStartReadinessChanged()
    TR:NotifyChanged()
end

function Presentations:OnCheckpointAdvanced()
    TR:NotifyChanged()
end

function Presentations:OnRaceFinished()
    TR:NotifyChanged()
end

TR.Controller:RegisterModule("Presentations", Presentations)
