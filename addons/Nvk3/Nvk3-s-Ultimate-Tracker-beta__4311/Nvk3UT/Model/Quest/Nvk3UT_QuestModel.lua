local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local function GetQuestListModule()
    return Nvk3UT and Nvk3UT.QuestList
end

local function GetQuestStateModule()
    return Nvk3UT and Nvk3UT.QuestState
end

local QuestModel = {}
QuestModel.__index = QuestModel

local QUEST_MODEL_NAME = addonName .. "QuestModel"
local EVENT_NAMESPACE = QUEST_MODEL_NAME .. "_Event"
local REBUILD_IDENTIFIER = QUEST_MODEL_NAME .. "_Rebuild"

local QUEST_SAVED_VARS_NAME = "Nvk3UT_Data_Quests"
local QUEST_SAVED_VARS_VERSION = 1
local QUEST_SAVED_VARS_DEFAULTS = {
    version = 1,
    meta = {
        initialized = false,
        lastInit = nil,
    },
    quests = {},
    settings = {
        autoVerticalResize = false,
    },
}

local questSavedVars = nil
local bootstrapState = {
    registered = false,
    executed = false,
}
local playerState = {
    hasActivated = false,
}

local DEBUG_INIT = false

local function NormalizeCategoryKey(categoryKey)
    local questState = GetQuestStateModule()
    if questState and questState.NormalizeCategoryKey then
        return questState.NormalizeCategoryKey(categoryKey)
    end

    if categoryKey == nil then
        return nil
    end

    if type(categoryKey) == "string" then
        return categoryKey
    end

    if type(categoryKey) == "number" then
        return tostring(categoryKey)
    end

    return tostring(categoryKey)
end

local function QuestKeyToJournalIndex(questKey)
    if questKey == nil then
        return nil
    end

    if type(questKey) == "table" and questKey.questKey then
        questKey = questKey.questKey
    end

    local numeric = tonumber(questKey)
    if numeric and numeric > 0 then
        return numeric
    end

    return nil
end

