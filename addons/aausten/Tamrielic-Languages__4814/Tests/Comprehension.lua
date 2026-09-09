-- Standalone from the addon root; loads actual modules in an isolated environment (Lua 5.1/5.2+).
local env = setmetatable({ TamrielicTongues = {} }, { __index = _G })
env._G = env
local function loadModule(path)
    local chunk
    if _VERSION == "Lua 5.1" then
        chunk = assert(loadfile(path))
        setfenv(chunk, env)
    else
        chunk = assert(loadfile(path, "t", env))
    end
    chunk()
end
for _, path in ipairs({
    "Core/Bootstrap.lua", "Core/Constants.lua", "Core/Versioning.lua", "Core/LanguageRegistry.lua",
    "Languages/Shared/Common.lua", "Languages/Shared/FrozenVocabulary.lua", "Core/CanonicalCatalog.lua",
    "Language/Normalizer.lua", "Language/Tokenizer.lua", "Language/WordGenerator.lua",
    "Language/Morphology.lua", "Language/Grammar.lua", "Language/Translator.lua",
    "Language/Analysis.lua", "Core/Knowledge.lua", "Language/Comprehension.lua",
}) do loadModule(path) end
for _, language in ipairs({ "Taagra", "Jel", "Dunmeri", "Altmeris", "Bosmeri", "Nordic", "Orcish", "Yoku", "Bretic" }) do
    for _, module in ipairs({ "Phonology", "Morphology", "Grammar", "Lexicon", "Language" }) do
        loadModule("Languages/" .. language .. "/" .. module .. ".lua")
    end
end
local TT = env.TamrielicTongues
TT.Registry:Finalize()
local K, C, catalog = TT.Knowledge, TT.Comprehension, TT.CanonicalCatalog
local function equal(a, b)
    assert(a == b, tostring(a) .. " ~= " .. tostring(b))
end
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = copy(item) end
    return result
end
local function same(a, b)
    equal(type(a), type(b))
    if type(a) ~= "table" then equal(a, b); return end
    for key, value in pairs(a) do same(value, b[key]) end
    for key in pairs(b) do assert(a[key] ~= nil) end
end
local function analyze(profile, source)
    local encoded = TT.Translator:EncodeBody(profile, source)
    return TT.Analysis:FromEncoded(profile, encoded), encoded
end
local tests = 0
local function test(name, callback)
    callback(); tests = tests + 1; print("PASS " .. name)
