
ExcessiveWithdrawals = {
	db = nil,
	name = "ExcessiveWithdrawals",
	addonName = "Excessive Withdrawals",
	displayName = "|cc40000Excessive Withdrawals|r",
	scanInterval = 600000,
	defaults = {
		building = false,
		warnings = false,
		gUser = "",
		ignoreAmt = "500",
		lastScan = {},
		userData = {},
    SizeOffsetX = 250,
    SizeOffsetY = 400,
    PosOffsetX = 0,
    PosOffsetY = 500,
    GUIshow = 1,
    GUIopacity = 50,
    ExitMode = ""
	}
}

function ExcessiveWithdrawals:Menu()
	local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

	local panelData = {
		type = "panel",
		name = self.addonName,
		displayName = self.displayName,
		author = "depeshmood_Kitherel",
		version = "18.23.0",
		slashCommand = "/exwithdraw",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	LAM2:RegisterAddonPanel(self.name .. "LAM2Options", panelData)
	local optionsTable = {
		{
			type = "header",
			name = "Guild Information",
			width = "full",
		},
		{
			type = "dropdown",
			name = "Guild",
			tooltip = "This is the guild that you would like to use to scan.",
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
			name = "Ignore up to                       $",
			tooltip = "Once the amount withdrawn exceeds this amount, you will begin to receive notifications per username.",
			width = "full",
			default = self.defaults.ignoreAmt,
			getFunc = function() return self.db.ignoreAmt end,
			setFunc = function(choice) self.db.ignoreAmt = choice end,
		},
		{
			type = "button",
			name = "Monitor Guild",
			tooltip = "This will start the addon for monitoring the guild bank's history, but only needs to be used after configuring the information above or to see any warnings.",
			width = "half",
			func = function() self:MonitorGuild() end
		},
		{
			type = "button",
			name = "List Disabled",
			tooltip = "This will list all usernames and guild bank total value, for gold/items deposited and withdrawn, that have their notifications disabled.",
			width = "half",
			func = function() self:ShowDisabled(false) end
		},
		{
			type = "header",
			name = "Automated Demotions (optional)",
			width = "full",
		},
		{
			type = "editbox",
			name = "Ignore up to                       $",
			tooltip = "Once the amount withdrawn exceeds this amount the user will automatically be demoted, while excluding the guild rank(s) specified above.",
			width = "full",
			default = 5000,
			getFunc = function() return self.db.demoteAmt end,
			setFunc = function(choice) self.db.demoteAmt = choice end,
		},
		{
			type = "dropdown",
			name = "New Guild Rank               #",
			tooltip = "The guild rank that you would like to demote players to that exceed the above amount. This should be a rank that does not have guild bank withdrawal permissions.",
			choices = {"-", 3, 4, 5, 6, 7, 8, 9, 10},
			default = 10,
			getFunc = function() return self.db.demoteRank end,
			setFunc = function(choice) self.db.demoteRank = choice end
		},
		{
			type = "header",
			name = "Member Management",
			width = "full",
		},
		{
			type = "editbox",
			name = "Username, including \"@\"",
			tooltip = "This is the guild member's username that you would like to manage.",
			width = "full",
			default = self.defaults.gUser,
			getFunc = function() return self.db.gUser end,
			setFunc = function(choice) self.db.gUser = choice end,
		},
		{
			type = "button",
			name = "Disable",
			tooltip = "This will disable all notifications for this user, until they do another guild bank transaction.",
			width = "half",
			func = function() self:Commands("ignore", self.db.gUser) end
		},
		{
			type = "button",
			name = "History",
			tooltip = "View the guild member's guild bank history.",
			width = "half",
			func = function() self:Commands("history", self.db.gUser) end
		},
		{
			type = "button",
			name = "Remove",
			tooltip = "This will remove the above username from the database for " .. self.displayName .. ", until they make new guild bank transactions.",
			width = "half",
			func = function() self:Commands("remove", self.db.gUser) end
		},
		{
			type = "button",
			name = "Enable",
			tooltip = "This will enable all chat window notifications for this user.",
			width = "half",
			func = function() self:Commands("enable", self.db.gUser) end
		},
		{
			type = "header",
			name = "Addon Settings",
			width = "full",
		},
		{
			type = "slider",
			name = "Scan Every ... minute(s)",
			tooltip = "This allows you to change the duration of time between each scan and notification(s).",
			width = "full",
			min = 1,
			max = 60,
			default = 10,
			getFunc = function() return self.db.delay end,
			setFunc = function(value)
				self.db.delay = value
				if tonumber(value) ~= nil then
					EVENT_MANAGER:UnregisterForUpdate(self.name)
					EVENT_MANAGER:RegisterForUpdate(self.name, tonumber(value) * 60000, function() ExcessiveWithdrawals:MonitorGuild() end)
				end
			end
		},
		{
			type = "checkbox",
			name = "Disable Warnings",
			tooltip = "This will disable the warning and/or error messages when pricing addons, Master Merchant and Tamriel Trade Centre, are not found and/or enabled.",
			width = "full",
			getFunc = function() return self.db.warnings end,
			setFunc = function(value) self.db.warnings = value end
		},
		{
			type = "button",
			name = "Reset All",
			tooltip = "This will reset and clear any and/or all guild data currently stored in " .. self.displayName .. ". (see warning below)",
			width = "half",
			func = function() self:Commands("reset", "history") end
		},
		{
			type = "button",
			name = "Reset Guild",
			tooltip = "This will clear all data for the currently selected guild. (see warning below)",
			width = "half",
			func = function() self:Commands("reset", self:GetGuilds(self.db.guild)) end
		},
		{
      type = "header",
      name = "GUI Options",
      width = "full",
    },
		{
      type = "button",
      name = "Show GUI",
      tooltip = "This will show the GUI",
      width = "half",
      func = function() self:Commands("show") end
    },
    {
      type = "button",
      name = "Hide GUI",
      tooltip = "This will hide the GUI",
      width = "half",
      func = function() self:Commands("hide") end
    },
    {
      type = "dropdown",
      name = "Bank Open Warning Rank         #",
      tooltip = "The guild rank is the first rank which indicates the guild bank is open if permissions are given",
      choices = {"-",2, 3, 4, 5, 6, 7, 8, 9, 10},
      default = 2,
      getFunc = function() return self.db.bankWarnRank end,
      setFunc = function(choice) self.db.bankWarnRank = choice end
    },
    {
      type = "slider",
      name = "Opacity of GUI",
      tooltip = "This allows you to change the opacity of the GUI",
      width = "full",
      min = 0,
      max = 100,
      default = 50,
      getFunc = function() return self.db.GUIopacity end,
      setFunc = function(value)
        self.db.GUIopacity = value
        if tonumber(value) ~= nil then
          value = value / 100
          ExcessiveWithdrawalsGUI:SetHidden(false)
          ExcessiveWithdrawalsGUI:SetAlpha(value)
        end
      end
    },
		{
			type = "header",
			name = "Chat Commands",
			width = "full",
		},
		{
			type = "description",
			text = "To open this menu, type: /exwithdraw\n\nUser's History: /excessive history @USERNAME\nDisable notifications: /excessive ignore @USERNAME\n               (auto-enabled upon deposit/withdrawal)\nEnable notifications: /excessive enable @USERNAME\nRemove history: /excessive remove @USERNAME\n\nList users with disabled notifications: /excessive history all\n               (configured guild members only)\n\nReset guild history: /excessive reset GUILD_NUMBER\nReset all history: /excessive reset history\n               (see below, as this can have a serious impact)\n\nPlease note: The guild bank's history is limited to 10 days, including today, and is only able to obtain information 9 days into the past. You will need to allow this addon to load and populate regularly within that timeframe in order to keep the information up-to-date.\n\nSlash commands can sometimes cause the UI to become unresponsive.\nType \"/reloadui\" to reset your user interface and resolve the issue."
		}
	}
	LAM2:RegisterOptionControls(self.name .. "LAM2Options", optionsTable)
end

function ExcessiveWithdrawals:GetGuilds(gName)
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
	if gName ~= nil then return false end
	return guilds
end

function ExcessiveWithdrawals:CheckGuildRank(gID, rank)
	users = {}
	if rank == nil or rank == "-" then rank = 0 end
	memberCount = GetNumGuildMembers(gID)
    if memberCount ~= 0 then
		for mIndex=1, memberCount, 1 do
			cName, _, cRank, _, _ = GetGuildMemberInfo(gID, mIndex)
            if cName ~= nil then
                if cRank <= rank then
					users[string.lower(cName)] = true
				else
					users[string.lower(cName)] = false
				end
            end
		end
	end
	return users
end

function ExcessiveWithdrawals:MonitorGuild()
	EVENT_MANAGER:UnregisterForUpdate(self.name)
	
	ExcessiveWithdrawalsGUILeft:SetText("")
	ExcessiveWithdrawalsGUIMid:SetText("")
	ExcessiveWithdrawalsGUIRight:SetText("")
	
	if self.db.guild == nil or self.db.guild == "-" or self:GetGuilds(self.db.guild) == false or self.defaults.building == true then return end

	guildName = self.db.guild
	guildId = self:GetGuilds(guildName)
	if guildId == false then return end
	if self.db.userData[guildName] == nil then
		self.db.userData[guildName] = {}
		self.db.lastScan[guildName] = nil
	end
	
	if self.db.bankWarnRank == "-" or self.db.bankWarnRank == nil then 
	 ExcessiveWithdrawalsGUIFooter:SetText("Last updated: ".. GetTimeString())
	else
	  tmpBankOpen = false
  	for rankCount=tonumber(self.db.bankWarnRank),10 do
  	   if DoesGuildRankHavePermission(guildId, rankCount, 16) then 
  	     tmpBankOpen = true
  	   end
  	end
    -- GUILD ID CHECK!!!  Name followed by Id number
    ExcessiveWithdrawalsGUIHeader:SetText("Guild: "..self.db.guild.." Id: "..self:GetGuilds(self.db.guild))
  	 
  	if tmpBankOpen then
  	  ExcessiveWithdrawalsGUIFooter:SetText("Last updated: ".. GetTimeString().."   |cFF0000Bank Open")
  	else
      ExcessiveWithdrawalsGUIFooter:SetText("Last updated: ".. GetTimeString().."   Bank Closed")
  	end
  end
  
	sT = self.db.lastScan[guildName]
	if sT == nil then sT = 1 end
	cT = GetTimeStamp()
	numEvents = self:BuildHistory(guildId, sT, cT, nil)
	if numEvents == nil or numEvents == 0 then return end
	trans = {}
	n = 0
	lS = sT
	for tIndex=numEvents, 1, -1 do
		eventType, secondsSinceDeposit, depositerName, qty, item, _, _, _ = GetGuildEventInfo(guildId, GUILD_HISTORY_BANK, tIndex)
		tS = cT - secondsSinceDeposit
		if depositerName ~= nil and tS >= sT then
			lS = cT
			if trans[depositerName] == nil then
				trans[depositerName] = {}
			end
			if eventType == GUILD_EVENT_BANKGOLD_ADDED or eventType == GUILD_EVENT_BANKGOLD_REMOVED then
				itemID = "gold"
				item = "gold"
			else
				itemID = tonumber(string.match(item, '|H.-:item:(.-):'))
				if itemID == nil then itemID = item end
			end
			if trans[depositerName][itemID] == nil then
				trans[depositerName][itemID] = {}
				trans[depositerName][itemID]["item"] = item
				trans[depositerName][itemID]["qty"] = 0
			end
			if eventType == GUILD_EVENT_BANKGOLD_ADDED or eventType == GUILD_EVENT_BANKITEM_ADDED then
				trans[depositerName][itemID]["qty"] = trans[depositerName][itemID]["qty"] + qty
			else
				trans[depositerName][itemID]["qty"] = trans[depositerName][itemID]["qty"] - qty
			end
			n = n + 1
		end
	end
	n = 0
	for k,v in pairs(trans) do
		self:BuildUser(guildName, k, v, cT)
	end
	userRanks = self:CheckGuildRank(guildId, self.db.guildRank)
	iAmt = tonumber(self.db.ignoreAmt)
	if iAmt == nil then iAmt = 0 end
	dRank, dAmt = nil
	if tonumber(self.db.demoteAmt) ~= nil and tonumber(self.db.demoteRank) ~= nil then
		_, _, cRank, _, _ = GetGuildMemberInfo(guildId, GetGuildMemberIndexFromDisplayName(guildId, GetDisplayName()))
		if DoesGuildRankHavePermission(guildId, cRank, GUILD_PERMISSION_DEMOTE) == true then
			dAmt = tonumber(self.db.demoteAmt)
			dRank = tonumber(self.db.demoteRank)
			if dRank > GetNumGuildRanks(guildId) then dRank = GetNumGuildRanks(guildId) end
		end
	end
	for user,arr in pairs(self.db.userData[guildName]) do
		if arr.ignore ~= true and userRanks[user] ~= true then
			bal = arr.goldDeposit - arr.goldWithdraw + arr.itemsDepositVal - arr.itemsWithdrawVal
			if (dAmt ~= nil and (dAmt + bal) < 0) or (iAmt + bal) < 0 then
				if userRanks[user] == nil then
					if ExcessiveWithdrawalsGUI:IsHidden() then
					 CHAT_SYSTEM:AddMessage("|cFF0000Warning!  Warning!  Warning!|r\n" .. arr.userName .. " exceeded the guild bank allowance and is no longer a member! Balance on logged transactions: ".. bal)
					end
					userData = ExcessiveWithdrawals.db.userData[ExcessiveWithdrawals.db.guild][string.lower(arr.userName)]
          itemTot = userData.itemsDeposit - userData.itemsWithdraw
					ExcessiveWithdrawalsGUILeft:SetText(ExcessiveWithdrawalsGUILeft:GetText().."|cFF0000"..arr.userName.."\n")
          ExcessiveWithdrawalsGUIMid:SetText(ExcessiveWithdrawalsGUIMid:GetText()..string.format("|cFF0000%s\n",ExcessiveWithdrawals:CommaValue(bal)))
          ExcessiveWithdrawalsGUIRight:SetText(ExcessiveWithdrawalsGUIRight:GetText()..string.format("|cFF0000%s\n",ExcessiveWithdrawals:CommaValue(itemTot)))
				else
					if dAmt ~= nil and (dAmt + bal) < 0 then
						_, _, uRank, _, _ = GetGuildMemberInfo(guildId, GetGuildMemberIndexFromDisplayName(guildId, arr.userName))
					end
					if dRank ~= nil and uRank ~= nil and dRank > uRank then
						while dRank > uRank do
							zo_callLater(function()
								GuildDemote(guildId, arr.userName)
							end, 1000 * uRank)
							uRank = uRank + 1
						end
						CHAT_SYSTEM:AddMessage("|cFF0000Warning: " .. arr.userName .. " has violated the guild bank allowance and has been automatically demoted.")
						userData = ExcessiveWithdrawals.db.userData[ExcessiveWithdrawals.db.guild][string.lower(arr.userName)]
            itemTot = userData.itemsDeposit - userData.itemsWithdraw
						ExcessiveWithdrawalsGUILeft:SetText(ExcessiveWithdrawalsGUILeft:GetText().."|cFFFFFF"..arr.userName.."\n")
						ExcessiveWithdrawalsGUIMid:SetText(ExcessiveWithdrawalsGUIMid:GetText()..string.format("|cFFFFFF%s\n",ExcessiveWithdrawals:CommaValue(bal)))
            ExcessiveWithdrawalsGUIRight:SetText(ExcessiveWithdrawalsGUIRight:GetText()..string.format("|cFFFFFF%s\n",ExcessiveWithdrawals:CommaValue(itemTot)))
					else
						if ExcessiveWithdrawalsGUI:IsHidden() then
						  CHAT_SYSTEM:AddMessage("|cFF0000Warning: " .. arr.userName .. " has exceeded the guild bank allowance.".." Balance on logged transactions: " .. ExcessiveWithdrawals:CommaValue(bal))
						end
						
-- Testing code 
						--if ExcessiveWithdrawals:CheckData(arr.userName) == false then return true end
            --userData = ExcessiveWithdrawals.db.userData[ExcessiveWithdrawals.db.guild][string.lower(arr.userName)]
            --notify = "Enabled"
            --if userData.ignore == true then notify = "Disabled" end
            
            --CHAT_SYSTEM:AddMessage('Username: ' .. userData.userName .. '\n |  Items Deposited: ' .. ExcessiveWithdrawals:CommaValue(userData.itemsDeposit) .. '   value: ' .. ExcessiveWithdrawals:CommaValue(userData.itemsDepositVal) .. ' gold\n |  Items Withdrawn: ' .. ExcessiveWithdrawals:CommaValue(userData.itemsWithdraw) .. '   value: ' .. ExcessiveWithdrawals:CommaValue(userData.itemsWithdrawVal) .. ' gold\n |  Gold Deposited: ' .. ExcessiveWithdrawals:CommaValue(userData.goldDeposit) .. '\n |  Gold Withdrawn: ' .. ExcessiveWithdrawals:CommaValue(userData.goldWithdraw) .. '\n |  First Scanned on ' .. GetDateStringFromTimestamp(userData.initialScan) .. '\n |  Notifications: ' .. notify)
            userData = ExcessiveWithdrawals.db.userData[ExcessiveWithdrawals.db.guild][string.lower(arr.userName)]
            itemTot = userData.itemsDeposit - userData.itemsWithdraw
            --CHAT_SYSTEM:AddMessage('Username: ' .. userData.userName .. '\n |  Items Deposited: ' .. ExcessiveWithdrawals:CommaValue(userData.itemsDeposit) .. '   Items Withdrawn: ' .. ExcessiveWithdrawals:CommaValue(userData.itemsWithdraw) ..'    Item Balance: ' .. ExcessiveWithdrawals:CommaValue(itemTot))
            --itemTot = userData.itemsDepositVal - userData.itemsWithdrawVal
            --goldTot = userData.goldDeposit - userData.goldWithdraw
            --grandTot = itemTot + goldTot
            --CHAT_SYSTEM:AddMessage("Guild Bank Total Values --\n  Items: " .. ExcessiveWithdrawals:CommaValue(itemTot) .. "\n |  Gold: " .. ExcessiveWithdrawals:CommaValue(goldTot) .. "\n |  Grand Total: " .. ExcessiveWithdrawals:CommaValue(grandTot))
-- Testing Code
						
						ExcessiveWithdrawalsGUILeft:SetText(ExcessiveWithdrawalsGUILeft:GetText().."|cFFFFFF"..arr.userName.."\n")
						ExcessiveWithdrawalsGUIMid:SetText(ExcessiveWithdrawalsGUIMid:GetText()..string.format("|cFFFFFF%s\n",ExcessiveWithdrawals:CommaValue(bal)))
            ExcessiveWithdrawalsGUIRight:SetText(ExcessiveWithdrawalsGUIRight:GetText()..string.format("|cFFFFFF%s\n",ExcessiveWithdrawals:CommaValue(itemTot)))
					end
				end
			end
		end
	end
  ExcessiveWithdrawals.SetDynamicDimensions()
	self.db.lastScan[guildName] = lS
	timer = 600000
	if tonumber(self.db.delay) ~= nil then timer = tonumber(self.db.delay) * 60000 end
	EVENT_MANAGER:RegisterForUpdate(self.name, timer, function() ExcessiveWithdrawals:MonitorGuild() end)
end

function ExcessiveWithdrawals:BuildHistory(gID, sT, cT, tot)
	if self.defaults.building == true and tot == nil then return nil end
	nE = GetNumGuildEvents(gID, GUILD_HISTORY_BANK)
	if tot == nil then RequestGuildHistoryCategoryNewest(gID, GUILD_HISTORY_BANK) end
	if tot == nil and nE == 0 then
		self.defaults.building = true
		if nE == 0 then
			zo_callLater(function()
				ExcessiveWithdrawals:BuildHistory(gID, sT, cT, 0)
			end, 2000)
			return nil
		elseif GetNumGuildEvents(gID, GUILD_HISTORY_BANK) > nE then
			zo_callLater(function()
				ExcessiveWithdrawals:GetRecentHistory(gID, cT)
			end, 2000)
			return nil
		end
	end
	_, secondsSinceDeposit, _, _, _, _, _, _ = GetGuildEventInfo(gID, GUILD_HISTORY_BANK, nE)
	if DoesGuildHistoryCategoryHaveMoreEvents(gID, GUILD_HISTORY_BANK) == true and (cT - secondsSinceDeposit) > sT then
		self.defaults.building = true
		time = 2000
		if nE > 1 then
			time = time + math.random(1, nE)
		end
		RequestGuildHistoryCategoryOlder(gID, GUILD_HISTORY_BANK)
		zo_callLater(function()
			ExcessiveWithdrawals:BuildHistory(gID, sT, cT, nE)
		end, time)
		return nil
	end
	self.defaults.building = false
	self.lastDeposit = secondsSinceDeposit
	if tot ~= nil then
		self:MonitorGuild()
	end
	nE = GetNumGuildEvents(gID, GUILD_HISTORY_BANK)
	return nE
end

function ExcessiveWithdrawals:GetRecentHistory(gID, cT)
	nE = GetNumGuildEvents(gID, GUILD_HISTORY_BANK)
	_, secondsSinceDeposit, _, _, _, _, _, _ = GetGuildEventInfo(gID, GUILD_HISTORY_BANK, nE)
	if DoesGuildHistoryCategoryHaveMoreEvents(gID, GUILD_HISTORY_BANK) == true and (cT - secondsSinceDeposit) >= self.lastDeposit then
		self.defaults.building = true
		time = 2000
		if nE > 1 then
			time = time + math.random(1, nE)
		end
		RequestGuildHistoryCategoryOlder(gID, GUILD_HISTORY_BANK)
		zo_callLater(function()
			ExcessiveWithdrawals:GetRecentHistory(gID, cT)
		end, time)
		return nil
	end
	self.defaults.building = false
	self:MonitorGuild()
end

function ExcessiveWithdrawals:BuildUser(guild, user, items, fScan)
	if self.db.userData[guild][string.lower(user)] == nil then
		self.db.userData[guild][string.lower(user)] = {
			userName = user,
			initialScan = fScan,
			itemsDeposit = 0,
			itemsWithdraw = 0,
			itemsDepositVal = 0,
			itemsWithdrawVal = 0,
			goldDeposit = 0,
			goldWithdraw = 0,
			ignore = false
		}
	end
	user = string.lower(user)
	for item,j in pairs(items) do
		if item == "gold" then
			if j["qty"] >= 0 then
				self.db.userData[guild][user].goldDeposit = self.db.userData[guild][user].goldDeposit + j["qty"]
			else
				self.db.userData[guild][user].goldDeposit = self.db.userData[guild][user].goldDeposit - j["qty"]
			end
		else
			qty = j["qty"]
			if qty < 0 then qty = qty * -1 end
			if j["qty"] ~= 0 then
				price = self:GetPrice(j["item"]) * qty
			else
				price = 0
			end
			if j["qty"] >= 0 then
				self.db.userData[guild][user].itemsDeposit = self.db.userData[guild][user].itemsDeposit + qty
				self.db.userData[guild][user].itemsDepositVal = self.db.userData[guild][user].itemsDepositVal + price
			else
				self.db.userData[guild][user].itemsWithdraw = self.db.userData[guild][user].itemsWithdraw + qty
				self.db.userData[guild][user].itemsWithdrawVal = self.db.userData[guild][user].itemsWithdrawVal + price
			end
		end
		if j["qty"] < 0 then self.db.userData[guild][string.lower(user)].ignore = false end
	end
end

function ExcessiveWithdrawals:GetPrice(item)
	val = 0
	if item == "gold" then
		val = 1
	else
		if MasterMerchant ~= nil then
			val = MasterMerchant:itemStats(item, true)
			val = val.avgPrice
		end
		if TamrielTradeCentrePrice ~= nil and (MasterMerchant == nil or val == nil) then
			val = TamrielTradeCentrePrice:GetPriceInfo(item)
			if val ~= nil then
				if val.SuggestedPrice ~= nil then
					val = val.SuggestedPrice
				elseif val.Avg ~= nil then
					val = val.Avg
				else
					val = 0
				end
			else
				val = 0
			end
		end
		if val == nil or val == 0 then
			_, val, _, _, _ = GetItemLinkInfo(item)
		else
			val = zo_round(val * 100)
			val = val / 100
		end
	end
	return val
end

function ExcessiveWithdrawals:CheckData(user)
	if ExcessiveWithdrawals.db.guild == nil then
		CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. ' -- \n|cFF0000ERROR: No guild is selected.|r\nType "/exwithdraw" to configure.')
		return false
	elseif ExcessiveWithdrawals.db.userData[self.db.guild] == nil then
		CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. ' -- \n|cFF0000ERROR: No data collected for ' .. self.db.guild .. '.')
		return false
	elseif user == nil or user == "" then
		CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. ' -- \n|cFF0000ERROR: You must enter a username.')
		return false
	elseif ExcessiveWithdrawals.db.userData[self.db.guild][string.lower(user)] == nil then
		CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. ' -- \n|cFF0000ERROR: ' .. user .. ' does not currently have any statistics.')
		return false
	end
	return true
