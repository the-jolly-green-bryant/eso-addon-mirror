-- Model/Quest/Nvk3UT_QuestSelection.lua
-- Centralizes quest tracker active selection state while preserving legacy behavior.

Nvk3UT = Nvk3UT or {}
Nvk3UT.QuestSelection = Nvk3UT.QuestSelection or {}

local QuestSelection = Nvk3UT.QuestSelection
local saved = QuestSelection._saved

local PRIORITY = {
    manual = 5,
    ["click-select"] = 4,
    ["external-select"] = 4,
    auto = 2,
    init = 1,
}

local function GetQuestStateModule()
    return Nvk3UT and Nvk3UT.QuestState
end

local function GetQuestModelModule()
    return Nvk3UT and Nvk3UT.QuestModel
end

local function GetCurrentTimeSeconds()
    local questState = GetQuestStateModule()
    if questState and questState.GetCurrentTimeSeconds then
        local ok, value = pcall(questState.GetCurrentTimeSeconds)
        if ok then
            return value
        end
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

local function NormalizeQuestKey(journalIndex)
    local questState = GetQuestStateModule()
    if questState and questState.NormalizeQuestKey then
        return questState.NormalizeQuestKey(journalIndex)
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

local function NormalizeCategoryKeys(categoryKeys)
    local normalized = {}
    local seen = {}

    local function append(key)
        local normalizedKey = NormalizeCategoryKey(key)
        if not normalizedKey or seen[normalizedKey] then
            return
        end

        seen[normalizedKey] = true
        normalized[#normalized + 1] = normalizedKey
    end

    if type(categoryKeys) == "table" then
        if #categoryKeys > 0 then
            for index = 1, #categoryKeys do
                append(categoryKeys[index])
            end
        else
            for key, value in pairs(categoryKeys) do
                if value then
                    append(key)
                end
            end
        end
    elseif categoryKeys ~= nil then
        append(categoryKeys)
    end

    return normalized
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

local function CopyCategoryKeys(categoryKeys)
    if type(categoryKeys) ~= "table" then
        return {}
    end

    local copy = {}
    for index = 1, #categoryKeys do
        copy[index] = categoryKeys[index]
    end

    return copy
end

local function CopySelectionEntry(entry)
    if type(entry) ~= "table" then
        return {
            questKey = nil,
            questId = nil,
            categoryKey = nil,
            categoryKeys = {},
            source = "init",
            ts = 0,
        }
    end

    return {
        questKey = entry.questKey,
        questId = entry.questId,
        categoryKey = entry.categoryKey,
        categoryKeys = CopyCategoryKeys(entry.categoryKeys),
        source = entry.source,
        ts = entry.ts,
    }
end

local function NormalizeQuestId(questId)
    local numeric = tonumber(questId)
    if numeric and numeric > 0 then
        return numeric
    end

    return nil
end

local function CollectCategoryKeysForQuest(questKey)
    local questModel = GetQuestModelModule()
    if questModel and questModel.GetCategoryKeysForQuestKey then
        local keys, found, orderedKeys = questModel.GetCategoryKeysForQuestKey(questKey)
        return type(keys) == "table" and keys or {}, type(orderedKeys) == "table" and orderedKeys or {}, found == true
    end

    return {}, {}, false
end

local function BuildCategoryKeysList(categoryMap, orderedKeys)
    local list = {}
    local seen = {}

    local function append(key)
        local normalized = NormalizeCategoryKey(key)
        if not normalized or seen[normalized] then
            return
        end

        seen[normalized] = true
        list[#list + 1] = normalized
    end

    if type(orderedKeys) == "table" then
        for index = 1, #orderedKeys do
            append(orderedKeys[index])
        end
    end

    if type(categoryMap) == "table" then
        for key, value in pairs(categoryMap) do
            if value then
                append(key)
            end
        end
    end

    return list
end

local function GetQuestModelSnapshot()
    local questModel = GetQuestModelModule()
    if questModel and type(questModel.GetSnapshot) == "function" then
        local ok, snapshot = pcall(questModel.GetSnapshot)
        if ok then
            return snapshot
        end
    end

    return nil
end

local function ResolveQuestName(journalIndex, snapshot)
    if not journalIndex then
        return nil
    end

    local questName
    local questModelSnapshot = snapshot or GetQuestModelSnapshot()
    if questModelSnapshot and questModelSnapshot.questByJournalIndex then
        local quest = questModelSnapshot.questByJournalIndex[journalIndex]
        questName = quest and quest.name or questName
    end

    if (not questName or questName == "") and GetJournalQuestName then
        local ok, name = pcall(GetJournalQuestName, journalIndex)
        if ok and type(name) == "string" and name ~= "" then
            questName = name
        end
    end

    return questName, questModelSnapshot
end

local function ResolveCategoryName(categoryKey, snapshot)
    if not categoryKey then
        return nil
    end

    local questModelSnapshot = snapshot or GetQuestModelSnapshot()
    local categories = questModelSnapshot and questModelSnapshot.categories
    local byKey = categories and categories.byKey

    if byKey and byKey[categoryKey] then
        return byKey[categoryKey].name
    end

    return nil
end

local function BuildSelectionDebugLine(label, entry, snapshot)
    if type(entry) ~= "table" then
        return string.format("%s quest=nil category=nil", label)
    end

    local journalIndex = QuestKeyToJournalIndex(entry.questKey)
    local questName, questSnapshot = ResolveQuestName(journalIndex, snapshot)
    local categoryName = ResolveCategoryName(entry.categoryKey, questSnapshot)

    return string.format(
        "%s quest=%s (%s) category=%s (%s)",
        label,
        tostring(entry.questKey or "-"),
        questName or "-",
        tostring(entry.categoryKey or "-"),
        categoryName or "-"
    )
end

local function LogActiveChange(previous, active, source)
    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics
    if not diagnostics or type(diagnostics.DebugIfEnabled) ~= "function" then
        return
    end

    local snapshot = GetQuestModelSnapshot()
    local message = string.format(
        "%s | %s | source=%s",
        BuildSelectionDebugLine("previous", previous, snapshot),
        BuildSelectionDebugLine("active", active, snapshot),
        tostring(source or "auto")
    )

    diagnostics:DebugIfEnabled("QuestSelection", "[QuestSelection] %s", message)
end

local function GetQuestTrackerSettings()
    local addon = Nvk3UT
    local sv = addon and addon.SV
    local questTracker = sv and sv.QuestTracker

    if type(questTracker) == "table" then
        return questTracker
    end

    return nil
end

local function IsAutoCollapseEnabled()
    local questTracker = GetQuestTrackerSettings()
    return questTracker and questTracker.autoCollapsePreviousCategoryOnActiveQuestChange == true
end

function QuestSelection.ApplyAutoCollapsePreviousCategory()
    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics

    if not IsAutoCollapseEnabled() then
        return false
    end

    if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
        diagnostics:DebugIfEnabled(
            "QuestSelection",
            "[AutoCollapse] Option enabled, evaluating previous category for collapse"
        )
    end

    local previousSelection = saved and saved.previous
    local previousCategoryKey = previousSelection and previousSelection.categoryKey
    if not previousCategoryKey then
        if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
            diagnostics:DebugIfEnabled(
                "QuestSelection",
                "[AutoCollapse] No previous category to collapse (previous.categoryKey is nil)"
            )
        end
        return false
    end

    local activeSelection = saved and saved.active
    local activeCategoryKey = activeSelection and activeSelection.categoryKey

    if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
        diagnostics:DebugIfEnabled(
            "QuestSelection",
            "[AutoCollapse] previous category key=%s, active category key=%s",
            tostring(previousCategoryKey),
            tostring(activeCategoryKey)
        )
    end

    if not activeCategoryKey then
        if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
            diagnostics:DebugIfEnabled(
                "QuestSelection",
                "[AutoCollapse] Active category key missing, skipping collapse"
            )
        end
        return false
    end

    if previousCategoryKey == activeCategoryKey then
        if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
            diagnostics:DebugIfEnabled(
                "QuestSelection",
                "[AutoCollapse] previous and active categories match (%s), skip (same category)",
                tostring(previousCategoryKey)
            )
        end
        return false
    end

    local questTracker = Nvk3UT and Nvk3UT.QuestTracker
    if not questTracker then
        return false
    end

    if type(questTracker.IsCategoryExpanded) ~= "function" then
        return false
    end

    local categoryName = ResolveCategoryName(previousCategoryKey)
    local isExpanded = questTracker.IsCategoryExpanded(previousCategoryKey)
    if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
        diagnostics:DebugIfEnabled(
            "QuestSelection",
            "[AutoCollapse] previous category key=%s name=%s expanded=%s",
            tostring(previousCategoryKey),
            tostring(categoryName or "-"),
            tostring(isExpanded)
        )
    end

    if not isExpanded then
        if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
            diagnostics:DebugIfEnabled(
                "QuestSelection",
                "[AutoCollapse] Previous category '%s' is not expanded, skipping collapse",
                tostring(previousCategoryKey)
            )
        end
        return false
    end

    if type(questTracker.SetCategoryExpanded) ~= "function" then
        return false
    end

    if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
        diagnostics:DebugIfEnabled(
            "QuestSelection",
            "[AutoCollapse] Collapsing previous category '%s' (active category=%s) due to active quest change (collapse (different category))",
            tostring(previousCategoryKey),
            tostring(activeCategoryKey)
        )
    end

    local changed = questTracker.SetCategoryExpanded(previousCategoryKey, false, {
        trigger = "click",
        source = "QuestTracker:AutoCollapsePreviousCategory",
        manualCollapseRespected = true,
    })

    if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
        diagnostics:DebugIfEnabled(
            "QuestSelection",
            "[AutoCollapse] Collapse %s",
            changed and "applied successfully" or "skipped by state"
        )
    end

    return changed == true
end

local function NormalizeSelectionEntry(entry, defaultSource)
    local normalized = CopySelectionEntry(entry)

    normalized.questKey = NormalizeQuestKey(normalized.questKey)
    normalized.questId = NormalizeQuestId(normalized.questId)
    normalized.categoryKeys = NormalizeCategoryKeys(normalized.categoryKeys)
    normalized.categoryKey = NormalizeCategoryKey(normalized.categoryKey or normalized.categoryKeys[1])
    normalized.source = (type(normalized.source) == "string" and normalized.source ~= "" and normalized.source)
        or defaultSource
        or "init"
    normalized.ts = tonumber(normalized.ts) or 0

    return normalized
end

local function ResolveQuestIdForJournalIndex(journalIndex)
    if not journalIndex or not GetJournalQuestId then
        return nil
    end

    local ok, questId = pcall(GetJournalQuestId, journalIndex)
    if ok then
        return NormalizeQuestId(questId)
    end

    return nil
end

local function ResolveJournalIndexByQuestId(questId)
    if not questId or not GetNumJournalQuests or not GetJournalQuestId then
        return nil
    end

    questId = NormalizeQuestId(questId)
    if not questId then
        return nil
    end

    for journalIndex = 1, GetNumJournalQuests() do
        local ok, id = pcall(GetJournalQuestId, journalIndex)
        if ok and id == questId then
            return journalIndex
        end
    end

    return nil
end

local function EnsureActiveSavedStateInternal(target)
    if type(target) ~= "table" then
        return nil
    end

    target.active = NormalizeSelectionEntry(target.active, "init")
    target.previous = NormalizeSelectionEntry(target.previous, "init")

    return target.active
end

local function ResolveWrite(source, options, previous)
    options = options or {}

    local priorityOverride = options.priorityOverride
    local priority = priorityOverride or PRIORITY[source] or 0
    local previousPriority = previous and (PRIORITY[previous.source] or 0) or 0
    local overrideTimestamp = tonumber(options.timestamp)
    local now = overrideTimestamp or GetCurrentTimeSeconds()
    local previousTimestamp = (previous and previous.ts) or 0
    local forceWrite = options.force == true
    local allowTimestampRegression = options.allowTimestampRegression == true

    if previous and not forceWrite then
        if previousPriority > priority then
            return false, priority, now
        end

        if previousPriority == priority and not allowTimestampRegression and now < previousTimestamp then
            return false, priority, now
        end
    end

    return true, priority, now
end

local function ApplyActiveWrite(questKey, source, options)
    if not saved then
        return false
    end

    source = source or "auto"
    options = options or {}

    local normalized = questKey and NormalizeQuestKey(questKey) or nil
    local active = EnsureActiveSavedStateInternal(saved)
    local shouldWrite, priority, timestamp = ResolveWrite(source, options, active)
    if not shouldWrite then
        return false, normalized, priority, source
    end

    if active and active.questKey == normalized then
        return false, normalized, priority, source
    end

    local categoryMap, orderedKeys = CollectCategoryKeysForQuest(normalized)
    local categoryKeys = BuildCategoryKeysList(categoryMap, orderedKeys)
    local categoryKey = categoryKeys[1]

    local normalizedJournalIndex = QuestKeyToJournalIndex(normalized)
    local questId = ResolveQuestIdForJournalIndex(normalizedJournalIndex)
    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics

    saved.previous = NormalizeSelectionEntry(active, active and active.source or "init")
    saved.active = NormalizeSelectionEntry({
        questKey = normalized,
        questId = questId,
        categoryKey = categoryKey,
        categoryKeys = categoryKeys,
        source = source,
        ts = timestamp,
    }, source)

    if diagnostics and type(diagnostics.DebugIfEnabled) == "function" and questId then
        diagnostics:DebugIfEnabled(
            "QuestSelection",
            "[QuestSelection] Stored active questId=%s for questKey=%s (journalIndex=%s)",
            tostring(questId),
            tostring(normalized),
            tostring(normalizedJournalIndex)
        )
    end

    LogActiveChange(saved.previous, saved.active, source)

    QuestSelection.ApplyAutoCollapsePreviousCategory()

    return true, normalized, priority, source
end

local function AssignSaved(container)
    if type(container) ~= "table" then
        saved = nil
        QuestSelection._saved = nil
        return nil
    end

    saved = container
    QuestSelection._saved = saved
    EnsureActiveSavedStateInternal(saved)
    return saved
end

function QuestSelection.Bind(root, questTrackerOverride)
    local container = questTrackerOverride

    if type(container) ~= "table" then
        if type(root) ~= "table" then
            return AssignSaved(nil)
        end

        container = root.QuestTracker
        if type(container) ~= "table" then
            container = {}
            root.QuestTracker = container
        end
    end

    EnsureActiveSavedStateInternal(container)

    return AssignSaved(container)
end

function QuestSelection.GetSaved()
    return saved
end

function QuestSelection.EnsureActiveSavedState(target)
    if target then
        return EnsureActiveSavedStateInternal(target)
    end

    return EnsureActiveSavedStateInternal(saved)
end

function QuestSelection.SetActive(questKey, source, options)
    return ApplyActiveWrite(questKey, source, options)
end

function QuestSelection.GetActive()
    return EnsureActiveSavedStateInternal(saved)
end

function QuestSelection.GetActiveQuestKey()
    local active = EnsureActiveSavedStateInternal(saved)
    local questKey = active and active.questKey or nil
    local journalIndex = QuestKeyToJournalIndex(questKey)
    local questId = active and active.questId or nil
    local diagnostics = (Nvk3UT and Nvk3UT.Diagnostics) or Nvk3UT_Diagnostics

    if questId then
        local resolvedJournalIndex = ResolveJournalIndexByQuestId(questId)
        if resolvedJournalIndex then
            if journalIndex ~= resolvedJournalIndex then
                local previousJournalIndex = journalIndex
                local resolvedQuestKey = NormalizeQuestKey(resolvedJournalIndex)
                active.questKey = resolvedQuestKey
                questKey = resolvedQuestKey
                journalIndex = resolvedJournalIndex

                if diagnostics and type(diagnostics.DebugIfEnabled) == "function" then
                    diagnostics:DebugIfEnabled(
                        "QuestSelection",
                        "[QuestSelection] Active quest reindexed: %s -> %s (questId=%s)",
                        tostring(previousJournalIndex),
                        tostring(resolvedJournalIndex),
                        tostring(questId)
                    )
                end
            else
                questKey = NormalizeQuestKey(resolvedJournalIndex)
                journalIndex = resolvedJournalIndex
            end
        end
    end

    return questKey
end

function QuestSelection.IsActive(questKey)
    if not saved then
        return false
    end

    local normalized = NormalizeQuestKey(questKey)
    local active = EnsureActiveSavedStateInternal(saved)

    if normalized == nil then
        return active and active.questKey == nil
    end

    return active and active.questKey == normalized
end

function QuestSelection.NormalizeQuestKey(journalIndex)
    return NormalizeQuestKey(journalIndex)
end

return QuestSelection
