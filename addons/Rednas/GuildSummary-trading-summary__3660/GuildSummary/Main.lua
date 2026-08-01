GuildSummary = GuildSummary or {}
local GS = GuildSummary

GS.isDiscordOutput = false

GS.listenerActive = {}
GS.listenerActive[1] = false
GS.listenerActive[2] = false
GS.listenerActive[3] = false
GS.listenerActive[4] = false
GS.listenerActive[5] = false 

GS.saleItems = {}

GS.summary = {}

GS.amountHighestPriceSingleItemLines = 5
GS.amountTotalPriceLines = 10
GS.amountMostSoldLines = 10

GS.outputStrings = {}
GS.outputStrings.HighestPriceSingleItemHeader = {}
GS.outputStrings.HighestPriceSingleItemHeader.basic		= "\nItems sold with the highest price:\n"
GS.outputStrings.HighestPriceSingleItemHeader.discord 	= "\n**__Items sold with the highest price:__**\n"
GS.outputStrings.HighestPriceSingleItem = {}
GS.outputStrings.HighestPriceSingleItem.basic		= "%s%s. %s sold for %s (%s%%)\n"
GS.outputStrings.HighestPriceSingleItem.discord 	= "%s> %s. **%s** sold for %s (%s%%)\n"
GS.outputStrings.MostSoldHeader = {}
GS.outputStrings.MostSoldHeader.basic		= "\nMost sold (quantity):\n"
GS.outputStrings.MostSoldHeader.discord 	= "\n**__Most sold (quantity):__**\n"
GS.outputStrings.MostSold = {}
GS.outputStrings.MostSold.basic		= "%s%s. %s %sx (%s%%), %s sales (%s%%)\n"
GS.outputStrings.MostSold.discord 	= "%s> %s. **%s** %sx (%s%%), %s sales (%s%%)\n"
GS.outputStrings.TotalPriceHeader = {}
GS.outputStrings.TotalPriceHeader.basic		= "\nMost sold (total gold price):\n"
GS.outputStrings.TotalPriceHeader.discord 	= "\n**__Most sold (total gold price):__**\n"
GS.outputStrings.TotalPrice = {}
GS.outputStrings.TotalPrice.basic		= "%s%s. %s %sg (%s%%), %s sales (%s%%)\n"
GS.outputStrings.TotalPrice.discord 	= "%s> %s. **%s** %sg (%s%%), %s sales (%s%%)\n"

GS.outputStrings.GenericSummary = {}
GS.outputStrings.GenericSummary.basic 		= "Generic summary:\n"
GS.outputStrings.GenericSummary.discord 	= "**__Generic summary:__**\n"
GS.outputStrings.TotalSales = {}
GS.outputStrings.TotalSales.basic		= "%s- %s sales\n"
GS.outputStrings.TotalSales.discord 	= "%s> - **%s** sales\n"
GS.outputStrings.TotalItemsSold = {}
GS.outputStrings.TotalItemsSold.basic		= "%s- %s items sold\n"
GS.outputStrings.TotalItemsSold.discord 	= "%s> - **%s** items sold\n"
GS.outputStrings.TotalGoldSold = {}
GS.outputStrings.TotalGoldSold.basic		= "%s- sold for %s gold\n"
GS.outputStrings.TotalGoldSold.discord 		= "%s> - sold for **%s** gold\n"
GS.outputStrings.UniqueItemsSold = {}
GS.outputStrings.UniqueItemsSold.basic		= "%s- %s unique items sold\n"
GS.outputStrings.UniqueItemsSold.discord 	= "%s> - **%s** unique items sold\n"

