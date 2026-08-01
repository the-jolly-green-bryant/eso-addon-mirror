local ADDON_NAME = "ChatLogger"
ChatLogger = {}

local logger = LibDebugLogger(ADDON_NAME)
local chat = LibChatMessage(ADDON_NAME, "CL", ADDON_NAME)

local nextEventHandleIndex = 1
local function RegisterForEvent(event, callback, eventHandleName)
    if(not eventHandleName) then
        eventHandleName = ADDON_NAME .. nextEventHandleIndex
        nextEventHandleIndex = nextEventHandleIndex + 1
    end
    EVENT_MANAGER:RegisterForEvent(eventHandleName, event, callback)
    return eventHandleName
end

local function UnregisterForEvent(event, name)
    EVENT_MANAGER:UnregisterForEvent(name, event)
end

local function OnAddonLoaded(callback)
    local eventHandle = ""
    eventHandle = RegisterForEvent(EVENT_ADD_ON_LOADED, function(event, name)
        if(name ~= ADDON_NAME) then return end
        UnregisterForEvent(event, eventHandle)
        callback()
    end)
end

local function ExtractHexColorFromPChatColor(color)
    if(color and color ~= "") then
        return color:sub(3, 8)
    end
end

local function GetPChatColors(channel)
    if(pChat_GetChannelColors) then
        local senderColor, messageColor = pChat_GetChannelColors(channel)
        logger:Verbose("get colors for channel %d from pChat", channel)
        senderColor = ExtractHexColorFromPChatColor(senderColor)
        messageColor = ExtractHexColorFromPChatColor(messageColor)
        if(not senderColor and messageColor) then
            senderColor = messageColor
        elseif(senderColor and not messageColor) then
            messageColor = senderColor
        end
        return senderColor, messageColor
    end
end

local function ExportChatColors(saveData)
    logger:Debug("begin ExportChatColors")
    local colors = {}
    for channel = CHAT_CHANNEL_MIN_VALUE, CHAT_CHANNEL_MAX_VALUE do
        local senderColor, messageColor = GetPChatColors(channel)
        if(not senderColor) then
            local color = ZO_ColorDef:New(ZO_ChatSystem_GetCategoryColorFromChannel(channel))
            logger:Verbose("get colors for channel %d from client", channel)
            senderColor = color:ToHex()
            messageColor = senderColor
        end
        colors[channel] = string.format("%s|%s", senderColor, messageColor)
    end
    saveData["$colors"] = colors
    logger:Debug("end ExportChatColors")
end

local function GetChatWindow()
    local primaryContainer = KEYBOARD_CHAT_SYSTEM.primaryContainer
    if not primaryContainer then
        logger:Warn("primary chat container is not available")
        return
    end

    local chatWindow = primaryContainer.control
    if not chatWindow then
        logger:Warn("chat window control is not available")
        return
    end

    return chatWindow
end

OnAddonLoaded(function()
    ChatLogger_Data = ChatLogger_Data or {}
    local saveData = ChatLogger_Data[GetDisplayName()] or {}
    ChatLogger_Data[GetDisplayName()] = saveData

    local function EnableChatLog()
        logger:Info("set log enabled")
        SetChatLogEnabled(true)
        saveData.enabled = true
    end

    local function DisableChatLog()
        logger:Info("set log disabled")
        SetChatLogEnabled(false)
        saveData.enabled = false
    end

    local function AppendChatLogMenuItem()
        if(IsChatLogEnabled()) then
            AddCustomMenuItem("Disable Chat Log", DisableChatLog)
        else
            AddCustomMenuItem("Enable Chat Log", EnableChatLog)
        end
        ShowMenu(ZO_Menu.owner)
    end

    local eventHandle, button
    eventHandle = RegisterForEvent(EVENT_PLAYER_ACTIVATED, function(event)
        UnregisterForEvent(event, eventHandle)

        if(saveData.enabled and not IsChatLogEnabled()) then
            EnableChatLog()
        end

        if(not ChatLogger_Data["$colors"]) then ExportChatColors(ChatLogger_Data) end
        SLASH_COMMANDS["/clexport"] = function()
            logger:Info("export chat colors")
            ExportChatColors(ChatLogger_Data)
            chat:Print("Exported chat colors")
        end

        local chatWindow = GetChatWindow()
        if chatWindow then
            button = chatWindow:CreateControl("ChatLoggerIndicator", CT_BUTTON)
            button:SetDimensions(32, 32)
            button:SetNormalTexture("EsoUI/Art/Miscellaneous/ESO_Icon_Warning.dds")
            button:SetMouseOverTexture("EsoUI/Art/WorldMap/mapNav_upArrow_over.dds")
            button:SetPressedOffset(2, 2)
            button:SetClickSound("Click")
            button:SetAnchor(RIGHT, chatWindow:GetNamedChild("Options"), LEFT, 0, 0)
            button:SetHandler("OnMouseEnter", function()
                InitializeTooltip(InformationTooltip, button, BOTTOMLEFT, 0, -2, TOPLEFT)
                SetTooltipText(InformationTooltip, "Chatlog is disabled. Click to enable")
            end)
            button:SetHandler("OnMouseExit", function()
                ClearTooltip(InformationTooltip)
            end)
            button:SetHandler("OnClicked", EnableChatLog)
            button:SetHidden(IsChatLogEnabled())
        end

        SecurePostHook("ZO_ChatSystem_ShowOptions", AppendChatLogMenuItem)
        SecurePostHook("ZO_ChatWindow_OpenContextMenu", AppendChatLogMenuItem)
    end)

    RegisterForEvent(EVENT_CHAT_LOG_TOGGLED, function(event, opened)
        logger:Info("log has been", opened and "enabled" or "disabled")
        if button then
            button:SetHidden(opened)
        end
    end)

    if(saveData.enabled and not IsChatLogEnabled()) then
        EnableChatLog()
    end
end)
