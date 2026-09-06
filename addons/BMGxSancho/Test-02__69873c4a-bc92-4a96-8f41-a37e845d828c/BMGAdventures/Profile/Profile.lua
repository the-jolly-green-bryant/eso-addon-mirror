local BA = BMGAdventures
BA.Profile = BA.Profile or {}

function BA.Profile:Initialize()
    BA.ProgressionEngine:RecalculateLevels()
end

function BA.Profile:GetCompletedChallengeCount()
    local n = 0
    for _, state in pairs(BA.account.challenges) do if state.c then n = n + 1 end end
    return n
end

function BA.Profile:GetUnlockCount()
    local n = 0
    for _, v in pairs(BA.account.unlocks) do if v then n = n + 1 end end
    return n
end

function BA.Profile:ResetForDevelopment()
    BA.account.adventurerXP = 0
    BA.account.adventurerLevel = 1
    BA.account.prestigeXP = 0
    BA.account.prestigeLevel = 0
    for _, id in ipairs(BA.Constants.DISCIPLINES) do BA.account.disciplines[id] = {xp=0, level=1}; BA.account.scores[id]=0 end
    BA.account.scores.adventure = 0
    BA.account.challenges = {}
    BA.account.collections = {}
    BA.account.unlocks = {}
    BA.account.presentation = { equippedTitle=nil, featuredBadges={} }
    BA.account.legacyImport = { version=0, completed=false, achievements={}, mappedIds={}, stats={}, mapped=0 }
    BA.account.profileRevision = (BA.account.profileRevision or 0) + 1
    BA.ProgressionEngine:RecalculateLevels()
    BA.ChallengeEngine:EvaluateMetaChallenges()
    BA.EventBus:Publish("PROFILE_CHANGED", { revision=BA.account.profileRevision })
end
