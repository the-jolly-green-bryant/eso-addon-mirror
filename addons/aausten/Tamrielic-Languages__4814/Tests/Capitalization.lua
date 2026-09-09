-- Run from the addon root: lua Tests/Capitalization.lua
-- Load only core/language modules; no ESO runtime or editor stubs are needed.
---@type table<string, any>
local env = setmetatable({}, { __index = _G })
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
TT.Registry:Finalize()
local failures = 0
local count = 0

for _, profile in ipairs(TT.Registry:GetOrdered()) do
    count = count + 1
    for _, source in ipairs({ "I", "A" }) do
        local encoded = TT.Translator:EncodeWord(profile, source)
        local target = assert(profile.lexicon[string.lower(source)])
        local expected = string.upper(target:sub(1, 1)) .. target:sub(2)
        if encoded ~= expected then
            failures = failures + 1
            print(string.format("FAIL %s: %s -> %s (expected %s)", profile.id, source, encoded, expected))
        end
        assert(TT.Translator:DecodeWord(profile, encoded) == source, profile.id .. ": single-letter round trip")
        -- Previously sent uppercase forms must still decode correctly.
        assert(TT.Translator:DecodeWord(profile, string.upper(target)) == source, profile.id .. ": legacy decoding")
    end
end
assert(count == 9, "expected all nine language packs")
assert(failures == 0, tostring(failures) .. " unexpected uppercase expansions across " .. count .. " languages")

assert(TT.Normalizer:GetCase("I") == "title")
assert(TT.Normalizer:GetCase("A") == "title")
assert(TT.Normalizer:GetCase("i") == "lower")
assert(TT.Normalizer:GetCase("Guard") == "title")
assert(TT.Normalizer:GetCase("GUARD") == "upper")
assert(TT.Normalizer:GetCase("") == "lower")

for _, profile in ipairs(TT.Registry:GetOrdered()) do
    for _, source in ipairs({ "I trust you, friend.", "A guard and I wait.", "I am a guard.", "I! A? I, A." }) do
        local encoded = assert(TT.Translator:Encode(profile.id, source))
        local _, body = TT.Translator:Detect(encoded)
        assert(body and not body:find("%u%u"), profile.id .. ": unexpected uppercase in " .. encoded)
        assert(TT.Translator:Decode(encoded) == source, profile.id .. ": sentence round trip")
    end
    local pronounCases = {
        { "He saw me and I ran", { false } },
        { "I ran and I hid.", { true, false } },
        { "He ran. I hid! I waited? I left.", { true, true, true } },
        { "  \"I ran,\" he said, \"and I hid.\"", { true, false } },
        { "He ran; I hid: I waited, I left.", { false, false, false } },
        { "He ran\nI hid\r\nI waited.", { true, true } },
        { "I'm here and I'll wait.", { true, false } },
        { "123 I ran", { false } },
        { "é I ran", { false } },
        { "|H1:item:123|h[I!]|h I ran", { false } },
        { "|H1:item:123|h[I!]|h. I ran", { true } },
    }
    for _, case in ipairs(pronounCases) do
        local source, expectedCases = case[1], case[2]
        local body = TT.Translator:EncodeBody(profile, source)
        local seen = 0
        TT.Tokenizer:MapWords(body, function(word)
            if string.lower(word) == profile.lexicon.i then
                seen = seen + 1
                local mode = expectedCases[seen] and "title" or "lower"
                assert(word == TT.Normalizer:ApplyCase(profile.lexicon.i, mode), profile.id .. ": pronoun case in " .. source)
            end
            return word
        end)
        assert(seen == #expectedCases, profile.id .. ": pronoun count in " .. source)
        assert(TT.Translator:DecodeBody(profile, body) == source, profile.id .. ": contextual round trip for " .. source)
    end
    local lowercaseSource = "he saw me and i ran"
    assert(TT.Translator:DecodeBody(profile, TT.Translator:EncodeBody(profile, lowercaseSource)) == "he saw me and I ran")

    -- Preserve intentional emphasis, title case, inflections, and codec behavior.
    for _, source in ipairs({ "guard", "Guard", "GUARD", "guards", "Guards", "GUARDS", "Leiadriel", "LEIADRIEL" }) do
        local encoded = TT.Translator:EncodeWord(profile, source)
        assert(TT.Translator:DecodeWord(profile, encoded) == source, profile.id .. ": case round trip for " .. source)
        if source == "GUARD" or source == "GUARDS" then
            assert(encoded == string.upper(encoded), profile.id .. ": intentional emphasis lost")
        end
    end
end

loadInEnvironment("Tests/RoundTrip.lua")
print("Capitalization and existing round-trip tests passed for all nine languages.")
