local ADDON_NAME = "GuildHistoryExactTime"
local eventManager = GetEventManager()

local function FormatGuildHistoryAbsoluteTime(timestampS)
    if not timestampS or timestampS == 0 then
        return ""
    end
    local year, month, day = GetDateElementsFromTimestamp(timestampS)
    local dateText = GetDateStringFromTimestamp(timestampS)
    local startOfDay = GetTimestampForStartOfDate(year, month, day, true)
    local timeText = ZO_FormatTime(timestampS - startOfDay, TIME_FORMAT_STYLE_CLOCK_TIME, ZO_GetClockFormat())
    return zo_strformat("<<1>> <<2>>", dateText, timeText)
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= ADDON_NAME then
        return
    end
    eventManager:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    SecurePostHook(ZO_GuildHistory_Shared, "SetupEventRow", function (_, control, eventData)
        control.timeLabel:SetText(FormatGuildHistoryAbsoluteTime(eventData:GetEventTimestampS()))
    end)
end

eventManager:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
