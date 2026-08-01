-- Core/Nvk3UT_Core.lua
-- Central addon root. Owns global table, SafeCall, module registry, SavedVariables bootstrap, lifecycle entry points.

local ADDON_NAME        = ADDON_NAME        or "Nvk3UT"
local ADDON_VERSION     = "0.17.5"
local ADDON_VERSION_INT = 1705
Nvk3UT = Nvk3UT or {}
local Addon = Nvk3UT

Addon.addonName    = ADDON_NAME
Addon.addonVersion = ADDON_VERSION
Addon.addonVersionInt = Addon.addonVersionInt or ADDON_VERSION_INT
Addon.versionString = Addon.versionString or Addon.addonVersion
Addon.SV           = Addon.SV or nil
Addon.sv           = Addon.sv or Addon.SV -- legacy alias expected by existing modules
Addon.modules      = Addon.modules or {}
Addon.debugEnabled = Addon.debugEnabled or false
Addon._rebuild_lock = Addon._rebuild_lock or false
Addon.initialized  = Addon.initialized or false
Addon.playerActivated = Addon.playerActivated or false

if Nvk3UT_Utils and type(Nvk3UT_Utils.AttachToRoot) == "function" then
    Nvk3UT_Utils.AttachToRoot(Addon)
end

if Nvk3UT_SelfTest and type(Nvk3UT_SelfTest.AttachToRoot) == "function" then
    Nvk3UT_SelfTest.AttachToRoot(Addon)
end

local function formatMessage(prefix, fmt, ...)
    if not fmt then
        return prefix
    end

    if select('#', ...) == 0 then
        return string.format("%s%s", prefix, tostring(fmt))
    end

    local formatString = prefix .. tostring(fmt)
    local ok, message = pcall(string.format, formatString, ...)
    if ok then
        return message
    end

    return string.format("%s%s", prefix, tostring(fmt))
end

---Debug helper routed through Diagnostics when available.
function Addon.Debug(fmt, ...)
    if Addon.IsDebugEnabled and not Addon:IsDebugEnabled() then
        return
    end

    if Nvk3UT_Diagnostics and Nvk3UT_Diagnostics.Debug then
        return Nvk3UT_Diagnostics.Debug(fmt, ...)
    end

    if d then
        d(formatMessage("[Nvk3UT DEBUG] ", fmt, ...))
    end
end

---Error helper routed through Diagnostics when available.
function Addon.Error(fmt, ...)
    if Nvk3UT_Diagnostics and Nvk3UT_Diagnostics.Error then
        return Nvk3UT_Diagnostics.Error(fmt, ...)
    end

    if d then
        d(formatMessage("|cFF0000[Nvk3UT ERROR]|r ", fmt, ...))
    end
end

local function _SafeCall(fn, ...)
    if type(fn) ~= "function" then
        return nil
    end

    local function _errHandler(err)
        if Nvk3UT and Nvk3UT.Error then
            Nvk3UT.Error("SafeCall error: %s\n%s", tostring(err), debug.traceback())
        end
        return err
    end

    local params = { ... }
    local ok, results = xpcall(function()
        return { fn(unpack(params)) }
    end, _errHandler)

    if ok and type(results) == "table" then
        return unpack(results)
    end

    return nil
end

Addon.SafeCall = _SafeCall

---Registers a named module for lookup.
function Addon.RegisterModule(name, moduleTable)
    if type(name) ~= "string" or name == "" then
        return nil
    end

    Addon.modules[name] = moduleTable or true
    return Addon.modules[name]
end

---Retrieves a module table by name.
function Addon.GetModule(name)
    return Addon.modules[name]
end

function Addon:GetName()
    return self.addonName
end

function Addon:GetVersion()
    return self.addonVersion
end

function Addon:IsDebugEnabled()
    return self.debugEnabled == true
end

function Addon:SetDebugEnabled(enabled)
    self.debugEnabled = enabled and true or false
end

---Initialises SavedVariables and exposes them on the addon table.
function Addon:InitSavedVariables()
    local stateInit = Nvk3UT_StateInit
    if stateInit and stateInit.BootstrapSavedVariables then
        local sv = stateInit.BootstrapSavedVariables(self)
        if type(sv) == "table" then
            self.SV = sv
        end
    end

    local sv = self.SV
    if type(sv) == "table" then
        self.sv = sv -- legacy alias consumed by existing modules
        if type(self.SetDebugEnabled) == "function" then
            self:SetDebugEnabled(sv.debug)
        end

        local cache = Nvk3UT and Nvk3UT.AchievementCache
        if cache and type(cache.Init) == "function" then
            _SafeCall(cache.Init, sv)
        end
    end

    return self.SV
