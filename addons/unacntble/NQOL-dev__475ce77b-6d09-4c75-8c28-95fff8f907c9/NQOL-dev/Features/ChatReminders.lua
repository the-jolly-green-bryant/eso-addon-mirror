NQOL = NQOL or {}
NQOL.Features = NQOL.Features or {}

local ChatReminders = {}

local REMINDER_LIMIT = 10
local HUD_WIDTH_MIN = 240
local HUD_WIDTH_MAX = 1200
local HUD_DEFAULT_WIDTH = 520
local HUD_PADDING = 12
local ROW_GAP = 4
local TITLE_GAP = 6
local DIVIDER_GAP = 8
local DIVIDER_HEIGHT = 1
local FONT_SIZE_MIN = 14
local FONT_SIZE_MAX = 34
local DEFAULT_FONT_SIZE = 22
local BACKGROUND_OPACITY_MIN = 0
local BACKGROUND_OPACITY_MAX = 100
local BORDER_SIZE_MIN = 0
local BORDER_SIZE_MAX = 6
local BORDER_TEXTURE_SIZE = 8
local DEFAULT_HEADER_COLOR = { 1, 0.86, 0.52, 1 }
local DEFAULT_TEXT_COLOR = { 0.94, 0.91, 0.82, 1 }
local DIALOG_NAME = "NQOL_CHAT_REMINDERS"
local GAMEPLAY_SCENES = { hud = true, hudui = true, siegeBar = true }

local defaults = {
    chat = {
        reminders = {
            enabled = false,
            showInGame = true,
            showInSettings = true,
            messages = {},
            horizontalPosition = 50,
            verticalPosition = 35,
            width = HUD_DEFAULT_WIDTH,
            font = NQOL.Util.GetDefaultFont(),
            fontSize = DEFAULT_FONT_SIZE,
            backgroundOpacity = 90,
            borderSize = 0,
            headerColor = { 1, 0.86, 0.52, 1 },
            textColor = { 0.94, 0.91, 0.82, 1 },
        },
    },
}

local savedVariables
local initialized = false
local settingsPanelVisible = false
local sceneCallbackInstalled = false
local chatMenuKeybindHookInstalled = false
local chatMenuKeybindHookAttempts = 0
local dialogRegistered = false
local hudControl
local hudBackground
local hudTitle
local hudDivider
local hudLabels = {}
local fontStringCache = {}

local Clamp = NQOL.Util.Clamp
local Round = NQOL.Util.Round
local StripChatMarkup = NQOL.Util.StripChatMarkup

local function CopyColor(color)
    return { color[1], color[2], color[3], color[4] }
end

local function NormalizeColor(value, defaultColor)
    if type(value) ~= "table" then
        return CopyColor(defaultColor)
    end

    return {
        Clamp(tonumber(value[1]) or defaultColor[1], 0, 1),
        Clamp(tonumber(value[2]) or defaultColor[2], 0, 1),
        Clamp(tonumber(value[3]) or defaultColor[3], 0, 1),
        Clamp(tonumber(value[4]) or defaultColor[4], 0, 1),
    }
end

local function GetSettings()
    local chatSettings = NQOL.Settings.GetSection(savedVariables, defaults, "chat")
    local settings = NQOL.Settings.EnsureTable(chatSettings, "reminders")
    local defaultSettings = defaults.chat.reminders

    NQOL.Settings.Boolean(settings, defaultSettings, "enabled")
    NQOL.Settings.Boolean(settings, defaultSettings, "showInGame")
    NQOL.Settings.Boolean(settings, defaultSettings, "showInSettings")
    NQOL.Settings.EnsureTable(settings, "messages")
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "horizontalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "verticalPosition", 0, 100)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "width", HUD_WIDTH_MIN, HUD_WIDTH_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "fontSize", FONT_SIZE_MIN, FONT_SIZE_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "backgroundOpacity", BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX, true)
    NQOL.Settings.ClampedNumber(settings, defaultSettings, "borderSize", BORDER_SIZE_MIN, BORDER_SIZE_MAX, true)
    settings.headerColor = NormalizeColor(settings.headerColor, DEFAULT_HEADER_COLOR)
    settings.textColor = NormalizeColor(settings.textColor, DEFAULT_TEXT_COLOR)

    if not NQOL.Util.IsFontChoice(settings.font) then
        settings.font = defaultSettings.font
    end

    for index = #settings.messages, 1, -1 do
        if type(settings.messages[index]) ~= "string" or settings.messages[index] == "" then
            table.remove(settings.messages, index)
        end
    end

    while #settings.messages > REMINDER_LIMIT do
        table.remove(settings.messages)
    end

    return settings
