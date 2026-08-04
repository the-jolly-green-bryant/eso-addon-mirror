local C = Conductor
C.ProfileModel = C.ProfileModel or {}
local Model = C.ProfileModel

local function Copy(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for key, entry in pairs(value) do output[Copy(key)] = Copy(entry) end
    return output
end

function Model:NewTeamProfile(values)
    values = values or {}
    return {
        schemaVersion = 1,
        id = values.id or "",
        name = values.name or "New Team",
        roster = Copy(values.roster or {}),
        defaults = Copy(values.defaults or {}),
        sharing = Copy(values.sharing or { enabled = true }),
        createdAt = values.createdAt or 0,
        updatedAt = values.updatedAt or 0,
    }
end

function Model:NewEncounterProfile(values)
    values = values or {}
    return {
        schemaVersion = 1,
        id = values.id or "",
        trialKey = values.trialKey or "",
        encounterKey = values.encounterKey or "",
        difficulty = values.difficulty or "VETERAN",
        setupType = values.setupType or "CUSTOM",
        roles = Copy(values.roles or {}),
        ultimates = Copy(values.ultimates or {}),
        buffs = Copy(values.buffs or {}),
        debuffs = Copy(values.debuffs or {}),
        gear = Copy(values.gear or {}),
        classMasteries = Copy(values.classMasteries or {}),
        championPoints = Copy(values.championPoints or {}),
        burnSequence = Copy(values.burnSequence or {}),
        intelligence = Copy(values.intelligence or {}),
        createdAt = values.createdAt or 0,
        updatedAt = values.updatedAt or 0,
    }
end

function Model:NewResponsibility(values)
    values = values or {}
    return {
        key = values.key or "",
        effectKey = values.effectKey or "",
        providerKey = values.providerKey or "OTHER",
        assignedAccount = values.assignedAccount or "",
        requirement = values.requirement or "REQUIRED",
        priority = values.priority or 0,
        alternatives = Copy(values.alternatives or {}),
        metadata = Copy(values.metadata or {}),
    }
end
