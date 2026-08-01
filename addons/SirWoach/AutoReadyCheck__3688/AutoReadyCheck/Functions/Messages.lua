AutoReadyCheck = AutoReadyCheck or {}
local LCM = LibChatMessage(AutoReadyCheck.name, AutoReadyCheck.tag)
local str_format = zo_strformat

-- LibChatMessage is required.

--- PrintMessage
-- @param tag The string to send as a message.
-- @param[opt="ffee00"] the hexadecamil of the color to apply to the message.
-- @return false if no message sent, true if completed.
local function PrintMessage(msg, color)
    if not AutoReadyCheck.settings.messagesEnabled then return false end

    local msgColor = color or "ffee00"
    -- send the message us LibChatMessage
    LCM:SetTagColor(msgColor):Print(msg)

    return true
end

function AutoReadyCheck.SetMessagesEnabled(val)
    AutoReadyCheck.settings.messagesEnabled = val
end

function AutoReadyCheck.GetMessagesEnabled()
    return AutoReadyCheck.settings.messagesEnabled
end

function AutoReadyCheck.SendToggleMessage(val, tag)
    local activity = GetString(tag)

    local text
    local color
    if val then
        color = '59ff00'
        text = str_format(GetString(ARC_READY_CHECK_ENABLED), activity)
    else
        color = 'ff2f00'
        text = str_format(GetString(ARC_READY_CHECK_DISABLED), activity)
    end

    PrintMessage(text, color)

    return val
end

