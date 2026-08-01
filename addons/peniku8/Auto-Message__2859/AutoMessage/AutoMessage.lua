if AutoMessage == nil then AutoMessage = {} end
local AM = AutoMessage
local em = GetEventManager()

AM.name = "AutoMessage"
AM.version = "1.4.12"
AM.blocked = {}
AM.fullInbox = {}
AM.unknown = {}
AM.currentRecipient = ""
AM.settings = {}
AM.defaults = {
    list = "",
    mail1 = "",
    mail2 = "",
    chatMessages = false,
    note = false,
    guild = {},
    rank = {{}, {}, {}, {}, {}},
}



	function AM.tableFind(table, userID)
		for i=1, #table do
			if table[i][1] == userID
			 then return true
			end
		end
	end
	
	
	function AM.sendFailed(eventCode, reason)
		if reason == 4 then
			d("|c6C00FFAuto Message - |cFFFFFF " .. AM.currentRecipient .. " ignores you.")
			table.insert(AM.blocked, AM.currentRecipient)
		 elseif reason == 3 then
      d("|c6C00FFAuto Message - |cFFFFFF " .. AM.currentRecipient .. "'s inbox is full.")
			table.insert(AM.fullInbox, AM.currentRecipient)
		 else
		 	table.insert(AM.unknown, AM.currentRecipient)
		end
	end
	
	
	function AM.report()
		local failed = #AM.blocked + #AM.fullInbox + #AM.unknown
		
		if failed<1 then return
		 elseif failed==1 then
		 	CHAT_SYSTEM:Maximize()
		 	d("|c6C00FFAuto Message - |cFFFFFF Failed to send mails to " .. failed .. " player.")
		 elseif failed>1 then
		 	CHAT_SYSTEM:Maximize()
		 	d("|c6C00FFAuto Message - |cFFFFFF Failed to send mails to " .. failed .. " players.")
		end
		
		if #AM.blocked>0 then
			d("|cFFFFFFThe following players ignore you:")
			for i=1, #AM.blocked do
				d("|cFFFFFF" .. AM.blocked[i])
			end
		end
		
		if #AM.fullInbox>0 then
			d("|cFFFFFFThe following players had a full inbox:")
			for i=1, #AM.fullInbox do
				d("|cFFFFFF" .. AM.fullInbox[i])
			end
		end
		
		if #AM.unknown>0 then
			d("|cFFFFFFThe following players couldn't be messaged due to an unexpected issue:")
			for i=1, #AM.unknown do
				d("|cFFFFFF" .. AM.unknown[i])
			end
		end
		
    AM.blocked = {}
    AM.fullInbox = {}
    AM.unknown = {}
	end




function AM.Initialize(event, addon)
	
	if addon ~= AM.name then return end
	
	em:UnregisterForEvent("AutoMessageInitialize", EVENT_ADD_ON_LOADED)

	AM.settings = ZO_SavedVars:NewAccountWide("AutoMessageSavedVars", 1, nil, AM.defaults)

  AM.MakeMenu()

end

em:RegisterForEvent("AutoMessageInitialize", EVENT_ADD_ON_LOADED, function(...) AM.Initialize(...) end)




function AM.process()
	if not AM.settings.list then return end
	
	local list = {}
	local recipient = {}
	local IDlist = AM.settings.list
	
	--TextBox
	IDlist = string.gsub(IDlist, "\n", "")
	IDlist = string.gsub(IDlist, ",", "")
	IDlist = string.gsub(IDlist, " ", "")
	IDlist = string.gsub(IDlist, "/", "")
	
	while true do
    local start = string.find(IDlist, "@")
    if not start then break end
    local stop = string.find(IDlist, "@", 2) or 0
    local userID = string.sub(IDlist, start, stop-1)
    if string.len(userID)>1 then
      list[#list+1] = {}
    	list[#list][1] = userID
    	list[#list][2] = 0
    end
    IDlist = string.gsub(IDlist, userID, "")
  end
  
  
  --Guilds
  for i=1, GetNumGuilds() do
  	
  	if AM.settings.guild[i] then
  		local guild = i
      local guildID = GetGuildId(guild)
      local UID = GetDisplayName()
      
      
      for i=1, GetNumGuildMembers(guildID) do
      	local userID, note, rank = GetGuildMemberInfo(guildID, i)
      	
      	if userID ~= UID and not AM.tableFind(list, userID) and AM.settings.rank[guild][rank] and not (AM.settings.note and string.len(note)>0) then
          list[#list+1] = {}
        	list[#list][1] = userID
        	list[#list][2] = guildID
      	end
      end
    end
  end
  
	AM.sendMails(list)
end



function AM.sendMails(recipients)
	em:UnregisterForUpdate("AMprocessing")
	AM.currentRecipient = ""
	em:RegisterForEvent("AutoMessageFailed", EVENT_MAIL_SEND_FAILED, AM.sendFailed)
	
	CHAT_SYSTEM:Maximize()
	
	if string.len(AM.settings.mail1)<1 or string.len(AM.settings.mail2)<1 then d("|c6C00FFAuto Message - |cFFFFFFCheck your settings!") return end
	
	local i = 1
	
	if #recipients < 1 then d("|c6C00FFAuto Message - |cFFFFFFNothing to do...") return
	 elseif #recipients == 1 then d("|c6C00FFAuto Message - |cFFFFFFSending " .. #recipients .. " mail...")
	 elseif #recipients > 1 then d("|c6C00FFAuto Message - |cFFFFFFSending " .. #recipients .. " mails...")
	end
  
	em:RegisterForUpdate("AMprocessing", 1600, function()
		
		local userID = recipients[i][1]
		local guildID = recipients[i][2]
		local guildname = GetGuildName(guildID)
  	local subject = string.gsub(AM.settings.mail1, "#GUILD", guildname)
    local text = string.gsub(AM.settings.mail2, "#GUILD", guildname)
    AM.currentRecipient = userID
		
    if AM.settings.chatMessages then d("|c6C00FFAuto Message - |cFFFFFFSending mail to " .. userID) end
   	
   	RequestOpenMailbox()
   	QueueMoneyAttachment(0)
    SendMail(userID, subject, text)
    CloseMailbox()
        
    i = i+1
	   
  	if not recipients[i] then
  		zo_callLater(function()
  			em:UnregisterForUpdate("AMprocessing")
  			em:UnregisterForUpdate("AutoMessageFailed")
  			AM.currentRecipient = ""
  	    d("|c6C00FFAuto Message - |cFFFFFFDONE!")
  	    AM.report()
	    end, 500)
		end
	end)
end