end

function Addon:UIUpdateStatus()
    if self.UI and self.UI.UpdateStatus then
        _SafeCall(function()
            self.UI.UpdateStatus()
        end)
    end
end

---Handles achievement completion side-effects.
-- TODO Events: wire achievement callbacks via Events/ layer.
function Addon:HandleAchievementChanged(achievementId)
    local id = tonumber(achievementId)
    if not id then
        return
    end

    local achievements = self.Achievements
    if not (achievements and achievements.IsComplete and achievements.IsComplete(id)) then
        return
    end

    local utils = self.Utils
    local normalized = utils and utils.NormalizeAchievementId and utils.NormalizeAchievementId(id) or id

    local favoritesData = self.FavoritesData
    local favorites = self.Favorites
    if favoritesData and favoritesData.IsFavorited and favorites and favorites.Remove then
        local candidates = { id }
        if normalized and normalized ~= id then
            candidates[#candidates + 1] = normalized
        end
        for _, candidateId in ipairs(candidates) do
            if favoritesData.IsFavorited(candidateId, "account") or favoritesData.IsFavorited(candidateId, "character") then
                favorites.Remove(candidateId)
            end
        end
    end

    local recentData = Nvk3UT and Nvk3UT.RecentData
    if recentData and recentData.Contains then
        local candidates = { id }
        if normalized and normalized ~= id then
            candidates[#candidates + 1] = normalized
        end

        for index = 1, #candidates do
            local candidateId = candidates[index]
            local ok, isTracked = pcall(recentData.Contains, candidateId)
            if ok and isTracked then
                local recent = self.Recent
                if recent and recent.CleanupCompleted then
                    _SafeCall(recent.CleanupCompleted)
                end
                break
            end
        end
    end

    self:UIUpdateStatus()
end

local function EnableCompletedCategory()
    if Nvk3UT and Nvk3UT.EnableCompletedCategory then
        _SafeCall(Nvk3UT.EnableCompletedCategory)
    end
end

local function EnableFavoritesCategory()
    if Nvk3UT and Nvk3UT.EnableFavorites then
        _SafeCall(Nvk3UT.EnableFavorites)
    end
end

local function EnableRecentCategory()
    if Nvk3UT and Nvk3UT.EnableRecentCategory then
        _SafeCall(Nvk3UT.EnableRecentCategory)
    end
end

local function EnableTodoCategory()
    if Nvk3UT and Nvk3UT.EnableTodoCategory then
        _SafeCall(Nvk3UT.EnableTodoCategory)
    end
end

local function logIntegrationsEnabled()
    local utils = Addon.Utils
    if utils and utils.d then
        utils.d("[Nvk3UT][Core][Integrations] enabled", string.format("data={favorites:%s, recent:%s, completed:%s}", tostring(Nvk3UT and Nvk3UT.EnableFavorites and true or false), tostring(Nvk3UT and Nvk3UT.EnableRecentCategory and true or false), tostring(Nvk3UT and Nvk3UT.EnableCompletedCategory and true or false)))
    end
end

function Addon:EnableIntegrations()
    if self.__integrated then
        return
    end

    local function TryEnable(attempt)
        attempt = attempt or 1

        if ACHIEVEMENTS then
            if not Addon.__integrated then
                Addon.__integrated = true
                logIntegrationsEnabled()
                EnableFavoritesCategory()
                EnableRecentCategory()
                EnableTodoCategory()
            end
            return
        end

        if attempt < 15 then
            zo_callLater(function()
                TryEnable(attempt + 1)
            end, 500)
        end
    end

    TryEnable(1)
end

---Addon load lifecycle entry point invoked by Events layer.
function Addon:OnAddonLoaded(actualAddonName)
    if actualAddonName ~= self.addonName then
        return
    end

    -- SavedVariables bootstrap lives in Core/Nvk3UT_StateInit.lua.
    self:InitSavedVariables()

    if Nvk3UT_Diagnostics and Nvk3UT_Diagnostics.SyncFromSavedVariables and self.SV then
        -- Ensure diagnostics pick up runtime toggles even if they loaded after StateInit.
        Nvk3UT_Diagnostics.SyncFromSavedVariables(self.SV)
    end

    self._rebuild_lock = false

    self.Debug("Nvk3UT loaded v%s", tostring(self.addonVersion))

    _SafeCall(function()
        local questModel = Addon.QuestModel
        if questModel and questModel.OnAddonLoaded then
            questModel.OnAddonLoaded(nil, actualAddonName)
        end
    end)

    _SafeCall(function()
        -- TODO Model: move favorites saved-variable init into Model layer.
        if Addon.FavoritesData and Addon.FavoritesData.InitSavedVars then
            Addon.FavoritesData.InitSavedVars()
        end
    end)

    _SafeCall(function()
        -- TODO Model: move recent saved-variable init into Model layer.
        if Addon.RecentData and Addon.RecentData.InitSavedVars then
            Addon.RecentData.InitSavedVars()
        end
    end)

    _SafeCall(function()
        -- TODO Events: migrate event wiring into Events/ handlers.
        if Addon.RecentData and Addon.RecentData.RegisterEvents then
            Addon.RecentData.RegisterEvents()
        end
    end)

    _SafeCall(function()
        -- TODO UI: relocate chat context bootstrap into Events layer when it exists.
        local context = Addon.ChatAchievementContext or (Nvk3UT and Nvk3UT.ChatAchievementContext)
        if context and context.Init then
            context.Init()
        end
    end)

    -- TODO UI: move status refresh trigger into HostLayout/UI layer.
    self:UIUpdateStatus()

    if Nvk3UT_SelfTest and Nvk3UT_SelfTest.RunCoreSanityCheck then
        _SafeCall(Nvk3UT_SelfTest.RunCoreSanityCheck)
    end

    EnableCompletedCategory()

    self.initialized = true
end

---PLAYER_ACTIVATED lifecycle entry point invoked by Events layer.
function Addon:OnPlayerActivated()
    if self.playerActivated then
        return
    end
    self.playerActivated = true

    -- TODO Controller: move integration gating into Controller layer once available.
    self:EnableIntegrations()

    _SafeCall(function()
        -- TODO UI: move tooltip bootstrapping into UI helpers.
        if Addon.Tooltips and Addon.Tooltips.Init then
            Addon.Tooltips.Init()
        end
    end)

    _SafeCall(function()
        -- TODO HostLayout: move tracker host init into HostLayout module.
        if Addon.TrackerHost and Addon.TrackerHost.Init then
            Addon.TrackerHost.Init()
        end
    end)

    _SafeCall(function()
        if Nvk3UT and Nvk3UT.QuestTracker and type(Nvk3UT.QuestTracker.ApplyBaseQuestTrackerVisibility) == "function" then
            pcall(Nvk3UT.QuestTracker.ApplyBaseQuestTrackerVisibility)
        elseif type(Nvk3UT) == "table" and type(Nvk3UT.ApplyBaseQuestTrackerVisibility) == "function" then
            pcall(Nvk3UT.ApplyBaseQuestTrackerVisibility)
        end
    end)

    _SafeCall(function()
        local questModel = Addon.QuestModel
        if questModel and questModel.OnPlayerActivated then
            questModel.OnPlayerActivated()
        end
    end)

    _SafeCall(function()
        local questTracker = Addon.QuestTracker
        if questTracker and questTracker.OnPlayerActivated then
            questTracker.OnPlayerActivated()
        end
    end)

    local cache = Nvk3UT and Nvk3UT.AchievementCache
    if cache and cache.SchedulePrebuild then
        _SafeCall(cache.SchedulePrebuild)
    end

    -- TODO UI: move status refresh trigger into HostLayout/UI layer.
    self:UIUpdateStatus()
end

-- Legacy compatibility wrappers ------------------------------------------------
function Addon.OnAddOnLoadedEvent(...)
    return Addon:OnAddonLoaded(...)
end

function Addon.OnPlayerActivatedEvent(...)
    return Addon:OnPlayerActivated(...)
end

-- Diagnostics slash command ----------------------------------------------------
SLASH_COMMANDS = SLASH_COMMANDS or {}
SLASH_COMMANDS["/nvk3test"] = function()
    if Nvk3UT_Diagnostics and Nvk3UT_Diagnostics.SelfTest then
        _SafeCall(Nvk3UT_Diagnostics.SelfTest)
    end
    if Nvk3UT_Diagnostics and Nvk3UT_Diagnostics.SystemTest then
        _SafeCall(Nvk3UT_Diagnostics.SystemTest)
    end
end

SLASH_COMMANDS["/nvkendeavor"] = function()
    _SafeCall(function()
        if type(Addon) ~= "table" then
            return
        end

        local sv = Addon.sv
        local stateModule = Addon.EndeavorState
        if type(stateModule) == "table" and type(stateModule._sv) ~= "table" and type(stateModule.Init) == "function" and type(sv) == "table" then
            stateModule:Init(sv)
        end

        local modelModule = Addon.EndeavorModel
        local dailyTotal = 0
        local weeklyTotal = 0
        local seals = 0
        if type(modelModule) == "table" then
            if type(modelModule.state) ~= "table" and type(modelModule.Init) == "function" and type(stateModule) == "table" then
                modelModule:Init(stateModule)
            end

            local refresh = modelModule.RefreshFromGame or modelModule.Refresh
            if type(refresh) == "function" then
                refresh(modelModule)
            end

            local getCounts = modelModule.GetCountsForDebug
            if type(getCounts) == "function" then
                local ok, counts = pcall(getCounts, modelModule)
                if ok and type(counts) == "table" then
                    dailyTotal = tonumber(counts.dailyTotal) or dailyTotal
                    weeklyTotal = tonumber(counts.weeklyTotal) or weeklyTotal
                    seals = tonumber(counts.seals) or seals
                end
            end
        end

        local controller = Addon.EndeavorTrackerController
        if type(controller) == "table" then
            local markDirty = controller.MarkDirty or controller.RequestRefresh
            if type(markDirty) == "function" then
                markDirty(controller)
            end
        end

        local runtime = Addon.TrackerRuntime
        if type(runtime) == "table" then
            local queueDirty = runtime.QueueDirty or runtime.MarkDirty or runtime.RequestRefresh
            if type(queueDirty) == "function" then
                queueDirty(runtime, "endeavor")
            end
        end

        local message = string.format("[Slash] endeavor refresh queued: daily=%d weekly=%d seals=%d", dailyTotal, weeklyTotal, seals)
        if type(d) == "function" then
            d(message)
        elseif type(print) == "function" then
            print(message)
        end
    end)
end

-- TODO(EVENTS_001_CREATE_EventHandlerBase_lua):
-- Remove this temporary bootstrap block from Core/Nvk3UT_Core.lua.
-- After the Events layer exists, EVENT_MANAGER:RegisterForEvent MUST live
-- exclusively in Events/Nvk3UT_EventHandlerBase.lua, not in Core.
--------------------------------------------------------------------------------
-- TEMPORARY BOOTSTRAP (will be moved into Events/Nvk3UT_EventHandlerBase.lua)
-- This block ONLY exists until the Events layer is introduced.
-- TODO: Remove this entire block once Events/Nvk3UT_EventHandlerBase.lua is added.
--------------------------------------------------------------------------------
do
    -- Forward EVENT_ADD_ON_LOADED into our lifecycle API
    local function _OnAddonLoaded(_, loadedAddonName)
        if loadedAddonName ~= ADDON_NAME then
            return
        end

        if EVENT_MANAGER then
            EVENT_MANAGER:UnregisterForEvent("Nvk3UT_Init_AddOnLoaded", EVENT_ADD_ON_LOADED)
        end

        if Nvk3UT and Nvk3UT.OnAddonLoaded then
            Nvk3UT:OnAddonLoaded(loadedAddonName)
        end

        if EVENT_MANAGER then
            EVENT_MANAGER:RegisterForEvent(
                "Nvk3UT_Init_PlayerActivated",
                EVENT_PLAYER_ACTIVATED,
                function()
                    if Nvk3UT and Nvk3UT.OnPlayerActivated then
                        Nvk3UT:OnPlayerActivated()
                    end

                    EVENT_MANAGER:UnregisterForEvent("Nvk3UT_Init_PlayerActivated", EVENT_PLAYER_ACTIVATED)
                end
            )
        end
    end

    EVENT_MANAGER:RegisterForEvent(
        "Nvk3UT_Init_AddOnLoaded",
        EVENT_ADD_ON_LOADED,
        _OnAddonLoaded
    )
end
--------------------------------------------------------------------------------
-- END TEMPORARY BOOTSTRAP
--------------------------------------------------------------------------------

return Addon