GS.guildOptions = {
			[1] = {name = "All guilds"	, value = 0},
}
GS.timeRangeOptions = {
			[1] = {name = "Past trading week"	, value = 0},
			[2] = {name = "Past month"	, value = 1},
}
GS.formatOptions = {
			[1] = {name = "Basic format", callback = function() GS.isDiscordOutput = false end},
			[2] = {name = "Discord format", callback = function() GS.isDiscordOutput = true end},
}
GS.mostSoldOptions = {
			[1] = {name = "Most Sold: Disable"		, callback = function() GS.amountMostSoldLines = 0 end},
			[2] = {name = "Most Sold: Show top 5"	, callback = function() GS.amountMostSoldLines = 5 end},
			[3] = {name = "Most Sold: Show top 10"	, callback = function() GS.amountMostSoldLines = 10 end},
			[4] = {name = "Most Sold: Show top 15"	, callback = function() GS.amountMostSoldLines = 15 end},
			[5] = {name = "Most Sold: Show top 20"	, callback = function() GS.amountMostSoldLines = 20 end},
			[6] = {name = "Most Sold: Show top 25"	, callback = function() GS.amountMostSoldLines = 25 end},
			[7] = {name = "Most Sold: Show top 50"	, callback = function() GS.amountMostSoldLines = 50 end},
}
GS.totalPriceOptions = {
			[1] = {name = "Total price: Disable"		, callback = function() GS.amountTotalPriceLines = 0 end},
			[2] = {name = "Total price: Show top 5"		, callback = function() GS.amountTotalPriceLines = 5 end},
			[3] = {name = "Total price: Show top 10"	, callback = function() GS.amountTotalPriceLines = 10 end},
			[4] = {name = "Total price: Show top 15"	, callback = function() GS.amountTotalPriceLines = 15 end},
			[5] = {name = "Total price: Show top 20"	, callback = function() GS.amountTotalPriceLines = 20 end},
			[6] = {name = "Total price: Show top 25"	, callback = function() GS.amountTotalPriceLines = 25 end},
			[7] = {name = "Total price: Show top 50"	, callback = function() GS.amountTotalPriceLines = 50 end},
}
GS.highestPriceSingleItemOptions = {
			[1] = {name = "Highest price: Disable"		, callback = function() GS.amountHighestPriceSingleItemLines = 0 end},
			[2] = {name = "Highest price: Show top 5"	, callback = function() GS.amountHighestPriceSingleItemLines = 5 end},
			[3] = {name = "Highest price: Show top 10"	, callback = function() GS.amountHighestPriceSingleItemLines = 10 end},
			[4] = {name = "Highest price: Show top 15"	, callback = function() GS.amountHighestPriceSingleItemLines = 15 end},
			[5] = {name = "Highest price: Show top 20"	, callback = function() GS.amountHighestPriceSingleItemLines = 20 end},
			[6] = {name = "Highest price: Show top 25"	, callback = function() GS.amountHighestPriceSingleItemLines = 25 end},
			[7] = {name = "Highest price: Show top 50"	, callback = function() GS.amountHighestPriceSingleItemLines = 50 end},
}

local function findInTable(table, value)
  if type(table[1]) == "table" and type(value) ~= "function" then return -1 end

  for i, v in ipairs(table) do
    if type(value) == "function" then
      if value(i, v) then return i end
    else 
      if table[i] == value then return i end
    end
  end

  return -1
end

function GuildSummary.ToggleGUI()
	SCENE_MANAGER:ToggleTopLevel(GuildSummary_GUI)
end

function GuildSummary.SetupEmptySummaryVars()
	GS.summary.startDate = ""
	GS.summary.endDate = ""
	GS.summary.totalSales = 0
	GS.summary.totalGoldSold = 0
	GS.summary.totalItemsSold = 0
end

