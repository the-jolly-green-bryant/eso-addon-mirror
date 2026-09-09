-- Run from the addon root: lua Tests/Localization.lua
-- Isolated ESO mocks; this file is never loaded by the addon manifest.
local function loadAddon(language)
    ---@type table<string, any>
    local env = setmetatable({}, { __index = _G })
    env._G = env
    local strings, versions, messages = {}, {}, {}
    local nextId = 0

    env.GetCVar = function(name)
        assert(name == "language.2")
        return language
    end
    env.ZO_CreateStringId = function(name, text)
        assert(rawget(env, name) == nil, "duplicate string ID: " .. name)
        nextId = nextId + 1
        env[name] = nextId
        strings[nextId], versions[nextId] = text, 0
    end
    env.SafeAddString = function(id, text, version)
        assert(strings[id], "override without default")
        if version >= versions[id] then
            strings[id], versions[id] = text, version
        end
    end
    env.GetString = function(id)
        return assert(strings[id], "missing string")
    end
    -- Only the numbered placeholders used here, not ESO's full grammar engine.
    env.zo_strformat = function(text, ...)
        local args = { ... }
        return (text:gsub("<<(%d+)>>", function(index)
            return tostring(assert(args[tonumber(index)], "missing format argument"))
        end))
    end
    env.EVENT_MANAGER = {
        RegisterForEvent = function() return true end,
        UnregisterForEvent = function() return true end,
    }
    env.EVENT_ADD_ON_LOADED = 1
    env.EVENT_CHAT_MESSAGE_CHANNEL = 2
    env.EVENT_PLAYER_ACTIVATED = 3
    env.GetWorldName = function() return "EU Megaserver" end
    env.GetUnitRaceId = function() return 8 end
    env.CHAT_ROUTER = {
        AddSystemMessage = function(_, message) messages[#messages + 1] = message end,
    }
    env.SharedChatSystem = {}
    env.ZO_PreHook = function() end
    env.SLASH_COMMANDS = {}
    env.ZO_SavedVars = {
        NewCharacterIdSettings = function(_, _, version, namespace, _, world)
            assert(version == 1 and (namespace == "Proficiency" or namespace == "Preferences")
                            and world == "EU Megaserver")
            return {}
        end,
        NewAccountWide = function(_, _, _, _, defaults)
            local saved = {}
            for key, value in pairs(defaults) do saved[key] = value end
            return saved
        end,
    }

    for line in io.lines("TamrielicTongues.txt") do
        local path = line:match("^%s*(.-)%s*$")
        if path:match("%.lua$") then
            local chunk
            if _VERSION == "Lua 5.1" then
                chunk = assert(loadfile(path))
                setfenv(chunk, env)
            else
                chunk = assert(loadfile(path, "t", env))
            end
            chunk()
        end
    end
    env.TamrielicTongues:Initialize()
    return env.TamrielicTongues, messages
end

local en, messages = loadAddon("en")
assert(en.Locale:Get("COMMON_NAME") == "Tamrielic (Common)")
assert(messages[1]:find("v1.5.0 loaded", 1, true))
en.Commands:HandleTT("help")
for _, command in ipairs({ "/lang", "/tt languages", "/tt translations", "/tt test", "/tt status", "/tt about", "/tt help" }) do
    assert(messages[#messages]:find(command, 1, true), "missing help: " .. command)
end
en.Commands:HandleTT("translations off")
en.Commands:HandleTT("status")
assert(messages[#messages]:find("Incoming translations: off.", 1, true))
en.Commands:Test("common Hello, friend.")
assert(messages[#messages]:find("Round trip: Hello, friend.", 1, true))
en.Commands:Test("taagra Hello, friend.")
assert(messages[#messages]:find("Round trip: Hello, friend.", 1, true))
en.Locale:Register("de", { COMMON_NAME = "must not load" }, 1)
assert(en.Locale:Get("COMMON_NAME") == "Tamrielic (Common)")

local de, translatedMessages = loadAddon("de")
local originalHelp = de.Locale:Get("HELP")
local profile = assert(de.Registry:Resolve("taagra"))
local sample = "Meet me at the old bridge after midnight."
local before = assert(de.Translator:Encode("taagra", sample))
de.Locale:Register("de", {
    COMMON_NAME = "Test Common",
    LANGUAGE_TAAGRA = "Test Language",
    RACE_TAAGRA = "Test Race",
    STATUS = "<<2>> / <<1>>",
    OFF = "Test Off",
    MESSAGE_EMPTY = "Test Empty",
}, 2)
assert(de.Locale:Get("HELP") == originalHelp, "partial override lost English fallback")
assert(de.Locale:LanguageName(profile) == "Test Language")
assert(de.Locale:RaceName(profile) == "Test Race")
assert(profile.name == "Ta'agra" and profile.race == "Khajiit")
assert(de.Registry:ResolveId("khajiit") == "taagra", "alias changed")
assert(de.Translator:Encode("taagra", sample) == before, "locale changed wire format")
assert(de.Locale:LanguageName({ id = "custom", name = "Custom" }) == "Custom")
de.Locale:Register("de", { COMMON_NAME = "outdated" }, 1)
assert(de.Locale:Get("COMMON_NAME") == "Test Common", "older override won")
de.Commands:HandleTT("translations off")
de.Commands:HandleTT("status")
assert(translatedMessages[#translatedMessages]:find("Test Off / Test Common", 1, true))
local _, emptyError = de.Translator:Encode("taagra", "")
assert(emptyError == "Test Empty")
assert(not pcall(function() de.Locale:Get("MISSING_KEY") end))

local unsupported = loadAddon("zz")
assert(unsupported.Locale:Get("HELP") == originalHelp)
print("Localization tests passed (English, partial override, unsupported locale, command output, stable encoding).")
