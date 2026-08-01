local ADDON_NAME = "ZoruahGamepadTuner"
local ADDON_TITLE = "Zoruah's Gamepad Tuner"
local OPTIONS_SHORTCUT_TITLE = "|cFF3333Zoruah|r's Tuner"
local AUTHOR = "Official Zoruah"
local VERSION = "2.0.0"
local SV_NAME = "ZoruahGamepadTunerSavedVariables"
local SV_VERSION = 1
local SETTINGS_BACKUP_LIMIT = 5
local MIN_GAMEPAD_OPTIONS_LIB_VERSION = 6

local PRESET_DEFAULT = "default"
local PRESET_LOW = "low"
local PRESET_MEDIUM = "medium"
local PRESET_HIGH = "high"
local PRESET_ADVANCED = "advanced"

local PROFILE_SCOPE_GLOBAL = "global"
local PROFILE_SCOPE_CHARACTER = "character"

local tuningKeys = {
    "advancedMode",
    "disableAimAssist",
    "reduceAcceleration",
    "oneToOneSensitivity",
    "sprintOneToOneSensitivity",
    "horizontalSensitivity",
    "sprintSensitivityMultiplier",
    "verticalSensitivity",
    "leftStickInnerDeadzone",
    "leftStickOuterThreshold",
    "rightStickInnerDeadzone",
    "rightStickOuterThreshold",
    "triggerDeadzone",
}

local settingsBackupKeys = {
    "presetMode",
    "showChatMessages",
}

for _, key in ipairs(tuningKeys) do
    settingsBackupKeys[#settingsBackupKeys + 1] = key
end

local presetSettings = {
    [PRESET_DEFAULT] = {
        disableAimAssist = false,
        reduceAcceleration = false,
        oneToOneSensitivity = false,
        sprintOneToOneSensitivity = false,
        horizontalSensitivity = 0.85,
        sprintSensitivityMultiplier = 1.00,
        verticalSensitivity = 0.85,
        leftStickInnerDeadzone = 0.25,
        leftStickOuterThreshold = 0.95,
        rightStickInnerDeadzone = 0.25,
        rightStickOuterThreshold = 0.95,
        triggerDeadzone = 0.50,
    },
    [PRESET_LOW] = {
        disableAimAssist = true,
        reduceAcceleration = true,
        oneToOneSensitivity = true,
        sprintOneToOneSensitivity = true,
        horizontalSensitivity = 0.75,
        sprintSensitivityMultiplier = 1.95,
        verticalSensitivity = 0.75,
        leftStickInnerDeadzone = 0.10,
        leftStickOuterThreshold = 0.80,
        rightStickInnerDeadzone = 0.10,
        rightStickOuterThreshold = 0.80,
        triggerDeadzone = 0.00,
    },
    [PRESET_MEDIUM] = {
        disableAimAssist = true,
        reduceAcceleration = true,
        oneToOneSensitivity = true,
        sprintOneToOneSensitivity = true,
        horizontalSensitivity = 1.25,
        sprintSensitivityMultiplier = 1.95,
        verticalSensitivity = 1.25,
        leftStickInnerDeadzone = 0.10,
        leftStickOuterThreshold = 0.80,
        rightStickInnerDeadzone = 0.10,
        rightStickOuterThreshold = 0.80,
        triggerDeadzone = 0.00,
    },
    [PRESET_HIGH] = {
        disableAimAssist = true,
        reduceAcceleration = true,
        oneToOneSensitivity = true,
        sprintOneToOneSensitivity = true,
        horizontalSensitivity = 2.25,
        sprintSensitivityMultiplier = 1.95,
        verticalSensitivity = 2.25,
        leftStickInnerDeadzone = 0.10,
        leftStickOuterThreshold = 0.80,
        rightStickInnerDeadzone = 0.10,
        rightStickOuterThreshold = 0.80,
        triggerDeadzone = 0.00,
    },
}

local defaults = {
    version = 4,
    profileScope = PROFILE_SCOPE_GLOBAL,
    presetMode = PRESET_DEFAULT,
    advancedMode = false,
    exportCode = "",
    importCode = "",
    settingsBackups = {},
    showChatMessages = false,
    socials = {
        youtube = "https://www.youtube.com/@OfficialZoruah",
        tiktok = "https://www.tiktok.com/@officialzoruah",
        twitch = "https://www.twitch.tv/officialzoruah",
        x = "https://x.com/OfficialZoruah",
        instagram = "https://www.instagram.com/officialzoruah/",
    },
}

for key, value in pairs(presetSettings[PRESET_DEFAULT]) do
    defaults[key] = value
end

local presetChoices = {
    "Default (ESO Default)",
    "Low (Zoruah's Tune)",
    "Medium (Zoruah's Tune)",
    "High (Zoruah's Tune)",
}

local presetChoiceValues = {
    PRESET_DEFAULT,
    PRESET_LOW,
    PRESET_MEDIUM,
    PRESET_HIGH,
}

local presetChoiceTooltips = {
    "Restores ESO-style baseline values for camera sensitivity, stick deadzones, trigger deadzone, aim assist, and smoothing.",
    "A clean low-speed tuned profile for controlled camera movement and safer stick response.",
    "A balanced tuned profile for PvE/PvP speed without making the sticks feel twitchy.",
    "A fast tuned profile for quick turns, target swaps, and high-action PvP.",
}

local presetToCode = {
    [PRESET_DEFAULT] = "0",
    [PRESET_LOW] = "1",
    [PRESET_MEDIUM] = "2",
    [PRESET_HIGH] = "3",
    [PRESET_ADVANCED] = "4",
}

local codeToPreset = {
    ["0"] = PRESET_DEFAULT,
    ["1"] = PRESET_LOW,
    ["2"] = PRESET_MEDIUM,
    ["3"] = PRESET_HIGH,
    ["4"] = PRESET_ADVANCED,
}

local scopeToCode = {
    [PROFILE_SCOPE_GLOBAL] = "0",
    [PROFILE_SCOPE_CHARACTER] = "1",
}

local codeToScope = {
    ["0"] = PROFILE_SCOPE_GLOBAL,
    ["1"] = PROFILE_SCOPE_CHARACTER,
}

local onOffChoices = {
    "Off",
    "On",
}

local onOffChoiceValues = {
    false,
    true,
}

local onOffControls = {}
local onOffControlCount = 0
local registeredPanelCallbacks = false
local keyboardOptionsShortcutRegistered = false
local gamepadOptionsRegistered = false
local keyboardMenu
local keyboardMenuFragment
local keyboardMenuCurrentPanel
local keyboardMenuControlIndex = 0
local keyboardMenuControls = {}
local keyboardMenuTabs = {}
local RefreshKeyboardTunerMenu
local SPRINT_SENSITIVITY_SLIDER_REFERENCE = ADDON_NAME .. "SprintSensitivitySlider"
local IMPORT_CODE_EDITBOX_REFERENCE = ADDON_NAME .. "ImportCodeEditBox"
local IMPORT_CODE_STATUS_REFERENCE = ADDON_NAME .. "ImportCodeStatus"
local IMPORT_APPLY_BUTTON_REFERENCE = ADDON_NAME .. "ImportApplyButton"
local SPRINT_ABILITY_ID = 973
local MOUNT_SPRINT_ABILITY_ID = 33439
local SPRINT_1TO1_MULTIPLIER = 1.95
local SPRINT_FALLBACK_WINDOW_MS = 1250
local SPRINT_MAX_BOOST_WINDOW_MS = 1600
local SPRINT_MONITOR_INTERVAL_MS = 100
local SPRINT_ACTION_BLOCK_MS = 350
local SPRINT_INTERACTION_BLOCK_MS = 650
local SPRINT_TRANSITION_BLOCK_MS = 1200
local SPRINT_MAX_BLOCK_WINDOW_MS = 1800

local accountSv
local characterSv
local sv
local sprintBoostActive = false
local sprintMonitorRunning = false
local sprintFallbackBoostUntilMs = 0
local sprintFallbackBoostStartedAtMs = 0
local sprintBoostBlockedUntilMs = 0
local sprintBoostBlockedStartedAtMs = 0
local sprintMonitorToken = 0
local lastStaminaPowerValue

local function Color(hex, text)
    return "|c" .. hex .. text .. "|r"
end

local function Header(text)
    return Color("FFD166", text)
end

local function Tooltip(title, body)
    return Color("88CCFF", title) .. "\n" .. Color("E6E6E6", body)
end

local function ClampNumber(value, fallback, minValue, maxValue)
    local numberValue = tonumber(value)
    if not numberValue then
        numberValue = fallback
    end

    if numberValue < minValue then
        return minValue
    end

    if numberValue > maxValue then
        return maxValue
    end

    return numberValue
end

local function RoundToStep(value, step)
    if not step or step <= 0 then
        return value
    end

    return math.floor((value / step) + 0.5) * step
end

local function ClampAndRound(value, fallback, minValue, maxValue, step)
    return RoundToStep(ClampNumber(value, fallback, minValue, maxValue), step)
end

local function FormatDecimal(value, decimals)
    return string.format("%." .. tostring(decimals or 2) .. "f", tonumber(value) or 0)
end

local function FormatMultiplier(value)
    return FormatDecimal(ClampNumber(value, defaults.sprintSensitivityMultiplier, 1.00, 10.00), 2) .. "x"
end

local function RoundNumber(value)
    return math.floor((tonumber(value) or 0) + 0.5)
end

local function Chat(message)
    if sv and sv.showChatMessages then
        d("|c88ccff" .. ADDON_TITLE .. ":|r " .. message)
    end
end

local function EnsureSavedVariableDefaults(savedVars, defaultValues)
    for key, value in pairs(defaultValues) do
        if type(value) == "table" then
            if type(savedVars[key]) ~= "table" then
                savedVars[key] = {}
            end
            EnsureSavedVariableDefaults(savedVars[key], value)
        elseif savedVars[key] == nil then
            savedVars[key] = value
        end
    end
end

local function CopyTuningValues(source, target)
    for _, key in ipairs(tuningKeys) do
        target[key] = source[key]
    end
end

local function CopySavedVariableValue(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, nestedValue in pairs(value) do
        copy[key] = CopySavedVariableValue(nestedValue)
    end

    return copy
end

local function CopySavedVariableProfile(source, target)
    if type(source) ~= "table" or type(target) ~= "table" then
        return
    end

    for key, value in pairs(source) do
        if key ~= "serverScopedProfileInitialized" then
            target[key] = CopySavedVariableValue(value)
        end
    end
end

local function MigrateAccountSavedVariablesToServer(legacyProfile, serverProfile)
    if serverProfile.serverScopedProfileInitialized == true then
        return
    end

    CopySavedVariableProfile(legacyProfile, serverProfile)
    serverProfile.serverScopedProfileInitialized = true
end

local function GetLegacyAccountSavedVariables()
    local root = _G[SV_NAME]
    local defaultProfile = root and root.Default
    local accountProfile = defaultProfile and defaultProfile[GetDisplayName()]
    return accountProfile and accountProfile["$AccountWide"] or nil
end

local function BuildSettingsBackup(profile, reason)
    local values = {}

    for _, key in ipairs(settingsBackupKeys) do
        values[key] = profile[key]
    end

    return {
        version = defaults.version,
        reason = reason or "apply",
        savedAt = GetTimeStamp(),
        values = values,
    }
end

local function BackupValuesEqual(left, right)
    if not (left and right) then
        return false
    end

    for _, key in ipairs(settingsBackupKeys) do
        if left[key] ~= right[key] then
            return false
        end
    end

    return true
end

local function BackupMatchesProfile(backup, profile)
    return backup and backup.values and BackupValuesEqual(backup.values, profile)
end

local function EnsureSettingsBackupList(profile)
    if type(profile.settingsBackups) ~= "table" then
        profile.settingsBackups = {}
    end

    return profile.settingsBackups
end

local function PushSettingsBackup(profile, reason)
    if not profile then
        return
    end

    local backups = EnsureSettingsBackupList(profile)
    local backup = BuildSettingsBackup(profile, reason)

    if backups[1] and BackupValuesEqual(backups[1].values, backup.values) then
        backups[1].savedAt = backup.savedAt
        backups[1].reason = backup.reason
        return
    end

    table.insert(backups, 1, backup)

    while #backups > SETTINGS_BACKUP_LIMIT do
        table.remove(backups)
    end
end

local function FindRestorableBackup(profile)
    if not profile or type(profile.settingsBackups) ~= "table" then
        return nil
    end

    for index, backup in ipairs(profile.settingsBackups) do
        if backup and backup.values and not BackupMatchesProfile(backup, profile) then
            return index, backup
        end
    end

    return nil
end

local function ApplyPresetToProfile(presetMode, profile)
    profile.presetMode = presetSettings[presetMode] and presetMode or PRESET_DEFAULT
    profile.advancedMode = false
end

local function NormalizeProfile(profile)
    profile.version = defaults.version
    if profile.presetMode == PRESET_ADVANCED then
        profile.advancedMode = true
        profile.presetMode = PRESET_DEFAULT
    end
    profile.presetMode = presetSettings[profile.presetMode] and profile.presetMode or PRESET_DEFAULT
    profile.advancedMode = profile.advancedMode == true
    profile.sprintOneToOneSensitivity = profile.sprintOneToOneSensitivity == true
    profile.profileScope = profile.profileScope == PROFILE_SCOPE_CHARACTER and PROFILE_SCOPE_CHARACTER or PROFILE_SCOPE_GLOBAL
    EnsureSettingsBackupList(profile)
    profile.horizontalSensitivity = ClampNumber(profile.horizontalSensitivity, defaults.horizontalSensitivity, 0.10, 3.00)
    profile.sprintSensitivityMultiplier = ClampAndRound(profile.sprintSensitivityMultiplier, defaults.sprintSensitivityMultiplier, 1.00, 10.00, 0.25)
    profile.verticalSensitivity = ClampNumber(profile.verticalSensitivity, defaults.verticalSensitivity, 0.10, 3.00)
    profile.leftStickInnerDeadzone = ClampNumber(profile.leftStickInnerDeadzone, defaults.leftStickInnerDeadzone, 0.05, 0.30)
    profile.leftStickOuterThreshold = ClampNumber(profile.leftStickOuterThreshold, defaults.leftStickOuterThreshold, 0.60, 1.00)
    profile.rightStickInnerDeadzone = ClampNumber(profile.rightStickInnerDeadzone, defaults.rightStickInnerDeadzone, 0.05, 0.30)
    profile.rightStickOuterThreshold = ClampNumber(profile.rightStickOuterThreshold, defaults.rightStickOuterThreshold, 0.60, 1.00)
    profile.triggerDeadzone = ClampNumber(profile.triggerDeadzone, defaults.triggerDeadzone, 0.00, 0.50)
end

local function InitializeProfile(profile)
    local shouldApplyDefaultPreset = profile.presetMode == nil
    local previousVersion = tonumber(profile.version) or 0
    EnsureSavedVariableDefaults(profile, defaults)

    if previousVersion < defaults.version and profile.showChatMessages == true then
        profile.showChatMessages = false
    end

    if shouldApplyDefaultPreset then
        ApplyPresetToProfile(PRESET_DEFAULT, profile)
    end

    NormalizeProfile(profile)
end

local function NormalizeSavedVariables()
    NormalizeProfile(sv)
end

local function SetActiveProfile(copyCurrentToCharacter)
    local previousProfile = sv
    local scope = accountSv.profileScope == PROFILE_SCOPE_CHARACTER and PROFILE_SCOPE_CHARACTER or PROFILE_SCOPE_GLOBAL

    if scope == PROFILE_SCOPE_CHARACTER then
        if copyCurrentToCharacter and not characterSv.profileInitialized and previousProfile then
            CopyTuningValues(previousProfile, characterSv)
            characterSv.presetMode = previousProfile.presetMode
            characterSv.importCode = previousProfile.importCode or ""
            characterSv.showChatMessages = previousProfile.showChatMessages
        end

        characterSv.profileInitialized = true
        sv = characterSv
    else
        sv = accountSv
    end

    NormalizeSavedVariables()
end

local function SetProfileScope(scope, copyCurrentToCharacter)
    accountSv.profileScope = scope == PROFILE_SCOPE_CHARACTER and PROFILE_SCOPE_CHARACTER or PROFILE_SCOPE_GLOBAL
    SetActiveProfile(copyCurrentToCharacter)
end

local function IsAdvancedMode()
    return sv and sv.advancedMode == true
end

local function IsPresetModeActive()
    return sv and not IsAdvancedMode()
end

local function MarkAdvancedForManualChange()
    if sv and not sv.advancedMode then
        sv.advancedMode = true
    end
end

local function TrySetSetting(settingType, settingId, value)
    return pcall(SetSetting, settingType, settingId, tostring(value))
end

local function TrySetCVar(cvarName, value)
    return pcall(SetCVar, cvarName, FormatDecimal(value, 8))
end

local function SetGamepadCameraSensitivityCVar(axis, value)
    if axis == "X" then
        local changed = false
        changed = TrySetCVar("GamepadSensitivityFirstPersonX", value) or changed
        changed = TrySetCVar("GamepadSensitivityThirdPersonX", value) or changed
        changed = TrySetCVar("GamepadSensitivityFirstPerson.2", value) or changed
        changed = TrySetCVar("GamepadSensitivityThirdPerson.2", value) or changed
        return changed
    end

    local changed = false
    changed = TrySetCVar("GamepadSensitivityFirstPersonY", value) or changed
    changed = TrySetCVar("GamepadSensitivityThirdPersonY", value) or changed
    return changed
end

local function TryGetSetting(settingType, settingId)
    local ok, value = pcall(GetSetting, settingType, settingId)
    if ok then
        return value
    end

    return nil
end

local function CaptureOriginalSetting(saveKey, settingType, settingId)
    if sv[saveKey] == nil then
        sv[saveKey] = TryGetSetting(settingType, settingId)
    end
end

local function RestoreOrSkipSetting(saveKey, settingType, settingId)
    if sv[saveKey] ~= nil then
        return TrySetSetting(settingType, settingId, sv[saveKey])
    end

    return false
end

local function GetNowMilliseconds()
    return GetGameTimeMilliseconds()
end

local function GetEffectiveTuningValue(key)
    if IsAdvancedMode() then
        return sv[key]
    end

    local preset = presetSettings[sv.presetMode] or presetSettings[PRESET_DEFAULT]
    if preset and preset[key] ~= nil then
        return preset[key]
    end

    return sv[key]
end

local function IsEffectiveTuningEnabled(key)
    return GetEffectiveTuningValue(key) == true
end

local function SetAimAssistDisabled()
    local changed = false

    if IsEffectiveTuningEnabled("disableAimAssist") then
        CaptureOriginalSetting("originalGamepadAimAssistIntensity", SETTING_TYPE_ACCESSIBILITY, ACCESSIBILITY_SETTING_GAMEPAD_AIM_ASSIST_INTENSITY)
        CaptureOriginalSetting("originalMouseAimAssistIntensity", SETTING_TYPE_ACCESSIBILITY, ACCESSIBILITY_SETTING_MOUSE_AIM_ASSIST_INTENSITY)
        changed = TrySetSetting(SETTING_TYPE_ACCESSIBILITY, ACCESSIBILITY_SETTING_GAMEPAD_AIM_ASSIST_INTENSITY, 0) or changed
        changed = TrySetSetting(SETTING_TYPE_ACCESSIBILITY, ACCESSIBILITY_SETTING_MOUSE_AIM_ASSIST_INTENSITY, 0) or changed
    else
        changed = RestoreOrSkipSetting("originalGamepadAimAssistIntensity", SETTING_TYPE_ACCESSIBILITY, ACCESSIBILITY_SETTING_GAMEPAD_AIM_ASSIST_INTENSITY) or changed
        changed = RestoreOrSkipSetting("originalMouseAimAssistIntensity", SETTING_TYPE_ACCESSIBILITY, ACCESSIBILITY_SETTING_MOUSE_AIM_ASSIST_INTENSITY) or changed
    end

    return changed
end

local function SetStickResponse()
    local changed = false
    changed = TrySetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_DEADZONE_INNER_LEFT_STICK, GetEffectiveTuningValue("leftStickInnerDeadzone")) or changed
    changed = TrySetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_DEADZONE_OUTER_LEFT_STICK, GetEffectiveTuningValue("leftStickOuterThreshold")) or changed
    changed = TrySetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_DEADZONE_INNER_RIGHT_STICK, GetEffectiveTuningValue("rightStickInnerDeadzone")) or changed
    changed = TrySetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_DEADZONE_OUTER_RIGHT_STICK, GetEffectiveTuningValue("rightStickOuterThreshold")) or changed
    changed = TrySetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_DEADZONE_TRIGGERS, GetEffectiveTuningValue("triggerDeadzone")) or changed

    if IsEffectiveTuningEnabled("reduceAcceleration") then
        CaptureOriginalSetting("originalCameraSmoothing", SETTING_TYPE_CAMERA, CAMERA_SETTING_SMOOTHING)
        changed = TrySetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_SMOOTHING, 0) or changed
    else
        changed = RestoreOrSkipSetting("originalCameraSmoothing", SETTING_TYPE_CAMERA, CAMERA_SETTING_SMOOTHING) or changed
    end

    return changed
