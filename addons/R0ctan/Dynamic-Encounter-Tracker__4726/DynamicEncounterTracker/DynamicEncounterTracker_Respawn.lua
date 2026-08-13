local DE = DynamicEncounterTracker

DE.RESPAWN_PHASE_COOLDOWN = "cooldown"
DE.RESPAWN_PHASE_WINDOW = "spawn-window"
DE.RESPAWN_PHASE_OVERDUE = "overdue"
DE.RESPAWN_MAX_SECONDS = (120 * 60) + 59
-- Increment when shipped respawn defaults change so existing profiles can migrate explicitly.
DE.RESPAWN_DEFAULTS_VERSION = 1

local function ClampSeconds(seconds)
    if type(seconds) ~= "number" then
        return nil
    end
    return zo_clamp(zo_floor(seconds + 0.5), 0, DE.RESPAWN_MAX_SECONDS)
end

function DE:GetEncounterConfigKey(config)
    if not config then
        return nil
    end
    if type(config.key) == "string" and config.key ~= "" then
        return config.key
    end
    return string.format(
        "zone%d_parent%d",
        tonumber(config.zoneId) or 0,
        tonumber(config.parentWorldEventInstanceId) or 0
    )
end

function DE:FormatRespawnTime(seconds)
    seconds = ClampSeconds(seconds)
    if seconds == nil then
        return "--:--"
    end

    local minutes = zo_floor(seconds / 60)
    local remainder = seconds % 60
    return string.format("%02d:%02d", minutes, remainder)
end

function DE:ParseRespawnTime(text)
    if type(text) ~= "string" then
        return nil
    end

    local trimmed = zo_strtrim(text)
    local minutesText, secondsText = string.match(trimmed, "^(%d+):(%d%d?)$")
    if not minutesText then
        return nil
    end

    local minutes = tonumber(minutesText)
    local seconds = tonumber(secondsText)
    if not minutes or not seconds or minutes > 120 or seconds > 59 then
        return nil
    end

    return ClampSeconds((minutes * 60) + seconds)
end

function DE:GetConfiguredRespawnTiming(config)
    local respawn = config and config.respawn or nil
    local expected = respawn and ClampSeconds(respawn.expectedSeconds) or nil
    local earliest = respawn and ClampSeconds(respawn.earliestSeconds) or nil

    -- Compatibility for older encounter configurations while project files are
    -- upgraded. New configurations must use the explicit two-stage table.
    if not expected and config then
        expected = ClampSeconds(config.respawnSeconds)
    end
    expected = expected or (30 * 60)
    earliest = earliest or zo_min(30 * 60, expected)
    expected = zo_max(earliest, expected)

    return earliest, expected
end

function DE:InitializeRespawnTimerSettings()
    self.sv.respawnTimerOverrides = type(self.sv.respawnTimerOverrides) == "table"
        and self.sv.respawnTimerOverrides
        or {}

    for key, override in pairs(self.sv.respawnTimerOverrides) do
        if type(key) ~= "string" or type(override) ~= "table" then
            self.sv.respawnTimerOverrides[key] = nil
        else
            local earliest = ClampSeconds(override.earliestSeconds)
            local expected = ClampSeconds(override.expectedSeconds)
            if earliest == nil or expected == nil then
                self.sv.respawnTimerOverrides[key] = nil
            else
                override.earliestSeconds = earliest
                override.expectedSeconds = zo_max(earliest, expected)
            end
        end
    end
end

function DE:GetRespawnTiming(config)
    local earliest, expected = self:GetConfiguredRespawnTiming(config)
    local key = self:GetEncounterConfigKey(config)
    local override = key and self.sv and self.sv.respawnTimerOverrides
        and self.sv.respawnTimerOverrides[key]
        or nil

    if type(override) == "table" then
        earliest = ClampSeconds(override.earliestSeconds) or earliest
        expected = ClampSeconds(override.expectedSeconds) or expected
    end

    expected = zo_max(earliest, expected)
    return {
        earliestSeconds = earliest,
        expectedSeconds = expected,
    }
end

function DE:SetRespawnTimerOverride(config, fieldName, seconds)
    if fieldName ~= "earliestSeconds" and fieldName ~= "expectedSeconds" then
        return false
    end

    seconds = ClampSeconds(seconds)
    local key = self:GetEncounterConfigKey(config)
    if not key or seconds == nil then
        return false
    end

    -- Validate table types because corrupted SavedVariables may contain non-nil scalars.
    if type(self.sv.respawnTimerOverrides) ~= "table" then
        self.sv.respawnTimerOverrides = {}
    end
    local timing = self:GetRespawnTiming(config)
    local override = self.sv.respawnTimerOverrides[key] or {
        earliestSeconds = timing.earliestSeconds,
        expectedSeconds = timing.expectedSeconds,
    }

    override[fieldName] = seconds
    if override.expectedSeconds < override.earliestSeconds then
        override.expectedSeconds = override.earliestSeconds
    end

    self.sv.respawnTimerOverrides[key] = override
    self:RecalculateActiveCooldown()
    return true
end

