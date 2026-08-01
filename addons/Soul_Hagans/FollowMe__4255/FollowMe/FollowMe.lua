local FollowMe = {}
FollowMe.name = "FollowMe"
_G["FollowMe"] = FollowMe

local EM = EVENT_MANAGER
local LAM = LibAddonMenu2
local L = FollowMe_L

-- =====================
-- 1. ФУНКЦИИ ДЕЙСТВИЙ (БИНДЫ И ТЕЛЕПОРТ)
-- =====================

function FollowMe.AcceptDialog()
    -- Если окно открыто — совершаем прыжок
    if FollowMe.Dialog and not FollowMe.Dialog:IsHidden() then
        if FollowMe.Dialog.leader then
            pcall(function() JumpToGroupMember(FollowMe.Dialog.leader) end)
            CHAT_SYSTEM:AddMessage(L.TELEPORTING .. FollowMe.Dialog.leader)
        end
        FollowMe.CloseDialog()
    end
end

function FollowMe.CloseDialog()
    if FollowMe.Dialog then
        FollowMe.Dialog:SetHidden(true)
    end
end

-- =====================
-- 2. СОЗДАНИЕ UI ОКНА
-- =====================

local function CreateDialog()
    local frame = WINDOW_MANAGER:CreateTopLevelWindow("FollowMe_FollowDialog")
    frame:SetDimensions(350, 220)
    
    -- Загружаем сохраненную позицию или выводим по умолчанию
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, FollowMe.savedVars.followDialogLeft or 500, FollowMe.savedVars.followDialogTop or 300)
    frame:SetHidden(true)
    frame:SetMouseEnabled(true)
    frame:SetMovable(true)

    -- Сохранение координат при перетаскивании
    frame:SetHandler("OnMoveStop", function(self)
        FollowMe.savedVars.followDialogLeft = self:GetLeft()
        FollowMe.savedVars.followDialogTop = self:GetTop()
    end)

    local bg = WINDOW_MANAGER:CreateControl("$(parent)BG", frame, CT_BACKDROP)
    bg:SetAnchorFill(frame)
    bg:SetCenterColor(0.1, 0.1, 0.1, 0.9)
    bg:SetEdgeColor(0.8, 0.5, 0.1, 1)
    bg:SetEdgeTexture("", 8, 2, 2)

    local label = WINDOW_MANAGER:CreateControl("$(parent)Label", frame, CT_LABEL)
    label:SetAnchor(TOP, frame, TOP, 0, 20)
    label:SetDimensions(340, 160)
    label:SetFont("ZoFontWinH3")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    
    local btnYes = WINDOW_MANAGER:CreateControl("$(parent)BtnYes", frame, CT_BUTTON)
    btnYes:SetDimensions(100, 30)
    btnYes:SetAnchor(BOTTOM, frame, BOTTOM, -60, -10)
    btnYes:SetNormalTexture("/esoui/art/buttons/btn_up.dds")
    btnYes:SetText(L.DIALOG_YES) -- Локализованный текст (Да / Yes)
    btnYes:SetFont("ZoFontWinH3")
    btnYes:SetHandler("OnClicked", FollowMe.AcceptDialog)

    local btnNo = WINDOW_MANAGER:CreateControl("$(parent)BtnNo", frame, CT_BUTTON)
    btnNo:SetDimensions(100, 30)
    btnNo:SetAnchor(BOTTOM, frame, BOTTOM, 60, -10)
    btnNo:SetNormalTexture("/esoui/art/buttons/btn_up.dds")
    btnNo:SetText(L.DIALOG_NO) -- Локализованный текст (Нет / No)
    btnNo:SetFont("ZoFontWinH3")
    btnNo:SetHandler("OnClicked", FollowMe.CloseDialog)

    FollowMe.Dialog = frame
    FollowMe.Label = label
end

-- =====================
-- 3. ЛОГИКА ДИАЛОГА И СИГНАЛОВ
-- =====================

