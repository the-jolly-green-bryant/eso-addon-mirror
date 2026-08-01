NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local CombatInfiniteArchive = {}

local C = {
    EVENT_NAMESPACE = "NQOL_CombatInfiniteArchive",
    PERSONAL_BEST_CSA_LIFESPAN_MS = 5000,
    RECORD_VALUE_COLOR = "FFD64D",
    GROUP_SOLO = "solo",
    GROUP_DUO = "duo",
}

local defaults = {
    combat = {
        infiniteArchive = {
            trackProgress = false,
            logStart = false,
            logBest = false,
            logStop = false,
            records = {
                solo = {},
                duo = {},
            },
        },
    },
}

local savedVariables
local initialized = false
local lifecycleEventsRegistered = false
local monitoringActive = false
local monitoringRun
local groupTypeRecheckPending = false
local ReconcileMonitoringGroupType
local FormatMonitoringBestMessage

local function GetSettings()
    local combat = NQOL.Settings.GetSection(savedVariables, defaults, "combat")
    if type(combat.infiniteArchive) ~= "table" then
        combat.infiniteArchive = {}
    end

    local settings = combat.infiniteArchive
    local archiveDefaults = defaults.combat.infiniteArchive
    NQOL.Settings.Boolean(settings, archiveDefaults, "trackProgress")
    NQOL.Settings.Boolean(settings, archiveDefaults, "logStart")
    NQOL.Settings.Boolean(settings, archiveDefaults, "logBest")
    NQOL.Settings.Boolean(settings, archiveDefaults, "logStop")
    if type(settings.records) ~= "table" then
        settings.records = {}
    end
    if type(settings.records[C.GROUP_SOLO]) ~= "table" then
        settings.records[C.GROUP_SOLO] = {}
    end
    if type(settings.records[C.GROUP_DUO]) ~= "table" then
        settings.records[C.GROUP_DUO] = {}
    end
    settings.records[C.GROUP_SOLO].classId = nil
    settings.records[C.GROUP_DUO].classId = nil
    return settings
end

local function MigrateLegacySettings()
    local progress = savedVariables and savedVariables.progress
    local legacy = type(progress) == "table" and progress.infiniteArchive or nil
    if type(legacy) ~= "table" then return end

    local combat = NQOL.Settings.EnsurePath(savedVariables, { "combat", "infiniteArchive" })
    for _, key in ipairs({ "trackProgress", "logStart", "logStop", "records", "activeRun" }) do
        if legacy[key] ~= nil then
            combat[key] = legacy[key]
            legacy[key] = nil
        end
    end
end

local function IsProgressGreater(arc, cycle, stage, record)
    local recordArc = tonumber(record.arc) or 0
    local recordCycle = tonumber(record.cycle) or 0
    local recordStage = tonumber(record.stage) or 0
    if arc ~= recordArc then return arc > recordArc end
    if cycle ~= recordCycle then return cycle > recordCycle end
    return stage > recordStage
end

local function GetCurrentGroupKey()
    if not GetEndlessDungeonGroupType then return nil end
    local groupType = GetEndlessDungeonGroupType()
    if ENDLESS_DUNGEON_GROUP_TYPE_SOLO and groupType == ENDLESS_DUNGEON_GROUP_TYPE_SOLO then
        return C.GROUP_SOLO
    end
    if ENDLESS_DUNGEON_GROUP_TYPE_DUO and groupType == ENDLESS_DUNGEON_GROUP_TYPE_DUO then
        return C.GROUP_DUO
    end
    return nil
end

local function CaptureCurrentProgress()
    if not GetEndlessDungeonCounterValue or not IsInstanceEndlessDungeon or not IsInstanceEndlessDungeon() then
        return
    end

    if monitoringActive and ReconcileMonitoringGroupType then
        ReconcileMonitoringGroupType()
    end
    local groupKey = monitoringActive and monitoringRun and monitoringRun.groupKey or GetCurrentGroupKey()
    if not groupKey then return end

    local arc = tonumber(GetEndlessDungeonCounterValue(ENDLESS_DUNGEON_COUNTER_TYPE_ARC)) or 0
    local cycle = tonumber(GetEndlessDungeonCounterValue(ENDLESS_DUNGEON_COUNTER_TYPE_CYCLE)) or 0
    local stage = tonumber(GetEndlessDungeonCounterValue(ENDLESS_DUNGEON_COUNTER_TYPE_STAGE)) or 0
    local score = GetEndlessDungeonScore and (tonumber(GetEndlessDungeonScore()) or 0) or 0
    if arc <= 0 then return end

    local record = GetSettings().records[groupKey]
    local progressImproved = IsProgressGreater(arc, cycle, stage, record)
    local scoreImproved = score > (tonumber(record.score) or 0)
    if progressImproved then
        record.arc = arc
        record.cycle = cycle
        record.stage = stage
    end
    if scoreImproved then
        record.score = score
    end
