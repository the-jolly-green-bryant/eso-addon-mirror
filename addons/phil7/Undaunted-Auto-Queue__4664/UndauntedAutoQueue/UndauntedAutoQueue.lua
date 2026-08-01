UndauntedAutoQueue = UndauntedAutoQueue or {}

local UAQ = UndauntedAutoQueue
local ADDON_NAME = "UndauntedAutoQueue"

local DEFAULTS = {
    difficulty = "normal",
    showDebug = false,
    window = {
        x = nil,
        y = nil,
    },
    pledgePrefixes = {
        "Pledge:",
        "Compromisso:",
    },
    queueHistory = {},
}

local DIFFICULTY = {
    normal = {
        label = "Normal",
        searchTerms = { "normal" },
        dungeonFinderIndex = 1,
    },
    veteran = {
        label = "Veteran",
        searchTerms = { "veteran", "vet", "veterano" },
        dungeonFinderIndex = 2,
    },
}

local UI = {}

-- Reversible behavior switches. Native queue-button automation is disabled by
-- default for now because the button can be unavailable while the Group panel
-- still says "Not Queued".
local USE_NATIVE_QUEUE_BUTTON = false
local USE_NATIVE_MODE_MIRROR = true
local QUEUE_STATE_POLL_MS = 1000
local MODE_SYNC_SUPPRESS_MS = 1200
local QUEUE_START_CONFIRM_MS = 10000
local QUEUE_START_MIN_HOLD_MS = 1000
local MAX_PLEDGE_ROWS = 3
local MAX_HISTORY_ENTRIES = 50

local DUNGEON_FINDER_IDS = {
    ["arx corinium"] = { normal = 8, veteran = 305 },
    ["bal sunnar"] = { normal = 613, veteran = 614 },
    ["bedlam veil"] = { normal = 640, veteran = 641 },
    ["black drake villa"] = { normal = 591, veteran = 592 },
    ["black gem foundry"] = { normal = 1039, veteran = 1040 },
    ["blackheart haven"] = { normal = 15, veteran = 321 },
    ["blessed crucible"] = { normal = 14, veteran = 320 },
    ["bloodroot forge"] = { normal = 324, veteran = 325 },
    ["castle thorn"] = { normal = 509, veteran = 510 },
    ["city of ash i"] = { normal = 10, veteran = 310 },
    ["city of ash ii"] = { normal = 322, veteran = 267 },
    ["coral aerie"] = { normal = 599, veteran = 600 },
    ["cradle of shadows"] = { normal = 295, veteran = 296 },
    ["crypt of hearts i"] = { normal = 9, veteran = 261 },
    ["crypt of hearts ii"] = { normal = 317, veteran = 318 },
    ["darkshade caverns i"] = { normal = 5, veteran = 309 },
    ["darkshade caverns ii"] = { normal = 308, veteran = 21 },
    ["depths of malatar"] = { normal = 435, veteran = 436 },
    ["direfrost keep"] = { normal = 11, veteran = 319 },
    ["earthen root enclave"] = { normal = 608, veteran = 609 },
    ["elden hollow i"] = { normal = 7, veteran = 23 },
    ["elden hollow ii"] = { normal = 303, veteran = 302 },
    ["exiled redoubt"] = { normal = 855, veteran = 856 },
    ["falkreath hold"] = { normal = 368, veteran = 369 },
    ["fang lair"] = { normal = 420, veteran = 421 },
    ["frostvault"] = { normal = 433, veteran = 434 },
    ["fungal grotto i"] = { normal = 2, veteran = 299 },
    ["fungal grotto ii"] = { normal = 18, veteran = 312 },
    ["graven deep"] = { normal = 610, veteran = 611 },
    ["icereach"] = { normal = 503, veteran = 504 },
    ["imperial city prison"] = { normal = 289, veteran = 268 },
    ["lair of maarselok"] = { normal = 496, veteran = 497 },
    ["lep seclusa"] = { normal = 857, veteran = 858 },
    ["march of sacrifices"] = { normal = 428, veteran = 429 },
    ["moon hunter keep"] = { normal = 426, veteran = 427 },
    ["moongrave fane"] = { normal = 494, veteran = 495 },
    ["naj-caldeesh"] = { normal = 1037, veteran = 1038 },
    ["oathsworn pit"] = { normal = 638, veteran = 639 },
    ["red petal bastion"] = { normal = 595, veteran = 596 },
    ["ruins of mazzatun"] = { normal = 293, veteran = 294 },
    ["scalecaller peak"] = { normal = 418, veteran = 419 },
    ["scrivener's hall"] = { normal = 615, veteran = 616 },
    ["selene's web"] = { normal = 16, veteran = 313 },
    ["shipwright's regret"] = { normal = 601, veteran = 602 },
    ["spindleclutch i"] = { normal = 3, veteran = 315 },
    ["spindleclutch ii"] = { normal = 316, veteran = 19 },
    ["stone garden"] = { normal = 507, veteran = 508 },
    ["tempest island"] = { normal = 13, veteran = 311 },
    ["the banished cells i"] = { normal = 4, veteran = 20 },
    ["the banished cells ii"] = { normal = 300, veteran = 301 },
    ["the cauldron"] = { normal = 593, veteran = 594 },
    ["the dread cellar"] = { normal = 597, veteran = 598 },
    ["unhallowed grave"] = { normal = 505, veteran = 506 },
    ["vaults of madness"] = { normal = 17, veteran = 314 },
    ["volenfell"] = { normal = 12, veteran = 304 },
    ["wayrest sewers i"] = { normal = 6, veteran = 306 },
    ["wayrest sewers ii"] = { normal = 22, veteran = 307 },
    ["white-gold tower"] = { normal = 288, veteran = 287 },
}

local function GetVeteranIconPattern()
    return "|t.-:.-:EsoUI/Art/UnitFrames/target_veteranRank_icon.dds|t%s*"
end

local function Chat(message)
    d("|c7fb7ff[Undaunted Auto Queue]|r " .. tostring(message))
end

local function Debug(message)
    if UAQ.savedVars and UAQ.savedVars.showDebug then
        Chat("|caaaaaa" .. tostring(message) .. "|r")
    end
end

local function SafeSetText(control, text)
    if control and type(control.SetText) == "function" then
        control:SetText(text)
    end
end

local function NowMilliseconds()
    if type(GetFrameTimeMilliseconds) == "function" then
        return GetFrameTimeMilliseconds()
    end

    if type(GetGameTimeMilliseconds) == "function" then
        return GetGameTimeMilliseconds()
    end

    return 0
end

local function Trim(value)
    if not value then
        return ""
    end

    return zo_strtrim(tostring(value))
end

local function Normalize(value)
    value = zo_strlower(Trim(value))
    value = value:gsub("|c%x%x%x%x%x%x", "")
    value = value:gsub("|r", "")
    value = value:gsub("%s+I$", " I")
    value = value:gsub("%s+II$", " II")
    value = value:gsub("%s+", " ")
    return zo_strtrim(value)
end

local function NormalizeDungeonKey(value)
    value = Normalize(value)
    value = value:gsub(" 1$", " i")
    value = value:gsub(" 2$", " ii")
    return value
end

local function FormatDuration(seconds)
    seconds = tonumber(seconds) or 0

    if seconds < 60 then
        return tostring(math.floor(seconds + 0.5)) .. "s"
    end

    local minutes = math.floor(seconds / 60)
    local remainingSeconds = math.floor(seconds - (minutes * 60) + 0.5)
    if minutes < 60 then
        return tostring(minutes) .. "m " .. tostring(remainingSeconds) .. "s"
    end

    local hours = math.floor(minutes / 60)
    minutes = minutes - (hours * 60)
    return tostring(hours) .. "h " .. tostring(minutes) .. "m"
end

local function GetRoleLabel(role)
    if LFG_ROLE_TANK and role == LFG_ROLE_TANK then
        return "Tank"
    end

    if LFG_ROLE_HEAL and role == LFG_ROLE_HEAL then
        return "Healer"
    end

    if LFG_ROLE_DPS and role == LFG_ROLE_DPS then
        return "Damage"
    end

    return "Damage"
end

local function GetSelectedRoleLabel()
    if type(GetSelectedLFGRole) == "function" then
        return GetRoleLabel(GetSelectedLFGRole())
    end

    return "Damage"
end

local function GetTimestamp()
    if type(GetTimeStamp) == "function" then
        return GetTimeStamp()
    end

    return 0
end

local function ContainsAny(haystack, needles)
    haystack = Normalize(haystack)

    for _, needle in ipairs(needles) do
        if haystack:find(Normalize(needle), 1, true) then
            return true
        end
    end

    return false
