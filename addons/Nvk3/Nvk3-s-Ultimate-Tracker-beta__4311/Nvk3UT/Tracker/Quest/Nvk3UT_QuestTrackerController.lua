local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local Controller = Nvk3UT.QuestTrackerController or {}
Nvk3UT.QuestTrackerController = Controller

local QUEST_FILTER_MODE_ALL = 1
local QUEST_FILTER_MODE_ACTIVE = 2
local QUEST_FILTER_MODE_SELECTION = 3

local state = {
    isDirty = false,
    lastReason = nil,
    rawSnapshot = nil,
    viewModel = nil,
}

local function getRoot()
    local root = rawget(_G, addonName)
    if type(root) == "table" then
        return root
    end

    return Nvk3UT
end

local function getUtils()
    local root = getRoot()
    return (root and root.Utils) or _G.Nvk3UT_Utils
end

local function getDiagnostics()
    local root = getRoot()
    return (root and root.Diagnostics) or _G.Nvk3UT_Diagnostics
end

local function isDebugEnabled()
    local utils = getUtils()
    if utils and type(utils.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(utils.IsDebugEnabled)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local diagnostics = getDiagnostics()
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        local ok, enabled = pcall(function()
            return diagnostics:IsDebugEnabled()
        end)
        if ok and enabled ~= nil then
            return enabled == true
        end
    end

    local root = getRoot()
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

local function dbg(message, ...)
    if not isDebugEnabled() then
        return
    end

    local formatted = message
    local argCount = select("#", ...)
    if argCount > 0 then
        formatted = string.format(message, ...)
    end

    if d then
        d(string.format("[%s][QuestCtrl] %s", addonName, formatted))
    elseif print then
        print(string.format("[%s][QuestCtrl] %s", addonName, formatted))
    end
end

local function EmptySnapshot()
    return { categories = { ordered = {}, byKey = {} } }
end

local function CountSnapshotEntries(snapshot)
    local categories = 0
    local quests = 0

    if snapshot and snapshot.categories and snapshot.categories.ordered then
        categories = #snapshot.categories.ordered
        for index = 1, categories do
            local category = snapshot.categories.ordered[index]
            if category and type(category.quests) == "table" then
                quests = quests + #category.quests
            end
        end
    end

    return categories, quests
end

local function CountViewModelEntries(viewModel)
    local categories = 0
    local quests = 0

    if viewModel and type(viewModel.categories) == "table" then
        categories = #viewModel.categories
        for index = 1, categories do
            local category = viewModel.categories[index]
            if category and type(category.quests) == "table" then
                quests = quests + #category.quests
            end
        end
    end

    return categories, quests
end

local function IsSnapshotValid(candidate)
    if type(candidate) ~= "table" then
        return false
    end

    local categories = candidate.categories
    if type(categories) ~= "table" then
        return false
    end

    return type(categories.ordered) == "table"
end

local function NormalizeQuestKey(journalIndex)
    local root = getRoot()
    local QuestState = root and root.QuestState
    if QuestState and QuestState.NormalizeQuestKey then
        return QuestState.NormalizeQuestKey(journalIndex)
    end

    if journalIndex == nil then
        return nil
    end

    if type(journalIndex) == "string" then
        local numeric = tonumber(journalIndex)
        if numeric and numeric > 0 then
            return tostring(numeric)
        end
        return journalIndex
    end

    if type(journalIndex) == "number" then
        if journalIndex > 0 then
            return tostring(journalIndex)
        end
        return nil
    end

    return tostring(journalIndex)
end

local function EnsureActiveSavedState()
    local root = getRoot()
    local QuestSelection = root and root.QuestSelection
    if QuestSelection and QuestSelection.EnsureActiveSavedState then
        return QuestSelection.EnsureActiveSavedState()
    end

    local QuestState = root and root.QuestState
    if QuestState and QuestState.EnsureActiveSavedState then
        return QuestState.EnsureActiveSavedState()
    end

    return nil
end

local function SyncSelectedQuestFromSaved()
    local root = getRoot()
    local QuestSelection = root and root.QuestSelection
    local QuestState = root and root.QuestState
    local questKey

    if QuestSelection and QuestSelection.GetActiveQuestKey then
        questKey = QuestSelection.GetActiveQuestKey()
    elseif QuestState and QuestState.GetSelectedQuestId then
        questKey = QuestState.GetSelectedQuestId()
    else
        local active = EnsureActiveSavedState()
        questKey = active and active.questKey or nil
    end

    if questKey ~= nil then
        questKey = NormalizeQuestKey(questKey)
    end

    state.selectedQuestKey = questKey

    return questKey
end

local function EnsureQuestFilterSavedVars()
    local root = getRoot()
    if not root then
        dbg("EnsureQuestFilterSavedVars: addon root missing")
        return nil
    end

    local sv = rawget(root, "SV")
    if not sv then
        dbg("EnsureQuestFilterSavedVars: saved vars missing")
        return nil
    end

    sv.QuestTracker = sv.QuestTracker or {}
    local tracker = sv.QuestTracker

    tracker.questFilter = tracker.questFilter or {}
    local filter = tracker.questFilter

    local mode = tonumber(filter.mode)
    if mode ~= QUEST_FILTER_MODE_ALL and mode ~= QUEST_FILTER_MODE_ACTIVE and mode ~= QUEST_FILTER_MODE_SELECTION then
        filter.mode = QUEST_FILTER_MODE_ALL
    else
        filter.mode = mode
    end

    if type(filter.selection) ~= "table" then
        filter.selection = {}
    end

    if filter.autoTrackNewQuestsInSelectionMode == nil then
        filter.autoTrackNewQuestsInSelectionMode = true
    else
        filter.autoTrackNewQuestsInSelectionMode = filter.autoTrackNewQuestsInSelectionMode == true
    end

    return filter
end

local function GetQuestFilterMode()
    local filter = EnsureQuestFilterSavedVars()
    if not filter then
        return QUEST_FILTER_MODE_ALL
    end

    local mode = tonumber(filter.mode)
    if mode == QUEST_FILTER_MODE_ALL or mode == QUEST_FILTER_MODE_ACTIVE or mode == QUEST_FILTER_MODE_SELECTION then
        return mode
    end

    filter.mode = QUEST_FILTER_MODE_ALL
    return QUEST_FILTER_MODE_ALL
end

local function getQuestFilterModule()
    local root = getRoot()
    return root and root.QuestFilter
end

local function BuildFilteredSnapshot(rawSnapshot)
    local snapshot = rawSnapshot or EmptySnapshot()
    state.rawSnapshot = snapshot

    if not IsSnapshotValid(snapshot) then
        dbg("BuildFilteredSnapshot: raw snapshot invalid")
        return snapshot
    end

    local filterMode = GetQuestFilterMode()
    local QuestFilter = getQuestFilterModule()

    if isDebugEnabled() then
        local rawCategories, rawQuests = CountSnapshotEntries(snapshot)
        dbg(
            "BuildFilteredSnapshot: mode=%s raw categories=%d quests=%d",
            tostring(filterMode),
            rawCategories,
            rawQuests
        )
    end

    if not QuestFilter or not QuestFilter.ApplyFilter or filterMode == QUEST_FILTER_MODE_ALL then
        return snapshot
    end

    local questFilter = EnsureQuestFilterSavedVars()
    local selection = questFilter and questFilter.selection
    local activeQuestKey = SyncSelectedQuestFromSaved()
    local categoryName = (GetString and GetString(SI_NVK3UT_QUEST_FILTER_CATEGORY_ACTIVE)) or "Quests"

    local ok, filtered = pcall(QuestFilter.ApplyFilter, snapshot, filterMode, selection, activeQuestKey, categoryName)
    if ok and IsSnapshotValid(filtered) then
        if isDebugEnabled() then
            local filteredCategories, filteredQuests = CountSnapshotEntries(filtered)
            dbg(
                "BuildFilteredSnapshot: mode=%s filtered categories=%d quests=%d",
                tostring(filterMode),
                filteredCategories,
                filteredQuests
            )
        end

        filtered.signature = snapshot.signature
        filtered.updatedAtMs = snapshot.updatedAtMs
        return filtered
    end

    dbg("BuildFilteredSnapshot: filter returned invalid result, falling back to unfiltered snapshot")
    return snapshot
end

function Controller:Init()
    state.isDirty = false
    state.lastReason = nil
    state.rawSnapshot = nil
    state.viewModel = nil
end

function Controller:MarkDirty(reason)
    state.isDirty = true
    state.lastReason = reason
    dbg("MarkDirty: %s", tostring(reason))
end

function Controller:RequestRefresh(reason)
    self:MarkDirty(reason)

    local root = getRoot()
    local runtime = root and rawget(root, "TrackerRuntime")
    if runtime and type(runtime.QueueDirty) == "function" then
        pcall(runtime.QueueDirty, runtime, "quest")
    end

    dbg("RequestRefresh: %s", tostring(reason))
end

function Controller:ClearDirty()
    state.isDirty = false
    state.lastReason = nil
end

function Controller:IsDirty()
    return state.isDirty == true
end

local function EnsureSnapshotShape(candidate)
    local snapshot = candidate
    if type(snapshot) ~= "table" then
        snapshot = EmptySnapshot()
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

    return snapshot
end

function Controller:BuildViewModel()
    local root = getRoot()
    local QuestModel = root and root.QuestModel
    local snapshot

    if QuestModel and QuestModel.GetSnapshot then
        snapshot = QuestModel.GetSnapshot()
    end

    local filtered = BuildFilteredSnapshot(snapshot)
    filtered = EnsureSnapshotShape(filtered)
    if not IsSnapshotValid(filtered) then
        filtered = EmptySnapshot()
    end

    local viewModel = {
        categories = {},
        signature = filtered.signature,
        updatedAtMs = filtered.updatedAtMs,
    }

    if filtered.categories then
        if type(filtered.categories.ordered) == "table" then
            viewModel.categories = filtered.categories.ordered
        elseif type(filtered.categories) == "table" then
            viewModel.categories = filtered.categories
        end
    end

    local hasObjectives = false
    local categories, quests = CountViewModelEntries(viewModel)

    if viewModel.categories then
        for categoryIndex = 1, #viewModel.categories do
            local category = viewModel.categories[categoryIndex]
            if category and type(category.quests) == "table" then
                for questIndex = 1, #category.quests do
                    local quest = category.quests[questIndex]
                    if quest then
                        if quest.objectives and next(quest.objectives) then
                            hasObjectives = true
                            break
                        end
                        if quest.steps and #quest.steps > 0 then
                            for stepIndex = 1, #quest.steps do
                                local step = quest.steps[stepIndex]
                                if step and step.conditions and #step.conditions > 0 then
                                    hasObjectives = true
                                    break
                                end
                            end
                        end
                    end
                end
            end

            if hasObjectives then
                break
            end
        end
    end

    viewModel.hasObjectives = hasObjectives

    state.viewModel = viewModel
    state.isDirty = false

    dbg(
        "BuildViewModel return: categories=%d quests=%d hasObjectives=%s",
        categories,
        quests,
        tostring(hasObjectives)
    )

    return viewModel
end

function Controller:GetLastReason()
    return state.lastReason
end

return Controller