function FollowMe.OpenDialog(leader, zone)
    local frame = FollowMe.Dialog
    if not frame then CreateDialog() frame = FollowMe.Dialog end
    
    local header = "|cFFD700" .. L.DIALOG_SUMMONED .. "|r"
    local formattedText = header .. "\n\n" .. zo_strformat(L.DIALOG_TEXT, leader, zone)
    
    FollowMe.Label:SetText(formattedText)
    frame.leader = leader
    frame:SetHidden(false)
end

function FollowMe.SendBeacon()
    if not IsUnitGrouped("player") then
        CHAT_SYSTEM:AddMessage(L.NOT_IN_GROUP)
        return
    end

    local name = GetUnitName("player") or ""
    local zone = GetUnitZone("player") or GetPlayerLocationName() or "???"
    local msg = string.format("FM:%s:%s", zo_strtrim(name), zo_strtrim(zone))

    StartChatInput("/p " .. msg, CHAT_CHANNEL_PARTY)
    CHAT_SYSTEM:AddMessage(L.SIGNAL_SENT .. zone)
end

local function OnChatMessage(eventCode, channelType, fromName, messageText, isCustomerService, fromDisplayName)
    if channelType ~= CHAT_CHANNEL_PARTY then return end
    if not messageText or type(messageText) ~= "string" or messageText:sub(1, 3) ~= "FM:" then return end

    local cmd, leader, zone = zo_strsplit(":", messageText)
    if not cmd or cmd:upper() ~= "FM" then return end

    local myChar = zo_strformat("<<1>>", GetUnitName("player") or "")
    local cleanFromName = zo_strformat("<<1>>", fromName or "")
    local senderIsSelf = (cleanFromName == myChar)

    if senderIsSelf and not FollowMe.savedVars.showOwn then
        CHAT_SYSTEM:AddMessage(L.IGNORE_OWN_SIGNAL)
        return
    end

    if FollowMe.savedVars.autoAccept then
        pcall(function() JumpToGroupMember(leader) end)
        CHAT_SYSTEM:AddMessage(L.AUTO_TELEPORT .. leader)
    else
        FollowMe.OpenDialog(leader, zone)
    end
end

-- =====================
-- 4. КНОПКА В ЧАТЕ
-- =====================

local function CreateChatButton()
    local btn = WINDOW_MANAGER:CreateControl("FollowMeChatBtn", ZO_ChatWindow, CT_BUTTON)
    btn:SetDimensions(28, 28)
    btn:SetAnchor(TOPLEFT, ZO_ChatWindow, TOPLEFT, FollowMe.savedVars.buttonX or 177, 10)
    btn:SetNormalTexture("/esoui/art/buttons/accept_up.dds")
    btn:SetMouseOverTexture("/esoui/art/buttons/accept_over.dds")
    btn:SetPressedTexture("/esoui/art/buttons/accept_down.dds")
    
    btn:SetHandler("OnClicked", function() 
        FollowMe.SendBeacon()
    end)
    
    btn:SetHandler("OnMouseEnter", function(control)
        InitializeTooltip(InformationTooltip, control)
        SetTooltipText(InformationTooltip, L.TOOLTIP_TITLE .. "\n" .. L.TOOLTIP_DESC)
    end)
    
    btn:SetHandler("OnMouseExit", function() 
        ClearTooltip(InformationTooltip) 
    end)
    
    FollowMe.ChatButton = btn
    
    if not FollowMe.savedVars.showButton then
        btn:SetHidden(true)
    end
end

local function UpdateButtonPosition()
    if FollowMe.ChatButton then
        FollowMe.ChatButton:ClearAnchors()
        FollowMe.ChatButton:SetAnchor(TOPLEFT, ZO_ChatWindow, TOPLEFT, FollowMe.savedVars.buttonX, 10)
    end
end

local function ResetButtonPosition()
    FollowMe.savedVars.buttonX = 177
    UpdateButtonPosition()
    CHAT_SYSTEM:AddMessage(L.BUTTON_RESET)
end

-- =====================
-- 5. РЕГИСТРАЦИЯ ТЕКСТА КЛАВИШ
-- =====================

local function RegisterBindingsStrings()
    ZO_CreateStringId("SI_BINDING_NAME_FOLLOWME_SEND", L.BINDING_SEND)
    ZO_CreateStringId("SI_BINDING_NAME_FOLLOWME_YES", L.BINDING_YES)
    ZO_CreateStringId("SI_BINDING_NAME_FOLLOWME_NO", L.BINDING_NO)
