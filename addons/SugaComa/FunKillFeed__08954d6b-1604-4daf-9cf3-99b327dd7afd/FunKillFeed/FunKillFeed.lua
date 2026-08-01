--------------------------------------------------------------
-- FunKillFeed.lua - v1.4.3 (PS5-safe, persistent, fixed)
--------------------------------------------------------------

FunKillFeed = {}
FunKillFeed.name     = "FunKillFeed"
FunKillFeed.version  = "1.4.3"
FunKillFeed.enabled  = false

--------------------------------------------------------
-- PS5 SavedVars Commit Helper
--------------------------------------------------------
local function ForceSave()
    -- triggers ESO console client to commit savedvars to disk
    SetCVar("Language.2", GetCVar("Language.2"))
end

--------------------------------------------------------
-- Shared [KF] chat output
--------------------------------------------------------
local function KF_Print(msg)
    if GroupKillFeed and type(GroupKillFeed.Print) == "function" then
        GroupKillFeed.Print(msg)
        return
    end

    local text = "[KF] " .. tostring(msg or "")
    if CHAT_SYSTEM and type(CHAT_SYSTEM.AddMessage) == "function" then
        CHAT_SYSTEM:AddMessage(text)
    else
        d(text)
    end
end

--------------------------------------------------------
-- Language loader
--------------------------------------------------------
FunKillFeedLang = FunKillFeedLang or {}

local function FKF_LoadLanguage()
    local lang = string.lower(GetCVar("Language.2") or "en")
    if not FunKillFeedLang[lang] then lang = "en" end

    FunKillFeed.text = FunKillFeedLang[lang] or { messages = {}, factionMessages = {} }
    FunKillFeed.messages = FunKillFeed.text.messages or {}
    FunKillFeed.factionMessages = FunKillFeed.text.factionMessages or {}
end

local function L(key)
    return (FunKillFeed.text and FunKillFeed.text[key]) or key
end

--------------------------------------------------------
-- Message picker
--------------------------------------------------------
local function GetFunMessage(killer, victim, location, killerAlliance)
    local defaults = FunKillFeed.messages or {}
    local customs  = FunKillFeed.customMessages or {}
    local faction  = FunKillFeed.factionMessages[killerAlliance] or {}

    local weighted = {}

    for _, msg in ipairs(customs)  do table.insert(weighted, msg); table.insert(weighted, msg) end
    for _, msg in ipairs(faction)  do table.insert(weighted, msg) end
    for _, msg in ipairs(defaults) do table.insert(weighted, msg) end
    if #weighted == 0 then weighted = defaults end

    local template = weighted[zo_random(1, #weighted)]
    return template
        :gsub("%%k", "|c00FF00"..killer.."|r")
        :gsub("%%v", "|cFF0000"..victim.."|r")
        :gsub("%%l", "|cFFFFFF"..location.."|r")
end

--------------------------------------------------------
-- GroupKillFeed extension API
--
-- Do NOT wrap GroupKillFeed.BuildMessage here. GroupKillFeed owns the
-- kill event and calls this function only while FunKillFeed is enabled.
--------------------------------------------------------
function FunKillFeed.BuildMessage(killerName, killerAlliance, victimName, victimAlliance, location)
    -- GroupKillFeed is the sole mode owner and only calls this extension while
    -- Fun Kill Feed is enabled. Avoid a second SavedVariables-backed gate here.
    return GetFunMessage(killerName, victimName, location, killerAlliance)
end

--------------------------------------------------------
-- Saved Variables (no structure changes)
--------------------------------------------------------
local SV_VERSION = 1
local SV = nil

local function SaveState()
    if SV then
        SV.enabled = FunKillFeed.enabled
        -- do NOT reassign the table, keep reference:
        -- SV.customMessages = FunKillFeed.customMessages   <-- REMOVED BAD LINE
    end
end

function FunKillFeed.SetEnabled(state)
    FunKillFeed.enabled = (state == true)
    SaveState()
    ForceSave()
end

local function InitializeSavedVars()
    local ok, sv = pcall(function()
        return ZO_SavedVars:NewAccountWide("FunKillFeed_SV", SV_VERSION, nil, {
            enabled = false,
            customMessages = {},
        })
    end)

    if ok and type(sv) == "table" then
        SV = sv
        FunKillFeed.enabled = (SV.enabled == true)

        -- Ensure table exists & reference it directly
        if type(SV.customMessages) ~= "table" then SV.customMessages = {} end
        FunKillFeed.customMessages = SV.customMessages
    else
        SV = { enabled = false, customMessages = {} }
        FunKillFeed.enabled = false
        FunKillFeed.customMessages = SV.customMessages
        KF_Print("FunKillFeed: SavedVariables failed, using defaults.")
    end
end

function FunKillFeed:ExposeSavedVars()
    _G.FKF = _G.FKF or {}
    _G.FKF.saved = SV
end

-- Slash commands removed; handled via settings menu

--------------------------------------------------------
-- Init
--------------------------------------------------------
local function OnAddonLoaded(_, addonName)
    if addonName ~= FunKillFeed.name then return end

    EVENT_MANAGER:UnregisterForEvent(FunKillFeed.name, EVENT_ADD_ON_LOADED)

    FKF_LoadLanguage()
    InitializeSavedVars()

    if GroupKillFeed and GroupKillFeed.funKillFeedEnabled ~= nil then
        FunKillFeed.enabled = (GroupKillFeed.funKillFeedEnabled == true)
        SaveState()
    end

    FunKillFeed:ExposeSavedVars()

    KF_Print("FunKillFeed v"..FunKillFeed.version.." loaded.")
end

EVENT_MANAGER:RegisterForEvent(FunKillFeed.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
