-- Shared constructors for the trial dataset.
-- Hard Mode is the base representation; each Veteran-without-HM difference is
-- carried by the same `vet` overlay mechanism used by the dungeon dataset.

local DMC = DungeonMechsCodex

local function cloneArray(value)
    local out = {}
    for index, item in ipairs(value or {}) do out[index] = item end
    return out
end

function DMC.TrialSummary(hmText, vetText)
    local value = {full = hmText, ui = hmText, chat = {hmText}}
    if vetText and vetText ~= hmText then
        value.vet = {
            classification = "veteran",
            full = vetText,
            ui = vetText,
            chat = {vetText},
        }
    else
        value.vet = {classification = "shared"}
    end
    return value
end

function DMC.TrialMechanic(name, shortName, tags, roles, hmText, vetText, quickHm, quickVet, casts)
    roles = cloneArray(roles or {"tank", "healer", "dps"})
    local mechanic = {
        name = name,
        shortName = shortName or name,
        casts = cloneArray(casts or {name}),
        tags = cloneArray(tags or {}),
        roles = roles,
        all = hmText,
        quick = quickHm or hmText,
    }

    -- Role views need explicit fields. Reusing the concise factual instruction
    -- keeps every relevant role filter useful without inventing role behavior.
    for _, role in ipairs(roles) do
        if role ~= "all" then mechanic[role] = hmText end
    end

    if vetText == false then
        mechanic.vet = false
    elseif vetText and vetText ~= hmText then
        mechanic.vet = {
            classification = "veteran",
            all = vetText,
            quick = quickVet or vetText,
            roles = cloneArray(roles),
        }
        for _, role in ipairs(roles) do
            if role ~= "all" then mechanic.vet[role] = vetText end
        end
    else
        mechanic.vet = {classification = "shared"}
    end
    return mechanic
end

function DMC.TrialBoss(id, name, flags, hmSummary, vetSummary, mechanics)
    local boss = {
        id = id,
        name = name,
        flags = cloneArray(flags or {"Main"}),
        summary = hmSummary,
        ui = hmSummary,
        chat = {hmSummary},
        mechanics = mechanics or {},
    }
    if vetSummary and vetSummary ~= hmSummary then
        boss.vet = {
            classification = "veteran",
            summary = vetSummary,
            ui = vetSummary,
            chat = {vetSummary},
        }
    else
        boss.vet = {classification = "shared"}
    end
    return boss
end
