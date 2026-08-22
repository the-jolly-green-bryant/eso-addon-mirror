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
local originalLogoutCallback
local hookedLogoutEntry

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "utility")
    NQOL.Settings.Boolean(settings, defaults.utility, "skipLogoutConfirmation")

    return settings
end

local function IsEnabled()
    return GetSettings().skipLogoutConfirmation == true
end

local function GetLogoutMenuEntry()
    if not MENU_ENTRY_DATA or not MENU_MAIN_ENTRIES then
        return nil
    end

    local entry = MENU_ENTRY_DATA[MENU_MAIN_ENTRIES.LOG_OUT]
    if type(entry) ~= "table" or type(entry.activatedCallback) ~= "function" then
        return nil
    end

    return entry
end

local function LogoutWithoutConfirmation()
    if type(IsProtectedFunction) == "function"
        and IsProtectedFunction("Logout")
        and type(CallSecureProtected) == "function"
    then
        return CallSecureProtected("Logout")
    end

    if type(Logout) == "function" then
        return Logout()
    end
end

local function RestoreLogoutMenuEntry()
    if not hookedLogoutEntry then
        return
    end

    if hookedLogoutEntry.activatedCallback == LogoutWithoutConfirmation then
        hookedLogoutEntry.activatedCallback = originalLogoutCallback
    end

    hookedLogoutEntry = nil
    originalLogoutCallback = nil
end

local function ApplyLogoutSetting()
    if not IsEnabled() then
        RestoreLogoutMenuEntry()
        return true
    end

    if hookedLogoutEntry then
        return true
    end

    local entry = GetLogoutMenuEntry()
    if not entry then
        return false
    end

    hookedLogoutEntry = entry
    originalLogoutCallback = entry.activatedCallback
    entry.activatedCallback = LogoutWithoutConfirmation
    return true
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
    ApplyLogoutSetting()
end

function SkipLogoutConfirmation.GetEnabled()
    return IsEnabled()
end

function SkipLogoutConfirmation.SetEnabled(value)
    GetSettings().skipLogoutConfirmation = value == true
    ApplyLogoutSetting()
end

function SkipLogoutConfirmation.GetEnabledLabel()
    return FEATURE_NAME
end

function SkipLogoutConfirmation.GetEnabledTooltip()
    return NQOL.L("features.skip_logout_confirmation.enabled_tooltip")
end

NQOL.Features.SkipLogoutConfirmation = SkipLogoutConfirmation