end

function ExcessiveWithdrawals:CommaValue(amount)
	amount = zo_round(amount)
	formatted = amount
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if k == 0 then break end
	end
	return formatted
end

function ExcessiveWithdrawals:ShowDisabled(m)
	if self.db.guild == nil or self.db.userData == nil or self.db.userData[self.db.guild] == nil then
		if self.db.guild == nil then
			CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. ' -- \n|cFF0000ERROR: No guild configured.')
		else
			CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. ' -- \n|cFF0000ERROR: ' .. self.db.guild .. ' does not currently have any data.')
		end
		return
	end
	n = 0
	CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. " -- \nGuild: " .. self.db.guild .. " \nStart Listing Notifications: Disabled")
	for user,arr in pairs(self.db.userData[self.db.guild]) do
		if arr.ignore == true then
			grandTot = arr.goldDeposit - arr.goldWithdraw + arr.itemsDepositVal - arr.itemsWithdrawVal
			CHAT_SYSTEM:AddMessage("Username: " .. arr.userName .. "\n |  Guild Bank Total Value: " .. ExcessiveWithdrawals:CommaValue(grandTot))
			n = n + 1
		end
	end
	if n == 0 or m == false then
		CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. " -- \nFinished Listing Notifications: Disabled")
	else
		CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. " -- \nFinished Listing Notifications: Disabled \nView details, type: /excessive history @USERNAME")
	end
