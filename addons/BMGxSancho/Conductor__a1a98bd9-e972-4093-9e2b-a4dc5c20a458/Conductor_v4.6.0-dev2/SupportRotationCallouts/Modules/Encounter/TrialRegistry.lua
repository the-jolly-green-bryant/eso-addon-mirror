local SRC = SupportRotationCallouts
SRC.TrialRegistry = SRC.TrialRegistry or {}
local Registry = SRC.TrialRegistry

function Registry:GetTrial(zoneName)
    return SRC.EncounterProfiles and SRC.EncounterProfiles:GetTrial(zoneName) or nil
end

function Registry:GetCurrentTrial()
    local zoneName = GetUnitZone and GetUnitZone("player") or ""
    return self:GetTrial(zoneName), zo_strtrim(zo_strformat("<<1>>", zoneName or ""))
end

function Registry:GetBossRule(trial, bossName, difficulty)
    return SRC.EncounterProfiles and SRC.EncounterProfiles:GetEncounter(trial, bossName, difficulty) or nil
end

function Registry:GetTrials()
    return SRC.EncounterProfiles and SRC.EncounterProfiles:GetTrials() or {}
end
