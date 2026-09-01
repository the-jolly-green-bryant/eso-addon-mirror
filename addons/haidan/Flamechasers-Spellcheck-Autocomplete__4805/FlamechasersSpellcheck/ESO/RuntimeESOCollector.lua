-- Flamechasers Spellcheck & Autocomplete: runtime ESO lexicon collector
-- Uses only native ESO APIs. It does not write files or access the network.
--
-- The hand-curated ESOSeed.lua is intentionally small enough to review. This file
-- supplements it from the player's installed game data so new abilities, morphs,
-- Champion stars, Scribing names, activities, zones, and item sets can be recognized
-- without waiting for a Spellcheck release.

local FSC = FlamechasersSpellcheck
local E = FSC.ESO

E.runtimeTokens = E.runtimeTokens or {}
E.runtimePhrases = E.runtimePhrases or {}
E.runtimePhraseSet = E.runtimePhraseSet or {}
E.runtimeTokensBySubcategory = E.runtimeTokensBySubcategory or {}
E.runtimeTokenSubcategories = E.runtimeTokenSubcategories or {}
E.runtimePhrasesBySubcategory = E.runtimePhrasesBySubcategory or {}
E.runtimePhraseSetsBySubcategory = E.runtimePhraseSetsBySubcategory or {}
E.runtimeRevision = E.runtimeRevision or 0
E.runtimeBuildFlags = E.runtimeBuildFlags or {}
E.runtimeStats = E.runtimeStats or {}
-- All runtime ESO tokens, bucketed by byte length as they are learned. Correction
-- generation filters category enablement at read time, so this index never needs a
-- first-click rebuild and does not need to be regenerated when settings change.
E.runtimeCorrectionAllLengthIndex = E.runtimeCorrectionAllLengthIndex or {}
E.runtimeCorrectionEdgeIndex = E.runtimeCorrectionEdgeIndex or {}

local function CategoryEnabled(id)
    return E.IsSubcategoryEnabled(id)
end

local function NormalizeToken(token)
    if not token then return nil end
    token = token:gsub("’", "'")
    token = string.lower(token)
    token = token:gsub("^['\"]+", ""):gsub("['\"]+$", "")
    if token == "" then return nil end
    return token
end

local function NormalizePhraseKey(phrase)
    phrase = tostring(phrase or "")
    phrase = phrase:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    phrase = phrase:gsub("%s+", " ")
    phrase = phrase:gsub("^%s+", ""):gsub("%s+$", "")
    phrase = phrase:gsub("’", "'")
    return string.lower(phrase)
end

local RUNTIME_TOKEN_STOPWORDS = {
    ["a"] = true, ["an"] = true, ["and"] = true, ["as"] = true, ["at"] = true,
    ["by"] = true, ["for"] = true, ["from"] = true, ["in"] = true, ["into"] = true,
    ["of"] = true, ["on"] = true, ["or"] = true, ["the"] = true, ["to"] = true,
    ["with"] = true, ["without"] = true,
}

local function BuildStaticPhraseSet()
    if E._staticPhraseSet then return E._staticPhraseSet end
    local set = {}
    for _, phrases in pairs(E.phrases or {}) do
        for _, phrase in ipairs(phrases) do
            local key = NormalizePhraseKey(phrase)
            if key ~= "" then set[key] = true end
        end
    end
    E._staticPhraseSet = set
    return set
end

local function BuildStaticPhraseSubcategorySet()
    if E._staticPhraseSubcategorySet then return E._staticPhraseSubcategorySet end
    local set = {}
    for category, phrases in pairs(E.phrases or {}) do
        local subcategory = E.GetPhraseSubcategory(category)
        for _, phrase in ipairs(phrases) do
            local key = NormalizePhraseKey(phrase)
            if key ~= "" then
                set[key] = set[key] or {}
                set[key][subcategory] = true
            end
        end
    end
    E._staticPhraseSubcategorySet = set
    return set
end

