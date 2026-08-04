local C = Conductor
C.RaidSession = C.RaidSession or {}
local RaidSession = C.RaidSession

RaidSession.SCHEMA_VERSION = 2
RaidSession.MODES = { ROSTERED = "ROSTERED", PROG_TEAM = "PROG_TEAM" }
RaidSession.STATES = {
    CREATED = "CREATED",
    PREPARING = "PREPARING",
    SHARED = "SHARED",
    ACTIVE = "ACTIVE",
    TRANSITION = "TRANSITION",
    PAUSED = "PAUSED",
    COMPLETED = "COMPLETED",
    ARCHIVED = "ARCHIVED",
}

local VALID_MODES = { ROSTERED=true, PROG_TEAM=true }
local VALID_STATES = { CREATED=true, PREPARING=true, SHARED=true, ACTIVE=true, TRANSITION=true, PAUSED=true, COMPLETED=true, ARCHIVED=true }

local function NowMs()
    return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0
end

local function Copy(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for key, item in pairs(value) do output[key] = Copy(item) end
    return output
end

local function GenerateId(hostAccount)
    local host = C.NormalizeAccountName and C:NormalizeAccountName(hostAccount or GetDisplayName()) or tostring(hostAccount or "")
    return string.format("RS-%s-%d", string.gsub(host, "[^%w]", ""), NowMs())
end

function RaidSession:New(config)
    config = config or {}
    local mode = VALID_MODES[config.mode] and config.mode or self.MODES.ROSTERED
    local host = C.NormalizeAccountName and C:NormalizeAccountName(config.hostAccount or GetDisplayName()) or tostring(config.hostAccount or "")
    local timestamp = NowMs()
    return {
        schemaVersion = self.SCHEMA_VERSION,
        sessionId = config.sessionId or GenerateId(host),
        sessionVersion = tonumber(config.sessionVersion) or 1,
        mode = mode,
        hostAccount = host,
        createdAt = tonumber(config.createdAt) or timestamp,
        updatedAt = timestamp,
        state = self.STATES.CREATED,
        trial = config.trial,
        difficulty = config.difficulty,
        objective = config.objective,
        strategy = config.strategy,
        players = Copy(config.players or {}),
        assignments = Copy(config.assignments or {}),
        responsibilities = Copy(config.responsibilities or {}),
        synchronization = Copy(config.synchronization or { accepted={}, pending={}, declined={}, disconnected={}, incompatible={}, outdated={} }),
        runtime = Copy(config.runtime or { encounter=nil, encounterState="INACTIVE", executionMode="INACTIVE", generation=0, rosterFingerprint="" }),
        sourceProfileId = config.sourceProfileId,
    }
end

function RaidSession:Create(config)
    if self.active then self:Archive("replaced by new raid session") end
    self.active = self:New(config)
    if C.EventBus then C.EventBus:Publish("RAID_SESSION_CREATED", { session=self.active }) end
    return self.active
end

function RaidSession:GetActive()
    return self.active
end

function RaidSession:HasActive()
    return self.active ~= nil and self.active.state ~= self.STATES.ARCHIVED
end

function RaidSession:Update(patch, reason)
    local session = self.active
    if not session or type(patch) ~= "table" then return nil end
    for key, value in pairs(patch) do
        if key ~= "sessionId" and key ~= "schemaVersion" and key ~= "createdAt" then
            session[key] = Copy(value)
        end
    end
    session.sessionVersion = (tonumber(session.sessionVersion) or 0) + 1
    session.updatedAt = NowMs()
    if C.EventBus then C.EventBus:Publish("RAID_SESSION_UPDATED", { session=session, reason=reason }) end
    return session
end

function RaidSession:Transition(nextState, reason)
    if not self.active or not VALID_STATES[nextState] then return false end
    if self.active.state == self.STATES.ARCHIVED then return false end
    self.active.state = nextState
    self.active.sessionVersion = (tonumber(self.active.sessionVersion) or 0) + 1
    self.active.updatedAt = NowMs()
    if C.EventBus then C.EventBus:Publish("RAID_SESSION_STATE_CHANGED", { session=self.active, state=nextState, reason=reason }) end
    return true
end

function RaidSession:SetSynchronizationState(accountName, state, reason)
    if not self.active then return false end
    local account = C.NormalizeAccountName and C:NormalizeAccountName(accountName or "") or tostring(accountName or "")
    if account == "" then return false end
    local key = string.lower(tostring(state or ""))
    local valid = { accepted=true, pending=true, declined=true, disconnected=true, incompatible=true, outdated=true }
    if not valid[key] then return false end
    local synchronization = self.active.synchronization or {}
    for bucketName in pairs(valid) do
        synchronization[bucketName] = synchronization[bucketName] or {}
        synchronization[bucketName][account] = nil
    end
    synchronization[key][account] = true
    self.active.synchronization = synchronization
    self.active.updatedAt = NowMs()
    if C.EventBus then
        C.EventBus:Publish("RAID_SESSION_SYNCHRONIZATION_CHANGED", { session=self.active, accountName=account, state=string.upper(key), reason=reason })
    end
    return true
end

function RaidSession:SetRuntime(patch, reason)
    if not self.active or type(patch) ~= "table" then return nil end
    self.active.runtime = self.active.runtime or {}
    for key, value in pairs(patch) do self.active.runtime[key] = Copy(value) end
    self.active.sessionVersion = (tonumber(self.active.sessionVersion) or 0) + 1
    self.active.updatedAt = NowMs()
    if C.EventBus then C.EventBus:Publish("RAID_SESSION_RUNTIME_CHANGED", { session=self.active, runtime=self.active.runtime, reason=reason }) end
    return self.active.runtime
end

function RaidSession:ApplyRemoteSnapshot(snapshot, reason)
    if type(snapshot) ~= "table" or tostring(snapshot.sessionId or "") == "" then return nil end
    local current = self.active
    if current and tostring(current.sessionId or "") ~= tostring(snapshot.sessionId) then
        self:Archive("replaced by synchronized raid session")
    end
    self.active = Copy(snapshot)
    self.active.schemaVersion = tonumber(self.active.schemaVersion) or self.SCHEMA_VERSION
    self.active.sessionVersion = tonumber(self.active.sessionVersion) or 1
    self.active.updatedAt = NowMs()
    self.active.remoteHost = true
    self.active.synchronization = self.active.synchronization or { accepted={}, pending={}, declined={}, disconnected={}, incompatible={}, outdated={} }
    if C.EventBus then C.EventBus:Publish("RAID_SESSION_REMOTE_SYNCHRONIZED", { session=self.active, reason=reason }) end
    return self.active
end

function RaidSession:Archive(reason)
    if not self.active then return nil end
    local archived = self.active
    archived.state = self.STATES.ARCHIVED
    archived.updatedAt = NowMs()
    archived.archiveReason = reason
    self.lastArchived = archived
    self.active = nil
    if C.EventBus then C.EventBus:Publish("RAID_SESSION_ARCHIVED", { session=archived, reason=reason }) end
    return archived
end

function RaidSession:Initialize()
    self.active = nil
    self.initialized = true
end
