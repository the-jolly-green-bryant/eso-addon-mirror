if not AutoKick then AutoKick = {} end
local AK = AutoKick
local em = GetEventManager()
local cm = CALLBACK_MANAGER

AK.name = "AutoKick"
AK.version = "2.2.4"
AK.guilds = {}
AK.ranks = {}
AK.tasks = {}
AK.blocked = {}
AK.fullInbox = {}
AK.unknown = {}
AK.currentRecipient = ""
AK.clear = false
AK.settings = {}
AK.defaults = {
	removeAmount = 10,
	lessOnly = false,
	chatMessages = true,
	rank = {{}, {}, {}, {}, {}},
	sales = {{}, {}, {}, {}, {}},
	donations = {{}, {}, {}, {}, {}},
	offlinePeriod = {{}, {}, {}, {}, {}},
	mail = {},
	mail1 = {},
	mail2 = {},
	altMail = {},
	altMail1 = {},
	altMail2 = {},
	altMailRank = {},
	salesTimeFrame = {"Last week", "Last week", "Last week", "Last week", "Last week"},
	donationsTimeFrame = {"Last week", "Last week", "Last week", "Last week", "Last week"},
	salesWindow = {7, 7, 7, 7, 7},
	trackLastDonation = {},
	donationsWindow = {30, 30, 30, 30, 30},
	note = {},
	noteKey = {},
	rememberPlayer = {},
	rememberPlayerRank = {},
	process = {},
	restrict = {7, 7, 7, 7, 7},
	savedPlayers  = {},
}


	function AK.getIDfromName(guildname)
		for i = 1, GetNumGuilds() do
		  if guildname == GetGuildName(GetGuildId(i))
		   then return GetGuildId(i)
	    end
	  end
	end


	function AK.getIndexfromID(guildID)
		for i = 1, GetNumGuilds() do
		  if GetGuildId(i) == guildID
		   then return i
	    end
	  end
	end


  function AK.getIDfromRank(guild, rankname)
		for i = 1, 10 do
		  if rankname == GetFinalGuildRankName(GetGuildId(guild), i)
		   then return i
	    end
	  end
	end


  function AK.populateGuildTable()
  	for i = 1, GetNumGuilds() do
  		table.insert(AK.guilds, GetGuildName(GetGuildId(i)))
  	end
  end


  function AK.populateRankTable()

  	for i = 1, GetNumGuilds() do
    	local guildRanks = {}
    	local guildID = GetGuildId(i)

    	for i = 1, GetNumGuildRanks(guildID) do
    		local rank = GetFinalGuildRankName(guildID, i)
    	  	 if  not  AK.isRankAdministrative(guildID, i)
    	  	 then table.insert(guildRanks, rank)
    		  end
    	end

    	table.insert(AK.ranks, guildRanks)
	  end
  end


  function AK.isRankAdministrative(guildID, rank)
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


  function AK.doesLastDonationMeetRequirement(guild, userID, requirement, factor)
  	local guildID = GetGuildId(guild)
	  local lastDonationTime = 0
	  local lastDonationAmount = 0
	  local ITTtime, ITTamount = AK.getLastDonationITT(guildID, userID)
  	
	  if ITTtime > lastDonationTime then
	  	lastDonationTime = ITTtime
	  	lastDonationAmount = ITTamount
	  end
	  
		lastDonationAmount = lastDonationAmount*factor
	  
	  local now = GetTimeStamp()
	  local timeRequirement = now-AK.settings.donationsWindow[guild]*86400
	  
	  if lastDonationTime>=timeRequirement and lastDonationAmount~=0 and (now-lastDonationTime)/86400>7
	    and lastDonationAmount*(7*86400)/(now-lastDonationTime)>=requirement
	    or lastDonationAmount>=requirement and (now-lastDonationTime)/86400<=7
	    then return true
	    else return false
	  end
  end


  function AK.getLastDonationITT(guildID, userID)
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


	function AK.sendFailed(eventCode, reason)
		if reason == 4 then
			d("|c6C00FFAuto Kick - |cFFFFFF" .. AK.currentRecipient .. " ignores you.")
			table.insert(AK.blocked, AK.currentRecipient)
		 elseif reason == 3 then
      d("|c6C00FFAuto Kick - |cFFFFFF" .. AK.currentRecipient .. "'s inbox is full.")
			table.insert(AK.fullInbox, AK.currentRecipient)
		 else
		 	table.insert(AK.unknown, AK.currentRecipient)
		end
	end


	function AK.report()
		local failed = #AK.blocked + #AK.fullInbox + #AK.unknown

		if failed<1 then return
		 elseif failed==1 then d("|c6C00FFAuto Kick - |cFFFFFF" .. "Failed to send mails to " .. failed .. " player.")
		 elseif failed>1 then d("|c6C00FFAuto Kick - |cFFFFFF" .. "Failed to send mails to " .. failed .. " players.")
		end

		if #AK.blocked>0 then
			d("|cFFFFFFThe following players ignore you:")
			for i=1, #AK.blocked do
				d("|cFFFFFF" .. AK.blocked[i])
			end
		end

		if #AK.fullInbox>0 then
			d("|cFFFFFFThe following players had a full inbox:")
			for i=1, #AK.fullInbox do
				d("|cFFFFFF" .. AK.fullInbox[i])
			end
		end

		if #AK.unknown>0 then
			d("|cFFFFFFThe following players couldn't be messaged due to an unexpected issue:")
			for i=1, #AK.unknown do
				d("|cFFFFFF" .. AK.unknown[i])
			end
		end

		AK.blocked = {}
    AK.fullInbox = {}
    AK.unknown = {}
	end


	function AK.migrateAMTITT()
		local total = 0
		
    d("|c6C00FFAuto Kick - |cFFFFFFMigrating join dates from AMT to ITT...")
    
		if not AMT or not ITTsRosterBot then
			d("|c6C00FFAuto Kick - |cFFFFFFMigration failed. Make sure both Advanced Member Tooltip and ITTsRosterBot are active and try again.")
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
  		  d("|c6C00FFAuto Kick - |cFFFFFFSuccessfully migrated " .. counter .. " join dates for " .. guildName .. " from AMT to ITT.")
  		  total = total + counter
		  end
		end
		
  	d("|c6C00FFAuto Kick - |cFFFFFFMigration done. Migrated a total of " .. total .. " join dates across " .. GetNumGuilds() .. " guilds.")
	end


	function AK.migrateITTAMT()
		local total = 0
		
    d("|c6C00FFAuto Kick - |cFFFFFFMigrating join dates from ITT to AMT...")
    
		if not AMT or not ITTsRosterBot then
			d("|c6C00FFAuto Kick - |cFFFFFFMigration failed. Make sure both ITTsRosterBot and Advanced Member Tooltip are active and try again.")
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
  		  d("|c6C00FFAuto Kick - |cFFFFFFSuccessfully migrated " .. counter .. " join dates for " .. guildName .. " from ITT to AMT.")
  		  total = total + counter
		  end
		end
		
  	d("|c6C00FFAuto Kick - |cFFFFFFMigration done. Migrated a total of " .. total .. " join dates across " .. GetNumGuilds() .. " guilds.")
	end


	function AK.fixJoinDates()
		local total = 0
		local now = GetTimeStamp()
		local oneYearAgo = now-31536000
		
    d("|c6C00FFAuto Kick - |cFFFFFFSetting unknown join dates to 'one year ago'...")
    
		if not AMT and not ITTsRosterBot then
			d("|c6C00FFAuto Kick - |cFFFFFFOperation failed. Make sure Advanced Member Tooltip or ITTsRosterBot are active and try again.")
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
  		  d("|c6C00FFAuto Kick - |cFFFFFFSuccessfully set " .. counter .. " missing join dates for " .. guildName .. " to 'one year ago'.")
  		  total = total + counter
		  end
		end
		
  	d("|c6C00FFAuto Kick - |cFFFFFFDone. Fixed a total of " .. total .. " missing join dates across " .. GetNumGuilds() .. " guilds.")
	end


  function AK.getCurrentWeekTimes()
    local _, endTime = GetGuildKioskCycleTimes()
    
    if GetTimeStamp() > endTime
     then endTime = endTime + 604800
    end
    
    local startTime = endTime - 604800
    
    return startTime, endTime
  end


  function AK.getLastWeekTimes()
    local _, endTime = GetGuildKioskCycleTimes()
    
    if GetTimeStamp() < endTime
     then endTime = endTime - 604800
    end
    
    local startTime = endTime - 604800
    
    return startTime, endTime
  end


  function AK.slash(arg)
  	if arg == "migrateamtitt" then AK.migrateAMTITT() end
  	if arg == "migrateittamt" then AK.migrateITTAMT() end
  	if arg == "fixjoindates" then AK.fixJoinDates() end
  	
  	if arg == "list" then AK.postList() end
  	if arg == "saved" then AK.postSavedPlayers() end
  	if arg == "clear" then AK.clearSavedPlayers() end
  	if arg and string.len(arg)>2 and string.match(arg, "@") == "@" then
  		local userID = string.gsub(arg, "exclude", "")
  		local userID = string.gsub(userID, " ", "")
  		AK.excludePlayer(userID)
  	end
  end


  function AK.postList()
  	if #AK.tasks == 0 then
  		d("|c6C00FFAuto Kick - |cFFFFFFNothing to do...")
  	 else
  		d("|c6C00FFAuto Kick - |cFFFFFFList of pending removals:")
  		
  		for i=1, #AK.tasks do
  			local userID = AK.tasks[i][2]
  			local guildID = AK.tasks[i][1]
  			local guildName = GetGuildName(guildID)
  			local rankName = GetFinalGuildRankName(guildID, AK.tasks[i][6])
  			d("|cFFFFFF" .. userID .. " - " .. rankName .. "|cFFFFFF in " .. guildName)
  		end
  	end
  end


  function AK.postSavedPlayers()
  	if #AK.settings.savedPlayers ~= 0 then
  		d("|c6C00FFAuto Kick - |cFFFFFFList of saved players&ranks:")
  		for i=1, #AK.settings.savedPlayers do
  			d("|cFFFFFF" .. AK.settings.savedPlayers[i][1] .. " in " .. GetGuildName(AK.settings.savedPlayers[i][2]) .. " (" .. AK.settings.savedPlayers[i][3] .. ")")
  			d()
  		end
  	 else
  	  d("|c6C00FFAuto Kick - |cFFFFFFThere are no players on the list.")
    end
  end


  function AK.clearSavedPlayers()
  	if not AK.clear then
  		d("|c6C00FFAuto Kick - |cFFFFFFType '/ak clear' again within 10 seconds to confirm the deletion of the saved players list...")
  		AK.clear = true
  		zo_callLater(function()
  			if AK.clear then
  				AK.clear = false
  				d("|c6C00FFAuto Kick - |cFFFFFFThe deletion process has been aborted.")
  			end
  		end, 10000)
  	 else AK.settings.savedPlayers = {}
  	  d("|c6C00FFAuto Kick - |cFFFFFFList deleted.")
  	  AK.clear = false
    end
  end


  function AK.excludePlayer(player)
  	local newList = {}

  	if #AK.tasks == 0 then
  		d("|c6C00FFAuto Kick - |cFFFFFFThe list is empty")
  		return
  	end

  	for i=1, #AK.tasks do
      if player~=AK.tasks[i][2] then
      	table.insert(newList, AK.tasks[i])
      	if i==#AK.tasks and #newList==#AK.tasks then
      		d("|c6C00FFAuto Kick - |cFFFFFFFound no player named '" .. player .. "' on the list")
      	end
       else
      	d("|c6C00FFAuto Kick - |cFFFFFF" .. player .. " removed from the list")
      end
  	end

  	AK.tasks = newList
  end




