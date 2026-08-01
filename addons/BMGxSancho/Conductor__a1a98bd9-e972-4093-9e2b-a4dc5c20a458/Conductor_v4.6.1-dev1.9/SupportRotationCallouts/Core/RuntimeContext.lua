local C = Conductor
local SRC = SupportRotationCallouts
C.RuntimeContext = C.RuntimeContext or {}
local Runtime = C.RuntimeContext

Runtime.SCHEMA_VERSION = 1
Runtime.MODES = { INACTIVE="INACTIVE", TRANSITION="TRANSITION", TRASH="TRASH", BOSS="BOSS" }

local function NowMs() return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0 end
local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = Copy(item) end
    return result
end

function Runtime:NewState(reason)
    return {
        schemaVersion = self.SCHEMA_VERSION,
        revision = (self.state and tonumber(self.state.revision) or 0) + 1,
        generation = C.LiveSession and C.LiveSession:GetGeneration() or 0,
        rosterFingerprint = C.LiveSession and C.LiveSession:GetFingerprint() or "",
        sessionId = (C.RaidSession and C.RaidSession:GetActive() or {}).sessionId,
        mode = self.MODES.INACTIVE,
        encounter = { id=nil, state="INACTIVE", boss=nil },
        timeline = { running=false, revision=0 },
        responsibilities = {},
        effects = {},
        scheduler = { active=false, queueSize=0 },
        sequence = { active=false, stage="IDLE", pending={}, completed={}, failed={} },
        reason = tostring(reason or "runtime initialized"),
        updatedAtMs = NowMs(),
    }
end

function Runtime:Get() return self.state end
function Runtime:GetGeneration() return self.state and self.state.generation or 0 end
function Runtime:GetFingerprint() return self.state and self.state.rosterFingerprint or "" end
function Runtime:IsCurrent(generation, fingerprint, sessionId)
    local state = self.state
    if not state then return false end
    if tonumber(generation) ~= tonumber(state.generation) then return false end
    if tostring(fingerprint or "") ~= tostring(state.rosterFingerprint or "") then return false end
    if sessionId ~= nil and tostring(sessionId or "") ~= tostring(state.sessionId or "") then return false end
    return true
end

function Runtime:Publish(name, payload)
    if C.EventBus then C.EventBus:Publish(name, payload) end
end

function Runtime:Patch(section, patch, reason)
    if not self.state or type(patch) ~= "table" then return false end
    local target = self.state
    if section and section ~= "" then
        target[section] = target[section] or {}
        target = target[section]
    end
    for key, value in pairs(patch) do target[key] = Copy(value) end
    self.state.revision = (tonumber(self.state.revision) or 0) + 1
    self.state.updatedAtMs = NowMs()
    self.state.reason = tostring(reason or "runtime updated")
    self:Publish("RUNTIME_CONTEXT_CHANGED", { state=self.state, section=section, reason=reason })
    return true
end

function Runtime:SetMode(mode, reason)
    mode = self.MODES[mode] or mode
    if not self.MODES[mode] then return false end
    if self.state.mode == mode then return true end
    local previous = self.state.mode
    self:Patch(nil, { mode=mode }, reason or "execution mode changed")
    self:Publish("RUNTIME_MODE_CHANGED", { previous=previous, mode=mode, state=self.state, reason=reason })
    return true
end

function Runtime:Invalidate(reason)
    local previous = self.state
    self.state = self:NewState(reason or "runtime invalidated")
    self:Publish("RUNTIME_CONTEXT_INVALIDATED", { previous=previous, state=self.state, reason=reason })
    self:Publish("RUNTIME_CONTEXT_CHANGED", { state=self.state, reason=reason })
end

function Runtime:RefreshIdentity(reason)
    if not self.state then self.state = self:NewState(reason) end
    local session = C.RaidSession and C.RaidSession:GetActive() or nil
    local generation = C.LiveSession and C.LiveSession:GetGeneration() or 0
    local fingerprint = C.LiveSession and C.LiveSession:GetFingerprint() or ""
    local sessionId = session and session.sessionId or nil
    if generation ~= self.state.generation or fingerprint ~= self.state.rosterFingerprint or sessionId ~= self.state.sessionId then
        self:Invalidate(reason or "runtime identity changed")
        self.state.sessionId = sessionId
    end
end

function Runtime:RegisterEvents()
    if not C.EventBus then return end
    C.EventBus:Subscribe("LIVE_SESSION_CHANGED", self, function(payload)
        self:Invalidate((payload and payload.reason) or "live session changed")
    end)
    C.EventBus:Subscribe("RAID_SESSION_CREATED", self, function(payload)
        self:RefreshIdentity("raid session created")
    end)
    C.EventBus:Subscribe("RAID_SESSION_UPDATED", self, function(payload)
        self:RefreshIdentity("raid session updated")
    end)
    C.EventBus:Subscribe("RAID_SESSION_STATE_CHANGED", self, function(payload)
        self:RefreshIdentity("raid session state changed")
    end)
    C.EventBus:Subscribe("ENCOUNTER_STATE_CHANGED", self, function(payload)
        local state = payload and (payload.state or payload.nextState) or "INACTIVE"
        self:Patch("encounter", { state=state }, "encounter state changed")
    end)
    C.EventBus:Subscribe("TIMELINE_STARTED", self, function()
        self:Patch("timeline", { running=true, revision=(self.state.timeline.revision or 0)+1 }, "timeline started")
    end)
    C.EventBus:Subscribe("TIMELINE_STOPPED", self, function()
        self:Patch("timeline", { running=false, revision=(self.state.timeline.revision or 0)+1 }, "timeline stopped")
    end)
end

function Runtime:GetSnapshot() return Copy(self.state or {}) end
function Runtime:Initialize()
    self.state = self:NewState("initialize")
    self:RegisterEvents()
    self.initialized = true
end