end

function ExcessiveWithdrawals:Commands(key, val)
  if string.find(key, "hide") then
     ExcessiveWithdrawals.db.GUIshow = 0
     ExcessiveWithdrawalsGUI:SetHidden(true)
  end
  if string.find(key, "show") then
     ExcessiveWithdrawals.db.GUIshow = 1
     ExcessiveWithdrawalsGUI:SetHidden(false)
  end
	if string.find(key, "his") or string.find(key, "stat") then
		if string.find(val, "@") == nil then
			ExcessiveWithdrawals:ShowDisabled(true)
			return true
		end
		if ExcessiveWithdrawals:CheckData(val) == false then return true end
		userData = ExcessiveWithdrawals.db.userData[ExcessiveWithdrawals.db.guild][string.lower(val)]
		notify = "Enabled"
		if userData.ignore == true then notify = "Disabled" end
		CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. ' --\n  Username: ' .. userData.userName .. '\n |  Items Deposited: ' .. ExcessiveWithdrawals:CommaValue(userData.itemsDeposit) .. '   value: ' .. ExcessiveWithdrawals:CommaValue(userData.itemsDepositVal) .. ' gold\n |  Items Withdrawn: ' .. ExcessiveWithdrawals:CommaValue(userData.itemsWithdraw) .. '   value: ' .. ExcessiveWithdrawals:CommaValue(userData.itemsWithdrawVal) .. ' gold\n |  Gold Deposited: ' .. ExcessiveWithdrawals:CommaValue(userData.goldDeposit) .. '\n |  Gold Withdrawn: ' .. ExcessiveWithdrawals:CommaValue(userData.goldWithdraw) .. '\n |  First Scanned on ' .. GetDateStringFromTimestamp(userData.initialScan) .. '\n |  Notifications: ' .. notify)
		itemTot = userData.itemsDepositVal - userData.itemsWithdrawVal
		goldTot = userData.goldDeposit - userData.goldWithdraw
		grandTot = itemTot + goldTot
		CHAT_SYSTEM:AddMessage("Guild Bank Total Values --\n  Items: " .. ExcessiveWithdrawals:CommaValue(itemTot) .. "\n |  Gold: " .. ExcessiveWithdrawals:CommaValue(goldTot) .. "\n |  Grand Total: " .. ExcessiveWithdrawals:CommaValue(grandTot))
		return true
	end
	if string.find(key, "ign") or string.find(key, "ena") then
		if ExcessiveWithdrawals:CheckData(val) == false then return true end
		if string.find(key, "ign") then
			ExcessiveWithdrawals.db.userData[ExcessiveWithdrawals.db.guild][string.lower(val)].ignore = true
		else
			ExcessiveWithdrawals.db.userData[ExcessiveWithdrawals.db.guild][string.lower(val)].ignore = false
		end
		userData = ExcessiveWithdrawals.db.userData[ExcessiveWithdrawals.db.guild][string.lower(val)]
		notify = "Enabled"
		if userData.ignore == true then notify = "Disabled" end
		CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. ' -- \nUsername: ' .. userData.userName .. '\nNotifications: ' .. notify)
		return true
	end
	if string.find(key, "remov") then
		if ExcessiveWithdrawals:CheckData(val) == false then return true end
		userData = ExcessiveWithdrawals.db.userData[ExcessiveWithdrawals.db.guild][string.lower(val)]
		userName = userData.userName
		ExcessiveWithdrawals.db.userData[ExcessiveWithdrawals.db.guild][string.lower(val)] = nil
		CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. ' -- \nGuild bank history for ' .. userData.userName .. ' has been removed/reset.')
		return true
	end
	if string.find(key, "reset") then
		if string.find(val, "hist") then
			ExcessiveWithdrawals.db.userData = {}
			ExcessiveWithdrawals.db.lastScan = {}
			CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. ' -- \n Successfully reset all guild bank history.')
		else
			guildName = nil
			if tonumber(val) ~= nil then guildName = GetGuildName(val) end
			if ExcessiveWithdrawals.db.userData ~= nil then
				if guildName == nil or guildName == "" then
					CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. " -- \n |cFF0000ERROR: Guild number doesn't exist.")
					return true
				elseif ExcessiveWithdrawals.db.userData[guildName] == nil then
					CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. ' -- \n |cFF0000ERROR: No data was found for ' .. guildName .. '.')
					return true
				end
				ExcessiveWithdrawals.db.userData[guildName] = nil
				ExcessiveWithdrawals.db.lastScan[guildName] = nil
			end
			CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. ' -- \n Successfully reset guild bank history for ' .. guildName .. '.')
		end
		return true
	end
	return false
