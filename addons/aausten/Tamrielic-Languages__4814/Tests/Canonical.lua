-- Standalone: lua Tests/Canonical.lua (Lua 5.1/5.4), from the addon root.
-- Explicit isolated loader: independent of the pending manifest/load-order edit.
local env = setmetatable({ TamrielicTongues = {} }, { __index = _G })
env._G = env
local function loadModule(path, source)
    local chunk
    if _VERSION == "Lua 5.1" then
        chunk = assert(source and loadstring(source, "@" .. path) or loadfile(path))
        setfenv(chunk, env)
    else
        chunk = assert(source and load(source, "@" .. path, "t", env) or loadfile(path, "t", env))
    end
    chunk()
end
for _, path in ipairs({
    "Core/Bootstrap.lua", "Core/Constants.lua", "Core/Versioning.lua", "Core/LanguageRegistry.lua",
    "Languages/Shared/Common.lua", "Languages/Shared/FrozenVocabulary.lua", "Core/CanonicalCatalog.lua",
    "Language/Normalizer.lua", "Language/Tokenizer.lua", "Language/WordGenerator.lua",
    "Language/Morphology.lua", "Language/Grammar.lua", "Language/Translator.lua",
    "Language/RoundTrip.lua", "Language/Analysis.lua",
    "Core/Knowledge.lua", "Language/Comprehension.lua",
}) do loadModule(path) end
for _, language in ipairs({ "Taagra", "Jel", "Dunmeri", "Altmeris", "Bosmeri", "Nordic", "Orcish", "Yoku", "Bretic" }) do
    for _, module in ipairs({ "Phonology", "Morphology", "Grammar", "Lexicon", "Language" }) do
        loadModule("Languages/" .. language .. "/" .. module .. ".lua")
    end
end
local TT = env.TamrielicTongues
TT.Registry:Finalize()
local catalog = TT.CanonicalCatalog
local tests = 0
local function test(name, callback)
    callback()
    tests = tests + 1
    print("PASS " .. name)
end
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = copy(item) end
    return result
end
local function equal(a, b)
    assert(a == b, tostring(a) .. " ~= " .. tostring(b))
