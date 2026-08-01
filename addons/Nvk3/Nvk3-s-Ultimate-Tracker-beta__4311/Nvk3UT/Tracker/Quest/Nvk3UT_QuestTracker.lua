local addonName = "Nvk3UT"

Nvk3UT = Nvk3UT or {}

local state
local DebugLog
local GetFocusedQuestIndex
local RefreshQuestJournalSelectionKeyLabelText
local UpdateQuestFilterKeybindLabelForActiveQuest
local UpdateQuestJournalSelectionKeyLabelVisibility

local QuestTracker = {}
QuestTracker.__index = QuestTracker

local MODULE_NAME = addonName .. "QuestTracker"
local EVENT_NAMESPACE = MODULE_NAME .. "_Event"

local function GetHideBaseQuestTrackerFlag()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local general = sv and sv.General
    if general and general.hideBaseQuestTracker ~= nil then
        return general.hideBaseQuestTracker == true
    end
    return true
end

local function GetQuestTrackerEnabledFlag()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local questTracker = sv and sv.QuestTracker

    if questTracker and questTracker.active ~= nil then
        return questTracker.active ~= false
    end

    return true
end

local function GetBaseQuestTracker()
    local tracker = QUEST_TRACKER

    if tracker == nil then
        tracker = ASSISTED_QUEST_TRACKER or FOCUSED_QUEST_TRACKER
    end

    if tracker and type(tracker.GetFragment) == "function" then
        return tracker
    end

    return nil
end

local Utils = Nvk3UT and Nvk3UT.Utils
local QuestState = Nvk3UT and Nvk3UT.QuestState
local QuestSelection = Nvk3UT and Nvk3UT.QuestSelection
local QuestFilter = Nvk3UT and Nvk3UT.QuestFilter
local QuestTrackerRows = Nvk3UT and Nvk3UT.QuestTrackerRows
local QuestTrackerLayout = Nvk3UT and Nvk3UT.QuestTrackerLayout
local QUEST_FILTER_MODE_ALL = (QuestFilter and QuestFilter.MODE_ALL) or 1
local QUEST_FILTER_MODE_ACTIVE = (QuestFilter and QuestFilter.MODE_ACTIVE) or 2
local QUEST_FILTER_MODE_SELECTION = (QuestFilter and QuestFilter.MODE_SELECTION) or 3

local function IsValidQuestFilterMode(mode)
    local numeric = tonumber(mode)
    if not numeric then
        return false
    end

    return numeric == QUEST_FILTER_MODE_ALL
        or numeric == QUEST_FILTER_MODE_ACTIVE
        or numeric == QUEST_FILTER_MODE_SELECTION
end
local FormatCategoryHeaderText =
    (Utils and Utils.FormatCategoryHeaderText)
    or function(baseText, count, showCounts)
        local text = baseText or ""
        if showCounts ~= false and type(count) == "number" and count >= 0 then
            local numericCount = math.floor(count + 0.5)
            return string.format("%s (%d)", text, numericCount)
        end
        return text
    end

local function ShouldShowQuestCategoryCounts()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local general = sv and sv.General

    if general and general.showQuestCategoryCounts ~= nil then
        return general.showQuestCategoryCounts ~= false
    end

    return true
end

local function EnsureQuestFilterSavedVars()
    local addon = Nvk3UT
    if not addon then
        DebugLog("EnsureQuestFilterSavedVars: addon is nil")
        return nil
    end

    local sv = addon.SV
    if not sv then
        DebugLog("EnsureQuestFilterSavedVars: addon.SV is nil")
        return nil
    end

    sv.QuestTracker = sv.QuestTracker or {}
    local tracker = sv.QuestTracker

    tracker.questFilter = tracker.questFilter or {}
    local filter = tracker.questFilter

    local numericMode = tonumber(filter.mode)
    if not IsValidQuestFilterMode(numericMode) then
        DebugLog("EnsureQuestFilterSavedVars: invalid mode '%s', resetting to ALL", tostring(filter.mode))
        filter.mode = QUEST_FILTER_MODE_ALL
    else
        filter.mode = numericMode
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
    local questFilter = EnsureQuestFilterSavedVars()
    if not questFilter then
        DebugLog("GetQuestFilterMode: filter is nil, falling back to ALL")
        return QUEST_FILTER_MODE_ALL
    end

    local mode = questFilter.mode
    if not IsValidQuestFilterMode(mode) then
        DebugLog("GetQuestFilterMode: invalid mode '%s', resetting to ALL", tostring(mode))
        questFilter.mode = QUEST_FILTER_MODE_ALL
        return QUEST_FILTER_MODE_ALL
    end

    return tonumber(mode)
end

local function IsQuestSelectionMode()
    return GetQuestFilterMode() == QUEST_FILTER_MODE_SELECTION
end

local function IsQuestSelectionModeActive()
    return IsQuestSelectionMode()
end

local CATEGORY_TOGGLE_TEXTURES = {
    expanded = {
        up = "EsoUI/Art/Buttons/tree_open_up.dds",
        over = "EsoUI/Art/Buttons/tree_open_over.dds",
    },
    collapsed = {
        up = "EsoUI/Art/Buttons/tree_closed_up.dds",
        over = "EsoUI/Art/Buttons/tree_closed_over.dds",
    },
}

local QUEST_SELECTED_ICON_TEXTURE = "EsoUI/Art/Journal/journal_Quest_Selected.dds"

local CATEGORY_INDENT_X = 0
local QUEST_INDENT_X = 18
local QUEST_ICON_SLOT_WIDTH = 18
local QUEST_ICON_SLOT_HEIGHT = 18
local QUEST_ICON_SLOT_PADDING_X = 6
local QUEST_LABEL_INDENT_X = QUEST_INDENT_X + QUEST_ICON_SLOT_WIDTH + QUEST_ICON_SLOT_PADDING_X
-- keep objective indentation ahead of quest titles even with the persistent icon slot
local CONDITION_RELATIVE_INDENT = 18
local CONDITION_INDENT_X = QUEST_LABEL_INDENT_X + CONDITION_RELATIVE_INDENT
local CATEGORY_SPACING_ABOVE = 3
local VERTICAL_PADDING = 3
local CATEGORY_BOTTOM_PAD_EXPANDED = 6
local CATEGORY_BOTTOM_PAD_COLLAPSED = 6
local ENTRY_SPACING_ABOVE = 3
local ENTRY_SPACING_BELOW = 3
local OBJECTIVE_SPACING_ABOVE = 3
local OBJECTIVE_SPACING_BELOW = 3
local OBJECTIVE_SPACING_BETWEEN = 1
local OBJECTIVE_INDENT_DEFAULT = 40
local OBJECTIVE_BASE_INDENT = 20
local BOTTOM_PIXEL_NUDGE = 3

local CATEGORY_MIN_HEIGHT = 26
local QUEST_MIN_HEIGHT = 24
local CONDITION_MIN_HEIGHT = 20
local ROW_TEXT_PADDING_Y = 4
local TOGGLE_LABEL_PADDING_X = 4
local CATEGORY_TOGGLE_WIDTH = 20

local DEFAULT_FONTS = {
    category = "$(BOLD_FONT)|20|soft-shadow-thick",
    quest = "$(BOLD_FONT)|16|soft-shadow-thick",
    condition = "$(BOLD_FONT)|14|soft-shadow-thick",
    toggle = "$(BOLD_FONT)|20|soft-shadow-thick",
}

local DEFAULT_FONT_OUTLINE = "soft-shadow-thick"
local REFRESH_DEBOUNCE_MS = 80
local DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR = { 1, 1, 0.6, 1 }

local function NormalizeSpacingValue(value, fallback)
    local numeric = tonumber(value)
    if numeric == nil or numeric ~= numeric then
        return fallback
    end
    if numeric < 0 then
        return fallback
    end
    return numeric
end

local function ApplyQuestSpacingFromSaved()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local spacing = sv and sv.spacing
    local questSpacing = spacing and spacing.quest
    local category = questSpacing and questSpacing.category
    local entry = questSpacing and questSpacing.entry
    local objective = questSpacing and questSpacing.objective

    CATEGORY_INDENT_X = NormalizeSpacingValue(category and category.indent, CATEGORY_INDENT_X)
    CATEGORY_SPACING_ABOVE = NormalizeSpacingValue(category and category.spacingAbove, CATEGORY_SPACING_ABOVE)

    local belowSpacing = NormalizeSpacingValue(category and category.spacingBelow, CATEGORY_BOTTOM_PAD_EXPANDED)
    CATEGORY_BOTTOM_PAD_EXPANDED = belowSpacing
    CATEGORY_BOTTOM_PAD_COLLAPSED = belowSpacing

    QUEST_INDENT_X = NormalizeSpacingValue(entry and entry.indent, QUEST_INDENT_X)
    ENTRY_SPACING_ABOVE = NormalizeSpacingValue(entry and entry.spacingAbove, ENTRY_SPACING_ABOVE)
    ENTRY_SPACING_BELOW = NormalizeSpacingValue(entry and entry.spacingBelow, ENTRY_SPACING_BELOW)

    QUEST_LABEL_INDENT_X = QUEST_INDENT_X + QUEST_ICON_SLOT_WIDTH + QUEST_ICON_SLOT_PADDING_X
    local objectiveIndent = NormalizeSpacingValue(objective and objective.indent, OBJECTIVE_INDENT_DEFAULT)
    CONDITION_INDENT_X = objectiveIndent + OBJECTIVE_BASE_INDENT
    OBJECTIVE_SPACING_ABOVE = NormalizeSpacingValue(objective and objective.spacingAbove, OBJECTIVE_SPACING_ABOVE)
    OBJECTIVE_SPACING_BELOW = NormalizeSpacingValue(objective and objective.spacingBelow, OBJECTIVE_SPACING_BELOW)
    OBJECTIVE_SPACING_BETWEEN = NormalizeSpacingValue(objective and objective.spacingBetween, OBJECTIVE_SPACING_BETWEEN)
end

local function ScheduleToggleFollowup(reason)
    local rebuild = (Nvk3UT and Nvk3UT.Rebuild) or _G.Nvk3UT_Rebuild
    if rebuild and type(rebuild.ScheduleToggleFollowup) == "function" then
        rebuild.ScheduleToggleFollowup(reason)
    end
end

local RequestRefresh -- forward declaration for functions that trigger refreshes
local SetCategoryExpanded -- forward declaration for expansion helpers used before assignment
local SetQuestExpanded
local IsQuestExpanded -- forward declaration so earlier functions can query quest expansion state
local HandleQuestRowClick -- forward declaration for quest row click orchestration
local FlushPendingTrackedQuestUpdate -- forward declaration for deferred tracking updates
local ProcessTrackedQuestUpdate -- forward declaration for deferred tracking processing
-- Forward declaration so SafeCall is visible to functions defined above its body.
-- Without this, calling SafeCall in ResolveQuestDebugInfo during quest accept can crash
-- because SafeCall would still be nil at that point.
local SafeCall

state = {
    isInitialized = false,
    opts = {},
    fonts = {},
    saved = nil,
    control = nil,
    container = nil,
    categoryPool = nil,
    questPool = nil,
    conditionPool = nil,
    orderedControls = {},
    lastAnchoredControl = nil,
    viewModel = nil,
    categoryControls = {},
    questControls = {},
    pendingRefresh = false,
    contentWidth = 0,
    contentHeight = 0,
    trackedQuestIndex = nil,
    trackedCategoryKeys = {},
    trackingEventsRegistered = false,
    suppressForceExpandFor = nil,
    pendingSelection = nil,
    lastTrackedBeforeSync = nil,
    syncingTrackedState = false,
    pendingDeselection = false,
    pendingExternalReveal = nil,
    pendingTrackedUpdate = nil,
    isClickSelectInProgress = false,
    selectedQuestKey = nil,
    isRebuildInProgress = false,
    questModelSubscription = nil,
    lastAutoExpandedQuestKey = nil,
}

local PRIORITY = {
    manual = 5,
    ["click-select"] = 4,
    ["external-select"] = 4,
    tracked = 3,
    auto = 2,
    init = 1,
}

NVK_DEBUG_DESELECT = NVK_DEBUG_DESELECT or false

local function IsDebugLoggingEnabled()
    local utils = (Nvk3UT and Nvk3UT.Utils) or Nvk3UT_Utils
    if utils and type(utils.IsDebugEnabled) == "function" then
        return utils.IsDebugEnabled()
    end
    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if diagnostics and type(diagnostics.IsDebugEnabled) == "function" then
        return diagnostics:IsDebugEnabled()
    end
    local addon = Nvk3UT
    if addon and type(addon.IsDebugEnabled) == "function" then
        return addon:IsDebugEnabled()
    end
    return false
end

function DebugLog(...)
    local isEnabled = type(IsDebugLoggingEnabled) == "function" and IsDebugLoggingEnabled()
    if not isEnabled then
        return
    end

    if d then
        d(string.format("[%s]", MODULE_NAME), ...)
    elseif print then
        print("[" .. MODULE_NAME .. "]", ...)
    end
end

