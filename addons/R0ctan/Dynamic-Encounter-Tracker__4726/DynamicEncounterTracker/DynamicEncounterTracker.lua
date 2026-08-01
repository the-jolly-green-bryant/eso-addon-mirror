DynamicEncounterTracker = DynamicEncounterTracker or {}
local DE = DynamicEncounterTracker

DE.name = "DynamicEncounterTracker"
DE.displayName = "Dynamic Encounter Tracker"
DE.version = "1.0.0"
DE.author = "R0ctan"
DE.savedVariablesName = "DynamicEncounterTracker_Data"
DE.savedVariablesVersion = 1
DE.eventPrefix = DE.name .. "_"
DE.updateName = DE.name .. "_TimerUpdate"
DE.scanUpdateName = DE.name .. "_PeriodicScan"
DE.scanIntervalMs = 1000
DE.noActiveGraceSeconds = 3
DE.chestHintDurationSeconds = 15
DE.centerChestAlertDefaultSeconds = 5
DE.maxDiagnosticHistory = 200
DE.dynamicEventMapLocationIcon = "/esoui/art/icons/servicemappins/u50_poi_dynamic_world_event.dds"

DE.STATUS_UNSUPPORTED = "unsupported"
DE.STATUS_UNKNOWN = "unknown"
DE.STATUS_ACTIVE = "active"
DE.STATUS_COOLDOWN = "cooldown"

DE.PARTICIPATION_UNKNOWN = "unknown"
DE.PARTICIPATION_OPEN = "open"
DE.PARTICIPATION_DETECTED = "detected"

DE.modules = DE.modules or {}

function DE:RegisterModule(name, module)
    if type(name) ~= "string" or name == "" or type(module) ~= "table" then
        return false
    end
    self.modules[name] = module
    module.owner = self
    return true
end

function DE:GetModule(name)
    return self.modules and self.modules[name] or nil
end

function DE:ModuleHook(moduleName, methodName, ...)
    local module = self:GetModule(moduleName)
    if not module then
        return nil
    end
    local method = module[methodName]
    if type(method) ~= "function" then
        return nil
    end
    return method(module, ...)
end

function DE:HasDebugModule()
    return self:GetModule("debug") ~= nil
end

function DE:IsDebugEnabled()
    return self:HasDebugModule()
        and self.sv ~= nil
        and self.sv.debugEnabled == true
end

function DE:DebugHook(methodName, ...)
    local module = self:GetModule("debug")
    if not module or not self:IsDebugEnabled() then
        return nil
    end
    local method = module[methodName]
    if type(method) ~= "function" then
        return nil
    end
    return method(module, ...)
end

-- No-op bridge when the debug module is not installed.
function DE:RecordDiagnosticSnapshot(source, force)
    return self:DebugHook("RecordDiagnosticSnapshot", source, force)
end

function DE:StartStepRun(isExact, source)
    return self:DebugHook("StartStepRun", isExact, source)
end

function DE:FinalizeStepRun(endExact, source)
    return self:DebugHook("FinalizeStepRun", endExact, source)
end

function DE:ResetStepRun(reason)
    return self:DebugHook("ResetStepRun", reason)
end

function DE:EnsureStepLearningZone(zoneId)
    return self:DebugHook("EnsureStepLearningZone", zoneId)
end

function DE:GetStableLearnedSequence(eventName)
    return self:DebugHook("GetStableLearnedSequence", eventName)
end

function DE:GetStableLearnedLocationSequence(eventName)
    return self:DebugHook("GetStableLearnedLocationSequence", eventName)
end

function DE:T(key, ...)
    local stringId = _G[key]
    local text = stringId and GetString(stringId) or tostring(key)
    if select("#", ...) > 0 then
        return zo_strformat(text, ...)
    end
    return text
end

function DE:Print(message)
    CHAT_ROUTER:AddSystemMessage(string.format("|cD6BD78[%s]|r %s", self.displayName, tostring(message)))
end

function DE:IsAddonRuntimeEnabled()
    return self.sv ~= nil and self.sv.enabled == true and self.state.runtimeEnabled == true
end

function DE:IsZoneRuntimeEnabled()
    return self:IsAddonRuntimeEnabled() and self.state.zoneRuntimeActive == true
end