end

local function FormatRecordValue(value)
    value = tonumber(value)
    if not value or value <= 0 then return "-" end
    return tostring(value)
end

local function FormatScore(record)
    local score = tonumber(record and record.score)
    if not score or score <= 0 then return "-" end
    score = math.floor(score)
    if ZO_CommaDelimitNumber then
        return ZO_CommaDelimitNumber(score)
    end
    return tostring(score)
end

local function IsCurrentArchiveActive()
    if not IsInstanceEndlessDungeon or IsInstanceEndlessDungeon() ~= true then
        return false
    end
    return not IsEndlessDungeonCompleted or IsEndlessDungeonCompleted() ~= true
end

local function SnapshotRecord(record)
    return {
        score = math.max(tonumber(record and record.score) or 0, 0),
        arc = math.max(tonumber(record and record.arc) or 0, 0),
        cycle = math.max(tonumber(record and record.cycle) or 0, 0),
        stage = math.max(tonumber(record and record.stage) or 0, 0),
    }
end

local function IsValidBaseline(baseline)
    if type(baseline) ~= "table" then return false end
    for _, key in ipairs({ "score", "arc", "cycle", "stage" }) do
        if type(baseline[key]) ~= "number" or baseline[key] < 0 then
            return false
        end
    end
    return true
end

local function GetCurrentRunStartTime()
    if not GetEndlessDungeonStartTimeMilliseconds then return nil end
    local startTime = tonumber(GetEndlessDungeonStartTimeMilliseconds())
    if not startTime or startTime <= 0 then return nil end
    return startTime
end

local function IsPersistedRunForStart(run, startTime)
    return type(run) == "table"
        and (run.groupKey == C.GROUP_SOLO or run.groupKey == C.GROUP_DUO)
        and type(run.startTime) == "number"
        and run.startTime > 0
        and run.startTime == startTime
        and IsValidBaseline(run.baseline)
end

local function RestoreRecord(record, snapshot)
    record.score = snapshot.score > 0 and snapshot.score or nil
    record.arc = snapshot.arc > 0 and snapshot.arc or nil
    record.cycle = snapshot.cycle > 0 and snapshot.cycle or nil
    record.stage = snapshot.stage > 0 and snapshot.stage or nil
end

local function PromoteRunToDuo(run)
    if type(run) ~= "table" or run.groupKey ~= C.GROUP_SOLO or not IsValidBaseline(run.baseline) then
        return false
    end

    local settings = GetSettings()
    local duoBaseline = SnapshotRecord(settings.records[C.GROUP_DUO])
    RestoreRecord(settings.records[C.GROUP_SOLO], run.baseline)
    run.groupKey = C.GROUP_DUO
    run.baseline = duoBaseline
    monitoringRun = run
    settings.activeRun = run.startTime and run or nil
    return true
end

local function LogGroupTypeChange()
    if monitoringActive then
        NQOL.Chat.Message(NQOL.L("features.combat_infinite_archive.run_changed_from_solo_to_duo_score_and_progress_trac_48adcc5"), NQOL.L("features.combat_infinite_archive.feature_name"))
        if GetSettings().logBest == true and monitoringRun and FormatMonitoringBestMessage then
            NQOL.Chat.Message(FormatMonitoringBestMessage(monitoringRun), NQOL.L("features.combat_infinite_archive.feature_name"))
        end
    end
end

local function ClearActiveRun()
    GetSettings().activeRun = nil
    monitoringRun = nil
end

local function PrepareActiveRun()
    local settings = GetSettings()
    local groupKey = GetCurrentGroupKey()
    local startTime = GetCurrentRunStartTime()
    local persistedRun = settings.activeRun

    if groupKey and startTime and IsPersistedRunForStart(persistedRun, startTime) then
        monitoringRun = persistedRun
        if persistedRun.groupKey == groupKey or persistedRun.groupKey == C.GROUP_DUO then
            return persistedRun
        end
        if groupKey == C.GROUP_DUO and PromoteRunToDuo(persistedRun) then
            return persistedRun, true
        end
    end

    settings.activeRun = nil
    if not groupKey then
        monitoringRun = nil
        return nil
    end

    local run = {
        groupKey = groupKey,
        startTime = startTime,
        baseline = SnapshotRecord(settings.records[groupKey]),
    }
    monitoringRun = run
    if startTime then
        settings.activeRun = run
    end
    return run
