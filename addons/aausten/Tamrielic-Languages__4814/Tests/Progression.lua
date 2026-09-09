-- Standalone from addon root: lua Tests/Progression.lua (Lua 5.1/5.4).
-- Isolated loader with a Knowledge grant spy; no persistence/UI/chat/manifest dependency.
local env = setmetatable({ TamrielicTongues = {} }, { __index = _G })
env._G = env
local function loadModule(path)
    local chunk
    if _VERSION == "Lua 5.1" then
        chunk = assert(loadfile(path)); setfenv(chunk, env)
    else chunk = assert(loadfile(path, "t", env)) end
    chunk()
end
loadModule("Core/Bootstrap.lua")
loadModule("Core/CanonicalCatalog.lua")
loadModule("Language/Analysis.lua")
local TT = env.TamrielicTongues

local grants = 0
TT.Translator = { DecodeWord = function(_, _, word) return word:lower() end }
loadModule("Core/Knowledge.lua")
local grant = TT.Knowledge.Grant
function TT.Knowledge:Grant(state, v, g)
    grants = grants + 1
    return grant(self, state, v, g)
end
loadModule("Core/Progression.lua")
local P, catalog = TT.Progression, TT.CanonicalCatalog
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = copy(v) end
    return result
end
local defaults = copy(P.Config)
local function state()
    return { schemaVersion = 1, thresholdVersion = 1, vocabularyXP = 0, grammarXP = 0,
        masteredVocabulary = {}, masteredGrammar = {} }
end
local function doc(text) return TT.Analysis:FromEncoded({}, text) end
local function observe(s, text, now, sender)
    return P:Observe(s, doc(text), { now = now, eligible = true, sender = sender })
end
local function total(result) return result.vocabularyXP + result.grammarXP end
local function eq(a, b) assert(a == b, tostring(a) .. " ~= " .. tostring(b)) end
local tests = 0
local function test(name, fn)
    P.Config = copy(defaults)
    fn()
    tests = tests + 1
    print("PASS " .. name)
