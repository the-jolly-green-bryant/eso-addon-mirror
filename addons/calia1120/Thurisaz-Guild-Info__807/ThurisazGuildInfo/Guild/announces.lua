-- Copyright (c) 2014 User Froali from ESOUI.com
-- All Rights Reserved. If you want to use arts of my AddOns for your own work, please contact me first!

TI.ANNOUNCES = {}

TI.RED = {1,0,0,1}
TI.GREEN = {0,1,0,1}
TI.BLUE = {0,0,1,1}
TI.BLACK = {1,1,1,0}
TI.WHITE = {1,1,1,1}
TI.YELLOW = {1,1,0,1}

function TI.AnnounceGuildMemberLeveled(eventCode, guildId, AccName, charName, newLvl)
	if( not TI:getShowStatus(guildId, TI.SETTINGS_LEVEL) ) then return end
	if( TI:isPlayerSelf(AccName) ) then return end
	if( TI:isPlayerOffline(AccName, guildId) ) then return end

	local guildName = { text= TI:GetGuildName(guildId), color = TI.GetGuildNameColorTable(guildId) }
	local name = {text = TI:createNameToDisplay(guildId, AccName, charName), color =  TI.GetPlayerNameColorTable() }
	newLvl = {text = newLvl}

	TI:showAnnouncement(TI.locale.templates.new_level, name, guildName, newLvl)
end

function TI.AnnounceGuildMemberChampionLeveled(eventCode, guildId, AccName, charName, newLvl)
	if( not TI:getShowStatus(guildId, TI.SETTINGS_LEVEL)) then return end
	if( TI:isPlayerSelf(AccName) ) then return end
	if( TI:isPlayerOffline(AccName, guildId)) then return end
	
	local guildName = { text= TI:GetGuildName(guildId), color = TI.GetGuildNameColorTable(guildId) }
	local name = {text = TI:createNameToDisplay(guildId, AccName, charName), color =  TI.GetPlayerNameColorTable() }
	newLvl = {text = newLvl}

	TI:showAnnouncement(TI.locale.templates.new_champion, name, guildName, newLvl)
end

function TI.AnnounceGuildMemberPlayerStatus(eventCode, guildId, AccName, oldStatus, newStatus)
	TI.IterateGuildList()
	
	if( not TI:getShowStatus(guildId, TI.SETTINGS_STATUS)) then return end
	if( TI:isPlayerSelf(AccName)) then return end
	
	local name = {text = TI:createNameToDisplay(guildId, AccName, nil), color =  TI.GetPlayerNameColorTable() }
	local guildName = { text= TI:GetGuildName(guildId), color = TI.GetGuildNameColorTable(guildId) }
	local newStatusTable = TI:getStatusString(newStatus)

	TI:showAnnouncement(TI.locale.templates.status_change, name, guildName, newStatusTable)
end


function TI.AnnounceGuildMemberAdded(eventCode, guildId, AccName)
	TI.IterateGuildList()
	
	if( not TI:getShowStatus(guildId, TI.SETTINGS_MEMBER)) then return end


	local name = {text = TI:createNameToDisplay(guildId, AccName, nil), color =  TI.GetPlayerNameColorTable()}
	local guildName = { text= TI:GetGuildName(guildId), color = TI.GetGuildNameColorTable(guildId) }

	TI:showAnnouncement(TI.locale.templates.guild_joined, name, guildName)
end


function TI.AnnounceGuildMemberRemoved(eventCode, guildId, AccName)
	TI.IterateGuildList()
	
	if( not TI:getShowStatus(guildId, TI.SETTINGS_MEMBER)) then return end


	local name = {text = TI:createNameToDisplay(guildId, AccName, nil), color =  TI.GetPlayerNameColorTable()}
	local guildName = { text= TI:GetGuildName(guildId), color = TI.GetGuildNameColorTable(guildId) }

	TI:showAnnouncement(TI.locale.templates.guild_left, name, guildName)
end

local function AnnounceGuildMotDChanged(eventCode, guildId)
	if( not TI:getShowStatus(guildId, TI.SETTINGS_ALL)) then return end

	local guildName = { text= TI:GetGuildName(guildId), color = TI.GetGuildNameColorTable(guildId) }
	local motd = {text= GetGuildMotD(guildId), color = nil }

	if(eventCode == nil ) then
		TI:showAnnouncement(TI.locale.templates.motd_startup, guildName, motd)
	else
		TI:showAnnouncement(TI.locale.templates.motd_changed, guildName, motd)
	end

end



function TI:getStatusString(status)
	if(status ==  PLAYER_STATUS_AWAY ) then
		return {text = TI.locale.away, color = TI.YELLOW}
	elseif(status ==  PLAYER_STATUS_DO_NOT_DISTURB) then
		return {text= TI.locale.dontdisturb, color = TI.RED}
	elseif(status == PLAYER_STATUS_OFFLINE) then
		return {text= TI.locale.offline, color = TI.RED}
	elseif(status == PLAYER_STATUS_ONLINE) then
		return {text= TI.locale.online, color = TI.GREEN}
	else
		return {text= TI.locale.unknown, color = nil}
	end
