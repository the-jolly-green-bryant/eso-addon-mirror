local TT = TamrielicTongues

TT.Proficiency = {
    SCHEMA_VERSION = 1,
    NativeLanguagesByRaceId = {
        [1] = "bretic", [2] = "yoku", [3] = "orcish",
        [4] = "dunmeri", [5] = "nordic", [6] = "altmeris",
        [7] = "bosmeri", [8] = "taagra", [9] = "jel", [10] = "common",
    },
}

-- Account preferences are deliberately not an input to this migration. Selecting
-- a speaking language in an older release is not evidence of knowing it.
function TT.Proficiency:Initialize(store, raceId)
    self.store = nil
    if type(store) ~= "table" then return false, "invalid-store" end
    local version = store.schemaVersion
    if version ~= nil and version ~= 0 and version ~= self.SCHEMA_VERSION then
        return false, "unsupported-schema"
    end
    local native = store.initialNativeLanguage
    if type(native) ~= "string" or native == "" then
        native = self.NativeLanguagesByRaceId[raceId]
        if not native then return false, "player-not-ready" end
    end

    -- v0 had no progression fields. Add them without replacing unrelated data,
    -- exposure history, or records for language packs that are not installed.
    if type(store.languages) ~= "table" then store.languages = {} end
    store.initialNativeLanguage = native
    store.schemaVersion = self.SCHEMA_VERSION
    local function ensure(id)
        local state = store.languages[id]
        if type(state) ~= "table" then
            store.languages[id] = TT.Knowledge:New(id == "common" or id == native)
        elseif TT.Knowledge:IsSupported(state) then
            TT.Knowledge:Normalize(state)
        end
    end
    ensure("common")
    for _, profile in ipairs(TT.Registry:GetOrdered()) do ensure(profile.id) end
    self.store = store
    return true
end

function TT.Proficiency:GetState(languageId)
    local id = TT.Registry:ResolveId(languageId)
    local state = self.store and id and self.store.languages[id]
    if type(state) ~= "table" or not TT.Knowledge:IsSupported(state) then return nil end
    return state
end

function TT.Proficiency:IsSupported(languageId)
    return self:GetState(languageId) ~= nil
end

function TT.Proficiency:GetProgressEnabled(languageId)
    local state = self:GetState(languageId)
    if not state then return nil end
    return TT.Knowledge:GetProgressEnabled(state)
end

function TT.Proficiency:SetProgressEnabled(languageId, enabled)
    local state = self:GetState(languageId)
    if not state then return false, "unavailable-knowledge" end
    return TT.Knowledge:SetProgressEnabled(state, enabled)
end

function TT.Proficiency:SetOverall(languageId, percent)
    local state = self:GetState(languageId)
    if not state then return false, "unavailable-knowledge" end
    return TT.Knowledge:SetOverall(state, percent)
end

function TT.Proficiency:GetOverall(languageId)
    local state = self:GetState(languageId)
    return state and TT.Knowledge:GetOverall(state) or nil
end

function TT.Proficiency:Study(languageId, lessonId, now)
    local state = self:GetState(languageId)
    if not state then return nil, "unavailable-knowledge" end
    return TT.Progression:Study(state, lessonId, now)
end

function TT.Proficiency:Practice(languageId, exerciseId, now)
    local state = self:GetState(languageId)
    if not state then return nil, "unavailable-knowledge" end
    return TT.Progression:Practice(state, exerciseId, now)
end