end
local profiles = TT.Registry:GetOrdered()
equal(#profiles, 9)

test("state normalization, isolated snapshots and deterministic capped grants", function()
    local a, b = K:New(false), K:New(true)
    equal(K:GetOverall(a), 0); equal(K:GetOverall(b), 100)
    equal(a.thresholdVersion, 1); equal(a.schemaVersion, 1)
    assert(a.masteredVocabulary ~= b.masteredVocabulary)
    local state = { vocabularyXP = -12, grammarXP = 10001.9, future = { keep = true },
        masteredVocabulary = { C9999 = true, metadata = { future = true } }, thresholdVersion = 1 }
    equal(K:Normalize(state), state)
    equal(state.vocabularyXP, 0); equal(state.grammarXP, 10000)
    equal(state.thresholdVersion, 1); assert(state.future.keep and state.masteredVocabulary.C9999)
    local snapshot = K:Snapshot(state)
    snapshot.masteredVocabulary.metadata.future = false
    assert(state.masteredVocabulary.metadata.future)
    snapshot.masteredVocabulary.C9999 = nil; assert(state.masteredVocabulary.C9999)
    K:Grant(a, 123.9, 456.8); equal(a.vocabularyXP, 123); equal(a.grammarXP, 456)
    K:Grant(a, -9, 0/0); equal(a.vocabularyXP, 123); equal(a.grammarXP, 456)
    K:Grant(a, 99999, 99999); equal(K:GetOverall(a), 100)
    for _, bad in ipairs({ "10000", false, {}, math.huge, -math.huge, 0/0 }) do
        local invalid = { vocabularyXP = bad, grammarXP = bad }
        equal(K:GetVocabularyLevel(invalid), 0); equal(K:GetGrammarLevel(invalid), 0)
        equal(K:GetOverall(invalid), 0)
        K:Normalize(invalid); equal(invalid.vocabularyXP, 0); equal(invalid.grammarXP, 0)
        local granted = K:New(false); K:Grant(granted, 123, 456)
        K:Grant(granted, bad, bad); equal(granted.vocabularyXP, 123); equal(granted.grammarXP, 456)
    end
    local x, y = K:Normalize({}), K:Normalize({})
    assert(x.masteredGrammar ~= y.masteredGrammar)
end)

test("all nine: zero is encoded, native is full normalized decode with opaque literals", function()
    for _, profile in ipairs(profiles) do
        local doc, encoded = analyze(profile, "He saw me. Guards don't wait! Unlisted café |cFF00AAHello|r || |H1:item:guard|h[secret ran?]|h")
        equal(C:Render(doc, K:New(false)), encoded)
        local rendered, stats = C:Render(doc, K:New(true))
        equal(rendered, TT.Translator:DecodeBody(profile, encoded))
        equal(stats.translatedWords, stats.words); equal(stats.unmetGrammarRequirements, 0)
        assert(stats.unknownWords > 0)
    end
end)

test("all nine: partial lexical recognition stable across time sender and formatting", function()
    local state = K:New(false)
    local id = catalog:Resolve("guard").id
    assert(K:MasterVocabulary(state, id))
    for _, profile in ipairs(profiles) do
        for _, source in ipairs({ "guard run", "GUARD   run", "|cFFFFFFGuard|r, run || |H1:x|h[label]|h" }) do
            local doc = analyze(profile, source)
            local expected = {}
            for i, token in ipairs(doc.tokens) do
                expected[i] = token.conceptId == id and token.decoded or token.original
            end
            for repeatIndex = 1, 5 do
                env.GetTimeStamp = function() return repeatIndex * 123456 end
                doc.sender, doc.timestamp = "sender" .. repeatIndex, repeatIndex
                local text, stats = C:Render(doc, K:Snapshot(state))
                equal(text, table.concat(expected)); equal(stats.translatedWords, 1)
            end
        end
    end
end)

test("all nine: morphology shares canonical mastery without bypassing grammar", function()
    for _, profile in ipairs(profiles) do
        for _, forms in ipairs({ { "run", "runs", "ran", "running" }, { "guard", "guards" }, { "see", "saw", "seen" } }) do
            local state, id = K:New(false), catalog:Resolve(forms[1]).id
            K:MasterVocabulary(state, id)
            for _, form in ipairs(forms) do
                local doc, encoded = analyze(profile, form)
                equal(doc.tokens[1].conceptId, id)
                if next(doc.grammar) then equal(C:Render(doc, state), encoded) end
                local fluentGrammar = K:Snapshot(state); fluentGrammar.grammarXP = 10000
                equal(C:Render(doc, fluentGrammar), TT.Translator:DecodeBody(profile, encoded))
            end
        end
    end
end)

test("all nine: exact grammar thresholds and conservative negation tense scopes", function()
    for _, profile in ipairs(profiles) do
        for _, source in ipairs({ "I do not run, you wait", "I ran", "I don't run", "I didn't run", "I will run", "If I run, you would wait?", "He is running", "Guards run" }) do
            local doc, encoded = analyze(profile, source)
            local maximum = 0
            for _, requirement in pairs(doc.grammar) do maximum = math.max(maximum, requirement) end
            assert(maximum > 0)
            local state = K:New(true); state.grammarXP = maximum * 100 - 1
            local text, stats = C:Render(doc, state)
            equal(text, encoded); equal(stats.grammarBlockedWords, stats.words)
            assert(stats.unmetGrammarRequirements > 0)
            K:Grant(state, 0, 1)
            equal(C:Render(doc, state), TT.Translator:DecodeBody(profile, encoded))
        end
        local doc = analyze(profile, "I run. I did not run, you wait! I run\nI ran")
        local state = K:New(true); state.grammarXP = 0
        local expected = {}
        for i, token in ipairs(doc.tokens) do
            expected[i] = token.kind == "word" and (token.clauseId == 1 or token.clauseId == 3)
                and token.decoded or token.original
        end
        local text, stats = C:Render(doc, state)
        equal(text, table.concat(expected)); equal(stats.blockedClauses, 2)
    end
end)

test("all nine: OOV only at full vocabulary, never explicitly learned", function()
    for _, profile in ipairs(profiles) do
        local doc, encoded = analyze(profile, "unlistedword")
        local token = doc.tokens[1]
        assert(token.unknown); equal(token.requirement, 100)
        local state = K:New(false); state.vocabularyXP = 9999
        assert(not K:MasterVocabulary(state, token.conceptId))
        state.masteredVocabulary[token.conceptId] = true
        assert(not K:KnowsVocabulary(state, token.conceptId, 0))
        equal(C:Render(doc, state), encoded)
        K:Grant(state, 1, 0)
        equal(C:Render(doc, state), token.decoded)
        equal(next(doc.vocabulary), nil)
    end
end)

test("explicit mastery is validated monotonic and independent of XP", function()
    local state = K:New(false)
    assert(not K:MasterVocabulary(state, "C9999"))
    assert(not K:MasterGrammar(state, "invented"))
    local id = catalog:Resolve("run").id
    assert(K:MasterVocabulary(state, id)); assert(K:MasterVocabulary(state, id))
    assert(K:KnowsVocabulary(state, id, 100))
    assert(K:MasterGrammar(state, "past")); assert(K:KnowsGrammar(state, "past", 100))
    equal(K:GetOverall(state), 0)
    K:Grant(state, 500, 500)
    assert(K:KnowsVocabulary(state, id)); assert(K:KnowsGrammar(state, "past"))
    local before = copy(state)
    assert(not K:MasterGrammar(state, {})); same(before, state)
    for _, profile in ipairs(profiles) do
        local doc, encoded = analyze(profile, "ran")
        equal(C:Render(doc, state), TT.Translator:DecodeBody(profile, encoded))
    end
end)

test("global percentage and thresholds do not depend on catalog size", function()
    local state = K:New(false); state.vocabularyXP, state.grammarXP = 10000, 0
    equal(K:GetOverall(state), 70)
    local original, config = TT.CanonicalCatalog, K.Config
    local id = catalog:Resolve("guard").id
    local known = K:KnowsVocabulary(state, id)
    TT.CanonicalCatalog = {
        GrammarRequirements = copy(catalog.GrammarRequirements),
        GetEntry = function(_, key)
            if key == "C9999" then return { lemma = "expansionfixture", requirement = 100 } end
            return original:GetEntry(key)
        end,
    }
    TT.CanonicalCatalog.GrammarRequirements.futureConstruction = 80
    equal(K:GetOverall(state), 70); equal(K:KnowsVocabulary(state, id), known)
    assert(K:MasterVocabulary(state, "C9999"))
    TT.CanonicalCatalog = original
    K:Normalize(state); assert(state.masteredVocabulary.C9999)
    assert(not K:KnowsVocabulary(state, "C9999", 0))
    equal(K:GetOverall(state), 70)
    K.Config = { vocabularyWeight = 1, grammarWeight = 1 }; equal(K:GetOverall(state), 50)
    K.Config = config
    state.vocabularyXP = catalog:GetVocabularyRequirement(id) * 100 - 1
    assert(not K:KnowsVocabulary(state, id, 0))
    K:Grant(state, 1, 0); assert(K:KnowsVocabulary(state, id))
end)

test("all nine: rendering and queries are pure, snapshots independent, missing scope closed", function()
    for _, profile in ipairs(profiles) do
        local doc = analyze(profile, "I didn't run. Guard unlistedword |cABCDEFhello|r")
        local state = K:New(false); K:Grant(state, 3500, 2000)
        local snapshot = K:Snapshot(state)
        local beforeDoc, beforeState, beforeSnapshot = copy(doc), copy(state), copy(snapshot)
        local text, stats = C:Render(doc, snapshot)
        for _ = 1, 5 do
            local again, counts = C:Render(doc, K:Snapshot(state))
            equal(again, text); same(counts, stats)
            K:GetOverall(state); K:KnowsGrammar(state, "past"); K:KnowsVocabulary(state, "C0001")
        end
        same(doc, beforeDoc); same(state, beforeState); same(snapshot, beforeSnapshot)
        K:Grant(state, 10000, 10000)
        equal(C:Render(doc, snapshot), text)
        local broken = copy(doc); broken.clauses = {}
        local originals = {}
        for i, token in ipairs(doc.tokens) do originals[i] = token.original end
        equal(C:Render(broken, state), table.concat(originals))
    end
end)

test("future and malformed versions are opaque, isolated and fail closed", function()
    local id = catalog:Resolve("run").id
    for _, field in ipairs({ "schemaVersion", "thresholdVersion" }) do
        for _, version in ipairs({ 2, 1000000, 1.5, math.huge, "2", false, -1 }) do
            local state = K:New(true)
            state[field] = version
            state.vocabularyXP, state.grammarXP = 20000.5, -25.5
            state.masteredVocabulary[id], state.masteredGrammar.past = true, true
            state.future = { nested = { value = 123 }, axis = 999999 }
            local before = copy(state)
            local vocabularyMap, grammarMap, future = state.masteredVocabulary, state.masteredGrammar, state.future
            assert(not K:IsSupported(state))
            equal(K:Normalize(state), state); equal(K:Grant(state, 9999, 9999), state)
            assert(not K:MasterVocabulary(state, id)); assert(not K:MasterGrammar(state, "past"))
            equal(K:GetVocabularyLevel(state), 0); equal(K:GetGrammarLevel(state), 0)
            equal(K:GetOverall(state), 0)
            assert(not K:KnowsVocabulary(state, id, 0)); assert(not K:KnowsGrammar(state, "past", 0))
            assert(not K:KnowsVocabulary(state, "oov:en:v1:unlisted", 0))
            local snapshot = K:Snapshot(state)
            same(snapshot, before); same(state, before)
            assert(snapshot ~= state and snapshot.future ~= future)
            equal(state.masteredVocabulary, vocabularyMap); equal(state.masteredGrammar, grammarMap)
            equal(state.future, future)
            snapshot.future.nested.value = 0; equal(state.future.nested.value, 123)
            snapshot.masteredVocabulary[id] = nil; assert(state.masteredVocabulary[id])
            for _, profile in ipairs(profiles) do
                local doc, encoded = analyze(profile, "run unlisted. I ran")
                equal(C:Render(doc, state), encoded)
            end
            same(state, before)
        end
        local sparse = { [field] = 2, future = { untouched = true } }
        local before = copy(sparse)
        K:Normalize(sparse); K:Grant(sparse, 100, 100)
        same(sparse, before); same(K:Snapshot(sparse), before)
        local malformed = K:New(true); malformed[field] = 0/0
        assert(not K:IsSupported(malformed)); equal(K:GetOverall(malformed), 0)
        K:Normalize(malformed); K:Grant(malformed, 1, 1)
        assert(malformed[field] ~= malformed[field]); equal(malformed.vocabularyXP, 10000)
        local snapshot = K:Snapshot(malformed); assert(snapshot[field] ~= snapshot[field])
    end
    assert(K:IsSupported(K:New(false))); assert(K:IsSupported({}))
    assert(not K:IsSupported(nil)); assert(not K:IsSupported(false))
end)

test("catalog membership precedes mastery and supplied requirements", function()
    local state, native = K:New(false), K:New(true)
    state.masteredVocabulary.C9999, state.masteredGrammar.futureConstruction = true, true
    native.masteredVocabulary.C9999, native.masteredGrammar.futureConstruction = true, true
    for _, knowledge in ipairs({ state, native }) do
        assert(not K:KnowsVocabulary(knowledge, "C9999", 0))
        assert(not K:KnowsGrammar(knowledge, "futureConstruction", 0))
        assert(not K:KnowsVocabulary(knowledge, "invented", 0))
        assert(not K:KnowsGrammar(knowledge, "invented", 0))
        assert(not K:MasterVocabulary(knowledge, "C9999"))
        assert(not K:MasterGrammar(knowledge, "futureConstruction"))
        K:Normalize(knowledge)
        assert(knowledge.masteredVocabulary.C9999 and knowledge.masteredGrammar.futureConstruction)
    end
    assert(not K:KnowsVocabulary(state, catalog:Resolve("run").id, 0))
    assert(not K:KnowsGrammar(state, "past", 0))
    local expanded = {
        GrammarRequirements = copy(catalog.GrammarRequirements),
        GetEntry = function(_, id)
            if id == "C9999" then return { lemma = "expansionfixture", requirement = 100 } end
            return catalog:GetEntry(id)
        end,
    }
    expanded.GrammarRequirements.futureConstruction = 100
    TT.CanonicalCatalog = expanded
    assert(K:KnowsVocabulary(state, "C9999", 100))
    assert(K:KnowsGrammar(state, "futureConstruction", 100))
    local early = K:New(false)
    assert(not K:KnowsVocabulary(early, "C9999", 0))
    assert(K:MasterVocabulary(early, "C9999")); assert(K:KnowsVocabulary(early, "C9999"))
    assert(K:MasterGrammar(early, "futureConstruction")); assert(K:KnowsGrammar(early, "futureConstruction"))
    TT.CanonicalCatalog = catalog
    assert(not K:KnowsVocabulary(early, "C9999", 0))
    assert(not K:KnowsGrammar(early, "futureConstruction", 0))
end)

test("native overall is exactly 100 for valid and fallback weight configurations", function()
    local original = K.Config
    for _, config in ipairs({
        { vocabularyWeight = 0.7, grammarWeight = 0.3 },
        { vocabularyWeight = 70, grammarWeight = 30 },
        { vocabularyWeight = 0, grammarWeight = 0 },
        { vocabularyWeight = 1e308, grammarWeight = 1e308 },
        { vocabularyWeight = 0/0, grammarWeight = math.huge },
        { vocabularyWeight = -1, grammarWeight = "bad" },
    }) do
        K.Config = config
        equal(K:GetOverall(K:New(true)), 100)
        equal(K:GetOverall(K:New(false)), 0)
        local partial = K:New(false); partial.vocabularyXP, partial.grammarXP = 3700, 3700
        equal(K:GetOverall(partial), 37)
    end
    K.Config = original
    local state = K:New(false); state.grammarXP = 10000
    equal(K:GetOverall(state), 30)
end)

print("Comprehension: " .. tests .. " tests passed across all nine languages")
