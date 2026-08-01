--------------------------------------------------------------
-- FunKillFeed.lua - v1.3.5 (PS5-safe, persistent, fixed)
--------------------------------------------------------------

FunKillFeed = {}
FunKillFeed.name     = "FunKillFeed"
FunKillFeed.version  = "1.3.5"
FunKillFeed.enabled  = false

--------------------------------------------------------
-- PS5 SavedVars Commit Helper
--------------------------------------------------------
local function ForceSave()
    -- triggers ESO console client to commit savedvars to disk
    SetCVar("Language.2", GetCVar("Language.2"))
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
-- GroupKillFeed override
--------------------------------------------------------
local function OverrideKillFeed()
    if not GroupKillFeed then return end
    if not GroupKillFeed._OriginalBuildMessage then
        GroupKillFeed._OriginalBuildMessage = GroupKillFeed.BuildMessage
    end

    GroupKillFeed.BuildMessage = function(killerName, killerAlliance, victimName, victimAlliance, location)
        if FunKillFeed.enabled then
            return GetFunMessage(killerName, victimName, location, killerAlliance)
        else
            return GroupKillFeed._OriginalBuildMessage(killerName, killerAlliance, victimName, victimAlliance, location)
        end
    end
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
        d("FunKillFeed: SavedVariables failed, using defaults.")
    end
end

function FunKillFeed:ExposeSavedVars()
    _G.FKF = _G.FKF or {}
    _G.FKF.saved = SV
end

--------------------------------------------------------
-- Slash commands
--------------------------------------------------------
SLASH_COMMANDS["/gkffunon"] = function()
    FunKillFeed.enabled = true
    SaveState()
    ForceSave()
    d("|c00FF00Fun Kill Feed ENABLED|r")
end

SLASH_COMMANDS["/gkffunoff"] = function()
    FunKillFeed.enabled = false
    SaveState()
    ForceSave()
    d("|cFF0000Fun Kill Feed DISABLED|r")
end

SLASH_COMMANDS["/gkfstatus"] = function()
    d("FunKillFeed Status: " .. (FunKillFeed.enabled and "|c00FF00ENABLED|r" or "|cFF0000DISABLED|r"))
end

--------------------------------------------------------
-- Custom message menu
--------------------------------------------------------
SLASH_COMMANDS["/gkffunmenu"] = function(arg)
    local sub, rest = string.match(arg or "", "^(%S*)%s*(.*)$")
    local function msg(t) d("|cFFD700[FKF]|r "..t) end

    if sub == "list" then
        if #SV.customMessages == 0 then msg("No custom messages saved.") return end
        msg("Custom messages:")
        for i, m in ipairs(SV.customMessages) do d(i..") "..m) end
        return
    end

    if sub == "add" and rest ~= "" then
        table.insert(SV.customMessages, rest)
        SaveState()
        ForceSave()
        msg("Added message #"..#SV.customMessages)
        return
    end

    if sub == "del" then
        local n = tonumber(rest)
        if not n or not SV.customMessages[n] then msg("Invalid index.") return end
        table.remove(SV.customMessages, n)
        SaveState()
        ForceSave()
        msg("Deleted message #"..n)
        return
    end

    msg("Commands:")
    d("  /gkffunmenu list")
    d("  /gkffunmenu add <text>")
    d("  /gkffunmenu del <#>")
end

--------------------------------------------------------
-- Init
--------------------------------------------------------
local function OnAddonLoaded(_, addonName)
    if addonName ~= FunKillFeed.name then return end

    EVENT_MANAGER:UnregisterForEvent(FunKillFeed.name, EVENT_ADD_ON_LOADED)

    FKF_LoadLanguage()
    InitializeSavedVars()
    FunKillFeed:ExposeSavedVars()
    OverrideKillFeed()

    d("FunKillFeed v"..FunKillFeed.version.." loaded.")
end

EVENT_MANAGER:RegisterForEvent(FunKillFeed.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)