end

function ExcessiveWithdrawals:myExit() 
  --CHAT_SYSTEM:AddMessage("myExit Hooked Function - tmpAllowExit: "..tmpAllowExit)
  tmpBankOpen = false
  -- ADD CODE FOR NIL HANDLING
  if tmpAllowExit == 0 and ExcessiveWithdrawals.db.bankWarnRank > 0 and ExcessiveWithdrawals.db.bankWarnRank <= 10 then
    --CHAT_SYSTEM:AddMessage("myExit Hooked Function - if section")
    for rankCount=tonumber(ExcessiveWithdrawals.db.bankWarnRank),10 do
      --CHAT_SYSTEM:AddMessage("myExit Hooked Function - PermissionsLoop")
      if DoesGuildRankHavePermission(ExcessiveWithdrawals:GetGuilds(ExcessiveWithdrawals.db.guild), rankCount, 16) then
      --CHAT_SYSTEM:AddMessage("myExit Hooked Function - Bank Open") 
        tmpBankOpen = true
      end
    end
  end
  --CHAT_SYSTEM:AddMessage("myExit Hooked Function - if section, after for")
  if tmpBankOpen then
    --CHAT_SYSTEM:AddMessage("myExit Hooked Function - Show Warn UI")
    if ZO_Keybindings_GetHighestPriorityBindingStringFromAction("EXCESSIVE_EXIT_OVERIDE") ~= nil then  
      ExcessiveWithdrawalsOverideLabel:SetText("Overide Exit Keybind:   " .. ZO_Keybindings_GetHighestPriorityBindingStringFromAction("EXCESSIVE_EXIT_OVERIDE"))
    else
      ExcessiveWithdrawalsOverideLabel:SetText("Overide Exit Keybind: Not Set")
    end
      ExcessiveWithdrawalsWarn:SetHidden(false)
    return true
  else
    --CHAT_SYSTEM:AddMessage("myExit Hooked Function - Allow Exit!")
    tmpAllowExit = 1
    if ExcessiveWithdrawals.db.ExitMode == "ReloadUI" then 
      ReloadUI()
    elseif ExcessiveWithdrawals.db.ExitMode == "Logout" then 
      Logout()
    elseif ExcessiveWithdrawals.db.ExitMode == "Quit" then 
      Quit()
    end 
  end
