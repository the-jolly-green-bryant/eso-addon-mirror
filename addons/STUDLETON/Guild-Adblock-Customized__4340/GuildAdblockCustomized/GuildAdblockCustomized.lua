local namespace = "GuildAdblockCustomized"
local savedVariables, guildInput, selectedGuild
local guildIds = {}
local playerName = GetDisplayName()

local function registerGuildInviteHandler()
	EVENT_MANAGER:RegisterForEvent(namespace, EVENT_GUILD_INVITE_ADDED, function(_, guildId, guildName, _)
		for guild, ids in pairs(guildIds) do
			for _, id in ipairs(ids) do
				if tostring(guildId) == tostring(id) then
					RejectGuildInvite(guildId)
					d("Blocked Guild Invite |H1:guild:" .. tostring(guildId) .. "|h" .. guildName .. "|h")
					return
				end
			end
		end
		d("Received guild invite from |H1:guild:" .. tostring(guildId) .. "|h" .. guildName .. "|h")
	end)
end

local recommendedGuilds = {
	"|H1:guild:625833|hThe Trading Council|h",
	"|H1:guild:866125|hThe Training Council|h",
	"|H1:guild:554617|hThe Gaming Council|h",
	"|H1:guild:679413|hThe Gaming Council II|h",
	"|H1:guild:699213|hThe Gaming Council III|h",
	"|H1:guild:753143|hThe Gaming Council IV|h",
	"|H1:guild:918623|hThe Gaming Council V|h",
}

