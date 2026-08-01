local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local AchievementModel = {}
AchievementModel.__index = AchievementModel

local MODEL_NAME = addonName .. "AchievementModel"
local EVENT_NAMESPACE = MODEL_NAME .. "_Event"
local REBUILD_IDENTIFIER = MODEL_NAME .. "_Rebuild"

local MIN_DEBOUNCE_MS = 50
local MAX_DEBOUNCE_MS = 120
local DEFAULT_DEBOUNCE_MS = 80

local function clampDebounce(value)
    if value < MIN_DEBOUNCE_MS then
        return MIN_DEBOUNCE_MS
    elseif value > MAX_DEBOUNCE_MS then
        return MAX_DEBOUNCE_MS
    end
    return value
end

local function getTimestampMs()
    if GetFrameTimeMilliseconds then
        return GetFrameTimeMilliseconds()
    end

    if GetGameTimeMilliseconds then
        return GetGameTimeMilliseconds()
    end

    if GetFrameTimeSeconds then
        return math.floor(GetFrameTimeSeconds() * 1000 + 0.5)
    end

    return nil
end

local function resolveListModule()
    return Nvk3UT and Nvk3UT.AchievementList
end

local function resolveStateModule()
    return Nvk3UT and Nvk3UT.AchievementState
end

local function isDebugEnabled()
    local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        return utils.IsDebugEnabled()
    end
    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        return diagnostics:IsDebugEnabled()
    end
    local root = Nvk3UT
    if root and type(root.IsDebugEnabled) == "function" then
        return root:IsDebugEnabled()
    end
    return false
end

