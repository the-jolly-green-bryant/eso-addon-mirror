local C = Conductor
C.RaidIntelligenceEngine = C.RaidIntelligenceEngine or {}
local Engine = C.RaidIntelligenceEngine

local CLASS_NAMES = {
    [1] = "Dragonknight",
    [2] = "Sorcerer",
    [3] = "Nightblade",
    [4] = "Warden",
    [5] = "Necromancer",
    [6] = "Templar",
    [117] = "Arcanist",
}

local function CopySources(entry)
    local sources = {}
    for _, source in ipairs(entry.sources or {}) do
        sources[#sources + 1] = {
            type = source.type,
            name = source.name,
            confidence = source.confidence,
            details = source.details,
        }
    end
    return sources
end

local function Add(target, entry)
    target[#target + 1] = {
        key = entry.key,
        name = entry.name,
        category = entry.category,
        confidence = entry.confidence or "CONFIRMED",
        sources = CopySources(entry),
    }
end

local function Has(profile, key)
    return profile.index[key] ~= nil
end

local function SourceSummary(entry)
    local names = {}
    local seen = {}
    for _, source in ipairs(entry.sources or {}) do
        local name = tostring(source.name or source.type or "Unknown")
        if not seen[name] then
            seen[name] = true
            names[#names + 1] = name
        end
    end
    return table.concat(names, ", ")
end

function Engine:BuildProfile(snapshot)
    snapshot = snapshot or {}
    local capabilities = snapshot.capabilities or {}
    local profile = {
        accountName = snapshot.accountName or "",
        characterName = snapshot.characterName or "",
        classId = tonumber(snapshot.classId) or 0,
        className = CLASS_NAMES[tonumber(snapshot.classId) or 0] or ("Class " .. tostring(snapshot.classId or 0)),
        selectedRole = snapshot.role or "UNKNOWN",
        contributions = {},
        buffs = {},
        debuffs = {},
        supportFunctions = {},
        ultimates = {},
        responsibilities = {},
        index = {},
        roleFit = { name = "Unclassified", reason = "Not enough recognized capability data", confidence = "REVIEW" },
        generatedAt = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0,
    }

    for _, entry in ipairs(capabilities.interpreted or {}) do
        profile.index[entry.key] = entry
        if entry.category == "BUFF" then
            Add(profile.buffs, entry)
            Add(profile.contributions, entry)
        elseif entry.category == "DEBUFF" then
            Add(profile.debuffs, entry)
            Add(profile.contributions, entry)
        elseif entry.category == "SUPPORT" or entry.category == "FUNCTION" then
            Add(profile.supportFunctions, entry)
            Add(profile.contributions, entry)
        elseif entry.category == "ULTIMATE" then
            Add(profile.ultimates, entry)
            Add(profile.contributions, entry)
        elseif entry.category == "RESPONSIBILITY" then
            Add(profile.responsibilities, entry)
        end
    end

    local healingSignals = 0
    if Has(profile, "HEALING") then healingSignals = healingSignals + 1 end
    if Has(profile, "GROUP_HEAL") then healingSignals = healingSignals + 1 end
    if Has(profile, "BARRIER_PROVIDER") then healingSignals = healingSignals + 1 end
    if Has(profile, "OZEZAN_PROVIDER") then healingSignals = healingSignals + 1 end

    if healingSignals >= 3 then
        profile.roleFit = {
            name = "Support Healer",
            confidence = "STRONG MATCH",
            reason = "Healing, group support, and defensive ultimate capabilities detected",
        }
    elseif Has(profile, "SLAYER_PROVIDER") and healingSignals >= 1 then
        profile.roleFit = {
            name = "Support Healer / Slayer Provider",
            confidence = "STRONG MATCH",
            reason = "Healing capabilities and a Major Slayer source detected",
        }
    elseif Has(profile, "VULNERABILITY_PROVIDER") and tostring(snapshot.role) == "TANK" then
        profile.roleFit = {
            name = "Support Tank",
            confidence = "STRONG MATCH",
            reason = "Tank role and Major Vulnerability capability detected",
        }
    elseif Has(profile, "SLAYER_PROVIDER") then
        profile.roleFit = {
            name = "Slayer Support",
            confidence = "MATCH",
            reason = "Major Slayer provider detected",
        }
    elseif Has(profile, "BARRIER_PROVIDER") then
        profile.roleFit = {
            name = "Defensive Support",
            confidence = "MATCH",
            reason = "Barrier responsibility detected",
        }
    end

    for _, list in ipairs({ profile.buffs, profile.debuffs, profile.supportFunctions, profile.ultimates, profile.responsibilities }) do
        table.sort(list, function(a, b) return tostring(a.name) < tostring(b.name) end)
        for _, entry in ipairs(list) do entry.sourceSummary = SourceSummary(entry) end
    end

    if C.ProviderGuidanceEngine then
        profile.effectStatus = C.ProviderGuidanceEngine:BuildEffectStatus(profile)
    end

    profile.index = nil
    capabilities.raidIntelligence = profile
    snapshot.raidIntelligence = profile
    return profile
end

function Engine:GetProfile(snapshot)
    if snapshot and snapshot.raidIntelligence then return snapshot.raidIntelligence end
    return self:BuildProfile(snapshot)
end

function Engine:Initialize()
    self.initialized = true
    if C.EventBus then
        C.EventBus:Subscribe("LOCAL_CAPABILITIES_CHANGED", "RaidIntelligenceEngine", function(payload)
            if payload and payload.snapshot then Engine:BuildProfile(payload.snapshot) end
        end)
    end
end
