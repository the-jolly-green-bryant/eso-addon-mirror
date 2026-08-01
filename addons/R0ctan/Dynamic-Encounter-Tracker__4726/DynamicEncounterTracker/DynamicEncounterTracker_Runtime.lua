local DE = DynamicEncounterTracker

local function WorldEventInstanceIterator(_, lastWorldEventInstanceId)
    return GetNextWorldEventInstanceId(lastWorldEventInstanceId)
end


function DE:UpdateCurrentZone(resetState)
    local previousZoneId = self.state.zoneId
    local zoneId, zoneName, configs = self:GetCurrentZoneData()
    local zoneChanged = zoneId ~= previousZoneId

    if zoneChanged and self.state.zoneRuntimeActive then
        self:DeactivateZoneRuntime("zone changed", true)
    end
    if zoneChanged and previousZoneId ~= 0 then
        self:ModuleHook("respawnMeasurement", "ResetMeasurementChain", string.format("zone changed: %d -> %d", previousZoneId, zoneId))
    end

    self.state.zoneId = zoneId
    self.state.zoneName = zoneName or ""
    self.state.zoneEncounterConfigs = configs

    if not configs then
        self.state.eventData = nil
        self.state.status = self.STATUS_UNSUPPORTED
        self.state.zoneRuntimeActive = false
        if self.window then
            self.window:SetHidden(true)
        end
        return false
    end

    if #configs == 1 and not self.state.eventData then
        self.state.eventData = configs[1]
    elseif self.state.eventData then
        local stillConfigured = false
        for _, config in ipairs(configs) do
            if config == self.state.eventData then
                stillConfigured = true
                break
            end
        end
        if not stillConfigured then
            self.state.eventData = #configs == 1 and configs[1] or nil
        end
    end

    if resetState or zoneChanged then
        local reason = zoneChanged and string.format("zone changed: %d -> %d", previousZoneId, zoneId) or "zone state reset"
        self:SetUnknownState(reason)
        if #configs == 1 then
            self.state.eventData = configs[1]
            self.state.status = self.STATUS_UNKNOWN
        end
    end

    if self:IsAddonRuntimeEnabled() and not self.state.zoneRuntimeActive then
        self:ActivateZoneRuntime()
    else
        self:RefreshUI()
    end
    return true
end

function DE:ScanActiveWorldEvents()
    if not self:IsZoneRuntimeEnabled() or not self.state.zoneEncounterConfigs then
        return false
    end

    local activeParents = {}
    local activeChildren = {}

    for worldEventInstanceId in WorldEventInstanceIterator do
        local config, role = self:FindEncounterConfigForInstance(worldEventInstanceId)
        if config and role == "parent" and not activeParents[config] then
            activeParents[config] = worldEventInstanceId
        elseif config and role == "child" and not activeChildren[config] then
            activeChildren[config] = worldEventInstanceId
        end
    end

    local selectedConfig = nil
    local activeChildInstanceId = nil
    if self.state.eventData and activeChildren[self.state.eventData] then
        selectedConfig = self.state.eventData
        activeChildInstanceId = activeChildren[selectedConfig]
    else
        for _, config in ipairs(self.state.zoneEncounterConfigs) do
            if activeChildren[config] then
                selectedConfig = config
                activeChildInstanceId = activeChildren[config]
                break
            end
        end
    end

    local now = GetTimeStamp()
    self.state.lastScanAt = now

    if selectedConfig and activeChildInstanceId then
        if self.state.eventData ~= selectedConfig and self.state.status == self.STATUS_ACTIVE then
            self:SetUnknownState("active encounter configuration changed")
        end
        self:SetActiveEncounterConfig(selectedConfig)
        self.state.parentActive = activeParents[selectedConfig] ~= nil
        self.state.noActiveSince = nil
        self:SetActiveState(activeChildInstanceId, "child", "api-scan", false)
        return true
    end

    local currentConfig = self.state.eventData
    local activeParentInstanceId = currentConfig and activeParents[currentConfig] or nil
    self.state.parentActive = activeParentInstanceId ~= nil

    if activeParentInstanceId then
        self.state.noActiveSince = nil
        if self.state.status == self.STATUS_ACTIVE then
            self:RefreshParticipatingPhase()
            self:RefreshMapLocationPhase()
            self:RecordDiagnosticSnapshot("api-scan-parent-transition")
            self:RefreshUI()
            return true
        end
        self:RecordDiagnosticSnapshot("api-scan-parent-only")
        return false
    end

    if self.state.status == self.STATUS_ACTIVE then
        if not self.state.noActiveSince then
            self.state.noActiveSince = now
            self:RecordDiagnosticSnapshot("api-scan-no-active-grace-start", true)
        end

        if (now - self.state.noActiveSince) < self.noActiveGraceSeconds then
            self:RefreshParticipatingPhase()
            self:RefreshMapLocationPhase()
            self:RefreshUI()
            return true
        end

        self:SetCooldownState(false, "api-scan-no-active-event-after-grace")
    end

    return false
