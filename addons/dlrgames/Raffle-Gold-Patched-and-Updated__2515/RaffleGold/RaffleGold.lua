RaffleGold = {
	db = nil,
	name = "RaffleGold",
	addonName = "Raffle Gold",
	displayName = "|cFFFFFFRaffle |cb38600Gold|r",
	lastDeposit = nil,
	defaults = {
		building = false,
		raffleType = "",
		totalEntries = "",
		totalAmount = "",
		entryPrice = "500",
		ticketPrice = nil,
		bonusTickets = nil,
		placeFirst = "35",
		placeSecond = "15",
		placeThird = "5",
		startAmt = "",
		dateStart = "-",
		dateEnd = "-",
		timeStart = "-",
		timeEnd = "-",
		restriction = "Multiple",
		prizes = {}
	}
}

function RaffleGold:Menu()
	local LAM2 = LibAddonMenu2

	local panelData = {
		type = "panel",
		name = self.addonName,
		displayName = self.displayName,
		author = "depeshmood",
		version = "18.23.51",
		slashCommand = "/rafflegold",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	LAM2:RegisterAddonPanel(self.name .. "LAM2Options", panelData)
	self.db = ZO_SavedVars:NewAccountWide("RaffleGold_SavedVars", 1, nil, self.defaults)
	local optionsTable = {
		{
			type = "header",
			name = "Global Raffle Settings",
			width = "full",
		},
		{
			type = "description",
			text = self.displayName .. " will display any error messages and the results of the raffle drawing in the chat window."
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
			name = "1st Place     %",
			tooltip = "The percentage that the first place winner wins from the total amount.",
			width = "full",
			default = self.defaults.placeFirst,
			getFunc = function() return self.db.placeFirst end,
			setFunc = function(choice) self.db.placeFirst = choice end
		},
		{
			type = "button",
			name = "Draw 1st Place",
			tooltip = "This will select only the first place winner.",
			width = "full",
			warning = "This will only select a winning number for 1st place!",
			func = function() self:DrawRaffle(true, "frt") end
		},
		{
			type = "editbox",
			name = "2nd Place     %",
			tooltip = "The percentage that the second place winner wins from the total amount.",
			width = "full",
			default = self.defaults.placeSecond,
			getFunc = function() return self.db.placeSecond end,
			setFunc = function(choice) self.db.placeSecond = choice end
		},
		{
			type = "button",
			name = "Draw 2nd Place",
			tooltip = "This will select only the second place winner.",
			width = "full",
			warning = "This will only select a winning number for 2nd place!",
			func = function() self:DrawRaffle(true, "scd") end
		},
		{
			type = "editbox",
			name = "3rd Place     %",
			tooltip = "The percentage that the third place winner wins from the total amount.",
			width = "full",
			default = self.defaults.placeThird,
			getFunc = function() return self.db.placeThird end,
			setFunc = function(choice) self.db.placeThird = choice end
		},
		{
			type = "button",
			name = "Draw 3rd Place",
			tooltip = "This will select only the third place winner.",
			width = "full",
			warning = "This will only select a winning number for 3rd place!",
			func = function() self:DrawRaffle(true, "trd") end
		},
		{
			type = "header",
			name = "Basic Raffle Drawing",
			width = "full",
		},
		{
			type = "editbox",
			name = "Total Entries",
			tooltip = "This is the total number of entries for the raffle, but should only be used if not pulling from the guild bank's deposit history.",
			width = "full",
			default = self.defaults.totalEntries,
			getFunc = function() return self.db.totalEntries end,
			setFunc = function(choice) self.db.totalEntries = choice end
		},
		{
			type = "editbox",
			name = "Total Amount     $",
			tooltip = "The grand total dollar amount.\n(if not using \"Entry Price\" above)",
			width = "full",
			default = self.defaults.totalAmount,
			getFunc = function() return self.db.totalAmount end,
			setFunc = function(choice) self.db.totalAmount = choice end
		},
		{
			type = "button",
			name = "Draw Raffle",
			tooltip = "This will select winning raffle ticket numbers only, based on the information above.\nThis will NOT include any of the \"Guild Bank Raffle Drawing\" settings and/or guild bank deposits.",
			width = "half",
			func = function() self:DrawRaffle(true) end
		},
		{
			type = "button",
			name = "Display Results",
			tooltip = "This will display the winners from the last time \"Draw Raffle\" was run.",
			width = "half",
			func = function() self:DrawRaffle(true, "d") end
		},
		{
			type = "header",
			name = "Guild Bank Raffle Drawing",
			width = "full",
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
			tooltip = "The number of allowed prizes per username.\nOne: Can only win one of the 3 places\nMultiple: First ticket # drawn",
			width = "full",
			choices = {"One", "Multiple"},
			default = self.defaults.restriction,
			getFunc = function() return self.db.restriction end,
			setFunc = function(choice) self.db.restriction = choice end
		},
		{
			type = "button",
			name = "Guild Raffle",
			tooltip = "This will select winners based on the deposits made into the guild bank and will not use the \"Basic Raffle Drawing\" settings.",
			width = "half",
			func = function() self:GuildRaffle() end
		},
		{
			type = "button",
			name = "Display Results",
			tooltip = "This will display the winners from the last time \"Guild Raffle\" was run.",
			width = "half",
			func = function() self:GuildResults() end
		},
		{
			type = "description",
			text = "Please note: If the guild is large enough and has enough transactions via the guild bank, it might take a few seconds, or so, to build the database.\nThere will be a message in the chat window letting you know that it has finished.\n\nThe guild bank's history is limited to 10 days, including today, and is only able to obtain information 9 days into the past. You will need to run this within that timeframe in order to retrieve any results.\n\nThe SavedVariables\\RaffleGold.lua file contains any of the entered information above and will also populate the guild entrants, which will need to be parsed if you would like to view and/or display them anywhere.\n\nTo open this menu, type: /rafflegold\nTo access the slash commands, type: /rfg <COMMAND> (For example: /rfg help)"
		}
	}
	LAM2:RegisterOptionControls(self.name .. "LAM2Options", optionsTable)
end

function RaffleGold:GetGuilds(gName)
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
			guilds[guild + 1] = guildName
		end
	end
	return guilds
end

function RaffleGold:DrawRaffle(out, p)
	m = nil
	if out == true and p == nil then
		self.db.prizes = {}
		self.db.raffleType = "draw"
	end
	if out == true and p ~= nil and self.db.raffleType == "guild" then
		return self:GuildRaffle(p)
	end
	nums = {
		entAmt = tonumber(self.db.entryPrice),
		entries = tonumber(self.db.totalEntries),
		pFrt = tonumber(self.db.placeFirst),
		pScd = tonumber(self.db.placeSecond),
		pTrd = tonumber(self.db.placeThird),
		tktAmt = tonumber(self.db.ticketPrice),
		totAmt = tonumber(self.db.totalAmount)
	}
	if out == true and (nums.entries == nil or nums.entries < 1) then
		m = "Total Entries"
		if self.db.totalEntries ~= nil and self.db.totalEntries ~= "" then
			m = "Valid " .. m
		end
	elseif out == true and (nums.totAmt == nil and nums.entAmt == nil) then
		m = "Total Amount or Entry Price"
	elseif out == true and self.db.totalAmount ~= nil and self.db.totalAmount ~= "" and (nums.totAmt == nil or nums.totAmt < 1) then
		m = "Valid Total Amount"
	elseif self.db.entryPrice ~= nil and self.db.entryPrice ~= "" and (nums.entAmt == nil or nums.entAmt < 1) then
		m = "Valid Entry Price"
	elseif out == true and nums.totAmt ~= nil and nums.entAmt ~= nil and (nums.entries * nums.entAmt) ~= nums.totAmt then
		m = "Valid Total Amount vs Entries and Entry Price"
	elseif self.db.ticketPrice ~= nil and self.db.ticketPrice ~= "" and (nums.tktAmt == nil or nums.tktAmt < 1 or nums.tktAmt >= nums.entAmt or (zo_round(nums.entAmt / nums.tktAmt) * nums.tktAmt) ~= nums.entAmt) then
		m = "Valid Price Per Ticket"
	elseif (p == nil or p == "frt") and (nums.pFrt == nil or nums.pFrt < 1) then
		m = "First Place Percentage"
		if self.db.placeFirst ~= nil and self.db.placeFirst ~= "" then
			m = "Valid " .. m
		end
	elseif (p == nil or p == "scd") and nums.pScd == nil then
		m = "Second Place Percentage"
		if self.db.placeSecond ~= nil and self.db.placeSecond ~= "" then
			m = "Valid " .. m
		end
	elseif (p == nil or p == "trd") and nums.pTrd == nil then
		m = "Third Place Percentage"
		if self.db.placeThird ~= nil and self.db.placeThird ~= "" then
			m = "Valid " .. m
		end
	end
	if m ~= nil then
		CHAT_SYSTEM:AddMessage(self.displayName .. " -- \n|cFF0000Required: " .. m .. "\r")
		return false
	end
	if out == false then
		return true
	end
	eAmt = nums.entries
	if nums.tktAmt ~= nil then
		eAmt = (zo_round(nums.entAmt / nums.tktAmt) * nums.entries)
	end
	if nums.totAmt ~= nil then
		tAmt = nums.totAmt
	else
		tAmt = nums.entAmt * nums.entries
	end
	sysMes = ""
	if p ~= "d" then
		sysMes = " -- \nTotal Raffle Tickets: " .. eAmt
		if eAmt ~= nums.entries then
			sysMes = sysMes .. " (Total Entries: " .. nums.entries .. ")"
		end
		sysMes = sysMes .. ", Total Amount: $" .. tAmt
	end
	if p == nil or p == "frt" or (p == "d" and self.db.prizes.numFrt ~= nil) then
		if p ~= "d" then
			self.db.prizes.numFrt = math.random(1, eAmt)
			while self.db.prizes.numScd == self.db.prizes.numFrt or self.db.prizes.numTrd == self.db.prizes.numFrt do
				self.db.prizes.numFrt = math.random(1, eAmt)
			end
			self.db.prizes.amtFrt = zo_round((nums.pFrt * .01) * tAmt)
		end
		sysMes = sysMes .. " -- \n1st Place: Ticket # " .. self.db.prizes.numFrt .. " won $" .. self.db.prizes.amtFrt
	end
	if ((p == nil or p == "scd") and nums.pScd > 0 and eAmt > 1) or (p == "d" and self.db.prizes.numScd ~= nil) then
		if p ~= "d" then
			self.db.prizes.numScd = zo_round(math.random(1, eAmt))
			while self.db.prizes.numScd == self.db.prizes.numFrt or self.db.prizes.numTrd == self.db.prizes.numScd do
				self.db.prizes.numScd = math.random(1, eAmt)
			end
			self.db.prizes.amtScd = zo_round((nums.pScd * .01) * tAmt)
		end
		sysMes = sysMes .. " -- \n2nd Place: Ticket # " .. self.db.prizes.numScd .. " won $" .. self.db.prizes.amtScd
	end
	if ((p == nil or p == "trd") and nums.pScd > 0 and nums.pTrd > 0 and eAmt > 2) or (p == "d" and self.db.prizes.numTrd ~= nil) then
		if p ~= "d" then
			self.db.prizes.numTrd = zo_round(math.random(1, eAmt))
			while self.db.prizes.numTrd == self.db.prizes.numFrt or self.db.prizes.numTrd == self.db.prizes.numScd do
				self.db.prizes.numTrd = math.random(1, eAmt)
			end
			self.db.prizes.amtTrd = zo_round((nums.pTrd * .01) * tAmt)
		end
		sysMes = sysMes .. " -- \n3rd Place: Ticket # " .. self.db.prizes.numTrd .. " won $" .. self.db.prizes.amtTrd
	end
	if out == true then
		CHAT_SYSTEM:AddMessage(self.displayName .. sysMes)
	end
	return true
end

function RaffleGold:GuildRaffle(p)
	if p == nil then
		self.db.prizes = {
			eAmt = nil,
			entries = nil,
			tAmt = nil,
			numFrt = nil,
			amtFrt = nil,
			nameFrt = nil,
			numScd = nil,
			amtScd = nil,
			nameScd = nil,
			numTrd = nil,
			amtTrd = nil,
			nameTrd = nil,
			drawDate = nil
		}
		self.db.raffleType = "guild"
	end
	m = nil
	if self:DrawRaffle(false) == false then
		return
	end
	if self.db.guild == nil or self.db.guild == "-" then
		m = "Guild"
	end
	stAmt = tonumber(self.db.startAmt)
	if self.db.startAmt ~= "" and stAmt == nil then
		m = "Valid Starting Amount"
	end
	if self.db.dateStart == nil or self.db.dateStart == "-" then
		m = "Starting Date"
	end
	if self.db.timeStart == nil or self.db.timeStart == "-" then
		m = "Start/End Time"
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
		CHAT_SYSTEM:AddMessage(self.displayName .. " -- \n|cFF0000ERROR: " .. m .. "lease wait for the addon to build the database and try again.")
		return false
	end
	
	nums = {
		entries = 0,
		entAmt = tonumber(self.db.entryPrice),
		pFrt = tonumber(self.db.placeFirst),
		pScd = tonumber(self.db.placeSecond),
		pTrd = tonumber(self.db.placeThird),
		tktAmt = tonumber(self.db.ticketPrice),
		tktPerEnt = "",
		totAmt = 0
	}
	if nums.tktAmt == nil or self.db.ticketPrice == "" then
		nums.tktAmt = nums.entAmt
	end
	nums.tktPerEnt = nums.entAmt / nums.tktAmt
	n = 1
	nn = 1
	depositInfo = {}
	entries = {}
	usernames = {}
	userRanks = {}
	self.db.prizes.entrants = {}
	for tIndex=numEvents, 1, -1 do
		eventType, secondsSinceDeposit, depositerName, amount, _, _, _, _ = GetGuildEventInfo(guildId, GUILD_HISTORY_BANK, tIndex)
		tS = cT - secondsSinceDeposit
		tP = amount / nums.entAmt
		if eventType == GUILD_EVENT_BANKGOLD_ADDED and (zo_round(tP) * nums.entAmt) == amount and tS >= sT and tS <= eT then
			tP = self:TicketCount(tP, amount)
			depositInfo[n] = { tS, tIndex, tP , depositerName, amount }
			userRanks[depositerName] = depositerName
			n = n + 1
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
			tP = v[3] * nums.tktPerEnt
			tckNums = n
			if tP > 1 then
				tckNums = tckNums .. "-" .. (n + tP - 1)
			end
			self.db.prizes.entrants[nn] = {
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
		self.db.prizes.oContrib = oC
	end
	usercount = nil
	if self.db.restriction == "One" then
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
	
	if p == nil then
		self.db.prizes.eAmt = eAmt
		self.db.prizes.entries = nums.entries
		self.db.prizes.tAmt = tAmt
		self.db.prizes.drawDate = GetDateStringFromTimestamp(eT)
	end
	
	sysMes = " -- \nTotal Raffle Tickets: " .. eAmt
	if eAmt ~= nums.entries then
		sysMes = sysMes .. " (Total Entries: " .. nums.entries .. ")"
	end
	sysMes = sysMes .. ", Total Amount: $" .. tAmt .. ", Drawing: " .. self.db.prizes.drawDate
	if p == nil or p == "frt" then
		self.db.prizes.numFrt = math.random(1, eAmt)
		while self.db.prizes.numScd == self.db.prizes.numFrt or self.db.prizes.numTrd == self.db.prizes.numFrt or (usercount ~= nil and ((self.db.prizes.nameScd ~= nil and entries[self.db.prizes.numFrt].name == self.db.prizes.nameScd) or (self.db.prizes.nameTrd ~= nil and entries[self.db.prizes.numFrt].name == self.db.prizes.nameTrd))) do
			self.db.prizes.numFrt = math.random(1, eAmt)
		end
		self.db.prizes.amtFrt = zo_round((nums.pFrt * .01) * tAmt)
		self.db.prizes.nameFrt = entries[self.db.prizes.numFrt].name
		sysMes = sysMes .. " -- \n1st Place: " .. self.db.prizes.nameFrt .. ", ticket # " .. self.db.prizes.numFrt .. ", won $" .. self.db.prizes.amtFrt
	end
	if (p == nil or p == "scd") and nums.pScd > 0 and eAmt > 1 and (usercount == nil or usercount >= 2) then
		self.db.prizes.numScd = zo_round(math.random(1, eAmt))
		while self.db.prizes.numScd == self.db.prizes.numFrt or self.db.prizes.numTrd == self.db.prizes.numScd or (usercount ~= nil and ((self.db.prizes.nameFrt ~= nil and entries[self.db.prizes.numScd].name == self.db.prizes.nameFrt) or (self.db.prizes.nameTrd ~= nil and entries[self.db.prizes.numScd].name == self.db.prizes.nameTrd))) do
			self.db.prizes.numScd = math.random(1, eAmt)
		end
		self.db.prizes.amtScd = zo_round((nums.pScd * .01) * tAmt)
		self.db.prizes.nameScd = entries[self.db.prizes.numScd].name
		sysMes = sysMes .. " -- \n2nd Place: " .. self.db.prizes.nameScd .. ", ticket # " .. self.db.prizes.numScd .. ", won $" .. self.db.prizes.amtScd
	end
	if (p == nil or p == "trd") and nums.pScd > 0 and nums.pTrd > 0 and eAmt > 2 and (usercount == nil or usercount >= 3) then
		self.db.prizes.numTrd = zo_round(math.random(1, eAmt))
		while self.db.prizes.numTrd == self.db.prizes.numFrt or self.db.prizes.numTrd == self.db.prizes.numScd or (usercount ~= nil and ((self.db.prizes.nameFrt ~= nil and entries[self.db.prizes.numTrd].name == self.db.prizes.nameFrt) or (self.db.prizes.nameScd ~= nil and entries[self.db.prizes.numTrd].name == self.db.prizes.nameScd))) do
			self.db.prizes.numTrd = math.random(1, eAmt)
		end
		self.db.prizes.amtTrd = zo_round((nums.pTrd * .01) * tAmt)
		self.db.prizes.nameTrd = entries[self.db.prizes.numTrd].name
		sysMes = sysMes .. " -- \n3rd Place: " .. self.db.prizes.nameTrd .. ", ticket # " .. self.db.prizes.numTrd .. ", won $" .. self.db.prizes.amtTrd
	end
	CHAT_SYSTEM:AddMessage(self.displayName .. " -- \nGuild: " .. self.db.guild .. sysMes)
	CHAT_SYSTEM:AddMessage("(\"Display Results\" will show the guild earnings)")
end

function RaffleGold:GuildResults()
	if self.db.prizes.numFrt == nil then
		return false
	end
	if self.db.raffleType == "draw" or self.db.prizes.nameFrt == nil then
		self:DrawRaffle(true)
		return false
	end

	eAmt = self.db.prizes.eAmt
	entries = self.db.prizes.entries
	tAmt = self.db.prizes.tAmt
	gAmt = tAmt

	sysMes = " -- \nTotal Raffle Tickets: " .. eAmt
	if eAmt ~= entries then
		sysMes = sysMes .. " (Total Entries: " .. entries .. ")"
	end
	sysMes = sysMes .. ", Total Amount: $" .. tAmt .. ", Drawing: " .. self.db.prizes.drawDate
	sysMes = sysMes .. " -- \n1st Place: " .. self.db.prizes.nameFrt .. ", ticket # " .. self.db.prizes.numFrt .. ", won $" .. self.db.prizes.amtFrt
	gAmt = gAmt - self.db.prizes.amtFrt
	if self.db.prizes.nameScd ~= nil then
		sysMes = sysMes .. " -- \n2nd Place: " .. self.db.prizes.nameScd .. ", ticket # " .. self.db.prizes.numScd .. ", won $" .. self.db.prizes.amtScd
		gAmt = gAmt - self.db.prizes.amtScd
	end
	if self.db.prizes.nameTrd ~= nil then
		sysMes = sysMes .. " -- \n3rd Place: " .. self.db.prizes.nameTrd .. ", ticket # " .. self.db.prizes.numTrd .. ", won $" .. self.db.prizes.amtTrd
		gAmt = gAmt - self.db.prizes.amtTrd
	end
	CHAT_SYSTEM:AddMessage(self.displayName .. " -- \nGuild: " .. self.db.guild .. sysMes .. " -- \nGuild Earned: $".. gAmt)
end

function RaffleGold:CreateDates(d)
	sD = GetTimeStamp() - (86400 * 10)
	rD = {}
	rD[1] = "-"
	n = 2
	for i=1, 21, 1 do
		t = sD + (86400 * i)
		if d == GetDateStringFromTimestamp(t) then
			return t
		else
			rD[n] = GetDateStringFromTimestamp(t)
			n = n+1
		end
	end
	if d ~= nil then
		return nil
	end
	return rD
end

function RaffleGold:CreateTimes()
	rT = {}
	rT[1] = "-"
	for i=0, 23, 1 do
		rT[i+2] = i .. ":00"
	end
	return rT
end

function RaffleGold:StartDate(sD, sT)
	sD = self:CreateDates(sD)
	if sD == nil then return nil end
	cT = {}
	cT.time = GetTimeString(sD)
	cT.hour, cT.min, cT.sec = cT.time:match("([^%:]+):([^%:]+):([^%:]+)")
	cT.sel, cT.sMin = sT:match("([^%:]+):([^%:]+)")
	sD = sD - (cT.min * 60) - cT.sec + ((tonumber(cT.sel) - tonumber(cT.hour)) * 60 * 60)
	return sD
end

function RaffleGold:BuildHistory(gID, sT, cT, tot, eT)
	if self.defaults.building == true and tot == nil then return nil end
	nE = GetNumGuildEvents(gID, GUILD_HISTORY_BANK)
	if tot == nil and (nE == 0 or eT > cT) then
		self.defaults.building = true
		RequestMoreGuildHistoryCategoryEvents(gID, GUILD_HISTORY_BANK)
		if nE == 0 then
			zo_callLater(function()
				RaffleGold:BuildHistory(gID, sT, cT, 0)
			end, 1500)
			return nil
		elseif GetNumGuildEvents(gID, GUILD_HISTORY_BANK) > nE then
			zo_callLater(function()
				RaffleGold:GetRecentHistory(gID, cT)
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
		RequestMoreGuildHistoryCategoryEvents(gID, GUILD_HISTORY_BANK)
		zo_callLater(function()
			RaffleGold:BuildHistory(gID, sT, cT, nE)
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

function RaffleGold:GetRecentHistory(gID, cT)
	nE = GetNumGuildEvents(gID, GUILD_HISTORY_BANK)
	_, secondsSinceDeposit, _, _, _, _, _, _ = GetGuildEventInfo(gID, GUILD_HISTORY_BANK, nE)
	if DoesGuildHistoryCategoryHaveMoreEvents(gID, GUILD_HISTORY_BANK) == true and (cT - secondsSinceDeposit) >= self.lastDeposit then
		self.defaults.building = true
		time = 1500
		if nE > 1 then
			time = time + math.random(1, nE)
		end
		RequestMoreGuildHistoryCategoryEvents(gID, GUILD_HISTORY_BANK)
		zo_callLater(function()
			RaffleGold:GetRecentHistory(gID, cT)
		end, time)
		return nil
	end
	self.defaults.building = false
	CHAT_SYSTEM:AddMessage(self.displayName .. " is now ready.")
end

function RaffleGold:CheckGuildRank(gID, rank, users)
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

function RaffleGold:RemainingTime(t)
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

function RaffleGold:ConvertNumber(amt, c)
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
			return amt * 1000
		end
	end
	return amt
end

function RaffleGold:TicketCount(tickets, amount)
	if RaffleGold.db.bonusTickets == nil or amount <= 0 then return tickets end
	for k,v in pairs(RaffleGold.db.bonusTickets["amount"]) do
		if amount >= v[1] then
			tickets = tickets + v[2]
			amount = amount - v[1]
			if RaffleGold.db.bonusTickets.multi == false then return (tickets) end
			return RaffleGold:TicketCount(tickets, amount)
		end
	end
	return tickets
end

function RaffleGold.Cmd(txt)
	if txt == "" then
		CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ': type "/rfg help" for a list of commands.')
		return
	end
	arr = {}
	i = 1
	for val in string.gmatch(txt,"%w+") do
		arr[i] = val
	    i = i + 1
	end
	if txt == "help" or arr[1] == "help" or arr[2] == "help" then
		if arr[2] == "help" then
			arr[2] = arr[1]
		end
		CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " commands:")
		if arr[2] == "set" then
			CHAT_SYSTEM:AddMessage('/rfg set entry price <AMOUNT> - Sets the "Entry Price"')
			CHAT_SYSTEM:AddMessage('/rfg set ticket price <AMOUNT> - Sets the "Ticket Price"')
			CHAT_SYSTEM:AddMessage('/rfg set first place <PERCENT> - Sets the "1st Place" percentage')
			CHAT_SYSTEM:AddMessage('/rfg set second place <PERCENT> - Sets the "2nd Place" percentage')
			CHAT_SYSTEM:AddMessage('/rfg set third place <PERCENT> - Sets the "3rd Place" percentage')
			CHAT_SYSTEM:AddMessage('/rfg set total entries <AMOUNT> - Sets the "Total Entries" for Basic Raffle')
			CHAT_SYSTEM:AddMessage('/rfg set total amount <AMOUNT> - Sets the "Total Amount $" for Basic Raffle')
			CHAT_SYSTEM:AddMessage('/rfg set guild <GUILD_NAME> - Sets the "Guild" for Guild Bank Raffle (case sensitive)')
			CHAT_SYSTEM:AddMessage('/rfg set rank <GUILD_RANK_NUMBER> - Sets the "Exclude Guild Rank(s)" for Guild Bank Raffle (numeric value)')
			CHAT_SYSTEM:AddMessage('/rfg set start amount <AMOUNT> - Sets the "Starting Amount $" for Guild Bank Raffle')
			CHAT_SYSTEM:AddMessage('/rfg set start date <M/D/YYYY> - Sets the "Starting Date" for Guild Bank Raffle')
			CHAT_SYSTEM:AddMessage('/rfg set start time <H:MM> - Sets the "Starting Time" for Guild Bank Raffle (military format)')
			CHAT_SYSTEM:AddMessage('/rfg set end date <M/D/YYYY> - Sets the "Ending Date" for Guild Bank Raffle')
			CHAT_SYSTEM:AddMessage('/rfg set end time <H:MM> - Sets the "Ending Time" for Guild Bank Raffle (military format)')
			CHAT_SYSTEM:AddMessage('/rfg set prizes <One OR Multiple> - Sets the number of prizes a username can win per raffle')
			CHAT_SYSTEM:AddMessage('/rfg set bonus <AMOUNT> <QUANTITY> - Gives QUANTITY of free tickets when AMOUNT of tickets purchased, per deposit, not username')
			CHAT_SYSTEM:AddMessage('/rfg set bonus multi <YES or NO> - Sets whether a deposit can receive multiple bonuses, default is "YES"')
		elseif arr[2] == "draw" then
			CHAT_SYSTEM:AddMessage('/rfg draw basic - This will draw the Basic Raffle')
			CHAT_SYSTEM:AddMessage('/rfg basic results - Results from the last Basic Raffle drawing')
			CHAT_SYSTEM:AddMessage("/rfg draw guild - This will run the Guild Bank Raffle\n(In-progress displays information; Ended displays winners)")
			CHAT_SYSTEM:AddMessage('/rfg guild results - Results from the last Guild Bank Raffle drawing\n(A new draw will overwrite this information)')
			CHAT_SYSTEM:AddMessage("/rfg entry <ENTRY_NUMBER> - Displays username, number of tickets, ticket numbers and amount deposited")
			CHAT_SYSTEM:AddMessage("/rfg entry <USERNAME> - Displays all entries for the username")
			CHAT_SYSTEM:AddMessage("/rfg draw first - This will draw only the 1st place winner")
			CHAT_SYSTEM:AddMessage("/rfg draw second - This will draw only the 2nd place winner")
			CHAT_SYSTEM:AddMessage("/rfg draw third - This will draw only the 3rd place winner")
		elseif arr[2] == "list" then
			CHAT_SYSTEM:AddMessage('/rfg list entry price - Displays the "Entry Price" amount')
			CHAT_SYSTEM:AddMessage('/rfg list ticket price - Displays the "Price per Ticket" amount')
			CHAT_SYSTEM:AddMessage('/rfg list percents - Displays the percentages for 1st, 2nd and 3rd')
			CHAT_SYSTEM:AddMessage('/rfg list first place - Displays the "1st Place" percentage')
			CHAT_SYSTEM:AddMessage('/rfg list second place - Displays the "2nd Place" percentage')
			CHAT_SYSTEM:AddMessage('/rfg list third place - Displays the "3rd Place" percentage')
			CHAT_SYSTEM:AddMessage('/rfg list basic settings - Displays the "Basic Raffle" specific settings')
			CHAT_SYSTEM:AddMessage('/rfg list total entries - Displays the "Total Entries" for the Basic Raffle')
			CHAT_SYSTEM:AddMessage('/rfg list total amount - Displays the "Total Amount" for the Basic Raffle')
			CHAT_SYSTEM:AddMessage('/rfg list guild settings - Displays the "Guild Bank Raffle" specific settings')
			CHAT_SYSTEM:AddMessage('/rfg list guild - Displays the "Guild" for the Guild Bank Raffle')
			CHAT_SYSTEM:AddMessage('/rfg list rank - Displays the "Exclude Guild Rank(s)" for the Guild Bank Raffle')
			CHAT_SYSTEM:AddMessage('/rfg list start amount - Displays the "Starting Amount" for the Guild Bank Raffle')
			CHAT_SYSTEM:AddMessage('/rfg list start date - Displays the "Starting Date" for the Guild Bank Raffle')
			CHAT_SYSTEM:AddMessage('/rfg list start time - Displays the "Starting Time" for the Guild Bank Raffle')
			CHAT_SYSTEM:AddMessage('/rfg list end date - Displays the "Ending Date" for the Guild Bank Raffle')
			CHAT_SYSTEM:AddMessage('/rfg list end time - Displays the "Ending Time" for the Guild Bank Raffle')
			CHAT_SYSTEM:AddMessage('/rfg list prizes - Displays the "Prizes Per Username" for the Guild Bank Raffle')
			CHAT_SYSTEM:AddMessage('/rfg list bonus - Displays all ticket purchase amounts and the number of free tickets for that amount')
		elseif arr[2] == "reset" or arr[2] == "remove" then
			CHAT_SYSTEM:AddMessage('/rfg reset all - Resets ALL of the stored information')
			CHAT_SYSTEM:AddMessage('/rfg reset defaults - Resets only the default UI information')
			CHAT_SYSTEM:AddMessage('/rfg reset bonus - Resets all bonus ticket amounts')
			CHAT_SYSTEM:AddMessage('/rfg remove bonus <AMOUNT> - Removes bonus tickets for the specified amount')
		else
			CHAT_SYSTEM:AddMessage('/rafflegold - Displays the menu UI')
			CHAT_SYSTEM:AddMessage('/rfg help - Displays the list of commands')
			CHAT_SYSTEM:AddMessage('/rfg help set - Displays the command settings')
			CHAT_SYSTEM:AddMessage('/rfg help list - Displays the commands for showing the current setting(s)')
			CHAT_SYSTEM:AddMessage('/rfg help draw - Displays the commands for drawing the raffle')
			CHAT_SYSTEM:AddMessage('/rfg help reset - Displays the commands for resetting the raffle')
		end
		return
	end
	if arr[1] == "reset" and arr[2] ~= nil then
		m = "|cFF0000ERROR: Reset command not found.\r\nFor the list of commands, type: /rfg help reset"
		if arr[2] == "all" or string.find(arr[2], "default") then
			if arr[2] == "all" then
				RaffleGold.db.bonusTickets = nil
				m = "All default settings restored."
			else
				m = "Default settings restored, excluding items and/or winners."
			end
			m = m .. "\nIf you do not see the change(s) in the menu, type: /reloadui"
			RaffleGold.db.building = RaffleGold.defaults.building
			RaffleGold.db.raffleType = RaffleGold.defaults.raffleType
			RaffleGold.db.totalEntries = RaffleGold.defaults.totalEntries
			RaffleGold.db.totalAmount = RaffleGold.defaults.totalAmount
			RaffleGold.db.entryPrice = RaffleGold.defaults.entryPrice
			RaffleGold.db.placeFirst = RaffleGold.defaults.placeFirst
			RaffleGold.db.placeSecond = RaffleGold.defaults.placeSecond
			RaffleGold.db.placeThird = RaffleGold.defaults.placeThird
			RaffleGold.db.startAmt = RaffleGold.defaults.startAmt
			RaffleGold.db.dateStart = RaffleGold.defaults.dateStart
			RaffleGold.db.dateEnd = RaffleGold.defaults.dateEnd
			RaffleGold.db.timeStart = RaffleGold.defaults.timeStart
			RaffleGold.db.timeEnd = RaffleGold.defaults.timeEnd
			RaffleGold.db.restriction = RaffleGold.defaults.restriction
			RaffleGold.db.prizes = RaffleGold.defaults.prizes
		elseif string.find(arr[2], "bon") then
			RaffleGold.db.bonusTickets = nil
			m = "Bonus ticket amounts have been reset."
		end
		CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n" .. m)
		return
	end
	if arr[1] == "remove" then
		arr[3] = tonumber(RaffleGold:ConvertNumber(arr[3], true))
		if string.find(arr[2], "bon") and RaffleGold.db.bonusTickets ~= nil and RaffleGold.db.bonusTickets["amount"][arr[3]] ~= nil then
			s = "s"
			if RaffleGold.db.bonusTickets["amount"][arr[3]] == 1 then s = "" end
			m = "Successfully removed " .. RaffleGold.db.bonusTickets["amount"][arr[3]][2] .. " bonus ticket" .. s .. " when " .. RaffleGold:ConvertNumber(RaffleGold.db.bonusTickets["amount"][arr[3]][1]) .. " deposited"
			if RaffleGold.db.bonusTickets["arrCount"] == 1 then
				RaffleGold.db.bonusTickets = nil
			else
				table.remove(RaffleGold.db.bonusTickets["amount"], arr[3])
				RaffleGold.db.bonusTickets["arrCount"] = RaffleGold.db.bonusTickets["arrCount"] - 1
				table.sort(RaffleGold.db.bonusTickets["amount"], function(a, b) return a[1] > b[1] end)
			end
		end
		CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n" .. m)
		return
	end
	if arr[1] == "set" then
		if string.find(arr[2], "ent") and arr[3] == "price" then
			arr[4] = tonumber(arr[4])
			if arr[4] == nil or arr[4] == 0 then arr[4] = RaffleGold.defaults.entryPrice end
			RaffleGold.db.entryPrice = arr[4]
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set the "Entry Price" to $' .. RaffleGold.db.entryPrice .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "tick") and arr[3] == "price" then
			arr[4] = tonumber(arr[4]) 
			if arr[4] == nil or arr[4] == 0 then
				RaffleGold.db.ticketPrice = RaffleGold.defaults.ticketPrice
				arr[4] = '<empty>'
			else
				RaffleGold.db.ticketPrice = arr[4]
				arr[4] = '$' .. arr[4]
			end
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set the "Ticket Price" to ' .. arr[4] .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if (arr[2] == "first" or arr[2] == "1st") and arr[3] == "place" then
			arr[4] = tonumber(arr[4])
			if arr[4] == nil or arr[4] == 0 then arr[4] = RaffleGold.defaults.placeFirst end
			RaffleGold.db.placeFirst = arr[4]
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set "1st Place" to ' .. RaffleGold.db.placeFirst .. "%\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if (arr[2] == "second" or arr[2] == "2nd") and arr[3] == "place" then
			arr[4] = tonumber(arr[4])
			if arr[4] == nil then arr[4] = 0 end
			RaffleGold.db.placeSecond = arr[4]
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set "2nd Place" to ' .. RaffleGold.db.placeSecond .. "%\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if (arr[2] == "third" or arr[2] == "3rd") and arr[3] == "place" then
			arr[4] = tonumber(arr[4])
			if arr[4] == nil then arr[4] = 0 end
			RaffleGold.db.placeThird = arr[4]
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set "3rd Place" to ' .. RaffleGold.db.placeThird .. "%\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "tot") and string.find(arr[2], "ent") then
			arr[4] = tonumber(arr[4])
			if arr[4] == nil or arr[4] == 0 then
				RaffleGold.db.totalEntries = RaffleGold.defaults.totalEntries
				arr[4] = '<empty>'
			else
				RaffleGold.db.totalEntries = arr[4]
			end
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set the "Total Entries" for the Basic Raffle to ' .. arr[4] .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "tot") and (arr[3] == "amount" or arr[3] == "amt") then
			arr[4] = tonumber(arr[4])
			if arr[4] == nil or arr[4] == 0 then
				RaffleGold.db.totalAmount = RaffleGold.defaults.totalAmount
				arr[4] = '<empty>'
			else
				RaffleGold.db.totalAmount = arr[4]
				arr[4] = '$' .. arr[4]
			end
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set the "Total Amount" for the Basic Raffle to ' .. arr[4] .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if arr[2] == "guild" then
			if arr[3] == nil or arr[3] == "-" then
				RaffleGold.db.guild = "-"
				arr[4] = '-'
			else
				n = 4
				while n < i do
					arr[3] = arr[3] .. " " .. arr[n]
					n = n + 1
				end
				if tonumber(RaffleGold:GetGuilds(arr[3])) == nil then
					CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n|cFF0000ERROR: You are not in the guild you entered!\r\nThe guild's name is case sensitive.")
					return
				end
				RaffleGold.db.guild = arr[3]
			end
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set the "Guild" for the Guild Bank Raffle to "' .. RaffleGold.db.guild .. "\"\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "rank") then
			arr[3] = tonumber(arr[3])
			if arr[3] == nil or arr[3] < 1 or arr[3] > 10 then
				arr[3] = "-"
				RaffleGold.db.guildRank = arr[3]
			else
				RaffleGold.db.guildRank = arr[3]
				if arr[3] > 1 then arr[3] = "1-" .. arr[3] end
			end
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set the "Exclude Guild Rank(s)" for the Guild Bank Raffle to "' .. arr[3] .. "\"\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "start") and (arr[3] == "amount" or arr[3] == "amt") then
			arr[4] = tonumber(arr[4])
			if arr[4] == nil or arr[4] == 0 then
				RaffleGold.db.startAmt = RaffleGold.defaults.startAmt
				arr[4] = '<empty>'
			else
				RaffleGold.db.startAmt = arr[4]
				arr[4] = '$' .. arr[4]
			end
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set the "Starting Amount" for the Guild Bank Raffle to ' .. arr[4] .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "start") and arr[3] == "date" then
			arr[4] = tonumber(arr[4])
			arr[5] = tonumber(arr[5])
			arr[6] = tonumber(arr[6])
			if arr[4] == nil or arr[5] == nil or arr[6] == nil then
				RaffleGold.db.dateStart = RaffleGold.defaults.dateStart
			else
				arr[4] = arr[4] .. '/' .. arr[5] .. '/' .. arr[6]
				if RaffleGold:CreateDates(arr[4]) == nil then
					CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n|cFF0000ERROR: Starting Date was not found!\r\nPlease make sure you are using the M/D/YYYY format.\nTo see the available date range, type: /rafflegold")
					return
				end
				RaffleGold.db.dateStart = arr[4]
			end
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set the "Starting Date" for the Guild Bank Raffle to ' .. RaffleGold.db.dateStart .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "start") and arr[3] == "time" then
			if arr[4] == nil or arr[4] == "-" or arr[5] == nil or arr[5] == "-" then
				RaffleGold.db.timeStart = RaffleGold.defaults.timeStart
			else
				found = false
				arr[4] = tonumber(arr[4])
				arr[5] = tonumber(arr[5])
				if arr[4] ~= nil and arr[5] ~= nil then
					if arr[6] ~= nil and string.lower(arr[6]) == "pm" then arr[4] = arr[4] + 12 end
					if arr[4] >= 24 then arr[4] = arr[4] - 24 end
					for i=0, 23, 1 do
						if i == arr[4] then
							found = true
							break
						end
					end
				end
				if found == false then
					CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n|cFF0000ERROR: Invalid Starting Time!\r\nThis must be in military time in the H:MM format.\nTo see the available times, type: /rafflegold")
					return
				end
				if arr[5] >= 30 and arr[4] < 23 then
					arr[4] = tonumber(arr[4]) + 1
				end
				RaffleGold.db.timeStart = arr[4] .. ":00"
			end
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set the "Starting Time" for the Guild Bank Raffle to ' .. RaffleGold.db.timeStart .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "end") and arr[3] == "date" then
			arr[4] = tonumber(arr[4])
			arr[5] = tonumber(arr[5])
			arr[6] = tonumber(arr[6])
			if arr[4] == nil or arr[5] == nil or arr[6] == nil then
				RaffleGold.db.dateEnd = RaffleGold.defaults.dateEnd
			else
				arr[4] = arr[4] .. '/' .. arr[5] .. '/' .. arr[6]
				if RaffleGold:CreateDates(arr[4]) == nil then
					CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n|cFF0000ERROR: Ending Date was not found!\r\nPlease make sure you are using the M/D/YYYY format.\nTo see the available date range, type: /rafflegold")
					return
				end
				RaffleGold.db.dateEnd = arr[4]
			end
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set the "Ending Date" for the Guild Bank Raffle to ' .. RaffleGold.db.dateEnd .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "end") and arr[3] == "time" then
			if arr[4] == nil or arr[4] == "-" or arr[5] == nil or arr[5] == "-" then
				RaffleGold.db.timeEnd = RaffleGold.defaults.timeEnd
			else
				found = false
				arr[4] = tonumber(arr[4])
				arr[5] = tonumber(arr[5])
				if arr[4] ~= nil and arr[5] ~= nil then
					if arr[6] ~= nil and string.lower(arr[6]) == "pm" then arr[4] = arr[4] + 12 end
					if arr[4] >= 24 then arr[4] = arr[4] - 24 end
					for i=0, 23, 1 do
						if i == arr[4] then
							found = true
							break
						end
					end
				end
				if found == false then
					CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n|cFF0000ERROR: Invalid Ending Time!\r\nThis must be in military time in the H:MM format.\nTo see the available times, type: /rafflegold")
					return
				end
				if arr[5] >= 30 and arr[4] < 23 then
					arr[4] = tonumber(arr[4]) + 1
				end
				RaffleGold.db.timeEnd = arr[4] .. ":00"
			end
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set the "Ending Time" for the Guild Bank Raffle to ' .. RaffleGold.db.timeEnd .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if string.find(arr[2], "prize") then
			if string.find(string.lower(arr[3]), "on") or arr[3] == "1" then
				RaffleGold.db.restriction = "One"
			else
				RaffleGold.db.restriction = RaffleGold.defaults.restriction
			end
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set the prizes per winner to ' .. RaffleGold.db.restriction .. "\nIf you do not see the change(s) in the menu, type: /reloadui")
			return
		end
		if (string.find(arr[2], "bon") and string.find(arr[3], "m")) or (string.find(arr[3], "bon") and string.find(arr[2], "m")) then
			if RaffleGold.db.bonusTickets == nil then
				CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n|cFF0000ERROR: No bonus tickets were found")
				return
			else
				arr[4] = string.lower(arr[4])
				if string.find(arr[4], "y") or string.find(arr[4], "t") then
					RaffleGold.db.bonusTickets["multi"] = true
					arr[4] = "YES"
				else
					RaffleGold.db.bonusTickets["multi"] = false
					arr[4] = "NO"
				end
			end
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set the bonus multiplier to "' .. arr[4] .. '"')
			return
		end		
		arr[3] = RaffleGold:ConvertNumber(arr[3], true)
		arr[4] = RaffleGold:ConvertNumber(arr[4], true)
		if string.find(arr[2], "bon") and tonumber(arr[3]) ~= nil and tonumber(arr[4]) ~= nil then
			arr[3] = tonumber(arr[3])
			if RaffleGold.db.bonusTickets == nil then
				RaffleGold.db.bonusTickets = {}
				RaffleGold.db.bonusTickets["arrCount"] = 0
				RaffleGold.db.bonusTickets["multi"] = true
				RaffleGold.db.bonusTickets["amount"] = {}
			end
			found = false
			for k,v in pairs(RaffleGold.db.bonusTickets["amount"]) do
				if v[1] == arr[3] then
					found = true
					RaffleGold.db.bonusTickets["amount"][k] = { arr[3], tonumber(arr[4]) }
					break
				end
			end
			if found == false then
				k = RaffleGold.db.bonusTickets["arrCount"] + 1
				RaffleGold.db.bonusTickets["arrCount"] = k
				RaffleGold.db.bonusTickets["amount"][k] = { arr[3], tonumber(arr[4]) }
			end
			if tonumber(arr[4]) == 1 then
				arr[4] = ""
			else
				arr[4] = "s"
			end
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. ' set ' .. RaffleGold.db.bonusTickets["amount"][k][2] .. ' bonus ticket' .. arr[4] .. ' when ' .. RaffleGold:ConvertNumber(arr[3]) .. ' is deposited')
			table.sort(RaffleGold.db.bonusTickets["amount"], function(a, b) return a[1] > b[1] end)
			return
		end
		CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n|cFF0000ERROR: Settings command not found.\r\nFor the list of commands, type: /rfg help set")
		return
	end
	if arr[1] == "draw" then
		if arr[2] == "basic" then
			RaffleGold:DrawRaffle(true)
			return
		elseif arr[2] == "guild" then
			RaffleGold:GuildRaffle()
			return
		elseif arr[2] == "first" or arr[2] == "1st" then
			RaffleGold:DrawRaffle(true, "frt")
			return
		elseif arr[2] == "second" or arr[2] == "2nd" then
			RaffleGold:DrawRaffle(true, "scd")
			return
		elseif arr[2] == "third" or arr[2] == "3rd" then
			RaffleGold:DrawRaffle(true, "trd")
			return
		end
		CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n|cFF0000ERROR: Drawing command not found.\r\nFor the list of commands, type: /rfg help draw")
		return
	end
	if arr[2] == "results" or arr[2] == "result" then
		if arr[1] == "basic" then
			RaffleGold:DrawRaffle(true, "d")
			return
		elseif arr[1] == "guild" then
			if RaffleGold:GuildResults() == false then
				RaffleGold:GuildRaffle()
			end
			return
		end
		CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n|cFF0000ERROR: Results command not found.\r\nFor the list of commands, type: /rfg help draw")
		return
	end
	if arr[1] == "list" or arr[1] == "display" then
		m = "|cFF0000ERROR: List command not found.\r\nFor the available commands, type: /rfg help list"
		if string.find(arr[2], "ent") and arr[3] == "price" then
			m = "Entry Price: $" .. RaffleGold.db.entryPrice
		elseif arr[2] == "ticket" and arr[3] == "price" then
			m = "Price per Ticket: $" .. RaffleGold.db.ticketPrice
		elseif string.find(arr[2], "percent") then
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \nRaffle Percentages")
			CHAT_SYSTEM:AddMessage("1st Place: " .. RaffleGold.db.placeFirst .. "%")
			CHAT_SYSTEM:AddMessage("2nd Place: " .. RaffleGold.db.placeSecond .. "%")
			CHAT_SYSTEM:AddMessage("3rd Place: " .. RaffleGold.db.placeThird .. "%")
			return
		elseif (arr[2] == "first" or arr[2] == "1st") and arr[3] == "place" then
			m = "1st Place: " .. RaffleGold.db.placeFirst .. "%"
		elseif (arr[2] == "second" or arr[2] == "2nd") and arr[3] == "place" then
			m = "2nd Place: " .. RaffleGold.db.placeSecond .. "%"
		elseif (arr[2] == "third" or arr[2] == "3rd") and arr[3] == "place" then
			m = "3rd Place: " .. RaffleGold.db.placeThird .. "%"
		elseif arr[2] == "basic" and string.find(arr[3], "setting") then
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \nBasic Raffle Drawing Settings")
			CHAT_SYSTEM:AddMessage("Total Entries: " .. RaffleGold.db.totalAmount)
			CHAT_SYSTEM:AddMessage("Total Amount: $" .. RaffleGold.db.totalAmount)
			return
		elseif string.find(arr[2], "tot") and string.find(arr[3], "ent") then
			m = "Total Entries: " .. RaffleGold.db.totalAmount
		elseif string.find(arr[2], "tot") and (arr[3] == "amount" or arr[3] == "amt") then
			m = "Total Amount: $" .. RaffleGold.db.totalAmount
		elseif arr[2] == "guild" and (arr[3] == "setting" or arr[3] == "settings") then
			CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \nGuild Bank Raffle Drawing Settings")
			CHAT_SYSTEM:AddMessage("Guild: " .. RaffleGold.db.guild)
			arr[3] = tonumber(RaffleGold.db.guildRank)
			if arr[3] ~= nil and arr[3] > 1 then
				arr[3] = "1-"
			else
				arr[3] = ""
			end
			CHAT_SYSTEM:AddMessage("Exclude Guild Rank(s): " .. arr[3] .. RaffleGold.db.guildRank)
			CHAT_SYSTEM:AddMessage("Starting Amount: $" .. RaffleGold.db.startAmt)
			CHAT_SYSTEM:AddMessage("Starting Date: " .. RaffleGold.db.dateStart)
			CHAT_SYSTEM:AddMessage("Starting Time: " .. RaffleGold.db.timeStart)
			CHAT_SYSTEM:AddMessage("Ending Date: " .. RaffleGold.db.dateEnd)
			CHAT_SYSTEM:AddMessage("Ending Time: " .. RaffleGold.db.timeEnd)
			CHAT_SYSTEM:AddMessage("Prizes Per Username: " .. RaffleGold.db.restriction)
			return
		elseif arr[2] == "guild" then
			m = "Guild: " .. RaffleGold.db.guild
		elseif string.find(arr[2], "rank") then
			arr[3] = tonumber(RaffleGold.db.guildRank)
			if arr[3] ~= nil and arr[3] > 1 then
				arr[3] = "1-"
			else
				arr[3] = ""
			end
			m = "Exclude Guild Rank(s): " .. arr[3] .. RaffleGold.db.guildRank
		elseif string.find(arr[2], "start") and (arr[3] == "amt" or arr[3] == "amount") then
			m = "Starting Amount: $" .. RaffleGold.db.startAmt
		elseif string.find(arr[2], "start") and arr[3] == "date" then
			m = "Starting Date: " .. RaffleGold.db.dateStart
		elseif string.find(arr[2], "start") and arr[3] == "time" then
			m = "Starting Time: " .. RaffleGold.db.timeStart
		elseif string.find(arr[2], "end") and arr[3] == "date" then
			m = "Ending Date: " .. RaffleGold.db.dateEnd
		elseif string.find(arr[2], "end") and arr[3] == "time" then
			m = "Ending Time: " .. RaffleGold.db.timeEnd
		elseif string.find(arr[2], "prize") then
			m = "Prizes Per Username: " .. RaffleGold.db.restriction
		elseif string.find(arr[2], "bon") then
			if RaffleGold.db.bonusTickets == nil then
				CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n|cFF0000ERROR: No bonus ticket amounts were found!")
			else
				CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \nBonus ticket amounts...")
				for k,v in pairs(RaffleGold.db.bonusTickets["amount"]) do
					s = "s"
					if v[2] == 1 then s = "" end
					CHAT_SYSTEM:AddMessage(RaffleGold:ConvertNumber(v[1]) .. " deposited gives " .. v[2] .. " free ticket" .. s .. " (" .. k .. ")")
				end
				if RaffleGold.db.bonusTickets.multi == true then
					m = "YES"
				else
					m = "NO"
				end
				if RaffleGold.db.bonusTickets["arrCount"] >= 2 then
					m = m .. " (For example: " .. RaffleGold:ConvertNumber(RaffleGold.db.bonusTickets["amount"][1][1] + RaffleGold.db.bonusTickets["amount"][2][1]) .. " deposit would give " .. (RaffleGold.db.bonusTickets["amount"][1][2] + RaffleGold.db.bonusTickets["amount"][2][2]) .. " bonus tickets)"
				else
					m = m .. " (For example: " .. RaffleGold:ConvertNumber(RaffleGold.db.bonusTickets["amount"][1][1]*2) .. " deposit would give " .. (RaffleGold.db.bonusTickets["amount"][1][2]*2) .. " bonus tickets)"
				end
				CHAT_SYSTEM:AddMessage("Bonus ticket multiplier is on? " .. m)
			end
			return
		end
		CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n" .. m)
		return
	end
	if string.find(arr[1], "ent") and arr[2] ~= nil and arr[2] ~= "" then
		if RaffleGold.db.prizes.entrants ~= nil then
			if tonumber(arr[2]) == nil then
				uN = string.lower(arr[2])
				found = false
				i = 1
				ii = 0
				totAmt = 0
				while RaffleGold.db.prizes.entrants[i] do
					if string.find(string.lower(RaffleGold.db.prizes.entrants[i].userName), uN) then
						found = true
						ii = ii + 1
						CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- Result: " .. ii .. " -- \nUsername: " .. RaffleGold.db.prizes.entrants[i].userName .. " -- Entry #: " .. RaffleGold.db.prizes.entrants[i].entryNum .. " -- Tickets Purchased: " .. RaffleGold.db.prizes.entrants[i].tickets .. " -- Ticket Numbers: " .. RaffleGold.db.prizes.entrants[i].ticketNums .. " -- Amount Deposited: $" .. RaffleGold.db.prizes.entrants[i].depositAmount)
						totAmt = totAmt + RaffleGold.db.prizes.entrants[i].depositAmount
					end
					i = i + 1
				end
				if found == true then
					CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- Total Entries Found: " .. ii .. " -- Total Deposited Found: $" .. totAmt)
					return
				end
			end
			arr[2] = tonumber(arr[2])
			if arr[2] ~= nil then
				if RaffleGold.db.prizes.entrants[arr[2]] == nil then
					CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n|cFF0000ERROR: Entry number not found!")
				else
					CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \nEntry #: " .. RaffleGold.db.prizes.entrants[arr[2]].entryNum .. " -- \nUsername: " .. RaffleGold.db.prizes.entrants[arr[2]].userName .. " -- \nTickets Purchased: " .. RaffleGold.db.prizes.entrants[arr[2]].tickets .. " -- \nTicket Numbers: " .. RaffleGold.db.prizes.entrants[arr[2]].ticketNums .. " -- \nAmount Deposited: $" .. RaffleGold.db.prizes.entrants[arr[2]].depositAmount)
				end
				return
			end
		end
		CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n|cFF0000ERROR: No entries were found!")
		return
	end
	CHAT_SYSTEM:AddMessage(RaffleGold.displayName .. " -- \n|cFF0000ERROR: Command not found.\r\nFor the list of commands, type: /rfg help")
end

function RaffleGold:Initialize()
	self:Menu()
	SLASH_COMMANDS["/rfg"] = RaffleGold.Cmd
	if RaffleGold.db.bonusTickets == nil and RaffleGold.db.ticketPrice ~= "" and tonumber(RaffleGold.db.ticketPrice) ~= nil then
		RaffleGold.db.ticketPrice = nil
	end
end
 
function RaffleGold.OnAddOnLoaded(event, addon)
	if addon == RaffleGold.name then
		RaffleGold:Initialize()
	end
end

EVENT_MANAGER:RegisterForEvent(RaffleGold.name, EVENT_ADD_ON_LOADED, RaffleGold.OnAddOnLoaded)