end

local function ShouldPreviewInSettings()
    local settings = GetSettings()
    return settingsPanelVisible and settings.showInSettings == true
end

local function GetCurrentSceneName()
    if not SCENE_MANAGER then
        return nil
    end

    if SCENE_MANAGER.GetCurrentSceneName then
        return SCENE_MANAGER:GetCurrentSceneName()
    end

    if SCENE_MANAGER.GetCurrentScene then
        local scene = SCENE_MANAGER:GetCurrentScene()
        if scene and scene.GetName then
            return scene:GetName()
        end
    end

    return nil
end

local function IsGameplaySceneShowing()
    if not SCENE_MANAGER then
        return true
    end

    return GAMEPLAY_SCENES[GetCurrentSceneName()] == true
end

local function ShouldShowHud()
    local settings = GetSettings()
    if ShouldPreviewInSettings() then
        return true
    end

    return settings.showInGame == true and #settings.messages > 0 and IsGameplaySceneShowing()
end

local function GetFont()
    local settings = GetSettings()
    local key = tostring(settings.font) .. ":" .. tostring(settings.fontSize)
    if not fontStringCache[key] then
        fontStringCache[key] = NQOL.Util.CreateFontString(settings.font, settings.fontSize, "ZoFontGamepad18")
    end

    return fontStringCache[key]
end

local function GetTitleFont()
    local settings = GetSettings()
    local fontSize = Clamp(settings.fontSize + 3, FONT_SIZE_MIN, FONT_SIZE_MAX + 3)
    local key = "title:" .. tostring(settings.font) .. ":" .. tostring(fontSize)
    if not fontStringCache[key] then
        fontStringCache[key] = NQOL.Util.CreateFontString(settings.font, fontSize, "ZoFontGamepad22")
    end

    return fontStringCache[key]
end

local function GetLineHeight()
    return math.max(DEFAULT_FONT_SIZE, GetSettings().fontSize + 6)
end

local function GetTitleHeight()
    return math.max(DEFAULT_FONT_SIZE + 6, GetSettings().fontSize + 10)
end

local function GetDisplayMessages()
    local messages = GetSettings().messages
    if #messages == 0 and ShouldPreviewInSettings() then
        return { NQOL.L("features.chat_reminders.no_reminders_1e21a6a") }
    end

    return messages
end

local function EnsureHud()
    if hudControl or not WINDOW_MANAGER or not WINDOW_MANAGER.CreateTopLevelWindow then
        return
    end

    hudControl = WINDOW_MANAGER:CreateTopLevelWindow("NQOLChatReminders")
    hudControl:SetHidden(true)
    hudControl:SetClampedToScreen(true)
    hudControl:SetMouseEnabled(false)

    hudBackground = WINDOW_MANAGER:CreateControl(nil, hudControl, CT_BACKDROP)
    hudBackground:SetAnchorFill(hudControl)
    hudBackground:SetCenterColor(0, 0, 0, 0.65)
    hudBackground:SetEdgeTexture("", 1, 1, 1)

    hudTitle = WINDOW_MANAGER:CreateControl(nil, hudControl, CT_LABEL)
    hudTitle:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    hudTitle:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    hudTitle:SetText(NQOL.L("features.chat_reminders.reminders_ae8c393"))

    hudDivider = WINDOW_MANAGER:CreateControl(nil, hudControl, CT_TEXTURE)
    hudDivider:SetColor(1, 0.86, 0.52, 0.28)

    for index = 1, REMINDER_LIMIT do
        local label = WINDOW_MANAGER:CreateControl(nil, hudControl, CT_LABEL)
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetVerticalAlignment(TEXT_ALIGN_TOP)
        if label.SetWrapMode and TEXT_WRAP_MODE_ELLIPSIS then
            label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        end
        hudLabels[index] = label
    end
