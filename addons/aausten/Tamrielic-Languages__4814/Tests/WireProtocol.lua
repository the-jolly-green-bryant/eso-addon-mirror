-- Run from the addon root: lua Tests/WireProtocol.lua (Lua 5.1 or 5.4).
-- Isolated core/language loader: no ESO runtime, localization files, or hooks.
local env = setmetatable({ TamrielicTongues = {} }, { __index = _G })
env._G = env

local function loadInEnvironment(path)
    local chunk
    if _VERSION == "Lua 5.1" then
        chunk = assert(loadfile(path))
        setfenv(chunk, env)
    else
        chunk = assert(loadfile(path, "t", env))
    end
    chunk()
end

for line in io.lines("TamrielicTongues.txt") do
    local path = line:match("^%s*(.-)%s*$")
    if path:match("%.lua$") and (path:match("^Core/") or path:match("^Language/") or path:match("^Languages/")) then
        loadInEnvironment(path)
    end
end

local TT = env.TamrielicTongues
local printed = {}
TT.Locale = {
    Get = function(_, key, ...)
        local parts = { key }
        for index = 1, select("#", ...) do
            parts[#parts + 1] = tostring(select(index, ...))
        end
        return table.concat(parts, ":")
    end,
}
function TT:Print(message)
    printed[#printed + 1] = message
end

loadInEnvironment("Chat/MessageDetector.lua")
loadInEnvironment("UI/Settings.lua")
loadInEnvironment("Chat/Input.lua")
TT.Registry:Finalize()

local tests, failures = 0, 0
local function test(name, callback)
    tests = tests + 1
    local ok, err = pcall(callback)
    if not ok then
        failures = failures + 1
        print("FAIL " .. name .. ": " .. tostring(err))
    end
end

local function equal(actual, expected, label)
    assert(actual == expected, (label or "value") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end

local function copy(value, seen)
    if type(value) ~= "table" then
        return value
    end
    seen = seen or {}
    if seen[value] then
        return seen[value]
    end
    local result = {}
    seen[value] = result
    for key, item in pairs(value) do
        result[key] = copy(item, seen)
    end
    return result
end

local expectedIds = {
    taagra = 1, jel = 2, dunmeri = 3, altmeris = 4, bosmeri = 5,
    nordic = 6, orcish = 7, yoku = 8, bretic = 9,
}
local profiles = TT.Registry:GetOrdered()
local first = assert(TT.Registry:Resolve("taagra"))
-- Independent hexadecimal-to-bit vectors, rather than production arithmetic.
local zeroBit, oneBit = string.char(226, 128, 139), string.char(226, 128, 140)
local nibbles = {
    ["0"] = "0000", ["1"] = "0001", ["2"] = "0010", ["3"] = "0011",
    ["4"] = "0100", ["5"] = "0101", ["6"] = "0110", ["7"] = "0111",
    ["8"] = "1000", ["9"] = "1001", A = "1010", B = "1011",
    C = "1100", D = "1101", E = "1110", F = "1111",
}
local function expectedMarker(hex)
    assert(#hex == 6)
    local bits = hex:gsub(".", nibbles)
    return (bits:gsub(".", { ["0"] = zeroBit, ["1"] = oneBit }))
end
local marker = expectedMarker("D71001")

local function parsed(text, version, id, body)
    local actualVersion, actualId, actualBody = TT.Versioning:ParseMarker(text)
    equal(actualVersion, version, "wire version")
    equal(actualId, id, "wire ID")
    equal(actualBody, body, "marker body")
end

local function detected(text, profile, body)
    local actualProfile, actualBody = TT.Translator:Detect(text)
    equal(actualProfile, profile, "Translator profile")
    equal(actualBody, body, "Translator body")
    actualProfile, actualBody = TT.MessageDetector:Detect(text)
    equal(actualProfile, profile, "MessageDetector profile")
    equal(actualBody, body, "MessageDetector body")
end

local function rejected(text)
    equal(TT.Translator:Detect(text), nil, "Translator rejection")
    equal(TT.MessageDetector:Detect(text), nil, "MessageDetector rejection")
    equal(TT.Translator:Decode(text), nil, "Decode rejection")
end

test("permanent assignments and all nine packs", function()
    equal(TT.Versioning.WIRE_VERSION, 1)
    equal(TT.Versioning.MARKER_PREFIX, "D7")
        equal(TT.Versioning.ZERO_BIT, zeroBit)
        equal(TT.Versioning.ONE_BIT, oneBit)
        equal(TT.Versioning.MARKER_BITS, 24)
        equal(TT.Versioning.MARKER_BYTES, 72)
        equal(marker, oneBit .. oneBit .. zeroBit .. oneBit .. zeroBit .. oneBit .. oneBit .. oneBit
            .. zeroBit .. zeroBit .. zeroBit .. oneBit .. string.rep(zeroBit, 11) .. oneBit)
    equal(#profiles, 9, "pack count")
    local count = 0
    for id, wireId in pairs(TT.Registry.WireIds) do
        equal(wireId, expectedIds[id], "central assignment " .. id)
        count = count + 1
    end
    equal(count, 9, "central assignment count")
    for id, wireId in pairs(expectedIds) do
        local profile = assert(TT.Registry:Resolve(id), id)
        equal(profile.wireId, wireId, id .. " profile assignment")
        equal(TT.Registry:FromWireId(wireId), profile, id .. " wire lookup")
        local suffix = TT.Versioning:GetMarker(profile)
                equal(suffix, expectedMarker(string.format("D71%03X", wireId)), id .. " marker")
                equal(#suffix, 72)
                equal(suffix:find("|", 1, true), nil, "no color markup generated")
                parsed(suffix, 1, wireId, "")
        equal(TT.Versioning:IsCompatible(profile), true, id .. " default compatibility")
        equal(TT.Versioning:IsCompatible(profile, 1), true, id .. " v1 compatibility")
    end
    equal(TT.Registry:FromWireId(0), nil)
    equal(TT.Registry:FromWireId(4095), nil)
    equal(TT.Registry:FromWireId("1"), nil)
end)

local samples = {
    "Meet me at the old bridge after midnight.",
    "I trust you, friend.",
        "I really want this to work.",
        "hello|", "hello|||",
        "hello" .. zeroBit .. "friend" .. oneBit,
        zeroBit .. oneBit .. "Hello" .. string.char(226, 128, 141),
        "Hello |cD71001 |r", -- Former markers are ordinary body markup.
    "Follow the guard and wait outside.",
    "Leiadriel will return tomorrow.",
    "Do not open the gate.",
    "hello", "I", "A", "GUARD",
    "Hello, friend! (Wait... really?) 123; yes: no.",
    "!!! 123 -- ?", "é café naïve — 世界 Привет",
    "Take |H1:item:123|h[An Iron Sword!]|h now.",
    "|cAa00FfHello|r, |c00ff00friend|r!",
    "|cFFFFFF|H1:item:123|h[An Iron Sword!]|h|r",
    "Hello || friend |||cAABBCCguard|r.",
    "Hello ||cD71001 ||r", -- Escaped markup is visible text, not a protocol suffix.
    "Hello  \t", "Hello\n", "Hello\r\n\n", "  Hello\nfriend.\t \r\n",
    " \t\r\n",
}

for _, profile in ipairs(profiles) do
    for index, source in ipairs(samples) do
        test(profile.id .. " round trip sample " .. index, function()
            local body = TT.Translator:EncodeBody(profile, source)
            local suffix = expectedMarker(string.format("D71%03X", expectedIds[profile.id]))
            local encoded, err, encodedProfile = TT.Translator:Encode(profile.id, source)
            equal(err, nil, "encode error")
            equal(encodedProfile, profile, "encode profile")
            -- Exact equality proves there is no leading legacy signature or separator.
            equal(encoded, body .. suffix, "suffix-only encoding")
            parsed(encoded, 1, profile.wireId, body)
            detected(encoded, profile, body)
            local decoded, decodedProfile = TT.Translator:Decode(encoded)
            equal(decoded, source, "lossless round trip")
            equal(decodedProfile, profile, "decode profile")
        end)
    end
    for _, signature in ipairs(profile.signatures) do
        test(profile.id .. " legacy signature " .. signature, function()
            local source = "I trust you, friend.\n"
            local body = TT.Translator:EncodeBody(profile, source)
            for _, spelling in ipairs({ signature, string.upper(signature) }) do
                local legacy = spelling .. " " .. body
                detected(legacy, profile, body)
                local decoded, decodedProfile = TT.Translator:Decode(legacy)
                equal(decoded, source, "legacy decode")
                equal(decodedProfile, profile)
            end
        end)
    end
end

test("tokenizer preserves actual ESO markup but maps visible words", function()
    local link = "|H1:item:123|h[An Iron Sword!]|h"
    local source = "|cAa00FfHello|r " .. link .. " || friend |||c00ff00guard|r"
    local mapped = TT.Tokenizer:MapWords(source, function(word)
        return "<" .. word .. ">"
    end)
    equal(mapped, "|cAa00Ff<Hello>|r " .. link .. " || <friend> |||c00ff00<guard>|r")
end)

test("marker parsing preserves every body byte and reads only the final suffix", function()
    for _, body in ipairs({ "", "body \t\r\n", "body|", "body|||", zeroBit .. oneBit,
        "body" .. marker, "|cD71001 |r", string.char(255) }) do
        parsed(body .. marker, 1, 1, body)
    end
    rejected(marker) -- A marker without a message is not spoken text.
end)

local unsupported = {
    { expectedMarker("D70001"), 0, 1 },
    { expectedMarker("D72001"), 2, 1 },
    { expectedMarker("D7F001"), 15, 1 },
    { expectedMarker("D71000"), 1, 0 },
    { expectedMarker("D71040"), 1, 64 },
    { expectedMarker("D71FFF"), 1, 4095 },
}
for _, case in ipairs(unsupported) do
    test("unsupported suffix v" .. case[2] .. " ID " .. case[3] .. " prevents legacy fallback", function()
        for _, body in ipairs({ "hello", first.signatures[1] .. " hello" }) do
            local text = body .. case[1]
            parsed(text, case[2], case[3], body)
            rejected(text)
        end
    end)
end

local malformed = {
    "", "hello", expectedMarker("E71001"), expectedMarker("071001"),
    string.rep(zeroBit, 24), string.rep(oneBit, 24),
    "hello" .. marker .. "more", "hello" .. marker .. " ",
    "hello" .. marker .. "\n", "hello" .. marker .. "\r\n",
    "hello" .. marker .. zeroBit,
    "hello||cD71001 ||r",
    "hello|cD71001 |r", "hello|cd71001 |r", "hello|cD71ABC |r",
    "hello|cD72001 |r", "hello|cD71FFF |r",
}
-- Every truncation, and every invalid three-byte group position, must fail.
for length = 1, 71 do
    malformed[#malformed + 1] = "hello" .. marker:sub(1, length)
    malformed[#malformed + 1] = "hello" .. marker:sub(length + 1)
end
for index = 1, 72, 3 do
    for _, invalid in ipairs({ "abc", string.char(226, 128, 141), -- U+200D is not a bit.
        string.char(226, 40, 139), string.char(255, 128, 139),
        string.char(192, 128, 139), string.char(237, 160, 128) }) do
        malformed[#malformed + 1] = "hello" .. marker:sub(1, index - 1)
            .. invalid .. marker:sub(index + 3)
    end
end
for index, text in ipairs(malformed) do
    test("malformed/nonterminal/former color marker " .. index, function()
        parsed(text, nil, nil, nil)
        rejected(text)
    end)
end

test("non-string input is not a marker or encoded message", function()
    for _, text in ipairs({ false, 1, {} }) do
        parsed(text, nil, nil, nil)
        rejected(text)
    end
    parsed(nil, nil, nil, nil)
    rejected(nil)
end)

test("valid suffix takes precedence over a legacy-looking first word", function()
    local other = assert(TT.Registry:Resolve("jel"))
    local body = first.signatures[1] .. " hello"
    detected(body .. TT.Versioning:GetMarker(other), other, body)
end)

-- Give registration tests their own maps so even an incorrectly accepted
-- candidate cannot corrupt the production profiles used by subsequent tests.
local function registryFixture()
    local registry = setmetatable({
        WireIds = copy(TT.Registry.WireIds),
        wireLanguages = {}, languages = {}, aliases = {}, signatures = {}, ordered = {},
    }, { __index = TT.Registry })
    registry:Register(copy(first))
    return registry
end

local function candidate(id, wireId)
    local profile = copy(first)
    profile.id = id
    profile.name = "Test " .. id
    profile.race = "Test race " .. id
    profile.aliases = { "test-alias-" .. id }
    profile.signatures = { "test-signature-" .. id }
    profile.wireId = wireId
    return profile
end

local function snapshotFields(object)
    local fields = {}
    for key, value in pairs(object) do
        fields[key] = value
    end
    return fields
end

local function unchanged(object, before, label)
    for key, value in pairs(before) do
        equal(object[key], value, label .. " changed " .. tostring(key))
    end
    for key, value in pairs(object) do
        equal(value, before[key], label .. " added " .. tostring(key))
    end
end

local function registrationRejected(registry, profile)
    local maps = { "WireIds", "wireLanguages", "languages", "aliases", "signatures", "ordered" }
    local before, references = {}, snapshotFields(registry)
    for _, name in ipairs(maps) do
        before[name] = snapshotFields(registry[name])
    end
    local profileBefore = snapshotFields(profile)
    local ok = pcall(function() registry:Register(profile) end)
    unchanged(registry, references, "registry fields")
    for _, name in ipairs(maps) do
        unchanged(registry[name], before[name], name)
    end
    unchanged(profile, profileBefore, "rejected profile")
    equal(ok, false, "registration must fail")
end

test("duplicate language ID registration is atomic", function()
    registrationRejected(registryFixture(), candidate("TAAGRA", 1))
end)

test("duplicate wire ID registration is atomic", function()
    local registry = registryFixture()
    registry.WireIds.future = 1
    registrationRejected(registry, candidate("future", 1))
end)

for _, wireId in ipairs({ 0, -1, 4096, 1.5, "10" }) do
    test("invalid wire ID " .. tostring(wireId) .. " registration is atomic", function()
        local registry = registryFixture()
        registry.WireIds.future = wireId
        registrationRejected(registry, candidate("future", wireId))
    end)
end

test("missing profile wire ID registration is atomic", function()
    local registry = registryFixture()
    registry.WireIds.future = 10
    registrationRejected(registry, candidate("future", nil))
end)

test("missing central assignment registration is atomic", function()
    registrationRejected(registryFixture(), candidate("future", 10))
end)

test("mismatched central assignment registration is atomic", function()
    local registry = registryFixture()
    registry.WireIds.future = 11
    registrationRejected(registry, candidate("future", 10))
end)

local function withRegistry(registry, callback)
    local original = TT.Registry
    TT.Registry = registry
    local ok, err = pcall(callback)
    TT.Registry = original
    assert(ok, err)
end

for _, wireId in ipairs({ 64, 65, 255, 256, 2748, 4095 }) do
    test("centrally assigned ID " .. wireId .. " works without translator changes", function()
        local registry = registryFixture()
        local future = candidate("future", wireId)
        future.signatures = nil -- New packs need no spoken legacy marker.
        registry.WireIds.future = wireId
        registry:Register(future)
        withRegistry(registry, function()
            equal(TT.Registry:FromWireId(wireId), future)
            equal(TT.Registry:Resolve("test-alias-future"), future)
            local suffix = expectedMarker(string.format("D71%03X", wireId))
            equal(TT.Versioning:GetMarker(future), suffix)
            equal(#suffix, 72)
            for _, source in ipairs(samples) do
                local body = TT.Translator:EncodeBody(future, source)
                local encoded = assert(TT.Translator:Encode("future", source))
                equal(encoded, body .. suffix)
                parsed(encoded, 1, wireId, body)
                detected(encoded, future, body)
                equal(TT.Translator:Decode(encoded), source)
            end
        end)
    end)
end

test("profile and protocol versions must both be compatible", function()
    equal(TT.Versioning:IsCompatible(nil), false)
    equal(TT.Versioning:IsCompatible({}), false)
    equal(TT.Versioning:IsCompatible(first, 0), false)
    equal(TT.Versioning:IsCompatible(first, 2), false)
    equal(TT.Versioning:IsCompatible(first, "1"), false)
    local registry = registryFixture()
    local incompatible = registry:FromWireId(1)
    incompatible.version = 2
    equal(TT.Versioning:IsCompatible(incompatible), false)
    equal(TT.Versioning:IsCompatible(incompatible, 1), false)
    equal(pcall(function() TT.Versioning:GetMarker(incompatible) end), false)
    withRegistry(registry, function()
        rejected("hello" .. marker)
        rejected(first.signatures[1] .. " hello" .. marker)
        equal(TT.Translator:Encode(incompatible.id, "hello"), nil, "incompatible encode")
    end)
end)

for _, id in ipairs({ TT.Constants.COMMON_LANGUAGE_ID, "off", "tamrielic" }) do
    test(id .. " is unchanged and unmarked", function()
        for _, source in ipairs(samples) do
            local encoded, err = TT.Translator:Encode(id, source)
            equal(encoded, source)
            equal(err, nil)
            equal(TT.Versioning:ParseMarker(encoded), nil)
        end
        local forwarded = "hello" .. marker
        equal(TT.Translator:Encode(id, forwarded), forwarded, "already marked Common text")
    end)
end

local function submit(text, languageId, limit)
    TT.saved = { activeLanguage = "common" }
    TT.characterPreferences = languageId ~= false and { activeLanguage = languageId or first.id } or nil
    env.MAX_TEXT_CHAT_INPUT_CHARACTERS = limit or TT.Constants.DEFAULT_MAX_CHAT_CHARACTERS
    printed = {}
    local entry = { text = text, writes = 0 }
    function entry:GetText() return self.text end
    function entry:SetText(value)
        self.text = value
        self.writes = self.writes + 1
    end
    local blocked = TT.ChatInput:BeforeSubmit({ textEntry = entry })
    return blocked, entry, printed
end

local function passThrough(text, languageId)
    local blocked, entry, messages = submit(text, languageId)
    equal(blocked, false, "native submission allowed")
    equal(entry.text, text, "text unchanged")
    equal(entry.writes, 0, "no SetText")
    equal(#messages, 0, "no error printed")
end

test("ChatInput uses character Common and unavailable preferences, never legacy selection", function()
    passThrough("hello", "common")
    passThrough("hello", false)
    TT.saved.activeLanguage = first.id
    local entry = { GetText = function() return "hello" end,
        SetText = function() error("unavailable preferences must pass through") end }
    equal(TT.ChatInput:BeforeSubmit({ textEntry = entry }), false)
    TT.characterPreferences = { activeLanguage = "common" }
    equal(TT.ChatInput:BeforeSubmit({ textEntry = entry }), false)
end)

for _, profile in ipairs(profiles) do
    test(profile.id .. " ChatInput does not double encode known wire or legacy text", function()
        local body = TT.Translator:EncodeBody(profile, "Hello, friend.")
        passThrough(body .. TT.Versioning:GetMarker(profile))
        for _, signature in ipairs(profile.signatures) do
            passThrough(signature .. " " .. body)
        end
    end)
end
for _, case in ipairs(unsupported) do
    test("ChatInput forwards unsupported marker v" .. case[2] .. " ID " .. case[3], function()
        passThrough("hello" .. case[1])
        passThrough(first.signatures[1] .. " hello" .. case[1])
    end)
end

test("all trailing pipes preserve marker boundaries and repeated submission", function()
    for _, profile in ipairs(profiles) do
        for _, pipes in ipairs({ "|", "||", "|||", "||||" }) do
            local source = "hello" .. pipes
            local encoded = assert(TT.Translator:Encode(profile.id, source))
            equal(TT.Translator:Decode(encoded), source)
            passThrough(encoded, profile.id)
            local blocked, entry, messages = submit(source, profile.id)
            equal(blocked, false)
            equal(entry.text, encoded)
            equal(entry.writes, 1)
            equal(#messages, 0)
            equal(TT.ChatInput:BeforeSubmit({ textEntry = entry }), false)
            equal(entry.text, encoded)
            equal(entry.writes, 1)
        end
    end
end)

test("ChatInput normal encode then repeated submit", function()
    local source = "Hello, friend."
    local expected = TT.Translator:EncodeBody(first, source) .. marker
    local blocked, entry, messages = submit(source)
    equal(blocked, false)
    equal(entry.text, expected)
    equal(entry.writes, 1)
    equal(#messages, 0)
    equal(TT.ChatInput:BeforeSubmit({ textEntry = entry }), false)
    equal(entry.text, expected)
    equal(entry.writes, 1, "second submission must not encode again")
end)

test("ChatInput treats former color markers as ordinary body, not forwarded messages", function()
    local source = "hello|cD71001 |r"
    local blocked, entry = submit(source)
    equal(blocked, false)
    equal(entry.writes, 1)
    equal(entry.text, TT.Translator:EncodeBody(first, source) .. marker)
    equal(TT.Translator:Decode(entry.text), source)
end)

test("ChatInput leaves Common, empty text, and slash commands alone", function()
    passThrough("Hello, friend.", TT.Constants.COMMON_LANGUAGE_ID)
    passThrough("")
    passThrough("/say Hello, friend.")
    equal(TT.ChatInput:BeforeSubmit(nil), false)
    equal(TT.ChatInput:BeforeSubmit({}), false)
end)

test("ChatInput exact size boundary includes the wire suffix", function()
    local limit = TT.Constants.DEFAULT_MAX_CHAT_CHARACTERS
    -- Digits do not expand, so the only overhead is the 72-byte suffix.
    equal(#marker, 72)
    local source = string.rep("1", limit - #marker)
    local blocked, entry, messages = submit(source, first.id, limit)
    equal(blocked, false, "exact limit allowed")
    equal(entry.text, source .. marker)
    equal(#entry.text, limit)
    equal(entry.writes, 1)
    equal(#messages, 0)
end)

test("ChatInput one byte over size boundary is blocked without changing input", function()
    local limit = TT.Constants.DEFAULT_MAX_CHAT_CHARACTERS
    local source = string.rep("1", limit - #marker + 1)
    local blocked, entry, messages = submit(source, first.id, limit)
    equal(blocked, true)
    equal(entry.text, source)
    equal(entry.writes, 0)
    equal(#messages, 1)
    equal(messages[1], "MESSAGE_TOO_LONG:" .. (limit + 1) .. ":" .. limit)
end)

test("ChatInput size accounting uses UTF-8 bytes, not codepoint count", function()
    local source = string.rep(string.char(226, 128, 141), 10)
    local limit = #source + 72
    local blocked, entry, messages = submit(source, first.id, limit)
    equal(blocked, false)
    equal(entry.text, source .. marker)
    equal(#entry.text, limit)
    equal(#messages, 0)
    blocked, entry, messages = submit(source, first.id, limit - 1)
    equal(blocked, true)
    equal(entry.text, source)
    equal(entry.writes, 0)
    equal(messages[1], "MESSAGE_TOO_LONG:" .. limit .. ":" .. (limit - 1))
end)

print(string.format("Wire protocol tests: %d passed, %d failed (%s).", tests - failures, failures, _VERSION))
assert(failures == 0, tostring(failures) .. " wire protocol tests failed")
