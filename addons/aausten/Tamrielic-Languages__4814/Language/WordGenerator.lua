local TT = TamrielicTongues

TT.WordGenerator = {}

local HASH_MODULUS = 2147483647

-- These IDs have shipped v1 forms. Missing frozen data is a load-order error,
-- not permission to silently regenerate the wire vocabulary.
local released = {
    taagra = true, jel = true, dunmeri = true, altmeris = true, bosmeri = true,
    nordic = true, orcish = true, yoku = true, bretic = true,
}

function TT.WordGenerator:Hash(value, seed)
    local hash = (seed or 5381) % HASH_MODULUS
    for i = 1, #value do
        hash = (hash * 33 + value:byte(i)) % HASH_MODULUS
    end
    return hash
end

local function pick(values, hash, salt)
    local index = ((hash + salt * 7919) % #values) + 1
    return values[index]
end

function TT.WordGenerator:GenerateLexeme(profile, source, attempt)
    local id = string.lower(profile.id or "")
    if released[id] and profile.version == 1 then
        local frozen = assert(TT.FrozenVocabulary and TT.FrozenVocabulary[id],
            "load FrozenVocabulary before preparing released languages: " .. id)
        local entry = assert(frozen.words[source],
            "new released lexeme requires a compatible frozen-data update: " .. id .. ":" .. source)
        return entry[1]
    end
    local phonology = profile.phonology
    local attemptValue = tostring(attempt or 0)
    local base = source .. ":" .. attemptValue
    local baseHash = self:Hash(base, profile.seed)
    local syllables = 2 + (baseHash % 2)
    local parts = {}

    for syllable = 1, syllables do
        local tag = tostring(syllable)
        local onsetHash = self:Hash(base .. ":o:" .. tag, profile.seed + 11)
        local vowelHash = self:Hash(base .. ":v:" .. tag, profile.seed + 23)
        local codaHash = self:Hash(base .. ":c:" .. tag, profile.seed + 37)
        parts[#parts + 1] = phonology.onsets[(onsetHash % #phonology.onsets) + 1]
        parts[#parts + 1] = phonology.vowels[(vowelHash % #phonology.vowels) + 1]
        parts[#parts + 1] = phonology.codas[(codaHash % #phonology.codas) + 1]
    end

    local word = string.lower(table.concat(parts))
    word = word:gsub("[^a-z]", "")

    if #word < 3 then
        word = word .. phonology.lengthFix .. "n"
    end

    -- Unknown-word codec output is always an even number of ASCII letters.
    -- Keeping lexicon forms odd-length makes the two namespaces unambiguous.
    if #word % 2 == 0 then
        word = word .. phonology.lengthFix
    end

    return word
end

function TT.WordGenerator:BuildLexicon(profile)
    local id = string.lower(profile.id or "")
    if released[id] and profile.version == 1 then
        local frozen = assert(TT.FrozenVocabulary and TT.FrozenVocabulary[id],
            "load FrozenVocabulary before preparing released languages: " .. id)
        assert(frozen.version == 1, "unsupported frozen vocabulary version: " .. id)
        local lexicon, reverse = {}, {}
        -- Validate before mutating the profile, including extra authored entries:
        -- new canonical forms require an explicit compatible frozen-data update.
        for source, target in pairs(profile.lexicon or {}) do
            assert(frozen.words[source] and frozen.words[source][1] == target,
                "changed released lexicon mapping: " .. id .. ":" .. source)
        end
        for source, entry in pairs(frozen.words) do
            local target = entry[1]
            assert(type(target) == "string" and target:match("^[a-z]+$") and #target % 2 == 1,
                "invalid frozen lexicon target: " .. tostring(target))
            assert(not reverse[target], "duplicate frozen lexicon target: " .. target)
            lexicon[source], reverse[target] = target, source
        end
        profile.lexicon, profile.reverseLexicon = lexicon, reverse
        return
    end

    profile.lexicon = profile.lexicon or {}
    profile.reverseLexicon = {}

    local used = {}

    for source, target in pairs(profile.lexicon) do
        local lowerTarget = string.lower(target)
        assert(#lowerTarget % 2 == 1, "lexicon target must have odd ASCII length: " .. lowerTarget)
        assert(not used[lowerTarget], "duplicate lexicon target: " .. lowerTarget)
        used[lowerTarget] = source
        profile.reverseLexicon[lowerTarget] = source
    end

    for _, source in ipairs(TT.CommonLexiconWords) do
        if not profile.lexicon[source] then
            local attempt = 0
            local target
            repeat
                target = self:GenerateLexeme(profile, source, attempt)
                attempt = attempt + 1
            until not used[target]

            profile.lexicon[source] = target
            profile.reverseLexicon[target] = source
            used[target] = source
        end
    end
end