function AK.Initialize(event, addon)

	if addon ~= AK.name then return end

	em:UnregisterForEvent("AutoKickInitialize", EVENT_ADD_ON_LOADED)

	AK.populateGuildTable()

	AK.populateRankTable()

	AK.settings = ZO_SavedVars:NewAccountWide("AutoKickSavedVars", 1, nil, AK.defaults)

	ZO_CreateStringId("SI_BINDING_NAME_AUTO_KICK_START", "Makes a list of members to kick")

	AK.MakeMenu()

	SLASH_COMMANDS['/ak'] = AK.slash
	
end

em:RegisterForEvent("AutoKickInitialize", EVENT_ADD_ON_LOADED, function(...) AK.Initialize(...) end)




function AK.doTasks(tasks)

	local i = 1
	em:UnregisterForUpdate("AKprocessing")
	em:UnregisterForEvent("AutoKickFailed", EVENT_MAIL_SEND_FAILED)

	CHAT_SYSTEM:Maximize()

	if #tasks > 1 then
    d("|c6C00FFAuto Kick - |cFFFFFFProcessing " .. #tasks .. " removals...")
   elseif #tasks == 1 then
  	d("|c6C00FFAuto Kick - |cFFFFFFProcessing " .. #tasks .. " removal...")
   else
  	d("|c6C00FFAuto Kick - |cFFFFFFNothing to do...")
  	cm:FireCallbacks("AutoKickDone", "AKdone")
  	return
  end

  AK.blocked = {}
  AK.fullInbox = {}
  AK.unknown = {}
  AK.currentRecipient = ""
  em:RegisterForEvent("AutoKickFailed", EVENT_MAIL_SEND_FAILED, AK.sendFailed)
	em:RegisterForUpdate("AKprocessing", 1600, function()
    local guildID = tasks[i][1]
    local userID = tasks[i][2]
    local offlineTime = math.floor(tasks[i][3])
    local sales = tasks[i][4]
    local donations = tasks[i][5]
    local rank = tasks[i][6]
    local guild = AK.getIndexfromID(guildID)
    local altMailRank = AK.getIDfromRank(guild, AK.settings.altMailRank[guild])
    local rememberRank = AK.getIDfromRank(guild, AK.settings.rememberPlayerRank[guild])


	  if AK.settings.altMail[guild] and AK.settings.altMailRank[guild] and rank==altMailRank then
	    if not AK.settings.altMail1[guild] or AK.settings.altMail1[guild]=="" or not AK.settings.altMail2[guild] or AK.settings.altMail2[guild]==""
       then em:UnregisterForUpdate("AKprocessing")
     	      d("|c6C00FFAuto Kick - |cFFFFFFThere is no '" .. AK.settings.altMailRank[guild] .. "|cFFFFFF' message text for " .. GetGuildName(guildID) .. " set up. Check your settings!")
     	 else
        GuildRemove(guildID, userID)

        if AK.settings.chatMessages then
         d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF removed from ".. GetGuildName(guildID) .. "|c82fa58 - '" .. AK.settings.altMailRank[guild] .. "' message sent.")
        end

        local text = string.gsub(string.gsub(string.gsub(AK.settings.altMail2[guild], "#SALES", sales), "#DONATIONS", donations), "#AFK", offlineTime)
        AK.currentRecipient = userID

       	RequestOpenMailbox()
       	QueueMoneyAttachment(0)
        SendMail(userID, AK.settings.altMail1[guild], text)
        CloseMailbox()

        if AK.settings.rememberPlayer[guild] and rank==rememberRank then
        	local playerData = {}
        	table.insert(playerData, userID)
        	table.insert(playerData, guildID)
        	table.insert(playerData, AK.settings.rememberPlayerRank[guild])

          if not AK.settings.savedPlayers[1] then
      	   	table.insert(AK.settings.savedPlayers, playerData)
      	   	d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF added to the list of saved member ranks.")
      	   else
          	for i=1, #AK.settings.savedPlayers do
          	  if AK.settings.savedPlayers[i][1] == playerData[1] and AK.settings.savedPlayers[i][2] == playerData[2] and AK.settings.savedPlayers[i][3] == playerData[3] then
          	  	d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF is already on the list of saved member ranks.")
          	  	break
          	   elseif i==#AK.settings.savedPlayers then
          	   	table.insert(AK.settings.savedPlayers, playerData)
          	   	d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF added to the list of saved member ranks.")
          	  end
          	end
          end
        end

        i = i+1
	    end

	   elseif AK.settings.mail[guild] then
	  	if not AK.settings.mail1[guild] or AK.settings.mail1[guild]=="" or not AK.settings.mail2[guild] or AK.settings.mail2[guild]==""
       then em:UnregisterForUpdate("AKprocessing")
     	      d("|c6C00FFAuto Kick - |cFFFFFFThere is no message text for " .. GetGuildName(guildID) .. " set up. Check your settings!")
     	 else
        GuildRemove(guildID, userID)

        if AK.settings.chatMessages then
         d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF removed from ".. GetGuildName(guildID) .. "|c82fa58 - Message sent.")
        end

        local text = string.gsub(string.gsub(string.gsub(AK.settings.mail2[guild], "#SALES", sales), "#DONATIONS", donations), "#AFK", offlineTime)
        AK.currentRecipient = userID

       	RequestOpenMailbox()
       	QueueMoneyAttachment(0)
        SendMail(userID, AK.settings.mail1[guild], text)
        CloseMailbox()

        if AK.settings.rememberPlayer[guild] and rank==rememberRank then
        	local playerData = {}
        	table.insert(playerData, userID)
        	table.insert(playerData, guildID)
        	table.insert(playerData, AK.settings.rememberPlayerRank[guild])

          if not AK.settings.savedPlayers[1] then
      	   	table.insert(AK.settings.savedPlayers, playerData)
      	   	d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF added to the list of saved member ranks.")
      	   else
          	for i=1, #AK.settings.savedPlayers do
          	  if AK.settings.savedPlayers[i][1] == playerData[1] and AK.settings.savedPlayers[i][2] == playerData[2] and AK.settings.savedPlayers[i][3] == playerData[3] then
          	  	d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF is already on the list of saved member ranks.")
          	  	break
          	   elseif i==#AK.settings.savedPlayers then
          	   	table.insert(AK.settings.savedPlayers, playerData)
          	   	d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF added to the list of saved member ranks.")
          	  end
          	end
          end
        end

        i = i+1
	    end

	   elseif AK.settings.altMail[guild] then
        GuildRemove(guildID, userID)

        if AK.settings.chatMessages then
         d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF removed from ".. GetGuildName(guildID) .. ".")
        end

        if AK.settings.rememberPlayer[guild] and rank==rememberRank then
        	local playerData = {}
        	table.insert(playerData, userID)
        	table.insert(playerData, guildID)
        	table.insert(playerData, AK.settings.rememberPlayerRank[guild])

          if not AK.settings.savedPlayers[1] then
      	   	table.insert(AK.settings.savedPlayers, playerData)
      	   	d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF added to the list of saved member ranks.")
      	   else
          	for i=1, #AK.settings.savedPlayers do
          	  if AK.settings.savedPlayers[i][1] == playerData[1] and AK.settings.savedPlayers[i][2] == playerData[2] and AK.settings.savedPlayers[i][3] == playerData[3] then
          	  	d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF is already on the list of saved member ranks.")
          	  	break
          	   elseif i==#AK.settings.savedPlayers then
          	   	table.insert(AK.settings.savedPlayers, playerData)
          	   	d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF added to the list of saved member ranks.")
          	  end
          	end
          end
        end

        i = i+1

	   else
	   	em:RegisterForUpdate("AKprocessingquick", 20, function()
    		guildID = tasks[i][1]
        userID = tasks[i][2]
        guild = AK.getIndexfromID(guildID)

        GuildRemove(guildID, userID)

        if AK.settings.chatMessages then
         d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF removed from ".. GetGuildName(guildID))
        end

        if AK.settings.rememberPlayer[guild] and rank==rememberRank then
        	local playerData = {}
        	table.insert(playerData, userID)
        	table.insert(playerData, guildID)
        	table.insert(playerData, AK.settings.rememberPlayerRank[guild])

          if not AK.settings.savedPlayers[1] then
      	   	table.insert(AK.settings.savedPlayers, playerData)
      	   	d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF added to the list of saved member ranks.")
      	   else
          	for i=1, #AK.settings.savedPlayers do
          	  if AK.settings.savedPlayers[i][1] == playerData[1] and AK.settings.savedPlayers[i][2] == playerData[2] and AK.settings.savedPlayers[i][3] == playerData[3] then
          	  	d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF is already on the list of saved member ranks.")
          	  	break
          	   elseif i==#AK.settings.savedPlayers then
          	   	table.insert(AK.settings.savedPlayers, playerData)
          	   	d("|c6C00FFAuto Kick - |cFFFFFF" .. userID .. "|cFFFFFF added to the list of saved member ranks.")
          	  end
          	end
          end
        end

        i = i+1

    		if not tasks[i] then
    			em:UnregisterForUpdate("AKprocessingquick")
    			em:UnregisterForUpdate("AKprocessing")
    			em:UnregisterForEvent("AutoKickFailed", EVENT_MAIL_SEND_FAILED)
    			AK.tasks = {}
    			AK.currentRecipient = ""
    			d("|c6C00FFAuto Kick - |cFFFFFFDONE!")
    			AK.report()
    	    cm:FireCallbacks("AutoKickDone", "AKdone")
    	   elseif tasks[i][1]~=tasks[i-1][1] then
    	  	 em:UnregisterForUpdate("AKprocessingquick")
    		end
    	end)
	  end

  	if not tasks[i] then
			em:UnregisterForUpdate("AKprocessing")
			em:UnregisterForEvent("AutoKickFailed", EVENT_MAIL_SEND_FAILED)
			AK.tasks = {}
			AK.currentRecipient = ""
	    d("|c6C00FFAuto Kick - |cFFFFFFDONE!")
	    AK.report()
	    cm:FireCallbacks("AutoKickDone", "AKdone")
		end
	end)

end



function AK.makeList(index)

	CHAT_SYSTEM:Maximize()

	if MasterMerchant and not MasterMerchant.isInitialized then
    d("|c6C00FFAuto Kick - |cFFFFFFPlease wait for MM to finish initializing...")
    return
  end

	AK.process(1, index)

	if #AK.tasks > 10 then
    d("|c6C00FFAuto Kick - |cFFFFFFFound " .. #AK.tasks .. " members to remove")
    d("|cFFFFFFType '/ak list' to show the members on the list")
   elseif #AK.tasks > 1 then
   	d("|c6C00FFAuto Kick - |cFFFFFFFound " .. #AK.tasks .. " members to remove")
   	AK.postList()
   elseif #AK.tasks == 1 then
  	d("|c6C00FFAuto Kick - |cFFFFFFFound one member to remove:")
  	d("|cFFFFFF" .. AK.tasks[1][2] .. " - " .. GetFinalGuildRankName(AK.tasks[1][1], AK.tasks[1][6]) .. "|cFFFFFF in " .. GetGuildName(AK.tasks[1][1]))
   else
  	d("|c6C00FFAuto Kick - |cFFFFFFNothing to do...")
  	return
  end

end



function AK.kickAmount(index, chat)

	if chat~=2 then CHAT_SYSTEM:Maximize() end

  if MasterMerchant and not MasterMerchant.isInitialized then
    d("|c6C00FFAuto Kick - |cFFFFFFPlease wait for MM to finish initializing...")
    return
  end

	local factor = 1
	local i = 1
	local disparity = 1
	local token = 0

	if not index then index = 0 end

	AK.tasks = {}

  if AK.settings.lessOnly then AK.process(1, index) else AK.process(0, index) end

  if #AK.tasks == 0 and index == 0 then
    if chat~=2 then d("|c6C00FFAuto Kick - |cFFFFFFFound no members to remove. Check your settings!") end
  	return
   elseif #AK.tasks == 0 then
   	if chat~=2 then d("|c6C00FFAuto Kick - |cFFFFFFFound no members to remove from " .. GetGuildName(GetGuildId(index)) .. ". Check your settings!") end
    return
   elseif #AK.tasks < AK.settings.removeAmount then
  	if chat~=2 then
  		d("|cFFFFFFCouldn't approximate " .. AK.settings.removeAmount .. " members to kick. Check your settings!")
  		
  	  if AK.settings.lessOnly then
        if #AK.tasks>10 then
        	d("|c6C00FFAuto Kick - |cFFFFFFFound " .. #AK.tasks .. " members to remove at normal requirements")
        	d("|cFFFFFFType '/ak list' to show the members on the list")
         elseif #AK.tasks > 1 then
     	    d("|c6C00FFAuto Kick - |cFFFFFFFound " .. #AK.tasks .. " members to remove at normal requirements")
         	AK.postList()
         elseif #AK.tasks == 1 then
     	    d("|c6C00FFAuto Kick - |cFFFFFFFound " .. #AK.tasks .. " member to remove at normal requirements")
    	    d("|cFFFFFF" .. AK.tasks[1][2] .. " in " .. GetGuildName(AK.tasks[1][1]))
        end
    	 else
        if #AK.tasks>10 then
        	d("|c6C00FFAuto Kick - |cFFFFFFFound " .. #AK.tasks .. " members to remove at infinite requirements")
        	d("|cFFFFFFType '/ak list' to show the members on the list")
         elseif #AK.tasks > 1 then
     	    d("|c6C00FFAuto Kick - |cFFFFFFFound " .. #AK.tasks .. " members to remove at infinite requirements")
         	AK.postList()
         elseif #AK.tasks == 1 then
     	    d("|c6C00FFAuto Kick - |cFFFFFFFound " .. #AK.tasks .. " member to remove at infinite requirements")
    	    d("|cFFFFFF" .. AK.tasks[1][2] .. " in " .. GetGuildName(AK.tasks[1][1]))
        end
      end
  	end
    return
  end

  AK.process(1, index)

	if #AK.tasks < AK.settings.removeAmount and not AK.settings.lessOnly then --approximation algorithm increase requirements
    token = 1
    
  	while #AK.tasks < AK.settings.removeAmount do
  		disparity = (AK.settings.removeAmount-#AK.tasks)/20
  		if disparity >= 1 then disparity = 0.99 end
  		factor = factor * (1-disparity)
  		AK.process(factor, index)
  		i = i+1
  		if i == 100 then
  			if chat ~= 0 and chat~=2 then
  			  d("|cFFFFFFCouldn't approximate " .. AK.settings.removeAmount .. " members to kick. Check your settings!")
  			end
  			break
  		end
  	end

  	while #AK.tasks > AK.settings.removeAmount do
  		disparity = (#AK.tasks-AK.settings.removeAmount)/100
  		factor = factor * (1+disparity)
  		AK.process(factor, index)
  		i = i+1
  		if i == 100 then break end
  	end


   elseif #AK.tasks > AK.settings.removeAmount then --approximation algorithm decrease requirements
    token = 2
    
  	while #AK.tasks > AK.settings.removeAmount do
  		disparity = (#AK.tasks-AK.settings.removeAmount)/20
  		factor = factor * (1+disparity)
  		AK.process(factor, index)
  		i = i+1
  		if i == 100 then
  			local oldList = {}
  			local newList = {}
  			oldList = AK.tasks

    		for i=1, AK.settings.removeAmount do
    			table.insert(newList, oldList[i])
    		end

  			AK.tasks=newList

  			if chat ~= 0 and chat~=2 then
  				d("|cFFFFFFCouldn't approximate " .. AK.settings.removeAmount .. " members to kick. Selecting " .. #AK.tasks .. " random players out of a total of " .. #oldList .. " below the requirements...")
  			end
  			break
  		end
  	end

  	while #AK.tasks < AK.settings.removeAmount do
  		disparity = (AK.settings.removeAmount-#AK.tasks)/100
  		factor = factor * (1-disparity)
  		AK.process(factor, index)
  		i = i+1
  		if i == 100 then break end
  	end

  end
  
  factor=1/factor

  if token == 0 then
  	factor = "normal"
   elseif token == 1 then
    if factor>100 or factor<0.01 then
    	factor="over 100x"
     elseif factor>10 then
    	factor=math.floor(factor) .. "x"
     elseif factor>2 then
    	factor=0.1*math.floor(factor*10) .. "x"
     elseif factor>1 then
    	factor=math.floor(factor*100) .. "%"
    end
   elseif token == 2 then
    if factor>10 then
    	factor=100*math.floor(factor) .. "%"
     elseif factor>1 then
    	factor=10*math.floor(factor*10) .. "%"
     elseif factor>0.1 then
    	factor=math.floor(factor*100) .. "%"
     elseif factor>0.01 then
    	factor=0.1*math.floor(factor*1000) .. "%"
     elseif factor<0.01 then
    	factor="smaller than 1%"
    end
  end

  if #AK.tasks > AK.settings.removeAmount then
  	local list = {}
  	for i=1, AK.settings.removeAmount do
  		table.insert(list, AK.tasks[i])
  	end
  	AK.tasks = list
  end

  if chat ~= 0 and chat~=2 then
    if #AK.tasks>10 then
    	d("|c6C00FFAuto Kick - |cFFFFFFFound " .. #AK.tasks .. " members to remove at " .. factor .. " requirements")
    	d("|cFFFFFFType '/ak list' to show the members on the list")
     elseif #AK.tasks>1 then 
    	d("|c6C00FFAuto Kick - |cFFFFFFFound " .. #AK.tasks .. " members to remove at " .. factor .. " requirements")
     	AK.postList()
     elseif #AK.tasks == 1 then
    	d("|c6C00FFAuto Kick - |cFFFFFFFound " .. #AK.tasks .. " member to remove at " .. factor .. " requirements")
     	AK.postList()
     else
  	  d("|c6C00FFAuto Kick - |cFFFFFFNothing to do...")
    end
  end
end



function AK.process(factor, index)

	em:UnregisterForUpdate("AKprocessing")
	AK.tasks = {}

	if not index then index = 0 end


  for guild=1, GetNumGuilds() do
  	
    if AK.settings.process[guild] and index == 0 or index == guild then
    	
    	local memberList = {}
    	local guildID = GetGuildId(guild)
    	local guildName = GetGuildName(guildID)
    	local startSalesTimeStamp
    	local endSalesTimeStamp
      local startDonationsTimeStamp
      local endDonationsTimeStamp
      local MMtimeframe
      local AMTrange
      local now = GetTimeStamp()
      local currentWeekStart, currentWeekEnd = AK.getCurrentWeekTimes()
      local lastWeekStart, lastWeekEnd = AK.getLastWeekTimes()
      
      
      
		  if DoesGuildRankHavePermission(guildID, zo_strformat("<<3>>", GetGuildMemberInfo(guildID, GetGuildMemberIndexFromDisplayName(guildID, GetDisplayName()))), GUILD_PERMISSION_REMOVE) and #AK.ranks[guild]>0 then
		  	
        if AK.settings.salesTimeFrame[guild] == "This week" then
         	startSalesTimeStamp = currentWeekStart
         	endSalesTimeStamp = now
        	MMtimeframe = 3
         elseif AK.settings.salesTimeFrame[guild] == "Last week" then
         	startSalesTimeStamp = lastWeekStart
         	endSalesTimeStamp = lastWeekEnd
         	MMtimeframe = 4
         elseif AK.settings.salesTimeFrame[guild] == "Custom" then
         	startSalesTimeStamp = now-AK.settings.salesWindow[guild]*86400
         	endSalesTimeStamp = now
         	MMtimeframe = 9
        end
  		  
  		  
        if AK.settings.donationsTimeFrame[guild] == "This week" then
        	startDonationsTimeStamp = currentWeekStart
        	endDonationsTimeStamp = now
        	AMTrange = 3
         elseif AK.settings.donationsTimeFrame[guild] == "Last week" then
        	startDonationsTimeStamp = lastWeekStart
        	endDonationsTimeStamp = lastWeekEnd
         	AMTrange = 4
         elseif AK.settings.donationsTimeFrame[guild] == "This+Last week" then
        	startDonationsTimeStamp = lastWeekStart
        	endDonationsTimeStamp = now
         	AMTrange = 34
  		   elseif AK.settings.donationsTimeFrame[guild] == "All" then
        	startDonationsTimeStamp = 0
        	endDonationsTimeStamp = now
  		   	AMTrange = 8
  		   elseif AK.settings.donationsTimeFrame[guild] == "Custom" then
        	startDonationsTimeStamp = now-AK.settings.donationsTime[guild]*86400
        	endDonationsTimeStamp = now
  		   	AMTrange = 10
        end
  		  
  		  
     	  for i=1, GetNumGuildMembers(guildID) do
      		local userID, note, rank = GetGuildMemberInfo(guildID, i)
      		
      		if AK.settings.rank[guild][rank]
      		  and not (AK.settings.note[guild] and string.len(note)>0 and (not AK.settings.noteKey[guild] or AK.settings.noteKey[guild] and string.len(AK.settings.noteKey[guild])==0))
      		  and not (AK.settings.note[guild] and AK.settings.noteKey[guild] and string.len(AK.settings.noteKey[guild])>0 and zo_strfind(note, AK.settings.noteKey[guild]))
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
           else d("|c6C00FFAuto Kick |cFFFFFFneeds AMT or ITT to operate properly!")
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
           else d("|c6C00FFAuto Kick |cFFFFFFneeds MM or ATT to scan sales!")
           	    return
  		  	end
  		  	
          if AK.settings.salesTimeFrame[guild] == "This week" and memberSince<7
           then sales = (7/memberSince)*sales
           elseif AK.settings.salesTimeFrame[guild] == "Last week" and memberSince<7
           then sales = (7/memberSince)*sales
           elseif AK.settings.salesTimeFrame[guild] == "Custom" and AK.settings.salesWindow[guild] and memberSince<tonumber(AK.settings.salesWindow[guild])
           then sales = (tonumber(AK.settings.salesWindow[guild])/memberSince)*sales
          end
          
  		  	sales = sales*factor
          
  		  	
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
           else d("|c6C00FFAuto Kick |cFFFFFFneeds AMT or ITT to scan donations!")
           	    return
  		  	end
  		  	
          donations = donations*factor
          
          
      		--Get offline time
      		local offlineTime=zo_strformat("<<5>>", GetGuildMemberInfo(guildID, GetGuildMemberIndexFromDisplayName(guildID, userID)))/86400

      		offlineTime = offlineTime/factor


      		for i=GetNumGuildRanks(guildID), 1, -1 do

      		  if AK.settings.rank[guild][i] and not AK.isRankAdministrative(guildID, i) and rank == i then
      		  	local salesRequirement
      		  	local donationsRequirement
          		local afk

        			if tonumber(AK.settings.sales[guild][i])
        			 then salesRequirement = tonumber(AK.settings.sales[guild][i])
        			 else salesRequirement = -1
        		  end

        		  if tonumber(AK.settings.donations[guild][i])
        		   then donationsRequirement = tonumber(AK.settings.donations[guild][i])
        			 else donationsRequirement = -1
              end

          		if AK.settings.offlinePeriod[guild][i] and AK.settings.offlinePeriod[guild][i]>0
          		 then if AK.settings.offlinePeriod[guild][i]<offlineTime
          			     then afk=1
          			     else afk=0
          			    end
          		 else afk=-1
          		end


        			if sales >= salesRequirement and salesRequirement >= 0
        				or donations >= donationsRequirement and donationsRequirement >= 0
        				or AK.doesLastDonationMeetRequirement(guild, userID, donationsRequirement, factor) and AK.settings.trackLastDonation[guild] and donationsRequirement >= 0
        				or afk==0
                or memberSince<AK.settings.restrict[guild]
        		   then break
        		   elseif donationsRequirement>0 or salesRequirement>0 or afk>0 then

      		    	local action = {}

      		    	table.insert(action, guildID)
      		    	table.insert(action, userID)
      		      table.insert(action, offlineTime)
      		      table.insert(action, sales)
      		      table.insert(action, donations)
      		      table.insert(action, rank)
      		      table.insert(AK.tasks, action)

      		      break
        		  end
          	end
      		end
      	end
      end
    end
  end
end