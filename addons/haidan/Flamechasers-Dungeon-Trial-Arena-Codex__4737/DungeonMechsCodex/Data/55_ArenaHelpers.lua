-- Shared constructors for Veteran arena modules.

local DMC = DungeonMechsCodex

local function cloneArray(value)
    local out = {}
    for index, item in ipairs(value or {}) do out[index] = item end
    return out
end

function DMC.ArenaSummary(text)
    return {
        full = text,
        ui = text,
        chat = {text},
        vet = {classification = "shared"},
    }
end

function DMC.ArenaMechanic(name, tags, text, quick, roles, casts)
    roles = cloneArray(roles or {})
    local mechanic = {
        name = name,
        shortName = name,
        casts = cloneArray(casts or {name}),
        tags = cloneArray(tags or {}),
        roles = roles,
        all = text,
        quick = quick or text,
        vet = {classification = "shared"},
    }
    for _, role in ipairs(roles) do
        if role ~= "all" then mechanic[role] = text end
    end
    return mechanic
end

function DMC.ArenaBoss(id, name, flags, summary, mechanics)
    return {
        id = id,
        name = name,
        flags = cloneArray(flags or {"Main"}),
        summary = summary,
        ui = summary,
        chat = {summary},
        mechanics = mechanics or {},
        vet = {classification = "shared"},
    }
end

