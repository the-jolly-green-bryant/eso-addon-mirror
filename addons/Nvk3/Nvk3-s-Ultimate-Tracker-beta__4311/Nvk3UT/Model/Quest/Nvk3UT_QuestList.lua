-- Model/Quest/Nvk3UT_QuestList.lua
-- Encapsulates quest journal retrieval, category normalization, and raw quest list snapshots.

Nvk3UT = Nvk3UT or {}
Nvk3UT.QuestList = Nvk3UT.QuestList or {}

local QuestList = Nvk3UT.QuestList
local Diagnostics = Nvk3UT and Nvk3UT.Diagnostics

local DEFAULT_OBJECTIVE_MODE = "focused"
QuestList.OBJECTIVE_MODE = QuestList.OBJECTIVE_MODE or DEFAULT_OBJECTIVE_MODE

local function GetObjectiveMode()
    local mode = QuestList.OBJECTIVE_MODE
    if mode == nil then
        return DEFAULT_OBJECTIVE_MODE
    end
    return mode
end

local localeAwareToLower = rawget(_G, "LocaleAwareToLower")
local hasWarnedSafeLowerCast = false

local function GetDiagnostics()
    Diagnostics = Diagnostics or (Nvk3UT and Nvk3UT.Diagnostics)
    return Diagnostics
end

local function SafeLower(value)
    if value == nil then
        return ""
    end

    if type(value) ~= "string" then
        if not hasWarnedSafeLowerCast then
            local diagnostics = GetDiagnostics()
            if
                diagnostics
                and diagnostics.IsDebugEnabled
                and diagnostics.IsDebugEnabled(diagnostics)
                and diagnostics.Warn
            then
                diagnostics.Warn(
                    "QuestList.SafeLower casting non-string value (type=%s, value=%s)",
                    type(value),
                    tostring(value)
                )
            end
            hasWarnedSafeLowerCast = true
        end

        value = tostring(value)
    end

    local lowerFn = localeAwareToLower
    if type(lowerFn) ~= "function" then
        lowerFn = rawget(_G, "LocaleAwareToLower")
        if type(lowerFn) == "function" then
            localeAwareToLower = lowerFn
        end
    end

    if type(lowerFn) == "function" then
        local ok, lowered = pcall(lowerFn, value)
        if ok and type(lowered) == "string" then
            return lowered
        end
    end

    local ok, lowered = pcall(string.lower, value)
    if ok and type(lowered) == "string" then
        return lowered
    end

    return tostring(value)
end

local QUEST_LOG_LIMIT = rawget(_G, "MAX_JOURNAL_QUESTS") or 25

local function StripProgressDecorations(text)
    if type(text) ~= "string" then
        return nil
    end

    local sanitized = text
    sanitized = sanitized:gsub("%s*%(%s*%d+%s*/%s*%d+%s*%)", "")
    sanitized = sanitized:gsub("%s*%[%s*%d+%s*/%s*%d+%s*%]", "")
    sanitized = sanitized:gsub("%s+", " ")
    sanitized = sanitized:gsub("^%s+", "")
    sanitized = sanitized:gsub("%s+$", "")

    if sanitized == "" then
        return nil
    end

    return sanitized
end

local function NormalizeObjectiveDisplayText(text)
    if type(text) ~= "string" then
        return nil
    end

    local displayText = text
    if zo_strformat then
        displayText = zo_strformat("<<1>>", displayText)
    end

    displayText = displayText:gsub("\r\n", "\n")
    displayText = displayText:gsub("\r", "\n")
    displayText = displayText:gsub("\t", " ")
    displayText = displayText:gsub("\n+", " ")
    displayText = displayText:gsub("^%s+", "")
    displayText = displayText:gsub("%s+$", "")

    if displayText == "" then
        return nil
    end

    return displayText
end

local function ShouldUseHeaderText(candidate, objectives)
    if type(candidate) ~= "string" then
        return nil
    end

    local headerText = candidate
    headerText = headerText:gsub("%s+", " ")
    headerText = headerText:gsub("^%s+", "")
    headerText = headerText:gsub("%s+$", "")

    if headerText == "" then
        return nil
    end

    if #headerText > 140 then
        return nil
    end

    local sentenceCount = 0
    headerText:gsub("[%.%!%?]", function()
        sentenceCount = sentenceCount + 1
    end)
    if sentenceCount >= 2 and #headerText > 80 then
        return nil
    end

    if objectives and type(objectives) == "table" then
        local headerLower = string.lower(headerText)
        for index = 1, #objectives do
            local objective = objectives[index]
            local displayText = objective and objective.displayText
            if type(displayText) == "string" then
                local comparison = string.lower(displayText)
                if comparison == headerLower then
                    return nil
                end
            end
        end
    end

    return headerText
end

local function AcquireTimestampMs()
    if type(GetFrameTimeMilliseconds) == "function" then
        return GetFrameTimeMilliseconds()
    end

    if type(GetGameTimeMilliseconds) == "function" then
        return GetGameTimeMilliseconds()
    end

    if type(GetFrameTimeSeconds) == "function" then
        local seconds = GetFrameTimeSeconds()
        if type(seconds) == "number" then
            return math.floor(seconds * 1000 + 0.5)
        end
    end

    return nil
end

local function EvaluateStepVisibility(visibility)
    if visibility == nil then
        return true
    end

    local hiddenConstant = rawget(_G, "QUEST_STEP_VISIBILITY_HIDDEN")
    if hiddenConstant ~= nil then
        return visibility ~= hiddenConstant
    end

    return visibility ~= false
end

local function GetTotalStepConditions(journalQuestIndex, stepIndex, reportedTotal)
    local totalConditions = tonumber(reportedTotal) or 0

    if type(GetJournalQuestNumConditions) == "function" then
        local countedConditions = GetJournalQuestNumConditions(journalQuestIndex, stepIndex)
        if type(countedConditions) == "number" and countedConditions > totalConditions then
            totalConditions = countedConditions
        end
    end

    return totalConditions
end

