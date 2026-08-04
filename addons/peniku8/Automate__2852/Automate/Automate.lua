if not Automate then Automate = {} end
local AM = Automate
local em = GetEventManager()
local cm = CALLBACK_MANAGER
AutomateKeybind = {}

AM.name = "Automate"
AM.version = "1.2.22"
AM.stage = 0
AM.settings = {}
AM.defaults = {
    
    process = {},
    interval = 5,
    ranks = {},
    kick = {},
    kickThreshold = {499, 499, 499, 499, 499},
    kickAmount = {5, 5, 5, 5, 5},
    apps = {},
    minCP = {0, 0, 0, 0, 0},
    appText = {},
    declineReason = {"", "", "", "", ""},
    welcomeText = {},
    welcomeText1 = {"", "", "", "", ""},
    welcomeText2 = {"", "", "", "", ""},
    altInvite = {},
    altGuild = {"", "", "", "", ""},
    altText = {},
    altText1 = {"", "", "", "", ""},
    altText2 = {"", "", "", "", ""},

}


  function AM.getGuildIndex(guildID)
		for i = 1, GetNumGuilds() do
		  if guildID == GetGuildId(i)
		   then return i
	    end
	  end
	end
	
	
  function AM.getGuildIndexFromName(guildName)
		for i = 1, GetNumGuilds() do
		  if GetGuildName(GetGuildId(i)) == guildName
		   then return i
	    end
	  end
	end
	
	
	function AM.getAppIndexFromID(guildID, userID)
		for i=1, GetGuildFinderNumGuildApplications(guildID) do
			if userID == zo_strformat("<<5>>", GetGuildFinderGuildApplicationInfoAt(guildID, i))
			 then return i
			end
		end
	end
  
  
  function AutomateKeybind.start()
   	 AM.start()
  end
  
  
  function AutomateKeybind.stop()
   	 AM.stop()
  end
  
  
  function AM.appAccepted(eventCode, guildID, userID, result)
  	local index = AM.getAppIndexFromID(guildID, userID)
  	if result == 5 then
  		DeclineGuildApplication(guildID, index)
  	end
  end
  
  
  function AM.start()
  	
  	local interval = AM.settings.interval*60000
  	em:UnregisterForUpdate("Automate")
  	
    CHAT_SYSTEM:Maximize()
  	d("|c6C00FFAutomate - |cFFFFFFProcessing your guilds every " .. AM.settings.interval .. " minutes.")
    
 	  zo_callLater(function() AM.process(1) end, 1000)
  	
  	em:RegisterForUpdate("Automate", interval, function()
      if AM.stage == 0 then AM.process() end
    end)
    
  end
  
  
  function AM.stop()
  	em:UnregisterForUpdate("Automate")
  	CHAT_SYSTEM:Maximize()
  	d("|c6C00FFAutomate - |cFFFFFFPaused all actions.")
  end




function AM.Initialize(event, addon)
	
	if addon ~= AM.name then return end
	
	em:UnregisterForEvent("AutomateInitialize", EVENT_ADD_ON_LOADED)

	AM.settings = ZO_SavedVars:NewAccountWide("AutomateSavedVars", 1, nil, AM.defaults)

	ZO_CreateStringId("SI_BINDING_NAME_AUTOMATE_START", "Start Automate")
	ZO_CreateStringId("SI_BINDING_NAME_AUTOMATE_STOP", "Stop Automate")
	
	em:RegisterForEvent("AutomateAppAccepted", EVENT_GUILD_FINDER_PROCESS_APPLICATION_RESPONSE, AM.appAccepted)
	
  AM.MakeMenu()
	
end

em:RegisterForEvent("AutomateInitialize", EVENT_ADD_ON_LOADED, function(...) AM.Initialize(...) end)




function AM.overflow(tasks)
	if #tasks < 1 then AM.stage = 0 return end
	local i=1
  
	em:RegisterForUpdate("AMalt", 16000, function()
		local guildID, userID, guild = unpack(tasks[i])
		
    GuildInvite(guildID, userID)
    
   	if AM.settings.altText[guild] and string.len(AM.settings.altText2[guild])>1 then
     	RequestOpenMailbox()
     	QueueMoneyAttachment(0)
      SendMail(userID, AM.settings.altText1[guild], AM.settings.altText2[guild])
      CloseMailbox()
    end
    
    i = i+1
    
		if not tasks[i] then
			em:UnregisterForUpdate("AMalt")
			AM.stage = 0
		end
  end)
end