end

-- =====================
-- 6. СЛЭШ-КОМАНДЫ
-- =====================

local function RegisterSlashCommands()
    local function CheckAddonLoaded()
        if not FollowMe.savedVars then
            CHAT_SYSTEM:AddMessage(L.ADDON_NOT_LOADED)
            return false
        end
        return true
    end

    SLASH_COMMANDS["/fm"] = function() 
        if not CheckAddonLoaded() then return end
        FollowMe.SendBeacon()
    end

    SLASH_COMMANDS["/fmauto"] = function() 
        if not CheckAddonLoaded() then return end
        FollowMe.savedVars.autoAccept = not FollowMe.savedVars.autoAccept
        CHAT_SYSTEM:AddMessage("[FollowMe] " .. L.SETTINGS_AUTO_ACCEPT .. ": " .. (FollowMe.savedVars.autoAccept and L.STATUS_ON or L.STATUS_OFF))
    end

    SLASH_COMMANDS["/fmshow"] = function() 
        if not CheckAddonLoaded() then return end
        FollowMe.savedVars.showOwn = not FollowMe.savedVars.showOwn
        CHAT_SYSTEM:AddMessage("[FollowMe] " .. L.SETTINGS_SHOW_OWN .. ": " .. (FollowMe.savedVars.showOwn and L.STATUS_ON or L.STATUS_OFF))
    end

    SLASH_COMMANDS["/fmpos"] = function(extra)
        if not CheckAddonLoaded() then return end
        if extra and extra ~= "" then
            local newPos = tonumber(extra)
            if newPos and newPos >= 0 and newPos <= 500 then
                FollowMe.savedVars.buttonX = newPos
                UpdateButtonPosition()
                CHAT_SYSTEM:AddMessage(L.BUTTON_POSITION_SET .. newPos)
            else
                CHAT_SYSTEM:AddMessage(L.BUTTON_POSITION_USAGE)
            end
        else
            CHAT_SYSTEM:AddMessage(L.BUTTON_CURRENT_POSITION .. FollowMe.savedVars.buttonX)
        end
    end

    SLASH_COMMANDS["/fmhelp"] = function()
        CHAT_SYSTEM:AddMessage(L.HELP_TITLE)
        CHAT_SYSTEM:AddMessage(L.HELP_FM)
        CHAT_SYSTEM:AddMessage(L.HELP_FMAUTO)
        CHAT_SYSTEM:AddMessage(L.HELP_FMSHOW)
        CHAT_SYSTEM:AddMessage(L.HELP_FMPOS)
        CHAT_SYSTEM:AddMessage(L.HELP_FMSETTINGS)
    end

    SLASH_COMMANDS["/fmsettings"] = function()
        if not CheckAddonLoaded() then return end
        LAM:OpenToPanel(FollowMe.settingsPanel)
    end

    -- Демо-команда для тестов
    SLASH_COMMANDS["/fmdemo"] = function()
        if not CheckAddonLoaded() then return end
        FollowMe.OpenDialog("Тестовый Игрок", "Тестовая Зона")
    end
end

-- =====================
-- 7. МЕНЮ НАСТРОЕК (LAM)
-- =====================