end

local function GetEffectiveVerticalSensitivity()
    if IsEffectiveTuningEnabled("oneToOneSensitivity") then
        return GetEffectiveTuningValue("horizontalSensitivity")
    end

    return GetEffectiveTuningValue("verticalSensitivity")
end

local function GetEffectiveSprintSensitivityMultiplier()
    if IsEffectiveTuningEnabled("sprintOneToOneSensitivity") then
        return SPRINT_1TO1_MULTIPLIER
    end

    return GetEffectiveTuningValue("sprintSensitivityMultiplier")
end

local function GetEffectiveHorizontalSensitivity()
    local horizontal = GetEffectiveTuningValue("horizontalSensitivity")

    if sprintBoostActive then
        horizontal = horizontal * GetEffectiveSprintSensitivityMultiplier()
    end

    return ClampNumber(horizontal, GetEffectiveTuningValue("horizontalSensitivity"), 0.10, 30.00)
end

local function SetCameraSensitivity()
    local horizontal = GetEffectiveHorizontalSensitivity()
    local vertical = GetEffectiveVerticalSensitivity()
    local changed = false
    changed = TrySetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_CAMERA_SENSITIVITY_X, horizontal) or changed
    changed = TrySetSetting(SETTING_TYPE_GAMEPAD, GAMEPAD_SETTING_CAMERA_SENSITIVITY_Y, vertical) or changed
    changed = SetGamepadCameraSensitivityCVar("X", horizontal) or changed
    changed = SetGamepadCameraSensitivityCVar("Y", vertical) or changed
    return changed
end

local function IsPlayerMounted()
    return IsMounted() == true
end

local function IsTryingToMove()
    return IsPlayerTryingToMove() == true
end

local function IsGameCameraInUIMode()
    return IsGameCameraUIModeActive() == true
end

local function IsSprintBoostBlocked()
    if sprintBoostBlockedUntilMs <= 0 then
        return false
    end

    local now = GetNowMilliseconds()
    local blockAge = now - sprintBoostBlockedStartedAtMs
    if blockAge < 0 or blockAge > SPRINT_MAX_BLOCK_WINDOW_MS then
        sprintBoostBlockedUntilMs = 0
        sprintBoostBlockedStartedAtMs = 0
        return false
    end

    if now >= sprintBoostBlockedUntilMs then
        sprintBoostBlockedUntilMs = 0
        sprintBoostBlockedStartedAtMs = 0
        return false
    end

    return true
end

local function CanApplySprintSensitivityBoost()
    return sv
        and GetEffectiveSprintSensitivityMultiplier() > 1
        and not IsPlayerMounted()
        and not IsGameCameraInUIMode()
        and not IsSprintBoostBlocked()
        and IsTryingToMove()
end

local function SetSprintBoostActive(active)
    active = active == true and CanApplySprintSensitivityBoost()

    if sprintBoostActive ~= active then
        sprintBoostActive = active
        SetCameraSensitivity()
    end

    return sprintBoostActive
end

local function ClearSprintSensitivityBoost()
    sprintFallbackBoostUntilMs = 0
    sprintFallbackBoostStartedAtMs = 0
    sprintMonitorRunning = false
    sprintMonitorToken = sprintMonitorToken + 1
    SetSprintBoostActive(false)
end

local function BlockSprintSensitivityBoost(durationMs)
    ClearSprintSensitivityBoost()

    local now = GetNowMilliseconds()
    sprintBoostBlockedStartedAtMs = now
    sprintBoostBlockedUntilMs = now + (durationMs or SPRINT_INTERACTION_BLOCK_MS)
end

local function ScheduleSprintSensitivityClear(delayMs)
    zo_callLater(ClearSprintSensitivityBoost, delayMs or 100)
end

local function UpdateSprintSensitivity()
    if not sv then
        return false
    end

    local sprintMultiplier = GetEffectiveSprintSensitivityMultiplier()
    local now = GetNowMilliseconds()

    if sprintMultiplier <= 1 or IsPlayerMounted() or IsGameCameraInUIMode() or IsSprintBoostBlocked() then
        ClearSprintSensitivityBoost()
        return false
    end

    if sprintFallbackBoostStartedAtMs > 0 then
        local boostAge = now - sprintFallbackBoostStartedAtMs
        if boostAge < 0 or boostAge > SPRINT_MAX_BOOST_WINDOW_MS then
            ClearSprintSensitivityBoost()
            return false
        end
    end

    local shouldBoost = now < sprintFallbackBoostUntilMs and IsTryingToMove()
    SetSprintBoostActive(shouldBoost)

    return shouldBoost
end

local function MonitorSprintSensitivity(token)
    if token ~= sprintMonitorToken then
        return
    end

    local shouldBoost = UpdateSprintSensitivity()

    if not sv or GetEffectiveSprintSensitivityMultiplier() <= 1 then
        sprintMonitorRunning = false
        return
    end

    if not shouldBoost and GetNowMilliseconds() >= sprintFallbackBoostUntilMs then
        ClearSprintSensitivityBoost()
        sprintMonitorRunning = false
        return
    end

    if not shouldBoost and not IsTryingToMove() then
        ClearSprintSensitivityBoost()
        sprintMonitorRunning = false
        return
    end

    zo_callLater(function() MonitorSprintSensitivity(token) end, SPRINT_MONITOR_INTERVAL_MS)
end

local function StartSprintSensitivityMonitor(boostWindowMs)
    if not CanApplySprintSensitivityBoost() then
        ClearSprintSensitivityBoost()
        return
    end

    if boostWindowMs and boostWindowMs > 0 then
        local now = GetNowMilliseconds()
        local boostUntilMs = now + boostWindowMs
        if boostUntilMs > sprintFallbackBoostUntilMs then
            sprintFallbackBoostUntilMs = boostUntilMs
            sprintFallbackBoostStartedAtMs = now
        end
    end

    if sprintMonitorRunning then
        UpdateSprintSensitivity()
        return
    end

    sprintMonitorRunning = true
    sprintMonitorToken = sprintMonitorToken + 1
    MonitorSprintSensitivity(sprintMonitorToken)
end

local function RefreshStaminaPowerBaseline()
    lastStaminaPowerValue = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_STAMINA)
end

local function ResetSprintSensitivityState(blockMs)
    local durationMs = blockMs or SPRINT_INTERACTION_BLOCK_MS
    BlockSprintSensitivityBoost(durationMs)
    RefreshStaminaPowerBaseline()
    ScheduleSprintSensitivityClear(100)
    if durationMs > 500 then
        ScheduleSprintSensitivityClear(500)
    end
end

local function OnSprintPowerUpdate(_, _, _, _, powerValue)
    if not sv then
        return
    end

    if lastStaminaPowerValue == nil then
        lastStaminaPowerValue = powerValue
        return
    end

    local powerValueChange = powerValue - lastStaminaPowerValue
    lastStaminaPowerValue = powerValue

    if powerValueChange < 0 and powerValueChange > -100 and CanApplySprintSensitivityBoost() then
        StartSprintSensitivityMonitor(SPRINT_FALLBACK_WINDOW_MS)
    end
end

local function StartSprintSensitivityPolling()
    if sprintMonitorRunning or not CanApplySprintSensitivityBoost() then
        return
    end

    sprintMonitorRunning = true
    sprintMonitorToken = sprintMonitorToken + 1
    MonitorSprintSensitivity(sprintMonitorToken)
end

local RefreshOnOffTextColorsSoon

