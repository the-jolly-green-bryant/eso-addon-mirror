DynamicEncounterTracker = DynamicEncounterTracker or {}
local DE = DynamicEncounterTracker

DE.name = "DynamicEncounterTracker"
DE.displayName = "Dynamic Encounter Tracker"
DE.version = "1.2.0"
-- Bumped by tools/increment-build-number.ps1 on every build (prod and dev),
-- independent of the semantic version above. Pilot for a cross-project
-- build-number convention (see .build-counter).
DE.buildNumber = 205
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

function DE:Debug(message)
    if not self:IsDebugEnabled() then
        return
    end
    if type(message) == "function" then
        message = message()
    end
    self:Print(message)
end

function DE:IsAddonRuntimeEnabled()
    return self.sv ~= nil and self.sv.enabled == true and self.state.runtimeEnabled == true
end

function DE:IsZoneRuntimeEnabled()
    if self.state.relayDebugPaused then
        return false
    end
    return self:IsAddonRuntimeEnabled() and self.state.zoneRuntimeActive == true
end

DE.defaults = {
    enabled = true,
    showWindow = true,
    locked = false,
    minimalMode = false,
    minimalShowFrame = false,
    showFrame = false,
    showCloseButton = true,
    showMinimalToggleButton = true,
    hideInMenus = true,
    showOnWorldMap = true,
    showStepInStatus = true,
    showStepProgressInStatus = true,
    showParticipationInStatus = true,
    showPhase = true,
    showHintInStatusWindow = true,
    showUnknownCountUp = true,
    -- Debugging must be explicitly enabled even in development builds.
    debugEnabled = false,
    showDebugArea = false,
    showRespawnTimer = true,
    showSpawnWindowHint = true,
    showRespawnOverrun = true,
    respawnTimerOverrides = {},
    respawnDefaultsAcknowledgedVersion = 0,
    relayShowButton = true,
    relayReceiveEnabled = true,
    relayAutoAccept = false,
    relayShowInvalidNotice = true,
    relaySequence = 0,
    relayGuildShowButton = true,
    relayGuildReceiveEnabled = true,
    relayCodeOfConductAcceptedVersion = 0,
    relayRequestReceiveEnabled = true,
    relayRequestReplyChannel = "ask",
    relayRequestShowButton = true,
    relayRequestCollectionWindowSeconds = 60,
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
    relayWindowShow = true,
    relayWindowLocked = false,
    relayWindowShowBorder = false,
    relayWindowFontSize = 16,
    relayWindowSortMode = "remaining",
    relayWindowBlinkThresholdSeconds = 30,
    relayWindowCheckIntervalSeconds = 15,
    -- One-time shares expire quickly; locally estimated starts have a calculable lifetime.
    relayWindowActiveShareMaxAgeSeconds = 30,
    relayWindowActiveEstimatedMaxAgeSeconds = 180,
    -- Left-aligned directly under the status window's own default position
    -- (TOPLEFT 200,200, height 190) with a small gap.
    relayWindowPosition = {
        anchor = "left",
        x = 200,
        y = 400,
    },
    relayWindowColors = {
        background = { 0.015, 0.018, 0.02, 0.90 },
        titleBar = { 0.13, 0.11, 0.09, 0.95 },
        titleText = { 0.93, 0.88, 0.72, 1 },
        zoneText = { 0.96, 0.96, 0.94, 1 },
        playerText = { 0.88, 0.84, 0.76, 1 },
        separator = { 0.63, 0.52, 0.31, 0.55 },
        warning = { 1, 0.55, 0, 1 },
        blink = { 0.42, 0.90, 0.28, 1 },
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
    -- Player-plus-encounter keys make later shares update rather than duplicate rows.
    guildRelayEntries = {},
}

-- Keybind handlers (see Bindings.xml). Guarded by IsAddonRuntimeEnabled so a
-- keybind press while the addon is off (via /dynet off) does nothing, same
-- as the equivalent slash commands (see HandleSlashCommand).
function DE:OnKeybindToggleWindow()
    if not self:IsAddonRuntimeEnabled() then
        return
    end
    self.sv.showWindow = not self.sv.showWindow
    self:RefreshVisibility()
end

function DE:OnKeybindToggleMinimal()
    if not self:IsAddonRuntimeEnabled() then
        return
    end
    self.sv.minimalMode = not self.sv.minimalMode
    self:RefreshUI()
    self:RefreshSettingsPanel()
end

function DE:OnKeybindShareDialog()
    if not self:IsAddonRuntimeEnabled() then
        return
    end
    self:ShowRelayShareDialog()
end

function DE:OnKeybindRequestDialog()
    if not self:IsAddonRuntimeEnabled() then
        return
    end
    self:ShowRelayRequestDialog()
end

function DE:OnKeybindToggleGuildWindow()
    if not self:IsAddonRuntimeEnabled() or not self.GuildRelayWindow then
        return
    end
    self.sv.relayWindowShow = not self.sv.relayWindowShow
    -- Refresh also restarts the one-second tick after the window was hidden.
    self.GuildRelayWindow:Refresh()
end

-- Bindings.xml resolves plain global functions, so wrappers guard the addon load order.
function DynamicEncounterTracker_OnKeybindToggleWindow()
    if DynamicEncounterTracker and DynamicEncounterTracker.OnKeybindToggleWindow then
        DynamicEncounterTracker:OnKeybindToggleWindow()
    end
end

function DynamicEncounterTracker_OnKeybindToggleMinimal()
    if DynamicEncounterTracker and DynamicEncounterTracker.OnKeybindToggleMinimal then
        DynamicEncounterTracker:OnKeybindToggleMinimal()
    end
end

function DynamicEncounterTracker_OnKeybindShareDialog()
    if DynamicEncounterTracker and DynamicEncounterTracker.OnKeybindShareDialog then
        DynamicEncounterTracker:OnKeybindShareDialog()
    end
end

function DynamicEncounterTracker_OnKeybindRequestDialog()
    if DynamicEncounterTracker and DynamicEncounterTracker.OnKeybindRequestDialog then
        DynamicEncounterTracker:OnKeybindRequestDialog()
    end
end

function DynamicEncounterTracker_OnKeybindToggleGuildWindow()
    if DynamicEncounterTracker and DynamicEncounterTracker.OnKeybindToggleGuildWindow then
        DynamicEncounterTracker:OnKeybindToggleGuildWindow()
    end
end

function DE:Initialize()
    self.sv = ZO_SavedVars:NewAccountWide(
        self.savedVariablesName,
        self.savedVariablesVersion,
        nil,
        self.defaults,
        GetWorldName()
    )
    -- Validate table types because corrupted SavedVariables may contain non-nil scalars.
    if self:HasDebugModule() then
        if type(self.sv.stepLearning) ~= "table" then
            self.sv.stepLearning = {}
        end
        if type(self.sv.diagnosticHistory) ~= "table" then
            self.sv.diagnosticHistory = {}
        end
    end
    if type(self.sv.size) ~= "table" then
        self.sv.size = {}
    end
    if type(self.sv.size.width) ~= "number" then
        self.sv.size.width = self.defaults.size.width
    end
    if type(self.sv.size.height) ~= "number" then
        self.sv.size.height = self.defaults.size.height
    end
    self.sv.size.width = zo_clamp(self.sv.size.width, self.WINDOW_MIN_WIDTH, self.WINDOW_MAX_WIDTH)
    self.sv.size.height = self.WINDOW_DEFAULT_HEIGHT
    if type(self.sv.colors) ~= "table" then
        self.sv.colors = {}
    end
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
    if self.sv.showUnknownCountUp == nil then
        self.sv.showUnknownCountUp = self.defaults.showUnknownCountUp
    end
    if self.sv.minimalShowFrame == nil then
        self.sv.minimalShowFrame = self.defaults.minimalShowFrame
    end
    if self.sv.showFrame == nil then
        self.sv.showFrame = self.defaults.showFrame
    end
    if self.sv.relayShowButton == nil then
        self.sv.relayShowButton = self.defaults.relayShowButton
    end
    if self.sv.relayReceiveEnabled == nil then
        self.sv.relayReceiveEnabled = self.defaults.relayReceiveEnabled
    end
    if self.sv.relayAutoAccept == nil then
        self.sv.relayAutoAccept = self.defaults.relayAutoAccept
    end
    if self.sv.relayShowInvalidNotice == nil then
        self.sv.relayShowInvalidNotice = self.defaults.relayShowInvalidNotice
    end
    if type(self.sv.relaySequence) ~= "number" then
        self.sv.relaySequence = self.defaults.relaySequence
    end
    if self.sv.relayGuildShowButton == nil then
        self.sv.relayGuildShowButton = self.defaults.relayGuildShowButton
    end
    if self.sv.relayGuildReceiveEnabled == nil then
        self.sv.relayGuildReceiveEnabled = self.defaults.relayGuildReceiveEnabled
    end
    if type(self.sv.relayCodeOfConductAcceptedVersion) ~= "number" then
        self.sv.relayCodeOfConductAcceptedVersion = self.defaults.relayCodeOfConductAcceptedVersion
    end
    if self.sv.relayRequestReceiveEnabled == nil then
        self.sv.relayRequestReceiveEnabled = self.defaults.relayRequestReceiveEnabled
    end
    if self.sv.relayRequestShowButton == nil then
        self.sv.relayRequestShowButton = self.defaults.relayRequestShowButton
    end
    if type(self.sv.relayRequestCollectionWindowSeconds) ~= "number" then
        self.sv.relayRequestCollectionWindowSeconds = self.defaults.relayRequestCollectionWindowSeconds
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
    if type(self.sv.chestAlertSize) ~= "table" then
        self.sv.chestAlertSize = {}
    end
    if type(self.sv.chestAlertSize.width) ~= "number" then
        self.sv.chestAlertSize.width = self.defaults.chestAlertSize.width
    end
    self.sv.chestAlertSize.width = zo_clamp(self.sv.chestAlertSize.width, 320, 900)
    self.sv.chestAlertSize.height = self.defaults.chestAlertSize.height
    if type(self.sv.chestAlertPosition) ~= "table" then
        self.sv.chestAlertPosition = {
            point = self.defaults.chestAlertPosition.point,
            relativePoint = self.defaults.chestAlertPosition.relativePoint,
            x = self.defaults.chestAlertPosition.x,
            y = self.defaults.chestAlertPosition.y,
        }
    end
    if type(self.sv.chestAlertColors) ~= "table" then
        self.sv.chestAlertColors = {}
    end
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

    if self.sv.relayWindowShow == nil then
        self.sv.relayWindowShow = self.defaults.relayWindowShow
    end
    if self.sv.relayWindowLocked == nil then
        self.sv.relayWindowLocked = self.defaults.relayWindowLocked
    end
    if self.sv.relayWindowShowBorder == nil then
        self.sv.relayWindowShowBorder = self.defaults.relayWindowShowBorder
    end
    if type(self.sv.relayWindowFontSize) ~= "number" then
        self.sv.relayWindowFontSize = self.defaults.relayWindowFontSize
    end
    self.sv.relayWindowFontSize = zo_clamp(self.sv.relayWindowFontSize, 12, 28)
    if type(self.sv.relayWindowSortMode) ~= "string" then
        self.sv.relayWindowSortMode = self.defaults.relayWindowSortMode
    end
    if type(self.sv.relayWindowBlinkThresholdSeconds) ~= "number" then
        self.sv.relayWindowBlinkThresholdSeconds = self.defaults.relayWindowBlinkThresholdSeconds
    end
    self.sv.relayWindowBlinkThresholdSeconds = zo_clamp(self.sv.relayWindowBlinkThresholdSeconds, 5, 300)
    if type(self.sv.relayWindowCheckIntervalSeconds) ~= "number" then
        self.sv.relayWindowCheckIntervalSeconds = self.defaults.relayWindowCheckIntervalSeconds
    end
    self.sv.relayWindowCheckIntervalSeconds = zo_clamp(self.sv.relayWindowCheckIntervalSeconds, 5, 60)
    if type(self.sv.relayWindowActiveShareMaxAgeSeconds) ~= "number" then
        self.sv.relayWindowActiveShareMaxAgeSeconds = self.defaults.relayWindowActiveShareMaxAgeSeconds
    end
    self.sv.relayWindowActiveShareMaxAgeSeconds = zo_clamp(self.sv.relayWindowActiveShareMaxAgeSeconds, 10, 300)
    if type(self.sv.relayWindowActiveEstimatedMaxAgeSeconds) ~= "number" then
        self.sv.relayWindowActiveEstimatedMaxAgeSeconds = self.defaults.relayWindowActiveEstimatedMaxAgeSeconds
    end
    self.sv.relayWindowActiveEstimatedMaxAgeSeconds = zo_clamp(self.sv.relayWindowActiveEstimatedMaxAgeSeconds, 30, 1800)
    if type(self.sv.relayWindowPosition) ~= "table" then
        self.sv.relayWindowPosition = {
            anchor = self.defaults.relayWindowPosition.anchor,
            x = self.defaults.relayWindowPosition.x,
            y = self.defaults.relayWindowPosition.y,
        }
    end
    if type(self.sv.relayWindowColors) ~= "table" then
        self.sv.relayWindowColors = {}
    end
    -- Preserve customized colors when migrating the legacy field names.
    if self.sv.relayWindowColors.nameText and not self.sv.relayWindowColors.zoneText then
        self.sv.relayWindowColors.zoneText = self.sv.relayWindowColors.nameText
        self.sv.relayWindowColors.nameText = nil
    end
    if self.sv.relayWindowColors.timeText and not self.sv.relayWindowColors.playerText then
        self.sv.relayWindowColors.playerText = self.sv.relayWindowColors.timeText
        self.sv.relayWindowColors.timeText = nil
    end
    for colorName, defaultColor in pairs(self.defaults.relayWindowColors) do
        if not self.sv.relayWindowColors[colorName] then
            self.sv.relayWindowColors[colorName] = {
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

    local relayModule = self:GetModule("relay")
    if relayModule and type(relayModule.Initialize) == "function" then
        relayModule:Initialize()
    end

    self:CreateUI()
    self:CreateSettings()

    if self.GuildRelayWindow and type(self.GuildRelayWindow.Initialize) == "function" then
        self.GuildRelayWindow:Initialize(self)
    end

    SLASH_COMMANDS["/dynet"] = function(text)
        self:HandleSlashCommand(text)
    end
    SLASH_COMMANDS["/dynamicencountertracker"] = SLASH_COMMANDS["/dynet"]

    self:RegisterRespawnDefaultsMigrationDialog()
    self:MaybeShowRespawnDefaultsMigrationDialog()

    if self.sv.enabled then
        self:EnableRuntime()
    else
        self:DisableRuntime()
    end
end
