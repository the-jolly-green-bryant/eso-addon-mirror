if not AutoRanks then AutoRanks = {} end
local AR = AutoRanks
local em = GetEventManager()
local cm = CALLBACK_MANAGER

AR.name = "AutoRanks"
AR.version = "3.4.2"
AR.guilds = {}
AR.ranks = {}
AR.tasks = {}
AR.blocked = {}
AR.fullInbox = {}
AR.unknown = {}
AR.currentRecipient = ""
AR.Localization = {}
local L = AR.Localization
AR.settings = {}

AR.defaults = {
	chatMessages = true,
	presets = {},
	ActivePreset = "",

	sales = {{}, {}, {}, {}, {}},
	salesTimeFrame = {L["AR_STR_THIS_WEEK"], L["AR_STR_THIS_WEEK"], L["AR_STR_THIS_WEEK"], L["AR_STR_THIS_WEEK"], L["AR_STR_THIS_WEEK"]},
	salesWindow = {7, 7, 7, 7, 7},
	donations = {{}, {}, {}, {}, {}},
	donationsTimeFrame = {L["AR_STR_THIS_WEEK"], L["AR_STR_THIS_WEEK"], L["AR_STR_THIS_WEEK"], L["AR_STR_THIS_WEEK"], L["AR_STR_THIS_WEEK"]},
	meetBoth = {{}, {}, {}, {}, {}},
	trackLastDonation = {},
	donationsWindow = {30, 30, 30, 30, 30},

	note = {},
	noteKey = {},
	demoteCap = {8, 8, 8, 8, 8},
	restoreRank = {},

	rank = {{}, {}, {}, {}, {}},
	recruits = {},
	newMemberPeriod = {7, 7, 7, 7, 7},
	noDemote = {{}, {}, {}, {}, {}},

	recruitMail = {},
	recruitMail1 = {},
	recruitMail2 = {},

	feesMail = {},
	feesMail1 = {},
	feesMail2 = {},

	process = {},
	restrict = {},
}


	function AR.getIDfromName(guildname)
		for i = 1, GetNumGuilds() do
		  if guildname == GetGuildName(GetGuildId(i))
		   then return GetGuildId(i)
	    end
	  end
	end


	function AR.getIndexfromID(guildID)
		for i = 1, GetNumGuilds() do
		  if GetGuildId(i) == guildID
		   then return i
	    end
	  end
	end


  function AR.getIDfromRank(guild, rankname)
		for i = 1, 10 do
		  if rankname == GetFinalGuildRankName(GetGuildId(guild), i)
		   then return i
	    end
	  end
	end


  function AR.populateGuildTable()
  	for i = 1, GetNumGuilds() do
  		table.insert(AR.guilds, GetGuildName(GetGuildId(i)))
  	end
  end


  function AR.populateRankTable()

  	for guild = 1, GetNumGuilds() do
    	local guildRanks = {}
    	local guildID = GetGuildId(guild)

    	for i = 1, GetNumGuildRanks(guildID) do
    		local rank = GetFinalGuildRankName(guildID, i)
    	  	 if  not  AR.isRankAdministrative(guildID, i)
    	  	 then table.insert(guildRanks, rank)
    		  end
    	end

    	table.insert(AR.ranks, guildRanks)
	  end
  end


  function AR.savePreset(presetName)
    CHAT_SYSTEM:Maximize()

    if not AR.settings.presets[presetName]
     then
    	AR.settings.presets[presetName] = {}
    	d(L["AR_STR_CHAT_PRESET_ACTION"] .. presetName .. L["AR_STR_CHAT_PRESET_SAVED"])
     else
     	d(L["AR_STR_CHAT_PRESET_ACTION"] .. presetName .. L["AR_STR_CHAT_PRESET_OVERWR"])
    end


    AR.settings.presets[presetName]["chatMessages"] = AR.settings["chatMessages"]

  	AR.settings.presets[presetName]["sales"] = AR.settings["sales"]
  	AR.settings.presets[presetName]["salesTimeFrame"] = AR.settings["salesTimeFrame"]
  	AR.settings.presets[presetName]["salesWindow"] = AR.settings["salesWindow"]
  	AR.settings.presets[presetName]["donations"] = AR.settings["donations"]
    AR.settings.presets[presetName]["donationsTimeFrame"] = AR.settings["donationsTimeFrame"]
    AR.settings.presets[presetName]["meetBoth"] = AR.settings["meetBoth"]
    AR.settings.presets[presetName]["trackLastDonation"] = AR.settings["trackLastDonation"]
    AR.settings.presets[presetName]["donationsWindow"] = AR.settings["donationsWindow"]

    AR.settings.presets[presetName]["note"] = AR.settings["note"]
    AR.settings.presets[presetName]["noteKey"] = AR.settings["noteKey"]
    AR.settings.presets[presetName]["demoteCap"] = AR.settings["demoteCap"]
    AR.settings.presets[presetName]["restoreRank"] = AR.settings["restoreRank"]


  	AR.settings.presets[presetName]["rank"] = AR.settings["rank"]
  	AR.settings.presets[presetName]["recruits"] = AR.settings["recruits"]
  	AR.settings.presets[presetName]["newMemberPeriod"] = AR.settings["newMemberPeriod"]
  	AR.settings.presets[presetName]["noDemote"] = AR.settings["noDemote"]

  	AR.settings.presets[presetName]["process"] = AR.settings["process"]
  	AR.settings.presets[presetName]["restrict"] = AR.settings["restrict"]


  	AR.loadPreset(presetName, 0)

  	d(L["AR_STR_CHAT_RELOADUI"])
  	zo_callLater(function() ReloadUI() end, 150)

  end


  function AR.loadPreset(presetName, chatMessages)
  	local reload

  	if presetName == AR.settings.ActivePreset then
  		CHAT_SYSTEM:Maximize()
  		d(L["AR_STR_CHAT_PRESET_ACTION"] .. presetName .. L["AR_STR_CHAT_PRESET_ACTIVE"])
  	 	return
  	end

  	--AddIfMissing:
  	if not AR.settings.presets[presetName]["chatMessages"] then
      AR.settings.presets[presetName]["chatMessages"] = AR.settings["chatMessages"]
      reload = 1
    end

    if not AR.settings.presets[presetName]["sales"] then
    	AR.settings.presets[presetName]["sales"] = AR.settings["sales"]
    	reload = 1
    end
    if not AR.settings.presets[presetName]["salesTimeFrame"] then
    	AR.settings.presets[presetName]["salesTimeFrame"] = AR.settings["salesTimeFrame"]
    	reload = 1
    end
    if not AR.settings.presets[presetName]["salesWindow"] then
    	AR.settings.presets[presetName]["salesWindow"] = AR.settings["salesWindow"]
    	reload = 1
    end
    if not AR.settings.presets[presetName]["donations"] then
    	AR.settings.presets[presetName]["donations"] = AR.settings["donations"]
    	reload = 1
    end
    if not AR.settings.presets[presetName]["donationsTimeFrame"] then
      AR.settings.presets[presetName]["donationsTimeFrame"] = AR.settings["donationsTimeFrame"]
      reload = 1
    end
    if not AR.settings.presets[presetName]["meetBoth"] then
      AR.settings.presets[presetName]["meetBoth"] = AR.settings["meetBoth"]
      reload = 1
    end
    if not AR.settings.presets[presetName]["trackLastDonation"] then
      AR.settings.presets[presetName]["trackLastDonation"] = AR.settings["trackLastDonation"]
      reload = 1
    end
    if not AR.settings.presets[presetName]["donationsWindow"] then
      AR.settings.presets[presetName]["donationsWindow"] = AR.settings["donationsWindow"]
      reload = 1
    end


    if not AR.settings.presets[presetName]["note"] then
      AR.settings.presets[presetName]["note"] = AR.settings["note"]
      reload = 1
    end
    if not AR.settings.presets[presetName]["noteKey"] then
      AR.settings.presets[presetName]["noteKey"] = AR.settings["noteKey"]
      reload = 1
    end
    if not AR.settings.presets[presetName]["demoteCap"] then
      AR.settings.presets[presetName]["demoteCap"] = AR.settings["demoteCap"]
      reload = 1
    end
    if not AR.settings.presets[presetName]["restoreRank"] then
      AR.settings.presets[presetName]["restoreRank"] = AR.settings["restoreRank"]
      reload = 1
    end


    if not AR.settings.presets[presetName]["rank"] then
    	AR.settings.presets[presetName]["rank"] = AR.settings["rank"]
    	reload = 1
    end
    if not AR.settings.presets[presetName]["recruits"] then
    	AR.settings.presets[presetName]["recruits"] = AR.settings["recruits"]
    	reload = 1
    end
    if not AR.settings.presets[presetName]["newMemberPeriod"] then
    	AR.settings.presets[presetName]["newMemberPeriod"] = AR.settings["newMemberPeriod"]
    	reload = 1
    end
    if not AR.settings.presets[presetName]["noDemote"] then
    	AR.settings.presets[presetName]["noDemote"] = AR.settings["noDemote"]
    	reload = 1
    end


    if not AR.settings.presets[presetName]["process"] then
    	AR.settings.presets[presetName]["process"] = AR.settings["process"]
    	reload = 1
    end
    if not AR.settings.presets[presetName]["restrict"] then
    	AR.settings.presets[presetName]["restrict"] = AR.settings["restrict"]
    	reload = 1
    end


  	--Load:

    AR.settings["chatMessages"] = AR.settings.presets[presetName]["chatMessages"]

    AR.settings["sales"] = AR.settings.presets[presetName]["sales"]
    AR.settings["salesTimeFrame"] = AR.settings.presets[presetName]["salesTimeFrame"]
    AR.settings["salesWindow"] = AR.settings.presets[presetName]["salesWindow"]
    AR.settings["donations"] = AR.settings.presets[presetName]["donations"]
    AR.settings["donationsTimeFrame"] = AR.settings.presets[presetName]["donationsTimeFrame"]
    AR.settings["meetBoth"] = AR.settings.presets[presetName]["meetBoth"]
  	AR.settings["trackLastDonation"] = AR.settings.presets[presetName]["trackLastDonation"]
  	AR.settings["donationsWindow"] = AR.settings.presets[presetName]["donationsWindow"]

  	AR.settings["note"] = AR.settings.presets[presetName]["note"]
  	AR.settings["noteKey"] = AR.settings.presets[presetName]["noteKey"]
  	AR.settings["demoteCap"] = AR.settings.presets[presetName]["demoteCap"]
  	AR.settings["restoreRank"] = AR.settings.presets[presetName]["restoreRank"]

  	AR.settings["rank"] = AR.settings.presets[presetName]["rank"]
  	AR.settings["recruits"] = AR.settings.presets[presetName]["recruits"]
  	AR.settings["newMemberPeriod"] = AR.settings.presets[presetName]["newMemberPeriod"]
  	AR.settings["noDemote"] = AR.settings.presets[presetName]["noDemote"]

  	AR.settings["process"] = AR.settings.presets[presetName]["process"]
  	AR.settings["restrict"] = AR.settings.presets[presetName]["restrict"]


  	CHAT_SYSTEM:Maximize()
  	d(L["AR_STR_CHAT_PRESET_ACTION"] .. presetName .. L["AR_STR_CHAT_PRESET_LOADED"])

  	AR.settings.ActivePreset = presetName

  	if reload == 1 then
    	d(L["AR_STR_AR"] .. L["AR_STR_CHAT_RELOADUI2"])
    	zo_callLater(function() ReloadUI() end, 500)
    end

  end


  function AR.getPresetNames()

  	local names = {}
    local n=0

    for i, v in pairs(AR.settings.presets) do
      n=n+1
      names[n]=i
    end

    return names

  end


  function AR.deletePreset()
    CHAT_SYSTEM:Maximize()

    if string.len(AR.settings.ActivePreset)==0 then
    	d(L["AR_STR_CHAT_DELETE_WARNING"])
    else
    	d(L["AR_STR_CHAT_PRESET_ACTION"] .. AR.settings.ActivePreset .. L["AR_STR_CHAT_PRESET_DELETED"])
    	AR.settings.presets[AR.settings.ActivePreset] = nil

    	local presets = AR.getPresetNames()

    	if presets[1] then
    		AR.loadPreset(presets[1])
    	  d(L["AR_STR_CHAT_RELOADUI"])
    	  zo_callLater(function() ReloadUI() end, 150)
    	 else
    		AR.settings.ActivePreset = ""
    	  d(L["AR_STR_CHAT_RELOADUI"])
    	  zo_callLater(function() ReloadUI() end, 150)
      end
    end
  end


  function AR.isRankAdministrative(guildID, rank)
     if  DoesGuildRankHavePermission(guildID, rank, GUILD_PERMISSION_BANK_WITHDRAW_GOLD)
	  	 or DoesGuildRankHavePermission(guildID, rank, GUILD_PERMISSION_DEMOTE)
	  	 or DoesGuildRankHavePermission(guildID, rank, GUILD_PERMISSION_DESCRIPTION_EDIT)
	  	 or DoesGuildRankHavePermission(guildID, rank, GUILD_PERMISSION_GUILD_KIOSK_BID)
	  	 or DoesGuildRankHavePermission(guildID, rank, GUILD_PERMISSION_MANAGE_APPLICATIONS)
	  	 or DoesGuildRankHavePermission(guildID, rank, GUILD_PERMISSION_PROMOTE)
	  	 or DoesGuildRankHavePermission(guildID, rank, GUILD_PERMISSION_REMOVE)
	  	 or DoesGuildRankHavePermission(guildID, rank, GUILD_PERMISSION_SET_MOTD)
	  	then return true
	  	else return false
		 end
	end


  function AR.doesLastDonationMeetRequirement(guild, userID, requirement)
  	local guildID = GetGuildId(guild)
	  local lastDonationTime = 0
	  local lastDonationAmount = 0
	  local ITTtime, ITTamount = AR.getLastDonationITT(guildID, userID)
  	
	  if ITTtime > lastDonationTime then
	  	lastDonationTime = ITTtime
	  	lastDonationAmount = ITTamount
	  end
	  
	  local now = GetTimeStamp()
	  local timeRequirement = now-AR.settings.donationsWindow[guild]*86400
	  
	  if lastDonationTime>=timeRequirement and lastDonationAmount~=0 and (now-lastDonationTime)/86400>7
	    and lastDonationAmount*(7*86400)/(now-lastDonationTime)>=requirement
	    or lastDonationAmount>=requirement and (now-lastDonationTime)/86400<=7
	    then return true
	    else return false
	  end
  end


  function AR.getLastDonationITT(guildID, userID)
  	local data
  	
  	if   ITTsDonationBotData
  	 and ITTsDonationBotData.records[GetWorldName()]
  	 and ITTsDonationBotData.records[GetWorldName()][guildID]
  	 and ITTsDonationBotData.records[GetWorldName()][guildID][userID] then
      data = ITTsDonationBotData.records[GetWorldName()][guildID][userID]
     else data = nil
    end
    
    if not data then return 0, 0 end
    
    local timestamps = {}
    
    for k, v in pairs(data) do
     table.insert(timestamps, k)
    end
    
    table.sort(
      timestamps,
      function(a, b)
        return a > b
      end
    )
    
    local timeStamp = timestamps[1]
    local value = data[timeStamp].amount
    
    return tonumber(timeStamp), value
  	
  end


	function AR.sendFailed(eventCode, reason)
		if reason == 4 then
			d(L["AR_STR_AR"] .. AR.currentRecipient .. L["AR_STR_CHAT_IGNORE"])
			table.insert(AR.blocked, AR.currentRecipient)
		 elseif reason == 3 then
      d(L["AR_STR_AR"] .. AR.currentRecipient .. L["AR_STR_CHAT_FULLINBOX"])
			table.insert(AR.fullInbox, AR.currentRecipient)
		 else
		 	table.insert(AR.unknown, AR.currentRecipient)
		end
	end


	function AR.report()
		local failed = #AR.blocked + #AR.fullInbox + #AR.unknown

		if failed<1 then return
		 elseif failed==1 then d(L["AR_STR_AR"] .. L["AR_STR_CHAT_MAILFAIL"] .. failed .. L["AR_STR_CHAT_PLAYER"])
		 elseif failed>1 then d(L["AR_STR_AR"] .. L["AR_STR_CHAT_MAILFAIL"] .. failed .. L["AR_STR_CHAT_PLAYERS"])
		end

		if #AR.blocked>0 then
			d(L["AR_STR_CHAT_IGNORELIST"])
			for i=1, #AR.blocked do
				d("|cFFFFFF" .. AR.blocked[i])
			end
		end

		if #AR.fullInbox>0 then
			d(L["AR_STR_CHAT_FULLINBOXLIST"])
			for i=1, #AR.fullInbox do
				d("|cFFFFFF" .. AR.fullInbox[i])
			end
		end

		if #AR.unknown>0 then
			d(L["AR_STR_CHAT_IDK"])
			for i=1, #AR.unknown do
				d("|cFFFFFF" .. AR.unknown[i])
			end
		end

    AR.blocked = {}
    AR.fullInbox = {}
    AR.unknown = {}
	end


	function AR.migrateAMTITT()
		local total = 0
		
    d("|c6C00FFAuto Ranks - |cFFFFFFMigrating join dates from AMT to ITT...")
    
		if not AMT or not ITTsRosterBot then
			d("|c6C00FFAuto Ranks - |cFFFFFFMigration failed. Make sure both Advanced Member Tooltip and ITTsRosterBot are active and try again.")
			return
		end
		
		for i=1, GetNumGuilds() do
		  local counter = 0
			local guildID = GetGuildId(i)
			local guildName = GetGuildName(guildID)
			
  		for i=1, GetNumGuildMembers(guildID) do
  			local userID = GetGuildMemberInfo(guildID, i)
  			local userName = string.lower(userID)
  			
        --AMT
  			local AMTjoinDate = 0
  			if AMT
				 and AMT.savedData
  			 and AMT.savedData[guildName]
  			 and AMT.savedData[guildName][userName]
  			 and AMT.savedData[guildName][userName]["timeJoined"] then
			    AMTjoinDate = AMT.savedData[guildName][userName]["timeJoined"]
  			end
  			
  			--ITT
  			local ITTjoinDate = 0
  			if ITTsRosterBot
  			 and ITTsRosterBotData
    		 and ITTsRosterBotData[GetWorldName()]
    		 and ITTsRosterBotData[GetWorldName()].guilds[guildID]
    		 and ITTsRosterBotData[GetWorldName()].guilds[guildID].join_records[userID] then
  			  ITTjoinDate = ITTsRosterBotData[GetWorldName()].guilds[guildID].join_records[userID].last	 	
  			end
  			
  			if ITTjoinDate==0 and AMTjoinDate>0 then
  				local joinDate = {}
  				joinDate["last"] = AMTjoinDate
  				ITTsRosterBotData[GetWorldName()].guilds[guildID].join_records[userID] = joinDate
  				counter = counter + 1
  			end
  		end
  		
  		if counter > 0 then 
  		  d("|c6C00FFAuto Ranks - |cFFFFFFSuccessfully migrated " .. counter .. " join dates for " .. guildName .. " from AMT to ITT.")
  		  total = total + counter
		  end
		end
		
  	d("|c6C00FFAuto Ranks - |cFFFFFFMigration done. Migrated a total of " .. total .. " join dates across " .. GetNumGuilds() .. " guilds.")
	end


	function AR.migrateITTAMT()
		local total = 0
		
    d("|c6C00FFAuto Ranks - |cFFFFFFMigrating join dates from ITT to AMT...")
    
		if not AMT or not ITTsRosterBot then
			d("|c6C00FFAuto Ranks - |cFFFFFFMigration failed. Make sure both ITTsRosterBot and Advanced Member Tooltip are active and try again.")
			return
		end
		
		for i=1, GetNumGuilds() do
		  local counter = 0
			local guildID = GetGuildId(i)
			local guildName = GetGuildName(guildID)
			
  		for i=1, GetNumGuildMembers(guildID) do
  			local userID = GetGuildMemberInfo(guildID, i)
  			local userName = string.lower(userID)
  			
  			--ITT
  			local ITTjoinDate = 0
  			if ITTsRosterBot
  			 and ITTsRosterBotData
    		 and ITTsRosterBotData[GetWorldName()]
    		 and ITTsRosterBotData[GetWorldName()].guilds[guildID]
    		 and ITTsRosterBotData[GetWorldName()].guilds[guildID].join_records[userID] then
  			  ITTjoinDate = ITTsRosterBotData[GetWorldName()].guilds[guildID].join_records[userID].last	 	
  			end
  			
        --AMT
  			local AMTjoinDate = 0
  			if AMT
				 and AMT.savedData
  			 and AMT.savedData[guildName]
  			 and AMT.savedData[guildName][userName]
  			 and AMT.savedData[guildName][userName]["timeJoined"] then
			    AMTjoinDate = AMT.savedData[guildName][userName]["timeJoined"]
  			end
  			
  			if AMTjoinDate==0 and ITTjoinDate>0 then
  				AMT.savedData[guildName][userName]["timeJoined"] = ITTjoinDate
  				counter = counter + 1
  			end
  		end
  		
  		if counter > 0 then 
  		  d("|c6C00FFAuto Ranks - |cFFFFFFSuccessfully migrated " .. counter .. " join dates for " .. guildName .. " from ITT to AMT.")
  		  total = total + counter
		  end
		end
		
  	d("|c6C00FFAuto Ranks - |cFFFFFFMigration done. Migrated a total of " .. total .. " join dates across " .. GetNumGuilds() .. " guilds.")
	end


	function AR.fixJoinDates()
		local total = 0
		local now = GetTimeStamp()
		local oneYearAgo = now-31536000
		
    d("|c6C00FFAuto Ranks - |cFFFFFFSetting unknown join dates to 'one year ago'...")
    
		if not AMT and not ITTsRosterBot then
			d("|c6C00FFAuto Ranks - |cFFFFFFOperation failed. Make sure Advanced Member Tooltip or ITTsRosterBot are active and try again.")
			return
		end
		
		for i=1, GetNumGuilds() do
		  local counter = 0
			local guildID = GetGuildId(i)
			local guildName = GetGuildName(guildID)
			
  		for i=1, GetNumGuildMembers(guildID) do
  			local userID = GetGuildMemberInfo(guildID, i)
  			local userName = string.lower(userID)
  			
        --AMT
  			local AMTjoinDate = 0
  			if AMT
				 and AMT.savedData
  			 and AMT.savedData[guildName]
  			 and AMT.savedData[guildName][userName]
  			 and AMT.savedData[guildName][userName]["timeJoined"] then
			    AMTjoinDate = AMT.savedData[guildName][userName]["timeJoined"]
  			end
  			
    		if AMT and AMTjoinDate==0 then
  				AMT.savedData[guildName][userName]["timeJoined"] = oneYearAgo
  				counter = counter + 1
      	end
  			
  			--ITT
  			local ITTjoinDate = 0
  			if ITTsRosterBot
  			 and ITTsRosterBotData
    		 and ITTsRosterBotData[GetWorldName()]
    		 and ITTsRosterBotData[GetWorldName()].guilds[guildID]
    		 and ITTsRosterBotData[GetWorldName()].guilds[guildID].join_records[userID] then
  			  ITTjoinDate = ITTsRosterBotData[GetWorldName()].guilds[guildID].join_records[userID].last	 	
  			end
  			
  			if ITTsRosterBot and ITTjoinDate==0 then
  				local joinDate = {}
  				joinDate["last"] = oneYearAgo
  				ITTsRosterBotData[GetWorldName()].guilds[guildID].join_records[userID] = joinDate
  				counter = counter + 1
    		end
  		end
  		
  		if counter > 0 then 
  		  d("|c6C00FFAuto Ranks - |cFFFFFFSuccessfully set " .. counter .. " missing join dates for " .. guildName .. " to 'one year ago'.")
  		  total = total + counter
		  end
		end
		
  	d("|c6C00FFAuto Ranks - |cFFFFFFDone. Fixed a total of " .. total .. " missing join dates across " .. GetNumGuilds() .. " guilds.")
	end


  function AR.getCurrentWeekTimes()
    local _, endTime = GetGuildKioskCycleTimes()
    
    if GetTimeStamp() > endTime
     then endTime = endTime + 604800
    end
    
    local startTime = endTime - 604800
    
    return startTime, endTime
  end


  function AR.getLastWeekTimes()
    local _, endTime = GetGuildKioskCycleTimes()
    
    if GetTimeStamp() < endTime
     then endTime = endTime - 604800
    end
    
    local startTime = endTime - 604800
    
    return startTime, endTime
  end


  function AR.slash(arg)
  	if arg == "migrateamtitt" then AR.migrateAMTITT() end
  	if arg == "migrateittamt" then AR.migrateITTAMT() end
  	if arg == "fixjoindates" then AR.fixJoinDates() end
  end


  function AR.restoreRankCheck(userID, guildID)
  	if AutoKick and AutoKick.settings.savedPlayers and #AutoKick.settings.savedPlayers>0 then
    	for i = 1, #AutoKick.settings.savedPlayers do
    		if userID == AutoKick.settings.savedPlayers[i][1] and guildID == AutoKick.settings.savedPlayers[i][2] then
    			return AutoKick.settings.savedPlayers[i][3]
    		end
    	end
    end
  end




