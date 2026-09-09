-- Run from the addon root: lua Tests/ProgressionControls.lua (Lua 5.1/5.4).
local env = setmetatable({ TamrielicTongues = {} }, { __index = _G })
env._G = env
local function loadModule(path)
    local chunk
    if _VERSION == "Lua 5.1" then
        chunk = assert(loadfile(path)); setfenv(chunk, env)
    else
        ---@diagnostic disable-next-line: redundant-parameter
        chunk = assert(loadfile(path, "t", env))
    end
    chunk()
end
for _, name in ipairs({ "Bootstrap", "Constants", "LanguageRegistry", "CanonicalCatalog",
    "Knowledge", "Progression", "Proficiency" }) do loadModule("Core/" .. name .. ".lua") end
local TT = env.TamrielicTongues
local K, P, F = TT.Knowledge, TT.Progression, TT.Proficiency
TT.Registry:Register({ id = "bretic", name = "Bretic", race = "Breton", wireId = 9 })
TT.Registry:Register({ id = "jel", name = "Jel", race = "Argonian", wireId = 2 })
local function eq(a, b) assert(a == b, tostring(a) .. " ~= " .. tostring(b)) end
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = copy(v) end
    return result
end
local function same(a, b)
    eq(type(a), type(b))
    if type(a) ~= "table" then
        if a ~= a and b ~= b then return end
        eq(a, b); return
    end
    for k, v in pairs(a) do same(v, b[k]) end
    for k in pairs(b) do assert(a[k] ~= nil) end
end
local tests = 0
local function test(name, fn)
    fn(); tests = tests + 1; print("PASS " .. name)
end
local grammarId, grammarRequirement = next(TT.CanonicalCatalog.GrammarRequirements)
assert(grammarId, "Expected a registered grammar construction")
local document = { fingerprint = "controls", vocabulary = { C0001 = 10, C0002 = 10 },
    grammar = { [grammarId] = grammarRequirement } }
local definition = { vocabulary = document.vocabulary, grammar = document.grammar,
    vocabularyXP = 2, grammarXP = 1 }
P:RegisterLesson("controls", definition)
P:RegisterExercise("controls", definition)
local function blocked(s, reason)
    local before = copy(s)
    local context = { eligible = true, now = 172800 }
    for _, result in ipairs({ P:CanObserve(s, document, context), P:Observe(s, document, context),
        P:Study(s, "controls", context.now), P:Practice(s, "controls", context.now) }) do
        eq(result.reason, reason); eq(result.vocabularyXP, 0); eq(result.grammarXP, 0)
        eq(next(result.vocabulary), nil); eq(next(result.grammar), nil)
    end
    eq(K:Grant(s, 100, 100), s)
    eq(K:MasterVocabulary(s, "C0001"), false)
    eq(K:MasterGrammar(s, grammarId), false)
    same(s, before)
end

test("new and migrated flags, snapshots, and idempotence", function()
    eq(K:New().progressEnabled, true); eq(K:New(true).progressEnabled, true)
    local legacy = { vocabularyXP = 2300, grammarXP = 1700, exposure = { sentinel = true } }
    K:Normalize(legacy); eq(legacy.progressEnabled, true)
    eq(legacy.vocabularyXP, 2300); eq(legacy.exposure.sentinel, true)
    legacy.progressEnabled = false
    local before = copy(legacy)
    K:Normalize(legacy); same(legacy, before)
    eq(K:Snapshot(legacy).progressEnabled, false)
    local missing = K:New(); missing.progressEnabled = nil
    eq(K:GetProgressEnabled(missing), true)
    eq(K:Snapshot(missing).progressEnabled, true); eq(missing.progressEnabled, nil)
    eq(P:Observe(missing, document, { eligible = true, now = 0 }).reason, "awarded")
end)

test("disabled learning never allocates or changes exposure", function()
    local s = K:New(); s.progressEnabled = false
    blocked(s, "progress-disabled"); eq(s.exposure, nil)
    s.exposure = { version = 1, highWater = 0, day = 0, vocabularyXP = 2, grammarXP = 1,
        records = { ["content:expired"] = { expires = 1 } } }
    local exposure = s.exposure
    blocked(s, "progress-disabled"); eq(s.exposure, exposure)
    s.exposure = { version = 99 }
    blocked(s, "progress-disabled")
end)

test("invalid flags fail closed before and after migration", function()
    for _, value in ipairs({ 0, 1, "true", "false", {}, 0/0 }) do
        local s = K:New(); s.progressEnabled = value
        eq(K:GetProgressEnabled(s), false)
        blocked(s, "progress-disabled")
        K:Normalize(s); eq(s.progressEnabled, false)
        blocked(s, "progress-disabled")
    end
end)

