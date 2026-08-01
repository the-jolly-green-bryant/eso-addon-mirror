local C = Conductor
local SRC = SupportRotationCallouts
SRC.EncounterSequenceEngine = SRC.EncounterSequenceEngine or {}
C.EncounterSequenceEngine = SRC.EncounterSequenceEngine
local Sequence = SRC.EncounterSequenceEngine

Sequence.PRIORITY = { LOW=10, ROTATION=20, ENCOUNTER=30, CRITICAL=40 }
Sequence.STATE = { IDLE="IDLE", RUNNING="RUNNING", PAUSED="PAUSED", INTERRUPTED="INTERRUPTED", COMPLETE="COMPLETE" }

local function NowMs()
    return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
end

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = Copy(item) end
    return result
end

local function Key(value)
    return string.upper(tostring(value or "")):gsub("[^A-Z0-9]+", "_")
end

local function NormalizeAccount(value)
    if SRC.NormalizeAccountName then return SRC:NormalizeAccountName(value or "") end
    return string.lower(tostring(value or ""))
end

local DEFAULT_PACKAGES = {
    STANDARD_BURN = {
        key = "STANDARD_BURN",
        steps = {
            { key="BURN", label="DPS BURN", offsetSeconds=0, lane="RAID", audiences={"all"}, priority="ENCOUNTER" },
            { key="MAJOR_SLAYER", label="Slayer", offsetSeconds=0, lane="SUPPORT", audiences={"trial_lead","assigned"}, responsibilityKey="MAJOR_SLAYER", enabledSetting="majorSlayerEnabled" },
            { key="WARHORN", label="Horn", offsetSeconds=1.0, lane="SUPPORT", audiences={"trial_lead","assigned"}, responsibilityKey="WARHORN", enabledSetting="warhornEnabled" },
            { key="COLOSSUS", label="Colossus", offsetSeconds=1.85, lane="SUPPORT", audiences={"trial_lead","assigned"}, responsibilityKey="COLOSSUS", enabledSetting="colossusEnabled" },
            { key="DAMAGE_ULTIMATES", label="DPS BURN", offsetSeconds=3.2, lane="RAID", audiences={"trial_lead","dd"}, priority="ENCOUNTER" },
            { key="PILLAGER", label="Pillager", offsetSeconds=4.4, lane="SUPPORT", audiences={"trial_lead","assigned"}, responsibilityKey="PILLAGER", enabledSetting="pillagerEnabled" },
            { key="NAZARAY", label="Nazaray", offsetSeconds=5.3, lane="SUPPORT", audiences={"trial_lead","assigned"}, responsibilityKey="NAZARAY", enabledSetting="nazarayEnabled" },
        },
    },
    DEFENSIVE_RECOVERY = {
        key = "DEFENSIVE_RECOVERY",
        steps = {
            { key="BARRIER", label="Barrier", offsetSeconds=0, lane="SUPPORT", audiences={"trial_lead","assigned"}, responsibilityKey="BARRIER", enabledSetting="barrierEnabled", priority="CRITICAL" },
            { key="RECOVERY", label="Recovery", offsetSeconds=2, lane="RAID", audiences={"all"}, priority="CRITICAL" },
            { key="RESUME", label="Resume", offsetSeconds=5, lane="RAID", audiences={"all"}, priority="ENCOUNTER" },
        },
    },
}

local RESPONSIBILITY_ROTATIONS = {
    WARHORN = { count="warhornRotationCount", list="warhornRotation" },
    COLOSSUS = { count="rotationCount", list="rotation" },
    BARRIER = { count="barrierRotationCount", list="barrierRotation" },
    MAJOR_SLAYER = { count="roaringOpportunistRotationCount", list="roaringOpportunistRotation" },
    PILLAGER = { count="pillagerRotationCount", list="pillagerRotation" },
    NAZARAY = { count="nazarayRotationCount", list="nazarayRotation" },
}

function Sequence:Initialize()
    self.state = self.STATE.IDLE
    self.profile = nil
    self.sequence = nil
    self.steps = {}
    self.cursor = 1
    self.startedAtMs = nil
    self.pauseStartedAtMs = nil
    self.interruptStack = {}
    self.completed = {}
    self.failed = {}
    self.revision = 0
    self.assignmentCursor = {}
    self.triggerSignals = {}
    self.packages = Copy(DEFAULT_PACKAGES)
    self.updateName = (SRC.name or "Conductor") .. "EncounterSequence"
    self.updateRegistered = false
    self:RegisterEventBus()
