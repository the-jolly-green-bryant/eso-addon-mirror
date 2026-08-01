-- cChat_Timestamps.lua
-- Timestamp formatting utilities

cChat.Timestamps = {}

-- Format a timestamp string based on user preferences
-- @param use24Hour boolean - true for 24-hour format, false for 12-hour with AM/PM
-- @param timeString string (optional) - time string in HH:mm:ss format, defaults to current time
-- @return string - formatted timestamp
function cChat.Timestamps.Format(use24Hour, timeString)
    if not timeString then
        timeString = GetTimeString()
    end

    -- Parse the time string (format: HH:mm:ss)
    local hours, minutes, seconds = timeString:match("([^:]+):([^:]+):([^:]+)")
    local hoursNum = tonumber(hours)

    if use24Hour then
        -- 24-hour format: HH:mm
        return string.format("%02d:%s", hoursNum, minutes)
    else
        -- 12-hour format: h:mm AM/PM
        local hours12 = ((hoursNum - 1) % 12) + 1
        local period = hoursNum >= 12 and "PM" or "AM"
        return string.format("%d:%s %s", hours12, minutes, period)
    end
end

-- Create a formatted timestamp with brackets for display in chat
-- @param use24Hour boolean - true for 24-hour format, false for 12-hour with AM/PM
-- @return string - formatted timestamp with brackets, e.g., "[3:45 PM] "
function cChat.Timestamps.CreateForDisplay(use24Hour)
    local timestamp = cChat.Timestamps.Format(use24Hour)
    return string.format("[%s] ", timestamp)
end

-- Add a timestamp to a chat message
-- @param message string - the chat message
-- @param use24Hour boolean - true for 24-hour format, false for 12-hour with AM/PM
-- @return string - message with timestamp prepended
function cChat.Timestamps.AddToMessage(message, use24Hour)
    if not message or message == "" then
        return message
    end

    local timestamp = cChat.Timestamps.CreateForDisplay(use24Hour)
    return timestamp .. message
end
