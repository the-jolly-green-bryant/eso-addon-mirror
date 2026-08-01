RaffleUnlimited = {
	db = nil,
	name = "RaffleUnlimited",
	addonName = "Raffle Unlimited",
	displayName = "|cFFFFFFRaffle |c2497bdUnlimited|r",
	lastDeposit = nil,
	defaults = {
		building = false,
		entryPrice = "500",
		guild = "-",
		guildRank = "-",
		startAmt = "",
		dateStart = "-",
		dateEnd = "-",
		timeStart = "-",
		timeEnd = "-",
		restriction = "One"
	}
}

function RaffleUnlimited:Menu()
	local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

	local panelData = {
		type = "panel",
		name = self.addonName,
		displayName = self.displayName,
		author = "depeshmood",
		version = "18.23.0",
		slashCommand = "/raffleunlimited",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	LAM2:RegisterAddonPanel(self.name .. "LAM2Options", panelData)
	self.db = ZO_SavedVars:NewAccountWide("RaffleUnlimited_SavedVars", 1, nil, self.defaults)
	local optionsTable = {
		{
			type = "header",
			name = "Raffle Settings",
			width = "full",
		},
		{
			type = "description",
			text = self.displayName .. " will display any error messages and the results of the raffle drawing in the chat window."
		},
		{
			type = "dropdown",
			name = "Guild",
			tooltip = "This is the guild that you would like to use for the raffle.",
			choices = self:GetGuilds(),
			default = "-",
			getFunc = function() return self.db.guild end,
			setFunc = function(choice) self.db.guild = choice end
		},
		{
			type = "dropdown",
			name = "Exclude Guild Rank(s)     #",
			tooltip = "The guild rank(s) to exclude, in the order they appear in the guild pane, and above.\n1 = Guild Master",
			choices = {"-", 1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
			default = "-",
			getFunc = function() return self.db.guildRank end,
			setFunc = function(choice) self.db.guildRank = choice end
		},
		{
			type = "editbox",
			name = "Entry Price     $",
			tooltip = "The amount for each entry into the raffle.",
			width = "full",
			default = self.defaults.entryPrice,
			getFunc = function() return self.db.entryPrice end,
			setFunc = function(choice) self.db.entryPrice = choice end,
		},
		{
			type = "editbox",
			name = "Starting Amount     $",
			tooltip = "This is the base amount being offered, without any raffle tickets even being purchased.",
			width = "full",
			default = self.defaults.startAmt,
			getFunc = function() return self.db.startAmt end,
			setFunc = function(choice) self.db.startAmt = choice end
		},
		{
			type = "dropdown",
			name = "Starting Date",
			tooltip = "This is the date that entries started being deposited for the raffle.",
			width = "full",
			choices = self:CreateDates(),
			default = self.defaults.dateStart,
			getFunc = function() return self.db.dateStart end,
			setFunc = function(choice) self.db.dateStart = choice end
		},
		{
			type = "dropdown",
			name = "Starting Time",
			tooltip = "This is the time that entries started being deposited.",
			width = "full",
			choices = self:CreateTimes(),
			default = self.defaults.timeStart,
			getFunc = function() return self.db.timeStart end,
			setFunc = function(choice) self.db.timeStart = choice end
		},
		{
			type = "dropdown",
			name = "Ending Date",
			tooltip = "This is the date that the entries finished being deposited for the raffle.",
			width = "full",
			choices = self:CreateDates(),
			default = self.defaults.dateEnd,
			getFunc = function() return self.db.dateEnd end,
			setFunc = function(choice) self.db.dateEnd = choice end
		},
		{
			type = "dropdown",
			name = "Ending Time",
			tooltip = "Any deposits made after this time, on the Ending Date, will be excluded from this raffle.",
			width = "full",
			choices = self:CreateTimes(),
			default = self.defaults.timeEnd,
			getFunc = function() return self.db.timeEnd end,
			setFunc = function(choice) self.db.timeEnd = choice end
		},
		{
			type = "dropdown",
			name = "Prizes Per Username",
			tooltip = "The number of allowed prizes per username.\nOne: Can only win one prize\nMultiple: First ticket # drawn",
			width = "full",
			choices = {"One", "Multiple"},
			default = self.defaults.restriction,
			getFunc = function() return self.db.restriction end,
			setFunc = function(choice) self.db.restriction = choice end
		},
		{
			type = "button",
			name = "Draw Raffle",
			tooltip = "This will select winners based on the deposits made into the guild bank.",
			width = "half",
			func = function() self:DrawRaffle() end
		},
		{
			type = "button",
			name = "Raffle Results",
			tooltip = "This will display the winners from the last time \"Guild Raffle\" was run.",
			width = "half",
			func = function() self:RaffleResults() end
		},
		{
			type = "description",
			text = "Please note: If the guild is large enough and has enough transactions via the guild bank, it might take a few seconds, or so, to build the database.\nThere will be a message in the chat window letting you know that it has finished.\n\nThe guild bank's history is limited to 10 days, including today, and is only able to obtain information 9 days into the past. You will need to run this within that timeframe in order to retrieve any results.\n\nThe SavedVariables\\RaffleUnlimited.lua file contains any of the entered information above and will also populate the guild entrants, which will need to be parsed if you would like to view and/or display them anywhere.\n\nTo open this menu, type: /raffleunlimited\nTo access the slash commands, type: /raffleu <COMMAND>\n(For example: /raffleu help)"
		}
	}
	LAM2:RegisterOptionControls(self.name .. "LAM2Options", optionsTable)
end

function RaffleUnlimited:GetGuilds(gName)
	guilds = {}
	guilds[1] = "-"
	if GetNumGuilds() > 0 then
		for guild = 1, GetNumGuilds() do
			local guildId = GetGuildId(guild)
			local guildName = GetGuildName(guildId)
			if(not guildName or (guildName):len() < 1) then
				guildName = "Guild " .. guildId
			end
			if gName ~= nil and gName == guildName then
				return guildId
			end
			guilds[guildId + 1] = guildName
		end
	end
	return guilds
end

function RaffleUnlimited:DrawRaffle(p)
	if p == nil then
		self.db.entries = {
			eAmt = nil,
			entries = nil,
			drawDate = nil
		}
	end
	m = nil
	stAmt = tonumber(self.db.startAmt)
	if self.db.guild == nil or self.db.guild == "-" then
		m = "Guild"
	elseif self.db.entryPrice == nil or tonumber(self.db.entryPrice) == nil then
		if self.db.entryPrice == nil then
			m = "Entry Price"
		else
			m = "Valid Entry Price"
		end
	elseif self.db.startAmt ~= "" and stAmt == nil then
		m = "Valid Starting Amount"
	elseif self.db.dateStart == nil or self.db.dateStart == "-" then
		m = "Starting Date"
	elseif self.db.dateEnd == nil or self.db.dateEnd == "-" then
		m = "Ending Date"
	elseif self.db.timeStart == nil or self.db.timeStart == "-" then
		m = "Starting Time"
	elseif self.db.timeEnd == nil or self.db.timeEnd == "-" then
		m = "Ending Time"
	elseif RaffleUnlimited.db.items == nil or RaffleUnlimited.db.items[1] == nil then
		m = "Raffle Prizes"
	end
	if m ~= nil then
		CHAT_SYSTEM:AddMessage(self.displayName .. " -- \n|cFF0000Required: " .. m .. "\r")
		return false
	end
	sT = self:StartDate(self.db.dateStart, self.db.timeStart)
	if sT == nil then
		CHAT_SYSTEM:AddMessage(self.displayName .. " -- \n|cFF0000ERROR: Starting Date is out of range!\r")
		return
	end
	eT = self:StartDate(self.db.dateEnd, self.db.timeEnd)
	if eT == nil then
		CHAT_SYSTEM:AddMessage(self.displayName .. " -- \n|cFF0000ERROR: Ending Date is out of range!\r")
		return
	end
	if sT >= eT then
		CHAT_SYSTEM:AddMessage(self.displayName .. " -- \n|cFF0000REQUIRED: Valid starting and ending date/time.\r\n(Ending Date/Time cannot be the same or less than Starting Date/Time)")
		return
	end
	cT = GetTimeStamp()
	guildId = self:GetGuilds(self.db.guild)
	numEvents = self:BuildHistory(guildId, sT, cT, nil, eT)
	
	if numEvents == nil or numEvents == 0 then
		m = "No raffle entries were found!\r\nIf you feel this is in error, p"
		if self.lastDeposit ~= nil and numEvents == nil then
			m = "New transactions found for " .. self.db.guild .. ".\r\nP"
		elseif numEvents == nil then
			m = "Collecting raffle entries for " .. self.db.guild .. ".\r\nP"
		end
		CHAT_SYSTEM:AddMessage(self.displayName .. " -- \n|cFF0000ERROR: " .. m .. "lease wait a few seconds to build the database and try again.")
		return false
	end
	
	nums = {
		entries = 0,
		entAmt = tonumber(self.db.entryPrice),
		totAmt = 0
	}
	n = 1
	nn = 1
	depositInfo = {}
	entries = {}
	usernames = {}
	userRanks = {}
	self.db.entries.entrants = {}
	for tIndex=numEvents, 1, -1 do
		eventType, secondsSinceDeposit, depositerName, amount, _, _, _, _ = GetGuildEventInfo(guildId, GUILD_HISTORY_BANK, tIndex)
		tS = cT - secondsSinceDeposit
		tP = amount / nums.entAmt
		if eventType == GUILD_EVENT_BANKGOLD_ADDED and (zo_round(tP) * nums.entAmt) == amount and tS >= sT and tS <= eT then
			tP = self:TicketCount(tP, amount)
			depositInfo[n] = { tS, tIndex, tP, depositerName, amount }
			userRanks[depositerName] = depositerName
			n = n + 1
		end
	end
	if RaffleUnlimited.db.tickets ~= nil then
		for k,v in pairs(RaffleUnlimited.db.tickets) do
			if k ~= "count" then
				depositInfo[n] = { v.timestamp, 0, v.quantity, v.username, 0 }
				userRanks[v.username] = v.username
				n = n + 1
			end
		end
	end
	table.sort(depositInfo, function(a, b) return a[1] < b[1] end)
	if self.db.guildRank ~= nil and self.db.guildRank ~= "-" then
		userRanks = self:CheckGuildRank(guildId, self.db.guildRank, userRanks)
	end
	n = 1
	oC = 0
	for k,v in ipairs(depositInfo) do
		nums.totAmt = nums.totAmt + v[5]
		if self.db.guildRank == nil or self.db.guildRank == "-" or userRanks[v[4]] == false then
			nums.entries = nums.entries + 1
			tP = v[3]
			tckNums = n
			if tP > 1 then
				tckNums = tckNums .. "-" .. (n + tP - 1)
			end
			self.db.entries.entrants[nn] = {
				entryNum = nn,
				userName = v[4],
				tickets = tP,
				depositAmount = v[5],
				ticketNums = tckNums,
				timestamp = v[1]
			}
			nn = nn + 1
			for i=1, tP, 1 do
				entries[n] = { name = v[4] }
				n = n + 1
			end
			usernames[v[4]] = v[4]
		else
			oC = oC + v[5]
		end
	end
	if oC > 0 then
		self.db.entries.oContrib = oC
	end
	usercount = nil
	if p == nil and self.db.restriction == "One" then
		usercount = 0
		for _ in pairs(usernames) do usercount = usercount + 1 end
		if usercount > 0 then CHAT_SYSTEM:AddMessage(self.displayName .. " -- Unique # of usernames: " .. usercount) end
	end
	n = n-1
	if eT > cT then
		if stAmt ~= nil then
			nums.totAmt = nums.totAmt + stAmt
		end
		CHAT_SYSTEM:AddMessage(self.displayName .. " -- \nGuild: " .. self.db.guild .. " -- \nCurrent Entries: " .. nums.entries .. " -- \nCurrent Tickets: " .. n .. " -- \nCurrent Amount: $" .. nums.totAmt .. " -- \nTime Remaining: " .. self:RemainingTime(eT - cT) .. "\r")
		return
	end
	eAmt = nums.entries
	if eAmt == 0 then
		CHAT_SYSTEM:AddMessage(self.displayName .. " -- \n|cFF0000ERROR: No entries were found.\r")
		return false
	end
	if n > nums.entries then
		eAmt = n
	end
	if nums.totAmt ~= nil then
		tAmt = nums.totAmt
	else
		tAmt = nums.entAmt * nums.entries
	end
	if stAmt ~= nil then
		tAmt = tAmt + stAmt
	end
	
	if p == nil or self.db.entries.prizes == nil or self.db.entries.prizes[p] == nil then
		self.db.entries.eAmt = eAmt
		self.db.entries.entries = nums.entries
		self.db.entries.tAmt = tAmt
		self.db.entries.drawDate = GetDateStringFromTimestamp(eT)
	end

	temp = {}
	n = 0
	for k,v in pairs(RaffleUnlimited.db.items) do
		if k ~= "arrCount" and tAmt >= k then
			n = n + 1
			temp[n] = { k }
		end
	end
	if p ~= nil and self.db.entries.prizes ~= nil and self.db.entries.prizes[p] ~= nil then
		if self:DrawPrize(p, entries, 1, self.db.entries.prizes[p].ticketNum, self.db.entries.prizes[p].username) == false then
			CHAT_SYSTEM:AddMessage(self.displayName .. " -- \n|cFF0000ERROR: Unable to find a new winner.\r")
			return
		end
		v = self.db.entries.prizes[p]
		item = self.db.items[v.p][v.c]
		if item.itemCode == "gold" then
			item = RaffleUnlimited:ConvertNumber(item.qty) .. " gold"
		else
			item = item.itemCode .. " x" .. item.qty
		end
		CHAT_SYSTEM:AddMessage(self.displayName .. " -- \n" .. v.username .. ", ticket # " .. v.ticketNum .. ", won " .. item)  
		return
	elseif n > 0 then
		n = 1
		self.db.entries.prizes = {}
		table.sort(temp, function(a, b) return a[1] < b[1] end)
		for k,v in pairs(temp) do
			for key,val in pairs(RaffleUnlimited.db.items[v[1]]) do
				self.db.entries.prizes[n] = { p = v[1], c = key }
				n = n + 1
			end
		end
		n = n - 1
		if (usercount == nil and n > eAmt) or (usercount ~= nil and n > usercount) then
			if usercount == nil then
				n = eAmt
			else
				if p ~= nil then
					CHAT_SYSTEM:AddMessage(self.displayName .. " -- \n|cFF0000ERROR: Not enough entries to draw again.\r")
					return
				end
				n = usercount
			end
		end
		for i=1, n, 1 do
			if self:DrawPrize(i, entries, 1) == false then
				CHAT_SYSTEM:AddMessage(self.displayName .. " -- \n|cFF0000ERROR: Entries Problem Found.\r")
				return
			end
		end
		self:RaffleResults()
	else
		CHAT_SYSTEM:AddMessage(self.displayName .. " -- \n|cFF0000ERROR: No raffle prizes were found.\r")
	end
end

function RaffleUnlimited:RaffleResults()
	if self.db.entries == nil or self.db.entries.prizes == nil or self.db.entries.prizes[1] == nil then
		return false
	end

	eAmt = self.db.entries.eAmt
	entries = self.db.entries.entries
	tAmt = self.db.entries.tAmt
	gAmt = tAmt

	sysMes = " -- \nTotal Raffle Tickets: " .. eAmt
	if eAmt ~= entries then
		sysMes = sysMes .. " (Total Entries: " .. entries .. ")"
	end
	CHAT_SYSTEM:AddMessage(self.displayName .. sysMes .. ", Total Amount: $" .. tAmt .. ", Drawing: " .. self.db.entries.drawDate)
	
	for k,v in pairs(self.db.entries.prizes) do
		if v.username ~= nil and v.username ~= "" then
			item = self.db.items[v.p][v.c]
			if item.itemCode == "gold" or string.find(item.itemCode, "Free Raffle Ticket") then
				if item.itemCode == "gold" then gAmt = gAmt - item.qty end
				item = RaffleUnlimited:ConvertNumber(item.qty) .. " " .. item.itemCode
			else
				item = item.itemCode .. " x" .. item.qty
			end
			CHAT_SYSTEM:AddMessage(v.username .. ", ticket # " .. v.ticketNum .. ", won " .. item .. " (" .. k .. ")")
		end
	end
	
	CHAT_SYSTEM:AddMessage(self.displayName .. " -- Guild Earned: $".. gAmt)
	return true
end

function RaffleUnlimited:CreateDates(dT)
	sD = GetTimeStamp() - (86400 * 10)
	rD = {}
	rD[1] = "-"
	n = 2
	for i=1, 21, 1 do
		t = sD + (86400 * i)
		if dT == GetDateStringFromTimestamp(t) then
			return t
		else
			rD[n] = GetDateStringFromTimestamp(t)
			n = n+1
		end
	end
	if dT ~= nil then
		return nil
	end
	return rD
end

function RaffleUnlimited:CreateTimes()
	rT = {}
	rT[1] = "-"
	for i=0, 23, 1 do
		rT[i+2] = i .. ":00"
	end
	return rT
end

function RaffleUnlimited:StartDate(sD, sT)
	sD = self:CreateDates(sD)
	if sD == nil then return nil end
	cT = {}
	cT.time = GetTimeString(sD)
	cT.hour, cT.min, cT.sec = cT.time:match("([^%:]+):([^%:]+):([^%:]+)")
	cT.sel, cT.sMin = sT:match("([^%:]+):([^%:]+)")
	sD = sD - (cT.min * 60) - cT.sec + ((tonumber(cT.sel) - tonumber(cT.hour)) * 60 * 60)
	return sD
end

function RaffleUnlimited:TicketCount(tickets, amount)
	if RaffleUnlimited.db.bonusTickets == nil or amount <= 0 then return tickets end
	for k,v in pairs(RaffleUnlimited.db.bonusTickets["amount"]) do
		if amount >= v[1] then
			tickets = tickets + v[2]
			amount = amount - v[1]
			if RaffleUnlimited.db.bonusTickets.multi == false then return (tickets) end
			return RaffleUnlimited:TicketCount(tickets, amount)
		end
	end
	return tickets
end

function RaffleUnlimited:BuildHistory(gID, sT, cT, tot, eT)
	if self.defaults.building == true and tot == nil then return nil end
	nE = GetNumGuildEvents(gID, GUILD_HISTORY_BANK)
	if tot == nil and (nE == 0 or eT > cT) then
		self.defaults.building = true
		RequestGuildHistoryCategoryNewest(gID, GUILD_HISTORY_BANK)
		if nE == 0 then
			zo_callLater(function()
				RaffleUnlimited:BuildHistory(gID, sT, cT, 0)
			end, 1500)
			return nil
		elseif GetNumGuildEvents(gID, GUILD_HISTORY_BANK) > nE then
			zo_callLater(function()
				RaffleUnlimited:GetRecentHistory(gID, cT)
			end, 1500)
			return nil
		end
	end
	_, secondsSinceDeposit, _, _, _, _, _, _ = GetGuildEventInfo(gID, GUILD_HISTORY_BANK, nE)
	if DoesGuildHistoryCategoryHaveMoreEvents(gID, GUILD_HISTORY_BANK) == true and (cT - secondsSinceDeposit) > sT then
		self.defaults.building = true
		time = 1500
		if nE > 1 then
			time = time + math.random(1, nE)
		end
		RequestGuildHistoryCategoryOlder(gID, GUILD_HISTORY_BANK)
		zo_callLater(function()
			RaffleUnlimited:BuildHistory(gID, sT, cT, nE)
		end, time)
		return nil
	end
	self.defaults.building = false
	self.lastDeposit = secondsSinceDeposit
	if tot ~= nil then
		CHAT_SYSTEM:AddMessage(self.displayName .. " is now ready.")
	end
	return nE
end

function RaffleUnlimited:GetRecentHistory(gID, cT)
	nE = GetNumGuildEvents(gID, GUILD_HISTORY_BANK)
	_, secondsSinceDeposit, _, _, _, _, _, _ = GetGuildEventInfo(gID, GUILD_HISTORY_BANK, nE)
	if DoesGuildHistoryCategoryHaveMoreEvents(gID, GUILD_HISTORY_BANK) == true and (cT - secondsSinceDeposit) >= self.lastDeposit then
		self.defaults.building = true
		time = 1500
		if nE > 1 then
			time = time + math.random(1, nE)
		end
		RequestGuildHistoryCategoryOlder(gID, GUILD_HISTORY_BANK)
		zo_callLater(function()
			RaffleUnlimited:GetRecentHistory(gID, cT)
		end, time)
		return nil
	end
	self.defaults.building = false
	CHAT_SYSTEM:AddMessage(self.displayName .. " is now ready.")
end

function RaffleUnlimited:CheckGuildRank(gID, rank, users)
	memberCount = GetNumGuildMembers(gID)
    if memberCount ~= 0 then
		for mIndex=1, memberCount, 1 do
			cName, _, cRank, _, _ = GetGuildMemberInfo(gID, mIndex)
            if cName ~= nil and users[cName] ~= nil then
                if cRank <= rank then
					users[cName] = true
				else
					users[cName] = false
				end
            end
		end
	end
	return users
end

function RaffleUnlimited:RemainingTime(t)
	days = 0
	hours = 0
	mins = 0
	while t > 86400 do
		days = days + 1
		t = t - 86400
	end
	while t > 3600 do
		hours = hours + 1
		t = t - 3600
	end
	while t > 60 do
		mins = mins + 1
		t = t - 60
	end
	return days .. "d " .. hours .. "h " .. mins .. "m"
end

function RaffleUnlimited:ConvertNumber(amt, c)
	if c ~= nil and tonumber(amt) ~= nil then
		return amt
	end
	if tonumber(amt) ~= nil then
		amt = tonumber(amt)
		if amt >= 1000000 then
			amt = amt / 1000000
			return amt .. "M"
		elseif amt >= 1000 then
			amt = amt / 1000
			return amt .. "k"
		end
	else
		if string.find(string.lower(amt), "m") then
			amt = tonumber(string.sub(amt, 0, string.find(string.lower(amt), "m") - 1))
			if amt == nil then
				return false
			end
			return amt * 1000000
		elseif string.find(string.lower(amt), "k") then
			amt = tonumber(string.sub(amt, 0, string.find(string.lower(amt), "k") - 1))
			if amt == nil then
				return false
			end
			return amt * 1000
		end
	end
	return amt
end

function RaffleUnlimited:ListItems(n)
	dN = RaffleUnlimited:ConvertNumber(n)
	if dN == 1 then dN = 0 end
	CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- Items unlocked at " .. dN)
	for k,v in ipairs(RaffleUnlimited.db.items[n]) do
		if v.itemCode == "gold" or string.find(v.itemCode, "Free Raffle Ticket") then
			CHAT_SYSTEM:AddMessage(RaffleUnlimited:ConvertNumber(v.qty) .. " " .. v.itemCode .. " (" .. dN .. " " .. k .. ")")
		else
			CHAT_SYSTEM:AddMessage(v.itemCode .. " x" .. v.qty .. " (" .. dN .. " " .. k .. ")")
		end
	end
end

function RaffleUnlimited:DrawPrize(p, entries, count, tNum, user)
	if count > 20 then return false end
	t = math.random(1, self.db.entries.eAmt)
	if tNum ~= nil and user ~= nil and (tNum == t or (self.db.restriction == 'One' and entries[t].name == user)) then
		return self:DrawPrize(p, entries, count + 1, tNum, user)
	end
	for k,v in pairs(self.db.entries.prizes) do
		if (v.ticketNum ~= nil and t == v.ticketNum) or (self.db.restriction == 'One' and entries[t].name == v.username) then
			return self:DrawPrize(p, entries, count + 1)
		end
	end
	self.db.entries.prizes[p].username = entries[t].name
	self.db.entries.prizes[p].ticketNum = t
	return true
end

function RaffleUnlimited.Cmd(txt)
	if txt == "" then
		CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. ': type "/raffleu help" for a list of commands.')
		return
	end
	arr = {}
	i = 1
	for val in string.gmatch(txt,"%S+") do
		arr[i] = val
	    i = i + 1
	end
	if txt == "help" or arr[1] == "help" or arr[2] == "help" then
		if arr[2] == "help" then
			arr[2] = arr[1]
		end
		CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " commands:")
		if arr[2] == "set" then
			CHAT_SYSTEM:AddMessage('/raffleu set guild <GUILD_NAME> - Sets the "Guild" for the raffle (case sensitive)')
			CHAT_SYSTEM:AddMessage('/raffleu set rank <GUILD_RANK_NUMBER> - Sets the "Exclude Guild Rank(s)" for the raffle (numeric value)')
			CHAT_SYSTEM:AddMessage('/raffleu set entry price <AMOUNT> - Sets the "Entry Price"')
			CHAT_SYSTEM:AddMessage('/raffleu set start amount <AMOUNT> - Sets the "Starting Amount $" for the raffle')
			CHAT_SYSTEM:AddMessage('/raffleu set start date <M/D/YYYY> - Sets the "Starting Date" for the raffle')
			CHAT_SYSTEM:AddMessage('/raffleu set start time <H:MM> - Sets the "Starting Time" for the raffle (military format)')
			CHAT_SYSTEM:AddMessage('/raffleu set end date <M/D/YYYY> - Sets the "Ending Date" for the raffle')
			CHAT_SYSTEM:AddMessage('/raffleu set end time <H:MM> - Sets the "Ending Time" for the raffle (military format)')
			CHAT_SYSTEM:AddMessage('/raffleu set allow <One OR Multiple> - Sets the number of prizes a username can win per raffle')
			CHAT_SYSTEM:AddMessage('/raffleu set gold <UNLOCK_AMOUNT> <AMOUNT> - Adds the amount of gold as a raffle prize')
			CHAT_SYSTEM:AddMessage('/raffleu set item <UNLOCK_AMOUNT> <QUANTITY> <LINK_ITEM_IN_CHAT> - Adds the item to the list of prizes to draw from')
			CHAT_SYSTEM:AddMessage('/raffleu set item <UNLOCK_AMOUNT> <QUANTITY> tickets - Adds raffle tickets as an available prize, for the next raffle')
			CHAT_SYSTEM:AddMessage('/raffleu set bonus <AMOUNT> <QUANTITY> - Gives QUANTITY of free tickets when AMOUNT of tickets purchased, per deposit, not username')
			CHAT_SYSTEM:AddMessage('/raffleu set bonus multi <YES or NO> - Sets whether a deposit can receive multiple bonuses, default is "YES"')
			CHAT_SYSTEM:AddMessage('/raffleu set tickets <QUANTITY> <USERNAME> - Gives username (case sensitive) free tickets')
		elseif arr[2] == "draw" then
			CHAT_SYSTEM:AddMessage("/raffleu draw - This will draw the raffle\n(In-progress displays information; Ended displays winners)")
			CHAT_SYSTEM:AddMessage('/raffleu results - Results from the last raffle drawing\n(A new draw will overwrite this information)')
			CHAT_SYSTEM:AddMessage('/raffleu entry <ENTRY_NUMBER> - Displays username, number of tickets, ticket numbers and amount deposited')
			CHAT_SYSTEM:AddMessage('/raffleu entry <USERNAME> - Displays all entries for the username')
			CHAT_SYSTEM:AddMessage('/raffleu draw <DRAW_NUMBER> - This will draw only the "(DRAW_NUMBER)" from the draw results')
		elseif arr[2] == "list" then
			CHAT_SYSTEM:AddMessage('/raffleu list settings - Displays all of the basic raffle settings')
			CHAT_SYSTEM:AddMessage('/raffleu list guild - Displays the selected "Guild" for the raffle')
			CHAT_SYSTEM:AddMessage('/raffleu list rank - Displays the selected "Exclude Guild Rank(s)" for the raffle')
			CHAT_SYSTEM:AddMessage('/raffleu list entry price - Displays the "Entry Price" amount')
			CHAT_SYSTEM:AddMessage('/raffleu list start date - Displays the "Starting Date" for the raffle')
			CHAT_SYSTEM:AddMessage('/raffleu list start time - Displays the "Starting Time" for the raffle')
			CHAT_SYSTEM:AddMessage('/raffleu list end date - Displays the "Ending Date" for the raffle')
			CHAT_SYSTEM:AddMessage('/raffleu list end time - Displays the "Ending Time" for the raffle')
			CHAT_SYSTEM:AddMessage('/raffleu list allow - Displays the "Prizes Per Username" for the raffle')
			CHAT_SYSTEM:AddMessage('/raffleu list prize all - Displays all of the entered items for the raffle')
			CHAT_SYSTEM:AddMessage('/raffleu list prize <UNLOCK_AMOUNT> - Displays entered items at the designated unlock amount for the raffle')
			CHAT_SYSTEM:AddMessage('/raffleu list prize <UNLOCK_AMOUNT> <RAFFLE_ITEM_NUMBER> - Displays the designated item for the raffle')
			CHAT_SYSTEM:AddMessage('/raffleu list bonus - Displays all ticket purchase amounts and the number of free tickets for that amount')
			CHAT_SYSTEM:AddMessage('/raffleu list tickets - Displays all usernames that have free raffle tickets')
		elseif arr[2] == "reset" or arr[2] == "remove" then
			CHAT_SYSTEM:AddMessage('/raffleu reset all - Resets ALL of the stored information')
			CHAT_SYSTEM:AddMessage('/raffleu reset defaults - Resets only the default UI information')
			CHAT_SYSTEM:AddMessage('/raffleu reset other - Resets the all of the non-default information')
			CHAT_SYSTEM:AddMessage('/raffleu reset items all - Resets all of the items that have been added')
			CHAT_SYSTEM:AddMessage('/raffleu reset items <UNLOCK_AMOUNT> - Resets all items that are unlocked at the designated amount')
			CHAT_SYSTEM:AddMessage('/raffleu reset bonus - Resets all bonus ticket amounts')
			CHAT_SYSTEM:AddMessage('/raffleu reset tickets - Resets all free tickets issued to users')
			CHAT_SYSTEM:AddMessage('/raffleu remove <UNLOCK_AMOUNT> <RAFFLE_ITEM_NUMBER> - Removes the specified item')
			CHAT_SYSTEM:AddMessage('/raffleu remove bonus <AMOUNT> - Removes bonus tickets for the specified amount')
			CHAT_SYSTEM:AddMessage('/raffleu remove tickets <TICKET_ID> - Removes free tickets for this specific username')
		else
			CHAT_SYSTEM:AddMessage('/raffleunlimited - Displays the menu UI')
			CHAT_SYSTEM:AddMessage('/raffleu help - Displays the list of commands')
			CHAT_SYSTEM:AddMessage('/raffleu help set - Displays the command settings')
			CHAT_SYSTEM:AddMessage('/raffleu help list - Displays the commands for showing the current setting(s)')
			CHAT_SYSTEM:AddMessage('/raffleu help draw - Displays the commands for drawing the raffle')
			CHAT_SYSTEM:AddMessage('/raffleu help reset - Displays the commands for resetting the raffle')
		end
		return
	end
	if arr[1] == "reset" and arr[2] ~= nil then
		m = "|cFF0000ERROR: Reset command not found.\r\nFor the list of commands, type: /raffleu help reset"
		if arr[2] == "all" or string.find(arr[2], "default") then
			if arr[2] == "all" then
				RaffleUnlimited.db.entries = nil
				RaffleUnlimited.db.items = nil
				RaffleUnlimited.db.tickets = nil
				RaffleUnlimited.db.bonusTickets = nil
				m = "All default settings restored."
			else
				m = "Default settings restored, excluding items and/or winners."
			end
			m = m .. "\nIf you do not see the change(s) in the menu, type: /reloadui"
			RaffleUnlimited.db.entryPrice = RaffleUnlimited.defaults.entryPrice
			RaffleUnlimited.db.guild = RaffleUnlimited.defaults.guild
			RaffleUnlimited.db.guildRank = RaffleUnlimited.defaults.guildRank
			RaffleUnlimited.db.startAmt = RaffleUnlimited.defaults.startAmt
			RaffleUnlimited.db.dateStart = RaffleUnlimited.defaults.dateStart
			RaffleUnlimited.db.dateEnd = RaffleUnlimited.defaults.dateEnd
			RaffleUnlimited.db.timeStart = RaffleUnlimited.defaults.timeStart
			RaffleUnlimited.db.timeEnd = RaffleUnlimited.defaults.timeEnd
			RaffleUnlimited.db.restriction = RaffleUnlimited.defaults.restriction
		elseif string.find(arr[2], "item") then
			arr[3] = RaffleUnlimited:ConvertNumber(arr[3], true)
			if arr[3] == "all" then
				RaffleUnlimited.db.items = nil
				m = "All items have been removed."
			elseif tonumber(arr[3]) ~= nil then
				arr[3] = tonumber(arr[3])
				if arr[3] == 0 then arr[3] = 1 end
				if RaffleUnlimited.db.items == nil then
					m = "|cFF0000ERROR: No items were found.\r"
				elseif RaffleUnlimited.db.items[arr[3]] == nil then
					m = "|cFF0000ERROR: No items were found at that unlock amount.\r"
				else
					RaffleUnlimited.db.items[arr[3]] = nil
					RaffleUnlimited.db.items["arrCount"][arr[3]] = nil
					if arr[3] == 1 then arr[3] = 0 end
					m = "All items have been removed at the unlock amount of " .. RaffleUnlimited:ConvertNumber(arr[3]) .. "."
				end
			end
		elseif arr[2] == "other" then
			RaffleUnlimited.db.entries = nil
			RaffleUnlimited.db.items = nil
			RaffleUnlimited.db.tickets = nil
			m = "Non-default settings have been reset."
		elseif string.find(arr[2], "bon") then
			RaffleUnlimited.db.bonusTickets = nil
			m = "Bonus ticket amounts have been reset."
		elseif string.find(arr[2], "tick") then
			RaffleUnlimited.db.tickets = nil
			m = "Raffle tickets have been reset."
		end
		CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n" .. m)
		return
	end
	if arr[1] == "remove" then
		arr[3] = tonumber(RaffleUnlimited:ConvertNumber(arr[3], true))
		if string.find(arr[2], "bon") and RaffleUnlimited.db.bonusTickets ~= nil and RaffleUnlimited.db.bonusTickets["amount"][arr[3]] ~= nil then
			s = "s"
			if RaffleUnlimited.db.bonusTickets["amount"][arr[3]] == 1 then s = "" end
			m = "Successfully removed " .. RaffleUnlimited.db.bonusTickets["amount"][arr[3]][2] .. " bonus ticket" .. s .. " when " .. RaffleUnlimited:ConvertNumber(RaffleUnlimited.db.bonusTickets["amount"][arr[3]][1]) .. " deposited"
			if RaffleUnlimited.db.bonusTickets["arrCount"] == 1 then
				RaffleUnlimited.db.bonusTickets = nil
			else
				table.remove(RaffleUnlimited.db.bonusTickets["amount"], arr[3])
				RaffleUnlimited.db.bonusTickets["arrCount"] = RaffleUnlimited.db.bonusTickets["arrCount"] - 1
				table.sort(RaffleUnlimited.db.bonusTickets["amount"], function(a, b) return a[1] > b[1] end)
			end
		elseif string.find(arr[2], "tick") and RaffleUnlimited.db.tickets ~= nil and RaffleUnlimited.db.tickets[arr[3]] ~= nil then
			temp = {}
			n = 0
			for k,v in pairs(RaffleUnlimited.db.tickets) do
				if k ~= arr[3] and k ~= 'count' then
					n = n + 1
					temp[n] = v
				elseif k ~= 'count' then
					m = "Successfully removed " .. v.quantity .. " free ticket"
					if tonumber(v.quantity) > 1 then
						m = m .. "s"
					end
					m = m .. " from " .. v.username
				end
			end
			if n == 0 then
				temp = nil
			end
			RaffleUnlimited.db.tickets = temp
			if temp ~= nil then
				RaffleUnlimited.db.tickets['count'] = n
			end
		else
			arr[2] = tonumber(RaffleUnlimited:ConvertNumber(arr[2], true))
			if arr[2] == 0 then arr[2] = 1 end
			m = "|cFF0000ERROR: Please ensure that you are entering the proper numbers.\r"
			if arr[2] ~= nil and arr[3] ~= nil then
				if RaffleUnlimited.db.items[arr[2]] == nil then
					m = "|cFF0000ERROR: No items found at the unlock amount.\r"
				else
					m = ""
					n = 0
					tt = {}
					for k,v in ipairs(RaffleUnlimited.db.items[arr[2]]) do
						if k ~= arr[3] then
							n = n + 1
							tt[n] = v
						else
							m = ""
							if v.qty > 1 then
								if v.itemCode == "gold" then
									m = RaffleUnlimited:ConvertNumber(v.qty) .. " "
								else
									m = v.qty .. "x "
								end
							end
							m = m .. v.itemCode .. " was successfully removed."
						end
					end
					if m == "" then
						m = "|cFF0000ERROR: Specified item number was not found.\r"
					end
					if n == 0 then
						tt = nil
						n = nil
					end
					RaffleUnlimited.db.items[arr[2]] = tt
					RaffleUnlimited.db.items["arrCount"][arr[2]] = n
				end
			end
		end
		CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n" .. m)
		return
	end
	if arr[1] == "set" then
		if arr[2] == nil then arr[2] = "" end
		if string.find(arr[2], "ent") and arr[3] == "price" then
			arr[4] = tonumber(arr[4])
			if arr[4] == nil or arr[4] == 0 then arr[4] = RaffleUnlimited.defaults.entryPrice end
			RaffleUnlimited.db.entryPrice = arr[4]
			CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. ' set the "Entry Price" to $' .. RaffleUnlimited.db.entryPrice .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if arr[2] == "guild" then
			if arr[3] == nil or arr[3] == "-" then
				RaffleUnlimited.db.guild = "-"
				arr[4] = '-'
			else
				n = 4
				while n < i do
					arr[3] = arr[3] .. " " .. arr[n]
					n = n + 1
				end
				if tonumber(RaffleUnlimited:GetGuilds(arr[3])) == nil then
					CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: You are not in the guild you entered!\r\nThe guild's name is case sensitive.")
					return
				end
				RaffleUnlimited.db.guild = arr[3]
			end
			CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. ' set the "Guild" for the raffle to "' .. RaffleUnlimited.db.guild .. "\"\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "rank") then
			arr[3] = tonumber(arr[3])
			if arr[3] == nil or arr[3] < 1 or arr[3] > 10 then
				arr[3] = "-"
				RaffleUnlimited.db.guildRank = arr[3]
			else
				RaffleUnlimited.db.guildRank = arr[3]
				if arr[3] > 1 then arr[3] = "1-" .. arr[3] end
			end
			CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. ' set the "Exclude Guild Rank(s)" for the raffle to "' .. arr[3] .. "\"\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "start") and (arr[3] == "amount" or arr[3] == "amt") then
			arr[4] = tonumber(arr[4])
			if arr[4] == nil or arr[4] == 0 then
				RaffleUnlimited.db.startAmt = RaffleUnlimited.defaults.startAmt
				arr[4] = '<empty>'
			else
				RaffleUnlimited.db.startAmt = arr[4]
				arr[4] = '$' .. arr[4]
			end
			CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. ' set the "Starting Amount" for the raffle to ' .. arr[4] .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "start") and arr[3] == "date" then
			dArr = {}
			i = 1
			for val in string.gmatch(arr[4],"%w+") do
				dArr[i] = tonumber(val)
				i = i + 1
			end
			if dArr[1] == nil or dArr[2] == nil or dArr[3] == nil then
				RaffleUnlimited.db.dateStart = RaffleUnlimited.defaults.dateStart
			else
				arr[4] = dArr[1] .. '/' .. dArr[2] .. '/' .. dArr[3]
				if RaffleUnlimited:CreateDates(arr[4]) == nil then
					CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: Starting Date was not found!\r\nPlease make sure you are using the M/D/YYYY format.\nTo see the available date range, type: /raffleunlimited")
					return
				end
				RaffleUnlimited.db.dateStart = arr[4]
			end
			CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. ' set the "Starting Date" for the raffle to ' .. RaffleUnlimited.db.dateStart .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "start") and arr[3] == "time" then
			dArr = {}
			i = 1
			for val in string.gmatch(arr[4],"%w+") do
				dArr[i] = tonumber(val)
				i = i + 1
			end
			if dArr[1] == nil or dArr[2] == nil then
				RaffleUnlimited.db.timeStart = RaffleUnlimited.defaults.timeStart
			else
				if arr[5] ~= nil and arr[5] ~= "" then
					arr[6] = arr[5]
				end
				arr[4] = dArr[1]
				arr[5] = dArr[2]
				found = false
				if arr[6] ~= nil and string.lower(arr[6]) == "pm" then arr[4] = arr[4] + 12 end
				if arr[4] >= 24 then arr[4] = arr[4] - 24 end
				for i=0, 23, 1 do
					if i == arr[4] then
						found = true
						break
					end
				end
				if found == false then
					CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: Invalid Starting Time!\r\nThis must be in military time in the H:MM format.\nTo see the available times, type: /raffleunlimited")
					return
				end
				if arr[5] >= 30 and arr[4] < 23 then
					arr[4] = tonumber(arr[4]) + 1
				end
				RaffleUnlimited.db.timeStart = arr[4] .. ":00"
			end
			CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. ' set the "Starting Time" for the raffle to ' .. RaffleUnlimited.db.timeStart .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "end") and arr[3] == "date" then
			dArr = {}
			i = 1
			for val in string.gmatch(arr[4],"%w+") do
				dArr[i] = tonumber(val)
				i = i + 1
			end
			if dArr[1] == nil or dArr[2] == nil or dArr[3] == nil then
				RaffleUnlimited.db.dateEnd = RaffleUnlimited.defaults.dateEnd
			else
				arr[4] = dArr[1] .. '/' .. dArr[2] .. '/' .. dArr[3]
				if RaffleUnlimited:CreateDates(arr[4]) == nil then
					CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: Ending Date was not found!\r\nPlease make sure you are using the M/D/YYYY format.\nTo see the available date range, type: /raffleunlimited")
					return
				end
				RaffleUnlimited.db.dateEnd = arr[4]
			end
			CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. ' set the "Ending Date" for the raffle to ' .. RaffleUnlimited.db.dateEnd .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "end") and arr[3] == "time" then
			dArr = {}
			i = 1
			for val in string.gmatch(arr[4],"%w+") do
				dArr[i] = tonumber(val)
				i = i + 1
			end
			if dArr[1] == nil or dArr[2] == nil then
				RaffleUnlimited.db.timeEnd = RaffleUnlimited.defaults.timeEnd
			else
				if arr[5] ~= nil and arr[5] ~= "" then
					arr[6] = arr[5]
				end
				arr[4] = dArr[1]
				arr[5] = dArr[2]
				found = false
				if arr[6] ~= nil and string.lower(arr[6]) == "pm" then arr[4] = arr[4] + 12 end
				if arr[4] >= 24 then arr[4] = arr[4] - 24 end
				for i=0, 23, 1 do
					if i == arr[4] then
						found = true
						break
					end
				end
				if found == false then
					CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: Invalid Ending Time!\r\nThis must be in military time in the H:MM format.\nTo see the available times, type: /raffleunlimited")
					return
				end
				if arr[5] >= 30 and arr[4] < 23 then
					arr[4] = tonumber(arr[4]) + 1
				end
				RaffleUnlimited.db.timeEnd = arr[4] .. ":00"
			end
			CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. ' set the "Ending Time" for the raffle to ' .. RaffleUnlimited.db.timeEnd .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if arr[2] == "allow" then
			if string.find(string.lower(arr[3]), "on") or arr[3] == "1" then
				RaffleUnlimited.db.restriction = "One"
			else
				RaffleUnlimited.db.restriction = "Multiple"
			end
			CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. ' set the prizes per winner to ' .. RaffleUnlimited.db.restriction .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if (string.find(arr[2], "bon") and string.find(arr[3], "m")) or (string.find(arr[3], "bon") and string.find(arr[2], "m")) then
			if RaffleUnlimited.db.bonusTickets == nil then
				CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: No bonus tickets were found")
				return
			else
				arr[4] = string.lower(arr[4])
				if string.find(arr[4], "y") or string.find(arr[4], "t") then
					RaffleUnlimited.db.bonusTickets["multi"] = true
					arr[4] = "YES"
				else
					RaffleUnlimited.db.bonusTickets["multi"] = false
					arr[4] = "NO"
				end
			end
			CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. ' set the bonus multiplier to "' .. arr[4] .. '"')
			return
		end		
		arr[3] = RaffleUnlimited:ConvertNumber(arr[3], true)
		if string.find(arr[2], "tick") and tonumber(arr[3]) ~= nil then
			arr[3] = tonumber(arr[3])
			if arr[3] <= 0 then
				CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: Invalid Ticket Quantity")
				return
			elseif arr[4] == nil or arr[4] == "" then
				CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000REQUIRED: Username")
				return
			end
			if RaffleUnlimited.db.tickets == nil then
				RaffleUnlimited.db.tickets = {}
				RaffleUnlimited.db.tickets['count'] = 0
			end
			n = RaffleUnlimited.db.tickets['count'] + 1
			if string.find(arr[4], "@") == nil then arr[4] = "@" .. arr[4] end
			RaffleUnlimited.db.tickets[n] = {
				timestamp = GetTimeStamp(),
				username = arr[4],
				quantity = arr[3]
			}
			RaffleUnlimited.db.tickets['count'] = n
			arr[2] = ""
			if arr[3] > 1 then
				arr[2] = "s"
			end
			CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. ' assigned ' .. arr[3] .. ' ticket' .. arr[2] .. ' for ' .. arr[4])
			return
		end
		arr[4] = RaffleUnlimited:ConvertNumber(arr[4], true)
		if string.find(arr[2], "bon") and tonumber(arr[3]) ~= nil and tonumber(arr[4]) ~= nil then
			arr[3] = tonumber(arr[3])
			if RaffleUnlimited.db.bonusTickets == nil then
				RaffleUnlimited.db.bonusTickets = {}
				RaffleUnlimited.db.bonusTickets["arrCount"] = 0
				RaffleUnlimited.db.bonusTickets["multi"] = true
				RaffleUnlimited.db.bonusTickets["amount"] = {}
			end
			found = false
			for k,v in pairs(RaffleUnlimited.db.bonusTickets["amount"]) do
				if v[1] == arr[3] then
					found = true
					RaffleUnlimited.db.bonusTickets["amount"][k] = { arr[3], tonumber(arr[4]) }
					break
				end
			end
			if found == false then
				k = RaffleUnlimited.db.bonusTickets["arrCount"] + 1
				RaffleUnlimited.db.bonusTickets["arrCount"] = k
				RaffleUnlimited.db.bonusTickets["amount"][k] = { arr[3], tonumber(arr[4]) }
			end
			if tonumber(arr[4]) == 1 then
				arr[4] = ""
			else
				arr[4] = "s"
			end
			CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. ' set ' .. RaffleUnlimited.db.bonusTickets["amount"][k][2] .. ' bonus ticket' .. arr[4] .. ' when ' .. RaffleUnlimited:ConvertNumber(arr[3]) .. ' is deposited')
			table.sort(RaffleUnlimited.db.bonusTickets["amount"], function(a, b) return a[1] > b[1] end)
			return
		end
		if string.find(arr[2], "item") and tonumber(arr[3]) ~= nil and tonumber(arr[4]) ~= nil then
			arr[3] = tonumber(arr[3])
			if arr[3] == 0 then arr[3] = 1 end
			arr[4] = tonumber(arr[4])
			if arr[4] == nil or arr[4] <= 0 then
				CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: Items must have a valid quantity.\r")
				return
			end
			q = ""
			if string.find(arr[5], "ticket") then
				item = "Free Raffle Ticket"
				zName = "Free Raffle Ticket"
				if arr[4] > 1 then
					item = item .. "s"
					zName = zName .. "s"
				end
			else
				item = arr[5]
				zName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(item))
				if item == nil or zName == nil or zName == "" then
					CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: " .. item .. " not found.\r")
					return
				end
				if IsItemLinkBound(item) == true then
					CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: " .. item .. " is bound!\r")
					return
				end
				q = GetString("SI_ITEMQUALITY", GetItemLinkQuality(item))
			end
			if RaffleUnlimited.db.items == nil or RaffleUnlimited.db.items["arrCount"] == nil or RaffleUnlimited.db.items["arrCount"][arr[3]] == nil then
				if RaffleUnlimited.db.items == nil then
					RaffleUnlimited.db.items = {}
					RaffleUnlimited.db.items["arrCount"] = {}
				end
				RaffleUnlimited.db.items["arrCount"][arr[3]] = nil
				RaffleUnlimited.db.items[arr[3]] = {}
				n = 0
			else
				n = RaffleUnlimited.db.items["arrCount"][arr[3]]
			end
			n = n + 1
			RaffleUnlimited.db.items["arrCount"][arr[3]] = n
			RaffleUnlimited.db.items[arr[3]][n] = {
				itemCode = item,
				qty = arr[4],
				name = zName,
				quality = q
			}
			item = RaffleUnlimited.db.items[arr[3]][n]
			if arr[3] == 1 then
				arr[3] = ""
			else
				arr[3] = ", which unlocks at " .. RaffleUnlimited:ConvertNumber(arr[3])
			end
			CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \nSuccessfully added " .. item.itemCode .. " with a quantity of " .. item.qty .. arr[3])
			return
		end
		if arr[2] == "gold" and tonumber(arr[3]) ~= nil and tonumber(arr[4]) ~= nil then
			arr[3] = tonumber(arr[3])
			if arr[3] == 0 then arr[3] = 1 end
			if RaffleUnlimited.db.items == nil or RaffleUnlimited.db.items["arrCount"] == nil or RaffleUnlimited.db.items["arrCount"][arr[3]] == nil then
				if RaffleUnlimited.db.items == nil then
					RaffleUnlimited.db.items = {}
					RaffleUnlimited.db.items["arrCount"] = {}
				end
				RaffleUnlimited.db.items["arrCount"][arr[3]] = nil
				RaffleUnlimited.db.items[arr[3]] = {}
				n = 0
			else
				n = RaffleUnlimited.db.items["arrCount"][arr[3]]
			end
			n = n + 1
			RaffleUnlimited.db.items["arrCount"][arr[3]] = n
			RaffleUnlimited.db.items[arr[3]][n] = {
				itemCode = "gold",
				qty = tonumber(arr[4]),
				name = "gold"
			}
			item = RaffleUnlimited.db.items[arr[3]][n]
			if arr[3] == 1 then
				arr[3] = ""
			else
				arr[3] = ", which unlocks at " .. RaffleUnlimited:ConvertNumber(arr[3])
			end
			CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \nSuccessfully added " .. item.qty .. " gold" .. arr[3])
			return
		end
		CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: Settings command not found.\r\nFor the list of commands, type: /raffleu help set")
		return
	end
	if arr[1] == "draw" then
		if arr[2] ~= nil and tonumber(arr[2]) ~= nil then
			RaffleUnlimited:DrawRaffle(tonumber(arr[2]))
		else
			RaffleUnlimited:DrawRaffle()
		end
		return
	end
	if string.find(arr[1], "result") then
		if RaffleUnlimited:RaffleResults() == false then
			RaffleUnlimited:DrawRaffle()
		end
		return
	end
	if arr[1] == "list" or arr[1] == "display" then
		m = "|cFF0000ERROR: List command not found.\r\nFor the available commands, type: /raffleu help list"
		if arr[2] == nil then arr[2] = "" end
		if string.find(arr[2], "ent") and arr[3] == "price" then
			m = "Entry Price: $" .. RaffleUnlimited.db.entryPrice
		elseif string.find(arr[2], "sett") then
			CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \nRaffle Settings")
			CHAT_SYSTEM:AddMessage("Guild: " .. RaffleUnlimited.db.guild)
			arr[3] = tonumber(RaffleUnlimited.db.guildRank)
			if arr[3] ~= nil and arr[3] > 1 then
				arr[3] = "1-"
			else
				arr[3] = ""
			end
			CHAT_SYSTEM:AddMessage("Exclude Guild Rank(s): " .. arr[3] .. RaffleUnlimited.db.guildRank)
			CHAT_SYSTEM:AddMessage("Entry Price: $" .. RaffleUnlimited.db.entryPrice)
			CHAT_SYSTEM:AddMessage("Starting Amount: $" .. RaffleUnlimited.db.startAmt)
			CHAT_SYSTEM:AddMessage("Starting Date: " .. RaffleUnlimited.db.dateStart)
			CHAT_SYSTEM:AddMessage("Starting Time: " .. RaffleUnlimited.db.timeStart)
			CHAT_SYSTEM:AddMessage("Ending Date: " .. RaffleUnlimited.db.dateEnd)
			CHAT_SYSTEM:AddMessage("Ending Time: " .. RaffleUnlimited.db.timeEnd)
			CHAT_SYSTEM:AddMessage("Prizes Per Username: " .. RaffleUnlimited.db.restriction)
			return
		elseif arr[2] == "guild" then
			m = "Guild: " .. RaffleUnlimited.db.guild
		elseif string.find(arr[2], "rank") then
			arr[3] = tonumber(RaffleUnlimited.db.guildRank)
			if arr[3] ~= nil and arr[3] > 1 then
				arr[3] = "1-"
			else
				arr[3] = ""
			end
			m = "Exclude Guild Rank(s): " .. arr[3] .. RaffleUnlimited.db.guildRank
		elseif string.find(arr[2], "ent") then
			m = "Entry Price: $" .. RaffleUnlimited.db.entryPrice
		elseif string.find(arr[2], "start") and string.find(arr[3], "am") and string.find(arr[3], "t") then
			m = "Starting Amount: $" .. RaffleUnlimited.db.startAmt
		elseif string.find(arr[2], "start") and arr[3] == "date" then
			m = "Starting Date: " .. RaffleUnlimited.db.dateStart
		elseif string.find(arr[2], "start") and arr[3] == "time" then
			m = "Starting Time: " .. RaffleUnlimited.db.timeStart
		elseif string.find(arr[2], "end") and arr[3] == "date" then
			m = "Ending Date: " .. RaffleUnlimited.db.dateEnd
		elseif string.find(arr[2], "end") and arr[3] == "time" then
			m = "Ending Time: " .. RaffleUnlimited.db.timeEnd
		elseif arr[2] == "allow" then
			m = "Prizes Per Username: " .. RaffleUnlimited.db.restriction
		elseif string.find(arr[2], "prize") then
			m = "|cFF0000ERROR: No items were found!"
			if RaffleUnlimited.db.items ~= nil then
				arr[3] = RaffleUnlimited:ConvertNumber(arr[3], true)
				if tonumber(arr[3]) == 0 then arr[3] = 1 end
				if arr[3] == "all" then
					temp = {}
					n = 1
					for k,v in pairs(RaffleUnlimited.db.items) do
						if k ~= "arrCount" then
							temp[n] = { k }
							n = n + 1
						end
					end
					table.sort(temp, function(a, b) return a[1] < b[1] end)
					for k,v in pairs(temp) do
						RaffleUnlimited:ListItems(v[1])
					end
					return
				elseif arr[4] ~= nil then
					m = "|cFF0000ERROR: Specified item was not found!"
					arr[3] = tonumber(arr[3])
					arr[4] = tonumber(arr[4])
					if arr[3] ~= nil and arr[4] ~= nil and RaffleUnlimited.db.items[arr[3]] ~= nil and RaffleUnlimited.db.items[arr[3]][arr[4]] ~= nil then
						item = RaffleUnlimited.db.items[arr[3]][arr[4]]
						arr[3] = RaffleUnlimited:ConvertNumber(arr[3])
						if item.itemCode == "gold" then item.qty = RaffleUnlimited:ConvertNumber(item.qty) end
						if arr[3] == 1 then arr[3] = 0 end
						CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \nItem: " .. item.itemCode .. " -- \nQuantity: " .. item.qty .. " -- \nUnlocks at: " .. arr[3] .. " -- \n" .. arr[3] .. " Raffle Item #: " .. arr[4])
						return
					end
				elseif tonumber(arr[3]) ~= nil and RaffleUnlimited.db.items[tonumber(arr[3])] ~= nil then
					if tonumber(arr[3]) == 0 then arr[3] = 1 end
					RaffleUnlimited:ListItems(tonumber(arr[3]))
					return
				end
			end
		elseif string.find(arr[2], "bon") then
			if RaffleUnlimited.db.bonusTickets == nil then
				CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: No bonus ticket amounts were found!")
			else
				CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \nBonus ticket amounts...")
				for k,v in pairs(RaffleUnlimited.db.bonusTickets["amount"]) do
					s = "s"
					if v[2] == 1 then s = "" end
					CHAT_SYSTEM:AddMessage(RaffleUnlimited:ConvertNumber(v[1]) .. " deposited gives " .. v[2] .. " free ticket" .. s .. " (" .. k .. ")")
				end
				if RaffleUnlimited.db.bonusTickets.multi == true then
					m = "YES"
				else
					m = "NO"
				end
				if RaffleUnlimited.db.bonusTickets["arrCount"] >= 2 then
					m = m .. " (For example: " .. RaffleUnlimited:ConvertNumber(RaffleUnlimited.db.bonusTickets["amount"][1][1] + RaffleUnlimited.db.bonusTickets["amount"][2][1]) .. " deposit would give " .. (RaffleUnlimited.db.bonusTickets["amount"][1][2] + RaffleUnlimited.db.bonusTickets["amount"][2][2]) .. " bonus tickets)"
				else
					m = m .. " (For example: " .. RaffleUnlimited:ConvertNumber(RaffleUnlimited.db.bonusTickets["amount"][1][1]*2) .. " deposit would give " .. (RaffleUnlimited.db.bonusTickets["amount"][1][2]*2) .. " bonus tickets)"
				end
				CHAT_SYSTEM:AddMessage("Bonus ticket multiplier is on? " .. m)
			end
			return
		elseif string.find(arr[2], "tick") then
			if RaffleUnlimited.db.tickets == nil then
				CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: No free raffle tickets were found!")
			else
				CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \nUsers with Free Tickets...")
				for k,v in pairs(RaffleUnlimited.db.tickets) do
					if tonumber(k) ~= nil then
						CHAT_SYSTEM:AddMessage(v.username .. " x" .. v.quantity .. " (" .. k .. ")")
					end
				end
			end
			return
		end
		CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n" .. m)
		return
	end
	if string.find(arr[1], "ent") and arr[2] ~= nil and arr[2] ~= "" then
		if RaffleUnlimited.db.entries ~= nil and RaffleUnlimited.db.entries.entrants ~= nil then
			if tonumber(arr[2]) == nil then
				uN = string.lower(arr[2])
				found = false
				i = 1
				ii = 0
				totAmt = 0
				while RaffleUnlimited.db.entries.entrants[i] do
					if string.find(string.lower(RaffleUnlimited.db.entries.entrants[i].userName), uN) then
						found = true
						ii = ii + 1
						CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- Result: " .. ii .. " -- \nUsername: " .. RaffleUnlimited.db.entries.entrants[i].userName .. " -- Entry #: " .. RaffleUnlimited.db.entries.entrants[i].entryNum .. " -- Tickets Purchased: " .. RaffleUnlimited.db.entries.entrants[i].tickets .. " -- Ticket Numbers: " .. RaffleUnlimited.db.entries.entrants[i].ticketNums .. " -- Amount Deposited: $" .. RaffleUnlimited.db.entries.entrants[i].depositAmount)
						totAmt = totAmt + RaffleUnlimited.db.prizes.entrants[i].depositAmount
					end
					i = i + 1
				end
				if found == true then
					CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- Total Entries Found: " .. ii .. " -- Total Deposited Found: $" .. totAmt)
					return
				end
			end
			arr[2] = tonumber(arr[2])
			if arr[2] ~= nil then
				if RaffleUnlimited.db.entries.entrants[arr[2]] == nil then
					CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: Entry number not found!")
				else
					CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \nEntry #: " .. RaffleUnlimited.db.entries.entrants[arr[2]].entryNum .. " -- \nUsername: " .. RaffleUnlimited.db.entries.entrants[arr[2]].userName .. " -- \nTickets Purchased: " .. RaffleUnlimited.db.entries.entrants[arr[2]].tickets .. " -- \nTicket Numbers: " .. RaffleUnlimited.db.entries.entrants[arr[2]].ticketNums .. " -- \nAmount Deposited: $" .. RaffleUnlimited.db.entries.entrants[arr[2]].depositAmount)
				end
				return
			end
		end
		CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: No entries were found!")
		return
	end
	CHAT_SYSTEM:AddMessage(RaffleUnlimited.displayName .. " -- \n|cFF0000ERROR: Command not found.\r\nFor the list of commands, type: /raffleu help")
end

function RaffleUnlimited:Initialize()
	self:Menu()
	SLASH_COMMANDS["/raffleu"] = RaffleUnlimited.Cmd
end
 
function RaffleUnlimited.OnAddOnLoaded(event, addon)
	if addon == RaffleUnlimited.name then
		RaffleUnlimited:Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(RaffleUnlimited.name, EVENT_ADD_ON_LOADED, RaffleUnlimited.OnAddOnLoaded)