local function IsDebugLoggingEnabled()
    if DEBUG_INIT then
        return true
    end

    local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(utils.IsDebugEnabled)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return diagnostics:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local root = Nvk3UT
    if root and type(root.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return root:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    return false
end

local function DebugInitLog(message, ...)
    if not IsDebugLoggingEnabled() then
        return
    end

    local formatted = message
    local argumentCount = select("#", ...)
    if argumentCount > 0 then
        formatted = string.format(message, ...)
    end

    if d then
        d(string.format("[Nvk3UT][QuestInit] %s", formatted))
    elseif print then
        print("[Nvk3UT][QuestInit]", formatted)
    end
end

local function CopyTable(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, entry in pairs(value) do
        copy[key] = CopyTable(entry)
    end
    return copy
end

local function AppendCategoryKey(list, seen, categoryKey)
    local normalized = NormalizeCategoryKey(categoryKey)
    if not normalized or seen[normalized] then
        return
    end

    seen[normalized] = true
    list[#list + 1] = normalized
end

local function CollectCategoryKeysForQuestFromSnapshot(snapshot, journalIndex)
    local keys = {}
    local orderedKeys = {}

    if not snapshot or not journalIndex then
        return keys, false, orderedKeys
    end

    local found = false
    local seen = {}
    local categories = snapshot.categories
    local ordered = categories and categories.ordered

    if type(ordered) ~= "table" then
        return keys, found, orderedKeys
    end

    for index = 1, #ordered do
        local category = ordered[index]
        if category and type(category.quests) == "table" then
            for questIndex = 1, #category.quests do
                local quest = category.quests[questIndex]
                if quest and quest.journalIndex == journalIndex then
                    found = true
                    AppendCategoryKey(orderedKeys, seen, category.key)
                    AppendCategoryKey(orderedKeys, seen, category.parent and category.parent.key)
                end
            end
        end
    end

    for idx = 1, #orderedKeys do
        keys[orderedKeys[idx]] = true
    end

    return keys, found, orderedKeys
end

local function BindQuestList(savedVars)
    local questList = GetQuestListModule()
    if questList and questList.Bind then
        pcall(function()
            questList:Bind(savedVars)
        end)
    end
end

local function EnsureSavedVars()
    if questSavedVars then
        return questSavedVars
    end

    if not ZO_SavedVars then
        questSavedVars = CopyTable(QUEST_SAVED_VARS_DEFAULTS)
        DebugInitLog("[Init] SavedVars ensured (fallback)")
        BindQuestList(questSavedVars)
        return questSavedVars
    end

    local sv = ZO_SavedVars:NewCharacterIdSettings(
        QUEST_SAVED_VARS_NAME,
        QUEST_SAVED_VARS_VERSION,
        nil,
        QUEST_SAVED_VARS_DEFAULTS
    )

    sv.version = sv.version or QUEST_SAVED_VARS_DEFAULTS.version

    if type(sv.meta) ~= "table" then
        sv.meta = {}
    end
    if sv.meta.initialized == nil then
        sv.meta.initialized = false
    else
        sv.meta.initialized = sv.meta.initialized == true
    end
    if sv.meta.lastInit ~= nil then
        local numeric = tonumber(sv.meta.lastInit)
        sv.meta.lastInit = numeric
    end

    if type(sv.quests) ~= "table" then
        sv.quests = {}
    elseif next(sv.quests) ~= nil then
        -- Objectives/steps are no longer persisted; clear legacy data eagerly.
        sv.quests = {}
    end

    if type(sv.settings) ~= "table" then
        sv.settings = {}
    end
    if sv.settings.autoVerticalResize == nil then
        sv.settings.autoVerticalResize = false
    else
        sv.settings.autoVerticalResize = sv.settings.autoVerticalResize == true
    end

    questSavedVars = sv
    DebugInitLog("[Init] SavedVars ensured")

    BindQuestList(sv)

    return questSavedVars
end

local function MarkInitialized(sv)
    if not sv then
        return
    end

    sv.meta = sv.meta or {}
    sv.meta.initialized = true
    if GetTimeStamp then
        sv.meta.lastInit = GetTimeStamp()
    else
        sv.meta.lastInit = sv.meta.lastInit or 0
    end
end

local function PersistQuests(quests)
    local sv = EnsureSavedVars()
    if not sv then
        return 0
    end

    sv.quests = {}
    MarkInitialized(sv)
    return 0
end

local function ShouldBootstrap(sv)
    if bootstrapState.executed then
        return false
    end

    if not sv then
        return false
    end

    if type(sv.meta) ~= "table" or sv.meta.initialized ~= true then
        return true
    end

    return false
end

local function BuildSnapshotFromSaved()
    local sv = EnsureSavedVars()
    if not sv then
        return nil
    end

    if type(sv.quests) == "table" and next(sv.quests) ~= nil then
        sv.quests = {}
    end

    return nil
end

local function BootstrapQuestData()
    if bootstrapState.executed then
        return 0
    end

    local questList = GetQuestListModule()
    local quests = {}
    if questList and questList.RefreshFromGame then
        quests = questList:RefreshFromGame()
    end

    local stored = PersistQuests(quests)
    bootstrapState.executed = true
    DebugInitLog("[Init] BootstrapQuestData → %d quests stored", stored)
    return stored
end

local ForceRebuildInternal

local function OnPlayerActivated()
    if bootstrapState.registered and EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "PlayerActivated", EVENT_PLAYER_ACTIVATED)
        bootstrapState.registered = false
    end

    local sv = EnsureSavedVars()
    local requiresBootstrap = ShouldBootstrap(sv)
    DebugInitLog("[Init] OnPlayerActivated → Bootstrap required: %s", tostring(requiresBootstrap))

    playerState.hasActivated = true

    if requiresBootstrap then
        BootstrapQuestData()
    end

    if QuestModel.isInitialized and ForceRebuildInternal then
        ForceRebuildInternal(QuestModel)
    end
end

local function RegisterForPlayerActivated()
    if bootstrapState.registered or not EVENT_MANAGER then
        return
    end

    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    bootstrapState.registered = true
end

local function OnAddOnLoaded(_, name)
    if name ~= addonName then
        return
    end

    if EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "OnLoaded", EVENT_ADD_ON_LOADED)
    end

    EnsureSavedVars()
    RegisterForPlayerActivated()
    DebugInitLog("[Init] OnAddOnLoaded → SavedVars ready")
end

if EVENT_MANAGER then
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "OnLoaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end

local MIN_DEBOUNCE_MS = 50
local MAX_DEBOUNCE_MS = 120
local DEFAULT_DEBOUNCE_MS = 80

local function ClampDebounce(value)
    if value < MIN_DEBOUNCE_MS then
        return MIN_DEBOUNCE_MS
    elseif value > MAX_DEBOUNCE_MS then
        return MAX_DEBOUNCE_MS
    end
    return value
end

local function LogDebug(self, ...)
    if not IsDebugLoggingEnabled() then
        return
    end

    if d then
        d(string.format("[%s]", QUEST_MODEL_NAME), ...)
    elseif print then
        print("[" .. QUEST_MODEL_NAME .. "]", ...)
    end
end

local function RegisterQuestEvent(eventId, handler)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. tostring(eventId), eventId, handler)
end

