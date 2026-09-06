local BA = BMGAdventures
BA.ChallengeEngine = BA.ChallengeEngine or {}

function BA.ChallengeEngine:Initialize()
    self.evaluatingMeta = false
end

function BA.ChallengeEngine:ProcessActivity(event)
    local candidates = BA.ChallengeIndex:GetCandidates(event)
    BA.Diagnostics:Count("challengeEvaluations", #candidates)
    for _, def in ipairs(candidates) do
        local amount = 1
        if event.result and event.result.quantity then amount = event.result.quantity end
        BA.Transaction:AddProgress(def, amount, event.evidence and event.evidence.detectionClass or "UNKNOWN")
    end
end

local function completedCount(category)
    local n = 0
    for _, def in ipairs(BA.Challenges) do
        local s = BA.account.challenges[def.id]
        if s and s.c and (not category or def.category == category) then n = n + 1 end
    end
    return n
end

function BA.ChallengeEngine:MetaValue(def)
    if def.metaType == "COMPLETED_CHALLENGES" then return completedCount(nil) end
    if def.metaType == "ADVENTURE_SCORE" then return BA.account.scores.adventure or 0 end
    if def.metaType == "ADVENTURER_LEVEL" then return BA.account.adventurerLevel or 1 end
    if def.metaType == "CATEGORY_COMPLETIONS" then return completedCount(def.metaArg) end
    if def.metaType == "DISCIPLINES_AT_LEVEL" then
        local n = 0
        for _, id in ipairs(BA.Constants.DISCIPLINES) do
            if (BA.account.disciplines[id].level or 1) >= (def.metaArg or 1) then n = n + 1 end
        end
        return n
    end
    return 0
end

function BA.ChallengeEngine:EvaluateMetaChallenges()
    if self.evaluatingMeta then return end
    self.evaluatingMeta = true
    local changed = true
    local passes = 0
    while changed and passes < 5 do
        changed = false
        passes = passes + 1
        for _, def in ipairs(BA.ChallengeIndex.meta) do
            local state = BA.account.challenges[def.id]
            if not (state and state.c) then
                local value = self:MetaValue(def)
                if value >= def.goal then
                    if BA.Transaction:CompleteChallenge(def, "BMG_STATE", true) then changed = true end
                else
                    if not state then state = {v=0,c=false}; BA.account.challenges[def.id]=state end
                    state.v = value
                end
            end
        end
    end
    self.evaluatingMeta = false
end