local function ApplySettings(silent)
    NormalizeSavedVariables()
    PushSettingsBackup(sv, "apply")

    local changed = false
    changed = SetAimAssistDisabled() or changed
    changed = SetStickResponse() or changed
    changed = SetCameraSensitivity() or changed
    StartSprintSensitivityPolling()

    if not silent then
        if changed then
            Chat("settings applied")
        else
            Chat("ESO did not expose one or more requested settings to add-ons")
        end
    end
end

local function HasRestorableSettingsBackup()
    return FindRestorableBackup(sv) ~= nil
end

local function CreateSettingsBackup()
    if not sv then
        return
    end

    PushSettingsBackup(sv, "manual")
    Chat("created settings backup")

    if RefreshOnOffTextColorsSoon then
        RefreshOnOffTextColorsSoon()
    end
end

local function RestoreSettingsBackup()
    local index, backup = FindRestorableBackup(sv)
    if not backup then
        Chat("no settings backup available")
        return
    end

    PushSettingsBackup(sv, "before restore")

    for _, key in ipairs(settingsBackupKeys) do
        if backup.values[key] ~= nil then
            sv[key] = backup.values[key]
        end
    end

    NormalizeSavedVariables()
    Chat("restored settings backup #" .. tostring(index))
    ApplySettings(false)
    RefreshOnOffTextColorsSoon()
end

local applyQueued = false
local queuedApplySilent = true

local function ApplySettingsSoon(silent)
    if silent == false then
        queuedApplySilent = false
    end

    if applyQueued then
        return
    end

    applyQueued = true
    zo_callLater(function()
        local silentMode = queuedApplySilent
        applyQueued = false
        queuedApplySilent = true
        ApplySettings(silentMode)
    end, 50)
end

local function SetAdvancedMode(value)
    value = value == true

    if value and not IsAdvancedMode() then
        for _, key in ipairs(tuningKeys) do
            if key ~= "advancedMode" then
                sv[key] = GetEffectiveTuningValue(key)
            end
        end
    end

    sv.advancedMode = value
    ApplySettingsSoon(false)
    StartSprintSensitivityPolling()
    RefreshOnOffTextColorsSoon()
end

local function ApplyAllSettings()
    ApplySettings(false)
end

local function ApplyPresetMode(presetMode)
    ApplyPresetToProfile(presetMode, sv)
    NormalizeSavedVariables()
    ApplySettingsSoon(false)
    RefreshOnOffTextColorsSoon()
end

local function TryCopyToClipboard(text)
    return false
end

local function TryReadClipboard()
    return nil
end

local base36Digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

local function ToBase36(value, width)
    local numberValue = math.max(0, math.floor((tonumber(value) or 0) + 0.5))
    local encoded = ""

    repeat
        local digit = (numberValue % 36) + 1
        encoded = string.sub(base36Digits, digit, digit) .. encoded
        numberValue = math.floor(numberValue / 36)
    until numberValue == 0

    while #encoded < width do
        encoded = "0" .. encoded
    end

    return encoded
end

local function FromBase36(value)
    local numberValue = 0
    value = string.upper(tostring(value or ""))

    for index = 1, #value do
        local char = string.sub(value, index, index)
        local position = string.find(base36Digits, char, 1, true)
        if not position then
            return nil
        end
        numberValue = (numberValue * 36) + position - 1
    end

    return numberValue
end

local function Checksum(payload)
    local total = 0

    for index = 1, #payload do
        total = total + string.byte(payload, index)
    end

    return ToBase36(total % 1296, 2)
end

local function FormatExportCode(body)
    local raw = "ZGT1" .. body
    local groups = {}

    for index = 1, #raw, 4 do
        groups[#groups + 1] = string.sub(raw, index, index + 3)
    end

    return table.concat(groups, "-")
end

local function GenerateExportCode()
    if not sv then
        return ""
    end

    NormalizeSavedVariables()

    local flags = 0
    flags = IsEffectiveTuningEnabled("disableAimAssist") and flags + 1 or flags
    flags = IsEffectiveTuningEnabled("reduceAcceleration") and flags + 2 or flags
    flags = IsEffectiveTuningEnabled("oneToOneSensitivity") and flags + 4 or flags
    flags = sv.advancedMode and flags + 8 or flags
    flags = IsEffectiveTuningEnabled("sprintOneToOneSensitivity") and flags + 16 or flags

    local payload = table.concat({
        presetToCode[sv.presetMode] or presetToCode[PRESET_DEFAULT],
        scopeToCode[accountSv.profileScope] or scopeToCode[PROFILE_SCOPE_GLOBAL],
        ToBase36(flags, 1),
        ToBase36(RoundNumber(GetEffectiveTuningValue("horizontalSensitivity") * 100), 2),
        ToBase36(RoundNumber(GetEffectiveTuningValue("verticalSensitivity") * 100), 2),
        ToBase36(RoundNumber(GetEffectiveTuningValue("leftStickInnerDeadzone") * 100), 2),
        ToBase36(RoundNumber(GetEffectiveTuningValue("leftStickOuterThreshold") * 100), 2),
        ToBase36(RoundNumber(GetEffectiveTuningValue("rightStickInnerDeadzone") * 100), 2),
        ToBase36(RoundNumber(GetEffectiveTuningValue("rightStickOuterThreshold") * 100), 2),
        ToBase36(RoundNumber(GetEffectiveTuningValue("triggerDeadzone") * 100), 2),
        ToBase36(RoundNumber(GetEffectiveTuningValue("sprintSensitivityMultiplier") * 100), 2),
    }, "")

    return FormatExportCode(payload .. Checksum(payload))
end

local function GetExportCode()
    if not sv then
        return ""
    end

    sv.exportCode = GenerateExportCode()
    return sv.exportCode
end

local function ExportSettingsCode()
    local code = GenerateExportCode()
    sv.exportCode = code

    if TryCopyToClipboard(code) then
        Chat("export code copied to clipboard")
    else
        Chat("export code ready: " .. code)
        Chat("ESO blocks direct clipboard copy for add-ons; keyboard users can copy the Export code field")
    end
end

local function DecodeExportCode(code)
    local normalized = string.upper(tostring(code or "")):gsub("[^A-Z0-9]", "")
    if string.sub(normalized, 1, 4) ~= "ZGT1" then
        return nil, "That code does not start with ZGT1."
    end

    local body = string.sub(normalized, 5)
    if #body ~= 19 and #body ~= 21 then
        return nil, "That code has the wrong length."
    end

    local payloadLength = #body - 2
    local payload = string.sub(body, 1, payloadLength)
    local expectedChecksum = string.sub(body, payloadLength + 1)
    if Checksum(payload) ~= expectedChecksum then
        return nil, "That code did not pass the checksum."
    end

    local presetMode = codeToPreset[string.sub(payload, 1, 1)]
    local profileScope = codeToScope[string.sub(payload, 2, 2)]
    local flags = FromBase36(string.sub(payload, 3, 3))
    local horizontal = FromBase36(string.sub(payload, 4, 5))
    local vertical = FromBase36(string.sub(payload, 6, 7))
    local leftInner = FromBase36(string.sub(payload, 8, 9))
    local leftOuter = FromBase36(string.sub(payload, 10, 11))
    local rightInner = FromBase36(string.sub(payload, 12, 13))
    local rightOuter = FromBase36(string.sub(payload, 14, 15))
    local trigger = FromBase36(string.sub(payload, 16, 17))
    local sprintMultiplier = payloadLength >= 19 and FromBase36(string.sub(payload, 18, 19)) or 100

    if not (presetMode and profileScope and flags and horizontal and vertical and leftInner and leftOuter and rightInner and rightOuter and trigger and sprintMultiplier) then
        return nil, "That code contains an unknown value."
    end

    return {
        presetMode = presetMode,
        profileScope = profileScope,
        advancedMode = (math.floor(flags / 8) % 2) >= 1,
        sprintOneToOneSensitivity = (math.floor(flags / 16) % 2) >= 1,
        disableAimAssist = (flags % 2) >= 1,
        reduceAcceleration = (math.floor(flags / 2) % 2) >= 1,
        oneToOneSensitivity = (math.floor(flags / 4) % 2) >= 1,
        horizontalSensitivity = horizontal / 100,
        verticalSensitivity = vertical / 100,
        leftStickInnerDeadzone = leftInner / 100,
        leftStickOuterThreshold = leftOuter / 100,
        rightStickInnerDeadzone = rightInner / 100,
        rightStickOuterThreshold = rightOuter / 100,
        triggerDeadzone = trigger / 100,
        sprintSensitivityMultiplier = sprintMultiplier / 100,
    }
end

local function GetImportCodeValidationState(code)
    local text = tostring(code or "")

    if text == "" then
        return nil, "Waiting for import code", { 0.72, 0.72, 0.72, 1 }
    end

    local imported = DecodeExportCode(text)
    if imported then
        return true, "Valid code", { 0.45, 1.00, 0.45, 1 }
    end

    return false, "Invalid code", { 1.00, 0.36, 0.36, 1 }
end

local function IsImportCodeValid(code)
    local valid = GetImportCodeValidationState(code)
    return valid == true
end

local function GetImportCodeValidationText()
    local _, text = GetImportCodeValidationState(sv and sv.importCode or "")
    return text
end

local function SetLabelColorFromTable(label, color)
    if label and color then
        label:SetColor(color[1], color[2], color[3], color[4])
    end
end

local function UpdateImportValidationLabel(label, code)
    if not label then
        return
    end

    local _, text, color = GetImportCodeValidationState(code)
    label:SetText(text)
    SetLabelColorFromTable(label, color)
end

local function RefreshImportValidationControls(code)
    code = code or (sv and sv.importCode) or ""

    if keyboardMenu and keyboardMenu.importStatusLabel then
        UpdateImportValidationLabel(keyboardMenu.importStatusLabel, code)
    end

    local statusControl = _G[IMPORT_CODE_STATUS_REFERENCE]
    if statusControl and statusControl.desc then
        UpdateImportValidationLabel(statusControl.desc, code)
    end

    local importControl = _G[IMPORT_CODE_EDITBOX_REFERENCE]
    if importControl and importControl.editbox and not importControl.zgtImportValidationHooked then
        importControl.zgtImportValidationHooked = true
        importControl.editbox:SetHandler("OnTextChanged", function(self)
            sv.importCode = self:GetText()
            RefreshImportValidationControls(sv.importCode)
        end)
    end

    if keyboardMenu and keyboardMenu.importApplyButtonRow and keyboardMenu.importApplyButtonRow.Refresh then
        keyboardMenu.importApplyButtonRow:Refresh()
    end

    local applyControl = _G[IMPORT_APPLY_BUTTON_REFERENCE]
    if applyControl and applyControl.UpdateDisabled then
        applyControl:UpdateDisabled()
    end
end

local function ImportSettingsCode(code)
    if code == nil or tostring(code) == "" then
        code = TryReadClipboard()
    end

    local imported, errorMessage = DecodeExportCode(code)
    if not imported then
        sv.importCode = tostring(code or "")
        RefreshImportValidationControls(sv.importCode)
        Chat("import failed: " .. errorMessage)
        return false
    end

    SetProfileScope(imported.profileScope, true)

    for _, key in ipairs(tuningKeys) do
        sv[key] = imported[key]
    end
    sv.presetMode = imported.presetMode
    sv.importCode = code

    NormalizeSavedVariables()
    RefreshImportValidationControls(sv.importCode)
    Chat("imported share code")
    ApplySettings(true)
    return true
end

local function OpenUrl(url)
    if url and url ~= "" then
        RequestOpenUnsafeURL(url)
    else
        Chat("no URL set for this social link")
    end
end

local function SocialUrl(name)
    return defaults.socials[name] or ""
end

local function SetOnOffTextColor(control, isOn)
    if not (control and control.label) then
        return
    end

    if isOn then
        control.label:SetColor(1, 1, 1, 1)
    else
        control.label:SetColor(0.55, 0.55, 0.55, 1)
    end
end

local function RefreshOnOffTextColors()
    for _, controlData in ipairs(onOffControls) do
        local control = _G[controlData.reference]
        if control then
            SetOnOffTextColor(control, controlData.getFunc() and true or false)
        end
    end
end

local function RefreshSprintSensitivitySlider()
    local control = _G[SPRINT_SENSITIVITY_SLIDER_REFERENCE]
    if not (control and sv) then
        return
    end

    local manualValue = ClampAndRound(GetEffectiveTuningValue("sprintSensitivityMultiplier"), defaults.sprintSensitivityMultiplier, 1.00, 10.00, 0.25)
    local activeValue = GetEffectiveSprintSensitivityMultiplier()
    if control.label then
        if IsEffectiveTuningEnabled("sprintOneToOneSensitivity") then
            control.label:SetText("Sprint sensitivity (" .. FormatMultiplier(activeValue) .. " 1:1)")
        else
            control.label:SetText("Sprint sensitivity (" .. FormatMultiplier(manualValue) .. ")")
        end
    end

    if control.slider then
        control.slider:SetValue(IsEffectiveTuningEnabled("sprintOneToOneSensitivity") and activeValue or manualValue)
    end

    if control.slidervalue then
        control.slidervalue:SetText(FormatDecimal(IsEffectiveTuningEnabled("sprintOneToOneSensitivity") and activeValue or manualValue, 2))
    end
end

function RefreshOnOffTextColorsSoon()
    RefreshOnOffTextColors()
    RefreshSprintSensitivitySlider()
    RefreshImportValidationControls()
    if RefreshKeyboardTunerMenu then
        RefreshKeyboardTunerMenu()
    end

    zo_callLater(RefreshOnOffTextColors, 80)
    zo_callLater(RefreshOnOffTextColors, 250)
    zo_callLater(RefreshSprintSensitivitySlider, 80)
    zo_callLater(RefreshSprintSensitivitySlider, 250)
    zo_callLater(RefreshImportValidationControls, 80)
    zo_callLater(RefreshImportValidationControls, 250)
    zo_callLater(function()
        if RefreshKeyboardTunerMenu then
            RefreshKeyboardTunerMenu()
        end
    end, 80)
    zo_callLater(function()
        if RefreshKeyboardTunerMenu then
            RefreshKeyboardTunerMenu()
        end
    end, 250)
end

local function RegisterPanelColorCallbacks()
    if registeredPanelCallbacks then
        return
    end

    registeredPanelCallbacks = true

    local function RefreshForPanel(panel)
        if panel and panel:GetName() == ADDON_NAME .. "Options" then
            RefreshOnOffTextColorsSoon()
        end
    end

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", RefreshForPanel)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", RefreshForPanel)
    CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", RefreshForPanel)