end

ReconcileMonitoringGroupType = function()
    if not monitoringActive or not monitoringRun or monitoringRun.groupKey ~= C.GROUP_SOLO then
        return false
    end
    if GetCurrentGroupKey() ~= C.GROUP_DUO then return false end
    local promoted = PromoteRunToDuo(monitoringRun)
    if promoted then LogGroupTypeChange() end
    return promoted
end

local function ShowPersonalBestAnnouncement(run, record, scoreImproved, progressImproved)
    if not scoreImproved and not progressImproved then return end
    if not CENTER_SCREEN_ANNOUNCE or not CENTER_SCREEN_ANNOUNCE.CreateMessageParams then return end

    local category = CSA_CATEGORY_LARGE_TEXT or CSA_CATEGORY_MAJOR_TEXT
    if not category then return end
    local sound
    if SOUNDS then
        sound = SOUNDS.RAID_TRIAL_NEW_BEST or SOUNDS.ACHIEVEMENT_AWARDED or SOUNDS.NONE
    end
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(category, sound)
    if not messageParams or not messageParams.SetText then return end

    local lines = {}
    if scoreImproved then
        lines[#lines + 1] = NQOL.L("features.combat_infinite_archive.best_score", C.RECORD_VALUE_COLOR, FormatScore(record))
    end
    if progressImproved then
        lines[#lines + 1] = NQOL.L(
            "features.combat_infinite_archive.best_progress",
            C.RECORD_VALUE_COLOR,
            FormatRecordValue(record.arc),
            FormatRecordValue(record.cycle),
            FormatRecordValue(record.stage)
        )
    end

    local mode = run.groupKey == C.GROUP_DUO and "DUO" or "SOLO"
    messageParams:SetText(NQOL.L("features.combat_infinite_archive.new_best", mode), table.concat(lines, "\n"))
    if messageParams.SetCSAType and CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT then
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
    end
    if messageParams.SetLifespanMS then
        messageParams:SetLifespanMS(C.PERSONAL_BEST_CSA_LIFESPAN_MS)
    end
    if messageParams.MarkSuppressIconFrame then
        messageParams:MarkSuppressIconFrame()
    end

    if CENTER_SCREEN_ANNOUNCE.AddMessageWithParams then
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    elseif CENTER_SCREEN_ANNOUNCE.DisplayMessage then
        CENTER_SCREEN_ANNOUNCE:DisplayMessage(messageParams)
    end
end

local function AnnounceRunPersonalBest(run)
    if type(run) ~= "table" or not IsValidBaseline(run.baseline) then return end
    local record = GetSettings().records[run.groupKey]
    if type(record) ~= "table" then return end

    local scoreImproved = (tonumber(record.score) or 0) > run.baseline.score
    local progressImproved = IsProgressGreater(
        tonumber(record.arc) or 0,
        tonumber(record.cycle) or 0,
        tonumber(record.stage) or 0,
        run.baseline
    )
    ShowPersonalBestAnnouncement(run, record, scoreImproved, progressImproved)
end

local function OnPotentialGroupTypeChanged()
    if not monitoringActive then return end

    CaptureCurrentProgress()
    if not monitoringRun or monitoringRun.groupKey == C.GROUP_DUO or groupTypeRecheckPending or not zo_callLater then
        return
    end

    local observedRun = monitoringRun
    groupTypeRecheckPending = true
    zo_callLater(function()
        groupTypeRecheckPending = false
        if monitoringActive and monitoringRun == observedRun then
            CaptureCurrentProgress()
        end
    end, 100)
end

local function UnregisterMonitoringEvents()
    if not EVENT_MANAGER then return end
    if EVENT_ENDLESS_DUNGEON_COUNTER_VALUE_CHANGED then
        EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE .. "_Counter", EVENT_ENDLESS_DUNGEON_COUNTER_VALUE_CHANGED)
    end
    if EVENT_ENDLESS_DUNGEON_SCORE_UPDATED then
        EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE .. "_Score", EVENT_ENDLESS_DUNGEON_SCORE_UPDATED)
    end
    if EVENT_ENDLESS_DUNGEON_COMPLETED then
        EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE .. "_Completed", EVENT_ENDLESS_DUNGEON_COMPLETED)
    end
    if EVENT_ACTIVE_COMPANION_STATE_CHANGED then
        EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE .. "_CompanionState", EVENT_ACTIVE_COMPANION_STATE_CHANGED)
    end
    if EVENT_COMPANION_ACTIVATED then
        EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE .. "_CompanionActivated", EVENT_COMPANION_ACTIVATED)
    end
    if EVENT_GROUP_MEMBER_JOINED then
        EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE .. "_GroupJoined", EVENT_GROUP_MEMBER_JOINED)
    end
