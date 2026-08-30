NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local Monitor = {}

local C = {
    EVENT_NAMESPACE = "NQOL_GroupFinderMonitor",
    TIMER_SUFFIX = "_Timer",
    SEARCH_TIMEOUT_SUFFIX = "_SearchTimeout",
    SINGLE_CATEGORY_REFRESH_INTERVAL_SECONDS = 30,
    REFRESH_INTERVAL_SECONDS = 60,
    SEARCH_TIMEOUT_MS = 30000,
    ROLE_ICON_SIZE = 20,
    WIDTH_MIN = 300,
    WIDTH_MAX = 680,
    SCALE_MIN = 60,
    SCALE_MAX = 160,
    MAX_ROWS_MIN = 2,
    MAX_ROWS_MAX = 15,
    BORDER_SIZE_MIN = 0,
    BORDER_SIZE_MAX = 6,
    OPACITY_MIN = 0,
    OPACITY_MAX = 100,
}

local CATEGORY_DEFINITIONS = {
    { key = "dungeon", category = GROUP_FINDER_CATEGORY_DUNGEON, usesDifficulty = true },
    { key = "arena", category = GROUP_FINDER_CATEGORY_ARENA, usesDifficulty = true },
    { key = "trial", category = GROUP_FINDER_CATEGORY_TRIAL, usesDifficulty = true },
    { key = "infiniteArchive", category = GROUP_FINDER_CATEGORY_ENDLESS_DUNGEON },
    { key = "pvp", category = GROUP_FINDER_CATEGORY_PVP },
    { key = "zone", category = GROUP_FINDER_CATEGORY_ZONE },
    { key = "custom", category = GROUP_FINDER_CATEGORY_CUSTOM },
}

local ACTIVITY_MODE_CHOICES = { "off", "normal", "veteran", "all" }
local VALID_ACTIVITY_MODES = { off = true, normal = true, veteran = true, all = true }
local ROLE_CHOICES = { "any", "damage", "tank", "healer" }
local VALID_ROLE_CHOICES = { any = true, damage = true, tank = true, healer = true }
local ALARM_SOUND_OFF = "off"
local ALARM_SOUND_CHOICES = { ALARM_SOUND_OFF }
local VALID_ALARM_SOUND_CHOICES = { [ALARM_SOUND_OFF] = true }
for _, value in ipairs(NQOL.Util.GetAlertSoundChoices()) do
    ALARM_SOUND_CHOICES[#ALARM_SOUND_CHOICES + 1] = value
    VALID_ALARM_SOUND_CHOICES[value] = true
end
local ROLE_BY_CHOICE = {
    damage = LFG_ROLE_DPS,
    tank = LFG_ROLE_TANK,
    healer = LFG_ROLE_HEAL,
}
local defaults = {
    groupFinderMonitor = {
        enabled = false,
        closeOnJoin = true,
        showInSettings = true,
        role = "any",
        alarmEnabled = false,
        alarmSound = NQOL.Util.GetAlertSoundDefault(),
        alarmText = "",
        horizontalPosition = 77,
        verticalPosition = 14,
        width = 420,
        maxRows = 8,
        font = NQOL.Util.GetDefaultFont(),
        scale = 100,
        backgroundOpacity = 90,
        borderSize = 1,
        categories = {
            dungeon = "off",
            arena = "off",
            trial = "off",
            infiniteArchive = false,
            pvp = false,
            zone = false,
            custom = false,
        },
    },
}

local savedVariables
local initialized = false
local settingsPanelVisible = false
local searchCallbackRegistered = false
local sceneCallbackInstalled = false
local groupJoinEventRegistered = false
local groupFinderStatusEventsRegistered = false
local keybindHooksInstalled = false
local startImmediatelyAfterGroupFinderCloses = false
local pausedForDisabledZone = false
local scanActive = false
local stopRequested = false
local scanPhase = "idle"
local scanTasks = {}
local baseScanTasks = {}
local scanTaskIndex = 0
local scanRows = {}
local scanPreviousRowsByKey = {}
local scanSourceOrder = {}
local scanAlarmedKeys = {}
local scanAlarmWords = {}
local scanConfig = {}
local scanHadCompletedScan = false
local scanPublishedCount = 0
local rows = {}
local savedFilterState
local hasCompletedScan = false
local scanFailed = false
local scanTimerScheduled = false
local nextScanAtMilliseconds

local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round

local function GetNowMilliseconds()
    if GetFrameTimeMilliseconds then return GetFrameTimeMilliseconds() end
    if GetGameTimeMilliseconds then return GetGameTimeMilliseconds() end
    return os and os.time and (os.time() * 1000) or 0
end

local function ClearTable(value)
    for key in pairs(value) do value[key] = nil end
end

local function ClearArray(value)
    for index = #value, 1, -1 do value[index] = nil end
end

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "groupFinderMonitor")
    NQOL.Settings.Boolean(settings, defaults.groupFinderMonitor, "enabled")
    NQOL.Settings.Boolean(settings, defaults.groupFinderMonitor, "closeOnJoin")
    NQOL.Settings.Boolean(settings, defaults.groupFinderMonitor, "showInSettings")
    NQOL.Settings.Boolean(settings, defaults.groupFinderMonitor, "alarmEnabled")
    NQOL.Settings.Choice(settings, defaults.groupFinderMonitor, "alarmSound", VALID_ALARM_SOUND_CHOICES)
    if not VALID_ROLE_CHOICES[settings.role] then settings.role = defaults.groupFinderMonitor.role end
    if type(settings.alarmText) ~= "string" then settings.alarmText = defaults.groupFinderMonitor.alarmText end
    NQOL.Settings.ClampedNumber(settings, defaults.groupFinderMonitor, "horizontalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, defaults.groupFinderMonitor, "verticalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, defaults.groupFinderMonitor, "width", C.WIDTH_MIN, C.WIDTH_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.groupFinderMonitor, "maxRows", C.MAX_ROWS_MIN, C.MAX_ROWS_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.groupFinderMonitor, "scale", C.SCALE_MIN, C.SCALE_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.groupFinderMonitor, "backgroundOpacity", C.OPACITY_MIN, C.OPACITY_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaults.groupFinderMonitor, "borderSize", C.BORDER_SIZE_MIN, C.BORDER_SIZE_MAX, true)
    settings.refreshInterval = nil
    settings.fontSize = nil
    if not NQOL.Util.IsFontChoice(settings.font) then settings.font = defaults.groupFinderMonitor.font end
    settings.headerColor = nil
    settings.textColor = nil
    if type(settings.categories) ~= "table" then settings.categories = {} end
    for _, definition in ipairs(CATEGORY_DEFINITIONS) do
        if definition.usesDifficulty then
            local value = settings.categories[definition.key]
            if value == true then value = "all" end
            if value == false or not VALID_ACTIVITY_MODES[value] then value = "off" end
            settings.categories[definition.key] = value
        else
            NQOL.Settings.Boolean(settings.categories, defaults.groupFinderMonitor.categories, definition.key)
        end
    end
    return settings
