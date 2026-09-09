-- Run from the addon root: lua Tests/ProficiencyIntegration.lua
-- Lua 5.1/5.4; only ESO APIs are mocked, all addon code loads from the manifest.
local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do result[key] = copy(item) end
    return result
end
local function equal(actual, expected, label)
    assert(actual == expected, (label or "value") .. ": " .. tostring(actual) .. " ~= " .. tostring(expected))
end
local function same(actual, expected, path)
    path = path or "table"
    equal(type(actual), type(expected), path)
    if type(actual) ~= "table" then
        if actual ~= actual and expected ~= expected then return end -- NaN preservation
        equal(actual, expected, path)
        return
    end
    for key, value in pairs(expected) do same(actual[key], value, path .. "." .. tostring(key)) end
    for key in pairs(actual) do assert(expected[key] ~= nil, path .. ": unexpected " .. tostring(key)) end
end
local function branch(root, key)
    if root[key] == nil then root[key] = {} end
    return root[key]
end
local function defaultsInto(saved, defaults)
    for key, value in pairs(defaults) do
        if saved[key] == nil then saved[key] = copy(value)
        elseif type(value) == "table" and type(saved[key]) == "table" then defaultsInto(saved[key], value) end
    end
    return saved
end
local function loadAddon(database, options)
    database, options = database or {}, options or {}
    ---@type table<string, any>
    local env = setmetatable({}, { __index = _G })
    env._G = env
    env.identity = { account = options.account or "@Account", world = options.world or "EU Megaserver",
        charID = options.charID or "1001", name = options.name or "First Character" }
    env.race, env.now = options.race or 1, options.now or 172810
    local messages, queued, events, calls, strings, versions = {}, {}, {}, {}, {}, {}
    env.GetCVar = function() return "en" end
    env.GetWorldName = function() return env.identity.world end
    env.GetDisplayName = function() return env.identity.account end
    env.GetCurrentCharacterId = function() return env.identity.charID end
    env.GetUnitName = function() return env.identity.name end
    env.GetUnitRaceId = function(unit) equal(unit, "player"); return env.race end
    env.GetTimeStamp = function() return env.now end
    env.ZO_CreateStringId = function(name, text)
        assert(rawget(env, name) == nil, "duplicate string ID")
        env[name], strings[name], versions[name] = name, text, 0
    end
    env.SafeAddString = function(id, text, version)
        assert(strings[id], "override without default")
        if version >= versions[id] then strings[id], versions[id] = text, version end
    end
    env.GetString = function(id) return assert(strings[id], "missing string") end
    env.zo_strformat = function(text, ...)
        local args = { ... }
        return (text:gsub("<<(%d+)>>", function(index) return tostring(assert(args[tonumber(index)])) end))
    end
    env.EVENT_ADD_ON_LOADED, env.EVENT_CHAT_MESSAGE_CHANNEL, env.EVENT_PLAYER_ACTIVATED = 1, 2, 3
    env.CHAT_CHANNEL_SAY, env.CHAT_CHANNEL_YELL = 10, 11
    env.CHAT_CHANNEL_WHISPER, env.CHAT_CHANNEL_PARTY = 12, 13
    env.EVENT_MANAGER = {
        RegisterForEvent = function(_, name, event, callback) branch(events, event)[name] = callback end,
        UnregisterForEvent = function(_, name, event) branch(events, event)[name] = nil end,
    }
    env.fire = function(event, ...)
        local pending = {}
        for _, callback in pairs(events[event] or {}) do pending[#pending + 1] = callback end
        for _, callback in ipairs(pending) do callback(event, ...) end
    end
    env.CHAT_ROUTER = { AddSystemMessage = function(_, text) messages[#messages + 1] = text end }
    -- Explicit false shadows any host global for the immediate-output case.
    env.zo_callLater = options.deferred and function(callback, delay)
        equal(delay, 0); queued[#queued + 1] = callback
    end or false
    env.flush = function()
        while #queued > 0 do table.remove(queued, 1)() end
    end
    env.SharedChatSystem, env.SLASH_COMMANDS = {}, {}
    env.ZO_PreHook = function() end
    local accountDefaults, characterDefaults, preferenceDefaults
    env.ZO_SavedVars = {
        NewAccountWide = function(_, name, version, namespace, defaults, ...)
            equal(select("#", ...), 0, "legacy account API arity")
            equal(version, 1); equal(namespace, nil)
            accountDefaults = defaults
            calls[#calls + 1] = { kind = "account", name = name }
            local root = branch(branch(branch(database, name), "account"), env.identity.account)
            return defaultsInto(root, defaults)
        end,
        NewCharacterIdSettings = function(_, name, version, namespace, defaults, world, ...)
            equal(select("#", ...), 0); equal(version, 1)
            assert(namespace == "Proficiency" or namespace == "Preferences")
            equal(world, env.identity.world); same(defaults, {})
            if namespace == "Proficiency" then characterDefaults = defaults
            else preferenceDefaults = defaults end
            calls[#calls + 1] = { kind = "character", name = name, namespace = namespace }
            -- ESO's namespace, world, account and stable character-ID boundaries.
            local root = branch(branch(branch(branch(branch(database, name), "character"), world),
                env.identity.account), env.identity.charID)
            return defaultsInto(branch(root, namespace), defaults)
        end,
    }
    for line in io.lines("TamrielicTongues.txt") do
        local path = line:match("^%s*(.-)%s*$")
        if path:match("%.lua$") then
            local chunk
            if _VERSION == "Lua 5.1" then chunk = assert(loadfile(path)); setfenv(chunk, env)
            else chunk = assert(loadfile(path, "t", env)) end
            chunk()
        end
    end
    local TT, order = env.TamrielicTongues, {}
    -- Transparent spies assert orchestration without replacing engine behavior.
    local function spy(owner, key, label)
        local original = assert(owner[key])
        owner[key] = function(self, ...)
            order[#order + 1] = label
            return original(self, ...)
        end
    end
    spy(TT.Registry, "Finalize", "finalize")
    spy(TT.SavedVariables, "InitializeKnowledge", "knowledge")
    spy(TT.Chat, "Initialize", "chat")
    env.fire(env.EVENT_ADD_ON_LOADED, "UnrelatedAddon")
    equal(#calls, 0)
    env.fire(env.EVENT_ADD_ON_LOADED, TT.ADDON_NAME)
    same(order, { "finalize", "knowledge", "chat" })
    equal(#calls, 3); equal(calls[1].kind, "account")
    equal(calls[1].name, TT.SAVED_VARIABLES_NAME)
    equal(calls[2].namespace, "Preferences"); equal(calls[3].namespace, "Proficiency")
    for i = 2, 3 do
        equal(calls[i].kind, "character"); equal(calls[i].name, calls[1].name)
    end
    assert(TT.characterPreferences ~= preferenceDefaults and TT.characterPreferences ~= TT.characterSaved)
    same(preferenceDefaults, {}); equal(accountDefaults.activeLanguage, nil)
    assert(TT.saved ~= accountDefaults and TT.characterSaved ~= characterDefaults)
    same(characterDefaults, {})
    env.messages, env.queued, env.events = messages, queued, events
    return TT, env, database
end
local function wire(TT, source)
    local text = assert(TT.Translator:Encode("taagra", source or "guard run"))
    local profile, body = TT.MessageDetector:Detect(text)
    assert(profile and profile.id == "taagra")
    return text, TT.Analysis:FromEncoded(profile, body), body, profile
end
local function receive(TT, env, text, sender, channel, customer)
    return TT.ChatOutput:OnChatMessage(channel or env.CHAT_CHANNEL_SAY, "Character Name", text,
        customer or false, sender == nil and "@Other" or sender)
end
local function noAward(award, reason)
    assert(award, "missing award summary")
    equal(award.vocabularyXP, 0); equal(award.grammarXP, 0)
    if reason then equal(award.reason, reason) end
end
local passed, failed = 0, 0
local function test(name, callback)
    local ok, err = pcall(callback)
    if ok then passed = passed + 1; print("PASS " .. name)
    else failed = failed + 1; print("FAIL " .. name .. ": " .. tostring(err)) end
end

test("all ESO races: native/Common 100, all foreign languages 0", function()
    local natives = { "bretic", "yoku", "orcish", "dunmeri", "nordic", "altmeris", "bosmeri", "taagra", "jel", "common" }
    for race, native in ipairs(natives) do
        local TT = loadAddon(nil, { race = race })
        equal(TT.characterSaved.initialNativeLanguage, native)
        equal(TT.characterSaved.schemaVersion, 1)
        equal(TT.Proficiency:GetOverall("common"), 100)
        equal(#TT.Registry:GetOrdered(), 9)
        for _, profile in ipairs(TT.Registry:GetOrdered()) do
            equal(TT.Proficiency:GetOverall(profile.id), profile.id == native and 100 or 0, profile.id)
        end
    end
end)

test("speaking preferences migrate once and isolate stable character, world and account", function()
    local initial, _, db = loadAddon()
    equal(initial.Settings:GetActiveLanguage(), "common")
    equal(initial.saved.activeLanguage, nil, "new accounts do not write legacy selection")
    -- Seed a pre-upgrade account, with no Preferences namespace for this character.
    db[initial.SAVED_VARIABLES_NAME].character = nil
    initial.saved.activeLanguage = "taagra"
    initial.saved.showTranslations, initial.saved.showLanguageName = false, false
    initial.saved.unknown = { keep = true }
    local legacy = copy(initial.saved)
    local TT = loadAddon(db)
    equal(TT.Settings:GetActiveLanguage(), "taagra")
    equal(TT.Proficiency:GetOverall("taagra"), 0, "migration grants no knowledge")
    local knowledge = copy(TT.characterSaved)
    TT.characterPreferences.unknown = { keep = false }
    assert(TT.Settings:SetActiveLanguage("common"))
    same(TT.saved, legacy); same(TT.characterSaved, knowledge)
    local reload = loadAddon(db, { name = "Renamed" })
    equal(reload.characterPreferences, TT.characterPreferences)
    equal(reload.Settings:GetActiveLanguage(), "common", "explicit Common survives migration/reload")
    equal(reload.characterPreferences.unknown.keep, false)
    for _, identity in ipairs({ { charID = "1002" }, { world = "NA Megaserver" } }) do
        local other = loadAddon(db, identity)
        equal(other.Settings:GetActiveLanguage(), "taagra", "legacy remains available to other characters/worlds")
        assert(other.characterPreferences ~= TT.characterPreferences)
        assert(other.Settings:SetActiveLanguage("jel"))
        equal(TT.Settings:GetActiveLanguage(), "common")
        same(other.saved, legacy)
        local otherReload = loadAddon(db, identity)
        equal(otherReload.Settings:GetActiveLanguage(), "jel")
    end
    local otherAccount = loadAddon(db, { account = "@Another" })
    equal(otherAccount.Settings:GetActiveLanguage(), "common")
    assert(otherAccount.Settings:SetActiveLanguage("bretic"))
    same(TT.saved, legacy)
    TT.Settings:SetTranslationsEnabled(true)
    local shared = loadAddon(db, { charID = "1002", world = "NA Megaserver" })
    equal(shared.saved.showTranslations, true); equal(shared.saved.showLanguageName, false)
    equal(shared.saved.activeLanguage, "taagra")
    -- Preference writes must not alter a future proficiency schema, either.
    TT.characterSaved.schemaVersion = 99
    local future = copy(TT.characterSaved)
    reload = loadAddon(db)
    assert(reload.Settings:SetActiveLanguage("jel"))
    same(reload.characterSaved, future)
    equal(reload.Settings:GetActiveLanguage(), "jel")
end)

test("existing character selection wins and missing legacy uses default", function()
    local TT, _, db = loadAddon()
    TT.saved.activeLanguage = "taagra"
    TT.characterPreferences.activeLanguage = "absentPack"
    local reload = loadAddon(db)
    equal(reload.Settings:GetActiveLanguage(), "absentPack")
    TT.saved.activeLanguage = nil
    TT.characterPreferences.activeLanguage = nil
    TT.Constants.DEFAULT_LANGUAGE_ID = "jel"
    TT.SavedVariables:Initialize()
    equal(TT.Settings:GetActiveLanguage(), "jel")
    TT.characterPreferences.activeLanguage = nil
    TT.Constants.DEFAULT_LANGUAGE_ID = nil
    TT.SavedVariables:Initialize()
    equal(TT.Settings:GetActiveLanguage(), "common")
    equal(TT.saved.activeLanguage, nil)
end)

test("legacy false preferences, identity isolation, reload and persistent exposure", function()
    local TT, env, db = loadAddon()
    TT.saved.activeLanguage, TT.saved.showTranslations, TT.saved.showLanguageName = "taagra", false, false
    local text = wire(TT)
    local _, _, award = receive(TT, env, text)
    equal(award.reason, "awarded")
    local saved = copy(TT.characterSaved)
    local reloaded, reloadEnv = loadAddon(db, { name = "Renamed", race = 8 })
    equal(reloaded.saved.activeLanguage, "taagra")
    equal(reloaded.saved.showTranslations, false); equal(reloaded.saved.showLanguageName, false)
    same(reloaded.characterSaved, saved)
    equal(reloaded.characterSaved, TT.characterSaved)
    equal(reloaded.characterSaved.initialNativeLanguage, "bretic", "race change must not grant a new native")
    local _, _, repeated = receive(reloaded, reloadEnv, text, "@DifferentSender")
    noAward(repeated, "content-cooldown"); same(reloaded.characterSaved, saved)
    for _, options in ipairs({ { charID = "1002", name = "First Character" },
        { world = "NA Megaserver" }, { account = "@Another" } }) do
        local other = loadAddon(db, options)
        equal(other.Proficiency:GetOverall("taagra"), 0)
        assert(other.characterSaved ~= TT.characterSaved)
        local a, b = other.Proficiency:GetState("taagra"), TT.Proficiency:GetState("taagra")
        assert(a ~= b and a.masteredVocabulary ~= b.masteredVocabulary)
        equal(a.exposure, nil)
        a.masteredVocabulary.testOnly = true
        equal(b.masteredVocabulary.testOnly, nil)
        assert(a.masteredGrammar ~= other.Proficiency:GetState("jel").masteredGrammar)
    end
    -- Persist an exhausted daily budget, then reload before a distinct message.
    local state = reloaded.Proficiency:GetState("taagra")
    state.exposure.vocabularyXP = reloaded.Progression.Config.dailyVocabularyCap
    local again, againEnv = loadAddon(db)
    local distinct = wire(again, "friend water")
    local _, _, capped = receive(again, againEnv, distinct)
    equal(capped.vocabularyXP, 0)
    equal(again.Proficiency:GetState("taagra").exposure.vocabularyXP, again.Progression.Config.dailyVocabularyCap)
end)

test("migration idempotence, unknown/absent-pack retention and unsupported versions", function()
    local TT = loadAddon()
    local store = { schemaVersion = 0, extra = { keep = false }, languages = {
        taagra = { vocabularyXP = 123.9, grammarXP = 456.8, extra = { keep = true } },
        absentPack = { schemaVersion = 99, opaque = { 1, 2, 3 } },
    } }
    local absent = copy(store.languages.absentPack)
    equal(TT.Proficiency:Initialize(store, 1), true)
    equal(store.languages.taagra.vocabularyXP, 123); equal(store.languages.taagra.grammarXP, 456)
    assert(store.languages.taagra.extra.keep); equal(store.extra.keep, false)
    same(store.languages.absentPack, absent)
    local migrated = copy(store)
    equal(TT.Proficiency:Initialize(store, 8), true); same(store, migrated)
    local future = { schemaVersion = 2, languages = { taagra = { opaque = true } }, extra = false }
    local before = copy(future)
    local ok, reason = TT.Proficiency:Initialize(future, 1)
    equal(ok, false); equal(reason, "unsupported-schema"); same(future, before)
    equal(TT.Proficiency:GetState("taagra"), nil)
    for _, field in ipairs({ "schemaVersion", "thresholdVersion" }) do
        store.languages.taagra = TT.Knowledge:New(false)
        store.languages.taagra[field] = 2
        before = copy(store.languages.taagra)
        equal(TT.Proficiency:Initialize(store, 1), true)
        equal(TT.Proficiency:GetState("taagra"), nil)
        local result, unavailable = TT.Proficiency:Study("taagra", "anything", 172810)
        equal(result, nil); equal(unavailable, "unavailable-knowledge")
        same(store.languages.taagra, before)
    end
end)

test("malformed XP normalization and exposure fail-closed through incoming chat", function()
    local TT, env = loadAddon()
    local text = wire(TT)
    for _, value in ipairs({ -10, "100", false, {}, math.huge, -math.huge, 0/0 }) do
        local state = { vocabularyXP = value, grammarXP = value }
        TT.characterSaved.languages.taagra = state
        assert(TT.Proficiency:Initialize(TT.characterSaved, 1))
        equal(state.vocabularyXP, 0); equal(state.grammarXP, 0)
    end
    for _, exposure in ipairs({ false, "bad", {}, { version = 2 },
        { version = 1, highWater = env.now, day = 2, vocabularyXP = -1, grammarXP = 0, records = {} } }) do
        local state = TT.Knowledge:New(false)
        state.exposure = exposure
        TT.characterSaved.languages.taagra = state
        local before = copy(state)
        local _, _, award = receive(TT, env, text)
        noAward(award)
        assert(award.reason == "malformed-exposure" or award.reason == "unsupported-exposure-version")
        same(state, before)
    end
end)

test("race zero waits for activation; valid race initializes once before chat use", function()
    local TT, env = loadAddon(nil, { race = 0 })
    same(TT.characterSaved, {}); equal(TT.Proficiency:GetState("taagra"), nil)
    local name = TT.ADDON_NAME .. "_KnowledgeReady"
    assert(env.events[env.EVENT_PLAYER_ACTIVATED][name])
    equal(receive(TT, env, (wire(TT))), nil); same(TT.characterSaved, {})
    env.fire(env.EVENT_PLAYER_ACTIVATED)
    same(TT.characterSaved, {}); assert(env.events[env.EVENT_PLAYER_ACTIVATED][name])
    env.race = 8; env.fire(env.EVENT_PLAYER_ACTIVATED)
    equal(TT.Proficiency:GetOverall("taagra"), 100)
    equal(env.events[env.EVENT_PLAYER_ACTIVATED][name], nil)
    local before = copy(TT.characterSaved)
    env.race = 9; env.fire(env.EVENT_PLAYER_ACTIVATED); same(TT.characterSaved, before)
end)

test("incoming uses pre-gain snapshot, deterministic rendering and sender-independent cooldown", function()
    local TT, env = loadAddon()
    local text, document = wire(TT)
    local state = TT.Proficiency:GetState("taagra")
    local requirement = TT.CanonicalCatalog:Resolve("guard").requirement
    assert(requirement > 0)
    state.vocabularyXP = requirement * 100 - 1
    local snapshot = TT.Knowledge:Snapshot(state)
    local expected, expectedStats = TT.Comprehension:Render(document, snapshot)
    local rendered, stats, award = receive(TT, env, text)
    equal(rendered, expected); same(stats, expectedStats); equal(award.reason, "awarded")
    equal(state.vocabularyXP, snapshot.vocabularyXP + award.vocabularyXP)
    assert(TT.Comprehension:Render(document, TT.Knowledge:Snapshot(state)) ~= expected,
        "fixture must cross a recognition threshold to detect render-after-award")
    same(snapshot, TT.Knowledge:Snapshot(snapshot))
    local stable = TT.Comprehension:Render(document, TT.Knowledge:Snapshot(state))
    for _, sender in ipairs({ "@Other", "@OTHER", "@Third" }) do
        env.now = env.now + 1
        local again, _, repeated = receive(TT, env, text, sender)
        equal(again, stable); noAward(repeated, "content-cooldown")
    end
end)

test("hidden translations learn; unreadable messages never add duplicate lines", function()
    for _, hidden in ipairs({ false, true }) do
        local TT, env = loadAddon()
        TT.saved.showTranslations = not hidden
        local text, _, body = wire(TT)
        local count = #env.messages
        local rendered, stats, award = receive(TT, env, text)
        equal(rendered, body); equal(stats.translatedWords, 0)
        equal(award.reason, "awarded"); equal(#env.messages, count)
        assert(TT.Proficiency:GetState("taagra").vocabularyXP > 0)
        if hidden then
            TT.Knowledge:MasterVocabulary(TT.Proficiency:GetState("taagra"), TT.CanonicalCatalog:Resolve("friend").id)
            local _, readable, learned = receive(TT, env, (wire(TT, "friend water")))
            assert(readable.translatedWords > 0); equal(learned.reason, "awarded")
            equal(#env.messages, count)
        end
    end
end)

test("eligible channels only, account-based self exclusion and missing senders", function()
    for _, channel in ipairs({ 10, 11, 12, 13 }) do
        local TT, env = loadAddon()
        local _, _, award = receive(TT, env, wire(TT), "@Other", channel)
        equal(award.reason, "awarded")
    end
    for _, case in ipairs({ { sender = "@ACCOUNT" }, { sender = "" }, { sender = false },
        { channel = 999 }, { channel = "10" } }) do
        local TT, env = loadAddon()
        local before = copy(TT.characterSaved)
        local _, _, award = receive(TT, env, wire(TT), case.sender, case.channel)
        noAward(award, "ineligible"); same(TT.characterSaved, before)
    end
    local TT, env = loadAddon()
    local before = copy(TT.characterSaved)
    local _, _, award = TT.ChatOutput:OnChatMessage(env.CHAT_CHANNEL_SAY, "Name", (wire(TT)), false, nil)
    noAward(award, "ineligible"); same(TT.characterSaved, before)
end)

test("bad, customer-service, unrecognized and unsupported messages do not touch state", function()
    local TT, env = loadAddon()
    local text, _, body, profile = wire(TT)
    local function marker(version, id)
        local payload, bits = 215 * 65536 + version * 4096 + id, {}
        for bit = 23, 0, -1 do
            bits[#bits + 1] = math.floor(payload / 2 ^ bit) % 2 == 0
                and TT.Versioning.ZERO_BIT or TT.Versioning.ONE_BIT
        end
        return table.concat(bits)
    end
    local before, count = copy(TT.characterSaved), #env.messages
    for _, bad in ipairs({ false, 123, {}, "", "ordinary unrecognized chat", body .. marker(2, profile.wireId),
        body .. marker(1, 4095), marker(1, profile.wireId) }) do
        equal(receive(TT, env, bad), nil); same(TT.characterSaved, before)
    end
    equal(TT.ChatOutput:OnChatMessage(10, "Name", nil, false, "@Other"), nil)
    equal(receive(TT, env, text, "@Other", nil, true), nil)
    same(TT.characterSaved, before); equal(#env.messages, count)
    TT.characterSaved.languages.taagra.schemaVersion = 2
    before = copy(TT.characterSaved)
    equal(receive(TT, env, text), nil); same(TT.characterSaved, before)
end)

test("immediate/deferred formatting preserves partial comprehension and never re-awards", function()
    for _, deferred in ipairs({ false, true }) do
        for _, showName in ipairs({ false, true }) do
            local TT, env = loadAddon(nil, { deferred = deferred })
            TT.saved.showLanguageName = showName
            local state = TT.Proficiency:GetState("taagra")
            assert(TT.Knowledge:MasterVocabulary(state, TT.CanonicalCatalog:Resolve("guard").id))
            local text, document, body, profile = wire(TT)
            local expected = TT.Comprehension:Render(document, TT.Knowledge:Snapshot(state))
            assert(expected ~= body and expected ~= TT.Translator:DecodeBody(profile, body))
            local formatted = TT.Formatter:Translation(profile, expected)
            local count = #env.messages
            local rendered, stats, award = receive(TT, env, text)
            equal(rendered, expected); equal(stats.translatedWords, 1); equal(award.reason, "awarded")
            equal(#env.messages, count + (deferred and 0 or 1))
            equal(#env.queued, deferred and 1 or 0)
            local after = copy(state)
            -- Even if knowledge/preferences change while queued, output is captured.
            state.vocabularyXP = 10000; TT.saved.showLanguageName = not showName
            env.flush()
            equal(#env.messages, count + 1); equal(env.messages[#env.messages], formatted)
            after.vocabularyXP = 10000; same(state, after)
            local beforeCallback = copy(state)
            env.fire(env.EVENT_CHAT_MESSAGE_CHANNEL, 999, "", formatted, false, "")
            same(state, beforeCallback)
            equal(#env.messages, count + 1); equal(#env.queued, 0)
        end
    end
end)

test("Proficiency delegates only registered study/practice activities", function()
    local TT, env = loadAddon()
    local entry = TT.CanonicalCatalog:Resolve("guard")
    local definition = { vocabulary = { [entry.id] = entry.requirement }, vocabularyXP = 3 }
    TT.Progression:RegisterLesson("integration-lesson", definition)
    TT.Progression:RegisterExercise("integration-exercise", definition)
    definition.vocabularyXP = 9999 -- registration owns a copy
    local state = TT.Proficiency:GetState("taagra")
    local study = TT.Proficiency:Study("taagra", "integration-lesson", env.now)
    equal(study.reason, "awarded"); equal(study.vocabularyXP, 3)
    local practice = TT.Proficiency:Practice("taagra", "integration-exercise", env.now)
    equal(practice.reason, "awarded"); equal(practice.vocabularyXP, 3)
    noAward(TT.Proficiency:Study("taagra", "integration-lesson", env.now), "activity-cooldown")
    noAward(TT.Proficiency:Practice("taagra", "integration-exercise", env.now), "activity-cooldown")
    noAward(TT.Proficiency:Study("taagra", "guard run", env.now), "unknown-activity")
    noAward(TT.Proficiency:Practice("taagra", { vocabularyXP = 9999 }, env.now), "unknown-activity")
    equal(state.vocabularyXP, 6); equal(TT.Proficiency:GetState("jel").vocabularyXP, 0)
    local result, reason = TT.Proficiency:Practice("absentPack", "integration-exercise", env.now)
    equal(result, nil); equal(reason, "unavailable-knowledge")
end)

print(string.format("Proficiency integration: %d passed, %d failed (%s).", passed, failed, _VERSION))
assert(failed == 0, "Proficiency integration failures: " .. failed)