end

local function StopMonitoring(reason)
    if not monitoringActive then
        ClearActiveRun()
        return
    end

    local run = monitoringRun or GetSettings().activeRun
    CaptureCurrentProgress()
    UnregisterMonitoringEvents()
    monitoringActive = false
    groupTypeRecheckPending = false
    ClearActiveRun()
    if reason == "completed" or reason == "exit" then
        AnnounceRunPersonalBest(run)
    end
    if GetSettings().logStop == true then
        NQOL.Chat.Message(NQOL.L("features.combat_infinite_archive.score_monitoring_has_stopped_d032dd4"), NQOL.L("features.combat_infinite_archive.feature_name"))
    end
end

local function OnDungeonCompleted()
    StopMonitoring("completed")
end

FormatMonitoringBestMessage = function(run)
    local baseline = run.baseline
    local mode = run.groupKey == C.GROUP_DUO and "DUO" or "SOLO"
    local details = {}
    if (tonumber(baseline.score) or 0) > 0 then
        details[#details + 1] = NQOL.L("features.combat_infinite_archive.best_score_plain", FormatScore(baseline))
    end
    if (tonumber(baseline.arc) or 0) > 0 then
        details[#details + 1] = NQOL.L(
            "features.combat_infinite_archive.best_progress_plain",
            FormatRecordValue(baseline.arc),
            FormatRecordValue(baseline.cycle),
            FormatRecordValue(baseline.stage)
        )
    end
    if #details == 0 then
        return NQOL.L("features.combat_infinite_archive.no_saved_best", mode)
    end
    return NQOL.L("features.combat_infinite_archive.saved_best", mode, table.concat(details, " · "))
end

local function StartMonitoring()
    if not EVENT_MANAGER or monitoringActive or GetSettings().trackProgress ~= true or not IsCurrentArchiveActive() then
        return
    end

    local run, promotedToDuo = PrepareActiveRun()
    if not run then return end

    if EVENT_ENDLESS_DUNGEON_COUNTER_VALUE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE .. "_Counter", EVENT_ENDLESS_DUNGEON_COUNTER_VALUE_CHANGED, CaptureCurrentProgress)
    end
    if EVENT_ENDLESS_DUNGEON_SCORE_UPDATED then
        EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE .. "_Score", EVENT_ENDLESS_DUNGEON_SCORE_UPDATED, CaptureCurrentProgress)
    end
    if EVENT_ENDLESS_DUNGEON_COMPLETED then
        EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE .. "_Completed", EVENT_ENDLESS_DUNGEON_COMPLETED, OnDungeonCompleted)
    end
    if EVENT_ACTIVE_COMPANION_STATE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE .. "_CompanionState", EVENT_ACTIVE_COMPANION_STATE_CHANGED, OnPotentialGroupTypeChanged)
    end
    if EVENT_COMPANION_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE .. "_CompanionActivated", EVENT_COMPANION_ACTIVATED, OnPotentialGroupTypeChanged)
    end
    if EVENT_GROUP_MEMBER_JOINED then
        EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE .. "_GroupJoined", EVENT_GROUP_MEMBER_JOINED, OnPotentialGroupTypeChanged)
    end

    monitoringActive = true
    if promotedToDuo then LogGroupTypeChange() end
    CaptureCurrentProgress()
    if GetSettings().logStart == true then
        local mode = run.groupKey == C.GROUP_DUO and "DUO" or "SOLO"
        NQOL.Chat.Message(NQOL.L("features.combat_infinite_archive.monitor_active", mode), NQOL.L("features.combat_infinite_archive.feature_name"))
    end
    if GetSettings().logBest == true and not promotedToDuo then
        NQOL.Chat.Message(FormatMonitoringBestMessage(run), NQOL.L("features.combat_infinite_archive.feature_name"))
    end
