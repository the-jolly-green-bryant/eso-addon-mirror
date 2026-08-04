local C = Conductor
C.ProviderGuidanceEngine = C.ProviderGuidanceEngine or {}
local Engine = C.ProviderGuidanceEngine

local EFFECT_ORDER = {
    -- Buff column
    "MAJOR_FORCE", "MAJOR_SLAYER", "MAJOR_COURAGE", "MINOR_COURAGE", "POWERFUL_ASSAULT",
    "MAJOR_RESOLVE", "MINOR_RESOLVE", "MINOR_BERSERK", "MAJOR_BERSERK", "ULTIMATE_RESTORE", "HEROISM",
    -- Debuff column
    "MAJOR_VULNERABILITY", "MAJOR_BRITTLE", "MINOR_BRITTLE", "CRUSHER", "MAJOR_BREACH",
    "MINOR_BREACH", "MINOR_VULNERABILITY", "MINOR_COWARDICE", "OFF_BALANCE", "DEBUFF_EXTENSION",
    -- Other Effects
    "MINOR_VITALITY", "ARMOR_SUPPORT",
    "ULT_WARHORN", "ULT_BARRIER", "ULT_COLOSSUS", "ULT_STANDARD", "ULT_NOVA", "ULT_METEOR", "ULT_ATRONACH", "ULT_CRYPTCANNON",
}

local CLASSIFICATION_RANK = { BEST_IN_SLOT=1, COMMON=2, ADVANCED=3, ALTERNATIVE=4, NICHE=5, LEGACY=6, VALID=7 }

local function CopyProvider(provider)
    return {
        key = provider.key, name = provider.name or provider.key,
        providerType = provider.providerType or provider.category or "OTHER",
        instructions = provider.instructions,
        classification = provider.classification or "VALID",
        candidateWerewolf = provider.candidateWerewolf == true,
        candidateClassIds = provider.candidateClassIds,
        candidateRoles = provider.candidateRoles,
    }
end

function Engine:GetCoreEffects(effectType)
    local output = {}
    for _, key in ipairs(EFFECT_ORDER) do
        local effect = C.Registry:Get("EFFECTS", key)
        if effect and (not effectType or effect.effectType == effectType) then output[#output + 1] = effect end
    end
    return output
end

function Engine:GetProviderOptions(effectKey)
    local providers = {}
    if not C.KnowledgeBase then return providers end
    for _, provider in ipairs(C.KnowledgeBase:GetProvidersForEffect(effectKey) or {}) do providers[#providers + 1] = CopyProvider(provider) end
    table.sort(providers, function(a,b)
        local ar=CLASSIFICATION_RANK[a.classification] or 99
        local br=CLASSIFICATION_RANK[b.classification] or 99
        if ar ~= br then return ar < br end
        return tostring(a.name) < tostring(b.name)
    end)
    return providers
end

function Engine:GetBestProvider(effectKey)
    return self:GetProviderOptions(effectKey)[1]
end

function Engine:BuildEffectStatus(profile)
    profile = profile or {}
    local present = {}
    for _, list in ipairs({ profile.buffs or {}, profile.debuffs or {}, profile.supportFunctions or {}, profile.ultimates or {} }) do
        for _, entry in ipairs(list) do present[entry.key] = entry end
    end
    local output = {}
    for _, effect in ipairs(self:GetCoreEffects()) do
        local detected = present[effect.key]
        local providers = self:GetProviderOptions(effect.key)
        output[#output + 1] = {
            key=effect.key, name=effect.name or effect.key, effectType=effect.effectType or "OTHER",
            whyItMatters=effect.whyItMatters or "", status=detected and "PRESENT" or "NOT_DETECTED",
            detectedSources=detected and (detected.sources or {}) or {}, sourceSummary=detected and (detected.sourceSummary or "") or "",
            providers=providers, bestProvider=providers[1], required=false,
        }
    end
    return output
end

function Engine:Initialize() self.initialized=true end