end

local function ApplyBorder()
    if not hudBackground then
        return
    end

    local borderSize = GetSettings().borderSize
    if borderSize <= 0 then
        hudBackground:SetEdgeColor(1, 1, 1, 0)
        hudBackground:SetEdgeTexture("", 1, 1, 1)
        return
    end

    hudBackground:SetEdgeColor(1, 1, 1, 0.18)
    hudBackground:SetEdgeTexture("", BORDER_TEXTURE_SIZE, BORDER_TEXTURE_SIZE, borderSize)
end

local function ApplyPosition(width, height)
    if not hudControl or not GuiRoot then
        return
    end

    local settings = GetSettings()
    local screenWidth = GuiRoot:GetWidth()
    local screenHeight = GuiRoot:GetHeight()
    local x = Round((screenWidth - width) * settings.horizontalPosition / 100)
    local y = Round((screenHeight - height) * settings.verticalPosition / 100)

    hudControl:ClearAnchors()
    hudControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
end

local function RefreshHud()
    if not ShouldShowHud() then
        if hudControl then
            hudControl:SetHidden(true)
        end
        return
    end

    EnsureHud()
    if not hudControl then
        return
    end

    local settings = GetSettings()
    local messages = GetDisplayMessages()
    local lineHeight = GetLineHeight()
    local titleHeight = GetTitleHeight()
    local messagesTop = HUD_PADDING + titleHeight + TITLE_GAP + DIVIDER_HEIGHT + DIVIDER_GAP
    local width = Clamp(settings.width, HUD_WIDTH_MIN, HUD_WIDTH_MAX)
    local height = messagesTop + (#messages * lineHeight) + ((#messages - 1) * ROW_GAP) + HUD_PADDING
    local font = GetFont()

    hudControl:SetDimensions(width, height)
    hudBackground:SetCenterColor(0, 0, 0, settings.backgroundOpacity / 100)
    ApplyBorder()
    hudTitle:SetFont(GetTitleFont())
    hudTitle:SetColor(settings.headerColor[1], settings.headerColor[2], settings.headerColor[3], settings.headerColor[4])
    hudTitle:SetDimensions(width - (HUD_PADDING * 2), titleHeight)
    hudTitle:ClearAnchors()
    hudTitle:SetAnchor(TOPLEFT, hudControl, TOPLEFT, HUD_PADDING, HUD_PADDING)

    hudDivider:SetDimensions(width - (HUD_PADDING * 2), DIVIDER_HEIGHT)
    hudDivider:SetColor(settings.headerColor[1], settings.headerColor[2], settings.headerColor[3], settings.headerColor[4] * 0.28)
    hudDivider:ClearAnchors()
    hudDivider:SetAnchor(TOPLEFT, hudControl, TOPLEFT, HUD_PADDING, HUD_PADDING + titleHeight + TITLE_GAP)

    for index, label in ipairs(hudLabels) do
        local message = messages[index]
        label:SetHidden(message == nil)
        if message then
            label:SetFont(font)
            label:SetText(message)
            label:SetColor(settings.textColor[1], settings.textColor[2], settings.textColor[3], settings.textColor[4])
            label:SetDimensions(width - (HUD_PADDING * 2), lineHeight)
            label:ClearAnchors()
            label:SetAnchor(TOPLEFT, hudControl, TOPLEFT, HUD_PADDING, messagesTop + ((index - 1) * (lineHeight + ROW_GAP)))
        end
    end

    ApplyPosition(width, height)
    hudControl:SetHidden(false)
end

local function InstallSceneCallback()
    if sceneCallbackInstalled or not SCENE_MANAGER or not SCENE_MANAGER.RegisterCallback then
        return
    end

    sceneCallbackInstalled = true
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", RefreshHud)
end

local function UninstallSceneCallback()
    if not sceneCallbackInstalled or not SCENE_MANAGER or not SCENE_MANAGER.UnregisterCallback then
        return
    end

    sceneCallbackInstalled = false
    SCENE_MANAGER:UnregisterCallback("SceneStateChanged", RefreshHud)
end

local function RefreshSceneCallback()
    local settings = GetSettings()
    local shouldListen = (settingsPanelVisible and settings.showInSettings == true)
        or (settings.showInGame == true and #settings.messages > 0)
    if shouldListen then
        InstallSceneCallback()
    else
        UninstallSceneCallback()
    end
end

local function GetSelectedChatMessageText(chatMenu)
    if not chatMenu or not chatMenu.list or not chatMenu.list.GetTargetData then
        return nil
    end

    local targetData = chatMenu.list:GetTargetData()
    if not targetData then
        return nil
    end

    local data = targetData.data
    if data and data.rawMessageText and data.rawMessageText ~= "" then
        return data.rawMessageText
    end

    if targetData.GetText then
        local text = targetData:GetText()
        if text and text ~= "" then
            return text
        end
    end

    return targetData.text
end

local function HasSelectedChatMessage(chatMenu)
    local text = GetSelectedChatMessageText(chatMenu)
    return type(text) == "string" and text ~= ""
end

local function ShowCenterMessage(message)
    if CENTER_SCREEN_ANNOUNCE and CENTER_SCREEN_ANNOUNCE.CreateMessageParams then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
        messageParams:SetText(message)

        if messageParams.SetCSAType and CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT then
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
        end

        if messageParams.MarkSuppressIconFrame then
            messageParams:MarkSuppressIconFrame()
        end

        if CENTER_SCREEN_ANNOUNCE.AddMessageWithParams then
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        elseif CENTER_SCREEN_ANNOUNCE.DisplayMessage then
            CENTER_SCREEN_ANNOUNCE:DisplayMessage(messageParams)
        end
    end
end

function ChatReminders.AddMessage(message)
    local text = StripChatMarkup(message)
    if text == "" then
        return
    end

    local messages = GetSettings().messages
    table.insert(messages, 1, text)
    while #messages > REMINDER_LIMIT do
        table.remove(messages)
    end

    RefreshSceneCallback()
    RefreshHud()
    ShowCenterMessage(NQOL.L("features.chat_reminders.reminder_added"))
end

local function AddSelectedChatMessage(chatMenu)
    ChatReminders.AddMessage(GetSelectedChatMessageText(chatMenu))
end

local function RefreshChatKeybinds()
    if KEYBIND_STRIP and CHAT_MENU_GAMEPAD and CHAT_MENU_GAMEPAD.chatEntryListKeybindDescriptor then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(CHAT_MENU_GAMEPAD.chatEntryListKeybindDescriptor)
    end
end

function ChatReminders.RemoveReminder(index)
    local messages = GetSettings().messages
    if type(index) == "number" and messages[index] then
        table.remove(messages, index)
        RefreshSceneCallback()
        RefreshHud()
    end
end

function ChatReminders.ClearAll()
    GetSettings().messages = {}
    RefreshSceneCallback()
    RefreshHud()
end

local function BuildReminderDialogList()
    local list = {}
    local messages = GetSettings().messages

    if #messages == 0 then
        list[#list + 1] = {
            template = "ZO_GamepadMenuEntryTemplate",
            templateData = {
                text = NQOL.L("features.chat_reminders.no_reminders_1e21a6a"),
                setup = ZO_SharedGamepadEntry_OnSetup,
                reminderIndex = nil,
            },
        }
        return list
    end

    for index, message in ipairs(messages) do
        list[#list + 1] = {
            template = "ZO_GamepadMenuEntryTemplate",
            templateData = {
                text = message,
                setup = ZO_SharedGamepadEntry_OnSetup,
                reminderIndex = index,
            },
        }
    end

    return list
end

local function RegisterDialog()
    if dialogRegistered or not ZO_Dialogs_RegisterCustomDialog then
        return
    end

    dialogRegistered = true
    ZO_Dialogs_RegisterCustomDialog(DIALOG_NAME, {
        canQueue = true,
        blockDialogReleaseOnPress = true,
        gamepadInfo = {
            dialogType = GAMEPAD_DIALOGS.PARAMETRIC,
        },
        setup = function(dialog)
            local parametricList = dialog.info.parametricList
            local entries = BuildReminderDialogList()
            ZO_ClearNumericallyIndexedTable(parametricList)
            for _, entry in ipairs(entries) do
                table.insert(parametricList, entry)
            end
            dialog:setupFunc()
        end,
        title = {
            text = NQOL.L("features.chat_reminders.reminders_ae8c393"),
        },
        parametricList = {},
        buttons = {
            {
                keybind = "DIALOG_PRIMARY",
                text = NQOL.L("features.chat_reminders.remove_e963907"),
                enabled = function(dialog)
                    local data = dialog.entryList and dialog.entryList:GetTargetData()
                    return data and data.reminderIndex ~= nil
                end,
                callback = function(dialog)
                    local data = dialog.entryList and dialog.entryList:GetTargetData()
                    if data and data.reminderIndex then
                        ChatReminders.RemoveReminder(data.reminderIndex)
                        ZO_Dialogs_ReleaseDialogOnButtonPress(DIALOG_NAME)
                        zo_callLater(ChatReminders.ShowDialog, 1)
                    end
                end,
            },
            {
                keybind = "DIALOG_RESET",
                text = NQOL.L("features.chat_reminders.clear_all_3a88a6d"),
                enabled = function()
                    return #GetSettings().messages > 0
                end,
                callback = function()
                    ChatReminders.ClearAll()
                    ZO_Dialogs_ReleaseDialogOnButtonPress(DIALOG_NAME)
                    zo_callLater(ChatReminders.ShowDialog, 1)
                end,
            },
            {
                keybind = "DIALOG_NEGATIVE",
                text = SI_GAMEPAD_BACK_OPTION,
                callback = function()
                    ZO_Dialogs_ReleaseDialogOnButtonPress(DIALOG_NAME)
                end,
            },
        },
    })
end

function ChatReminders.ShowDialog()
    RegisterDialog()
    if ZO_Dialogs_ShowGamepadDialog then
        ZO_Dialogs_ShowGamepadDialog(DIALOG_NAME)
    end
end

local function AddChatMenuKeybind(chatMenu)
    if not chatMenu or type(chatMenu.chatEntryListKeybindDescriptor) ~= "table" then
        return
    end

    for _, keybindDescriptor in ipairs(chatMenu.chatEntryListKeybindDescriptor) do
        if keybindDescriptor.nqolChatReminders then
            return
        end
    end

    table.insert(chatMenu.chatEntryListKeybindDescriptor, {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        name = NQOL.L("features.chat_reminders.remind"),
        keybind = "UI_SHORTCUT_RIGHT_STICK",
        callback = function()
            AddSelectedChatMessage(chatMenu)
        end,
        enabled = function()
            return HasSelectedChatMessage(chatMenu)
        end,
        visible = function()
            return GetSettings().enabled == true
        end,
        nqolChatReminders = true,
    })

    if chatMenu.chatEntryPanelFocalArea and chatMenu.chatEntryPanelFocalArea.SetKeybindDescriptor then
        chatMenu.chatEntryPanelFocalArea:SetKeybindDescriptor(chatMenu.chatEntryListKeybindDescriptor)
    end
end

local function InstallChatMenuKeybindHook()
    if chatMenuKeybindHookInstalled then
        return
    end

    if not ZO_ChatMenu_Gamepad or type(ZO_ChatMenu_Gamepad.InitializeFocusKeybinds) ~= "function" or type(SecurePostHook) ~= "function" then
        chatMenuKeybindHookAttempts = chatMenuKeybindHookAttempts + 1
        if chatMenuKeybindHookAttempts < 10 and zo_callLater then
            zo_callLater(InstallChatMenuKeybindHook, 1000)
        end

        AddChatMenuKeybind(CHAT_MENU_GAMEPAD)
        return
    end

    SecurePostHook(ZO_ChatMenu_Gamepad, "InitializeFocusKeybinds", function(self)
        AddChatMenuKeybind(self)
    end)

    chatMenuKeybindHookInstalled = true
    chatMenuKeybindHookAttempts = 0
    AddChatMenuKeybind(CHAT_MENU_GAMEPAD)
end

function ChatReminders.InitializeSavedVariables()
    savedVariables = NQOL.Settings.NewAccountWide(defaults, "$InstallationWide")
    GetSettings()
end

function ChatReminders.Initialize()
    if initialized then
        return
    end

    initialized = true
    RegisterDialog()
    InstallChatMenuKeybindHook()
    RefreshSceneCallback()
    RefreshHud()
end

function ChatReminders.SetSettingsPanelVisible(visible)
    settingsPanelVisible = visible == true
    RefreshSceneCallback()
    RefreshHud()
end

function ChatReminders.GetEnabled() return GetSettings().enabled end
function ChatReminders.SetEnabled(value) GetSettings().enabled = value == true; RefreshSceneCallback(); RefreshHud(); RefreshChatKeybinds() end
function ChatReminders.GetEnabledDefault() return defaults.chat.reminders.enabled end
function ChatReminders.GetShowInGame() return GetSettings().showInGame end
function ChatReminders.SetShowInGame(value) GetSettings().showInGame = value == true; RefreshSceneCallback(); RefreshHud() end
function ChatReminders.GetShowInSettings() return GetSettings().showInSettings end
function ChatReminders.SetShowInSettings(value) GetSettings().showInSettings = value == true; RefreshSceneCallback(); RefreshHud() end
function ChatReminders.GetHorizontalPosition() return GetSettings().horizontalPosition end
function ChatReminders.SetHorizontalPosition(value) GetSettings().horizontalPosition = Clamp(value, 0, 100); RefreshHud() end
function ChatReminders.GetVerticalPosition() return GetSettings().verticalPosition end
function ChatReminders.SetVerticalPosition(value) GetSettings().verticalPosition = Clamp(value, 0, 100); RefreshHud() end
function ChatReminders.GetWidth() return GetSettings().width end
function ChatReminders.SetWidth(value) GetSettings().width = Clamp(Round(value), HUD_WIDTH_MIN, HUD_WIDTH_MAX); RefreshHud() end
function ChatReminders.GetWidthMin() return HUD_WIDTH_MIN end
function ChatReminders.GetWidthMax() return HUD_WIDTH_MAX end
function ChatReminders.GetFont() return GetSettings().font end
function ChatReminders.SetFont(value) if not NQOL.Util.IsFontChoice(value) then value = NQOL.Util.GetDefaultFont() end; GetSettings().font = value; RefreshHud() end
function ChatReminders.GetFontChoices() return NQOL.Util.GetFontChoices() end
function ChatReminders.GetFontChoiceNames() return NQOL.Util.GetFontChoiceNames() end
function ChatReminders.GetFontSize() return GetSettings().fontSize end
function ChatReminders.SetFontSize(value) GetSettings().fontSize = Clamp(Round(value), FONT_SIZE_MIN, FONT_SIZE_MAX); RefreshHud() end
function ChatReminders.GetFontSizeMin() return FONT_SIZE_MIN end
function ChatReminders.GetFontSizeMax() return FONT_SIZE_MAX end
function ChatReminders.GetBackgroundOpacity() return GetSettings().backgroundOpacity end
function ChatReminders.SetBackgroundOpacity(value) GetSettings().backgroundOpacity = Clamp(Round(value), BACKGROUND_OPACITY_MIN, BACKGROUND_OPACITY_MAX); RefreshHud() end
function ChatReminders.GetBackgroundOpacityMin() return BACKGROUND_OPACITY_MIN end
function ChatReminders.GetBackgroundOpacityMax() return BACKGROUND_OPACITY_MAX end
function ChatReminders.GetBorderSize() return GetSettings().borderSize end
function ChatReminders.SetBorderSize(value) GetSettings().borderSize = Clamp(Round(value), BORDER_SIZE_MIN, BORDER_SIZE_MAX); RefreshHud() end
function ChatReminders.GetBorderSizeMin() return BORDER_SIZE_MIN end
function ChatReminders.GetBorderSizeMax() return BORDER_SIZE_MAX end
function ChatReminders.GetHeaderColor() local color = GetSettings().headerColor return color[1], color[2], color[3], color[4] end
function ChatReminders.SetHeaderColor(red, green, blue, alpha) GetSettings().headerColor = { red, green, blue, alpha or 1 }; RefreshHud() end
function ChatReminders.GetTextColor() local color = GetSettings().textColor return color[1], color[2], color[3], color[4] end
function ChatReminders.SetTextColor(red, green, blue, alpha) GetSettings().textColor = { red, green, blue, alpha or 1 }; RefreshHud() end
function ChatReminders.GetHasReminders() return #GetSettings().messages > 0 end

function ChatReminders.GetEntryLabel() return NQOL.L("features.chat_reminders.entry_label") end
function ChatReminders.GetEntryTooltip() return NQOL.L("features.chat_reminders.entry_tooltip") end
function ChatReminders.GetEnabledLabel() return NQOL.L("features.chat_reminders.enabled_label") end
function ChatReminders.GetEnabledTooltip() return NQOL.L("features.chat_reminders.enabled_tooltip") end
function ChatReminders.GetClearAllLabel() return NQOL.L("features.chat_reminders.clear_all_label") end
function ChatReminders.GetClearAllTooltip() return NQOL.L("features.chat_reminders.clear_all_tooltip") end
function ChatReminders.GetShowInGameLabel() return NQOL.L("features.chat_reminders.show_in_game_label") end
function ChatReminders.GetShowInGameTooltip() return NQOL.L("features.chat_reminders.show_in_game_tooltip") end
function ChatReminders.GetShowInSettingsLabel() return NQOL.L("features.chat_reminders.show_in_settings_label") end
function ChatReminders.GetShowInSettingsTooltip() return NQOL.L("features.chat_reminders.show_in_settings_tooltip") end
function ChatReminders.GetHorizontalPositionLabel() return NQOL.L("features.chat_reminders.horizontal_position_label") end
function ChatReminders.GetHorizontalPositionTooltip() return NQOL.L("features.chat_reminders.horizontal_position_tooltip") end
function ChatReminders.GetVerticalPositionLabel() return NQOL.L("features.chat_reminders.vertical_position_label") end
function ChatReminders.GetVerticalPositionTooltip() return NQOL.L("features.chat_reminders.vertical_position_tooltip") end
function ChatReminders.GetWidthLabel() return NQOL.L("features.chat_reminders.width_label") end
function ChatReminders.GetWidthTooltip() return NQOL.L("features.chat_reminders.width_tooltip") end
function ChatReminders.GetFontLabel() return NQOL.L("features.chat_reminders.font_label") end
function ChatReminders.GetFontTooltip() return NQOL.L("features.chat_reminders.font_tooltip") end
function ChatReminders.GetFontSizeLabel() return NQOL.L("features.chat_reminders.font_size_label") end
function ChatReminders.GetFontSizeTooltip() return NQOL.L("features.chat_reminders.font_size_tooltip") end
function ChatReminders.GetBackgroundOpacityLabel() return NQOL.L("features.chat_reminders.background_opacity_label") end
function ChatReminders.GetBackgroundOpacityTooltip() return NQOL.L("features.chat_reminders.background_opacity_tooltip") end
function ChatReminders.GetBorderSizeLabel() return NQOL.L("features.chat_reminders.border_size_label") end
function ChatReminders.GetBorderSizeTooltip() return NQOL.L("features.chat_reminders.border_size_tooltip") end
function ChatReminders.GetHeaderColorLabel() return NQOL.L("features.chat_reminders.header_color_label") end
function ChatReminders.GetHeaderColorTooltip() return NQOL.L("features.chat_reminders.header_color_tooltip") end
function ChatReminders.GetTextColorLabel() return NQOL.L("features.chat_reminders.text_color_label") end
function ChatReminders.GetTextColorTooltip() return NQOL.L("features.chat_reminders.text_color_tooltip") end

NQOL.Features.ChatReminders = ChatReminders
