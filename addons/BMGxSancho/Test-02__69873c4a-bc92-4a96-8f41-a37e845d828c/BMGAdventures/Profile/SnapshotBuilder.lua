local BA = BMGAdventures
BA.SnapshotBuilder = BA.SnapshotBuilder or {}

function BA.SnapshotBuilder:Build()
    local d = {}
    for _, id in ipairs(BA.Constants.DISCIPLINES) do
        local s = BA.account.disciplines[id]
        d[id] = { xp=s.xp or 0, level=s.level or 1, score=BA.account.scores[id] or 0 }
    end
    return {
        schemaVersion = 1,
        registryVersion = BA.Constants.REGISTRY_VERSION,
        addonVersion = BA.version,
        profileRevision = BA.account.profileRevision or 0,
        identity = { account = GetDisplayName and GetDisplayName() or "", characterId = GetCurrentCharacterId and tostring(GetCurrentCharacterId()) or "" },
        progression = { adventurerXP=BA.account.adventurerXP or 0, adventurerLevel=BA.account.adventurerLevel or 1, prestigeXP=BA.account.prestigeXP or 0, prestigeLevel=BA.account.prestigeLevel or 0 },
        disciplines = d,
        scores = { adventure=BA.account.scores.adventure or 0 },
        completedChallenges = BA.Profile:GetCompletedChallengeCount(),
        unlockCount = BA.Profile:GetUnlockCount(),
        completedCollections = BA.CollectionEngine and BA.CollectionEngine:GetCompletedCount() or 0,
        presentation = BA.account.presentation,
        leaderboardOptIn = BA.settings.leaderboardEnabled == true,
    }
end

function BA.SnapshotBuilder:ToDebugString()
    local s = self:Build()
    return string.format("schema=%d registry=%s revision=%d account=%s level=%d xp=%d score=%d completed=%d collections=%d unlocks=%d",
        s.schemaVersion, s.registryVersion, s.profileRevision, s.identity.account, s.progression.adventurerLevel,
        s.progression.adventurerXP, s.scores.adventure, s.completedChallenges, s.completedCollections or 0, s.unlockCount)
end
