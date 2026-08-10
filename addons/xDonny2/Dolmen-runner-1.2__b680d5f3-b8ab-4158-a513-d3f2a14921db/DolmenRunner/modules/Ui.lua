-- Minimal UI: pause-menu settings panel only (no in-game HUD).
local Ui = {}
local DR = DolmenRunner

local settingsWindowFocus = nil

local function SettingLabel(on)
    return on and "|c33FF33On|r" or "|cFF3333Off|r"
end

local function AddFocusEntries(focus, controls)
    for _, control in ipairs(controls) do
        if control and not control:IsHidden() then
            focus:AddEntry({ control = control })
        end
    end
end

local function SetupConsoleGamepadFocus()
    if not IsConsoleUI() or not DolmenRunnerSettingsWindow or settingsWindowFocus then
        return
    end
    SCENE_MANAGER:RegisterTopLevel(DolmenRunnerSettingsWindow, false)
    local movement = ZO_MovementController:New(MOVEMENT_CONTROLLER_DIRECTION_VERTICAL)
    settingsWindowFocus = ZO_GamepadFocus:New(DolmenRunnerSettingsWindow, movement)
end

local function RefreshSettingsFocusEntries()
    if not settingsWindowFocus then
        return
    end
    settingsWindowFocus:ClearEntries()
    AddFocusEntries(settingsWindowFocus, {
        DolmenRunnerSettingsWindowRunnerStartStop,
        DolmenRunnerSettingsWindowDirectionCW,
        DolmenRunnerSettingsWindowDirectionCCW,
        DolmenRunnerSettingsWindowAutoTravelToggle,
        DolmenRunnerSettingsWindowAutoDismissToggle,
        DolmenRunnerSettingsWindowReapplyBuffToggle,
    })
end

local function ActivateSettingsFocus()
    if settingsWindowFocus then
        RefreshSettingsFocusEntries()
        settingsWindowFocus:Activate()
    end
end

local function DeactivateSettingsFocus()
    if settingsWindowFocus then
        settingsWindowFocus:Deactivate()
    end
end

function Ui:RefreshSettings()
    local runnerLabel = DR.runner.started and GetString(DR_SETTINGS_LABEL_STOP) or GetString(DR_SETTINGS_LABEL_START)
    local direction = DR.runner:GetDirectionLabel()
    local s = DR.settings.runner

    if DolmenRunnerSettingsRunnerValue then
        DolmenRunnerSettingsRunnerValue:SetText(runnerLabel)
    end
    if DolmenRunnerSettingsDirectionCWValue then
        local cwSelected = direction == "CW"
        DolmenRunnerSettingsDirectionCWValue:SetText(cwSelected and "|c33FF33CW|r" or "CW")
    end
    if DolmenRunnerSettingsDirectionCCWValue then
        local ccwSelected = direction == "CCW"
        DolmenRunnerSettingsDirectionCCWValue:SetText(ccwSelected and "|c33FF33CCW|r" or "CCW")
    end
    if DolmenRunnerSettingsAutoTravelValue then
        DolmenRunnerSettingsAutoTravelValue:SetText(SettingLabel(s.autoTravel))
    end
    if DolmenRunnerSettingsAutoDismissValue then
        DolmenRunnerSettingsAutoDismissValue:SetText(SettingLabel(s.autoDismiss))
    end
    if DolmenRunnerSettingsReapplyBuffValue then
        DolmenRunnerSettingsReapplyBuffValue:SetText(SettingLabel(s.reapplyBuff))
    end
end

function Ui:OnPauseMenuOpen()
    if DolmenRunnerSettingsWindow then
        DolmenRunnerSettingsWindow:SetHidden(false)
    end
    self:RefreshSettings()
    ActivateSettingsFocus()
end

function Ui:OnPauseMenuClose()
    DeactivateSettingsFocus()
    if DolmenRunnerSettingsWindow then
        DolmenRunnerSettingsWindow:SetHidden(true)
    end
end

function Ui:Initialize()
    if DolmenRunnerSettingsWindow then
        DolmenRunnerSettingsWindow:SetHidden(true)
    end
    SetupConsoleGamepadFocus()
    self:RefreshSettings()
end

DolmenRunner.ui = Ui