local function CollectActiveObjectivesExpanded(journalIndex, questIsComplete)
    if type(GetJournalQuestNumSteps) ~= "function" or type(GetJournalQuestStepInfo) ~= "function" then
        return {}, nil
    end

    local objectiveList = {}
    local seen = {}
    local fallbackStepText = nil
    local fallbackObjectiveText = nil

    local numSteps = GetJournalQuestNumSteps(journalIndex)
    if type(numSteps) ~= "number" or numSteps <= 0 then
        return objectiveList, fallbackStepText
    end

    for stepIndex = 1, numSteps do
        local stepText, visibility, _, trackerOverrideText, stepNumConditions = GetJournalQuestStepInfo(journalIndex, stepIndex)
        local sanitizedOverrideText = StripProgressDecorations(trackerOverrideText)
        local sanitizedStepText = StripProgressDecorations(stepText)
        local fallbackObjectiveCandidate = nil

        local stepIsVisible = EvaluateStepVisibility(visibility)

        if questIsComplete and not stepIsVisible then
            stepIsVisible = true
        end

        if stepIsVisible then
            local fallbackStepCandidate = sanitizedOverrideText or sanitizedStepText
            if not fallbackStepText and fallbackStepCandidate then
                fallbackStepText = fallbackStepCandidate
            end

            fallbackObjectiveCandidate = NormalizeObjectiveDisplayText(trackerOverrideText) or NormalizeObjectiveDisplayText(stepText)
            if not fallbackObjectiveText and fallbackObjectiveCandidate then
                fallbackObjectiveText = fallbackObjectiveCandidate
            end

            local addedObjectiveForStep = false

            local totalConditions = GetTotalStepConditions(journalIndex, stepIndex, stepNumConditions)

            if totalConditions > 0 and type(GetJournalQuestConditionInfo) == "function" then
                for conditionIndex = 1, totalConditions do
                    local conditionText, current, maxValue, isFailCondition, isConditionComplete, _, isConditionVisible = GetJournalQuestConditionInfo(journalIndex, stepIndex, conditionIndex)
                    local formattedCondition = NormalizeObjectiveDisplayText(conditionText)
                    local isVisibleCondition = (isConditionVisible ~= false)
                    if questIsComplete and not isVisibleCondition then
                        isVisibleCondition = true
                    end
                    local isFail = (isFailCondition == true)

                    if formattedCondition and isVisibleCondition and not isFail then
                        addedObjectiveForStep = true

                        if not seen[formattedCondition] then
                            seen[formattedCondition] = true
                            objectiveList[#objectiveList + 1] = {
                                displayText = formattedCondition,
                                current = tonumber(current) or 0,
                                max = tonumber(maxValue) or 0,
                                complete = isConditionComplete == true,
                                isTurnIn = false,
                            }
                        end
                    end
                end
            end

            if not addedObjectiveForStep and fallbackObjectiveCandidate and not seen[fallbackObjectiveCandidate] then
                seen[fallbackObjectiveCandidate] = true
                objectiveList[#objectiveList + 1] = {
                    displayText = fallbackObjectiveCandidate,
                    current = 0,
                    max = 0,
                    complete = false,
                    isTurnIn = false,
                }
                addedObjectiveForStep = true
            end
        end
    end

    if #objectiveList == 0 and fallbackObjectiveText and not seen[fallbackObjectiveText] then
        objectiveList[1] = {
            displayText = fallbackObjectiveText,
            current = 0,
            max = 0,
            complete = false,
            isTurnIn = false,
        }
    end

    return objectiveList, fallbackStepText
end

local function CollectQuestStepsExpanded(journalQuestIndex)
    local questSteps = {}

    local isComplete = false
    if GetJournalQuestIsComplete then
        isComplete = GetJournalQuestIsComplete(journalQuestIndex)
    elseif IsJournalQuestComplete then
        isComplete = IsJournalQuestComplete(journalQuestIndex)
    end

    local fallbackHeaderText = nil
    local objectives, fallbackStepText = CollectActiveObjectivesExpanded(journalQuestIndex, isComplete)

    if type(GetJournalQuestNumSteps) == "function" and type(GetJournalQuestStepInfo) == "function" then
        local numSteps = GetJournalQuestNumSteps(journalQuestIndex) or 0
        for stepIndex = 1, numSteps do
            local stepText, stepType, numConditions, isVisible, isCompleteStep, isOptional, isTracked = GetJournalQuestStepInfo(journalQuestIndex, stepIndex)
            local stepObjectives = {}
            local stepHeader = nil

            local totalConditions = GetTotalStepConditions(journalQuestIndex, stepIndex, numConditions)

            local hasVisibleConditions = false

            if totalConditions > 0 and type(GetJournalQuestConditionInfo) == "function" then
                for conditionIndex = 1, totalConditions do
                    local conditionText, current, maxValue, isFailCondition, isConditionComplete, isCreditShared, isConditionVisible = GetJournalQuestConditionInfo(journalQuestIndex, stepIndex, conditionIndex)
                    local formattedCondition = NormalizeObjectiveDisplayText(conditionText)
                    local isVisibleCondition = (isConditionVisible ~= false)
                    if isComplete and not isVisibleCondition then
                        isVisibleCondition = true
                    end

                    local isFail = (isFailCondition == true)
                    local isCompleteCondition = (isConditionComplete == true)

                    if formattedCondition and isVisibleCondition and not isFail then
                        hasVisibleConditions = true

                        stepObjectives[#stepObjectives + 1] = {
                            displayText = formattedCondition,
                            current = tonumber(current) or 0,
                            max = tonumber(maxValue) or 0,
                            complete = isCompleteCondition,
                            isTurnIn = false,
                        }
                    end
                end
            end

            local stepHeaderCandidate = NormalizeObjectiveDisplayText(stepText)
            if stepHeaderCandidate then
                stepHeader = ShouldUseHeaderText(stepHeaderCandidate, stepObjectives)
            end

            if stepHeader and not hasVisibleConditions then
                stepObjectives[#stepObjectives + 1] = {
                    displayText = stepHeader,
                    current = 0,
                    max = 0,
                    complete = false,
                    isTurnIn = false,
                }
                stepHeader = nil
            end

            questSteps[#questSteps + 1] = {
                stepIndex = stepIndex,
                stepText = stepText,
                stepType = stepType,
                isVisible = (isVisible ~= false),
                isComplete = (isCompleteStep == true),
                isOptional = (isOptional == true),
                isTracked = (isTracked == true),
                conditions = stepObjectives,
                headerText = stepHeader,
            }
        end
    end

    if #questSteps == 0 and fallbackStepText then
        questSteps[1] = {
            stepIndex = 1,
            stepText = fallbackStepText,
            stepType = nil,
            isVisible = true,
            isComplete = isComplete,
            isOptional = false,
            isTracked = false,
            conditions = objectives,
            headerText = ShouldUseHeaderText(fallbackHeaderText or fallbackStepText, objectives),
        }
    elseif #questSteps > 0 then
        for stepIndex = 1, #questSteps do
            local step = questSteps[stepIndex]
            if step and not step.headerText then
                local fallbackHeader = ShouldUseHeaderText(step.stepText, step.conditions)
                if fallbackHeader then
                    step.headerText = fallbackHeader
                end
            end
        end
    end

    return questSteps
end

