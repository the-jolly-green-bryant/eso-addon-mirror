local C = Conductor
local SRC = SupportRotationCallouts
C.SessionSnapshot = C.SessionSnapshot or {}
local Snapshot = C.SessionSnapshot

Snapshot.SCHEMA_VERSION = 2
Snapshot.MAX_PLAYERS = 12
Snapshot.MAX_SERIALIZED_BYTES = 64000

local function Copy(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for key, item in pairs(value) do output[key] = Copy(item) end
    return output
end

local function Normalize(value)
    if C.NormalizeAccountName then return C:NormalizeAccountName(value or "") end
    return tostring(value or "")
end

local function Now()
    return GetTimeStamp and GetTimeStamp() or 0
end

local function TeamName(session)
    if C.TeamProfilesV2 and session.sourceProfileId then
        local profile = C.TeamProfilesV2:GetById(session.sourceProfileId)
        if profile and tostring(profile.name or "") ~= "" then return profile.name end
    end
    local draft = SRC.saved and SRC.saved.rosteredRunDraftName or ""
    if tostring(draft or "") ~= "" then return draft end
    if tostring(session.trial or "") ~= "" then return tostring(session.trial) end
    return "Shared Raid Team"
end

function Snapshot:Build(session)
    if type(session) ~= "table" then return nil, "No active Raid Session is available." end
    local snapshot = {
        snapshotSchemaVersion = self.SCHEMA_VERSION,
        raidSessionSchemaVersion = tonumber(session.schemaVersion) or 1,
        sessionId = tostring(session.sessionId or ""),
        sessionRevision = tonumber(session.sessionVersion) or 1,
        mode = tostring(session.mode or "ROSTERED"),
        hostAccount = Normalize(session.hostAccount),
        teamName = TeamName(session),
        createdAt = tonumber(session.createdAt) or Now(),
        sharedAt = Now(),
        trial = tostring(session.trial or ""),
        difficulty = tostring(session.difficulty or ""),
        objective = tostring(session.objective or ""),
        strategy = tostring(session.strategy or ""),
        sourceProfileId = tostring(session.sourceProfileId or ""),
        players = Copy(session.players or {}),
        assignments = Copy(session.assignments or {}),
        responsibilities = Copy(session.responsibilities or {}),
    }
    local valid, validationError = self:Validate(snapshot, true)
    if not valid then return nil, validationError end
    return snapshot
end

function Snapshot:ContainsPlayer(snapshot, accountName)
    local wanted = Normalize(accountName)
    if wanted == "" then return false end
    for _, player in ipairs(snapshot and snapshot.players or {}) do
        if Normalize(player.accountName) == wanted then return true end
    end
    return false
end

function Snapshot:Validate(snapshot, outgoing)
    if type(snapshot) ~= "table" then return false, "Snapshot is not a table." end
    if tonumber(snapshot.snapshotSchemaVersion) ~= self.SCHEMA_VERSION then return false, "Unsupported snapshot schema." end
    if tostring(snapshot.sessionId or "") == "" then return false, "Snapshot is missing its session ID." end
    if Normalize(snapshot.hostAccount) == "" then return false, "Snapshot is missing its host account." end
    if type(snapshot.players) ~= "table" or #snapshot.players < 1 then return false, "Snapshot roster is empty." end
    if #snapshot.players > self.MAX_PLAYERS then return false, "Snapshot roster exceeds 12 players." end
    if type(snapshot.assignments) ~= "table" then return false, "Snapshot assignments are invalid." end
    if type(snapshot.responsibilities) ~= "table" then return false, "Snapshot responsibilities are invalid." end

    local seen = {}
    for _, player in ipairs(snapshot.players) do
        local account = Normalize(player.accountName)
        if account == "" then return false, "Snapshot contains a player without an account name." end
        if seen[account] then return false, "Snapshot contains a duplicate player: " .. account end
        seen[account] = true
        player.accountName = account
        local slot = tonumber(player.rosterSlot)
        if slot and (slot < 1 or slot > self.MAX_PLAYERS) then return false, "Snapshot contains an invalid roster slot." end
    end

    if outgoing and not self:ContainsPlayer(snapshot, snapshot.hostAccount) then
        return false, "The Raid Session host is not present in the roster."
    end
    return true
end

function Snapshot:ToRaidSession(snapshot)
    return {
        schemaVersion = tonumber(snapshot.raidSessionSchemaVersion) or 1,
        sessionId = tostring(snapshot.sessionId),
        sessionVersion = tonumber(snapshot.sessionRevision) or 1,
        mode = tostring(snapshot.mode or "ROSTERED"),
        hostAccount = Normalize(snapshot.hostAccount),
        createdAt = tonumber(snapshot.createdAt) or Now(),
        state = C.RaidSession and C.RaidSession.STATES.ACTIVE or "ACTIVE",
        trial = snapshot.trial,
        difficulty = snapshot.difficulty,
        objective = snapshot.objective,
        strategy = snapshot.strategy,
        sourceProfileId = snapshot.sourceProfileId ~= "" and snapshot.sourceProfileId or nil,
        players = Copy(snapshot.players or {}),
        assignments = Copy(snapshot.assignments or {}),
        responsibilities = Copy(snapshot.responsibilities or {}),
        synchronization = { accepted={}, pending={}, declined={}, disconnected={}, incompatible={}, outdated={} },
        runtime = { encounter=nil, encounterState="INACTIVE", executionMode="INACTIVE" },
        sharedTeamName = snapshot.teamName,
    }
end
