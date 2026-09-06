local BA = BMGAdventures
BA.Transaction = BA.Transaction or {}

local function stateFor(def)
    local s = BA.account.challenges[def.id]
    if not s then s = { v=0, c=false }; BA.account.challenges[def.id] = s end
    return s
end

function BA.Transaction:Initialize() end

function BA.Transaction:CompleteChallenge(def, evidence, suppressMeta)
    local state = stateFor(def)
    if state.c then
        BA.Diagnostics:Count("duplicateCompletionsBlocked")
        return false
    end
    state.c = true
    state.v = def.goal
    state.t = GetTimeStamp and GetTimeStamp() or 0
    state.p = evidence or "UNKNOWN"

    local r = def.rewards or {}
    BA.account.adventurerXP = (BA.account.adventurerXP or 0) + (r.adventurerXP or 0)
    if r.discipline and BA.account.disciplines[r.discipline] then
        local ds = BA.account.disciplines[r.discipline]
        ds.xp = (ds.xp or 0) + (r.disciplineXP or 0)
        BA.account.scores[r.discipline] = (BA.account.scores[r.discipline] or 0) + (r.score or 0)
    end
    BA.account.scores.adventure = (BA.account.scores.adventure or 0) + (r.score or 0)

    for _, unlockId in ipairs(r.unlocks or {}) do BA.UnlockEngine:Grant(unlockId) end

    BA.ProgressionEngine:RecalculateLevels()
    BA.account.profileRevision = (BA.account.profileRevision or 0) + 1
    BA.Diagnostics:Count("transactions")
    BA.Diagnostics:Record("CHALLENGE_COMPLETE", def.id)
    BA.EventBus:Publish("CHALLENGE_COMPLETED", { challenge=def, state=state })
    BA.EventBus:Publish("PROFILE_CHANGED", { revision=BA.account.profileRevision })

    if not suppressMeta then BA.ChallengeEngine:EvaluateMetaChallenges() end
    return true
end

function BA.Transaction:AddProgress(def, amount, evidence)
    local state = stateFor(def)
    if state.c then return false end
    amount = amount or 1
    state.v = math.min(def.goal, (state.v or 0) + amount)
    if state.v >= def.goal then
        return self:CompleteChallenge(def, evidence, false)
    end
    BA.account.profileRevision = (BA.account.profileRevision or 0) + 1
    BA.EventBus:Publish("CHALLENGE_PROGRESS", { challenge=def, state=state })
    BA.EventBus:Publish("PROFILE_CHANGED", { revision=BA.account.profileRevision })
    return true
end

function BA.Transaction:SetProgressAtLeast(def, value, evidence)
    local state = stateFor(def)
    if state.c then return false end
    value = math.max(0, tonumber(value) or 0)
    if value <= (state.v or 0) then return false end
    state.v = math.min(def.goal, value)
    if state.v >= def.goal then
        return self:CompleteChallenge(def, evidence, false)
    end
    BA.account.profileRevision = (BA.account.profileRevision or 0) + 1
    BA.EventBus:Publish("CHALLENGE_PROGRESS", { challenge=def, state=state })
    BA.EventBus:Publish("PROFILE_CHANGED", { revision=BA.account.profileRevision })
    return true
end