end

local function OnOffDropdown(name, tooltip, getFunc, setFunc, defaultValue, disabledFunc)
    onOffControlCount = onOffControlCount + 1

    local reference = ADDON_NAME .. "OnOffDropdown" .. tostring(onOffControlCount)
    onOffControls[#onOffControls + 1] = {
        reference = reference,
        getFunc = getFunc,
    }

    return {
        type = "dropdown",
        name = name,
        reference = reference,
        tooltip = tooltip,
        choices = onOffChoices,
        choicesValues = onOffChoiceValues,
        scrollable = false,
        getFunc = function()
            return getFunc() and true or false
        end,
        setFunc = function(value)
            if disabledFunc and disabledFunc() then
                return
            end

            setFunc(value == true)
            RefreshOnOffTextColorsSoon()
        end,
        disabled = disabledFunc,
        default = defaultValue and true or false,
    }
end

local function KeyboardText(value)
    if type(value) == "function" then
        local ok, result = pcall(value)
        if ok then
            value = result
        else
            value = ""
        end
    end

    if value == nil then
        return ""
    end

    return tostring(value)
end

local function NextKeyboardMenuName(suffix)
    keyboardMenuControlIndex = keyboardMenuControlIndex + 1
    return ADDON_NAME .. "KeyboardMenu" .. suffix .. tostring(keyboardMenuControlIndex)
end

local function KeyboardFont(size, bold)
    return (bold and "$(BOLD_FONT)" or "$(MEDIUM_FONT)") .. "|" .. tostring(size) .. "|soft-shadow-thick"
end

local function CreateKeyboardLabel(name, parent, width, height, anchor, font, color, text)
    local label = WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)
    label:SetDimensions(width, height)
    label:SetAnchor(anchor[1], anchor[2] or parent, anchor[3], anchor[4] or 0, anchor[5] or 0)
    label:SetFont(font or KeyboardFont(18, true))
    label:SetColor(color[1], color[2], color[3], color[4])
    label:SetText(text or "")
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    return label
end

local function CreateKeyboardBackdrop(name, parent, width, height, anchor, center, edge)
    local backdrop = WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)
    backdrop:SetDimensions(width, height)
    backdrop:SetAnchor(anchor[1], anchor[2] or parent, anchor[3], anchor[4] or 0, anchor[5] or 0)
    backdrop:SetCenterColor(center[1], center[2], center[3], center[4])
    backdrop:SetEdgeColor(edge[1], edge[2], edge[3], edge[4])
    backdrop:SetEdgeTexture("", 8, 2, 2)
    return backdrop
end

local function FormatKeyboardSliderValue(value, decimals)
    return FormatDecimal(tonumber(value) or 0, decimals or 0)
end

local function SetKeyboardRowState(row, disabled, active)
    local label = row and row.label
    if label then
        if disabled then
            label:SetColor(0.32, 0.32, 0.32, 1)
        elseif active == false then
            label:SetColor(0.55, 0.55, 0.55, 1)
        else
            label:SetColor(0.86, 0.84, 0.62, 1)
        end
    end

    if row then
        row:SetAlpha(disabled and 0.58 or 1)
    end
end

local function AddKeyboardControl(control)
    keyboardMenuControls[#keyboardMenuControls + 1] = control
    return control
end

local function RefreshKeyboardTunerMenuSoon()
    if RefreshKeyboardTunerMenu then
        RefreshKeyboardTunerMenu()
    end

    zo_callLater(function()
        if RefreshKeyboardTunerMenu then
            RefreshKeyboardTunerMenu()
        end
    end, 80)
    zo_callLater(function()
        if RefreshKeyboardTunerMenu then
            RefreshKeyboardTunerMenu()
        end
    end, 250)
end

local function CreateKeyboardRow(panel, name, tooltip, height)
    local rowHeight = height or 30
    local row = WINDOW_MANAGER:CreateControl(NextKeyboardMenuName("Row"), panel.scroll, CT_CONTROL)
    row:SetDimensions(625, rowHeight)
    row:SetAnchor(TOPLEFT, panel.scroll, TOPLEFT, 0, panel.nextY)
    row:SetMouseEnabled(true)

    row.label = CreateKeyboardLabel(NextKeyboardMenuName("Label"), row, 370, 26, { TOPLEFT, row, TOPLEFT, 0, 0 }, KeyboardFont(18, true), { 0.86, 0.84, 0.62, 1 }, KeyboardText(name))

    row:SetHandler("OnMouseEnter", function(self)
        if keyboardMenu and keyboardMenu.highlight then
            keyboardMenu.highlight:ClearAnchors()
            keyboardMenu.highlight:SetAnchor(LEFT, self, LEFT, 0, 0)
            keyboardMenu.highlight:SetHidden(false)
        end

        if tooltip and tooltip ~= "" then
            ZO_Tooltips_ShowTextTooltip(self, BOTTOM, tooltip)
        end
    end)
    row:SetHandler("OnMouseExit", function()
        if keyboardMenu and keyboardMenu.highlight then
            keyboardMenu.highlight:SetHidden(true)
        end
        ZO_Tooltips_HideTextTooltip()
    end)

    panel.nextY = panel.nextY + rowHeight + 6
    panel.scroll:SetHeight(panel.nextY + 20)
    return row
end

local function AddKeyboardHeader(panel, text)
    local header = CreateKeyboardBackdrop(NextKeyboardMenuName("Header"), panel.scroll, 625, 30, { TOPLEFT, panel.scroll, TOPLEFT, 0, panel.nextY }, { 0.36, 0.34, 0.22, 0.35 }, { 0, 0, 0, 0 })
    header.label = CreateKeyboardLabel(NextKeyboardMenuName("HeaderLabel"), header, 610, 28, { LEFT, header, LEFT, 8, 0 }, KeyboardFont(22, true), { 1, 0.82, 0.28, 1 }, text)
    header.label:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
    panel.nextY = panel.nextY + 36
    panel.scroll:SetHeight(panel.nextY + 20)
    return header
end

local function SetKeyboardComboDisabled(comboControl, disabled)
    comboControl:SetMouseEnabled(not disabled)
    local openButton = comboControl:GetNamedChild("OpenDropdown")
    if openButton then
        openButton:SetMouseEnabled(not disabled)
    end
end

local function AddKeyboardDropdown(panel, data)
    local row = CreateKeyboardRow(panel, data.name, data.tooltip)
    local comboControl = WINDOW_MANAGER:CreateControlFromVirtual(data.reference or NextKeyboardMenuName("Dropdown"), row, "ZO_ComboBox")
    comboControl:SetDimensions(220, 28)
    comboControl:SetAnchor(TOPRIGHT, row, TOPRIGHT, 0, -1)
    comboControl.m_comboBox:SetSortsItems(false)
    comboControl.m_comboBox:SetFont(KeyboardFont(16, false))

    local refreshHandle = AddKeyboardControl({
        row = row,
        Refresh = function(self)
            row.label:SetText(KeyboardText(data.name))

            local comboBox = comboControl.m_comboBox
            local choices = data.choices or {}
            local values = data.choicesValues or choices
            local currentValue = data.getFunc and data.getFunc()
            local selectedIndex = 1

            comboBox:ClearItems()
            for index, choice in ipairs(choices) do
                local value = values[index]
                local entry = comboBox:CreateItemEntry(choice, function()
                    if data.setFunc then
                        data.setFunc(value)
                    end
                    RefreshKeyboardTunerMenuSoon()
                end)
                comboBox:AddItem(entry, ZO_COMBOBOX_SUPRESS_UPDATE)

                if currentValue == value then
                    selectedIndex = index
                end
            end

            if #choices > 0 then
                comboBox:SelectItemByIndex(selectedIndex, true)
            end

            local disabled = data.disabled and data.disabled() or false
            SetKeyboardComboDisabled(comboControl, disabled)
            SetKeyboardRowState(row, disabled, data.activeFunc and data.activeFunc())
        end,
    })

    refreshHandle:Refresh()
    return row
end

local function AddKeyboardOnOff(panel, name, tooltip, getFunc, setFunc, disabledFunc)
    return AddKeyboardDropdown(panel, {
        name = name,
        tooltip = tooltip,
        choices = onOffChoices,
        choicesValues = onOffChoiceValues,
        getFunc = function()
            return getFunc() and true or false
        end,
        setFunc = function(value)
            if disabledFunc and disabledFunc() then
                return
            end

            setFunc(value == true)
        end,
        activeFunc = function()
            return getFunc() and true or false
        end,
        disabled = disabledFunc,
    })
end

local function AddKeyboardSlider(panel, data)
    local row = CreateKeyboardRow(panel, data.name, data.tooltip, 52)
    local sliderWidth = 210
    local slider = WINDOW_MANAGER:CreateControl(NextKeyboardMenuName("Slider"), row, CT_SLIDER)
    slider:SetDimensions(sliderWidth, 16)
    slider:SetAnchor(TOPRIGHT, row, TOPRIGHT, -65, 4)
    slider:SetMouseEnabled(true)
    slider:SetOrientation(ORIENTATION_HORIZONTAL)
    slider:SetMinMax(data.min, data.max)
    slider:SetValueStep(data.step or 1)
    slider:SetThumbTexture("EsoUI\\Art\\Miscellaneous\\scrollbox_elevator.dds", "EsoUI\\Art\\Miscellaneous\\scrollbox_elevator_disabled.dds", nil, 8, 16)

    local sliderBg = WINDOW_MANAGER:CreateControl(NextKeyboardMenuName("SliderBg"), slider, CT_BACKDROP)
    sliderBg:SetAnchor(TOPLEFT, slider, TOPLEFT, 0, 4)
    sliderBg:SetAnchor(BOTTOMRIGHT, slider, BOTTOMRIGHT, 0, -4)
    sliderBg:SetCenterColor(0, 0, 0, 0.85)
    sliderBg:SetEdgeColor(0.80, 0.78, 0.55, 0.9)
    sliderBg:SetEdgeTexture("EsoUI\\Art\\Tooltips\\UI-SliderBackdrop.dds", 32, 4)

    local minLabel = CreateKeyboardLabel(NextKeyboardMenuName("MinLabel"), row, 80, 18, { TOPLEFT, slider, BOTTOMLEFT, 0, -3 }, KeyboardFont(13, true), { 0.86, 0.84, 0.62, 1 }, FormatKeyboardSliderValue(data.min, data.decimals))
    local maxLabel = CreateKeyboardLabel(NextKeyboardMenuName("MaxLabel"), row, 80, 18, { TOPRIGHT, slider, BOTTOMRIGHT, 0, -3 }, KeyboardFont(13, true), { 0.86, 0.84, 0.62, 1 }, FormatKeyboardSliderValue(data.max, data.decimals))
    maxLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    local valueBox = CreateKeyboardBackdrop(NextKeyboardMenuName("ValueBox"), row, 55, 19, { TOPRIGHT, row, TOPRIGHT, 0, 21 }, { 0.18, 0.18, 0.15, 0.85 }, { 0.55, 0.54, 0.40, 0.55 })
    local valueLabel = CreateKeyboardLabel(NextKeyboardMenuName("ValueLabel"), valueBox, 51, 17, { CENTER, valueBox, CENTER, 0, 0 }, KeyboardFont(13, true), { 1, 1, 1, 1 }, "")
    valueLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    local isUpdating = false
    local function SetSliderValue(value)
        local rounded = ClampAndRound(value, data.default or data.min, data.min, data.max, data.step or 1)
        isUpdating = true
        slider:SetValue(rounded)
        valueLabel:SetText(FormatKeyboardSliderValue(rounded, data.decimals))
        isUpdating = false
        return rounded
    end

    slider:SetHandler("OnValueChanged", function(_, value, eventReason)
        if isUpdating or eventReason == EVENT_REASON_SOFTWARE then
            return
        end

        local rounded = ClampAndRound(value, data.default or data.min, data.min, data.max, data.step or 1)
        valueLabel:SetText(FormatKeyboardSliderValue(rounded, data.decimals))
        if data.setFunc then
            data.setFunc(rounded)
        end
        RefreshKeyboardTunerMenuSoon()
    end)

    local refreshHandle = AddKeyboardControl({
        row = row,
        Refresh = function(self)
            row.label:SetText(KeyboardText(data.name))
            local value = data.getFunc and data.getFunc() or data.default or data.min
            SetSliderValue(value)

            local disabled = data.disabled and data.disabled() or false
            slider:SetMouseEnabled(not disabled)
            SetKeyboardRowState(row, disabled, true)
            minLabel:SetColor(disabled and 0.35 or 0.86, disabled and 0.35 or 0.84, disabled and 0.35 or 0.62, 1)
            maxLabel:SetColor(disabled and 0.35 or 0.86, disabled and 0.35 or 0.84, disabled and 0.35 or 0.62, 1)
            valueLabel:SetColor(disabled and 0.55 or 1, disabled and 0.55 or 1, disabled and 0.55 or 1, 1)
        end,
    })

    refreshHandle:Refresh()
    return row
end

local function AddKeyboardButton(panel, data)
    local row = CreateKeyboardRow(panel, data.name, data.tooltip)
    local button = WINDOW_MANAGER:CreateControlFromVirtual(data.reference or NextKeyboardMenuName("Button"), row, "ZO_DefaultButton")
    button:SetDimensions(190, 28)
    button:SetAnchor(TOPRIGHT, row, TOPRIGHT, 0, -1)
    button:SetFont(KeyboardFont(17, true))
    button:SetText(KeyboardText(data.name))
    button:SetClickSound("Click")
    button:SetHandler("OnClicked", function()
        if data.func then
            data.func()
        end
        RefreshKeyboardTunerMenuSoon()
    end)

    local refreshHandle = AddKeyboardControl({
        row = row,
        Refresh = function(self)
            row.label:SetText(KeyboardText(data.name))
            button:SetText(KeyboardText(data.name))
            local disabled = data.disabled and data.disabled() or false
            button:SetEnabled(not disabled)
            SetKeyboardRowState(row, disabled, true)
        end,
    })

    row.button = button
    row.Refresh = function(self)
        refreshHandle:Refresh()
    end

    refreshHandle:Refresh()
    return row
end

local function AddKeyboardEditBox(panel, data)
    local row = CreateKeyboardRow(panel, data.name, data.tooltip, data.statusFunc and 78 or 58)
    row.label:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 0)
    local bg = WINDOW_MANAGER:CreateControlFromVirtual(data.reference or NextKeyboardMenuName("EditBg"), row, "ZO_EditBackdrop")
    bg:SetDimensions(625, 24)
    bg:SetAnchor(TOPLEFT, row, TOPLEFT, 0, 28)

    local edit = WINDOW_MANAGER:CreateControlFromVirtual(NextKeyboardMenuName("Edit"), bg, "ZO_DefaultEditForBackdrop")
    edit:ClearAnchors()
    edit:SetAnchor(TOPLEFT, bg, TOPLEFT, 4, 1)
    edit:SetAnchor(BOTTOMRIGHT, bg, BOTTOMRIGHT, -4, -1)
    edit:SetMaxInputChars(data.maxChars or 64)
    edit:SetFont(KeyboardFont(15, false))

    local statusLabel
    local function RefreshStatus(text)
        if not (statusLabel and data.statusFunc) then
            return
        end

        local statusText, color = data.statusFunc(text)
        statusLabel:SetText(statusText or "")
        SetLabelColorFromTable(statusLabel, color)
    end

    if data.statusFunc then
        statusLabel = CreateKeyboardLabel(NextKeyboardMenuName("StatusLabel"), row, 625, 20, { TOPLEFT, row, TOPLEFT, 0, 54 }, KeyboardFont(14, true), { 0.72, 0.72, 0.72, 1 }, "")
        row.statusLabel = statusLabel
    end

    edit:SetHandler("OnTextChanged", function(self)
        if data.onTextChanged then
            data.onTextChanged(self:GetText())
        end

        RefreshStatus(self:GetText())
    end)

    edit:SetHandler("OnFocusLost", function(self)
        if data.setFunc then
            data.setFunc(self:GetText())
        end
        RefreshKeyboardTunerMenuSoon()
    end)

    local refreshHandle = AddKeyboardControl({
        row = row,
        Refresh = function(self)
            row.label:SetText(KeyboardText(data.name))
            local value = data.getFunc and data.getFunc() or ""
            if edit:GetText() ~= value then
                edit:SetText(value)
            end
            RefreshStatus(value)
            local disabled = data.disabled and data.disabled() or false
            edit:SetMouseEnabled(not disabled)
            SetKeyboardRowState(row, disabled, true)
        end,
    })

    refreshHandle:Refresh()
    return row