local function DebugDeselect(context, details)
    if not NVK_DEBUG_DESELECT then
        return
    end

    local parts = { string.format("[%s][DESELECT] %s", MODULE_NAME, tostring(context)) }

    if type(details) == "table" then
        for key, value in pairs(details) do
            parts[#parts + 1] = string.format("%s=%s", tostring(key), tostring(value))
        end
    elseif details ~= nil then
        parts[#parts + 1] = tostring(details)
    end

    local message = table.concat(parts, " | ")

    if d then
        d(message)
    elseif print then
        print(message)
    end
end

local function EscapeDebugString(value)
    return tostring(value):gsub('"', '\\"')
end

local function AppendDebugField(parts, key, value, treatAsString)
    if key == nil or key == "" then
        return
    end

    if value == nil then
        parts[#parts + 1] = string.format("%s=nil", key)
        return
    end

    local valueType = type(value)
    if valueType == "boolean" then
        parts[#parts + 1] = string.format("%s=%s", key, value and "true" or "false")
    elseif valueType == "number" then
        parts[#parts + 1] = string.format("%s=%s", key, tostring(value))
    elseif treatAsString or valueType == "string" then
        parts[#parts + 1] = string.format('%s="%s"', key, EscapeDebugString(value))
    else
        parts[#parts + 1] = string.format("%s=%s", key, tostring(value))
    end
end

local function EmitDebugAction(action, trigger, entityType, fieldList)
    if not (type(IsDebugLoggingEnabled) == "function" and IsDebugLoggingEnabled()) then
        return
    end

    local parts = { "[NVK]" }
    AppendDebugField(parts, "action", action or "unknown")
    AppendDebugField(parts, "trigger", trigger or "unknown")
    AppendDebugField(parts, "type", entityType or "unknown")

    if type(fieldList) == "table" then
        for index = 1, #fieldList do
            local entry = fieldList[index]
            if entry and entry.key then
                AppendDebugField(parts, entry.key, entry.value, entry.string)
            end
        end
    end

    local message = table.concat(parts, " ")
    if d then
        d(message)
    elseif print then
        print(message)
    end
end

local function GetQuestTrackerColor(role)
    local host = Nvk3UT and Nvk3UT.TrackerHost
    if host then
        if host.EnsureAppearanceDefaults then
            host.EnsureAppearanceDefaults()
        end
        if host.GetTrackerColor then
            return host.GetTrackerColor("questTracker", role)
        end
    end
    return 1, 1, 1, 1
end

local function GetMouseoverHighlightColor()
    local host = Nvk3UT and Nvk3UT.TrackerHost
    if host then
        if host.EnsureAppearanceDefaults then
            host.EnsureAppearanceDefaults()
        end
        if host.GetMouseoverHighlightColor then
            local r, g, b, a = host.GetMouseoverHighlightColor("questTracker")
            if r and g and b and a then
                return r, g, b, a
            end
        end
    end

    return unpack(DEFAULT_MOUSEOVER_HIGHLIGHT_COLOR)
end

local function ApplyMouseoverHighlight(ctrl)
    if not (ctrl and ctrl.label) then
        return
    end

    local r, g, b, a = GetMouseoverHighlightColor()
    ctrl.label:SetColor(r, g, b, a)

    if IsDebugLoggingEnabled() then
        DebugLog(string.format(
            "Quest hover: applying mouseover highlight color r=%.3f g=%.3f b=%.3f a=%.3f",
            r or 0,
            g or 0,
            b or 0,
            a or 0
        ))
    end
end

local function RestoreBaseColor(ctrl)
    if not (ctrl and ctrl.label and ctrl.baseColor) then
        return
    end

    ctrl.label:SetColor(unpack(ctrl.baseColor))

    if IsDebugLoggingEnabled() then
        local r, g, b, a = unpack(ctrl.baseColor)
        DebugLog(string.format(
            "Quest hover: restored base color r=%.3f g=%.3f b=%.3f a=%.3f",
            r or 0,
            g or 0,
            b or 0,
            a or 0
        ))
    end
end

local function ApplyBaseColor(control, r, g, b, a)
    if not control then
        return
    end

    local color = control.baseColor
    if type(color) ~= "table" then
        color = {}
        control.baseColor = color
    end

    color[1] = r or 1
    color[2] = g or 1
    color[3] = b or 1
    color[4] = a or 1

    if control.label and control.label.SetColor then
        control.label:SetColor(color[1], color[2], color[3], color[4])
    end
end

local function GetCurrentTimeSeconds()
    if QuestState and QuestState.GetCurrentTimeSeconds then
        return QuestState.GetCurrentTimeSeconds()
    end

    if GetFrameTimeSeconds then
        local ok, now = pcall(GetFrameTimeSeconds)
        if ok and type(now) == "number" then
            return now
        end
    end

    if GetGameTimeMilliseconds then
        local ok, ms = pcall(GetGameTimeMilliseconds)
        if ok and type(ms) == "number" then
            return ms / 1000
        end
    end

    if os and os.clock then
        return os.clock()
    end

    return 0
end

local function NormalizeCategoryKey(categoryKey)
    if QuestState and QuestState.NormalizeCategoryKey then
        return QuestState.NormalizeCategoryKey(categoryKey)
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

local function NormalizeQuestKey(journalIndex)
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

local function GetQuestKeyFromJournalIndex(journalIndex)
    return NormalizeQuestKey(journalIndex)
end

local function IsQuestSelectedInFilter(questKey)
    local questFilter = EnsureQuestFilterSavedVars()
    if QuestFilter and QuestFilter.IsQuestSelected then
        local ok, selected = pcall(QuestFilter.IsQuestSelected, questFilter, questKey)
        if ok then
            return selected == true
        end
    end

    local normalized = NormalizeQuestKey(questKey)
    if not normalized then
        return false
    end

    local selection = questFilter and questFilter.selection
    if type(selection) ~= "table" then
        return false
    end

    return selection[normalized] == true
end

function Nvk3UT.IsQuestTrackedForFilter(journalIndex)
    local normalizedIndex = tonumber(journalIndex)
    if not normalizedIndex or normalizedIndex <= 0 then
        return false
    end

    if DoesJournalQuestExist and not DoesJournalQuestExist(normalizedIndex) then
        return false
    end

    local questKey = GetQuestKeyFromJournalIndex(normalizedIndex)
    if not questKey then
        return false
    end

    return IsQuestSelectedInFilter(questKey)
end

local function IsQuestTrackedForFilter(journalIndex)
    return Nvk3UT.IsQuestTrackedForFilter(journalIndex)
end

local function ToggleQuestSelection(questKey, source)
    local questFilter = EnsureQuestFilterSavedVars()
    if not questFilter then
        return false
    end

    local changed = false
    if QuestFilter and QuestFilter.ToggleSelection then
        local ok, result = pcall(QuestFilter.ToggleSelection, questFilter, questKey)
        changed = ok and result ~= nil
    else
        local normalized = NormalizeQuestKey(questKey)
        if normalized then
            questFilter.selection = questFilter.selection or {}
            if questFilter.selection[normalized] == true then
                questFilter.selection[normalized] = nil
            else
                questFilter.selection[normalized] = true
            end
            changed = true
        end
    end

    if changed and RequestRefresh then
        RequestRefresh(source or "QuestSelectionToggle")
    end

    if changed and QUEST_JOURNAL_KEYBOARD and QUEST_JOURNAL_KEYBOARD.navigationTree then
        local tree = QUEST_JOURNAL_KEYBOARD.navigationTree
        if tree.RefreshVisible then
            tree:RefreshVisible()
        end
    end

    return changed
end

local function SelectQuestInFilter(journalIndex, source)
    if IsQuestTrackedForFilter(journalIndex) then
        return false
    end

    local questKey = GetQuestKeyFromJournalIndex(journalIndex)
    if not questKey then
        return false
    end

    ToggleQuestSelection(questKey, source or "QuestTracker:AutoTrackNewQuest")
    return true
end

local function DetermineQuestColorRole(quest)
    if not quest then
        return "entryTitle"
    end

    local questKey = NormalizeQuestKey(quest.journalIndex)
    local selected = false
    if questKey and state.selectedQuestKey then
        selected = questKey == state.selectedQuestKey
    end

    local tracked = false
    if state.trackedQuestIndex and quest.journalIndex then
        tracked = quest.journalIndex == state.trackedQuestIndex
    end

    local flags = quest.flags or {}
    local assisted = flags.assisted == true
    local watched = flags.tracked == true

    if assisted or selected or tracked then
        return "activeTitle"
    end

    -- Keep the legacy watcher branch in place even though it currently maps to the
    -- default entry color so future enhancements can differentiate it again without
    -- having to rediscover the selection logic.
    if watched then
        return "entryTitle"
    end

    return "entryTitle"
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

local function GetActiveCategories()
    if not (state.viewModel and type(state.viewModel.categories) == "table") then
        return nil
    end

    return state.viewModel.categories
end

local function ForEachQuest(callback)
    if type(callback) ~= "function" then
        return
    end

    local ordered = GetActiveCategories()
    if type(ordered) ~= "table" then
        return
    end

    for index = 1, #ordered do
        local category = ordered[index]
        if category and type(category.quests) == "table" then
            for questIndex = 1, #category.quests do
                local quest = category.quests[questIndex]
                if quest then
                    callback(quest, category)
                end
            end
        end
    end
end

local function ForEachQuestIndex(callback)
    if type(callback) ~= "function" then
        return
    end

    local visited = {}

    ForEachQuest(function(quest, category)
        if quest and quest.journalIndex then
            visited[quest.journalIndex] = true
            callback(quest.journalIndex, quest, category)
        end
    end)

    if not GetNumJournalQuests then
        return
    end

    local total = GetNumJournalQuests() or 0
    local maxIndex = MAX_JOURNAL_QUESTS or total
    if maxIndex and maxIndex > total then
        total = maxIndex
    end

    for index = 1, total do
        if not visited[index] then
            local isValid = true
            if IsValidJournalQuestIndex then
                isValid = IsValidJournalQuestIndex(index)
            elseif GetJournalQuestName then
                local name = GetJournalQuestName(index)
                isValid = name ~= nil and name ~= ""
            end

            if isValid then
                callback(index, nil, nil)
            end
        end
    end
end

local function CollectCategoryKeysForQuest(journalIndex)
    local questModel = Nvk3UT and Nvk3UT.QuestModel
    if questModel and questModel.GetCategoryKeysForQuestKey then
        local keys, found = questModel.GetCategoryKeysForQuestKey(journalIndex)
        if type(keys) == "table" then
            return keys, found
        end

        return {}, found
    end

    local keys = {}
    if not journalIndex then
        return keys, false
    end

    local found = false
    ForEachQuest(function(quest, category)
        if quest.journalIndex == journalIndex then
            found = true
            if category and category.key then
                local normalized = NormalizeCategoryKey(category.key)
                if normalized then
                    keys[normalized] = true
                end
            end
            if category and category.parent and category.parent.key then
                local normalizedParent = NormalizeCategoryKey(category.parent.key)
                if normalizedParent then
                    keys[normalizedParent] = true
                end
            end
        end
    end)

    return keys, found
end

local function ResolveStateSource(context, fallback)
    if type(context) == "string" then
        return ResolveStateSource({ trigger = context }, fallback)
    end

    if type(context) == "table" then
        if context.stateSource then
            return context.stateSource
        end

        local trigger = context.trigger
        if trigger == "click" or trigger == "manual" then
            return "manual"
        elseif trigger == "click-select" then
            return "click-select"
        elseif trigger == "external-select" or trigger == "external" then
            return "external-select"
        elseif trigger == "init" then
            return "init"
        elseif trigger == "auto" or trigger == "refresh" or trigger == "unknown" then
            return "auto"
        end
    end

    return fallback or "auto"
end

local function LogStateWrite(entity, key, expanded, source, priority)
    local debugCheck = IsDebugLoggingEnabled
    if type(debugCheck) ~= "function" or not debugCheck() then
        return
    end

    local formatted
    if entity == "cat" then
        formatted = string.format(
            "STATE_WRITE cat=%s expanded=%s source=%s prio=%d",
            tostring(key),
            tostring(expanded),
            tostring(source),
            priority or 0
        )
    elseif entity == "quest" then
        formatted = string.format(
            "STATE_WRITE quest=%s expanded=%s source=%s prio=%d",
            tostring(key),
            tostring(expanded),
            tostring(source),
            priority or 0
        )
    elseif entity == "active" then
        formatted = string.format(
            "STATE_WRITE active=%s source=%s prio=%d",
            tostring(key),
            tostring(source),
            priority or 0
        )
    end

    if formatted then
        DebugLog(formatted)
    end
end

-- TEMP SHIM (QMODEL_002): TODO remove on SWITCH token; forwards to QuestSelection for active-state ensures.
local function EnsureActiveSavedState()
    if QuestSelection and QuestSelection.EnsureActiveSavedState then
        return QuestSelection.EnsureActiveSavedState()
    end

    if QuestState and QuestState.EnsureActiveSavedState then
        return QuestState.EnsureActiveSavedState()
    end

    if not state.saved then
        return nil
    end

    local active = state.saved.active
    if type(active) ~= "table" then
        active = {
            questKey = nil,
            source = "init",
            ts = 0,
        }
        state.saved.active = active
    end

    if active.questKey ~= nil then
        active.questKey = NormalizeQuestKey(active.questKey)
    end

    if type(active.source) ~= "string" or active.source == "" then
        active.source = "init"
    end

    active.ts = tonumber(active.ts) or 0

    return active
end

local function SyncSelectedQuestFromSaved()
    local questKey

    if QuestSelection and QuestSelection.GetActiveQuestKey then
        questKey = QuestSelection.GetActiveQuestKey()
    elseif QuestState and QuestState.GetSelectedQuestId then
        questKey = QuestState.GetSelectedQuestId()
    elseif state.saved then
        local active = EnsureActiveSavedState()
        questKey = active and active.questKey or nil
    end

    if questKey ~= nil then
        questKey = NormalizeQuestKey(questKey)
    end

    state.selectedQuestKey = questKey

    return questKey
end

local function ApplyActiveQuestFromSaved()
    local questKey = SyncSelectedQuestFromSaved()
    local journalIndex = QuestKeyToJournalIndex(questKey)

    state.trackedQuestIndex = journalIndex

    if journalIndex then
        state.trackedCategoryKeys = CollectCategoryKeysForQuest(journalIndex)
    else
        state.trackedCategoryKeys = {}
    end

    return journalIndex
end

-- TEMP SHIM (QMODEL_001): TODO remove on SWITCH token; forwards category expansion state to Nvk3UT.QuestState.
local function WriteCategoryState(categoryKey, expanded, source, options)
    if QuestState and QuestState.SetCategoryExpanded then
        local changed, normalizedKey, newExpanded, priority, resolvedSource =
            QuestState.SetCategoryExpanded(categoryKey, expanded, source, options)
        if not changed then
            return false
        end

        LogStateWrite("cat", normalizedKey, newExpanded, resolvedSource or source or "auto", priority)
        return true
    end

    if not state.saved then
        return false
    end

    local key = NormalizeCategoryKey(categoryKey)
    if not key then
        return false
    end

    source = source or "auto"
    options = options or {}
    local manualCollapseRespected = options.manualCollapseRespected
    state.saved.cat = state.saved.cat or {}

    local prev = state.saved.cat[key]
    local previousManualCollapseRespected = prev and prev.manualCollapseRespected
    local priorityOverride = options.priorityOverride
    local priority = priorityOverride or PRIORITY[source] or 0
    local prevPriority = prev and (PRIORITY[prev.source] or 0) or 0
    local overrideTimestamp = tonumber(options.timestamp)
    local now = overrideTimestamp or GetCurrentTimeSeconds()
    local prevTs = (prev and prev.ts) or 0
    local forceWrite = options.force == true
    local allowTimestampRegression = options.allowTimestampRegression == true

    if prev and not forceWrite then
        if prevPriority > priority then
            return false
        end

        if prevPriority == priority and not allowTimestampRegression and now < prevTs then
            return false
        end
    end

    local newExpanded = expanded and true or false
    if manualCollapseRespected == nil then
        manualCollapseRespected = previousManualCollapseRespected
    end

    state.saved.cat[key] = {
        expanded = newExpanded,
        source = source,
        ts = now,
        manualCollapseRespected = manualCollapseRespected,
    }

    LogStateWrite("cat", key, newExpanded, source, priority)

    return true
end

-- TEMP SHIM (QMODEL_001): TODO remove on SWITCH token; forwards quest expansion state to Nvk3UT.QuestState.
local function WriteQuestState(questKey, expanded, source, options)
    if QuestState and QuestState.SetQuestExpanded then
        local changed, normalizedKey, newExpanded, priority, resolvedSource =
            QuestState.SetQuestExpanded(questKey, expanded, source, options)
        if not changed then
            return false
        end

        LogStateWrite("quest", normalizedKey, newExpanded, resolvedSource or source or "auto", priority)
        return true
    end

    if not state.saved then
        return false
    end

    local key = NormalizeQuestKey(questKey)
    if not key then
        return false
    end

    source = source or "auto"
    options = options or {}
    state.saved.quest = state.saved.quest or {}

    local prev = state.saved.quest[key]
    local priorityOverride = options.priorityOverride
    local priority = priorityOverride or PRIORITY[source] or 0
    local prevPriority = prev and (PRIORITY[prev.source] or 0) or 0
    local overrideTimestamp = tonumber(options.timestamp)
    local now = overrideTimestamp or GetCurrentTimeSeconds()
    local prevTs = (prev and prev.ts) or 0
    local forceWrite = options.force == true
    local allowTimestampRegression = options.allowTimestampRegression == true

    if prev and not forceWrite then
        if prevPriority > priority then
            return false
        end

        if prevPriority == priority and not allowTimestampRegression and now < prevTs then
            return false
        end
    end

    local newExpanded = expanded and true or false

    state.saved.quest[key] = {
        expanded = newExpanded,
        source = source,
        ts = now,
    }

    LogStateWrite("quest", key, newExpanded, source, priority)

    return true
end

-- TEMP SHIM (QMODEL_002): TODO remove on SWITCH token; forwards active quest state to QuestSelection.
local function WriteActiveQuest(questKey, source, options)
    if QuestSelection and QuestSelection.SetActive then
        local changed, normalizedKey, priority, resolvedSource =
            QuestSelection.SetActive(questKey, source, options)
        if not changed then
            return false
        end

        LogStateWrite("active", normalizedKey, nil, resolvedSource or source or "auto", priority)
        ApplyActiveQuestFromSaved()
        return true
    end

    if QuestState and QuestState.SetSelectedQuestId then
        local changed, normalizedKey, priority, resolvedSource =
            QuestState.SetSelectedQuestId(questKey, source, options)
        if not changed then
            return false
        end

        LogStateWrite("active", normalizedKey, nil, resolvedSource or source or "auto", priority)
        ApplyActiveQuestFromSaved()
        return true
    end

    if not state.saved then
        return false
    end

    source = source or "auto"
    options = options or {}
    local normalized = questKey and NormalizeQuestKey(questKey) or nil
    local prev = EnsureActiveSavedState()
    local priorityOverride = options.priorityOverride
    local priority = priorityOverride or PRIORITY[source] or 0
    local prevPriority = prev and (PRIORITY[prev.source] or 0) or 0
    local overrideTimestamp = tonumber(options.timestamp)
    local now = overrideTimestamp or GetCurrentTimeSeconds()
    local prevTs = (prev and prev.ts) or 0
    local forceWrite = options.force == true
    local allowTimestampRegression = options.allowTimestampRegression == true

    if prev and not forceWrite then
        if prevPriority > priority then
            return false
        end

        if prevPriority == priority and not allowTimestampRegression and now < prevTs then
            return false
        end
    end

    state.saved.active = {
        questKey = normalized,
        source = source,
        ts = now,
    }

    LogStateWrite("active", normalized, nil, source, priority)

    ApplyActiveQuestFromSaved()

    if normalized == nil then
        state.lastAutoExpandedQuestKey = nil
    end

    return true
end

local function PrimeInitialSavedState()
    if not state.saved then
        return
    end

    local ordered = GetActiveCategories()
    if type(ordered) ~= "table" then
        return
    end

    state.saved.initializedAt = state.saved.initializedAt or GetCurrentTimeSeconds()
    local initTimestamp = tonumber(state.saved.initializedAt) or GetCurrentTimeSeconds()

    local primedCategories = 0
    local primedQuests = 0

    for index = 1, #ordered do
        local category = ordered[index]
        if category then
            local catKey = NormalizeCategoryKey(category.key)
            if catKey then
                local entry = state.saved.cat and state.saved.cat[catKey]
                local entryTs = (entry and entry.ts) or 0
                if entryTs < initTimestamp or not entry then
                    if WriteCategoryState(catKey, true, "init", { timestamp = initTimestamp }) then
                        primedCategories = primedCategories + 1
                    end
                end
            end

            if type(category.quests) == "table" then
                for questIndex = 1, #category.quests do
                    local quest = category.quests[questIndex]
                    if quest then
                        local questKey = NormalizeQuestKey(quest.journalIndex)
                        if questKey then
                            local entry = state.saved.quest and state.saved.quest[questKey]
                            local entryTs = (entry and entry.ts) or 0
                            if entryTs < initTimestamp or not entry then
                                if WriteQuestState(questKey, true, "init", { timestamp = initTimestamp }) then
                                    primedQuests = primedQuests + 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local active = EnsureActiveSavedState()
    local activeTs = (active and active.ts) or 0
    if activeTs < initTimestamp then
        WriteActiveQuest(active and active.questKey or nil, "init", { timestamp = initTimestamp })
    end

    if IsDebugLoggingEnabled() and (primedCategories > 0 or primedQuests > 0) then
        DebugLog(string.format(
            "STATE_PRIME timestamp=%.3f categories=%d quests=%d",
            initTimestamp,
            primedCategories,
            primedQuests
        ))
    end
end

local function ApplyLabelDefaults(label)
    if not label or not label.SetHorizontalAlignment then
        return
    end

    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    if label.SetVerticalAlignment then
        label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    end
    if label.SetWrapMode then
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    end
end

local function ApplyToggleDefaults(toggle)
    if not toggle or not toggle.SetVerticalAlignment then
        return
    end

    toggle:SetVerticalAlignment(TEXT_ALIGN_TOP)
end

local function GetToggleWidth(toggle, fallback)
    if toggle then
        if toggle.GetWidth then
            local width = toggle:GetWidth()
            if width and width > 0 then
                return width
            end
        end
    end

    return fallback or 0
end

local function ResolveQuestDebugInfo(journalIndex)
    local info = { id = journalIndex or "-" }

    if not journalIndex then
        return info
    end

    local questName
    local categoryKey
    local categoryName

    ForEachQuest(function(quest, category)
        if quest and quest.journalIndex == journalIndex then
            questName = quest.name or questName
            if category then
                categoryKey = category.key or categoryKey
                categoryName = category.name or categoryName
            end
        end
    end)

    if (not questName or questName == "") and GetJournalQuestName then
        local ok, name = SafeCall(GetJournalQuestName, journalIndex)
        if ok and type(name) == "string" and name ~= "" then
            questName = name
        end
    end

    info.name = questName
    info.categoryId = categoryKey
    info.categoryName = categoryName

    return info
end

local function ResolveCategoryDebugInfo(categoryKey)
    local info = { id = categoryKey or "-" }

    if not categoryKey then
        return info
    end

    local ordered = GetActiveCategories()
    if type(ordered) == "table" then
        for index = 1, #ordered do
            local category = ordered[index]
            if category then
                if category.key == categoryKey then
                    info.name = category.name or info.name
                    return info
                end
                if category.parent and category.parent.key == categoryKey then
                    info.name = category.parent.name or info.name
                    return info
                end
            end
        end
    end

    ForEachQuest(function(_, category)
        if not category then
            return
        end
        if category.key == categoryKey then
            info.name = category.name or info.name
        elseif category.parent and category.parent.key == categoryKey then
            info.name = category.parent.name or info.name
        end
    end)

    return info
end

local function LogQuestSelectionChange(action, trigger, journalIndex, beforeSelectedId, afterSelectedId, source, extraFields)
    if not IsDebugLoggingEnabled() then
        return
    end

    local info = ResolveQuestDebugInfo(journalIndex)
    local fields = {
        { key = "id", value = info.id },
    }

    if info.name then
        fields[#fields + 1] = { key = "name", value = info.name, string = true }
    end
    if info.categoryId then
        fields[#fields + 1] = { key = "categoryId", value = info.categoryId }
    end
    if info.categoryName then
        fields[#fields + 1] = { key = "categoryName", value = info.categoryName, string = true }
    end

    fields[#fields + 1] = { key = "before.selectedId", value = beforeSelectedId }
    fields[#fields + 1] = { key = "after.selectedId", value = afterSelectedId }

    if type(extraFields) == "table" then
        for index = 1, #extraFields do
            fields[#fields + 1] = extraFields[index]
        end
    end

    if source then
        fields[#fields + 1] = { key = "source", value = source, string = true }
    end

    EmitDebugAction(action, trigger, "quest", fields)
end

local function LogQuestExpansion(action, trigger, journalIndex, beforeExpanded, afterExpanded, source, extraFields)
    if not IsDebugLoggingEnabled() then
        return
    end

    local info = ResolveQuestDebugInfo(journalIndex)
    local fields = {
        { key = "id", value = info.id },
    }

    if info.name then
        fields[#fields + 1] = { key = "name", value = info.name, string = true }
    end
    if info.categoryId then
        fields[#fields + 1] = { key = "categoryId", value = info.categoryId }
    end
    if info.categoryName then
        fields[#fields + 1] = { key = "categoryName", value = info.categoryName, string = true }
    end

    fields[#fields + 1] = { key = "before.expanded", value = beforeExpanded }
    fields[#fields + 1] = { key = "after.expanded", value = afterExpanded }

    if type(extraFields) == "table" then
        for index = 1, #extraFields do
            fields[#fields + 1] = extraFields[index]
        end
    end

    if source then
        fields[#fields + 1] = { key = "source", value = source, string = true }
    end

    EmitDebugAction(action, trigger, "quest", fields)
end

local function LogCategoryExpansion(action, trigger, categoryKey, beforeExpanded, afterExpanded, source, extraFields)
    if not IsDebugLoggingEnabled() then
        return
    end

    local info = ResolveCategoryDebugInfo(categoryKey)
    local fields = {
        { key = "id", value = info.id },
    }

    if info.name then
        fields[#fields + 1] = { key = "name", value = info.name, string = true }
    end

    fields[#fields + 1] = { key = "before.expanded", value = beforeExpanded }
    fields[#fields + 1] = { key = "after.expanded", value = afterExpanded }

    if type(extraFields) == "table" then
        for index = 1, #extraFields do
            fields[#fields + 1] = extraFields[index]
        end
    end

    if source then
        fields[#fields + 1] = { key = "source", value = source, string = true }
    end

    EmitDebugAction(action, trigger, "category", fields)
end

-- SafeCall implementation (assigned to the forward-declared upvalue above)
-- Hoisting this assignment prevents the quest-accept crash when ESO auto-assists a new quest.
SafeCall = function(func, ...)
    if type(func) ~= "function" then
        return false, nil
    end

    local ok, result = pcall(func, ...)
    if not ok then
        DebugLog("Call failed", tostring(result))
        return false, nil
    end

    return true, result
end

local function IsTruthy(value)
    return value ~= nil and value ~= false
end

local function NormalizeJournalIndex(journalIndex)
    local numeric = tonumber(journalIndex)
    if not numeric or numeric <= 0 then
        return nil
    end
    return numeric
end

local function QuestManagerCall(methodName, journalIndex)
    if not QUEST_JOURNAL_MANAGER or type(methodName) ~= "string" then
        return false, nil
    end

    local method = QUEST_JOURNAL_MANAGER[methodName]
    if type(method) ~= "function" then
        return false, nil
    end

    local ok, result = pcall(method, QUEST_JOURNAL_MANAGER, journalIndex)
    if not ok then
        DebugLog(string.format("QuestManager call failed (%s): %s", methodName, tostring(result)))
        return false, nil
    end

    return true, result
end

local function IsPlayerInGroup()
    if type(IsUnitGrouped) == "function" then
        local ok, grouped = SafeCall(IsUnitGrouped, "player")
        if ok then
            return grouped == true
        end
    end

    if type(GetGroupSize) == "function" then
        local ok, size = SafeCall(GetGroupSize)
        if ok then
            local numeric = tonumber(size) or 0
            return numeric > 1
        end
    end

    return false
end

local function CanQuestBeShared(journalIndex)
    local normalized = NormalizeJournalIndex(journalIndex)
    if not normalized then
        return false
    end

    if not IsPlayerInGroup() then
        return false
    end

    local managerOk, managerResult = QuestManagerCall("CanShareQuest", normalized)
    if managerOk and IsTruthy(managerResult) then
        return true
    end

    managerOk, managerResult = QuestManagerCall("CanShareQuestInJournal", normalized)
    if managerOk and IsTruthy(managerResult) then
        return true
    end

    if type(GetIsQuestSharable) == "function" then
        local ok, shareable = SafeCall(GetIsQuestSharable, normalized)
        if ok and IsTruthy(shareable) then
            return true
        end
    end

    return false
end

local function ShareQuestWithGroup(journalIndex)
    local normalized = NormalizeJournalIndex(journalIndex)
    if not normalized then
        return
    end

    local managerOk = QuestManagerCall("ShareQuest", normalized)
    if managerOk then
        return
    end

    if type(ShareQuest) == "function" then
        SafeCall(ShareQuest, normalized)
    end
end

local function CanQuestBeShownOnMap(journalIndex)
    local normalized = NormalizeJournalIndex(journalIndex)
    return normalized ~= nil
end

local function ShowQuestOnMap(journalIndex)
    local normalized = NormalizeJournalIndex(journalIndex)
    if not normalized then
        return
    end

    if type(ZO_WorldMap_ShowQuestOnMap) ~= "function" then
        return
    end

    if IsDebugLoggingEnabled() then
        DebugLog(string.format(
            "SHOW_QUEST_ON_MAP questIndex=%s normalized=%s",
            tostring(journalIndex),
            tostring(normalized)
        ))
    end

    -- Mirror the reference tracker by delegating straight to the base-game
    -- world map helper so the selected quest is highlighted using vanilla
    -- logic.
    SafeCall(ZO_WorldMap_ShowQuestOnMap, normalized)
end

local function CanQuestBeAbandoned(journalIndex)
    local normalized = NormalizeJournalIndex(journalIndex)
    if not normalized then
        return false
    end

    if type(IsJournalQuestAbandonable) == "function" then
        local ok, abandonable = SafeCall(IsJournalQuestAbandonable, normalized)
        if ok then
            return IsTruthy(abandonable)
        end
    end

    return true
end

local function ConfirmAbandonQuest(journalIndex)
    local normalized = NormalizeJournalIndex(journalIndex)
    if not normalized then
        return
    end

    local managerOk = QuestManagerCall("ConfirmAbandonQuest", normalized)
    if managerOk then
        return
    end

    if type(AbandonQuest) == "function" then
        SafeCall(AbandonQuest, normalized)
    end
end

local function BuildQuestContextMenuEntries(journalIndex)
    local entries = {}

    entries[#entries + 1] = {
        label = GetString(SI_NVK3UT_TRACKER_QUEST_CONTEXT_SHARE),
        enabled = function()
            return CanQuestBeShared(journalIndex)
        end,
        callback = function()
            if CanQuestBeShared(journalIndex) then
                ShareQuestWithGroup(journalIndex)
            end
        end,
    }

    entries[#entries + 1] = {
        label = GetString(SI_NVK3UT_TRACKER_QUEST_CONTEXT_SHOW_ON_MAP),
        enabled = function()
            return CanQuestBeShownOnMap(journalIndex)
        end,
        callback = function()
            ShowQuestOnMap(journalIndex)
        end,
    }

    entries[#entries + 1] = {
        label = GetString(SI_NVK3UT_TRACKER_QUEST_CONTEXT_ABANDON),
        enabled = function()
            return CanQuestBeAbandoned(journalIndex)
        end,
        callback = function()
            if CanQuestBeAbandoned(journalIndex) then
                ConfirmAbandonQuest(journalIndex)
            end
        end,
    }

    local questKey = NormalizeQuestKey(journalIndex)
    if IsQuestSelectionMode() and questKey then
        local isSelected = IsQuestSelectedInFilter(questKey)
        local label = GetString(SI_NVK3UT_TRACK_QUEST)
        if isSelected then
            label = GetString(SI_NVK3UT_UNTRACK_QUEST)
        end

        entries[#entries + 1] = {
            label = label,
            callback = function()
                ToggleQuestSelection(questKey, "QuestTracker:ContextMenu")
                RefreshQuestJournalSelectionKeyLabelText()
                UpdateQuestJournalSelectionKeyLabelVisibility("QuestTracker:ContextMenu")
            end,
        }
    end

    return entries
end

local function ShowQuestContextMenu(control, journalIndex)
    if not control then
        return
    end

    local entries = BuildQuestContextMenuEntries(journalIndex)
    if #entries == 0 then
        return
    end

    if Utils and Utils.ShowContextMenu and Utils.ShowContextMenu(control, entries) then
        return
    end

    if not (ClearMenu and AddCustomMenuItem and ShowMenu) then
        return
    end

    ClearMenu()

    local added = 0
    local function evaluateGate(gate)
        if gate == nil then
            return true
        end

        local gateType = type(gate)
        if gateType == "function" then
            local ok, result = pcall(gate, control)
            if not ok then
                return false
            end
            return result ~= false
        elseif gateType == "boolean" then
            return gate
        end

        return true
    end

    for index = 1, #entries do
        local entry = entries[index]
        if entry and type(entry.label) == "string" and type(entry.callback) == "function" then
            if evaluateGate(entry.visible) then
                local enabled = evaluateGate(entry.enabled)
                local itemType = (_G and _G.MENU_ADD_OPTION_LABEL) or 1
                local originalCallback = entry.callback
                local callback = originalCallback
                if type(originalCallback) == "function" then
                    callback = function(...)
                        if type(ClearMenu) == "function" then
                            pcall(ClearMenu)
                        end
                        originalCallback(...)
                    end
                end
                local beforeCount
                if type(ZO_Menu_GetNumMenuItems) == "function" then
                    local ok, count = pcall(ZO_Menu_GetNumMenuItems)
                    if ok and type(count) == "number" then
                        beforeCount = count
                    end
                end
                AddCustomMenuItem(entry.label, callback, itemType)
                local afterCount
                if type(ZO_Menu_GetNumMenuItems) == "function" then
                    local ok, count = pcall(ZO_Menu_GetNumMenuItems)
                    if ok and type(count) == "number" then
                        afterCount = count
                    end
                end
                local itemIndex = afterCount or ((type(beforeCount) == "number" and beforeCount + 1) or nil)
                if itemIndex and type(SetMenuItemEnabled) == "function" then
                    pcall(SetMenuItemEnabled, itemIndex, enabled ~= false)
                end
                added = added + 1
            end
        end
    end

    if added > 0 then
        ShowMenu(control)
    else
        ClearMenu()
    end
end

local questJournalSelectionKeybindDescriptor = nil
local questJournalSelectionKeybindEntry = nil
local questJournalSelectionKeyContainer = nil
local questJournalSelectionKeyLabel = nil
local questJournalSelectionDescLabel = nil
local questJournalEntryHooked = false
local questTrackIconMarkup = zo_iconFormat("/esoui/art/antiquities/antiquities_tabicon_scrying_up.dds", 16, 16)
local questJournalKeybindAdded = false
local questJournalKeybindHooked = false
local questJournalKeyLabelSceneHooked = false
local questJournalContextMenuHooked = false

local function GetFocusedQuestKey()
    local journalManager = QUEST_JOURNAL_MANAGER
    if not journalManager then
        if IsDebugLoggingEnabled() then
            DebugLog("GetFocusedQuestKey: journalManager missing")
        end
        return nil
    end

    local journalIndex = nil
    if type(journalManager.GetFocusedQuestIndex) == "function" then
        journalIndex = journalManager:GetFocusedQuestIndex()
    elseif type(GetFocusedQuestIndex) == "function" then
        journalIndex = GetFocusedQuestIndex()
    else
        if IsDebugLoggingEnabled() then
            DebugLog("GetFocusedQuestKey: no GetFocusedQuestIndex API available")
        end
        return nil
    end

    journalIndex = tonumber(journalIndex)
    if not journalIndex or journalIndex <= 0 then
        if IsDebugLoggingEnabled() then
            DebugLog("GetFocusedQuestKey: no focused quest index (%s)", tostring(journalIndex))
        end
        return nil
    end

    if DoesJournalQuestExist and not DoesJournalQuestExist(journalIndex) then
        return nil
    end

    local questKey = GetQuestKeyFromJournalIndex(journalIndex)
    if not questKey and IsDebugLoggingEnabled() then
        DebugLog("GetFocusedQuestKey: no questKey for journalIndex %s", tostring(journalIndex))
    end

    return questKey
end

local function ToggleFocusedQuestSelection(source)
    local questKey = GetFocusedQuestKey()
    DebugLog("QuestJournalKeybind.callback: questKey=%s", tostring(questKey))
    if not questKey then
        return
    end

    DebugLog("QuestJournalKeybind.callback: toggling selection and marking tracker dirty")
    ToggleQuestSelection(questKey, source or "QuestJournal:Keybind")
    UpdateQuestJournalSelectionKeyLabelVisibility("QuestJournal:KeybindToggle")
end

local function GetQuestJournalKeyLabelParent()
    if QUEST_JOURNAL_KEYBOARD and QUEST_JOURNAL_KEYBOARD.control then
        return QUEST_JOURNAL_KEYBOARD.control
    end

    return nil
end

local function ApplyQuestJournalTrackedIcon(control, questInfo)
    if not control or not questInfo then
        return
    end

    local journalIndex = questInfo.questIndex or (questInfo.data and questInfo.data.questIndex)
    if not journalIndex then
        return
    end

    local questName = questInfo.name
    if (not questName or questName == "") and GetJournalQuestName then
        questName = GetJournalQuestName(journalIndex)
    end

    if not questName or questName == "" then
        return
    end

    local label = control.text
    if not label and control.GetNamedChild then
        label = control:GetNamedChild("Text")
    end

    if not label or not label.SetText then
        return
    end

    if IsQuestTrackedForFilter(journalIndex) then
        label:SetText(string.format("%s %s", questName, questTrackIconMarkup))
    else
        label:SetText(questName)
    end
end

RefreshQuestJournalSelectionKeyLabelText = function()
    if not questJournalSelectionDescLabel then
        return
    end

    local journalIndex
    if GetFocusedQuestIndex then
        journalIndex = GetFocusedQuestIndex()
    end

    local stringId = SI_NVK3UT_TRACK_QUEST
    if IsQuestTrackedForFilter(journalIndex) then
        stringId = SI_NVK3UT_UNTRACK_QUEST
    end

    questJournalSelectionDescLabel:SetText(GetString(stringId))
end

UpdateQuestFilterKeybindLabelForActiveQuest = function()
    RefreshQuestJournalSelectionKeyLabelText()
end

local function EnsureQuestJournalKeyLabel()
    if questJournalSelectionKeyContainer and questJournalSelectionKeyContainer.SetHidden then
        return questJournalSelectionKeyContainer
    end

    local parent = GetQuestJournalKeyLabelParent()
    if not parent then
        if IsDebugLoggingEnabled() then
            DebugLog("QuestJournalKeybindLabel: parent control missing")
        end
        return nil
    end

    local containerName = string.format(
        "%sNvk3UTQuestSelectionKeyContainer",
        parent:GetName() or "Nvk3UTQuestSelectionKeyContainer"
    )
    questJournalSelectionKeyContainer = CreateControl(containerName, parent, CT_CONTROL)
    questJournalSelectionKeyContainer:SetHidden(true)
    questJournalSelectionKeyContainer:SetWidth(360)
    questJournalSelectionKeyContainer:ClearAnchors()
    questJournalSelectionKeyContainer:SetAnchor(BOTTOM, parent, BOTTOM, 5, -45)

    local keyLabelName = string.format("%sKey", containerName)
    questJournalSelectionKeyLabel = CreateControl(keyLabelName, questJournalSelectionKeyContainer, CT_LABEL)
    questJournalSelectionKeyLabel:SetFont("ZoFontKeybindStripKey")
    questJournalSelectionKeyLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    questJournalSelectionKeyLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    questJournalSelectionKeyLabel:ClearAnchors()

    local keyBgName = string.format("%sBg", containerName)
    local keyBg = CreateControl(keyBgName, questJournalSelectionKeyContainer, CT_BACKDROP)
    keyBg:SetCenterColor(0, 0, 0, 1)
    keyBg:SetEdgeColor(1, 1, 1, 1)
    keyBg:SetEdgeTexture(nil, 2, 2, 2, 2)
    keyBg:SetInsets(2, 2, -2, -2)
    keyBg:SetDrawLayer(DL_BACKGROUND)

    ZO_Keybindings_RegisterLabelForBindingUpdate(questJournalSelectionKeyLabel, "NVK3UT_TOGGLE_QUEST_SELECTION", true)

    local descLabelName = string.format("%sDesc", containerName)
    questJournalSelectionDescLabel = CreateControl(descLabelName, questJournalSelectionKeyContainer, CT_LABEL)
    questJournalSelectionDescLabel:SetFont("ZoFontKeybindStripDescription")
    questJournalSelectionDescLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    questJournalSelectionDescLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    do
        local r = 197 / 255
        local g = 194 / 255
        local b = 158 / 255
        local a = 1
        questJournalSelectionDescLabel:SetColor(r, g, b, a)
    end
    questJournalSelectionDescLabel:ClearAnchors()
    questJournalSelectionDescLabel:SetAnchor(CENTER, questJournalSelectionKeyContainer, CENTER, 0, 0)

    questJournalSelectionKeyLabel:SetAnchor(RIGHT, questJournalSelectionDescLabel, LEFT, -8, 0)
    keyBg:ClearAnchors()
    keyBg:SetAnchor(TOPLEFT, questJournalSelectionKeyLabel, TOPLEFT, -4, -2)
    keyBg:SetAnchor(BOTTOMRIGHT, questJournalSelectionKeyLabel, BOTTOMRIGHT, 4, 2)

    RefreshQuestJournalSelectionKeyLabelText()

    return questJournalSelectionKeyContainer
end

UpdateQuestJournalSelectionKeyLabelVisibility = function(reason)
    local label = EnsureQuestJournalKeyLabel()
    if not label then
        return
    end

    local shouldShow = IsQuestSelectionModeActive()
    if shouldShow then
        local isJournalShowing =
            (QUEST_JOURNAL_SCENE and QUEST_JOURNAL_SCENE.IsShowing and QUEST_JOURNAL_SCENE:IsShowing())
            or (SCENE_MANAGER and SCENE_MANAGER.IsShowing and SCENE_MANAGER:IsShowing("journal"))
        shouldShow = isJournalShowing
    end

    if shouldShow then
        shouldShow = GetFocusedQuestKey() ~= nil
    end

    label:SetHidden(not shouldShow)
    if shouldShow then
        RefreshQuestJournalSelectionKeyLabelText()
    end
end

local function EnsureQuestJournalKeybind()
    if questJournalSelectionKeybindDescriptor and questJournalSelectionKeybindEntry then
        return
    end

    local function isSelectionAvailable()
        local mode = GetQuestFilterMode()
        local focusedKey = GetFocusedQuestKey()
        DebugLog(
            "QuestJournalKeybind.visible: mode=%s, focusedKey=%s",
            tostring(mode),
            tostring(focusedKey)
        )
        return IsQuestSelectionModeActive() and focusedKey ~= nil
    end

    questJournalSelectionKeybindEntry = {
        name = function()
            return GetString(SI_NVK3UT_QUEST_SELECTION_KEYBIND)
        end,
        keybind = "UI_SHORTCUT_SECONDARY",
        callback = function()
            DebugLog("QuestJournalKeybind.callback: pressed")
            ToggleFocusedQuestSelection("QuestJournal:Keybind")
        end,
        visible = isSelectionAvailable,
        enabled = isSelectionAvailable,
    }

    questJournalSelectionKeybindDescriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        questJournalSelectionKeybindEntry,
    }

    Nvk3UT.questJournalSelectionKeybindDescriptor = questJournalSelectionKeybindDescriptor
end

local function HookQuestJournalKeybind()
    if questJournalKeybindHooked then
        return
    end

    DebugLog("QuestJournalKeybind: HookQuestJournalKeybind called")

    EnsureQuestJournalKeybind()
    EnsureQuestJournalKeyLabel()

    if not questJournalKeyLabelSceneHooked then
        local questJournalScene = QUEST_JOURNAL_SCENE
            or (SCENE_MANAGER and SCENE_MANAGER.GetScene and SCENE_MANAGER:GetScene("journal"))
        if questJournalScene and questJournalScene.RegisterCallback then
            questJournalScene:RegisterCallback("StateChange", function(_, newState)
                if newState == SCENE_SHOWING or newState == SCENE_HIDDEN then
                    UpdateQuestJournalSelectionKeyLabelVisibility("SceneChange")
                end
            end)
            questJournalKeyLabelSceneHooked = true
        end
    end

    if not (ZO_PostHook and ZO_QuestJournal_Keyboard) then
        return
    end

    ZO_PostHook(ZO_QuestJournal_Keyboard, "InitializeKeybindStripDescriptors", function(self)
        DebugLog("QuestJournalKeybind: InitializeKeybindStripDescriptors posthook")

        if questJournalKeybindAdded then
            DebugLog("QuestJournalKeybind: already added, skipping")
            return
        end

        local descriptorList = self and self.keybindStripDescriptor
        if type(descriptorList) ~= "table" then
            DebugLog("QuestJournalKeybind: keybindStripDescriptor missing")
            return
        end

        if not questJournalSelectionKeybindEntry then
            DebugLog("QuestJournalKeybind: keybind entry missing")
            return
        end

        table.insert(descriptorList, questJournalSelectionKeybindEntry)
        questJournalKeybindAdded = true
        DebugLog("QuestJournalKeybind: appended selection keybind descriptor")

        UpdateQuestJournalSelectionKeyLabelVisibility("KeybindDescriptorAdded")
    end)

    questJournalKeybindHooked = true
end

local function AppendQuestJournalContextMenu(control, button, upInside)
    DebugLog(
        "ContextMenuHook: OnMouseUp btn=%s inside=%s mode=%s",
        tostring(button),
        tostring(upInside),
        tostring(GetQuestFilterMode())
    )

    if button ~= MOUSE_BUTTON_INDEX_RIGHT then
        DebugLog("QuestJournalContextMenu: exit (not right mouse button)")
        return
    end

    if not upInside then
        DebugLog("QuestJournalContextMenu: exit (not upInside)")
        return
    end

    if not IsQuestSelectionModeActive() then
        DebugLog("QuestJournalContextMenu: exit (not selection mode)")
        return
    end

    local questIndex
    if control then
        local node = control.node
        local data = node and node.data
        questIndex = data and data.questIndex
    end

    if not questIndex then
        DebugLog("QuestJournalContextMenu: exit (no questIndex)")
        return
    end

    local questKey = GetQuestKeyFromJournalIndex(questIndex)
    if not questKey then
        DebugLog("QuestJournalContextMenu: exit (no questKey for questIndex %s)", tostring(questIndex))
        return
    end

    if not AddCustomMenuItem then
        return
    end

    local isSelected = IsQuestSelectedInFilter(questKey)
    DebugLog(
        "QuestJournalContextMenu: questKey=%s, selected=%s",
        tostring(questKey),
        tostring(isSelected)
    )

    local label = GetString(isSelected and SI_NVK3UT_UNTRACK_QUEST or SI_NVK3UT_TRACK_QUEST)

    AddCustomMenuItem(label, function()
        ToggleQuestSelection(questKey, "QuestJournal:ContextMenu")
        if RequestRefresh then
            RequestRefresh("QuestJournal:ContextMenu")
        end
        DebugLog("QuestJournalContextMenu: toggled selection for questKey=%s", tostring(questKey))
        RefreshQuestJournalSelectionKeyLabelText()
        UpdateQuestJournalSelectionKeyLabelVisibility("QuestJournal:ContextMenu")
    end)

    if ShowMenu then
        ShowMenu(control)
    end
end

local function HookQuestJournalContextMenu()
    if questJournalContextMenuHooked then
        DebugLog("QuestJournalContextMenu: Hook already registered, skipping")
        return
    end

    DebugLog("QuestJournalContextMenu: HookQuestJournalContextMenu called")

    if ZO_PostHook then
        ZO_PostHook("ZO_QuestJournalNavigationEntry_OnMouseUp", function(control, button, upInside)
            AppendQuestJournalContextMenu(control, button, upInside)
        end)
        DebugLog("QuestJournalContextMenu: PostHook on ZO_QuestJournalNavigationEntry_OnMouseUp registered")
        questJournalContextMenuHooked = true
    end
end

local function HookQuestJournalNavigationEntryTemplate()
    if questJournalEntryHooked then
        return
    end

    local navigationTree = QUEST_JOURNAL_KEYBOARD and QUEST_JOURNAL_KEYBOARD.navigationTree
    local templateInfo = navigationTree and navigationTree.templateInfo
    local template = templateInfo and templateInfo["ZO_QuestJournalNavigationEntry"]
    local setupFunction = template and template.setupFunction

    if not template then
        return
    end

    template.setupFunction = function(control, questInfo, ...)
        if type(setupFunction) == "function" then
            setupFunction(control, questInfo, ...)
        end
        ApplyQuestJournalTrackedIcon(control, questInfo)
    end

    questJournalEntryHooked = true
end

local function LogExternalSelect(questId)
    if not IsDebugLoggingEnabled() then
        return
    end

    DebugLog(string.format("EXTERNAL_SELECT questId=%s", tostring(questId)))
end

local function LogExpandCategory(categoryId, reason)
    if not IsDebugLoggingEnabled() then
        return
    end

    DebugLog(string.format(
        "EXPAND_CATEGORY categoryId=%s reason=%s",
        tostring(categoryId),
        reason or "external-select"
    ))
end

local function LogMissingCategory(questId)
    if not IsDebugLoggingEnabled() then
        return
    end

    DebugLog(string.format("WARN missing-category questId=%s", tostring(questId)))
end

local function LogScrollIntoView(questId)
    if not IsDebugLoggingEnabled() then
        return
    end

    DebugLog(string.format("SCROLL_INTO_VIEW questId=%s", tostring(questId)))
end

local function ExpandCategoriesForExternalSelect(journalIndex)
    if not (state.saved and journalIndex) then
        return false, false
    end

    local keys, found = CollectCategoryKeysForQuest(journalIndex)
    local expandedAny = false

    if keys then
        local debugEnabled = IsDebugLoggingEnabled()
        local context = {
            trigger = "external-select",
            source = "QuestTracker:ExpandCategoriesForExternalSelect",
            forceWrite = true,
        }

        for key in pairs(keys) do
            if key and SetCategoryExpanded then
                local manualCollapseRespected =
                    type(IsCategoryManualCollapseRespected) == "function"
                    and IsCategoryManualCollapseRespected(key)
                    or false
                if manualCollapseRespected then
                    if debugEnabled then
                        DebugLog(
                            string.format(
                                "CATEGORY_EXPAND_SKIP manual collapse respected (external-select) cat=%s",
                                tostring(key)
                            )
                        )
                    end
                else
                    local changed = SetCategoryExpanded(key, true, context)
                    if changed then
                        expandedAny = true
                        LogExpandCategory(key, "external-select")
                    end
                end
            end
        end
    end

    if (not found) or not keys or next(keys) == nil then
        LogMissingCategory(journalIndex)
    end

    if expandedAny and RequestRefresh then
        RequestRefresh("QuestTracker:ExpandCategoriesForExternalSelect")
    end

    return expandedAny, found
end

local function ExpandCategoriesForClickSelect(journalIndex)
    if not (state.saved and journalIndex) then
        return false, false
    end

    local keys, found = CollectCategoryKeysForQuest(journalIndex)
    local expandedAny = false

    if keys then
        local debugEnabled = IsDebugLoggingEnabled()
        local context = {
            trigger = "click-select",
            source = "QuestTracker:ExpandCategoriesForClickSelect",
        }

        for key in pairs(keys) do
            if key and SetCategoryExpanded then
                local manualCollapseRespected =
                    type(IsCategoryManualCollapseRespected) == "function"
                    and IsCategoryManualCollapseRespected(key)
                    or false
                if manualCollapseRespected then
                    if debugEnabled then
                        DebugLog(
                            string.format(
                                "CATEGORY_EXPAND_SKIP manual collapse respected (click-select) cat=%s",
                                tostring(key)
                            )
                        )
                    end
                else
                    local changed = SetCategoryExpanded(key, true, context)
                    if changed then
                        expandedAny = true
                        LogExpandCategory(key, "click-select")
                    end
                end
            end
        end
    end

    if (not found) or not keys or next(keys) == nil then
        LogMissingCategory(journalIndex)
    end

    if expandedAny and RequestRefresh then
        RequestRefresh("QuestTracker:ExpandCategoriesForClickSelect")
    end

    return expandedAny, found
end

local function FindQuestControlByJournalIndex(journalIndex)
    if not journalIndex then
        return nil
    end

    if state.questControls then
        local numeric = tonumber(journalIndex) or journalIndex
        local control = state.questControls[numeric]
        if control then
            return control
        end
    end

    for index = 1, #state.orderedControls do
        local control = state.orderedControls[index]
        if control and control.rowType == "quest" then
            local questData = control.data and control.data.quest
            if questData and questData.journalIndex == journalIndex then
                return control
            end
        end
    end

    return nil
end

local function EnsureQuestRowVisible(journalIndex, options)
    options = options or {}
    local allowQueue = options.allowQueue ~= false

    local control = FindQuestControlByJournalIndex(journalIndex)
    if not control or (control.IsHidden and control:IsHidden()) then
        if allowQueue and journalIndex then
            state.pendingExternalReveal = { questId = journalIndex }
        end
        return false
    end

    local host = Nvk3UT and Nvk3UT.TrackerHost
    if not (host and host.ScrollControlIntoView) then
        if allowQueue and journalIndex then
            state.pendingExternalReveal = { questId = journalIndex }
        end
        return false
    end

    local ok, ensured = pcall(host.ScrollControlIntoView, control)
    if not ok or not ensured then
        if allowQueue and journalIndex then
            state.pendingExternalReveal = { questId = journalIndex }
        end
        return false
    end

    LogScrollIntoView(journalIndex)

    return true
end

local function ProcessPendingExternalReveal()
    local pending = state.pendingExternalReveal
    if not pending then
        return
    end

    state.pendingExternalReveal = nil
    EnsureQuestRowVisible(pending.questId, { allowQueue = false })
end

local function DoesJournalQuestExist(journalIndex)
    if not (journalIndex and GetJournalQuestName) then
        return false
    end

    local ok, name = SafeCall(GetJournalQuestName, journalIndex)
    if not ok then
        return false
    end

    if type(name) ~= "string" then
        return false
    end

    return name ~= ""
end

GetFocusedQuestIndex = function()
    if QUEST_JOURNAL_MANAGER and QUEST_JOURNAL_MANAGER.GetFocusedQuestIndex then
        local ok, focused = SafeCall(function(manager)
            return manager:GetFocusedQuestIndex()
        end, QUEST_JOURNAL_MANAGER)
        if ok then
            local numeric = tonumber(focused)
            if numeric and numeric > 0 then
                return numeric
            end
        end
    end

    return nil
end

local function UpdateTrackedQuestCache(forcedIndex, context)
    local function normalize(index)
        local numeric = tonumber(index)
        if not numeric or numeric <= 0 then
            return nil
        end

        if DoesJournalQuestExist(numeric) then
            return numeric
        end

        return nil
    end

    local trackedIndex = normalize(forcedIndex)
    local allowFocusFallback = not state.pendingDeselection

    if not trackedIndex and GetTrackedQuestIndex then
        local ok, current = SafeCall(GetTrackedQuestIndex)
        if ok then
            trackedIndex = normalize(current)
        end
    end

    if not trackedIndex and allowFocusFallback then
        trackedIndex = normalize(GetFocusedQuestIndex())
    end

    if not trackedIndex and not state.pendingDeselection then
        local active = EnsureActiveSavedState()
        local savedActive = active and active.questKey
        trackedIndex = normalize(savedActive)
    end

    if not trackedIndex then
        ForEachQuest(function(quest)
            if trackedIndex then
                return
            end

            if not (quest and quest.flags and quest.flags.tracked) then
                return
            end

            local fallbackIndex = normalize(quest.journalIndex) or tonumber(quest.journalIndex)
            if fallbackIndex and fallbackIndex > 0 then
                trackedIndex = fallbackIndex
            end
        end)
    end

    if trackedIndex then
        state.pendingDeselection = false
        local sourceTag = ResolveStateSource(context, "auto")
        local writeOptions
        if context and context.isExternal then
            writeOptions = { force = true }
        end
        WriteActiveQuest(trackedIndex, sourceTag, writeOptions)
    else
        ApplyActiveQuestFromSaved()
    end
end

local function EnsureQuestTrackedState(journalIndex)
    if not (journalIndex and IsJournalQuestTracked and SetTracked) then
        return
    end

    if IsJournalQuestTracked(journalIndex) then
        return
    end

    if not SafeCall(SetTracked, TRACK_TYPE_QUEST, journalIndex, true) then
        SafeCall(SetTracked, TRACK_TYPE_QUEST, journalIndex)
    end
end

local function ClearOtherTrackedQuests(journalIndex)
    if not IsJournalQuestTracked then
        return
    end

    ForEachQuestIndex(function(index)
        if index and index ~= journalIndex and IsJournalQuestTracked(index) then
            local cleared = false
            if SetTracked then
                cleared = SafeCall(SetTracked, TRACK_TYPE_QUEST, index, false)
                if not cleared then
                    cleared = SafeCall(SetTracked, TRACK_TYPE_QUEST, index)
                end
            end
            if not cleared and QUEST_JOURNAL_MANAGER and QUEST_JOURNAL_MANAGER.StopTrackingQuest then
                SafeCall(function(manager, questIndex)
                    manager:StopTrackingQuest(questIndex)
                end, QUEST_JOURNAL_MANAGER, index)
            end
        end
    end)
end

local function EnsureExclusiveAssistedQuest(journalIndex)
    local numeric = tonumber(journalIndex)
    if not numeric or numeric <= 0 then
        return
    end

    if AssistJournalQuest then
        SafeCall(AssistJournalQuest, numeric)
        return
    end

    if not (type(SetTrackedIsAssisted) == "function" and TRACK_TYPE_QUEST) then
        return
    end

    local function SetAssisted(questIndex, assisted)
        SafeCall(SetTrackedIsAssisted, TRACK_TYPE_QUEST, assisted == true, questIndex)
    end

    ForEachQuestIndex(function(index)
        if not index then
            return
        end

        local isTarget = index == numeric
        local shouldAssist = isTarget and true or false

        if isTarget then
            SetAssisted(index, shouldAssist)
        elseif type(GetTrackedIsAssisted) == "function" then
            local ok, assisted = SafeCall(GetTrackedIsAssisted, TRACK_TYPE_QUEST, index)
            if ok and assisted then
                SetAssisted(index, false)
            end
        end
    end)
end

local function ApplyImmediateTrackedQuest(journalIndex, stateSource)
    if not journalIndex then
        return false
    end

    state.lastTrackedBeforeSync = state.trackedQuestIndex

    local sourceTag = stateSource or "auto"
    local changed = WriteActiveQuest(journalIndex, sourceTag)
    if not changed then
        ApplyActiveQuestFromSaved()
    end

    state.pendingDeselection = false

    return changed
end

local function AutoExpandQuestForTracking(journalIndex, forceExpand, context)
    if not (state.saved and journalIndex) then
        return
    end

    if forceExpand == false then
        DebugDeselect("AutoExpandQuestForTracking:skipped", {
            journalIndex = journalIndex,
            forceExpand = tostring(forceExpand),
        })
        return
    end

    local questKey = NormalizeQuestKey(journalIndex)

    DebugDeselect("AutoExpandQuestForTracking", {
        journalIndex = journalIndex,
        forceExpand = tostring(forceExpand),
        previous = tostring(
            state.saved
                and state.saved.quest
                and state.saved.quest[questKey]
                and state.saved.quest[questKey].expanded
        ),
    })

    local logContext = {
        trigger = (context and context.trigger) or "auto",
        source = (context and context.source) or "QuestTracker:AutoExpandQuestForTracking",
    }

    if context then
        if context.stateSource ~= nil then
            logContext.stateSource = context.stateSource
        end
        if context.forceWrite then
            logContext.forceWrite = true
        end
        if context.priorityOverride ~= nil then
            logContext.priorityOverride = context.priorityOverride
        end
    end

    if logContext.priorityOverride == nil then
        logContext.priorityOverride = PRIORITY.tracked
    end

    SetQuestExpanded(journalIndex, true, logContext)
end

local function EnsureTrackedCategoriesExpanded(journalIndex, forceExpand, context)
    if not (state.saved and journalIndex) then
        return
    end

    if forceExpand == false then
        DebugDeselect("EnsureTrackedCategoriesExpanded:skipped", {
            journalIndex = journalIndex,
            forceExpand = tostring(forceExpand),
        })
        return
    end

    local keys = CollectCategoryKeysForQuest(journalIndex)
    local logContext = {
        trigger = (context and context.trigger) or "auto",
        source = (context and context.source) or "QuestTracker:EnsureTrackedCategoriesExpanded",
    }

    local debugEnabled = IsDebugLoggingEnabled()

    for key in pairs(keys) do
        if key then
            local manualCollapseRespected =
                type(IsCategoryManualCollapseRespected) == "function"
                and IsCategoryManualCollapseRespected(key)
                or false
            if manualCollapseRespected then
                if debugEnabled then
                    DebugLog(
                        string.format(
                            "CATEGORY_EXPAND_SKIP manual collapse respected (tracked) cat=%s trigger=%s",
                            tostring(key),
                            tostring(logContext.trigger)
                        )
                    )
                end
            else
                local changed = SetCategoryExpanded(key, true, logContext)
                if debugEnabled and not changed then
                    DebugLog(
                        "Category expand skipped",
                        "category",
                        key,
                        "journalIndex",
                        journalIndex,
                        "trigger",
                        logContext.trigger
                    )
                end
            end
        end
    end
end

local function EnsureTrackedQuestVisible(journalIndex, forceExpand, context)
    if not journalIndex then
        return
    end

    DebugDeselect("EnsureTrackedQuestVisible", {
        journalIndex = journalIndex,
        forceExpand = tostring(forceExpand),
    })
    local logContext = {
        trigger = (context and context.trigger) or "auto",
        source = (context and context.source) or "QuestTracker:EnsureTrackedQuestVisible",
    }
    if context and context.stateSource ~= nil then
        logContext.stateSource = context.stateSource
    end
    local isExternal = context and context.isExternal
    local isNewTarget = context and context.isNewTarget
    local questKey = NormalizeQuestKey and NormalizeQuestKey(journalIndex)

    local shouldAutoExpand = forceExpand
    if shouldAutoExpand == nil then
        shouldAutoExpand = isNewTarget
    end
    if shouldAutoExpand == nil and questKey then
        shouldAutoExpand = questKey ~= state.lastAutoExpandedQuestKey
    end
    if shouldAutoExpand == nil then
        shouldAutoExpand = false
    end
    if isExternal then
        LogExternalSelect(journalIndex)
        ExpandCategoriesForExternalSelect(journalIndex)
    elseif shouldAutoExpand then
        local expansionContext = {
            trigger = logContext.trigger,
            source = logContext.source,
            stateSource = logContext.stateSource,
            priorityOverride = PRIORITY.tracked,
        }
        EnsureTrackedCategoriesExpanded(journalIndex, forceExpand, expansionContext)
    end
    if isExternal and isNewTarget then
        logContext.forceWrite = true
    end
    if shouldAutoExpand then
        local questContext = {
            trigger = logContext.trigger,
            source = logContext.source,
            stateSource = logContext.stateSource,
            priorityOverride = PRIORITY.tracked,
            forceWrite = logContext.forceWrite,
        }
        AutoExpandQuestForTracking(journalIndex, forceExpand, questContext)
        if questKey then
            state.lastAutoExpandedQuestKey = questKey
        end
    elseif IsDebugLoggingEnabled() then
        DebugLog(
            string.format(
                "AUTO_EXPAND_SKIP quest=%s newTarget=%s forceExpand=%s",
                tostring(questKey),
                tostring(isNewTarget),
                tostring(forceExpand)
            )
        )
    end
    if isExternal then
        EnsureQuestRowVisible(journalIndex, { allowQueue = true })
    end
end

local function SyncTrackedQuestState(forcedIndex, forceExpand, context)
    if state.syncingTrackedState then
        DebugDeselect("SyncTrackedQuestState:reentry", {
            forcedIndex = forcedIndex,
            forceExpand = tostring(forceExpand),
        })
        return
    end

    context = context or {}
    state.syncingTrackedState = true

    repeat
        local previousTracked = state.lastTrackedBeforeSync
        if previousTracked == nil then
            previousTracked = state.trackedQuestIndex
        end

        UpdateTrackedQuestCache(forcedIndex, context)
        state.lastTrackedBeforeSync = nil

        local currentTracked = state.trackedQuestIndex
        local shouldForceExpand = forceExpand == true
        local pending = state.pendingSelection
        local pendingApplied = false
        local expansionChanged = false
        local skipVisibilityUpdate = false

        DebugDeselect("SyncTrackedQuestState:enter", {
            forcedIndex = forcedIndex,
            forceExpand = tostring(forceExpand),
            previousTracked = tostring(previousTracked),
            currentTracked = tostring(currentTracked),
            pendingIndex = pending and pending.index,
            pendingDeselection = tostring(state.pendingDeselection),
        })

        if previousTracked and (not currentTracked or currentTracked == previousTracked) and IsJournalQuestTracked then
            local ok, trackedState = SafeCall(IsJournalQuestTracked, previousTracked)
            if ok and not trackedState then
                DebugDeselect("SyncTrackedQuestState:deselect-detected", {
                    previousTracked = previousTracked,
                    currentTracked = tostring(currentTracked),
                    forcedIndex = forcedIndex,
                    pendingDeselection = tostring(state.pendingDeselection),
                })
                if currentTracked == previousTracked then
                    state.trackedQuestIndex = nil
                    state.trackedCategoryKeys = {}
                    currentTracked = nil
                end
                state.pendingDeselection = true
                shouldForceExpand = false
                skipVisibilityUpdate = true
            end
        end

        local trigger = context.trigger
        if not trigger and pending and pending.trigger then
            trigger = pending.trigger
        end
        if not trigger then
            if context.isExternal then
                trigger = "external"
            else
                trigger = "unknown"
            end
        end

        local source = context.source or (pending and pending.source) or "QuestTracker:SyncTrackedQuestState"
        local isExternalFlag = context.isExternal
        if isExternalFlag == nil and trigger == "external" then
            isExternalFlag = true
        end

        if pending and currentTracked == pending.index then
            local wasExpandedBefore = IsQuestExpanded(currentTracked)
            pendingApplied = true
            local pendingContext = {
                trigger = pending.trigger or trigger,
                source = pending.source or source,
            }
            expansionChanged = SetQuestExpanded(currentTracked, pending.expanded, pendingContext) or expansionChanged

            if pending.forceExpand ~= nil then
                shouldForceExpand = pending.forceExpand and true or false
            elseif pending.expanded then
                shouldForceExpand = true
            else
                shouldForceExpand = false
            end

            DebugDeselect("SyncTrackedQuestState:pending-applied", {
                index = currentTracked,
                expandedBefore = tostring(wasExpandedBefore),
                expandedAfter = tostring(IsQuestExpanded(currentTracked)),
                shouldForceExpand = tostring(shouldForceExpand),
            })
        end

        state.pendingSelection = nil

        if currentTracked and state.suppressForceExpandFor and state.suppressForceExpandFor == currentTracked then
            if not (pendingApplied and shouldForceExpand) then
                shouldForceExpand = false
            end
            state.suppressForceExpandFor = nil
        elseif not currentTracked or state.suppressForceExpandFor ~= currentTracked then
            state.suppressForceExpandFor = nil
        end

        if currentTracked then
            state.pendingDeselection = false
        end

        if currentTracked
            and isExternalFlag
            and previousTracked == currentTracked
            and not pendingApplied
            and (not pending or pending.index ~= currentTracked)
        then
            shouldForceExpand = false
            skipVisibilityUpdate = true
            DebugDeselect("SyncTrackedQuestState:external-refresh-skip-expand", {
                index = tostring(currentTracked),
                previousTracked = tostring(previousTracked),
                pendingApplied = tostring(pendingApplied),
                pendingIndex = pending and tostring(pending.index) or "nil",
            })
        end

        if currentTracked and not skipVisibilityUpdate and previousTracked and currentTracked == previousTracked and not pendingApplied and not forcedIndex then
            if IsJournalQuestTracked then
                local ok, trackedState = SafeCall(IsJournalQuestTracked, currentTracked)
                if ok and not trackedState then
                    skipVisibilityUpdate = true
                    shouldForceExpand = false
                    DebugDeselect("SyncTrackedQuestState:skip-visibility", {
                        index = currentTracked,
                        trackedState = tostring(trackedState),
                    })
                end
            end
        end

        local isNewTarget = currentTracked and currentTracked ~= previousTracked

        if currentTracked and not skipVisibilityUpdate then
            DebugDeselect("SyncTrackedQuestState:ensure-visible", {
                index = currentTracked,
                shouldForceExpand = tostring(shouldForceExpand),
            })
            local visibilityContext = {
                trigger = trigger,
                source = source,
                isExternal = isExternalFlag,
                isNewTarget = isNewTarget,
            }
            EnsureTrackedQuestVisible(currentTracked, shouldForceExpand, visibilityContext)
        else
            DebugDeselect("SyncTrackedQuestState:skip-ensure-visible", {
                index = tostring(currentTracked),
                skipVisibilityUpdate = tostring(skipVisibilityUpdate),
            })
        end

        if previousTracked ~= currentTracked then
            if previousTracked then
                local deselectFields
                if IsDebugLoggingEnabled() then
                    deselectFields = {
                        { key = "inDeselect", value = state.pendingDeselection },
                    }
                    if isExternalFlag ~= nil then
                        deselectFields[#deselectFields + 1] = { key = "isExternal", value = isExternalFlag }
                    end
                end
                LogQuestSelectionChange(
                    "deselect",
                    trigger,
                    previousTracked,
                    previousTracked,
                    currentTracked,
                    source,
                    deselectFields
                )
            end

            if currentTracked then
                local selectFields
                if IsDebugLoggingEnabled() and isExternalFlag ~= nil then
                    selectFields = {
                        { key = "isExternal", value = isExternalFlag },
                    }
                end
                LogQuestSelectionChange(
                    "select",
                    trigger,
                    currentTracked,
                    previousTracked,
                    currentTracked,
                    source,
                    selectFields
                )
            end
        end

        if not state.isInitialized then
            break
        end

        local hasTracked = currentTracked ~= nil
        local hadTracked = previousTracked ~= nil

    if RequestRefresh and (previousTracked ~= currentTracked or hasTracked or hadTracked or pendingApplied or expansionChanged) then
        RequestRefresh("QuestTracker:SyncTrackedQuestState")
    end
    until true

    if state.pendingDeselection and not state.trackedQuestIndex then
        local clearSource = ResolveStateSource(context, "auto")
        WriteActiveQuest(nil, clearSource)
        state.pendingDeselection = false
    end

    state.syncingTrackedState = false
end

local function FocusQuestInJournal(journalIndex)
    if not (QUEST_JOURNAL_KEYBOARD and QUEST_JOURNAL_KEYBOARD.FocusQuestWithIndex) then
        return
    end

    SafeCall(function(journal, index)
        journal:FocusQuestWithIndex(index)
    end, QUEST_JOURNAL_KEYBOARD, journalIndex)
end

local function ForceAssistTrackedQuest(journalIndex)
    if not (FOCUSED_QUEST_TRACKER and FOCUSED_QUEST_TRACKER.ForceAssist) then
        return
    end

    SafeCall(function(tracker, index)
        tracker:ForceAssist(index)
    end, FOCUSED_QUEST_TRACKER, journalIndex)
end

local function RequestRefreshInternal(reason)
    local controller = Nvk3UT and Nvk3UT.QuestTrackerController
    if controller and controller.RequestRefresh then
        controller:RequestRefresh(reason)
        return
    end

    local runtime = Nvk3UT and Nvk3UT.TrackerRuntime
    if runtime and runtime.QueueDirty then
        runtime:QueueDirty("quest")
    end
end

RequestRefresh = RequestRefreshInternal

local function TrackQuestByJournalIndex(journalIndex, options)
    local numeric = tonumber(journalIndex)
    if not numeric or numeric <= 0 then
        return false
    end

    if state.opts.autoTrack == false then
        return false
    end

    options = options or {}

    local actionContext = {
        trigger = options.trigger or "auto",
        source = options.source or "QuestTracker:TrackQuestByJournalIndex",
    }

    if options.stateSource then
        actionContext.stateSource = options.stateSource
    end

    state.pendingDeselection = false

    DebugDeselect("TrackQuestByJournalIndex", {
        journalIndex = numeric,
        forceExpand = tostring(options.forceExpand),
        skipAutoExpand = tostring(options.skipAutoExpand),
        pendingSelection = state.pendingSelection and state.pendingSelection.index,
    })

    if options.skipAutoExpand then
        state.suppressForceExpandFor = numeric
    else
        if options.forceExpand == false then
            state.suppressForceExpandFor = numeric
        else
            state.suppressForceExpandFor = nil
        end
        AutoExpandQuestForTracking(numeric, options.forceExpand, actionContext)
        EnsureTrackedCategoriesExpanded(numeric, options.forceExpand, actionContext)
    end

    if options.applyImmediate ~= false then
        ApplyImmediateTrackedQuest(numeric, ResolveStateSource(actionContext, "auto"))
    end

    if SetTrackedQuestIndex then
        SafeCall(SetTrackedQuestIndex, numeric)
    elseif QUEST_JOURNAL_MANAGER and QUEST_JOURNAL_MANAGER.SetTrackedQuestIndex then
        SafeCall(function(manager, index)
            manager:SetTrackedQuestIndex(index)
        end, QUEST_JOURNAL_MANAGER, numeric)
    end

    FocusQuestInJournal(numeric)
    ForceAssistTrackedQuest(numeric)
    EnsureQuestTrackedState(numeric)
    ClearOtherTrackedQuests(numeric)
    EnsureExclusiveAssistedQuest(numeric)

    local shouldRequestRefresh = options.requestRefresh
    if shouldRequestRefresh == nil then
        shouldRequestRefresh = true
    end

    if shouldRequestRefresh then
        RequestRefresh()
    end

    return true
end

HandleQuestRowClick = function(journalIndex)
    local questId = tonumber(journalIndex)
    if not questId or questId <= 0 then
        return
    end

    if state.isClickSelectInProgress then
        if IsDebugLoggingEnabled() then
            DebugLog(string.format("CLICK_SELECT_SKIPPED questId=%s reason=in-progress", tostring(questId)))
        end
        return
    end

    state.isClickSelectInProgress = true

    if IsDebugLoggingEnabled() then
        DebugLog(string.format("CLICK_SELECT_START questId=%s", tostring(questId)))
    end

    state.pendingSelection = nil

    local previousQuest = state.trackedQuestIndex
    local previousQuestString = previousQuest and tostring(previousQuest) or "nil"

    ApplyImmediateTrackedQuest(questId, "click-select")

    if IsDebugLoggingEnabled() then
        DebugLog(string.format("SET_ACTIVE questId=%s prev=%s", tostring(questId), previousQuestString))
    end

    RequestRefresh()

    if IsDebugLoggingEnabled() then
        DebugLog(string.format("UI_SELECT questId=%s", tostring(questId)))
    end

    local nextExpanded = not IsQuestExpanded(questId)
    state.pendingSelection = {
        index = questId,
        expanded = nextExpanded,
        forceExpand = nextExpanded,
        trigger = "click",
        source = "QuestTracker:HandleQuestRowClick",
    }

    SetQuestExpanded(questId, nextExpanded, {
        trigger = "click-select",
        source = "QuestTracker:HandleQuestRowClick",
    })

    ExpandCategoriesForClickSelect(questId)

    EnsureQuestRowVisible(questId, { allowQueue = false })

    state.isClickSelectInProgress = false

    FlushPendingTrackedQuestUpdate()

    local trackOptions = {
        forceExpand = nextExpanded,
        trigger = "click",
        source = "QuestTracker:OnRowClick",
        skipAutoExpand = true,
        applyImmediate = false,
        requestRefresh = false,
        stateSource = "click-select",
    }

    local tracked = TrackQuestByJournalIndex(questId, trackOptions)

    if tracked then
        ProcessTrackedQuestUpdate(TRACK_TYPE_QUEST, {
            trigger = "click",
            source = "QuestTracker:HandleQuestRowClick",
            forcedIndex = questId,
            forceExpand = nextExpanded,
            isExternal = false,
            stateSource = "click-select",
        })
    else
        state.pendingSelection = nil
    end

    RequestRefresh()

    if IsDebugLoggingEnabled() then
        DebugLog(string.format("CLICK_SELECT_END questId=%s", tostring(questId)))
    end
end

local function AdoptTrackedQuestOnInit()
    local journalIndex = state.trackedQuestIndex

    if not journalIndex or journalIndex <= 0 then
        journalIndex = GetFocusedQuestIndex()
    end

    if (not journalIndex or journalIndex <= 0) and GetTrackedQuestIndex then
        local ok, current = SafeCall(GetTrackedQuestIndex)
        if ok then
            local numeric = tonumber(current)
            if numeric and numeric > 0 then
                journalIndex = numeric
            end
        end
    end

    if not journalIndex or journalIndex <= 0 then
        return
    end

    if not state.trackedQuestIndex then
        ApplyImmediateTrackedQuest(journalIndex, "init")
    end

    EnsureTrackedQuestVisible(journalIndex, true, {
        trigger = "init",
        source = "QuestTracker:AdoptTrackedQuestOnInit",
    })

    if state.opts.autoTrack == false then
        return
    end

    local currentTracked = nil
    if GetTrackedQuestIndex then
        local ok, current = SafeCall(GetTrackedQuestIndex)
        if ok then
            currentTracked = tonumber(current)
        end
    end

    if currentTracked ~= journalIndex then
        TrackQuestByJournalIndex(journalIndex, {
            forceExpand = true,
            trigger = "init",
            source = "QuestTracker:AdoptTrackedQuestOnInit",
        })
        return
    end

    ForceAssistTrackedQuest(journalIndex)
    EnsureQuestTrackedState(journalIndex)
    ClearOtherTrackedQuests(journalIndex)
    EnsureExclusiveAssistedQuest(journalIndex)
end

ProcessTrackedQuestUpdate = function(trackingType, context)
    if trackingType and trackingType ~= TRACK_TYPE_QUEST then
        return
    end

    local resolvedContext = context or {}

    if not resolvedContext.trigger then
        if state.pendingSelection and state.pendingSelection.trigger then
            resolvedContext.trigger = state.pendingSelection.trigger
        elseif resolvedContext.isExternal == false then
            resolvedContext.trigger = "unknown"
        else
            resolvedContext.trigger = "external"
        end
    end

    if resolvedContext.isExternal == nil then
        resolvedContext.isExternal = resolvedContext.trigger ~= "click"
    end

    if not resolvedContext.source then
        resolvedContext.source = "QuestTracker:OnTrackedQuestUpdate"
    end

    local forcedIndex = resolvedContext.forcedIndex

    SyncTrackedQuestState(forcedIndex, true, resolvedContext)
end

local function OnTrackedQuestUpdate(_, trackingType, context)
    if state.isClickSelectInProgress then
        state.pendingTrackedUpdate = {
            trackingType = trackingType,
            context = context,
        }
        return
    end

    ProcessTrackedQuestUpdate(trackingType, context)

    if trackingType == TRACK_TYPE_QUEST then
        UpdateQuestFilterKeybindLabelForActiveQuest(context)
    end
end

local function ResolveTrackedQuestAfterQuestAdded()
    local trackedIndex

    if GetTrackedQuestIndex then
        local ok, current = SafeCall(GetTrackedQuestIndex)
        if ok then
            local numeric = tonumber(current)
            if numeric and numeric > 0 then
                trackedIndex = numeric
            end
        end
    end

    if not trackedIndex then
        trackedIndex = GetFocusedQuestIndex()
    end

    if trackedIndex and trackedIndex > 0 and DoesJournalQuestExist(trackedIndex) then
        return trackedIndex
    end

    return nil
end

local function SyncActiveQuestForAutoTrack(journalIndex, questKey)
    if not journalIndex or journalIndex <= 0 then
        return
    end

    local normalizedQuestKey = questKey or GetQuestKeyFromJournalIndex(journalIndex)

    local function execute()
        local trackedIndex = ResolveTrackedQuestAfterQuestAdded()

        DebugLog(
            "QuestAdded: tracked/assisted after accept = %s (added=%s)",
            tostring(trackedIndex),
            tostring(journalIndex)
        )

        if trackedIndex == journalIndex then
            DebugLog("QuestAdded: Auto-track detected -> syncing active questKey %s", tostring(normalizedQuestKey))
            WriteActiveQuest(normalizedQuestKey, "auto")
        else
            DebugLog("QuestAdded: Auto-track not detected -> no sync")
        end
    end

    if zo_callLater then
        zo_callLater(execute, 0)
    else
        execute()
    end
end

local function ShouldAutoTrackNewQuest()
    if not IsQuestSelectionMode() then
        return false
    end

    local questFilter = EnsureQuestFilterSavedVars()
    if not questFilter then
        return false
    end

    return questFilter.autoTrackNewQuestsInSelectionMode ~= false
end

local function OnQuestAdded(_, journalIndex)
    local numericIndex = tonumber(journalIndex)
    local questKey = GetQuestKeyFromJournalIndex(journalIndex)

    DebugLog("QUEST_ADDED received: journalIndex=%s questKey=%s", tostring(numericIndex), tostring(questKey))

    if numericIndex then
        SyncActiveQuestForAutoTrack(numericIndex, questKey)
    end

    if not ShouldAutoTrackNewQuest() then
        return
    end

    if not numericIndex or numericIndex <= 0 then
        return
    end

    if SelectQuestInFilter(numericIndex, "QuestTracker:OnQuestAdded") then
        UpdateQuestFilterKeybindLabelForActiveQuest(numericIndex)
    end
end

FlushPendingTrackedQuestUpdate = function()
    local pending = state.pendingTrackedUpdate
    if not pending then
        return
    end

    state.pendingTrackedUpdate = nil
    ProcessTrackedQuestUpdate(pending.trackingType, pending.context)
end

local function OnFocusedTrackerAssistChanged(_, assistedData)
    local questIndex = assistedData and assistedData.arg1
    if questIndex ~= nil then
        local numeric = tonumber(questIndex)
        if numeric and numeric > 0 then
            SyncTrackedQuestState(numeric, true, {
                trigger = "external",
                source = "QuestTracker:OnFocusedTrackerAssistChanged",
                isExternal = true,
            })
            UpdateQuestFilterKeybindLabelForActiveQuest(questIndex)
            return
        end
    end

    SyncTrackedQuestState(nil, true, {
        trigger = "external",
        source = "QuestTracker:OnFocusedTrackerAssistChanged",
        isExternal = true,
    })
    UpdateQuestFilterKeybindLabelForActiveQuest()
end

local function OnPlayerActivated()
    local function execute()
        SyncTrackedQuestState(nil, true, {
            trigger = "init",
            source = "QuestTracker:OnPlayerActivated",
            isExternal = true,
        })
    end

    if zo_callLater then
        zo_callLater(execute, 20)
    else
        execute()
    end
end

local function RegisterTrackingEvents()
    if state.trackingEventsRegistered then
        return
    end

    if EVENT_MANAGER then
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "TrackUpdate", EVENT_TRACKING_UPDATE, OnTrackedQuestUpdate)
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
        EVENT_MANAGER:RegisterForEvent(EVENT_NAMESPACE .. "QuestAdded", EVENT_QUEST_ADDED, OnQuestAdded)
    end

    if FOCUSED_QUEST_TRACKER and FOCUSED_QUEST_TRACKER.RegisterCallback then
        FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerAssistStateChanged", OnFocusedTrackerAssistChanged)
    end

    state.trackingEventsRegistered = true
end

local function UnregisterTrackingEvents()
    if not state.trackingEventsRegistered then
        return
    end

    if EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "TrackUpdate", EVENT_TRACKING_UPDATE)
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "PlayerActivated", EVENT_PLAYER_ACTIVATED)
        EVENT_MANAGER:UnregisterForEvent(EVENT_NAMESPACE .. "QuestAdded", EVENT_QUEST_ADDED)
    end

    if FOCUSED_QUEST_TRACKER and FOCUSED_QUEST_TRACKER.UnregisterCallback then
        FOCUSED_QUEST_TRACKER:UnregisterCallback("QuestTrackerAssistStateChanged", OnFocusedTrackerAssistChanged)
    end

    state.trackingEventsRegistered = false
end

local function NotifyHostContentChanged()
    local host = Nvk3UT and Nvk3UT.TrackerHost
    if not (host and host.NotifyContentChanged) then
        return
    end

    pcall(host.NotifyContentChanged)
end

local function NotifyStatusRefresh()
    local ui = Nvk3UT and Nvk3UT.UI
    if ui and ui.UpdateStatus then
        ui.UpdateStatus()
    end
end

local function EnsureSavedVars()
    Nvk3UT.sv = Nvk3UT.sv or {}

    local questRoot =
        (Nvk3UT.QuestModel and Nvk3UT.QuestModel.GetSavedVars and Nvk3UT.QuestModel.GetSavedVars())
        or Nvk3UT.sv

    if QuestState and QuestState.Bind then
        local saved = QuestState.Bind(questRoot)
        state.saved = saved
        if QuestSelection and QuestSelection.Bind then
            QuestSelection.Bind(questRoot, saved)
        end
    else
        local root = questRoot or Nvk3UT.sv or {}
        local saved = root.QuestTracker or {}
        root.QuestTracker = saved
        state.saved = saved
        EnsureActiveSavedState()
        if QuestSelection and QuestSelection.Bind then
            QuestSelection.Bind(root, saved)
        end
    end

    EnsureQuestFilterSavedVars()
    ApplyActiveQuestFromSaved()
end

local function ApplyFont(label, font, fallback)
    if not label or not label.SetFont then
        return
    end
    local resolved = font
    if resolved == nil or resolved == "" then
        resolved = fallback
    end
    if resolved == nil or resolved == "" then
        return
    end
    label:SetFont(resolved)
end

local function ResolveFont(fontId)
    if not fontId or fontId == "" then
        return nil
    end

    if type(fontId) == "string" then
        return fontId
    end

    return nil
end

local function MergeFonts(opts)
    local fonts = {}
    fonts.category = ResolveFont(opts.category) or DEFAULT_FONTS.category
    fonts.quest = ResolveFont(opts.quest) or DEFAULT_FONTS.quest
    fonts.condition = ResolveFont(opts.condition) or DEFAULT_FONTS.condition
    fonts.toggle = ResolveFont(opts.toggle) or DEFAULT_FONTS.toggle
    return fonts
end

local function BuildFontString(descriptor, fallback)
    if type(descriptor) ~= "table" then
        return ResolveFont(descriptor) or fallback
    end

    local face = descriptor.face or descriptor.path
    local size = descriptor.size
    local outline = descriptor.outline or DEFAULT_FONT_OUTLINE

    if not face or face == "" or not size then
        return fallback
    end

    return string.format("%s|%d|%s", face, size, outline or DEFAULT_FONT_OUTLINE)
end

local function ResetLayoutState()
    if QuestTrackerLayout and QuestTrackerLayout.ResetLayoutState then
        QuestTrackerLayout:ResetLayoutState()
    end
end

local function ReleaseAll(pool)
    if pool then
        pool:ReleaseAllObjects()
    end
end

local function AnchorControl(control, indentX)
    if QuestTrackerLayout and QuestTrackerLayout.AnchorControl then
        return QuestTrackerLayout:AnchorControl(control, indentX)
    end
end

local function UpdateContentSize()
    if not (QuestTrackerLayout and QuestTrackerLayout.UpdateContentSize) then
        return
    end

    QuestTrackerLayout:UpdateContentSize()

    if QuestTrackerLayout.state and state then
        state.contentWidth = QuestTrackerLayout.state.contentWidth
        state.contentHeight = QuestTrackerLayout.state.contentHeight
    end
end

local function SelectCategoryToggleTexture(expanded, isMouseOver)
    local textures = expanded and CATEGORY_TOGGLE_TEXTURES.expanded or CATEGORY_TOGGLE_TEXTURES.collapsed
    if isMouseOver then
        return textures.over
    end
    return textures.up
end

local function UpdateCategoryToggle(control, expanded)
    if not (control and control.toggle and control.toggle.SetTexture) then
        return
    end

    local isMouseOver = false
    if control.IsMouseOver and control:IsMouseOver() then
        isMouseOver = true
    elseif control.toggle and control.toggle.IsMouseOver and control.toggle:IsMouseOver() then
        isMouseOver = true
    end

    local texture = SelectCategoryToggleTexture(expanded, isMouseOver)
    control.toggle:SetTexture(texture)
    if control.toggle.SetTextureRotation then
        local align = "left"
        local host = Nvk3UT and Nvk3UT.TrackerHost
        if host and type(host.GetContentAlignment) == "function" then
            local ok, value = pcall(host.GetContentAlignment, host)
            if ok and type(value) == "string" and value ~= "" then
                align = string.lower(value)
            end
        end

        local rotation = 0
        local texturePath = nil
        if align == "right" and expanded and host and type(host.ApplyChevronVisualTopRightExpanded) == "function" then
            texturePath, rotation = host.ApplyChevronVisualTopRightExpanded(control.toggle)
        else
            if align == "right" and not expanded then
                rotation = math.pi
            end
            control.toggle:SetTextureRotation(rotation, 0.5, 0.5)
        end

        local lastExpanded = control.__lastChevronExpanded
        if align == "right" and expanded and lastExpanded ~= expanded and IsDebugLoggingEnabled() then
            if texturePath == nil and control.toggle.GetTextureFileName then
                local okTexture, resolved = pcall(control.toggle.GetTextureFileName, control.toggle)
                if okTexture then
                    texturePath = resolved
                end
            end
            DebugLog(string.format(
                "CategoryChevron Quest align=%s expanded=%s texture=%s rotation=%s",
                tostring(align),
                tostring(expanded),
                tostring(texturePath),
                tostring(rotation)
            ))
        end
        control.__lastChevronExpanded = expanded
    end
    control.isExpanded = expanded and true or false
end

local function UpdateQuestIconSlot(control)
    if not (control and control.iconSlot) then
        return
    end

    local questData = control.data and control.data.quest
    local isSelected = false
    if questData then
        local questKey = NormalizeQuestKey(questData.journalIndex)
        if questKey and state.selectedQuestKey then
            isSelected = questKey == state.selectedQuestKey
        elseif state.trackedQuestIndex then
            isSelected = questData.journalIndex == state.trackedQuestIndex
        end
    end

    if isSelected then
        if control.iconSlot.SetTexture then
            control.iconSlot:SetTexture(QUEST_SELECTED_ICON_TEXTURE)
        end
        if control.iconSlot.SetAlpha then
            control.iconSlot:SetAlpha(1)
        end
        if control.iconSlot.SetHidden then
            control.iconSlot:SetHidden(false)
        end
    else
        if control.iconSlot.SetTexture then
            control.iconSlot:SetTexture(nil)
        end
        if control.iconSlot.SetAlpha then
            control.iconSlot:SetAlpha(0)
        end
        if control.iconSlot.SetHidden then
            control.iconSlot:SetHidden(false)
        end
    end
end

local function GetDefaultCategoryExpanded()
    if QuestState and QuestState.GetCategoryDefaultExpanded then
        local savedDefault = QuestState.GetCategoryDefaultExpanded()
        if savedDefault ~= nil then
            return savedDefault and true or false
        end
    elseif state.saved and state.saved.defaults and state.saved.defaults.categoryExpanded ~= nil then
        return state.saved.defaults.categoryExpanded and true or false
    end

    return state.opts.autoExpand ~= false
end

local function GetDefaultQuestExpanded()
    if QuestState and QuestState.GetQuestDefaultExpanded then
        local savedDefault = QuestState.GetQuestDefaultExpanded()
        if savedDefault ~= nil then
            return savedDefault and true or false
        end
    elseif state.saved and state.saved.defaults and state.saved.defaults.questExpanded ~= nil then
        return state.saved.defaults.questExpanded and true or false
    end

    return state.opts.autoExpand ~= false
end

local function IsCategoryExpanded(categoryKey)
    local key = NormalizeCategoryKey(categoryKey)
    if not key then
        return GetDefaultCategoryExpanded()
    end

    if QuestState and QuestState.IsCategoryExpanded then
        local stored = QuestState.IsCategoryExpanded(key)
        if stored ~= nil then
            return stored and true or false
        end
    elseif state.saved and state.saved.cat then
        local entry = state.saved.cat[key]
        if entry and entry.expanded ~= nil then
            return entry.expanded and true or false
        end
    end

    return GetDefaultCategoryExpanded()
end

local function IsCategoryManualCollapseRespected(categoryKey)
    local key = NormalizeCategoryKey(categoryKey)
    if not key then
        return false
    end

    if QuestState and QuestState.GetCategoryManualCollapseRespected then
        local stored = QuestState.GetCategoryManualCollapseRespected(key)
        if stored ~= nil then
            return stored and true or false
        end
    elseif state.saved and state.saved.cat then
        local entry = state.saved.cat[key]
        if entry and entry.manualCollapseRespected ~= nil then
            return entry.manualCollapseRespected and true or false
        end
    end

    return false
end

IsQuestExpanded = function(journalIndex)
    local key = NormalizeQuestKey(journalIndex)
    if not key then
        return GetDefaultQuestExpanded()
    end

    if QuestState and QuestState.IsQuestExpanded then
        local stored = QuestState.IsQuestExpanded(key)
        if stored ~= nil then
            return stored and true or false
        end
    elseif state.saved and state.saved.quest then
        local entry = state.saved.quest[key]
        if entry and entry.expanded ~= nil then
            return entry.expanded and true or false
        end
    end

    return GetDefaultQuestExpanded()
end

SetCategoryExpanded = function(categoryKey, expanded, context)
    if not state.saved then
        EnsureSavedVars()
    end

    local key = NormalizeCategoryKey(categoryKey)
    if not key then
        return false
    end

    local beforeExpanded = IsCategoryExpanded(key)
    local stateSource = ResolveStateSource(context, expanded and "auto" or "auto")
    local writeOptions
    if context and context.forceWrite and expanded and not beforeExpanded then
        writeOptions = { force = true }
    end

    if context and (context.trigger == "click" or context.trigger == "click-select") then
        writeOptions = writeOptions or {}
        writeOptions.force = true
        writeOptions.allowTimestampRegression = true
    end

    local manualCollapseRespected
    if expanded == false then
        if context and context.manualCollapseRespected ~= nil then
            manualCollapseRespected = context.manualCollapseRespected and true or false
        elseif context and context.trigger == "click" then
            manualCollapseRespected = true
        end
    else
        manualCollapseRespected = false
    end

    if manualCollapseRespected ~= nil then
        writeOptions = writeOptions or {}
        writeOptions.manualCollapseRespected = manualCollapseRespected
    end

    if context and context.priorityOverride ~= nil then
        writeOptions = writeOptions or {}
        writeOptions.priorityOverride = context.priorityOverride
    end

    local changed = WriteCategoryState(key, expanded, stateSource, writeOptions)
    if not changed then
        return false
    end

    DebugDeselect("SetCategoryExpanded", {
        categoryKey = key,
        previous = tostring(beforeExpanded),
        newValue = tostring(expanded),
    })

    local manualCollapseRespected
    if context and context.manualCollapseRespected ~= nil then
        manualCollapseRespected = context.manualCollapseRespected and true or false
    elseif context and context.trigger == "click" then
        manualCollapseRespected = true
    end

    local extraFields
    if IsDebugLoggingEnabled() then
        if manualCollapseRespected ~= nil then
            extraFields = extraFields or {}
            extraFields[#extraFields + 1] = {
                key = "manualCollapseRespected",
                value = manualCollapseRespected,
            }
        end
    end

    LogCategoryExpansion(
        expanded and "expand" or "collapse",
        (context and context.trigger) or "unknown",
        key,
        beforeExpanded,
        expanded,
        (context and context.source) or "QuestTracker:SetCategoryExpanded",
        extraFields
    )

    return true
end

SetQuestExpanded = function(journalIndex, expanded, context)
    if not state.saved then
        EnsureSavedVars()
    end

    local key = NormalizeQuestKey(journalIndex)
    if not key then
        return false
    end

    local beforeExpanded = IsQuestExpanded(key)
    local stateSource = ResolveStateSource(context, expanded and "auto" or "auto")
    local writeOptions
    if context and context.forceWrite and expanded and not beforeExpanded then
        writeOptions = { force = true }
    end

    if context and (context.trigger == "click" or context.trigger == "click-select") then
        writeOptions = writeOptions or {}
        writeOptions.force = true
        writeOptions.allowTimestampRegression = true
    end

    if context and context.priorityOverride ~= nil then
        writeOptions = writeOptions or {}
        writeOptions.priorityOverride = context.priorityOverride
    end

    local changed = WriteQuestState(key, expanded, stateSource, writeOptions)
    if not changed then
        return false
    end

    DebugDeselect("SetQuestExpanded", {
        journalIndex = key,
        previous = tostring(beforeExpanded),
        newValue = tostring(expanded),
    })

    local numericIndex = QuestKeyToJournalIndex(key) or key

    LogQuestExpansion(
        expanded and "expand" or "collapse",
        (context and context.trigger) or "unknown",
        numericIndex,
        beforeExpanded,
        expanded,
        (context and context.source) or "QuestTracker:SetQuestExpanded"
    )

    return true
end

local function ToggleCategoryExpansion(categoryKey, expanded, context)
    if not categoryKey then
        return false
    end

    local targetExpanded = expanded
    if targetExpanded == nil then
        targetExpanded = not IsCategoryExpanded(categoryKey)
    end

    local toggleContext = context or {}
    if toggleContext.trigger == nil then
        toggleContext = {
            trigger = "unknown",
            source = toggleContext.source,
        }
    elseif toggleContext.source == nil then
        toggleContext = {
            trigger = toggleContext.trigger,
            source = nil,
        }
    end

    if not toggleContext.source then
        toggleContext.source = "QuestTracker:ToggleCategoryExpansion"
    end

    local changed = SetCategoryExpanded(categoryKey, targetExpanded, toggleContext)
    if changed then
        if RequestRefresh then
            RequestRefresh(toggleContext.source)
        end
        ScheduleToggleFollowup("questCategoryToggle")
    end

    return changed
end

local function ToggleQuestExpansion(journalIndex, context)
    if not journalIndex then
        return false
    end

    local expanded = IsQuestExpanded(journalIndex)
    local toggleContext = context or {}
    if toggleContext.trigger == nil then
        toggleContext = {
            trigger = "unknown",
            source = toggleContext.source,
        }
    elseif toggleContext.source == nil then
        toggleContext = {
            trigger = toggleContext.trigger,
            source = nil,
        }
    end
    if not toggleContext.source then
        toggleContext.source = "QuestTracker:ToggleQuestExpansion"
    end

    local changed = SetQuestExpanded(journalIndex, not expanded, toggleContext)
    if changed then
        if RequestRefresh then
            RequestRefresh(toggleContext.source)
        end
        ScheduleToggleFollowup("questEntryToggle")
    end

    return changed
end

local function FormatConditionText(condition)
    if not condition then
        return ""
    end

    local text = condition.displayText or condition.text
    if type(text) ~= "string" or text == "" then
        return ""
    end

    if condition.isTurnIn then
        text = string.format("* %s", text)
    end

    if zo_strformat then
        return zo_strformat("<<1>>", text)
    end

    return text
end

local function InitializeCategoryControl(control)
    if not control or control.initialized then
        return
    end

    control.label = control:GetNamedChild("Label")
    control.toggle = control:GetNamedChild("Toggle")
    control.indentAnchor = control:GetNamedChild("IndentAnchor")
    if control.toggle and control.toggle.SetTexture then
        control.toggle:SetTexture(SelectCategoryToggleTexture(false, false))
    end
    control.isExpanded = false
    control:SetHandler("OnMouseUp", function(ctrl, button, upInside)
        if not upInside or button ~= MOUSE_BUTTON_INDEX_LEFT then
            return
        end
        local catKey = ctrl.categoryKey or (ctrl.data and ctrl.data.categoryKey)
        if not catKey then
            return
        end
        local expanded = not IsCategoryExpanded(catKey)
        ToggleCategoryExpansion(catKey, expanded, {
            trigger = "click",
            source = "QuestTracker:OnCategoryClick",
        })
    end)
    control:SetHandler("OnMouseEnter", function(ctrl)
        ApplyMouseoverHighlight(ctrl)
        local expanded = ctrl.isExpanded
        if expanded == nil then
            local catKey = ctrl.categoryKey or (ctrl.data and ctrl.data.categoryKey)
            expanded = IsCategoryExpanded(catKey)
        end
        UpdateCategoryToggle(ctrl, expanded)
    end)
    control:SetHandler("OnMouseExit", function(ctrl)
        RestoreBaseColor(ctrl)
        local expanded = ctrl.isExpanded
        if expanded == nil then
            local catKey = ctrl.categoryKey or (ctrl.data and ctrl.data.categoryKey)
            expanded = IsCategoryExpanded(catKey)
        end
        UpdateCategoryToggle(ctrl, expanded)
    end)
    control.initialized = true
end

local function AcquireCategoryControl(providedControl)
    local control, key

    if providedControl ~= nil then
        control = providedControl
        key = providedControl.poolKey
    else
        control, key = state.categoryPool:AcquireObject()
    end

    if not control then
        return nil, key
    end

    InitializeCategoryControl(control)
    if not control.initialized then
        return nil, key
    end
    control.rowType = "category"
    control.poolKey = key
    ApplyLabelDefaults(control.label)
    ApplyToggleDefaults(control.toggle)
    ApplyFont(control.label, state.fonts.category, DEFAULT_FONTS.category)
    ApplyFont(control.toggle, state.fonts.toggle, DEFAULT_FONTS.toggle)
    return control, key
end

local function AcquireQuestControl(providedControl)
    local control, key

    if providedControl ~= nil then
        control = providedControl
        key = providedControl.poolKey
    else
        control, key = state.questPool:AcquireObject()
    end

    if not control then
        return nil, key
    end
    if not control.initialized then
        control.label = control:GetNamedChild("Label")
        control.iconSlot = control:GetNamedChild("IconSlot")
        if control.iconSlot then
            control.iconSlot:SetDimensions(QUEST_ICON_SLOT_WIDTH, QUEST_ICON_SLOT_HEIGHT)
            control.iconSlot:ClearAnchors()
            control.iconSlot:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
            if control.iconSlot.SetTexture then
                control.iconSlot:SetTexture(nil)
            end
            if control.iconSlot.SetAlpha then
                control.iconSlot:SetAlpha(0)
            end
            if control.iconSlot.SetHidden then
                control.iconSlot:SetHidden(false)
            end
            if control.iconSlot.SetMouseEnabled then
                control.iconSlot:SetMouseEnabled(true)
            end
            control.iconSlot:SetHandler("OnMouseUp", function(toggleCtrl, button, upInside)
                if not upInside or button ~= MOUSE_BUTTON_INDEX_LEFT then
                    return
                end
                local parent = toggleCtrl:GetParent()
                local journalIndex = parent and parent.questJournalIndex
                if not journalIndex then
                    return
                end
                ToggleQuestExpansion(journalIndex, {
                    trigger = "click",
                    source = "QuestTracker:OnToggleClick",
                })
            end)
        end
        if control.label then
            control.label:ClearAnchors()
            if control.iconSlot then
                control.label:SetAnchor(TOPLEFT, control.iconSlot, TOPRIGHT, QUEST_ICON_SLOT_PADDING_X, 0)
            else
                control.label:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
            end
            control.label:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
        end
        control:SetHandler("OnMouseUp", function(ctrl, button, upInside)
            if not upInside then
                return
            end
            if button == MOUSE_BUTTON_INDEX_LEFT then
                local questData = ctrl.data and ctrl.data.quest
                local journalIndex = ctrl.questJournalIndex or (questData and questData.journalIndex)
                if not journalIndex then
                    return
                end
                local toggleMouseOver = false
                if ctrl.iconSlot then
                    local toggleIsMouseOver = ctrl.iconSlot.IsMouseOver
                    if type(toggleIsMouseOver) == "function" then
                        toggleMouseOver = toggleIsMouseOver(ctrl.iconSlot)
                    end
                end

                if toggleMouseOver then
                    ToggleQuestExpansion(journalIndex, {
                        trigger = "click",
                        source = "QuestTracker:OnRowClickToggle",
                    })
                    return
                end

                if state.opts.autoTrack == false then
                    ToggleQuestExpansion(journalIndex, {
                        trigger = "click",
                        source = "QuestTracker:OnRowClickManualToggle",
                    })
                    return
                end

                HandleQuestRowClick(journalIndex)
            elseif button == MOUSE_BUTTON_INDEX_RIGHT then
                local questData = ctrl.data and ctrl.data.quest
                local journalIndex = ctrl.questJournalIndex or (questData and questData.journalIndex)
                if not journalIndex then
                    return
                end
                ShowQuestContextMenu(ctrl, journalIndex)
            end
        end)
        control:SetHandler("OnMouseEnter", function(ctrl)
            ApplyMouseoverHighlight(ctrl)
        end)
        control:SetHandler("OnMouseExit", function(ctrl)
            RestoreBaseColor(ctrl)
        end)
        control.initialized = true
    end
    if QuestTrackerRows and QuestTrackerRows.ResetQuestRowObjectives then
        QuestTrackerRows:ResetQuestRowObjectives(control)
    end
    control.rowType = "quest"
    control.poolKey = key
    ApplyLabelDefaults(control.label)
    ApplyFont(control.label, state.fonts.quest, DEFAULT_FONTS.quest)
    return control, key
end

local function AcquireConditionControl()
    local control, key = state.conditionPool:AcquireObject()
    if not control.initialized then
        control.label = control:GetNamedChild("Label")
        control.initialized = true
    end
    control.rowType = "condition"
    control.poolKey = key
    ApplyLabelDefaults(control.label)
    ApplyFont(control.label, state.fonts.condition, DEFAULT_FONTS.condition)
    return control, key
end

local function ShouldDisplayCondition(condition)
    if not condition then
        return false
    end

    if condition.forceDisplay then
        local text = condition.displayText or condition.text
        return type(text) == "string" and text ~= ""
    end

    if condition.isVisible == false then
        return false
    end

    if condition.isComplete then
        return false
    end

    if condition.isFailCondition then
        return false
    end

    local text = condition.displayText or condition.text
    if not text or text == "" then
        return false
    end

    return true
end

local function AttachBackdrop()
    EnsureBackdrop()
end

local function EnsurePools()
    if state.categoryPool then
        return
    end

    state.categoryPool = ZO_ControlPool:New("CategoryHeader_Template", state.container)
    state.questPool = ZO_ControlPool:New("QuestHeader_Template", state.container)
    state.conditionPool = ZO_ControlPool:New("QuestCondition_Template", state.container)

    local function resetControl(control)
        if control.ClearAnchors then
            control:ClearAnchors()
        end
        if state and state.container and control.SetParent then
            control:SetParent(state.container)
        end
        if control.label and control.label.SetText then
            control.label:SetText("")
        end
        control:SetHidden(true)
        control.data = nil
        control.currentIndent = nil
        control.baseColor = nil
        control.isExpanded = nil
    end

    state.categoryPool:SetCustomResetBehavior(function(control)
        resetControl(control)
        if control.toggle then
            if control.toggle.SetTexture then
                control.toggle:SetTexture(SelectCategoryToggleTexture(false, false))
            end
            if control.toggle.SetHidden then
                control.toggle:SetHidden(false)
            end
        end
    end)
    state.questPool:SetCustomResetBehavior(function(control)
        resetControl(control)
        if control.label and control.label.SetText then
            control.label:SetText("")
        end
        if control.iconSlot then
            if control.iconSlot.SetTexture then
                control.iconSlot:SetTexture(nil)
            end
            if control.iconSlot.SetAlpha then
                control.iconSlot:SetAlpha(0)
            end
            if control.iconSlot.SetHidden then
                control.iconSlot:SetHidden(false)
            end
        end
    end)
    state.conditionPool:SetCustomResetBehavior(resetControl)
end

local function LayoutCondition(condition)
    if QuestTrackerLayout and QuestTrackerLayout.LayoutCondition then
        return QuestTrackerLayout:LayoutCondition(condition)
    end
end

local function LayoutQuest(quest)
    if QuestTrackerLayout and QuestTrackerLayout.LayoutQuest then
        return QuestTrackerLayout:LayoutQuest(quest)
    end
end

local function LayoutCategory(category, categoryControl)
    if QuestTrackerLayout and QuestTrackerLayout.LayoutCategory then
        return QuestTrackerLayout:LayoutCategory(category, categoryControl)
    end
end

local function ReleaseRowControl(control)
    if QuestTrackerLayout and QuestTrackerLayout.ReleaseRowControl then
        return QuestTrackerLayout:ReleaseRowControl(control)
    end
end

local function TrimOrderedControlsToCategory(keepCategoryCount)
    if QuestTrackerLayout and QuestTrackerLayout.TrimOrderedControlsToCategory then
        return QuestTrackerLayout:TrimOrderedControlsToCategory(keepCategoryCount)
    end
end

local function RelayoutFromCategoryIndex(startCategoryIndex)
    if QuestTrackerLayout and QuestTrackerLayout.RelayoutFromCategoryIndex then
        return QuestTrackerLayout:RelayoutFromCategoryIndex(startCategoryIndex)
    end
end

local function EmptyViewModel()
    return { categories = {} }
end

local function CountViewModelEntries(viewModel)
    local categories = 0
    local quests = 0

    local ordered = viewModel and viewModel.categories
    if type(ordered) == "table" then
        categories = #ordered
        for index = 1, categories do
            local category = ordered[index]
            if category and type(category.quests) == "table" then
                quests = quests + #category.quests
            end
        end
    end

    return categories, quests
end

local function IsViewModelValid(candidate)
    return type(candidate) == "table" and type(candidate.categories) == "table"
end

local function ApplyViewModel(viewModel, context)
    if not IsViewModelValid(viewModel) then
        viewModel = EmptyViewModel()
    end

    state.viewModel = viewModel

    if IsDebugLoggingEnabled() then
        local categoryCount, questCount = CountViewModelEntries(viewModel)
        DebugLog(
            "ApplyViewModel: trigger=%s source=%s categories=%d quests=%d",
            tostring((context and context.trigger) or "<nil>"),
            tostring((context and context.source) or "<nil>"),
            categoryCount,
            questCount
        )
    end

    local trackingContext = {
        trigger = (context and context.trigger) or "refresh",
        source = (context and context.source) or "QuestTracker:ApplyViewModel",
    }

    UpdateTrackedQuestCache(nil, trackingContext)

    if state.trackedQuestIndex then
        EnsureTrackedQuestVisible(state.trackedQuestIndex, nil, trackingContext)
    end

    NotifyStatusRefresh()
end

-- Apply the latest quest view model from the event-driven model and update the layout.
local function OnQuestViewModelUpdated(viewModel, context)
    if not IsViewModelValid(viewModel) then
        return
    end

    local previousCategories, previousQuests = CountViewModelEntries(state.viewModel)
    local previousHeight = state.contentHeight or 0

    ApplyViewModel(viewModel, context)

    if not state.isInitialized then
        return
    end

    if state.conditionPool then
        state.conditionPool:ReleaseAllObjects()
    end

    ResetLayoutState()

    local categoryControls
    local rowControls
    local rowsByCategory

    if QuestTrackerRows and QuestTrackerRows.BuildOrRebuildRows then
        rowsByCategory = QuestTrackerRows:BuildOrRebuildRows(state.viewModel)
        if QuestTrackerRows.GetCategoryControls then
            categoryControls = QuestTrackerRows:GetCategoryControls()
        end
        if QuestTrackerRows.GetRowControls then
            rowControls = QuestTrackerRows:GetRowControls()
        end
    end

    if QuestTrackerLayout and QuestTrackerLayout.ApplyLayout then
        QuestTrackerLayout:ApplyLayout(state.container, categoryControls, rowControls, rowsByCategory)
    end

    if IsDebugLoggingEnabled() then
        local newCategories, newQuests = CountViewModelEntries(state.viewModel)

        DebugLog(
            "OnQuestViewModelUpdated: prevCats=%d prevQuests=%d newCats=%d newQuests=%d height %s→%s",
            previousCategories,
            previousQuests,
            newCategories,
            newQuests,
            tostring(previousHeight),
            tostring(state.contentHeight)
        )
    end
end

-- Listen for view model updates from the quest model so the tracker stays in sync with game events.
local function SubscribeToQuestModel()
    if state.questModelSubscription then
        return
    end

    local questModel = Nvk3UT and Nvk3UT.QuestModel
    if not (questModel and questModel.Subscribe) then
        return
    end

    state.questModelSubscription = function()
        if RequestRefresh then
            RequestRefresh("QuestTracker:QuestModelSubscription")
        end
    end

    questModel.Subscribe(state.questModelSubscription)
end

local function UnsubscribeFromQuestModel()
    local questModel = Nvk3UT and Nvk3UT.QuestModel
    if state.questModelSubscription and questModel and questModel.Unsubscribe then
        questModel.Unsubscribe(state.questModelSubscription)
    end

    state.questModelSubscription = nil
end

local function ConfigureLayoutHelper()
    ApplyQuestSpacingFromSaved()
    if QuestTrackerLayout and QuestTrackerLayout.Init then
        QuestTrackerLayout:Init(state, {
            VERTICAL_PADDING = VERTICAL_PADDING,
            CONDITION_INDENT_X = CONDITION_INDENT_X,
            CONDITION_MIN_HEIGHT = CONDITION_MIN_HEIGHT,
            QUEST_INDENT_X = QUEST_INDENT_X,
            QUEST_ICON_SLOT_WIDTH = QUEST_ICON_SLOT_WIDTH,
            QUEST_ICON_SLOT_PADDING_X = QUEST_ICON_SLOT_PADDING_X,
            QUEST_MIN_HEIGHT = QUEST_MIN_HEIGHT,
            ENTRY_SPACING_ABOVE = ENTRY_SPACING_ABOVE,
            ENTRY_SPACING_BELOW = ENTRY_SPACING_BELOW,
            CATEGORY_INDENT_X = CATEGORY_INDENT_X,
            CATEGORY_SPACING_ABOVE = CATEGORY_SPACING_ABOVE,
            CATEGORY_SPACING_BELOW = CATEGORY_BOTTOM_PAD_EXPANDED,
            OBJECTIVE_SPACING_ABOVE = OBJECTIVE_SPACING_ABOVE,
            OBJECTIVE_SPACING_BELOW = OBJECTIVE_SPACING_BELOW,
            OBJECTIVE_SPACING_BETWEEN = OBJECTIVE_SPACING_BETWEEN,
            OBJECTIVE_BASE_INDENT = OBJECTIVE_BASE_INDENT,
            CATEGORY_TOGGLE_WIDTH = CATEGORY_TOGGLE_WIDTH,
            TOGGLE_LABEL_PADDING_X = TOGGLE_LABEL_PADDING_X,
            CATEGORY_MIN_HEIGHT = CATEGORY_MIN_HEIGHT,
            ROW_TEXT_PADDING_Y = ROW_TEXT_PADDING_Y,
            CATEGORY_BOTTOM_PAD_EXPANDED = CATEGORY_BOTTOM_PAD_EXPANDED,
            CATEGORY_BOTTOM_PAD_COLLAPSED = CATEGORY_BOTTOM_PAD_COLLAPSED,
            BOTTOM_PIXEL_NUDGE = BOTTOM_PIXEL_NUDGE,
            IsDebugLoggingEnabled = IsDebugLoggingEnabled,
            GetToggleWidth = GetToggleWidth,
            AcquireConditionControl = AcquireConditionControl,
            FormatConditionText = FormatConditionText,
            GetQuestTrackerColor = GetQuestTrackerColor,
            ApplyBaseColor = ApplyBaseColor,
            ShouldDisplayCondition = ShouldDisplayCondition,
            AcquireQuestControl = AcquireQuestControl,
            AcquireQuestRow = function()
                if QuestTrackerRows and QuestTrackerRows.AcquireQuestRow then
                    return QuestTrackerRows:AcquireQuestRow()
                end
                return nil
            end,
            ResetQuestRowObjectives = function(row)
                if QuestTrackerRows and QuestTrackerRows.ResetQuestRowObjectives then
                    return QuestTrackerRows:ResetQuestRowObjectives(row)
                end
            end,
            ApplyQuestObjectives = function(row, objectives)
                if QuestTrackerRows and QuestTrackerRows.ApplyObjectives then
                    return QuestTrackerRows:ApplyObjectives(row, objectives)
                end
            end,
            DetermineQuestColorRole = DetermineQuestColorRole,
            UpdateQuestIconSlot = UpdateQuestIconSlot,
            IsQuestExpanded = IsQuestExpanded,
            NormalizeQuestKey = NormalizeQuestKey,
            ShouldShowQuestCategoryCounts = ShouldShowQuestCategoryCounts,
            IsCategoryExpanded = IsCategoryExpanded,
            FormatCategoryHeaderText = FormatCategoryHeaderText,
            UpdateCategoryToggle = UpdateCategoryToggle,
            AcquireCategoryControl = AcquireCategoryControl,
            NormalizeCategoryKey = NormalizeCategoryKey,
            SetCategoryRowsVisible = function(categoryKey, visible)
                if QuestTrackerRows and QuestTrackerRows.SetCategoryRowsVisible then
                    return QuestTrackerRows:SetCategoryRowsVisible(categoryKey, visible)
                end
            end,
            RegisterQuestRow = function(row, categoryKey)
                if QuestTrackerRows and QuestTrackerRows.RegisterQuestRow then
                    QuestTrackerRows:RegisterQuestRow(row, categoryKey)
                end
            end,
            GetActiveRowsByCategory = function()
                if QuestTrackerRows and QuestTrackerRows.GetActiveRowsByCategory then
                    return QuestTrackerRows:GetActiveRowsByCategory()
                end
                return nil
            end,
            ReleaseAll = ReleaseAll,
            ApplyActiveQuestFromSaved = ApplyActiveQuestFromSaved,
            EnsurePools = EnsurePools,
            PrimeInitialSavedState = PrimeInitialSavedState,
            NotifyHostContentChanged = NotifyHostContentChanged,
            ProcessPendingExternalReveal = ProcessPendingExternalReveal,
        })
    end
end

local function ConfigureRowsHelper()
    if QuestTrackerRows and QuestTrackerRows.Init then
        QuestTrackerRows:Init(state.container, state, {
            EnsurePools = EnsurePools,
            ReleaseAll = ReleaseAll,
            ResetLayoutState = ResetLayoutState,
            PrimeInitialSavedState = PrimeInitialSavedState,
            LayoutCategory = LayoutCategory,
            UpdateContentSize = UpdateContentSize,
            NotifyHostContentChanged = NotifyHostContentChanged,
            ProcessPendingExternalReveal = ProcessPendingExternalReveal,
        })
    end
end

local function RefreshVisibility()
    if not state.control then
        return
    end

    local hidden = state.opts.active == false

    state.control:SetHidden(hidden)
    NotifyHostContentChanged()
end

function QuestTracker.Init(parentControl, opts)
    if state.isInitialized then
        return
    end

    assert(parentControl ~= nil, "QuestTracker.Init requires a parent control")

    state.control = parentControl
    state.container = parentControl
    if state.control and state.control.SetResizeToFitDescendents then
        state.control:SetResizeToFitDescendents(true)
    end

    ConfigureLayoutHelper()
    ConfigureRowsHelper()

    EnsureSavedVars()
    state.opts = {}
    state.fonts = {}
    state.pendingSelection = nil
    state.lastTrackedBeforeSync = nil
    state.syncingTrackedState = false
    state.pendingDeselection = false
    state.pendingExternalReveal = nil

    QuestTracker.ApplyTheme(state.saved or {})
    QuestTracker.ApplySettings(state.saved or {})

    if opts then
        QuestTracker.ApplyTheme(opts)
        QuestTracker.ApplySettings(opts)
    end

    RegisterTrackingEvents()

    SubscribeToQuestModel()

    HookQuestJournalKeybind()
    HookQuestJournalContextMenu()
    HookQuestJournalNavigationEntryTemplate()

    state.isInitialized = true
    RefreshVisibility()
    AdoptTrackedQuestOnInit()
end

QuestTracker.ToggleCategoryExpansion = ToggleCategoryExpansion
QuestTracker.IsCategoryExpanded = IsCategoryExpanded
QuestTracker.SetCategoryExpanded = SetCategoryExpanded
QuestTracker.EnsureQuestFilterSavedVars = EnsureQuestFilterSavedVars
QuestTracker.GetQuestFilterMode = GetQuestFilterMode
QuestTracker.UpdateQuestJournalSelectionKeyLabelVisibility = UpdateQuestJournalSelectionKeyLabelVisibility
QuestTracker.QUEST_FILTER_MODE_ALL = QUEST_FILTER_MODE_ALL
QuestTracker.QUEST_FILTER_MODE_ACTIVE = QUEST_FILTER_MODE_ACTIVE
QuestTracker.QUEST_FILTER_MODE_SELECTION = QUEST_FILTER_MODE_SELECTION

function QuestTracker.MarkDirty(reason)
    local controller = Nvk3UT and Nvk3UT.QuestTrackerController
    if controller and controller.RequestRefresh then
        controller:RequestRefresh(reason or "QuestTracker.MarkDirty")
        return
    end

    if controller and controller.MarkDirty then
        controller:MarkDirty(reason or "QuestTracker.MarkDirty")
    elseif RequestRefresh then
        RequestRefresh(reason or "QuestTracker.MarkDirty")
    end
end

function QuestTracker:Refresh(viewModel, context)
    if not IsViewModelValid(viewModel) then
        DebugLog("QuestTracker.Refresh called with nil/invalid viewModel -> skipping (no reset)")
        return
    end

    local refreshContext = context or {
        trigger = "refresh",
        source = "QuestTracker.Refresh",
    }

    OnQuestViewModelUpdated(viewModel, refreshContext)
end

function QuestTracker.Shutdown()
    if not state.isInitialized then
        return
    end

    UnregisterTrackingEvents()
    UnsubscribeFromQuestModel()

    if state.categoryPool then
        state.categoryPool:ReleaseAllObjects()
        state.categoryPool = nil
    end

    if state.questPool then
        state.questPool:ReleaseAllObjects()
        state.questPool = nil
    end

    if state.conditionPool then
        state.conditionPool:ReleaseAllObjects()
        state.conditionPool = nil
    end

    state.container = nil
    state.control = nil
    state.viewModel = nil
    state.orderedControls = {}
    state.lastAnchoredControl = nil
    state.categoryControls = {}
    state.questControls = {}
    state.isInitialized = false
    state.opts = {}
    state.fonts = {}
    state.pendingRefresh = false
    state.contentWidth = 0
    state.contentHeight = 0
    state.trackedQuestIndex = nil
    state.trackedCategoryKeys = {}
    state.trackingEventsRegistered = false
    state.suppressForceExpandFor = nil
    state.pendingSelection = nil
    state.lastTrackedBeforeSync = nil
    state.syncingTrackedState = false
    state.pendingDeselection = false
    state.pendingExternalReveal = nil
    state.selectedQuestKey = nil
    state.isRebuildInProgress = false
    state.questModelSubscription = nil
    NotifyHostContentChanged()
end

function QuestTracker.SetActive(active)
    state.opts.active = active
    RefreshVisibility()
    NotifyStatusRefresh()
end

function QuestTracker.ApplySettings(settings)
    if type(settings) ~= "table" then
        return
    end

    state.opts.autoExpand = settings.autoExpand ~= false
    state.opts.autoTrack = settings.autoTrack ~= false
    state.opts.autoCollapsePreviousCategoryOnActiveQuestChange =
        settings.autoCollapsePreviousCategoryOnActiveQuestChange == true
    state.opts.active = (settings.active ~= false)

    ConfigureLayoutHelper()
    RefreshVisibility()
    RequestRefresh()
    NotifyStatusRefresh()
end

function QuestTracker.ApplyTheme(settings)
    if type(settings) ~= "table" then
        return
    end

    state.opts.fonts = state.opts.fonts or {}

    local fonts = settings.fonts or {}
    state.opts.fonts.category = BuildFontString(fonts.category, state.opts.fonts.category or DEFAULT_FONTS.category)
    state.opts.fonts.quest = BuildFontString(fonts.title, state.opts.fonts.quest or DEFAULT_FONTS.quest)
    state.opts.fonts.condition = BuildFontString(fonts.line, state.opts.fonts.condition or DEFAULT_FONTS.condition)
    state.opts.fonts.toggle = state.opts.fonts.category or DEFAULT_FONTS.toggle
    state.fonts = MergeFonts(state.opts.fonts)

    RequestRefresh()
end

function QuestTracker.IsActive()
    return state.opts.active ~= false
end

function QuestTracker.RequestRefresh()
    RequestRefresh()
end

function QuestTracker.GetContentSize()
    local layoutState = QuestTrackerLayout and QuestTrackerLayout.state
    local width = (layoutState and layoutState.contentWidth) or state.contentWidth or 0
    local height = (layoutState and layoutState.contentHeight) or state.contentHeight or 0
    return width or 0, height or 0
end

function QuestTracker.GetHeight()
    local layoutState = QuestTrackerLayout and QuestTrackerLayout.state
    if layoutState and layoutState.contentHeight then
        return layoutState.contentHeight
    end
    return state.contentHeight or 0
end

function QuestTracker.ApplyBaseQuestTrackerVisibility()
    local hide = GetHideBaseQuestTrackerFlag()
    local questTrackerEnabled = GetQuestTrackerEnabledFlag()
    local shouldHide = hide and questTrackerEnabled

    if Nvk3UT and Nvk3UT.Debug then
        Nvk3UT.Debug(
            "ApplyBaseQuestTrackerVisibility: hide=%s, questTrackerEnabled=%s, effectiveHide=%s",
            tostring(hide),
            tostring(questTrackerEnabled),
            tostring(shouldHide)
        )
    end

    local tracker = GetBaseQuestTracker()
    if not tracker then
        return
    end

    local fragment = tracker and tracker.GetFragment and tracker:GetFragment()
    if fragment and type(fragment.SetHiddenForReason) == "function" then
        fragment:SetHiddenForReason("Nvk3UT_HideBaseQuestTracker", shouldHide, DEFAULT_HUD_DURATION, DEFAULT_HUD_DURATION)
    end

    if tracker and tracker.SetHidden then
        tracker:SetHidden(shouldHide)
    end
end

-- Binding handler exposed under Controls > Addons > Nvk3UT to toggle quest
-- selection while the keyboard quest journal is open in selection mode.
function Nvk3UT_ToggleQuestSelectionBinding()
    local addon = _G and _G.Nvk3UT or Nvk3UT
    if not addon then
        return
    end

    if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then
        return
    end

    local questJournalVisible = false
    if QUEST_JOURNAL_SCENE and QUEST_JOURNAL_SCENE.IsShowing and QUEST_JOURNAL_SCENE:IsShowing() then
        questJournalVisible = true
    elseif SCENE_MANAGER and SCENE_MANAGER.IsShowing and SCENE_MANAGER:IsShowing("journal") then
        questJournalVisible = true
    end

    if not questJournalVisible then
        return
    end

    if not IsQuestSelectionModeActive() then
        return
    end

    local questKey = GetFocusedQuestKey()
    if not questKey then
        return
    end

    ToggleQuestSelection(questKey, "Keybind:ToggleQuestSelection")
    local controller = addon and addon.QuestTrackerController
    if controller and controller.RequestRefresh then
        controller:RequestRefresh("Keybind:ToggleQuestSelection")
    else
        local runtime = addon and addon.TrackerRuntime
        if runtime and runtime.QueueDirty then
            runtime:QueueDirty("quest")
        end
    end

    if addon.QuestTracker and addon.QuestTracker.UpdateQuestJournalSelectionKeyLabelVisibility then
        addon.QuestTracker.UpdateQuestJournalSelectionKeyLabelVisibility("Keybind:ToggleQuestSelection")
    end
end

Nvk3UT.QuestTracker = QuestTracker

return QuestTracker