end

---Returns guild name enclosed in brackets []
function TI:GetGuildName(guildId)
	--if(not isnumeric(guildId) or guildId < 1 or guildId > 5)then return "" end
--	local func = TI.guildAbbreviationGetFuncs[TI:getNormalizedGuildId(guildId)]
--	if(not func) then return "" end
	local abbr = TI.GetGuildAbbreviationSetting(TI:getNormalizedGuildId(guildId));
	local str = "[<<1>>]"
	local guildName = ""
	if(string.len(abbr) > 0) then
		guildName = abbr
	else
		guildName = GetGuildName(guildId)
	end
	return zo_strformat(str, guildName)
end


local function DisplayMotDOnStartup()
	for i=1, GetNumGuilds() do
		if(TI.GetGuildSetting(i)) then
			zo_callLater( function() AnnounceGuildMotDChanged(nil, i) end , i*3000);
		end
	end
end

function TI.ANNOUNCES.Initialize()
	TI:CreateAnnouncementDisplay()

	DisplayMotDOnStartup()

	TI.HookNotifications()

	EVENT_MANAGER:RegisterForEvent("TGI_GuildMemberLeveled", EVENT_GUILD_MEMBER_CHARACTER_LEVEL_CHANGED, TI.AnnounceGuildMemberLeveled) --EVENT_GUILD_MEMBER_CHARACTER_LEVEL_CHANGED
	EVENT_MANAGER:RegisterForEvent("TGI_GuildMemberChampionLeveled", EVENT_GUILD_MEMBER_CHARACTER_CHAMPION_POINTS_CHANGED, TI.AnnounceGuildMemberChampionLeveled)--
	EVENT_MANAGER:RegisterForEvent("TGI_GuildMemberStatusChanged", EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, TI.AnnounceGuildMemberPlayerStatus) --EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED
	EVENT_MANAGER:RegisterForEvent("TGI_GuildMemberAdded", EVENT_GUILD_MEMBER_ADDED, TI.AnnounceGuildMemberAdded) --EVENT_GUILD_MEMBER_ADDED
	EVENT_MANAGER:RegisterForEvent("TGI_GuildMemberLeft", EVENT_GUILD_MEMBER_REMOVED, TI.AnnounceGuildMemberRemoved) --EVENT_GUILD_MEMBER_ADDED

	EVENT_MANAGER:RegisterForEvent("TGI_GuildMotDChanged", EVENT_GUILD_MOTD_CHANGED, AnnounceGuildMotDChanged) --EVENT_GUILD_MOTD_CHANGED
end




--Only Update Roster

EVENT_MANAGER:RegisterForEvent("TGI_GuildMemberRankChanged", EVENT_GUILD_MEMBER_RANK_CHANGED, TI.IterateGuildList)--EVENT_GUILD_MEMBER_RANK_CHANGED (guildId, AccName, newRank)
EVENT_MANAGER:RegisterForEvent("TGI_GuildMemberCharacterUpdated", EVENT_GUILD_MEMBER_CHARACTER_UPDATED, TI.IterateGuildList)--EVENT_GUILD_MEMBER_CHARACTER_UPDATED(guildId, AccName)
EVENT_MANAGER:RegisterForEvent("TGI_GuildMemberZoneChanged", EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED, TI.IterateGuildList)--EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED



--Raid Score Notifications
function TI.HookNotifications()
	ZO_PreHook(ZO_LeaderboardRaidProvider, "BuildNotificationList", function(self)
		for index = 1, GetNumRaidScoreNotifications() do
			local notificationId = GetRaidScoreNotificationId(index)
			local numMembers = GetNumRaidScoreNotificationMembers(notificationId)
			local showNotification = false
			local guildMembers = {}
			for memberIndex = 1, numMembers do
				local displayName, _, _, isGuildMember = GetRaidScoreNotificationMemberInfo(notificationId, memberIndex)
				if isGuildMember then
					table.insert(guildMembers, displayName)
				end
			end
			for _, name in ipairs(guildMembers) do
				for guildIndex = 1, GetNumGuilds() do
					if not showNotification and TI.GetGuildSetting(guildIndex) and TI.GetRaidScoreNotifySetting(guildIndex) then 
						local guildId = GetGuildId(guildIndex)
						for memberIndex = 1, GetNumGuildMembers(guildId) do 
							local displayName = GetGuildMemberInfo(guildId, memberIndex)
							if displayName == name then
								--d(zo_strformat("RL notify hit: <<1>> from <<2>>", displayName, GetGuildName(guildId)))
								showNotification = true
								break
							end
						end
					end
				end
			end
			if not showNotification then
				--d(zo_strformat("Removed RL notification! (i: <<1>>, id: <<2>>)", index, notificationId))
				RemoveRaidScoreNotification(notificationId)
			end 
		end
	end)
end

function TI.AnnouncementTest()
	TI:showAnnouncement("Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.")
end
SLASH_COMMANDS["/thuritest"] = TI.AnnouncementTest