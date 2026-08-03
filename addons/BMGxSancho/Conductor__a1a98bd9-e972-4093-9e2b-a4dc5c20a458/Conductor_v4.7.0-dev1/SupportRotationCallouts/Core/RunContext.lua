local C = Conductor
local SRC = SupportRotationCallouts
C.RunContext = C.RunContext or {}
local Run = C.RunContext

Run.SCHEMA_VERSION = 1
Run.STATES = { OFF="OFF", READY="READY", SEARCHING="SEARCHING", HOSTING="HOSTING", JOINED="JOINED", LOCAL="LOCAL", ACTIVE="ACTIVE", PAUSED="PAUSED", ENDED="ENDED" }

local function NowMs() return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0 end
local function Normalize(name) return SRC.NormalizeAccountName and SRC:NormalizeAccountName(name or "") or tostring(name or "") end
local function Copy(value)
    if type(value) ~= "table" then return value end
    local out = {}
    for key, item in pairs(value) do out[key] = Copy(item) end
    return out
end

function Run:NewState(reason)
    return {
        schemaVersion = self.SCHEMA_VERSION,
        state = self.STATES.OFF,
        runId = "",
        revision = 0,
        hostAccount = "",
        trialId = "",
        difficulty = "",
        strategyId = "",
        rosterGeneration = C.LiveSession and C.LiveSession:GetGeneration() or 0,
        combatRole = tostring(SRC.saved and SRC.saved.combatRole or "DAMAGE"),
        trialLeadView = SRC.saved and SRC.saved.trialLeadView == true or false,
        assignmentRevision = 0,
        assignments = {},
        encounterId = "",
        phaseId = "",
        timelineStep = 0,
        sequenceRevision = 0,
        startedAtMs = 0,
        updatedAtMs = NowMs(),
        reason = tostring(reason or "initialized"),
    }
end

function Run:Publish(eventName, payload)
    if C.EventBus then C.EventBus:Publish(eventName, payload) end
end

function Run:Get() return self.state end
function Run:IsHost() return self.state and self.state.state == self.STATES.HOSTING end
function Run:IsActive() return self.state and (self.state.state == self.STATES.HOSTING or self.state.state == self.STATES.JOINED or self.state.state == self.STATES.LOCAL or self.state.state == self.STATES.ACTIVE) end
function Run:GetCombatRole() return tostring((self.state and self.state.combatRole) or (SRC.saved and SRC.saved.combatRole) or "DAMAGE") end
function Run:IsTrialLeadView() return (self.state and self.state.trialLeadView == true) or (SRC.saved and SRC.saved.trialLeadView == true) end

function Run:SetState(nextState, reason)
    if not self.STATES[nextState] then return false end
    local previous = self.state.state
    self.state.state = nextState
    self.state.updatedAtMs = NowMs()
    self.state.reason = tostring(reason or "state changed")
    self:Publish("RUN_CONTEXT_STATE_CHANGED", { previous=previous, state=nextState, run=self:GetSnapshot(), reason=reason })
    self:Publish("RUN_CONTEXT_CHANGED", { run=self:GetSnapshot(), reason=reason })
    return true
end

function Run:SetPersonalIdentity(combatRole, trialLeadView)
    combatRole = string.upper(tostring(combatRole or "DAMAGE"))
    if combatRole ~= "TANK" and combatRole ~= "HEALER" and combatRole ~= "DAMAGE" then combatRole = "DAMAGE" end
    self.state.combatRole = combatRole
    self.state.trialLeadView = trialLeadView == true
    if SRC.saved then
        SRC.saved.combatRole = combatRole
        SRC.saved.trialLeadView = trialLeadView == true
        -- Compatibility only. Runtime filtering no longer treats this as authority.
        SRC.saved.displayRole = self.state.trialLeadView and "lead" or ((combatRole == "DAMAGE") and "dd" or "support")
    end
    self:Publish("RUN_PERSONAL_IDENTITY_CHANGED", { combatRole=combatRole, trialLeadView=self.state.trialLeadView })
end

function Run:GenerateRunId()
    local account = Normalize(GetDisplayName and GetDisplayName() or "player"):gsub("[^%w]", "")
    local now = NowMs()
    return string.format("CD-%s-%d", account ~= "" and account or "HOST", now)
end

function Run:Host(header)
    header = header or {}
    self.state = self:NewState("host run")
    self.state.state = self.STATES.HOSTING
    self.state.runId = tostring(header.runId or self:GenerateRunId())
    self.state.hostAccount = Normalize(GetDisplayName and GetDisplayName() or "")
    self.state.trialId = tostring(header.trialId or (SRC.saved and SRC.saved.profileDraftInstance) or "")
    self.state.difficulty = tostring(header.difficulty or (SRC.saved and SRC.saved.profileDraftDifficulty) or "veteran")
    self.state.strategyId = tostring(header.strategyId or (SRC.saved and SRC.saved.raidPlanStrategyId) or "")
    self.state.revision = 1
    self.state.rosterGeneration = C.LiveSession and C.LiveSession:GetGeneration() or 0
    self.state.startedAtMs = NowMs()
    self:SetPersonalIdentity(SRC.saved and SRC.saved.combatRole, SRC.saved and SRC.saved.trialLeadView)
    self:Publish("RUN_CONTEXT_HOSTED", { run=self:GetSnapshot() })
    self:Publish("RUN_CONTEXT_CHANGED", { run=self:GetSnapshot(), reason="hosted" })
    return self.state