local function CollectQuestStepsFocused(journalQuestIndex)
    local steps = {}

    if type(GetJournalQuestNumSteps) ~= "function" or type(GetJournalQuestStepInfo) ~= "function" then
        return steps
    end

    local numSteps = GetJournalQuestNumSteps(journalQuestIndex)
    if type(numSteps) ~= "number" or numSteps <= 0 then
        return steps
    end

    local firstVisibleStep = nil
    local focusedStep = nil

    for stepIndex = 1, numSteps do
        local stepText, visibility, stepType, trackerOverrideText, stepNumConditions = GetJournalQuestStepInfo(journalQuestIndex, stepIndex)

        local isStepVisible = EvaluateStepVisibility(visibility)
        local stepData = {
            stepIndex = stepIndex,
            stepText = stepText,
            stepType = stepType,
            trackerOverrideText = trackerOverrideText,
            isVisible = isStepVisible,
            totalConditions = GetTotalStepConditions(journalQuestIndex, stepIndex, stepNumConditions),
            conditions = {},
            hasVisibleIncomplete = false,
        }

        if isStepVisible and not firstVisibleStep then
            firstVisibleStep = stepData
        end

        if stepData.totalConditions > 0 and type(GetJournalQuestConditionInfo) == "function" then
            for conditionIndex = 1, stepData.totalConditions do
                local conditionText, current, maxValue, isFailCondition, isConditionComplete, _, isConditionVisible = GetJournalQuestConditionInfo(journalQuestIndex, stepIndex, conditionIndex)
                local visibleCondition = (isConditionVisible ~= false)

                if visibleCondition and type(conditionText) == "string" and conditionText ~= "" then
                    local conditionEntry = {
                        displayText = conditionText,
                        text = conditionText,
                        current = tonumber(current) or 0,
                        max = tonumber(maxValue) or 0,
                        complete = (isConditionComplete == true),
                        isTurnIn = false,
                        isVisible = true,
                        isFailCondition = (isFailCondition == true),
                    }

                    stepData.conditions[#stepData.conditions + 1] = conditionEntry

                    if not conditionEntry.complete and not conditionEntry.isFailCondition then
                        stepData.hasVisibleIncomplete = true
                    end
                end
            end
        end

        if isStepVisible then
            local hasOverride = type(trackerOverrideText) == "string" and trackerOverrideText ~= ""
            if hasOverride or stepData.hasVisibleIncomplete then
                focusedStep = stepData
                break
            end
        end
    end

    local selectedStep = focusedStep or firstVisibleStep
    if not selectedStep or not selectedStep.isVisible then
        return steps
    end

    local trackerOverrideText = nil
    if type(selectedStep.trackerOverrideText) == "string" and selectedStep.trackerOverrideText ~= "" then
        trackerOverrideText = selectedStep.trackerOverrideText
    end

    local conditionList = {}

    if trackerOverrideText then
        conditionList[1] = {
            displayText = trackerOverrideText,
            text = trackerOverrideText,
            current = 0,
            max = 0,
            complete = false,
            isTurnIn = false,
            isVisible = true,
            isFailCondition = false,
            forceDisplay = true,
        }
    else
        for index = 1, #selectedStep.conditions do
            local condition = selectedStep.conditions[index]
            if condition and condition.isVisible ~= false and not condition.isFailCondition and not condition.complete then
                conditionList[#conditionList + 1] = condition
            end
        end
    end

    local stepIsComplete = false
    if not trackerOverrideText and #conditionList == 0 then
        stepIsComplete = true
    end

    steps[1] = {
        stepIndex = selectedStep.stepIndex,
        stepText = selectedStep.stepText,
        stepType = selectedStep.stepType,
        isVisible = selectedStep.isVisible ~= false,
        isComplete = stepIsComplete,
        isOptional = false,
        isTracked = false,
        conditions = conditionList,
        headerText = nil,
    }

    return steps
end

local function CollectQuestSteps(journalQuestIndex)
    if GetObjectiveMode() == "expanded" then
        return CollectQuestStepsExpanded(journalQuestIndex)
    end

    return CollectQuestStepsFocused(journalQuestIndex)
end

local function CollectLocationInfo(journalQuestIndex)
    local zoneName, subZoneName, zoneIndex, poiIndex = GetJournalQuestLocationInfo(journalQuestIndex)
    zoneName = zoneName ~= "" and zoneName or nil
    subZoneName = subZoneName ~= "" and subZoneName or nil

    return {
        zoneName = zoneName,
        subZoneName = subZoneName,
        zoneIndex = zoneIndex,
        poiIndex = poiIndex,
    }
end

local function CopyParentInfo(parent)
    if not parent then
        return nil
    end

    return {
        key = parent.key,
        name = parent.name,
        order = parent.order,
        type = parent.type,
    }
end

local CATEGORY_GROUP_DEFINITIONS = {
    MAIN_STORY = {
        order = 10,
        labelId = rawget(_G, "SI_QUEST_JOURNAL_CATEGORY_MAIN_STORY"),
        fallbackName = "Main Story",
        typeId = rawget(_G, "ZO_QUEST_JOURNAL_CATEGORY_TYPE_MAIN_STORY"),
    },
    ZONE_STORY = {
        order = 20,
        labelId = rawget(_G, "SI_QUEST_JOURNAL_CATEGORY_ZONE_STORY"),
        fallbackName = "Zone Story",
        typeId = rawget(_G, "ZO_QUEST_JOURNAL_CATEGORY_TYPE_ZONE_STORY"),
    },
    ZONE = {
        order = 30,
        labelId = rawget(_G, "SI_QUEST_JOURNAL_CATEGORY_ZONE"),
        fallbackName = "Zone",
        typeId = rawget(_G, "ZO_QUEST_JOURNAL_CATEGORY_TYPE_ZONE"),
    },
    GUILD = {
        order = 40,
        labelId = rawget(_G, "SI_QUEST_JOURNAL_CATEGORY_GUILD"),
        fallbackName = "Guild",
        typeId = rawget(_G, "ZO_QUEST_JOURNAL_CATEGORY_TYPE_GUILD"),
    },
    CRAFTING = {
        order = 50,
        labelId = rawget(_G, "SI_QUEST_JOURNAL_CATEGORY_CRAFTING"),
        fallbackName = "Crafting",
        typeId = rawget(_G, "ZO_QUEST_JOURNAL_CATEGORY_TYPE_CRAFTING"),
    },
    DUNGEON = {
        order = 60,
        labelId = rawget(_G, "SI_QUEST_JOURNAL_CATEGORY_DUNGEON"),
        fallbackName = "Dungeon",
        typeId = rawget(_G, "ZO_QUEST_JOURNAL_CATEGORY_TYPE_DUNGEON"),
    },
    ALLIANCE_WAR = {
        order = 70,
        labelId = rawget(_G, "SI_QUEST_JOURNAL_CATEGORY_ALLIANCE_WAR"),
        fallbackName = "Alliance War",
        typeId = rawget(_G, "ZO_QUEST_JOURNAL_CATEGORY_TYPE_ALLIANCE_WAR"),
    },
    PROLOGUE = {
        order = 80,
        labelId = rawget(_G, "SI_QUEST_JOURNAL_CATEGORY_PROLOGUE"),
        fallbackName = "Prologue",
        typeId = rawget(_G, "ZO_QUEST_JOURNAL_CATEGORY_TYPE_PROLOGUE"),
    },
    REPEATABLE = {
        order = 90,
        labelId = rawget(_G, "SI_QUEST_JOURNAL_CATEGORY_REPEATABLE"),
        fallbackName = "Repeatable",
        typeId = rawget(_G, "ZO_QUEST_JOURNAL_CATEGORY_TYPE_REPEATABLE"),
    },
    COMPANION = {
        order = 100,
        labelId = rawget(_G, "SI_QUEST_JOURNAL_CATEGORY_COMPANION"),
        fallbackName = "Companion",
        typeId = rawget(_G, "ZO_QUEST_JOURNAL_CATEGORY_TYPE_COMPANION"),
    },
    MISC = {
        order = 110,
        labelId = rawget(_G, "SI_QUEST_JOURNAL_CATEGORY_MISC"),
        fallbackName = "Miscellaneous",
        typeId = rawget(_G, "ZO_QUEST_JOURNAL_CATEGORY_TYPE_MISCELLANEOUS"),
    },
}

local DEFAULT_GROUP_KEY = "MISC"

local function ResolveDefinitionName(definition)
    if definition and definition.labelId and GetString then
        local label = GetString(definition.labelId)
        if label and label ~= "" then
            return label
        end
    end

    if definition then
        return definition.fallbackName
    end

    return ""
end

local groupEntryCache = {}
local baseCategoryCache = nil

local function ResetBaseCategoryCacheInternal()
    baseCategoryCache = nil
end

local function GetGroupDefinition(groupKey)
    return CATEGORY_GROUP_DEFINITIONS[groupKey] or CATEGORY_GROUP_DEFINITIONS[DEFAULT_GROUP_KEY]
end

local function GetGroupEntry(groupKey)
    groupKey = groupKey or DEFAULT_GROUP_KEY

    if groupEntryCache[groupKey] then
        return groupEntryCache[groupKey]
    end

    local definition = GetGroupDefinition(groupKey)
    local entry = {
        key = groupKey,
        name = ResolveDefinitionName(definition),
        order = definition and definition.order or 0,
        type = definition and definition.typeId or nil,
    }

    groupEntryCache[groupKey] = entry
    return entry
end

local function NormalizeNameForKey(name)
    if not name or name == "" then
        return nil
    end

    local normalized = tostring(name)
    normalized = normalized:gsub("|[cC]%x%x%x%x%x%x%x%x", "")
    normalized = normalized:gsub("|[rR]", "")
    normalized = normalized:gsub("%s+", " ")
    normalized = normalized:gsub("[^%w%s\128-\255]", "")
    normalized = normalized:lower()
    normalized = normalized:gsub("%s", "_")
    normalized = normalized:gsub("_+", "_")
    normalized = normalized:gsub("^_", "")
    normalized = normalized:gsub("_$", "")

    if normalized == "" then
        return nil
    end

    return normalized
end

local function RegisterCategoryName(lookup, name, entry)
    if not lookup or not entry then
        return
    end

    if not name or name == "" then
        return
    end

    local bucket = lookup[name]
    if not bucket then
        bucket = {}
        lookup[name] = bucket
    end

    bucket[#bucket + 1] = entry
end

local function RegisterCategoryLookupVariants(lookup, name, entry)
    if not lookup or not entry then
        return
    end

    RegisterCategoryName(lookup, name, entry)

    local normalized = NormalizeNameForKey(name)
    if normalized and normalized ~= name then
        RegisterCategoryName(lookup, normalized, entry)
    end
end

local function FetchCategoryCandidates(lookup, name)
    if not lookup then
        return nil
    end

    if not name or name == "" then
        return nil
    end

    local candidates = lookup[name]
    if candidates then
        return candidates
    end

    local normalized = NormalizeNameForKey(name)
    if normalized then
        return lookup[normalized]
    end

    return nil
end

local function ExtractCategoryIdentifier(categoryData)
    if type(categoryData) ~= "table" then
        return nil
    end

    if categoryData.identifier ~= nil then
        return categoryData.identifier
    end

    local getter = categoryData.GetIdentifier
    if type(getter) == "function" then
        local ok, value = pcall(getter, categoryData)
        if ok then
            return value
        end
    end

    return nil
end

local function BuildLeafKey(groupEntry, identifier, name, orderSuffix)
    local parts = { groupEntry.key }

    if identifier ~= nil then
        parts[#parts + 1] = tostring(identifier)
    end

    local normalizedName = NormalizeNameForKey(name)
    if normalizedName then
        parts[#parts + 1] = normalizedName
    end

    parts[#parts + 1] = tostring(orderSuffix or 0)

    return table.concat(parts, ":")
end

local function CreateLeafEntry(groupEntry, name, orderSuffix, categoryType, identifier, overrideKey)
    local leafOrder = orderSuffix or 0
    local key = overrideKey or BuildLeafKey(groupEntry, identifier, name, leafOrder)

    local entry = {
        key = key,
        name = name or groupEntry.name,
        order = (groupEntry.order or 0) * 1000 + leafOrder,
        type = categoryType,
        groupKey = groupEntry.key,
        groupName = groupEntry.name,
        groupOrder = groupEntry.order,
        groupType = groupEntry.type,
        rawOrder = leafOrder,
        identifier = identifier,
    }

    entry.parent = CopyParentInfo({
        key = groupEntry.key,
        name = groupEntry.name,
        order = groupEntry.order,
        type = groupEntry.type,
    })

    return entry
end

local function CloneCategoryEntry(entry)
    if not entry then
        return nil
    end

    local copy = {
        key = entry.key,
        name = entry.name,
        order = entry.order,
        type = entry.type,
        groupKey = entry.groupKey,
        groupName = entry.groupName,
        groupOrder = entry.groupOrder,
        groupType = entry.groupType,
        rawOrder = entry.rawOrder,
        identifier = entry.identifier,
    }

    if entry.parent then
        copy.parent = CopyParentInfo(entry.parent)
    elseif entry.groupKey or entry.groupName then
        copy.parent = CopyParentInfo({
            key = entry.groupKey,
            name = entry.groupName,
            order = entry.groupOrder,
            type = entry.groupType,
        })
    end

    if copy.parent then
        copy.parentKey = copy.parent.key
        copy.parentName = copy.parent.name
    end

    return copy
end

local function BuildCategoryTypeToGroupMapping()
    local mapping = {}

    local function assign(constantName, groupKey)
        local value = rawget(_G, constantName)
        if value ~= nil then
            mapping[value] = groupKey
        end
    end

    assign("ZO_QUEST_JOURNAL_CATEGORY_TYPE_MAIN_STORY", "MAIN_STORY")
    assign("ZO_QUEST_JOURNAL_CATEGORY_TYPE_ZONE_STORY", "ZONE_STORY")
    assign("ZO_QUEST_JOURNAL_CATEGORY_TYPE_ZONE", "ZONE")
    assign("ZO_QUEST_JOURNAL_CATEGORY_TYPE_GUILD", "GUILD")
    assign("ZO_QUEST_JOURNAL_CATEGORY_TYPE_CRAFTING", "CRAFTING")
    assign("ZO_QUEST_JOURNAL_CATEGORY_TYPE_DUNGEON", "DUNGEON")
    assign("ZO_QUEST_JOURNAL_CATEGORY_TYPE_ALLIANCE_WAR", "ALLIANCE_WAR")
    assign("ZO_QUEST_JOURNAL_CATEGORY_TYPE_PROLOGUE", "PROLOGUE")
    assign("ZO_QUEST_JOURNAL_CATEGORY_TYPE_REPEATABLE", "REPEATABLE")
    assign("ZO_QUEST_JOURNAL_CATEGORY_TYPE_COMPANION", "COMPANION")
    assign("ZO_QUEST_JOURNAL_CATEGORY_TYPE_MISCELLANEOUS", "MISC")

    return mapping
end

local CATEGORY_TYPE_TO_GROUP = BuildCategoryTypeToGroupMapping()

local function ExtractCategoryName(categoryData)
    if type(categoryData) ~= "table" then
        return nil
    end

    if categoryData.name ~= nil then
        return categoryData.name
    end

    local getter = categoryData.GetName
    if type(getter) == "function" then
        local ok, value = pcall(getter, categoryData)
        if ok then
            return value
        end
    end

    return nil
end

local function ExtractCategoryType(categoryData)
    if type(categoryData) ~= "table" then
        return nil
    end

    if categoryData.type ~= nil then
        return categoryData.type
    end

    if categoryData.categoryType ~= nil then
        return categoryData.categoryType
    end

    local getter = categoryData.GetType or categoryData.GetCategoryType
    if type(getter) == "function" then
        local ok, value = pcall(getter, categoryData)
        if ok then
            return value
        end
    end

    return nil
end

local function ExtractQuestJournalIndex(questData)
    if type(questData) ~= "table" then
        return nil
    end

    if type(questData.questIndex) == "number" then
        return questData.questIndex
    end

    if type(questData.journalIndex) == "number" then
        return questData.journalIndex
    end

    local getter = questData.GetQuestIndex or questData.GetJournalIndex
    if type(getter) == "function" then
        local ok, value = pcall(getter, questData)
        if ok then
            return value
        end
    end

    return nil
end

local function ExtractQuestCategoryName(questData)
    if type(questData) ~= "table" then
        return nil
    end

    if questData.categoryName ~= nil then
        return questData.categoryName
    end

    if questData.name ~= nil and questData.category ~= nil then
        return questData.category
    end

    local getter = questData.GetCategoryName
    if type(getter) == "function" then
        local ok, value = pcall(getter, questData)
        if ok then
            return value
        end
    end

    return nil
end

local function ExtractQuestCategoryType(questData)
    if type(questData) ~= "table" then
        return nil
    end

    if questData.categoryType ~= nil then
        return questData.categoryType
    end

    if questData.type ~= nil then
        return questData.type
    end

    local getter = questData.GetCategoryType
    if type(getter) == "function" then
        local ok, value = pcall(getter, questData)
        if ok then
            return value
        end
    end

    return nil
end

local function NormalizeLeafCategory(categoryData, orderIndex)
    local categoryType = ExtractCategoryType(categoryData)
    local groupKey = CATEGORY_TYPE_TO_GROUP[categoryType] or DEFAULT_GROUP_KEY
    local groupEntry = GetGroupEntry(groupKey)
    local name = ExtractCategoryName(categoryData) or groupEntry.name
    local identifier = ExtractCategoryIdentifier(categoryData)

    return CreateLeafEntry(groupEntry, name, orderIndex or 0, categoryType, identifier)
end

local function BuildBaseCategoryCacheFromData(questList, categoryList)
    local categoriesByKey = {}
    local categoriesByName = {}
    local orderedCategories = {}

    for index = 1, #categoryList do
        local rawCategory = categoryList[index]
        local entry = NormalizeLeafCategory(rawCategory, index)
        orderedCategories[#orderedCategories + 1] = entry
        categoriesByKey[entry.key] = entry

        local categoryName = ExtractCategoryName(rawCategory)
        RegisterCategoryLookupVariants(categoriesByName, categoryName, entry)
    end

    local questCategoriesByJournalIndex = {}

    for index = 1, #questList do
        local questData = questList[index]
        local questIndex = ExtractQuestJournalIndex(questData)
        local categoryName = ExtractQuestCategoryName(questData)
        local categoryEntry = nil

        local possible = FetchCategoryCandidates(categoriesByName, categoryName)
        if categoryName and possible then
            if #possible == 1 then
                categoryEntry = possible[1]
            else
                local candidateType = ExtractQuestCategoryType(questData)
                if candidateType ~= nil then
                    for _, entry in ipairs(possible) do
                        if entry.type == candidateType then
                            categoryEntry = entry
                            break
                        end
                    end
                end
                if not categoryEntry then
                    categoryEntry = possible[1]
                end
            end
        end

        if questIndex and categoryEntry then
            questCategoriesByJournalIndex[questIndex] = categoryEntry
        end
    end

    return {
        ordered = orderedCategories,
        byKey = categoriesByKey,
        byName = categoriesByName,
        byJournalIndex = questCategoriesByJournalIndex,
    }
end

local function AcquireQuestJournalData()
    if not (QUEST_JOURNAL_MANAGER and QUEST_JOURNAL_MANAGER.GetQuestListData) then
        return nil, nil, nil
    end

    local ok, questList, categoryList, seenCategories = pcall(QUEST_JOURNAL_MANAGER.GetQuestListData, QUEST_JOURNAL_MANAGER)
    if not ok then
        return nil, nil, nil
    end

    if type(questList) ~= "table" or type(categoryList) ~= "table" then
        return nil, nil, nil
    end

    return questList, categoryList, seenCategories
end

local function AcquireBaseCategoryCache()
    if baseCategoryCache then
        return baseCategoryCache
    end

    local questList, categoryList = AcquireQuestJournalData()
    if type(questList) ~= "table" or type(categoryList) ~= "table" then
        return nil
    end

    baseCategoryCache = BuildBaseCategoryCacheFromData(questList, categoryList)
    return baseCategoryCache
end

local function GetTimestampMs()
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

local function BuildQuestTypeMapping()
    local mapping = {}
    local function assign(constantName, categoryKey)
        local value = rawget(_G, constantName)
        if value ~= nil then
            mapping[value] = categoryKey
        end
    end

    assign("QUEST_TYPE_MAIN_STORY", "MAIN_STORY")
    assign("QUEST_TYPE_GUILD", "GUILD")
    assign("QUEST_TYPE_CRAFTING", "CRAFTING")
    assign("QUEST_TYPE_DUNGEON", "DUNGEON")
    assign("QUEST_TYPE_UNDAUNTED_PLEDGE", "DUNGEON")
    assign("QUEST_TYPE_RAID", "DUNGEON")
    assign("QUEST_TYPE_AVA", "ALLIANCE_WAR")
    assign("QUEST_TYPE_AVA_GROUP", "ALLIANCE_WAR")
    assign("QUEST_TYPE_AVA_GRAND", "ALLIANCE_WAR")
    assign("QUEST_TYPE_PVP", "ALLIANCE_WAR")
    assign("QUEST_TYPE_AVA_WW", "ALLIANCE_WAR")
    assign("QUEST_TYPE_PROLOGUE", "PROLOGUE")
    assign("QUEST_TYPE_COMPANION", "COMPANION")
    assign("QUEST_TYPE_CLASS", "MISC")
    assign("QUEST_TYPE_GROUP", "MISC")
    assign("QUEST_TYPE_HOUSING", "MISC")
    assign("QUEST_TYPE_HOLIDAY_EVENT", "REPEATABLE")
    assign("QUEST_TYPE_HOLIDAY_DAILY", "REPEATABLE")
    assign("QUEST_TYPE_BATTLEGROUND", "ALLIANCE_WAR")

    return mapping
end

local function BuildDisplayTypeMapping()
    local mapping = {}
    local function assign(constantName, categoryKey)
        local value = rawget(_G, constantName)
        if value ~= nil then
            mapping[value] = categoryKey
        end
    end

    assign("QUEST_DISPLAY_TYPE_ZONE_STORY", "ZONE_STORY")
    assign("QUEST_DISPLAY_TYPE_REPEATABLE", "REPEATABLE")
    assign("QUEST_DISPLAY_TYPE_EVENT", "REPEATABLE")
    assign("QUEST_DISPLAY_TYPE_WEEKLY", "REPEATABLE")
    assign("QUEST_DISPLAY_TYPE_DAILY", "REPEATABLE")

    return mapping
end

local QUEST_TYPE_TO_CATEGORY = BuildQuestTypeMapping()
local QUEST_DISPLAY_TYPE_TO_CATEGORY = BuildDisplayTypeMapping()

local function GetCategoryKeyInternal(questType, displayType, isRepeatable, isDaily)
    if displayType and QUEST_DISPLAY_TYPE_TO_CATEGORY[displayType] then
        return QUEST_DISPLAY_TYPE_TO_CATEGORY[displayType]
    end

    if isRepeatable or isDaily then
        return "REPEATABLE"
    end

    if questType and QUEST_TYPE_TO_CATEGORY[questType] then
        return QUEST_TYPE_TO_CATEGORY[questType]
    end

    return DEFAULT_GROUP_KEY
end

local function DetermineLegacyCategory(questType, displayType, isRepeatable, isDaily)
    local key = GetCategoryKeyInternal(questType, displayType, isRepeatable, isDaily)
    local groupEntry = GetGroupEntry(key)
    return CreateLeafEntry(groupEntry, groupEntry.name, 0, groupEntry.type, groupEntry.key, groupEntry.key)
end

local function ResolveQuestCategoryInternal(journalQuestIndex, questType, displayType, isRepeatable, isDaily)
    local cache = AcquireBaseCategoryCache()
    if cache and cache.byJournalIndex then
        local entry = cache.byJournalIndex[journalQuestIndex]
        if entry then
            return CloneCategoryEntry(entry)
        end
    end

    return DetermineLegacyCategory(questType, displayType, isRepeatable, isDaily)
end

local function NormalizeQuestCategoryDataInternal(quest)
    if type(quest) ~= "table" then
        return quest
    end

    quest.flags = quest.flags or {}

    if type(quest.category) ~= "table" then
        local fallback = DetermineLegacyCategory(quest.questType, quest.displayType, quest.flags.isRepeatable, quest.flags.isDaily)
        quest.category = CloneCategoryEntry(fallback)
    end

    local category = quest.category

    if not category.groupKey or not category.groupName or category.groupOrder == nil then
        local groupKey = category.groupKey
            or CATEGORY_TYPE_TO_GROUP[category.type]
            or (quest.meta and quest.meta.groupKey)
            or CATEGORY_TYPE_TO_GROUP[quest.meta and quest.meta.categoryType]
            or (category.parent and category.parent.key)
            or GetCategoryKeyInternal(quest.questType, quest.displayType, quest.flags.isRepeatable, quest.flags.isDaily)
            or category.key

        local groupEntry = GetGroupEntry(groupKey)
        category.groupKey = groupEntry.key
        category.groupName = groupEntry.name
        category.groupOrder = groupEntry.order
        category.groupType = groupEntry.type
    end

    category.parent = QuestList.GetCategoryParentCopy(category)

    if not category.order then
        local orderBase = category.groupOrder or 0
        category.order = orderBase * 1000 + (category.rawOrder or 0)
    end

    quest.category = category

    quest.meta = quest.meta or {}
    local meta = quest.meta
    meta.questType = meta.questType or quest.questType
    meta.displayType = meta.displayType or quest.displayType
    meta.categoryType = meta.categoryType or category.type
    meta.categoryKey = meta.categoryKey or category.key
    meta.groupKey = meta.groupKey or category.groupKey
    meta.groupName = meta.groupName or category.groupName
    meta.parentKey = meta.parentKey or (category.parent and category.parent.key)
    meta.parentName = meta.parentName or (category.parent and category.parent.name)
    meta.zoneName = meta.zoneName or quest.zoneName

    if meta.isRepeatable == nil then
        meta.isRepeatable = quest.flags.isRepeatable
    end

    if meta.isDaily == nil then
        meta.isDaily = quest.flags.isDaily
    end

    return quest
end

local function GetCategoryParentCopyInternal(category)
    if not category then
        return nil
    end

    if category.parent then
        return CopyParentInfo(category.parent)
    end

    if category.groupKey or category.groupName then
        return CopyParentInfo({
            key = category.groupKey,
            name = category.groupName,
            order = category.groupOrder,
            type = category.groupType,
        })
    end

    return nil
end

function QuestList.GetCategoryParentCopy(category)
    return GetCategoryParentCopyInternal(category)
end

local function BuildCategoriesIndexInternal(quests)
    local categoriesByKey = {}
    local orderedKeys = {}

    for index = 1, #quests do
        local quest = quests[index]
        local category = quest.category or {}
        local key = category.key or string.format("unknown:%d", index)
        local categoryEntry = categoriesByKey[key]
        if not categoryEntry then
            categoryEntry = {
                key = key,
                name = category.name or "",
                order = category.order or 0,
                type = category.type,
                groupKey = category.groupKey,
                groupName = category.groupName,
                groupOrder = category.groupOrder,
                groupType = category.groupType,
                parent = GetCategoryParentCopyInternal(category),
                quests = {},
            }
            categoriesByKey[key] = categoryEntry
            orderedKeys[#orderedKeys + 1] = key
        end
        categoryEntry.quests[#categoryEntry.quests + 1] = quest
    end

    table.sort(orderedKeys, function(left, right)
        local leftOrder = categoriesByKey[left].order or 0
        local rightOrder = categoriesByKey[right].order or 0
        if leftOrder ~= rightOrder then
            return leftOrder < rightOrder
        end
        return left < right
    end)

    local orderedCategories = {}
    for index = 1, #orderedKeys do
        local key = orderedKeys[index]
        orderedCategories[index] = categoriesByKey[key]
    end

    return {
        byKey = categoriesByKey,
        ordered = orderedCategories,
    }
end

local function AppendSignaturePart(parts, value)
    parts[#parts + 1] = tostring(value)
end

local function BuildQuestSignatureInternal(quest)
    local parts = {}
    AppendSignaturePart(parts, quest.journalIndex)
    AppendSignaturePart(parts, quest.questId or "nil")
    AppendSignaturePart(parts, quest.name or "")
    AppendSignaturePart(parts, quest.zoneName or "")

    local category = quest.category or {}
    AppendSignaturePart(parts, category.key or "nil")
    AppendSignaturePart(parts, (category.parent and category.parent.key) or "nil")
    AppendSignaturePart(parts, category.type or "nil")
    AppendSignaturePart(parts, category.groupKey or "nil")
    AppendSignaturePart(parts, category.groupOrder or "nil")

    local meta = quest.meta or {}
    AppendSignaturePart(parts, meta.parentKey or "nil")
    AppendSignaturePart(parts, meta.categoryType or "nil")
    AppendSignaturePart(parts, meta.groupKey or "nil")

    AppendSignaturePart(parts, quest.flags.tracked and 1 or 0)
    AppendSignaturePart(parts, quest.flags.assisted and 1 or 0)
    AppendSignaturePart(parts, quest.flags.isComplete and 1 or 0)
    AppendSignaturePart(parts, quest.flags.isRepeatable and 1 or 0)
    AppendSignaturePart(parts, quest.flags.isDaily and 1 or 0)
    AppendSignaturePart(parts, quest.questType or "nil")
    AppendSignaturePart(parts, quest.displayType or "nil")
    AppendSignaturePart(parts, quest.instanceDisplayType or "nil")

    for stepIndex = 1, #quest.steps do
        local step = quest.steps[stepIndex]
        AppendSignaturePart(parts, step.stepText or "")
        AppendSignaturePart(parts, step.stepType or "")
        AppendSignaturePart(parts, step.isVisible and 1 or 0)
        AppendSignaturePart(parts, step.isComplete and 1 or 0)
        for conditionIndex = 1, #step.conditions do
            local condition = step.conditions[conditionIndex]
            AppendSignaturePart(parts, condition.displayText or condition.text or "")
            AppendSignaturePart(parts, condition.current or "")
            AppendSignaturePart(parts, condition.max or "")
            AppendSignaturePart(parts, condition.complete and 1 or 0)
            AppendSignaturePart(parts, condition.isVisible and 1 or 0)
            AppendSignaturePart(parts, condition.isFailCondition and 1 or 0)
        end
    end

    return table.concat(parts, "|")
end

local function BuildOverallSignatureInternal(quests)
    local parts = {}
    for index = 1, #quests do
        parts[index] = quests[index].signature
    end
    return table.concat(parts, "\31")
end

local function CompareStrings(left, right)
    if left == right then
        return 0
    end

    if left == nil then
        return 1
    end

    if right == nil then
        return -1
    end

    local leftLower = SafeLower(left)
    local rightLower = SafeLower(right)

    if leftLower == rightLower then
        local leftValue = tostring(left)
        local rightValue = tostring(right)
        if leftValue < rightValue then
            return -1
        elseif leftValue > rightValue then
            return 1
        end
        return 0
    end

    if leftLower < rightLower then
        return -1
    end

    return 1
end

local function CompareQuestEntries(left, right)
    if left == right then
        return false
    end

    if not left then
        return false
    end

    if not right then
        return true
    end

    if left.flags.assisted ~= right.flags.assisted then
        return left.flags.assisted and not right.flags.assisted
    end

    if left.flags.tracked ~= right.flags.tracked then
        return left.flags.tracked and not right.flags.tracked
    end

    local leftCategory = left.category or {}
    local rightCategory = right.category or {}

    local leftGroupOrder = leftCategory.groupOrder or 0
    local rightGroupOrder = rightCategory.groupOrder or 0
    if leftGroupOrder ~= rightGroupOrder then
        return leftGroupOrder < rightGroupOrder
    end

    local leftOrder = leftCategory.order or 0
    local rightOrder = rightCategory.order or 0
    if leftOrder ~= rightOrder then
        return leftOrder < rightOrder
    end

    local leftZoneLower = SafeLower(left.zoneName)
    local rightZoneLower = SafeLower(right.zoneName)
    if leftZoneLower ~= rightZoneLower then
        return leftZoneLower < rightZoneLower
    end

    local leftZoneValue = tostring(left.zoneName or "")
    local rightZoneValue = tostring(right.zoneName or "")
    if leftZoneValue ~= rightZoneValue then
        return leftZoneValue < rightZoneValue
    end

    local leftNameLower = SafeLower(left.name)
    local rightNameLower = SafeLower(right.name)
    if leftNameLower ~= rightNameLower then
        return leftNameLower < rightNameLower
    end

    local leftNameValue = tostring(left.name or "")
    local rightNameValue = tostring(right.name or "")
    if leftNameValue ~= rightNameValue then
        return leftNameValue < rightNameValue
    end

    if left.questId and right.questId then
        return left.questId < right.questId
    end

    return left.journalIndex < right.journalIndex
end

local function BuildQuestEntry(journalQuestIndex)
    local questName, backgroundText, activeStepText, activeStepType, questLevel, zoneName, questType, instanceDisplayType, isRepeatable, isDaily, questDescription, displayType = GetJournalQuestInfo(journalQuestIndex)
    if not questName or questName == "" then
        return nil
    end

    isRepeatable = not not isRepeatable
    isDaily = not not isDaily

    local questId = GetJournalQuestId and GetJournalQuestId(journalQuestIndex) or nil
    local isTracked = IsJournalQuestTracked and IsJournalQuestTracked(journalQuestIndex) or false
    isTracked = not not isTracked
    local isAssisted = false
    if GetTrackedIsAssisted and isTracked then
        isAssisted = GetTrackedIsAssisted(TRACK_TYPE_QUEST, journalQuestIndex) or false
    end
    isAssisted = not not isAssisted

    local isComplete = false
    if GetJournalQuestIsComplete then
        isComplete = GetJournalQuestIsComplete(journalQuestIndex)
    elseif IsJournalQuestComplete then
        isComplete = IsJournalQuestComplete(journalQuestIndex)
    end
    isComplete = not not isComplete

    local category = ResolveQuestCategoryInternal(journalQuestIndex, questType, displayType, isRepeatable, isDaily)

    local questEntry = {
        journalIndex = journalQuestIndex,
        questId = questId,
        name = questName,
        backgroundText = backgroundText,
        activeStepText = activeStepText,
        activeStepType = activeStepType,
        level = questLevel,
        zoneName = zoneName,
        questType = questType,
        instanceDisplayType = instanceDisplayType,
        displayType = displayType,
        flags = {
            tracked = isTracked,
            assisted = isAssisted,
            isComplete = isComplete,
            isRepeatable = isRepeatable,
            isDaily = isDaily,
        },
        category = category,
        steps = CollectQuestSteps(journalQuestIndex),
        location = CollectLocationInfo(journalQuestIndex),
        description = questDescription,
    }

    questEntry.name = questEntry.name or ""
    questEntry.zoneName = questEntry.zoneName or ""
    questEntry.category = questEntry.category or {}

    questEntry.meta = {
        questType = questType,
        displayType = displayType,
        categoryType = category and category.type or nil,
        categoryKey = category and category.key or nil,
        groupKey = category and category.groupKey or nil,
        groupName = category and category.groupName or nil,
        parentKey = category and category.parent and category.parent.key or nil,
        parentName = category and category.parent and category.parent.name or nil,
        zoneName = zoneName,
        isRepeatable = isRepeatable,
        isDaily = isDaily,
    }

    NormalizeQuestCategoryDataInternal(questEntry)

    questEntry.signature = BuildQuestSignatureInternal(questEntry)

    return questEntry
end

local function CollectQuestEntriesInternal()
    local diagnostics = GetDiagnostics()
    if diagnostics and diagnostics.Info then
        diagnostics.Info("[QLIST] Collecting quests from QUEST_JOURNAL_MANAGER:GetQuestListData()")
    end

    local questJournalManager = QUEST_JOURNAL_MANAGER
    if not questJournalManager or type(questJournalManager.GetQuestListData) ~= "function" then
        if diagnostics and diagnostics.Error then
            diagnostics.Error("Nvk3UT QuestList: QUEST_JOURNAL_MANAGER or GetQuestListData is not available")
        end
        error("Nvk3UT QuestList: QUEST_JOURNAL_MANAGER or GetQuestListData is not available")
    end

    local allQuests, allCategories, seenCategories = questJournalManager:GetQuestListData()
    if type(allQuests) ~= "table" or type(allCategories) ~= "table" then
        if diagnostics and diagnostics.Error then
            diagnostics.Error("Nvk3UT QuestList: GetQuestListData returned unexpected data")
        end
        error("Nvk3UT QuestList: GetQuestListData returned unexpected data")
    end

    local quests = {}

    for index = 1, #allQuests do
        local questData = allQuests[index]
        local journalIndex = ExtractQuestJournalIndex(questData)
        if type(journalIndex) ~= "number" then
            if diagnostics and diagnostics.Error then
                diagnostics.Error("Nvk3UT QuestList: Quest entry missing journal index (index=%s)", tostring(index))
            end
            error("Nvk3UT QuestList: GetQuestListData returned unexpected data")
        end

        local questEntry = BuildQuestEntry(journalIndex)
        if questEntry then
            quests[#quests + 1] = questEntry
        end
    end

    table.sort(quests, CompareQuestEntries)
    return quests
end

local function BuildSnapshotFromQuestsInternal(quests)
    if type(quests) ~= "table" then
        quests = {}
    end

    for index = 1, #quests do
        quests[index] = NormalizeQuestCategoryDataInternal(quests[index])
    end

    local snapshot = {
        updatedAtMs = GetTimestampMs(),
        quests = quests,
        categories = BuildCategoriesIndexInternal(quests),
        signature = BuildOverallSignatureInternal(quests),
        questById = {},
        questByJournalIndex = {},
    }

    for index = 1, #quests do
        local quest = quests[index]
        if quest then
            if quest.questId then
                snapshot.questById[quest.questId] = quest
            end
            if quest.journalIndex then
                snapshot.questByJournalIndex[quest.journalIndex] = quest
            end
        end
    end

    return snapshot
end

function QuestList:Bind(savedVars)
    self._saved = savedVars
end

function QuestList:ResetCaches()
    groupEntryCache = {}
    ResetBaseCategoryCacheInternal()
end

function QuestList.ResetBaseCategoryCache()
    ResetBaseCategoryCacheInternal()
end

function QuestList.ResolveQuestCategory(journalQuestIndex, questType, displayType, isRepeatable, isDaily)
    return ResolveQuestCategoryInternal(journalQuestIndex, questType, displayType, isRepeatable, isDaily)
end

function QuestList.NormalizeQuestCategoryData(quest)
    return NormalizeQuestCategoryDataInternal(quest)
end

function QuestList.GetCategoryKey(questType, displayType, isRepeatable, isDaily)
    return GetCategoryKeyInternal(questType, displayType, isRepeatable, isDaily)
end

function QuestList.BuildCategoriesIndex(quests)
    return BuildCategoriesIndexInternal(quests)
end

function QuestList.BuildQuestSignature(quest)
    return BuildQuestSignatureInternal(quest)
end

function QuestList.BuildOverallSignature(quests)
    return BuildOverallSignatureInternal(quests)
end

function QuestList:RefreshFromGame()
    local quests = CollectQuestEntriesInternal()
    self._lastBuild = self._lastBuild or {}
    self._lastBuild.quests = quests
    self._lastBuild.questByJournalIndex = {}
    for index = 1, #quests do
        local quest = quests[index]
        if quest and quest.journalIndex then
            self._lastBuild.questByJournalIndex[quest.journalIndex] = quest
        end
    end
    self._lastBuild.categories = BuildCategoriesIndexInternal(quests)
    self._lastBuild.signature = BuildOverallSignatureInternal(quests)
    self._lastBuild.updatedAtMs = GetTimestampMs()
    return quests
end

function QuestList:GetRawList()
    if not self._lastBuild or type(self._lastBuild.quests) ~= "table" then
        self:RefreshFromGame()
    end
    return self._lastBuild.quests or {}
end

function QuestList:GetByJournalIndex(journalIndex)
    if journalIndex == nil then
        return nil
    end

    if not self._lastBuild or type(self._lastBuild.questByJournalIndex) ~= "table" then
        self:RefreshFromGame()
    end

    return self._lastBuild.questByJournalIndex and self._lastBuild.questByJournalIndex[journalIndex] or nil
end

function QuestList:GetLastSignature()
    if not self._lastBuild then
        return nil
    end
    return self._lastBuild.signature
end

function QuestList:BuildSnapshotFromQuests(quests)
    local snapshot = BuildSnapshotFromQuestsInternal(quests)
    self._lastBuild = self._lastBuild or {}
    self._lastBuild.quests = snapshot.quests
    self._lastBuild.questByJournalIndex = snapshot.questByJournalIndex
    self._lastBuild.categories = snapshot.categories
    self._lastBuild.signature = snapshot.signature
    self._lastBuild.updatedAtMs = snapshot.updatedAtMs
    return snapshot
end

return QuestList