end

function DE:OnPlayerDeactivated()
    if not self:IsAddonRuntimeEnabled() then
        return
    end

    if self.state.zoneRuntimeActive then
        self:DeactivateZoneRuntime("player deactivated / loading screen", true)
        self:ModuleHook("respawnMeasurement", "ResetMeasurementChain", "player deactivated / loading screen")
    end
end

function DE:OnPlayerActivated()
    if not self:IsAddonRuntimeEnabled() then
        return
    end

    self:UpdateCurrentZone(true)
    if self.state.zoneEncounterConfigs and not self.state.zoneRuntimeActive then
        self:ActivateZoneRuntime()
    end
end

function DE:OnZoneChanged()
    if not self:IsAddonRuntimeEnabled() then
        return
    end
    self:UpdateCurrentZone(false)
end

function DE:OnWorldEventsInitialized()
    if not self:IsZoneRuntimeEnabled() then
        return
    end

    self:ScanActiveWorldEvents()
end

function DE:OnWorldEventActivated(_, worldEventInstanceId)
    if not self:IsZoneRuntimeEnabled() then
        return
    end

    local config, role = self:FindEncounterConfigForInstance(worldEventInstanceId)
    if not config or not role then
        return
    end

    if role == "parent" then
        if self.state.eventData == config or not self.state.eventData then
            self:SetActiveEncounterConfig(config)
            self.state.parentActive = true
            self:RecordDiagnosticSnapshot("EVENT_WORLD_EVENT_ACTIVATED:parent")
        end
        return
    end

    if self.state.eventData ~= config and self.state.status == self.STATUS_ACTIVE then
        self:SetUnknownState("active encounter configuration changed")
    end
    self:SetActiveEncounterConfig(config)
    self.state.noActiveSince = nil
    self:SetActiveState(worldEventInstanceId, role, "EVENT_WORLD_EVENT_ACTIVATED", true)
end

function DE:OnWorldEventDeactivated(_, worldEventInstanceId)
    if not self:IsZoneRuntimeEnabled() then
        return
    end

    local config, role = self:FindEncounterConfigForInstance(worldEventInstanceId)
    if config and role == "parent" and self.state.eventData == config then
        self.state.parentActive = false
        self:SetCooldownState(true, "EVENT_WORLD_EVENT_DEACTIVATED")
    end
end

function DE:OnWorldEventStepChanged(_, worldEventInstanceId, stepDefId)
    if not self:IsZoneRuntimeEnabled() or self.state.status ~= self.STATUS_ACTIVE then
        return
    end
    local config = self:GetEncounterConfigForInstance(worldEventInstanceId)
    if not config or config ~= self.state.eventData then
        return
    end

    if stepDefId ~= 0 then
        self:ObserveWorldEventStep(worldEventInstanceId, stepDefId, "EVENT_WORLD_EVENT_STEP_CHANGED")
    end
    self:RefreshMapLocationPhase()
    self:RefreshUI()
end

