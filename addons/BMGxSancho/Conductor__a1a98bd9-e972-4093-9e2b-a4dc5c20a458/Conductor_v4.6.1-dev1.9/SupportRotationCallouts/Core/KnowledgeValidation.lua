local C = Conductor
C.KnowledgeValidation = C.KnowledgeValidation or {}
local Validation = C.KnowledgeValidation

local PROVIDER_COLLECTIONS = {
    PROVIDERS = true,
    SKILLS = true,
    ULTIMATES = true,
    GEAR = true,
    MONSTER_SETS = true,
    ENCHANTMENTS = true,
    MASTERIES = true,
    SCRIBED_ABILITIES = true,
    CHAMPION_POINTS = true,
    ABILITIES = true,
}

local function AddIssue(target, code, message, context)
    target[#target + 1] = {
        code = code,
        message = message,
        context = context or {},
    }
end

local function ProviderExists(key)
    for collectionName in pairs(PROVIDER_COLLECTIONS) do
        if C.Registry:Get(collectionName, key) then return true, collectionName end
    end
    return false, nil
end

local function ValidateStableId(entry, collectionName, report)
    if not entry.id or entry.id == "" then
        AddIssue(report.errors, "MISSING_STABLE_ID", "Registry entry is missing a stable ID", {collection=collectionName,key=entry.key})
    elseif entry.id ~= entry.key then
        AddIssue(report.warnings, "ID_KEY_MISMATCH", "Stable ID differs from registry key", {collection=collectionName,key=entry.key,id=entry.id})
    end
end

local function ValidateLifecycle(entry, collectionName, report)
    if entry.removedPatch and entry.introducedPatch and entry.removedPatch <= entry.introducedPatch then
        AddIssue(report.errors, "INVALID_PATCH_RANGE", "removedPatch must be later than introducedPatch", {collection=collectionName,key=entry.key})
    end
    if entry.lastVerifiedPatch and entry.introducedPatch and entry.lastVerifiedPatch < entry.introducedPatch then
        AddIssue(report.warnings, "VERIFIED_BEFORE_INTRODUCED", "lastVerifiedPatch predates introducedPatch", {collection=collectionName,key=entry.key})
    end
    if entry.status == "REMOVED" and not entry.removedPatch then
        AddIssue(report.warnings, "REMOVED_WITHOUT_PATCH", "Removed entry does not declare removedPatch", {collection=collectionName,key=entry.key})
    end
end

function Validation:Run()
    local report = {
        schemaVersion = C.Registry.schemaVersion,
        currentPatch = C.Registry.currentPatch,
        generatedAtMs = GetGameTimeMilliseconds and GetGameTimeMilliseconds() or 0,
        counts = {collections=0,entries=0,effects=0,providers=0,responsibilities=0,unverified=0},
        errors = {},
        warnings = {},
        unresolvedProviders = {},
    }

    local seenIds = {}
    for collectionName, collection in pairs(C.Registry.collections or {}) do
        report.counts.collections = report.counts.collections + 1
        for _, key in ipairs(collection.order or {}) do
            local entry = collection.entries[key]
            if entry then
                report.counts.entries = report.counts.entries + 1
                if collectionName == "EFFECTS" then report.counts.effects = report.counts.effects + 1 end
                if collectionName == "PROVIDERS" then report.counts.providers = report.counts.providers + 1 end
                if collectionName == "RESPONSIBILITIES" then report.counts.responsibilities = report.counts.responsibilities + 1 end
                if entry.needsIdValidation then report.counts.unverified = report.counts.unverified + 1 end

                ValidateStableId(entry, collectionName, report)
                ValidateLifecycle(entry, collectionName, report)

                local scopedId = collectionName .. ":" .. tostring(entry.id or entry.key)
                if seenIds[scopedId] then
                    AddIssue(report.errors, "DUPLICATE_STABLE_ID", "Stable ID is duplicated within a registry collection", {
                        id=entry.id or entry.key,
                        collection=collectionName,
                        first=seenIds[scopedId],
                        second=tostring(key),
                    })
                else
                    seenIds[scopedId] = tostring(key)
                end
            end
        end
    end

    for _, effect in ipairs(C.Registry:GetAll("EFFECTS", true)) do
        for _, providerKey in ipairs(effect.providers or {}) do
            local exists = ProviderExists(providerKey)
            if not exists then
                local issue = {effectKey=effect.key,providerKey=providerKey}
                report.unresolvedProviders[#report.unresolvedProviders + 1] = issue
                AddIssue(report.warnings, "UNRESOLVED_PROVIDER", "Effect references a provider that is not registered", issue)
            end
        end
    end

    for _, provider in ipairs(C.Registry:GetAll("PROVIDERS", true)) do
        if provider.sourceRegistry and provider.sourceKey then
            if not C.Registry:Get(provider.sourceRegistry, provider.sourceKey) then
                AddIssue(report.errors, "MISSING_PROVIDER_SOURCE", "Provider source registry entry is missing", {
                    providerKey=provider.key,
                    sourceRegistry=provider.sourceRegistry,
                    sourceKey=provider.sourceKey,
                })
            end
        end
        for _, effectKey in ipairs(provider.provides or {}) do
            if not C.Registry:Get("EFFECTS", effectKey) then
                AddIssue(report.errors, "MISSING_PROVIDED_EFFECT", "Provider references a missing effect", {providerKey=provider.key,effectKey=effectKey})
            end
        end
    end

    local responsibilitiesByEffect = {}
    for _, responsibility in ipairs(C.Registry:GetAll("RESPONSIBILITIES", true)) do
        if responsibility.effectKey then responsibilitiesByEffect[responsibility.effectKey] = true end
        if not responsibility.effectKey then
            AddIssue(report.errors, "RESPONSIBILITY_WITHOUT_EFFECT", "Responsibility has no effectKey", {responsibilityKey=responsibility.key})
        elseif not C.Registry:Get("EFFECTS", responsibility.effectKey) then
            AddIssue(report.errors, "RESPONSIBILITY_MISSING_EFFECT", "Responsibility references a missing effect", {responsibilityKey=responsibility.key,effectKey=responsibility.effectKey})
        end
    end

    for _, effect in ipairs(C.Registry:GetAll("EFFECTS", true)) do
        if not responsibilitiesByEffect[effect.key] then
            AddIssue(report.errors, "EFFECT_WITHOUT_RESPONSIBILITY", "Tracked effect has no responsibility object", {effectKey=effect.key})
        end
    end

    for _, collectionName in ipairs({"SKILLS","ULTIMATES","GEAR","MONSTER_SETS","ENCHANTMENTS","MASTERIES","SCRIBED_ABILITIES","CHAMPION_POINTS","PASSIVES","SYNERGIES"}) do
        for _, provider in ipairs(C.Registry:GetAll(collectionName, true)) do
            for _, effectKey in ipairs(provider.provides or {}) do
                if not C.Registry:Get("EFFECTS", effectKey) then
                    AddIssue(report.errors, "SOURCE_MISSING_EFFECT", "Provider source references a missing effect", {collection=collectionName,key=provider.key,effectKey=effectKey})
                end
            end
        end
    end

    self.report = report
    C.Registry.validation = report
    return report
end

function Validation:GetReport()
    return self.report or self:Run()
end

function Validation:IsHealthy()
    local report = self:GetReport()
    return #report.errors == 0
end

function Validation:Initialize()
    self:Run()
    self.initialized = true
end
