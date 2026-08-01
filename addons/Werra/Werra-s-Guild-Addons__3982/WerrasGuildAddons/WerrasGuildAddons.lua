WGA = {}
WGA.name = "WerrasGuildAddons"
WGA.GuildIDtoMonitor = 0
WGA.GuildChatChannel = 0
ChumList = {}
WGA.GuildToMonitor = "Rum and Wreckage"
nRankToAlert = 10 --< This is Chum in R&W

----------------------------------------------------------
-- Debugging overrides
--WGA.GuildToMonitor = "Ducksaber Company"
--nRankToAlert = 4
----------------------------------------------------------
function WGA.debugprint(someVar)
  --Test output from /wga slash command
   d("WGA: ------------------" )

  local activeGuildID = WGA.GuildIDtoMonitor
  d("Active Guild ID: " .. activeGuildID)

  local guildName = GetGuildName(activeGuildID)
  d("Active Guild Name: " .. guildName)

  local guildMemberNum = GetNumGuildMembers(activeGuildID)
  d("Guild Member Total: " .. guildMemberNum )

  --get current player's guild index
  local playerIndex = GetPlayerGuildMemberIndex(activeGuildID)
  d("Guild Player Index: " .. playerIndex )

  --get their info based on this index
  local _,_,rankIndex,_,_ = GetGuildMemberInfo(activeGuildID, playerIndex)  
  d("Guild Player Rank: " .. rankIndex )

  d("-----------------------" )
end
 
function chatlisten(event,  channelType,  fromName,  messageText,  isCustomerService,  fromDisplayName)
	-- Only listen to the nominated Guild Chat
	if WGA.GuildChatChannel == channelType then 
		-- Only execute if message is from someone in our list
		if (ChumList[fromDisplayName]) then
			PlaySound(SOUNDS.CAMPAIGN_READY_CHECK) 
			d("------------- CHUM ALERT ----------------------")
		end
	end
end -- chatlisten event

----------------------------------------------------------
function WGA.GetMonitoringInfo()
	d("WGA - Getting Guild Members")
	WGA.GuildIDtoMonitor = 0
	for i = 1, 5 do
		local guildID = GetGuildId(i)
		local GuildName = GetGuildName(guildID)
		if (GuildName == WGA.GuildToMonitor) then
			WGA.GuildIDtoMonitor = guildID 
			d("WGA - Monitoring Guild " .. GuildName)
			WGA.GuildChatChannel = 11 + i
		end
	end --checking all guilds
	d("WGA - Monitoring GuildID:" .. WGA.GuildIDtoMonitor)

	local numGuildMembers = GetNumGuildMembers(WGA.GuildIDtoMonitor)
	--Build a list of only people to alert, to keep things quick
	for guildMemberIndex = 1, numGuildMembers do
		local accName,_,rankIndex,_,_ = GetGuildMemberInfo(WGA.GuildIDtoMonitor, guildMemberIndex)
		if (rankIndex == nRankToAlert) then 
		 	local memberdata =  {  
				index = guildMemberIndex,
				accName=accName,
				rankIndex = rankIndex,
				status = status,
		                }
			--add to list
			ChumList[accName] = memberdata
		end --if rank is chum
	end --for guildMemberIndex to numGuildMembers

end --GetMonitoringInfo()

----------------------------------------------------------
function WGA.Initialize()
	d("WGA Initialising")
	WGA.GetMonitoringInfo()
	-- Register chat events
	EVENT_MANAGER:RegisterForEvent(WGA.name, EVENT_CHAT_MESSAGE_CHANNEL, chatlisten)
        d("WGA Init Finished")

end

----------------------------------------------------------
function WGA.OnAddOnLoaded(event, addonName)
  if addonName == WGA.name then
    WGA.Initialize()
    EVENT_MANAGER:UnregisterForEvent(WGA.name, EVENT_ADD_ON_LOADED) 
  end
end

----------------------------------------------------------
SLASH_COMMANDS["/wga"] = WGA.debugprint

----------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(WGA.name, EVENT_ADD_ON_LOADED, WGA.OnAddOnLoaded)
----------------------------------------------------------