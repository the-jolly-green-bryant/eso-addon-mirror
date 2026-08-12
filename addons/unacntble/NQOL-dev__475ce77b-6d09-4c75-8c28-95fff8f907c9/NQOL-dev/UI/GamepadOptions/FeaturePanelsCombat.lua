NQOL = NQOL or {}
local GamepadOptions = NQOL.GamepadOptions

local PanelIds = GamepadOptions.PanelIds
local ULTIMATE_COUNTDOWN_FRONT_PANEL_ID = PanelIds.ULTIMATE_COUNTDOWN_FRONT
local ULTIMATE_COUNTDOWN_BACK_PANEL_ID = PanelIds.ULTIMATE_COUNTDOWN_BACK
local COMBAT_INFINITE_ARCHIVE_PANEL_ID = PanelIds.COMBAT_INFINITE_ARCHIVE
local COMBAT_MISCELLANEOUS_PANEL_ID = PanelIds.COMBAT_MISCELLANEOUS
local TRIAL_TIMER_PANEL_ID = PanelIds.TRIAL_TIMER

local function BuildUltimateCountdownEnabledOption(panelId, settingId, countdownKey)
    local ultimateCountdown = NQOL.Features.UltimateCountdown
    return GamepadOptions.BuildCheckboxOption(panelId, settingId, ultimateCountdown.GetEnabledLabel(), ultimateCountdown.GetEnabledTooltip(countdownKey), function()
        return ultimateCountdown.GetEnabled(countdownKey)
    end, function(value)
        ultimateCountdown.SetEnabled(countdownKey, value)
    end, nil, function()
        return ultimateCountdown.GetEnabledDefault(countdownKey)
    end)
end

local function BuildUltimateCountdownSecondsOption(panelId, settingId, countdownKey)
    local ultimateCountdown = NQOL.Features.UltimateCountdown
    return GamepadOptions.BuildSliderOption(panelId, settingId, ultimateCountdown.GetSecondsLabel(), ultimateCountdown.GetSecondsTooltip(), ultimateCountdown.GetSecondsMin(), ultimateCountdown.GetSecondsMax(), NQOL.L("common.seconds_format"), function()
        return ultimateCountdown.GetSeconds(countdownKey)
    end, function(value)
        ultimateCountdown.SetSeconds(countdownKey, value)
    end, 1)
end

local function BuildUltimateCountdownShowInSettingsOption(panelId, settingId, countdownKey)
    local ultimateCountdown = NQOL.Features.UltimateCountdown
    return GamepadOptions.BuildCheckboxOption(panelId, settingId, ultimateCountdown.GetShowInSettingsLabel(), ultimateCountdown.GetShowInSettingsTooltip(countdownKey), function()
        return ultimateCountdown.GetShowInSettings(countdownKey)
    end, function(value)
        ultimateCountdown.SetShowInSettings(countdownKey, value)
    end)
end

local function BuildUltimateCountdownHorizontalPositionOption(panelId, settingId, countdownKey)
    local ultimateCountdown = NQOL.Features.UltimateCountdown
    return GamepadOptions.BuildPositionSliderOption(panelId, settingId, ultimateCountdown.GetHorizontalPositionLabel(), ultimateCountdown.GetHorizontalPositionTooltip(countdownKey), 0, 100, "%.0f", function()
        return ultimateCountdown.GetHorizontalPosition(countdownKey)
    end, function(value)
        ultimateCountdown.SetHorizontalPosition(countdownKey, value)
    end)
end

local function BuildUltimateCountdownVerticalPositionOption(panelId, settingId, countdownKey)
    local ultimateCountdown = NQOL.Features.UltimateCountdown
    return GamepadOptions.BuildPositionSliderOption(panelId, settingId, ultimateCountdown.GetVerticalPositionLabel(), ultimateCountdown.GetVerticalPositionTooltip(countdownKey), 0, 100, "%.0f", function()
        return ultimateCountdown.GetVerticalPosition(countdownKey)
    end, function(value)
        ultimateCountdown.SetVerticalPosition(countdownKey, value)
    end)