end
-- Actual Lua serialization, rather than retaining shared tables across reload.
local function serialize(value)
    if type(value) == "string" then return string.format("%q", value) end
    if type(value) ~= "table" then return tostring(value) end
    local parts = { "{" }
    for k, v in pairs(value) do parts[#parts + 1] = "[" .. serialize(k) .. "]=" .. serialize(v) .. "," end
    parts[#parts + 1] = "}"
    return table.concat(parts)
end
local function reload(s)
    local source = "return " .. serialize(s)
    local chunk = assert((_VERSION == "Lua 5.1" and loadstring or load)(source))
    loadModule("Core/Progression.lua"); P = TT.Progression
    return chunk()
end

test("pure eligibility; receive gating and invalid times", function()
    local s, d = state(), doc("guard run")
    eq(total(P:CanObserve(s, d, { now = 0, eligible = true })), 2)
    eq(s.exposure, nil); eq(s.vocabularyXP, 0)
    for _, c in ipairs({ {}, { now = 0 }, { now = 0, eligible = 1 },
        { now = 0, eligible = true, isSelf = true }, { now = -1, eligible = true },
        { now = math.huge, eligible = true }, { now = 0/0, eligible = true },
        { now = "1", eligible = true } }) do eq(total(P:Observe(s, d, c)), 0) end
    eq(s.exposure, nil)
end)
test("repeat, trivial variants, sender and hour do not bypass content", function()
    local s = state()
    eq(total(observe(s, "guard run", 0, "@a")), 2)
    for _, text in ipairs({ "guard run", "GUARD RUN!", "|cFFFFFFguard|r run", "guard  run" }) do
        eq(total(observe(s, text, 3600, "@b")), 0)
    end
    eq(total(observe(s, "guard run", 86399, "@c")), 0)
    eq(total(observe(s, "guard run", 86400, "@c")), 2)
end)
test("inflections, duplicates and alternating content share unit identity", function()
    local s = state()
    eq(observe(s, "guard run", 0).vocabularyXP, 2)
    local r = observe(s, "guards running running", 1)
    eq(r.vocabularyXP, 0); assert(r.grammarXP > 0)
    eq(total(observe(s, "run guard run", 2)), 0)
    eq(observe(s, "run guard run", 3600).vocabularyXP, 2)
end)
test("OOV and one known unit never award; forged IDs ignored", function()
    local s = state()
    for i = 1, 100 do
        eq(total(observe(s, "unlisted blargh?", i)), 0)
        eq(total(observe(s, "guard unlisted?", i)), 0)
    end
    eq(next(s.exposure.records), nil)
    eq(total(P:Observe(s, { fingerprint = "forged", vocabulary = { C9999 = 10, bogus = 100 },
        grammar = { bogus = 0 } }, { now = 101, eligible = true })), 0)
end)
test("deterministic sorted selection and shared message cap", function()
    local s, d = state(), doc("guard run walk child hello? yesterday")
    local ids = {}; for id in pairs(d.vocabulary) do ids[#ids + 1] = id end; table.sort(ids)
    local r = P:Observe(s, d, { now = 1, eligible = true })
    eq(total(r), 4); eq(r.vocabularyXP, 3); eq(r.grammarXP, 1)
    for i, id in ipairs(r.vocabulary) do eq(id, ids[i]) end
    local grammar = {}; for id in pairs(d.grammar) do grammar[#grammar + 1] = id end; table.sort(grammar)
    eq(r.grammar[1], grammar[1])
end)
test("daily axes caps, forward-only days, reload and rollback", function()
    local s = state()
    P.Config.unitCooldown, P.Config.contentCooldown = 1, 1
    for i = 1, 100 do observe(s, "guards running? yesterday", i) end
    eq(s.exposure.vocabularyXP, 40); eq(s.exposure.grammarXP, 40)
    s = reload(s)
    eq(total(observe(s, "hello child", 99)), 0)
    eq(s.exposure.highWater, 100)
    eq(total(observe(s, "hello child", 100)), 0)
    assert(total(observe(s, "hello child", 86400)) > 0)
    eq(total(observe(s, "guard run", 86399)), 0)
    eq(s.exposure.day, 1)
end)
test("history saturates without evicting active cooldowns", function()
    local s = state(); P.Config.historyLimit = 3
    eq(total(observe(s, "guard run", 0)), 2)
    eq(total(observe(s, "hello child", 1)), 0)
    eq(total(observe(s, "run guard", 2)), 0)
    eq(total(observe(s, "hello child", 3600)), 1) -- content plus one freed unit slot
    eq(total(observe(s, "guard run", 3601)), 0) -- original content still retained
    local n = 0; for _ in pairs(s.exposure.records) do n = n + 1 end; eq(n, 3)
end)
test("fingerprint size bounded and native/full axes receive no XP", function()
    local s = state(); s.vocabularyXP, s.grammarXP = 10000, 10000
    eq(total(observe(s, "guards running?", 1)), 0); eq(next(s.exposure.records), nil)
    s = state(); local d = doc("guard run"); d.fingerprint = string.rep("x", 4097)
    eq(total(P:Observe(s, d, { now = 1, eligible = true })), 0)
    s.vocabularyXP = 9999
    eq(observe(s, "guard run", 2).vocabularyXP, 1); eq(s.vocabularyXP, 10000)
end)
local function definition(v, g)
    local id = catalog:Resolve("guard").id
    return { vocabulary = { [id] = catalog:GetVocabularyRequirement(id) }, grammar = { question = catalog.GrammarRequirements.question },
        vocabularyXP = v, grammarXP = g }
end
test("curated registration rejects invalid amounts, IDs and duplicates", function()
    P:RegisterLesson("valid", definition(10, 10))
    assert(not pcall(function() P:RegisterLesson("valid", definition(1, 0)) end))
    for _, value in ipairs({ -1, 1.5, math.huge, 0/0, 21, "2" }) do
        assert(not pcall(function() P:RegisterLesson("bad", definition(value, 0)) end))
    end
    local d = definition(1, 0); d.vocabulary = { C9999 = 10 }
    assert(not pcall(function() P:RegisterLesson("bad", d) end))
    assert(not pcall(function() P:RegisterExercise("bad", definition(10, 1)) end))
    assert(not pcall(function() P:RegisterLesson("", definition(1, 0)) end))
end)
test("study/practice cooldowns, shared caps, serialized reload and copied definitions", function()
    local s, d = state(), definition(10, 10)
    P:RegisterLesson("lesson", d); d.vocabularyXP = 10000
    P:RegisterExercise("exercise", definition(5, 5))
    eq(total(P:Study(s, "unknown", 0)), 0)
    eq(total(P:Study(s, "lesson", 1)), 20)
    eq(total(P:Practice(s, "exercise", 1)), 10)
    eq(total(P:Study(s, "lesson", 2)), 0)
    eq(total(P:Practice(s, "exercise", 2)), 0)
    s = reload(s)
    P:RegisterLesson("lesson", definition(10, 10))
    P:RegisterExercise("exercise", definition(5, 5))
    eq(total(P:Study(s, "lesson", 0)), 0)
    eq(total(P:Practice(s, "exercise", 3)), 0)
    eq(total(P:Study(s, "lesson", 86401)), 20)
end)
test("per-activity daily cap survives short cooldown and day boundary", function()
    local s = state(); P.Config.activityCooldown = 1
    P:RegisterLesson("daily", definition(10, 0))
    eq(total(P:Study(s, "daily", 1)), 10)
    eq(total(P:Study(s, "daily", 2)), 10)
    eq(total(P:Study(s, "daily", 3)), 0)
    eq(total(P:Study(s, "daily", 86400)), 10)
    eq(total(P:Study(s, "daily", 86399)), 0)
end)
test("activity capacity and exposure share global language cap", function()
    local s = state(); P.Config.historyLimit = 1
    P:RegisterLesson("one", definition(20, 0)); P:RegisterLesson("two", definition(20, 0))
    eq(total(P:Study(s, "one", 0)), 20)
    eq(total(P:Study(s, "two", 1)), 0)
    P.Config.historyLimit = 512
    eq(total(P:Study(s, "two", 2)), 20)
    eq(total(observe(s, "guard run", 3)), 0)
    eq(s.exposure.vocabularyXP, 40)
    eq(total(P:Study(s, "two", 86402)), 20)
end)
test("catalog membership accepts authored level 100 but excludes arbitrary IDs", function()
    local original = catalog.GetEntry
    function catalog:GetEntry(id)
        if id == "authored100" then return { requirement = 100 } end
        return original(self, id)
    end
    local d = doc("guard run"); d.vocabulary = { authored100 = 100, [catalog:Resolve("guard").id] = 10 }
    d.vocabulary[catalog:Resolve("guard").id] = catalog:Resolve("guard").requirement
    eq(P:Observe(state(), d, { now = 0, eligible = true }).vocabularyXP, 2)
    P:RegisterLesson("level100", { vocabulary = { authored100 = 100 }, vocabularyXP = 10 })
    eq(total(P:Study(state(), "level100", 0)), 10)
    assert(not pcall(function()
        P:RegisterLesson("not-authored", { vocabulary = { arbitrary = 100 }, vocabularyXP = 10 })
    end))
    catalog.GetEntry = original
end)
test("grammar reservation releases unavailable budgets and respects capacity", function()
    local d = doc("guard run walk child hello?")
    local s = state(); s.grammarXP = 10000
    eq(P:Observe(s, d, { now = 0, eligible = true }).vocabularyXP, 4)
    s = state(); P.Config.historyLimit = 3
    local r = P:Observe(s, d, { now = 0, eligible = true })
    eq(r.vocabularyXP, 1); eq(r.grammarXP, 1)
    s = state(); P.Config.historyLimit = 2
    r = P:Observe(s, d, { now = 0, eligible = true })
    eq(r.vocabularyXP, 1); eq(r.grammarXP, 0)
    P.Config.historyLimit = 512; P.Config.dailyGrammarCap = 0
    eq(P:Observe(state(), d, { now = 0, eligible = true }).vocabularyXP, 4)
    P.Config.dailyGrammarCap = 40
    s = state(); observe(s, "guard run?", 0)
    r = observe(s, "walk child hello yesterday?", 1)
    -- Question is cooling down, but new past grammar still earns its reserve.
    eq(r.grammarXP, 1)
end)
-- Deep equality includes NaN and detects in-place changes as well as replacement.
local function same(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b or (type(a) == "number" and a ~= a and b ~= b) end
    for k, v in pairs(a) do if not same(v, b[k]) then return false end end
    for k in pairs(b) do if a[k] == nil then return false end end
    return true
end
local function deniedUnchanged(exposure, expected)
    local s = state(); s.exposure = exposure
    local before, beforeGrants = copy(s), grants
    local context = { now = 172800, eligible = true }
    for _, call in ipairs({
        function() return P:CanObserve(s, doc("guard run?"), context) end,
        function() return P:Observe(s, doc("guard run?"), context) end,
        function() return P:Study(s, "lesson", context.now) end,
        function() return P:Practice(s, "exercise", context.now) end,
    }) do
        local result = call()
        eq(total(result), 0); eq(result.reason, expected)
        eq(s.exposure, exposure); assert(same(s, before)); eq(grants, beforeGrants)
    end
end
---@return table<string, any> Deliberately corrupted by validation tests.
local function exposureFixture()
    return { version = 1, highWater = 100, day = 0, vocabularyXP = 20, grammarXP = 10,
        records = { ["lesson:lesson"] = { expires = 86500, ready = 86500, day = 0, used = 20 },
            ["content:canonical"] = { expires = 86500 } } }
end
test("future Knowledge versions never initialize or mutate exposure", function()
    for _, field in ipairs({ "schemaVersion", "thresholdVersion" }) do
        for _, hasExposure in ipairs({ false, true }) do
            local s = state(); s[field] = 2
            if hasExposure then s.exposure = exposureFixture() end
            local exposure, before, beforeGrants = s.exposure, copy(s), grants
            local context = { now = 172800, eligible = true }
            for _, call in ipairs({
                function() return P:CanObserve(s, doc("guard run?"), context) end,
                function() return P:Observe(s, doc("guard run?"), context) end,
                function() return P:Study(s, "lesson", context.now) end,
                function() return P:Practice(s, "exercise", context.now) end,
            }) do
                local result = call()
                eq(total(result), 0); eq(result.reason, "unsupported-knowledge-state")
                eq(s.exposure, exposure); assert(same(s, before)); eq(grants, beforeGrants)
            end
        end
    end
end)
test("malformed and future exposure fail closed without touching saved data", function()
    for _, e in ipairs({ {}, "bad", false, 1 }) do deniedUnchanged(e, "malformed-exposure") end
    local e = exposureFixture(); e.version = 2
    deniedUnchanged(e, "unsupported-exposure-version")
    for _, field in ipairs({ "version", "highWater", "day", "vocabularyXP", "grammarXP", "records" }) do
        e = exposureFixture(); e[field] = nil; deniedUnchanged(e, "malformed-exposure")
        for _, value in ipairs({ "bad", false, -1, math.huge, 0/0 }) do
            e = exposureFixture(); e[field] = value; deniedUnchanged(e, "malformed-exposure")
        end
    end
    for _, field in ipairs({ "vocabularyXP", "grammarXP" }) do
        e = exposureFixture(); e[field] = 10001; deniedUnchanged(e, "malformed-exposure")
    end
    e = exposureFixture(); e.day = 1; deniedUnchanged(e, "malformed-exposure")
    e = exposureFixture(); e.highWater = 86400; deniedUnchanged(e, "malformed-exposure")
end)
test("invalid record fields and oversized history are never repaired by pruning", function()
    for _, field in ipairs({ "expires", "ready", "day", "used" }) do
        local e = exposureFixture(); e.records["lesson:lesson"][field] = nil
        deniedUnchanged(e, "malformed-exposure")
        for _, value in ipairs({ "bad", false, -1, math.huge, 0/0 }) do
            e = exposureFixture(); e.records["lesson:lesson"][field] = value
            deniedUnchanged(e, "malformed-exposure")
        end
    end
    for _, record in ipairs({ {}, "bad", { expires = -1 }, { expires = math.huge },
        { expires = 100, ready = 101, day = 0, used = 1 },
        { expires = 86500, ready = 100, day = 1, used = 1 },
        { expires = 86500, ready = 100, day = 0, used = 20001 } }) do
        local e = exposureFixture(); e.records["lesson:lesson"] = record
        deniedUnchanged(e, "malformed-exposure")
    end
    local e = exposureFixture(); e.records[1] = { expires = 100 }
    deniedUnchanged(e, "malformed-exposure")
    e = exposureFixture(); e.records["content:" .. string.rep("x", 4097)] = { expires = 100 }
    deniedUnchanged(e, "malformed-exposure")
    e = exposureFixture(); P.Config.historyLimit = 1
    deniedUnchanged(e, "exposure-history-over-capacity") -- even though now is after expiration
    e.records["content:canonical"].expires = 999999
    deniedUnchanged(e, "exposure-history-over-capacity") -- active history is not evicted either
end)
print(string.format("Progression: %d tests passed", tests))
