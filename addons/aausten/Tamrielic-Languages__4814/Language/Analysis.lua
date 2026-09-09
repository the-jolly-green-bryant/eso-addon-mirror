local TT = TamrielicTongues

TT.Analysis = {}

-- UTF-8 U+2019: recognition treats it as an apostrophe, literals retain its bytes.
local RIGHT_APOSTROPHE = string.char(226, 128, 153)
local perfectAuxiliaries = { have = true, has = true, had = true }
local perfectModifiers = { ["not"] = true, never = true, just = true, already = true }
local MAX_PERFECT_MODIFIERS = 3

local function sortedKeys(map)
    local keys = {}
    for key in pairs(map) do keys[#keys + 1] = key end
    table.sort(keys)
    return keys
end

-- Independent alignment scanner matching Tokenizer's v1 ASCII word runs.
-- Link payload AND label are opaque; color escapes are opaque but the visible
-- colored text is ordinary speech, just as it is in EncodeBody/DecodeBody.
function TT.Analysis:FromEncoded(profile, body)
    local catalog = TT.CanonicalCatalog
    local requirements = catalog.GrammarRequirements
    local document = { tokens = {}, vocabulary = {}, grammar = {}, clauses = {} }
    local clauseId, boundary = 1, false
    document.clauses[1] = { grammar = {} }

    local function grammar(id, clause)
        local requirement = assert(requirements[id], "unregistered grammar construction: " .. id)
        document.clauses[clause].grammar[id] = requirement
        document.grammar[id] = requirement
    end

    local function literal(raw, opaque)
        local previous = document.tokens[#document.tokens]
        if previous and previous.kind == "literal" and previous.clauseId == clauseId then
            previous.original = previous.original .. raw
        else
            document.tokens[#document.tokens + 1] = {
                kind = "literal", original = raw, clauseId = clauseId,
            }
        end
        if not opaque then
            if raw:find("?", 1, true) then grammar("question", clauseId) end
            if raw:find("[%.!?\r\n]") then boundary = true end
        end
    end

    local i = 1
    while i <= #body do
        local prefix = body:sub(i, i + 1)
        local color = prefix == "|c" and body:sub(i, i + 7):match("^|c%x%x%x%x%x%x$")
        if prefix == "||" or prefix == "|r" then
            literal(prefix, true)
            i = i + 2
        elseif color then
            literal(color, true)
            i = i + 8
        elseif prefix == "|H" then
            local _, firstEnd = body:find("|h", i + 2, true)
            local _, lastEnd
            if firstEnd then _, lastEnd = body:find("|h", firstEnd + 1, true) end
            lastEnd = lastEnd or #body
            literal(body:sub(i, lastEnd), true)
            i = lastEnd + 1
        elseif body:sub(i, i):match("[A-Za-z]") then
            if boundary then
                clauseId = clauseId + 1
                document.clauses[clauseId] = { grammar = {} }
                boundary = false
            end
            local start = i
            repeat i = i + 1 until i > #body or not body:sub(i, i):match("[A-Za-z]")
            local original = body:sub(start, i - 1)
            local decoded = TT.Translator:DecodeWord(profile, original)
            if decoded == "i" then decoded = "I" end
            document.tokens[#document.tokens + 1] = {
                kind = "word", original = original, decoded = decoded, clauseId = clauseId,
            }
        else
            literal(body:sub(i, i), false)
            i = i + 1
        end
    end

    -- Tokenizer splits contractions at apostrophes. Resolve the complete decoded
    -- contraction without losing either source run or its negation. Both runs
    -- carry the same concept; vocabulary maps deduplicate the learning award.
    local resolutions, contractionEnds = {}, {}
    for index, token in ipairs(document.tokens) do
        if token.kind == "word" then
            local separator, suffix = document.tokens[index + 1], document.tokens[index + 2]
            if separator and separator.kind == "literal"
                and (separator.original == "'" or separator.original == RIGHT_APOSTROPHE)
                and suffix and suffix.kind == "word" and suffix.clauseId == token.clauseId then
                local combined = catalog:Resolve(token.decoded .. "'" .. suffix.decoded)
                if combined.features.contraction then
                    resolutions[index], resolutions[index + 2] = combined, combined
                    contractionEnds[index] = index + 2
                end
            end
        end
    end

    local sequences = {}
    for id = 1, #document.clauses do sequences[id] = {} end
    for index, token in ipairs(document.tokens) do
        if token.kind == "word" then
            local concept = resolutions[index] or catalog:Resolve(token.decoded)
            token.conceptId, token.requirement, token.unknown = concept.id, concept.requirement, concept.unknown
            if not concept.unknown then document.vocabulary[concept.id] = concept.requirement end
            for feature in pairs(concept.features) do grammar(feature, token.clauseId) end
            local sequence = sequences[token.clauseId]
            sequence[#sequence + 1] = #concept.id .. ":" .. concept.id
        end
    end

    -- Bounded perfect construction: have/has/had (including negative contractions),
    -- then at most three not/never/just/already modifiers, then a catalogued
    -- participle. Only whitespace may separate runs; punctuation, markup, other
    -- words and clause boundaries stop the match. No general syntactic inference.
    for index, token in ipairs(document.tokens) do
        if token.kind == "word" and (perfectAuxiliaries[string.lower(token.decoded)]
            or (contractionEnds[index] and resolutions[index].lemma == "have")) then
            local cursor = contractionEnds[index] or index
            for skipped = 0, MAX_PERFECT_MODIFIERS do
                local separator, nextWord = document.tokens[cursor + 1], document.tokens[cursor + 2]
                if not separator or separator.kind ~= "literal" or not separator.original:match("^%s+$")
                    or not nextWord or nextWord.kind ~= "word" or nextWord.clauseId ~= token.clauseId then
                    break
                end
                if catalog:IsSupportedParticiple(nextWord.decoded) then
                    grammar("perfect", token.clauseId)
                    break
                end
                if not perfectModifiers[string.lower(nextWord.decoded)] then break end
                cursor = cursor + 2
            end
        end
    end

    -- Collision-free length-framed canonical representation, not a hash. Literal
    -- spellings, capitalization, markup and punctuation are never serialized.
    -- Clause grouping and punctuation-derived question grammar remain semantic.
    local fingerprint = { "canonical:en:v1" }
    for id, clause in ipairs(document.clauses) do
        if #sequences[id] > 0 then
            local words = table.concat(sequences[id])
            local features = table.concat(sortedKeys(clause.grammar), ",")
            fingerprint[#fingerprint + 1] = #words .. ":" .. words .. #features .. ":" .. features
        end
    end
    document.fingerprint = table.concat(fingerprint, ";")
    return document
end
