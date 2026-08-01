local SRC = SupportRotationCallouts
SRC.PostPullAnalytics = SRC.PostPullAnalytics or {}
local Analytics = SRC.PostPullAnalytics

local UPDATE_NAME = (SRC.name or "Conductor") .. "PostPullAnalytics"

local function NowMs()
    return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
end

local function Round(value)
    return zo_floor((tonumber(value) or 0) + 0.5)
end

local function Key(value)
    return string.upper(tostring(value or "")):gsub("[^A-Z0-9]+", "_")
end

local function IsLead()
    return SRC.saved and SRC.saved.displayRole == "lead"
end

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = Copy(item) end
    return result
end

local function ActiveCoverage(active, nowSeconds, target)
    local covered = 0
    for _, data in pairs(active or {}) do
        if data.endTime and data.endTime > nowSeconds then covered = covered + 1 end
    end
    target = zo_max(1, tonumber(target) or 1)
    return covered, zo_clamp(covered / target, 0, 1)
end

function Analytics:SetRaidState(state, reason)
    state = Key(state)
    if state == "" or self.raidState == state then return end
    local previous = self.raidState
    self.raidState = state
    if SRC.EventBus then
        SRC.EventBus:Publish("RAID_STATE_CHANGED", {
            state = state,
            previousState = previous,
            reason = reason,
            pull = self.activePull,
        })
    end
end

function Analytics:StartPull()
    if self.activePull then return end
    local encounter = SRC.EncounterEngine and SRC.EncounterEngine:GetSnapshot() or {}
    self.pullCounter = (tonumber(self.pullCounter) or 0) + 1
    self.activePull = {
        id = self.pullCounter,
        startedAtMs = NowMs(),
        endedAtMs = nil,
        mode = encounter.mode or "TRASH",
        encounterLabel = encounter.encounterLabel or encounter.bossName or "Trash Pull",
        trialCode = encounter.trialCode or "",
        objective = encounter.objective or "",
        effects = {},
        sequence = { scheduled = 0, completed = 0, missed = 0, skipped = 0, timing = {}, supportExecutions = {} },
        interrupts = 0,
        stateTransitions = {},
    }
    self:SetRaidState("PULLING", "combat started")
    if SRC.EventBus then SRC.EventBus:Publish("POST_PULL_CAPTURE_STARTED", { pull = self.activePull }) end
end

function Analytics:SampleEffects(elapsedMs)
    local pull = self.activePull
    local tracker = SRC.CoverageTracker
    if not pull or not tracker or not tracker.effects then return end
    local nowSeconds = GetGameTimeSeconds and GetGameTimeSeconds() or 0
    local groupTarget = zo_max(1, tonumber(GetGroupSize and GetGroupSize() or 1) or 1)

    for key, definition in pairs(tracker.effects) do
        if tracker:IsEnabled(key) then
            local metric = pull.effects[key]
            if not metric then
                metric = {
                    key = key,
                    name = definition.label or key,
                    effectType = definition.effectType,
                    sampledMs = 0,
                    activeMs = 0,
                    fullMs = 0,
                    coverageTotal = 0,
                    samples = 0,
                }
                pull.effects[key] = metric
            end
            local target = definition.effectType == "BUFF" and groupTarget or 1
            local covered, ratio = ActiveCoverage(tracker.active[key], nowSeconds, target)
            metric.sampledMs = metric.sampledMs + elapsedMs
            metric.samples = metric.samples + 1
            metric.coverageTotal = metric.coverageTotal + ratio
            if covered > 0 then metric.activeMs = metric.activeMs + elapsedMs end
            if ratio >= 0.999 then metric.fullMs = metric.fullMs + elapsedMs end
        end
    end
end

function Analytics:OnUpdate()
    if not self.activePull then return end
    local now = NowMs()
    local elapsed = zo_clamp(now - (self.lastSampleAtMs or now), 0, 1000)
    self.lastSampleAtMs = now
    self:SampleEffects(elapsed)

    local encounter = SRC.EncounterEngine and SRC.EncounterEngine:GetSnapshot() or {}
    local sequence = SRC.EncounterSequenceEngine
    if encounter.lowestBossHealth and encounter.lowestBossHealth <= 10 then
        self:SetRaidState("EXECUTE", "boss execute threshold")
    elseif sequence and sequence.state == sequence.STATE.INTERRUPTED then
        self:SetRaidState("RECOVERY", "encounter interrupt")
    elseif sequence and sequence.steps and sequence.cursor then
        local step = sequence.steps[sequence.cursor]
        if step and (step.key == "BURN" or step.key == "DAMAGE_ULTIMATES") then
            self:SetRaidState("BURN", "burn package active")
        elseif self.raidState ~= "PULLING" then
            self:SetRaidState("STABLE", "rotation active")
        end
    elseif self.raidState == "PULLING" then
        self:SetRaidState("STABLE", "combat established")
    end
