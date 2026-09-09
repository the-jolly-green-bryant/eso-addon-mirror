local TT = TamrielicTongues

local XP_PER_LEVEL, MAX_XP, THRESHOLD_VERSION = 100, 10000, 1
TT.Knowledge = {
    XP_PER_LEVEL = XP_PER_LEVEL, MAX_XP = MAX_XP,
    THRESHOLD_VERSION = THRESHOLD_VERSION,
    Config = { vocabularyWeight = 0.7, grammarWeight = 0.3 },
}
local Knowledge = TT.Knowledge

local function integer(value, maximum)
    if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then return 0 end
    return math.floor(math.max(0, math.min(maximum, value)))
end

local function copy(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local result = {}
    seen[value] = result
    for key, item in pairs(value) do result[copy(key, seen)] = copy(item, seen) end
    return result
end

function Knowledge:New(native)
    return {
        schemaVersion = 1, thresholdVersion = THRESHOLD_VERSION,
        progressEnabled = true,
        vocabularyXP = native == true and MAX_XP or 0,
        grammarXP = native == true and MAX_XP or 0,
        masteredVocabulary = {}, masteredGrammar = {},
    }
end

local function supportedVersion(value)
    -- Missing/zero versions are legacy v1 input; malformed versions fail closed.
    return value == nil or (type(value) == "number" and value == math.floor(value)
        and value >= 0 and value <= 1)
end

function Knowledge:IsSupported(state)
    return type(state) == "table" and supportedVersion(state.schemaVersion)
        and supportedVersion(state.thresholdVersion)
end

-- Never reinterpret or migrate a state whose schema or thresholds we do not know.
function Knowledge:Normalize(state)
    if type(state) ~= "table" then state = {} end
    if not self:IsSupported(state) then return state end
    state.schemaVersion = 1
    state.thresholdVersion = THRESHOLD_VERSION
    state.progressEnabled = state.progressEnabled == nil or state.progressEnabled == true
    state.vocabularyXP = integer(state.vocabularyXP, MAX_XP)
    state.grammarXP = integer(state.grammarXP, MAX_XP)
    if type(state.masteredVocabulary) ~= "table" then state.masteredVocabulary = {} end
    if type(state.masteredGrammar) ~= "table" then state.masteredGrammar = {} end
    return state
end

function Knowledge:Snapshot(state)
    state = type(state) == "table" and state or {}
    if not self:IsSupported(state) then return copy(state) end
    return self:Normalize({
        schemaVersion = state.schemaVersion, thresholdVersion = state.thresholdVersion,
        vocabularyXP = state.vocabularyXP, grammarXP = state.grammarXP,
        progressEnabled = state.progressEnabled,
        masteredVocabulary = copy(state.masteredVocabulary),
        masteredGrammar = copy(state.masteredGrammar),
    })
end

-- Legacy missing flags are enabled; malformed flags fail closed even before migration.
function Knowledge:GetProgressEnabled(state)
    return self:IsSupported(state) and (state.progressEnabled == nil or state.progressEnabled == true)
end

function Knowledge:SetProgressEnabled(state, enabled)
    if not self:IsSupported(state) then return false, "unavailable-knowledge" end
    if type(enabled) ~= "boolean" then return false, "invalid-progress-enabled" end
    state.progressEnabled = enabled
    return true
end

function Knowledge:SetOverall(state, percent)
    if not self:IsSupported(state) then return false, "unavailable-knowledge" end
    if type(percent) ~= "number" or percent ~= percent or percent < 0 or percent > 100
        or percent ~= math.floor(percent) then return false, "invalid-overall" end
    state.vocabularyXP, state.grammarXP = percent * XP_PER_LEVEL, percent * XP_PER_LEVEL
    state.masteredVocabulary, state.masteredGrammar = {}, {}
    return true
end

function Knowledge:GetVocabularyLevel(state)
    if not self:IsSupported(state) then return 0 end
    return math.floor(integer(type(state) == "table" and state.vocabularyXP, MAX_XP) / XP_PER_LEVEL)
end

function Knowledge:GetGrammarLevel(state)
    if not self:IsSupported(state) then return 0 end
    return math.floor(integer(type(state) == "table" and state.grammarXP, MAX_XP) / XP_PER_LEVEL)
end

local function weight(value, fallback)
    if type(value) ~= "number" or value ~= value or value < 0 or value == math.huge then
        return fallback
    end
    return value
end

function Knowledge:GetOverall(state)
    if not self:IsSupported(state) then return 0 end
    local vocabularyLevel, grammarLevel = self:GetVocabularyLevel(state), self:GetGrammarLevel(state)
    if vocabularyLevel == grammarLevel then return vocabularyLevel end
    local config = type(self.Config) == "table" and self.Config or {}
    local vocabulary = weight(config.vocabularyWeight, 0.7)
    local grammar = weight(config.grammarWeight, 0.3)
    if vocabulary + grammar == 0 then vocabulary, grammar = 0.7, 0.3 end
    -- Scale before summing so even large finite configuration weights stay finite.
    local scale = math.max(vocabulary, grammar)
    vocabulary, grammar = vocabulary / scale, grammar / scale
    return integer((vocabularyLevel * vocabulary
        + grammarLevel * grammar) / (vocabulary + grammar) + 1e-10, 100)
end

local function mastered(state, map, id)
    return type(state) == "table" and type(state[map]) == "table" and state[map][id] == true
end

local function threshold(value)
    if type(value) ~= "number" or value ~= value or value < 0 or value > 100 then return 100 end
    return math.ceil(value)
end

function Knowledge:KnowsVocabulary(state, id, requirement)
    if not self:IsSupported(state) or type(id) ~= "string" or id == "" then return false end
    if id:sub(1, 4) == "oov:" then return self:GetVocabularyLevel(state) == 100 end
    local entry = TT.CanonicalCatalog:GetEntry(id)
    if not entry then return false end
    return mastered(state, "masteredVocabulary", id)
        or self:GetVocabularyLevel(state) >= threshold(entry.requirement)
end

function Knowledge:KnowsGrammar(state, id, requirement)
    if not self:IsSupported(state) or type(id) ~= "string" or id == "" then return false end
    local fixed = TT.CanonicalCatalog.GrammarRequirements[id]
    if fixed == nil then return false end
    return mastered(state, "masteredGrammar", id) or self:GetGrammarLevel(state) >= threshold(fixed)
end

function Knowledge:Grant(state, vocabularyXP, grammarXP)
    if type(state) == "table" and not self:GetProgressEnabled(state) then return state end
    state = self:Normalize(state)
    if not self:IsSupported(state) then return state end
    state.vocabularyXP = math.min(MAX_XP, state.vocabularyXP + integer(vocabularyXP, MAX_XP))
    state.grammarXP = math.min(MAX_XP, state.grammarXP + integer(grammarXP, MAX_XP))
    return state
end

function Knowledge:MasterVocabulary(state, id)
    if not self:GetProgressEnabled(state) or type(id) ~= "string" or id:sub(1, 4) == "oov:"
        or not TT.CanonicalCatalog:GetEntry(id) then return false end
    self:Normalize(state).masteredVocabulary[id] = true
    return true
end

function Knowledge:MasterGrammar(state, id)
    if not self:GetProgressEnabled(state) or type(id) ~= "string"
        or TT.CanonicalCatalog.GrammarRequirements[id] == nil then return false end
    self:Normalize(state).masteredGrammar[id] = true
    return true
end