end

local function BuildUltimateCountdownFontOption(panelId, settingId, countdownKey)
    local ultimateCountdown = NQOL.Features.UltimateCountdown
    return GamepadOptions.BuildFiniteListOption(panelId, settingId, ultimateCountdown.GetFontLabel(), ultimateCountdown.GetFontTooltip(), ultimateCountdown.GetFontChoices(), ultimateCountdown.GetFontChoiceNames(), function()
        return ultimateCountdown.GetFont(countdownKey)
    end, function(value)
        ultimateCountdown.SetFont(countdownKey, value)
    end)
end

local function BuildUltimateCountdownFontSizeOption(panelId, settingId, countdownKey)
    local ultimateCountdown = NQOL.Features.UltimateCountdown
    return GamepadOptions.BuildValueStepSliderOption(panelId, settingId, ultimateCountdown.GetFontSizeLabel(), ultimateCountdown.GetFontSizeTooltip(), ultimateCountdown.GetFontSizeMin(), ultimateCountdown.GetFontSizeMax(), "%.0f", function()
        return ultimateCountdown.GetFontSize(countdownKey)
    end, function(value)
        ultimateCountdown.SetFontSize(countdownKey, value)
    end, 1)
end

local function BuildUltimateCountdownColorOption(panelId, settingId, countdownKey)
    local ultimateCountdown = NQOL.Features.UltimateCountdown
    return GamepadOptions.BuildColorOption(panelId, settingId, ultimateCountdown.GetColorLabel(), ultimateCountdown.GetColorTooltip(), function()
        return ultimateCountdown.GetColor(countdownKey)
    end, function(red, green, blue, alpha)
        ultimateCountdown.SetColor(countdownKey, red, green, blue, alpha)
    end)
end

local function BuildUltimateCountdownBackgroundOpacityOption(panelId, settingId, countdownKey)
    local ultimateCountdown = NQOL.Features.UltimateCountdown
    return GamepadOptions.BuildSliderOption(panelId, settingId, ultimateCountdown.GetBackgroundOpacityLabel(), ultimateCountdown.GetBackgroundOpacityTooltip(), ultimateCountdown.GetBackgroundOpacityMin(), ultimateCountdown.GetBackgroundOpacityMax(), "%.0f", function()
        return ultimateCountdown.GetBackgroundOpacity(countdownKey)
    end, function(value)
        ultimateCountdown.SetBackgroundOpacity(countdownKey, value)
    end, 1)
end

local function BuildUltimateCountdownBackgroundColorOption(panelId, settingId, countdownKey)
    local ultimateCountdown = NQOL.Features.UltimateCountdown
    return GamepadOptions.BuildColorOption(panelId, settingId, ultimateCountdown.GetBackgroundColorLabel(), ultimateCountdown.GetBackgroundColorTooltip(), function()
        return ultimateCountdown.GetBackgroundColor(countdownKey)
    end, function(red, green, blue, alpha)
        ultimateCountdown.SetBackgroundColor(countdownKey, red, green, blue, alpha)
    end)
end

local function BuildUltimateCountdownShapeOption(panelId, settingId, countdownKey)
    local ultimateCountdown = NQOL.Features.UltimateCountdown
    return GamepadOptions.BuildFiniteListOption(panelId, settingId, ultimateCountdown.GetShapeLabel(), ultimateCountdown.GetShapeTooltip(), ultimateCountdown.GetShapeChoices(), ultimateCountdown.GetShapeChoiceNames(), function()
        return ultimateCountdown.GetShape(countdownKey)
    end, function(value)
        ultimateCountdown.SetShape(countdownKey, value)
    end, function()
        return ultimateCountdown.GetShapeDefault(countdownKey)
    end)
end

