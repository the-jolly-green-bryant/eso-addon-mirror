GuildToolsByFenInternals.TimeJoined = {}
local TimeJoined = GuildToolsByFenInternals.TimeJoined
local langStrings = GuildToolsByFenInternals.langStrings
local lang = GuildToolsByFenInternals.lang

function TimeJoined.createTooltipString(guildId, displayName, timeStamp)
    local tooltip = ""

    if (GuildToolsByFen.history[guildId][displayName].timeJoined) then
        timeString = tostring(ZO_FormatTime(timeStamp - GuildToolsByFen.history[guildId][displayName].timeJoined,TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE,TIME_FORMAT_PRECISION_SECONDS))
        tooltip = tooltip .. langStrings[lang].member .. timeString
    else
        timeString = tostring(ZO_FormatTime(timeStamp - GuildToolsByFen.history[guildId].oldestEvent,TIME_FORMAT_STYLE_SHOW_LARGEST_UNIT_DESCRIPTIVE,TIME_FORMAT_PRECISION_SECONDS))
        tooltip = tooltip .. langStrings[lang].member .. "> " .. timeString
    end
    
    return tooltip
end

function TimeJoined.storeGuildJoins(guildId, user, eventTime)
    -- if (user == nil) then return end  
    -- if (guildId == nil) then return end  
    -- if (eventTime == nil) then return end  
    -- if(GuildToolsByFen.history[guildId][user] ~= nil) then return end
    
    GuildToolsByFen.history[guildId][user].timeJoined = eventTime    
end