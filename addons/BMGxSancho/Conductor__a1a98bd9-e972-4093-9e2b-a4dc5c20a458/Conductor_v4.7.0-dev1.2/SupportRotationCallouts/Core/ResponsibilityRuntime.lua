local C = Conductor
local SRC = SupportRotationCallouts
C.ResponsibilityRuntime = C.ResponsibilityRuntime or {}
local Runtime = C.ResponsibilityRuntime

local function NowMs() return GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0 end
local function Key(value) return string.upper(tostring(value or "")):gsub("[^A-Z0-9]+", "_") end
local function Normalize(value)
    return SRC.NormalizeAccountName and SRC:NormalizeAccountName(value or "") or tostring(value or "")
end
local function Copy(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for key, item in pairs(value) do output[key] = Copy(item) end
    return output
end

function Runtime:Reset(reason)
    self.entries = {}
    self.revision = (tonumber(self.revision) or 0) + 1
    self:Publish("RESPONSIBILITY_RUNTIME_RESET", { reason=reason, revision=self.revision })
    self:SyncContext(reason or "responsibilities reset")
end

function Runtime:Publish(name, payload)
    if C.EventBus then C.EventBus:Publish(name, payload) end
end

function Runtime:Get(key) return self.entries and self.entries[Key(key)] or nil end
function Runtime:GetAll() return Copy(self.entries or {}) end

function Runtime:ResolveAssignment(key)
    local session = C.RaidSession and C.RaidSession:GetActive() or nil
    local assignment = session and session.assignments and session.assignments[key] or nil
    if not assignment and session and session.responsibilities then assignment = session.responsibilities[key] end
    local account = assignment and (assignment.player or assignment.accountName or assignment.assignedAccount) or nil
    if account and C.LiveSession then account = C.LiveSession:ResolveAccount(account, key) end
    return account, assignment
end

function Runtime:Ensure(key)
    key = Key(key)
    if key == "" then return nil end
    self.entries[key] = self.entries[key] or {
        key=key, status="UNASSIGNED", assignedAccount=nil, available=false,
        ready=false, active=false, confirmed=false, remainingSeconds=0,
        revision=0, updatedAtMs=NowMs(),
    }
    return self.entries[key]
end

function Runtime:Update(key, patch, reason)
    local entry = self:Ensure(key)
    if not entry then return nil end
    local changed = false
    for field, value in pairs(patch or {}) do
        if entry[field] ~= value then entry[field] = value; changed = true end
    end
    if not changed then return entry end
    entry.revision = (tonumber(entry.revision) or 0) + 1
    entry.updatedAtMs = NowMs()
    entry.reason = reason
    if entry.active then entry.status = "ACTIVE"
    elseif entry.ready and entry.available then entry.status = "READY"
    elseif entry.available then entry.status = "AVAILABLE"
    elseif entry.assignedAccount then entry.status = "ASSIGNED_UNAVAILABLE"
    else entry.status = "UNASSIGNED" end
    self.revision = (tonumber(self.revision) or 0) + 1
    self:Publish("RESPONSIBILITY_RUNTIME_CHANGED", { key=entry.key, entry=entry, reason=reason, revision=self.revision })
    self:SyncContext(reason or "responsibility changed")
    return entry
end

function Runtime:RefreshAssignments(reason)
    local session = C.RaidSession and C.RaidSession:GetActive() or nil
    local keys = {}
    for key in pairs(session and session.assignments or {}) do keys[Key(key)] = true end
    for key in pairs(session and session.responsibilities or {}) do keys[Key(key)] = true end
    for key in pairs(self.entries or {}) do keys[key] = true end
    for key in pairs(keys) do
        local account = self:ResolveAssignment(key)
        self:Update(key, { assignedAccount=Normalize(account), available=account ~= nil }, reason or "assignments refreshed")
    end
end

function Runtime:ObserveTimeline(payload)
    local event = payload and payload.event
    if not event then return end
    local key = Key(event.responsibilityKey or event.key)
    if key == "" then return end
    self:Update(key, {
        assignedAccount=Normalize(event.assignedAccount),
        ready=event.status == "PENDING",
        active=event.status == "EXECUTED",
        confirmed=event.status == "EXECUTED",
    }, "timeline observation")
end

function Runtime:SyncContext(reason)
    if C.RuntimeContext then C.RuntimeContext:Patch("responsibilities", self.entries or {}, reason) end
end

function Runtime:RegisterEvents()
    if not C.EventBus then return end
    for _, eventName in ipairs({"RAID_SESSION_CREATED","RAID_SESSION_UPDATED","RAID_SESSION_STATE_CHANGED"}) do
        C.EventBus:Subscribe(eventName, self, function() self:RefreshAssignments(eventName) end)
    end
    C.EventBus:Subscribe("LIVE_SESSION_CHANGED", self, function(payload) self:Reset((payload and payload.reason) or "live session changed") end)
    C.EventBus:Subscribe("TIMELINE_EVENT_ADDED", self, function(payload) self:ObserveTimeline(payload) end)
    C.EventBus:Subscribe("TIMELINE_EVENT_EXECUTED", self, function(payload) self:ObserveTimeline(payload) end)
    C.EventBus:Subscribe("TIMELINE_CLEARED", self, function() self:RefreshAssignments("timeline cleared") end)
end

function Runtime:Initialize()
    self.entries = {}
    self.revision = 0
    self:RegisterEvents()
    self:RefreshAssignments("initialize")
    self.initialized = true
end