end

function Analytics:OnSequenceScheduled(payload)
    if not self.activePull then return end
    self.activePull.sequence.scheduled = self.activePull.sequence.scheduled + 1
end

function Analytics:OnSequenceCompleted(payload)
    local pull = self.activePull
    local step = payload and payload.step
    if not pull or not step then return end
    pull.sequence.completed = pull.sequence.completed + 1
    local targetMs = tonumber(step.targetMs)
    local completedAtMs = tonumber(step.completedAtMs) or NowMs()
    if targetMs then pull.sequence.timing[#pull.sequence.timing + 1] = completedAtMs - targetMs end
    local key = Key(step.key)
    if key == "WARHORN" or key == "MAJOR_SLAYER" or key == "COLOSSUS" or key == "PILLAGER" or key == "NAZARAY" or key == "DAMAGE_ULTIMATES" then
        pull.sequence.supportExecutions[#pull.sequence.supportExecutions + 1] = {
            key = key,
            label = step.label or key,
            atMs = completedAtMs,
            cycle = tonumber(step.cycle) or 0,
        }
    end
end

function Analytics:OnSequenceMissed(payload)
    if not self.activePull then return end
    self.activePull.sequence.missed = self.activePull.sequence.missed + 1
end

function Analytics:OnSequenceSkipped(payload)
    if not self.activePull then return end
    self.activePull.sequence.skipped = self.activePull.sequence.skipped + 1
end

function Analytics:OnInterrupt(payload)
    if not self.activePull then return end
    self.activePull.interrupts = self.activePull.interrupts + 1
    self:SetRaidState("RECOVERY", "sequence interrupted")
end

function Analytics:OnEncounterModeChanged(snapshot)
    if not self.activePull or not snapshot then return end
    self.activePull.mode = snapshot.mode or self.activePull.mode
    self.activePull.encounterLabel = snapshot.encounterLabel or snapshot.bossName or self.activePull.encounterLabel
end

function Analytics:BuildEffectResults(pull)
    local results = {}
    for _, metric in pairs(pull.effects or {}) do
        local sampled = zo_max(1, tonumber(metric.sampledMs) or 1)
        local uptime = zo_clamp((metric.activeMs / sampled) * 100, 0, 100)
        local full = zo_clamp((metric.fullMs / sampled) * 100, 0, 100)
        local averageCoverage = metric.samples > 0 and zo_clamp((metric.coverageTotal / metric.samples) * 100, 0, 100) or 0
        results[#results + 1] = {
            key = metric.key,
            name = metric.name,
            effectType = metric.effectType,
            uptime = Round(uptime),
            fullCoverage = Round(full),
            averageCoverage = Round(averageCoverage),
            health = Round(metric.effectType == "BUFF" and ((uptime + averageCoverage) / 2) or uptime),
        }
    end
    table.sort(results, function(a, b)
        if a.health == b.health then return tostring(a.name) < tostring(b.name) end
        return a.health < b.health
    end)
    return results
end

function Analytics:BuildSynchronization(pull)
    local byCycle = {}
    for _, event in ipairs(pull.sequence.supportExecutions or {}) do
        local cycle = event.cycle > 0 and event.cycle or 1
        byCycle[cycle] = byCycle[cycle] or {}
        byCycle[cycle][#byCycle[cycle] + 1] = event
    end
    local windows = {}
    local totalScore = 0
    local count = 0
    for cycle, events in pairs(byCycle) do
        table.sort(events, function(a, b) return a.atMs < b.atMs end)
        if #events >= 2 then
            local spread = events[#events].atMs - events[1].atMs
            local score = zo_clamp(100 - (spread / 80), 0, 100)
            windows[#windows + 1] = { cycle = cycle, spreadMs = spread, score = Round(score), count = #events }
            totalScore = totalScore + score
            count = count + 1
        end
    end
    table.sort(windows, function(a, b) return a.cycle < b.cycle end)
    return { score = count > 0 and Round(totalScore / count) or nil, windows = windows }
end

function Analytics:BuildBurnAnalysis(pull, effects, synchronization)
    local required = { MAJOR_FORCE=true, MAJOR_SLAYER=true, MAJOR_VULNERABILITY=true, CRUSHER=true, MAJOR_BRITTLE=true }
    local total = 0
    local found = 0
    for _, effect in ipairs(effects) do
        if required[effect.key] then total = total + effect.health; found = found + 1 end
    end
    local effectScore = found > 0 and (total / found) or nil
    local syncScore = synchronization.score
    local score
    if effectScore and syncScore then score = Round((effectScore * 0.65) + (syncScore * 0.35))
    elseif effectScore then score = Round(effectScore)
    elseif syncScore then score = Round(syncScore) end
    return { score = score, effectScore = effectScore and Round(effectScore) or nil, synchronizationScore = syncScore }
end

function Analytics:FinalizePull(reason)
    local pull = self.activePull
    if not pull then return nil end
    self:SampleEffects(zo_clamp(NowMs() - (self.lastSampleAtMs or NowMs()), 0, 1000))
    pull.endedAtMs = NowMs()
    pull.durationMs = zo_max(0, pull.endedAtMs - pull.startedAtMs)
    pull.reason = reason or "combat ended"
    pull.effects = self:BuildEffectResults(pull)
    pull.synchronization = self:BuildSynchronization(pull)
    pull.burn = self:BuildBurnAnalysis(pull, pull.effects, pull.synchronization)
    local timingTotal = 0
    for _, timing in ipairs(pull.sequence.timing or {}) do timingTotal = timingTotal + math.abs(timing) end
    pull.rotation = {
        scheduled = pull.sequence.scheduled,
        completed = pull.sequence.completed,
        missed = pull.sequence.missed,
        skipped = pull.sequence.skipped,
        averageTimingMs = #pull.sequence.timing > 0 and Round(timingTotal / #pull.sequence.timing) or nil,
        health = pull.sequence.scheduled > 0 and Round((pull.sequence.completed / pull.sequence.scheduled) * 100) or nil,
    }
    pull.sequence.timing = nil
    pull.sequence.supportExecutions = nil
    self.lastReport = Copy(pull)
    self.activePull = nil
    self:SetRaidState("VICTORY", reason or "pull ended")

    if SRC.EventBus then SRC.EventBus:Publish("POST_PULL_REPORT_READY", { report = self.lastReport }) end
    if IsLead() and SRC.saved.postPullChatEnabled ~= false then self:PrintReportToChat(self.lastReport) end
    return self.lastReport
end

function Analytics:PrintReportToChat(report)
    if not report then return end
    local function Say(text)
        if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then CHAT_SYSTEM:AddMessage("|cFFD447Conductor|r " .. tostring(text))
        elseif d then d("Conductor " .. tostring(text)) end
    end
    Say(string.format("Pull Health: %s (%ds)", report.encounterLabel or "Pull", Round((report.durationMs or 0) / 1000)))
    if report.rotation.health then Say(string.format("Rotation %d%% | %d completed | %d missed | %d skipped", report.rotation.health, report.rotation.completed or 0, report.rotation.missed or 0, report.rotation.skipped or 0)) end
    if report.rotation.averageTimingMs then Say(string.format("Average sequence timing difference: %.1fs", report.rotation.averageTimingMs / 1000)) end
    if (report.interrupts or 0) > 0 then Say(string.format("Recovery interruptions: %d", report.interrupts or 0)) end
    if report.synchronization.score then Say(string.format("Synchronization %d%%", report.synchronization.score)) end
    if report.burn.score then Say(string.format("Burn Window %d%%", report.burn.score)) end
    local limit = zo_min(8, #(report.effects or {}))
    for index = 1, limit do
        local effect = report.effects[index]
        Say(string.format("%s: %d%% health | %d%% uptime", effect.name, effect.health, effect.uptime))
    end
end

function Analytics:GetLastReport()
    return self.lastReport
end

function Analytics:Initialize()
    if self.initialized then return end
    self.initialized = true
    self.pullCounter = 0
    self.raidState = "PREPARING"
    self.lastSampleAtMs = NowMs()
    EVENT_MANAGER:RegisterForUpdate(UPDATE_NAME, 250, function() Analytics:OnUpdate() end)
    EVENT_MANAGER:RegisterForEvent(UPDATE_NAME .. "Combat", EVENT_PLAYER_COMBAT_STATE, function(_, inCombat)
        if inCombat then
            Analytics.lastSampleAtMs = NowMs()
            Analytics:StartPull()
        else
            zo_callLater(function()
                if Analytics.activePull and not SRC.inCombat then Analytics:FinalizePull("combat ended") end
            end, 500)
        end
    end)
    if SRC.EventBus then
        SRC.EventBus:Subscribe("SEQUENCE_STEP_SCHEDULED", self, function(payload) Analytics:OnSequenceScheduled(payload) end)
        SRC.EventBus:Subscribe("SEQUENCE_STEP_COMPLETED", self, function(payload) Analytics:OnSequenceCompleted(payload) end)
        SRC.EventBus:Subscribe("SEQUENCE_STEP_MISSED", self, function(payload) Analytics:OnSequenceMissed(payload) end)
        SRC.EventBus:Subscribe("SEQUENCE_STEP_SKIPPED", self, function(payload) Analytics:OnSequenceSkipped(payload) end)
        SRC.EventBus:Subscribe("SEQUENCE_INTERRUPTED", self, function(payload) Analytics:OnInterrupt(payload) end)
        SRC.EventBus:Subscribe("ENCOUNTER_MODE_CHANGED", self, function(payload) Analytics:OnEncounterModeChanged(payload) end)
    end
end