test("manual overall is exact, clears mastery, preserves flag and exposure", function()
    for _, enabled in ipairs({ true, false }) do
        local s = K:New(); s.progressEnabled = enabled
        s.exposure = { version = 99, sentinel = { 1, 2 } }
        local exposure, before = s.exposure, copy(s.exposure)
        for percent = 0, 100 do
            assert(s.masteredVocabulary).C0001 = true
            assert(s.masteredGrammar)[grammarId] = true
            eq(K:SetOverall(s, percent), true)
            eq(s.vocabularyXP, percent * 100); eq(s.grammarXP, percent * 100)
            eq(K:GetOverall(s), percent)
            eq(next(s.masteredVocabulary), nil); eq(next(s.masteredGrammar), nil)
            eq(s.progressEnabled, enabled); eq(s.exposure, exposure); same(s.exposure, before)
        end
    end
    local s = K:New(); s.progressEnabled = nil
    assert(K:SetOverall(s, 42)); eq(s.progressEnabled, nil)
    s.progressEnabled = "invalid"
    assert(K:SetOverall(s, 0)); eq(s.progressEnabled, "invalid")
end)

test("invalid setter inputs are atomic", function()
    local s = K:New(true)
    local before = copy(s)
    for _, value in ipairs({ -1, 101, 1.5, "50", false, {}, 0/0, math.huge, -math.huge }) do
        local ok, reason = K:SetOverall(s, value)
        eq(ok, false); eq(reason, "invalid-overall"); same(s, before)
    end
    eq(K:SetOverall(s, nil), false)
    for _, value in ipairs({ 0, 1, "true", {}, 0/0 }) do
        local ok, reason = K:SetProgressEnabled(s, value)
        eq(ok, false); eq(reason, "invalid-progress-enabled"); same(s, before)
    end
    eq(K:SetProgressEnabled(s, nil), false); same(s, before)
end)

test("future states remain untouched by migration and controls", function()
    for _, field in ipairs({ "schemaVersion", "thresholdVersion" }) do
        local s = K:New(); s[field] = 2; s.progressEnabled = nil
        local before = copy(s)
        eq(K:Normalize(s), s); same(K:Snapshot(s), before)
        eq(K:SetOverall(s, 50), false); eq(K:SetProgressEnabled(s, false), false)
        blocked(s, "unsupported-knowledge-state"); same(s, before)
        local store = { languages = { jel = s } }
        assert(F:Initialize(store, 1)); same(s, before)
        eq(F:IsSupported("jel"), false); eq(F:GetOverall("jel"), nil)
        eq(F:GetProgressEnabled("jel"), nil)
        eq(F:SetOverall("jel", 50), false); eq(F:SetProgressEnabled("jel", true), false)
        same(s, before)
    end
    local store = { schemaVersion = 2, languages = { jel = K:New() } }
    local before = copy(store)
    eq(F:Initialize(store, 1), false); same(store, before)
end)

test("character/language isolation, persistence reload, and UI facade", function()
    local first, second = {}, {}
    assert(F:Initialize(first, 1))
    eq(F:GetOverall("Breton"), 100); eq(F:GetOverall("jel"), 0)
    eq(F:IsSupported("jel"), true)
    assert(F:SetProgressEnabled("Jel", false)); assert(F:SetOverall("jel", 37))
    eq(F:GetProgressEnabled("jel"), false); eq(F:GetProgressEnabled("bretic"), true)
    eq(F:Study("jel", "controls", 0).reason, "progress-disabled")
    eq(F:Practice("jel", "controls", 0).reason, "progress-disabled")
    assert(F:Initialize(second, 1)); eq(F:GetProgressEnabled("jel"), true)
    eq(F:GetOverall("jel"), 0)
    -- Reload module and persisted values without retaining state table references.
    first = copy(first); loadModule("Core/Proficiency.lua"); F = TT.Proficiency
    assert(F:Initialize(first, 1)); eq(F:GetProgressEnabled("jel"), false)
    eq(F:GetOverall("jel"), 37)
    local before = copy(first)
    eq(F:SetOverall("jel", 1.5), false); eq(F:SetProgressEnabled("jel", 1), false)
    same(first, before)
    assert(F:SetProgressEnabled("jel", true))
    eq(F:Study("jel", "controls", 0).reason, "awarded")
    eq(F:Practice("jel", "controls", 0).reason, "awarded")
    local s = F:GetState("jel")
    assert(K:MasterVocabulary(s, "C0001")); assert(K:MasterGrammar(s, grammarId))
    local xp = s.vocabularyXP; K:Grant(s, 1, 1); eq(s.vocabularyXP, xp + 1)
end)

test("unavailable UI state has explicit support and setter failures", function()
    for _, id in ipairs({ "unknown", "jel" }) do
        if id == "jel" then F.store = nil end
        eq(F:IsSupported(id), false); eq(F:GetProgressEnabled(id), nil); eq(F:GetOverall(id), nil)
        local ok, reason = F:SetOverall(id, 50)
        eq(ok, false); eq(reason, "unavailable-knowledge")
        ok, reason = F:SetProgressEnabled(id, true)
        eq(ok, false); eq(reason, "unavailable-knowledge")
    end
end)
print("Progression controls: " .. tests .. " tests passed")