end

function Sequence:StartUpdateLoop()
    if self.updateRegistered then return end
    EVENT_MANAGER:RegisterForUpdate(self.updateName, 200, function() Sequence:Update() end)
    self.updateRegistered = true
    if C.RuntimeContext then C.RuntimeContext:Patch("scheduler", {active=true, queueSize=#(self.steps or {})}, "sequence loop started") end
end

function Sequence:StopUpdateLoop(reason)
    if self.updateRegistered then EVENT_MANAGER:UnregisterForUpdate(self.updateName) end
    self.updateRegistered = false
    if C.RuntimeContext then C.RuntimeContext:Patch("scheduler", {active=false, queueSize=0}, reason or "sequence loop stopped") end
end

function Sequence:RegisterEventBus()
    if not C.EventBus then return end
    C.EventBus:Subscribe("ENCOUNTER_MECHANIC_OBSERVED", self, function(payload)
        if not payload then return end
        local priority = payload.blocksBurn and "CRITICAL" or "ENCOUNTER"
        self:Interrupt({
            key = payload.key or "MECHANIC",
            label = payload.key or "Mechanic",
            durationSeconds = payload.durationSeconds or 0,
            priority = priority,
            audiences = {"all"},
        })
    end)
    C.EventBus:Subscribe("TIMELINE_EVENT_EXECUTED", self, function(payload)
        local event = payload and payload.event
        if event and event.sequenceStepId then self:CompleteStep(event.sequenceStepId, "observed ability") end
    end)
    C.EventBus:Subscribe("ENCOUNTER_SIGNAL_OBSERVED", self, function(payload)
        if payload then self:ObserveTrigger("SIGNAL", payload.key or payload.id, payload) end
    end)
    C.EventBus:Subscribe("ENCOUNTER_STATE_CHANGED", self, function(payload)
        local state = payload and (payload.state or payload.nextState)
        -- Boss unit tags and encounter-state observations can briefly report
        -- INACTIVE or COMPLETE during portals, floor changes, immunity, and
        -- wipe/re-entry transitions. Never erase the active sequence while the
        -- raid is still in combat or the boss lifecycle is still owned by the
        -- Encounter Engine. EncounterEngine:ExitBoss performs the authoritative
        -- reset once combat has actually ended.
        if (state == "COMPLETE" or state == "INACTIVE")
            and not SRC.inCombat
            and not SRC.bossEncounterActive
            and (not SRC.EncounterEngine or SRC.EncounterEngine.mode ~= SRC.EncounterEngine.MODE_BOSS) then
            self:Reset("encounter state " .. tostring(state))
        end
    end)
end

function Sequence:RegisterPackage(key, definition)
    key = Key(key)
    if key == "" or type(definition) ~= "table" then return false end
    self.packages[key] = Copy(definition)
    self.packages[key].key = key
    return true
end

function Sequence:GetPackage(key)
    return self.packages[Key(key)]
end

function Sequence:ResolveAssignedAccount(responsibilityKey, explicitAccount)
    if explicitAccount and explicitAccount ~= "" then return NormalizeAccount(explicitAccount) end
    -- The active Raid Session is the authoritative assignment source. Legacy
    -- saved rotations remain only as a compatibility fallback for sessions
    -- created before responsibility ownership was stored in RaidSession.
    if C.ExecutionPlanCompiler and C.ExecutionPlanCompiler.ResolveOwner then
        local owner = C.ExecutionPlanCompiler:ResolveOwner(responsibilityKey)
        if owner and owner ~= "" then return NormalizeAccount(owner) end
    end
    local key = Key(responsibilityKey)
    local mapping = RESPONSIBILITY_ROTATIONS[key]
    if not mapping or not SRC.saved then return "" end
    local list = SRC.saved[mapping.list] or {}
    local count = zo_max(1, tonumber(SRC.saved[mapping.count]) or 1)
    local cursor = (tonumber(self.assignmentCursor[key]) or 0) + 1
    if cursor > count then cursor = 1 end
    self.assignmentCursor[key] = cursor
    return NormalizeAccount(list[cursor] or "")
end

function Sequence:ExpandPackage(packageKey, baseOffsetSeconds, overrides)
    local package = self:GetPackage(packageKey)
    if not package then return {} end
    local result = {}
    for _, source in ipairs(package.steps or {}) do
        if not source.enabledSetting or not SRC.saved or SRC.saved[source.enabledSetting] ~= false then
            local step = Copy(source)
            step.offsetSeconds = (tonumber(baseOffsetSeconds) or 0) + (tonumber(step.offsetSeconds) or 0)
            if type(overrides) == "table" then
                for key, value in pairs(overrides) do step[key] = Copy(value) end
            end
            result[#result + 1] = step
        end
    end
    return result
end

function Sequence:BuildSteps(profile)
    local steps = {}
    if C.ExecutionPlanCompiler and C.ExecutionPlanCompiler.Compile then
        steps = C.ExecutionPlanCompiler:Compile(profile) or {}
    end

    -- No encounter profile may fabricate repeating burn cycles. An incomplete
    -- profile produces no predicted burn package and remains visible through
    -- diagnostics until objective burn-window guidance is added.
    for index, step in ipairs(steps) do
        step.id = step.id or ((profile and profile.id or "ENCOUNTER") .. "-STEP-" .. tostring(index))
        step.key = Key(step.key or step.responsibilityKey or step.label)
        step.priorityValue = self.PRIORITY[Key(step.priority or "ROTATION")] or self.PRIORITY.ROTATION
        step.leadTimeSeconds = tonumber(step.leadTimeSeconds) or 3
        step.fallbackSeconds = tonumber(step.fallbackSeconds) or 3.5
        step.status = "WAITING"
        step.assignedAccount = self:ResolveAssignedAccount(step.responsibilityKey, step.assignedAccount)
    end
    return steps
end

function Sequence:Start(profile, reason)
    self:Reset("start replacement")
    self.profile = profile or {}
    self.steps = self:BuildSteps(self.profile)
    self.sequence = { id=self.profile.id or "PROVISIONAL", reason=reason or "encounter started" }
    self.startedAtMs = NowMs()
    self.cursor = 1
    self.state = self.STATE.RUNNING
    self.revision = self.revision + 1
    self.runtimeGeneration = C.RuntimeContext and C.RuntimeContext:GetGeneration() or (C.LiveSession and C.LiveSession:GetGeneration() or 0)
    self.runtimeFingerprint = C.RuntimeContext and C.RuntimeContext:GetFingerprint() or (C.LiveSession and C.LiveSession:GetFingerprint() or "")
    self.runtimeSessionId = (C.RaidSession and C.RaidSession:GetActive() or {}).sessionId
    self:StartUpdateLoop()
    if C.TimelineEngine then
        C.TimelineEngine:Clear("sequence start")
        C.TimelineEngine:Start("encounter sequence")
    end
    -- A recognized boss must never produce a silent Timeline. When authored
    -- guidance is incomplete, show a truthful waiting state rather than nothing.
    if #self.steps == 0 and C.TimelineEngine then
        C.TimelineEngine:AddEvent({
            key="PREPARE_BURN", label="Strategy Guidance Pending", targetMs=NowMs(),
            lane="MECHANIC", audiences={"all"}, persistentInstruction=true,
            autoComplete=false, confidence="PROVISIONAL", leadTimeSeconds=1,
        })
    end
    self:Publish("SEQUENCE_STARTED", { reason=reason, profileId=self.profile.id, stepCount=#self.steps })
    return true
end

function Sequence:Reset(reason)
    self:StopUpdateLoop(reason or "sequence reset")
    self.state = self.STATE.IDLE
    self.profile = nil
    self.sequence = nil
    self.steps = {}
    self.cursor = 1
    self.startedAtMs = nil
    self.pauseStartedAtMs = nil
    self.interruptStack = {}
    self.completed = {}
    self.failed = {}
    self.assignmentCursor = {}
    self.triggerSignals = {}
    self.revision = (tonumber(self.revision) or 0) + 1
    if C.TimelineEngine then C.TimelineEngine:Clear(reason or "sequence reset") end
    self:Publish("SEQUENCE_RESET", { reason=reason })
end

function Sequence:Publish(eventName, payload)
    payload = payload or {}
    payload.state = self.state
    payload.revision = self.revision
    if C.EventBus then C.EventBus:Publish(eventName, payload) end
end

function Sequence:ObserveTrigger(triggerType, key, payload)
    triggerType = Key(triggerType)
    key = Key(key)
    if triggerType == "" then return false end
    self.triggerSignals[triggerType] = self.triggerSignals[triggerType] or {}
    self.triggerSignals[triggerType][key ~= "" and key or "ANY"] = {
        observedAtMs = NowMs(),
        payload = Copy(payload),
    }
    self:Publish("SEQUENCE_TRIGGER_OBSERVED", { triggerType=triggerType, key=key, payload=payload })
    return true
end

function Sequence:IsStepTriggered(step, now)
    local trigger = step and step.trigger
    if not trigger then return true end
    if type(trigger) == "string" then trigger = { type=trigger } end
    local triggerType = Key(trigger.type or trigger.triggerType or "TIMER")
    if triggerType == "TIMER" then
        return now >= self.startedAtMs + math.floor((tonumber(trigger.offsetSeconds or step.offsetSeconds) or 0) * 1000)
    elseif triggerType == "BOSS_HEALTH" then
        local context = SRC.EncounterEngine and SRC.EncounterEngine:GetExecutionContext() or {}
        local health = tonumber(context.lowestBossHealth)
        local threshold = tonumber(trigger.value or trigger.percent)
        return health and threshold and health <= threshold
    elseif triggerType == "ENCOUNTER_STATE" then
        local state = SRC.EncounterStateEngine and SRC.EncounterStateEngine.state or ""
        return Key(state) == Key(trigger.value or trigger.state)
    elseif triggerType == "AFTER_STEP" then
        local dependencyId = tostring(trigger.stepId or trigger.value or "")
        for _, dependency in ipairs(self.steps or {}) do
            if dependency.id == dependencyId then
                if dependency.status == "COMPLETE" or dependency.status == "MISSED" or dependency.status == "SKIPPED" then
                    local completedAt = tonumber(dependency.completedAtMs or dependency.missedAtMs or dependency.skippedAtMs or now)
                    return now >= completedAt + math.floor((tonumber(trigger.delaySeconds) or 0) * 1000)
                end
                return false
            end
        end
        return false
    elseif triggerType == "SIGNAL" then
        local bucket = self.triggerSignals.SIGNAL or {}
        return bucket[Key(trigger.key or trigger.value)] ~= nil or bucket.ANY ~= nil
    end
    local bucket = self.triggerSignals[triggerType] or {}
    return bucket[Key(trigger.key or trigger.value)] ~= nil or bucket.ANY ~= nil
end

function Sequence:ReassignStep(step, reason)
    if not step or not step.responsibilityKey then return false end
    local previous = step.assignedAccount
    step.assignedAccount = self:ResolveAssignedAccount(step.responsibilityKey, nil)
    if step.assignedAccount == previous then
        step.assignedAccount = self:ResolveAssignedAccount(step.responsibilityKey, nil)
    end
    local event = C.TimelineEngine and C.TimelineEngine.byId and C.TimelineEngine.byId[step.timelineEventId]
    if event then event.assignedAccount = step.assignedAccount end
    self:Publish("SEQUENCE_STEP_REASSIGNED", { step=step, previousAccount=previous, reason=reason })
    return step.assignedAccount ~= ""
end

function Sequence:BroadcastManualCommand(command, payload)
    -- The command stream is intentionally routed through EventBus so local and
    -- future network transports consume the same validated command object.
    local packet = { command=Key(command), payload=Copy(payload), sender=GetDisplayName and GetDisplayName() or "", sentAtMs=NowMs() }
    self:Publish("SEQUENCE_COMMAND_BROADCAST", packet)
    return self:ManualCommand(packet.command, packet.payload)
end

function Sequence:ScheduleStep(step)
    if not step or step.status ~= "WAITING" then return end
    local targetMs = tonumber(step.triggeredAtMs)
        or (self.startedAtMs + math.floor((tonumber(step.offsetSeconds) or 0) * 1000))
    step.targetMs = targetMs
    step.status = "SCHEDULED"
    if C.TimelineEngine then
        step.timelineEventId = C.TimelineEngine:AddEvent({
            key = step.key,
            label = step.label or step.key,
            targetMs = targetMs,
            lane = step.lane or "RAID",
            audiences = step.audiences,
            assignedAccount = step.assignedAccount,
            personalHighlight = NormalizeAccount(step.assignedAccount) == NormalizeAccount(GetDisplayName and GetDisplayName() or ""),
            displayAssignedText = NormalizeAccount(step.assignedAccount) == NormalizeAccount(GetDisplayName and GetDisplayName() or "") and "YOU" or nil,
            sequenceStepId = step.id,
            priority = step.priorityValue,
            windowId = step.windowId,
            windowType = step.windowType,
            confidence = step.confidence,
            responsibilityKey = step.responsibilityKey,
            confirmationKey = step.confirmationKey,
            leadTimeSeconds = step.leadTimeSeconds,
        })
    end
    self:Publish("SEQUENCE_STEP_SCHEDULED", { step=step })
end

function Sequence:CompleteStep(stepId, reason)
    for _, step in ipairs(self.steps) do
        if step.id == stepId and step.status ~= "COMPLETE" then
            step.status = "COMPLETE"
            step.completedAtMs = NowMs()
            self.completed[step.id] = true
            self:Publish("SEQUENCE_STEP_COMPLETED", { step=step, reason=reason })
            return true
        end
    end
    return false
end

function Sequence:Pause(reason)
    if self.state ~= self.STATE.RUNNING then return false end
    self.state = self.STATE.PAUSED
    self.pauseStartedAtMs = NowMs()
    self:Publish("SEQUENCE_PAUSED", { reason=reason })
    return true
end

function Sequence:Resume(reason)
    if self.state ~= self.STATE.PAUSED and self.state ~= self.STATE.INTERRUPTED then return false end
    local now = NowMs()
    if self.pauseStartedAtMs and self.startedAtMs then
        self.startedAtMs = self.startedAtMs + (now - self.pauseStartedAtMs)
        for _, step in ipairs(self.steps) do
            if step.status == "SCHEDULED" then
                step.targetMs = (step.targetMs or now) + (now - self.pauseStartedAtMs)
                local event = C.TimelineEngine and C.TimelineEngine.byId and C.TimelineEngine.byId[step.timelineEventId]
                if event then event.targetMs = step.targetMs end
            end
        end
    end
    self.pauseStartedAtMs = nil
    self.state = self.STATE.RUNNING
    self:Publish("SEQUENCE_RESUMED", { reason=reason })
    return true
end

function Sequence:Interrupt(data)
    if self.state ~= self.STATE.RUNNING and self.state ~= self.STATE.PAUSED then return false end
    data = Copy(data or {})
    data.priorityValue = self.PRIORITY[Key(data.priority or "ENCOUNTER")] or self.PRIORITY.ENCOUNTER
    data.startedAtMs = NowMs()
    data.endsAtMs = data.startedAtMs + math.floor((tonumber(data.durationSeconds) or 0) * 1000)
    self.interruptStack[#self.interruptStack + 1] = data
    table.sort(self.interruptStack, function(a,b) return a.priorityValue > b.priorityValue end)
    if self.state == self.STATE.RUNNING then self.pauseStartedAtMs = data.startedAtMs end
    self.state = self.STATE.INTERRUPTED
    if C.TimelineEngine then
        C.TimelineEngine:AddEvent({ key=data.key, label=data.label, targetMs=data.startedAtMs, lane="MECHANIC", audiences=data.audiences or {"all"}, isMechanic=true, priority=data.priorityValue })
    end
    self:Publish("SEQUENCE_INTERRUPTED", { interrupt=data })
    return true
end

function Sequence:Advance(reason)
    local step = self.steps[self.cursor]
    if not step then return false end
    if step.status ~= "COMPLETE" then self:CompleteStep(step.id, reason or "manual advance") end
    self.cursor = self.cursor + 1
    return true
end

function Sequence:Skip(reason)
    local step = self.steps[self.cursor]
    if not step then return false end
    step.status = "SKIPPED"
    step.skippedAtMs = NowMs()
    self:Publish("SEQUENCE_STEP_SKIPPED", { step=step, reason=reason })
    self.cursor = self.cursor + 1
    return true
end

function Sequence:ManualCommand(command, payload)
    command = Key(command)
    if command == "BURN_NOW" then
        local baseProfile = self.profile or { id="MANUAL" }
        local window = {
            id="MANUAL_BURN_" .. tostring(self.revision), type="FULL_BURN", label="FULL BURN",
            trigger={type="TIMER",offsetSeconds=0}, prewarnSeconds=1, confidence="MANUAL",
        }
        local steps = C.ExecutionPlanCompiler and C.ExecutionPlanCompiler:CompileWindow(baseProfile, window, 1) or {}
        local base = NowMs()
        for _, step in ipairs(steps) do
            step.status = "WAITING"
            step.assignedAccount = self:ResolveAssignedAccount(step.responsibilityKey, step.assignedAccount)
            step.offsetSeconds = ((base - (self.startedAtMs or base)) / 1000)
            self.steps[#self.steps + 1] = step
        end
        self:Publish("SEQUENCE_MANUAL_COMMAND", { command=command, stepCount=#steps })
        return #steps > 0
    elseif command == "HOLD" then return self:Pause("manual hold")
    elseif command == "RESUME" then return self:Resume("manual resume")
    elseif command == "SKIP" then return self:Skip("manual skip")
    elseif command == "ADVANCE" or command == "ADVANCE_PHASE" then return self:Advance("manual advance")
    elseif command == "RESET" then self:Reset("manual reset"); return true end
    return false
end

function Sequence:UpdateInterrupts(now)
    if self.state ~= self.STATE.INTERRUPTED then return end
    local active = {}
    for _, interrupt in ipairs(self.interruptStack) do
        if interrupt.endsAtMs > now then active[#active + 1] = interrupt end
    end
    self.interruptStack = active
    if #active == 0 then self:Resume("interrupt completed") end
end

function Sequence:Update()
    if C.RuntimeContext and not C.RuntimeContext:IsCurrent(self.runtimeGeneration, self.runtimeFingerprint, self.runtimeSessionId) then
        self:Reset("runtime context invalidated")
        return
    end
    local now = NowMs()
    self:UpdateInterrupts(now)
    if self.state ~= self.STATE.RUNNING or not self.startedAtMs then return end

    local scheduleHorizonMs = 22000
    for _, step in ipairs(self.steps) do
        if step.status == "WAITING" then
            local targetMs = self.startedAtMs + math.floor((tonumber(step.offsetSeconds) or 0) * 1000)
            local triggerReady = self:IsStepTriggered(step, now)
            local timerTrigger = not step.trigger or Key(type(step.trigger) == "table" and step.trigger.type or step.trigger) == "TIMER"
            if triggerReady and (not timerTrigger or targetMs - now <= scheduleHorizonMs) then
                if not timerTrigger then
                    step.offsetSeconds = (now - self.startedAtMs) / 1000
                    step.triggeredAtMs = now + math.floor((tonumber(step.releaseDelaySeconds) or 0) * 1000)
                end
                self:ScheduleStep(step)
            elseif timerTrigger and targetMs - now <= scheduleHorizonMs then
                self:ScheduleStep(step)
            end
        end
        if step.status == "SCHEDULED" and now >= (step.targetMs or now) + math.floor((tonumber(step.fallbackSeconds) or 3.5) * 1000) then
            if step.autoComplete == true then
                self:CompleteStep(step.id, "instruction window released")
            else
                step.status = "MISSED"
                step.missedAtMs = now
                self.failed[step.id] = true
                self:Publish("SEQUENCE_STEP_MISSED", { step=step, reason="confirmation fallback expired" })
            end
        end
    end

    while self.steps[self.cursor] and (self.steps[self.cursor].status == "COMPLETE" or self.steps[self.cursor].status == "SKIPPED" or self.steps[self.cursor].status == "MISSED") do
        self.cursor = self.cursor + 1
    end

    if #self.steps > 0 and self.cursor > #self.steps then
        self.state = self.STATE.COMPLETE
        self:StopUpdateLoop("sequence completed")
        self:Publish("SEQUENCE_COMPLETED", { profileId=self.profile and self.profile.id })
    end
end

function Sequence:GetSnapshot()
    return {
        state = self.state,
        profileId = self.profile and self.profile.id or nil,
        cursor = self.cursor,
        stepCount = #self.steps,
        completedCount = (function() local count=0 for _ in pairs(self.completed) do count=count+1 end return count end)(),
        failedCount = (function() local count=0 for _ in pairs(self.failed) do count=count+1 end return count end)(),
        interruptCount = #self.interruptStack,
        revision = self.revision,
    }
end