end
local function digest(profile)
    local keys, hash = {}, 5381
    for source in pairs(profile.lexicon) do keys[#keys + 1] = source end
    table.sort(keys)
    for _, source in ipairs(keys) do
        local mapping = source .. "=" .. profile.lexicon[source] .. "\n"
        for i = 1, #mapping do hash = (hash * 33 + mapping:byte(i)) % 2147483647 end
    end
    return hash, #keys
end
-- Independent fixture values captured from the pre-change generated snapshot.
local expected = {
    altmeris = 555204777, bosmeri = 547236238, bretic = 1680172116,
    dunmeri = 1878379659, jel = 1157300769, nordic = 636774787,
    orcish = 427596907, taagra = 406644494, yoku = 333113568,
}
local first = TT.Registry:Resolve("taagra")
local function analyze(source, profile)
    profile = profile or first
    return TT.Analysis:FromEncoded(profile, TT.Translator:EncodeBody(profile, source))
end

test("all nine released lexicons and provenance", function()
    for _, profile in ipairs(TT.Registry:GetOrdered()) do
        local hash, count = digest(profile)
        equal(hash, expected[profile.id]); equal(count, 230)
        for source, entry in pairs(TT.FrozenVocabulary[profile.id].words) do
            equal(profile.lexicon[source], entry[1])
            equal(profile.reverseLexicon[entry[1]], source)
            equal(TT.Translator:DecodeWord(profile, TT.Translator:EncodeWord(profile, source)), source)
            assert(entry[2] == "authored" or entry[2] == "generated")
            assert(not catalog:Resolve(source).unknown, source)
        end
    end
end)

test("common vocabulary reorder/expansion cannot change frozen mappings", function()
    local original = TT.CommonLexiconWords
    TT.CommonLexiconWords = { "brandnewcanonicalword" }
    for i = #original, 1, -1 do TT.CommonLexiconWords[#TT.CommonLexiconWords + 1] = original[i] end
    for _, profile in ipairs(TT.Registry:GetOrdered()) do
        local candidate = copy(profile)
        candidate.lexicon = {}
        candidate.seed = 1
        TT.WordGenerator:BuildLexicon(candidate)
        equal(digest(candidate), expected[profile.id])
        equal(candidate.lexicon.brandnewcanonicalword, nil)
        assert(not pcall(function() TT.WordGenerator:GenerateLexeme(candidate, "brandnewcanonicalword") end))
    end
    TT.CommonLexiconWords = original
end)

test("changed mappings, additions, collisions and missing freeze fail atomically", function()
    for _, source in ipairs({ "guard", "newword" }) do
        local candidate = copy(first)
        candidate.lexicon[source] = "xyz"
        local before = candidate.reverseLexicon
        assert(not pcall(function() TT.WordGenerator:BuildLexicon(candidate) end))
        equal(candidate.reverseLexicon, before)
    end
    local frozen = TT.FrozenVocabulary
    TT.FrozenVocabulary = copy(frozen)
    local words = TT.FrozenVocabulary.taagra.words
    words.guard[1] = words.run[1]
    local candidate = copy(first); candidate.lexicon = {}
    assert(not pcall(function() TT.WordGenerator:BuildLexicon(candidate) end))
    TT.FrozenVocabulary = nil
    assert(not pcall(function() TT.WordGenerator:BuildLexicon(candidate) end))
    TT.FrozenVocabulary = frozen
end)

test("legacy custom profiles still generate", function()
    local candidate = copy(first)
    candidate.id, candidate.lexicon = "fixture", {}
    TT.WordGenerator:BuildLexicon(candidate)
    assert(candidate.lexicon.guard)
    candidate.lexicon = { first = "abc", second = "abc" }
    assert(not pcall(function() TT.WordGenerator:BuildLexicon(candidate) end))
end)

test("explicit aliases, features, requirements and collision-free unknowns", function()
    for _, group in ipairs({
        { "run", "runs", "ran", "running" }, { "guard", "guards" },
        { "be", "am", "is", "are", "was", "were", "been" },
        { "see", "sees", "saw", "seen", "seeing" },
        { "walk", "walks", "walked", "walking" }, { "child", "children" },
    }) do
        for _, surface in ipairs(group) do
            local result = catalog:Resolve(surface)
            equal(result.id, catalog:Resolve(group[1]).id)
            equal(result.requirement, catalog:GetVocabularyRequirement(result.id))
        end
    end
    equal(catalog:Resolve("GUARDS!").id, catalog:Resolve("guard").id)
    equal(catalog:Resolve("was").features.past, 35)
    equal(catalog:Resolve("running").features.progressive, 40)
    equal(catalog:Resolve("didn't").features.negation, 20)
    equal(catalog:Resolve("didn't").features.past, 35)
    equal(catalog:Resolve("Unlisted").id, "oov:en:v1:unlisted")
    equal(catalog:Resolve("unlisted").requirement, 100)
    assert(catalog:Resolve("unlisted").id ~= catalog:Resolve("unlisteds").id)
    for _, threshold in pairs(catalog.GrammarRequirements) do
        assert(type(threshold) == "number" and threshold >= 0 and threshold <= 100)
    end
end)

test("literal catalog IDs survive source reorder and appended entries", function()
    local f = assert(io.open("Core/CanonicalCatalog.lua", "r"))
    local source = f:read("*a"); f:close()
    local originalIds = { never = "C0231" }
    for _, word in ipairs(TT.CommonLexiconWords) do originalIds[word] = catalog:Resolve(word).id end
    local start, finish, records = source:find("local entries = {\n(.-)\n}")
    assert(start)
    local lines = {}
    for line in records:gmatch("[^\n]+") do table.insert(lines, 1, line) end
    lines[#lines + 1] = '    ["C9999"] = { lemma = "expansionfixture", requirement = 70 },'
    source = source:sub(1, start - 1) .. "local entries = {\n" .. table.concat(lines, "\n") .. "\n}" .. source:sub(finish + 1)
    loadModule("Core/CanonicalCatalog.lua", source)
    for word, id in pairs(originalIds) do equal(TT.CanonicalCatalog:Resolve(word).id, id) end
    equal(TT.CanonicalCatalog:Resolve("expansionfixture").id, "C9999")
    TT.CanonicalCatalog = catalog
end)

test("all languages align original and decoded text, unknowns never award", function()
    for _, profile in ipairs(TT.Registry:GetOrdered()) do
        local source = "He saw me and I ran. Guards don't wait! Unlisted café\n|cFF00AAHello|r || |H1:item:guard|h[secret ran?]|h"
        local encoded = TT.Translator:EncodeBody(profile, source)
        local doc = TT.Analysis:FromEncoded(profile, encoded)
        local originals, decoded = {}, {}
        for _, token in ipairs(doc.tokens) do
            originals[#originals + 1] = token.original
            decoded[#decoded + 1] = token.decoded or token.original
            assert(doc.clauses[token.clauseId])
            if token.kind == "word" then
                assert(type(token.requirement) == "number" and type(token.unknown) == "boolean")
                if token.unknown then equal(doc.vocabulary[token.conceptId], nil) end
            end
        end
        equal(table.concat(originals), encoded)
        equal(table.concat(decoded), TT.Translator:DecodeBody(profile, encoded))
        equal(doc.clauses[1].grammar.past, 35)
        equal(doc.clauses[1].grammar.negation, nil)
        equal(doc.clauses[2].grammar.negation, 20)
        equal(doc.grammar.question, nil) -- punctuation inside link is opaque
        equal(doc.vocabulary["oov:en:v1:unlisted"], nil)
    end
end)

test("markup is opaque including malformed links and escaped pipes", function()
    for _, raw in ipairs({ "|H1:guard|h[run?]|h", "|Hguard", "|Hguard|hunfinished", "|cABCDEF|r||" }) do
        local doc = TT.Analysis:FromEncoded(first, raw)
        equal(next(doc.vocabulary), nil); equal(next(doc.grammar), nil)
        equal(#doc.tokens, 1); equal(doc.tokens[1].original, raw)
    end
end)

test("negative contractions and clause grammar remain visible", function()
    for _, source in ipairs({ "I don't run", "I didn't run", "I can't run", "I won't run", "He isn't running" }) do
        local doc = analyze(source)
        equal(doc.grammar.negation, 20); equal(doc.grammar.contraction, 45)
        equal(doc.clauses[1].grammar.negation, 20)
    end
    local doc = analyze("If guards will run, we would go? I walked. I run\nI wait")
    equal(#doc.clauses, 4)
    equal(doc.clauses[1].grammar.conditional, 65)
    equal(doc.clauses[1].grammar.future, 35)
    equal(doc.clauses[1].grammar.question, 25)
    equal(doc.clauses[2].grammar.past, 35)
    equal(doc.clauses[3].grammar.past, nil)
end)

test("curly contractions preserve wire punctuation and share canonical grammar", function()
    local apostrophe = string.char(226, 128, 153) -- U+2019, Lua 5.1-compatible UTF-8
    for _, ascii in ipairs({ "won't", "don't", "didn't", "can't", "hasn't", "haven't", "hadn't" }) do
        local curly = ascii:gsub("'", apostrophe)
        local plain, curved = catalog:Resolve(ascii), catalog:Resolve(curly)
        equal(curved.id, plain.id)
        for id, requirement in pairs(plain.features) do equal(curved.features[id], requirement) end
        for id, requirement in pairs(curved.features) do equal(plain.features[id], requirement) end
        for _, profile in ipairs(TT.Registry:GetOrdered()) do
            local source = "I " .. curly .. " run"
            local body = TT.Translator:EncodeBody(profile, source)
            local doc = TT.Analysis:FromEncoded(profile, body)
            equal(doc.fingerprint, analyze("I " .. ascii .. " run", profile).fingerprint)
            equal(doc.clauses[1].grammar.negation, 20)
            equal(doc.clauses[1].grammar.contraction, 45)
            local originals, decoded, found = {}, {}, false
            for _, token in ipairs(doc.tokens) do
                originals[#originals + 1] = token.original
                decoded[#decoded + 1] = token.decoded or token.original
                if token.kind == "literal" and token.original == apostrophe then found = true end
            end
            assert(found)
            equal(table.concat(originals), body)
            equal(table.concat(decoded), source)
        end
    end
end)

test("never has a permanent concept and negation without changing wire fallback", function()
    local concept = catalog:Resolve("NEVER!")
    equal(concept.id, "C0231"); equal(concept.lemma, "never")
    equal(concept.requirement, 35); equal(concept.unknown, false)
    equal(concept.features.negation, 20)
    equal(catalog:GetEntry("C0231").lemma, "never")
    for _, profile in ipairs(TT.Registry:GetOrdered()) do
        equal(profile.lexicon.never, nil)
        equal(TT.FrozenVocabulary[profile.id].words.never, nil)
        local codec = {}
        for i = 1, #"never" do codec[i] = profile.codec[("never"):byte(i) - 96] end
        equal(TT.Translator:EncodeWord(profile, "never"), table.concat(codec))
        equal(digest(profile), expected[profile.id])
        local doc = analyze("I never run. I run", profile)
        equal(doc.vocabulary.C0231, 35)
        equal(doc.clauses[1].grammar.negation, 20)
        equal(doc.clauses[2].grammar.negation, nil)
    end
end)

test("perfect requires a bounded auxiliary and explicitly supported participle", function()
    for _, profile in ipairs(TT.Registry:GetOrdered()) do
        for _, source in ipairs({
            "I have seen guards", "I have not seen guards", "I have never seen guards",
            "He has just seen guards", "I had already seen guards", "I have not yet guards",
        }) do
            local doc = analyze(source, profile)
            if source == "I have not yet guards" then
                equal(doc.grammar.perfect, nil)
            else
                equal(doc.grammar.perfect, 60); equal(doc.clauses[1].grammar.perfect, 60)
            end
        end
    end
    for _, participle in ipairs({ "seen", "walked", "guarded", "run", "come", "taken", "known", "done", "heard" }) do
        assert(catalog:IsSupportedParticiple(participle))
        equal(analyze("I have " .. participle).grammar.perfect, 60)
        equal(analyze("I have not just already " .. participle).grammar.perfect, 60)
    end
    for _, source in ipairs({
        "I have guards", "I saw guards", "I walked", "I have saw guards", "I have ran",
        "I have went", "I have left", "I have inventedparticiple", "I have really seen guards",
        "I have guards seen", "I have not just already never seen", "I have, seen",
        "I have. Seen", "I have! Seen", "I have? Seen", "I have\nseen", "I have\r\nseen",
        "I have |H1:item|h[not]|h seen", "I have |cFFFFFF|r seen", "I haven't guards",
    }) do equal(analyze(source).grammar.perfect, nil) end
    for _, source in ipairs({ "I haven't seen", "He hasn't seen", "I hadn't seen", "I hadn’t seen" }) do
        equal(analyze(source).grammar.perfect, 60)
        equal(analyze(source).grammar.negation, 20)
    end
    local doc = analyze("I have not seen guards. I saw guards")
    equal(doc.clauses[1].grammar.perfect, 60)
    equal(doc.clauses[1].grammar.negation, 20)
    equal(doc.clauses[2].grammar.perfect, nil)
    equal(doc.clauses[2].grammar.negation, nil)
    equal(doc.clauses[2].grammar.past, 35)
end)

test("renderer gates negation and perfect at exact grammar thresholds", function()
    for _, profile in ipairs(TT.Registry:GetOrdered()) do
        for _, fixture in ipairs({
            { "I won't run", 45 }, { "I won’t run", 45 }, { "I never run", 20 },
            { "I have seen guards", 60 }, { "I have not seen guards", 60 },
            { "I have never seen guards", 60 }, { "I hadn’t seen guards", 60 },
        }) do
            local source, threshold = fixture[1], fixture[2]
            local body = TT.Translator:EncodeBody(profile, source)
            local doc = TT.Analysis:FromEncoded(profile, body)
            local knowledge = TT.Knowledge:New(false)
            knowledge.vocabularyXP = 10000
            for _, level in ipairs({ 0, threshold - 1 }) do
                knowledge.grammarXP = level * 100
                local rendered, stats = TT.Comprehension:Render(doc, knowledge)
                equal(rendered, body)
                equal(stats.grammarBlockedWords, stats.words)
                equal(stats.translatedWords, 0)
            end
            knowledge.grammarXP = threshold * 100
            local rendered, stats = TT.Comprehension:Render(doc, knowledge)
            equal(rendered, source); equal(stats.translatedWords, stats.words)
        end
        local doc = analyze("I have not seen guards. I saw guards", profile)
        local knowledge = TT.Knowledge:New(false)
        knowledge.vocabularyXP, knowledge.grammarXP = 10000, 5900
        equal(TT.Comprehension:Render(doc, knowledge),
            TT.Translator:EncodeBody(profile, "I have not seen guards.") .. " I saw guards")
        knowledge.grammarXP = 1500 -- guards still requires plural, but not perfect
        equal(TT.Comprehension:Render(analyze("I have guards", profile), knowledge), "I have guards")
    end
end)

test("fingerprints ignore presentation but retain semantic features", function()
    equal(analyze("I run!").fingerprint, analyze("i RUN.").fingerprint)
    equal(analyze("|cFFFFFFI|r run").fingerprint, analyze("I run").fingerprint)
    assert(analyze("I ran").fingerprint ~= analyze("I run").fingerprint)
    assert(analyze("I don't run").fingerprint ~= analyze("I run").fingerprint)
    assert(analyze("I run?").fingerprint ~= analyze("I run.").fingerprint)
    for _, profile in ipairs(TT.Registry:GetOrdered()) do
        equal(analyze("Guards ran and I saw them", profile).fingerprint, analyze("Guards ran and I saw them").fingerprint)
    end
end)

loadModule("Tests/RoundTrip.lua")
print("Canonical: " .. tests .. " tests passed; legacy round-trip smoke tests passed")