DE.defaults = {
    enabled = true,
    showWindow = true,
    locked = false,
    minimalMode = false,
    showCloseButton = true,
    showMinimalToggleButton = true,
    hideInMenus = true,
    showOnWorldMap = true,
    hideOutsideSupportedZones = true,
    showStepInStatus = true,
    showStepProgressInStatus = true,
    showParticipationInStatus = true,
    showPhase = true,
    showHintInStatusWindow = true,
    debugEnabled = true,
    showDebugArea = true,
    showRespawnTimer = true,
    showSpawnWindowHint = true,
    showRespawnOverrun = true,
    respawnTimerOverrides = {},
    showChestHints = true,
    showCenterChestAlert = true,
    centerChestAlertSeconds = 5,
    chestAlertMovable = false,
    chestAlertTextSize = 28,
    textSize = 18,
    backgroundOpacity = 0.82,
    size = {
        width = 580,
        height = 245,
    },
    position = {
        point = TOPLEFT,
        relativePoint = TOPLEFT,
        x = 200,
        y = 200,
    },
    chestAlertSize = {
        width = 620,
        height = 86,
    },
    chestAlertPosition = {
        point = CENTER,
        relativePoint = CENTER,
        x = 0,
        y = 0,
    },
    chestAlertColors = {
        background = { 0.015, 0.018, 0.02, 0.90 },
        frame = { 0.63, 0.52, 0.31, 0.95 },
        text = { 0.96, 0.72, 0.18, 1 },
    },
    colors = {
        title = { 0.93, 0.88, 0.72, 1 },
        label = { 0.88, 0.84, 0.76, 1 },
        value = { 0.96, 0.96, 0.94, 1 },
        active = { 0.42, 0.90, 0.28, 1 },
        cooldown = { 0.96, 0.72, 0.18, 1 },
        unknown = { 0.60, 0.60, 0.60, 1 },
        frame = { 0.63, 0.52, 0.31, 0.95 },
        border = { 0.63, 0.52, 0.31, 0.95 },
    },
}

DE.state = {
    runtimeEnabled = false,
    zoneId = 0,
    zoneName = "",
    zoneEncounterConfigs = nil,
    eventData = nil,
    zoneRuntimeActive = false,
    baseEventsRegistered = false,
    zoneEventsRegistered = false,
    status = DE.STATUS_UNKNOWN,
    activeWorldEventInstanceId = nil,
    activeWorldEventRole = nil,
    parentActive = false,
    eventName = nil,
    phaseName = nil,
    phaseHintText = nil,
    currentStepDefId = nil,
    currentStepSource = nil,
    currentStepOrdinal = nil,
    currentStepTotal = nil,
    currentMapLocationIndex = nil,
    currentMapLocationSource = nil,
    currentMapLocationHeader = nil,
    currentMapLocationDescription = nil,
    currentMapLocationCandidateCount = 0,
    currentMapLocationScanReason = nil,
    isParticipating = false,
    participatingInstanceId = nil,
    participatingStepDefId = nil,
    currentProgress = nil,
    maxProgress = nil,
    progressSource = nil,
    lastProgressObservedAt = nil,
    participatedSteps = {},
    participationDisplayState = DE.PARTICIPATION_UNKNOWN,
    triggeredChestRules = {},
    lastChestRuleId = nil,
    chestCandidateCount = 0,
    chestHintText = nil,
    chestHintUntil = nil,
    centerChestAlertText = nil,
    centerChestAlertUntil = nil,
    lastChestTriggerKey = nil,
    lastChestTriggeredAt = nil,
    noActiveSince = nil,
    lastScanAt = nil,
    encounterRunId = 0,
    lastDiagnosticSignature = nil,
    stepRun = nil,
    earliestRespawnAt = nil,
    respawnAt = nil,
    expectedClockSeconds = nil,
    cooldownStartedAt = nil,
    cooldownStartExact = nil,
    cooldownSource = nil,
}