function DE:OnWorldEventParticipationChanged()
    if not self:IsZoneRuntimeEnabled() or self.state.status ~= self.STATUS_ACTIVE then
        return
    end

    self:RefreshParticipatingPhase()
    self:RefreshMapLocationPhase()
    self:RefreshUI()
end

function DE:OnWorldEventStepProgressChanged(_, worldEventInstanceId, stepDefId, newCurrentProgress, newMaxProgress)
    if not self:IsZoneRuntimeEnabled() or self.state.status ~= self.STATUS_ACTIVE then
        return
    end
    local config = self:GetEncounterConfigForInstance(worldEventInstanceId)
    if not config or config ~= self.state.eventData then
        return
    end

    if stepDefId and stepDefId ~= 0 then
        self:ObserveWorldEventStep(worldEventInstanceId, stepDefId, "EVENT_WORLD_EVENT_STEP_PROGRESS_CHANGED")
    end

    local participatingInstanceId, participatingStepDefId = GetParticipatingWorldEventStep()
    local isParticipating = participatingInstanceId == worldEventInstanceId
        and participatingStepDefId == stepDefId
    self:SetProgressState(
        newCurrentProgress,
        newMaxProgress,
        "EVENT_WORLD_EVENT_STEP_PROGRESS_CHANGED",
        isParticipating,
        isParticipating and participatingInstanceId or nil,
        isParticipating and participatingStepDefId or nil
    )
    self:RefreshMapLocationPhase()
    self:RefreshUI()
end

function DE:OnPeriodicScan()
    if not self:IsZoneRuntimeEnabled() then
        self:StopPeriodicScan()
        return
    end

    self:ExpireChestHint()
    self:ScanActiveWorldEvents()
end

function DE:StartPeriodicScan()
    self:StopPeriodicScan()
    if not self:IsZoneRuntimeEnabled() then
        return
    end
    EVENT_MANAGER:RegisterForUpdate(self.scanUpdateName, self.scanIntervalMs, function()
        self:OnPeriodicScan()
    end)
end

function DE:StopPeriodicScan()
    EVENT_MANAGER:UnregisterForUpdate(self.scanUpdateName)
end

function DE:OnTimerUpdate()
    if not self:IsZoneRuntimeEnabled() then
        self:StopTimerUpdate()
        return
    end

    self:ExpireChestHint()
    if self.state.status ~= self.STATUS_COOLDOWN or not self.state.respawnAt then
        self:StopTimerUpdate()
        return
    end

    self:RefreshUI()
    if GetTimeStamp() >= self.state.respawnAt and self.sv.showRespawnOverrun == false then
        self:StopTimerUpdate()
    end
end

function DE:StartTimerUpdate()
    self:StopTimerUpdate()
    if not self:IsZoneRuntimeEnabled() then
        return
    end
    EVENT_MANAGER:RegisterForUpdate(self.updateName, 1000, function()
        self:OnTimerUpdate()
    end)
end

function DE:StopTimerUpdate()
    EVENT_MANAGER:UnregisterForUpdate(self.updateName)
end

function DE:RegisterBaseRuntimeEvents()
    if self.state.baseEventsRegistered then
        return
    end

    EVENT_MANAGER:RegisterForEvent(self.eventPrefix .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, function(...)
        self:OnPlayerActivated()
    end)
    EVENT_MANAGER:RegisterForEvent(self.eventPrefix .. "PlayerDeactivated", EVENT_PLAYER_DEACTIVATED, function(...)
        self:OnPlayerDeactivated()
    end)
    EVENT_MANAGER:RegisterForEvent(self.eventPrefix .. "ZoneChanged", EVENT_ZONE_CHANGED, function(...)
        self:OnZoneChanged()
    end)
    self.state.baseEventsRegistered = true
end