local function logDebug(self, fmt, ...)
    if not isDebugEnabled() then
        return
    end

    local message = tostring(fmt)
    if select("#", ...) > 0 then
        local ok, formatted = pcall(string.format, tostring(fmt), ...)
        if ok then
            message = formatted
        else
            local parts = { tostring(fmt) }
            for index = 1, select("#", ...) do
                parts[#parts + 1] = tostring(select(index, ...))
            end
            message = table.concat(parts, " ")
        end
    end

    local prefix = string.format("[%s]", MODEL_NAME)
    local Utils = Nvk3UT and Nvk3UT.Utils
    if Utils and Utils.d then
        Utils.d("%s %s", prefix, message)
        return
    end

    if d then
        d(string.format("%s %s", prefix, message))
    elseif print then
        print(prefix, message)
    end
end

local function notifySubscribers(self)
    if not self.subscribers then
        return
    end

    for callback in pairs(self.subscribers) do
        local ok, err = pcall(callback, self.currentSnapshot)
        if not ok then
            logDebug(self, "Subscriber callback failed", tostring(err))
        end
    end
end

local function appendSignaturePart(parts, value)
    parts[#parts + 1] = tostring(value)
end

local function buildEntrySignature(entry)
    local parts = {}
    appendSignaturePart(parts, entry.id or "nil")
    appendSignaturePart(parts, entry.name or "")
    appendSignaturePart(parts, entry.progress and entry.progress.current or "nil")
    appendSignaturePart(parts, entry.progress and entry.progress.max or "nil")
    appendSignaturePart(parts, entry.flags and entry.flags.isComplete and 1 or 0)
    appendSignaturePart(parts, entry.sortOrder or 0)

    local objectives = entry.objectives or {}
    for index = 1, #objectives do
        local objective = objectives[index]
        appendSignaturePart(parts, objective.description or "")
        appendSignaturePart(parts, objective.current or "nil")
        appendSignaturePart(parts, objective.max or "nil")
        appendSignaturePart(parts, objective.isComplete and 1 or 0)
    end

    return table.concat(parts, "|")
end

local function applyStateHints(entry)
    if not entry then
        return
    end

    local state = resolveStateModule()
    if not state then
        return
    end

    if state.IsFavorited and entry.id then
        local ok, result = pcall(state.IsFavorited, entry.id)
        if ok and result ~= nil then
            entry.flags = entry.flags or {}
            entry.flags.isFavorite = result and true or false
        end
    end
end

local function fetchRawData(self, reason)
    local List = resolveListModule()
    if not List then
        return {}
    end

    local raw

    if type(List.RefreshFromGame) == "function" then
        local ok, result = pcall(List.RefreshFromGame, List, reason)
        if ok then
            raw = result
        else
            logDebug(self, "AchievementList.RefreshFromGame failed", tostring(result))
        end
    end

    if not raw and type(List.GetRaw) == "function" then
        local ok, result = pcall(List.GetRaw, List)
        if ok then
            raw = result
        else
            logDebug(self, "AchievementList.GetRaw failed", tostring(result))
        end
    end

    return raw or {}
end

local function buildSnapshot(self, reason)
    local raw = fetchRawData(self, reason)
    local entries = raw.achievements or {}
    local total = raw.total
    if type(total) ~= "number" then
        total = #entries
    end

    local totalComplete = raw.totalComplete or 0
    local totalIncomplete = raw.totalIncomplete
    if type(totalIncomplete) ~= "number" then
        totalIncomplete = total - totalComplete
    end

    local signatureParts = {}
    for index = 1, #entries do
        local entry = entries[index]
        entry.sortOrder = index
        applyStateHints(entry)
        entry.signature = buildEntrySignature(entry)
        signatureParts[index] = entry.signature
    end

    local snapshot = {
        achievements = entries,
        total = total,
        totalComplete = totalComplete,
        totalIncomplete = totalIncomplete,
        hasIncomplete = (raw.hasIncomplete ~= nil) and (raw.hasIncomplete == true) or (totalIncomplete > 0),
        updatedAtMs = getTimestampMs(),
    }

    snapshot.signature = table.concat(signatureParts, "\31")

    return snapshot
end

local function snapshotsDiffer(previous, current)
    if not previous then
        return true
    end

    return previous.signature ~= current.signature
end

local function performRebuild(self, reason)
    if not self.isInitialized then
        return
    end

    local snapshot = buildSnapshot(self, reason)
    if not snapshotsDiffer(self.currentSnapshot, snapshot) then
        return
    end

    snapshot.revision = (self.currentSnapshot and self.currentSnapshot.revision or 0) + 1
    self.currentSnapshot = snapshot

    local state = resolveStateModule()
    if state and state.TouchTimestamp then
        pcall(state.TouchTimestamp, "achievementModel.refresh")
    end

    notifySubscribers(self)
end

local function scheduleRebuild(self, reason)
    if self.pendingRebuild then
        return
    end

    self.pendingRebuild = true

    local interval = self.debounceMs or DEFAULT_DEBOUNCE_MS

    EVENT_MANAGER:RegisterForUpdate(
        REBUILD_IDENTIFIER,
        interval,
        function()
            EVENT_MANAGER:UnregisterForUpdate(REBUILD_IDENTIFIER)
            self.pendingRebuild = false
            performRebuild(self, reason)
        end
    )
end

local function forceRebuild(self, reason)
    if not self.isInitialized then
        return
    end

    if self.pendingRebuild then
        EVENT_MANAGER:UnregisterForUpdate(REBUILD_IDENTIFIER)
        self.pendingRebuild = false
    end

    performRebuild(self, reason)
end

local function onAchievementChanged(eventCode, ...)
    local self = AchievementModel
    if not self.isInitialized then
        return
    end

    local achievementId
    if eventCode == EVENT_ACHIEVEMENT_AWARDED then
        local _, _, awardedId = ...
        achievementId = awardedId
    elseif eventCode == EVENT_ACHIEVEMENT_UPDATED then
        achievementId = select(1, ...)
    end

    local handledFavorite = false
    if achievementId then
        local Fav = Nvk3UT and Nvk3UT.FavoritesData
        if Fav and type(Fav.HandleAchievementUpdate) == "function" then
            local ok, changed = pcall(Fav.HandleAchievementUpdate, achievementId, eventCode)
            handledFavorite = ok and changed or false
        end
    end

    if eventCode == EVENT_ACHIEVEMENT_AWARDED then
        local Fav = Nvk3UT and Nvk3UT.FavoritesData
        if (not handledFavorite) and Fav and type(Fav.RemoveIfCompleted) == "function" then
            -- TODO(Events-Migration): Move this call into Events/Nvk3UT_AchievementEventHandler.lua during SWITCH token.
            local ok, removed = pcall(Fav.RemoveIfCompleted, achievementId)
            if ok and removed then
                local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
                if runtime and type(runtime.QueueDirty) == "function" then
                    pcall(runtime.QueueDirty, runtime, "achievement")
                end
            end
        end

        local cache = Nvk3UT and Nvk3UT.AchievementCache
        if cache and cache.OnAchievementAwarded then
            pcall(cache.OnAchievementAwarded, achievementId)
        end
    end

    scheduleRebuild(self, "event")
end

local function registerForEvent(eventId)
    if not eventId then
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. tostring(eventId), eventId, onAchievementChanged)
end

local function unregisterEvent(eventId)
    if not eventId then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. tostring(eventId), eventId)
