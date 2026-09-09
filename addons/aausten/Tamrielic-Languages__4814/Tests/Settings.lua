-- Run from the addon root: lua Tests/Settings.lua (Lua 5.1/5.4).
-- Mock LAM's getter-only refresh contract; use real registry/knowledge APIs.
---@type table<string, any>
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
local function eq(a, b) assert(a == b, tostring(a) .. " ~= " .. tostring(b)) end
local tests = 0
local function test(name, fn)
    fn(); tests = tests + 1; print("PASS " .. name)
end
local strings, messages = {}, {}
env.ZO_CreateStringId = function(name, text)
    local id = #strings + 1
    env[name], strings[id] = id, text
end
env.GetString = function(id) return assert(strings[id]) end
env.GetCVar = function() return "en" end
env.zo_strformat = function(text, ...)
    local args = { ... }
    return (text:gsub("<<(%d+)>>", function(i) return tostring(args[tonumber(i)]) end))
end
env.SLASH_COMMANDS = {}
local callbacks, updates, registrations = {}, {}, 0
env.CALLBACK_MANAGER = {
    RegisterCallback = function(_, name, callback)
        callbacks[name] = callbacks[name] or {}
        table.insert(callbacks[name], callback)
    end,
    FireCallbacks = function(_, name, ...)
        for _, callback in ipairs(callbacks[name] or {}) do callback(...) end
    end,
}
env.EVENT_MANAGER = {
    RegisterForUpdate = function(_, name, interval, callback)
        eq(interval, 500); assert(not updates[name], "duplicate update")
        updates[name] = callback; registrations = registrations + 1
    end,
    UnregisterForUpdate = function(_, name) updates[name] = nil end,
}
for _, name in ipairs({ "Bootstrap", "Constants", "LanguageRegistry", "CanonicalCatalog",
    "Knowledge", "Progression", "Proficiency" }) do loadModule("Core/" .. name .. ".lua") end
loadModule("Locale/Localization.lua")
loadModule("Locale/en.lua")
loadModule("Language/Normalizer.lua")
loadModule("UI/Settings.lua")
loadModule("UI/Commands.lua")
local TT = env.TamrielicTongues