local function IndexRuntimeCorrectionToken(word)
    if not word or word == "" then return end
    local length = #word
    local bucket = E.runtimeCorrectionAllLengthIndex[length]
    if not bucket then bucket = {}; E.runtimeCorrectionAllLengthIndex[length] = bucket end
    bucket[word] = true

    -- Most plausible corrections preserve at least the first or last character.
    -- Keep two compact edge buckets per token so right-click correction generation
    -- can retrieve that common case without walking every runtime word of a length.
    local edge = E.runtimeCorrectionEdgeIndex[length]
    if not edge then edge = { first = {}, last = {} }; E.runtimeCorrectionEdgeIndex[length] = edge end
    local first, last = word:sub(1,1), word:sub(-1)
    local firstBucket = edge.first[first]
    if not firstBucket then firstBucket = {}; edge.first[first] = firstBucket end
    firstBucket[#firstBucket + 1] = word
    local lastBucket = edge.last[last]
    if not lastBucket then lastBucket = {}; edge.last[last] = lastBucket end
    lastBucket[#lastBucket + 1] = word
end

-- Adds the individual words in a display name to a token set. Returning the number
-- of newly inserted tokens lets the runtime collector invalidate caches only when
-- something actually changed.
function E.AddPhrase(target, phrase, skipStopwords)
    if not target or not phrase or phrase == "" then return 0 end
    local added = 0

    -- ESO's English client is overwhelmingly Latin-script. Apostrophes/hyphens are
    -- kept as part of a name, while hyphen components are also indexed separately.
    for token in tostring(phrase):gmatch("[A-Za-zÀ-ÖØ-öø-ÿ][A-Za-zÀ-ÖØ-öø-ÿ'’%-]*") do
        local n = NormalizeToken(token)
        if n then
            local skipToken = (skipStopwords == true or target == E.runtimeTokens) and RUNTIME_TOKEN_STOPWORDS[n] == true
            if not skipToken and not target[n] then
                target[n] = true
                added = added + 1
                if target == E.runtimeTokens then IndexRuntimeCorrectionToken(n) end
            end
            if not skipToken and n:find("-", 1, true) then
                for part in n:gmatch("[^%-]+") do
                    if part ~= "" and not target[part] then
                        target[part] = true
                        added = added + 1
                        if target == E.runtimeTokens then IndexRuntimeCorrectionToken(part) end
                    end
                end
            end
        end
    end
    return added
end

local function MarkPendingChanges(amount)
    amount = tonumber(amount) or 0
    if amount > 0 then E._pendingRuntimeChanges = (E._pendingRuntimeChanges or 0) + amount end
end

local function FlushRuntimeChanges()
    local changes = E._pendingRuntimeChanges or 0
    if changes <= 0 then return 0 end
    E._pendingRuntimeChanges = 0
    E.runtimeRevision = (E.runtimeRevision or 0) + 1
    FSC.dictionaryStateSignatureCache = nil
    E.runtimeAutocompletePrefixIndex = nil
    return changes
end

-- Adds both the words and, when useful for prediction, the whole phrase. Static seed
-- phrases are not duplicated in runtimePhrases, preventing accidental double-weighting.
function E.AddRuntimePhrase(phrase, subcategory)
    if not phrase or phrase == "" then return false end
    subcategory = tostring(subcategory or "general")
    phrase = tostring(phrase)

    local categoryTokens = E.runtimeTokensBySubcategory[subcategory]
    if not categoryTokens then categoryTokens = {}; E.runtimeTokensBySubcategory[subcategory] = categoryTokens end

    local tokenAdds = E.AddPhrase(E.runtimeTokens, phrase, true)
    local categoryTokenAdds = E.AddPhrase(categoryTokens, phrase, true)

    -- Record category membership for fast category-aware known-word checks.
    for token in tostring(phrase):gmatch("[A-Za-zÀ-ÖØ-öø-ÿ][A-Za-zÀ-ÖØ-öø-ÿ'’%-]*") do
        local n = NormalizeToken(token)
        if n and not RUNTIME_TOKEN_STOPWORDS[n] then
            E.runtimeTokenSubcategories[n] = E.runtimeTokenSubcategories[n] or {}
            E.runtimeTokenSubcategories[n][subcategory] = true
            if n:find("-", 1, true) then
                for part in n:gmatch("[^%-]+") do
                    if part ~= "" and not RUNTIME_TOKEN_STOPWORDS[part] then
                        E.runtimeTokenSubcategories[part] = E.runtimeTokenSubcategories[part] or {}
                        E.runtimeTokenSubcategories[part][subcategory] = true
                    end
                end
            end
        end
    end

    local key = NormalizePhraseKey(phrase)
    local phraseAdded = false
    local categoryPhraseAdded = false
    local staticMemberships = BuildStaticPhraseSubcategorySet()[key]
    local staticInSameCategory = staticMemberships and staticMemberships[subcategory]

    if key ~= "" and not staticInSameCategory then
        local categorySet = E.runtimePhraseSetsBySubcategory[subcategory]
        if not categorySet then categorySet = {}; E.runtimePhraseSetsBySubcategory[subcategory] = categorySet end
        if not categorySet[key] then
            categorySet[key] = true
            local categoryPhrases = E.runtimePhrasesBySubcategory[subcategory]
            if not categoryPhrases then categoryPhrases = {}; E.runtimePhrasesBySubcategory[subcategory] = categoryPhrases end
            categoryPhrases[#categoryPhrases + 1] = phrase
            categoryPhraseAdded = true
        end
    end

    -- Preserve the aggregate runtime list for compatibility/diagnostics. Core engines
    -- use the category-aware iterators below.
    if key ~= "" and not BuildStaticPhraseSet()[key] and not E.runtimePhraseSet[key] then
        E.runtimePhraseSet[key] = true
        E.runtimePhrases[#E.runtimePhrases + 1] = phrase
        phraseAdded = true
    end

    local changed = tokenAdds + categoryTokenAdds + (phraseAdded and 1 or 0) + (categoryPhraseAdded and 1 or 0)
    if changed > 0 then
        MarkPendingChanges(changed)
        return true
    end
    return false
end

function E.IsRuntimeTokenEnabled(word)
    local memberships = E.runtimeTokenSubcategories and E.runtimeTokenSubcategories[word]
    if not memberships then return false end
    for subcategory in pairs(memberships) do
        if CategoryEnabled(subcategory) then return true end
    end
    return false
end

function E.ForEachEnabledRuntimeToken(callback)
    if type(callback) ~= "function" then return end
    local seen = {}
    for subcategory, tokens in pairs(E.runtimeTokensBySubcategory or {}) do
        if CategoryEnabled(subcategory) then
            for word in pairs(tokens) do
                if not seen[word] then seen[word] = true; callback(word, subcategory) end
            end
        end
    end
end

function E.ForEachEnabledRuntimePhrase(callback)
    if type(callback) ~= "function" then return end
    local seen = {}
    for subcategory, phrases in pairs(E.runtimePhrasesBySubcategory or {}) do
        if CategoryEnabled(subcategory) then
            for _, phrase in ipairs(phrases) do
                local key = NormalizePhraseKey(phrase)
                if not seen[key] then seen[key] = true; callback(phrase, subcategory) end
            end
        end
    end
end

local function AddPhraseFromValue(statKey, subcategory, phrase)
    if not CategoryEnabled(subcategory) or not phrase or phrase == "" then return false end
    if E.AddRuntimePhrase(phrase, subcategory) then
        E.runtimeStats[statKey] = (E.runtimeStats[statKey] or 0) + 1
        return true
    end
    return false
end

local function CollectZonesAndMaps()
    if not CategoryEnabled("locations") or E.runtimeBuildFlags.zonesAndMaps then return 0 end
    local before = E._pendingRuntimeChanges or 0

    for zoneIndex = 1, GetNumZones() do
        AddPhraseFromValue("zonesAndMaps", "locations", GetZoneNameByIndex(zoneIndex))
    end
    for mapIndex = 1, GetNumMaps() do
        AddPhraseFromValue("zonesAndMaps", "locations", GetMapNameByIndex(mapIndex))
    end

    E.runtimeBuildFlags.zonesAndMaps = true
    return (E._pendingRuntimeChanges or 0) - before
end

local function CollectCoreNames()
    local before = E._pendingRuntimeChanges or 0

    if CategoryEnabled("general") and not E.runtimeBuildFlags.classes then
        for classIndex = 1, GetNumClasses() do
            local classId = GetClassIdByIndex(classIndex)
            AddPhraseFromValue("classes", "general", GetClassName(GENDER_MALE, classId))
            AddPhraseFromValue("classes", "general", GetClassName(GENDER_FEMALE, classId))
        end
        E.runtimeBuildFlags.classes = true
    end

    if CategoryEnabled("lore") and not E.runtimeBuildFlags.alliances then
        AddPhraseFromValue("alliances", "lore", GetAllianceName(ALLIANCE_ALDMERI_DOMINION))
        AddPhraseFromValue("alliances", "lore", GetAllianceName(ALLIANCE_DAGGERFALL_COVENANT))
        AddPhraseFromValue("alliances", "lore", GetAllianceName(ALLIANCE_EBONHEART_PACT))
        E.runtimeBuildFlags.alliances = true
    end

    return (E._pendingRuntimeChanges or 0) - before
end

local function LearnSkillLineName(skillType, skillLineIndex)
    local skillLineId = GetSkillLineId(skillType, skillLineIndex)
    AddPhraseFromValue("skillLines", "skills", GetSkillLineNameById(skillLineId))
end

function E.LearnSkillLexicon()
    if not CategoryEnabled("skills") or E.runtimeBuildFlags.skills then return 0 end
    if not AreSkillsInitialized() then return 0 end -- game data can initialize after addon load

    local before = E._pendingRuntimeChanges or 0
    for skillType = 1, GetNumSkillTypes() do
        for skillLineIndex = 1, GetNumSkillLines(skillType) do
            LearnSkillLineName(skillType, skillLineIndex)
            for skillIndex = 1, GetNumSkillAbilities(skillType, skillLineIndex) do
                local name, _, _, _, _, _, progressionIndex = GetSkillAbilityInfo(skillType, skillLineIndex, skillIndex)
                AddPhraseFromValue("skills", "skills", name)
                if progressionIndex then
                    for morph = 1, 2 do
                        local morphName = GetAbilityProgressionAbilityInfo(progressionIndex, morph, 1)
                        AddPhraseFromValue("skillMorphs", "skills", morphName)
                    end
                end
            end
        end
    end

    E.runtimeBuildFlags.skills = true
    return (E._pendingRuntimeChanges or 0) - before
end

function E.LearnChampionLexicon()
    if not CategoryEnabled("systems") or E.runtimeBuildFlags.champion then return 0 end
    local before = E._pendingRuntimeChanges or 0

    for disciplineIndex = 1, GetNumChampionDisciplines() do
        local disciplineId = GetChampionDisciplineId(disciplineIndex)
        AddPhraseFromValue("championDisciplines", "systems", GetChampionDisciplineName(disciplineId))
        for skillIndex = 1, GetNumChampionDisciplineSkills(disciplineIndex) do
            local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
            AddPhraseFromValue("championSkills", "systems", GetChampionSkillName(skillId))
            if IsChampionSkillClusterRoot(skillId) then
                AddPhraseFromValue("championClusters", "systems", GetChampionClusterName(skillId))
            end
        end
    end

    E.runtimeBuildFlags.champion = true
    return (E._pendingRuntimeChanges or 0) - before
end

function E.LearnScribingLexicon()
    if not CategoryEnabled("systems") or E.runtimeBuildFlags.scribing then return 0 end
    local before = E._pendingRuntimeChanges or 0
    local slots = { SCRIBING_SLOT_PRIMARY, SCRIBING_SLOT_SECONDARY, SCRIBING_SLOT_TERTIARY }

    for index = 1, GetNumCraftedAbilities() do
        local craftedAbilityId = GetCraftedAbilityIdAtIndex(index)
        AddPhraseFromValue("scribingGrimoires", "systems", GetCraftedAbilityDisplayName(craftedAbilityId))
        for _, slotType in ipairs(slots) do
            for scriptIndex = 1, GetNumScriptsInSlotForCraftedAbility(craftedAbilityId, slotType) do
                local scriptId = GetScriptIdAtSlotIndexForCraftedAbility(craftedAbilityId, slotType, scriptIndex)
                AddPhraseFromValue("scribingScripts", "systems", GetCraftedAbilityScriptDisplayName(scriptId))
            end
        end
    end

    E.runtimeBuildFlags.scribing = true
    return (E._pendingRuntimeChanges or 0) - before
end

function E.LearnItemSetLexicon()
    if not CategoryEnabled("sets") or E.runtimeBuildFlags.itemSets then return 0 end
    local before = E._pendingRuntimeChanges or 0
    local itemSetId = GetNextItemSetCollectionId(nil)
    while itemSetId do
        AddPhraseFromValue("itemSets", "sets", GetItemSetName(itemSetId))
        itemSetId = GetNextItemSetCollectionId(itemSetId)
    end

    E.runtimeBuildFlags.itemSets = true
    return (E._pendingRuntimeChanges or 0) - before
end

function E.LearnActivityLexicon()
    if not CategoryEnabled("activities") or E.runtimeBuildFlags.activities then return 0 end
    local before = E._pendingRuntimeChanges or 0
    local activityTypes = {
        LFG_ACTIVITY_DUNGEON,
        LFG_ACTIVITY_MASTER_DUNGEON,
        LFG_ACTIVITY_TRIAL,
        LFG_ACTIVITY_ARENA,
        LFG_ACTIVITY_ENDLESS_DUNGEON,
        LFG_ACTIVITY_ADVENTURE_ZONE,
    }
    local seenTypes = {}

    for _, activityType in ipairs(activityTypes) do
        if not seenTypes[activityType] then
            seenTypes[activityType] = true
            for index = 1, GetNumActivitiesByType(activityType) do
                local activityId = GetActivityIdByTypeAndIndex(activityType, index)
                AddPhraseFromValue("activities", "activities", GetActivityName(activityId))
            end
        end
    end

    E.runtimeBuildFlags.activities = true
    return (E._pendingRuntimeChanges or 0) - before
end

function E.BuildStaticRuntimeLexicon()
    CollectZonesAndMaps()
    CollectCoreNames()
    E.LearnSkillLexicon()
    E.LearnChampionLexicon()
    E.LearnScribingLexicon()
    E.LearnItemSetLexicon()
    E.LearnActivityLexicon()
    local changed = FlushRuntimeChanges()
    return E.runtimeTokens, changed
end

function E.LearnCurrentMap()
    if not CategoryEnabled("locations") then return E.runtimeTokens, 0 end
    local before = E._pendingRuntimeChanges or 0

    for locationIndex = 1, GetNumMapLocations() do
        AddPhraseFromValue("mapLocations", "locations", GetMapLocationTooltipHeader(locationIndex))
        for lineIndex = 1, GetNumMapLocationTooltipLines(locationIndex) do
            if IsMapLocationTooltipLineVisible(locationIndex, lineIndex) then
                local _, name = GetMapLocationTooltipLineInfo(locationIndex, lineIndex)
                AddPhraseFromValue("mapLocations", "locations", name)
            end
        end
    end

    -- Fast-travel nodes cover wayshrines and many instanced destinations. Build once;
    -- unlike map tooltip data, this list is global and does not need rescanning per zone.
    if not E.runtimeBuildFlags.fastTravel then
        for nodeIndex = 1, GetNumFastTravelNodes() do
            local _, name = GetFastTravelNodeInfo(nodeIndex)
            AddPhraseFromValue("fastTravel", "locations", name)
        end
        E.runtimeBuildFlags.fastTravel = true
    end

    local localChanges = (E._pendingRuntimeChanges or 0) - before
    local flushed = FlushRuntimeChanges()
    return E.runtimeTokens, math.max(localChanges, flushed)
end

function E.ContainsNormalized(word)
    if E.IsStaticTokenEnabled(word) then return true end
    return E.IsRuntimeTokenEnabled(word)
end

return E
