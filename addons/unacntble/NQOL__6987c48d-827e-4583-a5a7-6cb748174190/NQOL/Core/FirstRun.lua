NQOL = NQOL or {}

local FirstRun = {}

local DIALOG_NAME = "NQOL_FIRST_RUN_INFO"
local GAMEPAD_DIALOG_TYPE = GAMEPAD_DIALOGS and GAMEPAD_DIALOGS.BASIC

local defaults = {
    firstRun = {
        infoPopupShown = false,
    },
}

local savedVariables
local dialogRegistered = false

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "firstRun")
    NQOL.Settings.Boolean(settings, defaults.firstRun, "infoPopupShown")
    return settings
end

local function RegisterDialog()
    if dialogRegistered or not ZO_Dialogs_RegisterCustomDialog then
        return
    end

    ZO_Dialogs_RegisterCustomDialog(DIALOG_NAME, {
        canQueue = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOG_TYPE,
        },
        title = {
            text = function()
                return NQOL.L("dialogs.first_run.title")
            end,
        },
        mainText = {
            text = function()
                return NQOL.L("dialogs.first_run.message")
            end,
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_OK,
            },
        },
    })

    dialogRegistered = true
end

local function ShowDialog()
    RegisterDialog()

    if ZO_Dialogs_ShowGamepadDialog then
        ZO_Dialogs_ShowGamepadDialog(DIALOG_NAME)
    elseif ZO_Dialogs_ShowPlatformDialog then
        ZO_Dialogs_ShowPlatformDialog(DIALOG_NAME)
    elseif ZO_Dialogs_ShowDialog then
        ZO_Dialogs_ShowDialog(DIALOG_NAME)
    elseif NQOL.Chat and NQOL.Chat.Message then
        NQOL.Chat.Message(NQOL.L("dialogs.first_run.message"))
    end
end

function FirstRun.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults, "$InstallationWide")
end

function FirstRun.Initialize()
    local settings = GetSettings()
    if settings.infoPopupShown then
        return false
    end

    settings.infoPopupShown = true
    ShowDialog()
    return true
end

function FirstRun.ResetMessage()
    GetSettings().infoPopupShown = false
end

NQOL.FirstRun = FirstRun
