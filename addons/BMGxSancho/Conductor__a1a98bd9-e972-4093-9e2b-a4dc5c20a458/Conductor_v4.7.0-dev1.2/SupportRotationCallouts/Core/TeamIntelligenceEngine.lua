local C = Conductor
C.TeamIntelligenceEngine = C.TeamIntelligenceEngine or {}
local Engine = C.TeamIntelligenceEngine

local WEREWOLF_SKILL_MARKERS = {
    "FEROCIOUSROAR", "DEAFENINGROAR", "HIRCINESBOUNTY", "HIRCINESRAGE",
    "HIRCINESFORTITUDE", "POUNCE", "BRUTALPOUNCE", "FERALPOUNCE",
    "HOWLOFAGONY", "HOWLOFDESPAIR", "INFECTIOUSCLAWS", "CLAWSOFLIFE",
    "CLAWSOFANGUISH", "WEREWOLFBERSERKER", "PACKLEADER",
}

local function Normalize(value)
    return string.upper(tostring(value or "")):gsub("[^A-Z0-9]", "")
end

local function DisplayName(player)
    return player.accountName or "Unknown player"
end

local function AddProvider(target, player, sourceSummary, confidence)
    target.providers[#target.providers + 1] = {
        accountName = player.accountName,
        characterName = player.characterName,
        sourceSummary = sourceSummary or "",
        confidence = confidence or "CONFIRMED",
    }
end

local function HasClass(player, classIds)
    local id = tonumber(player.classId or (player.capabilities and player.capabilities.classId)) or 0
    for _, candidate in ipairs(classIds or {}) do if id == tonumber(candidate) then return true end end
    return false
end

local function HasWerewolfEvidence(player)
    local capabilities = player.capabilities or {}
    if capabilities.isWerewolf == true then return true end
    for _, skill in ipairs(capabilities.skills or {}) do
        local normalized = Normalize(skill.abilityName)
        for _, marker in ipairs(WEREWOLF_SKILL_MARKERS) do
            if normalized == marker then return true end
        end
    end
    for _, ultimate in ipairs(capabilities.ultimates or {}) do
        local normalized = Normalize(ultimate.abilityName)
        if normalized == "WEREWOLFBERSERKER" or normalized == "PACKLEADER" then return true end
    end
    return false
end

function Engine:FindTeamRecommendation(effect, providerOptions, players)
    for _, option in ipairs(providerOptions or {}) do
        if option.candidateWerewolf then
            for _, player in ipairs(players or {}) do
                if HasWerewolfEvidence(player) then
                    return {
                        playerName = DisplayName(player), providerName = option.name,
                        providerKey = option.key, confidence = "POSSIBLE",
                        reason = "Werewolf capability detected in the current group",
                    }
                end
            end
        end
        if option.candidateClassIds then
            for _, player in ipairs(players or {}) do
                if HasClass(player, option.candidateClassIds) then
                    return {
                        playerName = DisplayName(player), providerName = option.name,
                        providerKey = option.key, confidence = "POSSIBLE",
                        reason = "Compatible class detected in the current group",
                    }
                end
            end
        end
    end
    local count = providerOptions and #providerOptions or 0
    if count == 1 then
        local only = providerOptions[1]
        return {
            providerName = only.name, providerKey = only.key,
            confidence = "GENERAL", reason = "Only verified provider currently registered",
        }
    elseif count > 1 then
        return {
            providerName = "Review valid providers", providerKey = "MULTIPLE_VALID_PROVIDERS",
            confidence = "GENERAL", reason = "Multiple verified providers are available; no roster-specific best option was confirmed",
        }
    end
    return nil
end

function Engine:BuildCurrentTeam()
    local team = { players = {}, conductorProfiles = 0, effects = {}, generatedAt = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0 }
    if not C.Database then return team end
    for _, player in ipairs(C.Database:GetPlayers()) do
        team.players[#team.players + 1] = player
        local profile = player.raidIntelligence or (player.capabilities and player.capabilities.raidIntelligence)
        if profile then
            team.conductorProfiles = team.conductorProfiles + 1
            for _, list in ipairs({ profile.buffs or {}, profile.debuffs or {}, profile.supportFunctions or {}, profile.ultimates or {} }) do
                for _, entry in ipairs(list) do
                    team.effects[entry.key] = team.effects[entry.key] or { key = entry.key, name = entry.name, category = entry.category, providers = {} }
                    AddProvider(team.effects[entry.key], player, entry.sourceSummary, entry.confidence)
                end
            end
        end
    end

    team.effectStatus = {}
    team.covered = 0
    team.catalogued = 0
    team.duplicates = 0
    if C.ProviderGuidanceEngine then
        for _, effect in ipairs(C.ProviderGuidanceEngine:GetCoreEffects()) do
            local teamEffect = team.effects[effect.key]
            local providerCount = teamEffect and #teamEffect.providers or 0
            local providers = C.ProviderGuidanceEngine:GetProviderOptions(effect.key)
            local status = {
                key = effect.key, name = effect.name, effectType = effect.effectType, whyItMatters = effect.whyItMatters,
                status = teamEffect and "PRESENT" or "NOT_DETECTED",
                teamProviders = teamEffect and teamEffect.providers or {},
                providers = providers, bestProvider = providers[1], providerCount = providerCount,
                confidence = teamEffect and "CONFIRMED" or "MISSING",
            }
            if not teamEffect then status.teamRecommendation = self:FindTeamRecommendation(effect, providers, team.players) end
            team.catalogued = team.catalogued + 1
            if teamEffect then team.covered = team.covered + 1 end
            if providerCount > 1 then team.duplicates = team.duplicates + 1 end
            team.effectStatus[#team.effectStatus + 1] = status
        end
    end
    team.coveragePercent = team.catalogued > 0 and math.floor((team.covered / team.catalogued) * 100 + 0.5) or 0
    self.currentTeam = team
    return team
end

function Engine:GetCurrentTeam() return self:BuildCurrentTeam() end

function Engine:GetStatusesByType(effectType)
    local result = {}
    for _, status in ipairs((self:GetCurrentTeam().effectStatus or {})) do
        if status.effectType == effectType then result[#result + 1] = status end
    end
    return result
end

function Engine:Initialize()
    self.initialized = true
    if C.EventBus then
        C.EventBus:Subscribe("PLAYER_UPDATED", "TeamIntelligenceEngine", function() Engine:BuildCurrentTeam() end)
        C.EventBus:Subscribe("PLAYER_LEFT", "TeamIntelligenceEngine", function() Engine:BuildCurrentTeam() end)
        C.EventBus:Subscribe("LOCAL_CAPABILITIES_CHANGED", "TeamIntelligenceEngine", function() Engine:BuildCurrentTeam() end)
    end
end