function AR.Initialize(event, addon)

	if addon ~= AR.name then return end

	em:UnregisterForEvent("AutoRanksInitialize", EVENT_ADD_ON_LOADED)

	AR.populateGuildTable()

	AR.populateRankTable()

	AR.settings = ZO_SavedVars:NewAccountWide("AutoRanksSavedVars", 1, nil, AR.defaults)

	ZO_CreateStringId("SI_BINDING_NAME_AUTO_RANKS_START", L["AR_STR_KEYBIND"])

	AR.MakeMenu()
	
	SLASH_COMMANDS['/ar'] = AR.slash

	if string.len(AR.settings.ActivePreset)>0 then
		AR.loadPreset(AR.settings.ActivePreset, 0)
	end

end

em:RegisterForEvent("AutoRanksInitialize", EVENT_ADD_ON_LOADED, function(...) AR.Initialize(...) end)




function AR.launch(index)
	
	if not index then
		index = 0
		CHAT_SYSTEM:Maximize()
	end
  
	AR.process(index)
  
  AR.doTasks(AR.tasks)
  
end



function AR.doTasks(tasks)
	em:UnregisterForUpdate("ARprocessing")
  em:UnregisterForEvent("AutoRanksFailed", EVENT_MAIL_SEND_FAILED)
  
	if MasterMerchant and not MasterMerchant.isInitialized then return end
	
	local i = 1
	local messageAlert = 0
	
	if string.len(AR.settings.ActivePreset)>0 then
  	if #tasks > 1 then
      d(L["AR_STR_AR"] .. L["AR_STR_CHAT_PROCESSING"] .. #tasks .. L["AR_STR_CHAT_AMOUNT_PRESET"] .. AR.settings.ActivePreset .. "|cFFFFFF'...")
     elseif #tasks == 1 then
    	d(L["AR_STR_AR"] .. L["AR_STR_CHAT_PROCESSING"] .. #tasks .. L["AR_STR_CHAT_SINGLE_PRESET"] .. AR.settings.ActivePreset .. "|cFFFFFF'...")
     else
    	d(L["AR_STR_AR"] .. L["AR_STR_CHAT_ZERO_PRESET"] .. AR.settings.ActivePreset .. "|cFFFFFF'...")
    	cm:FireCallbacks("AutoRanksDone", "ARdone")
    	return
    end
   else
  	if #tasks > 1 then
      d(L["AR_STR_AR"] .. L["AR_STR_CHAT_PROCESSING"] .. #tasks .. L["AR_STR_CHAT_RANK_MANY"])
     elseif #tasks == 1 then
    	d(L["AR_STR_AR"] .. L["AR_STR_CHAT_PROCESSING"] .. #tasks .. L["AR_STR_CHAT_RANK_ONE"])
     else
    	d(L["AR_STR_AR"] .. L["AR_STR_CHAT_NOTHING"])
    	cm:FireCallbacks("AutoRanksDone", "ARdone")
    	return
    end
  end
  
  AR.blocked = {}
  AR.fullInbox = {}
  AR.unknown = {}
  AR.currentRecipient = ""
  em:RegisterForEvent("AutoRanksFailed", EVENT_MAIL_SEND_FAILED, AR.sendFailed)
	em:RegisterForUpdate("ARprocessing", 2000, function()
		
    local guildID = tasks[i][1]
    local userID = tasks[i][2]
    local steps = tasks[i][3]
    local sales = tasks[i][4]
    local donations = tasks[i][5]
    local oldRank = tasks[i][6]
    local guild = AR.getIndexfromID(guildID)
    local demoteCap = AR.settings.demoteCap[guild]*-1
    if steps<demoteCap then steps = demoteCap end
    local newRank = oldRank-steps
  	local currentRank = tonumber(zo_strformat("<<3>>", GetGuildMemberInfo(guildID, GetGuildMemberIndexFromDisplayName(guildID, userID))))
    local oldRankName = GetFinalGuildRankName(guildID, oldRank)
    local newRankName = GetFinalGuildRankName(guildID, newRank)
    
    
	  if steps>0 and oldRank==currentRank then

      GuildSetRank(guildID, userID, newRank)

      if AR.settings.recruitMail[guild] and oldRank==GetNumGuildRanks(guildID) and oldRank==newRank+1 then

    	  if AR.settings.recruitMail1[guild] and AR.settings.recruitMail1[guild]~="" and AR.settings.recruitMail2[guild] and AR.settings.recruitMail2[guild]~=""
         then
         	local text = string.gsub(string.gsub(AR.settings.recruitMail2[guild], "#SALES", sales), "#DONATIONS", donations)
         	AR.currentRecipient = userID

         	RequestOpenMailbox()
         	QueueMoneyAttachment(0)
          SendMail(userID, AR.settings.recruitMail1[guild], text)
          CloseMailbox()

          if AR.settings.chatMessages then
            d(L["AR_STR_AR"] .. userID .. L["AR_STR_CHAT_PROMOTED"] .. oldRankName .. L["AR_STR_CHAT_TO"] .. newRankName .. L["AR_STR_CHAT_IN"] .. GetGuildName(guildID) .. L["AR_STR_CHAT_PM_SENT"])
          end
         else
         	messageAlert = 1
         	if AR.settings.chatMessages then
         	  d(L["AR_STR_AR"] .. userID .. L["AR_STR_CHAT_PROMOTED"] .. oldRankName .. L["AR_STR_CHAT_TO"] .. newRankName .. L["AR_STR_CHAT_IN"] .. GetGuildName(guildID))
          end
        end

       elseif AR.settings.chatMessages then
        d(L["AR_STR_AR"] .. userID .. L["AR_STR_CHAT_PROMOTED"] .. oldRankName .. L["AR_STR_CHAT_TO"] .. newRankName .. L["AR_STR_CHAT_IN"] .. GetGuildName(guildID))
      end
    end
    
    
   	if steps<0 and oldRank==currentRank then

      GuildSetRank(guildID, userID, newRank)

      if AR.settings.feesMail[guild] and newRank==GetNumGuildRanks(guildID)-1 then

    	  if AR.settings.feesMail1[guild] and AR.settings.feesMail1[guild]~="" and AR.settings.feesMail2[guild] and AR.settings.feesMail2[guild]~=""
         then
         	local text = string.gsub(string.gsub(AR.settings.feesMail2[guild], "#SALES", sales), "#DONATIONS", donations)
         	AR.currentRecipient = userID

         	RequestOpenMailbox()
         	QueueMoneyAttachment(0)
          SendMail(userID, AR.settings.feesMail1[guild], text)
          CloseMailbox()

          if AR.settings.chatMessages then
            d(L["AR_STR_AR"] .. userID .. L["AR_STR_CHAT_DEMOTED"] .. oldRankName .. L["AR_STR_CHAT_TO"] .. newRankName .. L["AR_STR_CHAT_IN"] .. GetGuildName(guildID) .. L["AR_STR_CHAT_PM_SENT"])
          end
         else
         	messageAlert = 1
         	if AR.settings.chatMessages then
         	  d(L["AR_STR_AR"] .. userID .. L["AR_STR_CHAT_DEMOTED"] .. oldRankName .. L["AR_STR_CHAT_TO"] .. newRankName .. L["AR_STR_CHAT_IN"] .. GetGuildName(guildID))
          end
        end

       elseif AR.settings.chatMessages then
        d(L["AR_STR_AR"] .. userID .. L["AR_STR_CHAT_DEMOTED"] .. oldRankName .. L["AR_STR_CHAT_TO"] .. newRankName .. L["AR_STR_CHAT_IN"] .. GetGuildName(guildID))
      end

  	end
  	
  	
    i = i+1
    
		if not tasks[i] then
  		zo_callLater(function()
  			em:UnregisterForUpdate("ARprocessing")
  			em:UnregisterForEvent("AutoRanksFailed", EVENT_MAIL_SEND_FAILED)
  			AR.tasks = {}
  			AR.currentRecipient = ""
  	    d(L["AR_STR_AR"] .. L["AR_STR_CHAT_DONE"])
  	    if messageAlert==1 then
  	    	d(L["AR_STR_CHAT_PM_ALTERT"])
  	    end
  	    AR.report()
  	    cm:FireCallbacks("AutoRanksDone", "ARdone")
	    end, 500)
		end
	end)
end



function AR.process(index)
  
	em:UnregisterForUpdate("ARprocessing")
	AR.tasks = {}
  
	if MasterMerchant and not MasterMerchant.isInitialized then
    d(L["AR_STR_AR"] .. L["AR_STR_CHAT_WAITMM"])
    return
  end
  
	if not index then index = 0 end
  
  
  for guild=1, GetNumGuilds() do
    
    if AR.settings.process[guild] and index == 0 or index == guild then
      
    	local memberList = {}
    	local guildID = GetGuildId(guild)
    	local guildName = GetGuildName(guildID)
    	local startSalesTimeStamp = 0
    	local endSalesTimeStamp = 0
      local startDonationsTimeStamp = 0
      local endDonationsTimeStamp = 0
      local MMtimeframe = 0
      local AMTrange = 0
      local now = GetTimeStamp()
      local currentWeekStart, currentWeekEnd = AR.getCurrentWeekTimes()
      local lastWeekStart, lastWeekEnd = AR.getLastWeekTimes()
      
      
      
		  if DoesGuildRankHavePermission(guildID, zo_strformat("<<3>>", GetGuildMemberInfo(guildID, GetGuildMemberIndexFromDisplayName(guildID, GetDisplayName()))), GUILD_PERMISSION_PROMOTE) and #AR.ranks[guild]>0 then
        
        if AR.settings.salesTimeFrame[guild] == L["AR_STR_THIS_WEEK"] then
         	startSalesTimeStamp = currentWeekStart
         	endSalesTimeStamp = now
        	MMtimeframe = 3
         elseif AR.settings.salesTimeFrame[guild] == L["AR_STR_LAST_WEEK"] then
         	startSalesTimeStamp = lastWeekStart
         	endSalesTimeStamp = lastWeekEnd
         	MMtimeframe = 4
         elseif AR.settings.salesTimeFrame[guild] == L["AR_STR_CUSTOM"] then
         	startSalesTimeStamp = now-AR.settings.salesWindow[guild]*86400
         	endSalesTimeStamp = now
         	MMtimeframe = 9
        end
  		  
  		  
        if AR.settings.donationsTimeFrame[guild] == L["AR_STR_THIS_WEEK"] then
        	startDonationsTimeStamp = currentWeekStart
        	endDonationsTimeStamp = now
        	AMTrange = 3
         elseif AR.settings.donationsTimeFrame[guild] == L["AR_STR_LAST_WEEK"] then
        	startDonationsTimeStamp = lastWeekStart
        	endDonationsTimeStamp = lastWeekEnd
         	AMTrange = 4
         elseif AR.settings.donationsTimeFrame[guild] == L["AR_STR_TWO_WEEKS"] then
        	startDonationsTimeStamp = lastWeekStart
        	endDonationsTimeStamp = now
         	AMTrange = 34
  		   elseif AR.settings.donationsTimeFrame[guild] == L["AR_STR_ALL"] then
        	startDonationsTimeStamp = 0
        	endDonationsTimeStamp = now
  		   	AMTrange = 8
  		   elseif AR.settings.donationsTimeFrame[guild] == L["AR_STR_CUSTOM"] then
        	startDonationsTimeStamp = now-AR.settings.donationsTime[guild]*86400
        	endDonationsTimeStamp = now
  		   	AMTrange = 10
        end
  		  
  		  
      	for i=1, GetNumGuildMembers(guildID) do
      		local userID, note, rank = GetGuildMemberInfo(guildID, i)
      		
      		if AR.settings.rank[guild][rank]
      		  and not (AR.settings.note[guild] and string.len(note)>0 and (not AR.settings.noteKey[guild] or AR.settings.noteKey[guild] and string.len(AR.settings.noteKey[guild])==0))
      		  and not (AR.settings.note[guild] and AR.settings.noteKey[guild] and string.len(AR.settings.noteKey[guild])>0 and zo_strfind(note, AR.settings.noteKey[guild]))
      		 then
      		  table.insert(memberList, userID)
      		end
      	end
      	
      	
      	
      	for i=1, #memberList do
      		
      		local userID = memberList[i]
  		  	local userName = string.lower(userID)
      		local rank = tonumber(zo_strformat("<<3>>", GetGuildMemberInfo(guildID, GetGuildMemberIndexFromDisplayName(guildID, userID))))
      		
          
          --Get join date
          local joinDate = now
          
          --AMT
          local AMTjoinDate
    			if AMT then
    				if   AMT.savedData
      			 and AMT.savedData[guildName]
      			 and AMT.savedData[guildName][userName]
      			 and AMT.savedData[guildName][userName]["timeJoined"] then
    			    AMTjoinDate = AMT.savedData[guildName][userName]["timeJoined"]
    			   else AMTjoinDate = 0
    			  end
    			 else AMTjoinDate = nil
    			end
    			
    			--ITT
          local ITTjoinDate
    			if ITTsRosterBot then
    				if   ITTsRosterBotData
      			 and ITTsRosterBotData[GetWorldName()]
      			 and ITTsRosterBotData[GetWorldName()].guilds[guildID]
      			 and ITTsRosterBotData[GetWorldName()].guilds[guildID].join_records[userID] then
    			    ITTjoinDate = ITTsRosterBotData[GetWorldName()].guilds[guildID].join_records[userID].last
    			   else ITTjoinDate = 0
    			  end
    			 else ITTjoinDate = nil    			 	
    			end
    			
          --Take the more recent value that is not 'now'
          if AMTjoinDate and ITTjoinDate then
            if AMTjoinDate >= ITTjoinDate then
            	joinDate = AMTjoinDate
             else
             	joinDate = ITTjoinDate
            end
           elseif AMTjoinDate then joinDate = AMTjoinDate
           elseif ITTjoinDate then joinDate = ITTjoinDate
           else d(L["AR_STR_CHAT_AMT_ITT_MISSING"])
           	    return
          end
    			
    			if joinDate == 0 then joinDate = now end
    			
          local memberSince = (now-joinDate)/86400
          
          
  		  	--Get sales
  		  	local sales = 0
  		  	
  		  	--MM
  		  	local MMsales
  		  	if MasterMerchant then
  		  	  local MM = _G["LibGuildStore_Internal"]
  		  	 	if MM.guildSales
	  	         and MM.guildSales[guildName]
               and MM.guildSales[guildName].sellers
               and MM.guildSales[guildName].sellers[userID]
               and MM.guildSales[guildName].sellers[userID].sales
	  	       then MMsales = MM.guildSales[guildName].sellers[userID].sales[MMtimeframe] or 0
	  	       else MMsales = 0
	  	      end
  		  	 else MMsales = nil
  		  	end
  		  	
  		  	--ATT
  		  	local ATTpurchases, ATTsales
  		  	if ArkadiusTradeTools then
  		  	  ATTpurchases, ATTsales = ArkadiusTradeTools.Modules.Sales:GetPurchasesAndSalesVolumes(guildName, userID, startSalesTimeStamp, endSalesTimeStamp)
  		  	 else ATTsales = nil
  		  	end
  		  	
  		  	--Take the larger of the two
  		  	if MMsales and ATTsales then
  		  	 	if MMsales >= ATTsales
  		  	 	 then sales = MMsales
  		  	 	 else sales = ATTsales
  		  	 	end
  		  	 elseif MMsales then sales = MMsales
           elseif ATTsales then sales = ATTsales
           else d(L["AR_STR_CHAT_MM_ATT_MISSING"])
           	    return
  		  	end
  		  	
  		  	
  		  	--Get donations
  		  	local donations = 0
  		  	
  		  	--AMT
  		  	local AMTdonations
  		  	if   AMT
  		  	 and AMT.savedData
  		  	 and AMT.savedData[guildName]
  		  	 and AMT.savedData[guildName][userName]
  		  	 and AMT.savedData[guildName][userName][GUILD_EVENT_BANKGOLD_ADDED] then
  		  	 	
  		  	 	if AMTrange == 34 then
  		  	 		amountThisWeek = AMT.savedData[guildName][userName][GUILD_EVENT_BANKGOLD_ADDED][3].total
  		  	 		amountLastWeek = AMT.savedData[guildName][userName][GUILD_EVENT_BANKGOLD_ADDED][4].total
  		  	 		AMTdonations = amountLastWeek + amountThisWeek
  		  	 	 else
  		  	 		AMTdonations = AMT.savedData[guildName][userName][GUILD_EVENT_BANKGOLD_ADDED][AMTrange].total
  		  	 	end
        		--AMT DATERANGE: 1=today, 2=yesterday, 3=this week, 4=last week, 5=prior week, 6=7day, 7=10day, 8=30day
           else AMTdonations = nil
  		  	end
          
          --ITT
  		  	local ITTdonations
          if ITTsDonationBot then
    		  	ITTdonations = ITTsDonationBot:QueryValues(guildID, userID, startDonationsTimeStamp, endDonationsTimeStamp)
           else
           	ITTdonations = nil
          end
          
  		  	--Take the larger of the two
  		  	if AMTdonations and ITTdonations then
  		  	 	if AMTdonations >= ITTdonations
  		  	 	 then donations = AMTdonations
  		  	 	 else donations = ITTdonations
  		  	 	end
  		  	 elseif AMTdonations then donations = AMTdonations
           elseif ITTdonations then donations = ITTdonations
           else d(L["AR_STR_CHAT_AMT_ITT_MISSING"])
           	    return
  		  	end
  		  	
  		  	
          --Check AK saved list
          local restoreRank = AR.restoreRankCheck(userID, guildID)
          
          
          
      		for i=1, GetNumGuildRanks(guildID) do

      		  if AR.settings.rank[guild][i] and not AR.isRankAdministrative(guildID, i) then
      		  	local salesRequirement
      		  	local donationsRequirement

        			if tonumber(AR.settings.sales[guild][i])
        			 then salesRequirement = tonumber(AR.settings.sales[guild][i])
        			 else salesRequirement = -1
        		  end

        		  if tonumber(AR.settings.donations[guild][i])
        		   then donationsRequirement = tonumber(AR.settings.donations[guild][i])
        			 else donationsRequirement = -1
              end
              
              local salesRequirementMet = false
          		if salesRequirement >= 0 and sales >= salesRequirement then
          			salesRequirementMet = true
          		end
          		
          		local donationsRequirementMet = false
          		if donationsRequirement >= 0 and donations >= donationsRequirement then
          			donationsRequirementMet = true
          		end
          		
          		if donationsRequirement >= 0 and AR.settings.trackLastDonation[guild] and AR.doesLastDonationMeetRequirement(guild, userID, donationsRequirement) then
          			donationsRequirementMet = true
          		end
          		
          		local requirementsMet = false
          		if salesRequirementMet or donationsRequirementMet then
          		  requirementsMet = true
          		end
          		
      		   	if AR.settings.meetBoth[guild][i] and not (salesRequirementMet and donationsRequirementMet) then
      		   		requirementsMet = false
      		   	end
          		
          		
          		if requirementsMet
        				or AR.settings.recruits[guild] and rank==GetNumGuildRanks(guildID) and i==GetNumGuildRanks(guildID) and memberSince > AR.settings.newMemberPeriod[guild]
        				or AR.settings.restoreRank[guild] and restoreRank == GetFinalGuildRankName(guildID, i)
        		   then
          		   	
      		    	local steps = rank-i
      		    	local action = {}
      		    	
      		    	if rank==GetNumGuildRanks(guildID) and i==GetNumGuildRanks(guildID) and AR.settings.rank[guild][i-1] and AR.settings.recruits[guild] and memberSince > AR.settings.newMemberPeriod[guild]
      		    	 then steps = 1
      		    	end
      		    	
      		    	if steps == 0 then break end
      		    	
      		    	if i==GetNumGuildRanks(guildID) and AR.settings.recruits[guild] and rank ~= GetNumGuildRanks(guildID)
      		    	 then steps = steps+1
                end
                
                if (AR.settings.restrict[guild] or AR.settings.noDemote[guild][rank]) and steps<0 then break end
                
                if steps == 0 then break end
                
      		    	table.insert(action, guildID)
      		    	table.insert(action, userID)
      		      table.insert(action, steps)
      		      table.insert(action, sales)
      		      table.insert(action, donations)
      		      table.insert(action, rank)
      		      table.insert(AR.tasks, action)
      		      break
        		  end
          	end
      		end
      	end
      end
    end
  end
end