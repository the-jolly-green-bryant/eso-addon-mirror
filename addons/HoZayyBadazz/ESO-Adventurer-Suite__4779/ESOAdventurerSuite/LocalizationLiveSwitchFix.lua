-- ESO Adventurer Suite
-- v0.29.553 - live i18n language switching fix.
-- Allows already-localized controls to switch directly between any supported
-- language and immediately refreshes visible Suite UI without /reloadui.

local EPC = ESOProgressionCoach
if not EPC or not EPC.I18N then return end
local I = EPC.I18N

local reverseExact = {}
local english = I.keys and I.keys.en or {}

-- Build a translation -> canonical English lookup for every supported locale.
-- This lets a control currently showing German/Russian/etc. switch directly to
-- French/Japanese/etc. instead of requiring the source text to still be English.
if type(I.keys) == "table" and type(english) == "table" then
    for _, locale in pairs(I.keys) do
        if type(locale) == "table" then
            for key, translated in pairs(locale) do
                local source = english[key]
                if type(source) == "string" and type(translated) == "string" then
                    reverseExact[translated] = source
                end
            end
        end
    end
end

local function trim(value)
    value = tostring(value or "")
    value = value:gsub("^%s+", "")
    value = value:gsub("%s+$", "")
    return value
end

local function canonicalEnglish(text)
    if type(text) ~= "string" or text == "" then return text end
    if reverseExact[text] then return reverseExact[text] end

    -- Preserve category counters such as "Waffen (12)" / "Оружие (12)".
    local base, count = text:match("^(.-)%s*(%(%d+%))$")
    if base then
        local canonical = reverseExact[trim(base)] or trim(base)
        return canonical .. " " .. count
    end

    -- Preserve dynamic values after translated fixed labels.
    local left, right = text:match("^([^:]+):%s*(.+)$")
    if left and right then
        local canonical = reverseExact[trim(left)] or trim(left)
        return canonical .. ": " .. right
    end

    -- Handle compact A / B labels after either side has already been localized.
    local a, b = text:match("^([^/]+)/([^/]+)$")
    if a and b then
        a, b = trim(a), trim(b)
        return (reverseExact[a] or a) .. " / " .. (reverseExact[b] or b)
    end

    return text
end

local function translateCanonical(text, lang)
    if type(text) ~= "string" or text == "" or lang == "en" then return text end
    local raw = I.raw and I.raw[lang]
    if type(raw) ~= "table" then return text end

    if raw[text] then return raw[text] end

    local base, count = text:match("^(.-)%s*(%(%d+%))$")
    if base and raw[trim(base)] then return raw[trim(base)] .. " " .. count end

    local left, right = text:match("^([^:]+):%s*(.+)$")
    if left and right and raw[trim(left)] then return raw[trim(left)] .. ": " .. right end

    local a, b = text:match("^([^/]+)/([^/]+)$")
    if a and b then
        a, b = trim(a), trim(b)
        if raw[a] or raw[b] then return (raw[a] or a) .. " / " .. (raw[b] or b) end
    end

    return text
end

-- Replace the one-direction localization behavior with language-agnostic
-- relocalization. English remains the canonical source language.
function I:Localize(text)
    if type(text) ~= "string" or text == "" then return text end
    local lang = self.language or self:GetLanguage()
    self.language = lang
    return translateCanonical(canonicalEnglish(text), lang)
end

local function localizeVisibleControls()
    if type(I.LocalizeTopLevelSuiteControls) == "function" then
        pcall(I.LocalizeTopLevelSuiteControls, I)
    end
end

local function refreshLiveSurfaces()
    localizeVisibleControls()

    local M = EPC.ModernAppUI
    if type(M) == "table" then
        if type(M.RefreshCurrent) == "function" then pcall(M.RefreshCurrent, M) end
        if M.window and type(I.LocalizeControlTree) == "function" then
            pcall(I.LocalizeControlTree, I, M.window, 0)
        end
    end

    local B = EPC.BankGridUnifiedV2
    if type(B) == "table" and type(B.Refresh) == "function" then pcall(B.Refresh, B) end

    local G = EPC.CharacterGearScreen
    if type(G) == "table" and type(G.RequestRefresh) == "function" then
        pcall(G.RequestRefresh, G, 0)
    end

    local S = EPC.Settings
    if type(S) == "table" and S.panelObject and type(S.panelObject.RefreshPanel) == "function" then
        pcall(S.panelObject.RefreshPanel, S.panelObject)
    end

    if type(EPC.RefreshGameplayOverlays) == "function" then
        pcall(EPC.RefreshGameplayOverlays, EPC)
    end
end

local baseSetLanguage = I.SetLanguage
function I:SetLanguage(code)
    local result
    if type(baseSetLanguage) == "function" then
        result = baseSetLanguage(self, code)
    else
        code = tostring(code or "AUTO")
        if EPC.saved then EPC.saved.i18nLanguage029552 = code end
        self.language = self:GetLanguage()
        result = self.language
    end

    refreshLiveSurfaces()

    -- Some LAM/scene controls update one frame after the dropdown callback.
    -- Perform two one-shot sweeps; there is no persistent polling loop.
    if EVENT_MANAGER then
        local key = (EPC.name or "ESOAdventurerSuite") .. "_I18NLiveSwitch029553"
        EVENT_MANAGER:UnregisterForUpdate(key)
        local pass = 0
        EVENT_MANAGER:RegisterForUpdate(key, 80, function()
            pass = pass + 1
            refreshLiveSurfaces()
            if pass >= 2 then EVENT_MANAGER:UnregisterForUpdate(key) end
        end)
    end

    return result
end

-- Also make control-tree sweeps reversible when the currently displayed label
-- was produced by a previous language selection.
local baseTree = I.LocalizeControlTree
function I:LocalizeControlTree(control, depth)
    if not control then return end
    depth = tonumber(depth) or 0
    if depth > 18 then return end

    if type(control.GetText) == "function" and type(control.SetText) == "function" then
        local ok, text = pcall(control.GetText, control)
        if ok and type(text) == "string" and text ~= "" then
            local localized = self:Localize(text)
            if localized ~= text then pcall(control.SetText, control, localized) end
        end
    end

    if type(control.GetNumChildren) == "function" and type(control.GetChild) == "function" then
        local ok, count = pcall(control.GetNumChildren, control)
        count = ok and tonumber(count) or 0
        for index = 1, count do
            local okChild, child = pcall(control.GetChild, control, index)
            if okChild and child then self:LocalizeControlTree(child, depth + 1) end
        end
    elseif type(baseTree) == "function" then
        pcall(baseTree, self, control, depth)
    end
end

I.liveSwitch029553 = true