end

function AchievementModel.OnFavoritesChanged()
    if not AchievementModel.isInitialized then
        return
    end

    scheduleRebuild(AchievementModel, "favorites")
end

local function initListModule()
    local List = resolveListModule()
    if List and type(List.Init) == "function" then
        pcall(List.Init, List)
    end
end

local function initStateModule(savedRoot)
    local State = resolveStateModule()
    if State and type(State.Init) == "function" then
        pcall(State.Init, savedRoot)
    end
end

function AchievementModel.Init(opts)
    if AchievementModel.isInitialized then
        return
    end

    opts = opts or {}

    local requestedDebounce = tonumber(opts.debounceMs)
    if requestedDebounce then
        AchievementModel.debounceMs = clampDebounce(requestedDebounce)
    else
        AchievementModel.debounceMs = DEFAULT_DEBOUNCE_MS
    end

    AchievementModel.subscribers = {}
    AchievementModel.currentSnapshot = nil
    AchievementModel.pendingRebuild = nil

    initStateModule(opts.saved or opts.sv or (Nvk3UT and Nvk3UT.sv))
    initListModule()

    AchievementModel.isInitialized = true

    registerForEvent(EVENT_ACHIEVEMENTS_UPDATED)
    registerForEvent(EVENT_ACHIEVEMENT_UPDATED)
    registerForEvent(EVENT_ACHIEVEMENT_AWARDED)

    local trackedListEvent = rawget(_G, "EVENT_ACHIEVEMENT_TRACKED_LIST_UPDATED")
    if trackedListEvent then
        registerForEvent(trackedListEvent)
    end

    forceRebuild(AchievementModel, "init")
    notifySubscribers(AchievementModel)
end

function AchievementModel.Shutdown()
    if not AchievementModel.isInitialized then
        return
    end

    unregisterEvent(EVENT_ACHIEVEMENTS_UPDATED)
    unregisterEvent(EVENT_ACHIEVEMENT_UPDATED)
    unregisterEvent(EVENT_ACHIEVEMENT_AWARDED)

    local trackedListEvent = rawget(_G, "EVENT_ACHIEVEMENT_TRACKED_LIST_UPDATED")
    if trackedListEvent then
        unregisterEvent(trackedListEvent)
    end

    EVENT_MANAGER:UnregisterForUpdate(REBUILD_IDENTIFIER)

    initListModule()

    AchievementModel.isInitialized = false
    AchievementModel.subscribers = nil
    AchievementModel.currentSnapshot = nil
    AchievementModel.pendingRebuild = nil
end

function AchievementModel.RefreshFromGame(reason)
    if not AchievementModel.isInitialized then
        return AchievementModel.currentSnapshot
    end

    forceRebuild(AchievementModel, reason or "manual")
    return AchievementModel.currentSnapshot
end

function AchievementModel.GetViewData()
    if AchievementModel.currentSnapshot then
        return AchievementModel.currentSnapshot
    end

    if not AchievementModel.isInitialized then
        return nil
    end

    return AchievementModel.RefreshFromGame("view")
end

function AchievementModel.GetSnapshot()
    return AchievementModel.GetViewData()
end

function AchievementModel.Subscribe(callback)
    assert(type(callback) == "function", "AchievementModel.Subscribe expects a function")

    AchievementModel.subscribers = AchievementModel.subscribers or {}
    AchievementModel.subscribers[callback] = true

    if AchievementModel.isInitialized and not AchievementModel.currentSnapshot then
        forceRebuild(AchievementModel, "subscribe")
    end

    callback(AchievementModel.currentSnapshot)
end

function AchievementModel.Unsubscribe(callback)
    if AchievementModel.subscribers then
        AchievementModel.subscribers[callback] = nil
    end
end

Nvk3UT.AchievementModel = AchievementModel

return AchievementModel