local function CreateSettingsMenu()
    local panelData = {
        type = "panel",
        name = "FollowMe_Settings",
        displayName = "|c00FF00FollowMe|r",
        author = "|cff6401Soul_Hagans|r",
        version = "2.0.1",
        registerForDefaults = true,
    }

    local optionsData = {
        {
            type = "checkbox",
            name = L.SETTINGS_AUTO_ACCEPT,
            tooltip = L.SETTINGS_AUTO_ACCEPT_TT,
            getFunc = function() return FollowMe.savedVars.autoAccept end,
            setFunc = function(value) 
                FollowMe.savedVars.autoAccept = value 
            end,
            default = false,
        },
        {
            type = "checkbox",
            name = L.SETTINGS_SHOW_OWN,
            tooltip = L.SETTINGS_SHOW_OWN_TT,
            getFunc = function() return FollowMe.savedVars.showOwn end,
            setFunc = function(value) 
                FollowMe.savedVars.showOwn = value 
            end,
            default = false,
        },
        {
            type = "checkbox",
            name = L.SETTINGS_SHOW_BUTTON,
            tooltip = L.SETTINGS_SHOW_BUTTON_TT,
            getFunc = function() return FollowMe.savedVars.showButton end,
            setFunc = function(value) 
                FollowMe.savedVars.showButton = value 
                if FollowMe.ChatButton then
                    FollowMe.ChatButton:SetHidden(not value)
                end
            end,
            default = true,
        },
        {
            type = "slider",
            name = L.SETTINGS_BUTTON_X,
            tooltip = L.SETTINGS_BUTTON_X_TT,
            min = 0,
            max = 500,
            step = 1,
            getFunc = function() return FollowMe.savedVars.buttonX end,
            setFunc = function(value) 
                FollowMe.savedVars.buttonX = value 
                UpdateButtonPosition()
            end,
            default = 177,
        },
        {
            type = "button",
            name = L.SETTINGS_RESET_BUTTON,
            tooltip = L.SETTINGS_RESET_BUTTON_TT,
            func = function() 
                ResetButtonPosition()
            end,
        },
        {
            type = "checkbox",
            name = L.SETTINGS_ACCOUNT_WIDE,
            tooltip = L.SETTINGS_ACCOUNT_WIDE_TT,
            getFunc = function() return FollowMe.savedVars.accountWide end,
            setFunc = function(value) 
                FollowMe.savedVars.accountWide = value
                CHAT_SYSTEM:AddMessage(L.SETTINGS_APPLIED .. (value and L.ACCOUNT_WIDE or L.CHARACTER_ONLY))
                CHAT_SYSTEM:AddMessage(L.RELOAD_UI_REQUIRED)
            end,
            default = true,
            warning = L.RELOAD_UI_REQUIRED,
        },
    }

    FollowMe.settingsPanel = LAM:RegisterAddonPanel("FollowMe_Settings", panelData)
    LAM:RegisterOptionControls("FollowMe_Settings", optionsData)
end

-- =====================
-- 8. ИНИЦИАЛИЗАЦИЯ
-- =====================

local function OnAddOnLoaded(event, addonName)
    if addonName ~= FollowMe.name then return end
    EM:UnregisterForEvent(FollowMe.name, EVENT_ADD_ON_LOADED)

    local savedVarsName = "FollowMe_SavedSettings"
    local isAccountWide = true
    
    if _G[savedVarsName] and _G[savedVarsName].default then
        isAccountWide = _G[savedVarsName].default.accountWide ~= false
    end

    local defaults = {
        autoAccept = false,
        showOwn = false,
        showButton = true,
        buttonX = 177,
        accountWide = true,
        followDialogLeft = 500,
        followDialogTop = 300,
    }

    if isAccountWide then
        FollowMe.savedVars = ZO_SavedVars:NewAccountWide(savedVarsName, 1, nil, defaults, GetWorldName())
    else
        FollowMe.savedVars = ZO_SavedVars:NewCharacterIdSettings(savedVarsName, 1, nil, defaults, GetWorldName())
    end

    -- Запуск систем в правильном порядке
    RegisterBindingsStrings()  -- Регистрируем названия биндов до загрузки интерфейса
    CreateDialog()             -- Создаем кастомное чёрно-золотое окно
    CreateChatButton()         -- Кнопочка в чате
    CreateSettingsMenu()       -- Настройки LibAddonMenu
    RegisterSlashCommands()    -- Консольные слэш-команды

    EM:RegisterForEvent(FollowMe.name, EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)

    CHAT_SYSTEM:AddMessage(L.LOADED)
    CHAT_SYSTEM:AddMessage(L.SETTINGS_COMMAND)
    CHAT_SYSTEM:AddMessage(L.SAVING_TYPE .. (FollowMe.savedVars.accountWide and L.ACCOUNT_WIDE or L.CHARACTER_ONLY))
end

EM:RegisterForEvent(FollowMe.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)