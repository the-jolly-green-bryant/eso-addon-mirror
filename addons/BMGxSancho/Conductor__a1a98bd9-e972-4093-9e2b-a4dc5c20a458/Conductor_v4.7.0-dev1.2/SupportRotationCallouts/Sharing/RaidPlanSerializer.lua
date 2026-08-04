local C = Conductor
C.RaidPlanSerializer = C.RaidPlanSerializer or {}
local Serializer=C.RaidPlanSerializer

local function Copy(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for key, item in pairs(value) do output[key] = Copy(item) end
    return output
end

local function IsEmpty(value)
    return type(value) == "table" and next(value) == nil
end

-- More Markers succeeds by sending only the profile data required by the
-- recipient and allowing LibGroupBroadcast to own queueing. Conductor follows
-- the same principle here: remove duplicate runtime aliases before transfer,
-- then reconstruct the complete local Raid Plan after receipt.
function Serializer:PrepareWire(plan)
    local wire = Copy(plan or {})

    -- Canonical wire fields. Their local compatibility aliases are restored by
    -- ExpandWire after decoding.
    wire.planSchemaVersion = nil
    wire.planId = nil
    wire.revision = nil
    wire.sharedAt = nil
    wire.payloadType = nil

    -- assignments duplicates responsibilities and trashPlan groups in the
    -- compiled plan. Sending it tripled the largest portion of the payload.
    wire.assignments = nil

    if IsEmpty(wire.rosterMapping) then wire.rosterMapping = nil end
    if IsEmpty(wire.manualOverrides) then wire.manualOverrides = nil end
    if IsEmpty(wire.unresolved) then wire.unresolved = nil end

    return wire
end

function Serializer:ExpandWire(wire)
    local plan = Copy(wire or {})
    plan.snapshotSchemaVersion = tonumber(plan.snapshotSchemaVersion or plan.planSchemaVersion) or 0
    plan.planSchemaVersion = plan.snapshotSchemaVersion
    plan.sessionId = tostring(plan.sessionId or plan.planId or "")
    plan.planId = plan.sessionId
    plan.sessionRevision = tonumber(plan.sessionRevision or plan.revision) or 1
    plan.revision = plan.sessionRevision
    plan.payloadType = "RAID_PLAN"

    plan.players = plan.players or {}
    plan.responsibilities = plan.responsibilities or {}
    plan.trashPlan = plan.trashPlan or {}
    plan.trashPlan.groups = plan.trashPlan.groups or {}
    plan.bossPlans = plan.bossPlans or {}
    plan.rosterMapping = plan.rosterMapping or {}
    plan.manualOverrides = plan.manualOverrides or {}
    plan.unresolved = plan.unresolved or {}

    local groups = Copy(plan.trashPlan.groups)
    local responsibilities = Copy(plan.responsibilities)
    plan.assignments = {
        trashUltimateGroups = Copy(groups),
        ultimateGroups = Copy(groups),
        responsibilities = responsibilities,
    }
    return plan
end

function Serializer:Encode(plan)
    return C.SessionSerializer:Encode(self:PrepareWire(plan))
end

function Serializer:Decode(value)
    local wire, errorMessage = C.SessionSerializer:Decode(value)
    if not wire then return nil, errorMessage end
    return self:ExpandWire(wire)
end

function Serializer:Checksum(value) return C.SessionSerializer:Checksum(value) end
