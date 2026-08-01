NQOL = NQOL or {}

local WhatsNew = {}

local DIALOG_NAME = "NQOL_WHATS_NEW"
local GAMEPAD_DIALOG_TYPE = GAMEPAD_DIALOGS and GAMEPAD_DIALOGS.BASIC

local defaults = {
    whatsNew = {
        lastSeenVersion = "",
    },
}

local savedVariables
local dialogRegistered = false

local function GetContent()
    return NQOL.WhatsNewContent
end

local function GetSettings()
    local settings = NQOL.Settings.GetSection(savedVariables, defaults, "whatsNew")
    NQOL.Settings.Default(settings, defaults.whatsNew, "lastSeenVersion")
    return settings
end

local function GetContentVersion()
    local content = GetContent()
    if type(content) ~= "table" or type(content.version) ~= "string" or content.version == "" then
        return nil
    end

    return content.version
end

local function GetContentMessage()
    local content = GetContent()
    if type(content) ~= "table" or type(content.messages) ~= "table" then
        return ""
    end

    local language = NQOL.Lexicon.GetLanguage()
    return content.messages[language] or content.messages.en or ""
end

local function MarkSeen()
    local contentVersion = GetContentVersion()
    if contentVersion then
        GetSettings().lastSeenVersion = contentVersion
    end
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
                return NQOL.L("dialogs.whats_new.title")
            end,
        },
        mainText = {
            text = GetContentMessage,
        },
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = SI_OK,
                callback = MarkSeen,
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
        NQOL.Chat.Message(GetContentMessage(), NQOL.L("dialogs.whats_new.feature_name"))
        MarkSeen()
    end
end

function WhatsNew.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults, "$InstallationWide")
end

function WhatsNew.Initialize(isFirstRun)
    if not GetContentVersion() then
        return
    end

    if isFirstRun then
        MarkSeen()
        return
    end

    local settings = GetSettings()
    if settings.lastSeenVersion == GetContentVersion() then
        return
    end

    ShowDialog()
end

function WhatsNew.ResetMessage()
    GetSettings().lastSeenVersion = ""
end

NQOL.WhatsNew = WhatsNew
