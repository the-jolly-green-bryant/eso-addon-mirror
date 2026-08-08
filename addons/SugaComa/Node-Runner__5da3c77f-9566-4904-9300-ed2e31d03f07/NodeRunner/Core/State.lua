NODE_RUNNER = NODE_RUNNER or {}
local Project = NODE_RUNNER

Project.State = Project.State or {}
local State = Project.State

function State:ResetRun()
    self.phase = "idle"
    self.entryIndex = self.entryIndex or 1

    self.countdownEndsMs = 0

    -- Survival clock foundation.
    self.startedAtMs = 0

    -- Harvest clock foundation. This is remaining game time, not an absolute
    -- deadline, because future freeze/slow/fast effects need to change its rate.
    self.harvestTimeMs = 0
    self.lastTickMs = 0
    self.harvestRate = 1.0
    self.harvestRateEndsMs = 0

    -- Gather-pressure clock. It always runs in real time and is deliberately
    -- independent of any Harvest Clock speed/freeze effect.
    self.gatherDeadlineMs = 0
    self.gatherPenalties = 0

    self.nodesGathered = 0
    self.rouletteRolls = 0
    self.lastNodeKind = ""
    self.lastItemName = ""

    self.lastEffectText = ""
    self.lastEffectAmount = 0
    self.finishReason = ""
end

function State:Reset()
    self.entryIndex = 1
    self.lastResult = nil
    self:ResetRun()
end

function State:Initialize()
    self:Reset()
    if Project.sv and Project.sv.projectData then
        self.lastResult = Project.sv.projectData.lastRun
    end
    self.initialized = true
end

function State:IsCountdown()
    return self.phase == "countdown"
end

function State:IsRunning()
    return self.phase == "running"
end

function State:IsActive()
    return self:IsCountdown() or self:IsRunning()
end