local function UnregisterQuestEvent(eventId)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. tostring(eventId), eventId)
end

local function NotifySubscribers(self)
    if not self.subscribers then
        return
    end

    for callback in pairs(self.subscribers) do
        local success, err = pcall(callback, self.currentSnapshot)
        if not success then
            LogDebug(self, "Subscriber callback failed", err)
        end
    end
end

local function ResetBaseCategoryCache()
    -- TEMP SHIM (QMODEL_004): delegate cache resets to QuestList.
    local questList = GetQuestListModule()
    if questList and questList.ResetBaseCategoryCache then
        questList.ResetBaseCategoryCache()
    elseif questList and questList.ResetCaches then
        questList:ResetCaches()
    end
end

local function CollectQuestEntries()
    -- TEMP SHIM (QMODEL_004): forward quest refresh to QuestList facade.
    local questList = GetQuestListModule()
    if questList and questList.RefreshFromGame then
        return questList:RefreshFromGame()
    end
    return {}
end

local function BuildSnapshotFromQuests(quests)
    -- TEMP SHIM (QMODEL_004): reuse QuestList snapshot builder.
    local questList = GetQuestListModule()
    if questList and questList.BuildSnapshotFromQuests then
        return questList:BuildSnapshotFromQuests(quests)
    end

    quests = type(quests) == "table" and quests or {}
    return {
        updatedAtMs = nil,
        quests = quests,
        categories = {
            ordered = {},
            byKey = {},
        },
        signature = nil,
        questById = {},
        questByJournalIndex = {},
    }
end

local function BuildSnapshot(self)
    local quests = CollectQuestEntries()
    if type(quests) ~= "table" then
        quests = {}
    end

    local snapshot = BuildSnapshotFromQuests(quests)
    if not snapshot or type(snapshot) ~= "table" then
        snapshot = BuildSnapshotFromQuests({})
    end

    if type(snapshot.categories) ~= "table" then
        snapshot.categories = { ordered = {}, byKey = {} }
    end
    if type(snapshot.categories.ordered) ~= "table" then
        snapshot.categories.ordered = {}
    end
    if type(snapshot.categories.byKey) ~= "table" then
        snapshot.categories.byKey = {}
    end
    if type(snapshot.quests) ~= "table" then
        snapshot.quests = {}
    end
    if type(snapshot.questById) ~= "table" then
        snapshot.questById = {}
    end
    if type(snapshot.questByJournalIndex) ~= "table" then
        snapshot.questByJournalIndex = {}
    end

    return snapshot, quests
end

local function SnapshotsDiffer(previous, current)
    if not previous then
        return true
    end
    return previous.signature ~= current.signature
end

local function PerformRebuild(self)
    if not self.isInitialized or not playerState.hasActivated then
        return false
    end

    local snapshot, quests = BuildSnapshot(self)
    if not snapshot then
        return false
    end

    if not SnapshotsDiffer(self.currentSnapshot, snapshot) then
        PersistQuests(quests)
        return false
    end

    snapshot.revision = (self.currentSnapshot and self.currentSnapshot.revision or 0) + 1
    self.currentSnapshot = snapshot
    PersistQuests(quests)
    NotifySubscribers(self)
    return true
end

local function ScheduleRebuild(self)
    if not playerState.hasActivated then
        return
    end

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
            PerformRebuild(self)
        end
    )
end

ForceRebuildInternal = function(self)
    if not self.isInitialized or not playerState.hasActivated then
        return false
    end

    if self.pendingRebuild then
        EVENT_MANAGER:UnregisterForUpdate(REBUILD_IDENTIFIER)
        self.pendingRebuild = false
    end

    local updated = PerformRebuild(self)
    return updated
end