function GuildSummary.Initialize()
	SCENE_MANAGER:RegisterTopLevel(GuildSummary_GUI, locksUIMode)
	
	--Set options for guild names
	for i = 1, GetNumGuilds() do
		GS.guildOptions[i+1] = {name = GetGuildName(GetGuildId(i)), value = i}
	end
	
	--Fill dropdown for guilds
	for k,option in ipairs(GS.guildOptions) do
		local itemData = option
		--itemData.callback = nil
		GuildSummary_GUISettingsComboboxGuilds.m_comboBox:AddItem(itemData, ZO_COMBOBOX_SUPRESS_UPDATE)
	end
    GuildSummary_GUISettingsComboboxGuilds.m_comboBox:SelectItem(GS.guildOptions[1], true)
	
	--fill dropdown for timerange
	for k,option in ipairs(GS.timeRangeOptions) do
		local itemData = option
		--itemData.callback = nil
		GuildSummary_GUISettingsComboboxTimeRange.m_comboBox:AddItem(itemData, ZO_COMBOBOX_SUPRESS_UPDATE)
	end
    GuildSummary_GUISettingsComboboxTimeRange.m_comboBox:SelectItem(GS.timeRangeOptions[1], true)
	
	--fill dropdown for format
	for k,option in ipairs(GS.formatOptions) do
		local itemData = option
		GuildSummary_GUISettingsComboboxFormat.m_comboBox:AddItem(itemData, ZO_COMBOBOX_SUPRESS_UPDATE)
	end
    GuildSummary_GUISettingsComboboxFormat.m_comboBox:SelectItem(GS.formatOptions[1], true)
	
	--fill dropdown for MostSold
	for k,option in ipairs(GS.mostSoldOptions) do
		local itemData = option
		GuildSummary_GUISettingsComboboxMostSold.m_comboBox:AddItem(itemData, ZO_COMBOBOX_SUPRESS_UPDATE)
	end
    GuildSummary_GUISettingsComboboxMostSold.m_comboBox:SelectItem(GS.mostSoldOptions[3], true)
	
	--fill dropdown for highestPriceSingleItem
	for k,option in ipairs(GS.highestPriceSingleItemOptions) do
		local itemData = option
		GuildSummary_GUISettingsComboboxHighestPriceSingleItem.m_comboBox:AddItem(itemData, ZO_COMBOBOX_SUPRESS_UPDATE)
	end
    GuildSummary_GUISettingsComboboxHighestPriceSingleItem.m_comboBox:SelectItem(GS.highestPriceSingleItemOptions[2], true)
	
	--fill dropdown for highestPriceSingleItem
	for k,option in ipairs(GS.totalPriceOptions) do
		local itemData = option
		GuildSummary_GUISettingsComboboxTotalPrice.m_comboBox:AddItem(itemData, ZO_COMBOBOX_SUPRESS_UPDATE)
	end
    GuildSummary_GUISettingsComboboxTotalPrice.m_comboBox:SelectItem(GS.totalPriceOptions[3], true)
	
end

function GuildSummary.OnAddOnLoaded(event, addonName)
  if addonName == "GuildSummary" then
    EVENT_MANAGER:UnregisterForEvent("Guild Summary", EVENT_ADD_ON_LOADED)
    GS.Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent("Guild Summary", EVENT_ADD_ON_LOADED, GS.OnAddOnLoaded)

SLASH_COMMANDS["/guildsummary"] = GS.ToggleGUI

function GuildSummary.SetUpListners()
	local function SetUpListener(num, guildId, category)
		local listener = LibHistoire:CreateGuildHistoryListener(guildId, category)
		listener:SetStopOnLastEvent(true)
		
		local minTime, maxTime = GS.GetMinMaxTime()
		listener:SetTimeFrame(minTime, maxTime)
		GS.summary.startDate = os.date("%c", minTime)
		GS.summary.endDate = os.date("%c", maxTime)
	
		listener:SetEventCallback(function(eventType, eventId, eventTime, param1, param2, param3, param4, param5, param6)
			-- the events received by this callback are in the correct historic order
			-- Param1 = Seller
			-- Param2 = Buyer
			-- Param3 = aantal verkocht
			-- Param4 = Wat (itemLink)
			-- Param5 = voor hoeveel / Prijs
			-- Param6 = tax
			
			if eventType == GUILD_EVENT_ITEM_SOLD then
				local itemName = zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(param4))
				local singlePrice = param5/param3
				local tablePosition = findInTable(GS.saleItems, function(i, v) if v.name == itemName then return true end end)
				if tablePosition == -1 then
					table.insert(GS.saleItems, {
						name = itemName,
						quantitySold = param3,
						totalPrice = param5,
						highestPriceSingleItem = singlePrice,
						amountOfSales = 1
					})
				else
					GS.saleItems[tablePosition].quantitySold = GS.saleItems[tablePosition].quantitySold + param3
					GS.saleItems[tablePosition].totalPrice = GS.saleItems[tablePosition].totalPrice + param5
					GS.saleItems[tablePosition].amountOfSales = GS.saleItems[tablePosition].amountOfSales + 1
					
					if singlePrice > GS.saleItems[tablePosition].highestPriceSingleItem then
						GS.saleItems[tablePosition].highestPriceSingleItem = singlePrice
					end
				end
								
				GS.summary.totalSales = GS.summary.totalSales + 1
				GS.summary.totalGoldSold = GS.summary.totalGoldSold + param5
				GS.summary.totalItemsSold = GS.summary.totalItemsSold + param3
				
			end
		end)
		
		listener:SetIterationCompletedCallback(function()
			GS.listenerActive[num] = false
			GS.PostSummary()
		end)
		
		listener:Start()
		GS.listenerActive[num] = true
		d("listener is setup for guild with ID: "..guildId)
	end
	
	local currentlySelectedValue = GuildSummary_GUISettingsComboboxGuilds.m_comboBox.m_selectedItemData.value
	if currentlySelectedValue == 0 then
		for i = 1, GetNumGuilds() do
			SetUpListener(i, GetGuildId(i), GUILD_HISTORY_STORE)
		end
	else
		SetUpListener(currentlySelectedValue, GetGuildId(currentlySelectedValue), GUILD_HISTORY_STORE)
	end