end

local function IsPledgeQuest(questName)
    local normalizedName = Normalize(questName)

    for _, prefix in ipairs(UAQ.savedVars.pledgePrefixes) do
        local normalizedPrefix = Normalize(prefix)
        if normalizedName:sub(1, #normalizedPrefix) == normalizedPrefix then
            return true
        end
    end

    return false
end

local function ExtractDungeonName(questName)
    local name = Trim(questName)

    for _, prefix in ipairs(UAQ.savedVars.pledgePrefixes) do
        local plainPrefix = Trim(prefix)
        if Normalize(name):sub(1, #Normalize(plainPrefix)) == Normalize(plainPrefix) then
            name = zo_strtrim(name:sub(#plainPrefix + 1))
            break
        end
    end

    name = name:gsub("^%-", "")
    name = name:gsub("^:", "")
    name = name:gsub("%s+", " ")
    return zo_strtrim(name)
end

local function QuestHasReturnToTask(questIndex)
    if type(GetJournalQuestInfo) == "function" then
        local _, _, activeStepText, _, activeStepTrackerOverrideText = GetJournalQuestInfo(questIndex)
        if ContainsAny(activeStepText, { "return to" }) or ContainsAny(activeStepTrackerOverrideText, { "return to" }) then
            return true
        end
    end

    if type(GetJournalQuestNumSteps) == "function" and type(GetJournalQuestStepInfo) == "function" then
        for stepIndex = QUEST_MAIN_STEP_INDEX, GetJournalQuestNumSteps(questIndex) do
            local stepText, _, _, stepOverrideText = GetJournalQuestStepInfo(questIndex, stepIndex)
            if ContainsAny(stepText, { "return to" }) or ContainsAny(stepOverrideText, { "return to" }) then
                return true
            end
        end
    end

    if type(GetJournalQuestNumConditions) == "function" and type(GetJournalQuestConditionInfo) == "function" then
        local maxSteps = 1
        if type(GetJournalQuestNumSteps) == "function" then
            maxSteps = GetJournalQuestNumSteps(questIndex)
        end

        for stepIndex = QUEST_MAIN_STEP_INDEX, maxSteps do
            local conditionCount = GetJournalQuestNumConditions(questIndex, stepIndex) or 0
            for conditionIndex = 1, conditionCount do
                local conditionText, _, _, _, isComplete, _, isVisible = GetJournalQuestConditionInfo(questIndex, stepIndex, conditionIndex)
                if isVisible ~= false and not isComplete and ContainsAny(conditionText, { "return to" }) then
                    return true
                end
            end
        end
    end

    return false
end

local function GetActivePledges()
    local pledges = {}

    if type(GetNumJournalQuests) ~= "function" or type(GetJournalQuestInfo) ~= "function" then
        return pledges
    end

    for questIndex = 1, GetNumJournalQuests() do
        local questName, _, _, _, _, completed = GetJournalQuestInfo(questIndex)

        if questName and not completed and IsPledgeQuest(questName) and not QuestHasReturnToTask(questIndex) then
            table.insert(pledges, {
                questIndex = questIndex,
                questName = questName,
                dungeonName = ExtractDungeonName(questName),
            })
        end
    end

    return pledges
end

local function GetPledgeKey(pledge)
    return tostring(pledge.questIndex) .. ":" .. NormalizeDungeonKey(pledge.dungeonName)
end

local function GetPledgeDisplayName(pledge, fallbackIndex)
    if pledge and pledge.dungeonName and pledge.dungeonName ~= "" then
        return pledge.dungeonName
    end

    if pledge and pledge.questName and pledge.questName ~= "" then
        return pledge.questName
    end

    return "Pledge " .. tostring(fallbackIndex)
end

local function EnsurePledgeSelections(pledges)
    UAQ.selectedPledges = UAQ.selectedPledges or {}

    local activeKeys = {}
    for _, pledge in ipairs(pledges) do
        local key = GetPledgeKey(pledge)
        activeKeys[key] = true
        if UAQ.selectedPledges[key] == nil then
            UAQ.selectedPledges[key] = true
        end
    end

    for key in pairs(UAQ.selectedPledges) do
        if not activeKeys[key] then
            UAQ.selectedPledges[key] = nil
        end
    end
end

local function AreAllPledgesSelected(pledges)
    if #pledges == 0 then
        return false
    end

    for _, pledge in ipairs(pledges) do
        if not UAQ.selectedPledges[GetPledgeKey(pledge)] then
            return false
        end
    end

    return true
end

local function GetSelectedPledges(pledges)
    EnsurePledgeSelections(pledges)

    local selectedPledges = {}
    for _, pledge in ipairs(pledges) do
        if UAQ.selectedPledges[GetPledgeKey(pledge)] then
            table.insert(selectedPledges, pledge)
        end
    end

    return selectedPledges
end

local function SetPledgeSelected(pledge, selected)
    if not pledge then
        return
    end

    UAQ.selectedPledges = UAQ.selectedPledges or {}
    UAQ.selectedPledges[GetPledgeKey(pledge)] = selected == true
end

local function SetAllPledgesSelected(pledges, selected)
    UAQ.selectedPledges = UAQ.selectedPledges or {}

    for _, pledge in ipairs(pledges) do
        UAQ.selectedPledges[GetPledgeKey(pledge)] = selected == true
    end
end

local function NewEmptyHistory(dungeonName)
    return {
        name = dungeonName,
        runs = 0,
        totalWaitSeconds = 0,
        averageWaitSeconds = 0,
        lastWaitSeconds = nil,
        lastRole = "Damage",
        roles = {
            Tank = 0,
            Healer = 0,
            Damage = 0,
        },
        entries = {},
    }
end

local function AddEntryToHistory(history, entry)
    if not history or not entry then
        return
    end

    local waitedSeconds = tonumber(entry.waitedSeconds) or 0
    if waitedSeconds <= 0 then
        return
    end

    local roleLabel = entry.role
    if roleLabel ~= "Tank" and roleLabel ~= "Healer" and roleLabel ~= "Damage" then
        roleLabel = "Damage"
    end

    history.runs = (history.runs or 0) + 1
    history.totalWaitSeconds = (history.totalWaitSeconds or 0) + waitedSeconds
    history.averageWaitSeconds = history.totalWaitSeconds / history.runs
    history.roles = history.roles or { Tank = 0, Healer = 0, Damage = 0 }
    history.roles[roleLabel] = (history.roles[roleLabel] or 0) + 1

    if not history.lastWaitSeconds then
        history.lastWaitSeconds = waitedSeconds
        history.lastRole = roleLabel
    end

    table.insert(history.entries, {
        waitedSeconds = waitedSeconds,
        role = roleLabel,
        difficulty = entry.difficulty,
        timestamp = entry.timestamp,
    })
end

local function MigrateHistoryForDungeon(dungeonName, history)
    if not history or history.modes then
        return history
    end

    local migrated = {
        name = history.name or dungeonName,
        modes = {
            normal = NewEmptyHistory(dungeonName),
            veteran = NewEmptyHistory(dungeonName),
        },
    }

    if history.entries then
        for _, entry in ipairs(history.entries) do
            local difficultyKey = entry.difficulty == "veteran" and "veteran" or "normal"
            AddEntryToHistory(migrated.modes[difficultyKey], entry)
        end
    elseif (history.runs or 0) > 0 then
        local difficultyKey = history.difficulty == "veteran" and "veteran" or "normal"
        migrated.modes[difficultyKey] = history
        migrated.modes[difficultyKey].entries = migrated.modes[difficultyKey].entries or {}
        migrated.modes[difficultyKey].roles = migrated.modes[difficultyKey].roles or { Tank = 0, Healer = 0, Damage = 0 }
    end

    return migrated
end

local function GetDungeonHistoryRoot(dungeonName)
    if not UAQ.savedVars then
        return nil
    end

    UAQ.savedVars.queueHistory = UAQ.savedVars.queueHistory or {}

    local key = NormalizeDungeonKey(dungeonName)
    local history = UAQ.savedVars.queueHistory[key]
    if history then
        history = MigrateHistoryForDungeon(dungeonName, history)
        UAQ.savedVars.queueHistory[key] = history
    end

    return history
end

local function GetHistoryForDungeon(dungeonName, difficultyKey)
    local history = GetDungeonHistoryRoot(dungeonName)
    if not history or not history.modes then
        return nil
    end

    difficultyKey = difficultyKey == "veteran" and "veteran" or "normal"
    return history.modes[difficultyKey]
end

local function EnsureHistoryForDungeon(dungeonName, difficultyKey)
    UAQ.savedVars.queueHistory = UAQ.savedVars.queueHistory or {}

    difficultyKey = difficultyKey == "veteran" and "veteran" or "normal"

    local key = NormalizeDungeonKey(dungeonName)
    local history = GetDungeonHistoryRoot(dungeonName)
    if not history then
        history = {
            name = dungeonName,
            modes = {
                normal = NewEmptyHistory(dungeonName),
                veteran = NewEmptyHistory(dungeonName),
            },
        }
        UAQ.savedVars.queueHistory[key] = history
    end

    history.name = dungeonName
    history.modes = history.modes or {}
    history.modes[difficultyKey] = history.modes[difficultyKey] or NewEmptyHistory(dungeonName)
    history.modes[difficultyKey].name = dungeonName
    history.modes[difficultyKey].roles = history.modes[difficultyKey].roles or { Tank = 0, Healer = 0, Damage = 0 }
    history.modes[difficultyKey].entries = history.modes[difficultyKey].entries or {}
    return history.modes[difficultyKey]
end

local function RecordDungeonWait(dungeonName, waitSeconds, roleLabel, difficultyKey)
    if not UAQ.savedVars or not dungeonName or dungeonName == "" or waitSeconds <= 0 then
        return
    end

    if roleLabel ~= "Tank" and roleLabel ~= "Healer" and roleLabel ~= "Damage" then
        roleLabel = "Damage"
    end

    local history = EnsureHistoryForDungeon(dungeonName, difficultyKey)
    history.runs = (history.runs or 0) + 1
    history.totalWaitSeconds = (history.totalWaitSeconds or 0) + waitSeconds
    history.averageWaitSeconds = history.totalWaitSeconds / history.runs
    history.lastWaitSeconds = waitSeconds
    history.lastRole = roleLabel
    history.roles[roleLabel] = (history.roles[roleLabel] or 0) + 1

    table.insert(history.entries, 1, {
        waitedSeconds = waitSeconds,
        role = roleLabel,
        difficulty = difficultyKey,
        timestamp = GetTimestamp(),
    })

    while #history.entries > MAX_HISTORY_ENTRIES do
        table.remove(history.entries)
    end
end

local function StartQueueHistory(activities, difficultyKey)
    UAQ.pendingQueueHistory = nil

    if not activities or #activities == 0 then
        return
    end

    local startedAt = NowMilliseconds()
    local roleLabel = GetSelectedRoleLabel()
    local dungeons = {}
    local seen = {}

    for _, activity in ipairs(activities) do
        local dungeonName = activity.name
        local key = NormalizeDungeonKey(dungeonName)
        if dungeonName and dungeonName ~= "" and not seen[key] then
            table.insert(dungeons, dungeonName)
            seen[key] = true
        end
    end

    if #dungeons == 0 then
        return
    end

    UAQ.pendingQueueHistory = {
        startedAt = startedAt,
        role = roleLabel,
        difficulty = difficultyKey,
        dungeons = dungeons,
        activities = activities,
    }
end

local function GetCurrentQueueActivityId()
    if type(GetCurrentLFGActivityId) ~= "function" then
        return nil
    end

    local ok, activityId = pcall(GetCurrentLFGActivityId)
    if ok and type(activityId) == "number" and activityId > 0 then
        return activityId
    end

    return nil
end

local function FindPendingDungeonForActivityId(pending, activityId)
    if not pending or not pending.activities or not activityId then
        return nil
    end

    for _, activity in ipairs(pending.activities) do
        if activity and tonumber(activity.id) == tonumber(activityId) then
            return activity.name
        end
    end

    return nil
end

local function FinishQueueHistory(foundActivityId)
    local pending = UAQ.pendingQueueHistory
    UAQ.pendingQueueHistory = nil

    if not pending or not pending.startedAt or not pending.dungeons then
        return
    end

    local waitSeconds = math.max(0, (NowMilliseconds() - pending.startedAt) / 1000)
    if waitSeconds <= 0 then
        return
    end

    local foundDungeonName = FindPendingDungeonForActivityId(pending, foundActivityId)
    if foundDungeonName then
        RecordDungeonWait(foundDungeonName, waitSeconds, pending.role, pending.difficulty)
        return
    end

    if #pending.dungeons == 1 then
        RecordDungeonWait(pending.dungeons[1], waitSeconds, pending.role, pending.difficulty)
        return
    end

    Debug("Skipped queue history because the matched dungeon could not be identified. ActivityId: " .. tostring(foundActivityId))
end

local function ClearQueueHistoryAttempt()
    UAQ.pendingQueueHistory = nil
    UAQ.skipNextQueueHistory = nil
end

local function MarkDungeonFoundForHistory(source, foundActivityId)
    if not UAQ.pendingQueueHistory then
        return
    end

    foundActivityId = foundActivityId or GetCurrentQueueActivityId()
    Debug("Dungeon found for queue history via " .. tostring(source) .. ". ActivityId: " .. tostring(foundActivityId))
    FinishQueueHistory(foundActivityId)
end

local function TryCall(funcName, ...)
    local func = _G[funcName]
    if type(func) ~= "function" then
        return false, nil
    end

    local ok, result1, result2, result3, result4, result5 = pcall(func, ...)
    if ok then
        return true, result1, result2, result3, result4, result5
    end

    Debug(funcName .. " failed: " .. tostring(result1))
    return false, nil
end

local function ActivityNameLooksRight(activityName, dungeonName, difficultyKey)
    if not activityName or activityName == "" then
        return false
    end

    if not Normalize(activityName):find(Normalize(dungeonName), 1, true) then
        return false
    end

    local difficulty = DIFFICULTY[difficultyKey]
    if difficulty and ContainsAny(activityName, difficulty.searchTerms) then
        return true
    end

    return false
end

local function CleanDungeonFinderName(name)
    local cleaned = Trim(name)
    cleaned = cleaned:gsub(GetVeteranIconPattern(), "")
    cleaned = cleaned:gsub("%s+", " ")
    return zo_strtrim(cleaned)
end

local function ScanDungeonFinderNode(node, dungeonName, expectedVeteran)
    if not node or not node.children then
        return nil
    end

    for _, child in ipairs(node.children) do
        if child and child.data then
            local data = child.data
            local name = data.nameKeyboard or data.name or data.text
            local cleanedName = CleanDungeonFinderName(name)
            local hasVeteranIcon = name and name:find(GetVeteranIconPattern()) ~= nil

            if data.id and Normalize(cleanedName) == Normalize(dungeonName) then
                return {
                    id = data.id,
                    name = cleanedName,
                    allowed = true,
                    isVeteran = expectedVeteran or hasVeteranIcon,
                    source = "DUNGEON_FINDER_KEYBOARD",
                }
            end
        end

        local nested = ScanDungeonFinderNode(child, dungeonName, expectedVeteran)
        if nested then
            return nested
        end
    end

    return nil
end

local function FindActivityFromDungeonFinderTree(dungeonName, difficultyKey)
    local difficulty = DIFFICULTY[difficultyKey] or DIFFICULTY.normal
    local dungeonFinder = DUNGEON_FINDER_KEYBOARD
    local rootNode = dungeonFinder and dungeonFinder.navigationTree and dungeonFinder.navigationTree.rootNode
    local difficultyNode = rootNode and rootNode.children and rootNode.children[difficulty.dungeonFinderIndex]

    if not difficultyNode then
        return nil
    end

    return ScanDungeonFinderNode(difficultyNode, dungeonName, difficultyKey == "veteran")
end

local function FindActivityFromKnownDungeonIds(dungeonName, difficultyKey)
    local knownDungeon = DUNGEON_FINDER_IDS[NormalizeDungeonKey(dungeonName)]
    local activityId = knownDungeon and knownDungeon[difficultyKey]

    if not activityId then
        return nil
    end

    return {
        id = activityId,
        name = dungeonName,
        allowed = true,
        isVeteran = difficultyKey == "veteran",
        source = "known dungeon id",
    }
end

local function ReadActivityInfo(activityId)
    local knownReaders = {
        "GetLFGActivityInfo",
        "GetActivityInfo",
        "GetActivityFinderActivityInfo",
    }

    for _, readerName in ipairs(knownReaders) do
        local ok, value1, value2, value3, value4, value5 = TryCall(readerName, activityId)
        if ok and (value1 or value2 or value3 or value4 or value5) then
            local parts = { value1, value2, value3, value4, value5, n = 5 }
            for index = 1, parts.n do
                local part = parts[index]
                if type(part) == "string" and part ~= "" then
                    return part, readerName
                end
            end
        end
    end

    return nil, nil
end

local function IsQueueAllowed(activityId)
    local capabilityChecks = {
        "CanQueueForLFGActivity",
        "CanQueueForActivity",
        "IsLFGActivityAvailable",
        "IsActivityAvailable",
    }

    for _, checkName in ipairs(capabilityChecks) do
        local ok, allowed, reason = TryCall(checkName, activityId)
        if ok and allowed ~= nil then
            return allowed == true, reason
        end
    end

    return true, nil
end

local function GetNativeLeaveQueueButton()
    return ZO_SearchingForGroupLeaveQueueButton
end

local function GetNativeQueueButton()
    return ZO_DungeonFinder_KeyboardActionButtonContainerQueueButton
end

local function TryInvokeControl(control, mouseButton)
    if not control then
        return false
    end

    mouseButton = mouseButton or MOUSE_BUTTON_INDEX_LEFT

    local handlerNames = { "OnClicked", "OnMouseUp" }
    for _, handlerName in ipairs(handlerNames) do
        if type(control.GetHandler) == "function" then
            local handler = control:GetHandler(handlerName)
            if type(handler) == "function" then
                local ok = pcall(handler, control, mouseButton, true)
                if ok then
                    return true
                end
            end
        end
    end

    if type(control.OnClicked) == "function" then
        local ok = pcall(function()
            control:OnClicked(mouseButton, true)
        end)
        if ok then
            return true
        end
    end

    if type(control.OnMouseUp) == "function" then
        local ok = pcall(function()
            control:OnMouseUp(mouseButton, true)
        end)
        if ok then
            return true
        end
    end

    if type(control.m_callback) == "function" then
        local ok = pcall(control.m_callback, control)
        if ok then
            return true
        end
    end

    if type(control.callback) == "function" then
        local ok = pcall(control.callback, control)
        if ok then
            return true
        end
    end

    if control.button and control.button ~= control then
        return TryInvokeControl(control.button, mouseButton)
    end

    return false
end

local function NativeButtonLooksUsable(button)
    if not button then
        return false
    end

    if type(button.IsHidden) == "function" and button:IsHidden() then
        return false
    end

    if type(button.IsEnabled) == "function" then
        return button:IsEnabled()
    end

    return true
end

local function GetNativeQueueStatusText()
    local statusControls = {
        ZO_SearchingForGroupStatus,
        ZO_SearchingForGroupStatusLabel,
        ZO_SearchingForGroupStatusText,
        ZO_SearchingForGroupStatusValue,
    }

    for _, control in ipairs(statusControls) do
        if control and type(control.GetText) == "function" then
            local text = control:GetText()
            if text and text ~= "" then
                local normalized = Normalize(text)
                if normalized:find("not queued", 1, true)
                    or normalized == "queued"
                    or normalized:find("status: queued", 1, true)
                    or normalized:find("searching", 1, true) then
                    return normalized
                end
            end
        end
    end

    local function ScanControl(control, depth)
        if not control or depth > 8 then
            return nil
        end

        if type(control.GetText) == "function" then
            local ok, text = pcall(function()
                return control:GetText()
            end)

            if ok and text and text ~= "" then
                local normalized = Normalize(text)
                if normalized:find("not queued", 1, true) then
                    return "not queued"
                end
                if normalized == "queued" or normalized:find("status: queued", 1, true) then
                    return "queued"
                end
                if normalized:find("searching", 1, true) then
                    return "searching"
                end
            end
        end

        if type(control.GetNumChildren) == "function" and type(control.GetChild) == "function" then
            local ok, childCount = pcall(function()
                return control:GetNumChildren()
            end)

            if ok and type(childCount) == "number" then
                for index = 1, childCount do
                    local child = control:GetChild(index)
                    local status = ScanControl(child, depth + 1)
                    if status then
                        return status
                    end
                end
            end
        end

        return nil
    end

    return ScanControl(ZO_SearchingForGroup, 0)
end

local function LooksQueued()
    local now = NowMilliseconds()
    local statusText = GetNativeQueueStatusText()
    if statusText then
        if statusText:find("not queued", 1, true) then
            if UAQ.isQueued and UAQ.queueStartConfirmUntil and now < UAQ.queueStartConfirmUntil then
                local confirmStartedAt = UAQ.queueStartConfirmStartedAt or (UAQ.queueStartConfirmUntil - QUEUE_START_CONFIRM_MS)
                if now - confirmStartedAt < QUEUE_START_MIN_HOLD_MS then
                    return true
                end
            end

            if UAQ.isQueued then
                ClearQueueHistoryAttempt()
            end

            UAQ.isQueued = false
            UAQ.queueStartConfirmUntil = nil
            UAQ.queueStartConfirmStartedAt = nil
            return false
        end

        if statusText:find("queued", 1, true) or statusText:find("searching", 1, true) then
            UAQ.isQueued = true
            UAQ.queueStartConfirmUntil = nil
            UAQ.queueStartConfirmStartedAt = nil
            return true
        end
    end

    if UAQ.isQueued and UAQ.queueStartConfirmUntil and now < UAQ.queueStartConfirmUntil then
        return true
    end

    return UAQ.isQueued == true
end

local RefreshPledgeList

local function UpdateQueueControls()
    local queued = LooksQueued()
    local difficultyKey = UAQ.savedVars and UAQ.savedVars.difficulty or "normal"

    if UI.queueButton then
        UI.queueButton:SetText(queued and "Stop Queue" or "Start Queue")
    end

    if UI.normalButton and UI.veteranButton then
        UI.normalButton:SetEnabled(not queued)
        UI.veteranButton:SetEnabled(not queued)

        local normalSelected = difficultyKey == "normal"
        local veteranSelected = difficultyKey == "veteran"
        UI.normalButton:SetState(normalSelected and BSTATE_PRESSED or BSTATE_NORMAL)
        UI.veteranButton:SetState(veteranSelected and BSTATE_PRESSED or BSTATE_NORMAL)
        UI.normalButton:SetNormalFontColor(normalSelected and 0.55 or 0.78, normalSelected and 0.88 or 0.78, normalSelected and 1 or 0.72, queued and 0.55 or 1)
        UI.veteranButton:SetNormalFontColor(veteranSelected and 0.55 or 0.78, veteranSelected and 0.88 or 0.78, veteranSelected and 1 or 0.72, queued and 0.55 or 1)
        UI.normalButton:SetMouseOverFontColor(normalSelected and 0.7 or 1, normalSelected and 0.95 or 1, 1, queued and 0.55 or 1)
        UI.veteranButton:SetMouseOverFontColor(veteranSelected and 0.7 or 1, veteranSelected and 0.95 or 1, 1, queued and 0.55 or 1)
        UI.normalButton:SetPressedFontColor(0.55, 0.88, 1, queued and 0.55 or 1)
        UI.veteranButton:SetPressedFontColor(0.55, 0.88, 1, queued and 0.55 or 1)
        UI.normalButton:SetAlpha(queued and 0.5 or (normalSelected and 1 or 0.72))
        UI.veteranButton:SetAlpha(queued and 0.5 or (veteranSelected and 1 or 0.72))
    end

    if RefreshPledgeList then
        RefreshPledgeList()
    end
end

local function MarkQueueStarted(activities, difficultyKey)
    UAQ.isQueued = true
    UAQ.skipNextQueueHistory = nil
    UAQ.queueStartConfirmStartedAt = NowMilliseconds()
    UAQ.queueStartConfirmUntil = UAQ.queueStartConfirmStartedAt + QUEUE_START_CONFIRM_MS
    StartQueueHistory(activities, difficultyKey)

    if UI.queueButton then
        UI.queueButton:SetText("Stop Queue")
    end

    UpdateQueueControls()
end

local function FormatCheckLabel(checked, text)
    return (checked and "[x] " or "[ ] ") .. text
end

RefreshPledgeList = function()
    if not UI.allPledgeButton or not UI.pledgeButtons then
        return
    end

    local pledges = GetActivePledges()
    UI.currentPledges = pledges
    EnsurePledgeSelections(pledges)

    local queued = LooksQueued()
    local allSelected = AreAllPledgesSelected(pledges)

    if UI.noPledgeLabel then
        UI.noPledgeLabel:SetHidden(#pledges > 0)
    end

    UI.allPledgeButton:SetHidden(#pledges == 0)
    UI.allPledgeButton:SetText(FormatCheckLabel(allSelected, "All"))
    UI.allPledgeButton:SetEnabled(#pledges > 0 and not queued)
    UI.allPledgeButton:SetAlpha((#pledges > 0 and not queued) and 1 or 0.55)

    for index = 1, MAX_PLEDGE_ROWS do
        local button = UI.pledgeButtons[index]
        local pledge = pledges[index]

        if pledge then
            button:SetHidden(false)
            local selected = UAQ.selectedPledges[GetPledgeKey(pledge)] == true
            button:SetText(FormatCheckLabel(selected, GetPledgeDisplayName(pledge, index)))
            button:SetEnabled(not queued)
            button:SetAlpha(queued and 0.55 or 1)
        else
            button:SetHidden(true)
            button:SetText("")
            button:SetEnabled(false)
            button:SetAlpha(0)
        end
    end
end

local function ShowPledgeTooltip(control, pledge)
    if not pledge then
        return
    end

    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -4)

    local dungeonName = GetPledgeDisplayName(pledge, control.pledgeIndex or 0)
    local difficultyKey = UAQ.savedVars and UAQ.savedVars.difficulty or "normal"
    local difficulty = DIFFICULTY[difficultyKey] or DIFFICULTY.normal
    local history = GetHistoryForDungeon(dungeonName, difficultyKey)

    InformationTooltip:AddLine(dungeonName)
    InformationTooltip:AddLine("Mode: " .. difficulty.label)
    ZO_Tooltip_AddDivider(InformationTooltip)

    if history and (history.runs or 0) > 0 then
        InformationTooltip:AddLine("Average wait: " .. FormatDuration(history.averageWaitSeconds))
        if history.lastWaitSeconds then
            InformationTooltip:AddLine("Last wait: " .. FormatDuration(history.lastWaitSeconds))
        end
        local lastRole = history.lastRole
        if lastRole ~= "Tank" and lastRole ~= "Healer" and lastRole ~= "Damage" then
            lastRole = "Damage"
        end
        InformationTooltip:AddLine("Last role: " .. tostring(lastRole))
        ZO_Tooltip_AddDivider(InformationTooltip)
        InformationTooltip:AddLine("Tank (" .. tostring((history.roles and history.roles.Tank) or 0) .. ")")
        InformationTooltip:AddLine("Healer (" .. tostring((history.roles and history.roles.Healer) or 0) .. ")")
        InformationTooltip:AddLine("Damage (" .. tostring((history.roles and history.roles.Damage) or 0) .. ")")
    else
        InformationTooltip:AddLine("Average wait: No history yet")
        InformationTooltip:AddLine("Last role: No history yet")
        ZO_Tooltip_AddDivider(InformationTooltip)
        InformationTooltip:AddLine("Tank (0)")
        InformationTooltip:AddLine("Healer (0)")
        InformationTooltip:AddLine("Damage (0)")
    end
end

local function ShowAlert(message)
    if not UI.alertRoot then
        local alertRoot = WINDOW_MANAGER:CreateTopLevelWindow("UndauntedAutoQueueAlert")
        alertRoot:SetDimensions(392, 122)
        alertRoot:SetAnchor(CENTER, GuiRoot, CENTER, 0, -40)
        alertRoot:SetHidden(true)
        alertRoot:SetMouseEnabled(true)
        alertRoot:SetDrawLayer(DL_OVERLAY)
        UI.alertRoot = alertRoot

        local backdrop = WINDOW_MANAGER:CreateControl("UndauntedAutoQueueAlertBackdrop", alertRoot, CT_BACKDROP)
        backdrop:SetAnchorFill(alertRoot)
        backdrop:SetCenterColor(0.03, 0.04, 0.05, 0.94)
        backdrop:SetEdgeColor(0.48, 0.56, 0.6, 1)
        backdrop:SetEdgeTexture(nil, 1, 1, 1)

        local title = WINDOW_MANAGER:CreateControl("UndauntedAutoQueueAlertTitle", alertRoot, CT_LABEL)
        title:SetDimensions(376, 24)
        title:SetAnchor(TOPLEFT, alertRoot, TOPLEFT, 8, 8)
        title:SetFont("ZoFontWinH5")
        title:SetColor(0.72, 0.9, 1, 1)
        title:SetText("Undaunted Auto Queue")

        local text = WINDOW_MANAGER:CreateControl("UndauntedAutoQueueAlertText", alertRoot, CT_LABEL)
        text:SetDimensions(376, 42)
        text:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 8)
        text:SetFont("ZoFontGame")
        text:SetColor(0.92, 0.92, 0.84, 1)
        if type(text.SetWrapMode) == "function" and TEXT_WRAP_MODE_ELLIPSIS then
            text:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        end
        UI.alertText = text

        local okButton = WINDOW_MANAGER:CreateControl("UndauntedAutoQueueAlertOK", alertRoot, CT_BUTTON)
        okButton:SetDimensions(96, 28)
        okButton:SetAnchor(BOTTOM, alertRoot, BOTTOM, 0, -10)
        okButton:SetFont("ZoFontGameSmall")
        okButton:SetText("OK")
        okButton:SetNormalFontColor(0.92, 0.92, 0.84, 1)
        okButton:SetMouseOverFontColor(1, 1, 1, 1)
        okButton:SetPressedFontColor(0.7, 0.9, 1, 1)
        okButton:SetHandler("OnClicked", function()
            alertRoot:SetHidden(true)
        end)
    end

    UI.alertText:SetText(message)
    UI.alertRoot:SetHidden(false)
end

local function FindActivityForDungeon(dungeonName, difficultyKey)
    local activity = FindActivityFromKnownDungeonIds(dungeonName, difficultyKey)
    if activity then
        Debug("Found " .. activity.name .. " via " .. activity.source .. " id " .. tostring(activity.id))
        return activity
    end

    activity = FindActivityFromDungeonFinderTree(dungeonName, difficultyKey)
    if activity then
        Debug("Found " .. activity.name .. " via " .. activity.source .. " id " .. tostring(activity.id))
        return activity
    end

    local countReaders = {
        "GetNumLFGActivities",
        "GetNumActivities",
        "GetNumActivityFinderActivities",
    }

    for _, countReaderName in ipairs(countReaders) do
        local ok, count = TryCall(countReaderName)
        if ok and type(count) == "number" and count > 0 then
            Debug("Scanning " .. count .. " activities via " .. countReaderName)

            for activityId = 1, count do
                local activityName = ReadActivityInfo(activityId)

                if ActivityNameLooksRight(activityName, dungeonName, difficultyKey) then
                    local allowed, reason = IsQueueAllowed(activityId)
                    return {
                        id = activityId,
                        name = activityName,
                        allowed = allowed,
                        reason = reason,
                    }
                end
            end
        end
    end

    -- Some builds use sparse activity IDs. This bounded probe keeps the addon
    -- useful without assuming a hardcoded dungeon list.
    for activityId = 1, 2500 do
        local activityName = ReadActivityInfo(activityId)
        if ActivityNameLooksRight(activityName, dungeonName, difficultyKey) then
            local allowed, reason = IsQueueAllowed(activityId)
            return {
                id = activityId,
                name = activityName,
                allowed = allowed,
                reason = reason,
            }
        end
    end

    return nil
end

local function TryDirectQueue(activityId)
    local queueFunctions = {
        "RequestLFGActivity",
        "QueueForLFGActivity",
        "RequestActivityFinderActivity",
        "QueueForActivity",
    }

    for _, queueFunctionName in ipairs(queueFunctions) do
        local ok, result = TryCall(queueFunctionName, activityId)
        if ok and result ~= false then
            return true, queueFunctionName
        end
    end

    return false, nil
end

local function TrySpecificDungeonQueue(activityId, difficultyKey, options)
    options = options or {}

    local clearFunctions = {
        "ClearActivityFinderSpecificSearch",
        "ClearLFGSpecificSearch",
        "ClearSpecificDungeonSearch",
    }

    local addFunctions = {
        "AddActivityFinderSpecificSearchEntry",
        "AddLFGSpecificSearchEntry",
        "SetActivityFinderSpecificSearchEntry",
        "SelectLFGSpecificDungeon",
    }

    local startFunctions = {
        "StartActivityFinderSearch",
        "StartLFGSearch",
        "JoinLFGQueue",
        "JoinActivityFinderQueue",
    }

    if not options.skipClear then
        for _, clearFunctionName in ipairs(clearFunctions) do
            TryCall(clearFunctionName)
        end
    end

    local oppositeDifficultyKey = difficultyKey == "veteran" and "normal" or "veteran"
    local removeFunctions = {
        "RemoveActivityFinderSpecificSearchEntry",
        "RemoveLFGSpecificSearchEntry",
        "SetActivityFinderSpecificSearchEntry",
        "SelectLFGSpecificDungeon",
    }

    if not options.skipClear then
        for _, pledge in ipairs(GetActivePledges()) do
            local oppositeActivity = FindActivityFromKnownDungeonIds(pledge.dungeonName, oppositeDifficultyKey)
            if oppositeActivity then
                for _, removeFunctionName in ipairs(removeFunctions) do
                    TryCall(removeFunctionName, oppositeActivity.id, false)
                end
            end
        end
    end

    local selected = false
    local selectFunctionName = nil

    for _, addFunctionName in ipairs(addFunctions) do
        local ok, result = TryCall(addFunctionName, activityId)
        if ok and result ~= false then
            selected = true
            selectFunctionName = addFunctionName
            break
        end

        ok, result = TryCall(addFunctionName, activityId, true)
        if ok and result ~= false then
            selected = true
            selectFunctionName = addFunctionName
            break
        end
    end

    if not selected then
        return false, nil
    end

    if options.selectOnly then
        return true, selectFunctionName
    end

    for _, startFunctionName in ipairs(startFunctions) do
        local ok, result = TryCall(startFunctionName)
        if ok and result ~= false then
            return true, selectFunctionName .. " + " .. startFunctionName
        end
    end

    return false, nil
end

local function ClearSpecificDungeonSelection()
    local clearFunctions = {
        "ClearGroupFinderSearch",
        "ClearActivityFinderSpecificSearch",
        "ClearLFGSpecificSearch",
        "ClearSpecificDungeonSearch",
    }

    local cleared = false
    for _, clearFunctionName in ipairs(clearFunctions) do
        local ok, result = TryCall(clearFunctionName)
        if ok and result ~= false then
            cleared = true
        end
    end

    return cleared
end

local function AddSpecificDungeonSelection(activityId)
    local addFunctions = {
        "AddActivityFinderSpecificSearchEntry",
        "AddLFGSpecificSearchEntry",
    }

    for _, addFunctionName in ipairs(addFunctions) do
        local ok, result = TryCall(addFunctionName, activityId)
        if ok and result ~= false then
            return true, addFunctionName
        end
    end

    return false, nil
end

local function StartSpecificDungeonSearch()
    local startFunctions = {
        "StartGroupFinderSearch",
        "StartActivityFinderSearch",
        "StartLFGSearch",
        "JoinLFGQueue",
        "JoinActivityFinderQueue",
    }

    for _, startFunctionName in ipairs(startFunctions) do
        local ok, result = TryCall(startFunctionName)
        if ok then
            if result == false then
                Debug(startFunctionName .. " returned false after being called; treating it as a started search.")
            end
            return true, startFunctionName
        end
    end

    return false, nil
end

local function QueueSpecificDungeonActivities(activities)
    if #activities == 0 then
        return false, 0, nil
    end

    ClearSpecificDungeonSelection()

    local selectedCount = 0
    local lastSource = nil
    local selectedIds = {}

    for _, activity in ipairs(activities) do
        if activity.id and not selectedIds[activity.id] then
            local selected, source = AddSpecificDungeonSelection(activity.id)
            if selected then
                selectedCount = selectedCount + 1
                lastSource = source
                selectedIds[activity.id] = true
            else
                Chat("Could not select " .. activity.name .. " in Specific Dungeons.")
            end
        end
    end

    if selectedCount == 0 then
        return false, 0, lastSource
    end

    local started, startSource = StartSpecificDungeonSearch()
    if started then
        return true, selectedCount, tostring(lastSource) .. " + " .. tostring(startSource)
    end

    return false, selectedCount, lastSource
end

local function SelectActivitiesForQueue(activities, difficultyKey)
    local selectedCount = 0
    local lastSource = nil

    for index, activity in ipairs(activities) do
        local selected, source = TrySpecificDungeonQueue(activity.id, difficultyKey, { skipClear = index > 1, selectOnly = true })
        if selected then
            selectedCount = selectedCount + 1
            lastSource = source
        else
            Chat("Could not select " .. activity.name .. " in Specific Dungeons.")
        end
    end

    return selectedCount, lastSource
end

local function TryNativeQueueButton()
    local queueButton = GetNativeQueueButton()
    if NativeButtonLooksUsable(queueButton) and TryInvokeControl(queueButton) then
        return true, "native queue button"
    end

    return false, nil
end

local function QueueActivity(activityId, difficultyKey)
    if USE_NATIVE_QUEUE_BUTTON then
        local selected, source = TrySpecificDungeonQueue(activityId, difficultyKey)
        if selected then
            local queued, queueSource = TryNativeQueueButton()
            if queued then
                return true, source .. " + " .. queueSource
            end
        end
    end

    local queued, source = TryDirectQueue(activityId)
    if queued then
        return true, source
    end

    return TrySpecificDungeonQueue(activityId, difficultyKey)
end

local function GetGameDungeonMode()
    local ok, difficulty = TryCall("ZO_GetEffectiveDungeonDifficulty")
    if ok and ZO_ConvertToIsVeteranDifficulty then
        return ZO_ConvertToIsVeteranDifficulty(difficulty) and "veteran" or "normal"
    end

    ok, difficulty = TryCall("GetDungeonDifficulty")
    if ok and difficulty == DUNGEON_DIFFICULTY_VETERAN then
        return "veteran"
    elseif ok and difficulty == DUNGEON_DIFFICULTY_NORMAL then
        return "normal"
    end

    ok, difficulty = TryCall("GetGroupDungeonDifficulty")
    if ok and difficulty == DUNGEON_DIFFICULTY_VETERAN then
        return "veteran"
    elseif ok and difficulty == DUNGEON_DIFFICULTY_NORMAL then
        return "normal"
    end

    ok, difficulty = TryCall("IsUnitUsingVeteranDifficulty", "player")
    if ok and difficulty ~= nil then
        return difficulty and "veteran" or "normal"
    end

    return nil
end

local function SetGameDungeonMode(difficultyKey)
    if USE_NATIVE_MODE_MIRROR and type(SetVeteranDifficulty) == "function" then
        SetVeteranDifficulty(difficultyKey == "veteran")
        local control = ZO_GroupListVeteranDifficultySettings
        if control then
            if control.veteranModeButton then
                control.veteranModeButton:SetState(difficultyKey == "veteran" and BSTATE_PRESSED or BSTATE_NORMAL)
            end
            if control.normalModeButton then
                control.normalModeButton:SetState(difficultyKey == "normal" and BSTATE_PRESSED or BSTATE_NORMAL)
            end
        end
        return true
    end

    local difficulty = difficultyKey == "veteran" and DUNGEON_DIFFICULTY_VETERAN or DUNGEON_DIFFICULTY_NORMAL

    local ok, result = TryCall("SetDungeonDifficulty", difficulty)
    if ok and result ~= false then
        return true
    end

    ok, result = TryCall("SetGroupDungeonDifficulty", difficulty)
    if ok and result ~= false then
        return true
    end

    return false
end

local function QueuePledge(pledge)
    local difficultyKey = UAQ.savedVars.difficulty or "normal"
    local difficulty = DIFFICULTY[difficultyKey] or DIFFICULTY.normal

    local activity = FindActivityForDungeon(pledge.dungeonName, difficultyKey)
    if not activity then
        Chat("Could not find \"" .. pledge.dungeonName .. "\" in the Activity Finder.")
        return false
    end

    if not activity.allowed then
        local reason = activity.reason and (" Reason: " .. tostring(activity.reason)) or ""
        Chat("Cannot queue for " .. pledge.dungeonName .. " on " .. difficulty.label .. "." .. reason)
        return false
    end

    local queued, queueFunctionName = QueueActivity(activity.id, difficultyKey)
    if queued then
        Chat("Queued: " .. activity.name .. " (" .. difficulty.label .. ").")
        Debug("Queued activity " .. tostring(activity.id) .. " via " .. tostring(queueFunctionName))
        return true
    end

    Chat("Found " .. activity.name .. ", but this client did not expose a compatible queue function to the addon.")
    return false
end

function UAQ.QueueActivePledges()
    if UAQ.isQueued or UAQ.pendingQueueHistory or LooksQueued() then
        UAQ.StopQueue()
        return
    end

    local pledges = GetActivePledges()
    RefreshPledgeList()

    if #pledges == 0 then
        ShowAlert("No active Undaunted Pledges were found.")
        Chat("No active Undaunted Pledges were found.")
        return
    end

    pledges = GetSelectedPledges(pledges)

    if #pledges == 0 then
        ShowAlert("Select at least one pledge before starting the queue.")
        Chat("Select at least one pledge before starting the queue.")
        return
    end

    local difficultyKey = UAQ.savedVars.difficulty or "normal"
    local difficulty = DIFFICULTY[difficultyKey] or DIFFICULTY.normal
    local activities = {}
    local blockedCount = 0

    for _, pledge in ipairs(pledges) do
        local activity = FindActivityForDungeon(pledge.dungeonName, difficultyKey)
        if activity and activity.allowed then
            table.insert(activities, activity)
        elseif activity then
            local reason = activity.reason and (" Reason: " .. tostring(activity.reason)) or ""
            Chat("Cannot queue for " .. pledge.dungeonName .. " on " .. difficulty.label .. "." .. reason)
            blockedCount = blockedCount + 1
        else
            Chat("Could not find \"" .. pledge.dungeonName .. "\" in the Activity Finder.")
            blockedCount = blockedCount + 1
        end
    end

    if #activities == 0 and blockedCount > 0 then
        Chat("No pledge could be queued automatically. Open Dungeon Finder > Specific Dungeons to queue manually.")
        UpdateQueueControls()
        return
    end

    if USE_NATIVE_QUEUE_BUTTON then
        local selectedCount = SelectActivitiesForQueue(activities, difficultyKey)
        if selectedCount > 0 then
            local queued, queueSource = TryNativeQueueButton()
            if queued then
                MarkQueueStarted(activities, difficultyKey)
                Chat("Queue started for " .. tostring(selectedCount) .. " " .. difficulty.label .. " pledge dungeon(s).")
                Debug("Queued via " .. tostring(queueSource))
            else
                Chat("Selected " .. tostring(selectedCount) .. " pledge dungeon(s), but the native Start Queue button was not ready.")
            end
        end
    else
        local queued, selectedCount, queueSource = QueueSpecificDungeonActivities(activities)
        if queued then
            MarkQueueStarted(activities, difficultyKey)
            Chat("Queue started for " .. tostring(selectedCount) .. " " .. difficulty.label .. " pledge dungeon(s).")
            Debug("Queued via " .. tostring(queueSource))
        elseif selectedCount > 0 then
            Chat("Selected " .. tostring(selectedCount) .. " pledge dungeon(s), but this client did not expose a compatible start queue function.")
        end
    end

    UpdateQueueControls()
end

function UAQ.StopQueue()
    local wasQueued = UAQ.isQueued or UAQ.pendingQueueHistory or LooksQueued()

    local leaveButton = GetNativeLeaveQueueButton()

    if NativeButtonLooksUsable(leaveButton) and TryInvokeControl(leaveButton) then
        ClearQueueHistoryAttempt()
        UAQ.isQueued = false
        UAQ.queueStartConfirmUntil = nil
        UAQ.queueStartConfirmStartedAt = nil
        Chat("Queue stopped.")
        UpdateQueueControls()
        return
    end

    local cancelFunctions = {
        "LeaveLFGQueue",
        "CancelLFGSearch",
        "CancelActivityFinderSearch",
        "LeaveActivityFinderQueue",
    }

    for _, cancelFunctionName in ipairs(cancelFunctions) do
        local ok, result = TryCall(cancelFunctionName)
        if ok and result ~= false then
            ClearQueueHistoryAttempt()
            UAQ.isQueued = false
            UAQ.queueStartConfirmUntil = nil
            UAQ.queueStartConfirmStartedAt = nil
            Chat("Queue stopped.")
            UpdateQueueControls()
            return
        end
    end

    if wasQueued then
        Chat("Could not stop the queue automatically. Use the native Leave Queue button.")
    else
        UAQ.isQueued = false
        ClearQueueHistoryAttempt()
        Chat("Not queued.")
    end
    UpdateQueueControls()
end

local function SetDifficulty(difficultyKey, options)
    options = options or {}

    if not DIFFICULTY[difficultyKey] then
        difficultyKey = "normal"
    end

    if LooksQueued() and not options.force then
        Chat("Leave the queue before changing dungeon mode.")
        UpdateQueueControls()
        return
    end

    UAQ.savedVars.difficulty = difficultyKey

    if not options.skipGameUpdate then
        UAQ.suppressModeSyncUntil = NowMilliseconds() + MODE_SYNC_SUPPRESS_MS
        SetGameDungeonMode(difficultyKey)
    end

    if UI.normalButton and UI.veteranButton then
        UI.normalButton:SetState(difficultyKey == "normal" and BSTATE_PRESSED or BSTATE_NORMAL)
        UI.veteranButton:SetState(difficultyKey == "veteran" and BSTATE_PRESSED or BSTATE_NORMAL)
    end

    UpdateQueueControls()
end

local function SyncDifficultyFromGame()
    if UAQ.suppressModeSyncUntil and NowMilliseconds() < UAQ.suppressModeSyncUntil then
        return
    end

    local gameMode = GetGameDungeonMode()
    if gameMode and gameMode ~= UAQ.savedVars.difficulty then
        SetDifficulty(gameMode, { skipGameUpdate = true, force = true })
    end
end

local function SaveWindowPosition()
    if not UI.root or not UAQ.savedVars then
        return
    end

    UAQ.savedVars.window = UAQ.savedVars.window or {}
    UAQ.savedVars.window.x = UI.root:GetLeft()
    UAQ.savedVars.window.y = UI.root:GetTop()
end

local function RestoreWindowPosition(root)
    local position = UAQ.savedVars and UAQ.savedVars.window
    root:ClearAnchors()

    if position and position.x and position.y then
        root:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, position.x, position.y)
    else
        root:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -82, 88)
    end
end

local function CreateButton(parent, name, text, width, height)
    local button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
    button:SetDimensions(width, height)
    button:SetFont("ZoFontGameSmall")
    button:SetText(text)
    button:SetNormalFontColor(0.92, 0.92, 0.84, 1)
    button:SetMouseOverFontColor(1, 1, 1, 1)
    button:SetPressedFontColor(0.7, 0.9, 1, 1)
    return button
end

local function CreatePledgeButton(parent, name, index)
    local button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
    button:SetDimensions(414, 20)
    button:SetFont("ZoFontGameSmall")
    if type(button.SetHorizontalAlignment) == "function" then
        button:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    end
    button:SetNormalFontColor(0.92, 0.92, 0.84, 1)
    button:SetMouseOverFontColor(1, 1, 1, 1)
    button:SetPressedFontColor(0.7, 0.9, 1, 1)
    button.pledgeIndex = index
    return button
end

local function CreateUI()
    if UI.root then
        return
    end

    local root = WINDOW_MANAGER:CreateTopLevelWindow("UndauntedAutoQueueRoot")
    root:SetDimensions(430, 166)
    RestoreWindowPosition(root)
    root:SetHidden(true)
    root:SetMouseEnabled(true)
    root:SetMovable(true)
    root:SetClampedToScreen(true)
    UI.root = root

    local backdrop = WINDOW_MANAGER:CreateControl("UndauntedAutoQueueBackdrop", root, CT_BACKDROP)
    backdrop:SetAnchorFill(root)
    backdrop:SetCenterColor(0.03, 0.04, 0.05, 0.82)
    backdrop:SetEdgeColor(0.25, 0.31, 0.34, 0.9)
    backdrop:SetEdgeTexture(nil, 1, 1, 1)
    UI.backdrop = backdrop

    local title = WINDOW_MANAGER:CreateControl("UndauntedAutoQueueTitle", root, CT_LABEL)
    title:SetDimensions(414, 24)
    title:SetAnchor(TOPLEFT, root, TOPLEFT, 8, 4)
    title:SetFont("ZoFontWinH5")
    title:SetColor(0.72, 0.9, 1, 1)
    title:SetText("Undaunted Auto Queue")
    title:SetMouseEnabled(true)
    title:SetHandler("OnMouseDown", function()
        root:StartMoving()
    end)
    title:SetHandler("OnMouseUp", function()
        root:StopMovingOrResizing()
        SaveWindowPosition()
    end)
    title:SetHandler("OnMouseEnter", function(control)
        InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -4)
        SetTooltipText(InformationTooltip, "Drag to reposition")
    end)
    title:SetHandler("OnMouseExit", function()
        ClearTooltip(InformationTooltip)
    end)
    UI.title = title

    local noPledgeLabel = WINDOW_MANAGER:CreateControl("UndauntedAutoQueueNoPledgeLabel", root, CT_LABEL)
    noPledgeLabel:SetDimensions(414, 24)
    noPledgeLabel:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 12)
    noPledgeLabel:SetFont("ZoFontGameSmall")
    noPledgeLabel:SetColor(0.92, 0.92, 0.84, 0.8)
    noPledgeLabel:SetText("No pledge available")
    noPledgeLabel:SetHidden(true)
    UI.noPledgeLabel = noPledgeLabel

    local allPledgeButton = CreatePledgeButton(root, "UndauntedAutoQueuePledgeAll", 0)
    allPledgeButton:SetAnchor(TOPLEFT, title, BOTTOMLEFT, 0, 4)
    allPledgeButton:SetHandler("OnClicked", function()
        local pledges = UI.currentPledges or GetActivePledges()
        EnsurePledgeSelections(pledges)
        SetAllPledgesSelected(pledges, not AreAllPledgesSelected(pledges))
        RefreshPledgeList()
    end)
    UI.allPledgeButton = allPledgeButton

    UI.pledgeButtons = {}
    for index = 1, MAX_PLEDGE_ROWS do
        local pledgeButton = CreatePledgeButton(root, "UndauntedAutoQueuePledge" .. tostring(index), index)
        if index == 1 then
            pledgeButton:SetAnchor(TOPLEFT, allPledgeButton, BOTTOMLEFT, 0, 0)
        else
            pledgeButton:SetAnchor(TOPLEFT, UI.pledgeButtons[index - 1], BOTTOMLEFT, 0, 0)
        end
        pledgeButton:SetHandler("OnClicked", function(control)
            local pledges = UI.currentPledges or GetActivePledges()
            local pledge = pledges[control.pledgeIndex]
            if pledge then
                EnsurePledgeSelections(pledges)
                SetPledgeSelected(pledge, not UAQ.selectedPledges[GetPledgeKey(pledge)])
                RefreshPledgeList()
            end
        end)
        pledgeButton:SetHandler("OnMouseEnter", function(control)
            local pledges = UI.currentPledges or GetActivePledges()
            ShowPledgeTooltip(control, pledges[control.pledgeIndex])
        end)
        pledgeButton:SetHandler("OnMouseExit", function()
            ClearTooltip(InformationTooltip)
        end)
        UI.pledgeButtons[index] = pledgeButton
    end

    local modeLabel = WINDOW_MANAGER:CreateControl("UndauntedAutoQueueModeLabel", root, CT_LABEL)
    modeLabel:SetDimensions(104, 28)
    modeLabel:SetAnchor(BOTTOMLEFT, root, BOTTOMLEFT, 8, -10)
    modeLabel:SetFont("ZoFontGameSmall")
    modeLabel:SetColor(0.86, 0.84, 0.66, 1)
    modeLabel:SetText("Dungeon Mode:")
    UI.modeLabel = modeLabel

    local normalButton = CreateButton(root, "UndauntedAutoQueueNormal", "Normal", 68, 28)
    normalButton:SetAnchor(LEFT, modeLabel, RIGHT, 4, 0)
    normalButton:SetHandler("OnClicked", function()
        SetDifficulty("normal")
    end)
    UI.normalButton = normalButton

    local veteranButton = CreateButton(root, "UndauntedAutoQueueVeteran", "Veteran", 68, 28)
    veteranButton:SetAnchor(LEFT, normalButton, RIGHT, 6, 0)
    veteranButton:SetHandler("OnClicked", function()
        SetDifficulty("veteran")
    end)
    UI.veteranButton = veteranButton

    local queueButton = CreateButton(root, "UndauntedAutoQueueStart", "Start Queue", 116, 28)
    queueButton:SetAnchor(LEFT, veteranButton, RIGHT, 8, 0)
    queueButton:SetHandler("OnClicked", function()
        UAQ.QueueActivePledges()
    end)
    UI.queueButton = queueButton

    SyncDifficultyFromGame()
    RefreshPledgeList()
    SetDifficulty(UAQ.savedVars.difficulty, { skipGameUpdate = true })
end

local ACTIVITY_SCENES = {
    groupMenuKeyboard = true,
    activityFinder = true,
    activityFinderKeyboard = true,
    dungeonFinder = true,
    dungeonFinderKeyboard = true,
}

local function RefreshVisibility()
    if not UI.root or not SCENE_MANAGER then
        return
    end

    local currentScene = SCENE_MANAGER:GetCurrentScene()
    local sceneName = currentScene and currentScene:GetName()
    SyncDifficultyFromGame()
    UI.root:SetHidden(not ACTIVITY_SCENES[sceneName])
end

local function RegisterDifficultyUpdates()
    if EVENT_DUNGEON_DIFFICULTY_CHANGED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_DUNGEON_DIFFICULTY_CHANGED, function()
            SyncDifficultyFromGame()
        end)
    end

    if type(SecurePostHook) == "function" then
        if type(SetVeteranDifficulty) == "function" then
            SecurePostHook("SetVeteranDifficulty", function()
                zo_callLater(SyncDifficultyFromGame, 100)
            end)
        end

        if type(SetDungeonDifficulty) == "function" then
            SecurePostHook("SetDungeonDifficulty", function()
                zo_callLater(SyncDifficultyFromGame, 100)
            end)
        end

        if type(SetGroupDungeonDifficulty) == "function" then
            SecurePostHook("SetGroupDungeonDifficulty", function()
                zo_callLater(SyncDifficultyFromGame, 100)
            end)
        end
    end
end

local function RegisterQueueStateUpdates()
    EVENT_MANAGER:RegisterForUpdate(ADDON_NAME .. "QueueState", QUEUE_STATE_POLL_MS, function()
        if UAQ.isQueued and not LooksQueued() then
            UAQ.isQueued = false
            UAQ.queueStartConfirmUntil = nil
            UAQ.queueStartConfirmStartedAt = nil
        end
        SyncDifficultyFromGame()
        UpdateQueueControls()
    end)
end

local function RefreshPledgesSoon()
    if type(zo_callLater) == "function" then
        zo_callLater(function()
            if RefreshPledgeList then
                RefreshPledgeList()
            end
            UpdateQueueControls()
        end, 250)
    else
        if RefreshPledgeList then
            RefreshPledgeList()
        end
        UpdateQueueControls()
    end
end

local function RegisterQueueHistoryTriggers()
    if EVENT_GROUPING_TOOLS_READY_CHECK_UPDATED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "QueueHistoryFound", EVENT_GROUPING_TOOLS_READY_CHECK_UPDATED, function()
            if type(HasLFGReadyCheckNotification) ~= "function" or HasLFGReadyCheckNotification() then
                MarkDungeonFoundForHistory("EVENT_GROUPING_TOOLS_READY_CHECK_UPDATED", GetCurrentQueueActivityId())
            end
        end)
    end

    if EVENT_GROUPING_TOOLS_READY_CHECK_CANCELLED then
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. "QueueHistoryCancelled", EVENT_GROUPING_TOOLS_READY_CHECK_CANCELLED, function()
            ClearQueueHistoryAttempt()
        end)
    end
