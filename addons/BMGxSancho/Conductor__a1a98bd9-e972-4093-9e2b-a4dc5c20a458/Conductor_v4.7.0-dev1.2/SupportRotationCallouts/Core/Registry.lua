local C = Conductor
C.Registry = C.Registry or {}
local Registry = C.Registry

Registry.collections = Registry.collections or {}
Registry.aliases = Registry.aliases or {}
Registry.validation = Registry.validation or { errors = {}, warnings = {} }
Registry.frozen = false
Registry.schemaVersion = 4
Registry.currentPatch = 101050

local function NormalizeKey(value)
    if value == nil then return nil end
    return string.upper(tostring(value)):gsub("[^A-Z0-9_]+", "_"):gsub("_+", "_"):gsub("^_", ""):gsub("_$", "")
end

local function CopyArray(values)
    local output = {}
    for index, value in ipairs(values or {}) do output[index] = value end
    return output
end

function Registry:DefineCollection(name)
    local key = NormalizeKey(name)
    if not key then return nil end
    self.collections[key] = self.collections[key] or { entries = {}, order = {} }
    return self.collections[key]
end

function Registry:Register(collectionName, key, definition)
    if self.frozen then return false, "registry is frozen" end
    local collectionKey = NormalizeKey(collectionName)
    local collection = self:DefineCollection(collectionKey)
    local normalizedKey = NormalizeKey(key)
    if not collection or not normalizedKey or type(definition) ~= "table" then
        return false, "invalid registry entry"
    end

    local isNew = collection.entries[normalizedKey] == nil
    definition.key = normalizedKey
    definition.id = definition.id or normalizedKey
    definition.registry = collectionKey
    definition.schemaVersion = definition.schemaVersion or self.schemaVersion
    definition.status = definition.status or "ACTIVE"
    definition.introducedPatch = definition.introducedPatch or definition.introduced or nil
    definition.lastVerifiedPatch = definition.lastVerifiedPatch or definition.verifiedPatch or definition.lastVerified or nil
    definition.deprecatedPatch = definition.deprecatedPatch or definition.deprecated or nil
    definition.removedPatch = definition.removedPatch or definition.removed or nil
    definition.introduced = definition.introducedPatch
    definition.verifiedPatch = definition.lastVerifiedPatch
    definition.deprecated = definition.deprecatedPatch
    definition.removed = definition.removedPatch
    definition.needsIdValidation = definition.needsIdValidation == true
    definition.tags = CopyArray(definition.tags)

    collection.entries[normalizedKey] = definition
    if isNew then collection.order[#collection.order + 1] = normalizedKey end
    return true, definition
end

function Registry:RegisterAlias(collectionName, alias, canonicalKey)
    local collection = NormalizeKey(collectionName)
    local aliasKey = NormalizeKey(alias)
    local canonical = NormalizeKey(canonicalKey)
    if not collection or not aliasKey or not canonical then return false end
    self.aliases[collection] = self.aliases[collection] or {}
    self.aliases[collection][aliasKey] = canonical
    return true
end

function Registry:ResolveKey(collectionName, key)
    local collection = NormalizeKey(collectionName)
    local normalized = NormalizeKey(key)
    local aliases = collection and self.aliases[collection]
    return aliases and aliases[normalized] or normalized
end

function Registry:Get(collectionName, key)
    local collection = self.collections[NormalizeKey(collectionName)]
    if not collection then return nil end
    return collection.entries[self:ResolveKey(collectionName, key)]
end

function Registry:GetAll(collectionName, includeInactive)
    local collection = self.collections[NormalizeKey(collectionName)]
    local output = {}
    if not collection then return output end
    for _, key in ipairs(collection.order) do
        local entry = collection.entries[key]
        if includeInactive or entry.status ~= "REMOVED" then output[#output + 1] = entry end
    end
    return output
end

function Registry:Find(collectionName, predicate)
    local output = {}
    if type(predicate) ~= "function" then return output end
    for _, entry in ipairs(self:GetAll(collectionName)) do
        if predicate(entry) then output[#output + 1] = entry end
    end
    return output
end

function Registry:IsEntryAvailable(entry, patch)
    if not entry or entry.status == "REMOVED" then return false end
    patch = tonumber(patch) or self.currentPatch
    if entry.introducedPatch and patch < entry.introducedPatch then return false end
    if entry.removedPatch and patch >= entry.removedPatch then return false end
    return true
end

function Registry:ValidateReferences()
    self.validation = { errors = {}, warnings = {} }
    for _, effect in ipairs(self:GetAll("EFFECTS", true)) do
        for _, providerKey in ipairs(effect.providers or {}) do
            if not self:Get("PROVIDERS", providerKey)
                and not self:Get("SKILLS", providerKey)
                and not self:Get("ULTIMATES", providerKey)
                and not self:Get("GEAR", providerKey)
                and not self:Get("MONSTER_SETS", providerKey)
                and not self:Get("ENCHANTMENTS", providerKey)
                and not self:Get("MASTERIES", providerKey)
                and not self:Get("SCRIBED_ABILITIES", providerKey) then
                self.validation.warnings[#self.validation.warnings + 1] = "Unresolved provider " .. tostring(providerKey) .. " for effect " .. tostring(effect.key)
            end
        end
    end
    for _, responsibility in ipairs(self:GetAll("RESPONSIBILITIES", true)) do
        if responsibility.effectKey and not self:Get("EFFECTS", responsibility.effectKey) then
            self.validation.errors[#self.validation.errors + 1] = "Responsibility " .. tostring(responsibility.key) .. " references missing effect " .. tostring(responsibility.effectKey)
        end
    end
    return self.validation
end

function Registry:Freeze() self.frozen = true end
function Registry:Initialize()
    self:ValidateReferences()
    self.initialized = true
end

function Registry:GetStatistics()
    local statistics = {collections=0,entries=0,active=0,removed=0,needsIdValidation=0}
    for _, collection in pairs(self.collections or {}) do
        statistics.collections = statistics.collections + 1
        for _, key in ipairs(collection.order or {}) do
            local entry = collection.entries[key]
            if entry then
                statistics.entries = statistics.entries + 1
                if entry.status == "REMOVED" then statistics.removed = statistics.removed + 1 else statistics.active = statistics.active + 1 end
                if entry.needsIdValidation then statistics.needsIdValidation = statistics.needsIdValidation + 1 end
            end
        end
    end
    return statistics
end