end

function ExcessiveWithdrawals.Cmd(txt)
	if txt == "" then
		CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. ': type "/exwithdraw" for a list of commands.')
		return
	end
	arr = {}
	i = 1
	-- Experimental change due to account names with special characters
	--for val in string.gmatch(txt,"%w+") do
	for val in string.gmatch(txt,"[^%s|\@]+") do
		arr[i] = val
	    i = i + 1
	end
	if string.find(txt, "@") then arr[2] = "@" .. arr[2] end
	if ExcessiveWithdrawals:Commands(arr[1], arr[2]) == true then return end
	CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. ' -- \n |cFF0000ERROR: Chat command was not found.|r \nFor a list of commands, type: /exwithdraw')
end

local function PreHooks()
    -- Hook the game menus etc to Hide / Show
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnShow", function()
        ExcessiveWithdrawalsGUI:SetHidden(true)
    end)
    ZO_PreHookHandler(ZO_GameMenu_InGame, "OnHide", function()
      if ExcessiveWithdrawals.db.GUIshow == 1 then
        ExcessiveWithdrawalsGUI:SetHidden(false)
      end
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnShow", function()
        ExcessiveWithdrawalsGUI:SetHidden(true)
    end)
    ZO_PreHookHandler(ZO_InteractWindow, "OnHide", function()
      if ExcessiveWithdrawals.db.GUIshow == 1 then
        ExcessiveWithdrawalsGUI:SetHidden(false)
      end
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnShow", function()
        ExcessiveWithdrawalsGUI:SetHidden(true)
    end)
    ZO_PreHookHandler(ZO_KeybindStripControl, "OnHide", function()
      if ExcessiveWithdrawals.db.GUIshow == 1 then
        ExcessiveWithdrawalsGUI:SetHidden(false)
      end
    end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnShow", function()
        ExcessiveWithdrawalsGUI:SetHidden(true)
    end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar, "OnHide", function()
      if ExcessiveWithdrawals.db.GUIshow == 1 then
        ExcessiveWithdrawalsGUI:SetHidden(false)
      end
    end)
    ZO_PreHook("Logout", function()
      ExcessiveWithdrawals.db.ExitMode = "Logout"
      if tmpAllowExit == 0 then
        ExcessiveWithdrawals:myExit()
        return true
      end
    end)
    ZO_PreHook("Quit", function()
      ExcessiveWithdrawals.db.ExitMode = "Quit"
      if tmpAllowExit == 0 then
        ExcessiveWithdrawals:myExit()
        return true
      end
    end)
    ZO_PreHook("ReloadUI", function()
      ExcessiveWithdrawals.db.ExitMode = "ReloadUI"
      if tmpAllowExit == 0 then
        ExcessiveWithdrawals:myExit()
        return true
      end
    end)
     --[[
      ExcessiveWithdrawals.db.ExitMode = "Reloadui"
      CHAT_SYSTEM:AddMessage("ReloadUI Hooked Function - tmpAllowExit: "..tmpAllowExit)
      --Debug true, otherwise false for normal use
      tmpBankOpen = false
      if tmpAllowExit == 0 then
        CHAT_SYSTEM:AddMessage("ReloadUI Hooked Function - if section")
        --for rankCount=tonumber(self.db.bankWarnRank),10 do
        for rankCount=tonumber(ExcessiveWithdrawals.db.bankWarnRank),10 do
          CHAT_SYSTEM:AddMessage("ReloadUI Hooked Function - PermissionsLoop")
          if DoesGuildRankHavePermission(ExcessiveWithdrawals:GetGuilds(ExcessiveWithdrawals.db.guild), rankCount, 16) then
          --if DoesGuildRankHavePermission(2, rankCount, 16) then
            CHAT_SYSTEM:AddMessage("ReloadUI Hooked Function - Bank Open") 
            tmpBankOpen = true
          end
        end
        CHAT_SYSTEM:AddMessage("ReloadUI Hooked Function - if section, after for")
        if tmpBankOpen then
          CHAT_SYSTEM:AddMessage("ReloadUI Hooked Function - Show Warn UI")
          ExcessiveWithdrawalsWarn:SetHidden(false)
          ShowMouse(true)
          return true
        else
          CHAT_SYSTEM:AddMessage("ReloadUI Hooked Function - Allow Exit!")
          tmpAllowExit = 1
          ReloadUI()
        end
      end
      ]]--
  
    
    CHAMPION_PERKS_SCENE:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            ExcessiveWithdrawalsGUI:SetHidden(true)
        elseif newState == SCENE_HIDDEN then
          if ExcessiveWithdrawals.db.GUIshow == 1 then
            ExcessiveWithdrawalsGUI:SetHidden(false)
          end
        end
    end)
    --OnMinimize of the chat system
    --[[
    ZO_PreHook(CHAT_SYSTEM, "Minimize", function()
        if settings.repositionOnChatMinimize then
            --Reposition Regrouper
            zo_callLater(function() RepositionRegrouper() end, 250)
        end
    end)
    --OnMaximize of the chat system
    ZO_PreHook(CHAT_SYSTEM, "Maximize", function()
        --Reposition Regrouper
        zo_callLater(function() RepositionRegrouper() end, 250)
    end)
    ]]--
