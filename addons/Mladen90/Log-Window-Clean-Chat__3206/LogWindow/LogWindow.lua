LogWindow = {}


-- LogWindow_Globals.lua
LogWindow.Version = 1
LogWindow.StringVersion = "1.0.0"
LogWindow.AddOnName = "LogWindow"
LogWindow.SavedVariablesFileName = "LogWindow_Settings"


-- LogWindow_Default.lua
LogWindow.Default =
{
    MainWindowLock      = false,
    MainWindowLeft      = nil,
    MainWindowBottom    = nil,
    MainWindowWidth     = 600,
    MainWindowHeight    = 320,
}


LogWindow.FragmentResourceBuffer = nil


LogWindow_Load = function(eventCode, addonName)
    if addonName ~= LogWindow.AddOnName then return end

    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)

    LogWindow.SavedVariables = ZO_SavedVars:NewAccountWide(LogWindow.SavedVariablesFileName, LogWindow.Version, nil, LogWindow.Default, nil, LogWindow.AddOnName)

    d = function (msg)
        LogWindow_AddMessage(msg)
    end

    CHAT_ROUTER.AddSystemMessage = function (control, msg)
        LogWindow_AddMessage(msg)
    end

    CHAT_ROUTER.AddDebugMessage = function (control, msg)
        LogWindow_AddMessage(msg)
    end

    -- needs to be called later when containers loaded
    zo_callLater(function()
        for k, cc in ipairs(CHAT_SYSTEM.containers) do
            for i = 1, #cc.windows do
                local chatContainer = cc
                if chatContainer and chatContainer.id == 1 then
                    local base = chatContainer.AddEventMessageToWindow
                    chatContainer.AddEventMessageToWindow = function (control, window, message, category)
                        if window and window.key == 1 and category == CHAT_CATEGORY_SYSTEM then
                            LogWindow_AddMessage(message)
                        else
                            base(control, window, message, category)
                        end
                    end
                end
            end
        end
    end, 1000)

    local base_CHAT_SYSTEM_Minimize = CHAT_SYSTEM.Minimize
    CHAT_SYSTEM.Minimize = function (...)
        base_CHAT_SYSTEM_Minimize(...)
        LogWindow_Root:SetHidden(true)
    end

    local base_CHAT_SYSTEM_Maximize = CHAT_SYSTEM.Maximize
    CHAT_SYSTEM.Maximize = function (...)
        base_CHAT_SYSTEM_Maximize(...)
        LogWindow_Fade(false)
    end

    local base_LogWindow_Root_TextBuffer_SetHidden = LogWindow_Root_TextBuffer.SetHidden
    LogWindow_Root_TextBuffer.SetHidden = function (control, value)
        if LogWindow_CanShow() then
            base_LogWindow_Root_TextBuffer_SetHidden(control, value)
        else
            base_LogWindow_Root_TextBuffer_SetHidden(control, true)
        end
    end

    LogWindow.FadeRoot = ZO_AlphaAnimation:New(LogWindow_Root)
    LogWindow.FadeRoot:SetMinMaxAlpha(0, 1.0)

    LogWindow.FragmentResourceBuffer = ZO_HUDFadeSceneFragment:New(LogWindow_Root_TextBuffer)
    SCENE_MANAGER:AddFragment(LogWindow.FragmentResourceBuffer)

    if LogWindow.SavedVariables.MainWindowLeft and LogWindow.SavedVariables.MainWindowBottom then
        LogWindow_Root:ClearAnchors()
		LogWindow_Root:SetAnchor(BOTTOMLEFT, GuiRoot, TOPLEFT, LogWindow.SavedVariables.MainWindowLeft, LogWindow.SavedVariables.MainWindowBottom)
    end

    LogWindow_LockToggleInternal(true)
    LogWindow_UpdateDimensions()
end


LogWindow_CanShow = function ()
    if CHAT_SYSTEM and (CHAT_SYSTEM.isMinimized or CHAT_SYSTEM.isMinimizingOrMaximizing) then
        return false
    else
        return true
    end
end


LogWindow_AddMessage = function(msg, r, g, b)
    LogWindow_Fade(false)

    if LogWindow_CanShow() then
        LogWindow_Root_ScrollBar:SetHidden(false)
        LogWindow_Root_ScrollBarUp:SetHidden(false)
        LogWindow_Root_ScrollBarDown:SetHidden(false)
    else
        LogWindow_Root_ScrollBar:SetHidden(true)
        LogWindow_Root_ScrollBarUp:SetHidden(true)
        LogWindow_Root_ScrollBarDown:SetHidden(true)
    end

    msg = LogWindow_GetLogTimestamp(r, g, b) .. " " .. (msg or "")
    LogWindow_Root_TextBuffer:AddMessage(msg)

    local orig = LogWindow_Root_TextBuffer:GetScrollPosition()
    LogWindow_Root_TextBuffer:SetScrollPosition(10000)

    LogWindow_Root_ScrollBar:SetMinMax(0, LogWindow_Root_TextBuffer:GetScrollPosition())
    LogWindow_Root_ScrollBar:SetValueStep(1)

    if orig == 0 then
        LogWindow_Root_ScrollBar:SetValue(LogWindow_Root_TextBuffer:GetScrollPosition())
        LogWindow_Root_TextBuffer:SetScrollPosition(0)
    else
        LogWindow_Root_TextBuffer:SetScrollPosition(orig)
    end

    LogWindow_Fade(true)
