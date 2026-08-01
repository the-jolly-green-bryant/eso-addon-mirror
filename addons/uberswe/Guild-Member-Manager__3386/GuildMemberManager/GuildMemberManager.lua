GuildMemberManager = {}

GuildMemberManager.name = "GuildMemberManager"
GuildMemberManager.columns = {}
GuildMemberManager.savedData = {}
GuildMemberManager.LibHistoireListener = {}
local LGH = LibHistoire

local function secondsToString(time)
    local years = zo_floor(time/(86400*30*12))
    local months = zo_floor(time/(86400*30))
    local days = zo_floor(time/86400)
    local hours = zo_floor(zo_mod(time, 86400)/3600)
    local minutes = zo_floor(zo_mod(time,3600)/60)
    local seconds = zo_floor(zo_mod(time,60))

    if years > 0 then
        return string.format("%s years", years)
    end
    if months > 0 then
        return string.format("%s months", months)
    end
    if days > 0 then
        return string.format("%s days", days)
    end
    if hours > 0 then
        return string.format("%s hours", hours)
    end
    if minutes > 0 then
        return string.format("%s minutes", minutes)
    end
    if seconds > 0 then
        return string.format("%s seconds", seconds)
    end
    return "0 days"
end

function GuildMemberManager:Initialize()
    GuildMemberManager.savedData = ZO_SavedVars:NewAccountWide('GuildMemberManagerSavedData', 1, nil, systemDefault, nil, 'GuildMemberManager')
    zo_callLater(function()
        CHAT_ROUTER:AddSystemMessage("Guild Member Manager Initializing...")
        GuildMemberManager.LoadFromLibHistoire()
        CHAT_ROUTER:AddSystemMessage("Guild Member Manager Initialized")
    end, 2500)
    GuildMemberManager.RegisterColumns()
end

function GuildMemberManager.OnAddOnLoaded(event, addonName)
  if addonName == GuildMemberManager.name then
    GuildMemberManager:Initialize()
  end
end

function GuildMemberManager.LoadFromLibHistoire()
    numGuilds = GetNumGuilds()
    for guildNum = 1, numGuilds do
        local guildId = GetGuildId(guildNum)
        if not GuildMemberManager.savedData["lastEventID"] then
            GuildMemberManager.savedData["lastEventID"] = {}
        end
        if not GuildMemberManager.savedData["lastEventID"][guildId] then
            GuildMemberManager.savedData["lastEventID"][guildId] = "0"
        end
        GuildMemberManager.LibHistoireListener[guildId] = {}
        GuildMemberManager.LibHistoireListener[guildId] = LGH:CreateGuildHistoryListener(guildId, GUILD_HISTORY_GENERAL)

        GuildMemberManager.LibHistoireListener[guildId]:SetEventCallback(function(eventType, eventId, eventTime, p1, p2, p3, p4, p5, p6)
            if eventType == GUILD_EVENT_GUILD_JOIN then
                local param1 = p1 or ""
                local param2 = p2 or ""
                local param3 = p3 or ""
                local param4 = p4 or ""
                local param5 = p5 or ""
                local param6 = p6 or ""
                local theString = param1 .. param2 .. param3 .. param4 .. param5 .. param6

                if not lastReceivedGeneralEventID or CompareId64s(eventId, lastReceivedGeneralEventID) > 0 then
                    GuildMemberManager.savedData["lastEventID"][guildId] = Id64ToString(eventId)
                    lastReceivedGeneralEventID = eventId
                end

                local guildName = GetGuildName(guildId)
                local displayName = string.lower(p1)

                if not GuildMemberManager.savedData[guildName] then
                    GuildMemberManager.savedData[guildName] = {}
                end

                if not GuildMemberManager.savedData[guildName][displayName] then
                    GuildMemberManager.savedData[guildName][displayName] = eventTime
                elseif GuildMemberManager.savedData[guildName][displayName] > eventTime then
                    GuildMemberManager.savedData[guildName][displayName] = eventTime
                end

                if not GuildMemberManager.savedData[guildName]["oldestEventTimestamp"] then
                    GuildMemberManager.savedData[guildName]["oldestEventTimestamp"] = eventTime
                elseif GuildMemberManager.savedData[guildName]["oldestEventTimestamp"] > eventTime then
                    GuildMemberManager.savedData[guildName]["oldestEventTimestamp"] = eventTime
                end

            end
        end)

        GuildMemberManager.LibHistoireListener[guildId]:Start()
    end
end

function GuildMemberManager.RegisterColumns()
    GuildMemberManager.columns["MemberSince"] = LibGuildRoster:AddColumn({
        key = 'GuildMemberManager_MemberSince',
        disabled = false,
        width = 150,
        header = {
            title = "Member For",
            align = TEXT_ALIGN_RIGHT
        },
        row = {
            align = TEXT_ALIGN_RIGHT,
            data = function(guildId, data, index)
                local output = "unknown"
                local guildName = GetGuildName(guildId)
                local timeStamp = GetTimeStamp()
                if GuildMemberManager.savedData and GuildMemberManager.savedData[guildName] and GuildMemberManager.savedData[guildName][string.lower(data["displayName"])] then
                    local memberSince = GuildMemberManager.savedData[guildName][string.lower(data["displayName"])]
                    local timeString = secondsToString(timeStamp - memberSince)
                    output = string.format("%s", timeString)
                elseif GuildMemberManager.savedData and GuildMemberManager.savedData[guildName] and GuildMemberManager.savedData[guildName]["oldestEventTimestamp"] then
                    local timeString = secondsToString(timeStamp - GuildMemberManager.savedData[guildName]["oldestEventTimestamp"])
                    output = string.format("more than %s", timeString)
                end
                return output

            end,
        }
    })
end

EVENT_MANAGER:RegisterForEvent(GuildMemberManager.name, EVENT_ADD_ON_LOADED, GuildMemberManager.OnAddOnLoaded)