QuestModel.ForceRebuild = ForceRebuildInternal
QuestModel.forceRebuild = ForceRebuildInternal

local function OnQuestChanged(_, ...)
    local self = QuestModel
    if not self.isInitialized or not playerState.hasActivated then
        return
    end

    ResetBaseCategoryCache()
    ScheduleRebuild(self)
end

local function OnTrackingUpdate(eventCode, trackingType)
    if trackingType ~= TRACK_TYPE_QUEST then
        return
    end
    OnQuestChanged(eventCode)
end

function QuestModel.GetCategoryKeysForQuestKey(questKey)
    local journalIndex = QuestKeyToJournalIndex(questKey)
    local snapshot = QuestModel.GetSnapshot and QuestModel.GetSnapshot()

    return CollectCategoryKeysForQuestFromSnapshot(snapshot, journalIndex)
end

function QuestModel.Init(opts)
    if QuestModel.isInitialized then
        return
    end

    opts = opts or {}

    EnsureSavedVars()
    RegisterForPlayerActivated()

    local requestedDebounce = tonumber(opts.debounceMs)
    if requestedDebounce then
        QuestModel.debounceMs = ClampDebounce(requestedDebounce)
    else
        QuestModel.debounceMs = DEFAULT_DEBOUNCE_MS
    end
    QuestModel.subscribers = {}
    QuestModel.isInitialized = true

    local savedSnapshot = BuildSnapshotFromSaved()
    if savedSnapshot then
        savedSnapshot.revision = (QuestModel.currentSnapshot and QuestModel.currentSnapshot.revision) or 0
        QuestModel.currentSnapshot = savedSnapshot
    else
        QuestModel.currentSnapshot = nil
    end

    local eventHandler = function(...)
        OnQuestChanged(...)
    end

    RegisterQuestEvent(EVENT_QUEST_ADDED, eventHandler)
    RegisterQuestEvent(EVENT_QUEST_REMOVED, eventHandler)
    RegisterQuestEvent(EVENT_QUEST_ADVANCED, eventHandler)
    RegisterQuestEvent(EVENT_QUEST_CONDITION_COUNTER_CHANGED, eventHandler)
    RegisterQuestEvent(EVENT_QUEST_LOG_UPDATED, eventHandler)
    EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "TRACKING", EVENT_TRACKING_UPDATE, OnTrackingUpdate)

    if playerState.hasActivated then
        ForceRebuildInternal(QuestModel)
    end

    if QuestModel.currentSnapshot and next(QuestModel.subscribers) then
        NotifySubscribers(QuestModel)
    end
end

function QuestModel.Shutdown()
    if not QuestModel.isInitialized then
        return
    end

    UnregisterQuestEvent(EVENT_QUEST_ADDED)
    UnregisterQuestEvent(EVENT_QUEST_REMOVED)
    UnregisterQuestEvent(EVENT_QUEST_ADVANCED)
    UnregisterQuestEvent(EVENT_QUEST_CONDITION_COUNTER_CHANGED)
    UnregisterQuestEvent(EVENT_QUEST_LOG_UPDATED)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "TRACKING", EVENT_TRACKING_UPDATE)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "OnLoaded", EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:UnregisterForUpdate(REBUILD_IDENTIFIER)
    EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "PlayerActivated", EVENT_PLAYER_ACTIVATED)
    bootstrapState.registered = false
    playerState.hasActivated = false

    QuestModel.isInitialized = false
    QuestModel.subscribers = nil
    QuestModel.currentSnapshot = nil
    QuestModel.pendingRebuild = nil

    ResetBaseCategoryCache()
end

function QuestModel.GetSavedVars()
    return questSavedVars
end

function QuestModel.GetSnapshot()
    return QuestModel.currentSnapshot
end

function QuestModel.Subscribe(callback)
    assert(type(callback) == "function", "QuestModel.Subscribe expects a function")

    QuestModel.subscribers = QuestModel.subscribers or {}
    QuestModel.subscribers[callback] = true

    if QuestModel.isInitialized and playerState.hasActivated and not QuestModel.currentSnapshot then
        ForceRebuildInternal(QuestModel)
    end

    callback(QuestModel.currentSnapshot)
end

function QuestModel.Unsubscribe(callback)
    if QuestModel.subscribers then
        QuestModel.subscribers[callback] = nil
    end
end

Nvk3UT.QuestModel = QuestModel

return QuestModel
