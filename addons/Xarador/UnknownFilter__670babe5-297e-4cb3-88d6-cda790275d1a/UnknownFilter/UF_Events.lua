-- UF_Events.lua
local UF = UnknownFilter

local MAX_RUNTIME_ATTEMPTS = 20
local RUNTIME_RETRY_MS = 250

function UF:ApplySettingsMigration()
    if not self.saved then
        return
    end

    local savedVersion = tonumber(self.saved.settingsVersion) or 0
    if savedVersion < 301 then
        -- Version 0.3.1 changes these runtime conveniences to opt-in. Reset them
        -- once so stale 0.3.0 SavedVariables cannot silently keep them enabled.
        self.saved.autoPage = false
        self.saved.debug = false
        self.saved.debugScan = false
        self.saved.echo = false
    end
    self.saved.settingsVersion = self.settingsVersion
end

function UF:InitializeRuntime()
    if not self._armed then
        return
    end

    local browseReady = self:InstallBrowseResultsHook()
    local results = self:GetBrowseResultsObject()
    local pagingReady = browseReady and self:InstallPagingHooks(results)
    local sceneReady = self:WireSceneKeybind()

    if browseReady and pagingReady and sceneReady then
        self._runtimeAttempts = 0
        return
    end

    self._runtimeAttempts = (self._runtimeAttempts or 0) + 1
    if self._runtimeAttempts < MAX_RUNTIME_ATTEMPTS then
        zo_callLater(function()
            UF:InitializeRuntime()
        end, RUNTIME_RETRY_MS)
    end
end

local function EnsureEvents()
    if UF._eventsRegistered then
        return
    end

    EVENT_MANAGER:RegisterForEvent(UF.name, EVENT_PLAYER_ACTIVATED, function()
        if UF._armed then
            UF:InitializeRuntime()
        end
    end)

    UF._eventsRegistered = true
end

local function ArmAddon()
    if UF._armed then
        return
    end

    UF.saved = UF.saved or ZO_SavedVars:NewAccountWide(
        "UnknownFilterSavedVars",
        1,
        nil,
        UF.defaults
    )
    UF:ApplySettingsMigration()
    UF._armed = true

    EnsureEvents()
    UF:InitializeRuntime()
end

local function OnAddonLoaded(_, addonName)
    if addonName ~= UF.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(UF.name, EVENT_ADD_ON_LOADED)
    UF.saved = ZO_SavedVars:NewAccountWide(
        "UnknownFilterSavedVars",
        1,
        nil,
        UF.defaults
    )
    ArmAddon()
end

EVENT_MANAGER:RegisterForEvent(UF.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

SLASH_COMMANDS["/uf"] = function(argument)
    local command, rest = tostring(argument or ""):match("^%s*(%S*)%s*(.-)%s*$")
    command = tostring(command or ""):lower()

    if command == "debug" then
        UF:Slash_debug(rest)
    elseif command == "auto" then
        UF:Slash_auto(rest)
    elseif command == "mode" then
        UF:Slash_mode()
    elseif command == "probe" then
        UF:Slash_probe()
    elseif command == "force" or command == "recheck" then
        UF:Slash_force()
    elseif command == "page" then
        UF:Slash_page(rest)
    elseif command == "skip" then
        UF:Slash_skip(rest)
    elseif command == "scan" then
        UF:Slash_scan(rest)
    elseif command == "dump" then
        UF:Slash_dump()
    elseif command == "echo" then
        UF:Slash_echo(rest)
    else
        UF:EchoOnce()
        UF:Say(UF:T("usage") .. ": /uf debug|auto|mode|probe|force|page|skip|scan|dump|echo")
    end
end

SLASH_COMMANDS["/ufmode"] = function()
    UF:Slash_mode()
end
SLASH_COMMANDS["/ufdebug"] = function(argument)
    UF:Slash_debug(argument)
end
SLASH_COMMANDS["/ufscan"] = function(argument)
    UF:Slash_scan(argument)
end
SLASH_COMMANDS["/ufdump"] = function()
    UF:Slash_dump()
end
SLASH_COMMANDS["/ufprobe"] = function()
    UF:Slash_probe()
end
SLASH_COMMANDS["/ufforce"] = function()
    UF:Slash_force()
end
SLASH_COMMANDS["/ufauto"] = function(argument)
    UF:Slash_auto(argument)
end
SLASH_COMMANDS["/ufskip"] = function(argument)
    UF:Slash_skip(argument)
end
SLASH_COMMANDS["/ufpage"] = function(argument)
    UF:Slash_page(argument)
end
SLASH_COMMANDS["/ufecho"] = function(argument)
    UF:Slash_echo(argument)
end
SLASH_COMMANDS["/uflimit"] = function(argument)
    UF:Slash_limit(argument)
end
SLASH_COMMANDS["/ufrecheck"] = function()
    UF:Slash_force()
end