local function BuildUltimateCountdownOptionsData(panelId, countdownKey)
    return {
        BuildUltimateCountdownEnabledOption(panelId, 1, countdownKey),
        BuildUltimateCountdownSecondsOption(panelId, 2, countdownKey),
        BuildUltimateCountdownShowInSettingsOption(panelId, 3, countdownKey),
        GamepadOptions.WithHeader(BuildUltimateCountdownHorizontalPositionOption(panelId, 4, countdownKey), NQOL.L("ui.headers.position_and_appearance_346f660")),
        BuildUltimateCountdownVerticalPositionOption(panelId, 5, countdownKey),
        BuildUltimateCountdownFontOption(panelId, 6, countdownKey),
        BuildUltimateCountdownFontSizeOption(panelId, 7, countdownKey),
        BuildUltimateCountdownColorOption(panelId, 8, countdownKey),
        BuildUltimateCountdownBackgroundOpacityOption(panelId, 9, countdownKey),
        BuildUltimateCountdownBackgroundColorOption(panelId, 10, countdownKey),
        BuildUltimateCountdownShapeOption(panelId, 11, countdownKey),
    }
end

function GamepadOptions.BuildUltimateCountdownFrontOptionsData()
    return BuildUltimateCountdownOptionsData(ULTIMATE_COUNTDOWN_FRONT_PANEL_ID, NQOL.Features.UltimateCountdown.GetFrontBarKey())
end

function GamepadOptions.BuildTrialTimerOptionsData()
    local timer = NQOL.Features.TrialTimer
    return {
        GamepadOptions.BuildCheckboxOption(TRIAL_TIMER_PANEL_ID, 1, timer.GetEnabledLabel(), timer.GetEnabledTooltip(), timer.GetEnabled, timer.SetEnabled, nil, timer.GetEnabledDefault),
        GamepadOptions.BuildCheckboxOption(TRIAL_TIMER_PANEL_ID, 2, timer.GetShowInSettingsLabel(), timer.GetShowInSettingsTooltip(), timer.GetShowInSettings, timer.SetShowInSettings),
        GamepadOptions.WithHeader(GamepadOptions.BuildCheckboxOption(TRIAL_TIMER_PANEL_ID, 3, timer.GetShowElapsedTimeLabel(), timer.GetShowElapsedTimeTooltip(), timer.GetShowElapsedTime, timer.SetShowElapsedTime), NQOL.L("features.trial_timer.components_header")),
        GamepadOptions.BuildCheckboxOption(TRIAL_TIMER_PANEL_ID, 4, timer.GetShowVitalityLabel(), timer.GetShowVitalityTooltip(), timer.GetShowVitality, timer.SetShowVitality),
        GamepadOptions.BuildCheckboxOption(TRIAL_TIMER_PANEL_ID, 5, timer.GetShowLiveScoreLabel(), timer.GetShowLiveScoreTooltip(), timer.GetShowLiveScore, timer.SetShowLiveScore),
        GamepadOptions.BuildCheckboxOption(TRIAL_TIMER_PANEL_ID, 6, timer.GetShowBestScoreLabel(), timer.GetShowBestScoreTooltip(), timer.GetShowBestScore, timer.SetShowBestScore),
        GamepadOptions.WithHeader(GamepadOptions.BuildPositionSliderOption(TRIAL_TIMER_PANEL_ID, 7, timer.GetHorizontalPositionLabel(), timer.GetHorizontalPositionTooltip(), 0, 100, "%.0f", timer.GetHorizontalPosition, timer.SetHorizontalPosition), NQOL.L("ui.headers.position_and_appearance_346f660")),
        GamepadOptions.BuildPositionSliderOption(TRIAL_TIMER_PANEL_ID, 8, timer.GetVerticalPositionLabel(), timer.GetVerticalPositionTooltip(), 0, 100, "%.0f", timer.GetVerticalPosition, timer.SetVerticalPosition),
        GamepadOptions.BuildFiniteListOption(TRIAL_TIMER_PANEL_ID, 9, timer.GetFontLabel(), timer.GetFontTooltip(), timer.GetFontChoices(), timer.GetFontChoiceNames(), timer.GetFont, timer.SetFont),
        GamepadOptions.BuildValueStepSliderOption(TRIAL_TIMER_PANEL_ID, 10, timer.GetFontSizeLabel(), timer.GetFontSizeTooltip(), timer.GetFontSizeMin(), timer.GetFontSizeMax(), "%.0f", timer.GetFontSize, timer.SetFontSize, 1),
        GamepadOptions.BuildColorOption(TRIAL_TIMER_PANEL_ID, 11, timer.GetColorLabel(), timer.GetColorTooltip(), timer.GetColor, timer.SetColor),
        GamepadOptions.BuildColorOption(TRIAL_TIMER_PANEL_ID, 12, timer.GetBackgroundColorLabel(), timer.GetBackgroundColorTooltip(), timer.GetBackgroundColor, timer.SetBackgroundColor),
        GamepadOptions.BuildSliderOption(TRIAL_TIMER_PANEL_ID, 13, timer.GetBackgroundOpacityLabel(), timer.GetBackgroundOpacityTooltip(), timer.GetBackgroundOpacityMin(), timer.GetBackgroundOpacityMax(), "%.0f", timer.GetBackgroundOpacity, timer.SetBackgroundOpacity, 1),
    }
