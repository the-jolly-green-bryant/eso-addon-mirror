TrialRecorder = TrialRecorder or {}
local TR = TrialRecorder

TR.Trials = {
    { key = "AETHERIAN_ARCHIVE", name = "Aetherian Archive", short = "AA", sort = 1, aliases = { "Aetherian Archive" }, hmRule = "BONUS_HIGH" },
    { key = "HEL_RA_CITADEL", name = "Hel Ra Citadel", short = "HRC", sort = 2, aliases = { "Hel Ra Citadel" }, hmRule = "BONUS_HIGH" },
    { key = "SANCTUM_OPHIDIA", name = "Sanctum Ophidia", short = "SO", sort = 3, aliases = { "Sanctum Ophidia" }, hmRule = "BONUS_HIGH" },
    { key = "MAW_OF_LORKHAJ", name = "Maw of Lorkhaj", short = "MoL", sort = 4, aliases = { "Maw of Lorkhaj" }, hmRule = "BONUS_HIGH" },
    { key = "HALLS_OF_FABRICATION", name = "Halls of Fabrication", short = "HoF", sort = 5, aliases = { "Halls of Fabrication" }, hmRule = "BONUS_HIGH" },
    { key = "ASYLUM_SANCTORIUM", name = "Asylum Sanctorium", short = "AS", sort = 6, aliases = { "Asylum Sanctorium" }, hmRule = "BONUS_HIGH", configuration = "AS" },
    { key = "CLOUDREST", name = "Cloudrest", short = "CR", sort = 7, aliases = { "Cloudrest" }, hmRule = "BONUS_HIGH", configuration = "CR" },
    { key = "SUNSPIRE", name = "Sunspire", short = "SS", sort = 8, aliases = { "Sunspire" }, hmRule = "BONUS_HIGH" },
    { key = "KYNES_AEGIS", name = "Kyne's Aegis", short = "KA", sort = 9, aliases = { "Kyne's Aegis", "Kynes Aegis" }, hmRule = "BONUS_HIGH" },
    { key = "ROCKGROVE", name = "Rockgrove", short = "RG", sort = 10, aliases = { "Rockgrove" }, hmRule = "BONUS_HIGH" },
    { key = "DREADSAIL_REEF", name = "Dreadsail Reef", short = "DSR", sort = 11, aliases = { "Dreadsail Reef" }, hmRule = "BONUS_HIGH" },
    { key = "SANITYS_EDGE", name = "Sanity's Edge", short = "SE", sort = 12, aliases = { "Sanity's Edge", "Sanitys Edge" }, hmRule = "BONUS_HIGH" },
    { key = "LUCENT_CITADEL", name = "Lucent Citadel", short = "LC", sort = 13, aliases = { "Lucent Citadel" }, hmRule = "BONUS_HIGH" },
    { key = "OSSEIN_CAGE", name = "Ossein Cage", short = "OC", sort = 14, aliases = { "Ossein Cage" }, hmRule = "BONUS_HIGH" },
}

TR.TrialByKey = {}
TR.TrialByNormalizedName = {}

local function NormalizeName(value)
    if not value then return "" end
    value = zo_strlower(value)
    value = value:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    -- Native leaderboard labels may include the localized Veteran suffix.
    -- Remove the English token as a safe fallback, then compare punctuation-free names.
    value = value:gsub("veteran", "")
    value = value:gsub("[^%w]", "")
    return value
end
TR.NormalizeName = NormalizeName

for _, trial in ipairs(TR.Trials) do
    TR.TrialByKey[trial.key] = trial
    TR.TrialByNormalizedName[NormalizeName(trial.name)] = trial
    for _, alias in ipairs(trial.aliases or {}) do
        TR.TrialByNormalizedName[NormalizeName(alias)] = trial
    end
end

function TR:GetTrialByName(name)
    return self.TrialByNormalizedName[self.NormalizeName(name)]
end

TR.RaidIdByTrialKey = TR.RaidIdByTrialKey or {}

function TR:RefreshRaidLeaderboardIds()
    ZO_ClearTable(self.RaidIdByTrialKey)

    if type(GetNextRaidLeaderboardId) ~= "function" or type(GetRaidLeaderboardName) ~= "function" then
        return
    end

    local lastRaidId = nil
    while true do
        local raidId = GetNextRaidLeaderboardId(RAID_CATEGORY_TRIAL, lastRaidId)
        if not raidId then
            break
        end

        local raidName = GetRaidLeaderboardName(raidId)
        local trial = self:GetTrialByName(raidName)

        -- Fallback for localized/formatted leaderboard names. Match the normalized
        -- trial name as a contained token rather than requiring an exact label.
        if not trial then
            local normalizedRaidName = self.NormalizeName(raidName)
            for _, candidate in ipairs(self.Trials) do
                local normalizedTrialName = self.NormalizeName(candidate.name)
                if normalizedRaidName == normalizedTrialName
                    or normalizedRaidName:find(normalizedTrialName, 1, true)
                    or normalizedTrialName:find(normalizedRaidName, 1, true) then
                    trial = candidate
                    break
                end
            end
        end

        if trial then
            self.RaidIdByTrialKey[trial.key] = raidId
        end

        lastRaidId = raidId
    end
end

function TR:GetRaidIdForTrial(trialKey)
    if not next(self.RaidIdByTrialKey) then
        self:RefreshRaidLeaderboardIds()
    end

    return self.RaidIdByTrialKey[trialKey]
end