end

local function SelectKeyboardMenuPanel(panelKey)
    if not keyboardMenu or not keyboardMenu.panels then
        return
    end

    for key, panel in pairs(keyboardMenu.panels) do
        local selected = key == panelKey
        panel:SetHidden(not selected)
        if keyboardMenuTabs[key] then
            keyboardMenuTabs[key]:SetColor(selected and 1 or 0.72, selected and 0.82 or 0.72, selected and 0.28 or 0.72, 1)
        end
    end

    keyboardMenuCurrentPanel = panelKey
    RefreshKeyboardTunerMenuSoon()
end

local function AddKeyboardCategory(ui, key, label, index)
    local tab = WINDOW_MANAGER:CreateControl(NextKeyboardMenuName("Tab"), ui, CT_LABEL)
    tab:SetDimensions(285, 28)
    tab:SetAnchor(TOPLEFT, ui, TOPLEFT, 65, 160 + ((index - 1) * 32))
    tab:SetFont(KeyboardFont(20, true))
    tab:SetText(label)
    tab:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    tab:SetMouseEnabled(true)
    tab:SetHandler("OnMouseDown", function()
        SelectKeyboardMenuPanel(key)
        PlaySound(SOUNDS.MENU_SUBCATEGORY_SELECTION)
    end)
    tab:SetHandler("OnMouseEnter", function(self)
        self:SetColor(1, 0.9, 0.45, 1)
    end)
    tab:SetHandler("OnMouseExit", function(self)
        local selected = keyboardMenuCurrentPanel == key
        self:SetColor(selected and 1 or 0.72, selected and 0.82 or 0.72, selected and 0.28 or 0.72, 1)
    end)
    keyboardMenuTabs[key] = tab
    return tab
end

local function CreateKeyboardPanel(ui, key, title)
    local panel = WINDOW_MANAGER:CreateControl(NextKeyboardMenuName("Panel"), ui.panelArea, CT_CONTROL)
    panel:SetDimensions(645, 675)
    panel:SetAnchor(TOPLEFT, ui.panelArea, TOPLEFT, 0, 0)
    panel:SetHidden(true)
    panel.nextY = 0

    panel.title = CreateKeyboardLabel(NextKeyboardMenuName("PanelTitle"), panel, 645, 30, { TOPLEFT, panel, TOPLEFT, 0, 0 }, KeyboardFont(22, true), { 1, 1, 1, 1 }, title)
    panel.title:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)

    local container = WINDOW_MANAGER:CreateControlFromVirtual(NextKeyboardMenuName("Scroll"), panel, "ZO_ScrollContainer")
    container:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 48)
    container:SetAnchor(BOTTOMRIGHT, panel, BOTTOMRIGHT, 0, 0)
    panel.scroll = GetControl(container, "ScrollChild")
    panel.scroll:SetResizeToFitPadding(0, 0)

    ui.panels[key] = panel
    return panel
end

local function BuildKeyboardMenuPanels(ui)
    local general = CreateKeyboardPanel(ui, "general", "General")
    AddKeyboardHeader(general, "Toggles")
    AddKeyboardOnOff(general, "Disable aim assist", Tooltip("Aim Assist", "Sets ESO's exposed aim-assist intensity values to 0 while keeping native gamepad input. Presets control this while Advanced Mode is off."), function() return IsEffectiveTuningEnabled("disableAimAssist") end, function(value) sv.disableAimAssist = value; ApplySettingsSoon(false) end, IsPresetModeActive)
    AddKeyboardOnOff(general, "Disable acceleration", Tooltip("Acceleration", "Disables ESO's exposed camera smoothing and makes stick input feel more direct. Presets control this while Advanced Mode is off."), function() return IsEffectiveTuningEnabled("reduceAcceleration") end, function(value) sv.reduceAcceleration = value; ApplySettingsSoon(false) end, IsPresetModeActive)
    AddKeyboardOnOff(general, "1:1 horizontal / vertical", Tooltip("1:1 Sensitivity", "Uses the horizontal camera value for both camera axes. Presets control this while Advanced Mode is off."), function() return IsEffectiveTuningEnabled("oneToOneSensitivity") end, function(value) sv.oneToOneSensitivity = value; ApplySettingsSoon(false) end, IsPresetModeActive)
    AddKeyboardOnOff(general, "Sprint 1:1", Tooltip("Sprint 1:1", "Uses Zoruah's measured 1.95x sprint compensation for on-foot sprint camera turning. Presets control this while Advanced Mode is off."), function() return IsEffectiveTuningEnabled("sprintOneToOneSensitivity") end, function(value) sv.sprintOneToOneSensitivity = value; ApplySettingsSoon(false); StartSprintSensitivityPolling(); UpdateSprintSensitivity() end, IsPresetModeActive)
    AddKeyboardOnOff(general, "Advanced Mode", Tooltip("Advanced Mode", "Unlocks manual tuning sliders while preserving your custom values."), function() return IsAdvancedMode() end, SetAdvancedMode)
    AddKeyboardDropdown(general, {
        name = "Preset",
        tooltip = Tooltip("Preset", "Choose ESO Default or one of Zoruah's tuned profiles. Disabled while Advanced Mode is on."),
        choices = presetChoices,
        choicesValues = presetChoiceValues,
        getFunc = function() return sv.presetMode end,
        setFunc = ApplyPresetMode,
        disabled = IsAdvancedMode,
    })
    local sensitivity = CreateKeyboardPanel(ui, "sensitivity", "Sensitivity")
    AddKeyboardHeader(sensitivity, "Camera")
    AddKeyboardSlider(sensitivity, {
        name = "Horizontal sensitivity",
        tooltip = Tooltip("Horizontal Camera Speed", "Controls right-stick left/right camera speed. This can go higher than ESO's normal menu slider."),
        min = 0.10, max = 3.00, step = 0.01, decimals = 2, default = defaults.horizontalSensitivity,
        getFunc = function() return GetEffectiveTuningValue("horizontalSensitivity") end,
        setFunc = function(value) sv.horizontalSensitivity = value; MarkAdvancedForManualChange(); ApplySettingsSoon(true) end,
        disabled = function() return not IsAdvancedMode() end,
    })
    AddKeyboardSlider(sensitivity, {
        name = function()
            if IsEffectiveTuningEnabled("sprintOneToOneSensitivity") then
                return "Sprint sensitivity (" .. FormatMultiplier(SPRINT_1TO1_MULTIPLIER) .. " 1:1)"
            end
            return "Sprint sensitivity (" .. FormatMultiplier(GetEffectiveTuningValue("sprintSensitivityMultiplier")) .. ")"
        end,
        tooltip = Tooltip("Sprint Sensitivity", "Manual on-foot sprint camera multiplier. Disabled while Sprint 1:1 is on."),
        min = 1.00, max = 10.00, step = 0.25, decimals = 2, default = defaults.sprintSensitivityMultiplier,
        getFunc = function() return GetEffectiveSprintSensitivityMultiplier() end,
        setFunc = function(value) sv.sprintSensitivityMultiplier = ClampAndRound(value, defaults.sprintSensitivityMultiplier, 1.00, 10.00, 0.25); MarkAdvancedForManualChange(); ApplySettingsSoon(true); StartSprintSensitivityPolling(); UpdateSprintSensitivity(); SetCameraSensitivity() end,
        disabled = function() return not IsAdvancedMode() or IsEffectiveTuningEnabled("sprintOneToOneSensitivity") end,
    })
    AddKeyboardSlider(sensitivity, {
        name = "Vertical sensitivity",
        tooltip = Tooltip("Vertical Camera Speed", "Controls right-stick up/down camera speed when 1:1 mode is off."),
        min = 0.10, max = 3.00, step = 0.01, decimals = 2, default = defaults.verticalSensitivity,
        getFunc = function() return GetEffectiveTuningValue("verticalSensitivity") end,
        setFunc = function(value) sv.verticalSensitivity = value; MarkAdvancedForManualChange(); ApplySettingsSoon(true) end,
        disabled = function() return not IsAdvancedMode() or IsEffectiveTuningEnabled("oneToOneSensitivity") end,
    })

    local sticks = CreateKeyboardPanel(ui, "sticks", "Sticks & Triggers")
    AddKeyboardHeader(sticks, "Right Stick")
    AddKeyboardSlider(sticks, {
        name = "Right-stick inner deadzone",
        tooltip = Tooltip("Right Inner Deadzone", "How far the right stick must move before the camera starts. Minimum is 0.05 to prevent drift."),
        min = 0.05, max = 0.30, step = 0.01, decimals = 2, default = defaults.rightStickInnerDeadzone,
        getFunc = function() return GetEffectiveTuningValue("rightStickInnerDeadzone") end,
        setFunc = function(value) sv.rightStickInnerDeadzone = value; MarkAdvancedForManualChange(); ApplySettingsSoon(true) end,
        disabled = function() return not IsAdvancedMode() end,
    })
    AddKeyboardSlider(sticks, {
        name = "Right-stick outer threshold",
        tooltip = Tooltip("Right Outer Threshold", "How soon the right stick reaches full camera speed."),
        min = 0.60, max = 1.00, step = 0.01, decimals = 2, default = defaults.rightStickOuterThreshold,
        getFunc = function() return GetEffectiveTuningValue("rightStickOuterThreshold") end,
        setFunc = function(value) sv.rightStickOuterThreshold = value; MarkAdvancedForManualChange(); ApplySettingsSoon(true) end,
        disabled = function() return not IsAdvancedMode() end,
    })
    AddKeyboardHeader(sticks, "Left Stick")
    AddKeyboardSlider(sticks, {
        name = "Left-stick inner deadzone",
        tooltip = Tooltip("Left Inner Deadzone", "How far the left stick must move before movement begins. Minimum is 0.05 to prevent drift."),
        min = 0.05, max = 0.30, step = 0.01, decimals = 2, default = defaults.leftStickInnerDeadzone,
        getFunc = function() return GetEffectiveTuningValue("leftStickInnerDeadzone") end,
        setFunc = function(value) sv.leftStickInnerDeadzone = value; MarkAdvancedForManualChange(); ApplySettingsSoon(true) end,
        disabled = function() return not IsAdvancedMode() end,
    })
    AddKeyboardSlider(sticks, {
        name = "Left-stick outer threshold",
        tooltip = Tooltip("Left Outer Threshold", "How soon movement reaches full input."),
        min = 0.60, max = 1.00, step = 0.01, decimals = 2, default = defaults.leftStickOuterThreshold,
        getFunc = function() return GetEffectiveTuningValue("leftStickOuterThreshold") end,
        setFunc = function(value) sv.leftStickOuterThreshold = value; MarkAdvancedForManualChange(); ApplySettingsSoon(true) end,
        disabled = function() return not IsAdvancedMode() end,
    })
    AddKeyboardHeader(sticks, "Triggers")
    AddKeyboardSlider(sticks, {
        name = "Trigger deadzone",
        tooltip = Tooltip("Trigger Deadzone", "How far triggers must be pressed before ESO counts them."),
        min = 0.00, max = 0.50, step = 0.01, decimals = 2, default = defaults.triggerDeadzone,
        getFunc = function() return GetEffectiveTuningValue("triggerDeadzone") end,
        setFunc = function(value) sv.triggerDeadzone = value; MarkAdvancedForManualChange(); ApplySettingsSoon(true) end,
        disabled = function() return not IsAdvancedMode() end,
    })

    local share = CreateKeyboardPanel(ui, "share", "Share Codes")
    AddKeyboardHeader(share, "Export")
    AddKeyboardEditBox(share, { name = "Export code", tooltip = Tooltip("Export", "Click the box, press Ctrl+A, then Ctrl+C to copy the compact share code."), maxChars = 64, getFunc = GetExportCode, setFunc = function(value) sv.exportCode = value end })
    AddKeyboardHeader(share, "Import")
    local importRow = AddKeyboardEditBox(share, {
        name = "Import code",
        tooltip = Tooltip("Import", "Paste or type a ZGT1 share code here. The status updates immediately while you type."),
        maxChars = 64,
        getFunc = function() return sv.importCode or "" end,
        setFunc = function(value) sv.importCode = value; RefreshImportValidationControls(value) end,
        onTextChanged = function(value) sv.importCode = value; RefreshImportValidationControls(value) end,
        statusFunc = function(value)
            local _, text, color = GetImportCodeValidationState(value)
            return text, color
        end,
    })
    ui.importStatusLabel = importRow.statusLabel
    ui.importApplyButtonRow = AddKeyboardButton(share, { name = "Apply Import", tooltip = Tooltip("Apply Import", "Imports the ZGT1 share code and applies every imported setting immediately."), func = function() ImportSettingsCode(sv.importCode) end, disabled = function() return not IsImportCodeValid(sv.importCode) end })

    local socials = CreateKeyboardPanel(ui, "socials", "Socials")
    AddKeyboardHeader(socials, "Official Zoruah")
    AddKeyboardButton(socials, { name = "YouTube", tooltip = SocialUrl("youtube"), func = function() OpenUrl(SocialUrl("youtube")) end })
    AddKeyboardButton(socials, { name = "TikTok", tooltip = SocialUrl("tiktok"), func = function() OpenUrl(SocialUrl("tiktok")) end })
    AddKeyboardButton(socials, { name = "Twitch", tooltip = SocialUrl("twitch"), func = function() OpenUrl(SocialUrl("twitch")) end })
    AddKeyboardButton(socials, { name = "X", tooltip = SocialUrl("x"), func = function() OpenUrl(SocialUrl("x")) end })
    AddKeyboardButton(socials, { name = "Instagram", tooltip = SocialUrl("instagram"), func = function() OpenUrl(SocialUrl("instagram")) end })

    local other = CreateKeyboardPanel(ui, "other", "Other")
    AddKeyboardHeader(other, "Profiles")
    AddKeyboardOnOff(other, "Character-specific profile", Tooltip("Profiles", "Off uses one global profile. On gives this character its own saved tuning."), function() return accountSv.profileScope == PROFILE_SCOPE_CHARACTER end, function(value) SetProfileScope(value and PROFILE_SCOPE_CHARACTER or PROFILE_SCOPE_GLOBAL, value); ApplySettingsSoon(false) end)
    AddKeyboardHeader(other, "Backups")
    AddKeyboardButton(other, { name = "Create Backup", tooltip = Tooltip("Settings Backup", "Saves the current profile into the backup list stored in ESO SavedVariables."), func = CreateSettingsBackup })
    AddKeyboardButton(other, { name = "Restore Backup", tooltip = Tooltip("Settings Backup", "Restores the newest saved backup that differs from the current profile."), func = RestoreSettingsBackup, disabled = function() return not HasRestorableSettingsBackup() end })
    AddKeyboardHeader(other, "Options")
    AddKeyboardOnOff(other, "Show chat messages", Tooltip("Chat Messages", "Shows a short chat message when settings apply, import fails, or a social link cannot open."), function() return sv.showChatMessages end, function(value) sv.showChatMessages = value end)