end

function Run:Join(header)
    if type(header) ~= "table" or tostring(header.runId or "") == "" then return false, "invalid run header" end
    self.state = self:NewState("join run")
    self.state.state = self.STATES.JOINED
    self.state.runId = tostring(header.runId)
    self.state.hostAccount = Normalize(header.hostAccount)
    self.state.trialId = tostring(header.trialId or "")
    self.state.difficulty = tostring(header.difficulty or "")
    self.state.strategyId = tostring(header.strategyId or "")
    self.state.revision = tonumber(header.revision) or 1
    self.state.rosterGeneration = C.LiveSession and C.LiveSession:GetGeneration() or 0
    self.state.startedAtMs = tonumber(header.startedAtMs) or NowMs()
    self:SetPersonalIdentity(SRC.saved and SRC.saved.combatRole, SRC.saved and SRC.saved.trialLeadView)
    self:Publish("RUN_CONTEXT_JOINED", { run=self:GetSnapshot() })
    self:Publish("RUN_CONTEXT_CHANGED", { run=self:GetSnapshot(), reason="joined" })
    return true
end

function Run:StartLocal(reason)
    self.state = self:NewState(reason or "local run")
    self.state.state = self.STATES.LOCAL
    self.state.runId = self:GenerateRunId()
    self.state.hostAccount = Normalize(GetDisplayName and GetDisplayName() or "")
    self.state.trialId = tostring(SRC.saved and SRC.saved.profileDraftInstance or "")
    self.state.difficulty = tostring(SRC.saved and SRC.saved.profileDraftDifficulty or "veteran")
    self.state.strategyId = tostring(SRC.saved and SRC.saved.raidPlanStrategyId or "")
    self.state.startedAtMs = NowMs()
    self:SetPersonalIdentity(SRC.saved and SRC.saved.combatRole, SRC.saved and SRC.saved.trialLeadView)
    self:Publish("RUN_CONTEXT_LOCAL_STARTED", { run=self:GetSnapshot() })
    self:Publish("RUN_CONTEXT_CHANGED", { run=self:GetSnapshot(), reason="local" })
    return self.state
end

function Run:ApplyAssignments(assignments, revision)
    self.state.assignments = Copy(assignments or {})
    self.state.assignmentRevision = tonumber(revision) or ((tonumber(self.state.assignmentRevision) or 0) + 1)
    self.state.revision = (tonumber(self.state.revision) or 0) + 1
    self:Publish("RUN_ASSIGNMENTS_CHANGED", { assignments=Copy(self.state.assignments), revision=self.state.assignmentRevision, runId=self.state.runId })
end

function Run:ApplyCheckpoint(checkpoint)
    if type(checkpoint) ~= "table" then return false end
    if checkpoint.runId and tostring(checkpoint.runId) ~= tostring(self.state.runId) then return false end
    self.state.encounterId = tostring(checkpoint.encounterId or self.state.encounterId or "")
    self.state.phaseId = tostring(checkpoint.phaseId or self.state.phaseId or "")
    self.state.timelineStep = tonumber(checkpoint.timelineStep) or self.state.timelineStep or 0
    self.state.sequenceRevision = tonumber(checkpoint.sequenceRevision) or self.state.sequenceRevision or 0
    self.state.updatedAtMs = NowMs()
    self:Publish("RUN_CHECKPOINT_CHANGED", { checkpoint=Copy(checkpoint), run=self:GetSnapshot() })
    return true
end

function Run:Stop(reason)
    local previous = self:GetSnapshot()
    self.state = self:NewState(reason or "stopped")
    self.state.state = self.STATES.ENDED
    if C.TimelineEngine then C.TimelineEngine:Clear(reason or "run stopped") end
    if C.RuntimeContext then C.RuntimeContext:Invalidate(reason or "run stopped") end
    self:Publish("RUN_CONTEXT_ENDED", { previous=previous, reason=reason })
    self:Publish("RUN_CONTEXT_CHANGED", { run=self:GetSnapshot(), reason=reason })
end

function Run:GetSnapshot() return Copy(self.state or {}) end

function Run:RegisterEvents()
    if not C.EventBus then return end
    C.EventBus:Subscribe("LIVE_SESSION_CHANGED", self, function(payload)
        if self:IsActive() then self:Stop((payload and payload.reason) or "roster changed") end
    end)
    C.EventBus:Subscribe("ENCOUNTER_STATE_CHANGED", self, function(payload)
        if not self:IsActive() then return end
        local state = tostring(payload and (payload.state or payload.nextState) or "")
        self.state.phaseId = state
        self.state.updatedAtMs = NowMs()
    end)
end

function Run:Initialize()
    self.state = self:NewState("initialize")
    self:SetPersonalIdentity(SRC.saved and SRC.saved.combatRole, SRC.saved and SRC.saved.trialLeadView)
    self:RegisterEvents()
    self.initialized = true
end