end

local function RegisterPledgeUpdates()
    local events = {
        EVENT_QUEST_ADDED,
        EVENT_QUEST_ADVANCED,
        EVENT_QUEST_COMPLETE,
        EVENT_QUEST_CONDITION_COUNTER_CHANGED,
        EVENT_QUEST_REMOVED,
    }

    for _, eventId in ipairs(events) do
        if eventId then
            EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. tostring(eventId), eventId, RefreshPledgesSoon)
        end
    end
end

local function RegisterSceneUpdates()
    if not SCENE_MANAGER then
        return
    end

    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function(_, _, newState)
        if newState == SCENE_SHOWN or newState == SCENE_HIDING then
            RefreshVisibility()
        end
    end)
end

local function SlashCommand(args)
    args = Normalize(args)

    if args == "clearhistory" then
        UAQ.savedVars.queueHistory = {}
        UAQ.pendingQueueHistory = nil
        Chat("Queue history and stats cleared.")
        if RefreshPledgeList then
            RefreshPledgeList()
        end
    elseif args == "debug" then
        UAQ.savedVars.showDebug = not UAQ.savedVars.showDebug
        Chat("Debug " .. (UAQ.savedVars.showDebug and "enabled." or "disabled."))
    else
        Chat("Commands: /uaq clearhistory, /uaq debug")
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    UAQ.savedVars = ZO_SavedVars:NewAccountWide("UndauntedAutoQueueSavedVariables", 1, nil, DEFAULTS)
    SLASH_COMMANDS["/uaq"] = SlashCommand

    CreateUI()
    RegisterDifficultyUpdates()
    RegisterQueueStateUpdates()
    RegisterQueueHistoryTriggers()
    RegisterPledgeUpdates()
    RegisterSceneUpdates()
    RefreshVisibility()

    Chat("Loaded. Open Guild & Activity Finder to use the queue controls.")
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