EVENT_MANAGER:RegisterForEvent(namespace, EVENT_ADD_ON_LOADED, function(_, addonName)
	if(addonName ~= namespace) then return end
	
	savedVariables = ZO_SavedVars:NewAccountWide(namespace .. "Vars", 1, nil, {
		enabledAdBlock = true,
		enabledInviteDecline = true,
		notify = true,
		notifyGuild = true,
		isloggingBlocks = true,
		isloggingAds = true,
		logRetention = false,
		blockLog = {},
		adLog = {},
		guilds = {},
		firstStart = true,
		posTop = nil,
		posLeft = nil,
	})
	
	if savedVariables.firstStart then
		if GetWorldName() == "NA Megaserver" then
			for _, guild in ipairs(recommendedGuilds) do
				table.insert(savedVariables.guilds, guild)
			end
		end
		savedVariables.firstStart = false
	end
	
	local function updateGuildLists()
		GuildList:UpdateValue()
		local control = GetControl("GuildDropdown")
		control:UpdateChoices(savedVariables.guilds)
		control.dropdown:SetSelectedItem(nil)
	end
	
	local function isGuildBlocked(guild)
		for _, blockedGuild in ipairs(savedVariables.guilds) do
			if guild == blockedGuild then return true end
		end
		return false
	end

	local function saveGuildIds(guildLink)
		local ids = {}
		for id in guildLink:gmatch("%:guild:(%d+)%|") do
			table.insert(ids, id)
		end
		guildIds[guildLink] = ids
	end
	
	for _, guildLink in ipairs(savedVariables.guilds) do
		saveGuildIds(guildLink)
	end
	
	local function clearExpiredLog(log)
		local cutoff = GetTimeStamp() - savedVariables.logRetention
		while log[1] and log[1][2] < cutoff do
			table.remove(log, 1)
		end
	end
	if savedVariables.logRetention then
		clearExpiredLog(savedVariables.adLog)
		clearExpiredLog(savedVariables.blockLog)
	end
	
	GuildAdblockCustomized:SetHandler("OnMoveStop", function()
		savedVariables.posTop = GuildAdblockCustomized:GetTop()
		savedVariables.posLeft = GuildAdblockCustomized:GetLeft()
	end)
	
	if savedVariables.posTop and savedVariables.posLeft then
		GuildAdblockCustomized:ClearAnchors()
		GuildAdblockCustomized:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, savedVariables.posLeft, savedVariables.posTop )
	end
	
	local function OnRowSetup(rowControl, data, scrollList)
		rowControl:SetFont("ZoFontGame")
		rowControl:SetMaxLineCount(1)
		rowControl:SetText(data.text)
		rowControl:SetHandler("OnMouseUp", function(control)
			ClearMenu()

			AddMenuItem("Link in Chat", function()
				CHAT_SYSTEM.textEntry:InsertLink(data.guild)
			end, MENU_ADD_OPTION_LABEL )

			-- CUSTOM CODE
			AddMenuItem("View Guild", function()
				LINK_HANDLER:FireCallbacks(LINK_HANDLER.LINK_CLICKED_EVENT, data.guild, MOUSE_BUTTON_INDEX_LEFT, ZO_LinkHandler_ParseLink(data.guild))
			end, MENU_ADD_OPTION_LABEL )

			ShowMenu( control, 2, MENU_TYPE_COMBO_BOX )
			SetMenuPad( 100 )
		end)
	end
	ZO_ScrollList_AddDataType(GuildAdblockCustomizedList, 1, "ZO_SelectableLabel", 30, OnRowSetup, nil, nil, nil)
		
	local panelConfig = {
		type = "panel",
		name = "Guild Adblock Customized",
		author = "@STUDLETON",
		version = "1.0.2",
		registerForRefresh = true,
	}
	
	local optionsConfig = {
		{
			type = "checkbox",
			name = "Enable Ad Message Blocking",
			tooltip = "Enable ad blocking guilds in the block list",
			getFunc = function() return savedVariables.enabledAdBlock end,
			setFunc = function(value) savedVariables.enabledAdBlock = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = "Enable Guild Invite Blocking",
			tooltip = "Enable auto guild invite decline for guilds in the block list",
			getFunc = function() return savedVariables.enabledInviteDecline end,
			setFunc = function(value) 
				savedVariables.enabledInviteDecline = value
				if value then
					registerGuildInviteHandler()
				else
					EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_GUILD_INVITE_ADDED)
				end
			end,
			width = "half",
		},
		{
			type = "checkbox",
			name = "Notify",
			tooltip = "Send \"Blocked Message\" in chat when a message is blocked",
			getFunc = function() return savedVariables.notify end,
			setFunc = function(value) savedVariables.notify = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = "Show guild",
			tooltip = "Send \"Blocked Message: [Guild: Zone Spammers]\" in chat when a message is blocked",
			getFunc = function() return savedVariables.notifyGuild end,
			setFunc = function(value) savedVariables.notifyGuild = value end,
			disabled = function() return not savedVariables.notify end,
			width = "half",
		},
		{
			type = "header",
			name = "Logging",
		},
		{
			type = "description",
			text = "View with /gabc. Log guild ads if you'd like to check how much they're spamming you.",
		},
		{
			type = "checkbox",
			name = "Save Block Log",
			tooltip = "Log blocked ads",
			getFunc = function() return savedVariables.isloggingBlocks end,
			setFunc = function(value) savedVariables.isloggingBlocks = value end,
			width = "half",
		},
		{
			type = "checkbox",
			name = "Save Ad Log",
			tooltip = "Log all guild ads to see block candidates",
			getFunc = function() return savedVariables.isloggingAds end,
			setFunc = function(value) savedVariables.isloggingAds = value end,
			width = "half",
		},
		{
			type = "dropdown",
			name = "Log Retention",
			tooltip = "How long you want a logged ad to be retained",
			choices = {"Indefinite", "1 year", "6 months", "3 months", "1 month", "1 week", "1 day"},
			choicesValues = {false, 31556926, 15778458, 7889229, 2629743, 604800, 86400}, 
			getFunc = function() return savedVariables.logRetention end,
			setFunc = function(value) savedVariables.logRetention = value end,
			disabled = function() return not (savedVariables.isloggingBlocks or savedVariables.isloggingAds) end,
			width = "half",
		},
		{
			type = "button",
			name = "Clear Log",
			tooltip = "Clears all logs. Use the Log Retention setting to only clear old logs.",
			func = function()
				savedVariables.blockLog = {}
				savedVariables.adLog = {}
			end,
			isDangerous = true,
			width = "half",
		},
		{
			type = "header",
			name = "Block List",
		},
		{
			type = "description",
			text = "You can easily copy the link to a guild you want to block by right-clicking it from a recent unwanted ad, clicking \"Link in Chat\" and then copying it from your own chat box.",
		},
		{
			type = "editbox",
			name = "New guild link",
			tooltip = "Paste the link to a guild you want to block from zone chat",
			getFunc = function() return guildInput or "" end,
			setFunc = function(value) guildInput = value end,
			isMultiline = false,
			width = "half",
		},
		{
			type = "button",
			name = "Add",
			tooltip = "Add to block list",
			func = function()
				if guildInput and zo_strfind(guildInput, ":guild:") then
					saveGuildIds(guildInput)
					if #guildInput > 58 then
						local hasSuffix = guildInput:sub(-2) == "|h"
						guildInput = guildInput:sub(1, hasSuffix and 56 or 58) .. (hasSuffix and "|h" or "")
					end
					if not isGuildBlocked(guildInput) then
						table.insert(savedVariables.guilds, guildInput)
					end
					guildInput = nil
					updateGuildLists()
				end
			end,
			width = "half",
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
		},
		{
			type = "dropdown",
			tooltip = "Select a guild from block list to remove or link",
			choices = savedVariables.guilds,
			getFunc = function() return selectedGuild end,
			setFunc = function(value) selectedGuild = value end,
			reference = "GuildDropdown",
			width = "half",
		},
		{
			type = "button",
			name = "Remove",
			tooltip = "Remove selected guild from block list",
			func = function()
				if selectedGuild then
					for i, guild in ipairs(savedVariables.guilds) do
						if guild == selectedGuild then
							table.remove(savedVariables.guilds, i)
							guildIds[guild] = nil
							selectedGuild = nil
							updateGuildLists()
							return
						end
					end
				end
			end,
			width = "half",
		},
		{
			type = "divider",
			height = 15,
			alpha = 0,
			width = "half",
		},
		{
			type = "button",
			name = "Link In Chat",
			tooltip = "Puts the selected guild in your chat box to copy or share",
			func = function()
				if selectedGuild then
					CHAT_SYSTEM.textEntry:InsertLink(selectedGuild)
				end
			end,
			width = "half",
		},
		{
			type = "description",
			title = "Blocked Guilds",
			text = function() return table.concat(savedVariables.guilds, "\n") end,
			reference = "GuildList"
		}
	}
	
	if GetWorldName() == "NA Megaserver" then
		table.insert(optionsConfig, 13, {
			type = "button",
			name = "Add recommended guilds",
			tooltip = "On PCNA these guilds are known to spam ads and invites. v1.0.2 adds more TGC subguilds not originally preloaded",
			func = function()
				for _, guild in ipairs(recommendedGuilds) do
					if not isGuildBlocked(guild) then
						table.insert(savedVariables.guilds, guild)
						saveGuildIds(guild)
						updateGuildLists()
					end
				end
			end,
		})
	end
	
	LibAddonMenu2:RegisterAddonPanel(namespace .. "Settings", panelConfig)
	LibAddonMenu2:RegisterOptionControls(namespace .. "Settings", optionsConfig)
	
	if savedVariables.enabledInviteDecline then registerGuildInviteHandler() end
	
	ZO_PreHook(CHAT_ROUTER, "FormatAndAddChatMessage", function(self, eventKey, ...)
		if eventKey == EVENT_CHAT_MESSAGE_CHANNEL and savedVariables.enabledAdBlock then
			local messageType, _, rawMessageText, _, fromDisplayName = select(1, ...)
			if messageType == CHAT_CHANNEL_ZONE and fromDisplayName ~= playerName and rawMessageText:match("|[Hh]1:guild:%d+|[Hh].-|[Hh]") then
				if savedVariables.isloggingAds then
					for guild in rawMessageText:gmatch("|[Hh]1:guild:%d+|[Hh].-|[Hh]") do
					   table.insert(savedVariables.adLog, {guild, GetTimeStamp()})
					end
				end
				for guild, searchStrings in pairs(guildIds) do
					for _, searchString in ipairs(searchStrings) do
						if zo_strfind(rawMessageText, searchString) then
							if savedVariables.notify then
								if savedVariables.notifyGuild then
									d("Blocked Advertisement " .. guild)
								else
									d("Blocked Advertisement")
								end
							end
							if savedVariables.isloggingBlocks then
								table.insert(savedVariables.blockLog, {guild, GetTimeStamp()})
							end
							
							return true
						end
					end
				end
			end
		end
		return false
	end)
	
	SLASH_COMMANDS["/gabc"] = function()
		GuildAdblockCustomized:SetHidden(false)
		
		local dataList = ZO_ScrollList_GetDataList(GuildAdblockCustomizedList)
		local blockHistoryList = {}
		local blockCountList = {}
		local adHistoryList = {}
		local adCountList = {}
		local activeButton = GuildAdblockCustomizedBlockHistoryButton
		local activeList = blockHistoryList
		local timeFilter = nil
		
		local function setButtonActive(button)
			local buttonBg = button:GetNamedChild("BG")
			buttonBg:SetCenterColor(0.3,0.3,0.5)
			buttonBg:SetEdgeColor(0.3,0.3,0.5)
			button:GetNamedChild("Label"):SetColor(1,1,1)
		end
		local function setButtonInactive(button)
			local buttonBg = button:GetNamedChild("BG")
			buttonBg:SetCenterColor(0.2,0.2,0.2)
			buttonBg:SetEdgeColor(0.2,0.2,0.2)
			button:GetNamedChild("Label"):SetColor(0.7,0.7,0.7)
		end
		setButtonActive(GuildAdblockCustomizedBlockHistoryButton)
		setButtonInactive(GuildAdblockCustomizedBlockCountButton)
		setButtonInactive(GuildAdblockCustomizedAdHistoryButton)
		setButtonInactive(GuildAdblockCustomizedAdCountButton)
		
		local function populateList()
			ZO_ClearNumericallyIndexedTable(dataList)
			for _, listEntry in ipairs(activeList) do
				table.insert(dataList, listEntry)
			end
			ZO_ScrollList_Commit(GuildAdblockCustomizedList)
		end
		local function showTab(button, list)
			setButtonInactive(activeButton)
			setButtonActive(button)
			activeButton = button
			activeList = list
			populateList()
		end
		local function clearTable(t)
			for k in pairs(t) do
				t[k] = nil
			end
		end
		
		local function generateTimedLists()
			clearTable(blockHistoryList)
			clearTable(blockCountList)
			clearTable(adHistoryList)
			clearTable(adCountList)
			
			local countMap = {}
			
			for i = #savedVariables.blockLog, 1, -1 do
				local guild, timestamp = unpack(savedVariables.blockLog[i])
				if timeFilter and timestamp < timeFilter then break end
				local text = os.date("%d %b %y %H:%M:%S", timestamp) .. " " .. guild
				table.insert(blockHistoryList, ZO_ScrollList_CreateDataEntry(1, {text = text, guild = guild, timestamp = timestamp, index = i}))
				if not countMap[guild] then
					countMap[guild] = 1
				else
					countMap[guild] = countMap[guild] + 1
				end
			end
			for guild, count in pairs(countMap) do
				local text = guild .. " - " .. count
				table.insert(blockCountList, ZO_ScrollList_CreateDataEntry(1, {text = text, guild = guild, count = count, index = i}))
			end
			table.sort(blockCountList, function(a, b) return a.data.count > b.data.count end)
			for i, entry in ipairs(blockCountList) do entry.data.text = tostring(i) .. ". " .. entry.data.text end
			
			countMap = {}
			for i = #savedVariables.adLog, 1, -1 do
				local guild, timestamp = unpack(savedVariables.adLog[i])
				if timeFilter and timestamp < timeFilter then break end
				local text = os.date("%d %b %y %H:%M:%S", timestamp) .. " " .. guild
				table.insert(adHistoryList, ZO_ScrollList_CreateDataEntry(1, {text = text, guild = guild, timestamp = timestamp, index = i}))
				if not countMap[guild] then
					countMap[guild] = 1
				else
					countMap[guild] = countMap[guild] + 1
				end
			end
			for guild, count in pairs(countMap) do
				local text = guild .. " - " .. count
				table.insert(adCountList, ZO_ScrollList_CreateDataEntry(1, {text = text, guild = guild, count = count, index = i}))
			end
			table.sort(adCountList, function(a, b) return a.data.count > b.data.count end)
			for i, entry in ipairs(adCountList) do entry.data.text = tostring(i) .. ". " .. entry.data.text end
			
			populateList()
		end
		generateTimedLists()
		activeList = blockHistoryList
		
		GuildAdblockCustomizedBlockHistoryButton:SetHandler("OnMouseDown", function()
			showTab(GuildAdblockCustomizedBlockHistoryButton, blockHistoryList)
		end)
		
		GuildAdblockCustomizedBlockCountButton:SetHandler("OnMouseDown", function()
			showTab(GuildAdblockCustomizedBlockCountButton, blockCountList)
		end)
		
		GuildAdblockCustomizedAdHistoryButton:SetHandler("OnMouseDown", function()
			showTab(GuildAdblockCustomizedAdHistoryButton, adHistoryList)
		end)
		
		GuildAdblockCustomizedAdCountButton:SetHandler("OnMouseDown", function()
			showTab(GuildAdblockCustomizedAdCountButton, adCountList)
		end)
		
		local now = GetTimeStamp()
		GuildAdblockCustomizedSliderContainerSlider:SetMinMax(0, 17078463)
		GuildAdblockCustomizedSliderContainerSlider:SetHandler("OnValueChanged", function(_, offset)
			local time = now - offset
			if offset > 7889231 then time = time - ((offset-7889231)) end
			if offset > 11833846 then time = time - ((offset-11833846)) end
			
			
            GuildAdblockCustomizedSliderContainerSliderLabel:SetText(os.date("%d %b %y %H:%M:%S", time))
			timeFilter = time
        end)
		GuildAdblockCustomizedSliderContainerSlider:SetValue(17078463)
		GuildAdblockCustomizedSliderContainerSlider:SetHandler("OnSliderReleased", function()
			generateTimedLists()
		end)
	end
	
	EVENT_MANAGER:UnregisterForEvent(namespace, EVENT_ADD_ON_LOADED)	
end)