end

function ExcessiveWithdrawals.SetDynamicDimensions()
  -- Function to resize window based on number of users listed in GUI
  local strCount = 0
  for i in string.gfind(ExcessiveWithdrawalsGUILeft:GetText(), "\n") do
     strCount = strCount + 1
  end
  ExcessiveWithdrawalsGUI:SetDimensions(ExcessiveWithdrawals.db.SizeOffsetX,90 + strCount*25) -- 90 for header/footer + lines * 25 pixels  
end

function ExcessiveWithdrawals.OnAddOnLoaded(event, addon)
  ZO_CreateStringId("SI_BINDING_NAME_EXCESSIVE_HIDE_GUI", "Hide GUI")
  ZO_CreateStringId("SI_BINDING_NAME_EXCESSIVE_EXIT_OVERIDE", "Exit Overide")
 
	if addon ~= ExcessiveWithdrawals.name then return end
	ExcessiveWithdrawals.db = ZO_SavedVars:NewAccountWide("ExcessiveWithdrawals_Vars", 1, nil, ExcessiveWithdrawals.defaults)
	ExcessiveWithdrawals:Menu()
	SLASH_COMMANDS["/excessive"] = ExcessiveWithdrawals.Cmd
	if ExcessiveWithdrawals.db.warnings == false then
		if MasterMerchant == nil and TamrielTradeCentrePrice == nil then
			CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. " -- \n|cFF0000ERROR: Master Merchant and Tamriel Trade Centre addons were not found.|r\nDefault system prices will be used instead!")
		elseif MasterMerchant == nil then
			CHAT_SYSTEM:AddMessage(ExcessiveWithdrawals.displayName .. " -- \n|cFF0000Warning: Master Merchant addon was not found.|r\nPrices used for calculations may not reflect your current market value!")
		end
	end
	EVENT_MANAGER:UnregisterForEvent(ExcessiveWithdrawals.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForUpdate(ExcessiveWithdrawals.name, 30000, function() ExcessiveWithdrawals:MonitorGuild() end)
	
  ExcessiveWithdrawalsGUI:ClearAnchors()
  ExcessiveWithdrawalsGUI:SetAnchor(TOLEFT, GuiRoot, TOPLEFT, ExcessiveWithdrawals.db.PosOffsetX, ExcessiveWithdrawals.db.PosOffsetY)
  ExcessiveWithdrawalsGUI:SetDimensions(ExcessiveWithdrawals.db.SizeOffsetX,ExcessiveWithdrawals.db.SizeOffsetY)
  if ExcessiveWithdrawals.db.GUIshow == 1 then
    ExcessiveWithdrawalsGUI:SetHidden(false)
  else
    ExcessiveWithdrawalsGUI:SetHidden(true)
  end
  if ExcessiveWithdrawals.db.GUIopacity ~= nil then
   ExcessiveWithdrawalsGUI:SetAlpha(tonumber(ExcessiveWithdrawals.db.GUIopacity)/100)
  end
  
--[[
  ExcessiveWithdrawalsGUIFooter:SetText("Exit Mode: "..ExcessiveWithdrawals.db.ExitMode)  
  --Dumpout current permissions
  tmpRank = ZO_Object.New(ZO_GuildRank_Shared)
  tmpRank.guildId = 5
  tmpRank.name = GetFinalGuildRankName(tmpRank.guildId, 2) 
  tmpRank.iconIndex = GetGuildRankIconIndex(tmpRank.guildId, 2) 
  tmpRank.permissionSet = {} 
  for i = 1, GetNumGuildPermissions() do 
    tmpRank.permissionSet[i] = DoesGuildRankHavePermission(tmpRank.guildId, 2, i) 
  end
  --asign new permissions
  newPermissions = 0
  for i = 1, GetNumGuildPermissions() do
    if i == 16 then 
      newPermissions = ComposeGuildRankPermissions(newPermissions, i, false)
      --ExcessiveWithdrawalsGUIFooter:SetText("Permisison 16 set to false")    
    else 
      newPermissions = ComposeGuildRankPermissions(newPermissions, i, tmpRank.permissionSet[i])
    end
  end
  
  tmpAddResponse = AddPendingGuildRank(2, tmpRank.name, newPermissions, tmpRank.iconIndex)
  ExcessiveWithdrawalsGUIFooter:SetText("Added pend rank.")
  
  ExcessiveWithdrawalsGUIFooter:SetText("About to init pend rank.")
  tmpInitResponse = InitializePendingGuildRanks(5)
  ExcessiveWithdrawalsGUIFooter:SetText("Init pend rank done.")
  
  tmpSaveResponse = SavePendingGuildRanks()
  ExcessiveWithdrawalsGUIFooter:SetText("Saved pend rank.")
  ExcessiveWithdrawalsGUIFooter:SetText("tmpInitResponse: "..tostring(tmpInitResponse).."\ntmpAddResponse: "..tostring(tmpAddResponse).."\ntmpSaveResponse: "..tostring(tmpSaveResponse).."\nNew Permissions: "..newPermissions.."\nExit Mode: "..ExcessiveWithdrawals.db.ExitMode)
   
    
  --CHAT_SYSTEM:AddMessage(tmpRank)
  --ExcessiveWithdrawalsGUIFooter:SetText("tmpRank.name: "..tmpRank.name)  
  ]]--
  
  ExcessiveWithdrawals.db.ExitMode = ""
  tmpAllowExit = 0
  tmpBankOpen = false
  PreHooks()
end

--function ExcessiveWithdrawals.UpdatePermissions()
--  rank = ZO_Object.New(ZO_GuildRank_Shared) rank.name = GetFinalGuildRankName(9, 2) rank.id = 6 rank.iconIndex = GetGuildRankIconIndex(9, 2) rank.permissionSet = {} for i = 1, GetNumGuildPermissions() do rank.permissionSet[i] = DoesGuildRankHavePermission(9, 2, i) end d(rank)
--end

function ExcessiveWithdrawals.SaveLoc()
  ExcessiveWithdrawals.db.SizeOffsetX = ExcessiveWithdrawalsGUI:GetRight() - ExcessiveWithdrawalsGUI:GetLeft() 
  ExcessiveWithdrawals.db.SizeOffsetY = ExcessiveWithdrawalsGUI:GetBottom() - ExcessiveWithdrawalsGUI:GetTop() 
	ExcessiveWithdrawals.db.PosOffsetX = ExcessiveWithdrawalsGUI:GetLeft()
	ExcessiveWithdrawals.db.PosOffsetY = ExcessiveWithdrawalsGUI:GetTop()
	--CHAT_SYSTEM:AddMessage("Saving location of ExcessiveWithdrawals GUI - Width: " .. ExcessiveWithdrawals.db.SizeOffsetX .. " Height: " .. ExcessiveWithdrawals.db.SizeOffsetY .. " PosXOffset: " .. ExcessiveWithdrawals.db.PosOffsetX .. " PosYOffset: " .. ExcessiveWithdrawals.db.PosOffsetY)
end

EVENT_MANAGER:RegisterForEvent(ExcessiveWithdrawals.name, EVENT_ADD_ON_LOADED, ExcessiveWithdrawals.OnAddOnLoaded)



--/script d(GetGuildRankCustomName(3, 8)) -- returns "New and Fail safe"
-- /script rankcount=GetNumGuildRanks(3) d(rankcount) d(DoesGuildRankHavePermission(3, 8, 12))
--/script guild=3 rank=8 for count=1,GetNumGuildPermissions(guild,rank) do d(count,DoesGuildRankHavePermission(guild, rank, count)) end

--/script guild=3 rank=7 d(GetGuildName(guild)) for count=1,GetNumGuildPermissions(guild,rank) do d(count,GetString("SI_GUILDPERMISSION", count),DoesGuildRankHavePermission(guild, rank, count),"\n") end

--/script for i=1,GetNumGuilds() do d("Counter: "..i.." - "..GetGuildName(GetGuildId(i)).." Id: "..GetGuildId(i)) end
--/script guild=5 rank=2 d(GetGuildName(guild)) for count=1,GetNumGuildPermissions(guild,rank) do d("Permission Number: "..count.."    Permission Name: "..GetString("SI_GUILDPERMISSION", count).."   Permission Granted: "..tostring(DoesGuildRankHavePermission(guild, rank, count))) end


-- Withdraw from guild bank is permission 16 

--[[


        rank.id = GetGuildRankId(guildId, index)
        rank.name = GetFinalGuildRankName(guildId, index)
        rank.hasCustomName = GetGuildRankCustomName(guildId, index) ~= ""
        rank.iconIndex = GetGuildRankIconIndex(guildId, index)
        for i = 1, GetNumGuildPermissions() do
            rank.permissionSet[i] = DoesGuildRankHavePermission(guildId, index, i)
        end
        

function ZO_GuildRank_Shared:GetPermissions()
    local permissions = 0
    for i = 1, #self.permissionSet do
        permissions = ComposeGuildRankPermissions(permissions, i, self.permissionSet[i])
    end
    return permissions
end

function ZO_GuildRank_Shared:Save()
    --                    2    ,  Rank2 ,   ,
    AddPendingGuildRank(self.id, self:GetSaveName(), self:GetPermissions(), self.iconIndex)
end



Working
/script local rank = ZO_Object.New(ZO_GuildRank_Shared) rank.name = GetFinalGuildRankName(9, 2) rank.id = 6 rank.iconIndex = GetGuildRankIconIndex(9, 2) rank.permissionSet = {} for i = 1, GetNumGuildPermissions() do rank.permissionSet[i] = DoesGuildRankHavePermission(9, 2, i) end d(rank)

]]--



--/script ExcessiveWithdrawalsWarn:SetHidden(false) abcd = {ZO_GamepadOptions:GetButtonTextureInfoFromActionName(EXCESSIVE_EXIT_OVERIDE)} d(abcd[1]) ExcessiveWithdrawalsButtonClose:SetNormalTexture(abcd[1])

--/script d(ZO_Keybindings_GetHighestPriorityBindingStringFromAction("EXCESSIVE_EXIT_OVERIDE")) 
--/script ExcessiveWithdrawalsWarn:SetHidden(false) ExcessiveWithdrawalsOverideLabel:SetText(ZO_Keybindings_GetHighestPriorityBindingStringFromAction("EXCESSIVE_EXIT_OVERIDE"))
--ExcessiveWithdrawalsOverideLabel

--/script ExcessiveWithdrawalsOverideLabel:SetText("Overide Exit Keybind: " .. ZO_Keybindings_GetHighestPriorityBindingStringFromAction("EXCESSIVE_EXIT_OVERIDE")) ExcessiveWithdrawalsWarn:SetHidden(false)