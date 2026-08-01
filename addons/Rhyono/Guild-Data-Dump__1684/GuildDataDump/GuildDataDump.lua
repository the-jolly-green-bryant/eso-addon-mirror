GDD = {
Name = "GuildDataDump",
Author = "Rhyono",
Version = 1.23,
SettingsVersion = 1.04}

GDD.Default = {['GuildBanks']={}}

--Handles guild member dumps
local function GuildMemberDump(text)
	GDD.SavedVars.GuildMembers = {}
	for inc=1,GetNumGuilds() do
		local guild = GetGuildId(inc)
		local guild_name = GetGuildName(guild)
		GDD.SavedVars.GuildMembers[guild_name] = {}
		for member=1,GetNumGuildMembers(guild) do
			local pname,note,rank,status,logoff = GetGuildMemberInfo(guild,member)
			if text == 'name' then
				GDD.SavedVars.GuildMembers[guild_name][member] = pname
			else
				GDD.SavedVars.GuildMembers[guild_name][member] = {["Name"]=pname,["Note"]=note,["Rank"]=rank,["Status"]=status,["Logoff"]=logoff}	
			end
		end
			for nomember=GetNumGuildMembers(guild)+1,500 do
				if text == 'name' then
					GDD.SavedVars.GuildMembers[guild_name][nomember] = nil
				else	
					GDD.SavedVars.GuildMembers[guild_name][nomember] = nil
				end	
			end
	end
	CHAT_SYSTEM:AddMessage("[Guild Data Dump] Guild Members dumped to saved variables.")
end

local function GuildMemberShow()
	if Zgoo then
		Zgoo.CommandHandler(GDD.SavedVars.GuildMembers)
	else
		CHAT_SYSTEM:AddMessage("[Guild Data Dump] Zgoo required to view data in game.")
	end	
end

--Handles guild bank dumps
local function GuildBankDump(text)
	text = text:lower()
	--Ensure bank is open
	local guild = GetSelectedGuildBankId()
	if guild ~= nil then
		local guild_name = GetGuildName(guild)
		GDD.SavedVars.GuildBanks[guild_name] = {}
		local bank_index = 1
		for index, data in pairs(SHARED_INVENTORY.bagCache[BAG_GUILDBANK]) do 
			if data ~= nil then
				if text == '' or text == 'link' then
					GDD.SavedVars.GuildBanks[guild_name][bank_index] = GetItemLink(BAG_GUILDBANK,index)			
				elseif text == 'name' then
					GDD.SavedVars.GuildBanks[guild_name][bank_index] = data.name
				elseif text == 'all' then
					GDD.SavedVars.GuildBanks[guild_name][bank_index] = data					
				else
					GDD.SavedVars.GuildBanks[guild_name][bank_index] = {}
					if text:find('name') then
						GDD.SavedVars.GuildBanks[guild_name][bank_index]["Name"] = data.name
					end
					if text:find('link') or not text:find('name') then
						GDD.SavedVars.GuildBanks[guild_name][bank_index]["Link"] = GetItemLink(BAG_GUILDBANK,index)	
					end
					if text:find('qty') then
						GDD.SavedVars.GuildBanks[guild_name][bank_index]["Qty"] = data.stackCount	
					end
				end	
				bank_index = bank_index+1
			end
		end
		CHAT_SYSTEM:AddMessage("[Guild Data Dump] Guild Bank contents for " .. guild_name .. " dumped to saved variables.")
	else
		CHAT_SYSTEM:AddMessage("[Guild Data Dump] Guild Bank must be open during dump.")
	end	
end

local function GuildBankShow()
	if Zgoo then
		Zgoo.CommandHandler(GDD.SavedVars.GuildBanks)
	else
		CHAT_SYSTEM:AddMessage("[Guild Data Dump] Zgoo required to view data in game.")
	end		
end

local function OnAddOnLoaded(event, addonName)
	if addonName == GDD.Name then
		GDD.SavedVars = ZO_SavedVars:NewAccountWide("GuildDataDumpVars", GDD.SettingsVersion, nil, GDD.Default)
		EVENT_MANAGER:UnregisterForEvent(GDD.Name, EVENT_ADD_ON_LOADED)
	end
end

SLASH_COMMANDS["/guildmemberdump"] = GuildMemberDump
SLASH_COMMANDS["/guildmembershow"] = GuildMemberShow
SLASH_COMMANDS["/guildbankdump"] = GuildBankDump
SLASH_COMMANDS["/guildbankshow"] = GuildBankShow

EVENT_MANAGER:RegisterForEvent(GDD.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)