TT.Print = function(_, text) messages[#messages + 1] = text end
TT.saved = { activeLanguage = "jel", showTranslations = true }
TT.characterPreferences = { activeLanguage = "common" }
TT.Registry:Register({ id = "jel", name = "Jel", race = "Argonian", wireId = 2 })
TT.Registry:Register({ id = "bretic", name = "Bretic", race = "Breton", wireId = 9 })
TT.ChatMenu = { GetActiveLanguageLabel = function() return TT.Settings:GetActiveLanguage() end }
TT.Commands:Initialize()
local S, F = TT.Settings, TT.Proficiency
local function fire(name, panel) env.CALLBACK_MANAGER:FireCallbacks(name, panel) end
local function tick() for _, callback in pairs(updates) do callback() end end

test("speaking settings use only available character preferences", function()
    eq(S:GetActiveLanguage(), "common")
    TT.characterPreferences = nil
    eq(S:GetActiveLanguage(), "common"); eq(S:SetActiveLanguage("jel"), false)
    eq(TT.saved.activeLanguage, "jel")
    TT.characterPreferences = {}
    eq(S:GetActiveLanguage(), "common"); eq(next(TT.characterPreferences), nil)
    eq(S:SetActiveLanguage("unknown"), false); eq(next(TT.characterPreferences), nil)
    local account = TT.saved
    TT.saved = nil
    eq(S:SetActiveLanguage("argonian"), true); eq(S:GetActiveLanguage(), "jel")
    eq(S:SetActiveLanguage("common"), true); eq(S:GetActiveLanguage(), "common")
    TT.saved = account
    eq(TT.saved.activeLanguage, "jel"); eq(TT.saved.showTranslations, true)
end)

test("missing LAM is silent at initialization and localized on command", function()
    eq(S:Initialize(), false); eq(#messages, 0); eq(next(updates), nil)
    env.SLASH_COMMANDS["/tt"]("settings")
    eq(#messages, 1); eq(messages[1], TT.Locale:Get("SETTINGS_MISSING_LIBRARY"))
end)

local panel, panelCount, openCount = {}, 0, 0
---@type table[]
local options = {}
---@type table<string, any>
local panelData = {}
env.LibAddonMenu2 = {
    RegisterAddonPanel = function(_, name, data)
        eq(name, TT.ADDON_NAME .. "Settings")
        panelCount = panelCount + 1; panelData = data
        return panel
    end,
    RegisterOptionControls = function(_, name, data)
        eq(name, TT.ADDON_NAME .. "Settings"); options = data
    end,
    OpenToPanel = function(_, target)
        eq(target, panel); openCount = openCount + 1
        fire("LAM-PanelOpened", target)
    end,
}
local refreshes, writes = 0, 0
local displayed = {}
env.CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", function(target)
    eq(target, panel); refreshes = refreshes + 1
    for i, option in ipairs(options) do
        if option.getFunc then
            displayed[i] = { value = option.getFunc(),
                disabled = option.disabled and option.disabled() or false,
                warning = option.warning and option.warning() }
        end
    end
end)
for _, name in ipairs({ "SetOverall", "SetProgressEnabled" }) do
    local original = F[name]
    F[name] = function(self, ...)
        writes = writes + 1
        return original(self, ...)
    end
end
local dropdown, jelSlider, jelCheck, breticSlider, breticCheck

test("late LAM registration is idempotent, localized and registry ordered", function()
    assert(S:Initialize()); assert(S:Initialize()); eq(panelCount, 1)
    eq(panelData.registerForRefresh, true); eq(panelData.registerForDefaults, nil)
    eq(#options, 9)
    dropdown, jelSlider, jelCheck, breticSlider, breticCheck = options[2], options[5], options[6], options[8], options[9]
    eq(dropdown.type, "dropdown"); eq(dropdown.sort, nil)
    eq(table.concat(dropdown.choicesValues, ","), "common,jel,bretic")
    eq(dropdown.choices[1], TT.Locale:Get("COMMON_NAME"))
    for i, profile in ipairs(TT.Registry:GetOrdered()) do
        eq(dropdown.choices[i + 1], TT.Locale:LanguageName(profile))
        eq(options[1 + i * 3].name, TT.Locale:LanguageName(profile))
    end
    eq(dropdown.name, TT.Locale:Get("SETTINGS_SPEAKING"))
    for _, slider in ipairs({ jelSlider, breticSlider }) do
        eq(slider.type, "slider"); eq(slider.min, 0); eq(slider.max, 100)
        eq(slider.step, 1); eq(slider.decimals, 0); eq(slider.clampInput, true)
        eq(slider.tooltip, TT.Locale:Get("SETTINGS_OVERALL_TOOLTIP"))
    end
    for _, check in ipairs({ jelCheck, breticCheck }) do
        eq(check.type, "checkbox"); eq(check.tooltip, TT.Locale:Get("SETTINGS_PROGRESS_TOOLTIP"))
    end
    eq(next(updates), nil); eq(writes, 0)
end)

local store = {}
test("command opens panel before knowledge is ready without saving fallback values", function()
    eq(F:Initialize(store, 0), false)
    fire("LAM-PanelOpened", {}); eq(next(updates), nil)
    env.SLASH_COMMANDS["/tt"]("settings")
    eq(openCount, 1); eq(refreshes, 1); eq(registrations, 1)
    for _, i in ipairs({ 5, 6, 8, 9 }) do
        eq(displayed[i].disabled, true)
        eq(displayed[i].warning, TT.Locale:Get("SETTINGS_KNOWLEDGE_UNAVAILABLE"))
    end
    eq(displayed[5].value, 0); eq(displayed[6].value, false)
    jelSlider.setFunc(50); breticCheck.setFunc(false); eq(writes, 0)
    tick(); eq(refreshes, 1)
    fire("LAM-PanelOpened", panel); eq(registrations, 1)
end)

test("delayed character readiness refreshes values and enabled states without setters", function()
    assert(F:Initialize(store, 1)); tick(); eq(refreshes, 2)
    eq(displayed[5].value, 0); eq(displayed[8].value, 100)
    eq(displayed[6].value, true); eq(displayed[9].value, true)
    for _, i in ipairs({ 5, 6, 8, 9 }) do
        eq(displayed[i].disabled, false); eq(displayed[i].warning, nil)
    end
    eq(writes, 0); tick(); eq(refreshes, 2)
end)

test("per-language closures preserve cooldowns and isolate character knowledge", function()
    local jel, bretic = store.languages.jel, store.languages.bretic
    local exposure = { version = 1, records = { lesson = { expires = 9999 } } }
    jel.exposure = exposure
    jel.masteredVocabulary.C0001 = true
    local grammarId = assert(next(TT.CanonicalCatalog.GrammarRequirements))
    jel.masteredGrammar[grammarId] = true
    jelCheck.setFunc(false); jelSlider.setFunc(37)
    eq(jel.vocabularyXP, 3700); eq(jel.grammarXP, 3700)
    eq(next(jel.masteredVocabulary), nil); eq(next(jel.masteredGrammar), nil)
    eq(jel.exposure, exposure); eq(exposure.records.lesson.expires, 9999)
    eq(jel.progressEnabled, false); eq(bretic.progressEnabled, true)
    eq(breticSlider.getFunc(), 100); eq(jelSlider.getFunc(), 37)
    breticSlider.setFunc(62); breticCheck.setFunc(false); jelCheck.setFunc(true)
    eq(breticSlider.getFunc(), 62); eq(jelSlider.getFunc(), 37)
    eq(jelCheck.getFunc(), true); eq(breticCheck.getFunc(), false)
    local before = writes
    tick(); eq(writes, before)
    dropdown.setFunc("bretic"); eq(TT.characterPreferences.activeLanguage, "bretic")
    eq(TT.saved.activeLanguage, "jel")
    eq(jelSlider.getFunc(), 37); eq(breticSlider.getFunc(), 62)
end)

test("external language, progression and flag changes refresh only on visible changes", function()
    tick()
    local before, beforeWrites = refreshes, writes
    env.SLASH_COMMANDS["/lang"]("jel"); tick()
    eq(displayed[2].value, "jel"); eq(refreshes, before + 1)
    TT.Knowledge:Grant(store.languages.jel, 100, 100); tick()
    eq(displayed[5].value, 38); eq(refreshes, before + 2)
    TT.Knowledge:SetProgressEnabled(store.languages.jel, false); tick()
    eq(displayed[6].value, false); eq(refreshes, before + 3)
    tick(); eq(refreshes, before + 3); eq(writes, beforeWrites)
end)

test("future language states are disabled and never changed by controls or refresh", function()
    for _, field in ipairs({ "schemaVersion", "thresholdVersion" }) do
        local state = store.languages.jel
        local old = state[field]
        state[field] = 99
        local before = writes
        tick(); eq(displayed[5].disabled, true); eq(displayed[6].disabled, true)
        eq(displayed[8].disabled, false)
        jelSlider.setFunc(90); jelCheck.setFunc(true); tick()
        eq(writes, before); eq(state[field], 99)
        eq(state.vocabularyXP, 3800); eq(state.progressEnabled, false)
        state[field] = old; tick(); eq(displayed[5].disabled, false)
    end
end)

test("closing unregisters polling; reopening catches hidden changes", function()
    fire("LAM-PanelClosed", {}); assert(next(updates))
    fire("LAM-PanelClosed", panel); eq(next(updates), nil)
    local before = refreshes
    env.SLASH_COMMANDS["/lang"]("common")
    S:Refresh(true); tick(); eq(refreshes, before)
    env.SLASH_COMMANDS["/tt"]("settings")
    eq(displayed[2].value, "common"); eq(refreshes, before + 1)
    eq(panelCount, 1); eq(registrations, 2)
    fire("LAM-PanelClosed", panel); eq(next(updates), nil)
    env.SLASH_COMMANDS["/tt"]("help")
    assert(messages[#messages]:find("/tt settings", 1, true))
end)

print(string.format("Settings: %d tests passed", tests))
