-- Flamechasers Spellcheck & Autocomplete: modular dictionary registry
-- Built-in dictionaries register here so Settings and the prediction engines do not
-- need hard-coded controls for every language/domain pack we may add later.

local FSC = FlamechasersSpellcheck

local English = FSC.English
local Frequency = FSC.Frequency
local ESO = FSC.ESO
local Chat = FSC.Chat

FSC.dictionaryPacks = FSC.dictionaryPacks or {}
FSC.dictionaryStateRevision = FSC.dictionaryStateRevision or 0
FSC.sortedDictionaryPacks = nil
FSC.dictionaryStateSignatureCache = nil
local DICTIONARY_LOOKUP_CACHE_MAX = 4096

local function CleanId(value)
    value = string.lower(tostring(value or ""))
    value = value:gsub("[^a-z0-9_%-]", "")
    return value
end

local function NormalizeSubcategories(definition)
    local out = {}
    for _, entry in ipairs(definition.subcategories or {}) do
        if type(entry) == "table" then
            local id = CleanId(entry.id)
            if id ~= "" then
                entry.id = id
                entry.name = tostring(entry.name or id)
                entry.description = tostring(entry.description or "")
                entry.order = tonumber(entry.order) or 100
                if entry.defaultEnabled == nil then entry.defaultEnabled = true end
                out[#out + 1] = entry
            end
        end
    end
    table.sort(out, function(a, b)
        if (a.order or 100) == (b.order or 100) then return tostring(a.name) < tostring(b.name) end
        return (a.order or 100) < (b.order or 100)
    end)
    definition.subcategories = out
end

function FSC:RegisterDictionaryPack(definition)
    if type(definition) ~= "table" then return false end
    local id = CleanId(definition.id)
    if id == "" then return false end

    definition.id = id
    definition.name = tostring(definition.name or id)
    definition.description = tostring(definition.description or "")
    definition.order = tonumber(definition.order) or 100
    if definition.defaultEnabled == nil then definition.defaultEnabled = true end
    NormalizeSubcategories(definition)

    self.dictionaryPacks[id] = definition
    self.sortedDictionaryPacks = nil
    self.dictionaryStateSignatureCache = nil
    return true
end

function FSC:GetDictionaryPacks()
    if self.sortedDictionaryPacks then return self.sortedDictionaryPacks end
    local packs = {}
    for _, pack in pairs(self.dictionaryPacks or {}) do packs[#packs + 1] = pack end
    table.sort(packs, function(a, b)
        if (a.order or 100) == (b.order or 100) then return tostring(a.name) < tostring(b.name) end
        return (a.order or 100) < (b.order or 100)
    end)
    self.sortedDictionaryPacks = packs
    return packs
end

function FSC:GetDictionarySubcategories(id)
    id = CleanId(id)
    local pack = self.dictionaryPacks and self.dictionaryPacks[id]
    return pack and pack.subcategories or {}
end

local function DictionaryStateTable(self, create)
    if not self.saved then return nil end
    if create then
        self.saved.settings = self.saved.settings or {}
        self.saved.settings.dictionaries = self.saved.settings.dictionaries or {}
    end
    return self.saved.settings and self.saved.settings.dictionaries or nil
end

local function DictionaryCategoryStateTable(self, packId, create)
    if not self.saved then return nil end
    if create then
        self.saved.settings = self.saved.settings or {}
        self.saved.settings.dictionaryCategories = self.saved.settings.dictionaryCategories or {}
        self.saved.settings.dictionaryCategories[packId] = self.saved.settings.dictionaryCategories[packId] or {}
    end
    local all = self.saved.settings and self.saved.settings.dictionaryCategories
    return all and all[packId] or nil
end

function FSC:IsDictionaryEnabled(id)
    id = CleanId(id)
    local pack = self.dictionaryPacks and self.dictionaryPacks[id]
    if not pack then return false end
    local states = DictionaryStateTable(self, false)
    if states and states[id] ~= nil then return states[id] ~= false end
    return pack.defaultEnabled ~= false
end

function FSC:IsDictionarySubcategoryEnabled(packId, subcategoryId)
    packId = CleanId(packId)
    subcategoryId = CleanId(subcategoryId)
    local pack = self.dictionaryPacks and self.dictionaryPacks[packId]
    if not pack then return false end

    local definition = nil
    for _, entry in ipairs(pack.subcategories or {}) do
        if entry.id == subcategoryId then definition = entry; break end
    end
    if not definition then return false end

    local states = DictionaryCategoryStateTable(self, packId, false)
    if states and states[subcategoryId] ~= nil then return states[subcategoryId] ~= false end
    return definition.defaultEnabled ~= false
end

function FSC:GetDictionaryStateSignature()
    if self.dictionaryStateSignatureCache then return self.dictionaryStateSignatureCache end
    local parts = {}
    for _, pack in ipairs(self:GetDictionaryPacks()) do
        local revision = ""
        if type(pack.revision) == "function" then
            local value = pack.revision(pack, self)
            if value ~= nil then revision = "@" .. tostring(value) end
        elseif pack.revision ~= nil then
            revision = "@" .. tostring(pack.revision)
        end

        local categoryState = {}
        for _, subcategory in ipairs(pack.subcategories or {}) do
            categoryState[#categoryState + 1] = subcategory.id .. ":" .. (self:IsDictionarySubcategoryEnabled(pack.id, subcategory.id) and "1" or "0")
        end
        local categories = #categoryState > 0 and ("[" .. table.concat(categoryState, ",") .. "]") or ""
        parts[#parts + 1] = pack.id .. "=" .. (self:IsDictionaryEnabled(pack.id) and "1" or "0") .. categories .. revision
    end
    local signature = table.concat(parts, ";")
    self.dictionaryStateSignatureCache = signature
    return signature
end

function FSC:InvalidateDictionaryCaches()
    self.dictionaryStateRevision = (self.dictionaryStateRevision or 0) + 1
    self.dictionaryStateSignatureCache = nil
    self:InvalidateInputLayoutCaches()
    self.suggestionCache = {}
    self.suggestionCacheCount = 0
    self.dictionaryKnownWordCache = {}
    self.dictionaryKnownWordCacheCount = 0
    self.dictionaryFrequencyScoreCache = {}
    self.dictionaryFrequencyScoreCacheCount = 0
    self.autocompleteSeedBigrams = nil
    self.autocompleteSeedTrigrams = nil
    self.autocompleteSeedSignature = nil
    self.superSeedBigrams = nil
    self.superSeedTrigrams = nil
    self.superSeedFourgrams = nil
    self.superSeedSignature = nil
    self.superPredictionCacheKey = nil
    self.superPredictionCacheResults = nil

    ESO.autocompleteTokens = nil
    ESO.autocompleteTokensSignature = nil
    ESO.autocompletePrefixIndex = nil
    ESO.autocompletePrefixIndexSignature = nil
    ESO.runtimeAutocompletePrefixIndex = nil
    ESO.runtimeAutocompletePrefixIndexSignature = nil
    ESO.staticCorrectionLengthIndex = nil
    ESO.staticCorrectionLengthIndexSignature = nil
    ESO.staticCorrectionLengthIndexESOOnly = nil
    ESO.staticCorrectionLengthIndexESOOnlySignature = nil
    ESO.spellcheckSuggestionTokens = nil
    ESO.spellcheckSuggestionTokensSignature = nil
    ESO.spellcheckSuggestionTokensESOOnly = nil
    ESO.spellcheckSuggestionTokensESOOnlySignature = nil

    self:ScheduleRefresh(0)
end

function FSC:SetDictionaryEnabled(id, enabled)
    id = CleanId(id)
    local pack = self.dictionaryPacks and self.dictionaryPacks[id]
    if not pack then return false end
    local states = DictionaryStateTable(self, true)
    if not states then return false end

    local newValue = enabled == true
    local oldValue = self:IsDictionaryEnabled(id)
    states[id] = newValue
    if oldValue == newValue then return true end

    if newValue and type(pack.onEnabled) == "function" then
        pack.onEnabled(pack, self)
    elseif not newValue and type(pack.onDisabled) == "function" then
        pack.onDisabled(pack, self)
    end

    self:InvalidateDictionaryCaches()
    return true
end

function FSC:SetDictionarySubcategoryEnabled(packId, subcategoryId, enabled)
    packId = CleanId(packId)
    subcategoryId = CleanId(subcategoryId)
    local pack = self.dictionaryPacks and self.dictionaryPacks[packId]
    if not pack then return false end

    local definition = nil
    for _, entry in ipairs(pack.subcategories or {}) do
        if entry.id == subcategoryId then definition = entry; break end
    end
    if not definition then return false end

    local states = DictionaryCategoryStateTable(self, packId, true)
    if not states then return false end
    local newValue = enabled == true
    local oldValue = self:IsDictionarySubcategoryEnabled(packId, subcategoryId)
    states[subcategoryId] = newValue
    if oldValue == newValue then return true end

    if newValue and type(pack.onSubcategoryEnabled) == "function" then
        pack.onSubcategoryEnabled(pack, self, subcategoryId)
    elseif not newValue and type(pack.onSubcategoryDisabled) == "function" then
        pack.onSubcategoryDisabled(pack, self, subcategoryId)
    end

    self:InvalidateDictionaryCaches()
    return true
end

function FSC:SetAllDictionarySubcategories(packId, enabled)
    packId = CleanId(packId)
    local pack = self.dictionaryPacks and self.dictionaryPacks[packId]
    if not pack then return false end
    local states = DictionaryCategoryStateTable(self, packId, true)
    if not states then return false end
    for _, entry in ipairs(pack.subcategories or {}) do states[entry.id] = enabled == true end
    if enabled == true and type(pack.onSubcategoryEnabled) == "function" then
        pack.onSubcategoryEnabled(pack, self, nil)
    end
    self:InvalidateDictionaryCaches()
    return true
end

function FSC:ForEachEnabledDictionaryPack(callback)
    if type(callback) ~= "function" then return end
    for _, pack in ipairs(self:GetDictionaryPacks()) do
        if self:IsDictionaryEnabled(pack.id) then callback(pack) end
    end
end

function FSC:IsKnownByEnabledDictionary(word)
    self.dictionaryKnownWordCache = self.dictionaryKnownWordCache or {}
    local cached = self.dictionaryKnownWordCache[word]
    if cached ~= nil then return cached end

    local known = false
    self:ForEachEnabledDictionaryPack(function(pack)
        if known then return end
        local contains = pack.contains
        if type(contains) == "function" and contains(word, self, pack) then known = true end
    end)
    local count = (self.dictionaryKnownWordCacheCount or 0) + 1
    if count > DICTIONARY_LOOKUP_CACHE_MAX then
        self.dictionaryKnownWordCache = {}
        count = 1
    end
    self.dictionaryKnownWordCacheCount = count
    self.dictionaryKnownWordCache[word] = known
    return known
end

function FSC:GetDictionaryFrequencyScore(word)
    self.dictionaryFrequencyScoreCache = self.dictionaryFrequencyScoreCache or {}
    local cached = self.dictionaryFrequencyScoreCache[word]
    if cached ~= nil then return cached end

    local best = 0
    self:ForEachEnabledDictionaryPack(function(pack)
        local scorer = pack.frequencyScore
        if type(scorer) == "function" then
            local value = tonumber(scorer(word, self, pack)) or 0
            if value > best then best = value end
        end
    end)
    local count = (self.dictionaryFrequencyScoreCacheCount or 0) + 1
    if count > DICTIONARY_LOOKUP_CACHE_MAX then
        self.dictionaryFrequencyScoreCache = {}
        count = 1
    end
    self.dictionaryFrequencyScoreCacheCount = count
    self.dictionaryFrequencyScoreCache[word] = best
    return best
end

function FSC:EnumerateRegisteredAutocompleteCandidates(context, emit)
    if type(emit) ~= "function" then return end
    self:ForEachEnabledDictionaryPack(function(pack)
        if type(pack.autocompleteCandidates) == "function" then
            pack.autocompleteCandidates(context, emit, self, pack)
        end
    end)
end

function FSC:EnumerateRegisteredCorrectionCandidates(typo, context, emit)
    if type(emit) ~= "function" then return end
    self:ForEachEnabledDictionaryPack(function(pack)
        if type(pack.correctionCandidates) == "function" then
            pack.correctionCandidates(typo, context, emit, self, pack)
        end
    end)
end

function FSC:ForEachEnabledDictionaryPhrase(callback, superMode)
    if type(callback) ~= "function" then return end
    self:ForEachEnabledDictionaryPack(function(pack)
        local provider = pack.predictionPhrases
        if type(provider) == "function" then
            provider(callback, superMode == true, self, pack)
        end
    end)
end

FSC:RegisterDictionaryPack({
    id = "english",
    name = "English",
    description = "General English spelling, word-frequency data, common corrections, and informal chat/MMO vocabulary.",
    order = 10,
    defaultEnabled = true,
    contains = function(word)
        if Chat.ContainsNormalized(word) then return true end
        return English.ContainsNormalized(word)
    end,
    frequencyScore = function(word)
        return Frequency.GetScore(word) or 0
    end,
})

FSC:RegisterDictionaryPack({
    id = "eso",
    name = "ESO terminology",
    description = "Elder Scrolls Online names and terminology, including runtime names collected from the installed game client.",
    order = 20,
    defaultEnabled = true,
    subcategories = ESO.subcategories or {},
    subcategoryDescription = "All ESO categories stay enabled by default for compatibility. If the predictor feels too eager to suggest obscure names, Item sets & Mythics and Skills & skill lines are the two largest pools to turn off first. Category switches filter only built-in ESO knowledge; your Personal Dictionary and your own learned phrases stay independent.",
    contains = function(word)
        return ESO.ContainsNormalized(word)
    end,
    revision = function()
        return ESO.runtimeRevision or 0
    end,
    predictionPhrases = function(emit, superMode)
        ESO.ForEachEnabledStaticPhrase(function(phrase)
            emit(phrase, superMode and 3 or 5, not superMode)
        end)
        ESO.ForEachEnabledRuntimePhrase(function(phrase)
            emit(phrase, superMode and 2 or 3, true)
        end)
    end,
    onEnabled = function()
        ESO.BuildStaticRuntimeLexicon()
        ESO.LearnCurrentMap()
    end,
    onSubcategoryEnabled = function()
        -- Builders are idempotent and each one skips disabled categories, so this
        -- cheaply fills a category that was disabled when the addon first loaded.
        ESO.BuildStaticRuntimeLexicon()
        ESO.LearnCurrentMap()
    end,
})

return FSC
