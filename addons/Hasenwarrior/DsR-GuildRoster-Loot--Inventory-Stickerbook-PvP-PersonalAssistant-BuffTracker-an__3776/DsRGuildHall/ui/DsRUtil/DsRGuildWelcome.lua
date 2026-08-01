-- Create namespace
DsRGuildWelcome = {}
local DsRGuildWelcome = DsRGuildWelcome or {}

DsRGuildWelcome.name = "DsRGuildWelcome"

-------------------------------------------------------------------------------------------------------------------------------------------------
-- -- Welcome our newest member
-------------------------------------------------------------------------------------------------------------------------------------------------
function addWelcomeToChat(_, gId, pName)
	local gNum = DsRAutoINV.cfg.GuildNumbers[gId]
	local msg  = DsRAutoINV.cfg.message[gNum]

    if IsUnitInCombat("player") then return end

	if DsRAutoINV.cfg.welcome[gNum] == true then

        for guildId = 1, GetNumGuilds() do
            local guild = GetGuildId(guildId)
            local numMembers = GetNumGuildMembers(guild)

            for i = 1, numMembers do
                local displayName, note, rankIndex, status = GetGuildMemberInfo(guild, i)

                if displayName == pName then
                    if tostring(status) ~= "4" then -- 4 = offline, 1-3 = online
                        local channel = string.format("%s%s", "/guild", gNum)
                		local welcome = string.gsub(msg, "%%1", pName)

                        CHAT_SYSTEM:Maximize()
                        CHAT_SYSTEM.textEntry:InsertLink( channel )
                        CHAT_SYSTEM.textEntry:InsertLink( " " .. welcome )
                        CHAT_SYSTEM.textEntry:Open()
                        CHAT_SYSTEM.textEntry:FadeIn()
                        return
                    end
                end
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
-- On addon loaded
-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildWelcome.OnAddOnLoaded(event, name)
    if not DsRAutoINV.cfg.welcomeOnOff then return end
    
    EVENT_MANAGER:RegisterForEvent(DsRGuildWelcome.name, EVENT_GUILD_MEMBER_ADDED, addWelcomeToChat)
    EVENT_MANAGER:UnregisterForEvent(DsRGuildWelcome.name, EVENT_ADD_ON_LOADED)
end