end

local function CreateKeyboardTunerMenu()
    if keyboardMenu then
        return keyboardMenu
    end

    local ui = WINDOW_MANAGER:CreateTopLevelWindow(ADDON_NAME .. "KeyboardMenu")
    keyboardMenu = ui
    ui:SetDimensions(1010, 914)
    ui:SetAnchor(LEFT, GuiRoot, LEFT, 245, 0)
    ui:SetHidden(true)
    ui:SetMouseEnabled(true)
    ui.panels = {}

    ui.bgLeft = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "KeyboardMenuBgLeft", ui, CT_TEXTURE)
    ui.bgLeft:SetTexture("EsoUI/Art/Miscellaneous/centerscreen_left.dds")
    ui.bgLeft:SetDimensions(1024, 1024)
    ui.bgLeft:SetAnchor(TOPLEFT, ui, TOPLEFT, 0, 0)

    ui.bgRight = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "KeyboardMenuBgRight", ui, CT_TEXTURE)
    ui.bgRight:SetTexture("EsoUI/Art/Miscellaneous/centerscreen_right.dds")
    ui.bgRight:SetDimensions(64, 1024)
    ui.bgRight:SetAnchor(TOPLEFT, ui.bgLeft, TOPRIGHT, 0, 0)

    ui.underlayLeft = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "KeyboardMenuUnderlayLeft", ui, CT_TEXTURE)
    ui.underlayLeft:SetTexture("EsoUI/Art/Miscellaneous/centerscreen_indexArea_left.dds")
    ui.underlayLeft:SetDimensions(256, 1024)
    ui.underlayLeft:SetAnchor(TOPLEFT, ui, TOPLEFT, 0, 0)

    ui.underlayRight = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "KeyboardMenuUnderlayRight", ui, CT_TEXTURE)
    ui.underlayRight:SetTexture("EsoUI/Art/Miscellaneous/centerscreen_indexArea_right.dds")
    ui.underlayRight:SetDimensions(128, 1024)
    ui.underlayRight:SetAnchor(TOPLEFT, ui.underlayLeft, TOPRIGHT, 0, 0)

    ui.title = CreateKeyboardLabel(ADDON_NAME .. "KeyboardMenuTitle", ui, 650, 34, { TOPLEFT, ui, TOPLEFT, 65, 58 }, KeyboardFont(25, true), { 1, 1, 1, 1 }, ADDON_TITLE)
    ui.title:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)

    ui.info = CreateKeyboardLabel(ADDON_NAME .. "KeyboardMenuInfo", ui, 175, 20, { TOPLEFT, ui.title, BOTTOMLEFT, 0, -2 }, KeyboardFont(14, false), { 0.9, 0.9, 0.9, 1 }, "Author: " .. AUTHOR)

    ui.versionInfo = CreateKeyboardLabel(ADDON_NAME .. "KeyboardMenuVersion", ui, 120, 20, { LEFT, ui.info, RIGHT, 14, 0 }, KeyboardFont(14, false), { 0.9, 0.9, 0.9, 1 }, "Version: " .. VERSION)

    ui.website = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "KeyboardMenuWebsite", ui, CT_BUTTON)
    ui.website:SetAnchor(LEFT, ui.versionInfo, RIGHT, 14, 0)
    ui.website:SetFont(KeyboardFont(14, false))
    ui.website:SetNormalFontColor(0.35, 0.35, 0.85, 1)
    ui.website:SetMouseOverFontColor(0.72, 0.72, 0.95, 1)
    ui.website:SetText("Visit Website")
    ui.website:SetDimensions(110, 20)
    ui.website:SetClickSound("Click")
    ui.website:SetHandler("OnClicked", function() OpenUrl(SocialUrl("youtube")) end)

    ui.divider = WINDOW_MANAGER:CreateControlFromVirtual(ADDON_NAME .. "KeyboardMenuDivider", ui, "ZO_Options_Divider")
    ui.divider:SetAnchor(TOPLEFT, ui, TOPLEFT, 65, 112)

    ui.panelArea = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "KeyboardMenuPanelArea", ui, CT_CONTROL)
    ui.panelArea:SetDimensions(645, 675)
    ui.panelArea:SetAnchor(TOPLEFT, ui, TOPLEFT, 365, 120)

    ui.highlight = WINDOW_MANAGER:CreateControl(ADDON_NAME .. "KeyboardMenuHighlight", ui.panelArea, CT_TEXTURE)
    ui.highlight:SetTexture("esoui/art/miscellaneous/listitem_highlight.dds")
    ui.highlight:SetDimensions(420, 26)
    ui.highlight:SetColor(1, 0.96, 0.35, 0.25)
    ui.highlight:SetHidden(true)

    local categories = {
        { "general", "General" },
        { "sensitivity", "Sensitivity" },
        { "sticks", "Sticks & Triggers" },
        { "share", "Share Codes" },
        { "socials", "Socials" },
        { "other", "Other" },
    }

    for index, category in ipairs(categories) do
        AddKeyboardCategory(ui, category[1], category[2], index)
    end

    BuildKeyboardMenuPanels(ui)

    keyboardMenuFragment = ZO_FadeSceneFragment:New(ui, true, 100)
    keyboardMenuFragment:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_FRAGMENT_SHOWN then
            PushActionLayerByName("OptionsWindow")
            SelectKeyboardMenuPanel(keyboardMenuCurrentPanel or "general")
        elseif newState == SCENE_FRAGMENT_HIDDEN then
            RemoveActionLayerByName("OptionsWindow")
        end
    end)

    return ui
end

RefreshKeyboardTunerMenu = function()
    if not keyboardMenu then
        return
    end

    if keyboardMenu.info then
        keyboardMenu.info:SetText("Author: " .. AUTHOR)
    end

    if keyboardMenu.versionInfo then
        keyboardMenu.versionInfo:SetText("Version: " .. VERSION)
    end

    for _, control in ipairs(keyboardMenuControls) do
        if control.Refresh then
            control:Refresh()
        end
    end
end

local function OpenKeyboardTunerMenu()
    CreateKeyboardTunerMenu()

    if SCENE_MANAGER and keyboardMenuFragment then
        SCENE_MANAGER:AddFragment(keyboardMenuFragment)
    end

    SelectKeyboardMenuPanel(keyboardMenuCurrentPanel or "general")
end

local function CloseKeyboardTunerMenu()
    if SCENE_MANAGER and keyboardMenuFragment then
        SCENE_MANAGER:RemoveFragment(keyboardMenuFragment)
    end
end

local function RegisterKeyboardOptionsShortcut(panel, LAM)
    if keyboardOptionsShortcutRegistered or not panel then
        return
    end

    if IsKeyboardUISupported and not IsKeyboardUISupported() then
        return
    end

    if not (KEYBOARD_OPTIONS and ZO_GameMenu_AddSettingPanel and SCENE_MANAGER) then
        return
    end

    local panelId = KEYBOARD_OPTIONS.currentPanelId
    if not panelId then
        return
    end

    keyboardOptionsShortcutRegistered = true

    local function OpenTunerPanel()
        OpenKeyboardTunerMenu()
        RefreshOnOffTextColorsSoon()
    end

    local shortcutData = {
        id = panelId,
        name = OPTIONS_SHORTCUT_TITLE,
        longname = ADDON_TITLE,
        callback = function()
            zo_callLater(OpenTunerPanel, 1)
        end,
        unselectedCallback = CloseKeyboardTunerMenu,
    }

    KEYBOARD_OPTIONS.currentPanelId = panelId + 1
    KEYBOARD_OPTIONS.panelNames[panelId] = shortcutData.name
    if KEYBOARD_OPTIONS.controlTable then
        KEYBOARD_OPTIONS.controlTable[panelId] = {}
    end

    ZO_GameMenu_AddSettingPanel(shortcutData)
end