end

local function NotifyHudResults()
    local hud = NQOL.Features.GroupFinderMonitorHud
    if hud and hud.RefreshResults then
        hud.RefreshResults()
    elseif hud and hud.Refresh then
        hud.Refresh()
    end
end

local function NotifyHudStatus()
    local hud = NQOL.Features.GroupFinderMonitorHud
    if hud and hud.RefreshStatus then
        hud.RefreshStatus()
    else
        NotifyHudResults()
    end
end

local function IsGroupFinderShowing()
    if GROUP_FINDER_GAMEPAD_FRAGMENT and GROUP_FINDER_GAMEPAD_FRAGMENT.IsShowing and GROUP_FINDER_GAMEPAD_FRAGMENT:IsShowing() then return true end
    if GROUP_FINDER_GAMEPAD_LIST_SCENE and GROUP_FINDER_GAMEPAD_LIST_SCENE.IsShowing and GROUP_FINDER_GAMEPAD_LIST_SCENE:IsShowing() then return true end
    if GROUP_FINDER_KEYBOARD_FRAGMENT and GROUP_FINDER_KEYBOARD_FRAGMENT.IsShowing and GROUP_FINDER_KEYBOARD_FRAGMENT:IsShowing() then return true end
    local scene = SCENE_MANAGER and SCENE_MANAGER.GetCurrentScene and SCENE_MANAGER:GetCurrentScene()
    local name = scene and scene.GetName and scene:GetName()
    return name == "GroupFinderGamepad" or name == "group_finder_gamepad_list"
end

local function IsGroupFinderDisabledInZone()
    return GetGroupFinderStatusReason
        and GROUP_FINDER_ACTION_RESULT_FAILED_DISABLED_IN_ZONE
        and GetGroupFinderStatusReason() == GROUP_FINDER_ACTION_RESULT_FAILED_DISABLED_IN_ZONE
end

local function CaptureFilterState()
    local state = {
        category = GetGroupFinderFilterCategory(),
        searchString = GetGroupFinderGroupFilterSearchString(),
        primary = {},
        secondary = {},
        groupSizes = GetGroupFinderFilterGroupSizes(),
        playstyles = GetGroupFinderFilterPlaystyles(),
        champion = DoesGroupFinderFilterRequireChampion(),
        voip = DoesGroupFinderFilterRequireVOIP(),
        inviteCode = DoesGroupFinderFilterRequireInviteCode(),
        autoAccept = DoesGroupFinderFilterAutoAcceptRequests(),
        enforceRoles = DoesGroupFinderFilterRequireEnforceRoles(),
        championPoints = GetGroupFinderFilterChampionPoints(),
    }
    for index = 1, GetGroupFinderFilterNumPrimaryOptions() do
        local _, selected = GetGroupFinderFilterPrimaryOptionByIndex(index)
        state.primary[index] = selected == true
    end
    for index = 1, GetGroupFinderFilterNumSecondaryOptions() do
        local _, selected = GetGroupFinderFilterSecondaryOptionByIndex(index)
        state.secondary[index] = selected == true
    end
    return state
end

local function ApplyFilterState(state)
    if not state then return end
    SetGroupFinderFilterCategory(state.category, false)
    UpdateGroupFinderFilterOptions()
    SetGroupFinderGroupFilterSearchString(state.searchString or "")
    for index = 1, GetGroupFinderFilterNumPrimaryOptions() do
        SetGroupFinderFilterPrimaryOptionByIndex(index, state.primary[index] == true)
    end
    for index = 1, GetGroupFinderFilterNumSecondaryOptions() do
        SetGroupFinderFilterSecondaryOptionByIndex(index, state.secondary[index] == true)
    end
    SetGroupFinderFilterGroupSizeFlags(state.groupSizes or 0)
    SetGroupFinderFilterPlaystyleFlags(state.playstyles or 0)
    SetGroupFinderFilterRequiresChampion(state.champion == true)
    SetGroupFinderFilterRequiresVOIP(state.voip == true)
    SetGroupFinderFilterRequiresInviteCode(state.inviteCode == true)
    SetGroupFinderFilterAutoAcceptRequests(state.autoAccept == true)
    SetGroupFinderFilterEnforceRoles(state.enforceRoles == true)
    SetGroupFinderFilterChampionPoints(state.championPoints or 0)
end

local function ConfigureBroadSearch(category)
    SetGroupFinderFilterCategory(category, false)
    UpdateGroupFinderFilterOptions()
    ResetGroupFinderFilterOptionsToDefault()
    SetGroupFinderGroupFilterSearchString("")
end

