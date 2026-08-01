-- GoA Tamriel Trade Centre UA Patch
-- Compatibility shim for ESO clients using the unofficial "ua" language code.
-- No TTC version number is hard-coded: the patch only waits for the public
-- TamrielTradeCentre table and wraps its Init method when available.

local PATCH_NAME = "GoA_TamrielTradeCentreUAPatch"
local TTC_NAME = "TamrielTradeCentre"
local RETRY_NAME = PATCH_NAME .. "_Retry"
local DISMISS_NAME = PATCH_NAME .. "_DismissTTCError"

-- TTC shows its unsupported-language message before this compatibility patch
-- gets a chance to re-run TTC under the English compatibility context.
-- Once TTC has initialized successfully, close that stale startup dialog.
local function DismissStaleTTCStartupDialog()
    EVENT_MANAGER:UnregisterForUpdate(DISMISS_NAME)
    EVENT_MANAGER:RegisterForUpdate(DISMISS_NAME, 150, function()
        EVENT_MANAGER:UnregisterForUpdate(DISMISS_NAME)
        if type(ZO_Dialogs_ReleaseAllDialogs) == "function" then
            ZO_Dialogs_ReleaseAllDialogs()
        end
    end)
end

local function WithEnglishLanguage(func, self, ...)
    local originalGetCVar = GetCVar
    GetCVar = function(name)
        if name == "language.2" then
            return "en"
        end
        return originalGetCVar(name)
    end

    local results = { pcall(func, self, ...) }
    GetCVar = originalGetCVar

    local ok = table.remove(results, 1)
    if not ok then
        d("|cFF3333GoA TTC UA Patch:|r " .. tostring(results[1]))
        return nil
    end
    return unpack(results)
end

local function PatchTTC()
    local ttc = _G[TTC_NAME]
    if type(ttc) ~= "table" or type(ttc.Init) ~= "function" then
        return false
    end

    if not ttc.__GoA_UA_OriginalInit then
        ttc.__GoA_UA_OriginalInit = ttc.Init
        ttc.Init = function(self, ...)
            return WithEnglishLanguage(self.__GoA_UA_OriginalInit, self, ...)
        end
    end

    -- TTC may already have attempted to initialize before this patch loaded.
    -- Retry only when its main Data table is still absent.
    if ttc.Data == nil then
        ttc:Init()
    end

    -- If TTC is now functional, the old language error is only a stale dialog.
    if ttc.Data ~= nil then
        DismissStaleTTCStartupDialog()
    end
    return true
end

local function StopRetry()
    EVENT_MANAGER:UnregisterForUpdate(RETRY_NAME)
end

local function StartRetry()
    EVENT_MANAGER:RegisterForUpdate(RETRY_NAME, 250, function()
        if PatchTTC() then
            StopRetry()
        end
    end)
end

EVENT_MANAGER:RegisterForEvent(PATCH_NAME, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName == PATCH_NAME then
        if not PatchTTC() then
            StartRetry()
        end
    elseif addonName == TTC_NAME then
        PatchTTC()
    end
end)

EVENT_MANAGER:RegisterForEvent(PATCH_NAME .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED, function()
    EVENT_MANAGER:UnregisterForEvent(PATCH_NAME .. "_PlayerActivated", EVENT_PLAYER_ACTIVATED)
    PatchTTC()
end)