local function RegisterGamepadOptionsPanel()
    local LGO = LibGamepadOptions
    if gamepadOptionsRegistered or not (LGO and LGO.RegisterAddon) or (tonumber(LGO.version) or 0) < MIN_GAMEPAD_OPTIONS_LIB_VERSION then
        return
    end

    gamepadOptionsRegistered = true

    local function SetBoolean(key, value, afterChange)
        sv[key] = value and true or false
        if afterChange then
            afterChange()
        end
    end

    LGO:RegisterAddon(ADDON_NAME, {
        name = OPTIONS_SHORTCUT_TITLE,
        displayName = ADDON_TITLE,
        categoryName = OPTIONS_SHORTCUT_TITLE,
        directOpen = true,
        showInRoot = false,
        tooltip = "Quick controller access for " .. ADDON_TITLE .. ".",
        sortOrder = 10,
    }, {
        {
            type = "header",
            name = "Toggles",
        },
        {
            type = "checkbox",
            name = "Disable aim assist",
            tooltip = "Sets ESO's exposed aim-assist intensity values to 0 while keeping native gamepad input. Presets control this while Advanced Mode is off.",
            getFunc = function() return IsEffectiveTuningEnabled("disableAimAssist") end,
            setFunc = function(value)
                SetBoolean("disableAimAssist", value, function() ApplySettingsSoon(false) end)
            end,
            disabled = IsPresetModeActive,
            default = defaults.disableAimAssist,
        },
        {
            type = "checkbox",
            name = "Disable acceleration",
            tooltip = "Disables ESO's exposed camera smoothing and makes stick input feel more direct. Presets control this while Advanced Mode is off.",
            getFunc = function() return IsEffectiveTuningEnabled("reduceAcceleration") end,
            setFunc = function(value)
                SetBoolean("reduceAcceleration", value, function() ApplySettingsSoon(false) end)
            end,
            disabled = IsPresetModeActive,
            default = defaults.reduceAcceleration,
        },
        {
            type = "checkbox",
            name = "1:1 horizontal / vertical",
            tooltip = "Uses the horizontal camera value for both camera axes. Presets control this while Advanced Mode is off.",
            getFunc = function() return IsEffectiveTuningEnabled("oneToOneSensitivity") end,
            setFunc = function(value)
                SetBoolean("oneToOneSensitivity", value, function() ApplySettingsSoon(false) end)
            end,
            disabled = IsPresetModeActive,
            default = defaults.oneToOneSensitivity,
        },
        {
            type = "checkbox",
            name = "Sprint 1:1",
            tooltip = "Uses Zoruah's measured 1.95x sprint compensation so on-foot sprint camera turning matches regular turning more closely. Presets control this while Advanced Mode is off.",
            getFunc = function() return IsEffectiveTuningEnabled("sprintOneToOneSensitivity") end,
            setFunc = function(value)
                SetBoolean("sprintOneToOneSensitivity", value, function()
                    ApplySettingsSoon(false)
                    StartSprintSensitivityPolling()
                    UpdateSprintSensitivity()
                end)
            end,
            disabled = IsPresetModeActive,
            default = defaults.sprintOneToOneSensitivity,
        },
        {
            type = "checkbox",
            name = "Advanced Mode",
            tooltip = "Unlocks manual tuning sliders while preserving your custom values.",
            getFunc = function() return IsAdvancedMode() end,
            setFunc = function(value)
                SetAdvancedMode(value)
            end,
            default = defaults.advancedMode,
        },
        {
            type = "dropdown",
            name = "Preset",
            tooltip = "Choose ESO Default or one of Zoruah's tuned profiles. Disabled while Advanced Mode is on.",
            choices = presetChoices,
            choicesValues = presetChoiceValues,
            getFunc = function() return sv.presetMode end,
            setFunc = ApplyPresetMode,
            disabled = IsAdvancedMode,
            default = defaults.presetMode,
        },
        {
            type = "header",
            name = "Sensitivity",
        },
        {
            type = "slider",
            name = "Horizontal sensitivity",
            tooltip = "Right-stick left/right camera speed. This can go higher than ESO's normal menu slider.",
            min = 0.10,
            max = 3.00,
            step = 0.01,
            decimals = 2,
            getFunc = function() return GetEffectiveTuningValue("horizontalSensitivity") end,
            setFunc = function(value)
                sv.horizontalSensitivity = ClampAndRound(value, defaults.horizontalSensitivity, 0.10, 3.00, 0.01)
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
            end,
            disabled = function() return not IsAdvancedMode() end,
            default = defaults.horizontalSensitivity,
        },
        {
            type = "slider",
            name = "Sprint sensitivity",
            tooltip = "Manual on-foot sprint camera multiplier. Disabled while Sprint 1:1 is on.",
            min = 1.00,
            max = 10.00,
            step = 0.25,
            decimals = 2,
            getFunc = function() return GetEffectiveSprintSensitivityMultiplier() end,
            setFunc = function(value)
                sv.sprintSensitivityMultiplier = ClampAndRound(value, defaults.sprintSensitivityMultiplier, 1.00, 10.00, 0.25)
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
                StartSprintSensitivityPolling()
                UpdateSprintSensitivity()
                SetCameraSensitivity()
            end,
            disabled = function() return not IsAdvancedMode() or IsEffectiveTuningEnabled("sprintOneToOneSensitivity") end,
            default = defaults.sprintSensitivityMultiplier,
        },
        {
            type = "slider",
            name = "Vertical sensitivity",
            tooltip = "Right-stick up/down camera speed when 1:1 mode is off.",
            min = 0.10,
            max = 3.00,
            step = 0.01,
            decimals = 2,
            getFunc = function() return GetEffectiveTuningValue("verticalSensitivity") end,
            setFunc = function(value)
                sv.verticalSensitivity = ClampAndRound(value, defaults.verticalSensitivity, 0.10, 3.00, 0.01)
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
            end,
            disabled = function() return not IsAdvancedMode() or IsEffectiveTuningEnabled("oneToOneSensitivity") end,
            default = defaults.verticalSensitivity,
        },
        {
            type = "header",
            name = "Right Stick",
        },
        {
            type = "slider",
            name = "Right-stick inner deadzone",
            tooltip = "How far the right stick must move before the camera starts. Minimum is 0.05 to prevent drift.",
            min = 0.05,
            max = 0.30,
            step = 0.01,
            decimals = 2,
            getFunc = function() return GetEffectiveTuningValue("rightStickInnerDeadzone") end,
            setFunc = function(value)
                sv.rightStickInnerDeadzone = ClampAndRound(value, defaults.rightStickInnerDeadzone, 0.05, 0.30, 0.01)
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
            end,
            disabled = function() return not IsAdvancedMode() end,
            default = defaults.rightStickInnerDeadzone,
        },
        {
            type = "slider",
            name = "Right-stick outer threshold",
            tooltip = "How soon the right stick reaches full camera speed.",
            min = 0.60,
            max = 1.00,
            step = 0.01,
            decimals = 2,
            getFunc = function() return GetEffectiveTuningValue("rightStickOuterThreshold") end,
            setFunc = function(value)
                sv.rightStickOuterThreshold = ClampAndRound(value, defaults.rightStickOuterThreshold, 0.60, 1.00, 0.01)
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
            end,
            disabled = function() return not IsAdvancedMode() end,
            default = defaults.rightStickOuterThreshold,
        },
        {
            type = "header",
            name = "Left Stick",
        },
        {
            type = "slider",
            name = "Left-stick inner deadzone",
            tooltip = "How far the left stick must move before movement begins. Minimum is 0.05 to prevent drift.",
            min = 0.05,
            max = 0.30,
            step = 0.01,
            decimals = 2,
            getFunc = function() return GetEffectiveTuningValue("leftStickInnerDeadzone") end,
            setFunc = function(value)
                sv.leftStickInnerDeadzone = ClampAndRound(value, defaults.leftStickInnerDeadzone, 0.05, 0.30, 0.01)
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
            end,
            disabled = function() return not IsAdvancedMode() end,
            default = defaults.leftStickInnerDeadzone,
        },
        {
            type = "slider",
            name = "Left-stick outer threshold",
            tooltip = "How soon movement reaches full input.",
            min = 0.60,
            max = 1.00,
            step = 0.01,
            decimals = 2,
            getFunc = function() return GetEffectiveTuningValue("leftStickOuterThreshold") end,
            setFunc = function(value)
                sv.leftStickOuterThreshold = ClampAndRound(value, defaults.leftStickOuterThreshold, 0.60, 1.00, 0.01)
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
            end,
            disabled = function() return not IsAdvancedMode() end,
            default = defaults.leftStickOuterThreshold,
        },
        {
            type = "header",
            name = "Triggers",
        },
        {
            type = "slider",
            name = "Trigger deadzone",
            tooltip = "How far triggers must be pressed before ESO counts them.",
            min = 0.00,
            max = 0.50,
            step = 0.01,
            decimals = 2,
            getFunc = function() return GetEffectiveTuningValue("triggerDeadzone") end,
            setFunc = function(value)
                sv.triggerDeadzone = ClampAndRound(value, defaults.triggerDeadzone, 0.00, 0.50, 0.01)
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
            end,
            disabled = function() return not IsAdvancedMode() end,
            default = defaults.triggerDeadzone,
        },
        {
            type = "header",
            name = "Other",
        },
        {
            type = "header",
            name = "Profiles",
        },
        {
            type = "checkbox",
            name = "Character-specific profile",
            tooltip = "Off uses one global profile. On gives this character its own saved tuning.",
            getFunc = function() return accountSv.profileScope == PROFILE_SCOPE_CHARACTER end,
            setFunc = function(value)
                SetProfileScope(value and PROFILE_SCOPE_CHARACTER or PROFILE_SCOPE_GLOBAL, value)
                ApplySettingsSoon(false)
            end,
            default = false,
        },
        {
            type = "header",
            name = "Backups",
        },
        {
            type = "button",
            name = "Create Backup",
            tooltip = "Saves the current profile into the backup list stored in ESO SavedVariables.",
            func = CreateSettingsBackup,
        },
        {
            type = "button",
            name = "Restore Backup",
            tooltip = "Restores the newest saved backup that differs from the current profile.",
            func = RestoreSettingsBackup,
            disabled = function() return not HasRestorableSettingsBackup() end,
        },
        {
            type = "header",
            name = "Options",
        },
        {
            type = "checkbox",
            name = "Show chat messages",
            tooltip = "Shows short chat messages when settings apply or an action fails.",
            getFunc = function() return sv.showChatMessages end,
            setFunc = function(value)
                sv.showChatMessages = value and true or false
            end,
            default = defaults.showChatMessages,
        },
    })
end

local function RegisterSettingsPanel()
    local LAM = LibAddonMenu2

    RegisterPanelColorCallbacks()

    local settingsPanel = LAM:RegisterAddonPanel(ADDON_NAME .. "Options", {
        type = "panel",
        name = ADDON_TITLE,
        displayName = ADDON_TITLE,
        author = AUTHOR,
        version = VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
        website = function() return SocialUrl("youtube") end,
        feedback = function() return SocialUrl("x") end,
    })

    LAM:RegisterOptionControls(ADDON_NAME .. "Options", {
        {
            type = "header",
            name = Header("Toggles"),
        },
        OnOffDropdown(
            "Disable aim assist",
            Tooltip("Aim Assist", "Sets ESO's exposed aim-assist intensity values to 0 while keeping native gamepad input. Presets control this while Advanced Mode is off."),
            function() return IsEffectiveTuningEnabled("disableAimAssist") end,
            function(value)
                sv.disableAimAssist = value
                ApplySettingsSoon(false)
            end,
            defaults.disableAimAssist,
            IsPresetModeActive
        ),
        OnOffDropdown(
            "Disable acceleration",
            Tooltip("Acceleration", "Disables ESO's exposed camera smoothing and pairs cleanly with tuned outer thresholds. Presets control this while Advanced Mode is off."),
            function() return IsEffectiveTuningEnabled("reduceAcceleration") end,
            function(value)
                sv.reduceAcceleration = value
                ApplySettingsSoon(false)
            end,
            defaults.reduceAcceleration,
            IsPresetModeActive
        ),
        OnOffDropdown(
            "1:1 horizontal / vertical",
            Tooltip("1:1 Sensitivity", "Uses the horizontal camera value for both camera axes. Presets control this while Advanced Mode is off."),
            function() return IsEffectiveTuningEnabled("oneToOneSensitivity") end,
            function(value)
                sv.oneToOneSensitivity = value
                ApplySettingsSoon(false)
            end,
            defaults.oneToOneSensitivity,
            IsPresetModeActive
        ),
        OnOffDropdown(
            "Sprint 1:1",
            Tooltip("Sprint 1:1", "Uses Zoruah's measured 1.95x sprint compensation so on-foot sprint camera turning matches regular camera turning more closely. Presets control this while Advanced Mode is off."),
            function() return IsEffectiveTuningEnabled("sprintOneToOneSensitivity") end,
            function(value)
                sv.sprintOneToOneSensitivity = value
                ApplySettingsSoon(false)
                StartSprintSensitivityPolling()
                UpdateSprintSensitivity()
                RefreshOnOffTextColorsSoon()
            end,
            defaults.sprintOneToOneSensitivity,
            IsPresetModeActive
        ),
        OnOffDropdown(
            "Advanced Mode",
            Tooltip("Advanced Mode", "On unlocks every manual tuning slider and keeps those custom values saved. Off uses the selected preset without deleting your Advanced Mode settings."),
            function() return IsAdvancedMode() end,
            function(value)
                SetAdvancedMode(value)
            end,
            defaults.advancedMode
        ),
        {
            type = "dropdown",
            name = "Preset",
            tooltip = Tooltip("Preset", "Choose ESO Default for baseline behavior or pick one of Zoruah's tuned profiles for quick setup. Presets are locked while Advanced Mode is on so custom tuning never gets overwritten."),
            choices = presetChoices,
            choicesValues = presetChoiceValues,
            choicesTooltips = presetChoiceTooltips,
            scrollable = true,
            getFunc = function() return sv.presetMode end,
            setFunc = function(value)
                ApplyPresetMode(value)
            end,
            disabled = IsAdvancedMode,
            default = defaults.presetMode,
        },
        {
            type = "header",
            name = Header("Advanced Tuning"),
        },
        {
            type = "header",
            name = Header("Sensitivity"),
        },
        {
            type = "slider",
            name = "Horizontal sensitivity",
            tooltip = Tooltip("Horizontal Camera Speed", "Controls right-stick left/right camera speed. This can go higher than ESO's normal menu slider. Raise it for faster turns; lower it for more precise target tracking."),
            min = 0.10,
            max = 3.00,
            step = 0.01,
            decimals = 2,
            getFunc = function() return GetEffectiveTuningValue("horizontalSensitivity") end,
            setFunc = function(value)
                sv.horizontalSensitivity = value
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
            end,
            disabled = function() return not IsAdvancedMode() end,
            default = defaults.horizontalSensitivity,
        },
        {
            type = "slider",
            name = function()
                if IsEffectiveTuningEnabled("sprintOneToOneSensitivity") then
                    return "Sprint sensitivity (" .. FormatMultiplier(SPRINT_1TO1_MULTIPLIER) .. " 1:1)"
                end

                return "Sprint sensitivity (" .. FormatMultiplier(GetEffectiveTuningValue("sprintSensitivityMultiplier")) .. ")"
            end,
            reference = SPRINT_SENSITIVITY_SLIDER_REFERENCE,
            tooltip = Tooltip("Sprint Sensitivity", "Manual sprint camera multiplier for on-foot sprinting. This slider is disabled while Sprint 1:1 is on, because Sprint 1:1 uses the measured 1.95x compensation instead."),
            min = 1.00,
            max = 10.00,
            step = 0.25,
            decimals = 2,
            getFunc = function() return GetEffectiveSprintSensitivityMultiplier() end,
            setFunc = function(value)
                sv.sprintSensitivityMultiplier = ClampAndRound(value, defaults.sprintSensitivityMultiplier, 1.00, 10.00, 0.25)
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
                StartSprintSensitivityPolling()
                UpdateSprintSensitivity()
                SetCameraSensitivity()
                RefreshOnOffTextColorsSoon()
            end,
            disabled = function() return not IsAdvancedMode() or IsEffectiveTuningEnabled("sprintOneToOneSensitivity") end,
            default = defaults.sprintSensitivityMultiplier,
        },
        {
            type = "slider",
            name = "Vertical sensitivity",
            tooltip = Tooltip("Vertical Camera Speed", "Controls right-stick up/down camera speed when 1:1 mode is off. While 1:1 is on, ESO uses the horizontal value for both axes."),
            min = 0.10,
            max = 3.00,
            step = 0.01,
            decimals = 2,
            getFunc = function() return GetEffectiveTuningValue("verticalSensitivity") end,
            setFunc = function(value)
                sv.verticalSensitivity = value
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
            end,
            disabled = function() return not IsAdvancedMode() or IsEffectiveTuningEnabled("oneToOneSensitivity") end,
            default = defaults.verticalSensitivity,
        },
        {
            type = "header",
            name = Header("Right Stick"),
        },
        {
            type = "slider",
            name = "Right-stick inner deadzone",
            tooltip = Tooltip("Right Inner Deadzone", "Controls how far the right stick must move before the camera starts. Values below 0.05 are forced to 0.05 to prevent stick drift on normal and hall effect controllers."),
            min = 0.05,
            max = 0.30,
            step = 0.01,
            decimals = 2,
            getFunc = function() return GetEffectiveTuningValue("rightStickInnerDeadzone") end,
            setFunc = function(value)
                sv.rightStickInnerDeadzone = value
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
            end,
            disabled = function() return not IsAdvancedMode() end,
            default = defaults.rightStickInnerDeadzone,
        },
        {
            type = "slider",
            name = "Right-stick outer threshold",
            tooltip = Tooltip("Right Outer Threshold", "Controls how soon the right stick reaches full camera speed. Lower values reduce ramp-up and feel snappier; higher values keep more fine control near the edge."),
            min = 0.60,
            max = 1.00,
            step = 0.01,
            decimals = 2,
            getFunc = function() return GetEffectiveTuningValue("rightStickOuterThreshold") end,
            setFunc = function(value)
                sv.rightStickOuterThreshold = value
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
            end,
            disabled = function() return not IsAdvancedMode() end,
            default = defaults.rightStickOuterThreshold,
        },
        {
            type = "header",
            name = Header("Left Stick"),
        },
        {
            type = "slider",
            name = "Left-stick inner deadzone",
            tooltip = Tooltip("Left Inner Deadzone", "Controls how far the left stick must move before movement begins. Values below 0.05 are forced to 0.05, which avoids drift without hiding real movement input."),
            min = 0.05,
            max = 0.30,
            step = 0.01,
            decimals = 2,
            getFunc = function() return GetEffectiveTuningValue("leftStickInnerDeadzone") end,
            setFunc = function(value)
                sv.leftStickInnerDeadzone = value
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
            end,
            disabled = function() return not IsAdvancedMode() end,
            default = defaults.leftStickInnerDeadzone,
        },
        {
            type = "slider",
            name = "Left-stick outer threshold",
            tooltip = Tooltip("Left Outer Threshold", "Controls how soon movement reaches full input. Lower can make sprinting and strafing feel more immediate, while higher values preserve more gradual walking control."),
            min = 0.60,
            max = 1.00,
            step = 0.01,
            decimals = 2,
            getFunc = function() return GetEffectiveTuningValue("leftStickOuterThreshold") end,
            setFunc = function(value)
                sv.leftStickOuterThreshold = value
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
            end,
            disabled = function() return not IsAdvancedMode() end,
            default = defaults.leftStickOuterThreshold,
        },
        {
            type = "header",
            name = Header("Triggers"),
        },
        {
            type = "slider",
            name = "Trigger deadzone",
            tooltip = Tooltip("Trigger Deadzone", "Controls how far triggers must be pressed before ESO counts them. Lower responds sooner; raise it if a trigger activates by accident."),
            min = 0.00,
            max = 0.50,
            step = 0.01,
            decimals = 2,
            getFunc = function() return GetEffectiveTuningValue("triggerDeadzone") end,
            setFunc = function(value)
                sv.triggerDeadzone = value
                MarkAdvancedForManualChange()
                ApplySettingsSoon(true)
            end,
            disabled = function() return not IsAdvancedMode() end,
            default = defaults.triggerDeadzone,
        },
        {
            type = "header",
            name = Header("Share Codes"),
        },
        {
            type = "editbox",
            name = "Export code",
            tooltip = Tooltip("Export", "Click the box, press Ctrl+A, then Ctrl+C to copy a compact ZGT1 share code. It stores the preset, profile scope, toggles, sensitivities, deadzones, and trigger setting without creating files."),
            isExtraWide = true,
            maxChars = 64,
            getFunc = GetExportCode,
            setFunc = function(value)
                sv.exportCode = value
            end,
        },
        {
            type = "editbox",
            name = "Import code",
            tooltip = Tooltip("Import", "Paste or type a ZGT1 share code here, then press Apply Import. This control is PC UI only because gamepad mode cannot reliably access clipboard-based share codes."),
            reference = IMPORT_CODE_EDITBOX_REFERENCE,
            isExtraWide = true,
            maxChars = 64,
            getFunc = function() return sv.importCode or "" end,
            setFunc = function(value)
                sv.importCode = value
                RefreshImportValidationControls(value)
            end,
            default = "",
        },
        {
            type = "description",
            text = GetImportCodeValidationText,
            reference = IMPORT_CODE_STATUS_REFERENCE,
        },
        {
            type = "button",
            name = "Apply Import",
            reference = IMPORT_APPLY_BUTTON_REFERENCE,
            tooltip = Tooltip("Apply Import", "Confirms the ZGT1 share code from the PC UI text field, updates the profile, and applies every imported setting immediately."),
            func = function() ImportSettingsCode(sv.importCode) end,
            disabled = function() return not IsImportCodeValid(sv.importCode) end,
        },
        {
            type = "header",
            name = Header("Socials"),
        },
        {
            type = "button",
            name = "YouTube",
            tooltip = Tooltip("Follow Official Zoruah", SocialUrl("youtube")),
            func = function() OpenUrl(SocialUrl("youtube")) end,
        },
        {
            type = "button",
            name = "TikTok",
            tooltip = Tooltip("Follow Official Zoruah", SocialUrl("tiktok")),
            func = function() OpenUrl(SocialUrl("tiktok")) end,
        },
        {
            type = "button",
            name = "Twitch",
            tooltip = Tooltip("Follow Official Zoruah", SocialUrl("twitch")),
            func = function() OpenUrl(SocialUrl("twitch")) end,
        },
        {
            type = "button",
            name = "X",
            tooltip = Tooltip("Follow Official Zoruah", SocialUrl("x")),
            func = function() OpenUrl(SocialUrl("x")) end,
        },
        {
            type = "button",
            name = "Instagram",
            tooltip = Tooltip("Follow Official Zoruah", SocialUrl("instagram")),
            func = function() OpenUrl(SocialUrl("instagram")) end,
        },
        {
            type = "header",
            name = Header("Other"),
        },
        {
            type = "header",
            name = Header("Profiles"),
        },
        OnOffDropdown(
            "Character-specific profile",
            Tooltip("Profiles", "Off uses one global profile for every character. On gives this character its own settings while keeping the global profile saved for other characters."),
            function() return accountSv.profileScope == PROFILE_SCOPE_CHARACTER end,
            function(value)
                SetProfileScope(value and PROFILE_SCOPE_CHARACTER or PROFILE_SCOPE_GLOBAL, value)
                ApplySettingsSoon(false)
            end,
            false
        ),
        {
            type = "header",
            name = Header("Backups"),
        },
        {
            type = "button",
            name = "Create Backup",
            tooltip = Tooltip("Settings Backup", "Saves the current profile into the backup list stored in ESO's SavedVariables file. Backups survive Minion updates because they are stored outside the add-on folder."),
            func = CreateSettingsBackup,
        },
        {
            type = "button",
            name = "Restore Backup",
            tooltip = Tooltip("Settings Backup", "Restores the newest saved backup that is different from your current profile. Backups are stored in ESO's SavedVariables file and survive Minion updates."),
            func = RestoreSettingsBackup,
            disabled = function() return not HasRestorableSettingsBackup() end,
        },
        {
            type = "header",
            name = Header("Options"),
        },
        OnOffDropdown(
            "Show chat messages",
            Tooltip("Chat Messages", "Shows a short chat message when settings apply, import fails, or a social link cannot open. Turn this off for a cleaner chat box."),
            function() return sv.showChatMessages end,
            function(value)
                sv.showChatMessages = value
            end,
            defaults.showChatMessages
        ),
    })

    RegisterKeyboardOptionsShortcut(settingsPanel, LAM)
    RefreshOnOffTextColorsSoon()