end

local function RefreshMonitoringState()
    if GetSettings().trackProgress == true and IsCurrentArchiveActive() then
        StartMonitoring()
    else
        StopMonitoring("exit")
    end
end

local function OnDungeonInitialized(_, _, _, _, _, completed)
    if completed == true then
        StopMonitoring("completed")
        return
    end
    RefreshMonitoringState()
end

local function RegisterLifecycleEvents()
    if not EVENT_MANAGER or lifecycleEventsRegistered then return end
    lifecycleEventsRegistered = true
    if EVENT_ENDLESS_DUNGEON_INITIALIZED then
        EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE .. "_Initialized", EVENT_ENDLESS_DUNGEON_INITIALIZED, OnDungeonInitialized)
    end
    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(C.EVENT_NAMESPACE .. "_Player", EVENT_PLAYER_ACTIVATED, RefreshMonitoringState)
    end
end

local function UnregisterLifecycleEvents()
    if not EVENT_MANAGER or not lifecycleEventsRegistered then return end
    if EVENT_ENDLESS_DUNGEON_INITIALIZED then
        EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE .. "_Initialized", EVENT_ENDLESS_DUNGEON_INITIALIZED)
    end
    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:UnregisterForEvent(C.EVENT_NAMESPACE .. "_Player", EVENT_PLAYER_ACTIVATED)
    end
    lifecycleEventsRegistered = false
end

local function ApplyTrackingSetting()
    if GetSettings().trackProgress == true then
        RegisterLifecycleEvents()
        RefreshMonitoringState()
    else
        StopMonitoring("disabled")
        UnregisterLifecycleEvents()
    end
end

function CombatInfiniteArchive.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    MigrateLegacySettings()
    GetSettings()
end

function CombatInfiniteArchive.Initialize()
    if initialized then return end
    initialized = true
    ApplyTrackingSetting()
end

function CombatInfiniteArchive.GetRecord(groupKey)
    local records = GetSettings().records
    return records[groupKey] or {}
end

function CombatInfiniteArchive.GetTrackProgress() return GetSettings().trackProgress end
function CombatInfiniteArchive.GetTrackProgressDefault() return defaults.combat.infiniteArchive.trackProgress end
function CombatInfiniteArchive.SetTrackProgress(value) GetSettings().trackProgress = value == true; ApplyTrackingSetting() end
function CombatInfiniteArchive.GetLogStart() return GetSettings().logStart end
function CombatInfiniteArchive.GetLogStartDefault() return defaults.combat.infiniteArchive.logStart end
function CombatInfiniteArchive.SetLogStart(value) GetSettings().logStart = value == true end
function CombatInfiniteArchive.GetLogBest() return GetSettings().logBest end
function CombatInfiniteArchive.GetLogBestDefault() return defaults.combat.infiniteArchive.logBest end
function CombatInfiniteArchive.SetLogBest(value) GetSettings().logBest = value == true end
function CombatInfiniteArchive.GetLogStop() return GetSettings().logStop end
function CombatInfiniteArchive.GetLogStopDefault() return defaults.combat.infiniteArchive.logStop end
function CombatInfiniteArchive.SetLogStop(value) GetSettings().logStop = value == true end

function CombatInfiniteArchive.GetTrackProgressLabel() return NQOL.L("features.combat_infinite_archive.track_progress_label") end
function CombatInfiniteArchive.GetTrackProgressTooltip() return NQOL.L("features.combat_infinite_archive.track_progress_tooltip") end
function CombatInfiniteArchive.GetLogStartLabel() return NQOL.L("features.combat_infinite_archive.log_start_label") end
function CombatInfiniteArchive.GetLogStartTooltip() return NQOL.L("features.combat_infinite_archive.log_start_tooltip") end
function CombatInfiniteArchive.GetLogBestLabel() return NQOL.L("features.combat_infinite_archive.log_best_label") end
function CombatInfiniteArchive.GetLogBestTooltip() return NQOL.L("features.combat_infinite_archive.log_best_tooltip") end
function CombatInfiniteArchive.GetLogStopLabel() return NQOL.L("features.combat_infinite_archive.log_stop_label") end
function CombatInfiniteArchive.GetLogStopTooltip() return NQOL.L("features.combat_infinite_archive.log_stop_tooltip") end

NQOL.Features.CombatInfiniteArchive = CombatInfiniteArchive
