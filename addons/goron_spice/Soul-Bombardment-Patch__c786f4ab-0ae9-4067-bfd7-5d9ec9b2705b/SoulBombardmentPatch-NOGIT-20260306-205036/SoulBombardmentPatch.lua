SoulBombardmentPatch = {}

SoulBombardmentPatch.name = "SoulBombardmentPatch"
SoulBombardmentPatch.savedVariableVersion = 1
SoulBombardmentPatch.blackGemFoundryZoneName = "Black Gem Foundry"
SoulBombardmentPatch.refractedSoulEssenceName = "Refracted Soul Essence"
SoulBombardmentPatch.soulEssenceBombardmentName = "Soul Essence Bombardment"
SoulBombardmentPatch.soulEssenceBombardmentAbilityId = 241689
SoulBombardmentPatch.soulEssenceBombardmentSignalAbilityIdList = { 241685, 241687 }
SoulBombardmentPatch.soulEssenceBombardmentSignalAbilityIds = {
    [241685] = true,
    [241687] = true,
}
SoulBombardmentPatch.soulBombardmentIncomingWarningText = "Soul Bombardment incoming..."
SoulBombardmentPatch.castDurationMs = 1000
SoulBombardmentPatch.barMaxWidth = 320
SoulBombardmentPatch.dangerStartProgress = 0.75
SoulBombardmentPatch.joystickNudgeStep = 8
SoulBombardmentPatch.joystickNudgeDeadzone = 0.45
SoulBombardmentPatch.joystickNudgeInitialDelayMs = 180
SoulBombardmentPatch.joystickNudgeRepeatMs = 70
SoulBombardmentPatch.joystickNudgePixelsPerSecond = 420
SoulBombardmentPatch.devDisplayNames = {
    ohmygoron = true,
    goron_spice = true,
}
SoulBombardmentPatch.startSoundId = "DUEL_START"

SoulBombardmentPatch.activeCast = nil
SoulBombardmentPatch.activeIncomingWarning = false
SoulBombardmentPatch.positionPreviewVisible = false
SoulBombardmentPatch.positionPreviewToken = 0
SoulBombardmentPatch.settingsPanel = nil
SoulBombardmentPatch.wasPlayerInCombat = false
SoulBombardmentPatch.joystickRepositioningEnabled = false
SoulBombardmentPatch.defaultSettings = {
    trackerEnabled = true,
    indicatorOffsetX = 0,
    indicatorOffsetY = -40,
    playStartSound = false,
    enableJoystickRepositioning = false,
}

function SoulBombardmentPatch.InitializeSavedVariables()
    SoulBombardmentPatch.savedVariables = ZO_SavedVars:NewAccountWide(
        "SoulBombardmentPatchSavedVariables",
        SoulBombardmentPatch.savedVariableVersion,
        nil,
        SoulBombardmentPatch.defaultSettings
    )
    SoulBombardmentPatch.trackerEnabled = SoulBombardmentPatch.savedVariables.trackerEnabled
    SoulBombardmentPatch.indicatorOffsetX = SoulBombardmentPatch.savedVariables.indicatorOffsetX
    SoulBombardmentPatch.indicatorOffsetY = SoulBombardmentPatch.savedVariables.indicatorOffsetY
    SoulBombardmentPatch.playStartSound = SoulBombardmentPatch.savedVariables.playStartSound
    SoulBombardmentPatch.joystickRepositioningEnabled = SoulBombardmentPatch.savedVariables.enableJoystickRepositioning == true
end

function SoulBombardmentPatch.GetTrackerModeText()
    local signalIds = SoulBombardmentPatch.soulEssenceBombardmentSignalAbilityIdList or {}
    if #signalIds == 0 then
        return string.format("Filtered (core=%d)", SoulBombardmentPatch.soulEssenceBombardmentAbilityId)
    end

    local parts = {}
    for _, abilityId in ipairs(signalIds) do
        table.insert(parts, tostring(abilityId))
    end
    return string.format(
        "Filtered (core=%d, signals=%s)",
        SoulBombardmentPatch.soulEssenceBombardmentAbilityId,
        table.concat(parts, ",")
    )
end

function SoulBombardmentPatch.IsDevAccount()
    local displayName = nil
    if type(GetDisplayName) == "function" then
        displayName = GetDisplayName()
    end
    if (displayName == nil or displayName == "") and type(GetUnitDisplayName) == "function" then
        displayName = GetUnitDisplayName("player")
    end
    if type(displayName) ~= "string" or displayName == "" then
        return false
    end

    local normalized = string.lower(displayName)
    normalized = string.gsub(normalized, "^@", "")
    return SoulBombardmentPatch.devDisplayNames[normalized] == true
end

function SoulBombardmentPatch.SetTrackerEnabled(enabled)
    SoulBombardmentPatch.trackerEnabled = enabled
    if SoulBombardmentPatch.savedVariables ~= nil then
        SoulBombardmentPatch.savedVariables.trackerEnabled = enabled
    end
    if not enabled then
        SoulBombardmentPatch.HideCastWindow()
    end
    d(string.format("Soul Bombardment Patch: tracker %s.", enabled and "enabled" or "disabled"))
end

