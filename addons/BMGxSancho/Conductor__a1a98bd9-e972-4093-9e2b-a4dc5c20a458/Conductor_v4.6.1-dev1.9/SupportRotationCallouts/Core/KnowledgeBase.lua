local C = Conductor
C.KnowledgeBase = C.KnowledgeBase or {}
local Knowledge = C.KnowledgeBase

local SOURCE_COLLECTIONS = {"PROVIDERS","SKILLS","ULTIMATES","GEAR","MONSTER_SETS","ENCHANTMENTS","MASTERIES","SCRIBED_ABILITIES","CHAMPION_POINTS","PASSIVES","SYNERGIES","ABILITIES"}

local function ResolveProvider(providerKey)
    for _, collection in ipairs(SOURCE_COLLECTIONS) do
        local provider = C.Registry:Get(collection, providerKey)
        if provider then return provider, collection end
    end
    return nil, nil
end

function Knowledge:RebuildIndexes()
    self.providersByEffect = {}
    self.effectsByProvider = {}
    self.responsibilitiesByEffect = {}
    self.responsibilitiesByProvider = {}
    self.providerRecords = {}

    for _, effect in ipairs(C.Registry:GetAll("EFFECTS")) do
        self.providersByEffect[effect.key] = {}
        for _, providerKey in ipairs(effect.providers or {}) do
            local provider, collection = ResolveProvider(providerKey)
            local resolved = provider or {key=providerKey,id=providerKey,name=providerKey,unresolved=true,needsIdValidation=true}
            resolved.sourceRegistry = resolved.sourceRegistry or collection
            self.providersByEffect[effect.key][#self.providersByEffect[effect.key] + 1] = resolved
            self.effectsByProvider[providerKey] = self.effectsByProvider[providerKey] or {}
            self.effectsByProvider[providerKey][#self.effectsByProvider[providerKey] + 1] = effect
            self.providerRecords[providerKey] = resolved
        end
    end

    for _, responsibility in ipairs(C.Registry:GetAll("RESPONSIBILITIES")) do
        if responsibility.effectKey then
            self.responsibilitiesByEffect[responsibility.effectKey] = self.responsibilitiesByEffect[responsibility.effectKey] or {}
            self.responsibilitiesByEffect[responsibility.effectKey][#self.responsibilitiesByEffect[responsibility.effectKey] + 1] = responsibility
            for _, provider in ipairs(self.providersByEffect[responsibility.effectKey] or {}) do
                self.responsibilitiesByProvider[provider.key] = self.responsibilitiesByProvider[provider.key] or {}
                self.responsibilitiesByProvider[provider.key][#self.responsibilitiesByProvider[provider.key] + 1] = responsibility
            end
        end
    end
end

function Knowledge:GetEffect(effectKey) return C.Registry:Get("EFFECTS", effectKey) end
function Knowledge:GetResponsibility(responsibilityKey) return C.Registry:Get("RESPONSIBILITIES", responsibilityKey) end

function Knowledge:GetProvidersForEffect(effectKey, includeUnresolved)
    if not self.providersByEffect then self:RebuildIndexes() end
    local output = {}
    for _, provider in ipairs(self.providersByEffect[C.Registry:ResolveKey("EFFECTS", effectKey)] or {}) do
        if includeUnresolved or not provider.unresolved then output[#output + 1] = provider end
    end
    return output
end

function Knowledge:GetProvidersForResponsibility(responsibilityKey, includeUnresolved)
    local responsibility = self:GetResponsibility(responsibilityKey)
    if not responsibility then return {} end
    return self:GetProvidersForEffect(responsibility.effectKey, includeUnresolved)
end

function Knowledge:GetEffectsProvidedBy(providerKey)
    if not self.effectsByProvider then self:RebuildIndexes() end
    return self.effectsByProvider[C.Registry:ResolveKey("PROVIDERS", providerKey)] or self.effectsByProvider[providerKey] or {}
end

function Knowledge:GetResponsibilitiesForEffect(effectKey)
    if not self.responsibilitiesByEffect then self:RebuildIndexes() end
    return self.responsibilitiesByEffect[C.Registry:ResolveKey("EFFECTS", effectKey)] or {}
end

function Knowledge:FindProviderByDisplayName(name)
    local normalized = string.upper(tostring(name or "")):gsub("[^A-Z0-9]", "")
    for _, collection in ipairs(SOURCE_COLLECTIONS) do
        for _, entry in ipairs(C.Registry:GetAll(collection)) do
            local candidate = string.upper(tostring(entry.name or "")):gsub("[^A-Z0-9]", "")
            if candidate == normalized then return entry, collection end
        end
    end
    return nil, nil
end

function Knowledge:GetProvider(providerKey)
    if not self.providerRecords then self:RebuildIndexes() end
    local normalized = C.Registry:ResolveKey("PROVIDERS", providerKey)
    return self.providerRecords[normalized] or ResolveProvider(providerKey)
end

function Knowledge:GetResponsibilitiesProvidedBy(providerKey)
    if not self.responsibilitiesByProvider then self:RebuildIndexes() end
    local normalized = C.Registry:ResolveKey("PROVIDERS", providerKey)
    return self.responsibilitiesByProvider[normalized] or self.responsibilitiesByProvider[providerKey] or {}
end

function Knowledge:CanProviderSatisfy(providerKey, responsibilityKey)
    local responsibility = self:GetResponsibility(responsibilityKey)
    if not responsibility then return false end
    local normalized = C.Registry:ResolveKey("PROVIDERS", providerKey)
    for _, provider in ipairs(self:GetProvidersForEffect(responsibility.effectKey, true)) do
        if provider.key == normalized or provider.sourceKey == normalized or provider.key == providerKey then
            return true, provider
        end
    end
    return false, nil
end

function Knowledge:GetGraphNode(collectionName, key)
    collectionName = string.upper(tostring(collectionName or "")):gsub("[^A-Z0-9_]+", "_")
    local entry = C.Registry:Get(collectionName, key)
    if not entry then return nil end
    local node = {entry=entry,collection=collectionName,effects={},providers={},responsibilities={}}
    if collectionName == "EFFECTS" then
        node.providers = self:GetProvidersForEffect(entry.key, true)
        node.responsibilities = self:GetResponsibilitiesForEffect(entry.key)
    elseif collectionName == "RESPONSIBILITIES" then
        node.effects = {self:GetEffect(entry.effectKey)}
        node.providers = self:GetProvidersForResponsibility(entry.key, true)
    else
        node.effects = self:GetEffectsProvidedBy(entry.key)
        node.responsibilities = self:GetResponsibilitiesProvidedBy(entry.key)
    end
    return node
end

function Knowledge:FindByTag(collectionName, tag)
    local wanted = string.upper(tostring(tag or ""))
    return C.Registry:Find(collectionName, function(entry)
        for _, value in ipairs(entry.tags or {}) do
            if string.upper(tostring(value)) == wanted then return true end
        end
        return false
    end)
end

function Knowledge:GetProviderAlternatives(providerKey)
    local alternatives, seen = {}, {}
    for _, effect in ipairs(self:GetEffectsProvidedBy(providerKey)) do
        for _, provider in ipairs(self:GetProvidersForEffect(effect.key, false)) do
            if provider.key ~= providerKey and not seen[provider.key] then
                seen[provider.key] = true
                alternatives[#alternatives + 1] = provider
            end
        end
    end
    return alternatives
end

function Knowledge:GetUnverifiedEntries(collectionName)
    return C.Registry:Find(collectionName, function(entry) return entry.needsIdValidation == true end)
end

function Knowledge:GetCoverageReport()
    local report = { collections = {}, effectsWithoutResponsibility = 0, effectsWithoutProvider = 0 }
    for _, scope in ipairs(C.Registry:GetAll("KNOWLEDGE_SCOPE", true)) do
        local entries = C.Registry:GetAll(scope.collection, true)
        local unverified = 0
        for _, entry in ipairs(entries) do if entry.needsIdValidation then unverified = unverified + 1 end end
        report.collections[scope.collection] = { total=#entries, unverified=unverified, scope=scope.name }
    end
    for _, effect in ipairs(C.Registry:GetAll("EFFECTS", true)) do
        if #(self:GetResponsibilitiesForEffect(effect.key) or {}) == 0 then report.effectsWithoutResponsibility = report.effectsWithoutResponsibility + 1 end
        if #(self:GetProvidersForEffect(effect.key, true) or {}) == 0 then report.effectsWithoutProvider = report.effectsWithoutProvider + 1 end
    end
    return report
end

function Knowledge:GetValidationReport()
    return C.Registry.validation or {errors={},warnings={}}
end

function Knowledge:Initialize()
    self:RebuildIndexes()
    self.initialized = true
end