function DE:UnregisterBaseRuntimeEvents()
    if not self.state.baseEventsRegistered then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(self.eventPrefix .. "PlayerActivated", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(self.eventPrefix .. "PlayerDeactivated", EVENT_PLAYER_DEACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(self.eventPrefix .. "ZoneChanged", EVENT_ZONE_CHANGED)
    self.state.baseEventsRegistered = false
end

function DE:RegisterZoneRuntimeEvents()
    if self.state.zoneEventsRegistered then
        return
    end

    EVENT_MANAGER:RegisterForEvent(self.eventPrefix .. "WorldEventsInitialized", EVENT_WORLD_EVENTS_INITIALIZED, function(...)
        self:OnWorldEventsInitialized()
    end)
    EVENT_MANAGER:RegisterForEvent(self.eventPrefix .. "WorldEventActivated", EVENT_WORLD_EVENT_ACTIVATED, function(...)
        self:OnWorldEventActivated(...)
    end)
    EVENT_MANAGER:RegisterForEvent(self.eventPrefix .. "WorldEventDeactivated", EVENT_WORLD_EVENT_DEACTIVATED, function(...)
        self:OnWorldEventDeactivated(...)
    end)
    EVENT_MANAGER:RegisterForEvent(self.eventPrefix .. "WorldEventStepChanged", EVENT_WORLD_EVENT_STEP_CHANGED, function(...)
        self:OnWorldEventStepChanged(...)
    end)
    EVENT_MANAGER:RegisterForEvent(self.eventPrefix .. "WorldEventStepProgressChanged", EVENT_WORLD_EVENT_STEP_PROGRESS_CHANGED, function(...)
        self:OnWorldEventStepProgressChanged(...)
    end)
    EVENT_MANAGER:RegisterForEvent(self.eventPrefix .. "WorldEventParticipationBegin", EVENT_WORLD_EVENT_PARTICIPATION_BEGIN, function(...)
        self:OnWorldEventParticipationChanged()
    end)
    EVENT_MANAGER:RegisterForEvent(self.eventPrefix .. "WorldEventParticipationEnd", EVENT_WORLD_EVENT_PARTICIPATION_END, function(...)
        self:OnWorldEventParticipationChanged()
    end)
    self.state.zoneEventsRegistered = true
end

function DE:UnregisterZoneRuntimeEvents()
    if not self.state.zoneEventsRegistered then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(self.eventPrefix .. "WorldEventsInitialized", EVENT_WORLD_EVENTS_INITIALIZED)
    EVENT_MANAGER:UnregisterForEvent(self.eventPrefix .. "WorldEventActivated", EVENT_WORLD_EVENT_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(self.eventPrefix .. "WorldEventDeactivated", EVENT_WORLD_EVENT_DEACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(self.eventPrefix .. "WorldEventStepChanged", EVENT_WORLD_EVENT_STEP_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(self.eventPrefix .. "WorldEventStepProgressChanged", EVENT_WORLD_EVENT_STEP_PROGRESS_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(self.eventPrefix .. "WorldEventParticipationBegin", EVENT_WORLD_EVENT_PARTICIPATION_BEGIN)
    EVENT_MANAGER:UnregisterForEvent(self.eventPrefix .. "WorldEventParticipationEnd", EVENT_WORLD_EVENT_PARTICIPATION_END)
    self.state.zoneEventsRegistered = false
end

function DE:ActivateZoneRuntime()
    if not self:IsAddonRuntimeEnabled() or self.state.zoneRuntimeActive or not self.state.zoneEncounterConfigs then
        return false
    end

    self.state.zoneRuntimeActive = true
    if #self.state.zoneEncounterConfigs == 1 then
        self.state.eventData = self.state.zoneEncounterConfigs[1]
    end
    self:RegisterZoneRuntimeEvents()
    self:RegisterSceneCallback()
    self:ScanActiveWorldEvents()
    self:StartPeriodicScan()
    self:RefreshVisibility()
    return true
end

function DE:DeactivateZoneRuntime(reason, clearEncounterConfig)
    self:StopTimerUpdate()
    self:StopPeriodicScan()
    self:UnregisterZoneRuntimeEvents()
    self:UnregisterSceneCallback()
    self.state.zoneRuntimeActive = false

    self.state.status = self.state.zoneEncounterConfigs and self.STATUS_UNKNOWN or self.STATUS_UNSUPPORTED
    self.state.activeWorldEventInstanceId = nil
    self.state.activeWorldEventRole = nil
    self.state.parentActive = false
    self:ResetStepRun(reason or "zone runtime disabled")
    self.state.earliestRespawnAt = nil
    self.state.respawnAt = nil
    self.state.expectedClockSeconds = nil
    self.state.cooldownStartedAt = nil
    self.state.cooldownStartExact = nil
    self.state.cooldownSource = nil
    self.state.noActiveSince = nil
    self:ResetEncounterTransientState()
    if clearEncounterConfig then
        self.state.eventData = nil
    end
    if self.window then
        self.window:SetHidden(true)
    end
end

function DE:EnableRuntime()
    if self.state.runtimeEnabled then
        self:UpdateCurrentZone(true)
        return
    end

    self.state.runtimeEnabled = true
    self:ModuleHook("respawnMeasurement", "ResetMeasurementChain", "runtime enabled")
    self:RegisterBaseRuntimeEvents()
    self:UpdateCurrentZone(true)
    if self.state.zoneEncounterConfigs and not self.state.zoneRuntimeActive then
        self:ActivateZoneRuntime()
    end
end

function DE:DisableRuntime()
    self:DeactivateZoneRuntime("runtime disabled", true)
    self.state.runtimeEnabled = false
    self:UnregisterBaseRuntimeEvents()

    self.state.zoneEncounterConfigs = nil
    self.state.status = self.STATUS_UNKNOWN
    self.state.zoneId = 0
    self.state.zoneName = ""
    self.state.eventData = nil
    self.state.lastDiagnosticSignature = nil
    self:ModuleHook("respawnMeasurement", "ResetMeasurementChain", "runtime disabled")

    if self.centerAlertWindow then
        self:HideCenterChestAlert()
    end
    if self.window then
        self.window:SetHidden(true)
    end
end

function DE:SetEnabled(enabled)
    self.sv.enabled = enabled == true
    if self.sv.enabled then
        self:EnableRuntime()
    else
        self:DisableRuntime()
    end
end

function DE:SetDebugEnabled(enabled)
    self.sv.debugEnabled = enabled == true
    self.state.lastDiagnosticSignature = nil

    if self.sv.debugEnabled then
        if self:IsZoneRuntimeEnabled() and self.state.status == self.STATUS_ACTIVE and not self.state.stepRun then
            self:StartStepRun(false, "debugging enabled")
        end
    else
        self.state.stepRun = nil
    end

    self:RefreshUI()
end

function DE:HandleSlashCommand(text)
    local command = zo_strlower(zo_strtrim(text or ""))

    if command == "on" then
        self:SetEnabled(true)
        self:RefreshSettingsPanel()
        self:Print(self:T("DE_SLASH_ENABLED"))
        return
    end

    if not self.sv.enabled then
        return
    end

    if command == "off" then
        self:SetEnabled(false)
        self:RefreshSettingsPanel()
        self:Print(self:T("DE_SLASH_DISABLED"))
    elseif command == "show" then
        self.sv.showWindow = true
        self:RefreshVisibility()
    elseif command == "hide" then
        self.sv.showWindow = false
        self:RefreshVisibility()
    else
        local respawnMeasurementModule = self:GetModule("respawnMeasurement")
        if respawnMeasurementModule and type(respawnMeasurementModule.HandleSlashCommand) == "function"
            and respawnMeasurementModule:HandleSlashCommand(command) then
            return
        end

        local debugModule = self:GetModule("debug")
        if debugModule and type(debugModule.HandleSlashCommand) == "function"
            and debugModule:HandleSlashCommand(command) then
            return
        end
        self:Print(self:T("DE_SLASH_COMMANDS"))
        self:ModuleHook("respawnMeasurement", "PrintCommandHelp")
        self:ModuleHook("debug", "PrintCommandHelp")
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= DE.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(DE.name .. "_Loaded", EVENT_ADD_ON_LOADED)
    DE:Initialize()
end

EVENT_MANAGER:RegisterForEvent(DE.name .. "_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