function SoulBombardmentPatch.PrintCommandHelp()
    d("Soul Bombardment Patch commands:")
    d("/sbp on|off|status|settings|x <value>|y <value>|sound on|off|preview|defaults")
end

function SoulBombardmentPatch.ParseOnOff(value)
    local normalized = string.lower(zo_strtrim(tostring(value or "")))
    if normalized == "on" or normalized == "1" or normalized == "true" then
        return true
    end
    if normalized == "off" or normalized == "0" or normalized == "false" then
        return false
    end
    return nil
end

function SoulBombardmentPatch.ApplyDefaultSettings()
    SoulBombardmentPatch.SetTrackerEnabled(SoulBombardmentPatch.defaultSettings.trackerEnabled)
    SoulBombardmentPatch.SetIndicatorOffsetX(SoulBombardmentPatch.defaultSettings.indicatorOffsetX)
    SoulBombardmentPatch.SetIndicatorOffsetY(SoulBombardmentPatch.defaultSettings.indicatorOffsetY)
    SoulBombardmentPatch.SetPlayStartSound(SoulBombardmentPatch.defaultSettings.playStartSound)
    SoulBombardmentPatch.SetJoystickRepositioningEnabled(SoulBombardmentPatch.defaultSettings.enableJoystickRepositioning)
    d("Soul Bombardment Patch: restored default settings.")
end

function SoulBombardmentPatch.OnSlashCommand(args)
    local input = string.lower(zo_strtrim(args or ""))
    if input == "" or input == "help" then
        SoulBombardmentPatch.PrintCommandHelp()
        return
    end

    if input == "on" then
        SoulBombardmentPatch.SetTrackerEnabled(true)
        return
    end
    if input == "off" then
        SoulBombardmentPatch.SetTrackerEnabled(false)
        return
    end
    if input == "status" then
        d(string.format(
            "Soul Bombardment Patch: tracker=%s mode=%s x=%d y=%d sound=%s joystick=%s",
            SoulBombardmentPatch.trackerEnabled and "on" or "off",
            SoulBombardmentPatch.GetTrackerModeText(),
            SoulBombardmentPatch.indicatorOffsetX or 0,
            SoulBombardmentPatch.indicatorOffsetY or 0,
            SoulBombardmentPatch.playStartSound and "on" or "off",
            SoulBombardmentPatch.joystickRepositioningEnabled and "on" or "off"
        ))
        return
    end
    if input == "settings" then
        SoulBombardmentPatch.OpenSettingsPanel()
        return
    end
    if input == "preview" then
        SoulBombardmentPatch.ShowPositionPreview()
        SoulBombardmentPatch.ScheduleHidePositionPreview(2000)
        return
    end
    if input == "defaults" then
        SoulBombardmentPatch.ApplyDefaultSettings()
        SoulBombardmentPatch.RefreshSettingsPanel()
        return
    end

    local xValue = string.match(input, "^x%s+(-?%d+)$")
    if xValue ~= nil then
        SoulBombardmentPatch.SetIndicatorOffsetX(tonumber(xValue))
        SoulBombardmentPatch.RefreshSettingsPanel()
        return
    end

    local yValue = string.match(input, "^y%s+(-?%d+)$")
    if yValue ~= nil then
        SoulBombardmentPatch.SetIndicatorOffsetY(tonumber(yValue))
        SoulBombardmentPatch.RefreshSettingsPanel()
        return
    end

    local soundValue = string.match(input, "^sound%s+(%S+)$")
    if soundValue ~= nil then
        local enabled = SoulBombardmentPatch.ParseOnOff(soundValue)
        if enabled == nil then
            d("Soul Bombardment Patch: use /sbp sound on|off")
            return
        end
        SoulBombardmentPatch.SetPlayStartSound(enabled)
        SoulBombardmentPatch.RefreshSettingsPanel()
        d(string.format("Soul Bombardment Patch: start sound %s.", enabled and "enabled" or "disabled"))
        return
    end

    SoulBombardmentPatch.PrintCommandHelp()
end

function SoulBombardmentPatch.Initialize()
    SoulBombardmentPatch.InitializeSavedVariables()
    SoulBombardmentPatch.PrepareIndicatorForConsole()
    SoulBombardmentPatch.ConfigureBarZones()
    SoulBombardmentPatch.SetBarProgress(0)
    SoulBombardmentPatch.RegisterCombatEventHandlers()
    SoulBombardmentPatch.RegisterSettingsPanel()
    SoulBombardmentPatch.EnsureJoystickRepositionSceneHook()
    SoulBombardmentPatch.RefreshJoystickRepositionMode()

    SLASH_COMMANDS["/sbp"] = SoulBombardmentPatch.OnSlashCommand
    d("Soul Bombardment Patch: loaded.")
end

function SoulBombardmentPatch.OnAddOnLoaded(eventCode, addonName)
    if addonName ~= SoulBombardmentPatch.name then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(SoulBombardmentPatch.name, EVENT_ADD_ON_LOADED)
    SoulBombardmentPatch.Initialize()
end

EVENT_MANAGER:RegisterForEvent(
    SoulBombardmentPatch.name,
    EVENT_ADD_ON_LOADED,
    SoulBombardmentPatch.OnAddOnLoaded
)