function AM.handleApplicants(tasks)
	
	local i=1
	local overflow = {}
	em:UnregisterForUpdate("AMprocessing")
	AM.stage = 4
	
	if #tasks > 1 then
    d("|c6C00FFAutomate - |cFFFFFFProcessing " .. #tasks .. " applicants...")
   elseif #tasks == 1 then
  	d("|c6C00FFAutomate - |cFFFFFFProcessing " .. #tasks .. " applicant...")
   else
   	AM.stage = 0
  	return
  end
  
  
	em:RegisterForUpdate("AMprocessing", 2000, function()
		local guildID, userID, CP, AP, text = unpack(tasks[i])
		local guild = AM.getGuildIndex(guildID)
		local space = 500 - (tonumber(zo_strformat("<<1>>", GetGuildInfo(guildID))) + tonumber(zo_strformat("<<4>>", GetGuildInfo(guildID))))
		local index = AM.getAppIndexFromID(guildID, userID)
	  local altGuild = AM.getGuildIndexFromName(AM.settings.altGuild[guild])
	  local altGuildID = GetGuildId(altGuild)
		local altSpace = 500 - (tonumber(zo_strformat("<<1>>", GetGuildInfo(altGuildID))) + tonumber(zo_strformat("<<4>>", GetGuildInfo(altGuildID))) + #overflow)
    
    if (CP>AM.settings.minCP[guild] or AM.settings.minCP[guild]==0 or string.len(text) > 0 and AM.settings.appText[guild]) and space > 5
     then
     	
     	AcceptGuildApplication(guildID, index)
     	
      zo_callLater(function()
       	if GetGuildMemberIndexFromDisplayName(guildID, userID) then
          if AM.settings.welcomeText[guild] and string.len(AM.settings.welcomeText2[guild])>1 then
           	RequestOpenMailbox()
           	QueueMoneyAttachment(0)
            SendMail(userID, AM.settings.welcomeText1[guild], AM.settings.welcomeText2[guild])
            CloseMailbox()
            d("|c6C00FFAutomate - |cFFFFFFWelcome message was sent to " .. userID)
          end
 				end
      end, 1000)
      
     elseif not (CP>AM.settings.minCP[guild] or AM.settings.minCP[guild]==0 or string.len(text) > 0 and AM.settings.appText[guild]) then
     	
     	DeclineGuildApplication(guildID, index, AM.settings.declineReason[guild])
     	if string.len(AM.settings.altGuild[guild])>0 then
       	if (CP>AM.settings.minCP[altGuild] or AM.settings.minCP[altGuild]==0 or string.len(text)>0 and AM.settings.appText[altGuild])
       	  and altSpace>1 and AM.settings.altInvite[guild] and not GetGuildMemberIndexFromDisplayName(altGuildID, userID) 
         then table.insert(overflow, {altGuildID, userID, guild})
        end
      end
     	
    end
    
    i = i+1
    
		if not tasks[i] then
			em:UnregisterForUpdate("AMprocessing")
			if overflow[1] then AM.overflow(overflow) else AM.stage = 0 end
		end
  end)
end



function AM.apps()
	
	AM.stage = 3
	cm:UnregisterCallback("AutoKickDone")
  
  local tasks = {}
  
  for i=1, GetNumGuilds() do
  	local guildID = GetGuildId(i)
  	local freeSpots = 500-zo_strformat("<<1>>", GetGuildInfo(guildID))
  	
  	if AM.settings.process[i] and AM.settings.apps[i] and freeSpots>4 then
  		
  		if not DoesGuildRankHavePermission(guildID, zo_strformat("<<3>>", GetGuildMemberInfo(guildID, GetGuildMemberIndexFromDisplayName(guildID, GetDisplayName()))), GUILD_PERMISSION_MANAGE_APPLICATIONS) then
        d("|c6C00FFAutomate - |cFFFFFFYou don't have permission to handle applicants in " .. GetGuildName(guildID))
       else
    		for i=GetGuildFinderNumGuildApplications(guildID), 1, -1 do
    			local level, CP, alliance, class, userID, charName, AP, text = GetGuildFinderGuildApplicationInfoAt(guildID, i)
    			table.insert(tasks, {guildID, userID, CP, AP, text})
    		end
    	end
  	end
  end
  
  AM.handleApplicants(tasks)
end



function AM.kick()
	
  local AK = AutoKick
	AM.stage = 2
  cm:UnregisterCallback("AutoRanksDone")
  cm:RegisterCallback("AutoKickDone", AM.apps)
  
  if AK then
  	
  	local tasks = {}
  	
    for i=1, GetNumGuilds() do
    	    	
  	  if AM.settings.process[i] and AM.settings.kick[i] then
  	  	
    	  local members = tonumber(zo_strformat("<<1>>", GetGuildInfo(GetGuildId(i)))) + tonumber(zo_strformat("<<4>>", GetGuildInfo(GetGuildId(i))))
  	  	
  	  	if members>=AM.settings.kickThreshold[i] then
    	  	local memory = AK.settings.removeAmount
    	  	 	  	  	
    	  	AK.settings.removeAmount = AM.settings.kickAmount[i]
    	  	
    	  	AK.kickAmount(i, 2)
    	  	
      		for i=1, #AK.tasks do
      			tasks[#tasks+1] = AK.tasks[i]
      		end
      		
      		if #AK.tasks > 0 then
      			d("|c6C00FFAutomate - |cFFFFFFRemoving members from " .. GetGuildName(GetGuildId(i)))
          end
      		
    	  	AK.settings.removeAmount = memory
    	  end
  	  end
  	end
  	
    if tasks[1]
     then AK.doTasks(tasks)
     else cm:FireCallbacks("AutoKickDone", "AKdone")
    end
    
   else
  	cm:FireCallbacks("AutoKickDone", "AKdone")
  end
end



function AM.process(index)
	
	local AR = AutoRanks
	AM.stage = 1
	cm:RegisterCallback("AutoRanksDone", AM.kick)
	
	if AR then
		
  	local tasks = {}
  	
	  for i=1, GetNumGuilds() do
    	if AM.settings.process[i] and AM.settings.ranks[i] then
    		AR.process(i)
    		for i=1, #AR.tasks do
    			tasks[#tasks+1] = AR.tasks[i]
    		end
    	end
    end
    
    if tasks[1]
     then AR.doTasks(tasks)
     else 
     	if index==1 then AR.doTasks(tasks)
     	 else cm:FireCallbacks("AutoRanksDone", "ARdone")
     	end
    end
    
   else
  	cm:FireCallbacks("AutoRanksDone", "ARdone")
  end
end