end

local function OnSprintStartedCombatEvent()
    StartSprintSensitivityMonitor(SPRINT_FALLBACK_WINDOW_MS)
end

local function OnSprintEndedCombatEvent()
    ClearSprintSensitivityBoost()
end

local function OnMountedSprintCombatEvent()
    ResetSprintSensitivityState(SPRINT_INTERACTION_BLOCK_MS)
end

local function OnSprintEffectChanged(_, changeType)
    if IsPlayerMounted() then
        ClearSprintSensitivityBoost()
        return
    end

    if changeType == EFFECT_RESULT_FADED then
        ClearSprintSensitivityBoost()
        return
    end

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        StartSprintSensitivityMonitor(SPRINT_FALLBACK_WINDOW_MS)
    end
end

local function OnMountedStateChanged(eventCodeOrMounted, mounted)
    local isMounted = mounted
    if isMounted == nil and type(eventCodeOrMounted) == "boolean" then
        isMounted = eventCodeOrMounted
    end

    if isMounted then
        ResetSprintSensitivityState(SPRINT_INTERACTION_BLOCK_MS)
    else
        ResetSprintSensitivityState(SPRINT_ACTION_BLOCK_MS)
    end
end

local function OnActionSlotAbilityUsed()
    ResetSprintSensitivityState(SPRINT_ACTION_BLOCK_MS)
end

local function OnPlayerStateReset()
    ResetSprintSensitivityState(SPRINT_TRANSITION_BLOCK_MS)
end

local function OnInteractionStateReset()
    ResetSprintSensitivityState(SPRINT_INTERACTION_BLOCK_MS)
end

local function OnCameraUiModeChanged()
    ResetSprintSensitivityState(SPRINT_INTERACTION_BLOCK_MS)
end

local function RegisterSprintSensitivityEvents()
    local function RegisterResetEvent(suffix, eventId, callback)
        EVENT_MANAGER:RegisterForEvent(ADDON_NAME .. suffix, eventId, callback or OnPlayerStateReset)
    end

    local function RegisterSprintCombatEvent(suffix, result, abilityId, callback, combatUnitFilter)
        local eventName = ADDON_NAME .. suffix
        local unitFilter = combatUnitFilter or REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE
        EVENT_MANAGER:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, callback)

        if abilityId then
            EVENT_MANAGER:AddFilterForEvent(
                eventName,
                EVENT_COMBAT_EVENT,
                REGISTER_FILTER_IS_ERROR, false,
                unitFilter, COMBAT_UNIT_TYPE_PLAYER,
                REGISTER_FILTER_COMBAT_RESULT, result,
                REGISTER_FILTER_ABILITY_ID, abilityId
            )
        else
            EVENT_MANAGER:AddFilterForEvent(
                eventName,
                EVENT_COMBAT_EVENT,
                REGISTER_FILTER_IS_ERROR, false,
                unitFilter, COMBAT_UNIT_TYPE_PLAYER,
                REGISTER_FILTER_COMBAT_RESULT, result
            )
        end
    end

    RegisterSprintCombatEvent("SprintEffectGained", ACTION_RESULT_EFFECT_GAINED, SPRINT_ABILITY_ID, OnSprintStartedCombatEvent)
    RegisterSprintCombatEvent("SprintEffectGainedDuration", ACTION_RESULT_EFFECT_GAINED_DURATION, SPRINT_ABILITY_ID, OnSprintStartedCombatEvent)
    RegisterSprintCombatEvent("SprintEffectFaded", ACTION_RESULT_EFFECT_FADED, SPRINT_ABILITY_ID, OnSprintEndedCombatEvent)
    RegisterSprintCombatEvent("SprintResult", ACTION_RESULT_SPRINTING, nil, OnSprintStartedCombatEvent)
    RegisterSprintCombatEvent("SprintResultSource", ACTION_RESULT_SPRINTING, nil, OnSprintStartedCombatEvent, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE)
    RegisterSprintCombatEvent("MountSprintEffectGained", ACTION_RESULT_EFFECT_GAINED, MOUNT_SPRINT_ABILITY_ID, OnMountedSprintCombatEvent)
    RegisterSprintCombatEvent("MountSprintEffectGainedDuration", ACTION_RESULT_EFFECT_GAINED_DURATION, MOUNT_SPRINT_ABILITY_ID, OnMountedSprintCombatEvent)

    local powerEventName = ADDON_NAME .. "SprintPower"
    EVENT_MANAGER:RegisterForEvent(powerEventName, EVENT_POWER_UPDATE, OnSprintPowerUpdate)
    EVENT_MANAGER:AddFilterForEvent(
        powerEventName,
        EVENT_POWER_UPDATE,
        REGISTER_FILTER_UNIT_TAG, "player",
        REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_STAMINA
    )
    lastStaminaPowerValue = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_STAMINA)

    local effectEventName = ADDON_NAME .. "SprintEffectChanged"
    EVENT_MANAGER:RegisterForEvent(effectEventName, EVENT_EFFECT_CHANGED, OnSprintEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(
        effectEventName,
        EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_UNIT_TAG, "player",
        REGISTER_FILTER_ABILITY_ID, SPRINT_ABILITY_ID
    )

    RegisterResetEvent("MountedState", EVENT_MOUNTED_STATE_CHANGED, OnMountedStateChanged)
    RegisterResetEvent("ActionSlotAbilityUsed", EVENT_ACTION_SLOT_ABILITY_USED, OnActionSlotAbilityUsed)
    RegisterResetEvent("ActionSlotAbilityUsedWrongWeapon", EVENT_ACTION_SLOT_ABILITY_USED_WRONG_WEAPON, OnActionSlotAbilityUsed)
    RegisterResetEvent("PlayerActivatedSprintReset", EVENT_PLAYER_ACTIVATED, OnPlayerStateReset)
    RegisterResetEvent("PlayerDeactivatedSprintReset", EVENT_PLAYER_DEACTIVATED, OnPlayerStateReset)
    RegisterResetEvent("PlayerDeadSprintReset", EVENT_PLAYER_DEAD, OnPlayerStateReset)
    RegisterResetEvent("PlayerAliveSprintReset", EVENT_PLAYER_ALIVE, OnPlayerStateReset)
    RegisterResetEvent("PlayerSwimmingSprintReset", EVENT_PLAYER_SWIMMING, OnPlayerStateReset)
    RegisterResetEvent("ZoneChangedSprintReset", EVENT_ZONE_CHANGED, OnPlayerStateReset)
    RegisterResetEvent("ClientInteractResultSprintReset", EVENT_CLIENT_INTERACT_RESULT, OnInteractionStateReset)
    RegisterResetEvent("GameCameraUiModeSprintReset", EVENT_GAME_CAMERA_UI_MODE_CHANGED, OnCameraUiModeChanged)
    RegisterResetEvent("StartFastTravelSprintReset", EVENT_START_FAST_TRAVEL_INTERACTION, OnInteractionStateReset)
    RegisterResetEvent("EndFastTravelSprintReset", EVENT_END_FAST_TRAVEL_INTERACTION, OnInteractionStateReset)

end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    local legacyAccountSv = GetLegacyAccountSavedVariables()
    accountSv = ZO_SavedVars:NewAccountWide(SV_NAME, SV_VERSION, GetWorldName(), defaults)
    characterSv = ZO_SavedVars:NewCharacterIdSettings(SV_NAME, SV_VERSION, nil, defaults)

    MigrateAccountSavedVariablesToServer(legacyAccountSv, accountSv)
    InitializeProfile(accountSv)
    InitializeProfile(characterSv)
    SetActiveProfile(false)
    RegisterSettingsPanel()
    RegisterGamepadOptionsPanel()
    RegisterSprintSensitivityEvents()
    RefreshOnOffTextColorsSoon()
    zo_callLater(function() ApplySettings(false) end, 1500)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