end

function GamepadOptions.BuildCombatInfiniteArchiveOptionsData()
    local archive = NQOL.Features.CombatInfiniteArchive
    return {
        GamepadOptions.WithHeader(GamepadOptions.BuildCheckboxOption(COMBAT_INFINITE_ARCHIVE_PANEL_ID, 1, archive.GetTrackProgressLabel(), archive.GetTrackProgressTooltip(), archive.GetTrackProgress, function(value)
            archive.SetTrackProgress(value)
            GamepadOptions.RefreshCurrentOptionsList()
        end, nil, archive.GetTrackProgressDefault), "Tracking"),
        GamepadOptions.BuildCheckboxOption(COMBAT_INFINITE_ARCHIVE_PANEL_ID, 2, archive.GetLogStartLabel(), archive.GetLogStartTooltip(), archive.GetLogStart, archive.SetLogStart, archive.GetTrackProgress, archive.GetLogStartDefault),
        GamepadOptions.BuildCheckboxOption(COMBAT_INFINITE_ARCHIVE_PANEL_ID, 3, archive.GetLogBestLabel(), archive.GetLogBestTooltip(), archive.GetLogBest, archive.SetLogBest, archive.GetTrackProgress, archive.GetLogBestDefault),
        GamepadOptions.BuildCheckboxOption(COMBAT_INFINITE_ARCHIVE_PANEL_ID, 4, archive.GetLogStopLabel(), archive.GetLogStopTooltip(), archive.GetLogStop, archive.SetLogStop, archive.GetTrackProgress, archive.GetLogStopDefault),
    }
end

function GamepadOptions.BuildCombatMiscellaneousOptionsData()
    local miscellaneous = NQOL.Features.CombatMiscellaneous
    local option = GamepadOptions.BuildCheckboxOption(
        COMBAT_MISCELLANEOUS_PANEL_ID,
        1,
        miscellaneous.GetLCCrutchMirrorsRotateLabel(),
        miscellaneous.GetLCCrutchMirrorsRotateTooltip(),
        miscellaneous.GetLCCrutchMirrorsRotate,
        miscellaneous.SetLCCrutchMirrorsRotate,
        miscellaneous.IsCrutchAlertsAvailable,
        miscellaneous.GetLCCrutchMirrorsRotateDefault
    )
    option.gamepadIsEnabledCallback = miscellaneous.IsCrutchAlertsAvailable

    return {
        option,
    }
end

function GamepadOptions.BuildUltimateCountdownBackOptionsData()
    return BuildUltimateCountdownOptionsData(ULTIMATE_COUNTDOWN_BACK_PANEL_ID, NQOL.Features.UltimateCountdown.GetBackBarKey())
end