function DE:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide(
        self.savedVariablesName,
        self.savedVariablesVersion,
        nil,
        self.defaults,
        GetWorldName()
    )
    if self:HasDebugModule() then
        self.sv.stepLearning = self.sv.stepLearning or {}
        self.sv.diagnosticHistory = self.sv.diagnosticHistory or {}
    end
    self.sv.size = self.sv.size or {}
    if type(self.sv.size.width) ~= "number" then
        self.sv.size.width = self.defaults.size.width
    end
    if type(self.sv.size.height) ~= "number" then
        self.sv.size.height = self.defaults.size.height
    end
    self.sv.size.width = zo_clamp(self.sv.size.width, self.WINDOW_MIN_WIDTH, self.WINDOW_MAX_WIDTH)
    self.sv.size.height = self.WINDOW_DEFAULT_HEIGHT
    self.sv.colors = self.sv.colors or {}
    if not self.sv.colors.frame then
        local oldBorder = self.sv.colors.border or self.defaults.colors.frame
        self.sv.colors.frame = {
            oldBorder[1],
            oldBorder[2],
            oldBorder[3],
            oldBorder[4] or 1,
        }
    end
    if self.sv.showStepInStatus == nil then
        self.sv.showStepInStatus = self.defaults.showStepInStatus
    end
    if self.sv.showStepProgressInStatus == nil then
        self.sv.showStepProgressInStatus = self.defaults.showStepProgressInStatus
    end
    if self.sv.showParticipationInStatus == nil then
        self.sv.showParticipationInStatus = self.defaults.showParticipationInStatus
    end
    if self.sv.showHintInStatusWindow == nil then
        self.sv.showHintInStatusWindow = self.defaults.showHintInStatusWindow
    end
    if self.sv.showRespawnTimer == nil then
        self.sv.showRespawnTimer = self.defaults.showRespawnTimer
    end
    if self.sv.showSpawnWindowHint == nil then
        self.sv.showSpawnWindowHint = self.defaults.showSpawnWindowHint
    end
    if self.sv.showRespawnOverrun == nil then
        self.sv.showRespawnOverrun = self.defaults.showRespawnOverrun
    end
    self:InitializeRespawnTimerSettings()
    if self.sv.debugEnabled == nil then
        self.sv.debugEnabled = self.defaults.debugEnabled
    end
    if self.sv.showDebugArea == nil then
        self.sv.showDebugArea = self.defaults.showDebugArea
    end
    if self.sv.showChestHints == nil then
        self.sv.showChestHints = self.defaults.showChestHints
    end
    if self.sv.showCenterChestAlert == nil then
        self.sv.showCenterChestAlert = self.defaults.showCenterChestAlert
    end
    if type(self.sv.centerChestAlertSeconds) ~= "number" then
        self.sv.centerChestAlertSeconds = self.defaults.centerChestAlertSeconds
    end
    self.sv.centerChestAlertSeconds = zo_clamp(self.sv.centerChestAlertSeconds, 1, 30)
    if self.sv.chestAlertMovable == nil then
        self.sv.chestAlertMovable = self.defaults.chestAlertMovable
    end
    if type(self.sv.chestAlertTextSize) ~= "number" then
        self.sv.chestAlertTextSize = self.defaults.chestAlertTextSize
    end
    self.sv.chestAlertTextSize = zo_clamp(self.sv.chestAlertTextSize, 16, 42)
    self.sv.chestAlertSize = self.sv.chestAlertSize or {}
    if type(self.sv.chestAlertSize.width) ~= "number" then
        self.sv.chestAlertSize.width = self.defaults.chestAlertSize.width
    end
    self.sv.chestAlertSize.width = zo_clamp(self.sv.chestAlertSize.width, 320, 900)
    self.sv.chestAlertSize.height = self.defaults.chestAlertSize.height
    self.sv.chestAlertPosition = self.sv.chestAlertPosition or {
        point = self.defaults.chestAlertPosition.point,
        relativePoint = self.defaults.chestAlertPosition.relativePoint,
        x = self.defaults.chestAlertPosition.x,
        y = self.defaults.chestAlertPosition.y,
    }
    self.sv.chestAlertColors = self.sv.chestAlertColors or {}
    for colorName, defaultColor in pairs(self.defaults.chestAlertColors) do
        if not self.sv.chestAlertColors[colorName] then
            self.sv.chestAlertColors[colorName] = {
                defaultColor[1],
                defaultColor[2],
                defaultColor[3],
                defaultColor[4] or 1,
            }
        end
    end

    local respawnMeasurementModule = self:GetModule("respawnMeasurement")
    if respawnMeasurementModule and type(respawnMeasurementModule.Initialize) == "function" then
        respawnMeasurementModule:Initialize()
    end

    local debugModule = self:GetModule("debug")
    if debugModule and type(debugModule.Initialize) == "function" then
        debugModule:Initialize()
    end

    self:CreateUI()
    self:CreateSettings()

    SLASH_COMMANDS["/dynet"] = function(text)
        self:HandleSlashCommand(text)
    end
    SLASH_COMMANDS["/dynamicencountertracker"] = SLASH_COMMANDS["/dynet"]

    if self.sv.enabled then
        self:EnableRuntime()
    else
        self:DisableRuntime()
    end
end