end


LogWindow_Fade = function(value)
    if LogWindow_CanShow() then
        if value then
            LogWindow.FadeRoot:FadeOut(3000, 500)
            LogWindow.FragmentResourceBuffer:Hide(10000)
        else
            LogWindow.FadeRoot:FadeIn(0, 500)
            LogWindow.FragmentResourceBuffer:Hide(0)
            LogWindow.FragmentResourceBuffer:Show(0)
        end
    else
        LogWindow_Root:SetHidden(true)
    end
end


LogWindow_GetChatTextColor = function(r, g, b)
	local color = ZO_ColorDef:New(r, g, b, 1.0)
	return "|c" .. color:ToHex()
end


local gray_color = LogWindow_GetChatTextColor(0.5, 0.5, 0.5)
local yellow_color = LogWindow_GetChatTextColor(1.0, 1.0, 0.0)
LogWindow_GetLogTimestamp = function(r, g, b)
    if r and g and b then
        local color = LogWindow_GetChatTextColor(r, g, b)
        return gray_color .. "[" .. GetTimeString() .. "]" .. color
    else
        return gray_color .. "[" .. GetTimeString() .. "]" .. yellow_color
    end
end


LogWindow_LockToggleInternal = function (is_load)
    if not is_load then
        if LogWindow.SavedVariables.MainWindowLock then
            LogWindow.SavedVariables.MainWindowLock = false
        else
            LogWindow.SavedVariables.MainWindowLock = true
        end
    end

    if LogWindow.SavedVariables.MainWindowLock then
        LogWindow_Root:SetMovable(false)
        LogWindow_Root:SetResizeHandleSize()
    else
        LogWindow_Root:SetMovable(true)
        LogWindow_Root:SetResizeHandleSize(8)
    end
end


LogWindow_UpdateDimensions = function ()
    if LogWindow.SavedVariables.MainWindowWidth and LogWindow.SavedVariables.MainWindowHeight then
        if LogWindow.SavedVariables.MainWindowLeft and LogWindow.SavedVariables.MainWindowBottom then
            LogWindow_Root:ClearAnchors()
            LogWindow_Root:SetAnchor(BOTTOMLEFT, GuiRoot, TOPLEFT, LogWindow.SavedVariables.MainWindowLeft, LogWindow.SavedVariables.MainWindowBottom)

            LogWindow_Root_TextBuffer:ClearAnchors()
            LogWindow_Root_TextBuffer:SetAnchor(BOTTOMLEFT, LogWindow_Root, BOTTOMLEFT, 5, -5)

            LogWindow_Root:SetDimensions(LogWindow.SavedVariables.MainWindowWidth, LogWindow.SavedVariables.MainWindowHeight)
            LogWindow_Root_TextBuffer:SetDimensions(LogWindow.SavedVariables.MainWindowWidth - 20, LogWindow.SavedVariables.MainWindowHeight - 40)
        end
    end
end


SLASH_COMMANDS["/logw_lock_toggle"] = function() LogWindow_LockToggleInternal(false) end


SLASH_COMMANDS["/logw_reset"] = function()
    LogWindow.SavedVariables.MainWindowLock = LogWindow.Default.MainWindowLock
    LogWindow.SavedVariables.MainWindowLeft = LogWindow.Default.MainWindowLeft
    LogWindow.SavedVariables.MainWindowBottom = LogWindow.Default.MainWindowBottom
    LogWindow.SavedVariables.MainWindowWidth = LogWindow.Default.MainWindowWidth
    LogWindow.SavedVariables.MainWindowHeight = LogWindow.Default.MainWindowHeight

    LogWindow_Root:ClearAnchors()
    LogWindow_Root:SetAnchor(CENTER, GuiRoot, CENTER)

    LogWindow_LockToggleInternal(true)
    LogWindow_UpdateDimensions()
end


SLASH_COMMANDS["/logw_hide_toggle"] = function()
    local value = LogWindow_Root:IsHidden()
    LogWindow_Root:SetHidden(not value)
end


SLASH_COMMANDS["/logw_clear"] = function() LogWindow_Root_TextBuffer:Clear() end


EVENT_MANAGER:RegisterForEvent("LogWindow_Load", EVENT_ADD_ON_LOADED, LogWindow_Load)