end

function GuildSummary.GetGuildsSummary()
	if LibHistoire == nil then 
		d("LibHistoire not found")
		return 
	end
	if LibHistoire.callback.INITIALIZED == "HistyIsReadyForAction" then 
		if
				GS.listenerActive[1] == false
			and GS.listenerActive[2] == false
			and GS.listenerActive[3] == false
			and GS.listenerActive[4] == false
			and GS.listenerActive[5] == false
			then
			GS.saleItems = nil
			GS.saleItems = {}
			
			GS.SetupEmptySummaryVars()			
			
			GuildSummary.SetUpListners()
			GuildSummary_GUIMultiLineText:SetText("Calculating....")
		else
			d("Already a summary calculation running")
		end		
	else 
		d("Histoire is not yet INITIALIZED")
	end
end

function GuildSummary.PostSummary()
	if
			GS.listenerActive[1] == false
		and GS.listenerActive[2] == false
		and GS.listenerActive[3] == false
		and GS.listenerActive[4] == false
		and GS.listenerActive[5] == false
		then	
		d("All information recieved, calculating summary now...")
		GS.SetInEditbox()
		d("Calculating Summary is done!")
	end
end

function GuildSummary.SetInEditbox()
	local fullOutput = ""
	
	local GenericSummaryHeaderString = GS.isDiscordOutput and GS.outputStrings.GenericSummary.discord or GS.outputStrings.GenericSummary.basic
	fullOutput = fullOutput .. GenericSummaryHeaderString
	fullOutput = string.format(GS.isDiscordOutput and GS.outputStrings.TotalSales.discord or GS.outputStrings.TotalSales.basic
		, fullOutput
		, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(GS.summary.totalSales))
	)
	fullOutput = string.format(GS.isDiscordOutput and GS.outputStrings.TotalItemsSold.discord or GS.outputStrings.TotalItemsSold.basic
		, fullOutput
		, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(GS.summary.totalItemsSold))
	)
	fullOutput = string.format(GS.isDiscordOutput and GS.outputStrings.TotalGoldSold.discord or GS.outputStrings.TotalGoldSold.basic
		, fullOutput
		, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(GS.summary.totalGoldSold))
	)
	fullOutput = string.format(GS.isDiscordOutput and GS.outputStrings.UniqueItemsSold.discord or GS.outputStrings.UniqueItemsSold.basic
		, fullOutput
		, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(#GS.saleItems))
	)
	
	if GS.amountHighestPriceSingleItemLines > 0 then 
		local HighestPriceHeaderString = GS.isDiscordOutput and GS.outputStrings.HighestPriceSingleItemHeader.discord or GS.outputStrings.HighestPriceSingleItemHeader.basic
		fullOutput = fullOutput .. HighestPriceHeaderString
		table.sort(GS.saleItems, function(k1, k2) return k1.highestPriceSingleItem > k2.highestPriceSingleItem end)
		for i = 1, GS.amountHighestPriceSingleItemLines, 1 do
			fullOutput = string.format(GS.isDiscordOutput and GS.outputStrings.HighestPriceSingleItem.discord or GS.outputStrings.HighestPriceSingleItem.basic
					, fullOutput
					, i
					, GS.saleItems[i].name
					, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(GS.saleItems[i].highestPriceSingleItem))
					, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(math.floor(GS.saleItems[i].highestPriceSingleItem/GS.summary.totalGoldSold*10000)/100))
				)
		end
	end
	
	if GS.amountMostSoldLines > 0 then 
		local MostSoldHeaderString = GS.isDiscordOutput and GS.outputStrings.MostSoldHeader.discord or GS.outputStrings.MostSoldHeader.basic
		fullOutput = fullOutput .. MostSoldHeaderString
		table.sort(GS.saleItems, function(k1, k2) return k1.quantitySold > k2.quantitySold end)
		for i = 1, GS.amountMostSoldLines, 1 do
			fullOutput = string.format(GS.isDiscordOutput and GS.outputStrings.MostSold.discord or GS.outputStrings.MostSold.basic
					, fullOutput
					, i
					, GS.saleItems[i].name
					, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(GS.saleItems[i].quantitySold))
					, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(math.floor(GS.saleItems[i].quantitySold/GS.summary.totalItemsSold*10000)/100))
					, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(GS.saleItems[i].amountOfSales))
					, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(math.floor(GS.saleItems[i].amountOfSales/GS.summary.totalSales*10000)/100))
				)
		end
	end
	
	if GS.amountTotalPriceLines > 0 then 
		local MostTotalPriceHeaderString = GS.isDiscordOutput and GS.outputStrings.TotalPriceHeader.discord or GS.outputStrings.TotalPriceHeader.basic
		fullOutput = fullOutput .. MostTotalPriceHeaderString
		table.sort(GS.saleItems, function(k1, k2) return k1.totalPrice > k2.totalPrice end)
		for i = 1, GS.amountTotalPriceLines, 1 do
			fullOutput = string.format(GS.isDiscordOutput and GS.outputStrings.TotalPrice.discord or GS.outputStrings.TotalPrice.basic
					, fullOutput
					, i
					, GS.saleItems[i].name
					, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(GS.saleItems[i].totalPrice))
					, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(math.floor(GS.saleItems[i].totalPrice/GS.summary.totalGoldSold*10000)/100))
					, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(GS.saleItems[i].amountOfSales))
					, zo_strformat("<<1>>", ZO_LocalizeDecimalNumber(math.floor(GS.saleItems[i].amountOfSales/GS.summary.totalSales*10000)/100))
				)
		end
	end
	
	local TimeRangeString = "\nData from " .. GS.summary.startDate .. " till ".. GS.summary.endDate .. "."
	
	fullOutput = fullOutput .. TimeRangeString
	
	GuildSummary_GUIMultiLineText:SetText(fullOutput)
end

function GuildSummary.GetMinMaxTime()
	local currentDate = os.date("*t")
	local minTime, maxTime = os.time(), os.time()
	local selectedTimeframe = GuildSummary_GUISettingsComboboxTimeRange.m_comboBox.m_selectedItemData.value
	
	if selectedTimeframe == 0 then
		local daySubtract = (3-(currentDate.wday < 3 and currentDate.wday + 7 or currentDate.wday))
		maxTime = os.time{
			year = currentDate.year,
			month = currentDate.month,
			day = currentDate.day + daySubtract ,
			hour = 14,
		}
		minTime = maxTime-7*24*60*60
	
	elseif selectedTimeframe == 1 then
		maxTime = os.time{
			year = currentDate.year,
			month = currentDate.month,
			day = 1 ,
			hour = 0,
		} - 1
		minTime = os.time{
			year = currentDate.year,
			month = currentDate.month - 1,
			day = 1 ,
			hour = 0,
		}
	end
	
	return minTime, maxTime
end