function DE:SetRespawnTimerOverrideFromText(config, fieldName, text)
    local seconds = self:ParseRespawnTime(text)
    if seconds == nil then
        return false
    end
    return self:SetRespawnTimerOverride(config, fieldName, seconds)
end

function DE:ResetRespawnTimerOverrides()
    self.sv.respawnTimerOverrides = {}
    self:RecalculateActiveCooldown()
end

-- Ask once per version because saved overrides would otherwise mask changed defaults forever.
function DE:MaybeShowRespawnDefaultsMigrationDialog()
    if (self.sv.respawnDefaultsAcknowledgedVersion or 0) >= self.RESPAWN_DEFAULTS_VERSION then
        return
    end

    local hasOverrides = false
    for _ in pairs(self.sv.respawnTimerOverrides or {}) do
        hasOverrides = true
        break
    end

    if not hasOverrides then
        -- Nothing to migrate, but still record the version as seen so this
        -- check stays a no-op on every future login too, not just this one.
        self.sv.respawnDefaultsAcknowledgedVersion = self.RESPAWN_DEFAULTS_VERSION
        return
    end

    ZO_Dialogs_ShowDialog("DE_RESPAWN_DEFAULTS_MIGRATION")
end

function DE:RegisterRespawnDefaultsMigrationDialog()
    ZO_Dialogs_RegisterCustomDialog("DE_RESPAWN_DEFAULTS_MIGRATION", {
        title = {
            text = DE:T("DE_RESPAWN_DEFAULTS_MIGRATION_TITLE"),
        },
        mainText = {
            text = DE:T("DE_RESPAWN_DEFAULTS_MIGRATION_TEXT"),
        },
        buttons = {
            [1] = {
                text = DE:T("DE_RESPAWN_DEFAULTS_MIGRATION_ACCEPT"),
                callback = function()
                    DE:ResetRespawnTimerOverrides()
                    DE.sv.respawnDefaultsAcknowledgedVersion = DE.RESPAWN_DEFAULTS_VERSION
                end,
            },
            [2] = {
                text = DE:T("DE_RESPAWN_DEFAULTS_MIGRATION_KEEP"),
                callback = function()
                    -- A deliberate keep decision still acknowledges this defaults version.
                    DE.sv.respawnDefaultsAcknowledgedVersion = DE.RESPAWN_DEFAULTS_VERSION
                end,
            },
        },
    })
end

function DE:RecalculateActiveCooldown()
    if self.state.status ~= self.STATUS_COOLDOWN
        or not self.state.cooldownStartedAt
        or not self.state.eventData then
        return false
    end

    local timing = self:GetRespawnTiming(self.state.eventData)
    self.state.earliestRespawnAt = self.state.cooldownStartedAt + timing.earliestSeconds
    self.state.respawnAt = self.state.cooldownStartedAt + timing.expectedSeconds

    local elapsedSinceCooldown = zo_max(0, GetTimeStamp() - self.state.cooldownStartedAt)
    local cooldownStartClockSeconds = (GetSecondsSinceMidnight() - elapsedSinceCooldown) % ZO_ONE_DAY_IN_SECONDS
    self.state.expectedClockSeconds = (cooldownStartClockSeconds + timing.expectedSeconds) % ZO_ONE_DAY_IN_SECONDS

    if self.sv.showRespawnTimer ~= false
        and (GetTimeStamp() < self.state.respawnAt or self.sv.showRespawnOverrun ~= false) then
        self:StartTimerUpdate()
    else
        self:StopTimerUpdate()
    end

    self:RefreshUI()
    return true
end

function DE:GetRespawnPhase(now)
    if self.state.status ~= self.STATUS_COOLDOWN or not self.state.respawnAt then
        return nil, nil
    end

    now = now or GetTimeStamp()
    local earliestAt = self.state.earliestRespawnAt or self.state.respawnAt
    if now < earliestAt then
        return self.RESPAWN_PHASE_COOLDOWN, self.state.respawnAt - now
    elseif now < self.state.respawnAt then
        return self.RESPAWN_PHASE_WINDOW, self.state.respawnAt - now
    end

    return self.RESPAWN_PHASE_OVERDUE, now - self.state.respawnAt
end

function DE:GetAllEncounterConfigsForSettings()
    local result = {}
    for _, configs in pairs(self.encountersByZoneId or {}) do
        for _, config in ipairs(configs) do
            result[#result + 1] = config
        end
    end

    table.sort(result, function(left, right)
        local leftOrder = tonumber(left.settingsOrder) or tonumber(left.zoneId) or 0
        local rightOrder = tonumber(right.settingsOrder) or tonumber(right.zoneId) or 0
        if leftOrder == rightOrder then
            return tostring(left.key or "") < tostring(right.key or "")
        end
        return leftOrder < rightOrder
    end)
    return result
end

function DE:GetEncounterConfigByRelayCode(relayCode)
    if type(relayCode) ~= "string" or relayCode == "" then
        return nil
    end

    for _, configs in pairs(self.encountersByZoneId or {}) do
        for _, config in ipairs(configs) do
            if config.relayCode == relayCode then
                return config
            end
        end
    end

    return nil
end
