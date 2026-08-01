NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local SkipLogoutConfirmation = {}

local FEATURE_NAME = NQOL.L("features.skip_logout_confirmation.feature_name")
NQOL.Lexicon.RegisterRefreshCallback(function() FEATURE_NAME = NQOL.L("features.skip_logout_confirmation.feature_name") end)

local defaults = {
    utility = {
        skipLogoutConfirmation = false,
    },
}

local savedVariables
local initialized = false
local originalShowGamepadDialog

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "utility")
    NQOL.Settings.Boolean(settings, defaults.utility, "skipLogoutConfirmation")

    return settings
end

local function IsEnabled()
    return GetSettings().skipLogoutConfirmation == true
end

local function ShouldSkipGamepadDialog(dialogName, data)
    return IsEnabled()
        and dialogName == "GAMEPAD_LOG_OUT"
        and data
        and data.quit == false
        and type(Logout) == "function"
end

local function HookLogoutDialog()
    if originalShowGamepadDialog or type(ZO_Dialogs_ShowGamepadDialog) ~= "function" then
        return
    end

    originalShowGamepadDialog = ZO_Dialogs_ShowGamepadDialog

    ZO_Dialogs_ShowGamepadDialog = function(dialogName, data, ...)
        if ShouldSkipGamepadDialog(dialogName, data) then
            Logout()
            return nil
        end

        return originalShowGamepadDialog(dialogName, data, ...)
    end
end

function SkipLogoutConfirmation.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults)
    GetSettings()
end

function SkipLogoutConfirmation.Initialize()
    if initialized then
        return
    end

    initialized = true
    HookLogoutDialog()
end

function SkipLogoutConfirmation.GetEnabled()
    return IsEnabled()
end

function SkipLogoutConfirmation.SetEnabled(value)
    GetSettings().skipLogoutConfirmation = value == true
end

function SkipLogoutConfirmation.GetEnabledLabel()
    return FEATURE_NAME
end

function SkipLogoutConfirmation.GetEnabledTooltip()
    return NQOL.L("features.skip_logout_confirmation.enabled_tooltip")
end

NQOL.Features.SkipLogoutConfirmation = SkipLogoutConfirmation
