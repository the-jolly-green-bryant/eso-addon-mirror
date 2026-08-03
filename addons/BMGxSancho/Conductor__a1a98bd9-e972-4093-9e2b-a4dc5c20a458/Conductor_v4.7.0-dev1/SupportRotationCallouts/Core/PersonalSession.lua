local C = Conductor
C.PersonalSession = C.PersonalSession or {}
local PersonalSession = C.PersonalSession

local function Normalize(value)
    if C.NormalizeAccountName then return C:NormalizeAccountName(value or "") end
    return string.lower(tostring(value or ""))
end

local function Copy(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for key, item in pairs(value) do output[key] = Copy(item) end
    return output
end

local function AssignmentBelongsTo(account, assignment)
    if type(assignment) ~= "table" then return false end
    return Normalize(assignment.accountName or assignment.player or assignment.assignedAccount or assignment.providerAccount) == account
end

local function CollectAssignments(source, account, output, path)
    if type(source) ~= "table" then return end
    if AssignmentBelongsTo(account, source) then
        local item = Copy(source)
        item.assignmentPath = path
        output[#output + 1] = item
        return
    end
    for key, value in pairs(source) do
        if type(value) == "table" then
            CollectAssignments(value, account, output, path == "" and tostring(key) or (path .. "." .. tostring(key)))
        end
    end
end

local function CollectResponsibilities(source, account, output)
    if type(source) ~= "table" then return end
    for key, value in pairs(source) do
        if type(value) == "table" then
            if AssignmentBelongsTo(account, value) then
                local item = Copy(value)
                item.key = item.key or item.responsibilityKey or tostring(key)
                output[#output + 1] = item
            else
                CollectResponsibilities(value, account, output)
            end
        elseif Normalize(value) == account then
            output[#output + 1] = { key=tostring(key), responsibilityKey=tostring(key), player=account }
        end
    end
end

function PersonalSession:Build(session)
    if type(session) ~= "table" then return nil end
    local account = Normalize(GetDisplayName and GetDisplayName() or "")
    local player = nil
    for _, candidate in ipairs(session.players or {}) do
        if Normalize(candidate.accountName) == account then player = Copy(candidate); break end
    end
    if not player then return nil end

    local assignments, responsibilities = {}, {}
    CollectAssignments(session.assignments or {}, account, assignments, "")
    CollectResponsibilities(session.responsibilities or {}, account, responsibilities)

    local timeline = {}
    for _, assignment in ipairs(assignments) do
        timeline[#timeline + 1] = {
            key = assignment.timelineKey or assignment.responsibilityKey or assignment.key or assignment.assignmentPath,
            source = "ASSIGNMENT",
            enabled = true,
        }
    end
    for _, responsibility in ipairs(responsibilities) do
        timeline[#timeline + 1] = {
            key = responsibility.timelineKey or responsibility.responsibilityKey or responsibility.key,
            source = "RESPONSIBILITY",
            enabled = true,
        }
    end

    return {
        sessionId = session.sessionId,
        sessionVersion = session.sessionVersion,
        accountName = account,
        player = player,
        role = player.combatRole or player.rosterRole or "UNKNOWN",
        rosterSlot = player.rosterSlot,
        assignments = assignments,
        responsibilities = responsibilities,
        timelineSubscriptions = timeline,
        callouts = Copy(timeline),
        initializedAt = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0,
    }
end

function PersonalSession:InitializeFromSession(session, reason)
    local context = self:Build(session)
    if not context then
        self.active = nil
        return false
    end
    self.active = context
    if C.EventBus then
        C.EventBus:Publish("PERSONAL_SESSION_INITIALIZED", { context=context, session=session, reason=reason })
        C.EventBus:Publish("PERSONAL_ROLE_INITIALIZED", { role=context.role, player=context.player, session=session })
        C.EventBus:Publish("PERSONAL_RESPONSIBILITIES_INITIALIZED", { responsibilities=context.responsibilities, session=session })
        C.EventBus:Publish("PERSONAL_TIMELINE_INITIALIZED", { subscriptions=context.timelineSubscriptions, session=session })
        C.EventBus:Publish("PERSONAL_CALLOUTS_INITIALIZED", { callouts=context.callouts, session=session })
    end
    return true
end

function PersonalSession:GetActive() return self.active end
function PersonalSession:Clear(reason)
    local previous = self.active
    self.active = nil
    if previous and C.EventBus then C.EventBus:Publish("PERSONAL_SESSION_CLEARED", { context=previous, reason=reason }) end
end

function PersonalSession:Initialize()
    if C.EventBus then
        C.EventBus:Subscribe("RAID_SESSION_CREATED", self, function(payload) self:InitializeFromSession(payload and payload.session, "local session created") end)
        C.EventBus:Subscribe("RAID_SESSION_REMOTE_SYNCHRONIZED", self, function(payload) self:InitializeFromSession(payload and payload.session, "remote session synchronized") end)
        C.EventBus:Subscribe("RAID_SESSION_REVISION_APPLIED", self, function(payload) self:InitializeFromSession(payload and payload.session, "session revision applied") end)
        C.EventBus:Subscribe("RAID_SESSION_ARCHIVED", self, function(payload) self:Clear(payload and payload.reason or "session archived") end)
    end
    self.initialized = true
end