local function BuildTasks(tasks, categorySettings)
    ClearArray(tasks)
    for _, definition in ipairs(CATEGORY_DEFINITIONS) do
        local selection = categorySettings[definition.key]
        if selection ~= false and selection ~= "off"
            and (not IsGroupFinderCategoryAvailable or IsGroupFinderCategoryAvailable(definition.category)) then
            if definition.usesDifficulty then
                if selection == "normal" or selection == "all" then
                    tasks[#tasks + 1] = { category = definition.category, primaryOption = DUNGEON_DIFFICULTY_NORMAL }
                end
                if selection == "veteran" or selection == "all" then
                    tasks[#tasks + 1] = { category = definition.category, primaryOption = DUNGEON_DIFFICULTY_VETERAN }
                end
            elseif definition.category == GROUP_FINDER_CATEGORY_PVP then
                tasks[#tasks + 1] = { category = definition.category, expandPrimary = true }
            else
                tasks[#tasks + 1] = { category = definition.category }
            end
        end
    end
    return tasks
end

local function GetRefreshIntervalMilliseconds(categorySettings)
    local selectedCategoryCount = 0
    for _, definition in ipairs(CATEGORY_DEFINITIONS) do
        local selection = categorySettings[definition.key]
        if selection == true or (definition.usesDifficulty and selection ~= "off") then
            selectedCategoryCount = selectedCategoryCount + 1
            if selectedCategoryCount > 1 then return C.REFRESH_INTERVAL_SECONDS * 1000 end
        end
    end
    if selectedCategoryCount == 0 then return nil end
    return C.SINGLE_CATEGORY_REFRESH_INTERVAL_SECONDS * 1000
end

local function ExpandSearchTasks(tasks, expanded)
    ClearArray(expanded)
    for _, task in ipairs(tasks) do
        if task.expandPrimary then
            ConfigureBroadSearch(task.category)
            local optionCount = GetGroupFinderFilterNumPrimaryOptions()
            if optionCount == 0 then
                expanded[#expanded + 1] = { category = task.category }
            else
                for optionIndex = 1, optionCount do
                    expanded[#expanded + 1] = { category = task.category, primaryOption = optionIndex }
                end
            end
        else
            expanded[#expanded + 1] = task
        end
    end
    return expanded
end

local function PrepareSearchTasks(tasks)
    ClearTable(scanSourceOrder)
    for index, task in ipairs(tasks) do
        task.sourceKey = string.format("%s:%s", task.category, task.primaryOption or 0)
        task.sourceOrder = index
        scanSourceOrder[task.sourceKey] = index
    end

    local rowsChanged = false
    for index = #rows, 1, -1 do
        local row = rows[index]
        local sourceOrder = scanSourceOrder[row.sourceKey]
        if sourceOrder then
            row.sourceOrder = sourceOrder
        else
            table.remove(rows, index)
            rowsChanged = true
        end
    end
    return rowsChanged
end

local function CleanText(value)
    local text = NQOL.Util.StripChatMarkup(value)
    text = string.gsub(text, "|t.-|t", "")
    text = string.gsub(text, "|u.-|u", "")
    if EscapeMarkup then text = EscapeMarkup(text) end
    return text
end

local function PopulateAlarmWords(words, alarmText)
    ClearArray(words)
    for value in string.gmatch(alarmText or "", "[^,]+") do
        local word = value
        word = string.gsub(word, "^%s+", "")
        word = string.gsub(word, "%s+$", "")
        word = NQOL.Util.Lower(word)
        if word ~= "" then words[#words + 1] = word end
    end
    return words
end

local function MatchesAlarm(activity, title, description, alarmWords)
    if #alarmWords == 0 then return false end
    local searchableText = NQOL.Util.Lower(string.format("%s\n%s\n%s", activity, title, description))
    for _, word in ipairs(alarmWords) do
        if string.find(searchableText, word, 1, true) then return true end
    end
    return false
end

local function PlayAlarmSound(soundKey)
    local selectedSound = soundKey or GetSettings().alarmSound
    if selectedSound ~= ALARM_SOUND_OFF then
        NQOL.Util.PlayAlertSound(selectedSound)
    end
end

local function FormatRoleCount(role, count)
    local texture = ZO_GetGamepadRoleIcon and ZO_GetGamepadRoleIcon(role)
    local icon = texture and zo_iconFormat and zo_iconFormat(texture, C.ROLE_ICON_SIZE, C.ROLE_ICON_SIZE) or ""
    return string.format("%s%d", icon, count)
end

local function GetListingRoleData(listingIndex, capacity, hasRoleData, enforcesRoles, roleChoice)
    if not hasRoleData then return true, "" end

    local tankDesired, tankCount = GetGroupFinderSearchListingRoleStatusCount(listingIndex, LFG_ROLE_TANK)
    local healerDesired, healerCount = GetGroupFinderSearchListingRoleStatusCount(listingIndex, LFG_ROLE_HEAL)
    local damageDesired, damageCount = GetGroupFinderSearchListingRoleStatusCount(listingIndex, LFG_ROLE_DPS)
    tankDesired, tankCount = tonumber(tankDesired) or 0, tonumber(tankCount) or 0
    healerDesired, healerCount = tonumber(healerDesired) or 0, tonumber(healerCount) or 0
    damageDesired, damageCount = tonumber(damageDesired) or 0, tonumber(damageCount) or 0

    local roleCountsText = FormatRoleCount(LFG_ROLE_TANK, tankCount)
        .. " " .. FormatRoleCount(LFG_ROLE_HEAL, healerCount)
        .. " " .. FormatRoleCount(LFG_ROLE_DPS, damageCount)
    local selectedRole = ROLE_BY_CHOICE[roleChoice]
    if not selectedRole then return true, roleCountsText end

    local totalAttained = tankCount + healerCount + damageCount
    if totalAttained >= capacity then return false, roleCountsText end
    if not enforcesRoles then return true, roleCountsText end
    local totalDesired = tankDesired + healerDesired + damageDesired
    local selectedDesired, selectedCount = damageDesired, damageCount
    if selectedRole == LFG_ROLE_TANK then
        selectedDesired, selectedCount = tankDesired, tankCount
    elseif selectedRole == LFG_ROLE_HEAL then
        selectedDesired, selectedCount = healerDesired, healerCount
    end
    return totalDesired < capacity or selectedDesired > selectedCount, roleCountsText
end

local function CaptureCurrentResults(task)
    local resultData = GROUP_FINDER_SEARCH_MANAGER:GetSearchResults() or {}
    for _, data in ipairs(resultData) do
        local listingIndex = data.listingIndex
        local primary, secondary = GetGroupFinderSearchListingOptionsSelectionTextByIndex(listingIndex)
        local category = GetGroupFinderSearchListingCategoryByIndex(listingIndex)
        local title = CleanText(GetGroupFinderSearchListingTitleByIndex(listingIndex))
        local description = CleanText(GetGroupFinderSearchListingDescriptionByIndex(listingIndex))
        local leader = CleanText(GetGroupFinderSearchListingLeaderDisplayNameByIndex(listingIndex))
        if ZO_FormatUserFacingDisplayName then leader = ZO_FormatUserFacingDisplayName(leader) end
        if leader ~= "" and string.sub(leader, 1, 1) ~= "@" then leader = "@" .. leader end
        primary = CleanText(primary)
        secondary = CleanText(secondary)
        local categoryText = GetString("SI_GROUPFINDERCATEGORY", category)
        local activity = secondary ~= "" and secondary or (title ~= "" and title or categoryText)
        local preferActivityTitle = category == GROUP_FINDER_CATEGORY_DUNGEON
            or category == GROUP_FINDER_CATEGORY_TRIAL
            or category == GROUP_FINDER_CATEGORY_ARENA
        local capacity = tonumber(GetGroupFinderSearchListingNumRolesByIndex(listingIndex)) or 0
        local supportsRoles = capacity > 0
        local enforcesRoles = supportsRoles and DoesGroupFinderSearchListingEnforceRoles(listingIndex) == true
        local hasSelectedRoleSpace, roleCountsText = GetListingRoleData(listingIndex, capacity, supportsRoles, enforcesRoles, scanConfig.role)
        if hasSelectedRoleSpace then
            local key = string.format("%s\31%s\31%s\31%s\31%s\31%s", category, primary, secondary, leader, title, description)
            scanRows[#scanRows + 1] = {
                key = key,
                sourceKey = task.sourceKey,
                sourceOrder = task.sourceOrder,
                categoryText = categoryText,
                primary = primary,
                activity = activity,
                preferActivityTitle = preferActivityTitle,
                title = title,
                leader = leader,
                description = description,
                supportsRoles = supportsRoles,
                roleCountsText = roleCountsText,
                isAlarm = scanConfig.alarmEnabled and MatchesAlarm(activity, title, description, scanAlarmWords),
                isVeteran = primary ~= "" and primary == scanConfig.veteranText,
            }
        end
    end
end

local function PublishScanRows(task)
    local playAlarm = false
    local firstNewIndex = scanPublishedCount + 1
    for index = firstNewIndex, #scanRows do
        local row = scanRows[index]
        local previousRow = scanPreviousRowsByKey[row.key]
        row.isNew = scanHadCompletedScan and previousRow == nil
        if row.isAlarm and (not previousRow or not previousRow.isAlarm) and not scanAlarmedKeys[row.key] then
            scanAlarmedKeys[row.key] = true
            playAlarm = true
        end
    end

    local insertionIndex
    for index = #rows, 1, -1 do
        if rows[index].sourceKey == task.sourceKey then
            insertionIndex = index
            table.remove(rows, index)
        end
    end
    if not insertionIndex then
        insertionIndex = #rows + 1
        for index, row in ipairs(rows) do
            if (row.sourceOrder or math.huge) > task.sourceOrder then
                insertionIndex = index
                break
            end
        end
    end
    for index = firstNewIndex, #scanRows do
        table.insert(rows, insertionIndex, scanRows[index])
        insertionIndex = insertionIndex + 1
    end
    scanPublishedCount = #scanRows
    if playAlarm then PlayAlarmSound(scanConfig.alarmSound) end
    NotifyHudResults()
end

local ScheduleNextScan
local StopTimer
local HandleSearchTimeout

local function StopSearchTimeout()
    if EVENT_MANAGER then EVENT_MANAGER:UnregisterForUpdate(C.EVENT_NAMESPACE .. C.SEARCH_TIMEOUT_SUFFIX) end
end

local function StartSearchTimeout()
    if not EVENT_MANAGER then return end
    StopSearchTimeout()
    EVENT_MANAGER:RegisterForUpdate(C.EVENT_NAMESPACE .. C.SEARCH_TIMEOUT_SUFFIX, C.SEARCH_TIMEOUT_MS, function()
        StopSearchTimeout()
        if HandleSearchTimeout then HandleSearchTimeout() end
    end)
end

local function CommitRows()
    ClearArray(scanRows)
    hasCompletedScan = true
end

local function ResetScanState()
    ClearArray(scanRows)
    scanActive = false
    stopRequested = false
    scanPhase = "idle"
    ClearArray(scanTasks)
    ClearArray(baseScanTasks)
    scanTaskIndex = 0
    ClearTable(scanPreviousRowsByKey)
    ClearTable(scanSourceOrder)
    ClearTable(scanAlarmedKeys)
    ClearArray(scanAlarmWords)
    ClearTable(scanConfig)
    scanHadCompletedScan = false
    scanPublishedCount = 0
    savedFilterState = nil
    scanFailed = false
end

local function FinishScan(commit)
    StopSearchTimeout()
    if commit then
        CommitRows()
    end
    ResetScanState()
    if commit then NotifyHudStatus() else NotifyHudResults() end
    if GetSettings().enabled == true and ScheduleNextScan then
        ScheduleNextScan(GetRefreshIntervalMilliseconds(GetSettings().categories))
    end
end

local function ExecuteConfiguredSearch()
    StopSearchTimeout()
    local manager = GROUP_FINDER_SEARCH_MANAGER
    if not manager or not manager.ExecuteSearch then return false end
    manager:ExecuteSearch()
    local state = manager:GetSearchState()
    local pending = state == ZO_GROUP_FINDER_SEARCH_STATES.WAITING or state == ZO_GROUP_FINDER_SEARCH_STATES.QUEUED
    if pending then StartSearchTimeout() end
    return pending
end

local BeginRestore
local RunNextTask

BeginRestore = function()
    if not scanActive then return end
    scanPhase = "restore"
    NotifyHudStatus()
    ApplyFilterState(savedFilterState)
    if not ExecuteConfiguredSearch() then FinishScan(false) end
end

RunNextTask = function()
    if not scanActive then return end
    if stopRequested then BeginRestore() return end
    scanTaskIndex = scanTaskIndex + 1
    local task = scanTasks[scanTaskIndex]
    if not task then BeginRestore() return end
    scanPhase = "monitor"
    NotifyHudStatus()
    ConfigureBroadSearch(task.category)
    if task.primaryOption then SetGroupFinderFilterPrimaryOptionByIndex(task.primaryOption, true) end
    if not ExecuteConfiguredSearch() then scanFailed = true; BeginRestore() end
end

HandleSearchTimeout = function()
    if not scanActive then return end
    local timedOutPhase = scanPhase
    scanPhase = "timeout"
    local manager = GROUP_FINDER_SEARCH_MANAGER
    if manager and manager.SetSearchState and ZO_GROUP_FINDER_SEARCH_STATES.NONE then
        manager:SetSearchState(ZO_GROUP_FINDER_SEARCH_STATES.NONE)
    end
    if timedOutPhase == "monitor" then
        if zo_callLater then
            zo_callLater(function()
                if scanActive and scanPhase == "timeout" then RunNextTask() end
            end, 0)
        else
            RunNextTask()
        end
    elseif timedOutPhase == "restore" then
        FinishScan(not stopRequested and not scanFailed)
    end
end

local function OnSearchResultsReady()
    if not scanActive then return end
    if scanPhase == "timeout" then return end
    StopSearchTimeout()
    if scanPhase == "restore" then
        FinishScan(not stopRequested and not scanFailed)
        return
    end
    local task = scanTasks[scanTaskIndex]
    if task then
        CaptureCurrentResults(task)
        PublishScanRows(task)
    end
    if zo_callLater then zo_callLater(RunNextTask, 0) else RunNextTask() end
end

local function TryStartScan()
    local settings = GetSettings()
    if settings.enabled ~= true or pausedForDisabledZone or scanActive or IsGroupFinderShowing() then return false end
    if HasGroupListingForUserType
        and HasGroupListingForUserType(GROUP_FINDER_GROUP_LISTING_USER_TYPE_CREATED_GROUP_LISTING) then return false end
    local manager = GROUP_FINDER_SEARCH_MANAGER
    if not manager or not manager.IsSearchStateReady or not manager:IsSearchStateReady() then return false end
    BuildTasks(baseScanTasks, settings.categories)
    if #baseScanTasks == 0 then
        if #rows > 0 then
            ClearArray(rows)
            NotifyHudResults()
        else
            NotifyHudStatus()
        end
        return false
    end
    UpdateGroupFinderFilterOptions()
    savedFilterState = CaptureFilterState()
    ExpandSearchTasks(baseScanTasks, scanTasks)
    local rowsChanged = PrepareSearchTasks(scanTasks)
    scanTaskIndex = 0
    ClearTable(scanPreviousRowsByKey)
    for _, row in ipairs(rows) do scanPreviousRowsByKey[row.key] = row end
    ClearTable(scanAlarmedKeys)
    scanConfig.role = settings.role
    scanConfig.alarmEnabled = settings.alarmEnabled == true
    scanConfig.alarmSound = settings.alarmSound
    scanConfig.veteranText = GetString("SI_DUNGEONDIFFICULTY", DUNGEON_DIFFICULTY_VETERAN)
    PopulateAlarmWords(scanAlarmWords, scanConfig.alarmEnabled and settings.alarmText or "")
    scanHadCompletedScan = hasCompletedScan
    ClearArray(scanRows)
    scanPublishedCount = 0
    scanFailed = false
    stopRequested = false
    scanActive = true
    StopTimer()
    if rowsChanged then NotifyHudResults() else NotifyHudStatus() end
    RunNextTask()
    return true
end

StopTimer = function()
    if EVENT_MANAGER then EVENT_MANAGER:UnregisterForUpdate(C.EVENT_NAMESPACE .. C.TIMER_SUFFIX) end
    scanTimerScheduled = false
    nextScanAtMilliseconds = nil
end

ScheduleNextScan = function(delayMs)
    StopTimer()
    local settings = GetSettings()
    if not delayMs or settings.enabled ~= true or pausedForDisabledZone or scanActive or not EVENT_MANAGER then return end
    scanTimerScheduled = true
    nextScanAtMilliseconds = GetNowMilliseconds() + delayMs
    EVENT_MANAGER:RegisterForUpdate(C.EVENT_NAMESPACE .. C.TIMER_SUFFIX, delayMs, function()
        StopTimer()
        if not TryStartScan() and GetSettings().enabled == true and not scanActive then
            ScheduleNextScan(GetRefreshIntervalMilliseconds(GetSettings().categories))
        end
    end)
end

local function StartTimer(immediate)
    if scanActive or scanTimerScheduled then return end
    local refreshDelayMs = GetRefreshIntervalMilliseconds(GetSettings().categories)
    if not refreshDelayMs then StopTimer() return end
    ScheduleNextScan(immediate and 250 or refreshDelayMs)
end

local function StopMonitoring()
    StopTimer()
    StopSearchTimeout()
    if scanActive then
        local filterState = savedFilterState
        ResetScanState()
        ApplyFilterState(filterState)
        local manager = GROUP_FINDER_SEARCH_MANAGER
        if manager and manager.SetSearchState and ZO_GROUP_FINDER_SEARCH_STATES.NONE then
            manager:SetSearchState(ZO_GROUP_FINDER_SEARCH_STATES.NONE)
        end
    end
    NotifyHudStatus()
end

local function RefreshCategorySelection()
    local refreshDelayMs = GetRefreshIntervalMilliseconds(GetSettings().categories)
    if not refreshDelayMs then
        StopMonitoring()
        ClearArray(rows)
        hasCompletedScan = false
        NotifyHudResults()
        return
    end
    if not scanActive and not TryStartScan() then ScheduleNextScan(refreshDelayMs) end
    NotifyHudStatus()
end

local function PauseForDisabledZone()
    StopTimer()
    StopSearchTimeout()
    if scanActive then
        local filterState = savedFilterState
        ResetScanState()
        ApplyFilterState(filterState)
        local manager = GROUP_FINDER_SEARCH_MANAGER
        if manager and manager.SetSearchState and ZO_GROUP_FINDER_SEARCH_STATES.NONE then
            manager:SetSearchState(ZO_GROUP_FINDER_SEARCH_STATES.NONE)
        end
    end
    ClearArray(rows)
    hasCompletedScan = false
    NotifyHudResults()
end

local function AbortScanForGroupFinder()
    StopSearchTimeout()
    local filterState = savedFilterState
    ResetScanState()
    if filterState then
        ApplyFilterState(filterState)
        local manager = GROUP_FINDER_SEARCH_MANAGER
        if manager and manager.SetSearchState and ZO_GROUP_FINDER_SEARCH_STATES.NONE then
            manager:SetSearchState(ZO_GROUP_FINDER_SEARCH_STATES.NONE)
        end
        if manager and manager.ExecuteSearch then manager:ExecuteSearch() end
    end
end

local function RegisterSearchCallback()
    if searchCallbackRegistered or not GROUP_FINDER_SEARCH_MANAGER then return end
    searchCallbackRegistered = true
    GROUP_FINDER_SEARCH_MANAGER:RegisterCallback("OnGroupFinderSearchResultsReady", OnSearchResultsReady)
end

local function UnregisterSearchCallback()
    if not searchCallbackRegistered or not GROUP_FINDER_SEARCH_MANAGER then return end
    searchCallbackRegistered = false
    GROUP_FINDER_SEARCH_MANAGER:UnregisterCallback("OnGroupFinderSearchResultsReady", OnSearchResultsReady)
end

local function OnSceneStateChanged()
    if IsGroupFinderShowing() then
        StopTimer()
        if scanActive then AbortScanForGroupFinder() end
    elseif GetSettings().enabled == true and not scanActive then
        if startImmediatelyAfterGroupFinderCloses then
            startImmediatelyAfterGroupFinderCloses = false
            StopTimer()
            StartTimer(true)
        else
            StartTimer(false)
        end
    end
    NotifyHudResults()
end

local function RegisterSceneCallback()
    if sceneCallbackInstalled or not SCENE_MANAGER or not SCENE_MANAGER.RegisterCallback then return end
    sceneCallbackInstalled = true
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", OnSceneStateChanged)
end

local function UnregisterSceneCallback()
    if not sceneCallbackInstalled or not SCENE_MANAGER or not SCENE_MANAGER.UnregisterCallback then return end
    sceneCallbackInstalled = false
    SCENE_MANAGER:UnregisterCallback("SceneStateChanged", OnSceneStateChanged)
end

local function OnGroupMemberJoined(_, _, _, isLocalPlayer)
    if isLocalPlayer == true and GetSettings().enabled == true and GetSettings().closeOnJoin == true then
        settingsPanelVisible = false
        Monitor.SetEnabled(false)
    end
end

local function RegisterGroupJoinEvent()
    if groupJoinEventRegistered or not EVENT_MANAGER or not EVENT_GROUP_MEMBER_JOINED then return end
    groupJoinEventRegistered = true
    EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE, EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
end

local function UnregisterGroupJoinEvent()
    if not groupJoinEventRegistered or not EVENT_MANAGER or not EVENT_GROUP_MEMBER_JOINED then return end
    groupJoinEventRegistered = false
    EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE, EVENT_GROUP_MEMBER_JOINED)
end

local function OnGroupFinderAvailabilityChanged()
    local disabledInZone = IsGroupFinderDisabledInZone() == true
    local wasPaused = pausedForDisabledZone
    pausedForDisabledZone = disabledInZone
    if disabledInZone then
        PauseForDisabledZone()
    elseif wasPaused and GetSettings().enabled == true then
        StopTimer()
        StartTimer(true)
        NotifyHudResults()
    end
end

local function RegisterGroupFinderStatusEvents()
    if groupFinderStatusEventsRegistered or not EVENT_MANAGER then return end
    groupFinderStatusEventsRegistered = true
    if EVENT_GROUP_FINDER_STATUS_UPDATED then
        EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE, EVENT_GROUP_FINDER_STATUS_UPDATED, OnGroupFinderAvailabilityChanged)
    end
    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED, OnGroupFinderAvailabilityChanged)
    end
    OnGroupFinderAvailabilityChanged()
end

local function UnregisterGroupFinderStatusEvents()
    if not groupFinderStatusEventsRegistered or not EVENT_MANAGER then return end
    groupFinderStatusEventsRegistered = false
    if EVENT_GROUP_FINDER_STATUS_UPDATED then
        EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE, EVENT_GROUP_FINDER_STATUS_UPDATED)
    end
    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE, EVENT_PLAYER_ACTIVATED)
    end
end

local function RefreshRuntime(immediate)
    local settings = GetSettings()
    local hud = NQOL.Features.GroupFinderMonitorHud
    local hudActive = settings.enabled == true or (settingsPanelVisible and settings.showInSettings == true)
    if hud and hud.SetActive then
        hud.SetActive(hudActive)
    elseif hud and hud.Initialize and hudActive then
        hud.Initialize()
    end
    if settings.enabled == true then
        RegisterSearchCallback()
        RegisterSceneCallback()
        RegisterGroupFinderStatusEvents()
        if settings.closeOnJoin == true then RegisterGroupJoinEvent() else UnregisterGroupJoinEvent() end
        StartTimer(immediate)
    else
        startImmediatelyAfterGroupFinderCloses = false
        StopMonitoring()
        UnregisterSearchCallback()
        UnregisterSceneCallback()
        UnregisterGroupJoinEvent()
        UnregisterGroupFinderStatusEvents()
    end
    NotifyHudResults()
end

local function GetMonitorKeybindDescriptor()
    local descriptor = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        keybind = "UI_SHORTCUT_RIGHT_STICK",
        sound = SOUNDS.GAMEPAD_MENU_FORWARD,
        nqolGroupFinderMonitor = true,
    }
    descriptor.name = function()
        local key = Monitor.GetEnabled()
            and "features.group_finder_monitor.stop_monitor_keybind"
            or "features.group_finder_monitor.monitor_keybind"
        return NQOL.L(key)
    end
    descriptor.callback = function()
        if Monitor.GetEnabled() then
            Monitor.SetEnabled(false)
        else
            Monitor.EnableFromGroupFinder()
        end
        if KEYBIND_STRIP and KEYBIND_STRIP.UpdateKeybindButton then
            KEYBIND_STRIP:UpdateKeybindButton(descriptor)
        end
    end
    return descriptor
end

local function RebuildActiveKeybindGroup(descriptor, callback)
    local wasActive = KEYBIND_STRIP and KEYBIND_STRIP.HasKeybindButtonGroup
        and KEYBIND_STRIP:HasKeybindButtonGroup(descriptor)
    if wasActive then KEYBIND_STRIP:RemoveKeybindButtonGroup(descriptor) end
    callback()
    if wasActive then KEYBIND_STRIP:AddKeybindButtonGroup(descriptor) end
end

local function AddOuterGroupFinderKeybind(groupFinder)
    local descriptor = groupFinder and groupFinder.keybindStripDescriptor
    if not descriptor then return end
    for _, keybind in ipairs(descriptor) do
        if keybind.nqolGroupFinderMonitor then return end
    end
    RebuildActiveKeybindGroup(descriptor, function()
        local keybind = GetMonitorKeybindDescriptor()
        keybind.visible = function()
            return groupFinder.mode == ZO_GROUP_FINDER_MODES.SEARCH
        end
        descriptor[#descriptor + 1] = keybind
    end)
end

local function AddSearchResultsKeybind(resultsList)
    if not resultsList or resultsList.nqolGroupFinderMonitorKeybindInstalled then return end
    local focusAreas = { resultsList.panelFocalArea, resultsList.filtersFocalArea, resultsList.appliedToListingArea }
    local activeDescriptors = {}
    for _, focusArea in ipairs(focusAreas) do
        local descriptor = focusArea and focusArea.keybindDescriptor
        if descriptor and KEYBIND_STRIP and KEYBIND_STRIP.HasKeybindButtonGroup
            and KEYBIND_STRIP:HasKeybindButtonGroup(descriptor) then
            activeDescriptors[#activeDescriptors + 1] = descriptor
            KEYBIND_STRIP:RemoveKeybindButtonGroup(descriptor)
        end
    end
    for _, focusArea in ipairs(focusAreas) do
        local descriptor = focusArea and focusArea.keybindDescriptor
        if descriptor then
            for _, keybind in ipairs(descriptor) do
                if keybind.keybind == "UI_SHORTCUT_RIGHT_STICK" then
                    keybind.keybind = "UI_SHORTCUT_LEFT_STICK"
                end
            end
        end
    end
    resultsList:AddUniversalKeybind(GetMonitorKeybindDescriptor())
    resultsList.nqolGroupFinderMonitorKeybindInstalled = true
    for _, descriptor in ipairs(activeDescriptors) do
        KEYBIND_STRIP:AddKeybindButtonGroup(descriptor)
    end
end

local function InstallGroupFinderKeybinds()
    AddOuterGroupFinderKeybind(GROUP_FINDER_GAMEPAD)
    local resultsScreen = GROUP_FINDER_SEARCH_RESULTS_LIST_SCREEN_GAMEPAD
    AddSearchResultsKeybind(resultsScreen and resultsScreen.resultsList)
    if keybindHooksInstalled or not SecurePostHook then return end
    keybindHooksInstalled = true
    if ZO_GroupFinder_Gamepad then
        SecurePostHook(ZO_GroupFinder_Gamepad, "InitializeControls", AddOuterGroupFinderKeybind)
    end
    if ZO_GroupFinder_SearchResultsList_Gamepad then
        SecurePostHook(ZO_GroupFinder_SearchResultsList_Gamepad, "InitializeKeybinds", AddSearchResultsKeybind)
    end
end

function Monitor.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function Monitor.Initialize()
    if initialized then return end
    initialized = true
    InstallGroupFinderKeybinds()
    RefreshRuntime(true)
end

function Monitor.GetRows() return rows end
function Monitor.IsScanning() return scanActive end
function Monitor.IsPausedForDisabledZone() return pausedForDisabledZone end
function Monitor.IsRestoringFilter() return scanActive and scanPhase == "restore" end
function Monitor.GetCurrentScanCategoryLabel()
    if not scanActive or scanPhase ~= "monitor" then return nil end
    local task = scanTasks[scanTaskIndex]
    if not task then return nil end
    return GetString("SI_GROUPFINDERCATEGORY", task.category)
end
function Monitor.HasCompletedScan() return hasCompletedScan end
function Monitor.GetSecondsUntilNextRefresh()
    if not scanTimerScheduled or not nextScanAtMilliseconds then return nil end
    return math.max(math.ceil((nextScanAtMilliseconds - GetNowMilliseconds()) / 1000), 0)
end
function Monitor.HasSelectedCategories()
    local categorySettings = GetSettings().categories
    for _, definition in ipairs(CATEGORY_DEFINITIONS) do
        local selection = categorySettings[definition.key]
        if selection == true or (definition.usesDifficulty and selection ~= "off") then return true end
    end
    return false
end
function Monitor.IsSettingsPanelVisible() return settingsPanelVisible end

function Monitor.GetEnabled() return GetSettings().enabled end
function Monitor.GetEnabledDefault() return defaults.groupFinderMonitor.enabled end
function Monitor.SetEnabled(value) GetSettings().enabled = value == true; RefreshRuntime(value == true) end
function Monitor.EnableFromGroupFinder()
    startImmediatelyAfterGroupFinderCloses = true
    Monitor.SetEnabled(true)
    if SCENE_MANAGER and SCENE_MANAGER.ShowBaseScene then SCENE_MANAGER:ShowBaseScene() end
end
function Monitor.GetCloseOnJoin() return GetSettings().closeOnJoin end
function Monitor.GetCloseOnJoinDefault() return defaults.groupFinderMonitor.closeOnJoin end
function Monitor.SetCloseOnJoin(value) GetSettings().closeOnJoin = value == true; RefreshRuntime(false) end
function Monitor.GetShowInSettings() return GetSettings().showInSettings end
function Monitor.GetShowInSettingsDefault() return defaults.groupFinderMonitor.showInSettings end
function Monitor.SetShowInSettings(value) GetSettings().showInSettings = value == true; RefreshRuntime(false) end
function Monitor.SetSettingsPanelVisible(value) settingsPanelVisible = value == true; RefreshRuntime(false) end
function Monitor.GetRole() return GetSettings().role end
function Monitor.GetRoleDefault() return defaults.groupFinderMonitor.role end
function Monitor.SetRole(value) if VALID_ROLE_CHOICES[value] then GetSettings().role = value; if not scanActive then TryStartScan() end; NotifyHudStatus() end end
function Monitor.GetRoleChoices() return ROLE_CHOICES end
function Monitor.GetRoleChoiceNames()
    return {
        GetString(SI_GROUP_FINDER_ROLE_ANY),
        NQOL.L("features.group_finder_monitor.role_damage"),
        GetString("SI_LFGROLE", LFG_ROLE_TANK),
        GetString("SI_LFGROLE", LFG_ROLE_HEAL),
    }
end
function Monitor.GetAlarmEnabled() return GetSettings().alarmEnabled end
function Monitor.GetAlarmEnabledDefault() return defaults.groupFinderMonitor.alarmEnabled end
function Monitor.SetAlarmEnabled(value) GetSettings().alarmEnabled = value == true; if not scanActive then TryStartScan() end; NotifyHudStatus() end
function Monitor.GetAlarmSound() return GetSettings().alarmSound end
function Monitor.GetAlarmSoundDefault() return defaults.groupFinderMonitor.alarmSound end
function Monitor.SetAlarmSound(value)
    if VALID_ALARM_SOUND_CHOICES[value] and GetSettings().alarmSound ~= value then
        GetSettings().alarmSound = value
        PlayAlarmSound()
    end
end
function Monitor.GetAlarmSoundChoices()
    return ALARM_SOUND_CHOICES
end
function Monitor.GetAlarmSoundChoiceNames()
    local names = { NQOL.L("features.group_finder_monitor.mode_off") }
    local alertSoundNames = NQOL.Util.GetAlertSoundChoiceNames()
    for index, name in ipairs(alertSoundNames) do names[index + 1] = name end
    return names
end
function Monitor.GetAlarmText() return GetSettings().alarmText end
function Monitor.SetAlarmText(value) GetSettings().alarmText = tostring(value or ""); if not scanActive then TryStartScan() end; NotifyHudStatus() end
function Monitor.GetCategoryEnabled(key) return GetSettings().categories[key] == true end
function Monitor.SetCategoryEnabled(key, value) if defaults.groupFinderMonitor.categories[key] ~= nil then GetSettings().categories[key] = value == true; RefreshCategorySelection() end end
function Monitor.GetCategoryDefault(key) return defaults.groupFinderMonitor.categories[key] == true end
function Monitor.GetCategoryMode(key) return GetSettings().categories[key] end
function Monitor.SetCategoryMode(key, value)
    if VALID_ACTIVITY_MODES[value] and type(defaults.groupFinderMonitor.categories[key]) == "string" then
        GetSettings().categories[key] = value
        RefreshCategorySelection()
    end
end
function Monitor.GetCategoryModeDefault(key) return defaults.groupFinderMonitor.categories[key] end
function Monitor.GetCategoryModeChoices() return ACTIVITY_MODE_CHOICES end
function Monitor.GetCategoryModeChoiceNames()
    return {
        NQOL.L("features.group_finder_monitor.mode_off"),
        NQOL.L("common.normal"),
        NQOL.L("common.veteran"),
        NQOL.L("features.group_finder_monitor.mode_all"),
    }
end
function Monitor.GetCategoryLabel(key)
    for _, definition in ipairs(CATEGORY_DEFINITIONS) do
        if definition.key == key then return GetString("SI_GROUPFINDERCATEGORY", definition.category) end
    end
    return key
end
function Monitor.GetCategoryKeys()
    local keys = {}
    for index, definition in ipairs(CATEGORY_DEFINITIONS) do keys[index] = definition.key end
    return keys
end

function Monitor.GetHorizontalPosition() return GetSettings().horizontalPosition end
function Monitor.SetHorizontalPosition(value) GetSettings().horizontalPosition = Clamp(tonumber(value) or 0, 0, 100); NotifyHudResults() end
function Monitor.GetVerticalPosition() return GetSettings().verticalPosition end
function Monitor.SetVerticalPosition(value) GetSettings().verticalPosition = Clamp(tonumber(value) or 0, 0, 100); NotifyHudResults() end
function Monitor.GetWidth() return GetSettings().width end
function Monitor.SetWidth(value) GetSettings().width = Clamp(Round(value), C.WIDTH_MIN, C.WIDTH_MAX); NotifyHudResults() end
function Monitor.GetWidthMin() return C.WIDTH_MIN end
function Monitor.GetWidthMax() return C.WIDTH_MAX end
function Monitor.GetMaxRows() return GetSettings().maxRows end
function Monitor.SetMaxRows(value) GetSettings().maxRows = Clamp(Round(value), C.MAX_ROWS_MIN, C.MAX_ROWS_MAX); NotifyHudResults() end
function Monitor.GetMaxRowsMin() return C.MAX_ROWS_MIN end
function Monitor.GetMaxRowsMax() return C.MAX_ROWS_MAX end
function Monitor.GetFont() return GetSettings().font end
function Monitor.SetFont(value) if NQOL.Util.IsFontChoice(value) then GetSettings().font = value; NotifyHudResults() end end
function Monitor.GetFontChoices() return NQOL.Util.GetFontChoices() end
function Monitor.GetFontChoiceNames() return NQOL.Util.GetFontChoiceNames() end
function Monitor.GetScale() return GetSettings().scale end
function Monitor.SetScale(value) GetSettings().scale = Clamp(Round(value), C.SCALE_MIN, C.SCALE_MAX); NotifyHudResults() end
function Monitor.GetScaleMin() return C.SCALE_MIN end
function Monitor.GetScaleMax() return C.SCALE_MAX end
function Monitor.GetBackgroundOpacity() return GetSettings().backgroundOpacity end
function Monitor.SetBackgroundOpacity(value) GetSettings().backgroundOpacity = Clamp(Round(value), C.OPACITY_MIN, C.OPACITY_MAX); NotifyHudResults() end
function Monitor.GetBackgroundOpacityMin() return C.OPACITY_MIN end
function Monitor.GetBackgroundOpacityMax() return C.OPACITY_MAX end
function Monitor.GetBorderSize() return GetSettings().borderSize end
function Monitor.SetBorderSize(value) GetSettings().borderSize = Clamp(Round(value), C.BORDER_SIZE_MIN, C.BORDER_SIZE_MAX); NotifyHudResults() end
function Monitor.GetBorderSizeMin() return C.BORDER_SIZE_MIN end
function Monitor.GetBorderSizeMax() return C.BORDER_SIZE_MAX end
function Monitor.GetEntryLabel() return NQOL.L("features.group_finder_monitor.entry_label") end
function Monitor.GetEntryTooltip() return NQOL.L("features.group_finder_monitor.entry_tooltip") end
function Monitor.GetEnabledLabel() return NQOL.L("features.group_finder_monitor.enabled_label") end
function Monitor.GetEnabledTooltip() return NQOL.L("features.group_finder_monitor.enabled_tooltip") end
function Monitor.GetCloseOnJoinLabel() return NQOL.L("features.group_finder_monitor.close_on_join_label") end
function Monitor.GetCloseOnJoinTooltip() return NQOL.L("features.group_finder_monitor.close_on_join_tooltip") end
function Monitor.GetShowInSettingsLabel() return NQOL.L("features.group_finder_monitor.show_in_settings_label") end
function Monitor.GetShowInSettingsTooltip() return NQOL.L("features.group_finder_monitor.show_in_settings_tooltip") end
function Monitor.GetRoleLabel() return NQOL.L("features.group_finder_monitor.role_label") end
function Monitor.GetRoleTooltip() return NQOL.L("features.group_finder_monitor.role_tooltip") end
function Monitor.GetAlarmEnabledLabel() return NQOL.L("features.group_finder_monitor.alarm_label") end
function Monitor.GetAlarmEnabledTooltip() return NQOL.L("features.group_finder_monitor.alarm_tooltip") end
function Monitor.GetAlarmSoundLabel() return NQOL.L("features.group_finder_monitor.alarm_sound_label") end
function Monitor.GetAlarmSoundTooltip() return NQOL.L("features.group_finder_monitor.alarm_sound_tooltip") end
function Monitor.GetAlarmTextLabel()
    local alarmText = Monitor.GetAlarmText()
    if alarmText == "" then alarmText = NQOL.L("common.not_set") end
    return NQOL.L("features.group_finder_monitor.alarm_text_label", alarmText)
end
function Monitor.GetAlarmTextTooltip() return NQOL.L("features.group_finder_monitor.alarm_text_tooltip") end
function Monitor.GetCategoryTooltip(key) return NQOL.L("features.group_finder_monitor.category_tooltip", Monitor.GetCategoryLabel(key)) end
function Monitor.GetHorizontalPositionLabel() return NQOL.L("features.group_finder_monitor.horizontal_position_label") end
function Monitor.GetHorizontalPositionTooltip() return NQOL.L("features.group_finder_monitor.horizontal_position_tooltip") end
function Monitor.GetVerticalPositionLabel() return NQOL.L("features.group_finder_monitor.vertical_position_label") end
function Monitor.GetVerticalPositionTooltip() return NQOL.L("features.group_finder_monitor.vertical_position_tooltip") end
function Monitor.GetWidthLabel() return NQOL.L("features.group_finder_monitor.width_label") end
function Monitor.GetWidthTooltip() return NQOL.L("features.group_finder_monitor.width_tooltip") end
function Monitor.GetMaxRowsLabel() return NQOL.L("features.group_finder_monitor.max_rows_label") end
function Monitor.GetMaxRowsTooltip() return NQOL.L("features.group_finder_monitor.max_rows_tooltip") end
function Monitor.GetFontLabel() return NQOL.L("features.group_finder_monitor.font_label") end
function Monitor.GetFontTooltip() return NQOL.L("features.group_finder_monitor.font_tooltip") end
function Monitor.GetScaleLabel() return NQOL.L("features.group_finder_monitor.scale_label") end
function Monitor.GetScaleTooltip() return NQOL.L("features.group_finder_monitor.scale_tooltip") end
function Monitor.GetBackgroundOpacityLabel() return NQOL.L("features.group_finder_monitor.background_opacity_label") end
function Monitor.GetBackgroundOpacityTooltip() return NQOL.L("features.group_finder_monitor.background_opacity_tooltip") end
function Monitor.GetBorderSizeLabel() return NQOL.L("features.group_finder_monitor.border_size_label") end
function Monitor.GetBorderSizeTooltip() return NQOL.L("features.group_finder_monitor.border_size_tooltip") end
NQOL.Features.GroupFinderMonitor = Monitor
